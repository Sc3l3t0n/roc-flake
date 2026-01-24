{
  description = "Roc nightlies flake";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      perSystem = {
        pkgs,
        system,
        self',
        ...
      }: {
        packages = {
          default = self'.packages.roc;
          roc = import ./package.nix {inherit pkgs system;};
        };

        devShells = {
          update-current = pkgs.mkShell {
            packages = [pkgs.curl pkgs.jq pkgs.nix];
            shellHook = ''
              echo "Use ./scripts/update-current.sh to update current.nix"
            '';
          };
        };
      };
    };
}
