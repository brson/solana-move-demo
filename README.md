# End-to-end Move-on-Solana demo

This is a demo of running Move language programs on Solana.

It specifies minimum feature requirements,
outlines a minimal workflow for building, deploying and running Move programs,
demos comparable existing workflows on Sui and Solana,
describes implementation details and a roadmap.

- [Requirements](#user-content-requirements)
- [Which toolset should Solana-Move integrate with?](#user-content-which-toolset-should-solana-move-integrate-with)
- [Running the Solana-Move demo](#user-content-running-the-solana-move-demo)
- [`solana-move` commands discussion](#user-content-solana-move-commands)
- [Calling Move programs from the client](#user-content-calling-move-programs-from-the-client)
- [Handling on-chain bytecode dependencies](#user-content-handling-on-chain-bytecode-dependencies)
- [Proposed roadmap](#user-content-proposed-roadmap)
- [Running the Sui example demo](#user-content-running-the-sui-example-demo)
- [Running the Solana example demo](#user-content-running-the-solana-examnple-demo)



## Requirements

We want to aim to demo the following:

- Build contracts, with dependencies
- Test contracts on rbpf
- Deploy and re-deploy contracts to a localnet
- Call contracts with arguments and return values from Rust client code
- Call contracts with arguments and return values from the CLI

Note that for now we are not demoing on-chain storage.

We can do this in two phases, with the first phase MVP being

- Build contracts, no dependencies
- Test contracts on rbpf
- Deploy and re-deploy contracts to a localnet
- Call contracts with arguments and return values from Rust client code

This MVP forgoes the ability to use dependencies,
which will entail locating the corresponding omve bytecode for rbpf programs;
and to call programs directly from the CLI, which will require the same,
plus introspection and reflection on the interface of the program.




## Which toolset should Solana-Move integrate with?

Since our project is a mashup of Solana, Move, and Sui,
there are already 4 main CLI tools involved.

- `cargo` - The Rust build tool. Solana uses a cargo subcommand, `cargo build-bpf`,
  as well as `cargo test` etc.
- `solana` - Used for deploying to Solana, wallets, etc.
- `sui` - All interaction with Move and Sui
- `move` - Move build tools, not typically used directly with Sui

These tools perhaps each have their own different designs and "feels".
I suggest that since we are a Solana project we should attempt to integrate with
and match the `solana` experience. Ultimately we might want any new
CLI commands to part of `solana` CLI, and to integrate Move features with
existing `solana` commands.

For an initial demo I suggest we can do everything necessary with a combination of
the `solana` and `move` commands.

Beyond that we might work in our own `solana-move` CLI, inside the
`external-crates/move/solana` subdirectory of Solana's sui fork.
We can consider this a prototype tool with the intent of moving the functionality
elsewhere once proven. Working on the CLI in Solana's `sui` fork will avoid
having to work in the main Solana codebase for now, and avoid the scrutiny
of mainline Solana pull requests.




## Running the Solana-Move demo

**This is aspirational - none of this works now but is what we are working toward.**

To run this demo you'll need the solana CLI tools installed,
and the CLI wallet set up with testnet tokens.

You'll also need the `move` command from Solana's `sui` repo,
built with Solana support. This can be done with

```
cargo build --manifest-path=external-crates/move/Cargo.toml -p move-cli --features=solana-backend
```

or optionally installed with

```
cargo install --manifest-path=external-crates/move/Cargo.toml -p move-cli --features=solana-backend
```

Change to the `solana-move` directory:

```
cd solana-move
```

Build the program:

```
move build
```

This creates the `build` directory containing:

```
demo/
  demo.so
  BuildInfo.yml
  bytecode_modules/
    demo.mv
    dependencies/...
  source_maps/...
  sources/...
target/
  ...
```

This structure is a combination of the `move-cli` output
and the `cargo` output, as our build will include
both move compiler builds and rust builds (for move-native).
Note here that the rbpf dylib is built into the `build/demo` directory.

todo


## `solana-move` commands discussion


### `solana-move build`

Compare to: `sui move build`, `move build`, `cargo build-bpf`

  - Locate and download bytecode for dependencies

### `solana-move test`

Compare to: `sui move test`, `move test`, `cargo test`

### `solana-move publish`

Compare to: `sui client publish`, `solana program publish`

### `solana-move call`

Compare to: `sui client call`


- Build
  - Compile with move-cli
    - Sui: `sui move build`
    - Move: `move build`
    - Solana: `cargo build-bpf`
    - Solana-Move: `solana-move build`
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




## Calling Move programs from the client



## Proposed roadmap

These can correspond to GitHub issues:

- Create `solana-move` crate in `external-crates/move/solana/`
  - Set up arg parsing with clap for the commands in this demo
- Make `solana-move build` and `solana-move test` behave like
  `move build` and `move test`. The Move libraries are reusable
  so this shouldn't have much code duplication.
- Write `solana-move deploy` - crib off of `solana program deploy`,
  or just shell out to `solana program deploy`.
- Create an client SDK crate, perhaps `solana-move-program` (vs. `solana-program`)




---





## Running the Sui example demo

This shows how the Sui workflow works for the features we want to demo with Move on Solana.


### Install `sui` CLI tools and run the test validator

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
RUST_LOG=off,sui_node=info cargo run -p sui-test-validator
```

Configure sui for the local network per
[instructions](https://docs.sui.io/guides/developer/getting-started/local-network):

```
sui client new-env --alias local --rpc http://127.0.0.1:9000
```

FIXME: the above doesn't actually work if sui is not alreday configured -
you'll have to walk through the interactive setup, providing the same configuration.




### Set up a wallet and get tokens for gas

```
sui client faucet && sui client gas
```



### Run the demo

Change to the `sui` directory:

```
cd sui
```

Build the program:

```
sui move build
```

This creates a `build` directory with the contents:

```
demo/
  BuildInfo.yml
  bytecode_modules/
    demo.mv
    dependencies/...
  source_maps/...
  sources/...
```

Run the tests:

```
sui move test
```

Deploy the contract:

```
sui client publish --gas-budget 10000000
```

Call the contract:

```
$ sui client call --package <package-id> --module demo --function main --args 10 --gas-budget 10000000
```

The package ID will be output by the previous `publish` command.



---





## Running the Solana example demo

This shows how the Solana workflow works for the features we want to demo with Move on Solana.


### Install `solana` CLI tools and run the test validator

First install the Solana tools following

https://docs.solanalabs.com/cli/install

e.g. the stable toolchain

```
sh -c "$(curl -sSfL https://release.solana.com/v1.18.9/install)"
```

Run the test validator:

```
solana-test-validator
```


## Change the global configuration to localhost

Run

```
solana config set -u localhost
```

Otherwise all commands will need a `--url localhost` argument.



### Set up a wallet and get tokens for gas

```
solana-keygen new
solana airdrop 10
```


### Run the demo

Change to the `solana` directory:

```
cd solana
```

Build the program:

```
cargo build-bpf
```

This creates a `target` directory with the contents:

```
sbf-solana-solana/release/
  demo.so
```

Run the tests:

```
cargo test
```

Create a re-usable `program-keypair.json`.
This contais the address of and signing key to deploy and redeploy.

```
solana-keygen new -o program-keypair.json
```

Deploy the contract:

```
solana program deploy target/sbf-solana-solana/release/demo.so --program-id program-keypair.json
```

Call the contract:

todo - this needs to be done from code
