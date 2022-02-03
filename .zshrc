# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(ag git aws colored-man-pages) # jack

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi
export EDITOR='nvim' # jack

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

## All jack from here on
in_git () {
  git rev-parse --git-dir > /dev/null 2>&1
}

git_branch () {
  git branch 2> /dev/null | grep '\*' | sed "s/* //"
}

git_rev () {
  git show 2>/dev/null | head -1 | awk '{print $NF}' | cut -c 1-10
}

# pass this the number of items and the action, e.g "colorize_git_output (<command>, "tweaked")"
colorize_git_output () {
  if [[ $1 -ge 1 ]]; then
    echo -e "%F{red}$1 $2%f"
  else
    echo -e "%F{green}$1 $2%f"
  fi

}
parse_git_modified () {
  MODIFIED=$(echo "$1" | grep -c "^[ ]*M")
  colorize_git_output "$MODIFIED" "modified"
}

parse_git_staged () {
  # M = staged, MM = staged and unstaged commits
  STAGED=$(echo "$1" | grep -c "^[MA]")
  colorize_git_output "$STAGED" "staged"
}

parse_untracked_files () {
  UNTRACKED=$(echo "$1" | grep -c "^??")
  colorize_git_output "$UNTRACKED" "untracked"
}

parse_unstaged_commits () {
  UNSTAGED=$(echo "$1" | grep -c "^ M")
  colorize_git_output "$UNSTAGED" "unstaged"
}

parse_deleted_files () {
  DELETED=$(echo "$1" | grep -c "^ D")
  colorize_git_output "$DELETED" "deleted"
}

parse_branch_ahead () {
  VAL=$(echo "$1" | grep -c "^##.*ahead ")
  if [[ $VAL -ge 1 ]]; then
    echo -e "%F{red}P%f"
  else
    echo -e "%F{green}C%f"
  fi
}
git_repo () {
  basename "$(git rev-parse --show-toplevel)"
}

git_prompt () {
  if in_git; then
    STATUS=$(git status --porcelain -b 2>/dev/null)
    echo "($(git_repo): $(git_branch) [$(parse_branch_ahead "${STATUS}")] | $(parse_git_modified "${STATUS}") | $(parse_untracked_files "${STATUS}") | $(parse_unstaged_commits "${STATUS}") | $(parse_git_staged "${STATUS}") | $(parse_deleted_files "${STATUS}"))"
  fi
}

get_number_of_jobs () {
  jobs | wc -l | tr -d " "
}

show_aws_profile () {
  [ "$AWS_PROFILE" ] && echo "[%F{yellow}$AWS_PROFILE%f]"
  [ "$AWS_VAULT" ] && echo "[%F{blue}$AWS_VAULT%f]"
}
NEWLINE=$'\n'
PROMPT='[$SHLVL] %n %F{green}(%d)%f %F{blue}%D{%Y/%m/%d}%f %F{cyan}%*%f $(show_aws_profile)  [%j] $(git_prompt 2>/dev/null )${NEWLINE} > '

set -o vi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

wait_for_ssh () {
  until nc -vz -w1 "$1" 22; do
    sleep 1;
  done
}

export VISUAL=nvim
export EDITOR="$VISUAL"

# FZF/GIT, YO!
alias git_log_fzf="git log --oneline | fzf --multi --preview 'git show {+1}'"

# delete aws-vault sessions without risking removal of a profile by omission of the cli arg
remove_aws_vault_sessions() {
  aws-vault remove "$1" --sessions-only
}

# bash users may source the functions instead of loading the aliases
if [ -d "$HOME/.bash-my-aws" ]; then
  export PATH="$PATH:$HOME/.bash-my-aws/bin"
  # shellcheck disable=SC1090
  source "$HOME/.bash-my-aws/aliases"

  # For ZSH users, uncomment the following two lines:
  autoload -U +X compinit && compinit
  autoload -U +X bashcompinit && bashcompinit

  # shellcheck disable=SC1090
  source "$HOME/.bash-my-aws/bash_completion.sh"
fi

alias ls='ls -FG'
alias python=python3
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

alias selectVictim="$HOME/select.sh darren elvin xavier leonar matt eric jack"

notify_after() {
  local cmd
  cmd="$1"
  if [ -z "$cmd" ]; then
    >&2 echo "this function will run a command and notify you when it completes"
    >&2 echo "usage: $0 <command>"
    return
  fi
  if ! command -v terminal-notifier; then
    >&2 echo 'terminal-notifier not found, cannot notify'
    return
  fi
  trap "terminal-notifier -message \"$cmd completed\" -sound default" EXIT
  "$@"
}

notify_after_existing() {
  local pid
  pid="$1"
  if [ -z "$pid" ]; then
    >&2 echo "this function will notify you when a given pid terminates"
    >&2 echo "usage: $0 <pid>"
    return
  fi
  if ! command -v terminal-notifier; then
    >&2 echo 'terminal-notifier not found, cannot notify'
    return
  fi
  trap "terminal-notifier -message \"$pid terminated\" -sound default" EXIT
  echo "waiting for $pid to terminate"
  ps -ef "$pid"
  while true; do
    ps "$pid" &>/dev/null || break
    echo -n '.'
    sleep 1
  done
}
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export PATH="/Users/jack/.pyenv/shims:${PATH}"
export PYENV_SHELL=zsh
source '/usr/local/Cellar/pyenv/2.2.3/libexec/../completions/pyenv.zsh'
command pyenv rehash 2>/dev/null
pyenv() {
  local command
  command="${1:-}"
  if [ "$#" -gt 0 ]; then
    shift
  fi

  case "$command" in
  rehash|shell)
    eval "$(pyenv "sh-$command" "$@")"
    ;;
  *)
    command pyenv "$command" "$@"
    ;;
  esac
}

