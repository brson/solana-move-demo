# End-to-end Move-on-Solana demo

- [Requirements](#user-requirements)
- [Which toolset should Solana-Move integrate with?](#user-which-toolset-should-solana-move-integrate-with)
- [`solana-move` commands](#user-solana-move-commands)
- [Running the Sui example demo](#user-running-the-sui-example-demo)
- [Proposed roadmap](#user-proposed-roadmap)

## Requirements

- Build
  - Compile with move-cli
    - Sui: `sui move build`
    - Move: `move build`
    - Solana: `cargo build-bpf`
    - Solana-Move: `solana-move build`
  - Locate and download bytecode for dependencies
- Test
  - Sui: `sui move test`
  - Move: `move test`
  - Solana: `cargo test`
  - Solana-Move: `solana-move test`
- Deploy with move-cli/solana-cli
  - Sui: `sui client publish`
  - Solana: `solana program publish`
  - Solana-Move: `solana-move publish`
  - Update deployed contracts
- Call
  - Call from Rust code, via Solana/Move client SDK
  - Call from command line via ?..
  - Call with argument and return value
  - Sui: `sui client call`
  - Solana-Move: `solana-move call`



## `solana-move` commands



## Which toolset should Solana-Move integrate with?

Since our project is a mashup of Solana, Move, and Sui,
there are already 4 CLI tools involved.

- `cargo` - The Rust build tool. Solana uses a cargo subcommand, `cargo build-bpf`,
  as well as `cargo test` etc.
- `solana` - 

These tools perhaps each have their own different designs and "feels".
I suggest that since we are a Solana project we should attempt to integrate with
and match the `solana` experience. Ultimately we might want any needed
CLI commands to part of `solana` CLI.

For now though I suggest we work in our own `solana-move` CLI, inside the
`external-crates/move/solana` subdirectory of Solana's sui fork.
We can consider this a prototype tool with the intent of moving the functionality
elsewhere once proven. Working on the CLI in Solana's `sui` fork will avoid
having to work in the main Solana codebase for now, and avoid the scrutiny
of mainline Solana pull requests.


## Running the Sui example demo

This shows how the Sui workflow works for the features we want to demo on Solana.


### Install `sui` tool and run `sui-test-validator`

First install the Sui tools following

https://docs.sui.io/guides/developer/getting-started/sui-install

You'll need both the `sui` and `sui-test-validator`.

One option is to install `sui` from source, and run `sui-test-validator` from the source directory:

```
git clone https://github.com/MystenLabs/sui.git
cd sui
git checkout origin/testnet -b testnet
# This will put `sui` in your `.cargo/bin` directory for use later
cargo install --path crates/sui
# Run the validator
cargo run -p sui-test-validator
```


### Set up a wallet and get tokens for gas


