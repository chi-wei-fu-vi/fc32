#!/usr/bin/env python2
import os, sys
from emerald_reg_access import *

def hex2dec(number):
  """
  """
  number=number.replace('_','')
  return int(number,16)

class txbist:
  regrw=None
  def __init__(self,fpgaid,chid):
    """
    """
    self.regrw=bist_tx_ch(fpgaid,chid)

  def readmif(self,file):
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
  
  def read_ram_and_compare_with_mif(self,file):
    """
    """
    (ctrls,datas,depth)=self.readmif(file)
    # set data space
    self.regrw.write('control_space',hex2dec('0'))
    # write data
    for i,data in enumerate(datas):
      self.regrw.write('txbist_rd_addr',i)
      out = self.regrw.read('txbist_rd_data')
      if data != out:
        print "Error: read %s and expect %s in location %d"%(out,data,i)
      else:
        print "Match: read %s and expect %s in location %d"%(out,data,i)
    # set control space
    self.regrw.write('control_space',hex2dec('1'))
    for i,ctrl in enumerate(ctrls):
      self.regrw.write('txbist_rd_addr',i)
      out = self.regrw.read('txbist_rd_data')
      if ctrl != out:
        print "Error: read %s and expect %s in location %d"%(out,ctrl,i)
      else:
        print "Match: read %s and expect %s in location %d"%(out,ctrl,i)
  
  def write_mif_to_ram(self,file):
    """
    """
    (ctrls,datas,depth)=self.readmif(file)
    # write starting address
    self.regrw.write('txbist_wr_addr',hex2dec('0'))
    # set data space
    self.regrw.write('control_space',hex2dec('0'))
    # write data
    for data in datas:
      self.regrw.write('txbist_wr_data',hex2dec(data))
    # write starting address
    self.regrw.write('txbist_wr_addr',hex2dec('0'))
    # set control space
    self.regrw.write('control_space',hex2dec('1'))
    for ctrl in ctrls:
      self.regrw.write('txbist_wr_data',hex2dec(ctrl))
      
        
  def txbist_init(self,file):
    """
    """
    (ctrls,datas,depth)=readmif(file)
    # ipg number
    self.regrw.write('txbist_ipg_min',4)
    # write end address
    self.regrw.write('txbist_ram_end',depth-1)
    # write loop count
    self.regrw.write('txbist_loop_cnt',0)
    # Tx mode
    self.regrw.write('mode',1)

if __name__ == '__main__':
  import sys
  argc=len(sys.argv)
  if argc > 1: mif=sys.argv[1]

  fpgaid=1
  chid=1
  data=0x123456
  txbist_1=txbist(fpgaid,chid)
  bitfield='txbist_tx_frame_cnt'
  shift,mask=txbist_1.regrw._bitfield2mask(bitfield)
  txbist_1.regrw.read(bitfield)
  txbist_1.regrw.write(bitfield,data)
  print bitfield,shift,"%016x"%mask
  bitfield='size'
  shift,mask=txbist_1.regrw._bitfield2mask(bitfield)
  print bitfield,shift,"%016x"%mask
  txbist_1.write_mif_to_ram(mif)
  txbist_1.read_ram_and_compare_with_mif(mif)

