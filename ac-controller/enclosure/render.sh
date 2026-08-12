#!/usr/bin/env bash
# render.sh — export all parts to STL using OpenSCAD CLI
#
# Usage:
#   ./render.sh            # render all parts
#   ./render.sh base       # render one part by name
#
# Requires OpenSCAD 2021.01 or later.
# Install: sudo apt install openscad   (Debian/Ubuntu)
#          sudo dnf install openscad   (Fedora)
#          brew install openscad       (macOS)
#
# Output files go to stl/ directory.
# For final prints use $fn=128 (set in params.scad before rendering).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUT="$SCRIPT_DIR/stl"
mkdir -p "$OUT"

render() {
    local name="$1"
    local src="$SCRIPT_DIR/${name}.scad"
    local dst="$OUT/${name}.stl"
    echo "Rendering $name ..."
    openscad --export-format binstl -o "$dst" "$src"
    echo "  → $dst"
}

case "${1:-all}" in
    base)        render base ;;
    box_lower)   render box_lower ;;
    box_upper)   render box_upper ;;
    socket_cap)  render socket_cap ;;
    all)
        render base
        render box_lower
        render box_upper
        render socket_cap
        echo "Done. STL files in stl/"
        ;;
    *)
        echo "Unknown part: $1"
        echo "Valid parts: base box_lower box_upper socket_cap all"
        exit 1
        ;;
esac
