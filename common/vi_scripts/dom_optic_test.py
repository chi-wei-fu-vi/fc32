#!/usr/bin/env python2
import os
import fcntl
import termios
import signal
import array
import select
import time
import pexpect
import sys
device=0
delay=3
low=0
high=5
incr=0.5

fpgas=range(1,5)
#fpgas=range(1,2)

links=range(12)
#links=range(1)
#links=[0,2,3]

chids=range(2)
#chids=range(1)


expectFrmRate=1800000.
expectTaStatRate=4.
debug=0

def open_ttyUSB(num):
  """
  open tty
  """
  fd=os.open("/dev/ttyUSB%d"%num,os.O_RDWR | os.O_NOCTTY)
  return fd

def term_getattr(fd):
  """
  """
  (iflag,oflag,cflag,lflag,ispeed,ospeed,cc)=termios.tcgetattr(fd)

def term_getattr(fd,iflag,oflag,cflag,lflag,ispeed,ospeed,cc):
  """
  """
  termios.tcsetattr(fd, termios.TCSADRAIN,[iflag,oflag,cflag,lflag,ispeed,ospeed,cc])

def get_response(fd):
  """
  """
  ch=os.read(fd,80) 
  print ch
  return ch

def config_port(fd):
  """
  """
  termios.tcflush(fd, termios.TCIOFLUSH)
  (iflag,oflag,cflag,lflag,ispeed,ospeed,cc)=termios.tcgetattr(fd)
  cflag = termios.B1200 | termios.CS8 | termios.CLOCAL | termios.CREAD | termios.CRTSCTS
  iflag = termios.IGNPAR | termios.ICRNL # translate CR to NL on input
  oflag = termios.ONLCR                  # map NL to CR-NL on output
  lflag = termios.ICANON;
  cc[termios.VEOF] = 4                   # ^D
  cc[termios.VMIN] = 1                   # should not be necessary since we're in canonical processing mode...

  termios.tcflush(fd, termios.TCIFLUSH);  # flush input data
  termios.tcsetattr(fd, termios.TCSADRAIN,[iflag,oflag,cflag,lflag,ispeed,ospeed,cc])
def send_cmd(fd,cmd):
  """
  """
  ret= os.write(fd,"%s\r"%cmd)
  return ret

def attenuation(fd,delay=3,low=10,high=14,incr=0.5,verbose=0):
  """
  """
  global debug;
  # block light
  print "Block light"
  ret=send_cmd(fd,"D 1")
  if ret == -1:
    print """Error while executing "D 1" command"""
    os.close(fd)
    exit(1)
  # check status
  # check_status(delay,verbose)

  # unblock light
  print "Unblock light"
  ret=send_cmd(fd,"D 0")
  if ret == -1:
    print """Error while executing "D 0" command"""
    os.close(fd)
    exit(1)
  # check status
  check_status(delay,verbose)
  
  # increase attenuation
  low=float(low)
  high=float(high)
  incr=float(incr)
  att=low 
  while att <= high:
    print "att %f" % att
    ret=send_cmd(fd,"ATT %f"%att)
    if ret == -1:
      print """Error while executing "ATT %f" command"""%att
      os.close(fd)
      exit(1)
    att=att+incr
    check_status(delay,verbose)

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
    print "ERROR: %s %s" % (cmd,out)
    return ""

def check_status(delay,verbose=0):
  """
  """
  global debug;
  out1s=[]
  out2s=[]
  t1=time.time()
  # query 
  for fpgaid in fpgas:
    for linkid in links:
      # interval stat count
      out1s.append(query_TaDalStatCtr(fpgaid,linkid))
      for chid in chids:
        out1s.append(query_FcFrmCtr(fpgaid,linkid,chid))

  time.sleep(delay)

  t2=time.time()
  # query 
  for fpgaid in fpgas:
    for linkid in links:
      # interval stat count
      out2s.append(query_TaDalStatCtr(fpgaid,linkid))
      for chid in chids:
        out2s.append(query_FcFrmCtr(fpgaid,linkid,chid))
  time_elapse=t2-t1
  # check
  for fpgaid in fpgas:
    for linkid in links:
      taStat1=out1s.pop(0)
      taStat2=out2s.pop(0)
      delta_taStat=taStat2-taStat1
      if delta_taStat==0:
        print "Exit : taStat of FPGA %d link %d is frozen %d %d"%(fpgaid,linkid,taStat1,taStat2)
        os.close(fd)
        exit(2)
      elif delta_taStat>0:
        taStatRate=float(delta_taStat)/time_elapse
        if taStatRate < (expectTaStatRate*.5):
          print "Exit : taStat Rate of FPGA %d link %d drops to %e"%(fpgaid,linkid,taStatRate)
          os.close(fd)
          exit(2)
      else:
        pass
      for chid in chids:
        frmCtr1=out1s.pop(0)
        frmCtr2=out2s.pop(0)
        delta_frmCtr=frmCtr2-frmCtr1
        if delta_frmCtr==0:
          print "Exit : frmCtr of FPGA %d link %d ch %d is frozen %d %d"%(fpgaid,linkid,chid,frmCtr1,frmCtr2)
          os.close(fd)
          exit(3)
        elif delta_frmCtr>0:
          frmRate=float(delta_frmCtr)/time_elapse
          if frmRate < (expectFrmRate*.8):
            print "Exit : frame Rate of FPGA %d link %d ch %d drops to %e"%(fpgaid,linkid,chid,frmRate)
            os.close(fd)
            exit(3)
        else:
          pass
 



def query_TaDalStatCtr(fpgaid,linkid,verbose=0):
  global debug
  cmd="rdwr -b %d link[%d].g.csr.TaDalStatCtr" % (fpgaid,linkid)
  if (verbose & 2) == 2 : print cmd
  out=exec_cmd(cmd)
  if out == "":
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "FPGA %d link[%d].g.csr.TaDalStatCtr is %s" % (fpgaid,linkid,out)
    if (verbose & 1) == 1 : print "="*30
    return out
  else:
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "FPGA %d link[%d].g.csr.TaDalStatCtr is %s" % (fpgaid,linkid,out)
    if (verbose & 1) == 1 : print "="*30
    return int(out)

def query_FcFrmCtr(fpgaid,linkid,chid,verbose=0):
  global debug
  cmd="rdwr -b %d link[%d].ch[%d].mtip_fc2.FcFrmCtr" % (fpgaid,linkid,chid)

  if (verbose & 2) == 2 : print cmd
  out=exec_cmd(cmd)
  if out == "":
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "FPGA %d link[%d].ch[%d].mtip_fc2.FcFrmCtr is %s" % (fpgaid,linkid,chid,out)
    if (verbose & 1) == 1 : print "="*30
    return out
  else:
    if (verbose & 1) == 1 : print "="*30
    if (verbose & 1) == 1 : print "FPGA %d link[%d].ch[%d].mtip_fc2.FcFrmCtr is %s" % (fpgaid,linkid,chid,out)
    if (verbose & 1) == 1 : print "="*30
    return int(out)


# test begin
fd=open_ttyUSB(device)

time.sleep(delay)
config_port(fd)
time.sleep(delay)
while 1:
  attenuation(fd,delay,low,high,incr,0)
os.close(fd)
# test end

