#!/usr/bin/env python2
import os, sys
import subprocess
import time

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

def exec_cmd (cmd):
  proc = subprocess.Popen( cmd, shell=True, stdout = subprocess.PIPE, stderr = subprocess.PIPE )
  out,error=proc.communicate()
  print out
  print error
  if proc.returncode !=0:
    print "ERROR: read/write error %s %s" % (out,error)

def enable_direct_access ( fpgaid ):
  global ReconfigCtrl
  # set direct access mode
  cmd = "rdwr -b %s 0x%X 0x%X" % ( fpga_addrs[fpgaid] , ReconfigCtrl , 2)
  print cmd
  exec_cmd(cmd)
  time.sleep(0.1)

def disable_direct_access ( fpgaid ):
  global ReconfigCtrl
  # clear direct access mode
  cmd = "rdwr -b %s 0x%X 0x%X" % ( fpga_addrs[fpgaid] , ReconfigCtrl , 0)
  print cmd
  exec_cmd(cmd)
  time.sleep(0.1)
def hex2dec(number):
  """
  """
  number=number.replace('_','')
  return int(number,16)


def mac_init ( fpgaid, chid ) :
  # stat cnt trans,rx_en,max_rx_frm_length 2220 
  cmd = "rdwr -b %s link[%d].ch[%d].eth_mac.MAC_Ctrl 0x%X" % (fpgaid,chid//2,chid%2,hex2dec('08ac_0000_0100_0004'))
  print cmd
  exec_cmd(cmd)
  time.sleep(0.1)
  # FCOE 8906
  cmd = "rdwr -b %s link[%d].ch[%d].eth_mac.Data_type_3_0 0x%X" % (fpgaid,chid//2,chid%2,hex2dec('8906'))
  print cmd
  exec_cmd(cmd)
  time.sleep(0.1)
  # FIP, LLDP
  cmd = "rdwr -b %s link[%d].ch[%d].eth_mac.CNTL_type_3_0 0x%X" % (fpgaid,chid//2,chid%2,hex2dec('88cc_8914'))
  print cmd
  exec_cmd(cmd)
  time.sleep(0.1)
  # flow control
  cmd = "rdwr -b %s link[%d].ch[%d].eth_mac.Pause_type_3_0 0x%X" % (fpgaid,chid//2,chid%2,hex2dec('8808'))
  print cmd
  exec_cmd(cmd)
  time.sleep(0.1)
  # valid bits
  #cmd = "rdwr -b %s link[%d].ch[%d].eth_mac.FrameCtrl 0x%X" % (fpgaid,chid//2,chid%2,hex2dec('1_0f_01_03_01'))
  cmd = "rdwr -b %s link[%d].ch[%d].eth_mac.FrameCtrl 0x%X" % (fpgaid,chid//2,chid%2,hex2dec('0_01_00_00_01'))
  print cmd
  exec_cmd(cmd)
  time.sleep(0.1)
  cmd = "rdwr -b %s link[%d].ch[%d].eth_mac.Ethertype_3_0 0x%X" % (fpgaid,chid//2,chid%2,hex2dec('88cc_8914_8808_8906'))
  print cmd
  exec_cmd(cmd)
  time.sleep(0.1)
  # Link control
  if chid%2 :
    # datctlsz 32bytes, DataMonMode Normal, CtrlMonMode Normal
    cmd = "rdwr -b %s link[%d].g.csr.LinkCtrl 0x%X" % (fpgaid,chid//2,hex2dec('2_2_0_0'))
    print cmd
    exec_cmd(cmd)
    time.sleep(0.1)
    




# find fpga pcie address region
find_fpga_addr ( )

for fpgaid in range(1,len(fpga_addrs)+1):
  for chid in range(24):
    
    mac_init(fpgaid,chid)
  
