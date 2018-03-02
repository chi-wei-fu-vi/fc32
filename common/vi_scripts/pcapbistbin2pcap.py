#!/usr/bin/env python2.7
from pcapgen import *
import struct
class pcapbistbin2pcap(object):
  """
  """
  def __init__(self,fch0,fch1):
    """
    """
    self.ch0frames=self.readbin(fch0)
    self.ch1frames=self.readbin(fch1)

  def readbin(self,fname):
    """
    """
    frames=[]
    with open(fname,'rb') as fh:
      dbytes=fh.read()
      while len(dbytes) > 0:
        lword,=struct.unpack('>Q',dbytes[:8])
        frame_len=lword >> 48
        ts=lword & 0xffffffffffff
        frame_data=dbytes[8:frame_len+8]
        frames.append((ts,frame_data))
        next_frame=((frame_len+7)//8)*8 
        dbytes=dbytes[next_frame+8:] 
    return frames
  def writepcap(self,frames,pcapf):
    """
    """
    payload=[]
    for ts,data in frames:
      ts_sec=ts//100000000  # ts in 10 ns time unit
      ts_nsec=(ts%100000000)*10
      pcaprecobj = pcaprecgen(
                              ts_sec                     = ts_sec,
                              ts_usec                    = ts_nsec,
#                              data                       = map(ord,data[:-4])
                              data                       = map(ord,data)
                             )

      payload.extend(pcaprecobj.pktgen(pcaprecobj.db))
    pcapobj=pcapgen(
                    magic_number                  = 0xa1b23c4d,
                    version_major                 = 0x0002,
                    version_minor                 = 0x0004,
                    thiszone                      = 0x00000000,
                    sigfigs                       = 0x00000000,
                    snaplen                       = 0x0000ffff,
                    network                       = 0x00000001,
                    data                          = payload,
                   )
    pcapobj.writepcap(fname=pcapf,dbytes=pcapobj.pktgen(pcapobj.db))

  def mergeframes(self,frame0s,frame1s):
    frames=[]
    idx0=0
    idx1=0
    while True:
      t0=frame0s[idx0][0]
      t1=frame1s[idx1][0]
      if t0 < t1:
        frames.append(frame0s[idx0])  
        if idx0==len(frame0s)-1: # last one
          frames.extend(frame1s[idx1:])
          break
        else:
          idx0+=1
      elif t0 > t1:
        frames.append(frame1s[idx1])  
        if idx1==len(frame1s)-1: # last one
          frames.extend(frame0s[idx0:])
          break
        else:
          idx1+=1
      else:
        print "Error: two frames have identical time stamp %d vs %d"%(idx0,idx1)
        break
    return frames
if __name__=='__main__':
  import sys
  argc=len(sys.argv)
  if argc > 1: fch0=sys.argv[1]
  if argc > 2: fch1=sys.argv[2]
  obj=pcapbistbin2pcap(fch0,fch1)

  obj.writepcap(obj.ch0frames,fch0.replace('.bin','.pcap'))
  obj.writepcap(obj.ch1frames,fch1.replace('.bin','.pcap'))
  frames=obj.mergeframes(obj.ch0frames,obj.ch1frames)
  obj.writepcap(frames,fch1.replace('ch1','merge').replace('.bin','.pcap'))
  
