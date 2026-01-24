let
  inherit (import ./url.nix) mkGHUrl systemsMap;
  current = import ./current.nix;
in
  nixpkgsSystem: let
    system = systemsMap.${nixpkgsSystem};
  in {
    inherit (current) version;

    url = mkGHUrl system current;
    sha256 = current.hashes.${system};
  }
