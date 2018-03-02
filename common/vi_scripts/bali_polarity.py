#!/usr/bin/env python2
import os, sys
import subprocess
import time

tx_swaps=[
  0, 
  2 , 
  4 , 
  6 , 
  9 , 
 11 , 
 13 , 
 15  
]
rx_swaps=range(16)

def exec_cmd (cmd):
  proc = subprocess.Popen( cmd, shell=True, stdout = subprocess.PIPE, stderr = subprocess.PIPE )
  out,error=proc.communicate()
  print out
  print error
  if proc.returncode !=0:
    print "ERROR: read/write error %s %s" % (out,error)


def enable_tx_polarity_swap (chanId):
  global ReconfigCtrl
  # set direct access mode
  link=int(chanId/2)
  ch  =chanId%2
  cmd = "rdwr link[%d].ch[%d].serdes.Ctl.TxInvert %d" % ( link,ch, 1)
  print cmd
  exec_cmd(cmd)
  time.sleep(0.01)

def enable_rx_polarity_swap (chanId):
  global ReconfigCtrl
  # set direct access mode
  link=int(chanId/2)
  ch  =chanId%2
  cmd = "rdwr link[%d].ch[%d].serdes.Ctl.RxInvert %d" % ( link,ch, 1)
  print cmd
  exec_cmd(cmd)
  time.sleep(0.01)


for i in range(16):
  
  # tx polarity swap
  if i in tx_swaps:
    enable_tx_polarity_swap(i)

  # rx polarity swap
  if i in rx_swaps:
    enable_rx_polarity_swap(i)
