#!/bin/bash

SCRIPTS_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)

cd $SCRIPTS_DIR
tmux new -ds gather
tmux send -t gather.0 "sleep $((RANDOM% 20000)) &&  ./transfer.sh 2>&1 | tee ~/mix-keys/gather.log" ENTER
