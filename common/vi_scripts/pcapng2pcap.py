#!/usr/bin/env python2.7
import os
import gzip
import zlib
import struct
import time
import re
import datetime
from pcap_header import *
from pcapng_parser import *
from pcapgen import *
from pprint import pprint,pformat


class pcapng2pcap(object):
  """
  """
   
  pkts=[]
  def __init__(self,fname,debug=False):
    """
    """
    def timestamp(tsresol,ts_high,ts_low):
      """
      """
      ts_low_s='%d'%ts_low
      ts_high_s='%d'%(ts_high<<32)
      if tsresol >6:
        nsec_digits=tsresol-6
        usec_digits=6
      else:
        nsec_digits=0
        usec_digits=tsresol
      if nsec_digits > 0:
        nsec_low=int(ts_low_s[-nsec_digits:])
        nsec_high=int(ts_high_s[-nsec_digits:])
        ts_low_s=ts_low_s[:-nsec_digits]
        ts_high_s=ts_high_s[:-nsec_digits]
        if usec_digits > 0:
          usec_low=int(ts_low_s[-usec_digits:])
          usec_high=int(ts_high_s[-usec_digits:])
          sec_low=int(ts_low_s[:-usec_digits])
          sec_high=int(ts_high_s[:-usec_digits])
        else:
          usec_low=0
          usec_high=0
          sec_low=int(ts_low_s)
          sec_high=int(ts_high_s)
      else:
        nsec_low=0
        nsec_high=0
        if usec_digits > 0:
          usec_low=int(ts_low_s[-usec_digits:])
          usec_high=int(ts_high_s[-usec_digits:])
          sec_low=int(ts_low_s[:-usec_digits])
          sec_high=int(ts_high_s[:-usec_digits])
        else:
          usec_low=0
          usec_high=0
          sec_low=int(ts_low_s)
          sec_high=int(ts_high_s)
      nsec=nsec_low+nsec_high
      print sec_low,sec_high
      if nsec > 1000:
        ts_nsec=nsec%1000
        usec=usec_low+usec_high+(ts_nsec//1000)
        if usec > 1000000:
          ts_usec=usec%1000000
          ts_sec=sec_low+sec_high+(ts_usec//1000)
        else:
          ts_usec=usec
          ts_sec=sec_low+sec_high
      else:
        ts_nsec=nsec
        usec=usec_low+usec_high
        if usec > 1000000:
          ts_usec=usec%1000000
          ts_sec=sec_low+sec_high+(ts_usec//1000)
        else:
          ts_usec=usec
          ts_sec=sec_low+sec_high
      return ts_sec,ts_usec,ts_nsec
    if fname.endswith('ng') or fname.endswith('ng.gz'): # pcapng
      pcapngobj=pcapng_parser()
      pcapngobj.read(fname)
      pcapngobj.check_endian(pcapngobj.dbytes)
      pcapngobj.parse_block(pcapngobj.dbytes)
      ts_sec=0
      ts_usec=0
      ts_nsec=0
      for pktno,(ts_high,ts_low,dbytes) in enumerate(pcapngobj.pkts,1):
        dbytes=list(dbytes)
        tsresol=pcapngobj.tsresol
        if tsresol > 9:
          print "ERROR: timestamp resolution is greater than ns",pcapngobj.tsresol
          exit(1)
        if len(dbytes) < 60:
          print "Warning: Ethernet frame %d length of %d is less than 60 (exclude CRC 4bytes)"%(pktno,len(dbytes))
          if fix_short_frame:
            print "Pad %d zeros to Ethernet frame"%(60-len(dbytes))
            dbytes.extend([0]*(60-len(dbytes)))
        ts=long(ts_high<<32)+long(ts_low)
        ts_s="%064d"%ts
        if tsresol > 6:
          ts_nsec=int(ts_s[-(tsresol-6):])
          ts_usec=int(ts_s[-tsresol:-(tsresol-6)])
          ts_sec=int(ts_s[:-tsresol])
        elif tsresol > 0:
          ts_nsec=0
          ts_usec=int(ts_s[-tsresol:])
          ts_sec=int(ts_s[:-tsresol])
        else:
          ts_nsec=0
          ts_usec=0
          ts_sec=ts
        self.pkts.append((ts_sec,ts_usec,ts_nsec,dbytes))
        if debug:
          print ts_sec,ts_usec,ts_nsec,dbytes
    else:
      pass
  def writepcap(self,fname):
    """      
    """      
    records=[]
    for ts_sec,ts_usec,ts_nsec,dbytes in self.pkts:
      pcaprecobj = pcaprecgen(
                              ts_sec                     = ts_sec,
                              ts_usec                    = ts_usec*1000000+ts_nsec,
                              data                       = dbytes,
                             )
      records.append(pcaprecobj.pktgen(pcaprecobj.db))
     

    pcapbobj=pcapgen(
#               magic_number                  = 0xa1b2c3d4,
                magic_number                  = 0xa1b23c4d,
                version_major                 = 0x0002,
                version_minor                 = 0x0004,
                thiszone                      = 0x00000000,
                sigfigs                       = 0x00000000,
                snaplen                       = 0x0000ffff,
                network                       = 0x00000001,
                data                          = reduce(lambda x,y: x+y,records),
               )
    dbytes=pcapbobj.pktgen(pcapbobj.db)
    pcapbobj.writepcap(fname=fname,dbytes=dbytes)
   
if __name__ == '__main__': 
  """
  """
  import sys
  argv=sys.argv
  argc=len(sys.argv)
  if argc > 1: pcapngfile  = argv[1]
  if argc > 2: pcapfile    = argv[2]
  obj=pcapng2pcap(pcapngfile,debug=False)
  obj.writepcap(pcapfile)
