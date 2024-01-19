# Shell Scripts Index

### Update Git

This is a shell script that is setup by the `setup.sh` script, and is placed as a binary executable placed in the users `/usr/bin`. Once setup, this script is called to update the current Git branch with the upstream branch defined. `dev` branch is the default branch, but can be changed with passing in an argument with the program, or passing it a `-b` flag followed by the branch name.

##### Example:

```shell
update-from-upstream master
```

or

```shell
update-from-upstream -b master
```
