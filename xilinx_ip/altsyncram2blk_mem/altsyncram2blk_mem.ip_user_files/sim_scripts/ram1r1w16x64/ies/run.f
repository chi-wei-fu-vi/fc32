-makelib ies_lib/xil_defaultlib -sv \
  "/opt/Xilinx/Vivado/2017.3/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib ies_lib/xpm \
  "/opt/Xilinx/Vivado/2017.3/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies_lib/blk_mem_gen_v8_4_0 \
  "../../../ipstatic/simulation/blk_mem_gen_v8_4.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../../altsyncram2blk_mem.srcs/sources_1/ip/ram1r1w16x64/sim/ram1r1w16x64.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  glbl.v
-endlib

