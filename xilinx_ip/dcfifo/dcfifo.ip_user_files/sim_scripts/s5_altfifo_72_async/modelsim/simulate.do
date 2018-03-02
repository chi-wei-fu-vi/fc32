onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -t 1ps -L xil_defaultlib -L xpm -L fifo_generator_v13_2_0 -L unisims_ver -L unimacro_ver -L secureip -lib xil_defaultlib xil_defaultlib.s5_altfifo_72_async xil_defaultlib.glbl

do {wave.do}

view wave
view structure
view signals

do {s5_altfifo_72_async.udo}

run -all

quit -force
