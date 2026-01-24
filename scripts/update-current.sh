#!/usr/bin/env bash
set -euo pipefail

root_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
src_nix="$root_dir/src.nix"
current_nix="$root_dir/current.nix"
url_nix="$root_dir/url.nix"

if [[ ! -f "$src_nix" ]]; then
  echo "Missing $src_nix" >&2
  exit 1
fi

if [[ ! -f "$current_nix" ]]; then
  echo "Missing $current_nix" >&2
  exit 1
fi

if [[ ! -f "$url_nix" ]]; then
  echo "Missing $url_nix" >&2
  exit 1
fi

base_url=$(nix eval --raw --file "$url_nix" baseReleaseUrl)
if [[ -z "$base_url" ]]; then
  echo "baseReleaseUrl not found in url.nix" >&2
  exit 1
fi

repo=$(nix eval --raw --file "$url_nix" repo)
if [[ -z "$repo" ]]; then
  echo "repo not found in url.nix" >&2
  exit 1
fi

systems_json=$(nix eval --json --file "$url_nix" systemsMap)
mapfile -t systems < <(jq -r 'to_entries[].value' <<<"$systems_json" | sort)

if (( ${#systems[@]} == 0 )); then
  echo "no systems found in url.nix" >&2
  exit 1
fi

systems_json=$(printf '%s\n' "${systems[@]}" | jq -R . | jq -s .)

auth_header=()
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  auth_header=(-H "Authorization: Bearer $GITHUB_TOKEN")
fi

release_json=$(curl -sSL "${auth_header[@]}" "https://api.github.com/repos/${repo}/releases/latest")

declare -A asset_urls=()
tag=$(jq -r '.tag_name // empty' <<<"$release_json")
if [[ -z "$tag" ]]; then
  echo "tag_name missing from release JSON" >&2
  exit 1
fi

release_name_version=""

while IFS=$'\t' read -r system version url; do
  if [[ -z "$release_name_version" ]]; then
    release_name_version="$version"
  elif [[ "$release_name_version" != "$version" ]]; then
    echo "mismatched release versions in assets" >&2
    exit 1
  fi
  asset_urls["$system"]="$url"
done < <(
  jq -r --argjson systems "$systems_json" '
    .assets[]
    | (try (.name | capture("^roc_nightly-(?<system>.+)-(?<version>[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9a-f]+)\\.tar\\.gz$")) catch empty) as $c
    | select($c != null)
    | select($systems | index($c.system))
    | "\($c.system)\t\($c.version)\t\(.browser_download_url)"
  ' <<<"$release_json"
)

missing=()
for system in "${systems[@]}"; do
  if [[ -z "${asset_urls[$system]:-}" ]]; then
    missing+=("$system")
  fi
done
if (( ${#missing[@]} )); then
  echo "missing assets for: ${missing[*]}" >&2
  exit 1
fi

if [[ -z "$release_name_version" ]]; then
  echo "no matching assets found" >&2
  exit 1
fi

declare -A hashes=()
for system in "${systems[@]}"; do
  url="${asset_urls[$system]:-}"
  if [[ -z "$url" ]]; then
    echo "Missing asset URL for $system" >&2
    exit 1
  fi
  hash=$(nix store prefetch-file --json "$url" | jq -r '.hash // empty')
  if [[ -z "$hash" ]]; then
    echo "hash missing from nix prefetch output" >&2
    exit 1
  fi
  hashes["$system"]="$hash"
done

cat >"$current_nix" <<EOF
{
  version = "${tag}";
  releaseNameVersion = "${release_name_version}";
  hashes = {
EOF

for system in "${systems[@]}"; do
  printf '    "%s" = "%s";\n' "$system" "${hashes[$system]}" >>"$current_nix"
done

cat >>"$current_nix" <<EOF
  };
}
EOF

echo "Updated $current_nix for ${repo} ${tag}"
