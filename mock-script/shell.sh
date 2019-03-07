#!/bin/sh

echo "Tell me what you do for fun"
read random

var=$(echo $random | tr "{aeioutnmwzv}" "{AEIOUTNMWZV}")

echo "\n\n\n$var"
echo YO THAT SHIT IS LAME AS FUCK GET OUT OF HERE

/bin/bash ./img.sh ./sb.jpg
