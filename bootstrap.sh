#!/bin/bash

set -e

PACKAGES="jq vim tmux"
if which X; then
  PACKAGES+=('xclip')
fi
### packages ###
echo installing packages, sudo required
if which apt-get; then
  sudo apt-get -y install $PACKAGES
elif which yum; then
  sudo yum install -y $PACKAGES
else
  echo "could not find a package manager!"
fi

### Regular config ###
echo "installing $HOME/.custom_bashrc"
cp ./bashrc $HOME/.custom_bashrc
chmod o+x $HOME/.custom_bashrc
echo "after this runs, add 'source .custom_bashrc' to the regular bashrc"

### pylint ###
echo "installing $HOME/.pylint"
cp ./pylint $HOME/.pylint 

### tmux ###
echo "installing $HOME/.tmux.conf"
if [ -f $HOME/.tmux.conf ]; then
  cp $HOME/.tmux.conf $HOME/.tmux.conf.bootstrap.bkp
fi
cp tmux.conf $HOME/.tmux.conf

### Vim config ###
echo "installing vim plugins"
# pathogen
echo -ne "\tpathogen: "
# path for the vimrc to dump swpfiles in
mkdir -p $HOME/.vim/swpfiles
mkdir -p $HOME/.vim/autoload $HOME/.vim/bundle && \
curl -LSso $HOME/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim 2>/dev/null && echo "ok" || echo "didn't install pathogen"

function pull_or_clone() {
  if [ -d $2 ]; then
    git -C $2 pull && echo "ok" || echo "couldn't pull $3"
  else
    git clone $1 $2 && echo "ok" || echo "couldn't clone $3"
  fi  
}

# Bash my AWS
pull_or_clone "https://github.com/bash-my-aws/bash-my-aws.git" "$HOME/.bash-my-aws"
# Ale
echo -ne "\tale: "
mkdir -p $HOME/.vim/pack/git-plugins/start
pull_or_clone "https://github.com/w0rp/ale.git" "$HOME/.vim/pack/git-plugins/start/ale"

# NERDTree
echo -ne "\tnerdtree: "

pull_or_clone "https://github.com/scrooloose/nerdtree.git" "$HOME/.vim/bundle/nerdtree" "nerdtree"

# AnsiEsc
echo -ne "\tAnsiEsc: "
pull_or_clone "https://github.com/vim-scripts/AnsiEsc.vim.git" "$HOME/.vim/bundle/ansiesc" "ansiesc"

# MBE
echo -ne "\tMBE: "
curl -LSso $HOME/.vim/autoload/minibufexpl.vim https://raw.githubusercontent.com/fholgado/minibufexpl.vim/master/plugin/minibufexpl.vim
pull_or_clone "https://github.com/fholgado/minibufexpl.vim.git" "$HOME/.vim/pack/git-plugins/start/minibufexpl"

# .vimrc
echo "installing vimrc"
if [ -f $HOME/.vimrc ]; then
  cp $HOME/.vimrc $HOME/.vimrc.bootstrap.bkp
fi

cp ./vimrc $HOME/.vimrc

# gitignore
echo "installing gitignore_global"
if [ -e $HOME/.gitignore_global ]; then
  cp $HOME/.gitignore_global $HOME/.gitignore_global.bootstrap.bkp
fi
cp ./gitignore_global $HOME/.gitignore_global
git config --global core.excludesfile $HOME/.gitignore_global

# jq
echo "installing jq config"
if [ -e $HOME/.jq ]; then
  cp $HOME/.jq $HOME/.jq.bkp
fi
cp jq $HOME/.jq

# jira.d
echo "installing go-jira config"
if [ -d $HOME/.jira.d ]; then
  cp -r $HOME/.jira.d $HOME/.jira.d.backup
fi
rm -fr $HOME/.jira.d
cp -r jira.d $HOME/.jira.d

# fzf - not using pull_or_clone because it's cloning at depth 1
# TODO should pull_or_clone do the same thing? unclear...
if [ ! -d $HOME/.fzf ]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf
else
  git -C $HOME/.fzf pull https://github.com/junegunn/fzf.git
fi
echo "to install or upgrade fzf, run '$HOME/.fzf/install'"
