# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi

if [ -e ~/go ]; then
  PATH=$PATH:$HOME/go/bin
fi

export PATH

in_git () {
  git rev-parse --git-dir > /dev/null 2>&1
}

git_branch () {
  git branch 2> /dev/null | grep '*' | sed "s/* //"
}

# pass this the number of items and the action, e.g "colorize_git_output (<command>, "tweaked")"
colorize_git_output () {
  if [[ $1 -ge 1 ]]; then
    echo -e "\033[0;31m$1 $2\033[m"
  else
    echo -e "\033[0;32m$1 $2\033[m"
  fi

}
parse_git_modified () {
  MODIFIED=$(echo "$1" | grep -c "^[ ]*M")
  colorize_git_output $MODIFIED "modified"
  #if [[ $MODIFIED -ge 1 ]]; then
    #echo -e "\033[0;31m$MODIFIED modified\033[m"
  #else
    #echo -e "\033[0;32m$MODIFIED modified\033[m"
  #fi
}

parse_git_staged () {
  # M = staged, MM = staged and unstaged commits
  STAGED=$(echo "$1" | grep -c "^[MA]")
  colorize_git_output $STAGED "staged"
}

parse_untracked_files () {
  UNTRACKED=$(echo "$1" | grep -c "^??")
  colorize_git_output $UNTRACKED "untracked"
}

parse_unstaged_commits () {
  UNSTAGED=$(echo "$1" | grep -c "^ M")
  colorize_git_output $UNSTAGED "unstaged"
}

parse_deleted_files () {
  DELETED=$(echo "$1" | grep -c "^ D")
  colorize_git_output $DELETED "deleted"
}

parse_branch_ahead () {
  VAL=$(echo "$1" | grep -c "^##.*ahead ")
  if [[ $VAL -ge 1 ]]; then
    echo -e "\033[0;31mP\033[m"
  else
    echo -e "\033[032mC\033[m"
  fi
}
git_repo () {
  basename `git rev-parse --show-toplevel`
}

git_ps1 () {
  if in_git; then
    STATUS=`git status --porcelain -b 2>/dev/null`
    echo "($(git_repo): $(git_branch) [$(parse_branch_ahead "${STATUS}")] | $(parse_git_modified "${STATUS}") | $(parse_untracked_files "${STATUS}") | $(parse_unstaged_commits "${STATUS}") | $(parse_git_staged "${STATUS}") | $(parse_deleted_files "${STATUS}"))"
  fi
}

get_number_of_jobs () {
  jobs | wc -l | tr -d " "
}

export PS1='>\e[0;32m \u (\t)   <\W>\e[m [$(get_number_of_jobs 2>/dev/null)] $(git_ps1 2>/dev/null)  \n> '

export PYTHONDONTWRITEBYTECODE=True

set -o vi

alias ls='ls -F --color'

alias clipcopy='xclip -selection clipboard'

wait_for_node () {
  until nc -vz -w1 $1 22; do
    sleep 1;
  done
}

# force vim as the default editor
export VISUAL=vim
export EDITOR="$VISUAL"
