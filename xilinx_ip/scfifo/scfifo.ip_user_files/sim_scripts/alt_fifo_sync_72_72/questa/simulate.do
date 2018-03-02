onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib alt_fifo_sync_72_72_opt

do {wave.do}

view wave
view structure
view signals

do {alt_fifo_sync_72_72.udo}

run -all

quit -force
