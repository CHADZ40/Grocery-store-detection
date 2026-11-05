#!/usr/bin/env bash
# Sets up Python packages and opens the notebook. Run with: bash start_mac_linux.sh
set -e
cd "$(dirname "$0")"

if [ ! -x .venv/bin/python ]; then
    echo "Creating the Python environment..."
    python3 -m venv .venv
fi

echo "Installing packages. The first time can take several minutes..."
.venv/bin/python -m pip install --upgrade pip
.venv/bin/python -m pip install -r requirements.txt

.venv/bin/python -c "import torch; print('NVIDIA GPU:', torch.cuda.is_available(), '| Apple GPU:', torch.backends.mps.is_available())"

if [ "$1" != "--no-open" ]; then
    source .venv/bin/activate
    python -m notebook yolo_detect_grocery.ipynb
fi
