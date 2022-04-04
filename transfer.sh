#!/bin/bash

source $HOME/rust-scripts/scripts/rust-env.sh
source $HOME/mix-scripts/function.shinc

MIX_KEYS="$HOME/mix-keys"
GATHER_ADDR=$(cat $MIX_KEYS/gather.addr)

DEST_COUNT=$(ls $MIX_KEYS | grep 'dest' | grep 'addr' | wc -w)

for (( i = 1; i <= $DEST_COUNT; i++ ))
do
	echo "DEST $i"
	DEST_ADDR=$(cat $MIX_KEYS/dest-$i.addr)
	DEST_BALANCE=$($TONOS_CLI -c $TONOS_CLI_CONFIG account $DEST_ADDR | grep 'balance' | awk '{print $2}')

	submitTransactionFunc $DEST_ADDR $GATHER_ADDR $(($DEST_BALANCE - 40000000)) true $MIX_KEYS/dest-$i.keys.json

	if [ $DEST_COUNT -ge 2 ] && [ $i -le 1 ]; then
		sleep $((RANDOM% 7200))
	fi
done
