#!/usr/bin/env python2.7
import os
import gzip
import zlib
import struct
import time
import re
import datetime
from headerstripper_new import *
from pprint import pprint,pformat

fix_short_frame=1

class pcap2bin(object):
  """
  """
  outs=[[],[]]            # binary image
  def __init__(self,pfile):
    """
    """
    channels=process (pfile)
    self.outs=[[],[]]
    offset=min(int(float(channels[0][0][0])*100000000),int(float(channels[1][0][0])*100000000))
    for chno,channel in enumerate(channels,1):
      for ts,dbytes in channel:
        ts=int(float(ts)*100000000)-offset   # 10ns time unit
        if dbytes[-4:]==map(lambda x: int(x,16),self.calcrc32(dbytes[:-4])):
           crcval=dbytes[-4:]
           dbytes=dbytes[:-4]
        if fix_short_frame:
          if len(dbytes) < 60:
            print "Pad %d zeros to Ethernet frame"%(60-len(dbytes))
            dbytes.extend([0]*(60-len(dbytes)))
        dbytes.extend(map(lambda x: int(x,16),self.calcrc32(dbytes)))
        self.outs[chno%2].append((len(dbytes),ts,dbytes,0))
      
  def genbin(self,file,pkts):
    """
    """
    with open(file,'wb') as f:
      for length,ts,dbytes,sa in pkts:
        f.write(struct.pack('>H',length))  # big endian
        for byte in filter(lambda x: x!='',re.split('([0-9a-f]{2})','%012x'%ts)):
          f.write(struct.pack('B',int(byte,16)))
        for byte in dbytes:
          f.write(struct.pack('B',byte))
        if length%8 !=0: 
          for byte in range(8-(length %8)):
            f.write(struct.pack('B',0))
      f.close()
  def calcrc32(self,dbytes):
    """
    Calculate crc32
    """
    crcval=zlib.crc32("")
    for byte in dbytes:
      crcval=zlib.crc32(chr(byte),crcval)
    if crcval >= 0:
      crcval="%08x" % crcval
    else:
      crcval=-crcval
      crcval= "%08x" % ((crcval ^ 0xFFFFFFFF) + 1)
    #print filter(lambda x: x!='',re.split('([0-9a-f]{2})',crcval))[::-1]
    return filter(lambda x: x!='',re.split('([0-9a-f]{2})',crcval))[::-1]

if __name__ == '__main__': 
  """
  """
  import sys
  argv=sys.argv
  if '-disable_fix_short_frame' in argv: 
    fix_short_frame=0
    argv.remove('-disable_fix_short_frame')
  
  argc=len(argv)
  if argc > 1: pcap    = argv[1]
  if argc > 2: outf    = argv[2]
  obj=pcap2bin(pcap)
  obj.genbin('%sch0.bin'%outf,obj.outs[0])
  obj.genbin('%sch1.bin'%outf,obj.outs[1])
