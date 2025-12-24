#!/bin/sh
if [ -f ./tf/custom/pongo/cfg/mapcycle.txt ]; then
	grep -vE '^\s*(//|$)' ./tf/custom/pongo/cfg/mapcycle.txt | shuf -n 1 
else
	grep -oP '"map"\s+"\K[^"]+' ./tf/custom/pongo/tf_mvm_missioncycle.res | shuf -n 1
fi
