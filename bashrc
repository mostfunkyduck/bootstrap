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
  git branch 2> /dev/null | sed "s/* //"
}

parse_git_dirty () {
  [[ $(git status 2> /dev/null | tail -n1) != "nothing to commit, working tree clean" ]] && echo "dirty" || echo "clean"
}

parse_git_up_to_date () {
  [[ $(git status 2> /dev/null | grep -ic "your branch is up to date") != 1 ]] && echo "out of sync" || echo "up to date"
}


git_repo () {
  basename `git rev-parse --show-toplevel`
}

git_ps1 () {
  if in_git; then
    echo "($(git_repo): $(git_branch)/$(parse_git_dirty)/$(parse_git_up_to_date))"
  fi
}

get_number_of_jobs () {
  jobs | wc -l | tr -d " "
}

export PS1='[\t   <\W> [$(get_number_of_jobs)]] $(git_ps1)  \n> '

export PYTHONDONTWRITEBYTECODE=True

set -o vi
