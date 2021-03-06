onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib fifo2c8x128_opt

do {wave.do}

view wave
view structure
view signals

do {fifo2c8x128.udo}

run -all

quit -force
