# State Sync

## Goal

The goal of this bounty is to demonstrate a completely local, running and functional state synced node.

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

- Must use gaiad 4.0.2 or above. If using a later version, edit the version check in the configure_network.sh script.

- Need to be able to duplicate the functionality locally. Upon completion of a successful state sync with the 
local network at or beyond block 1000, this task will be complete.
