#!/bin/bash

FRAME_RATE_LIST=( 1000 1100 1200 1300 1400 1500 1600 1700 1800 )

for frame_rate in ${FRAME_RATE_LIST[@]}
do
	./txbist_interface.sh load $frame_rate
	./txbist_interface.sh start $frame_rate
	sleep 30
	./txbist_interface.sh stop
done