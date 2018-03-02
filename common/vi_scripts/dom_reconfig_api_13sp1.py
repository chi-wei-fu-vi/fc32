#!/bin/env python2
from pprint import pprint
import os, sys
import subprocess
import time
import datetime
debug = 0

mem_map={
   'ADCE': {5: {'adapt_done': {0: '[8]'},
                'equalization_results': {1: '[3:0]'},
                'mode': {0: '[1:0]'}}},
   'ANALOG': {1: {'Post_CDR_Reverse_Serial_Loopback': {33: '[0]'},
                  'Pre_CDR_Reverse_Serial_Loopback': {32: '[0]'},
                  'Pre_emphasis_first_post_tap': {2: '[4:0]'},
                  'Pre_emphasis_pre_tap': {1: '[4:0]'},
                  'Pre_emphasis_second_post_tap': {3: '[4:0]'},
                  'RX_equalization_DC_gain': {16: '[2:0]'},
                  'RX_equalization_control': {17: '[3:0]'},
                  'VOD': {0: '[5:0]'}}},
   'DCD': {9: {}},
   'DFE': {3: {'DFE_adaptation': {11: '[0]'},
               'DFE_calibration': {10: '[0]'},
               'adaptation_engine_enable': {0: '[0]'},
               'power_on': {0: '[1]'},
               'tap_1': {1: '[3:0]'},
               'tap_2': {2: '[2:0]'},
               'tap_2_polarity': {2: '[3]'},
               'tap_3': {3: '[2:0]'},
               'tap_3_polarity': {3: '[3]'},
               'tap_4': {4: '[2:0]'},
               'tap_4_polarity': {4: '[3]'},
               'tap_5': {5: '[2:0]'},
               'tap_5_polarity': {5: '[3]'}}},
   'DIRECT': {4: {}},
   'END': {10: {}},
   'EYEMON': {2: {'1D_Eye': {3: '[13]'},
                  'Enable_Eye_Monitor': {0: '[0]'},
                  'BERB_Enable': {0: '[1]'},
                  'BERB_Snap_Shot_and_Reset': {0: '[4:3]'},
                  'Bit_Counter31_0': {5: '[31:0]'},
                  'Bit_Counter63_32': {6: '[31:0]'},
                  'Counter_Enable': {0: '[2]'},
                  'Err_Conter63_32': {8: '[31:0]'},
                  'Err_Counter31_0': {7: '[31:0]'},
                  'Horizontal_phase': {1: '[5:0]'},
                  'Polarity': {3: '[2]'},
                  'Vertical_height': {2: '[5:0]'}}},
   'LC': {6: {'Control': {0: '[1]'}}},
   'MIF': {7: {'Clear_error_status': {1: '[2]'},
               'Invalid_register_access': {2: '[0]'},
               'MIF_address_mode': {1: '[1]'},
               'MIF_base_address': {0: '[31:0]'},
               'MIF_opcode_error': {2: '[1]'},
               'MIF_or_Channel_mismatch': {2: '[4]'},
               'PLL_reconfiguration_IP_error': {2: '[2]'},
               'Start_MIF_stream': {1: '[0]'}}},
   'OFFSET': {0: {}},
   'PLL': {8: {'PLL_physical_mapping': {3: '[14:0]'},
               'TX_PLL_select': {4: '[0:0]'},
               'logical_PLL_selection': {1: '[2:0]'},
               'logical_refclk_selection': {0: '[2:0]'},
               'refclk_physical_mapping': {2: '[24:0]'}}}
}

def help_command():
  """
  enable_direct_access (fpgaid)
  disable_direct_access (fpgaid)
  enable_direct_access ()
  disable_direct_access ()
  reconfig_AEQ_get_adapt_done(fpgaid)
  reconfig_AEQ_get_controlstatus(fpgaid)
  reconfig_AEQ_get_equalization_results(fpgaid)
  reconfig_AEQ_get_indirect_register(fpgaid,addr)
  reconfig_AEQ_get_logical_channel_address(fpgaid)
  reconfig_AEQ_get_mode(fpgaid)
  reconfig_AEQ_set_indirect_register(fpgaid,addr,data)
  reconfig_AEQ_set_logical_channel_address(fpgaid,chid)
  reconfig_AEQ_set_mode(fpgaid,data)
  reconfig_ATX_get_controlstatus(fpgaid)
  reconfig_ATX_get_indirect_register(fpgaid,addr)
  reconfig_ATX_get_logical_channel_address(fpgaid)
  reconfig_ATX_set_indirect_register(fpgaid,addr,data)
  reconfig_ATX_set_logical_channel_address(fpgaid,chid)
  reconfig_DFE_get_adaptation_engine_enable(fpgaid)
  reconfig_DFE_get_controlstatus(fpgaid)
  reconfig_DFE_get_indirect_register(fpgaid,addr)
  reconfig_DFE_get_logical_channel_address(fpgaid)
  reconfig_DFE_get_power_on(fpgaid)
  reconfig_DFE_get_tap_1(fpgaid)
  reconfig_DFE_get_tap_2(fpgaid)
  reconfig_DFE_get_tap_2_polarity(fpgaid)
  reconfig_DFE_get_tap_3(fpgaid)
  reconfig_DFE_get_tap_3_polarity(fpgaid)
  reconfig_DFE_get_tap_4(fpgaid)
  reconfig_DFE_get_tap_4_polarity(fpgaid)
  reconfig_DFE_get_tap_5(fpgaid)
  reconfig_DFE_get_tap_5_polarity(fpgaid)
  reconfig_DFE_set_adaptation_engine_enable(fpgaid,data)
  reconfig_DFE_set_DFE_adaptation(fpgaid,data)
  reconfig_DFE_set_DFE_calibration(fpgaid,data)
  reconfig_DFE_set_indirect_register(fpgaid,addr,data)
  reconfig_DFE_set_logical_channel_address(fpgaid,chid)
  reconfig_DFE_set_power_on(fpgaid,data)
  reconfig_DFE_set_tap_1(fpgaid,data)
  reconfig_DFE_set_tap_2(fpgaid,data)
  reconfig_DFE_set_tap_2_polarity(fpgaid,data)
  reconfig_DFE_set_tap_3(fpgaid,data)
  reconfig_DFE_set_tap_3_polarity(fpgaid,data)
  reconfig_DFE_set_tap_4(fpgaid,data)
  reconfig_DFE_set_tap_4_polarity(fpgaid,data)
  reconfig_DFE_set_tap_5(fpgaid,data)
  reconfig_DFE_set_tap_5_polarity(fpgaid,data)
  reconfig_EyeQ_get_1D_Eye(fpgaid)
  reconfig_EyeQ_get_BERB_Enable(fpgaid)
  reconfig_EyeQ_get_BERB_Snap_Shot_and_Reset(fpgaid)
  reconfig_EyeQ_get_Bit_Counter31_0(fpgaid)
  reconfig_EyeQ_get_Bit_Counter63_32(fpgaid)
  reconfig_EyeQ_get_controlstatus(fpgaid)
  reconfig_EyeQ_get_Counter_Enable(fpgaid)
  reconfig_EyeQ_get_Enable_Eye_Monitor(fpgaid,data)
  reconfig_EyeQ_get_Err_Conter63_32(fpgaid)
  reconfig_EyeQ_get_Err_Counter31_0(fpgaid)
  reconfig_EyeQ_get_Horizontal_phase(fpgaid)
  reconfig_EyeQ_get_indirect_register(fpgaid,addr)
  reconfig_EyeQ_get_logical_channel_address(fpgaid)
  reconfig_EyeQ_get_Polarity(fpgaid)
  reconfig_EyeQ_get_Vertical_height(fpgaid)
  reconfig_EyeQ_set_1D_Eye(fpgaid,data)
  reconfig_EyeQ_set_BERB_Enable(fpgaid,data)
  reconfig_EyeQ_set_BERB_Snap_Shot_and_Reset(fpgaid,data)
  reconfig_EyeQ_set_Counter_Enable(fpgaid,data)
  reconfig_EyeQ_set_Enable_Eye_Monitor(fpgaid,data)
  reconfig_EyeQ_set_Horizontal_phase(fpgaid,data)
  reconfig_EyeQ_set_indirect_register(fpgaid,addr,data)
  reconfig_EyeQ_set_logical_channel_address(fpgaid,chid)
  reconfig_EyeQ_set_Polarity(fpgaid,data)
  reconfig_EyeQ_set_Vertical_height(fpgaid,data)
  reconfig_PLL_get_controlstatus(fpgaid)
  reconfig_PLL_get_indirect_register(fpgaid,addr)
  reconfig_PLL_get_logical_channel_address(fpgaid)
  reconfig_PLL_set_indirect_register(fpgaid,addr,data)
  reconfig_PLL_set_logical_channel_address(fpgaid,chid)
  reconfig_PMA_get_controlstatus(fpgaid)
  reconfig_PMA_get_indirect_register(fpgaid,addr)
  reconfig_PMA_get_logical_channel_address(fpgaid)
  reconfig_PMA_get_Pre_emphasis_first_post_tap(fpgaid)
  reconfig_PMA_get_Pre_emphasis_pre_tap(fpgaid)
  reconfig_PMA_get_Pre_emphasis_second_post_tap(fpgaid)
  reconfig_PMA_get_RX_equalization_control(fpgaid)
  reconfig_PMA_get_RX_equalization_DC_gain(fpgaid)
  reconfig_PMA_get_VOD(fpgaid)
  reconfig_PMA_set_indirect_register(fpgaid,addr,data)
  reconfig_PMA_set_logical_channel_address(fpgaid,chid)
  reconfig_PMA_set_Post_CDR_Reverse_Serial_Loopback(fpgaid,data)
  reconfig_PMA_set_Pre_CDR_Reverse_Serial_Loopback(fpgaid,data)
  reconfig_PMA_set_Pre_emphasis_first_post_tap(fpgaid,data)
  reconfig_PMA_set_Pre_emphasis_pre_tap(fpgaid,data)
  reconfig_PMA_set_Pre_emphasis_second_post_tap(fpgaid,data)
  reconfig_PMA_set_RX_equalization_control(fpgaid,data)
  reconfig_PMA_set_RX_equalization_DC_gain(fpgaid,data)
  reconfig_PMA_set_VOD(fpgaid,data)
  reconfig_Streamer_get_controlstatus(fpgaid)
  reconfig_Streamer_get_indirect_register(fpgaid,addr)
  reconfig_Streamer_get_logical_channel_address(fpgaid)
  reconfig_Streamer_set_indirect_register(fpgaid,addr,data)
  reconfig_Streamer_set_logical_channel_address(fpgaid,chid)
  reconfig_dump_state(fpgaid)
"""

def tapformat(number):
  """
  PMA Pre_emphasis_pre_tap
  PMA Pre_emphasis_second_post_tap
  5'b00000-5'b10000: 0
  5'b00001-5'b01111: -15 to -1
  5'b10001-5b'11111: 1 to 15
  """
  number=number - 16
  if number == -16: number = 0
  return number

def enable_direct_access (fpgaid,verbose=0):
  """set direct access mode"""
  cmd = "rdwr -b %d %s 0x%X" % (fpgaid,"global.g.fpga.ReconfigCtrl.Direct", 1)
  if (verbose & 2) == 2 : print cmd
  exec_cmd(cmd)
  time.sleep(1.0)

def disable_direct_access (fpgaid,verbose=0):
  """clear direct access mode"""
  cmd = "rdwr -b %d %s 0x%X" % (fpgaid,"global.g.fpga.ReconfigCtrl.Direct", 0)
  if (verbose & 2) == 2 : print cmd
  exec_cmd(cmd)
  time.sleep(1.0)


def exec_cmd (cmd):
  global debug
  proc = subprocess.Popen( cmd, shell=True, stdout = subprocess.PIPE, stderr = subprocess.PIPE )
  out,error=proc.communicate()
  if debug :print out
  if debug :print error

  if proc.returncode !=0:
    print "ERROR: read/write error %s %s" % (out,error)
    return ""
  else:
    index=out.index("]:")
    out=out[index+2:].strip()
    index=out.index(" ")
    out=out[:index].strip()
    return int(out,16)













def reconfig_AEQ_set_logical_channel_address(fpgaid,chid,verbose=1):
  global debug
  cmd="rdwr -b %d global.g.rcfg.AEQ_LogicalChanNo 0x%X" % (fpgaid,chid)
  if (verbose & 2) == 2 : print cmd
  exec_cmd(cmd)  
  if (verbose & 1) == 1 : print "="*30
  if (verbose & 1) == 1 : print "set AEQ logical channel to %d" % chid
  if (verbose & 1) == 1 : print "="*30

def reconfig_AEQ_get_logical_channel_address(fpgaid,verbose=1):
  global debug
  cmd="rdwr -b %d global.g.rcfg.AEQ_LogicalChanNo" % fpgaid
  if (verbose & 2) == 2 : print cmd
  out=exec_cmd(cmd)  
  if out == "":
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "AEQ logical channel is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return out
  else:
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "AEQ logical channel is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return int(out)

def reconfig_Streamer_set_logical_channel_address(fpgaid,chid,verbose=1):
  global debug
  cmd="rdwr -b %d global.g.rcfg.Streamer_LogicalChanNo 0x%X" % (fpgaid,chid)
  if (verbose & 2) == 2 : print cmd
  exec_cmd(cmd)  
  if (verbose & 1) == 1 : print "="*30
  if (verbose & 1) == 1 : print "set Streamer logical channel to %d" % chid
  if (verbose & 1) == 1 : print "="*30

def reconfig_Streamer_get_logical_channel_address(fpgaid,verbose=1):
  global debug
  cmd="rdwr -b %d global.g.rcfg.Streamer_LogicalChanNo" % fpgaid
  if (verbose & 2) == 2 : print cmd
  out=exec_cmd(cmd)  
  if out == "":
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "Streamer logical channel is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return out
  else:
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "Streamer logical channel is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return int(out)

def reconfig_DFE_set_logical_channel_address(fpgaid,chid,verbose=1):
  global debug
  cmd="rdwr -b %d global.g.rcfg.DFE_LogicalChanNo 0x%X" % (fpgaid,chid)
  if (verbose & 2) == 2 : print cmd
  exec_cmd(cmd)  
  if (verbose & 1) == 1 : print "="*30
  if (verbose & 1) == 1 : print "set DFE logical channel to %d" % chid
  if (verbose & 1) == 1 : print "="*30

def reconfig_DFE_get_logical_channel_address(fpgaid,verbose=1):
  global debug
  cmd="rdwr -b %d global.g.rcfg.DFE_LogicalChanNo" % fpgaid
  if (verbose & 2) == 2 : print cmd
  out=exec_cmd(cmd)  
  if out == "":
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "DFE logical channel is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return out
  else:
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "DFE logical channel is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return int(out)

def reconfig_EyeQ_set_logical_channel_address(fpgaid,chid,verbose=1):
  global debug
  cmd="rdwr -b %d global.g.rcfg.EyeQ_LogicalChanNo 0x%X" % (fpgaid,chid)
  if (verbose & 2) == 2 : print cmd
  exec_cmd(cmd)  
  if (verbose & 1) == 1 : print "="*30
  if (verbose & 1) == 1 : print "set EyeQ logical channel to %d" % chid
  if (verbose & 1) == 1 : print "="*30

def reconfig_EyeQ_get_logical_channel_address(fpgaid,verbose=1):
  global debug
  cmd="rdwr -b %d global.g.rcfg.EyeQ_LogicalChanNo" % fpgaid
  if (verbose & 2) == 2 : print cmd
  out=exec_cmd(cmd)  
  if out == "":
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "EyeQ logical channel is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return out
  else:
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "EyeQ logical channel is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return int(out)

def reconfig_PMA_set_logical_channel_address(fpgaid,chid,verbose=1):
  global debug
  cmd="rdwr -b %d global.g.rcfg.PMA_LogicalChanNo 0x%X" % (fpgaid,chid)
  if (verbose & 2) == 2 : print cmd
  exec_cmd(cmd)  
  if (verbose & 1) == 1 : print "="*30
  if (verbose & 1) == 1 : print "set PMA logical channel to %d" % chid
  if (verbose & 1) == 1 : print "="*30

def reconfig_PMA_get_logical_channel_address(fpgaid,verbose=1):
  global debug
  cmd="rdwr -b %d global.g.rcfg.PMA_LogicalChanNo" % fpgaid
  if (verbose & 2) == 2 : print cmd
  out=exec_cmd(cmd)  
  if out == "":
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "PMA logical channel is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return out
  else:
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "PMA logical channel is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return int(out)

def reconfig_ATX_set_logical_channel_address(fpgaid,chid,verbose=1):
  global debug
  cmd="rdwr -b %d global.g.rcfg.ATX_LogicalChanNo 0x%X" % (fpgaid,chid)
  if (verbose & 2) == 2 : print cmd
  exec_cmd(cmd)  
  if (verbose & 1) == 1 : print "="*30
  if (verbose & 1) == 1 : print "set ATX logical channel to %d" % chid
  if (verbose & 1) == 1 : print "="*30

def reconfig_ATX_get_logical_channel_address(fpgaid,verbose=1):
  global debug
  cmd="rdwr -b %d global.g.rcfg.ATX_LogicalChanNo" % fpgaid
  if (verbose & 2) == 2 : print cmd
  out=exec_cmd(cmd)  
  if out == "":
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "ATX logical channel is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return out
  else:
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "ATX logical channel is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return int(out)

def reconfig_PLL_set_logical_channel_address(fpgaid,chid,verbose=1):
  global debug
  cmd="rdwr -b %d global.g.rcfg.PLL_LogicalChanNo 0x%X" % (fpgaid,chid)
  if (verbose & 2) == 2 : print cmd
  exec_cmd(cmd)  
  if (verbose & 1) == 1 : print "="*30
  if (verbose & 1) == 1 : print "set PLL logical channel to %d" % chid
  if (verbose & 1) == 1 : print "="*30

def reconfig_PLL_get_logical_channel_address(fpgaid,verbose=1):
  global debug
  cmd="rdwr -b %d global.g.rcfg.PLL_LogicalChanNo" % fpgaid
  if (verbose & 2) == 2 : print cmd
  out=exec_cmd(cmd)  
  if out == "":
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "PLL logical channel is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return out
  else:
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "PLL logical channel is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return int(out)

def reconfig_AEQ_set_indirect_register(fpgaid,addr,data,verbose=1):
  global debug
  cmd="rdwr -b %d global.g.rcfg.AEQ_Offset 0x%X" % (fpgaid,addr)
  if (verbose & 2) == 2 : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.AEQ_Data 0x%X" % (fpgaid,data)
  if (verbose & 2) == 2 : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.AEQ_ControlStatus 1" % fpgaid
  if (verbose & 2) == 2 : print cmd
  exec_cmd(cmd)  

def reconfig_AEQ_get_indirect_register(fpgaid,addr,verbose=1):
  cmd="rdwr -b %d global.g.rcfg.AEQ_Offset 0x%X" % (fpgaid,addr)
  if (verbose & 2) == 2 : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.AEQ_ControlStatus 2" % fpgaid
  if (verbose & 2) == 2 : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.AEQ_Data" % fpgaid
  if (verbose & 2) == 2 : print cmd
  out=exec_cmd(cmd)  
  if out == "":
    return out
  else:
    return int(out)

def reconfig_Streamer_set_indirect_register(fpgaid,addr,data,verbose=1):
  global debug
  cmd="rdwr -b %d global.g.rcfg.Streamer_Offset 0x%X" % (fpgaid,addr)
  if (verbose & 2) == 2 : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.Streamer_Data 0x%X" % (fpgaid,data)
  if (verbose & 2) == 2 : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.Streamer_ControlStatus 1" % fpgaid
  if (verbose & 2) == 2 : print cmd
  exec_cmd(cmd)  

def reconfig_Streamer_get_indirect_register(fpgaid,addr,verbose=1):
  cmd="rdwr -b %d global.g.rcfg.Streamer_Offset 0x%X" % (fpgaid,addr)
  if (verbose & 2) == 2 : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.Streamer_ControlStatus 2" % fpgaid
  if (verbose & 2) == 2 : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.Streamer_Data" % fpgaid
  if (verbose & 2) == 2 : print cmd
  out=exec_cmd(cmd)  
  if out == "":
    return out
  else:
    return int(out)

def reconfig_DFE_set_indirect_register(fpgaid,addr,data,verbose=1):
  global debug
  cmd="rdwr -b %d global.g.rcfg.DFE_Offset 0x%X" % (fpgaid,addr)
  if (verbose & 2) == 2 : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.DFE_Data 0x%X" % (fpgaid,data)
  if (verbose & 2) == 2 : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.DFE_ControlStatus 1" % fpgaid
  if (verbose & 2) == 2 : print cmd
  exec_cmd(cmd)  

def reconfig_DFE_get_indirect_register(fpgaid,addr,verbose=1):
  cmd="rdwr -b %d global.g.rcfg.DFE_Offset 0x%X" % (fpgaid,addr)
  if (verbose & 2) == 2 : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.DFE_ControlStatus 2" % fpgaid
  if (verbose & 2) == 2 : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.DFE_Data" % fpgaid
  if (verbose & 2) == 2 : print cmd
  out=exec_cmd(cmd)  
  if out == "":
    return out
  else:
    return int(out)

def reconfig_EyeQ_set_indirect_register(fpgaid,addr,data,verbose=1):
  global debug
  cmd="rdwr -b %d global.g.rcfg.EyeQ_Offset 0x%X" % (fpgaid,addr)
  if (verbose & 2) == 2 : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.EyeQ_Data 0x%X" % (fpgaid,data)
  if (verbose & 2) == 2 : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.EyeQ_ControlStatus 1" % fpgaid
  if (verbose & 2) == 2 : print cmd
  exec_cmd(cmd)  

def reconfig_EyeQ_get_indirect_register(fpgaid,addr,verbose=1):
  cmd="rdwr -b %d global.g.rcfg.EyeQ_Offset 0x%X" % (fpgaid,addr)
  if (verbose & 2) == 2 : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.EyeQ_ControlStatus 2" % fpgaid
  if (verbose & 2) == 2 : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.EyeQ_Data" % fpgaid
  if (verbose & 2) == 2 : print cmd
  out=exec_cmd(cmd)  
  if out == "":
    return out
  else:
    return int(out)

def reconfig_PMA_set_indirect_register(fpgaid,addr,data,verbose=1):
  global debug
  cmd="rdwr -b %d global.g.rcfg.PMA_Offset 0x%X" % (fpgaid,addr)
  if (verbose & 2) == 2 : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.PMA_Data 0x%X" % (fpgaid,data)
  if (verbose & 2) == 2 : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.PMA_ControlStatus 1" % fpgaid
  if (verbose & 2) == 2 : print cmd
  exec_cmd(cmd)  

def reconfig_PMA_get_indirect_register(fpgaid,addr,verbose=1):
  cmd="rdwr -b %d global.g.rcfg.PMA_Offset 0x%X" % (fpgaid,addr)
  if (verbose & 2) == 2 : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.PMA_ControlStatus 2" % fpgaid
  if (verbose & 2) == 2 : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.PMA_Data" % fpgaid
  if (verbose & 2) == 2 : print cmd
  out=exec_cmd(cmd)  
  if out == "":
    return out
  else:
    return int(out)

def reconfig_ATX_set_indirect_register(fpgaid,addr,data,verbose=1):
  global debug
  cmd="rdwr -b %d global.g.rcfg.ATX_Offset 0x%X" % (fpgaid,addr)
  if (verbose & 2) == 2 : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.ATX_Data 0x%X" % (fpgaid,data)
  if (verbose & 2) == 2 : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.ATX_ControlStatus 1" % fpgaid
  if (verbose & 2) == 2 : print cmd
  exec_cmd(cmd)  

def reconfig_ATX_get_indirect_register(fpgaid,addr,verbose=1):
  cmd="rdwr -b %d global.g.rcfg.ATX_Offset 0x%X" % (fpgaid,addr)
  if (verbose & 2) == 2 : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.ATX_ControlStatus 2" % fpgaid
  if (verbose & 2) == 2 : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.ATX_Data" % fpgaid
  if (verbose & 2) == 2 : print cmd
  out=exec_cmd(cmd)  
  if out == "":
    return out
  else:
    return int(out)

def reconfig_PLL_set_indirect_register(fpgaid,addr,data,verbose=1):
  global debug
  cmd="rdwr -b %d global.g.rcfg.PLL_Offset 0x%X" % (fpgaid,addr)
  if (verbose & 2) == 2 : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.PLL_Data 0x%X" % (fpgaid,data)
  if (verbose & 2) == 2 : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.PLL_ControlStatus 1" % fpgaid
  if (verbose & 2) == 2 : print cmd
  exec_cmd(cmd)  

def reconfig_PLL_get_indirect_register(fpgaid,addr,verbose=1):
  cmd="rdwr -b %d global.g.rcfg.PLL_Offset 0x%X" % (fpgaid,addr)
  if (verbose & 2) == 2 : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.PLL_ControlStatus 2" % fpgaid
  if (verbose & 2) == 2 : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.PLL_Data" % fpgaid
  if (verbose & 2) == 2 : print cmd
  out=exec_cmd(cmd)  
  if out == "":
    return out
  else:
    return int(out)

def reconfig_AEQ_get_adapt_done(fpgaid,verbose=1):
  """When asserted, indicates that adaptation has completed. In One-Time Adaptation Mode, AEQ stops searching new EQ settings even if the signal quality of incoming serial data is inadequate. In Continuous Adaptation Mode, AEQ continues to search for new settings after this bit is asserted.  This bit is only valid in one-time AEQ adaptation mode. For some extreme cases, when the channel loss is too much for AEQ to compensate, the adapt_done signal may never be asserted. The AEQ engine can take up to 50,000 reconfiguration clock cycles before selecting the final equalization settings.
"""
  if (verbose & 1) == 1 : print """When asserted, indicates that adaptation has completed. In One-Time Adaptation Mode, AEQ stops searching new EQ settings even if the signal quality of incoming serial data is inadequate. In Continuous Adaptation Mode, AEQ continues to search for new settings after this bit is asserted.  This bit is only valid in one-time AEQ adaptation mode. For some extreme cases, when the channel loss is too much for AEQ to compensate, the adapt_done signal may never be asserted. The AEQ engine can take up to 50,000 reconfiguration clock cycles before selecting the final equalization settings.
"""
  out=reconfig_AEQ_get_indirect_register(fpgaid,0,verbose)
  out=out & 256
  out=out >> 8
  if out == "":
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "AEQ adapt_done is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return out
  else:
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "AEQ adapt_done is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return int(out)

def reconfig_AEQ_get_equalization_results(fpgaid,verbose=1):
  """This is the value set by the automatic AEQ adaptation performed at startup. If you choose to perform manual equalization using the linear equalizer, you can use this value as a reference.  Although automatic and manual equalization do not provide identical functionality, specifying this value enables manual equalization to approximate the original setting.
"""
  if (verbose & 1) == 1 : print """This is the value set by the automatic AEQ adaptation performed at startup. If you choose to perform manual equalization using the linear equalizer, you can use this value as a reference.  Although automatic and manual equalization do not provide identical functionality, specifying this value enables manual equalization to approximate the original setting.
"""
  out=reconfig_AEQ_get_indirect_register(fpgaid,1,verbose)
  out=out & 15
  out=out >> 0
  if out == "":
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "AEQ equalization_results is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return out
  else:
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "AEQ equalization_results is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return int(out)

def reconfig_AEQ_set_mode(fpgaid,data,verbose=1):
  """Specifies the following address modes:
 2'b00: Low power manual equalization mode
 2'b01: One-time AEQ adaptation at power up
 2'b10: Perform continuous AEQ adaptation
 2'b11: Reserved
"""
  if (verbose & 1) == 1 : print """Specifies the following address modes:
 2'b00: Low power manual equalization mode
 2'b01: One-time AEQ adaptation at power up
 2'b10: Perform continuous AEQ adaptation
 2'b11: Reserved
"""
  # read
  out=reconfig_AEQ_get_indirect_register(fpgaid,0,verbose)
  # modify data
  data=(out & ~3) | (data << 0)

  reconfig_AEQ_set_indirect_register(fpgaid,0,data,verbose)
  if (verbose & 1) == 1 : print "="*30
  if (verbose & 1) == 1 : print "set mode to %d" % data
  if (verbose & 1) == 1 : print "="*30

def reconfig_AEQ_get_mode(fpgaid,verbose=1):
  """Specifies the following address modes:
 2'b00: Low power manual equalization mode
 2'b01: One-time AEQ adaptation at power up
 2'b10: Perform continuous AEQ adaptation
 2'b11: Reserved
"""
  if (verbose & 1) == 1 : print """Specifies the following address modes:
 2'b00: Low power manual equalization mode
 2'b01: One-time AEQ adaptation at power up
 2'b10: Perform continuous AEQ adaptation
 2'b11: Reserved
"""
  out=reconfig_AEQ_get_indirect_register(fpgaid,0,verbose)
  out=out & 3
  out=out >> 0
  if out == "":
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "AEQ mode is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return out
  else:
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "AEQ mode is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return int(out)

def reconfig_DFE_set_tap_2_polarity(fpgaid,data,verbose=1):
  """Specifies the polarity of the second post tap as follows:
  0: negative polarity
  1: positive polarity
"""
  if (verbose & 1) == 1 : print """Specifies the polarity of the second post tap as follows:
  0: negative polarity
  1: positive polarity
"""
  # read
  out=reconfig_DFE_get_indirect_register(fpgaid,2,verbose)
  # modify data
  data=(out & ~8) | (data << 3)

  reconfig_DFE_set_indirect_register(fpgaid,2,data,verbose)
  if (verbose & 1) == 1 : print "="*30
  if (verbose & 1) == 1 : print "set tap_2_polarity to %d" % data
  if (verbose & 1) == 1 : print "="*30

def reconfig_DFE_get_tap_2_polarity(fpgaid,verbose=1):
  """Specifies the polarity of the second post tap as follows:
  0: negative polarity
  1: positive polarity
"""
  if (verbose & 1) == 1 : print """Specifies the polarity of the second post tap as follows:
  0: negative polarity
  1: positive polarity
"""
  out=reconfig_DFE_get_indirect_register(fpgaid,2,verbose)
  out=out & 8
  out=out >> 3
  if out == "":
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "DFE tap_2_polarity is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return out
  else:
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "DFE tap_2_polarity is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return int(out)

def reconfig_DFE_set_tap_5(fpgaid,data,verbose=1):
  """Specifies the coefficient for the fifth post tap. The valid range is 0-3.
"""
  if (verbose & 1) == 1 : print """Specifies the coefficient for the fifth post tap. The valid range is 0-3.
"""
  # read
  out=reconfig_DFE_get_indirect_register(fpgaid,5,verbose)
  # modify data
  data=(out & ~7) | (data << 0)

  reconfig_DFE_set_indirect_register(fpgaid,5,data,verbose)
  if (verbose & 1) == 1 : print "="*30
  if (verbose & 1) == 1 : print "set tap_5 to %d" % data
  if (verbose & 1) == 1 : print "="*30

def reconfig_DFE_get_tap_5(fpgaid,verbose=1):
  """Specifies the coefficient for the fifth post tap. The valid range is 0-3.
"""
  if (verbose & 1) == 1 : print """Specifies the coefficient for the fifth post tap. The valid range is 0-3.
"""
  out=reconfig_DFE_get_indirect_register(fpgaid,5,verbose)
  out=out & 7
  out=out >> 0
  if out == "":
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "DFE tap_5 is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return out
  else:
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "DFE tap_5 is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return int(out)

def reconfig_DFE_set_tap_4_polarity(fpgaid,data,verbose=1):
  """Specifies the polarity of the fourth post tap as follows:
"""
  if (verbose & 1) == 1 : print """Specifies the polarity of the fourth post tap as follows:
"""
  # read
  out=reconfig_DFE_get_indirect_register(fpgaid,4,verbose)
  # modify data
  data=(out & ~8) | (data << 3)

  reconfig_DFE_set_indirect_register(fpgaid,4,data,verbose)
  if (verbose & 1) == 1 : print "="*30
  if (verbose & 1) == 1 : print "set tap_4_polarity to %d" % data
  if (verbose & 1) == 1 : print "="*30

def reconfig_DFE_get_tap_4_polarity(fpgaid,verbose=1):
  """Specifies the polarity of the fourth post tap as follows:
"""
  if (verbose & 1) == 1 : print """Specifies the polarity of the fourth post tap as follows:
"""
  out=reconfig_DFE_get_indirect_register(fpgaid,4,verbose)
  out=out & 8
  out=out >> 3
  if out == "":
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "DFE tap_4_polarity is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return out
  else:
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "DFE tap_4_polarity is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return int(out)

def reconfig_DFE_set_power_on(fpgaid,data,verbose=1):
  """Writing a 0 to this bit powers down DFE in the channel specified.
"""
  if (verbose & 1) == 1 : print """Writing a 0 to this bit powers down DFE in the channel specified.
"""
  # read
  out=reconfig_DFE_get_indirect_register(fpgaid,0,verbose)
  # modify data
  data=(out & ~2) | (data << 1)

  reconfig_DFE_set_indirect_register(fpgaid,0,data,verbose)
  if (verbose & 1) == 1 : print "="*30
  if (verbose & 1) == 1 : print "set power_on to %d" % data
  if (verbose & 1) == 1 : print "="*30

def reconfig_DFE_get_power_on(fpgaid,verbose=1):
  """Writing a 0 to this bit powers down DFE in the channel specified.
"""
  if (verbose & 1) == 1 : print """Writing a 0 to this bit powers down DFE in the channel specified.
"""
  out=reconfig_DFE_get_indirect_register(fpgaid,0,verbose)
  out=out & 2
  out=out >> 1
  if out == "":
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "DFE power_on is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return out
  else:
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "DFE power_on is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return int(out)

def reconfig_DFE_set_DFE_adaptation(fpgaid,data,verbose=1):
  """Writing a 1 to this bit initiates DFE 1-time adaptation on the specified channel.
"""
  if (verbose & 1) == 1 : print """Writing a 1 to this bit initiates DFE 1-time adaptation on the specified channel.
"""
  reconfig_DFE_set_indirect_register(fpgaid,11,data,verbose)
  if (verbose & 1) == 1 : print "="*30
  if (verbose & 1) == 1 : print "set DFE_adaptation to %d" % data
  if (verbose & 1) == 1 : print "="*30

def reconfig_DFE_set_adaptation_engine_enable(fpgaid,data,verbose=1):
  """Writing a 1 triggers the adaptive equalization engine.
"""
  if (verbose & 1) == 1 : print """Writing a 1 triggers the adaptive equalization engine.
"""
  # read
  out=reconfig_DFE_get_indirect_register(fpgaid,0,verbose)
  # modify data
  data=(out & ~1) | (data << 0)

  reconfig_DFE_set_indirect_register(fpgaid,0,data,verbose)
  if (verbose & 1) == 1 : print "="*30
  if (verbose & 1) == 1 : print "set adaptation_engine_enable to %d" % data
  if (verbose & 1) == 1 : print "="*30

def reconfig_DFE_get_adaptation_engine_enable(fpgaid,verbose=1):
  """Writing a 1 triggers the adaptive equalization engine.
"""
  if (verbose & 1) == 1 : print """Writing a 1 triggers the adaptive equalization engine.
"""
  out=reconfig_DFE_get_indirect_register(fpgaid,0,verbose)
  out=out & 1
  out=out >> 0
  if out == "":
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "DFE adaptation_engine_enable is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return out
  else:
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "DFE adaptation_engine_enable is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return int(out)

def reconfig_DFE_set_tap_3(fpgaid,data,verbose=1):
  """Specifies the coefficient for the third post tap. The valid range is 0-7.
"""
  if (verbose & 1) == 1 : print """Specifies the coefficient for the third post tap. The valid range is 0-7.
"""
  # read
  out=reconfig_DFE_get_indirect_register(fpgaid,3,verbose)
  # modify data
  data=(out & ~7) | (data << 0)

  reconfig_DFE_set_indirect_register(fpgaid,3,data,verbose)
  if (verbose & 1) == 1 : print "="*30
  if (verbose & 1) == 1 : print "set tap_3 to %d" % data
  if (verbose & 1) == 1 : print "="*30

def reconfig_DFE_get_tap_3(fpgaid,verbose=1):
  """Specifies the coefficient for the third post tap. The valid range is 0-7.
"""
  if (verbose & 1) == 1 : print """Specifies the coefficient for the third post tap. The valid range is 0-7.
"""
  out=reconfig_DFE_get_indirect_register(fpgaid,3,verbose)
  out=out & 7
  out=out >> 0
  if out == "":
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "DFE tap_3 is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return out
  else:
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "DFE tap_3 is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return int(out)

def reconfig_DFE_set_tap_2(fpgaid,data,verbose=1):
  """Specifies the coefficient for the second post tap. The valid range is 0-7.
"""
  if (verbose & 1) == 1 : print """Specifies the coefficient for the second post tap. The valid range is 0-7.
"""
  # read
  out=reconfig_DFE_get_indirect_register(fpgaid,2,verbose)
  # modify data
  data=(out & ~7) | (data << 0)

  reconfig_DFE_set_indirect_register(fpgaid,2,data,verbose)
  if (verbose & 1) == 1 : print "="*30
  if (verbose & 1) == 1 : print "set tap_2 to %d" % data
  if (verbose & 1) == 1 : print "="*30

def reconfig_DFE_get_tap_2(fpgaid,verbose=1):
  """Specifies the coefficient for the second post tap. The valid range is 0-7.
"""
  if (verbose & 1) == 1 : print """Specifies the coefficient for the second post tap. The valid range is 0-7.
"""
  out=reconfig_DFE_get_indirect_register(fpgaid,2,verbose)
  out=out & 7
  out=out >> 0
  if out == "":
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "DFE tap_2 is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return out
  else:
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "DFE tap_2 is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return int(out)

def reconfig_DFE_set_tap_1(fpgaid,data,verbose=1):
  """Specifies the coefficient for the first post tap. The valid range is 0-15.
"""
  if (verbose & 1) == 1 : print """Specifies the coefficient for the first post tap. The valid range is 0-15.
"""
  reconfig_DFE_set_indirect_register(fpgaid,1,data,verbose)
  if (verbose & 1) == 1 : print "="*30
  if (verbose & 1) == 1 : print "set tap_1 to %d" % data
  if (verbose & 1) == 1 : print "="*30

def reconfig_DFE_get_tap_1(fpgaid,verbose=1):
  """Specifies the coefficient for the first post tap. The valid range is 0-15.
"""
  if (verbose & 1) == 1 : print """Specifies the coefficient for the first post tap. The valid range is 0-15.
"""
  out=reconfig_DFE_get_indirect_register(fpgaid,1,verbose)
  out=out & 15
  out=out >> 0
  if out == "":
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "DFE tap_1 is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return out
  else:
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "DFE tap_1 is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return int(out)

def reconfig_DFE_set_tap_3_polarity(fpgaid,data,verbose=1):
  """Specifies the polarity of the third post tap as follows:
  0: negative polarity
  1: positive polarity
"""
  if (verbose & 1) == 1 : print """Specifies the polarity of the third post tap as follows:
  0: negative polarity
  1: positive polarity
"""
  # read
  out=reconfig_DFE_get_indirect_register(fpgaid,3,verbose)
  # modify data
  data=(out & ~8) | (data << 3)

  reconfig_DFE_set_indirect_register(fpgaid,3,data,verbose)
  if (verbose & 1) == 1 : print "="*30
  if (verbose & 1) == 1 : print "set tap_3_polarity to %d" % data
  if (verbose & 1) == 1 : print "="*30

def reconfig_DFE_get_tap_3_polarity(fpgaid,verbose=1):
  """Specifies the polarity of the third post tap as follows:
  0: negative polarity
  1: positive polarity
"""
  if (verbose & 1) == 1 : print """Specifies the polarity of the third post tap as follows:
  0: negative polarity
  1: positive polarity
"""
  out=reconfig_DFE_get_indirect_register(fpgaid,3,verbose)
  out=out & 8
  out=out >> 3
  if out == "":
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "DFE tap_3_polarity is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return out
  else:
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "DFE tap_3_polarity is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return int(out)

def reconfig_DFE_set_tap_4(fpgaid,data,verbose=1):
  """Specifies the coefficient for the fourth post tap. The valid range is 0-7.
"""
  if (verbose & 1) == 1 : print """Specifies the coefficient for the fourth post tap. The valid range is 0-7.
"""
  # read
  out=reconfig_DFE_get_indirect_register(fpgaid,4,verbose)
  # modify data
  data=(out & ~7) | (data << 0)

  reconfig_DFE_set_indirect_register(fpgaid,4,data,verbose)
  if (verbose & 1) == 1 : print "="*30
  if (verbose & 1) == 1 : print "set tap_4 to %d" % data
  if (verbose & 1) == 1 : print "="*30

def reconfig_DFE_get_tap_4(fpgaid,verbose=1):
  """Specifies the coefficient for the fourth post tap. The valid range is 0-7.
"""
  if (verbose & 1) == 1 : print """Specifies the coefficient for the fourth post tap. The valid range is 0-7.
"""
  out=reconfig_DFE_get_indirect_register(fpgaid,4,verbose)
  out=out & 7
  out=out >> 0
  if out == "":
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "DFE tap_4 is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return out
  else:
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "DFE tap_4 is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return int(out)

def reconfig_DFE_set_tap_5_polarity(fpgaid,data,verbose=1):
  """Specifies the polarity of the fifth post tap as follows:
  0: negative polarity
  1: positive polarity
"""
  if (verbose & 1) == 1 : print """Specifies the polarity of the fifth post tap as follows:
  0: negative polarity
  1: positive polarity
"""
  # read
  out=reconfig_DFE_get_indirect_register(fpgaid,5,verbose)
  # modify data
  data=(out & ~8) | (data << 3)

  reconfig_DFE_set_indirect_register(fpgaid,5,data,verbose)
  if (verbose & 1) == 1 : print "="*30
  if (verbose & 1) == 1 : print "set tap_5_polarity to %d" % data
  if (verbose & 1) == 1 : print "="*30

def reconfig_DFE_get_tap_5_polarity(fpgaid,verbose=1):
  """Specifies the polarity of the fifth post tap as follows:
  0: negative polarity
  1: positive polarity
"""
  if (verbose & 1) == 1 : print """Specifies the polarity of the fifth post tap as follows:
  0: negative polarity
  1: positive polarity
"""
  out=reconfig_DFE_get_indirect_register(fpgaid,5,verbose)
  out=out & 8
  out=out >> 3
  if out == "":
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "DFE tap_5_polarity is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return out
  else:
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "DFE tap_5_polarity is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return int(out)

def reconfig_DFE_set_DFE_calibration(fpgaid,data,verbose=1):
  """Writing a 1 to this bit initiates DFE manual calibration on the specified channel.
"""
  if (verbose & 1) == 1 : print """Writing a 1 to this bit initiates DFE manual calibration on the specified channel.
"""
  reconfig_DFE_set_indirect_register(fpgaid,10,data,verbose)
  if (verbose & 1) == 1 : print "="*30
  if (verbose & 1) == 1 : print "set DFE_calibration to %d" % data
  if (verbose & 1) == 1 : print "="*30

def reconfig_EyeQ_set_Counter_Enable(fpgaid,data,verbose=1):
  """Only available when you turn on the Enable Bit Error Rate Block in the Transceiver Reconfiguration Controller IP Core GUI.  When set to 1, the counters accumulate bits and errors. When set to 0, pauses accumulation, preserving the current values.
"""
  if (verbose & 1) == 1 : print """Only available when you turn on the Enable Bit Error Rate Block in the Transceiver Reconfiguration Controller IP Core GUI.  When set to 1, the counters accumulate bits and errors. When set to 0, pauses accumulation, preserving the current values.
"""
  # read
  out=reconfig_EyeQ_get_indirect_register(fpgaid,0,verbose)
  # modify data
  data=(out & ~4) | (data << 2)

  reconfig_EyeQ_set_indirect_register(fpgaid,0,data,verbose)
  if (verbose & 1) == 1 : print "="*30
  if (verbose & 1) == 1 : print "set Counter_Enable to %d" % data
  if (verbose & 1) == 1 : print "="*30

def reconfig_EyeQ_get_Counter_Enable(fpgaid,verbose=1):
  """Only available when you turn on the Enable Bit Error Rate Block in the Transceiver Reconfiguration Controller IP Core GUI.  When set to 1, the counters accumulate bits and errors. When set to 0, pauses accumulation, preserving the current values.
"""
  if (verbose & 1) == 1 : print """Only available when you turn on the Enable Bit Error Rate Block in the Transceiver Reconfiguration Controller IP Core GUI.  When set to 1, the counters accumulate bits and errors. When set to 0, pauses accumulation, preserving the current values.
"""
  out=reconfig_EyeQ_get_indirect_register(fpgaid,0,verbose)
  out=out & 4
  out=out >> 2
  if out == "":
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "EyeQ Counter_Enable is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return out
  else:
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "EyeQ Counter_Enable is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return int(out)

def reconfig_EyeQ_set_Horizontal_phase(fpgaid,data,verbose=1):
  """Taken together, the horizontal phase and vertical height specify the Cartesian x-y coordinates of the point on the eye diagram that you want to sample. You can increment through 64 phases over 2 UI on the horizontal axis.
"""
  if (verbose & 1) == 1 : print """Taken together, the horizontal phase and vertical height specify the Cartesian x-y coordinates of the point on the eye diagram that you want to sample. You can increment through 64 phases over 2 UI on the horizontal axis.
"""
  reconfig_EyeQ_set_indirect_register(fpgaid,1,data,verbose)
  if (verbose & 1) == 1 : print "="*30
  if (verbose & 1) == 1 : print "set Horizontal_phase to %d" % data
  if (verbose & 1) == 1 : print "="*30

def reconfig_EyeQ_get_Horizontal_phase(fpgaid,verbose=1):
  """Taken together, the horizontal phase and vertical height specify the Cartesian x-y coordinates of the point on the eye diagram that you want to sample. You can increment through 64 phases over 2 UI on the horizontal axis.
"""
  if (verbose & 1) == 1 : print """Taken together, the horizontal phase and vertical height specify the Cartesian x-y coordinates of the point on the eye diagram that you want to sample. You can increment through 64 phases over 2 UI on the horizontal axis.
"""
  out=reconfig_EyeQ_get_indirect_register(fpgaid,1,verbose)
  out=out & 63
  out=out >> 0
  if out == "":
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "EyeQ Horizontal_phase is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return out
  else:
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "EyeQ Horizontal_phase is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return int(out)

def reconfig_EyeQ_get_Err_Counter31_0(fpgaid,verbose=1):
  """Only available when the BERB Enable and Counter Enable bits are set. Err
Counter[63:0]reports the total number of error bits received since you enabled or reset BER counters.
"""
  if (verbose & 1) == 1 : print """Only available when the BERB Enable and Counter Enable bits are set. Err
Counter[63:0]reports the total number of error bits received since you enabled or reset BER counters.
"""
  out=reconfig_EyeQ_get_indirect_register(fpgaid,7,verbose)
  out=out & 4294967295
  out=out >> 0
  if out == "":
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "EyeQ Err_Counter31_0 is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return out
  else:
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "EyeQ Err_Counter31_0 is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return int(out)

def reconfig_EyeQ_set_Polarity(fpgaid,data,verbose=1):
  """Specifies the sign of the Vertical height .
When 0, the Vertical height is negative.
When 1, the Vertical height is positive.
"""
  if (verbose & 1) == 1 : print """Specifies the sign of the Vertical height .
When 0, the Vertical height is negative.
When 1, the Vertical height is positive.
"""
  # read
  out=reconfig_EyeQ_get_indirect_register(fpgaid,3,verbose)
  # modify data
  data=(out & ~4) | (data << 2)

  reconfig_EyeQ_set_indirect_register(fpgaid,3,data,verbose)
  if (verbose & 1) == 1 : print "="*30
  if (verbose & 1) == 1 : print "set Polarity to %d" % data
  if (verbose & 1) == 1 : print "="*30

def reconfig_EyeQ_get_Polarity(fpgaid,verbose=1):
  """Specifies the sign of the Vertical height .
When 0, the Vertical height is negative.
When 1, the Vertical height is positive.
"""
  if (verbose & 1) == 1 : print """Specifies the sign of the Vertical height .
When 0, the Vertical height is negative.
When 1, the Vertical height is positive.
"""
  out=reconfig_EyeQ_get_indirect_register(fpgaid,3,verbose)
  out=out & 4
  out=out >> 2
  if out == "":
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "EyeQ Polarity is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return out
  else:
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "EyeQ Polarity is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return int(out)

def reconfig_EyeQ_get_Bit_Counter63_32(fpgaid,verbose=1):
  """Only valid when the BERB Enable and Counter Enable bits are set.
Bit_Counter[63:0] reports the total number of bits received since you enabled or reset BER counters. Each increment represents 256 bits.
"""
  if (verbose & 1) == 1 : print """Only valid when the BERB Enable and Counter Enable bits are set.
Bit_Counter[63:0] reports the total number of bits received since you enabled or reset BER counters. Each increment represents 256 bits.
"""
  out=reconfig_EyeQ_get_indirect_register(fpgaid,6,verbose)
  out=out & 4294967295
  out=out >> 0
  if out == "":
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "EyeQ Bit_Counter63_32 is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return out
  else:
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "EyeQ Bit_Counter63_32 is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return int(out)

def reconfig_EyeQ_get_Bit_Counter31_0(fpgaid,verbose=1):
  """Only valid when the BERB Enable and Counter Enable bits are set.
Bit Counter[63:0] reports the total number of bits received since you enabled or reset BER counters. Each increment represents 256 bits.
"""
  if (verbose & 1) == 1 : print """Only valid when the BERB Enable and Counter Enable bits are set.
Bit Counter[63:0] reports the total number of bits received since you enabled or reset BER counters. Each increment represents 256 bits.
"""
  out=reconfig_EyeQ_get_indirect_register(fpgaid,5,verbose)
  out=out & 4294967295
  out=out >> 0
  if out == "":
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "EyeQ Bit_Counter31_0 is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return out
  else:
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "EyeQ Bit_Counter31_0 is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return int(out)

def reconfig_EyeQ_set_1D_Eye(fpgaid,data,verbose=1):
  """Writing a 1 to this bit selects 1D Eye mode and disables vertical height measurement. Writing a 0 to this bit selects normal 2D Eye measurement mode including both the horizontal and vertical axes. You must use 1D Eye mode if you have enabled DFE.
"""
  if (verbose & 1) == 1 : print """Writing a 1 to this bit selects 1D Eye mode and disables vertical height measurement. Writing a 0 to this bit selects normal 2D Eye measurement mode including both the horizontal and vertical axes. You must use 1D Eye mode if you have enabled DFE.
"""
  # read
  out=reconfig_EyeQ_get_indirect_register(fpgaid,3,verbose)
  # modify data
  data=(out & ~8192) | (data << 13)

  reconfig_EyeQ_set_indirect_register(fpgaid,3,data,verbose)
  if (verbose & 1) == 1 : print "="*30
  if (verbose & 1) == 1 : print "set 1D_Eye to %d" % data
  if (verbose & 1) == 1 : print "="*30

def reconfig_EyeQ_get_1D_Eye(fpgaid,verbose=1):
  """Writing a 1 to this bit selects 1D Eye mode and disables vertical height measurement. Writing a 0 to this bit selects normal 2D Eye measurement mode including both the horizontal and vertical axes. You must use 1D Eye mode if you have enabled DFE.
"""
  if (verbose & 1) == 1 : print """Writing a 1 to this bit selects 1D Eye mode and disables vertical height measurement. Writing a 0 to this bit selects normal 2D Eye measurement mode including both the horizontal and vertical axes. You must use 1D Eye mode if you have enabled DFE.
"""
  out=reconfig_EyeQ_get_indirect_register(fpgaid,3,verbose)
  out=out & 8192
  out=out >> 13
  if out == "":
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "EyeQ 1D_Eye is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return out
  else:
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "EyeQ 1D_Eye is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return int(out)

def reconfig_EyeQ_set_Vertical_height(fpgaid,data,verbose=1):
  """Taken together, the horizontal phase and vertical height specify the Cartesian x-y coordinates of the point on the eye diagram that you want to sample. You can specify 64 heights on the vertical axis.
"""
  if (verbose & 1) == 1 : print """Taken together, the horizontal phase and vertical height specify the Cartesian x-y coordinates of the point on the eye diagram that you want to sample. You can specify 64 heights on the vertical axis.
"""
  reconfig_EyeQ_set_indirect_register(fpgaid,2,data,verbose)
  if (verbose & 1) == 1 : print "="*30
  if (verbose & 1) == 1 : print "set Vertical_height to %d" % data
  if (verbose & 1) == 1 : print "="*30

def reconfig_EyeQ_get_Vertical_height(fpgaid,verbose=1):
  """Taken together, the horizontal phase and vertical height specify the Cartesian x-y coordinates of the point on the eye diagram that you want to sample. You can specify 64 heights on the vertical axis.
"""
  if (verbose & 1) == 1 : print """Taken together, the horizontal phase and vertical height specify the Cartesian x-y coordinates of the point on the eye diagram that you want to sample. You can specify 64 heights on the vertical axis.
"""
  out=reconfig_EyeQ_get_indirect_register(fpgaid,2,verbose)
  out=out & 63
  out=out >> 0
  if out == "":
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "EyeQ Vertical_height is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return out
  else:
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "EyeQ Vertical_height is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return int(out)

def reconfig_EyeQ_set_BERB_Enable(fpgaid,data,verbose=1):
  """Only available when you turn on the Enable Bit Error Rate Block in the Transceiver Reconfiguration Controller IP Core GUI.  When set to 1, enables the BER. When set to 0, disables the BER counters and the bit checker.
"""
  if (verbose & 1) == 1 : print """Only available when you turn on the Enable Bit Error Rate Block in the Transceiver Reconfiguration Controller IP Core GUI.  When set to 1, enables the BER. When set to 0, disables the BER counters and the bit checker.
"""
  # read
  out=reconfig_EyeQ_get_indirect_register(fpgaid,0,verbose)
  # modify data
  data=(out & ~2) | (data << 1)

  reconfig_EyeQ_set_indirect_register(fpgaid,0,data,verbose)
  if (verbose & 1) == 1 : print "="*30
  if (verbose & 1) == 1 : print "set BERB_Enable to %d" % data
  if (verbose & 1) == 1 : print "="*30

def reconfig_EyeQ_get_BERB_Enable(fpgaid,verbose=1):
  """Only available when you turn on the Enable Bit Error Rate Block in the Transceiver Reconfiguration Controller IP Core GUI.  When set to 1, enables the BER. When set to 0, disables the BER counters and the bit checker.
"""
  if (verbose & 1) == 1 : print """Only available when you turn on the Enable Bit Error Rate Block in the Transceiver Reconfiguration Controller IP Core GUI.  When set to 1, enables the BER. When set to 0, disables the BER counters and the bit checker.
"""
  out=reconfig_EyeQ_get_indirect_register(fpgaid,0,verbose)
  out=out & 2
  out=out >> 1
  if out == "":
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "EyeQ BERB_Enable is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return out
  else:
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "EyeQ BERB_Enable is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return int(out)

def reconfig_EyeQ_set_Enable_Eye_Monitor(fpgaid,data,verbose=1):
  """Writing a 1 to this bit enables the Eye monitor.
"""
  if (verbose & 1) == 1 : print """Writing a 1 to this bit enables the Eye monitor.
"""
  # read
  out=reconfig_EyeQ_get_indirect_register(fpgaid,0,verbose)
  # modify data
  data=(out & ~1) | (data << 0)

  reconfig_EyeQ_set_indirect_register(fpgaid,0,data,verbose)
  if (verbose & 1) == 1 : print "="*30
  if (verbose & 1) == 1 : print "set Enable_Eye_Monitor to %d" % data
  if (verbose & 1) == 1 : print "="*30

def reconfig_EyeQ_get_Enable_Eye_Monitor(fpgaid,verbose=1):
  """Writing a 1 to this bit enables the Eye monitor.
"""
  if (verbose & 1) == 1 : print """Writing a 1 to this bit enables the Eye monitor.
"""
  out=reconfig_EyeQ_get_indirect_register(fpgaid,0,verbose)
  out=out & 1
  out=out >> 0
  if out == "":
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "EyeQ Enable_Eye_Monitor is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return out
  else:
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "EyeQ Enable_Eye_Monitor is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return int(out)

def reconfig_EyeQ_get_Err_Conter63_32(fpgaid,verbose=1):
  """Only available when the BERB Enable and Counter Enable bits are set. Err
Counter[63:0]reports the total number of error bits received since you enabled or reset BER counters.
"""
  if (verbose & 1) == 1 : print """Only available when the BERB Enable and Counter Enable bits are set. Err
Counter[63:0]reports the total number of error bits received since you enabled or reset BER counters.
"""
  out=reconfig_EyeQ_get_indirect_register(fpgaid,8,verbose)
  out=out & 4294967295
  out=out >> 0
  if out == "":
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "EyeQ Err_Conter63_32 is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return out
  else:
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "EyeQ Err_Conter63_32 is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return int(out)

def reconfig_EyeQ_set_BERB_Snap_Shot_and_Reset(fpgaid,data,verbose=1):
  """Only available when you turn on the Enable Bit Error Rate Block in the Transceiver Reconfiguration Controller IP Core GUI. The following encodings are defined:
  2'b00: Reserved.
  2'b01: Reset everything, snapshot and counters are reset to 0.
  2'b10: Take a snapshot. Copy the counter values into local registers for read access. These values are not updated until another snapshot is taken.
  2'b11: Snapshot and reset. Take a snapshot of the counter values. Reset the counters and leave the snap shot untouched.
"""
  if (verbose & 1) == 1 : print """Only available when you turn on the Enable Bit Error Rate Block in the Transceiver Reconfiguration Controller IP Core GUI. The following encodings are defined:
  2'b00: Reserved.
  2'b01: Reset everything, snapshot and counters are reset to 0.
  2'b10: Take a snapshot. Copy the counter values into local registers for read access. These values are not updated until another snapshot is taken.
  2'b11: Snapshot and reset. Take a snapshot of the counter values. Reset the counters and leave the snap shot untouched.
"""
  # read
  out=reconfig_EyeQ_get_indirect_register(fpgaid,0,verbose)
  # modify data
  data=(out & ~24) | (data << 3)

  reconfig_EyeQ_set_indirect_register(fpgaid,0,data,verbose)
  if (verbose & 1) == 1 : print "="*30
  if (verbose & 1) == 1 : print "set BERB_Snap_Shot_and_Reset to %d" % data
  if (verbose & 1) == 1 : print "="*30

def reconfig_EyeQ_get_BERB_Snap_Shot_and_Reset(fpgaid,verbose=1):
  """Only available when you turn on the Enable Bit Error Rate Block in the Transceiver Reconfiguration Controller IP Core GUI. The following encodings are defined:
  2'b00: Reserved.
  2'b01: Reset everything, snapshot and counters are reset to 0.
  2'b10: Take a snapshot. Copy the counter values into local registers for read access. These values are not updated until another snapshot is taken.
  2'b11: Snapshot and reset. Take a snapshot of the counter values. Reset the counters and leave the snap shot untouched.
"""
  if (verbose & 1) == 1 : print """Only available when you turn on the Enable Bit Error Rate Block in the Transceiver Reconfiguration Controller IP Core GUI. The following encodings are defined:
  2'b00: Reserved.
  2'b01: Reset everything, snapshot and counters are reset to 0.
  2'b10: Take a snapshot. Copy the counter values into local registers for read access. These values are not updated until another snapshot is taken.
  2'b11: Snapshot and reset. Take a snapshot of the counter values. Reset the counters and leave the snap shot untouched.
"""
  out=reconfig_EyeQ_get_indirect_register(fpgaid,0,verbose)
  out=out & 24
  out=out >> 3
  if out == "":
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "EyeQ BERB_Snap_Shot_and_Reset is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return out
  else:
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "EyeQ BERB_Snap_Shot_and_Reset is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return int(out)

def reconfig_PMA_set_Pre_emphasis_pre_tap(fpgaid,data,verbose=1):
  """The following encodings are defined:
  5'b00000-5'b10000: 0
  5'b00001-5'b01111: -15 to -1
  5'b10001-5b'11111: 1 to 15
"""
  if (verbose & 1) == 1 : print """The following encodings are defined:
  5'b00000-5'b10000: 0
  5'b00001-5'b01111: -15 to -1
  5'b10001-5b'11111: 1 to 15
"""
  reconfig_PMA_set_indirect_register(fpgaid,1,data,verbose)
  if (verbose & 1) == 1 : print "="*30
  if (verbose & 1) == 1 : print "set Pre_emphasis_pre_tap to %d" % data
  if (verbose & 1) == 1 : print "="*30

def reconfig_PMA_get_Pre_emphasis_pre_tap(fpgaid,verbose=1):
  """The following encodings are defined:
  5'b00000-5'b10000: 0
  5'b00001-5'b01111: -15 to -1
  5'b10001-5b'11111: 1 to 15
"""
  if (verbose & 1) == 1 : print """The following encodings are defined:
  5'b00000-5'b10000: 0
  5'b00001-5'b01111: -15 to -1
  5'b10001-5b'11111: 1 to 15
"""
  out=reconfig_PMA_get_indirect_register(fpgaid,1,verbose)
  out=out & 31
  out=out >> 0
  if out == "":
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "PMA Pre_emphasis_pre_tap is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return out
  else:
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "PMA Pre_emphasis_pre_tap is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return int(out)

def reconfig_PMA_set_RX_equalization_DC_gain(fpgaid,data,verbose=1):
  """The following encodings are defined:
  3'b000-3b'111:0-4
"""
  if (verbose & 1) == 1 : print """The following encodings are defined:
  3'b000-3b'111:0-4
"""
  reconfig_PMA_set_indirect_register(fpgaid,16,data,verbose)
  if (verbose & 1) == 1 : print "="*30
  if (verbose & 1) == 1 : print "set RX_equalization_DC_gain to %d" % data
  if (verbose & 1) == 1 : print "="*30

def reconfig_PMA_get_RX_equalization_control(fpgaid,verbose=1):
  """The following encodings are defined:
  4'b0000-4'b1111: 0-15
"""
  if (verbose & 1) == 1 : print """The following encodings are defined:
  4'b0000-4'b1111: 0-15
"""
  out=reconfig_PMA_get_indirect_register(fpgaid,17,verbose)
  out=out & 15
  out=out >> 0
  if out == "":
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "PMA RX_equalization_control is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return out
  else:
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "PMA RX_equalization_control is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return int(out)

def reconfig_PMA_get_RX_equalization_DC_gain(fpgaid,verbose=1):
  """The following encodings are defined:
  3'b000-3b'111:0-4
"""
  if (verbose & 1) == 1 : print """The following encodings are defined:
  3'b000-3b'111:0-4
"""
  out=reconfig_PMA_get_indirect_register(fpgaid,16,verbose)
  out=out & 7
  out=out >> 0
  if out == "":
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "PMA RX_equalization_DC_gain is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return out
  else:
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "PMA RX_equalization_DC_gain is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return int(out)

def reconfig_PMA_set_Post_CDR_Reverse_Serial_Loopback(fpgaid,data,verbose=1):
  """Writing a 1 to this bit enables post-CDR reverse serial loopback. Writing a 0 disables post-CDR reverse serial loopback."""
  if (verbose & 1) == 1 : print """Writing a 1 to this bit enables post-CDR reverse serial loopback. Writing a 0 disables post-CDR reverse serial loopback."""
  reconfig_PMA_set_indirect_register(fpgaid,33,data,verbose)
  if (verbose & 1) == 1 : print "="*30
  if (verbose & 1) == 1 : print "set Post_CDR_Reverse_Serial_Loopback to %d" % data
  if (verbose & 1) == 1 : print "="*30

def reconfig_PMA_set_Pre_emphasis_first_post_tap(fpgaid,data,verbose=1):
  """The following encodings are defined:
  5'b00000-5'b11111: 0-31
"""
  if (verbose & 1) == 1 : print """The following encodings are defined:
  5'b00000-5'b11111: 0-31
"""
  reconfig_PMA_set_indirect_register(fpgaid,2,data,verbose)
  if (verbose & 1) == 1 : print "="*30
  if (verbose & 1) == 1 : print "set Pre_emphasis_first_post_tap to %d" % data
  if (verbose & 1) == 1 : print "="*30

def reconfig_PMA_get_Pre_emphasis_first_post_tap(fpgaid,verbose=1):
  """The following encodings are defined:
  5'b00000-5'b11111: 0-31
"""
  if (verbose & 1) == 1 : print """The following encodings are defined:
  5'b00000-5'b11111: 0-31
"""
  out=reconfig_PMA_get_indirect_register(fpgaid,2,verbose)
  out=out & 31
  out=out >> 0
  if out == "":
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "PMA Pre_emphasis_first_post_tap is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return out
  else:
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "PMA Pre_emphasis_first_post_tap is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return int(out)

def reconfig_PMA_set_Pre_emphasis_second_post_tap(fpgaid,data,verbose=1):
  """The following encodings are defined:
  5'b00000-5'b10000: 0
  5'b00001-5'b01111: -15 to -1
  5'b10001-5b'11111: 1 to 15
"""
  if (verbose & 1) == 1 : print """The following encodings are defined:
  5'b00000-5'b10000: 0
  5'b00001-5'b01111: -15 to -1
  5'b10001-5b'11111: 1 to 15
"""
  reconfig_PMA_set_indirect_register(fpgaid,3,data,verbose)
  if (verbose & 1) == 1 : print "="*30
  if (verbose & 1) == 1 : print "set Pre_emphasis_second_post_tap to %d" % data
  if (verbose & 1) == 1 : print "="*30

def reconfig_PMA_get_Pre_emphasis_second_post_tap(fpgaid,verbose=1):
  """The following encodings are defined:
  5'b00000-5'b10000: 0
  5'b00001-5'b01111: -15 to -1
  5'b10001-5b'11111: 1 to 15
"""
  if (verbose & 1) == 1 : print """The following encodings are defined:
  5'b00000-5'b10000: 0
  5'b00001-5'b01111: -15 to -1
  5'b10001-5b'11111: 1 to 15
"""
  out=reconfig_PMA_get_indirect_register(fpgaid,3,verbose)
  out=out & 31
  out=out >> 0
  if out == "":
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "PMA Pre_emphasis_second_post_tap is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return out
  else:
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "PMA Pre_emphasis_second_post_tap is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return int(out)

def reconfig_PMA_set_RX_equalization_control(fpgaid,data,verbose=1):
  """The following encodings are defined:
  4'b0000-4'b1111: 0-15
"""
  if (verbose & 1) == 1 : print """The following encodings are defined:
  4'b0000-4'b1111: 0-15
"""
  reconfig_PMA_set_indirect_register(fpgaid,17,data,verbose)
  if (verbose & 1) == 1 : print "="*30
  if (verbose & 1) == 1 : print "set RX_equalization_control to %d" % data
  if (verbose & 1) == 1 : print "="*30

def reconfig_PMA_set_VOD(fpgaid,data,verbose=1):
  """VOD. The following encodings are defined:
  6'b000000:6'b111111:0-63
"""
  if (verbose & 1) == 1 : print """VOD. The following encodings are defined:
  6'b000000:6'b111111:0-63
"""
  reconfig_PMA_set_indirect_register(fpgaid,0,data,verbose)
  if (verbose & 1) == 1 : print "="*30
  if (verbose & 1) == 1 : print "set VOD to %d" % data
  if (verbose & 1) == 1 : print "="*30

def reconfig_PMA_get_VOD(fpgaid,verbose=1):
  """VOD. The following encodings are defined:
  6'b000000:6'b111111:0-63
"""
  if (verbose & 1) == 1 : print """VOD. The following encodings are defined:
  6'b000000:6'b111111:0-63
"""
  out=reconfig_PMA_get_indirect_register(fpgaid,0,verbose)
  out=out & 63
  out=out >> 0
  if out == "":
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "PMA VOD is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return out
  else:
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "PMA VOD is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return int(out)

def reconfig_PMA_set_Pre_CDR_Reverse_Serial_Loopback(fpgaid,data,verbose=1):
  """Writing a 1 to this bit enables reverse serial loopback. Writing a 0 disables pre-CDR reverse serial loopback."""
  if (verbose & 1) == 1 : print """Writing a 1 to this bit enables reverse serial loopback. Writing a 0 disables pre-CDR reverse serial loopback."""
  reconfig_PMA_set_indirect_register(fpgaid,32,data,verbose)
  if (verbose & 1) == 1 : print "="*30
  if (verbose & 1) == 1 : print "set Pre_CDR_Reverse_Serial_Loopback to %d" % data
  if (verbose & 1) == 1 : print "="*30

def reconfig_AEQ_get_controlstatus(fpgaid,verbose=1):
  """
  Read AEQ control/status register
  """
  global debug
  cmd="rdwr -b %d global.g.rcfg.AEQ_ControlStatus" % fpgaid
  if (verbose & 2) == 2 : print cmd
  out=exec_cmd(cmd)  
  if out == "":
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "AEQ control/status register %s" % out
    if (verbose & 1) == 1 : print "="*30
    return out
  else:
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "AEQ control/status register is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return int(out)

def reconfig_Streamer_get_controlstatus(fpgaid,verbose=1):
  """
  Read Streamer control/status register
  """
  global debug
  cmd="rdwr -b %d global.g.rcfg.Streamer_ControlStatus" % fpgaid
  if (verbose & 2) == 2 : print cmd
  out=exec_cmd(cmd)  
  if out == "":
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "Streamer control/status register %s" % out
    if (verbose & 1) == 1 : print "="*30
    return out
  else:
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "Streamer control/status register is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return int(out)

def reconfig_DFE_get_controlstatus(fpgaid,verbose=1):
  """
  Read DFE control/status register
  """
  global debug
  cmd="rdwr -b %d global.g.rcfg.DFE_ControlStatus" % fpgaid
  if (verbose & 2) == 2 : print cmd
  out=exec_cmd(cmd)  
  if out == "":
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "DFE control/status register %s" % out
    if (verbose & 1) == 1 : print "="*30
    return out
  else:
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "DFE control/status register is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return int(out)

def reconfig_EyeQ_get_controlstatus(fpgaid,verbose=1):
  """
  Read EyeQ control/status register
  """
  global debug
  cmd="rdwr -b %d global.g.rcfg.EyeQ_ControlStatus" % fpgaid
  if (verbose & 2) == 2 : print cmd
  out=exec_cmd(cmd)  
  if out == "":
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "EyeQ control/status register %s" % out
    if (verbose & 1) == 1 : print "="*30
    return out
  else:
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "EyeQ control/status register is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return int(out)

def reconfig_PMA_get_controlstatus(fpgaid,verbose=1):
  """
  Read PMA control/status register
  """
  global debug
  cmd="rdwr -b %d global.g.rcfg.PMA_ControlStatus" % fpgaid
  if (verbose & 2) == 2 : print cmd
  out=exec_cmd(cmd)  
  if out == "":
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "PMA control/status register %s" % out
    if (verbose & 1) == 1 : print "="*30
    return out
  else:
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "PMA control/status register is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return int(out)

def reconfig_ATX_get_controlstatus(fpgaid,verbose=1):
  """
  Read ATX control/status register
  """
  global debug
  cmd="rdwr -b %d global.g.rcfg.ATX_ControlStatus" % fpgaid
  if (verbose & 2) == 2 : print cmd
  out=exec_cmd(cmd)  
  if out == "":
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "ATX control/status register %s" % out
    if (verbose & 1) == 1 : print "="*30
    return out
  else:
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "ATX control/status register is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return int(out)

def reconfig_PLL_get_controlstatus(fpgaid,verbose=1):
  """
  Read PLL control/status register
  """
  global debug
  cmd="rdwr -b %d global.g.rcfg.PLL_ControlStatus" % fpgaid
  if (verbose & 2) == 2 : print cmd
  out=exec_cmd(cmd)  
  if out == "":
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "PLL control/status register %s" % out
    if (verbose & 1) == 1 : print "="*30
    return out
  else:
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "PLL control/status register is %s" % out
    if (verbose & 1) == 1 : print "="*30
    return int(out)

def reconfig_dump_state(fpgaid,verbose=1):
  """
  Dump states of reonfig controller.
  """
  date = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
  OUTFILE=open("log%s"%date.replace(' ','_'),"w")
  lines=[]
  lines.append(date)

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
  if verbose & 4 == 4:
    lines.append("="*50)
    lines.append("Test Observation:")
    lines.append("="*50)
    line=raw_input("Enter your observation: (end with END):")
    line=line.strip()
    lines.append(line)
    while line != "END":
      line=raw_input()
      line=line.strip()
      lines.append(line)
  OUTFILE.write("\n".join(lines))


if __name__ == '__main__':
  """
  """
  import sys
  argc=len(sys.argv)
  if argc >1 : script=sys.argv[1]

