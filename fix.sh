#!/bin/bash

echo "Fix CryptographyDeprecationWarning"
pip3 uninstall matrix-synapse twisted cryptography bcrypt cftp
pip3 install cryptography==3.2
