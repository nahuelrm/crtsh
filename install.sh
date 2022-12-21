#!/bin/bash

sudo cp crtsh.sh /bin/crtsh
sudo chmod +x /bin/crtsh
sudo chown root:root /bin/crtsh

sudo cp libcrt.lib /lib/libcrt.lib
sudo chown root:root /lib/libcrt.lib
