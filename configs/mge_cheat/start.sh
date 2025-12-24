#!/bin/sh

echo "\n" >> ../mge_cheat.log
while true; do ./source_logger -game tf +maxplayers 12 +map mge_training_v8_beta4b +sv_pure -1 -insecure +ip 0.0.0.0 -port 27018 +tv_enable 1 +tv_port 27023 2>&1 | tee -a ../mge_cheat.log; done
