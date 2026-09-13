#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "usage: $0 <version> <asset-directory>" >&2
  exit 2
fi

version="$1"
asset_dir="$2"
project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
hardware_dir="$project_dir/hardware"
work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT

mkdir -p "$asset_dir" "$work_dir/tools"
cp "$hardware_dir/tools/generate_schematic.py" "$work_dir/tools/"
python3 "$work_dir/tools/generate_schematic.py"

for file in \
  battery_monitor.kicad_sch \
  battery_monitor.kicad_pro \
  BM.kicad_sym \
  sym-lib-table \
  fp-lib-table
do
  if [[ ! -s "$work_dir/$file" ]]; then
    echo "generated KiCad file is missing or empty: $file" >&2
    exit 1
  fi
done

cp "$hardware_dir/README.md" "$work_dir/README.md"

archive="$asset_dir/battery_monitor-kicad-${version}.zip"
(
  cd "$work_dir"
  zip -q "$archive" \
    battery_monitor.kicad_sch \
    battery_monitor.kicad_pro \
    BM.kicad_sym \
    sym-lib-table \
    fp-lib-table \
    README.md
)

(
  cd "$asset_dir"
  sha256sum "$(basename "$archive")" > "$(basename "$archive").sha256"
)
