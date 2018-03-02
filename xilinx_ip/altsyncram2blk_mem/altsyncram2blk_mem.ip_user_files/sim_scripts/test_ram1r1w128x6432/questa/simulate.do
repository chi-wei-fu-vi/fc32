onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib test_ram1r1w128x6432_opt

do {wave.do}

view wave
view structure
view signals

do {test_ram1r1w128x6432.udo}

run -all

quit -force
