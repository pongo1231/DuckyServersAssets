#!/bin/sh

echo "\n" >> ../mge2.log
while true; do ./source_logger -game tf +maxplayers 12 +map mge_training_v8_beta4b +sv_pure 1 +ip 0.0.0.0 -port 27020 +tv_enable 1 +tv_port 26020 2>&1 | tee -a ../mge2.log; done
