#!/bin/sh
BASEDIR=$(dirname $0)
ZSHRC=~/.zshrc
BASHRC=~/.bashrc
ZSH_PATH=/usr/bin/zsh
BASH_PATH=/bin/bash
DELAY_SEC=10

echo "ALWAYS REVIEW SCRIPTS BEFORE RUNNING!"
echo "----------------------------------------"
echo ""

echo "****************************************"
tail -n16 $0
echo "****************************************"

(( ++DELAY_SEC ))
while (( --DELAY_SEC >= 0)); do
    printf "$DELAY_SEC..\r"
    sleep 1
done

mkdir -p ~/bin > /dev/null 2>&1
cp -v $BASEDIR/src/headlines.pl ~/bin

if [ "$SHELL" = "$(which zsh)" ]; then
    cat $BASEDIR/src/lobsters_startup.sh >> $ZSHRC
fi

if [ "$SHELL" = "$(which bash)" ]; then
    cat $BASEDIR/src/lobsters_startup.sh >> $BASHRC
fi
