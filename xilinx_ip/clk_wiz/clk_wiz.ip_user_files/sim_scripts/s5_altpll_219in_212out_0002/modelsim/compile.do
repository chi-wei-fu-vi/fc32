vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib
vlib modelsim_lib/msim/xpm

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib
vmap xpm modelsim_lib/msim/xpm

vlog -work xil_defaultlib -64 -incr -sv "+incdir+../../../ipstatic" "+incdir+../../../ipstatic" \
"/opt/Xilinx/Vivado/2017.3/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \

vcom -work xpm -64 -93 \
"/opt/Xilinx/Vivado/2017.3/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib -64 -incr "+incdir+../../../ipstatic" "+incdir+../../../ipstatic" \
"../../../../clk_wiz.srcs/sources_1/ip/s5_altpll_219in_212out_0002/s5_altpll_219in_212out_0002_clk_wiz.v" \
"../../../../clk_wiz.srcs/sources_1/ip/s5_altpll_219in_212out_0002/s5_altpll_219in_212out_0002.v" \

vlog -work xil_defaultlib \
"glbl.v"

