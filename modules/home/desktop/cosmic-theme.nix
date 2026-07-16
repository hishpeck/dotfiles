{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

let
  # ── User-facing knobs ────────────────────────────────────────────────────────
  gaps = "(0, 8)";
  activeHint = "3";
  isFrosted = "true";

  # ── Driven by global catppuccin options (set in theme.nix) ──────────────────
  accent = config.catppuccin.accent;
  lightFlavor = config.catppuccin.flavor;
  darkFlavor = "mocha";

  # ── Static COSMIC defaults (same as COSMIC ships) ───────────────────────────
  cornerRadii = ''
    (
        radius_0: (0.0, 0.0, 0.0, 0.0),
        radius_xs: (4.0, 4.0, 4.0, 4.0),
        radius_s: (8.0, 8.0, 8.0, 8.0),
        radius_m: (16.0, 16.0, 16.0, 16.0),
        radius_l: (32.0, 32.0, 32.0, 32.0),
        radius_xl: (160.0, 160.0, 160.0, 160.0),
    )'';

  spacing = ''
    (
        space_none: 0,
        space_xxxs: 4,
        space_xxs: 8,
        space_xs: 12,
        space_s: 16,
        space_m: 24,
        space_l: 32,
        space_xl: 48,
        space_xxl: 64,
        space_xxxl: 128,
    )'';

  # ── Helpers ──────────────────────────────────────────────────────────────────
  # For fields that take (red, green, blue, alpha) — bg_color, primary/secondary
  mkColor = r: g: b: ''
    Some((
        red: ${r},
        green: ${g},
        blue: ${b},
        alpha: 1.0,
    ))'';

  # For fields that take (red, green, blue) without alpha — accent, text_tint, etc.
  mkColor3 = r: g: b: ''
    Some((
        red: ${r},
        green: ${g},
        blue: ${b},
    ))'';

  # ── Catppuccin Latte palette (RON) ───────────────────────────────────────────
  lattePalette = ''
    Light((
        name: "Catppuccin-Latte",
        blue: (red: 0.11764706, green: 0.40000000, blue: 0.96078431, alpha: 1.0),
        red: (red: 0.82352941, green: 0.05882353, blue: 0.22352941, alpha: 1.0),
        green: (red: 0.25098039, green: 0.62745098, blue: 0.16862745, alpha: 1.0),
        yellow: (red: 0.87450980, green: 0.55686275, blue: 0.11372549, alpha: 1.0),
        gray_1: (red: 0.90196078, green: 0.91372549, blue: 0.93725490, alpha: 1.0),
        gray_2: (red: 0.93725490, green: 0.94509804, blue: 0.96078431, alpha: 1.0),
        gray_3: (red: 0.80000000, green: 0.81568627, blue: 0.85490196, alpha: 1.0),
        neutral_0: (red: 0.86274510, green: 0.87843137, blue: 0.90980392, alpha: 1.0),
        neutral_1: (red: 0.90196078, green: 0.91372549, blue: 0.93725490, alpha: 1.0),
        neutral_2: (red: 0.93725490, green: 0.94509804, blue: 0.96078431, alpha: 1.0),
        neutral_3: (red: 0.80000000, green: 0.81568627, blue: 0.85490196, alpha: 1.0),
        neutral_4: (red: 0.73725490, green: 0.75294118, blue: 0.80000000, alpha: 1.0),
        neutral_5: (red: 0.67450980, green: 0.69019608, blue: 0.74509804, alpha: 1.0),
        neutral_6: (red: 0.61176471, green: 0.62745098, blue: 0.69019608, alpha: 1.0),
        neutral_7: (red: 0.54901961, green: 0.56078431, blue: 0.63137255, alpha: 1.0),
        neutral_8: (red: 0.48627451, green: 0.49803922, blue: 0.57647059, alpha: 1.0),
        neutral_9: (red: 0.42352941, green: 0.43529412, blue: 0.52156863, alpha: 1.0),
        neutral_10: (red: 0.36078431, green: 0.37254902, blue: 0.46666667, alpha: 1.0),
        bright_green: (red: 0.25098039, green: 0.62745098, blue: 0.16862745, alpha: 1.0),
        bright_red: (red: 0.82352941, green: 0.05882353, blue: 0.22352941, alpha: 1.0),
        bright_orange: (red: 0.99607843, green: 0.39215686, blue: 0.04313725, alpha: 1.0),
        ext_warm_grey: (red: 0.48627451, green: 0.49803922, blue: 0.57647059, alpha: 1.0),
        ext_orange: (red: 0.99607843, green: 0.39215686, blue: 0.04313725, alpha: 1.0),
        ext_yellow: (red: 0.87450980, green: 0.55686275, blue: 0.11372549, alpha: 1.0),
        ext_blue: (red: 0.11764706, green: 0.40000000, blue: 0.96078431, alpha: 1.0),
        ext_purple: (red: 0.44705882, green: 0.52941176, blue: 0.99215686, alpha: 1.0),
        ext_pink: (red: 0.91764706, green: 0.46274510, blue: 0.79607843, alpha: 1.0),
        ext_indigo: (red: 0.53333333, green: 0.22352941, blue: 0.93725490, alpha: 1.0),
        accent_blue: (red: 0.11764706, green: 0.40000000, blue: 0.96078431, alpha: 1.0),
        accent_red: (red: 0.82352941, green: 0.05882353, blue: 0.22352941, alpha: 1.0),
        accent_green: (red: 0.25098039, green: 0.62745098, blue: 0.16862745, alpha: 1.0),
        accent_warm_grey: (red: 0.48627451, green: 0.49803922, blue: 0.57647059, alpha: 1.0),
        accent_orange: (red: 0.99607843, green: 0.39215686, blue: 0.04313725, alpha: 1.0),
        accent_yellow: (red: 0.87450980, green: 0.55686275, blue: 0.11372549, alpha: 1.0),
        accent_purple: (red: 0.44705882, green: 0.52941176, blue: 0.99215686, alpha: 1.0),
        accent_pink: (red: 0.91764706, green: 0.46274510, blue: 0.79607843, alpha: 1.0),
        accent_indigo: (red: 0.53333333, green: 0.22352941, blue: 0.93725490, alpha: 1.0),
    ))'';

  # ── Catppuccin Mocha palette (RON) ───────────────────────────────────────────
  mochaPalette = ''
    Dark((
        name: "Catppuccin-Mocha",
        blue: (red: 0.53725490, green: 0.70588235, blue: 0.98039216, alpha: 1.0),
        red: (red: 0.95294118, green: 0.54509804, blue: 0.65882353, alpha: 1.0),
        green: (red: 0.65098039, green: 0.89019608, blue: 0.63137255, alpha: 1.0),
        yellow: (red: 0.97647059, green: 0.88627451, blue: 0.68627451, alpha: 1.0),
        gray_1: (red: 0.09411765, green: 0.09411765, blue: 0.14509804, alpha: 1.0),
        gray_2: (red: 0.11764706, green: 0.11764706, blue: 0.18039216, alpha: 1.0),
        gray_3: (red: 0.19215686, green: 0.19607843, blue: 0.26666667, alpha: 1.0),
        neutral_0: (red: 0.06666667, green: 0.06666667, blue: 0.10588235, alpha: 1.0),
        neutral_1: (red: 0.09411765, green: 0.09411765, blue: 0.14509804, alpha: 1.0),
        neutral_2: (red: 0.11764706, green: 0.11764706, blue: 0.18039216, alpha: 1.0),
        neutral_3: (red: 0.19215686, green: 0.19607843, blue: 0.26666667, alpha: 1.0),
        neutral_4: (red: 0.27058824, green: 0.27843137, blue: 0.35294118, alpha: 1.0),
        neutral_5: (red: 0.34509804, green: 0.35686275, blue: 0.43921569, alpha: 1.0),
        neutral_6: (red: 0.42352941, green: 0.43921569, blue: 0.52549020, alpha: 1.0),
        neutral_7: (red: 0.49803922, green: 0.51764706, blue: 0.61176471, alpha: 1.0),
        neutral_8: (red: 0.57647059, green: 0.60000000, blue: 0.69803922, alpha: 1.0),
        neutral_9: (red: 0.65098039, green: 0.67843137, blue: 0.78431373, alpha: 1.0),
        neutral_10: (red: 0.72941176, green: 0.76078431, blue: 0.87058824, alpha: 1.0),
        bright_green: (red: 0.65098039, green: 0.89019608, blue: 0.63137255, alpha: 1.0),
        bright_red: (red: 0.95294118, green: 0.54509804, blue: 0.65882353, alpha: 1.0),
        bright_orange: (red: 0.98039216, green: 0.70196078, blue: 0.52941176, alpha: 1.0),
        ext_warm_grey: (red: 0.57647059, green: 0.60000000, blue: 0.69803922, alpha: 1.0),
        ext_orange: (red: 0.98039216, green: 0.70196078, blue: 0.52941176, alpha: 1.0),
        ext_yellow: (red: 0.97647059, green: 0.88627451, blue: 0.68627451, alpha: 1.0),
        ext_blue: (red: 0.53725490, green: 0.70588235, blue: 0.98039216, alpha: 1.0),
        ext_purple: (red: 0.70588235, green: 0.74509804, blue: 0.99607843, alpha: 1.0),
        ext_pink: (red: 0.96078431, green: 0.76078431, blue: 0.90588235, alpha: 1.0),
        ext_indigo: (red: 0.79607843, green: 0.65098039, blue: 0.96862745, alpha: 1.0),
        accent_blue: (red: 0.53725490, green: 0.70588235, blue: 0.98039216, alpha: 1.0),
        accent_red: (red: 0.95294118, green: 0.54509804, blue: 0.65882353, alpha: 1.0),
        accent_green: (red: 0.65098039, green: 0.89019608, blue: 0.63137255, alpha: 1.0),
        accent_warm_grey: (red: 0.57647059, green: 0.60000000, blue: 0.69803922, alpha: 1.0),
        accent_orange: (red: 0.98039216, green: 0.70196078, blue: 0.52941176, alpha: 1.0),
        accent_yellow: (red: 0.97647059, green: 0.88627451, blue: 0.68627451, alpha: 1.0),
        accent_purple: (red: 0.70588235, green: 0.74509804, blue: 0.99607843, alpha: 1.0),
        accent_pink: (red: 0.96078431, green: 0.76078431, blue: 0.90588235, alpha: 1.0),
        accent_indigo: (red: 0.79607843, green: 0.65098039, blue: 0.96862745, alpha: 1.0),
    ))'';

  palettes = {
    latte = lattePalette;
    mocha = mochaPalette;
  };

  # ── Semantic colors per flavor ───────────────────────────────────────────────
  # bg_color uses mkColor (with alpha); the rest use mkColor3 (no alpha)
  semantic = {
    latte = {
      bg = mkColor "0.93725490" "0.94509804" "0.96078431"; # Base
      text = mkColor3 "0.29803922" "0.30980392" "0.41176471"; # Text
      success = mkColor3 "0.25098039" "0.62745098" "0.16862745"; # Green
      warning = mkColor3 "0.87450980" "0.55686275" "0.11372549"; # Yellow
      destructive = mkColor3 "0.82352941" "0.05882353" "0.22352941"; # Red
    };
    mocha = {
      bg = mkColor "0.11764706" "0.11764706" "0.18039216"; # Base
      text = mkColor3 "0.80392157" "0.83921569" "0.95686275"; # Text
      success = mkColor3 "0.65098039" "0.89019608" "0.63137255"; # Green
      warning = mkColor3 "0.97647059" "0.88627451" "0.68627451"; # Yellow
      destructive = mkColor3 "0.95294118" "0.54509804" "0.65882353"; # Red
    };
  };

  # ── Accent color lookup — Catppuccin Latte ───────────────────────────────────
  latteAccents = {
    rosewater = mkColor3 "0.86274510" "0.54509804" "0.54117647";
    flamingo = mkColor3 "0.91764706" "0.46274510" "0.52156863";
    pink = mkColor3 "0.91764706" "0.46274510" "0.79607843";
    mauve = mkColor3 "0.53333333" "0.22352941" "0.93725490";
    red = mkColor3 "0.82352941" "0.05882353" "0.22352941";
    maroon = mkColor3 "0.90196078" "0.31764706" "0.39215686";
    peach = mkColor3 "0.99607843" "0.39215686" "0.04313725";
    yellow = mkColor3 "0.87450980" "0.55686275" "0.11372549";
    green = mkColor3 "0.25098039" "0.62745098" "0.16862745";
    teal = mkColor3 "0.09803922" "0.61960784" "0.61176471";
    sky = mkColor3 "0.02352941" "0.63529412" "0.91372549";
    sapphire = mkColor3 "0.12549020" "0.52156863" "0.82352941";
    blue = mkColor3 "0.11764706" "0.40000000" "0.96078431";
    lavender = mkColor3 "0.44705882" "0.52941176" "0.99215686";
  };

  # ── Accent color lookup — Catppuccin Mocha ───────────────────────────────────
  mochaAccents = {
    rosewater = mkColor3 "0.94901961" "0.74901961" "0.72549020";
    flamingo = mkColor3 "0.95686275" "0.74117647" "0.76078431";
    pink = mkColor3 "0.96078431" "0.76078431" "0.90588235";
    mauve = mkColor3 "0.81176471" "0.62352941" "0.97254902";
    red = mkColor3 "0.95294118" "0.54509804" "0.65882353";
    maroon = mkColor3 "0.92156863" "0.60392157" "0.67843137";
    peach = mkColor3 "0.98039216" "0.70196078" "0.52941176";
    yellow = mkColor3 "0.97647059" "0.88627451" "0.68627451";
    green = mkColor3 "0.65098039" "0.89019608" "0.63137255";
    teal = mkColor3 "0.58823529" "0.92156863" "0.81960784";
    sky = mkColor3 "0.53333333" "0.90196078" "0.93725490";
    sapphire = mkColor3 "0.45490196" "0.79607843" "0.93725490";
    blue = mkColor3 "0.53725490" "0.70588235" "0.98039216";
    lavender = mkColor3 "0.70588235" "0.74509804" "0.99607843";
  };

  accentColors = {
    latte = latteAccents;
    mocha = mochaAccents;
  };

  # ── Resolved values ──────────────────────────────────────────────────────────
  lightSemantic = semantic.${lightFlavor};
  darkSemantic = semantic.${darkFlavor};
  lightAccent = accentColors.${lightFlavor}.${accent};
  darkAccent = accentColors.${darkFlavor}.${accent};

  # ── Builder file helper ──────────────────────────────────────────────────────
  # Returns an attrset of home.file entries for one theme variant
  mkBuilder = variant: pal: sem: acc: {
    ".config/cosmic/com.system76.CosmicTheme.${variant}.Builder/v1/palette".text = pal;
    ".config/cosmic/com.system76.CosmicTheme.${variant}.Builder/v1/accent".text = acc;
    ".config/cosmic/com.system76.CosmicTheme.${variant}.Builder/v1/window_hint".text = acc;
    ".config/cosmic/com.system76.CosmicTheme.${variant}.Builder/v1/bg_color".text = sem.bg;
    ".config/cosmic/com.system76.CosmicTheme.${variant}.Builder/v1/text_tint".text = sem.text;
    ".config/cosmic/com.system76.CosmicTheme.${variant}.Builder/v1/success".text = sem.success;
    ".config/cosmic/com.system76.CosmicTheme.${variant}.Builder/v1/warning".text = sem.warning;
    ".config/cosmic/com.system76.CosmicTheme.${variant}.Builder/v1/destructive".text = sem.destructive;
    # Keep as None — COSMIC derives sane values from the palette
    ".config/cosmic/com.system76.CosmicTheme.${variant}.Builder/v1/neutral_tint".text = "None";
    ".config/cosmic/com.system76.CosmicTheme.${variant}.Builder/v1/primary_container_bg".text = "None";
    ".config/cosmic/com.system76.CosmicTheme.${variant}.Builder/v1/secondary_container_bg".text =
      "None";
    # User-facing knobs (top of file)
    ".config/cosmic/com.system76.CosmicTheme.${variant}.Builder/v1/gaps".text = gaps;
    ".config/cosmic/com.system76.CosmicTheme.${variant}.Builder/v1/active_hint".text = activeHint;
    ".config/cosmic/com.system76.CosmicTheme.${variant}.Builder/v1/is_frosted".text = isFrosted;
    # COSMIC defaults — no reason to change these outside COSMIC Settings
    ".config/cosmic/com.system76.CosmicTheme.${variant}.Builder/v1/corner_radii".text = cornerRadii;
    ".config/cosmic/com.system76.CosmicTheme.${variant}.Builder/v1/spacing".text = spacing;
  };

in
{
  # CosmicTheme.Mode (light/dark toggle) is intentionally not managed here —
  # the user controls that at runtime via COSMIC Settings.
  config = {
    home.packages = [
      inputs.cosmic-ctl.packages.${pkgs.stdenv.hostPlatform.system}.cosmic-ext-ctl
    ];

    home.activation.buildCosmicTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if command -v cosmic-ctl &>/dev/null; then
        $DRY_RUN_CMD cosmic-ctl build-theme
      fi
    '';

    home.file = lib.mapAttrs (name: value: value // { force = true; }) (
      (mkBuilder "Light" palettes.${lightFlavor} lightSemantic lightAccent)
      // (mkBuilder "Dark" palettes.${darkFlavor} darkSemantic darkAccent)
    );
  };
}
