{
  pkgs,
  system,
  ...
}: let
  src = import ./src.nix system;
in
  pkgs.stdenv.mkDerivation {
    inherit (src) version;
    pname = "roc";

    src = pkgs.fetchurl {
      inherit (src) url sha256;
    };

    dontBuild = true;

    installPhase = ''
      mkdir -p $out/bin
      mv roc $out/bin
      chmod +x $out/bin/roc
    '';

    meta = with pkgs.lib; {
      description = "Roc Zig compiler";
      homepage = "https://roc-lang.org/";
      license = licenses.mit; # TODO:
    };
  }
