#!/bin/bash

source $HOME/rust-scripts/scripts/rust-env.sh

MIX_KEYS="$HOME/mix-keys"

function hex2gram () {
	echo $1 1000000000 | awk '{printf "%.9f\n", $1 / $2}'
}

function balanceFunc () {
	BALANCE=$($TONOS_CLI -c $TONOS_CLI_CONFIG account $1 | grep 'balance' | awk '{print $2}')
	hex2gram $BALANCE
	#$TONOS_CLI -c $TONOS_CLI_CONFIG account $1
}

DIVIDED_COUNT=$(ls $MIX_KEYS | grep 'divided' | grep 'addr' | wc -w)
DEST_COUNT=$(ls $MIX_KEYS | grep 'dest' | grep 'addr' | wc -w)

echo "VALIDATOR"
balanceFunc $VALIDATOR_ADDR

for (( i = 1; i <= $DIVIDED_COUNT; i++ ))
do
	echo "DIVIDED $i"
	balanceFunc $(cat $MIX_KEYS/divided-$i.addr)
done

echo "BRIDGE"
balanceFunc $(cat $MIX_KEYS/bridge.addr)

for (( i = 1; i <= $DEST_COUNT; i++ ))
do
	echo "DEST $i"
	balanceFunc $(cat $MIX_KEYS/dest-$i.addr)
done

