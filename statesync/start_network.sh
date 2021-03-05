#!/bin/bash

HOME=$PWD/data

HOME_NODE1=$HOME/gaiad-node1
HOME_NODE2=$HOME/gaiad-node2

setsid gaiad start --home $HOME_NODE1 > ./logs.node1 2>&1 &
setsid gaiad start --home $HOME_NODE2 > ./logs.node2 2>&1 &
