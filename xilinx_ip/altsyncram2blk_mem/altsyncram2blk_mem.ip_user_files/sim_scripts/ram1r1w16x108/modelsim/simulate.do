onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -t 1ps -L xil_defaultlib -L xpm -L blk_mem_gen_v8_4_0 -L unisims_ver -L unimacro_ver -L secureip -lib xil_defaultlib xil_defaultlib.ram1r1w16x108 xil_defaultlib.glbl

do {wave.do}

view wave
view structure
view signals

do {ram1r1w16x108.udo}

run -all

quit -force
