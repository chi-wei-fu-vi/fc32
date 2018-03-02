onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -t 1ps -L gtwizard_ultrascale_v1_7_1 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -lib xil_defaultlib xil_defaultlib.s5_native_phy_16gbps xil_defaultlib.glbl

do {wave.do}

view wave
view structure
view signals

do {s5_native_phy_16gbps.udo}

run -all

quit -force
