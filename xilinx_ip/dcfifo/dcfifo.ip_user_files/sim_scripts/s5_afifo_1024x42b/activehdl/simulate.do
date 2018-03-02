onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+s5_afifo_1024x42b -L xil_defaultlib -L xpm -L fifo_generator_v13_2_0 -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.s5_afifo_1024x42b xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {s5_afifo_1024x42b.udo}

run -all

endsim

quit -force
