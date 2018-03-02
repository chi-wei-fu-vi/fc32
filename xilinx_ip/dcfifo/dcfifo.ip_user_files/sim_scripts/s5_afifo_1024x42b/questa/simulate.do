onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib s5_afifo_1024x42b_opt

do {wave.do}

view wave
view structure
view signals

do {s5_afifo_1024x42b.udo}

run -all

quit -force
