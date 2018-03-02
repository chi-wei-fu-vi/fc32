onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+s5_altpll_425in_219out_0002 -L xil_defaultlib -L xpm -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.s5_altpll_425in_219out_0002 xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {s5_altpll_425in_219out_0002.udo}

run -all

endsim

quit -force
