#!/usr/bin/env python2
import os, sys
import pexpect
import time
debug=0
def exec_cmd (cmd):
  global debug
  out = pexpect.run(cmd)
  if debug :print cmd
  if debug :print out

  if "]:" in out:
    index=out.index("]:")
    out=out[index+2:].strip()
    index=out.index(" ")
    out=out[:index].strip()
    return int(out,16)
  else:
    if debug: print "ERROR: %s %s" % (cmd,out)
    return ""

def tx_speed_change ( fpgaid, speed ) :
  global debug
  # set speed
  cmd = "rdwr -b %d global.g.clkrst.TxBistCtrl.LinkSpeed %X" % ( fpgaid , speed)
  if debug:   print cmd
  exec_cmd(cmd)
  time.sleep(3.0)

def rx_speed_change ( fpgaid, linkid, speed ) :
  global debug
  
  # set speed
  cmd = "rdwr -b %d link[%d].g.csr.LinkCtrl.LinkSpeed %X" % ( fpgaid , linkid , speed)
  if debug:   print cmd
  exec_cmd(cmd)
  time.sleep(3.0)

  # check speed
  cmd = "rdwr -b %d  link[%d].g.csr.LinkStatus" % ( fpgaid ,linkid )
  if debug:   print cmd
  exec_cmd(cmd)
  time.sleep(1.0)

  check_clock( fpgaid , linkid )


def check_clock ( fpgaid, linkid ):
  global debug
  cmd = "rdwr -b %d global.g.clkrst.ClkCtrSerdes%d_0" % ( fpgaid, linkid )
  if debug:   print cmd
  exec_cmd(cmd)

  cmd = "rdwr -b %d global.g.clkrst.ClkCtrSerdes%d_1" % ( fpgaid, linkid )
  if debug:   print cmd
  exec_cmd(cmd)

while 1:
  for fpgaid in range(1,5):
    for speed in range(4):
      tx_speed_change(fpgaid,speed)
      for linkid in range(12):
        rx_speed_change(fpgaid,linkid,speed)

