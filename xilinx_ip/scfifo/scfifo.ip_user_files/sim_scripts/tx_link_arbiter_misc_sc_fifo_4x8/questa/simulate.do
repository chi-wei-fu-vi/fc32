onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib tx_link_arbiter_misc_sc_fifo_4x8_opt

do {wave.do}

view wave
view structure
view signals

do {tx_link_arbiter_misc_sc_fifo_4x8.udo}

run -all

quit -force
