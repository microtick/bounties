#!/bin/bash
set -e

INTERVAL=100

LATEST_HEIGHT=$(curl -s http://localhost:26657/block | jq -r .result.block.header.height);
BLOCK_HEIGHT=$(($(($LATEST_HEIGHT / $INTERVAL)) * $INTERVAL));
if [ $BLOCK_HEIGHT -eq 0 ]; then
  echo "Error: Cannot state sync to block 0; Latest block is $LATEST_HEIGHT and must be at least $INTERVAL; wait a few blocks!"
  exit 1
fi

TRUST_HASH=$(curl -s "http://localhost:26657/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)
if [ "$TRUST_HASH" == "null" ]; then
  echo "Error: Cannot find block hash. This shouldn't happen :/"
  exit 1
fi
NODE1_ID=$(curl -s "http://localhost:26657/status" | jq -r .result.node_info.id)
NODE1_IP=$(hostname -I | cut -f1 -d' ')

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"http://localhost:26657,http://localhost:26557\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"| ; \
s|^(seeds[[:space:]]+=[[:space:]]+).*$|\1\"${NODE1_ID}@${NODE1_IP}:26656\"|" ./data/gaiad-sync/config/config.toml

gaiad unsafe-reset-all --home ./data/gaiad-sync
rm -f ./data/gaiad-sync/config/addrbook.json
gaiad start --home ./data/gaiad-sync

