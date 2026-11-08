#!/usr/bin/env bash
# Build hello-world for every CPU architecture that Zig supports on one OS.
#
# Usage: scripts/build-os.sh <os> <output-dir>
#   <os>          A general-purpose OS tag understood by Zig, e.g. "linux".
#   <output-dir>  Directory where the resulting binaries are copied.
#
# Architecture/OS combinations that Zig cannot build are reported as
# warnings and skipped. The script succeeds if at least one binary was built.

set -uo pipefail

if [ "$#" -ne 2 ]; then
  echo "usage: $0 <os> <output-dir>" >&2
  exit 2
fi

os="$1"
out_dir="$2"
work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT

mkdir -p "$out_dir"

# Architectures that cannot host a general-purpose OS.
excluded_archs='^(spirv32|spirv64|nvptx|nvptx64|amdgcn|bpfel|bpfeb|wasm32|wasm64)$'

# Every architecture Zig knows about for this Zig version.
archs="$(zig targets | jq -r '.arch[]' | grep -Ev "$excluded_archs")"

built=0
failed=()

for arch in $archs; do
  triple="${arch}-${os}"

  # Linux binaries are linked against musl so they are statically linked
  # and run on any distribution.
  if [ "$os" = "linux" ]; then
    triple="${arch}-linux-musl"
  fi

  echo "::group::Building ${triple}"
  if zig build \
      -Dtarget="$triple" \
      -Doptimize=ReleaseSafe \
      --prefix "$work_dir/$arch"; then
    cp "$work_dir/$arch"/bin/hello-* "$out_dir/"
    built=$((built + 1))
  else
    failed+=("$triple")
  fi
  echo "::endgroup::"
done

echo "Built ${built} binaries for ${os}."

for t in "${failed[@]}"; do
  echo "::warning::Skipped unsupported target: ${t}"
done

[ "$built" -gt 0 ]
