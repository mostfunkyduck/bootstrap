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

get_number_of_jobs () {
  jobs | wc -l | tr -d " "
}

export PS1='[\t   <\W> [$(get_number_of_jobs)]] \n> '

export PYTHONDONTWRITEBYTECODE=True

set -o vi
