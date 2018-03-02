onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib template_ram_opt

do {wave.do}

view wave
view structure
view signals

do {template_ram.udo}

run -all

quit -force
