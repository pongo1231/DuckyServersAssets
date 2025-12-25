#!/bin/sh

echo "\n" >> ../mvm_sandbox.log
while true; do ./source_logger -game tf +maxplayers 32 +map $(../../randommap.sh) +sv_pure -1 +ip 0.0.0.0 -port 27016 +tv_enable 1 +tv_port 26016 2>&1 | grep --line-buffered -v Setting\ sv_visiblemaxplayers\ to\ ..\ for\ MvM | tee -a ../mvm_sandbox.log; done
