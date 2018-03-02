#!/usr/bin/env python2
import time
import os, sys
import subprocess
import time
import string
speed2count={
0:531250,
1:1062500,
2:2125000,
3:4250000
}
speed2count_max={}
speed2count_min={}

def calminmax (percent):
  """
  """
  for speed in speed2count:
    speed2count_max[speed]=speed2count[speed]*(1.0+percent)
    speed2count_min[speed]=speed2count[speed]*(1.0-percent)

def program_fpga(rbf):
  """
  """
  cmd="fpga_load %s"%rbf
  proc = subprocess.Popen( cmd, shell=True, stdout = subprocess.PIPE, stderr = subprocess.PIPE )
  print out
  print error
  if proc.returncode !=0:
    print "ERROR: read/write error %s %s" % (out,error)

def load_ko(ko):
  """
  """
  cmd="insmod %s"%ko
  proc = subprocess.Popen( cmd, shell=True, stdout = subprocess.PIPE, stderr = subprocess.PIPE )
  print out
  print error
  if proc.returncode !=0:
    print "ERROR: read/write error %s %s" % (out,error)

def check_freq( linkid ):
  """
  """
  # channel 0
  cmd="rdwr global.g.clkrst.ClkCtrSerdes%d_0.TxClk" % linkid
  txfreq0=extract_freq(cmd)
  cmd="rdwr global.g.clkrst.ClkCtrSerdes%d_0.RxRecClk" % linkid
  rxfreq0=extract_freq(cmd)

  # channel 1
  cmd="rdwr global.g.clkrst.ClkCtrSerdes%d_1.TxClk" % linkid
  txfreq1=extract_freq(cmd)
  cmd="rdwr global.g.clkrst.ClkCtrSerdes%d_1.RxRecClk" % linkid
  rxfreq1=extract_freq(cmd)
  return ( rxfreq1, txfreq1, rxfreq0, txfreq0 )
  
def check_all_freqs( linkid, speed, prevspeed ):
  """
  """
  lines=[]
  cmd="rdwr global.g.clkrst"
  proc = subprocess.Popen( cmd, shell=True, stdout = subprocess.PIPE, stderr = subprocess.PIPE )
  out,error=proc.communicate()
  if proc.returncode !=0:
    print "ERROR: read/write error %s %s" % (out,error)
  else:
    i=0
    for line in out.split('\n'):
      line=line.strip()
      line=line.expandtabs()
      if 'ClkCtrSerdes' in line:
        index=line.index(':')
        line=line[index+1:]
        line=line.strip()
        index=line.index(' ')
        line=line[:index]
        if len(line) > 8:
          txclk=int(line[:-8],16)
          rxclk=int(line[-8:],16)
        else:
          txclk=0
          rxclk=int(line)
        if i > linkid*2+1:
          (txcolor,rxcolor)=check_freq(txclk,rxclk,prevspeed)
        else:
          (txcolor,rxcolor)=check_freq(txclk,rxclk,speed)
        lines.append("%s%8X%s%8X"%(txcolor,txclk,rxcolor,rxclk))
        i=i+1
  return " ".join(lines)
        
def check_freq(txclk,rxclk,speed):
  """
  """
  if txclk > speed2count_max[speed] or txclk < speed2count_min[speed]:
    txcolor = "\033[31m"
  else:
    txcolor = "\033[32m"
  if rxclk > speed2count_max[speed] or rxclk < speed2count_min[speed]:
    rxcolor = "\033[31m"
  else:
    rxcolor = "\033[32m"
  return txcolor,rxcolor

def extract_freq (cmd):
  proc = subprocess.Popen( cmd, shell=True, stdout = subprocess.PIPE, stderr = subprocess.PIPE )
  out,error=proc.communicate()
  if proc.returncode !=0:
    print "ERROR: read/write error %s %s" % (out,error)
    print error
    print out
  else:
    if ': ' in out:
      index=out.index(': ')
      out=out[index+2:]
      if ' ' in out:
        index=out.index(' ')
        out=out[:index]
        return int(out,16)
    else:
      print "ERROR: read/write error %s %s" % (out,error)

def exec_cmd (cmd):
  proc = subprocess.Popen( cmd, shell=True, stdout = subprocess.PIPE, stderr = subprocess.PIPE )
  out,error=proc.communicate()
  print out
  print error
  if proc.returncode !=0:
    print "ERROR: read/write error %s %s" % (out,error)

def speed_change ( linkid, speed ) :
  
  # set speed
  cmd = "rdwr link[%d].g.csr.LinkCtrl.LinkSpeed %d" % ( linkid , speed)
  print cmd
  exec_cmd(cmd)
  time.sleep(3.0)

  # check speed
  cmd = "rdwr link[%d].g.csr.LinkStatus" % ( linkid )
  print cmd
  exec_cmd(cmd)
  time.sleep(1.0)

  #for i in range(8):
  #  check_clock(i)


def check_clock ( linkid ):

  cmd = "rdwr global.g.clkrst.ClkCtrSerdes%d_0" % ( linkid )
  print cmd
  exec_cmd(cmd)

  cmd = "rdwr global.g.clkrst.ClkCtrSerdes%d_1" % ( linkid )
  print cmd
  exec_cmd(cmd)

def logout(file,iteration):
  """
  """
  OUTFILE=open(file,"w")
  prevspeed=3
  for i in range(iteration):
   lines=[]
   for speed in range(4):
     #freqs=[]
     for linkid in range(8):
       #chfreqs=[] 
       speed_change(linkid,speed)
       #chfreqs.append(check_freq( linkid ))
       #freqs.append(chfreqs)
       line='\033[30m%d: %s'% (linkid,check_all_freqs(linkid, speed, prevspeed))
       lines.append(line)
       #print line
       #OUTFILE.write(line)
     prevspeed=speed
     #print '='*240
     #OUTFILE.write('='*240)
   outline= "\n".join(lines)
   print '%s\033[30m'%outline
   OUTFILE.write("%s\033[30m\n"%outline)
  OUTFILE.close()
  filter_extra_char(file)

def filter_extra_char(file):
  """
  """
  INFILE=open(file,"r")
  lines=INFILE.readlines()
  INFILE.close()

  OUTFILE=open(file,"w")
  outlines=[]
  while lines:
    line=lines.pop(0)
    line=line.strip()
    if line.startswith("addr:"):
      continue
    elif 'addr:' in line:
      index=line.index('addr:')
      line=line[:index]
      tmpline=lines.pop(0)
      tmpline=line.strip()
      tmpline=tmpline.replace('7:','')
      line=line+tmpline
      outlines.append(line)
    else:
      outlines.append(line)

      
     
  OUTFILE.write("\n".join(outlines))
  OUTFILE.close()

if __name__ == '__main__':
  """ 
  """
  import sys 
  argc=len(sys.argv)

  log="/tmp/log%s"%time.time()
  calminmax(0.05)
  logout(log,10)
