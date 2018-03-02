#!/bin/env python2
from pprint import pprint
import datetime
import os, sys
import subprocess
import time
debug=0
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




def set_Ctl_TxReset(fpgaid,chid,data,verbose=1): 
  """
SW reset - applies reset to transmit.  To reset the entire transceiver, assert both TxReset and RxReset on the same write event
  """
  global debug 
  if chid > 24: 
    chan=chid-24 
    cmd="rdwr -b %d global.g.cross_ch[%d].Ctl.TxReset 0x%X" % (fpgaid,chan,data) 
  else: 
    link=int(chid/2) 
    chan=chid%2 
    cmd="rdwr -b %d link[%d].ch[%d].serdes.Ctl.TxReset 0x%X" % (fpgaid,link,chan,data) 
  if (verbose & 2) == 2 : print cmd 
  exec_cmd(cmd) 
  if (verbose & 1) == 1 : print "="*30 
  if (verbose & 1) == 1 : print "set TxReset in Ctl on channel %d to %d" % (chid,data) 
  if (verbose & 1) == 1 : print "="*30 

def get_Ctl_TxReset(fpgaid,chid,verbose=1): 
  """
SW reset - applies reset to transmit.  To reset the entire transceiver, assert both TxReset and RxReset on the same write event
  """
  global debug 
  if chid > 24: 
    chan=chid-24 
    cmd="rdwr -b %d global.g.cross_ch[%d].Ctl.TxReset" % (fpgaid,chan) 
  else: 
    link=int(chid/2) 
    chan=chid%2 
    cmd="rdwr -b %d link[%d].ch[%d].serdes.Ctl.TxReset" % (fpgaid,link,chan) 
  if (verbose & 2) == 2 : print cmd 
  out=exec_cmd(cmd) 
  if out == "": 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get TxReset in Ctl on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return out 
  else: 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get TxReset in Ctl on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return int(out)

def set_Ctl_RxReset(fpgaid,chid,data,verbose=1): 
  """
SW reset - applies reset to receive.   To reset the entire transceiver, assert both TxReset and RxReset on the same write event
  """
  global debug 
  if chid > 24: 
    chan=chid-24 
    cmd="rdwr -b %d global.g.cross_ch[%d].Ctl.RxReset 0x%X" % (fpgaid,chan,data) 
  else: 
    link=int(chid/2) 
    chan=chid%2 
    cmd="rdwr -b %d link[%d].ch[%d].serdes.Ctl.RxReset 0x%X" % (fpgaid,link,chan,data) 
  if (verbose & 2) == 2 : print cmd 
  exec_cmd(cmd) 
  if (verbose & 1) == 1 : print "="*30 
  if (verbose & 1) == 1 : print "set RxReset in Ctl on channel %d to %d" % (chid,data) 
  if (verbose & 1) == 1 : print "="*30 

def get_Ctl_RxReset(fpgaid,chid,verbose=1): 
  """
SW reset - applies reset to receive.   To reset the entire transceiver, assert both TxReset and RxReset on the same write event
  """
  global debug 
  if chid > 24: 
    chan=chid-24 
    cmd="rdwr -b %d global.g.cross_ch[%d].Ctl.RxReset" % (fpgaid,chan) 
  else: 
    link=int(chid/2) 
    chan=chid%2 
    cmd="rdwr -b %d link[%d].ch[%d].serdes.Ctl.RxReset" % (fpgaid,link,chan) 
  if (verbose & 2) == 2 : print cmd 
  out=exec_cmd(cmd) 
  if out == "": 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get RxReset in Ctl on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return out 
  else: 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get RxReset in Ctl on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return int(out)

def set_Ctl_SerialLpbkEn(fpgaid,chid,data,verbose=1): 
  """
Enable near end serial loopback.  Connects transmit output to receive at FPGA.
  """
  global debug 
  if chid > 24: 
    chan=chid-24 
    cmd="rdwr -b %d global.g.cross_ch[%d].Ctl.SerialLpbkEn 0x%X" % (fpgaid,chan,data) 
  else: 
    link=int(chid/2) 
    chan=chid%2 
    cmd="rdwr -b %d link[%d].ch[%d].serdes.Ctl.SerialLpbkEn 0x%X" % (fpgaid,link,chan,data) 
  if (verbose & 2) == 2 : print cmd 
  exec_cmd(cmd) 
  if (verbose & 1) == 1 : print "="*30 
  if (verbose & 1) == 1 : print "set SerialLpbkEn in Ctl on channel %d to %d" % (chid,data) 
  if (verbose & 1) == 1 : print "="*30 

def get_Ctl_SerialLpbkEn(fpgaid,chid,verbose=1): 
  """
Enable near end serial loopback.  Connects transmit output to receive at FPGA.
  """
  global debug 
  if chid > 24: 
    chan=chid-24 
    cmd="rdwr -b %d global.g.cross_ch[%d].Ctl.SerialLpbkEn" % (fpgaid,chan) 
  else: 
    link=int(chid/2) 
    chan=chid%2 
    cmd="rdwr -b %d link[%d].ch[%d].serdes.Ctl.SerialLpbkEn" % (fpgaid,link,chan) 
  if (verbose & 2) == 2 : print cmd 
  out=exec_cmd(cmd) 
  if out == "": 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get SerialLpbkEn in Ctl on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return out 
  else: 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get SerialLpbkEn in Ctl on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return int(out)

def set_Ctl_CDRLockMode(fpgaid,chid,data,verbose=1): 
  """
CDR lock mode.  Controls the CDR PLL lock to reference / lock to data settings.
 00 = Automatic CDR lock mode.  CDR initially locks to reference clock, and then locks to data.  This should be the default setting
 X1 = Manual CDR  lock to data.  Lock time is dependent on transition density of incoming data and clock PPM difference.  When bit 0 is set, bit 1 is a don't care
 10 = Manual CDR lock to reference.  CDR tracks the receiver input reference clock.

  """
  global debug 
  if chid > 24: 
    chan=chid-24 
    cmd="rdwr -b %d global.g.cross_ch[%d].Ctl.CDRLockMode 0x%X" % (fpgaid,chan,data) 
  else: 
    link=int(chid/2) 
    chan=chid%2 
    cmd="rdwr -b %d link[%d].ch[%d].serdes.Ctl.CDRLockMode 0x%X" % (fpgaid,link,chan,data) 
  if (verbose & 2) == 2 : print cmd 
  exec_cmd(cmd) 
  if (verbose & 1) == 1 : print "="*30 
  if (verbose & 1) == 1 : print "set CDRLockMode in Ctl on channel %d to %d" % (chid,data) 
  if (verbose & 1) == 1 : print "="*30 

def get_Ctl_CDRLockMode(fpgaid,chid,verbose=1): 
  """
CDR lock mode.  Controls the CDR PLL lock to reference / lock to data settings.
 00 = Automatic CDR lock mode.  CDR initially locks to reference clock, and then locks to data.  This should be the default setting
 X1 = Manual CDR  lock to data.  Lock time is dependent on transition density of incoming data and clock PPM difference.  When bit 0 is set, bit 1 is a don't care
 10 = Manual CDR lock to reference.  CDR tracks the receiver input reference clock.

  """
  global debug 
  if chid > 24: 
    chan=chid-24 
    cmd="rdwr -b %d global.g.cross_ch[%d].Ctl.CDRLockMode" % (fpgaid,chan) 
  else: 
    link=int(chid/2) 
    chan=chid%2 
    cmd="rdwr -b %d link[%d].ch[%d].serdes.Ctl.CDRLockMode" % (fpgaid,link,chan) 
  if (verbose & 2) == 2 : print cmd 
  out=exec_cmd(cmd) 
  if out == "": 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get CDRLockMode in Ctl on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return out 
  else: 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get CDRLockMode in Ctl on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return int(out)

def set_Ctl_TxMuxSel(fpgaid,chid,data,verbose=1): 
  """
Transmit mux select between PRBS and crossbar.  0=crossbar, 1=PRBS.  Transmit is always enabled.
  """
  global debug 
  if chid > 24: 
    chan=chid-24 
    cmd="rdwr -b %d global.g.cross_ch[%d].Ctl.TxMuxSel 0x%X" % (fpgaid,chan,data) 
  else: 
    link=int(chid/2) 
    chan=chid%2 
    cmd="rdwr -b %d link[%d].ch[%d].serdes.Ctl.TxMuxSel 0x%X" % (fpgaid,link,chan,data) 
  if (verbose & 2) == 2 : print cmd 
  exec_cmd(cmd) 
  if (verbose & 1) == 1 : print "="*30 
  if (verbose & 1) == 1 : print "set TxMuxSel in Ctl on channel %d to %d" % (chid,data) 
  if (verbose & 1) == 1 : print "="*30 

def get_Ctl_TxMuxSel(fpgaid,chid,verbose=1): 
  """
Transmit mux select between PRBS and crossbar.  0=crossbar, 1=PRBS.  Transmit is always enabled.
  """
  global debug 
  if chid > 24: 
    chan=chid-24 
    cmd="rdwr -b %d global.g.cross_ch[%d].Ctl.TxMuxSel" % (fpgaid,chan) 
  else: 
    link=int(chid/2) 
    chan=chid%2 
    cmd="rdwr -b %d link[%d].ch[%d].serdes.Ctl.TxMuxSel" % (fpgaid,link,chan) 
  if (verbose & 2) == 2 : print cmd 
  out=exec_cmd(cmd) 
  if out == "": 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get TxMuxSel in Ctl on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return out 
  else: 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get TxMuxSel in Ctl on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return int(out)

def set_Ctl_EyeHClear(fpgaid,chid,data,verbose=1): 
  """
Clear horizontal eye monitor (this feature is still TBD)
  """
  global debug 
  if chid > 24: 
    chan=chid-24 
    cmd="rdwr -b %d global.g.cross_ch[%d].Ctl.EyeHClear 0x%X" % (fpgaid,chan,data) 
  else: 
    link=int(chid/2) 
    chan=chid%2 
    cmd="rdwr -b %d link[%d].ch[%d].serdes.Ctl.EyeHClear 0x%X" % (fpgaid,link,chan,data) 
  if (verbose & 2) == 2 : print cmd 
  exec_cmd(cmd) 
  if (verbose & 1) == 1 : print "="*30 
  if (verbose & 1) == 1 : print "set EyeHClear in Ctl on channel %d to %d" % (chid,data) 
  if (verbose & 1) == 1 : print "="*30 

def get_Ctl_EyeHClear(fpgaid,chid,verbose=1): 
  """
Clear horizontal eye monitor (this feature is still TBD)
  """
  global debug 
  if chid > 24: 
    chan=chid-24 
    cmd="rdwr -b %d global.g.cross_ch[%d].Ctl.EyeHClear" % (fpgaid,chan) 
  else: 
    link=int(chid/2) 
    chan=chid%2 
    cmd="rdwr -b %d link[%d].ch[%d].serdes.Ctl.EyeHClear" % (fpgaid,link,chan) 
  if (verbose & 2) == 2 : print cmd 
  out=exec_cmd(cmd) 
  if out == "": 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get EyeHClear in Ctl on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return out 
  else: 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get EyeHClear in Ctl on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return int(out)

def set_Ctl_EyeVClear(fpgaid,chid,data,verbose=1): 
  """
Clear vertical eye monitor (this feature is still TBD)
  """
  global debug 
  if chid > 24: 
    chan=chid-24 
    cmd="rdwr -b %d global.g.cross_ch[%d].Ctl.EyeVClear 0x%X" % (fpgaid,chan,data) 
  else: 
    link=int(chid/2) 
    chan=chid%2 
    cmd="rdwr -b %d link[%d].ch[%d].serdes.Ctl.EyeVClear 0x%X" % (fpgaid,link,chan,data) 
  if (verbose & 2) == 2 : print cmd 
  exec_cmd(cmd) 
  if (verbose & 1) == 1 : print "="*30 
  if (verbose & 1) == 1 : print "set EyeVClear in Ctl on channel %d to %d" % (chid,data) 
  if (verbose & 1) == 1 : print "="*30 

def get_Ctl_EyeVClear(fpgaid,chid,verbose=1): 
  """
Clear vertical eye monitor (this feature is still TBD)
  """
  global debug 
  if chid > 24: 
    chan=chid-24 
    cmd="rdwr -b %d global.g.cross_ch[%d].Ctl.EyeVClear" % (fpgaid,chan) 
  else: 
    link=int(chid/2) 
    chan=chid%2 
    cmd="rdwr -b %d link[%d].ch[%d].serdes.Ctl.EyeVClear" % (fpgaid,link,chan) 
  if (verbose & 2) == 2 : print cmd 
  out=exec_cmd(cmd) 
  if out == "": 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get EyeVClear in Ctl on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return out 
  else: 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get EyeVClear in Ctl on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return int(out)

def set_Ctl_TxInvert(fpgaid,chid,data,verbose=1): 
  """
Invert polarity of TX serial line
  """
  global debug 
  if chid > 24: 
    chan=chid-24 
    cmd="rdwr -b %d global.g.cross_ch[%d].Ctl.TxInvert 0x%X" % (fpgaid,chan,data) 
  else: 
    link=int(chid/2) 
    chan=chid%2 
    cmd="rdwr -b %d link[%d].ch[%d].serdes.Ctl.TxInvert 0x%X" % (fpgaid,link,chan,data) 
  if (verbose & 2) == 2 : print cmd 
  exec_cmd(cmd) 
  if (verbose & 1) == 1 : print "="*30 
  if (verbose & 1) == 1 : print "set TxInvert in Ctl on channel %d to %d" % (chid,data) 
  if (verbose & 1) == 1 : print "="*30 

def get_Ctl_TxInvert(fpgaid,chid,verbose=1): 
  """
Invert polarity of TX serial line
  """
  global debug 
  if chid > 24: 
    chan=chid-24 
    cmd="rdwr -b %d global.g.cross_ch[%d].Ctl.TxInvert" % (fpgaid,chan) 
  else: 
    link=int(chid/2) 
    chan=chid%2 
    cmd="rdwr -b %d link[%d].ch[%d].serdes.Ctl.TxInvert" % (fpgaid,link,chan) 
  if (verbose & 2) == 2 : print cmd 
  out=exec_cmd(cmd) 
  if out == "": 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get TxInvert in Ctl on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return out 
  else: 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get TxInvert in Ctl on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return int(out)

def set_Ctl_RxInvert(fpgaid,chid,data,verbose=1): 
  """
Invert polarity of RX serial line
  """
  global debug 
  if chid > 24: 
    chan=chid-24 
    cmd="rdwr -b %d global.g.cross_ch[%d].Ctl.RxInvert 0x%X" % (fpgaid,chan,data) 
  else: 
    link=int(chid/2) 
    chan=chid%2 
    cmd="rdwr -b %d link[%d].ch[%d].serdes.Ctl.RxInvert 0x%X" % (fpgaid,link,chan,data) 
  if (verbose & 2) == 2 : print cmd 
  exec_cmd(cmd) 
  if (verbose & 1) == 1 : print "="*30 
  if (verbose & 1) == 1 : print "set RxInvert in Ctl on channel %d to %d" % (chid,data) 
  if (verbose & 1) == 1 : print "="*30 

def get_Ctl_RxInvert(fpgaid,chid,verbose=1): 
  """
Invert polarity of RX serial line
  """
  global debug 
  if chid > 24: 
    chan=chid-24 
    cmd="rdwr -b %d global.g.cross_ch[%d].Ctl.RxInvert" % (fpgaid,chan) 
  else: 
    link=int(chid/2) 
    chan=chid%2 
    cmd="rdwr -b %d link[%d].ch[%d].serdes.Ctl.RxInvert" % (fpgaid,link,chan) 
  if (verbose & 2) == 2 : print cmd 
  out=exec_cmd(cmd) 
  if out == "": 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get RxInvert in Ctl on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return out 
  else: 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get RxInvert in Ctl on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return int(out)

def get_Status_PLLPwrDn(fpgaid,chid,verbose=1): 
  """
Current value of pll_powerdown (from reset controller)
  """
  global debug 
  if chid > 24: 
    chan=chid-24 
    cmd="rdwr -b %d global.g.cross_ch[%d].Status.PLLPwrDn" % (fpgaid,chan) 
  else: 
    link=int(chid/2) 
    chan=chid%2 
    cmd="rdwr -b %d link[%d].ch[%d].serdes.Status.PLLPwrDn" % (fpgaid,link,chan) 
  if (verbose & 2) == 2 : print cmd 
  out=exec_cmd(cmd) 
  if out == "": 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get PLLPwrDn in Status on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return out 
  else: 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get PLLPwrDn in Status on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return int(out)

def get_Status_TxDigitalRst(fpgaid,chid,verbose=1): 
  """
Current value of tx_digitalreset
  """
  global debug 
  if chid > 24: 
    chan=chid-24 
    cmd="rdwr -b %d global.g.cross_ch[%d].Status.TxDigitalRst" % (fpgaid,chan) 
  else: 
    link=int(chid/2) 
    chan=chid%2 
    cmd="rdwr -b %d link[%d].ch[%d].serdes.Status.TxDigitalRst" % (fpgaid,link,chan) 
  if (verbose & 2) == 2 : print cmd 
  out=exec_cmd(cmd) 
  if out == "": 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get TxDigitalRst in Status on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return out 
  else: 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get TxDigitalRst in Status on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return int(out)

def get_Status_TxAnalogRst(fpgaid,chid,verbose=1): 
  """
Current value of tx_analogreset
  """
  global debug 
  if chid > 24: 
    chan=chid-24 
    cmd="rdwr -b %d global.g.cross_ch[%d].Status.TxAnalogRst" % (fpgaid,chan) 
  else: 
    link=int(chid/2) 
    chan=chid%2 
    cmd="rdwr -b %d link[%d].ch[%d].serdes.Status.TxAnalogRst" % (fpgaid,link,chan) 
  if (verbose & 2) == 2 : print cmd 
  out=exec_cmd(cmd) 
  if out == "": 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get TxAnalogRst in Status on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return out 
  else: 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get TxAnalogRst in Status on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return int(out)

def get_Status_RxDigitalRst(fpgaid,chid,verbose=1): 
  """
Current value of rx_digitalreset
  """
  global debug 
  if chid > 24: 
    chan=chid-24 
    cmd="rdwr -b %d global.g.cross_ch[%d].Status.RxDigitalRst" % (fpgaid,chan) 
  else: 
    link=int(chid/2) 
    chan=chid%2 
    cmd="rdwr -b %d link[%d].ch[%d].serdes.Status.RxDigitalRst" % (fpgaid,link,chan) 
  if (verbose & 2) == 2 : print cmd 
  out=exec_cmd(cmd) 
  if out == "": 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get RxDigitalRst in Status on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return out 
  else: 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get RxDigitalRst in Status on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return int(out)

def get_Status_RxAnalogRst(fpgaid,chid,verbose=1): 
  """
Current value of rx_analogreset
  """
  global debug 
  if chid > 24: 
    chan=chid-24 
    cmd="rdwr -b %d global.g.cross_ch[%d].Status.RxAnalogRst" % (fpgaid,chan) 
  else: 
    link=int(chid/2) 
    chan=chid%2 
    cmd="rdwr -b %d link[%d].ch[%d].serdes.Status.RxAnalogRst" % (fpgaid,link,chan) 
  if (verbose & 2) == 2 : print cmd 
  out=exec_cmd(cmd) 
  if out == "": 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get RxAnalogRst in Status on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return out 
  else: 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get RxAnalogRst in Status on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return int(out)

def get_Status_RxLockedToRef(fpgaid,chid,verbose=1): 
  """
Current value of rx_is_lockedtoref
  """
  global debug 
  if chid > 24: 
    chan=chid-24 
    cmd="rdwr -b %d global.g.cross_ch[%d].Status.RxLockedToRef" % (fpgaid,chan) 
  else: 
    link=int(chid/2) 
    chan=chid%2 
    cmd="rdwr -b %d link[%d].ch[%d].serdes.Status.RxLockedToRef" % (fpgaid,link,chan) 
  if (verbose & 2) == 2 : print cmd 
  out=exec_cmd(cmd) 
  if out == "": 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get RxLockedToRef in Status on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return out 
  else: 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get RxLockedToRef in Status on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return int(out)

def get_Status_RxLockedToData(fpgaid,chid,verbose=1): 
  """
Current value of rx_is_lockedtodata
  """
  global debug 
  if chid > 24: 
    chan=chid-24 
    cmd="rdwr -b %d global.g.cross_ch[%d].Status.RxLockedToData" % (fpgaid,chan) 
  else: 
    link=int(chid/2) 
    chan=chid%2 
    cmd="rdwr -b %d link[%d].ch[%d].serdes.Status.RxLockedToData" % (fpgaid,link,chan) 
  if (verbose & 2) == 2 : print cmd 
  out=exec_cmd(cmd) 
  if out == "": 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get RxLockedToData in Status on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return out 
  else: 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get RxLockedToData in Status on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return int(out)

def get_Status_TxCalBusy(fpgaid,chid,verbose=1): 
  """
Current value of tx_cal_busy, transmit calibration is busy
  """
  global debug 
  if chid > 24: 
    chan=chid-24 
    cmd="rdwr -b %d global.g.cross_ch[%d].Status.TxCalBusy" % (fpgaid,chan) 
  else: 
    link=int(chid/2) 
    chan=chid%2 
    cmd="rdwr -b %d link[%d].ch[%d].serdes.Status.TxCalBusy" % (fpgaid,link,chan) 
  if (verbose & 2) == 2 : print cmd 
  out=exec_cmd(cmd) 
  if out == "": 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get TxCalBusy in Status on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return out 
  else: 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get TxCalBusy in Status on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return int(out)

def get_Status_RxCalBusy(fpgaid,chid,verbose=1): 
  """
Current value of rx_cal_busy, receive calibration is busy
  """
  global debug 
  if chid > 24: 
    chan=chid-24 
    cmd="rdwr -b %d global.g.cross_ch[%d].Status.RxCalBusy" % (fpgaid,chan) 
  else: 
    link=int(chid/2) 
    chan=chid%2 
    cmd="rdwr -b %d link[%d].ch[%d].serdes.Status.RxCalBusy" % (fpgaid,link,chan) 
  if (verbose & 2) == 2 : print cmd 
  out=exec_cmd(cmd) 
  if out == "": 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get RxCalBusy in Status on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return out 
  else: 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get RxCalBusy in Status on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return int(out)

def get_Status_PLLLocked(fpgaid,chid,verbose=1): 
  """
Current value of pll_locked (from ATX PLL)
  """
  global debug 
  if chid > 24: 
    chan=chid-24 
    cmd="rdwr -b %d global.g.cross_ch[%d].Status.PLLLocked" % (fpgaid,chan) 
  else: 
    link=int(chid/2) 
    chan=chid%2 
    cmd="rdwr -b %d link[%d].ch[%d].serdes.Status.PLLLocked" % (fpgaid,link,chan) 
  if (verbose & 2) == 2 : print cmd 
  out=exec_cmd(cmd) 
  if out == "": 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get PLLLocked in Status on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return out 
  else: 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get PLLLocked in Status on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return int(out)

def get_Status_RxReady(fpgaid,chid,verbose=1): 
  """
Current value of rx_ready (from reset controller)
  """
  global debug 
  if chid > 24: 
    chan=chid-24 
    cmd="rdwr -b %d global.g.cross_ch[%d].Status.RxReady" % (fpgaid,chan) 
  else: 
    link=int(chid/2) 
    chan=chid%2 
    cmd="rdwr -b %d link[%d].ch[%d].serdes.Status.RxReady" % (fpgaid,link,chan) 
  if (verbose & 2) == 2 : print cmd 
  out=exec_cmd(cmd) 
  if out == "": 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get RxReady in Status on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return out 
  else: 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get RxReady in Status on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return int(out)

def get_Status_TxReady(fpgaid,chid,verbose=1): 
  """
Current value of tx_ready (from reset controller)
  """
  global debug 
  if chid > 24: 
    chan=chid-24 
    cmd="rdwr -b %d global.g.cross_ch[%d].Status.TxReady" % (fpgaid,chan) 
  else: 
    link=int(chid/2) 
    chan=chid%2 
    cmd="rdwr -b %d link[%d].ch[%d].serdes.Status.TxReady" % (fpgaid,link,chan) 
  if (verbose & 2) == 2 : print cmd 
  out=exec_cmd(cmd) 
  if out == "": 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get TxReady in Status on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return out 
  else: 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get TxReady in Status on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return int(out)

def get_Status_LinkSpeed(fpgaid,chid,verbose=1): 
  """
Current value of link speed setting from link engine. 000 = 1G, 001=2G, 010=4G, 011=8G.  Other encodings are reserved.  same rate.  
  """
  global debug 
  if chid > 24: 
    chan=chid-24 
    cmd="rdwr -b %d global.g.cross_ch[%d].Status.LinkSpeed" % (fpgaid,chan) 
  else: 
    link=int(chid/2) 
    chan=chid%2 
    cmd="rdwr -b %d link[%d].ch[%d].serdes.Status.LinkSpeed" % (fpgaid,link,chan) 
  if (verbose & 2) == 2 : print cmd 
  out=exec_cmd(cmd) 
  if out == "": 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get LinkSpeed in Status on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return out 
  else: 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get LinkSpeed in Status on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return int(out)

def get_TxData_RxData(fpgaid,chid,verbose=1): 
  """
Last transmitted 40b parallel data value
  """
  global debug 
  if chid > 24: 
    chan=chid-24 
    cmd="rdwr -b %d global.g.cross_ch[%d].TxData.RxData" % (fpgaid,chan) 
  else: 
    link=int(chid/2) 
    chan=chid%2 
    cmd="rdwr -b %d link[%d].ch[%d].serdes.TxData.RxData" % (fpgaid,link,chan) 
  if (verbose & 2) == 2 : print cmd 
  out=exec_cmd(cmd) 
  if out == "": 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get RxData in TxData on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return out 
  else: 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get RxData in TxData on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return int(out)

def get_TxData_RxData(fpgaid,chid,verbose=1): 
  """
Last transmitted 40b parallel data value
  """
  global debug 
  if chid > 24: 
    chan=chid-24 
    cmd="rdwr -b %d global.g.cross_ch[%d].TxData.RxData" % (fpgaid,chan) 
  else: 
    link=int(chid/2) 
    chan=chid%2 
    cmd="rdwr -b %d link[%d].ch[%d].serdes.TxData.RxData" % (fpgaid,link,chan) 
  if (verbose & 2) == 2 : print cmd 
  out=exec_cmd(cmd) 
  if out == "": 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get RxData in TxData on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return out 
  else: 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get RxData in TxData on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return int(out)

def set_PrbsCtl_PrbsSel(fpgaid,chid,data,verbose=1): 
  """
PRBS control register: prbs mode select.  00 = off, 01 = prbs7, 10=prbs31. other encodings reserved. 
  """
  global debug 
  if chid > 24: 
    chan=chid-24 
    cmd="rdwr -b %d global.g.cross_ch[%d].PrbsCtl.PrbsSel 0x%X" % (fpgaid,chan,data) 
  else: 
    link=int(chid/2) 
    chan=chid%2 
    cmd="rdwr -b %d link[%d].ch[%d].serdes.PrbsCtl.PrbsSel 0x%X" % (fpgaid,link,chan,data) 
  if (verbose & 2) == 2 : print cmd 
  exec_cmd(cmd) 
  if (verbose & 1) == 1 : print "="*30 
  if (verbose & 1) == 1 : print "set PrbsSel in PrbsCtl on channel %d to %d" % (chid,data) 
  if (verbose & 1) == 1 : print "="*30 

def get_PrbsCtl_PrbsSel(fpgaid,chid,verbose=1): 
  """
PRBS control register: prbs mode select.  00 = off, 01 = prbs7, 10=prbs31. other encodings reserved. 
  """
  global debug 
  if chid > 24: 
    chan=chid-24 
    cmd="rdwr -b %d global.g.cross_ch[%d].PrbsCtl.PrbsSel" % (fpgaid,chan) 
  else: 
    link=int(chid/2) 
    chan=chid%2 
    cmd="rdwr -b %d link[%d].ch[%d].serdes.PrbsCtl.PrbsSel" % (fpgaid,link,chan) 
  if (verbose & 2) == 2 : print cmd 
  out=exec_cmd(cmd) 
  if out == "": 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get PrbsSel in PrbsCtl on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return out 
  else: 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get PrbsSel in PrbsCtl on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return int(out)

def set_PrbsCtl_InjErr(fpgaid,chid,data,verbose=1): 
  """
PRBS control register: inject a random bit error into the next transmitted PRBS primitive
  """
  global debug 
  if chid > 24: 
    chan=chid-24 
    cmd="rdwr -b %d global.g.cross_ch[%d].PrbsCtl.InjErr 0x%X" % (fpgaid,chan,data) 
  else: 
    link=int(chid/2) 
    chan=chid%2 
    cmd="rdwr -b %d link[%d].ch[%d].serdes.PrbsCtl.InjErr 0x%X" % (fpgaid,link,chan,data) 
  if (verbose & 2) == 2 : print cmd 
  exec_cmd(cmd) 
  if (verbose & 1) == 1 : print "="*30 
  if (verbose & 1) == 1 : print "set InjErr in PrbsCtl on channel %d to %d" % (chid,data) 
  if (verbose & 1) == 1 : print "="*30 

def get_PrbsCtl_InjErr(fpgaid,chid,verbose=1): 
  """
PRBS control register: inject a random bit error into the next transmitted PRBS primitive
  """
  global debug 
  if chid > 24: 
    chan=chid-24 
    cmd="rdwr -b %d global.g.cross_ch[%d].PrbsCtl.InjErr" % (fpgaid,chan) 
  else: 
    link=int(chid/2) 
    chan=chid%2 
    cmd="rdwr -b %d link[%d].ch[%d].serdes.PrbsCtl.InjErr" % (fpgaid,link,chan) 
  if (verbose & 2) == 2 : print cmd 
  out=exec_cmd(cmd) 
  if out == "": 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get InjErr in PrbsCtl on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return out 
  else: 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get InjErr in PrbsCtl on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return int(out)

def set_PrbsCtl_ErrCntClr(fpgaid,chid,data,verbose=1): 
  """
PRBS control register: clear PRBS error count register
  """
  global debug 
  if chid > 24: 
    chan=chid-24 
    cmd="rdwr -b %d global.g.cross_ch[%d].PrbsCtl.ErrCntClr 0x%X" % (fpgaid,chan,data) 
  else: 
    link=int(chid/2) 
    chan=chid%2 
    cmd="rdwr -b %d link[%d].ch[%d].serdes.PrbsCtl.ErrCntClr 0x%X" % (fpgaid,link,chan,data) 
  if (verbose & 2) == 2 : print cmd 
  exec_cmd(cmd) 
  if (verbose & 1) == 1 : print "="*30 
  if (verbose & 1) == 1 : print "set ErrCntClr in PrbsCtl on channel %d to %d" % (chid,data) 
  if (verbose & 1) == 1 : print "="*30 

def get_PrbsCtl_ErrCntClr(fpgaid,chid,verbose=1): 
  """
PRBS control register: clear PRBS error count register
  """
  global debug 
  if chid > 24: 
    chan=chid-24 
    cmd="rdwr -b %d global.g.cross_ch[%d].PrbsCtl.ErrCntClr" % (fpgaid,chan) 
  else: 
    link=int(chid/2) 
    chan=chid%2 
    cmd="rdwr -b %d link[%d].ch[%d].serdes.PrbsCtl.ErrCntClr" % (fpgaid,link,chan) 
  if (verbose & 2) == 2 : print cmd 
  out=exec_cmd(cmd) 
  if out == "": 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get ErrCntClr in PrbsCtl on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return out 
  else: 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get ErrCntClr in PrbsCtl on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return int(out)

def set_PrbsCtl_RxCntClr(fpgaid,chid,data,verbose=1): 
  """
PRBS control register: clear PRBS receive count register
  """
  global debug 
  if chid > 24: 
    chan=chid-24 
    cmd="rdwr -b %d global.g.cross_ch[%d].PrbsCtl.RxCntClr 0x%X" % (fpgaid,chan,data) 
  else: 
    link=int(chid/2) 
    chan=chid%2 
    cmd="rdwr -b %d link[%d].ch[%d].serdes.PrbsCtl.RxCntClr 0x%X" % (fpgaid,link,chan,data) 
  if (verbose & 2) == 2 : print cmd 
  exec_cmd(cmd) 
  if (verbose & 1) == 1 : print "="*30 
  if (verbose & 1) == 1 : print "set RxCntClr in PrbsCtl on channel %d to %d" % (chid,data) 
  if (verbose & 1) == 1 : print "="*30 

def get_PrbsCtl_RxCntClr(fpgaid,chid,verbose=1): 
  """
PRBS control register: clear PRBS receive count register
  """
  global debug 
  if chid > 24: 
    chan=chid-24 
    cmd="rdwr -b %d global.g.cross_ch[%d].PrbsCtl.RxCntClr" % (fpgaid,chan) 
  else: 
    link=int(chid/2) 
    chan=chid%2 
    cmd="rdwr -b %d link[%d].ch[%d].serdes.PrbsCtl.RxCntClr" % (fpgaid,link,chan) 
  if (verbose & 2) == 2 : print cmd 
  out=exec_cmd(cmd) 
  if out == "": 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get RxCntClr in PrbsCtl on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return out 
  else: 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get RxCntClr in PrbsCtl on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return int(out)

def set_PrbsCtl_NotLockedCntClr(fpgaid,chid,data,verbose=1): 
  """
PRBS control register: clear PRBS not locked count register
  """
  global debug 
  if chid > 24: 
    chan=chid-24 
    cmd="rdwr -b %d global.g.cross_ch[%d].PrbsCtl.NotLockedCntClr 0x%X" % (fpgaid,chan,data) 
  else: 
    link=int(chid/2) 
    chan=chid%2 
    cmd="rdwr -b %d link[%d].ch[%d].serdes.PrbsCtl.NotLockedCntClr 0x%X" % (fpgaid,link,chan,data) 
  if (verbose & 2) == 2 : print cmd 
  exec_cmd(cmd) 
  if (verbose & 1) == 1 : print "="*30 
  if (verbose & 1) == 1 : print "set NotLockedCntClr in PrbsCtl on channel %d to %d" % (chid,data) 
  if (verbose & 1) == 1 : print "="*30 

def get_PrbsCtl_NotLockedCntClr(fpgaid,chid,verbose=1): 
  """
PRBS control register: clear PRBS not locked count register
  """
  global debug 
  if chid > 24: 
    chan=chid-24 
    cmd="rdwr -b %d global.g.cross_ch[%d].PrbsCtl.NotLockedCntClr" % (fpgaid,chan) 
  else: 
    link=int(chid/2) 
    chan=chid%2 
    cmd="rdwr -b %d link[%d].ch[%d].serdes.PrbsCtl.NotLockedCntClr" % (fpgaid,link,chan) 
  if (verbose & 2) == 2 : print cmd 
  out=exec_cmd(cmd) 
  if out == "": 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get NotLockedCntClr in PrbsCtl on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return out 
  else: 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get NotLockedCntClr in PrbsCtl on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return int(out)

def get_PrbsErrCnt(fpgaid,chid,verbose=1): 
  """
Count of PRBS errors.  Along with PrbsRxCnt register, can be used to calculate bit error rates
  """
  global debug 
  if chid > 24: 
    chan=chid-24 
    cmd="rdwr -b %d global.g.cross_ch[%d].PrbsErrCnt" % (fpgaid,chan) 
  else: 
    link=int(chid/2) 
    chan=chid%2 
    cmd="rdwr -b %d link[%d].ch[%d].serdes.PrbsErrCnt" % (fpgaid,link,chan) 
  if (verbose & 2) == 2 : print cmd 
  out=exec_cmd(cmd) 
  if out == "": 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get PrbsErrCnt on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return out 
  else: 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get PrbsErrCnt on channel %d: %d" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return int(out)

def get_PrbsRxCnt(fpgaid,chid,verbose=1): 
  """
Count of received PRBS bits for use in calculating bit error rate.  This counter only starts incrementing after the prbs checker locks onto the incoming stream.   
  """
  global debug 
  if chid > 24: 
    chan=chid-24 
    cmd="rdwr -b %d global.g.cross_ch[%d].PrbsRxCnt" % (fpgaid,chan) 
  else: 
    link=int(chid/2) 
    chan=chid%2 
    cmd="rdwr -b %d link[%d].ch[%d].serdes.PrbsRxCnt" % (fpgaid,link,chan) 
  if (verbose & 2) == 2 : print cmd 
  out=exec_cmd(cmd) 
  if out == "": 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get PrbsRxCnt on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return out 
  else: 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get PrbsRxCnt on channel %d: %d" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return int(out)

def get_PrbsNotLockedCnt(fpgaid,chid,verbose=1): 
  """
Count of cycles when PRBS is enabled, and the prbs checker is not locked.  
  """
  global debug 
  if chid > 24: 
    chan=chid-24 
    cmd="rdwr -b %d global.g.cross_ch[%d].PrbsNotLockedCnt" % (fpgaid,chan) 
  else: 
    link=int(chid/2) 
    chan=chid%2 
    cmd="rdwr -b %d link[%d].ch[%d].serdes.PrbsNotLockedCnt" % (fpgaid,link,chan) 
  if (verbose & 2) == 2 : print cmd 
  out=exec_cmd(cmd) 
  if out == "": 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get PrbsNotLockedCnt on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return out 
  else: 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get PrbsNotLockedCnt on channel %d: %d" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return int(out)

def get_PrbsLock(fpgaid,chid,verbose=1): 
  """
Current value of PRBS lock signal.  
  """
  global debug 
  if chid > 24: 
    chan=chid-24 
    cmd="rdwr -b %d global.g.cross_ch[%d].PrbsLock" % (fpgaid,chan) 
  else: 
    link=int(chid/2) 
    chan=chid%2 
    cmd="rdwr -b %d link[%d].ch[%d].serdes.PrbsLock" % (fpgaid,link,chan) 
  if (verbose & 2) == 2 : print cmd 
  out=exec_cmd(cmd) 
  if out == "": 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get PrbsLock on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return out 
  else: 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get PrbsLock on channel %d: %d" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return int(out)

def set_scratch(fpgaid,chid,data,verbose=1): 
  """
scratch register
  """
  global debug 
  if chid > 24: 
    chan=chid-24 
    cmd="rdwr -b %d global.g.cross_ch[%d].scratch 0x%X" % (fpgaid,chan,data) 
  else: 
    link=int(chid/2) 
    chan=chid%2 
    cmd="rdwr -b %d link[%d].ch[%d].serdes.scratch 0x%X" % (fpgaid,link,chan,data) 
  if (verbose & 2) == 2 : print cmd 
  exec_cmd(cmd) 
  if (verbose & 1) == 1 : print "="*30 
  if (verbose & 1) == 1 : print "set scratch on channel %d" % (chid,data) 
  if (verbose & 1) == 1 : print "="*30 

def get_scratch(fpgaid,chid,verbose=1): 
  """
scratch register
  """
  global debug 
  if chid > 24: 
    chan=chid-24 
    cmd="rdwr -b %d global.g.cross_ch[%d].scratch" % (fpgaid,chan) 
  else: 
    link=int(chid/2) 
    chan=chid%2 
    cmd="rdwr -b %d link[%d].ch[%d].serdes.scratch" % (fpgaid,link,chan) 
  if (verbose & 2) == 2 : print cmd 
  out=exec_cmd(cmd) 
  if out == "": 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get scratch on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return out 
  else: 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get scratch on channel %d: %d" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return int(out)

def get_PrbsInjErrCnt(fpgaid,chid,verbose=1): 
  """
Count of PRBS inject error requests
  """
  global debug 
  if chid > 24: 
    chan=chid-24 
    cmd="rdwr -b %d global.g.cross_ch[%d].PrbsInjErrCnt" % (fpgaid,chan) 
  else: 
    link=int(chid/2) 
    chan=chid%2 
    cmd="rdwr -b %d link[%d].ch[%d].serdes.PrbsInjErrCnt" % (fpgaid,link,chan) 
  if (verbose & 2) == 2 : print cmd 
  out=exec_cmd(cmd) 
  if out == "": 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get PrbsInjErrCnt on channel %d: %s" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return out 
  else: 
    if (verbose & 1) == 1 : print "="*30 
    if (verbose & 1) == 1 : print "get PrbsInjErrCnt on channel %d: %d" % (chid,out) 
    if (verbose & 1) == 1 : print "="*30 
    return int(out)

