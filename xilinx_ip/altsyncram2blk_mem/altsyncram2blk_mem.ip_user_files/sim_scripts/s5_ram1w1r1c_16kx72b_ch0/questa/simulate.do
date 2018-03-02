onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib s5_ram1w1r1c_16kx72b_ch0_opt

do {wave.do}

view wave
view structure
view signals

do {s5_ram1w1r1c_16kx72b_ch0.udo}

run -all

quit -force
