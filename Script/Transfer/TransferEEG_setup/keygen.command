#!/bin/bash

echo ""
echo "Creating access keys to remote server"
echo "--------------------------------------------------"

ssh-keygen -t rsa -b 4096

echo ""
echo "Installing access keys in remote server"
echo "--------------------------------------------------"

ssh-copy-id innn@elefant.imbim.uu.se
