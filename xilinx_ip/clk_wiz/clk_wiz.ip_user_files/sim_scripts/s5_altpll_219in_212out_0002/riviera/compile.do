vlib work
vlib riviera

vlib riviera/xil_defaultlib
vlib riviera/xpm

vmap xil_defaultlib riviera/xil_defaultlib
vmap xpm riviera/xpm

vlog -work xil_defaultlib  -sv2k12 "+incdir+../../../ipstatic" "+incdir+../../../ipstatic" \
"/opt/Xilinx/Vivado/2017.3/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \

vcom -work xpm -93 \
"/opt/Xilinx/Vivado/2017.3/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../ipstatic" "+incdir+../../../ipstatic" \
"../../../../clk_wiz.srcs/sources_1/ip/s5_altpll_219in_212out_0002/s5_altpll_219in_212out_0002_clk_wiz.v" \
"../../../../clk_wiz.srcs/sources_1/ip/s5_altpll_219in_212out_0002/s5_altpll_219in_212out_0002.v" \

vlog -work xil_defaultlib \
"glbl.v"

