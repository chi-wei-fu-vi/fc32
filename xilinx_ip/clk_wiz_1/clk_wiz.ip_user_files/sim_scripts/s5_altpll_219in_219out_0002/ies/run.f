-makelib ies_lib/xil_defaultlib -sv \
  "/opt/Xilinx/Vivado/2017.3/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
-endlib
-makelib ies_lib/xpm \
  "/opt/Xilinx/Vivado/2017.3/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../../clk_wiz.srcs/sources_1/ip/s5_altpll_219in_219out_0002/s5_altpll_219in_219out_0002_clk_wiz.v" \
  "../../../../clk_wiz.srcs/sources_1/ip/s5_altpll_219in_219out_0002/s5_altpll_219in_219out_0002.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  glbl.v
-endlib

