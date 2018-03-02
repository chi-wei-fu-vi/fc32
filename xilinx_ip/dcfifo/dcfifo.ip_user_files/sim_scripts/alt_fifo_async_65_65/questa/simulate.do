onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib alt_fifo_async_65_65_opt

do {wave.do}

view wave
view structure
view signals

do {alt_fifo_async_65_65.udo}

run -all

quit -force
