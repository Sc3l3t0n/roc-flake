let
  current = import ./current.nix;
  baseUrl = "https://github.com/roc-lang/nightlies/releases/download";
  mkReleaseName = system: "roc_nightly-${system}-${current.releaseNameVersion}.tar.gz";
  mkGHUrl = system: "${baseUrl}/${current.version}/${mkReleaseName system}";
  systems = {
    "x86_64-linux" = "linux_x86_64";
    "aarch64-linux" = "linux_arm64";
    "x86_64-darwin" = "macos_x86_64";
    "aarch64-darwin" = "macos_apple_silicon";
  };
in
  nixpkgsSystem: let
    system = systems.${nixpkgsSystem};
  in {
    inherit (current) version;

    url = mkGHUrl system;
    sha256 = current.hashes.${system};
  }
