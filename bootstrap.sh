#!/bin/bash

set -e

function usage() {
  >&2 echo "usage:"
  >&2 echo "$0 [--help] [--bash] [--vim] [--brew] [--light]"
  >&2 echo ""
  >&2 echo "--help show this message" 
  >&2 echo "--vim configure vim extensions"
  >&2 echo "--bash configure bashrc and bash scripts"
  >&2 echo "--brew configure/install/update homebrew"
  >&2 echo "--light run the lightweight parts of the bootstrap"
  exit 0
}
# prints all arguments in bold
function bold() {
  echo -e "\e[1m$*\e[0m"
}

# prints all arguments in dim
function dim() {
  echo -e "\e[2m$*\e[0m"
}

configure_packages() {
  PACKAGES="jq vim tmux universal-ctags sysstat shellcheck cscope golang-cfssl"
  if command -v X >/dev/null && [[ -z $WSL_DISTRO_NAME ]]; then
    PACKAGES+=" xclip"
  fi

  bold "installing packages, sudo required"
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
    bold "could not find a package manager!"
  fi
}

configure_brew() {
  if [[ ! "$(uname -a)" =~ \ x86_64\   ]]; then
    bold "unsupported architecture for brew, will skip brew packages"
    return
  fi

  if [[ ! -d /home/linuxbrew ]]; then
    dim "installing homebrew for linux" >&2
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi

  # run an upgrade check, could be slow, but will keep brew and its packages up to date
  brew upgrade
  brewPackages=(
    vektra/tap/mockery
    go
    gopls
    gh
    jsonlint
  )
  for package in "${brewPackages[@]}"; do
    # remove package name down to the executable
    if ! command -v "${package/*\//}" > /dev/null; then
      dim "installing $package" >&2
      brew install "$package"
    fi
  done
}

configure_shell() {
  dim "installing $HOME/.custom_bashrc" >&2
  cp ./bashrc "$HOME/.custom_bashrc"
  chmod o+x "$HOME/.custom_bashrc"
  bold "after this runs, add 'source .custom_bashrc' to the regular bashrc"

  ### pylint ###
  dim "installing $HOME/.pylint" >&2
  cp ./pylint "$HOME/.pylint"

  ### tmux ###
  dim "installing $HOME/.tmux.conf" >&2
  if [ -f "$HOME/.tmux.conf" ]; then
    cp "$HOME/.tmux.conf" "$HOME/.tmux.conf.bootstrap.bkp"
  fi
  cp tmux.conf "$HOME/.tmux.conf"

  # gitignore
  dim "installing gitignore_global" >&2
  if [ -e "$HOME/.gitignore_global" ]; then
    cp "$HOME/.gitignore_global" "$HOME/.gitignore_global.bootstrap.bkp"
  fi
  cp ./gitignore_global "$HOME/.gitignore_global"
  git config --global core.excludesfile "$HOME/.gitignore_global"

  # jq
  dim "installing jq config" >&2
  if [ -e "$HOME/.jq" ]; then
    cp "$HOME/.jq" "$HOME/.jq.bkp"
  fi
  cp jq "$HOME/.jq"

  # Bash my AWS
  pull_or_clone "https://github.com/bash-my-aws/bash-my-aws.git" "$HOME/.bash-my-aws" "bash-my-aws"
}

pull_or_clone() {
  dim "\\t$3: " | tr -d "\n" >&2 # makes it easier to use formatting funcs with `echo -e`
  if [ -d "$2/.git" ]; then
    git -C "$2" pull >&2 || bold "couldn't pull $1" >&2
  else
    mkdir -p "$2"
    git clone "$1" "$2" >&2 || bold "couldn't clone $1" >&2
  fi
}

configure_vim_extensions() {
  dim "installing vim plugins" >&2
  # pathogen
  dim "\\tpathogen: " | tr -d "\n" >&2 # makes it easier to use formatting funcs with `echo -e`
  mkdir -p "$HOME/.vim/autoload" "$HOME/.vim/bundle" && \
  if [[ ! -f $HOME/.vim/autoload/pathogen.vim ]]; then
    curl -LSso "$HOME/.vim/autoload/pathogen.vim" https://tpo.pe/pathogen.vim 2>/dev/null | tr -d "\\n" && echo "ok" || echo "didn't install pathogen"
  else
    dim "ok" >&2
  fi

  # NERDTree
  pull_or_clone "https://github.com/scrooloose/nerdtree.git" "$HOME/.vim/bundle/nerdtree" "nerdtree"

  # AnsiEsc
  pull_or_clone "https://github.com/vim-scripts/AnsiEsc.vim.git" "$HOME/.vim/bundle/ansiesc" "ansiesc"

  # plantuml syntax
  pull_or_clone "https://github.com/aklt/plantuml-syntax.git" "$HOME/.vim/pack/git-plugins/start/plantuml-syntax"  "plantuml-syntax"

  # jinja2 syntax
  pull_or_clone "https://github.com/Glench/Vim-Jinja2-Syntax.git" "$HOME/.vim/pack/git-plugins/start/vim-jinja2-syntax" "jinja2"

  pull_or_clone "https://github.com/k-takata/minpac.git" "$HOME/.vim/pack/minpac/opt/minpac" "minpac"
}

configure_vim() {
  # path for the vimrc to dump swpfiles in
  mkdir -p "$HOME/.vim/swpfiles"

  # .vimrc
  dim "installing vimrc" >&2
  if [ -f "$HOME/.vimrc" ]; then
    cp "$HOME/.vimrc" "$HOME/.vimrc.bootstrap.bkp"
  fi

  cp ./vimrc "$HOME/.vimrc"

  # nvim
  dim "installing init.vim for nvim" >&2
  mkdir -p "$HOME/.config/nvim"

  if [[ -f "$HOME/.config/nvim/init.vim" ]]; then
    cp "$HOME/.config/nvim/init.vim" "$HOME/.config/nvim/init.vim.bak"
  fi

  cp init.vim "$HOME/.config/nvim/init.vim"

}

configure_bash_extensions() {
  # fzf - not using pull_or_clone because it's cloning at depth 1
  # NOTE pull_or_clone doesn't clone at depth 1 since I'm using some of those repos for dev
  if [ ! -d "$HOME/.fzf" ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf" >&2
  else
    git -C "$HOME/.fzf" pull https://github.com/junegunn/fzf.git >&2
  fi
  bold "to install or upgrade fzf, run '$HOME/.fzf/install'" >&2
}

configure_bash_scripts() {
  dir=$HOME/.bootstrap_utilities.d
  # shellcheck disable=2086
  rm -fr $dir
  # shellcheck disable=2086
  mkdir $dir
  # shellcheck disable=2086
  cat > $dir/README <<EOF
This directory is generated automatically by github.com/mostfunkyduck/bootstrap
It will hold useful utilities and should be added to PATH.
Do not edit anything in here, it will be overwritten
EOF

  # shellcheck disable=2086
  cp ./ip.sh $dir
}

run_light() {
  configure_vim
  configure_shell
}

run_normal() {
  configure_packages
  configure_brew
  configure_bash_extensions
  configure_bash_scripts
  configure_vim_extensions
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
      --vim)
        bold "configuring vim"
        configure_vim
        configure_vim_extensions
        ;;
      --bash)
        bold "configuring bash"
        configure_bash_extensions
        bold "configuring bash scripts"
        configure_bash_scripts
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
args=($(getopt -o l --long packages --long light --long help --long vim --long bash --long brew -- "$@"))
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
