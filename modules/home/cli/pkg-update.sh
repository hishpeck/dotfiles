# Lazy-style updater for custom apps installed on this host (anything defined in custom-apps/
# that downloads a GitHub release asset). Pick in fzf; bumps version + URL in the app's file and
# lets nix-update fix the hash. Esc / nothing picked = skip updates (exit 0), so `niup` carries on.

flake="${DOTFILES:-$HOME/dotfiles}"
host=$(hostname)

# Discovered from what's actually installed (system + Home Manager packages) on this host.
if ! apps=$(nix eval --json "$flake#nixosConfigurations.\"$host\".config" --apply '
  c: let
    ps = c.environment.systemPackages
      ++ builtins.concatLists (map (u: u.home.packages) (builtins.attrValues c.home-manager.users));
    url = p: builtins.head (p.src.urls or [ (p.src.url or "") ]);
    dir = p: builtins.match ".*/(custom-apps/[^/]+)/.*" (p.meta.position or "");
    ok = p: dir p != null && p ? version
      && builtins.match "https://github.com/[^/]+/[^/]+/releases/download/.*" (url p) != null;
  in map (p: { dir = builtins.head (dir p); inherit (p) version; url = url p; }) (builtins.filter ok ps)
' 2>/dev/null); then
  echo "pkg-update: couldn't evaluate nixosConfigurations.$host in $flake, skipping"
  exit 0
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir "$tmp/apps"

echo "pkg-update: checking releases..."
while IFS=$'\t' read -r dir version url; do
  (
    name=${dir#custom-apps/}
    repo=$(sed -nE 's#^https://github\.com/([^/]+/[^/]+)/.*#\1#p' <<<"$url")
    tag=$(gh api "repos/$repo/releases/latest" -q .tag_name 2>/dev/null) || tag=""
    latest=${tag#v}
    if [[ -z $latest ]]; then status="?"; latest="?"
    elif [[ $latest == "$version" ]]; then status="✓"
    else status="↑"; fi
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
      "$status" "$name" "$version" "$latest" "$repo" "$tag" "$dir" "$url" >"$tmp/apps/$name"
  ) &
done < <(jq -r 'unique[] | [.dir, .version, .url] | @tsv' <<<"$apps")
wait

if ! grep -qh '^↑' "$tmp"/apps/*; then
  echo "pkg-update: all custom apps up to date"
  exit 0
fi

rows=$(grep -h '^↑' "$tmp"/apps/*; grep -hv '^↑' "$tmp"/apps/* || true)

# fzf exits 1 on no match / 130 on Esc; both mean "skip updates"
picked=$(cut -f1-5 <<<"$rows" | column -t -s $'\t' -o '   ' | fzf --multi \
  --header 'TAB select · ENTER update selected · ESC skip · ✓ up to date  ↑ outdated  ? unknown' \
  --preview 'gh release view -R {5} 2>/dev/null || echo "no release notes"' \
  --preview-window 'right,60%,wrap' \
  --bind 'ctrl-a:select-all') || exit 0

while read -r _ name _; do
  IFS=$'\t' read -r status _ current latest repo tag dir url <"$tmp/apps/$name"
  [[ $status != "↑" ]] && { echo "skip $name ($status)"; continue; }
  file="$flake/$dir/default.nix"
  old_asset=${url##*/}

  # Same filename with the new version, unless the release names its files differently
  # (e.g. Bambu Studio adds a build timestamp) - then pick the asset by hand.
  assets=$(gh release view "$tag" -R "$repo" --json assets -q '.assets[].name')
  new_asset=${old_asset//"$current"/"$latest"}
  if ! grep -qxF "$new_asset" <<<"$assets"; then
    new_asset=$(fzf --header "$name $latest: pick the release file (was $old_asset)" \
      --query "${old_asset##*.}" <<<"$assets") || { echo "skip $name"; continue; }
  fi

  # The file spells the URL with ${version}; rewrite that template and the version string.
  # shellcheck disable=SC2016 # literal Nix ${version}, not a shell expansion
  old_t=${old_asset//"$current"/'${version}'}
  # shellcheck disable=SC2016
  new_t=${new_asset//"$latest"/'${version}'}
  src=$(<"$file")
  if [[ $src != *"version = \"$current\""* || $src != *"$old_t"* ]]; then
    echo "!! $name: couldn't find version/URL in $file, update it by hand"
    continue
  fi
  src=${src//"version = \"$current\""/"version = \"$latest\""}
  src=${src//"$old_t"/"$new_t"}
  printf '%s\n' "$src" >"$file"

  echo "==> $name $current → $latest"
  printf '{ ... }: { "%s" = (import <nixpkgs> { config.allowUnfree = true; }).callPackage %s { }; }\n' \
    "$name" "$flake/$dir" >"$tmp/pkgs.nix"
  nix-update -f "$tmp/pkgs.nix" --version skip "$name"
done <<<"$picked"

git -C "$flake" --no-pager diff --stat -- custom-apps
