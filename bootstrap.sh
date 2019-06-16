### Regular config ###
cp ~/.bashrc ~/.bashrc.bak
cp ./bashrc ~/.bashrc
chmod o+x ~/.bashrc
. ~/.bashrc

### tmux ###
cp ~/.tmux.conf ~/.tmux.conf.bootstrap.bkp
cp tmux.conf ~/.tmux.conf

### Vim config ###
# pathogen
mkdir -p ~/.vim/autoload ~/.vim/bundle && \
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

# Ale
mkdir -p ~/.vim/pack/git-plugins/start
git clone --depth 1 https://github.com/w0rp/ale.git ~/.vim/pack/git-plugins/start/ale

# NERDTree
git clone https://github.com/scrooloose/nerdtree.git ~/.vim/bundle/nerdtree

# MBE
curl -LSso ~/.vim/autoload/minibufexpl.vim https://raw.githubusercontent.com/fholgado/minibufexpl.vim/master/plugin/minibufexpl.vim
git clone --depth 1 https://github.com/fholgado/minibufexpl.vim.git ~/.vim/pack/git-plugins/start/minibufexpl
