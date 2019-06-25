# Source global definitions
## Doing this to ensure compatibility with distros that include the global defs in their ~/.bashrc
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

### Git functions

# Determines whether or not the current directory is part of a git repo
in_git () {
  git rev-parse --git-dir > /dev/null 2>&1
}

# retrieves the current branch
git_branch () {
  git branch 2> /dev/null | grep '*' | sed "s/* //"
}

### Git status functions
# Each of these functions takes the output of 'git status --porcelain' and parses
# it into ps1-friendly chunks
parse_git_modified () {
  # ' M' = modified, unstaged. 'MM' = staged
  MODIFIED=$(echo "$1" | grep -c "^[ ]*M")
  echo "$MODIFIED modified"
}

parse_git_staged () {
  # M = staged, MM = staged and unstaged commits, A = added (implies staged)
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

git_repo () {
  basename `git rev-parse --show-toplevel`
}

git_ps1 () {
  if in_git; then
    STATUS=`git status --porcelain 2>/dev/null`
    echo "($(git_repo): $(git_branch) | $(parse_git_modified "${STATUS}") | $(parse_untracked_files "${STATUS}") | $(parse_unstaged_commits "${STATUS}") | $(parse_git_staged "${STATUS}"))"
  fi
}

## Other stuff

get_number_of_jobs () {
  jobs | wc -l | tr -d " "
}

export PS1='[\t   <\W> [$(get_number_of_jobs)]] $(git_ps1)  \n> '

export PYTHONDONTWRITEBYTECODE=True

set -o vi
