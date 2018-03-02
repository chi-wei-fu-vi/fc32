onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib tx_link_arbiter_sc_fifo_256x256_opt

do {wave.do}

view wave
view structure
view signals

do {tx_link_arbiter_sc_fifo_256x256.udo}

run -all

quit -force
