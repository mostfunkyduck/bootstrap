# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

in_git () {
  git rev-parse --git-dir > /dev/null 2>&1
}

git_branch () {
  git branch 2> /dev/null | grep '*' | sed "s/* //"
}

parse_git_modified () {
  MODIFIED=$(echo "$1" | grep -c "^[ ]*M")
  echo "$MODIFIED modified"
}

parse_git_staged () {
  # M = staged, MM = staged and unstaged commits
  STAGED=$(echo "$1" | grep -c "^[MA]")
  echo "$STAGED staged"
}

parse_untracked_files () {
  UNTRACKED=$(echo "$1" | grep -c "^??")
  echo "$UNTRACKED untracked"
}

parse_unstaged_commits () {
  UNSTAGED=$(echo "$1" | grep -c "^ M")
  echo "$UNSTAGED unstaged"
}

parse_branch_ahead () {
  VAL=$(echo "$1" | grep -c "^##.*ahead ")
  if [[ $VAL -ge 1 ]]; then
    echo "P"
  else
    echo " "
  fi
}
git_repo () {
  basename `git rev-parse --show-toplevel`
}

git_ps1 () {
  if in_git; then
    STATUS=`git status --porcelain -b 2>/dev/null`
    echo "($(git_repo): $(git_branch) [$(parse_branch_ahead "${STATUS}")] | $(parse_git_modified "${STATUS}") | $(parse_untracked_files "${STATUS}") | $(parse_unstaged_commits "${STATUS}") | $(parse_git_staged "${STATUS}"))"
  fi
}

get_number_of_jobs () {
  jobs | wc -l | tr -d " "
}

export PS1='[\e[0;32m\t   <\W> [$(get_number_of_jobs)]] $(git_ps1)\e[m  \n> '

export PYTHONDONTWRITEBYTECODE=True

set -o vi
