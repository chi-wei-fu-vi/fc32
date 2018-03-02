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
  #print out
  #print error
  if proc.returncode !=0:
    print "ERROR: read/write error %s %s" % (out,error)
  index=out.index(':')
  out=out[index+1:].lstrip()
  index=out.index(' ')
  out=out[:index]
  return out

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
  cmd = "rdwr -b %s link[%d].ch[%d].eth_mac.FrameCtrl 0x%X" % (fpgaid,chid//2,chid%2,hex2dec('1_0f_01_03_01'))
  #cmd = "rdwr -b %s link[%d].ch[%d].eth_mac.FrameCtrl 0x%X" % (fpgaid,chid//2,chid%2,hex2dec('0_01_00_00_01'))
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
    
def readmif(file):
  """
  """
  INFILE=open(file,'r')
  datas=[]
  ctrls=[]
  for line in INFILE.readlines():
    line=line.strip()
    if line.startswith('DEPTH='):
      depth=int(line[6:-1])
    elif ':' in line:
      index=line.index(':')
      line=line[index+1:].strip()
      index=line.index(';')
      line=line[:index].strip()
      ctrls.append(line[:2])
      datas.append(line[2:])
  INFILE.close()
  return ctrls,datas,depth

def read_ram_and_compare_with_mif(fpgaid,chid,file):
  """
  """
  (ctrls,datas,depth)=readmif(file)
  # set data space
  cmd = "rdwr -b %s bist.tx_ch[%d].txbist_ctl.control_space 0x%X" % (fpgaid,chid,hex2dec('0'))
  print cmd
  exec_cmd(cmd)
  time.sleep(0.1)
  # write data
  for i,data in enumerate(datas):
    cmd = "rdwr -b %s bist.tx_ch[%d].txbist_rd_addr 0x%X" % (fpgaid,chid,i)
    #print cmd
    exec_cmd(cmd)
    cmd = "rdwr -b %s bist.tx_ch[%d].txbist_rd_data" % (fpgaid,chid)
    #print cmd
    out="%016x"%int(exec_cmd(cmd),16)
    if data != out:
      print "Error: read %s and expect %s in location %d"%(out,data,i)
    else:
      print "Match: read %s and expect %s in location %d"%(out,data,i)
    time.sleep(0.01)
  # set control space
  cmd = "rdwr -b %s bist.tx_ch[%d].txbist_ctl.control_space 0x%X" % (fpgaid,chid,hex2dec('1'))
  print cmd
  exec_cmd(cmd)
  time.sleep(0.1)
  for i,ctrl in enumerate(ctrls):
    cmd = "rdwr -b %s bist.tx_ch[%d].txbist_rd_addr 0x%X" % (fpgaid,chid,i)
    #print cmd
    exec_cmd(cmd)
    cmd = "rdwr -b %s bist.tx_ch[%d].txbist_rd_data" % (fpgaid,chid)
    #print cmd
    out="%02x"%int(exec_cmd(cmd),16)
    if ctrl != out:
      print "Error: read %s and expect %s in location %d"%(out,ctrl,i)
    else:
      print "Match: read %s and expect %s in location %d"%(out,ctrl,i)
    time.sleep(0.01)

def write_mif_to_ram(fpgaid,chid,file):
  """
  """
  (ctrls,datas,depth)=readmif(file)
  # write starting address
  cmd = "rdwr -b %s bist.tx_ch[%d].txbist_wr_addr 0x%X" % (fpgaid,chid,hex2dec('0'))
  print cmd
  exec_cmd(cmd)
  time.sleep(0.1)
  # set data space
  cmd = "rdwr -b %s bist.tx_ch[%d].txbist_ctl.control_space 0x%X" % (fpgaid,chid,hex2dec('0'))
  print cmd
  exec_cmd(cmd)
  time.sleep(0.1)
  # write data
  for data in datas:
    cmd = "rdwr -b %s bist.tx_ch[%d].txbist_wr_data 0x%X" % (fpgaid,chid,hex2dec(data))
    print cmd
    exec_cmd(cmd)
    time.sleep(0.01)
  # write starting address
  cmd = "rdwr -b %s bist.tx_ch[%d].txbist_wr_addr 0x%X" % (fpgaid,chid,hex2dec('0'))
  print cmd
  exec_cmd(cmd)
  time.sleep(0.1)
  # set control space
  cmd = "rdwr -b %s bist.tx_ch[%d].txbist_ctl.control_space 0x%X" % (fpgaid,chid,hex2dec('1'))
  print cmd
  exec_cmd(cmd)
  time.sleep(0.1)
  for ctrl in ctrls:
    cmd = "rdwr -b %s bist.tx_ch[%d].txbist_wr_data 0x%X" % (fpgaid,chid,hex2dec(ctrl))
    print cmd
    exec_cmd(cmd)
    time.sleep(0.01)
    
      
def txbist_init(fpgaid,chid,file):
  """
  """
  (ctrls,datas,depth)=readmif(file)
  # ipg number
  cmd = "rdwr -b %s bist.tx_ch[%d].txbist_ipg_min 0x%X" % (fpgaid,chid,3)
  print cmd
  exec_cmd(cmd)
  time.sleep(0.1)
  # write end address
  cmd = "rdwr -b %s bist.tx_ch[%d].txbist_ram_end 0x%X" % (fpgaid,chid,depth)
  print cmd
  exec_cmd(cmd)
  time.sleep(0.1)
  # write loop count
  cmd = "rdwr -b %s bist.tx_ch[%d].txbist_loop_cnt 0x%X" % (fpgaid,chid,0)
  print cmd
  exec_cmd(cmd)
  time.sleep(0.1)
  # Tx mode
  cmd = "rdwr -b %s bist.tx_ch[%d].txbist_ctl.mode 0x%X" % (fpgaid,chid,1)
  print cmd
  exec_cmd(cmd)
  time.sleep(0.1)


if __name__ == '__main__':
  import sys
  argc=len(sys.argv)
  if argc > 1: mif=sys.argv[1]

  # find fpga pcie address region
  find_fpga_addr ( )

  # eth mac init
  for fpgaid in range(1,len(fpga_addrs)+1):
    for chid in range(24):
      mac_init(fpgaid,chid)

  # write mif to ram
  for fpgaid in range(1,len(fpga_addrs)+1):
    for chid in range(2):
      write_mif_to_ram(fpgaid,chid,mif)  
      
    
  # read ram and compare with mif
  for fpgaid in range(1,len(fpga_addrs)+1):
    for chid in range(2):
      read_ram_and_compare_with_mif(fpgaid,chid,mif)  

  for fpgaid in range(1,len(fpga_addrs)+1):
    for chid in range(2):
      txbist_init(fpgaid,chid,mif)
