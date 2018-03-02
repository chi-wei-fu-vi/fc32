onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib s5_altfifo_72_async_opt

do {wave.do}

view wave
view structure
view signals

do {s5_altfifo_72_async.udo}

run -all

quit -force
