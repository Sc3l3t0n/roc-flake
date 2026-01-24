# Roc Nightly Flake

This repository provides a Nix flake for easy access to the new Zig-based compiler nightlies for the [Roc programming language](https://roc-lang.org/). It automatically tracks the [nightly releases](https://github.com/roc-lang/nightlies).

## Usage

### Creating a New Project

To start a new Roc project using this flake, run the following command in an empty directory:

```bash
nix flake init -t github:Sc3l3t0n/roc-flake
```

This will generate a `flake.nix` configured to use the nightly compiler, along with a starter `main.roc` file.

### Flake Outputs

This flake provides:
- `packages.${system}.default` (alias `roc`): The Roc compiler package.
- `overlays.default`: An overlay to add `roc` to `nixpkgs`.

Add `github:Sc3l3t0n/roc-flake` to your `inputs` to use them.

## Supported Systems

This flake supports the following systems, matching the official Roc nightly releases:

- `x86_64-linux`
- `aarch64-linux`
- `x86_64-darwin` (macOS Intel)
- `aarch64-darwin` (macOS Apple Silicon)

## Maintenance

This repository includes scripts to automatically update to the latest nightly version.

### Updating Locally

1. Enter the update devshell:
   ```bash
   nix develop .#update-current
   ```
2. Run the update script:
   ```bash
   ./scripts/update-current.sh
   ```

This will fetch the latest version information from the `roc-lang/nightlies` repository and update `current.nix` with the new version tag and artifact hashes.
