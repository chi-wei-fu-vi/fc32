onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib ram1r1w64x144_opt

do {wave.do}

view wave
view structure
view signals

do {ram1r1w64x144.udo}

run -all

quit -force
