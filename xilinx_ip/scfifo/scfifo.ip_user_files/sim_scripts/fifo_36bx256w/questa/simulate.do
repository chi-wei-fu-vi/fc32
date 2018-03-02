onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib fifo_36bx256w_opt

do {wave.do}

view wave
view structure
view signals

do {fifo_36bx256w.udo}

run -all

quit -force
