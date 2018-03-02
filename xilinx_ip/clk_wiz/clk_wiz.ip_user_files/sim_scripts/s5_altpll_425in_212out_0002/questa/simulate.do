onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib s5_altpll_425in_212out_0002_opt

do {wave.do}

view wave
view structure
view signals

do {s5_altpll_425in_212out_0002.udo}

run -all

quit -force
