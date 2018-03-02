#!/usr/bin/env python2
import os, sys
import subprocess
import time

LoopbackSerdesCfg=0x12
tx_swaps=[
  0 , 
  2 , 
  4 , 
  6 , 
  9 , 
 11 , 
 13 , 
 15 ,
 17 ,
 19 ,
 21 ,
 23  
]
rx_swaps=range(16)+range(17,24)
fpga_addrs=[]

def find_fpga_addr ( ):
  cmd = "lspci -d 1bb9: -vvv"
  print cmd
  proc = subprocess.Popen( cmd, shell=True, stdout = subprocess.PIPE, stderr = subprocess.PIPE )
  out,error=proc.communicate()
  if proc.returncode !=0:
    print "ERROR: lspci -d 1bb9: -vvv" % (out,error)
  else:
    for line in out.split('\n'):
      line=line.strip()
      if line.startswith('Region 2: Memory at '):
        addr=line[20:28]
        fpga_addrs.append(addr)
  print fpga_addrs

def enable_IntLpbk_LoopbackSerdesCfg ( fpgaid ):
  global LoopbackSerdesCfg
  # set direct access mode
  cmd = "rdwr64 -r %s 0x%X 0x%X" % ( fpga_addrs[fpgaid] , LoopbackSerdesCfg , 0)
  #cmd = "rdwr -b %d global.g.fpga.LoopbackSerdesCfg %d" % (fpgaId+1, 0)
  print cmd
  exec_cmd(cmd)
  time.sleep(0.1)

def enable_ExtLpbk_LoopbackSerdesCfg ( fpgaid ):
  global LoopbackSerdesCfg
  # set direct access mode
  cmd = "rdwr64 -r %s 0x%X 0x%X" % ( fpga_addrs[fpgaid] , LoopbackSerdesCfg , 1)
  #cmd = "rdwr -b %d global.g.fpga.LoopbackSerdesCfg %d" % (fpgaId+1, 1)
  print cmd
  exec_cmd(cmd)
  time.sleep(0.1)

def exec_cmd (cmd):
  proc = subprocess.Popen( cmd, shell=True, stdout = subprocess.PIPE, stderr = subprocess.PIPE )
  out,error=proc.communicate()
  print out
  print error
  if proc.returncode !=0:
    print "ERROR: read/write error %s %s" % (out,error)


def enable_tx_polarity_swap (fpgaId,chanId):
  global ReconfigCtrl
  # set direct access mode
  link=int(chanId/2)
  ch  =chanId%2
  cmd = "rdwr -b %d link[%d].ch[%d].serdes.Ctl.TxInvert %d" % (fpgaId, link, ch, 1)
  print cmd
  exec_cmd(cmd)
  time.sleep(0.01)

def enable_rx_polarity_swap (fpgaId,chanId):
  global ReconfigCtrl
  # set direct access mode
  link=int(chanId/2)
  ch  =chanId%2
  cmd = "rdwr -b %d link[%d].ch[%d].serdes.Ctl.RxInvert %d" % (fpgaId, link, ch, 1)
  print cmd
  exec_cmd(cmd)
  time.sleep(0.01)

def disable_tx_polarity_swap (fpgaId,chanId):
  global ReconfigCtrl
  # set direct access mode
  link=int(chanId/2)
  ch  =chanId%2
  cmd = "rdwr -b %d link[%d].ch[%d].serdes.Ctl.TxInvert %d" % (fpgaId, link, ch, 0)
  print cmd
  exec_cmd(cmd)
  time.sleep(0.01)

def disable_rx_polarity_swap (fpgaId,chanId):
  global ReconfigCtrl
  # set direct access mode
  link=int(chanId/2)
  ch  =chanId%2
  cmd = "rdwr -b %d link[%d].ch[%d].serdes.Ctl.RxInvert %d" % (fpgaId, link, ch, 0)
  print cmd
  exec_cmd(cmd)
  time.sleep(0.01)


find_fpga_addr()

for fpgaId in range(1,len(fpga_addrs)+1):
  enable_IntLpbk_LoopbackSerdesCfg(fpgaId-1)
  for chanId in range(24):
    
    # tx polarity swap
    if chanId in tx_swaps:
      enable_tx_polarity_swap(fpgaId,chanId)
    else:
      disable_tx_polarity_swap(fpgaId,chanId)
  
    # rx polarity swap
    if chanId in rx_swaps:
      enable_rx_polarity_swap(fpgaId,chanId)
    else:
      disable_rx_polarity_swap(fpgaId,chanId)
