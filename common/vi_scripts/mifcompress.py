#!/usr/bin/env python2.7
import re
import os
class mifcompress:
  """
  """
  depth=0
  tx_frame_cnt=0
  def __init__(self,file):
    """
    """

    self.readmif(file)
    self.compress()

  def readmif(self,file):
    """
    """
    INFILE=open(file,'r')
    self.datas=[]
    self.tx_frame_cnt=0
    for line in INFILE.readlines():
      line=line.lstrip()
      line=line.rstrip('\n')
      if line.startswith('DEPTH='):
        self.depth=int(line[6:-1])
      elif ':' in line:
        if '--' in line:
          index=line.index('--')
          comment=line[index+3:]
          if 'pkt' in line:
            self.tx_frame_cnt+=1
        else:
          comment=''
        index=line.index(':')
        line=line[index+1:].strip()
        index=line.index(';')
        line=line[:index].strip()
        if line.startswith('55'):
          cnt=int(line[2:],16)
          self.datas[-1][1]=cnt+1
        else:
          self.datas.append([line,1,comment])
    INFILE.close()


  def compress(self):
    """
    keep out the last 8 lines
    """
    self.compresses=[]
    #for i,data in enumerate(self.datas):
    for i,(data,cnt,comment) in enumerate(self.datas[:-8]):
      if i==0:
        repeat_cnt=cnt
      elif data==self.datas[i-1][0]:
        repeat_cnt+=cnt
      else:
        self.compresses.append((self.datas[i-1][0],repeat_cnt,self.datas[i-1][2]))
        repeat_cnt=cnt
  
    self.compresses.append((self.datas[len(self.datas)-9][0],repeat_cnt,comment))
    self.compresses+=self.datas[-8:]

  def writemif(self,file):
    """
    """
    OUTFILE=open(file,'w')
    lines=[]
    lines.append('')
    cnt=0
    ts_cnt=0
    for i,fs in enumerate(self.compresses):
      (data,repeat_cnt,comment)=fs
      if repeat_cnt < 4:
        for i in range(repeat_cnt):
          if comment=='':
            lines.append("%10d : %s;"%(cnt,data))
          else:
            if 'pkt' in comment:
              lines.append("%10d : %s;    -- %s"%(cnt,data,comment+' {} {} us'.format(ts_cnt,ts_cnt*6.4/1000)))
              #lines.append("%10d : %s;    -- %s"%(cnt,data,comment))
            else:
              lines.append("%10d : %s;    -- %s"%(cnt,data,comment))
          cnt+=1
      else:
        if comment=='':
          lines.append("%10d : %s;"%(cnt,data))
        else:
          lines.append("%10d : %s;    -- %s"%(cnt,data,comment))
        cnt+=1
        lines.append("%10d : %02x%016x;    -- %s"%(cnt,0x55,repeat_cnt-1,'repeat %d'%(repeat_cnt-1)))
        cnt+=1
      ts_cnt+=repeat_cnt+1 
          
    lines[0]="""
DEPTH=%d;
WIDTH=72;
ADDRESS_RADIX=UNS;
DATA_RADIX=HEX;

CONTENT BEGIN
"""%cnt
    lines.append("END;")
    
    OUTFILE.write("\n".join(lines))
    OUTFILE.close()



  
  

if __name__ == '__main__':
  import sys
  argc=len(sys.argv)
  if argc > 1 : mifin  = sys.argv[1]
  if argc > 2 : mifout = sys.argv[2]
  obj=mifcompress(mifin)
  obj.writemif(mifout)
