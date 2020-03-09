#!/bin/bash

echo ""
echo "Installing homebrew"
echo "--------------------------------------------------"

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

brew install ssh-copy-id
