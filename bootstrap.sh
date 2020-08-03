#!/bin/bash

set -e

configure_packages() {
  PACKAGES="jq vim tmux ctags sysstat shellcheck neovim cscope"
  if command -v X && [[ -n $WSL_DISTRO_NAME ]]; then
    PACKAGES+=('xclip')
  fi

  echo installing packages, sudo required
  if command -v apt-get >/dev/null; then
    # shellcheck disable=SC2128,SC2086
    sudo apt-get -y install $PACKAGES build-essential
  elif command -v yum >/dev/null; then
    sudo yum -y groupinstall "Development Tools"
    # shellcheck disable=SC2128,SC2086
    sudo yum install -y $PACKAGES
  elif command -v dnf >/dev/null; then
    # shellcheck disable=SC2128,SC2086
    sudo dnf install -y $PACKAGES
  else
  echo "could not find a package manager!"
  fi
}

configure_brew() {
  echo installing homebrew for linux
  if [[ ! -d /home/linuxbrew ]]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi

  # don't run this unless we have to, it's slow
  if ! command -v mockery >/dev/null; then
    brew install vektra/tap/mockery
    brew upgrade mockery
  fi

  if ! command -v go >/dev/null; then
    brew install go
  fi
}

configure_xinitrc() {
  echo "installing $HOME/.xinitrc"
  if [[ -f $HOME/.xinitrc ]]; then
    echo "backing up old $HOME/.xinitrc to $HOME/.xinitrc.bak"
    mv "$HOME/.xinitrc" "$HOME/.xinitrc.bak"
  fi
  cp ./xinitrc "$HOME/.xinitrc"
}

configure_shell() {
  echo "installing $HOME/.custom_bashrc"
  cp ./bashrc "$HOME/.custom_bashrc"
  chmod o+x "$HOME/.custom_bashrc"
  echo "after this runs, add 'source .custom_bashrc' to the regular bashrc"

  ### pylint ###
  echo "installing $HOME/.pylint"
  cp ./pylint "$HOME/.pylint"

  ### tmux ###
  echo "installing $HOME/.tmux.conf"
  if [ -f "$HOME/.tmux.conf" ]; then
    cp "$HOME/.tmux.conf" "$HOME/.tmux.conf.bootstrap.bkp"
  fi
  cp tmux.conf "$HOME/.tmux.conf"

  # gitignore
  echo "installing gitignore_global"
  if [ -e "$HOME/.gitignore_global" ]; then
    cp "$HOME/.gitignore_global" "$HOME/.gitignore_global.bootstrap.bkp"
  fi
  cp ./gitignore_global "$HOME/.gitignore_global"
  git config --global core.excludesfile "$HOME/.gitignore_global"

  # jq
  echo "installing jq config"
  if [ -e "$HOME/.jq" ]; then
    cp "$HOME/.jq" "$HOME/.jq.bkp"
  fi
  cp jq "$HOME/.jq"

}

pull_or_clone() {
  echo -ne "\t$3: "
  if [ -d "$2/.git" ]; then
    git -C "$2" pull || echo "couldn't pull $1"
  else
    mkdir -p "$2"
    git clone "$1" "$2" || echo "couldn't clone $1"
  fi
}

configure_vim_extensions() {
  echo "installing vim plugins"
  # pathogen
  echo -ne "\tpathogen: "
  mkdir -p "$HOME/.vim/autoload" "$HOME/.vim/bundle" && \
  if [[ ! -f $HOME/.vim/autoload/pathogen.vim ]]; then
    curl -LSso "$HOME/.vim/autoload/pathogen.vim" https://tpo.pe/pathogen.vim 2>/dev/null | tr -d "\n" && echo "ok" || echo "didn't install pathogen"
  else
    echo "ok"
  fi


  # Bash my AWS
  pull_or_clone "https://github.com/bash-my-aws/bash-my-aws.git" "$HOME/.bash-my-aws" "bash-my-aws"
  # Ale - pulling from my fork because PR #3191 in the main repo needs to be in there or go won't work
  pull_or_clone "https://github.com/mostfunkyduck/ale.git" "$HOME/.vim/pack/git-plugins/start/ale" "ale"

  # NERDTree
  pull_or_clone "https://github.com/scrooloose/nerdtree.git" "$HOME/.vim/bundle/nerdtree" "nerdtree"

  # AnsiEsc
  pull_or_clone "https://github.com/vim-scripts/AnsiEsc.vim.git" "$HOME/.vim/bundle/ansiesc" "ansiesc"
}

configure_vim() {
  # path for the vimrc to dump swpfiles in
  mkdir -p "$HOME/.vim/swpfiles"

  # .vimrc
  echo "installing vimrc"
  if [ -f "$HOME/.vimrc" ]; then
    cp "$HOME/.vimrc" "$HOME/.vimrc.bootstrap.bkp"
  fi

  cp ./vimrc "$HOME/.vimrc"

  # nvim
  echo "installing init.vim for nvim"
  mkdir -p "$HOME/.config/nvim"

  if [[ -f "$HOME/.config/nvim/init.vim" ]]; then
    cp "$HOME/.config/nvim/init.vim" "$HOME/.config/nvim/init.vim.bak"
  fi

  cp init.vim "$HOME/.config/nvim/init.vim"

}

configure_bash_extensions() {
  # fzf - not using pull_or_clone because it's cloning at depth 1
  # TODO should pull_or_clone do the same thing? unclear...
  if [ ! -d "$HOME/.fzf" ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
  else
    git -C "$HOME/.fzf" pull https://github.com/junegunn/fzf.git
  fi
  echo "to install or upgrade fzf, run '$HOME/.fzf/install'"
}

run_light() {
  configure_vim
  configure_shell
  configure_xinitrc
}

run_normal() {
  configure_packages
  configure_brew
  configure_bash_extensions
  configure_vim_extensions
  run_light
}
####

# shellcheck disable=SC2207
arg=($(getopt -o l --long light -- "$@"))
# shellcheck disable=SC2181
if [[ $? != 0 ]]; then
  echo "incorrect or illegal arguments provided"
  exit 1
fi

for arg in "${arg[@]}"; do
  case "$arg" in
    --light)
      run_light
      break;
      ;;
    --|*)
      run_normal
      break
      ;;
  esac
done
