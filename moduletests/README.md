# Golang Module Tests

## Goal

The x/microtick module needs a set of golang tests to test the 8 transactions and 8 queries the Microtick module handles.

## Setup

To start a local network, scripts have been provided in this directory. Make sure you have the latest mtm executable
in your path:

```
$ git clone https://github.com/microtick/mtzone
$ cd mtzone
$ git checkout stargate
$ make proto
$ make
$ cp mtm <somewhere in your path>
```

The tools **jq** and **node.js** must be installed as well.

Once the executable is in your path, run a local testnet in this directory with:

```
$ npm install
$ ./run
```

## Task

Your task is to create a set of golang tests that cover the all the primary code path(s) and test the various error conditions
that can occur for the following transactions and queries:

| Transaction | CLI command (for reference) | filename |
| ----------- | --------------------------- | -------- |
| Create Quote | ```$ mtm tx microtick create``` | x/microtick/msg/txCreate.go |
| Update Quote | ```$ mtm tx microtick update``` | x/microtick/msg/txUpdate.go |
| Cancel Quote | ```$ mtm tx microtick cancel``` | x/microtick/msg/txCancel.go |
| Deposit Quote | ```$ mtm tx microtick deposit``` | x/microtick/msg/txDeposit.go |
| Withdraw Quote | ```$ mtm tx microtick withdraw``` | x/microtick/msg/txWithdraw.go |
| Market Trade | ```$ mtm tx microtick trade``` | x/microtick/msg/txTrade.go |
| Pick Trade | ```$ mtm tx microtick pick``` | x/microtick/msg/txPick.go |
| Settle Trade | ```$ mtm tx microtick settle``` | x/microtick/msg/txSettle.go |

| Query | CLI command (for reference) | filename |
| ----- | --------------------------- | -------- |
| Account | ``` $ mtm query microtick account``` | x/microtick/msg/queryAccount.go |
| Consensus | ``` $ mtm query microtick consensus``` | x/microtick/msg/queryConsensus.go |
| Market | ``` $ mtm query microtick market``` | x/microtick/msg/queryMarket.go |
| OrderBook | ``` $ mtm query microtick orderbook``` | x/microtick/msg/queryOrderBook.go |
| Params | ``` $ mtm query microtick params``` | x/microtick/msg/queryParams.go |
| Quote | ``` $ mtm query microtick quote``` | x/microtick/msg/queryQuote.go |
| Synthetic | ``` $ mtm query microtick synthetic``` | x/microtick/msg/querySynthetic.go |
| Trade | ``` $ mtm query microtick trade``` | x/microtick/msg/queryTrade.go |

Note: this task only includes the set of golang tests, not the CLI commands themselves. Those will be in a separate future
bounty.

## Acceptance Criteria

- Must use the latest version of x/microtick on the 'stargate' branch of https://github.com/microtick/mtzone.

- Tests should be able to be run using "make test" from the root directory.

- Coverage:

For each transaction or query, the tests should cover:

 - **primary flow** (where the command or query is successful, has enough funds, is not rejected due to out-of-range parameters, etc)
 - **main alternate flows**
   - insufficient funds
   - code paths in the transaction or query function that return non-nil errors
 - **embedded alternate flows**
   - code paths that return non-nil errors due to an error condition in the x/microtick/keeper logic

If there are cases other than those specified above, _they are *optional* to claim the bounty_. Note that in the case of multiple simultaneous
PRs to claim this bounty, the test package with the most complete coverage will be used as a selection criteria.

There are some hidden complexities for commissions and TICK rewards due to the adjustment factor described [at the bottom of this document](https://microtick.com/alpha/docs/stargate-changes). 
_These complexities are out of scope for this bounty_. It is enough to test:
  - the commission paid by a transaction signer is never less than the minimum commission.
  - the TICK reward paid to a transaction signer is never greater than the maximum TICK reward.
