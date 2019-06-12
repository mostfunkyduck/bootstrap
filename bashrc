get_number_of_jobs () {
  jobs | wc -l | tr -d " "
}

export PS1='[\t   <\W> [$(get_number_of_jobs)]] \n> '

export PYTHONDONTWRITEBYTECODE=True

set -o vi
