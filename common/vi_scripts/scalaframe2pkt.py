#!/bin/env python2
from daldatapacket import *
from intervalpacket1 import *
from intervalpacket2 import *
from intervalpacket3 import *
from pprint import pprint
import struct
class scalaframe2pkt:
  datapkts=[]
  intpkts=[[],[],[]]
  debug=False
  def __init__(self,file):
    """
    """
    with open(file,'rb') as f:
      self.data=f.read()
    f.close()
  def extract(self):
    """
    """
    while self.data:
      packetType=struct.unpack('B',self.data[0])[0]

      if packetType == 1:
        pkt=daldatapacket()
      elif packetType == 4:
        type=struct.unpack('<H',self.data[62:64])[0]
        #print '{0:016b}'.format(type)
        intervalStatsType=type & 0x7
        channel=type>>12 & 0x1
        link=(type>>8) & 0xf
        if self.debug:
          print "IntervalStatsType=",intervalStatsType
        if intervalStatsType==0:
          pkt=intervalpacket1()
        elif intervalStatsType==1:
          pkt=intervalpacket2()
        elif intervalStatsType==2:
          pkt=intervalpacket3()
      pkt.extract(self.data[:64])
      if self.debug:
        pkt.puts()
      if packetType == 1:
        self.datapkts.append(pkt.get())
      elif packetType == 4:
        if intervalStatsType==0:
          self.intpkts[0].append(pkt.get())
        elif intervalStatsType==1:
          self.intpkts[1].append(pkt.get())
        elif intervalStatsType==2:
          self.intpkts[2].append(pkt.get())
      self.data=self.data[64:]
if __name__=='__main__':
  import sys
  argc=len(sys.argv)
  if argc > 1: binf=sys.argv[1]
  obj=scalaframe2pkt(binf)
  obj.extract()
  pprint(obj.datapkts)
  pprint(obj.intpkts)
  
