#!/bin/bash

SCRIPTS_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)

cd $SCRIPTS_DIR
tmux new -ds mix
tmux send -t mix.0 "./execute.sh" ENTER
