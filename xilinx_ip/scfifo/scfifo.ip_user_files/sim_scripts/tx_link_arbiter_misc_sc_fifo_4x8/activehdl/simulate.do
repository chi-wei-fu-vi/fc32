onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+tx_link_arbiter_misc_sc_fifo_4x8 -L xil_defaultlib -L xpm -L fifo_generator_v13_2_0 -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.tx_link_arbiter_misc_sc_fifo_4x8 xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {tx_link_arbiter_misc_sc_fifo_4x8.udo}

run -all

endsim

quit -force
