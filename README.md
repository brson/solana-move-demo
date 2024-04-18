# End-to-end Move-on-Solana demo

This is a demo of running Move language programs on Solana.

It specifies minimum feature requirements,
outlines a minimal workflow for building, deploying and running Move programs,
demos comparable existing workflows on Sui and Solana,
describes implementation details and a roadmap.

- [Requirements](#user-content-requirements)
- [Which toolset should Solana-Move integrate with?](#user-content-which-toolset-should-solana-move-integrate-with)
- [Running the Solana-Move demo](#user-content-running-the-solana-move-demo)
- [`solana-move` commands discussion](#user-content-solana-move-commands-discussion)
- [Calling Move programs from the client](#user-content-calling-move-programs-from-the-client)
- [Handling on-chain bytecode dependencies](#user-content-handling-on-chain-bytecode-dependencies)
- [Proposed roadmap](#user-content-proposed-roadmap)
- [Running the Sui example demo](#user-content-running-the-sui-example-demo)
- [Running the Solana example demo](#user-content-running-the-solana-examnple-demo)



## Requirements

We want to aim to demo the following:

- Build contracts, with dependencies (source, local bytecode, on-chain bytecode)
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

There are two features demonstrated here that are feasible with
Move but not with plain Solana:

- Calling arbitrary programs from the CLI, introspecting
  the called program to get argument types
- Calling dependencies without access to any of their source
  code, again by using the bytecode.




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

**This is aspirational - not all of this works now but is what we are working toward.**

You'll need the `move` command from Solana's `sui` repo,
built with Solana support. This can be done with

```
cargo build --manifest-path=external-crates/move/Cargo.toml -p move-cli --features=solana-backend
```

or optionally installed with

```
cargo install --manifest-path=external-crates/move/Cargo.toml -p move-cli --features=solana-backend
```


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


### Change the global configuration to localhost

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


### Build the contract

Change to the `solana-move` directory and build

```
cd solana-move
```

```
move build --arch=solana
```

This creates the `build` directory containing:

```
solana/demo/
  demo.so
  BuildInfo.yml
  bytecode_modules/
    demo.mv
    dependencies/...
  source_maps/...
  sources/...
  ...
```

Note this is mostly the same as the Sui move build,
but there is an rbf dylib, demo.so,
and it's in an arch-specific `solana` directory.


### Run the tests

```
move test
```


### Deploy the contract

Create a re-usable `program-keypair.json`.
This contais the address of and signing key to deploy and redeploy.

```
solana-keygen new -o program-keypair.json
```

```
solana program deploy target/sbf-solana-solana/release/demo.so --program-id program-keypair.json
```

### Call the contract from source

todo


### Call the contract from the CLI

```
solana-move call --program <address> --module demo --function main --args 10
```





## `solana-move` commands discussion


### `solana-move build`

Compare to: `sui move build`, `move build`, `cargo build-bpf`

- Locate and download bytecode for dependencies
- Find move-native, optionally embedded directly in binary

### `solana-move test`

Compare to: `sui move test`, `move test`, `cargo test`

### `solana-move publish`

Compare to: `sui client publish`, `solana program publish`

### `solana-move call`

Compare to: `sui client call`

- Parse arguments as move types
- Build solana transactions




## Calling Move programs from the client



## Handling on-chain bytecode dependencies




## Proposed roadmap

There are three main thrusts of work here:

- Creating `solana-move-sdk` crate that can parse move values and prepare solana transactions
- Creating the `solana-move` CLI, and especially the solana-move-specific `solana-move call`
  command (other commands will be identical to `move` and `solana` commands at first.
- Moving the storage model forward.


### Demo 1


- Create a client SDK crate, perhaps `solana-move-sdk` (vs. `solana-sdk`)
  - This will depend on both existing Solana and Move crates
- Add APIs for parsing move values
- Add APIs for preparing Move transactions
- Write the demo `solana-demo-client` using the `solana-move-sdk`
  and `solana-client` SDKs, calling the demo program.


### Demo 2

- Create `solana-move` crate in `external-crates/move/solana/`
  - Set up arg parsing with clap for the commands in this demo
- Include the compiled move-native library directly into the `solana-move` binary
- Set up binary releases of `solana-move` that people can test
- Make `solana-move build` and `solana-move test` behave like
  `move build` and `move test`. The Move libraries are reusable
  so this shouldn't have much code duplication.
- Write `solana-move deploy` - crib off of `solana program deploy`,
  or just shell out to `solana program deploy`.
- Teach `solana-move deploy` to deploy both rbpf and the original bytecode
- Create `solana-move call` using `solana-move-client`
  - Download and introspect bytecode to get argument types

## Future

- Storage model
- Reduce size of compiled output
  - Function sections
  - LTO



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



## Build the program

Change to the `sui` directory and build

```
cd sui
```

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

## Run the tests

```
sui move test
```

## Deploy the contract

```
sui client publish --gas-budget 10000000
```

## Call the contract

```
sui client call --package <package-id> --module demo --function main --args 10 --gas-budget 10000000
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

## Run the tests

```
cargo test
```

## Deploy the contract

Create a re-usable `program-keypair.json`.
This contais the address of and signing key to deploy and redeploy.

```
solana-keygen new -o program-keypair.json
```

```
solana program deploy target/sbf-solana-solana/release/demo.so --program-id program-keypair.json
```

## Call the contract

todo - this needs to be done from code
