vlib work
vlib riviera

vlib riviera/xil_defaultlib
vlib riviera/xpm
vlib riviera/fifo_generator_v13_2_0

vmap xil_defaultlib riviera/xil_defaultlib
vmap xpm riviera/xpm
vmap fifo_generator_v13_2_0 riviera/fifo_generator_v13_2_0

vlog -work xil_defaultlib  -sv2k12 \
"/opt/Xilinx/Vivado/2017.3/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"/opt/Xilinx/Vivado/2017.3/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93 \
"/opt/Xilinx/Vivado/2017.3/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work fifo_generator_v13_2_0  -v2k5 \
"../../../ipstatic/simulation/fifo_generator_vlog_beh.v" \

vcom -work fifo_generator_v13_2_0 -93 \
"../../../ipstatic/hdl/fifo_generator_v13_2_rfs.vhd" \

vlog -work fifo_generator_v13_2_0  -v2k5 \
"../../../ipstatic/hdl/fifo_generator_v13_2_rfs.v" \

vlog -work xil_defaultlib  -v2k5 \
"../../../../scfifo.srcs/sources_1/ip/tx_app2hip_sc_fifo_48x512/sim/tx_app2hip_sc_fifo_48x512.v" \

vlog -work xil_defaultlib \
"glbl.v"

