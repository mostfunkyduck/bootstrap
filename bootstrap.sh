#!/bin/bash

set -e

bootstrap_dir="$(cd "$(dirname "$0")" && pwd)"
usage() {
  >&2 echo "usage:"
  >&2 echo "$0 [--help] [--shell] [--brew] [--light]"
  >&2 echo ""
  >&2 echo "  --help show this message" 
  >&2 echo "  --shell configure all the shell and terminal stuff"
  >&2 echo "  --brew configure/install/update homebrew"
  >&2 echo "  --light run the lightweight parts of the bootstrap"
  exit 0
}
# prints all arguments in bold
bold() {
  echo -e "\e[1m$*\e[0m"
}

# prints all arguments in dim
dim() {
  echo -e "\e[2m$*\e[0m"
}

deploy_symlink() {
  filename="$1"
  if [ ! -e "$HOME/$filename" ] && [ ! -L "$HOME/$filename" ]; then
    bold "installing $filename"
    ln -s "$bootstrap_dir/$filename" "$HOME/$filename"
  else
    dim "$filename is already installed" >&2
  fi

}

configure_packages() {
  bold "installing packages, sudo required"
  if command -v apt-get >/dev/null; then
    sudo apt-get -y install build-essential weather-util zsh-syntax-highlighting
  elif command -v yum >/dev/null; then
    sudo yum -y groupinstall "Development Tools"
    sudo yum -y install weather-util
  else
    bold "could not find a package manager!"
  fi
}

configure_brew() {
  if [[ ! "$(uname -a)" =~ \ x86_64\   ]]; then
    bold "unsupported architecture for brew, will skip brew packages"
    return
  fi

  if ! command -v brew &>/dev/null; then
    dim "installing homebrew for linux" >&2
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi
  deploy_symlink ".Brewfile"
  brew bundle --global
}

configure_shell() {
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    bold "installing oh-my-zsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  else
    dim "oh-my-zsh is already installed" >&2
  fi 

  if [ ! -d "$HOME/.fzf" ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf" >&2
  else
    git -C "$HOME/.fzf" pull https://github.com/junegunn/fzf.git >&2
  fi
  bold "to install or upgrade fzf, run '$HOME/.fzf/install'" >&2

  deploy_symlink .wezterm.lua
  deploy_symlink .custom_bashrc

  # shellcheck disable=SC2016
  bashrc_source_line='source "$HOME/.custom_bashrc"'
  grep "$bashrc_source_line" "$HOME/.bashrc" &>/dev/null || echo "$bashrc_source_line" >> "$HOME/.bashrc"

  ### pylint ###
  deploy_symlink .pylint

  ### tmux ###
  # gotta do this because tmux will continuously redeploy this directory if it's preconfigured
  deploy_symlink .config/tmux-powerline/config.sh
  deploy_symlink .config/tmux-powerline/themes
  deploy_symlink .config/tmux-powerline/segments

  deploy_symlink .tmux/plugins/get-weather
  deploy_symlink .tmux.conf
  # gitignore
  deploy_symlink .gitignore_global
  git config --global core.excludesfile "$HOME/.gitignore_global"

  deploy_symlink .custom_zshrc
  # shellcheck disable=SC2016
  zshrc_source_line='source "$HOME/.custom_zshrc"'
  grep "$zshrc_source_line" "$HOME/.zshrc" &>/dev/null || echo "$zshrc_source_line" >> "$HOME/.zshrc"

  # vim stuff
  mkdir -p "$HOME/.vim/swpfiles"
  deploy_symlink .vimrc
  deploy_symlink .config/nvim
}

run_light() {
  configure_shell
}

run_normal() {
  configure_packages
  configure_brew
  run_light
}

# parses the arguments to determine which configuration to deploy
apply_arguments() {
  args=("$@")
  for arg in "${args[@]}"; do
    case "$arg" in
      --packages)
        bold "configuring packages"
        configure_packages
        ;;
      --shell)
        bold "configuring shell"
        configure_shell
        ;;
      --brew)
        bold "configuring brew"
        configure_brew
        ;;
      --help)
        usage
        ;;
    esac
  done
}
####

# shellcheck disable=SC2207
args=($(getopt -o l --long packages --long light --long help --long vim --long shell --long brew -- "$@"))
# shellcheck disable=SC2181
if [[ $? != 0 ]]; then
  echo "incorrect or illegal arguments provided"
  exit 1
fi

# determine if we need to short circuit which components to run due to --light being passed in
LIGHTMODE=0

for arg in "${args[@]}"; do
  case "$arg" in
    --light)
      LIGHTMODE=1
      break;
      ;;
  esac
done

if [ $LIGHTMODE == 1 ]; then
  bold "running in light mode"
  run_light
elif [ $# == 0 ]; then
  bold "running in normal mode"
  run_normal
else
  apply_arguments "${args[@]}"
fi
