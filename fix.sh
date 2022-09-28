#!/bin/bash

echo "Fix CryptographyDeprecationWarning"
pip3 uninstall -y matrix-synapse twisted cryptography bcrypt cftp
pip3 install -y cryptography==3.2
