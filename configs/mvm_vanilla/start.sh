#!/bin/sh

echo "\n" >> ../mvm_vanilla.log
while true; do ./source_logger -game tf +maxplayers 32 +map $(../../randommap.sh) +sv_pure 1 +ip 0.0.0.0 -port 27015 +tv_enable 1 +tv_port 26015 2>&1 | tee -a ../mvm_vanilla.log; done
