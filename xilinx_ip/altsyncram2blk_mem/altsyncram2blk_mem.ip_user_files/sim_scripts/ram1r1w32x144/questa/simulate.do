onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib ram1r1w32x144_opt

do {wave.do}

view wave
view structure
view signals

do {ram1r1w32x144.udo}

run -all

quit -force
