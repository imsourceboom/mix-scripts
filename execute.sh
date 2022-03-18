#!/bin/bash

source $HOME/rust-scripts/scripts/rust-env.sh
source $HOME/mix-scripts/function.shinc

$HOME/rust-scripts/scripts/validatorBalance.sh > $HOME/validatorBalance

MIX_KEYS="$HOME/mix-keys"

if [ ! -d $MIX_KEYS ]; then
	mkdir $HOME/mix-keys
fi

if [ -f $MIX_KEYS/divided-1.seed ]; then
	echo "!! already files"
	exit
fi

echo "SERVER NO: $(cat $HOME/serverno)"

DIVIDED_RANDOM=$((RANDOM% 3 + 2)) 
echo "DIVIDED_RANDOM: $DIVIDED_RANDOM"

# Create Divided Address
for (( i = 1; i <= $DIVIDED_RANDOM; i++ ))
do
	DIVIDED_GEN_ADDR=$(genaddrFunc $MIX_KEYS/divided-$i.keys.json 0)
	echo "$DIVIDED_GEN_ADDR" | grep "Seed phrase" | cut -d ' ' -f 3- | tr -d '"' > $MIX_KEYS/divided-$i.seed
	echo "$DIVIDED_GEN_ADDR" | grep "Raw address" | cut -d ' ' -f 3-  > $MIX_KEYS/divided-$i.addr
done

# Coin Send and Deploy Divided Address
for (( i = 1; i <= $DIVIDED_RANDOM; i++ ))
do
	DIVIDED_ADDR=$(cat $MIX_KEYS/divided-$i.addr)
	DIVIDED_PUBLIC=$(cat $MIX_KEYS/divided-$i.keys.json | jq -r '.public')
	FRONT_RANDOM=$((RANDOM% 5 + 6))
	MIDDLE_RANDOM=$((RANDOM% 500 + 300))
	BACK_RANDOM=$((RANDOM% 3000 + 4567))
	SUM_RANDOM="$FRONT_RANDOM$MIDDLE_RANDOM$BACK_RANDOM"

	submitTransactionFunc $VALIDATOR_ADDR $DIVIDED_ADDR $SUM_RANDOM false $MSIG_KEYS_JSON_PATH
	sleep $((RANDOM% 61 + 60))
	confirmTransactionFunc $DIVIDED_ADDR
	sleep $((RANDOM% 61 + 60))
	deployFunc $MIX_KEYS/divided-$i.keys.json $DIVIDED_PUBLIC 1
	sleep $((RANDOM% 3600))
done

VALIDATOR_BALANCE=$($TONOS_CLI -c $TONOS_CLI_CONFIG account $VALIDATOR_ADDR | grep "balance" | awk '{print $2}')
echo "VALIDATOR_BALANCE: $VALIDATOR_BALANCE"

VALIDATOR_DIVISION_BALANCE=$(($(($VALIDATOR_BALANCE - 200000000)) / $DIVIDED_RANDOM))
echo "VALIDATOR_DIVISION_BALANCE: $VALIDATOR_DIVISION_BALANCE"

# Division amount to Divided Address
for (( i = 1; i <= $DIVIDED_RANDOM; i++ ))
do
	DIVIDED_ADDR=$(cat $MIX_KEYS/divided-$i.addr)

	submitTransactionFunc $VALIDATOR_ADDR $DIVIDED_ADDR $(($VALIDATOR_DIVISION_BALANCE - 40000000)) true $MSIG_KEYS_JSON_PATH
	sleep $((RANDOM% 61 + 60))
	confirmTransactionFunc $DIVIDED_ADDR
	sleep $((RANDOM% 3600))
done

#################################################

BRIDGE_RANDOM=$((RANDOM% $DIVIDED_RANDOM + 1))
echo "BRIDGE_RANDOM: $BRIDGE_RANDOM"

# Create Bridge Address
BRIDGE_GEN_ADDR=$(genaddrFunc $MIX_KEYS/bridge.keys.json 0)
echo "$BRIDGE_GEN_ADDR" | grep "Seed phrase" | cut -d ' ' -f 3- | tr -d '"' > $MIX_KEYS/bridge.seed
echo "$BRIDGE_GEN_ADDR" | grep "Raw address" | cut -d ' ' -f 3- > $MIX_KEYS/bridge.addr

# Coin Send and Deploy Bridge Address
BRIDGE_ADDR=$(cat $MIX_KEYS/bridge.addr)
BRIDGE_PUBLIC=$(cat $MIX_KEYS/bridge.keys.json | jq -r '.public')
FRONT_RANDOM=$((RANDOM% 5 + 6))
MIDDLE_RANDOM=$((RANDOM% 500 + 300))
BACK_RANDOM=$((RANDOM% 3000 + 4567))
SUM_RANDOM="$FRONT_RANDOM$MIDDLE_RANDOM$BACK_RANDOM"

submitTransactionFunc $(cat $MIX_KEYS/divided-$BRIDGE_RANDOM.addr) $BRIDGE_ADDR $SUM_RANDOM false $MIX_KEYS/divided-$BRIDGE_RANDOM.keys.json
sleep $((RANDOM% 61 + 60))
deployFunc $MIX_KEYS/bridge.keys.json $BRIDGE_PUBLIC 1
sleep $((RANDOM% 3600))

# Division amount to Bridge Address
for (( i = 1; i <= $DIVIDED_RANDOM; i++ ))
do
	DIVIDED_ADDR=$(cat $MIX_KEYS/divided-$i.addr)
	DIVIDED_BALANCE=$($TONOS_CLI -c $TONOS_CLI_CONFIG account $DIVIDED_ADDR | grep "balance" | awk '{print $2}')

	submitTransactionFunc $DIVIDED_ADDR $BRIDGE_ADDR $(($DIVIDED_BALANCE - 40000000)) true $MIX_KEYS/divided-$i.keys.json
	sleep $((RANDOM% 3600))
done

#################################################

DEST_RANDOM=$((RANDOM% 2 + 1))
echo "DEST_RANDOM: $DEST_RANDOM"

# Create Dest Address
for (( i = 1; i <= $DEST_RANDOM; i++ ))
do
	DEST_GEN_ADDR=$(genaddrFunc $MIX_KEYS/dest-$i.keys.json 0)
	echo "$DEST_GEN_ADDR" | grep "Seed phrase" | cut -d ' ' -f 3- | tr -d '"' > $MIX_KEYS/dest-$i.seed
	echo "$DEST_GEN_ADDR" | grep "Raw address" | cut -d ' ' -f 3- > $MIX_KEYS/dest-$i.addr
done

# Coin Send and Deploy Dest Address
for (( i = 1; i <= $DEST_RANDOM; i++))
do
	DEST_ADDR=$(cat $MIX_KEYS/dest-$i.addr)
	DEST_PUBLIC=$(cat $MIX_KEYS/dest-$i.keys.json | jq -r '.public')
	FRONT_RANDOM=$((RANDOM% 5 + 6))
	MIDDLE_RANDOM=$((RANDOM% 500 + 300))
	BACK_RANDOM=$((RANDOM% 3000 + 4567))
	SUM_RANDOM="$FRONT_RANDOM$MIDDLE_RANDOM$BACK_RANDOM"

	submitTransactionFunc $BRIDGE_ADDR $DEST_ADDR $SUM_RANDOM false $MIX_KEYS/bridge.keys.json
	sleep $((RANDOM% 61 + 60))
	deployFunc $MIX_KEYS/dest-$i.keys.json $DEST_PUBLIC 1
	sleep $((RANDOM% 3600))
done

BRIDGE_BALANCE=$($TONOS_CLI -c $TONOS_CLI_CONFIG account $BRIDGE_ADDR | grep "balance" | awk '{print $2}')
echo "BRIDGE_BALANCE: $BRIDGE_BALANCE"
FINAL_BALANCE=$(($(($BRIDGE_BALANCE - 100000000)) / $DEST_RANDOM))
echo "FINAL_BALANCE: $FINAL_BALANCE"

# Final send to Dest Address
for (( i = 1; i <= $DEST_RANDOM; i++ ))
do
	DEST_ADDR=$(cat $MIX_KEYS/dest-$i.addr)

	submitTransactionFunc $BRIDGE_ADDR $DEST_ADDR $(($FINAL_BALANCE - 40000000)) true $MIX_KEYS/bridge.keys.json
	sleep $((RANDOM% 3600))
done








