# End-to-end Move-on-Solana Demo

## Features

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
