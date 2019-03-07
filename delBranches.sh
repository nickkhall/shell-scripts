#!/bin/bash

## DO NOT USE THIS SCRIPT RIGHT NOW, IT DOES NOT WORK WITH ARGUMENTS
## GOOD JOB NICK, YOU HIT A HOMERUN ON THIS ONE!

getBranches() {
	# If the user specifies a branch, we know they want to remove all branches
	# EXCEPT the branch they specified and the master and stash branches.
	if [[ "$#" -gt 0 ]]; then
		git for-each-ref --format='%(refname:short)' refs/ | while read branch; do
			if ! [[ $branch =~ master || $branch =~ stash || $branch =~ HEAD || $branch =~ origin ]]; then
				for b in "$@"; do
					if ! [[ $branch == $b ]]; then
						git branch -D $branch && git push origin --delete $branch
					fi
				done
			fi
		done

		git fetch -p origin

		echo "Branches were successfully deleted."

	# If the user does not specify a branch to save, we assume they want to wipe
	# all branches excluding master and stash.

	fi
}

getBranches "$@"
