# Hermes Relayer

## Goal

The goal of this bounty is to demonstrate a functional and reliable IBC setup for reliable token transfers using the [Hermes relayer](https://hermes.informal.systems/).
A second goal is to support the Cosmos ecosystem and provide a reference implementation for other chains wanting to create similar setups.

## Setup

### Sync to the testnet(s)

To sync to the Microtick testnet, have the latest software versions for gaiad and mtm (the Cosmos and Microtick backend nodes).
To get the required versions on the current testnet, join the [Discord channel](https://discord.gg/SrVgSydE) and inquire there.

For this bounty, you'll need a node on both the gaiad-microtick-testnet chain and the microtick-testnet-rcN chain. Genesis blocks
can be obtained from the Discord channel. Microtick testnet binary releases are [available here](https://microtick.com/releases/testnet/stargate).

While you'll need to demonstrate the final version on the public testnet, it is fine to develop locally with the 
correct versions of software. You'll need to ensure the GUI works as well as CLI transfers, both of which can run locally with
some setup.

## Task

Your task is to create a reliable, maintainable and documented IBC relayer setup for IBC token transfers using the Hermes relayer written in Rust. All **code changes** and 
**bug fixes** must be open-source and submitted as PRs to the Informal Systems code repository.  All **task-specific documentation** must be submitted as a
PR to this repository.

Development on this task is likely to be iterative and incremental, requiring bug fixes and software changes where necessary.

Reasonable changes to the requirements for acceptance may also be necessary as the scope and understanding changes. These changes can be incorporated
to the PR you will create to claim the bounty.

In the event that multiple people want to work on this task, cooperation is encouraged. It is fine for teams to work together to claim the bounty, 
with the portion of TICK payout to each address specified in the final PR to this repo. To keep it fair and competitive team sizes will be limited
to three destination addresses.

## Acceptance Criteria

- Must run on the latest Microtick testnet and gaiad test chains. Both seeds exist on testnet.microtick.zone (see Setup).

- Must be able to run a relayer using the existing on-chain IBC client(s), connection and channel, if already set up. (If the connection
needs updated using governance, the testnet participants will coordinate to make that happen)

- Must be able to set up the client(s), connection and channel, if they are not already set up on-chain.

- Must be able to demonstrate reliability by running for one week, handling all incoming and outgoing IBC transfers. Token balances
must be updated on the destination chain within two minutes or less of an IBC transfer request being submitted successfully on the source chain.

- Documentation must include:

  - How to perform a set up, from scratch, of a new set of on-chain clients, connection and channel.
  - How to sync a relayer to an existing on-chain channel, assuming the channel was created elsewhere.
  - How to start the relayer
  - How to stop the relayer
  - How to resync the relayer, if the local store gets out of sync with the on-chain client.
  - Any other useful pieces of information, as deemed necessary.
