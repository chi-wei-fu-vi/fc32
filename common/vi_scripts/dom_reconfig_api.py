#!/bin/env python2
from pprint import pprint
import datetime
import os, sys
import subprocess
import time
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
                'Bandwidth': {3: '[10:9]'},
                'Control': {0: '[0]'},
                'Horizontal_phase': {1: '[5:0]'},
                'Reserved': {3: '[8:0]'},
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
  help_command()
  reconfig_dump_state(fpgaid)
  enable_direct_access (fpgaid)
  disable_direct_access (fpgaid)
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
  reconfig_EyeQ_get_Bandwidth(fpgaid)
  reconfig_EyeQ_get_Control(fpgaid)
  reconfig_EyeQ_get_controlstatus(fpgaid)
  reconfig_EyeQ_get_Horizontal_phase(fpgaid)
  reconfig_EyeQ_get_indirect_register(fpgaid,addr)
  reconfig_EyeQ_get_logical_channel_address(fpgaid)
  reconfig_EyeQ_get_Vertical_height(fpgaid)
  reconfig_EyeQ_set_1D_Eye(fpgaid,data)
  reconfig_EyeQ_set_Bandwidth(fpgaid,data)
  reconfig_EyeQ_set_Control(fpgaid,data)
  reconfig_EyeQ_set_Horizontal_phase(fpgaid,data)
  reconfig_EyeQ_set_indirect_register(fpgaid,addr,data)
  reconfig_EyeQ_set_logical_channel_address(fpgaid,chid)
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

def enable_direct_access (fpgaid):
  """set direct access mode"""
  cmd = "rdwr -b %d %s 0x%X" % (fpgaid,"global.g.fpga.ReconfigCtrl.Direct", 1)
  if debug : print cmd
  exec_cmd(cmd)
  time.sleep(1.0)

def disable_direct_access (fpgaid):
  """clear direct access mode"""
  cmd = "rdwr -b %d %s 0x%X" % (fpgaid,"global.g.fpga.ReconfigCtrl.Direct", 0)
  if debug : print cmd
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










def reconfig_AEQ_set_logical_channel_address(fpgaid,chid):
  global debug
  cmd="rdwr -b %d global.g.rcfg.AEQ_LogicalChanNo 0x%X" % (fpgaid,chid)
  if debug : print cmd
  exec_cmd(cmd)  
  print "="*30
  print "set AEQ logical channel to %d" % chid
  print "="*30

def reconfig_AEQ_get_logical_channel_address(fpgaid):
  global debug
  cmd="rdwr -b %d global.g.rcfg.AEQ_LogicalChanNo" % fpgaid
  if debug : print cmd
  out=exec_cmd(cmd)  
  if out == "":
    print "="*30
    print "AEQ logical channel is %s" % out
    print "="*30
    return out
  else:
    print "="*30
    print "AEQ logical channel is %s" % out
    print "="*30
    return int(out)

def reconfig_Streamer_set_logical_channel_address(fpgaid,chid):
  global debug
  cmd="rdwr -b %d global.g.rcfg.Streamer_LogicalChanNo 0x%X" % (fpgaid,chid)
  if debug : print cmd
  exec_cmd(cmd)  
  print "="*30
  print "set Streamer logical channel to %d" % chid
  print "="*30

def reconfig_Streamer_get_logical_channel_address(fpgaid):
  global debug
  cmd="rdwr -b %d global.g.rcfg.Streamer_LogicalChanNo" % fpgaid
  if debug : print cmd
  out=exec_cmd(cmd)  
  if out == "":
    print "="*30
    print "Streamer logical channel is %s" % out
    print "="*30
    return out
  else:
    print "="*30
    print "Streamer logical channel is %s" % out
    print "="*30
    return int(out)

def reconfig_DFE_set_logical_channel_address(fpgaid,chid):
  global debug
  cmd="rdwr -b %d global.g.rcfg.DFE_LogicalChanNo 0x%X" % (fpgaid,chid)
  if debug : print cmd
  exec_cmd(cmd)  
  print "="*30
  print "set DFE logical channel to %d" % chid
  print "="*30

def reconfig_DFE_get_logical_channel_address(fpgaid):
  global debug
  cmd="rdwr -b %d global.g.rcfg.DFE_LogicalChanNo" % fpgaid
  if debug : print cmd
  out=exec_cmd(cmd)  
  if out == "":
    print "="*30
    print "DFE logical channel is %s" % out
    print "="*30
    return out
  else:
    print "="*30
    print "DFE logical channel is %s" % out
    print "="*30
    return int(out)

def reconfig_EyeQ_set_logical_channel_address(fpgaid,chid):
  global debug
  cmd="rdwr -b %d global.g.rcfg.EyeQ_LogicalChanNo 0x%X" % (fpgaid,chid)
  if debug : print cmd
  exec_cmd(cmd)  
  print "="*30
  print "set EyeQ logical channel to %d" % chid
  print "="*30

def reconfig_EyeQ_get_logical_channel_address(fpgaid):
  global debug
  cmd="rdwr -b %d global.g.rcfg.EyeQ_LogicalChanNo" % fpgaid
  if debug : print cmd
  out=exec_cmd(cmd)  
  if out == "":
    print "="*30
    print "EyeQ logical channel is %s" % out
    print "="*30
    return out
  else:
    print "="*30
    print "EyeQ logical channel is %s" % out
    print "="*30
    return int(out)

def reconfig_PMA_set_logical_channel_address(fpgaid,chid):
  global debug
  cmd="rdwr -b %d global.g.rcfg.PMA_LogicalChanNo 0x%X" % (fpgaid,chid)
  if debug : print cmd
  exec_cmd(cmd)  
  print "="*30
  print "set PMA logical channel to %d" % chid
  print "="*30

def reconfig_PMA_get_logical_channel_address(fpgaid):
  global debug
  cmd="rdwr -b %d global.g.rcfg.PMA_LogicalChanNo" % fpgaid
  if debug : print cmd
  out=exec_cmd(cmd)  
  if out == "":
    print "="*30
    print "PMA logical channel is %s" % out
    print "="*30
    return out
  else:
    print "="*30
    print "PMA logical channel is %s" % out
    print "="*30
    return int(out)

def reconfig_ATX_set_logical_channel_address(fpgaid,chid):
  global debug
  cmd="rdwr -b %d global.g.rcfg.ATX_LogicalChanNo 0x%X" % (fpgaid,chid)
  if debug : print cmd
  exec_cmd(cmd)  
  print "="*30
  print "set ATX logical channel to %d" % chid
  print "="*30

def reconfig_ATX_get_logical_channel_address(fpgaid):
  global debug
  cmd="rdwr -b %d global.g.rcfg.ATX_LogicalChanNo" % fpgaid
  if debug : print cmd
  out=exec_cmd(cmd)  
  if out == "":
    print "="*30
    print "ATX logical channel is %s" % out
    print "="*30
    return out
  else:
    print "="*30
    print "ATX logical channel is %s" % out
    print "="*30
    return int(out)

def reconfig_PLL_set_logical_channel_address(fpgaid,chid):
  global debug
  cmd="rdwr -b %d global.g.rcfg.PLL_LogicalChanNo 0x%X" % (fpgaid,chid)
  if debug : print cmd
  exec_cmd(cmd)  
  print "="*30
  print "set PLL logical channel to %d" % chid
  print "="*30

def reconfig_PLL_get_logical_channel_address(fpgaid):
  global debug
  cmd="rdwr -b %d global.g.rcfg.PLL_LogicalChanNo" % fpgaid
  if debug : print cmd
  out=exec_cmd(cmd)  
  if out == "":
    print "="*30
    print "PLL logical channel is %s" % out
    print "="*30
    return out
  else:
    print "="*30
    print "PLL logical channel is %s" % out
    print "="*30
    return int(out)

def reconfig_AEQ_set_indirect_register(fpgaid,addr,data):
  global debug
  cmd="rdwr -b %d global.g.rcfg.AEQ_Offset 0x%X" % (fpgaid,addr)
  if debug : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.AEQ_Data 0x%X" % (fpgaid,data)
  if debug : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.AEQ_ControlStatus 1" % fpgaid
  if debug : print cmd
  exec_cmd(cmd)  

def reconfig_AEQ_get_indirect_register(fpgaid,addr):
  cmd="rdwr -b %d global.g.rcfg.AEQ_Offset 0x%X" % (fpgaid,addr)
  if debug : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.AEQ_ControlStatus 2" % fpgaid
  if debug : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.AEQ_Data" % fpgaid
  if debug : print cmd
  out=exec_cmd(cmd)  
  if out == "":
    return out
  else:
    return int(out)

def reconfig_Streamer_set_indirect_register(fpgaid,addr,data):
  global debug
  cmd="rdwr -b %d global.g.rcfg.Streamer_Offset 0x%X" % (fpgaid,addr)
  if debug : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.Streamer_Data 0x%X" % (fpgaid,data)
  if debug : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.Streamer_ControlStatus 1" % fpgaid
  if debug : print cmd
  exec_cmd(cmd)  

def reconfig_Streamer_get_indirect_register(fpgaid,addr):
  cmd="rdwr -b %d global.g.rcfg.Streamer_Offset 0x%X" % (fpgaid,addr)
  if debug : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.Streamer_ControlStatus 2" % fpgaid
  if debug : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.Streamer_Data" % fpgaid
  if debug : print cmd
  out=exec_cmd(cmd)  
  if out == "":
    return out
  else:
    return int(out)

def reconfig_DFE_set_indirect_register(fpgaid,addr,data):
  global debug
  cmd="rdwr -b %d global.g.rcfg.DFE_Offset 0x%X" % (fpgaid,addr)
  if debug : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.DFE_Data 0x%X" % (fpgaid,data)
  if debug : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.DFE_ControlStatus 1" % fpgaid
  if debug : print cmd
  exec_cmd(cmd)  

def reconfig_DFE_get_indirect_register(fpgaid,addr):
  cmd="rdwr -b %d global.g.rcfg.DFE_Offset 0x%X" % (fpgaid,addr)
  if debug : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.DFE_ControlStatus 2" % fpgaid
  if debug : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.DFE_Data" % fpgaid
  if debug : print cmd
  out=exec_cmd(cmd)  
  if out == "":
    return out
  else:
    return int(out)

def reconfig_EyeQ_set_indirect_register(fpgaid,addr,data):
  global debug
  cmd="rdwr -b %d global.g.rcfg.EyeQ_Offset 0x%X" % (fpgaid,addr)
  if debug : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.EyeQ_Data 0x%X" % (fpgaid,data)
  if debug : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.EyeQ_ControlStatus 1" % fpgaid
  if debug : print cmd
  exec_cmd(cmd)  

def reconfig_EyeQ_get_indirect_register(fpgaid,addr):
  cmd="rdwr -b %d global.g.rcfg.EyeQ_Offset 0x%X" % (fpgaid,addr)
  if debug : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.EyeQ_ControlStatus 2" % fpgaid
  if debug : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.EyeQ_Data" % fpgaid
  if debug : print cmd
  out=exec_cmd(cmd)  
  if out == "":
    return out
  else:
    return int(out)

def reconfig_PMA_set_indirect_register(fpgaid,addr,data):
  global debug
  cmd="rdwr -b %d global.g.rcfg.PMA_Offset 0x%X" % (fpgaid,addr)
  if debug : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.PMA_Data 0x%X" % (fpgaid,data)
  if debug : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.PMA_ControlStatus 1" % fpgaid
  if debug : print cmd
  exec_cmd(cmd)  

def reconfig_PMA_get_indirect_register(fpgaid,addr):
  cmd="rdwr -b %d global.g.rcfg.PMA_Offset 0x%X" % (fpgaid,addr)
  if debug : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.PMA_ControlStatus 2" % fpgaid
  if debug : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.PMA_Data" % fpgaid
  if debug : print cmd
  out=exec_cmd(cmd)  
  if out == "":
    return out
  else:
    return int(out)

def reconfig_ATX_set_indirect_register(fpgaid,addr,data):
  global debug
  cmd="rdwr -b %d global.g.rcfg.ATX_Offset 0x%X" % (fpgaid,addr)
  if debug : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.ATX_Data 0x%X" % (fpgaid,data)
  if debug : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.ATX_ControlStatus 1" % fpgaid
  if debug : print cmd
  exec_cmd(cmd)  

def reconfig_ATX_get_indirect_register(fpgaid,addr):
  cmd="rdwr -b %d global.g.rcfg.ATX_Offset 0x%X" % (fpgaid,addr)
  if debug : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.ATX_ControlStatus 2" % fpgaid
  if debug : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.ATX_Data" % fpgaid
  if debug : print cmd
  out=exec_cmd(cmd)  
  if out == "":
    return out
  else:
    return int(out)

def reconfig_PLL_set_indirect_register(fpgaid,addr,data):
  global debug
  cmd="rdwr -b %d global.g.rcfg.PLL_Offset 0x%X" % (fpgaid,addr)
  if debug : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.PLL_Data 0x%X" % (fpgaid,data)
  if debug : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.PLL_ControlStatus 1" % fpgaid
  if debug : print cmd
  exec_cmd(cmd)  

def reconfig_PLL_get_indirect_register(fpgaid,addr):
  cmd="rdwr -b %d global.g.rcfg.PLL_Offset 0x%X" % (fpgaid,addr)
  if debug : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.PLL_ControlStatus 2" % fpgaid
  if debug : print cmd
  exec_cmd(cmd)  
  cmd="rdwr -b %d global.g.rcfg.PLL_Data" % fpgaid
  if debug : print cmd
  out=exec_cmd(cmd)  
  if out == "":
    return out
  else:
    return int(out)

def reconfig_AEQ_get_adapt_done(fpgaid):
  """When asserted, indicates that adaptation has completed. In One-Time Adaptation Mode, AEQ stops searching new EQ settings even if the signal quality of incoming serial data is inadequate. In Continuous Adaptation Mode, AEQ continues to search for new settings after this bit is asserted.  This bit is only valid in one-time AEQ adaptation mode. For some extreme cases, when the channel loss is too much for AEQ to compensate, the adapt_done signal may never be asserted. The AEQ engine can take up to 50,000 reconfiguration clock cycles before selecting the final equalization settings.
"""
  print """When asserted, indicates that adaptation has completed. In One-Time Adaptation Mode, AEQ stops searching new EQ settings even if the signal quality of incoming serial data is inadequate. In Continuous Adaptation Mode, AEQ continues to search for new settings after this bit is asserted.  This bit is only valid in one-time AEQ adaptation mode. For some extreme cases, when the channel loss is too much for AEQ to compensate, the adapt_done signal may never be asserted. The AEQ engine can take up to 50,000 reconfiguration clock cycles before selecting the final equalization settings.
"""
  out=reconfig_AEQ_get_indirect_register(fpgaid,0)
  out=out & 256
  out=out >> 8
  if out == "":
    print "="*30
    print "AEQ adapt_done is %s" % out
    print "="*30
    return out
  else:
    print "="*30
    print "AEQ adapt_done is %s" % out
    print "="*30
    return int(out)

def reconfig_AEQ_get_equalization_results(fpgaid):
  """This is the value set by the automatic AEQ adaptation performed at startup. If you choose to perform manual equalization using the linear equalizer, you can use this value as a reference.  Although automatic and manual equalization do not provide identical functionality, specifying this value enables manual equalization to approximate the original setting.
"""
  print """This is the value set by the automatic AEQ adaptation performed at startup. If you choose to perform manual equalization using the linear equalizer, you can use this value as a reference.  Although automatic and manual equalization do not provide identical functionality, specifying this value enables manual equalization to approximate the original setting.
"""
  out=reconfig_AEQ_get_indirect_register(fpgaid,1)
  out=out & 15
  out=out >> 0
  if out == "":
    print "="*30
    print "AEQ equalization_results is %s" % out
    print "="*30
    return out
  else:
    print "="*30
    print "AEQ equalization_results is %s" % out
    print "="*30
    return int(out)

def reconfig_AEQ_set_mode(fpgaid,data):
  """Specifies the following address modes:
 2'b00: Low power manual equalization mode
 2'b01: One-time AEQ adaptation at power up
 2'b10: Perform continuous AEQ adaptation
 2'b11: Reserved
"""
  print """Specifies the following address modes:
 2'b00: Low power manual equalization mode
 2'b01: One-time AEQ adaptation at power up
 2'b10: Perform continuous AEQ adaptation
 2'b11: Reserved
"""
  # read
  out=reconfig_AEQ_get_indirect_register(fpgaid,0)
  # modify data
  data=(out & 3) | (data << 0)

  reconfig_AEQ_set_indirect_register(fpgaid,0,data)

def reconfig_AEQ_get_mode(fpgaid):
  """Specifies the following address modes:
 2'b00: Low power manual equalization mode
 2'b01: One-time AEQ adaptation at power up
 2'b10: Perform continuous AEQ adaptation
 2'b11: Reserved
"""
  print """Specifies the following address modes:
 2'b00: Low power manual equalization mode
 2'b01: One-time AEQ adaptation at power up
 2'b10: Perform continuous AEQ adaptation
 2'b11: Reserved
"""
  out=reconfig_AEQ_get_indirect_register(fpgaid,0)
  out=out & 3
  out=out >> 0
  if out == "":
    print "="*30
    print "AEQ mode is %s" % out
    print "="*30
    return out
  else:
    print "="*30
    print "AEQ mode is %s" % out
    print "="*30
    return int(out)

def reconfig_DFE_set_tap_2_polarity(fpgaid,data):
  """Specifies the polarity of the second post tap as follows:
  0: negative polarity
  1: positive polarity
"""
  print """Specifies the polarity of the second post tap as follows:
  0: negative polarity
  1: positive polarity
"""
  # read
  out=reconfig_DFE_get_indirect_register(fpgaid,2)
  # modify data
  data=(out & 8) | (data << 3)

  reconfig_DFE_set_indirect_register(fpgaid,2,data)

def reconfig_DFE_get_tap_2_polarity(fpgaid):
  """Specifies the polarity of the second post tap as follows:
  0: negative polarity
  1: positive polarity
"""
  print """Specifies the polarity of the second post tap as follows:
  0: negative polarity
  1: positive polarity
"""
  out=reconfig_DFE_get_indirect_register(fpgaid,2)
  out=out & 8
  out=out >> 3
  if out == "":
    print "="*30
    print "DFE tap_2_polarity is %s" % out
    print "="*30
    return out
  else:
    print "="*30
    print "DFE tap_2_polarity is %s" % out
    print "="*30
    return int(out)

def reconfig_DFE_set_tap_5(fpgaid,data):
  """Specifies the coefficient for the fifth post tap. The valid range is 0-3.
"""
  print """Specifies the coefficient for the fifth post tap. The valid range is 0-3.
"""
  # read
  out=reconfig_DFE_get_indirect_register(fpgaid,5)
  # modify data
  data=(out & 7) | (data << 0)

  reconfig_DFE_set_indirect_register(fpgaid,5,data)

def reconfig_DFE_get_tap_5(fpgaid):
  """Specifies the coefficient for the fifth post tap. The valid range is 0-3.
"""
  print """Specifies the coefficient for the fifth post tap. The valid range is 0-3.
"""
  out=reconfig_DFE_get_indirect_register(fpgaid,5)
  out=out & 7
  out=out >> 0
  if out == "":
    print "="*30
    print "DFE tap_5 is %s" % out
    print "="*30
    return out
  else:
    print "="*30
    print "DFE tap_5 is %s" % out
    print "="*30
    return int(out)

def reconfig_DFE_set_tap_4_polarity(fpgaid,data):
  """Specifies the polarity of the fourth post tap as follows:
"""
  print """Specifies the polarity of the fourth post tap as follows:
"""
  # read
  out=reconfig_DFE_get_indirect_register(fpgaid,4)
  # modify data
  data=(out & 8) | (data << 3)

  reconfig_DFE_set_indirect_register(fpgaid,4,data)

def reconfig_DFE_get_tap_4_polarity(fpgaid):
  """Specifies the polarity of the fourth post tap as follows:
"""
  print """Specifies the polarity of the fourth post tap as follows:
"""
  out=reconfig_DFE_get_indirect_register(fpgaid,4)
  out=out & 8
  out=out >> 3
  if out == "":
    print "="*30
    print "DFE tap_4_polarity is %s" % out
    print "="*30
    return out
  else:
    print "="*30
    print "DFE tap_4_polarity is %s" % out
    print "="*30
    return int(out)

def reconfig_DFE_set_power_on(fpgaid,data):
  """Writing a 0 to this bit powers down DFE in the channel specified.
"""
  print """Writing a 0 to this bit powers down DFE in the channel specified.
"""
  # read
  out=reconfig_DFE_get_indirect_register(fpgaid,0)
  # modify data
  data=(out & 2) | (data << 1)

  reconfig_DFE_set_indirect_register(fpgaid,0,data)

def reconfig_DFE_get_power_on(fpgaid):
  """Writing a 0 to this bit powers down DFE in the channel specified.
"""
  print """Writing a 0 to this bit powers down DFE in the channel specified.
"""
  out=reconfig_DFE_get_indirect_register(fpgaid,0)
  out=out & 2
  out=out >> 1
  if out == "":
    print "="*30
    print "DFE power_on is %s" % out
    print "="*30
    return out
  else:
    print "="*30
    print "DFE power_on is %s" % out
    print "="*30
    return int(out)

def reconfig_DFE_set_DFE_adaptation(fpgaid,data):
  """Writing a 1 to this bit initiates DFE 1-time adaptation on the specified channel.
"""
  print """Writing a 1 to this bit initiates DFE 1-time adaptation on the specified channel.
"""
  reconfig_DFE_set_indirect_register(fpgaid,11,data)

def reconfig_DFE_set_adaptation_engine_enable(fpgaid,data):
  """Writing a 1 triggers the adaptive equalization engine.
"""
  print """Writing a 1 triggers the adaptive equalization engine.
"""
  # read
  out=reconfig_DFE_get_indirect_register(fpgaid,0)
  # modify data
  data=(out & 1) | (data << 0)

  reconfig_DFE_set_indirect_register(fpgaid,0,data)

def reconfig_DFE_get_adaptation_engine_enable(fpgaid):
  """Writing a 1 triggers the adaptive equalization engine.
"""
  print """Writing a 1 triggers the adaptive equalization engine.
"""
  out=reconfig_DFE_get_indirect_register(fpgaid,0)
  out=out & 1
  out=out >> 0
  if out == "":
    print "="*30
    print "DFE adaptation_engine_enable is %s" % out
    print "="*30
    return out
  else:
    print "="*30
    print "DFE adaptation_engine_enable is %s" % out
    print "="*30
    return int(out)

def reconfig_DFE_set_tap_3(fpgaid,data):
  """Specifies the coefficient for the third post tap. The valid range is 0-7.
"""
  print """Specifies the coefficient for the third post tap. The valid range is 0-7.
"""
  # read
  out=reconfig_DFE_get_indirect_register(fpgaid,3)
  # modify data
  data=(out & 7) | (data << 0)

  reconfig_DFE_set_indirect_register(fpgaid,3,data)

def reconfig_DFE_get_tap_3(fpgaid):
  """Specifies the coefficient for the third post tap. The valid range is 0-7.
"""
  print """Specifies the coefficient for the third post tap. The valid range is 0-7.
"""
  out=reconfig_DFE_get_indirect_register(fpgaid,3)
  out=out & 7
  out=out >> 0
  if out == "":
    print "="*30
    print "DFE tap_3 is %s" % out
    print "="*30
    return out
  else:
    print "="*30
    print "DFE tap_3 is %s" % out
    print "="*30
    return int(out)

def reconfig_DFE_set_tap_2(fpgaid,data):
  """Specifies the coefficient for the second post tap. The valid range is 0-7.
"""
  print """Specifies the coefficient for the second post tap. The valid range is 0-7.
"""
  # read
  out=reconfig_DFE_get_indirect_register(fpgaid,2)
  # modify data
  data=(out & 7) | (data << 0)

  reconfig_DFE_set_indirect_register(fpgaid,2,data)

def reconfig_DFE_get_tap_2(fpgaid):
  """Specifies the coefficient for the second post tap. The valid range is 0-7.
"""
  print """Specifies the coefficient for the second post tap. The valid range is 0-7.
"""
  out=reconfig_DFE_get_indirect_register(fpgaid,2)
  out=out & 7
  out=out >> 0
  if out == "":
    print "="*30
    print "DFE tap_2 is %s" % out
    print "="*30
    return out
  else:
    print "="*30
    print "DFE tap_2 is %s" % out
    print "="*30
    return int(out)

def reconfig_DFE_set_tap_1(fpgaid,data):
  """Specifies the coefficient for the first post tap. The valid range is 0-15.
"""
  print """Specifies the coefficient for the first post tap. The valid range is 0-15.
"""
  reconfig_DFE_set_indirect_register(fpgaid,1,data)

def reconfig_DFE_get_tap_1(fpgaid):
  """Specifies the coefficient for the first post tap. The valid range is 0-15.
"""
  print """Specifies the coefficient for the first post tap. The valid range is 0-15.
"""
  out=reconfig_DFE_get_indirect_register(fpgaid,1)
  out=out & 15
  out=out >> 0
  if out == "":
    print "="*30
    print "DFE tap_1 is %s" % out
    print "="*30
    return out
  else:
    print "="*30
    print "DFE tap_1 is %s" % out
    print "="*30
    return int(out)

def reconfig_DFE_set_tap_3_polarity(fpgaid,data):
  """Specifies the polarity of the third post tap as follows:
  0: negative polarity
  1: positive polarity
"""
  print """Specifies the polarity of the third post tap as follows:
  0: negative polarity
  1: positive polarity
"""
  # read
  out=reconfig_DFE_get_indirect_register(fpgaid,3)
  # modify data
  data=(out & 8) | (data << 3)

  reconfig_DFE_set_indirect_register(fpgaid,3,data)

def reconfig_DFE_get_tap_3_polarity(fpgaid):
  """Specifies the polarity of the third post tap as follows:
  0: negative polarity
  1: positive polarity
"""
  print """Specifies the polarity of the third post tap as follows:
  0: negative polarity
  1: positive polarity
"""
  out=reconfig_DFE_get_indirect_register(fpgaid,3)
  out=out & 8
  out=out >> 3
  if out == "":
    print "="*30
    print "DFE tap_3_polarity is %s" % out
    print "="*30
    return out
  else:
    print "="*30
    print "DFE tap_3_polarity is %s" % out
    print "="*30
    return int(out)

def reconfig_DFE_set_tap_4(fpgaid,data):
  """Specifies the coefficient for the fourth post tap. The valid range is 0-7.
"""
  print """Specifies the coefficient for the fourth post tap. The valid range is 0-7.
"""
  # read
  out=reconfig_DFE_get_indirect_register(fpgaid,4)
  # modify data
  data=(out & 7) | (data << 0)

  reconfig_DFE_set_indirect_register(fpgaid,4,data)

def reconfig_DFE_get_tap_4(fpgaid):
  """Specifies the coefficient for the fourth post tap. The valid range is 0-7.
"""
  print """Specifies the coefficient for the fourth post tap. The valid range is 0-7.
"""
  out=reconfig_DFE_get_indirect_register(fpgaid,4)
  out=out & 7
  out=out >> 0
  if out == "":
    print "="*30
    print "DFE tap_4 is %s" % out
    print "="*30
    return out
  else:
    print "="*30
    print "DFE tap_4 is %s" % out
    print "="*30
    return int(out)

def reconfig_DFE_set_tap_5_polarity(fpgaid,data):
  """Specifies the polarity of the fifth post tap as follows:
  0: negative polarity
  1: positive polarity
"""
  print """Specifies the polarity of the fifth post tap as follows:
  0: negative polarity
  1: positive polarity
"""
  # read
  out=reconfig_DFE_get_indirect_register(fpgaid,5)
  # modify data
  data=(out & 8) | (data << 3)

  reconfig_DFE_set_indirect_register(fpgaid,5,data)

def reconfig_DFE_get_tap_5_polarity(fpgaid):
  """Specifies the polarity of the fifth post tap as follows:
  0: negative polarity
  1: positive polarity
"""
  print """Specifies the polarity of the fifth post tap as follows:
  0: negative polarity
  1: positive polarity
"""
  out=reconfig_DFE_get_indirect_register(fpgaid,5)
  out=out & 8
  out=out >> 3
  if out == "":
    print "="*30
    print "DFE tap_5_polarity is %s" % out
    print "="*30
    return out
  else:
    print "="*30
    print "DFE tap_5_polarity is %s" % out
    print "="*30
    return int(out)

def reconfig_DFE_set_DFE_calibration(fpgaid,data):
  """Writing a 1 to this bit initiates DFE manual calibration on the specified channel.
"""
  print """Writing a 1 to this bit initiates DFE manual calibration on the specified channel.
"""
  reconfig_DFE_set_indirect_register(fpgaid,10,data)

def reconfig_EyeQ_set_Control(fpgaid,data):
  """Writing a 1 to this bit triggers ATX PLL calibration. This register self-clears. Unused bits of this register must be set to 0.
"""
  print """Writing a 1 to this bit triggers ATX PLL calibration. This register self-clears. Unused bits of this register must be set to 0.
"""
  reconfig_EyeQ_set_indirect_register(fpgaid,0,data)

def reconfig_EyeQ_get_Control(fpgaid):
  """Writing a 1 to this bit triggers ATX PLL calibration. This register self-clears. Unused bits of this register must be set to 0.
"""
  print """Writing a 1 to this bit triggers ATX PLL calibration. This register self-clears. Unused bits of this register must be set to 0.
"""
  out=reconfig_EyeQ_get_indirect_register(fpgaid,0)
  out=out & 1
  out=out >> 0
  if out == "":
    print "="*30
    print "EyeQ Control is %s" % out
    print "="*30
    return out
  else:
    print "="*30
    print "EyeQ Control is %s" % out
    print "="*30
    return int(out)

def reconfig_EyeQ_set_Horizontal_phase(fpgaid,data):
  """Taken together, the horizontal phase and vertical height specify the Cartesian x-y coordinates of the point on the eye diagram that you want to sample. You can increment through 64 phases over 2 UI on the horizontal axis.
"""
  print """Taken together, the horizontal phase and vertical height specify the Cartesian x-y coordinates of the point on the eye diagram that you want to sample. You can increment through 64 phases over 2 UI on the horizontal axis.
"""
  reconfig_EyeQ_set_indirect_register(fpgaid,1,data)

def reconfig_EyeQ_get_Horizontal_phase(fpgaid):
  """Taken together, the horizontal phase and vertical height specify the Cartesian x-y coordinates of the point on the eye diagram that you want to sample. You can increment through 64 phases over 2 UI on the horizontal axis.
"""
  print """Taken together, the horizontal phase and vertical height specify the Cartesian x-y coordinates of the point on the eye diagram that you want to sample. You can increment through 64 phases over 2 UI on the horizontal axis.
"""
  out=reconfig_EyeQ_get_indirect_register(fpgaid,1)
  out=out & 63
  out=out >> 0
  if out == "":
    print "="*30
    print "EyeQ Horizontal_phase is %s" % out
    print "="*30
    return out
  else:
    print "="*30
    print "EyeQ Horizontal_phase is %s" % out
    print "="*30
    return int(out)

def reconfig_EyeQ_set_1D_Eye(fpgaid,data):
  """Writing a 1 to this bit selects 1D Eye mode and disables vertical height measurement. Writing a 0 to this bit selects normal 2D Eye measurement mode including both the horizontal and vertical axes. You must use 1D Eye mode if you have enabled DFE.
"""
  print """Writing a 1 to this bit selects 1D Eye mode and disables vertical height measurement. Writing a 0 to this bit selects normal 2D Eye measurement mode including both the horizontal and vertical axes. You must use 1D Eye mode if you have enabled DFE.
"""
  # read
  out=reconfig_EyeQ_get_indirect_register(fpgaid,3)
  # modify data
  data=(out & 8192) | (data << 13)

  reconfig_EyeQ_set_indirect_register(fpgaid,3,data)

def reconfig_EyeQ_get_1D_Eye(fpgaid):
  """Writing a 1 to this bit selects 1D Eye mode and disables vertical height measurement. Writing a 0 to this bit selects normal 2D Eye measurement mode including both the horizontal and vertical axes. You must use 1D Eye mode if you have enabled DFE.
"""
  print """Writing a 1 to this bit selects 1D Eye mode and disables vertical height measurement. Writing a 0 to this bit selects normal 2D Eye measurement mode including both the horizontal and vertical axes. You must use 1D Eye mode if you have enabled DFE.
"""
  out=reconfig_EyeQ_get_indirect_register(fpgaid,3)
  out=out & 8192
  out=out >> 13
  if out == "":
    print "="*30
    print "EyeQ 1D_Eye is %s" % out
    print "="*30
    return out
  else:
    print "="*30
    print "EyeQ 1D_Eye is %s" % out
    print "="*30
    return int(out)

def reconfig_EyeQ_set_Vertical_height(fpgaid,data):
  """Taken together, the horizontal phase and vertical height specify the Cartesian x-y coordinates of the point on the eye diagram that you want to sample. You can specify 64 heights on the vertical axis.
"""
  print """Taken together, the horizontal phase and vertical height specify the Cartesian x-y coordinates of the point on the eye diagram that you want to sample. You can specify 64 heights on the vertical axis.
"""
  reconfig_EyeQ_set_indirect_register(fpgaid,2,data)

def reconfig_EyeQ_get_Vertical_height(fpgaid):
  """Taken together, the horizontal phase and vertical height specify the Cartesian x-y coordinates of the point on the eye diagram that you want to sample. You can specify 64 heights on the vertical axis.
"""
  print """Taken together, the horizontal phase and vertical height specify the Cartesian x-y coordinates of the point on the eye diagram that you want to sample. You can specify 64 heights on the vertical axis.
"""
  out=reconfig_EyeQ_get_indirect_register(fpgaid,2)
  out=out & 63
  out=out >> 0
  if out == "":
    print "="*30
    print "EyeQ Vertical_height is %s" % out
    print "="*30
    return out
  else:
    print "="*30
    print "EyeQ Vertical_height is %s" % out
    print "="*30
    return int(out)

def reconfig_EyeQ_set_Bandwidth(fpgaid,data):
  """Sets the EyeQ bandwidth based on receiver channel data rate. The following encodings are defined:
 2'b00: data rate < 1 Gbps
 2'b01: data rate > 1 Gbps and <= 2.5 Gbps
 2'b10: data rate > 2.5 Gbps and <= 7.5 Gbps
 2'b11: data rate > 7.5 Gbps
"""
  print """Sets the EyeQ bandwidth based on receiver channel data rate. The following encodings are defined:
 2'b00: data rate < 1 Gbps
 2'b01: data rate > 1 Gbps and <= 2.5 Gbps
 2'b10: data rate > 2.5 Gbps and <= 7.5 Gbps
 2'b11: data rate > 7.5 Gbps
"""
  # read
  out=reconfig_EyeQ_get_indirect_register(fpgaid,3)
  # modify data
  data=(out & 1536) | (data << 9)

  reconfig_EyeQ_set_indirect_register(fpgaid,3,data)

def reconfig_EyeQ_get_Bandwidth(fpgaid):
  """Sets the EyeQ bandwidth based on receiver channel data rate. The following encodings are defined:
 2'b00: data rate < 1 Gbps
 2'b01: data rate > 1 Gbps and <= 2.5 Gbps
 2'b10: data rate > 2.5 Gbps and <= 7.5 Gbps
 2'b11: data rate > 7.5 Gbps
"""
  print """Sets the EyeQ bandwidth based on receiver channel data rate. The following encodings are defined:
 2'b00: data rate < 1 Gbps
 2'b01: data rate > 1 Gbps and <= 2.5 Gbps
 2'b10: data rate > 2.5 Gbps and <= 7.5 Gbps
 2'b11: data rate > 7.5 Gbps
"""
  out=reconfig_EyeQ_get_indirect_register(fpgaid,3)
  out=out & 1536
  out=out >> 9
  if out == "":
    print "="*30
    print "EyeQ Bandwidth is %s" % out
    print "="*30
    return out
  else:
    print "="*30
    print "EyeQ Bandwidth is %s" % out
    print "="*30
    return int(out)

def reconfig_PMA_set_Pre_emphasis_pre_tap(fpgaid,data):
  """The following encodings are defined:
  5'b00000-5'b10000: 0
  5'b00001-5'b01111: -15 to -1
  5'b10001-5b'11111: 1 to 15
"""
  print """The following encodings are defined:
  5'b00000-5'b10000: 0
  5'b00001-5'b01111: -15 to -1
  5'b10001-5b'11111: 1 to 15
"""
  reconfig_PMA_set_indirect_register(fpgaid,1,data)

def reconfig_PMA_get_Pre_emphasis_pre_tap(fpgaid):
  """The following encodings are defined:
  5'b00000-5'b10000: 0
  5'b00001-5'b01111: -15 to -1
  5'b10001-5b'11111: 1 to 15
"""
  print """The following encodings are defined:
  5'b00000-5'b10000: 0
  5'b00001-5'b01111: -15 to -1
  5'b10001-5b'11111: 1 to 15
"""
  out=reconfig_PMA_get_indirect_register(fpgaid,1)
  out=out & 31
  out=out >> 0
  if out == "":
    print "="*30
    print "PMA Pre_emphasis_pre_tap is %s" % out
    print "="*30
    return out
  else:
    print "="*30
    print "PMA Pre_emphasis_pre_tap is %s" % out
    print "="*30
    return int(out)

def reconfig_PMA_set_RX_equalization_DC_gain(fpgaid,data):
  """The following encodings are defined:
  3'b000-3b'111:0-4
"""
  print """The following encodings are defined:
  3'b000-3b'111:0-4
"""
  reconfig_PMA_set_indirect_register(fpgaid,16,data)

def reconfig_PMA_get_RX_equalization_DC_gain(fpgaid):
  """The following encodings are defined:
  3'b000-3b'111:0-4
"""
  print """The following encodings are defined:
  3'b000-3b'111:0-4
"""
  out=reconfig_PMA_get_indirect_register(fpgaid,16)
  out=out & 7
  out=out >> 0
  if out == "":
    print "="*30
    print "PMA RX_equalization_DC_gain is %s" % out
    print "="*30
    return out
  else:
    print "="*30
    print "PMA RX_equalization_DC_gain is %s" % out
    print "="*30
    return int(out)

def reconfig_PMA_set_Post_CDR_Reverse_Serial_Loopback(fpgaid,data):
  """Writing a 1 to this bit enables post-CDR reverse serial loopback. Writing a 0 disables post-CDR reverse serial loopback."""
  print """Writing a 1 to this bit enables post-CDR reverse serial loopback. Writing a 0 disables post-CDR reverse serial loopback."""
  reconfig_PMA_set_indirect_register(fpgaid,33,data)

def reconfig_PMA_set_Pre_emphasis_first_post_tap(fpgaid,data):
  """The following encodings are defined:
  5'b00000-5'b11111: 0-31
"""
  print """The following encodings are defined:
  5'b00000-5'b11111: 0-31
"""
  reconfig_PMA_set_indirect_register(fpgaid,2,data)

def reconfig_PMA_get_Pre_emphasis_first_post_tap(fpgaid):
  """The following encodings are defined:
  5'b00000-5'b11111: 0-31
"""
  print """The following encodings are defined:
  5'b00000-5'b11111: 0-31
"""
  out=reconfig_PMA_get_indirect_register(fpgaid,2)
  out=out & 31
  out=out >> 0
  if out == "":
    print "="*30
    print "PMA Pre_emphasis_first_post_tap is %s" % out
    print "="*30
    return out
  else:
    print "="*30
    print "PMA Pre_emphasis_first_post_tap is %s" % out
    print "="*30
    return int(out)

def reconfig_PMA_set_Pre_emphasis_second_post_tap(fpgaid,data):
  """The following encodings are defined:
  5'b00000-5'b10000: 0
  5'b00001-5'b01111: -15 to -1
  5'b10001-5b'11111: 1 to 15
"""
  print """The following encodings are defined:
  5'b00000-5'b10000: 0
  5'b00001-5'b01111: -15 to -1
  5'b10001-5b'11111: 1 to 15
"""
  reconfig_PMA_set_indirect_register(fpgaid,3,data)

def reconfig_PMA_get_Pre_emphasis_second_post_tap(fpgaid):
  """The following encodings are defined:
  5'b00000-5'b10000: 0
  5'b00001-5'b01111: -15 to -1
  5'b10001-5b'11111: 1 to 15
"""
  print """The following encodings are defined:
  5'b00000-5'b10000: 0
  5'b00001-5'b01111: -15 to -1
  5'b10001-5b'11111: 1 to 15
"""
  out=reconfig_PMA_get_indirect_register(fpgaid,3)
  out=out & 31
  out=out >> 0
  if out == "":
    print "="*30
    print "PMA Pre_emphasis_second_post_tap is %s" % out
    print "="*30
    return out
  else:
    print "="*30
    print "PMA Pre_emphasis_second_post_tap is %s" % out
    print "="*30
    return int(out)

def reconfig_PMA_set_RX_equalization_control(fpgaid,data):
  """The following encodings are defined:
  4'b0000-4'b1111: 0-15
"""
  print """The following encodings are defined:
  4'b0000-4'b1111: 0-15
"""
  reconfig_PMA_set_indirect_register(fpgaid,17,data)

def reconfig_PMA_set_VOD(fpgaid,data):
  """VOD. The following encodings are defined:
  6'b000000:6'b111111:0-63
"""
  print """VOD. The following encodings are defined:
  6'b000000:6'b111111:0-63
"""
  reconfig_PMA_set_indirect_register(fpgaid,0,data)

def reconfig_PMA_get_VOD(fpgaid):
  """VOD. The following encodings are defined:
  6'b000000:6'b111111:0-63
"""
  print """VOD. The following encodings are defined:
  6'b000000:6'b111111:0-63
"""
  out=reconfig_PMA_get_indirect_register(fpgaid,0)
  out=out & 63
  out=out >> 0
  if out == "":
    print "="*30
    print "PMA VOD is %s" % out
    print "="*30
    return out
  else:
    print "="*30
    print "PMA VOD is %s" % out
    print "="*30
    return int(out)

def reconfig_PMA_set_Pre_CDR_Reverse_Serial_Loopback(fpgaid,data):
  """Writing a 1 to this bit enables reverse serial loopback. Writing a 0 disables pre-CDR reverse serial loopback."""
  print """Writing a 1 to this bit enables reverse serial loopback. Writing a 0 disables pre-CDR reverse serial loopback."""
  reconfig_PMA_set_indirect_register(fpgaid,32,data)

def reconfig_AEQ_get_controlstatus(fpgaid):
  """
  Read AEQ control/status register
  """
  global debug
  cmd="rdwr -b %d global.g.rcfg.AEQ_ControlStatus" % fpgaid
  if debug : print cmd
  out=exec_cmd(cmd)  
  if out == "":
    print "="*30
    print "AEQ control/status register %s" % out
    print "="*30
    return out
  else:
    print "="*30
    print "AEQ control/status register is %s" % out
    print "="*30
    return int(out)

def reconfig_Streamer_get_controlstatus(fpgaid):
  """
  Read Streamer control/status register
  """
  global debug
  cmd="rdwr -b %d global.g.rcfg.Streamer_ControlStatus" % fpgaid
  if debug : print cmd
  out=exec_cmd(cmd)  
  if out == "":
    print "="*30
    print "Streamer control/status register %s" % out
    print "="*30
    return out
  else:
    print "="*30
    print "Streamer control/status register is %s" % out
    print "="*30
    return int(out)

def reconfig_DFE_get_controlstatus(fpgaid):
  """
  Read DFE control/status register
  """
  global debug
  cmd="rdwr -b %d global.g.rcfg.DFE_ControlStatus" % fpgaid
  if debug : print cmd
  out=exec_cmd(cmd)  
  if out == "":
    print "="*30
    print "DFE control/status register %s" % out
    print "="*30
    return out
  else:
    print "="*30
    print "DFE control/status register is %s" % out
    print "="*30
    return int(out)

def reconfig_EyeQ_get_controlstatus(fpgaid):
  """
  Read EyeQ control/status register
  """
  global debug
  cmd="rdwr -b %d global.g.rcfg.EyeQ_ControlStatus" % fpgaid
  if debug : print cmd
  out=exec_cmd(cmd)  
  if out == "":
    print "="*30
    print "EyeQ control/status register %s" % out
    print "="*30
    return out
  else:
    print "="*30
    print "EyeQ control/status register is %s" % out
    print "="*30
    return int(out)

def reconfig_PMA_get_controlstatus(fpgaid):
  """
  Read PMA control/status register
  """
  global debug
  cmd="rdwr -b %d global.g.rcfg.PMA_ControlStatus" % fpgaid
  if debug : print cmd
  out=exec_cmd(cmd)  
  if out == "":
    print "="*30
    print "PMA control/status register %s" % out
    print "="*30
    return out
  else:
    print "="*30
    print "PMA control/status register is %s" % out
    print "="*30
    return int(out)

def reconfig_ATX_get_controlstatus(fpgaid):
  """
  Read ATX control/status register
  """
  global debug
  cmd="rdwr -b %d global.g.rcfg.ATX_ControlStatus" % fpgaid
  if debug : print cmd
  out=exec_cmd(cmd)  
  if out == "":
    print "="*30
    print "ATX control/status register %s" % out
    print "="*30
    return out
  else:
    print "="*30
    print "ATX control/status register is %s" % out
    print "="*30
    return int(out)

def reconfig_PLL_get_controlstatus(fpgaid):
  """
  Read PLL control/status register
  """
  global debug
  cmd="rdwr -b %d global.g.rcfg.PLL_ControlStatus" % fpgaid
  if debug : print cmd
  out=exec_cmd(cmd)  
  if out == "":
    print "="*30
    print "PLL control/status register %s" % out
    print "="*30
    return out
  else:
    print "="*30
    print "PLL control/status register is %s" % out
    print "="*30
    return int(out)

def reconfig_dump_state(fpgaid):
  """
  Dump states of reonfig controller.
  """
  date = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
  OUTFILE=open("log%s"%date.replace(' ','_'),"w")
  lines=[]
  lines.append(date)

  lines.append("Group  : AEQ")
  lines.append("  Logic Channel                  : %d" % reconfig_AEQ_get_logical_channel_address(fpgaid))
  lines.append("  adapt_done                     : %d" % reconfig_AEQ_get_adapt_done(fpgaid))
  lines.append("  equalization_results           : %d" % reconfig_AEQ_get_equalization_results(fpgaid))
  lines.append("  mode                           : %d" % reconfig_AEQ_get_mode(fpgaid))
  lines.append("Group  : DFE")
  lines.append("  Logic Channel                  : %d" % reconfig_DFE_get_logical_channel_address(fpgaid))
  lines.append("  adaptation_engine_enable       : %d" % reconfig_DFE_get_adaptation_engine_enable(fpgaid))
  lines.append("  power_on                       : %d" % reconfig_DFE_get_power_on(fpgaid))
  lines.append("  tap_1                          : %d" % reconfig_DFE_get_tap_1(fpgaid))
  lines.append("  tap_2                          : %d" % reconfig_DFE_get_tap_2(fpgaid))
  lines.append("  tap_2_polarity                 : %d" % reconfig_DFE_get_tap_2_polarity(fpgaid))
  lines.append("  tap_3                          : %d" % reconfig_DFE_get_tap_3(fpgaid))
  lines.append("  tap_3_polarity                 : %d" % reconfig_DFE_get_tap_3_polarity(fpgaid))
  lines.append("  tap_4                          : %d" % reconfig_DFE_get_tap_4(fpgaid))
  lines.append("  tap_4_polarity                 : %d" % reconfig_DFE_get_tap_4_polarity(fpgaid))
  lines.append("  tap_5                          : %d" % reconfig_DFE_get_tap_5(fpgaid))
  lines.append("  tap_5_polarity                 : %d" % reconfig_DFE_get_tap_5_polarity(fpgaid))
  lines.append("Group  : EyeQ")
  lines.append("  Logic Channel                  : %d" % reconfig_EyeQ_get_logical_channel_address(fpgaid))
  lines.append("  1D_Eye                         : %d" % reconfig_EyeQ_get_1D_Eye(fpgaid))
  lines.append("  Bandwidth                      : %d" % reconfig_EyeQ_get_Bandwidth(fpgaid))
  lines.append("  Control                        : %d" % reconfig_EyeQ_get_Control(fpgaid))
  lines.append("  Horizontal_phase               : %d" % reconfig_EyeQ_get_Horizontal_phase(fpgaid))
  lines.append("  Vertical_height                : %d" % reconfig_EyeQ_get_Vertical_height(fpgaid))
  lines.append("Group  : PMA")
  lines.append("  Logic Channel                  : %d" % reconfig_PMA_get_logical_channel_address(fpgaid))
  lines.append("  Pre_emphasis_first_post_tap    : %d" % reconfig_PMA_get_Pre_emphasis_first_post_tap(fpgaid))
  lines.append("  Pre_emphasis_pre_tap           : %d" % tapformat(reconfig_PMA_get_Pre_emphasis_pre_tap(fpgaid)))
  lines.append("  Pre_emphasis_second_post_tap   : %d" % tapformat(reconfig_PMA_get_Pre_emphasis_second_post_tap(fpgaid)))
  lines.append("  RX_equalization_DC_gain        : %d" % reconfig_PMA_get_RX_equalization_DC_gain(fpgaid))
  lines.append("  VOD                            : %d" % reconfig_PMA_get_VOD(fpgaid))

  print "\n".join(lines)
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

