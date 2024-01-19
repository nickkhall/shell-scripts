#! /usr/bin/env bash

current_branch=''
upstream_branch='dev'

# script arguments
args=( "$@" )

##################################################
#                     Help                       #
##################################################

for ((i = 0; i < $#; i++)); do
  case "${args[$(($i))]}" in
    -h | --help )
      print_help
      exit 1;
      ;;
    *)
      # Check if it's a positional argument (upstream branch)
      if [ "$1" ]; then
        upstream_branch="$1"
      fi
      ;;
  esac
done

##################################################
#                Helper Functions                #
##################################################
print_help() {
  echo ""
  echo "-----------------------------------------------------------------"
  echo ""
  echo -e $'A bash script for updating \e[45mgit\e[37m branches with a given upstream branch.'
  echo ""
  echo "-----------------------------------------------------------------"
  echo -e $'REQUIRED*'
  echo -e $'\e[32m-b  \e[39mor \e[32m--branch\e[39m*  \e[39mThe git branch to update and merge into the current branch. (Default branch is `dev`).'
  echo ""
  echo "-----------------------------------------------------------------"
  echo ""
  echo -e $'\e[35mEXAMPLES\e[39m:'
  echo "./update-from-upstream.sh -b master"
  echo ""
  echo "-----------------------------------------------------------------"
  echo ""
}

##################################################
#               Handler Functions                #
##################################################

check_is_in_git_directory() {
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo -e "\e[31mERROR\e[37m: Not in a Git repository."
    exit 1
  fi

  return 0
}

set_current_git_branch() {
  local branch_output
  branch_output=$(git branch --show-current 2>&1)

  if [[ $branch_output == *"fatal: not a git repository"* ]]; then
    return 1
  else
    current_branch=$branch_output
    return 0
  fi
}

update_upstream_and_checkout_current_branch() {
  if [[ ! -z $upstream_branch && ! -z $current_branch ]]; then
    git checkout $upstream_branch && \
      git pull && \
      git checkout $current_branch && \
      git merge $upstream_branch
  elif [[ -z $upstream_branch ]]; then
    echo -e $'\e[31mERROR\e[37m: Failed to update upstream, no \e[32mupstream\e[37m branch set.'
  elif [[ -z $current_branch ]]; then
    echo -e $'\e[31mERROR\e[37m: Failed to update upstream, no \e[32mcurrent\e[37m branch.'
  fi
}

update_branch() {
  if ! git diff --quiet --exit-code; then
    echo -e $'\e[33mUncommitted changes found. Stashing changes...\e[37m'
    git stash

    # Now that changes are stashed, switch branches
    update_upstream_and_checkout_current_branch

    # Apply the stashed changes back
    git stash apply

    # If there are conflicts after applying the stash, you may need to resolve them manually
    if git status | grep "Unmerged paths"; then
      echo -e $'\e[33mConflict detected. Please resolve conflicts manually.\e[37m'
    else
      echo -e $'\e[32mStashed changes applied successfully.\e[37m'
    fi
  elif check_is_in_git_directory; then
    git checkout $upstream_branch && \
      git pull && \
      git checkout $current_branch && \
      git merge $upstream_branch

  fi
}

##################################################
#                   Main Logic                   #
##################################################

echo "Getting current Git branch..."

if set_current_git_branch; then
  if [[ ! -z $upstream_branch && ! -z $current_branch ]]; then
    echo "Updating branch..."
    update_branch
  fi
else
  print_help 
  exit 1
fi
