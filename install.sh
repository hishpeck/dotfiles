git clone --bare git@github.com:hishpeck/dotfiles.git $HOME/dotfiles
function my-config {
   /usr/bin/git --git-dir=$HOME/dotfiles/ --work-tree=$HOME $@
}
mkdir -p .config-backup
my-config checkout
if [ $? = 0 ]; then
  echo "Checked out config.";
  else
    echo "Backing up pre-existing dot files.";
    my-config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .config-backup/{}
fi;
my-config checkout
my-config config status.showUntrackedFiles no
