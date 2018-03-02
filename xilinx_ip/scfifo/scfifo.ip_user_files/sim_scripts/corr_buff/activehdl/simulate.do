onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+corr_buff -L xil_defaultlib -L xpm -L fifo_generator_v13_2_0 -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.corr_buff xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {corr_buff.udo}

run -all

endsim

quit -force
