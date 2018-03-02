onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+s5_ram1w1r1c_4096x36b_ch0 -L dist_mem_gen_v8_0_12 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.s5_ram1w1r1c_4096x36b_ch0 xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {s5_ram1w1r1c_4096x36b_ch0.udo}

run -all

endsim

quit -force
