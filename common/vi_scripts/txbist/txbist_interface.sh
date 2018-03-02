#!/bin/bash

PROBE_PERF_SCRIPT_DIR=/tmp/dpl_perf

TXBIST_DATA_DIR=$PROBE_PERF_SCRIPT_DIR/txbist_data

TXBIST_CMD=/usr/local/vi/bin/test_fc_8g.py
#TXBIST_CMD=/src/pld/trunk/platform/src/txbist/test_fc_8g.py
#----------------------------------------------------------------------------------------------------------------------
function run_cmd()
{
    local cmd=$1
    echo $1
    $cmd
}

#----------------------------------------------------------------------------------------------------------------------
function load_test()
{
    frame_rate=$1
    for dal in {0..0}
    do
        for chan in {0..1}
        do
            run_cmd "$TXBIST_CMD write $chan $TXBIST_DATA_DIR/data_ch${chan}.${frame_rate}k.ptc -scramble 1 -fpga $dal"
        done
    done
}


#----------------------------------------------------------------------------------------------------------------------
function start_test()
{
    local frame_rate=$1
    local dal=$2
    local meta_file=$TXBIST_DATA_DIR/data.${frame_rate}k.txt

    if [ -f $meta_file ]; then

        meta_file=$TXBIST_DATA_DIR/data.${frame_rate}k.txt
        read -r length < $meta_file


        if [ -z "$dal" ]; then
            for dal in {0..0}
            do
                run_cmd "$TXBIST_CMD start -loop 0 -fpga $dal -l $length"
            done
        else
            run_cmd "$TXBIST_CMD start -loop 0 -fpga $dal -l $length"
        fi
    else
        echo "Error: mata file: $meta_file not found"
    fi
}


#----------------------------------------------------------------------------------------------------------------------
function stop_test()
{
    local dal=$1
    if [ -z "$dal" ]; then
        for dal in {0..0}
        do
            run_cmd "$TXBIST_CMD stop -fpga $dal"
        done
    else
        run_cmd "$TXBIST_CMD stop -fpga $dal"
    fi
}


#----------------------------------------------------------------------------------------------------------------------


case $1 in
load)
    if [ -n "$2" ]; then
        data_file=$TXBIST_DATA_DIR/data_ch0.${2}k.ptc
        if [ -f  $data_file ]; then
            load_test $2
        else
            echo "Error: The specified frame rate does not have a coressponding txbist data file: $data_file"
        fi
    else
        echo "Error invalid argument for load command, specify frame rate"
    fi
    ;;
start)
    if [ -n "$2" ]; then
         start_test $2 $3
    else
        echo "Error: frame_rate argument expected"
    fi
    ;;

stop)
    stop_test $2
    ;;
   :)
    echo "unknown command $1"
    ;;
esac

