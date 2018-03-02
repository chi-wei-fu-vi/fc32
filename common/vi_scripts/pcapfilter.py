#!/usr/bin/env python2.7
import sys
import os
import collections
import ctypes
import ctypes.util

libc = ctypes.cdll.LoadLibrary(ctypes.util.find_library("c"))
libpcap = ctypes.cdll.LoadLibrary(ctypes.util.find_library("pcap"))
libpcap.pcap_geterr.restype = ctypes.c_char_p
class pcapError(Exception):
  def __init__(self, value):
    super(pcapError, self).__init__("Error: libpcap %s" % value)

class pcap_ts_t(ctypes.Structure):
  #_pack_=1
  _fields_ = [
  ("ts_sec", ctypes.c_uint32),
  ("ts_usec", ctypes.c_uint64),
  ]
class pcap_pkthdr(ctypes.Structure):
  #_pack_=1
  _fields_ = [
  ("ts", pcap_ts_t),
  ("caplen", ctypes.c_uint32),
  ("pktlen", ctypes.c_uint32),
  ]

class pcapfilter(object):
  """
  """
  PCAP_ERRBUF_SIZE = 256
  pcap_errbuf = ctypes.create_string_buffer(PCAP_ERRBUF_SIZE)
  frame = collections.namedtuple("frame", ["header", "data"])
  def __init__(self,fname,pfilter=''):
    self.pcap = libpcap.pcap_open_offline(fname, self.pcap_errbuf)
    if not self.pcap:
      raise pcapError("Error3: fail to open pcap %s: %s" % (fname,pcap.errbuf.value))
    self.pkt_header = ctypes.pointer(pcap_pkthdr())
    self.pkt_data = ctypes.c_void_p()

  def close(self):
    libpcap.pcap_close(self.pcap)

  def set_filter(self, pfilter):
    bpf_program = ctypes.c_void_p()
    rerr = libpcap.pcap_compile(self.pcap, ctypes.byref(bpf_program), pfilter, 1, 0)
    if rerr != 0:
      raise pcapError("Error1: fail to compile filter: %s: %s" % (pfilter, self.get_error()))
    rerr = libpcap.pcap_setfilter(self.pcap, ctypes.byref(bpf_program))
    if rerr != 0:
      raise pcapError("Error2: fail to set filter: %s" % (self.get_error()))
  
  def get_error(self):
    return libpcap.pcap_geterr(self.pcap)

  def get_next(self):
    rc = libpcap.pcap_next_ex(self.pcap, ctypes.byref(self.pkt_header),ctypes.byref(self.pkt_data))
    if rc == 1:
      return self.frame(self.pkt_header.contents, self.pkt_data)
    elif rc in [-2, 0]:
      return None
    else:
      raise pcapError(self.get_error())
  class pcapDumper(object):
    """
    libpcap.pcap_dump wrapper
    """
    def __init__(self, pcap, fname):
      self.dumper = libpcap.pcap_dump_open(pcap.pcap, fname)
  
    def puts(self, packet):
      libpcap.pcap_dump(self.dumper, ctypes.byref(packet.header), packet.data)
      libpcap.pcap_dump_flush(self.dumper)
  
    def close(self):
      libpcap.pcap_dump_close(self.dumper)

if __name__=='__main__':
  """
  http://wiki.wireshark.org/CaptureFilters
  http://www.tcpdump.org/manpages/pcap-filter.7.html
  """
  import sys
  argc=len(sys.argv)
  if argc > 1: pfile=sys.argv[1]
  if True:
    obj=pcapfilter(pfile)
    obj.set_filter('udp')
    dumpobj=obj.pcapDumper(obj,'test.pcap')
    frame= obj.get_next()
    while frame:
      dumpobj.puts(frame)
      print frame.header.ts.ts_sec
      print frame.header.ts.ts_usec
      print frame.header.caplen
      print frame.header.pktlen
      caplen=frame.header.caplen
      #print frame.data
      UBYTEP=ctypes.POINTER(ctypes.c_ubyte)
      datap= ctypes.cast(frame.data,UBYTEP)
  
      print map(lambda x: '%02x'%ord(x),ctypes.cast(frame.data,ctypes.c_char_p).value[:caplen])
      print map(lambda x: '%02x'%datap[x],range(caplen))
      frame= obj.get_next()
    dumpobj.close()
    obj.close()
