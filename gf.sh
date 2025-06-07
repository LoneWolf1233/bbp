#!/bin/bash

TOOLS_DIR=$HOME/tools
PYTHON_VENV=$HOME/Python-Environments
export WORDLIST_DIR="$TOOLS_DIR/wordlists"
GOBIN=$(go env GOPATH)/bin
mkdir -p "$WORDLIST_DIR"
mkdir -p "$TOOLS_DIR"
mkdir -p "$PYTHON_VENV"


echo -e "Installing Ghauri in a virtual environment..."
sudo apt-get install python3-setuptools
git clone https://github.com/r0oth3x49/ghauri.git "$TOOLS_DIR/ghauri"
python3 -m venv $PYTHON_VENV/ghauri
source $PYTHON_VENV/ghauri/bin/activate
pip install setuptools
python3 $TOOLS_DIR/ghauri/setup.py install
deactivate
cd $HOME

