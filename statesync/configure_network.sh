#!/bin/bash

EXPECTED_VERSION=4.0.2

HOME=$PWD/data

HOME_NODE1=$HOME/gaiad-node1
HOME_NODE2=$HOME/gaiad-node2
HOME_SYNC=$HOME/gaiad-sync

SILENT=1
redirect() {
  if [ "$SILENT" -eq 1 ]; then
    "$@" > /dev/null 2>&1
  else
    "$@"
  fi
}

# Version check
VERSION=$(gaiad version)
if [ $VERSION != $EXPECTED_VERSION ]; then
  echo "Incorrect gaiad version. Got $VERSION, need $EXPECTED_VERSION."
  exit 1
fi
echo "GAIA VERSION: $VERSION"
echo

# Warn user
echo "======================================="
echo "WARNING: Deleting chain config and data"
echo "======================================="
echo
if [[ -d $HOME ]]; then
  echo "$(basename $0) will delete:"
  echo
  echo "- $HOME"
  echo
  read -p "Do you wish to continue? (y/n): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      exit 1
  fi
  echo
fi

pkill gaiad

# Delete old data
rm -rf $HOME

redirect gaiad --home $HOME_NODE1 init node1
redirect gaiad --home $HOME_NODE2 init node2
redirect gaiad --home $HOME_SYNC init syncnode

# Add validator keys and bank
redirect gaiad --home $HOME_NODE1 --keyring-backend test keys add bank
redirect gaiad --home $HOME_NODE1 --keyring-backend test keys add validator
redirect gaiad --home $HOME_NODE2 --keyring-backend test keys add validator

# Create accounts
BANK=$(gaiad --home $HOME_NODE1 --keyring-backend test keys show bank -a)
VALIDATOR1=$(gaiad --home $HOME_NODE1 --keyring-backend test keys show validator -a)
VALIDATOR2=$(gaiad --home $HOME_NODE2 --keyring-backend test keys show validator -a)
echo "Bank: $BANK"
echo "Validator, node 1: $VALIDATOR1"
echo "Validator, node 2: $VALIDATOR2"

# Add genesis accounts
redirect gaiad --home $HOME_NODE1 --keyring-backend test add-genesis-account $BANK 1000000000000uatom,1000000000000stake
redirect gaiad --home $HOME_NODE1 --keyring-backend test add-genesis-account $VALIDATOR1 1000000000000stake
redirect gaiad --home $HOME_NODE1 --keyring-backend test add-genesis-account $VALIDATOR2 1000000000000stake

# Set chain params
TRANSFORMS='.chain_id="'statesync'"'
jq "$TRANSFORMS" $HOME_NODE1/config/genesis.json > tmp
mv tmp $HOME_NODE1/config/genesis.json

# Copy genesis into place on node 2
cp $HOME_NODE1/config/genesis.json $HOME_NODE2/config/genesis.json

# Create gentxs
redirect gaiad --home $HOME_NODE1 --keyring-backend test gentx validator 10000000000stake --chain-id statesync
redirect gaiad --home $HOME_NODE2 --keyring-backend test gentx validator 10000000000stake --chain-id statesync
cp $HOME_NODE2/config/gentx/gentx* $HOME_NODE1/config/gentx
redirect gaiad --home $HOME_NODE1 collect-gentxs

# Re-copy sealed genesis into place on node 2 and 3 with updated gen_txs
cp $HOME_NODE1/config/genesis.json $HOME_NODE2/config/genesis.json
cp $HOME_NODE1/config/genesis.json $HOME_SYNC/config/genesis.json

## zoom zoom
sed -i 's/timeout_propose = "3s"/timeout_propose = "250ms"/g' $HOME_NODE1/config/config.toml
sed -i 's/timeout_commit = "5s"/timeout_commit = "500ms"/g' $HOME_NODE1/config/config.toml
sed -i 's/timeout_precommit = "1s"/timeout_precommit = "250ms"/g' $HOME_NODE1/config/config.toml
sed -i 's/timeout_prevote = "1s"/timeout_prevote = "250ms"/g' $HOME_NODE1/config/config.toml

sed -i 's/timeout_propose = "3s"/timeout_propose = "250ms"/g' $HOME_NODE2/config/config.toml
sed -i 's/timeout_commit = "5s"/timeout_commit = "500ms"/g' $HOME_NODE2/config/config.toml
sed -i 's/timeout_precommit = "1s"/timeout_precommit = "250ms"/g' $HOME_NODE2/config/config.toml
sed -i 's/timeout_prevote = "1s"/timeout_prevote = "250ms"/g' $HOME_NODE2/config/config.toml

# Edit the ports for node1
sed -i 's#addr_book_strict = true#addr_book_strict = false#g' $HOME_NODE1/config/config.toml
sed -i 's#"tcp://127.0.0.1:26657"#"tcp://0.0.0.0:26657"#g' $HOME_NODE1/config/config.toml
sed -i 's#"tcp://0.0.0.0:26656"#"tcp://0.0.0.0:26656"#g' $HOME_NODE1/config/config.toml

# Edit the ports for node 2
sed -i 's#addr_book_strict = true#addr_book_strict = false#g' $HOME_NODE2/config/config.toml
sed -i 's#"tcp://127.0.0.1:26657"#"tcp://0.0.0.0:26557"#g' $HOME_NODE2/config/config.toml
sed -i 's#"tcp://0.0.0.0:26656"#"tcp://0.0.0.0:26556"#g' $HOME_NODE2/config/config.toml
sed -i 's#"localhost:6060"#"localhost:6061"#g' $HOME_NODE2/config/config.toml
sed -i 's/address = "0.0.0.0:9090"/address = "0.0.0.0:9091"/g' $HOME_NODE2/config/app.toml

# enable snapshot interval
sed -i 's/snapshot-interval = 0/snapshot-interval = 100/g' $HOME_NODE2/config/app.toml
sed -i 's/snapshot-interval = 0/snapshot-interval = 100/g' $HOME_NODE1/config/app.toml

# Edit the ports for sync node
sed -i 's#addr_book_strict = true#addr_book_strict = false#g' $HOME_SYNC/config/config.toml
sed -i 's#"tcp://127.0.0.1:26657"#"tcp://127.0.0.1:26457"#g' $HOME_SYNC/config/config.toml
sed -i 's#"tcp://0.0.0.0:26656"#"tcp://127.0.0.1:26456"#g' $HOME_SYNC/config/config.toml
sed -i 's#"localhost:6060"#"localhost:6062"#g' $HOME_SYNC/config/config.toml
sed -i 's/address = "0.0.0.0:9090"/address = "0.0.0.0:9092"/g' $HOME_SYNC/config/app.toml

# Add in seed info to peer nodes
PEER_NODE_ID=$(gaiad --home $HOME_NODE1 tendermint show-node-id)
sed -i 's#seeds = ""#seeds = "'$PEER_NODE_ID'@127.0.0.1:26656"#g' $HOME_NODE2/config/config.toml
