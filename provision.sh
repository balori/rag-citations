#!/usr/bin/env bash
#
# provision.sh — set up THIS project's isolated virtualenv + Jupyter kernel.
#
# Fully self-contained: it operates only on its own folder, so this project can be
# copied out and provisioned on its own. Creates:
#   - .venv/                             isolated deps from ./requirements.txt
#   - a Jupyter kernel "GenAI: <folder>" (name: genai-<folder>)
#   - points this folder's notebook(s) at that kernel
#
# Usage:
#   ./provision.sh                    provision this project
#   PYTHON=python3.12 ./provision.sh  pick the interpreter (needed if torch lacks a wheel)
#   ./provision.sh --clean            remove the venv and kernel
#
# Requirements: bash, python3 (with the `venv` module), network access for pip. macOS/Linux.

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT="$(basename "$DIR")"
KERNEL="genai-$PROJECT"
DISP="GenAI: $PROJECT"
PYTHON="${PYTHON:-python3}"
VENV="$DIR/.venv"
PY="$VENV/bin/python"

remove_kernel() {
  rm -rf "$HOME/Library/Jupyter/kernels/$KERNEL" \
         "$HOME/.local/share/jupyter/kernels/$KERNEL" 2>/dev/null
}

case "${1:-}" in
  --clean)
    remove_kernel
    rm -rf "$VENV"
    echo "$PROJECT: removed .venv and kernel $KERNEL"
    exit 0 ;;
  -h|--help)
    sed -n '2,20p' "$0"; exit 0 ;;
esac

if [ ! -f "$DIR/requirements.txt" ]; then
  echo "$PROJECT: no requirements.txt next to provision.sh — nothing to do"; exit 1
fi

echo "=== provisioning $PROJECT ==="
echo "  [1/4] creating venv with $PYTHON"
if ! "$PYTHON" -m venv "$VENV"; then
  echo "  ERROR: could not create a venv with '$PYTHON'"; exit 1
fi

echo "  [2/4] upgrading pip"
"$PY" -m pip install --quiet --upgrade pip

echo "  [3/4] installing requirements.txt (+ ipykernel)"
if ! "$PY" -m pip install --quiet -r "$DIR/requirements.txt" ipykernel; then
  echo "  ERROR: pip install failed."
  echo "         If torch has no wheel for $PYTHON, retry e.g.:  PYTHON=python3.12 $0"
  exit 1
fi

echo "  [4/4] registering kernel '$DISP'  (name: $KERNEL)"
"$PY" -m ipykernel install --user --name "$KERNEL" --display-name "$DISP" >/dev/null

for nb in "$DIR"/*.ipynb; do
  [ -e "$nb" ] || continue
  "$PY" - "$nb" "$KERNEL" "$DISP" <<'PY'
import json, sys
path, name, disp = sys.argv[1], sys.argv[2], sys.argv[3]
d = json.load(open(path))
d.setdefault("metadata", {})["kernelspec"] = {"name": name, "display_name": disp, "language": "python"}
with open(path, "w") as f:
    json.dump(d, f, indent=1)
PY
done

echo "  OK — open this folder's .ipynb and select the '$DISP' kernel"
