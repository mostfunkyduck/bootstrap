export PATH=$HOME/bin:/usr/local/bin:$PATH
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

source $ZSH/oh-my-zsh.sh

## Git hacks
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
parse_git_renamed () {
  local RENAMED
  RENAMED=$(echo "$1" | grep -c "^R")
  colorize_git_output "$RENAMED" "renamed"
}

parse_git_modified () {
  local MODIFIED
  MODIFIED=$(echo "$1" | grep -c "^[ R]*M")
  colorize_git_output "$MODIFIED" "modified"
}

parse_git_staged () {
  local STAGED
  # M = staged, MM = staged and unstaged commits, A = staged and added, R = renamed and added
  STAGED=$(echo "$1" | grep -c "^[MAR]")
  colorize_git_output "$STAGED" "staged"
}

parse_untracked_files () {
  local UNTRACKED
  UNTRACKED=$(echo "$1" | grep -c "^??")
  colorize_git_output "$UNTRACKED" "untracked"
}

parse_unstaged_commits () {
  local UNSTAGED
  UNSTAGED=$(echo "$1" | grep -c "^[ R]M")
  colorize_git_output "$UNSTAGED" "unstaged"
}

parse_deleted_files () {
  local DELETED
  DELETED=$(echo "$1" | grep -c "^ D")
  colorize_git_output "$DELETED" "deleted"
}

parse_branch_ahead () {
  local VAL
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
  local STATUS
  if in_git; then
    STATUS=$(git status --porcelain -b 2>/dev/null)
    echo "($(git_repo): $(git_branch) [$(parse_branch_ahead "${STATUS}")] | $(parse_git_modified "${STATUS}") | $(parse_untracked_files "${STATUS}") | $(parse_unstaged_commits "${STATUS}") | $(parse_git_staged "${STATUS}") | $(parse_deleted_files "${STATUS}") | $(parse_git_renamed "${STATUS}") )"
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
PROMPT='s:[$SHLVL] j:[%j]$(echo "\t") %n %F{green}(%d)%f %F{blue}%D{%Y/%m/%d}%f %F{cyan}%*%f $(show_aws_profile) $(in_git && echo && git_prompt 2>/dev/null )${NEWLINE} > '

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

# mac commands to send notification after running process
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

if command -v kubectl &>/dev/null; then
  KUBECTL_COMPLETIONS_FILE="$HOME/.kube/completion.zsh.inc"
  if [ -f "$KUBECTL_COMPLETIONS_FILE" ]; then
    source "$HOME/.kube/completion.zsh.inc"
  fi
fi
