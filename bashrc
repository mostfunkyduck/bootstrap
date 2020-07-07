# go doesn't put itself in the global path on installs
if [ -d "$HOME/go/bin" ]; then
  PATH=$PATH:$HOME/go/bin
fi

# if snap is installed and misconfigured...
if [[ ! $PATH =~ "/snap/bin" ]] && command -v snap; then
  PATH=$PATH:/snap/bin
fi

export PATH

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
    echo -e "\033[0;31m$1 $2\033[m"
  else
    echo -e "\033[0;32m$1 $2\033[m"
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
    echo -e "\033[0;31mP\033[m"
  else
    echo -e "\033[032mC\033[m"
  fi
}
git_repo () {
  basename "$(git rev-parse --show-toplevel)"
}

git_ps1 () {
  if in_git; then
    STATUS=$(git status --porcelain -b 2>/dev/null)
    echo "($(git_repo): $(git_branch) [$(parse_branch_ahead "${STATUS}")] | $(parse_git_modified "${STATUS}") | $(parse_untracked_files "${STATUS}") | $(parse_unstaged_commits "${STATUS}") | $(parse_git_staged "${STATUS}") | $(parse_deleted_files "${STATUS}"))"
  fi
}

get_number_of_jobs () {
  jobs | wc -l | tr -d " "
}

aws_ps1() {
  if [[ -n $AWS_PROFILE ]]; then
    echo -ne "\033[0;33m[P: $AWS_PROFILE]\033[m "
  fi
 
  if [[ -n $AWS_REGION ]]; then
    echo -ne "\033[0;34m[R: $AWS_REGION]\033[m "
  fi
}
# shellcheck disable=SC2025
export PS1='>\e[0;32m \u (\t)   <\W>\e[m [$(get_number_of_jobs 2>/dev/null)] $(git_ps1 2>/dev/null)  \n$(aws_ps1)\h > '

export PYTHONDONTWRITEBYTECODE=True

set -o vi

alias ls='ls -F --color'

alias clipcopy='xclip -selection clipboard'
alias clippaste='xclip -sel clipboard -o'

wait_for_ssh () {
  until nc -vz -w1 "$1" 22; do
    sleep 1;
  done
}

# force vim as the default editor
export VISUAL=vim
export EDITOR="$VISUAL"

#### OnePassword Hacks ####

# depends on the clipcopy hack above 

op_get_login () {
  if [ $# -lt 1 ]; then
    echo "returns login for a given entry"
    echo "op_get_login <item title>"
    return
  fi  
  LOGIN=$(op get item "$1" --vault=Private)
  PARSED=$(echo "$LOGIN" | jq '.details.fields[] | select(.designation == "username") | .value')
  if [ -z "$PARSED" ]; then
    echo "could not parse login! $LOGIN"
    return 1
  fi
  echo "$PARSED"
  return
}
op_get_password() {
  if [ $# -lt 1 ]; then
    echo "copies password for a given item to the clipboard"
    echo "works for a standard 'Login' item"
    echo "op_get_password <item title>"
    return 1
  fi

  PASSWORD=$(op get item "$1" --vault=Private)
  if [ -z "$PASSWORD" ]; then
    echo "could not find password named $1!"
    return 1
  fi

  PARSED=$(echo "$PASSWORD" | jq '.details.fields[] | select(.designation == "password") | .value')
  if [ -z "$PARSED" ]; then
    # it's in this password-only format... hopefully
    PARSED=$(echo "$PASSWORD" | jq '.details.password')
  fi

  if [ -z "$PARSED" ]; then
    # somethings funky
    echo "could not parse this blob: $PASSWORD"
    return 1
  fi

  echo "$PARSED" | sed 's/"//g' | clipcopy && echo "done"
}

op_create_login() {
  # shellcheck disable=SC2089
  LOGINBLOB='{ "notesPlain": "", "sections": [], "passwordHistory": [], "fields": [ { "value": "USERNAME", "name": "username", "type": "T", "designation": "username" }, { "value": "PASSWORD", "name": "password", "type": "P", "designation": "password" } ] }'
  if [ $# -lt 3 ]; then
    echo "This function creates a username and password in onepassword"
    echo "example: op_create_login <username> <password> <item title>"
    return 1
  fi
  # shellcheck disable=SC2090
  ENCODED=$(echo "$LOGINBLOB" | sed "s/USERNAME/$1/" | sed "s/PASSWORD/$2/" | op encode)
  op create item --vault=Private --title="$3" Login "$ENCODED"
}

op_delete_item() {
  if [ $# -lt 1 ]; then
    echo "op_delete_item <name of item>"
    return 1
  fi

  ORIGINAL=$(op get item "$1" --vault=Private | jq .)
  if [ -z "$ORIGINAL" ]; then
    echo "could not retrieve an item named $1!"
    return 1
  fi

  echo "deleting item: $ORIGINAL"

  UUID=$(echo "$ORIGINAL" | jq .uuid | sed 's/"//g')
  echo -n "enter 'Y' to confirm deletion: "
  read -r confirm
  if [ "$confirm" = "Y" ]; then
    echo 'deleting!'
    op delete item "$UUID"
  else
    echo 'not deleting!'
  fi
}

# FZF/GIT, YO!
alias git_log_fzf="git log --oneline | fzf --multi --preview 'git show {+1}'"

# quicky commands to bring networkmanager vpns up and down
activate_vpn() {
  echo push | nmcli --ask con up id "$@"
}

deactivate_vpn() {
  nmcli con down id "$@"
}

alias less=less\ -R

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
  # autoload -U +X compinit && compinit
  # autoload -U +X bashcompinit && bashcompinit

  # shellcheck disable=SC1090
  source "$HOME/.bash-my-aws/bash_completion.sh"
fi

if [[ -d /home/linuxbrew ]]; then
  # linuxbrew is installed
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# because https://github.com/scop/bash-completion/issues/44
set +o nounset

# because caps lock is pointless
setxkbmap -option ctrl:nocaps
