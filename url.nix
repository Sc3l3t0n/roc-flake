rec {
  repo = "roc-lang/nightlies";
  baseReleaseUrl = "https://github.com/${repo}/releases/download";
  mkReleaseName = system: current: "roc_nightly-${system}-${current.releaseNameVersion}.tar.gz";
  mkGHUrl = system: current: "${baseReleaseUrl}/${current.version}/${mkReleaseName system current}";
  systemsMap = {
    "x86_64-linux" = "linux_x86_64";
    "aarch64-linux" = "linux_arm64";
    "x86_64-darwin" = "macos_x86_64";
    "aarch64-darwin" = "macos_apple_silicon";
  };
}
