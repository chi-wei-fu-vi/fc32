onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib ram1r1w16x108_opt

do {wave.do}

view wave
view structure
view signals

do {ram1r1w16x108.udo}

run -all

quit -force
