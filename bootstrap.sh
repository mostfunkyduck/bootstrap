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
echo "installing ~/.custom_bashrc"
cp ./bashrc ~/.custom_bashrc
chmod o+x ~/.custom_bashrc
echo "after this runs, add 'source .custom_bashrc' to the regular bashrc"

### pylint ###
echo "installing ~/.pylint"
cp ./pylint ~/.pylint 

### tmux ###
echo "installing ~/.tmux.conf"
if [ -f ~/.tmux.conf ]; then
  cp ~/.tmux.conf ~/.tmux.conf.bootstrap.bkp
fi
cp tmux.conf ~/.tmux.conf

### Vim config ###
echo "installing vim plugins"
# pathogen
echo -ne "\tpathogen: "
# path for the vimrc to dump swpfiles in
mkdir -p ~/.vim/swpfiles
mkdir -p ~/.vim/autoload ~/.vim/bundle && \
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim 2>/dev/null && echo "ok" || echo "didn't install pathogen"

# Ale
echo -ne "\tale: "
mkdir -p ~/.vim/pack/git-plugins/start
git clone --depth 1 https://github.com/w0rp/ale.git ~/.vim/pack/git-plugins/start/ale 2>/dev/null && echo "ok" || echo "didn't install ale"

# NERDTree
echo -ne "\tnerdtree: "
git clone https://github.com/scrooloose/nerdtree.git ~/.vim/bundle/nerdtree 2>/dev/null && echo "ok" || echo "didn't install nerdtree"

# MBE
echo -ne "\tMBE: "
curl -LSso ~/.vim/autoload/minibufexpl.vim https://raw.githubusercontent.com/fholgado/minibufexpl.vim/master/plugin/minibufexpl.vim
git clone --depth 1 https://github.com/fholgado/minibufexpl.vim.git ~/.vim/pack/git-plugins/start/minibufexpl 2>/dev/null && echo "ok" || echo "didn't install minibufexplorer"

# .vimrc
echo "installing vimrc"
if [ -f ~/.vimrc ]; then
  cp ~/.vimrc ~/.vimrc.bootstrap.bkp
fi

cp ./vimrc ~/.vimrc

# gitignore
echo "installing gitignore_global"
if [ -e ~/.gitignore_global ]; then
  cp ~/.gitignore_global ~/.gitignore_global.bootstrap.bkp
fi
cp ./gitignore_global ~/.gitignore_global
git config --global core.excludesfile ~/.gitignore_global

# jq
echo "installing jq config"
if [ -e ~/.jq ]; then
  cp ~/.jq ~/.jq.bkp
fi
cp jq ~/.jq

# jira.d
echo "installing go-jira config"
if [ -d ~/.jira.d ]; then
  cp -r ~/.jira.d ~/.jira.d.backup
fi
rm -fr ~/.jira.d
cp -r jira.d ~/.jira.d
