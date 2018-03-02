onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib tlp_decode_sc_fifo_48x8_opt

do {wave.do}

view wave
view structure
view signals

do {tlp_decode_sc_fifo_48x8.udo}

run -all

quit -force
