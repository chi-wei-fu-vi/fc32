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
cmds=[]
mtip_fc2_FcCrcErrCtrs =[
'0x84C11',
'0x88C11',
'0xA4C11',
'0xA8C11',
'0xC4C11',
'0xC8C11',
'0xE4C11',
'0xE8C11',
'0x104C11',
'0x108C11',
'0x124C11',
'0x128C11',
'0x144C11',
'0x148C11',
'0x164C11',
'0x168C11',
'0x184C11',
'0x188C11',
'0x1A4C11',
'0x1A8C11',
'0x1C4C11',
'0x1C8C11',
'0x1E4C11',
'0x1E8C11'
]
def find_fpga_addr ( ):
  cmd = "lspci -d 1bb9: -vvv"
  #print cmd
  cmds.append(cmd)
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

def enable_IntLpbk_LoopbackSerdesCfg ( fpgaId ):
  global LoopbackSerdesCfg
  # set direct access mode
  cmd = "rdwr64 -r %s 0x%X 0x%X" % ( fpga_addrs[fpgaId-1] , LoopbackSerdesCfg , 0)
  #cmd = "rdwr -b %d global.g.fpga.LoopbackSerdesCfg %d" % (fpgaId+1, 0)
  #print cmd
  cmds.append(cmd)
  exec_cmd(cmd)
  time.sleep(0.1)
 

def enable_ExtLpbk_LoopbackSerdesCfg ( fpgaId ):
  global LoopbackSerdesCfg
  # set direct access mode
  cmd = "rdwr64 -r %s 0x%X 0x%X" % ( fpga_addrs[fpgaId-1] , LoopbackSerdesCfg , 1)
  #cmd = "rdwr -b %d global.g.fpga.LoopbackSerdesCfg %d" % (fpgaId+1, 1)
  #print cmd
  cmds.append(cmd)
  exec_cmd(cmd)
  time.sleep(0.1)

def exec_cmd (cmd):
  proc = subprocess.Popen( cmd, shell=True, stdout = subprocess.PIPE, stderr = subprocess.PIPE )
  out,error=proc.communicate()
  #print out
  #print error
  if proc.returncode !=0:
    print "ERROR: read/write error %s %s" % (out,error)
  return out


def enable_tx_polarity_swap (fpgaId,chanId):
  # set direct access mode
  link=int(chanId/2)
  ch  =chanId%2
  cmd = "rdwr -b %d link[%d].ch[%d].serdes.Ctl.TxInvert %d" % (fpgaId, link, ch, 1)
  #print cmd
  cmds.append(cmd)
  out=exec_cmd(cmd)
  print out 
  time.sleep(0.01)

def enable_rx_polarity_swap (fpgaId,chanId):
  # set direct access mode
  link=int(chanId/2)
  ch  =chanId%2
  cmd = "rdwr -b %d link[%d].ch[%d].serdes.Ctl.RxInvert %d" % (fpgaId, link, ch, 1)
  #print cmd
  cmds.append(cmd)
  out=exec_cmd(cmd)
  print out 
  time.sleep(0.01)

def disable_tx_polarity_swap (fpgaId,chanId):
  # set direct access mode
  link=int(chanId/2)
  ch  =chanId%2
  cmd = "rdwr -b %d link[%d].ch[%d].serdes.Ctl.TxInvert %d" % (fpgaId, link, ch, 0)
  #print cmd
  cmds.append(cmd)
  out=exec_cmd(cmd)
  print out 
  time.sleep(0.01)

def disable_rx_polarity_swap (fpgaId,chanId):
  # set direct access mode
  link=int(chanId/2)
  ch  =chanId%2
  cmd = "rdwr -b %d link[%d].ch[%d].serdes.Ctl.RxInvert %d" % (fpgaId, link, ch, 0)
  #print cmd
  cmds.append(cmd)
  out=exec_cmd(cmd)
  print out 
  time.sleep(0.01)

def toggle_rx_polarity_swap (fpgaId,chanId):
  # set direct access mode
  link=int(chanId/2)
  ch  =chanId%2
  cmd = "rdwr -b %d link[%d].ch[%d].serdes.Ctl.RxInvert" % (fpgaId, link, ch)
  #print cmd
  cmds.append(cmd)
  out= exec_cmd(cmd)
  time.sleep(0.01)
  for line in out.split('\n'):
    if ": " in line:
      index= line.index(": ")
      #print line[index+2:index+3]
      value= int(line[index+2:index+3])
      print "fpga[%d].link[%d].ch[%d rx inv status %d" % (fpgaId,link, ch,value)
  if value == 1:
    cmd = "rdwr -b %d link[%d].ch[%d].serdes.Ctl.RxInvert %d" % (fpgaId, link, ch, 0)
    print cmd
    cmds.append(cmd)
    out= exec_cmd(cmd)
    time.sleep(0.01)
  else:
    cmd = "rdwr -b %d link[%d].ch[%d].serdes.Ctl.RxInvert %d" % (fpgaId, link, ch, 1)
    print cmd
    cmds.append(cmd)
    out= exec_cmd(cmd)
    time.sleep(0.01)


def read_LosigCh (fpgaId,chanId):
  # set direct access mode
  link=int(chanId/2)
  ch  =chanId%2
  if ch == 0:
    cmd = "rdwr -b %d link[%d].g.csr.LinkStatus.LosyncCh0" % (fpgaId, link)
  else:
    cmd = "rdwr -b %d link[%d].g.csr.LinkStatus.LosyncCh1" % (fpgaId, link)
  #print cmd
  out= exec_cmd(cmd)
  time.sleep(0.01)
  for line in out.split('\n'):
    if ": " in line:
      index= line.index(": ")
      #print line[index+2:index+3]
      value= int(line[index+2:index+3],16)
      print "fpga[%d].link[%d].ch[%d] loss sync: %d" % (fpgaId,link, ch,value)
      return value

def clear_Ctr (fpgaId,chanId,symbol):
  # set direct access mode
  link=int(chanId/2)
  ch  =chanId%2
  cmd = "rdwr -b %d link[%d].ch[%d].%s %d" % (fpgaId, link, ch, symbol,1)
  #print cmd
  cmds.append(cmd)
  out= exec_cmd(cmd)

def read_Ctr (fpgaId,chanId,symbol):
  # set direct access mode
  link=int(chanId/2)
  ch  =chanId%2
  cmd = "rdwr -b %d link[%d].ch[%d].%s" % (fpgaId, link, ch, symbol)
  #print cmd
  cmds.append(cmd)
  out= exec_cmd(cmd)
  time.sleep(0.01)
  for line in out.split('\n'):
    if ": " in line:
      index= line.index(": ")
      line=line[index+2:]
      print line
      index= line.index(" ")
      cntr= int(line[:index],16)
      print "fpga[%d].link[%d].ch[%d].%s cntr: %d" % (fpgaId,link, ch,symbol,cntr)
      return cntr
  print_cmds()
  print "Error: reading fpga[%d].link[%d].ch[%d].%s" % (fpgaId,link, ch,symbol) 
  exit()

def ScrmEnbl (fpgaId,link):
  """
  """
  # set direct access mode
  cmd = "rdwr -b %d link[%d].g.csr.LinkCtrl.ScrmEnbl %d" % (fpgaId, link, 1)
  #print cmd
  cmds.append(cmd)
  out=exec_cmd(cmd)
  print out 
  time.sleep(0.01)

def print_cmds ():
  """
  """
  INFILE=open("cmd.log","w")
  INFILE.write("\n".join(cmds))

find_fpga_addr()

for fpgaId in range(1,len(fpga_addrs)+1):
#for fpgaId in range(1,2):
  enable_IntLpbk_LoopbackSerdesCfg(fpgaId)
  for chanId in range(24):
    print "="*80
    link = chanId//2
    ScrmEnbl (fpgaId,link)
    if read_LosigCh(fpgaId,chanId)==1:
      print "Error: loss sync on %d" % chanId
    else:
      #read_Ctr(fpgaId,chanId,"mtip_fc1.DispErrCtr")
      #read_Ctr(fpgaId,chanId,"mtip_fc2.FcLosErrCtr")
      #read_Ctr(fpgaId,chanId,"mtip_fc2.FcLosIErrCtr")
      cntr1=read_Ctr(fpgaId,chanId,"mtip_fc2.FcFrmCtr")
      time.sleep(0.1)
      cntr2=read_Ctr(fpgaId,chanId,"mtip_fc2.FcFrmCtr")
    

    # rx polarity swap
    if cntr2 > cntr1:
      read_Ctr(fpgaId,chanId,"mtip_fc2.FcCrcErrCtr")
      time.sleep(0.1)
      read_Ctr(fpgaId,chanId,"mtip_fc2.FcCrcErrCtr")
    else:
      toggle_rx_polarity_swap(fpgaId,chanId)
print_cmds()
