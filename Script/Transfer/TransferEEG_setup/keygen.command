#!/bin/bash

echo ""
echo "Creating access keys to remote server"
echo "--------------------------------------------------"

ssh-keygen -t rsa -b 4096

ssh-copy-id innn@elefant.imbim.uu.se
