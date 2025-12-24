#!/bin/sh

echo "\n" >> ../sandbox.log
while true; do ./source_logger -game tf +maxplayers 32 +map $(../../randommap.sh) +sv_pure -1 +ip 0.0.0.0 -port 27017 +tv_enable 1 +tv_port 27020 2>&1 | tee -a ../sandbox.log; done
