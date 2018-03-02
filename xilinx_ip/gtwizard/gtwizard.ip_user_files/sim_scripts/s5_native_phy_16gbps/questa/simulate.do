onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib s5_native_phy_16gbps_opt

do {wave.do}

view wave
view structure
view signals

do {s5_native_phy_16gbps.udo}

run -all

quit -force
