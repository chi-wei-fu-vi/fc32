onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+s5_native_phy_16gbps -L gtwizard_ultrascale_v1_7_1 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.s5_native_phy_16gbps xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {s5_native_phy_16gbps.udo}

run -all

endsim

quit -force
