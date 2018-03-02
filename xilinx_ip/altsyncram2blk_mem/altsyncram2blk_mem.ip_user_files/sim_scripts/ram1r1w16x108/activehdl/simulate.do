onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+ram1r1w16x108 -L xil_defaultlib -L xpm -L blk_mem_gen_v8_4_0 -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.ram1r1w16x108 xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {ram1r1w16x108.udo}

run -all

endsim

quit -force
