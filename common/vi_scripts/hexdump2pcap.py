#!/usr/bin/env python2.7
from pcapgen import *
import zlib
class hexdump2pcap(object):
  def __init__(self,hexs):
    """
    """
    self.dbytes=map(lambda x: int(x,16),filter(lambda x: x !='',hexs.replace('\n',' ').split(' ')))
    if self.dbytes[-4:]==self.calcrc32(self.dbytes[-4:]):
      self.dbytes=self.dbyte[:-4]
      
  def calcrc32(self,bytes):
    """
    Calculate crc32
    """
    crcval=zlib.crc32("")
    for byte in bytes:
      crcval=zlib.crc32(chr(byte),crcval)
    if crcval >= 0:
      #crcval="%08x" % crcval
      crcval=crcval
    else:
      crcval=-crcval
      #crcval= "%08x" % ((crcval ^ 0xFFFFFFFF) + 1)
      crcval= ((crcval ^ 0xFFFFFFFF) + 1)
    return map(lambda x: int(('%08x'%crcval)[x*2:x*2+2],16),range(4))[::-1]


if __name__=='__main__':
  hexs='''
01 80  C2 00 00 0E  00 2A 6A 59  C1 8F 88 CC
02 07 04 00  2A 6A 59 C1  8F 04 07 07  45 74 68 31
2F 38 06 02  00 78 08 0B  45 74 68 65  72 6E 65 74
31 2F 38 0A  04 6E 35 6B  31 0C A1 43  69 73 63 6F
20 4E 65 78  75 73 20 4F  70 65 72 61  74 69 6E 67
20 53 79 73  74 65 6D 20  28 4E 58 2D  4F 53 29 20
53 6F 66 74  77 61 72 65  20 37 2E 32  28 30 29 4E
31 28 31 29  0A 54 41 43  20 73 75 70  70 6F 72 74
3A 20 68 74  74 70 3A 2F  2F 77 77 77  2E 63 69 73
63 6F 2E 63  6F 6D 2F 74  61 63 0A 43  6F 70 79 72
69 67 68 74  20 28 63 29  20 32 30 30  32 2D 32 30
31 35 2C 20  43 69 73 63  6F 20 53 79  73 74 65 6D
73 2C 20 49  6E 63 2E 20  41 6C 6C 20  72 69 67 68
74 73 20 72  65 73 65 72  76 65 64 2E  0E 04 00 04
00 04 10 0C  05 01 0A 0A  1A 6A 02 05  00 00 00 00
FE 37 00 1B  21 02 02 0A  00 00 00 00  00 01 00 00
00 04 06 06  00 00 80 00  08 08 08 0A  00 00 80 00
89 06 00 1B  21 08 04 11  00 00 80 00  00 01 00 00
32 32 00 00  00 00 00 00  02 FE 05 00  01 42 01 01
FE 14 00 01  42 02 05 DC  05 DC 05 DC  08 6E 05 DC
05 DC 05 DC  05 DC FE 06  00 80 C2 01  00 01 00 00
3D 38 D4 08  FD 07
'''
  obj=hexdump2pcap(hexs) 
  import sys
  argc=len(sys.argv)
  if argc > 1: pfile=sys.argv[1]
  if True:
    pcappkts=[]
    for i,pkt in enumerate([obj.dbytes]):
      pcaprecobj = pcaprecgen(
                              ts_sec                     = 0x00000000,
                              ts_usec                    = i*1000,
                              data                       = pkt,
                             )

      pcappkts.append(pcaprecobj.pktgen(pcaprecobj.db))
    #print pcappkts
    payload=[]
    for data in pcappkts:
      payload.extend(data)
    pcapobj=pcapgen(
                    magic_number                  = 0xa1b2c3d4,
                    version_major                 = 0x0002,
                    version_minor                 = 0x0004,
                    thiszone                      = 0x00000000,
                    sigfigs                       = 0x00000000,
                    snaplen                       = 0x0000ffff,
                    network                       = 0x00000001,
                    data                          = payload,
                   )
    dbytes= pcapobj.pktgen(pcapobj.db)
    #print map(lambda x: '%02x'%x,dbytes)
    #print len(dbytes)
    if False and argv > 1:
      pcapobj.writepcap(fname=pfile,dbytes=dbytes)
    else:
      pcapobj.writepcap(dbytes=dbytes)



