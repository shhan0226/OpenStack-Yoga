# OpenStack-Yoga
- This is an OpenStack:Yoga installation script.

</br>

## Prerequisites
- It is based on installing OpenStack on two servers, Controller Node and Compute Node.
- The OS of each node is ubuntu20.04.

</br>

## Configure components
- Before you install and configure the inpute values.
  ```
  vi set.conf
  >
  # Inpute Value
  CONTROLLER_HOSTv="controller" # controller hostname
  COMPUTE_HOSTv="compute1"      # compute hostname
  SET_IPv="192.168.1.150"       # controller ip
  SET_IP2v="192.168.1.150"      # compute ip
  SET_IP_ALLOWv="192.168.0.0/22"                # allow ip 
  INTERFACE_NAME_v="eth0|enP6p1s0|br-provider"  # insterface name
  STACK_PASSWDv="stack"         # default passwd
  CPU_ARCHv="arm64|amd64"       # cpu architectureh
  ...
  ```

</br>

## Installation

### Controller Node
- Start the OpenStack installation of the Controller Node
  ```
  cd OpenStack-Yoga
  source controller-run.sh
  ```

### Compute Node
- Start the OpenStack installation of the Compute Node
  ```
  cd OpenStack-Yoga
  source compute-run.sh
  ```

</br>

## BUG Fix
- bug.1  
  - Warning Messages
    ```
    /usr/lib/python3/dist-packages/secretstorage/dhcrypto.py:15: CryptographyDeprecationWarning: int_from_bytes is deprecated, use int.from_bytes instead
    from cryptography.utils import int_from_bytes
    /usr/lib/python3/dist-packages/secretstorage/util.py:19: CryptographyDeprecationWarning: int_from_bytes is deprecated, use int.from_bytes instead
    from cryptography.utils import int_from_bytes
    ```
  - Sol
    ```
    cd OpenStack-Yoga
    sh fix.sh
    ```