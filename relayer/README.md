# State Sync

## Goal

The goal of this bounty is to demonstrate a running and functional IBC setup using the Cosmos
relayer (https://github.com/cosmos/relayer).

## Setup

To start the local network, have the required gaiad version in your path. The tool **jq** and **node.js** must be installed as well.

1. Run the ```./configure_network.sh``` script to set up the data directory for the two local nodes.
2. Start the local network with ```./start_network.sh```. At this point you should see two gaiad instances running.

```
$ ps ax | grep gaiad
```

Logs should be redirected into the files **logs.node1** and **logs.node2**

```
$ tail -f ./logs.node1
```

3. Let the network run and generate state snapshots. For acceptance, we will let the network run past block 1000.

## Task

Your task is to modify the scripts as necessary so the third node uses [State Sync](https://blog.cosmos.network/cosmos-sdk-state-sync-guide-99e4cf43be2f)
to sync with the network.

The third node should be started with ```./sync_new_node.sh```

## Acceptance Criteria

- Must run on the latest Microtick testnet and gaiad test chains, both available at testnet.microtick.zone (see Setup).

- Must be able to run a relayer using the existing IBC client(s), connection and channel, if already set up. (If the connection
needs updated using governance, the testnet participants will make that happen)

- Must be able to set up the client(s), connection and channel, if they are not already set up on-chain.

- Must be able to demonstrate reliability by running for one week, handling all incoming and outgoing IBC transfers.

- Documentation must include:
