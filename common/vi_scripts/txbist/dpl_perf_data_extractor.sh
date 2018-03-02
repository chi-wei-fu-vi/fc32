#!/bin/bash

ARGS_OK=1
LIST_OF_LINK_NUMBERS=()
NLINKS=0
MONITOR_CPU_USAGE=0
MONITOR_CPU_PROC_PID=
CPU_LOG_FILE=/var/log/dpl_perf.cpu.log
DAL_REG_LOG_FILE=/var/log/dpl_perf.dal.reg.log

declare -a DPL_PROCS_LIST
declare -a DPL_PROC_TO_LINK_HASH
declare -a LINK_DROPPED_FRAME_COUNTER_HASH_CH0
declare -a LINK_DROPPED_FRAME_COUNTER_HASH_CH1

#--------------------------------------------------------------------------------------------------
function signal_handler()
{
    echo 'dpl_perf_data_extractor: caught SIGINT/SIGUSR1';

    echo "Sending SIGUSR1 to DPL processes"
    cat ./dpl_proc.run | xargs kill -SIGUSR1
    
    stop_cpu_monitor_proc
}
trap signal_handler SIGUSR1 SIGUSR2 SIGINT


#--------------------------------------------------------------------------------------------------
function start_cpu_monitor_proc()
{
    echo "Launching CPU monitor:"
    echo ${DPL_PROCS_LIST[@]} > ./dpl_proc.run 
    echo "HOME DIR:"$HOME
     date +"%d.%m.%Y %H:%M:%S"  > $CPU_LOG_FILE
    top -bc >> $CPU_LOG_FILE &
    MONITOR_CPU_PROC_PID=$!
}


#--------------------------------------------------------------------------------------------------
function stop_cpu_monitor_proc()
{
    echo "Sending SIGUSR1 to CPU monitor child processes"
    /bin/kill -9 $MONITOR_CPU_PROC_PID  > /dev/null 2>&1
    wait $MONITOR_CPU_PROC_PID    
}


#--------------------------------------------------------------------------------------------------
function init_dpl_list_and_hashes()
{
    read -a DPL_PROCS_LIST <<< `pidof dpl`

    for proc_id in ${DPL_PROCS_LIST[@]}
    do
        cmd_line=`cat /proc/$proc_id/cmdline`

        link_number=`echo $cmd_line | sed 's/^.*-l\(.*\)-o.*/\1/'`

        DPL_PROCS_LIST+=($proc_id)

        DPL_PROC_TO_LINK_HASH[$proc_id]=$link_number

        LINK_DROPPED_FRAME_COUNTER_HASH_CH0[$link_number]=0

        LINK_DROPPED_FRAME_COUNTER_HASH_CH1[$link_number]=0
    done
}


#--------------------------------------------------------------------------------------------------
function update_dropped_frame_counter()
{
    for proc_id in ${DPL_PROCS_LIST[@]}
    do
        local link_number=${DPL_PROC_TO_LINK_HASH[$proc_id]}

        ch0_count_prev=${LINK_DROPPED_FRAME_COUNTER_HASH_CH0[$link_number]}
        ch1_count_prev=${LINK_DROPPED_FRAME_COUNTER_HASH_CH1[$link_number]}

        read ch0_count < /sys/class/dal/fclink${link_number}/ch0/extr/DataFrameBpCtr
        read ch1_count < /sys/class/dal/fclink${link_number}/ch1/extr/DataFrameBpCtr

        LINK_DROPPED_FRAME_COUNTER_HASH_CH0[$link_number]=$((ch0_count - ch0_count_prev))
        LINK_DROPPED_FRAME_COUNTER_HASH_CH1[$link_number]=$((ch1_count - ch1_count_prev))
    done
}


#--------------------------------------------------------------------------------------------------
function write_out_dropped_frame_counter()
{
    for proc_id in ${DPL_PROCS_LIST[@]}
    do
        local link_number=${DPL_PROC_TO_LINK_HASH[$proc_id]}

        ch0_count=${LINK_DROPPED_FRAME_COUNTER_HASH_CH0[$link_number]}
        ch1_count=${LINK_DROPPED_FRAME_COUNTER_HASH_CH1[$link_number]}


        echo "{ \"link_num\":$link_number,"\
            "\"ch0_dropped_frames\":$ch0_count,"\
            "\"ch1_dropped_frames\":$ch1_count"\
            "}"\
            >> $DAL_REG_LOG_FILE
    done    
}


#--------------------------------------------------------------------------------------------------
function main
{
    echo $$ > /var/log/.dpl_perf_data_extractor.run

    echo "Clearing out old performance logs ..."
    rm -f /var/log/dpl_perf*
    rm -f $CPU_LOG_FILE
    rm -f $DAL_REG_LOG_FILE

    init_dpl_list_and_hashes

    start_cpu_monitor_proc

    echo "Sending performance-counter-reset SIGNAL to DPL processes ..."
    killall -SIGUSR1 dpl

    update_dropped_frame_counter

    echo "Sleeping for $DPL_INTERVAL_REPEATS ..."
    sleep $DPL_INTERVAL_REPEATS

    update_dropped_frame_counter

    echo "Sending performance-log-dump signal to DPL processes ..."
    killall -SIGUSR2 dpl

    sleep 3

    stop_cpu_monitor_proc

    write_out_dropped_frame_counter

    echo "DPL Perf Data Extractor Exited!"
}


#--------------------------------------------------------------------------------------------------

while getopts "l:r:" opt; do
    case $opt in
    l)
        NLINKS=$OPTARG
        ;;
    r)
        DPL_INTERVAL_REPEATS=$OPTARG
        ;;
    
    \?)
        echo "Invalid option: -$OPTARG"
        ARGS_OK=0
        ;;
    :)
        echo "Option -$OPTARG requires an argument."
        ARGS_OK=0
        ;;
    esac
done

# call main
if [ $ARGS_OK -eq 1 ]
then
    main
fi
