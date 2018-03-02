#!/usr/bin/env python2
import os, sys
import subprocess
import time

LoopbackSerdesCfg=0x12
fpga_addrs=[]
cmds=[]
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

def exec_cmd (cmd):
  proc = subprocess.Popen( cmd, shell=True, stdout = subprocess.PIPE, stderr = subprocess.PIPE )
  out,error=proc.communicate()
  #print out
  #print error
  if proc.returncode !=0:
    print "ERROR: read/write error %s %s" % (out,error)
  return out



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


def print_cmds ():
  """
  """
  INFILE=open("cmd.log","w")
  INFILE.write("\n".join(cmds))

find_fpga_addr()

for fpgaId in range(1,len(fpga_addrs)+1):
  for chanId in range(24):
    clear_Ctr(fpgaId,chanId,"mtip_fc1.DispErrCtr")
    clear_Ctr(fpgaId,chanId,"mtip_fc1.EofErrCtr")
    clear_Ctr(fpgaId,chanId,"mtip_fc1.InvldErrCtr")
    clear_Ctr(fpgaId,chanId,"mtip_fc1.PrimLinkUpCtr")
    clear_Ctr(fpgaId,chanId,"mtip_fc1.PrimLipCtr")
    clear_Ctr(fpgaId,chanId,"mtip_fc1.PrimLrLrrCtr")
    clear_Ctr(fpgaId,chanId,"mtip_fc1.PrimNosOlsCtr")
    clear_Ctr(fpgaId,chanId,"mtip_fc1.SofErrCtr")
    clear_Ctr(fpgaId,chanId,"mtip_fc2.FcCrcErrCtr")
    clear_Ctr(fpgaId,chanId,"mtip_fc2.FcEofErrCtr")
    clear_Ctr(fpgaId,chanId,"mtip_fc2.FcFrmCtr")
    clear_Ctr(fpgaId,chanId,"mtip_fc2.FcLosErrCtr")
    clear_Ctr(fpgaId,chanId,"mtip_fc2.FcLosIErrCtr")
    clear_Ctr(fpgaId,chanId,"mtip_fc2.FcShortErrCtr")
    clear_Ctr(fpgaId,chanId,"mtip_fc2.FcTruncErrCtr")

print_cmds()
