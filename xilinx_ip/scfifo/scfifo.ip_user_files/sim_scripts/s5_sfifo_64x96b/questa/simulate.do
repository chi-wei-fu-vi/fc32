onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib s5_sfifo_64x96b_opt

do {wave.do}

view wave
view structure
view signals

do {s5_sfifo_64x96b.udo}

run -all

quit -force
