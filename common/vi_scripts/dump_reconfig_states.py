#!/usr/bin/env python2
import os, sys
import subprocess
import time
from dom_reconfig_api_13sp1 import *

def serdes_dump_state(fpgaid,verbose=1):
  """
  Dump states of reonfig controller.
  """
  lines=[]

  lines.append("Group  : AEQ")
  lines.append("  Logic Channel                  : %d" % reconfig_AEQ_get_logical_channel_address(fpgaid,verbose))
  lines.append("  adapt_done                     : %d" % reconfig_AEQ_get_adapt_done(fpgaid,verbose))
  lines.append("  equalization_results           : %d" % reconfig_AEQ_get_equalization_results(fpgaid,verbose))
  lines.append("  mode                           : %d" % reconfig_AEQ_get_mode(fpgaid,verbose))
  lines.append("Group  : DFE")
  lines.append("  Logic Channel                  : %d" % reconfig_DFE_get_logical_channel_address(fpgaid,verbose))
  lines.append("  adaptation_engine_enable       : %d" % reconfig_DFE_get_adaptation_engine_enable(fpgaid,verbose))
  lines.append("  power_on                       : %d" % reconfig_DFE_get_power_on(fpgaid,verbose))
  lines.append("  tap_1                          : %d" % reconfig_DFE_get_tap_1(fpgaid,verbose))
  lines.append("  tap_2                          : %d" % reconfig_DFE_get_tap_2(fpgaid,verbose))
  lines.append("  tap_2_polarity                 : %d" % reconfig_DFE_get_tap_2_polarity(fpgaid,verbose))
  lines.append("  tap_3                          : %d" % reconfig_DFE_get_tap_3(fpgaid,verbose))
  lines.append("  tap_3_polarity                 : %d" % reconfig_DFE_get_tap_3_polarity(fpgaid,verbose))
  lines.append("  tap_4                          : %d" % reconfig_DFE_get_tap_4(fpgaid,verbose))
  lines.append("  tap_4_polarity                 : %d" % reconfig_DFE_get_tap_4_polarity(fpgaid,verbose))
  lines.append("  tap_5                          : %d" % reconfig_DFE_get_tap_5(fpgaid,verbose))
  lines.append("  tap_5_polarity                 : %d" % reconfig_DFE_get_tap_5_polarity(fpgaid,verbose))
  lines.append("Group  : EyeQ")
  lines.append("  Logic Channel                  : %d" % reconfig_EyeQ_get_logical_channel_address(fpgaid,verbose))
  lines.append("  1D_Eye                         : %d" % reconfig_EyeQ_get_1D_Eye(fpgaid,verbose))
  lines.append("  BERB_Enable                    : %d" % reconfig_EyeQ_get_BERB_Enable(fpgaid,verbose))
  lines.append("  BERB_Snap_Shot_and_Reset       : %d" % reconfig_EyeQ_get_BERB_Snap_Shot_and_Reset(fpgaid,verbose))
  lines.append("  Bit_Counter31_0                : %d" % reconfig_EyeQ_get_Bit_Counter31_0(fpgaid,verbose))
  lines.append("  Bit_Counter63_32               : %d" % reconfig_EyeQ_get_Bit_Counter63_32(fpgaid,verbose))
  lines.append("  Counter_Enable                 : %d" % reconfig_EyeQ_get_Counter_Enable(fpgaid,verbose))
  lines.append("  Enable_Eye_Monitor             : %d" % reconfig_EyeQ_get_Enable_Eye_Monitor(fpgaid,verbose))
  lines.append("  Err_Conter63_32                : %d" % reconfig_EyeQ_get_Err_Conter63_32(fpgaid,verbose))
  lines.append("  Err_Counter31_0                : %d" % reconfig_EyeQ_get_Err_Counter31_0(fpgaid,verbose))
  lines.append("  Horizontal_phase               : %d" % reconfig_EyeQ_get_Horizontal_phase(fpgaid,verbose))
  lines.append("  Polarity                       : %d" % reconfig_EyeQ_get_Polarity(fpgaid,verbose))
  lines.append("  Vertical_height                : %d" % reconfig_EyeQ_get_Vertical_height(fpgaid,verbose))
  lines.append("Group  : PMA")
  lines.append("  Logic Channel                  : %d" % reconfig_PMA_get_logical_channel_address(fpgaid,verbose))
  lines.append("  Pre_emphasis_first_post_tap    : %d" % reconfig_PMA_get_Pre_emphasis_first_post_tap(fpgaid,verbose))
  lines.append("  Pre_emphasis_pre_tap           : %d" % tapformat(reconfig_PMA_get_Pre_emphasis_pre_tap(fpgaid,verbose)))
  lines.append("  Pre_emphasis_second_post_tap   : %d" % tapformat(reconfig_PMA_get_Pre_emphasis_second_post_tap(fpgaid,verbose)))
  lines.append("  RX_equalization_control        : %d" % reconfig_PMA_get_RX_equalization_control(fpgaid,verbose))
  lines.append("  RX_equalization_DC_gain        : %d" % reconfig_PMA_get_RX_equalization_DC_gain(fpgaid,verbose))
  lines.append("  VOD                            : %d" % reconfig_PMA_get_VOD(fpgaid,verbose))
  print "\n".join(lines)
  return lines


def set_logic_channel(fpgaid,chid):
  """
  """
  #reconfig_ATX_set_logical_channel_address(fpgaid,chid)
  #reconfig_PLL_set_logical_channel_address(fpgaid,chid)
  #reconfig_PMA_set_logical_channel_address(fpgaid,chid)
  reconfig_AEQ_set_logical_channel_address(fpgaid,chid)
  reconfig_DFE_set_logical_channel_address(fpgaid,chid)
  reconfig_EyeQ_set_logical_channel_address(fpgaid,chid)
  reconfig_PMA_set_logical_channel_address(fpgaid,chid)

def main():
  lines=[]
  date = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
  OUTFILE=open("log%s"%date.replace(' ','_'),"w")
  lines.append(date)
  for fpgaid in range(1,5):
    enable_direct_access (fpgaid)
    for linkid in range(12):
      for chid in range(2):
        lines.append("="*80)
        lines.append("FPGA %d Link %d Channel %d"%(fpgaid,linkid,chid))
        lines.append("="*80)
        set_logic_channel(fpgaid,linkid*2+chid)
        lines.extend(serdes_dump_state(fpgaid,verbose=0))
  
    disable_direct_access (fpgaid)
  OUTFILE.write("\n".join(lines))

main()




