onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib corr_buff_opt

do {wave.do}

view wave
view structure
view signals

do {corr_buff.udo}

run -all

quit -force
