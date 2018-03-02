onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+s5_ram1w1r1c_16kx72b_ch0 -L xil_defaultlib -L xpm -L blk_mem_gen_v8_4_0 -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.s5_ram1w1r1c_16kx72b_ch0 xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {s5_ram1w1r1c_16kx72b_ch0.udo}

run -all

endsim

quit -force
