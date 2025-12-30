#!/bin/sh

echo "\n" >> ../mge_cheat2.log
while true; do ./source_logger -game tf +maxplayers 12 +map mge_training_v8_beta4b +sv_pure -1 -insecure +ip 0.0.0.0 -port 27025 +tv_enable 1 +tv_port 26025 2>&1 | tee -a ../mge_cheat2.log; done
