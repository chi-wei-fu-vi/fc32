#!/bin/sh

cd syn
make syn
echo "** Running quartus_map ** "
quartus_map --64bit fc8_top | tee map.log

for SEED in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
do
    cd ../
    echo "** Starting fit with seed=$SEED"
    cp -p -r syn syn_seed$SEED
    cd syn_seed$SEED
    quartus_fit --64bit --pack_register=auto --read_settings_files=on --write_settings_files=off --seed=$SEED fc8_top | tee fit.log
    quartus_sta --64bit --do_report_timing fc8_top | tee sta.log
done
