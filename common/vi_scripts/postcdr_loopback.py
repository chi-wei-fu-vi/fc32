#!/usr/bin/env python2
import os, sys
import subprocess
import time

ReconfigCtrl = 0x4
base	= 0x1800
index	= 1
lchreg	= 0x0
pchreg	= 0x1
csrreg	= 0x2
addreg	= 0x3
datreg	= 0x4
perword = 1
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
  cmd = "rdwr64 -r %s 0x%X 0x%X" % ( fpga_addrs[fpgaid] , ReconfigCtrl , 2)
  print cmd
  exec_cmd(cmd)
  time.sleep(0.1)

def disable_direct_access ( fpgaid ):
  global ReconfigCtrl
  # clear direct access mode
  cmd = "rdwr64 -r %s 0x%X 0x%X" % ( fpga_addrs[fpgaid] , ReconfigCtrl , 0)
  print cmd
  exec_cmd(cmd)
  time.sleep(0.1)

def enable_postcdr_loopback ( fpgaid, chid ) :
  
  global base
  global index
  global lchreg
  global pchreg
  global csrreg
  global addreg
  global datreg
  global perword
  global ReconfigCtrl

  # set direct access mode
  cmd = "rdwr64 -r %s 0x%X 0x%X" % ( fpga_addrs[fpgaid] , ReconfigCtrl , 2)
  print cmd
  exec_cmd(cmd)
  time.sleep(0.1)

  # select logical channel
  cmd = "rdwr64 -r %s 0x%X 0x%X" % ( fpga_addrs[fpgaid] , base + index*8 +lchreg*perword , chid)
  print cmd
  exec_cmd(cmd)
  time.sleep(0.1)
  
  # set address offset
  cmd = "rdwr64 -r %s 0x%X 0x%X" % ( fpga_addrs[fpgaid] , base + index*8 +addreg*perword , 0x21)
  print cmd
  exec_cmd(cmd)
  time.sleep(0.1)
  
  # set data channel
  cmd = "rdwr64 -r %s 0x%X 0x%X" % ( fpga_addrs[fpgaid] , base + index*8 +datreg*perword , 1)
  print cmd
  exec_cmd(cmd)
  time.sleep(0.1)
  
  # enable indirect write
  cmd = "rdwr64 -r %s 0x%X 0x%X" % ( fpga_addrs[fpgaid] , base + index*8 +csrreg*perword , 1)
  print cmd
  exec_cmd(cmd)
  time.sleep(0.1)
  
  # clear direct access mode
  cmd = "rdwr64 -r %s 0x%X 0x%X" % ( fpga_addrs[fpgaid] , ReconfigCtrl , 0)
  print cmd
  exec_cmd(cmd)
  time.sleep(0.1)


def disable_postcdr_loopback ( fpgaid , chid ) :
  
  global base
  global index
  global lchreg
  global pchreg
  global csrreg
  global addreg
  global datreg
  global perword
  global ReconfigCtrl

  # set direct access mode
  cmd = "rdwr64 -r %s 0x%X 0x%X" % ( fpga_addrs[fpgaid] , ReconfigCtrl , 2)
  print cmd
  exec_cmd(cmd)
  time.sleep(0.1)

  # select logical channel
  cmd = "rdwr64 -r %s 0x%X 0x%X" % ( fpga_addrs[fpgaid] , base + index*8 +lchreg*perword , chid)
  print cmd
  exec_cmd(cmd)
  time.sleep(0.1)
  
  # set address offset
  cmd = "rdwr64 -r %s 0x%X 0x%X" % ( fpga_addrs[fpgaid] , base + index*8 +addreg*perword , 0x21)
  print cmd
  exec_cmd(cmd)
  time.sleep(0.1)
  
  # set data channel
  cmd = "rdwr64 -r %s 0x%X 0x%X" % ( fpga_addrs[fpgaid] , base + index*8 +datreg*perword , 0)
  print cmd
  exec_cmd(cmd)
  time.sleep(0.1)
  
  # enable indirect write
  cmd = "rdwr64 -r %s 0x%X 0x%X" % ( fpga_addrs[fpgaid] , base + index*8 +csrreg*perword , 1)
  print cmd
  exec_cmd(cmd)
  time.sleep(0.1)
  
  # clear direct access mode
  cmd = "rdwr64 -r %s 0x%X 0x%X" % ( fpga_addrs[fpgaid] , ReconfigCtrl , 0)
  print cmd
  exec_cmd(cmd)
  time.sleep(0.1)

def enable_precdr_loopback ( fpgaid , chid ) :
  
  global base
  global index
  global lchreg
  global pchreg
  global csrreg
  global addreg
  global datreg
  global perword
  global ReconfigCtrl

  # set direct access mode
  cmd = "rdwr64 -r %s 0x%X 0x%X" % ( fpga_addrs[fpgaid] , ReconfigCtrl , 2)
  print cmd
  exec_cmd(cmd)
  time.sleep(0.1)

  # select logical channel
  cmd = "rdwr64 -r %s 0x%X 0x%X" % ( fpga_addrs[fpgaid] , base + index*8 +lchreg*perword , chid)
  print cmd
  exec_cmd(cmd)
  time.sleep(0.1)
  
  # set address offset
  cmd = "rdwr64 -r %s 0x%X 0x%X" % ( fpga_addrs[fpgaid] , base + index*8 +addreg*perword , 0x20)
  print cmd
  exec_cmd(cmd)
  time.sleep(0.1)
  
  # set data channel
  cmd = "rdwr64 -r %s 0x%X 0x%X" % ( fpga_addrs[fpgaid] , base + index*8 +datreg*perword , 1)
  print cmd
  exec_cmd(cmd)
  time.sleep(0.1)
  
  # enable indirect write
  cmd = "rdwr64 -r %s 0x%X 0x%X" % ( fpga_addrs[fpgaid] , base + index*8 +csrreg*perword , 1)
  print cmd
  exec_cmd(cmd)
  time.sleep(0.1)
  
  # clear direct access mode
  cmd = "rdwr64 -r %s 0x%X 0x%X" % ( fpga_addrs[fpgaid] , ReconfigCtrl , 0)
  print cmd
  exec_cmd(cmd)
  time.sleep(0.1)

def disable_precdr_loopback ( fpgaid , chid ) :
  
  global base
  global index
  global lchreg
  global pchreg
  global csrreg
  global addreg
  global datreg
  global perword
  global ReconfigCtrl

  # set direct access mode
  cmd = "rdwr64 -r %s 0x%X 0x%X" % ( fpga_addrs[fpgaid] , ReconfigCtrl , 2)
  print cmd
  exec_cmd(cmd)
  time.sleep(0.1)

  # select logical channel
  cmd = "rdwr64 -r %s 0x%X 0x%X" % ( fpga_addrs[fpgaid] , base + index*8 +lchreg*perword , chid)
  print cmd
  exec_cmd(cmd)
  time.sleep(0.1)
  
  # set address offset
  cmd = "rdwr64 -r %s 0x%X 0x%X" % ( fpga_addrs[fpgaid] , base + index*8 +addreg*perword , 0x20)
  print cmd
  exec_cmd(cmd)
  time.sleep(0.1)
  
  # set data channel
  cmd = "rdwr64 -r %s 0x%X 0x%X" % ( fpga_addrs[fpgaid] , base + index*8 +datreg*perword , 0)
  print cmd
  exec_cmd(cmd)
  time.sleep(0.1)
  
  # enable indirect write
  cmd = "rdwr64 -r %s 0x%X 0x%X" % ( fpga_addrs[fpgaid] , base + index*8 +csrreg*perword , 1)
  print cmd
  exec_cmd(cmd)
  time.sleep(0.1)
  
  # clear direct access mode
  cmd = "rdwr64 -r %s 0x%X 0x%X" % ( fpga_addrs[fpgaid] , ReconfigCtrl , 0)
  print cmd
  exec_cmd(cmd)
  time.sleep(0.1)

# find fpga pcie address region
find_fpga_addr ( )

#
for fpgaid in range(len(fpga_addrs)):
  for chid in range(24):
    
    enable_postcdr_loopback(fpgaid,chid)
  
    enable_direct_access(fpgaid)
  
    cmd = "rdwr64 -r %s 0x%X" % ( fpga_addrs[fpgaid] , base + index*8 +lchreg*perword )
    print cmd
    exec_cmd(cmd)
    time.sleep(0.1)
    cmd = "rdwr64 -r %s 0x%X" % ( fpga_addrs[fpgaid] , base + index*8 +pchreg*perword )
    print cmd
    exec_cmd(cmd)
    time.sleep(0.1)
    cmd = "rdwr64 -r %s 0x%X" % ( fpga_addrs[fpgaid] , base + index*8 +csrreg*perword )
    print cmd
    exec_cmd(cmd)
    time.sleep(0.1)
    cmd = "rdwr64 -r %s 0x%X" % ( fpga_addrs[fpgaid] , base + index*8 +addreg*perword )
    print cmd
    exec_cmd(cmd)
    time.sleep(0.1)
    cmd = "rdwr64 -r %s 0x%X" % ( fpga_addrs[fpgaid] , base + index*8 +datreg*perword )
    print cmd
    exec_cmd(cmd)
    time.sleep(0.1)
  
    disable_direct_access(fpgaid)
