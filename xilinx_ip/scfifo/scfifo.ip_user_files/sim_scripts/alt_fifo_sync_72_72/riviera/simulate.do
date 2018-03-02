onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+alt_fifo_sync_72_72 -L xil_defaultlib -L xpm -L fifo_generator_v13_2_0 -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.alt_fifo_sync_72_72 xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {alt_fifo_sync_72_72.udo}

run -all

endsim

quit -force
