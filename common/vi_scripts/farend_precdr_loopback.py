#!/usr/bin/env python2
import os, sys
import subprocess
import time

def exec_cmd (cmd):
  proc = subprocess.Popen(cmd, shell=True, stdout = subprocess.PIPE, stderr = subprocess.PIPE )
  out,error=proc.communicate()
  print out
  print error
  if proc.returncode !=0:
    print "ERROR: read/write error %s %s" % (out,error)

def enable_direct_access (fpgaid):
  # set direct access mode
  cmd = "rdwr -b %d %s 0x%X" % (fpgaid, "global.g.fpga.ReconfigCtrl.Direct", 1)
  print cmd
  exec_cmd(cmd)
  time.sleep(1.0)

def disable_direct_access (fpgaid):
  # clear direct access mode
  cmd = "rdwr -b %d %s 0x%X" % (fpgaid, "global.g.fpga.ReconfigCtrl.Direct", 0)
  print cmd
  exec_cmd(cmd)
  time.sleep(1.0)

def enable_postcdr_loopback (fpgaid, chid ) :
  

  # set direct access mode
  cmd = "rdwr -b %d %s 0x%X" % (fpgaid, "global.g.fpga.ReconfigCtrl.Direct", 1)
  print cmd
  exec_cmd(cmd)
  time.sleep(1.0)

  # select logical channel
  cmd = "rdwr -b %d %s 0x%X" % (fpgaid, "global.g.rcfg.PMA_LogicalChanNo ", chid)
  print cmd
  exec_cmd(cmd)
  time.sleep(1.0)
  
  # set address offset
  cmd = "rdwr -b %d %s 0x%X" % (fpgaid, "global.g.rcfg.PMA_Offset ", 0x21)
  print cmd
  exec_cmd(cmd)
  time.sleep(1.0)
  
  # set data channel
  cmd = "rdwr -b %d %s 0x%X" % (fpgaid, "global.g.rcfg.PMA_Data ", 1)
  print cmd
  exec_cmd(cmd)
  time.sleep(1.0)
  
  # enable indirect write
  cmd = "rdwr -b %d %s 0x%X" % (fpgaid, "global.g.rcfg.PMA_ControlStatus.PMA_Write ", 1)
  print cmd
  exec_cmd(cmd)
  time.sleep(1.0)
  
  # clear direct access mode
  cmd = "rdwr -b %d %s 0x%X" % (fpgaid, "global.g.fpga.ReconfigCtrl.Direct", 0)
  print cmd
  exec_cmd(cmd)
  time.sleep(1.0)


def disable_postcdr_loopback (fpgaid, chid ) :
  

  # set direct access mode
  cmd = "rdwr -b %d %s 0x%X" % (fpgaid, "global.g.fpga.ReconfigCtrl.Direct", 1)
  print cmd
  exec_cmd(cmd)
  time.sleep(1.0)

  # select logical channel
  cmd = "rdwr -b %d %s 0x%X" % (fpgaid, "global.g.rcfg.PMA_LogicalChanNo ", chid)
  print cmd
  exec_cmd(cmd)
  time.sleep(1.0)
  
  # set address offset
  cmd = "rdwr -b %d %s 0x%X" % (fpgaid, "global.g.rcfg.PMA_Offset ", 0x21)
  print cmd
  exec_cmd(cmd)
  time.sleep(1.0)
  
  # set data channel
  cmd = "rdwr -b %d %s 0x%X" % (fpgaid, "global.g.rcfg.PMA_Data ", 0)
  print cmd
  exec_cmd(cmd)
  time.sleep(1.0)
  
  # enable indirect write
  cmd = "rdwr -b %d %s 0x%X" % (fpgaid, "global.g.rcfg.PMA_ControlStatus.PMA_Write ", 1)
  print cmd
  exec_cmd(cmd)
  time.sleep(1.0)
  
  # clear direct access mode
  cmd = "rdwr -b %d %s 0x%X" % (fpgaid, "global.g.fpga.ReconfigCtrl.Direct", 0)
  print cmd
  exec_cmd(cmd)
  time.sleep(1.0)

def enable_precdr_loopback (fpgaid, chid ) :
  

  # set direct access mode
  cmd = "rdwr -b %d %s 0x%X" % (fpgaid, "global.g.fpga.ReconfigCtrl.Direct", 1)
  print cmd
  exec_cmd(cmd)
  time.sleep(1.0)

  # select logical channel
  cmd = "rdwr -b %d %s 0x%X" % (fpgaid, "global.g.rcfg.PMA_LogicalChanNo ", chid)
  print cmd
  exec_cmd(cmd)
  time.sleep(1.0)
  
  # set address offset
  cmd = "rdwr -b %d %s 0x%X" % (fpgaid, "global.g.rcfg.PMA_Offset ", 0x20)
  print cmd
  exec_cmd(cmd)
  time.sleep(1.0)
  
  # set data channel
  cmd = "rdwr -b %d %s 0x%X" % (fpgaid, "global.g.rcfg.PMA_Data ", 1)
  print cmd
  exec_cmd(cmd)
  time.sleep(1.0)
  
  # enable indirect write
  cmd = "rdwr -b %d %s 0x%X" % (fpgaid, "global.g.rcfg.PMA_ControlStatus.PMA_Write ", 1)
  print cmd
  exec_cmd(cmd)
  time.sleep(1.0)
  
  # clear direct access mode
  cmd = "rdwr -b %d %s 0x%X" % (fpgaid, "global.g.fpga.ReconfigCtrl.Direct", 0)
  print cmd
  exec_cmd(cmd)
  time.sleep(1.0)

def disable_precdr_loopback (fpgaid, chid ) :
  

  # set direct access mode
  cmd = "rdwr -b %d %s 0x%X" % (fpgaid, "global.g.fpga.ReconfigCtrl.Direct", 1)
  print cmd
  exec_cmd(cmd)
  time.sleep(1.0)

  # select logical channel
  cmd = "rdwr -b %d %s 0x%X" % (fpgaid, "global.g.rcfg.PMA_LogicalChanNo ", chid)
  print cmd
  exec_cmd(cmd)
  time.sleep(1.0)
  
  # set address offset
  cmd = "rdwr -b %d %s 0x%X" % (fpgaid, "global.g.rcfg.PMA_Offset ", 0x20)
  print cmd
  exec_cmd(cmd)
  time.sleep(1.0)
  
  # set data channel
  cmd = "rdwr -b %d %s 0x%X" % (fpgaid, "global.g.rcfg.PMA_Data ", 0)
  print cmd
  exec_cmd(cmd)
  time.sleep(1.0)
  
  # enable indirect write
  cmd = "rdwr -b %d %s 0x%X" % (fpgaid, "global.g.rcfg.PMA_ControlStatus.PMA_Write ", 1)
  print cmd
  exec_cmd(cmd)
  time.sleep(1.0)
  
  # clear direct access mode
  cmd = "rdwr -b %d %s 0x%X" % (fpgaid, "global.g.fpga.ReconfigCtrl.Direct", 0)
  print cmd
  exec_cmd(cmd)
  time.sleep(1.0)


for fpgaid in range(2):
  for i in range(24):
    
    enable_precdr_loopback(fpgaid,i)
  
    enable_direct_access(fpgaid)
  
    cmd = "rdwr -b %d %s" % (fpgaid, "global.g.rcfg.PMA_LogicalChanNo")
    print cmd
    exec_cmd(cmd)
    time.sleep(1.0)
    cmd = "rdwr -b %d %s" % (fpgaid, "global.g.rcfg.PMA_PhyChanAddr")
    print cmd
    exec_cmd(cmd)
    time.sleep(1.0)
    cmd = "rdwr -b %d %s" % (fpgaid, "global.g.rcfg.PMA_ControlStatus")
    print cmd
    exec_cmd(cmd)
    time.sleep(1.0)
    cmd = "rdwr -b %d %s" % (fpgaid, "global.g.rcfg.PMA_Offset")
    print cmd
    exec_cmd(cmd)
    time.sleep(1.0)
    cmd = "rdwr -b %d %s" % (fpgaid, "global.g.rcfg.PMA_Data")
    print cmd
    exec_cmd(cmd)
    time.sleep(1.0)
    disable_direct_access(fpgaid)
