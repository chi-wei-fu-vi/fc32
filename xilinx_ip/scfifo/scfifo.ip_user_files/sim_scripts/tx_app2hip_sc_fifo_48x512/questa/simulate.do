onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib tx_app2hip_sc_fifo_48x512_opt

do {wave.do}

view wave
view structure
view signals

do {tx_app2hip_sc_fifo_48x512.udo}

run -all

quit -force
