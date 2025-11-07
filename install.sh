#!/bin/sh
BASEDIR=$(dirname $0)
ZSHRC=~/.zshrc
BASHRC=~/.bashrc
ZSH_PATH=/usr/bin/zsh
BASH_PATH=/bin/bash

echo "ALWAYS REVIEW SCRIPTS BEFORE RUNNING!"
echo "----------------------------------------"
echo ""

sleep 10

mkdir -p ~/bin > /dev/null 2>&1
cp -v $BASEDIR/src/headlines.pl ~/bin

if [ "$SHELL" = "$(which zsh)" ]; then
    cat $BASEDIR/src/lobsters_startup.sh >> $ZSHRC
fi

if [ "$SHELL" = "$(which bash)" ]; then
    cat $BASEDIR/src/lobsters_startup.sh >> $BASHRC
fi
