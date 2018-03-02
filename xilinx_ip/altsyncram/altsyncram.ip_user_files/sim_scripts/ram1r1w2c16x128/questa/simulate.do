onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib ram1r1w2c16x128_opt

do {wave.do}

view wave
view structure
view signals

do {ram1r1w2c16x128.udo}

run -all

quit -force
