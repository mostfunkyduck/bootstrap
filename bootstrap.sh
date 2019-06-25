#!/bin/bash -v

set -e

### Regular config ###
echo "installing ~/.bashrc"
cp ~/.bashrc ~/.bashrc.bootstrap.bkp
cp ./bashrc ~/.bashrc
chmod o+x ~/.bashrc

### tmux ###
echo "installing ~/.tmux.conf"
cp ~/.tmux.conf ~/.tmux.conf.bootstrap.bkp
cp tmux.conf ~/.tmux.conf

### Vim config ###
echo "installing vim plugins"
# pathogen
echo -ne "\tpathogen: "
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
cp ~/.vimrc ~/.vimrc.bootstrap.bkp
cp ./vimrc ~/.vimrc

# gitignore
echo "installing gitignore_global"
cp ~/.gitignore_global ~/.gitignore_global.bootstrap.bkp
cp ./gitignore_global ~/.gitignore_global
git config --global core.excludesfile ~/.gitignore_global
