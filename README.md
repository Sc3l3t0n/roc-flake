# Roc Nightly Flake

This repository provides a Nix flake for easy access to the new Zig-based compiler nightlies for the [Roc programming language](https://roc-lang.org/). It automatically tracks the [nightly releases](https://github.com/roc-lang/nightlies).

## Usage

To use this flake in your own Roc project, add it to your `flake.nix` inputs:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    roc.url = "github:Sc3l3t0n/roc-flake";
  };

  outputs = { self, nixpkgs, roc, ... }:
  let
    system = "x86_64-linux"; # Adjust for your system
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = [
        roc.packages.${system}.default
      ];
    };
  };
}
```

This will provide the `roc` binary in your devshell.

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
