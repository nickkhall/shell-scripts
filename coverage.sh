#!/usr/bin/env bash
JEST=node_modules/jest/bin/jest.js
HELP_TEXT="\n\n\tPass a target with '-t' or '--target'.\n"

RED='\033[0;31m'
NC='\033[0m' # No Color

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -t|--target)
    TARGET="$2"
    shift # past argument
    shift # past value
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

if [ -z ${TARGET+x} ]; then
  echo -e "${RED}Give me a fucking target, you pleb!!!${NC}$HELP_TEXT"
  exit 1
fi

if [ -z ${TARGET} ]; then
  echo -e "${RED}You give me a flag... but no data? Fuck You!!!${NC}$HELP_TEXT"
  exit 1
fi

$JEST --coverage $TARGET
exit 0
