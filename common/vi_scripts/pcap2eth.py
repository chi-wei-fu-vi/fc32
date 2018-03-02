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
from pprint import pprint,pformat

big_endian=0
limit_mif_size=0
enable_txbist=0
fix_ip_checksum=1
fix_tcp_checksum=1
fix_short_frame=1
frame_crc_error=0
txbist_size=4096
flowid2bytes={}
start_frame_en=0
start_frame=0
end_frame_en=0
end_frame=0
ts_mif_gen_en=0

class datastruct(object):
  decodes={}
  def __init__(self,*kwts,**kwds):
    """
    for examples, create data struct obj.a and obj.b
      obj=datastruct(a=1, b=2)
      obj=datastruct({'a':1,'b':2)
      obj=datastruct(['a','b'],[1,2])
    """
    self.decodes['flavor']=pcap2eth.rpc_hdr.auth_flavor.inv_map
    ks=None
    for f in kwts:
      if type(f) == dict:
        self.__dict__.update(f)
      elif type(f) == list or type(item) == tuple:
        if ks is None:
          ks=f
        else:
          self.__dict__.update(zip(ks,f))
          ks=None
    self.__dict__.update(kwds)
  def get(self):
    """
    Class name : self.__class__.__name__
    array      : getattr(self,'_itemlist',None)
    dict       : self.__dict__.iterkeys()
    """
    outs=[]
    for key in sorted(self.__dict__.iterkeys()):
      if key[0] != '_':
        val = self.__dict__.get(key, None)
        if val != None:
          value = pformat(val)
          if key in self.decodes:
            outs.append("%-15s : %s (%s)" % (key, self.decodes[key][int(value)],value))
          else:
            outs.append("%-15s : %s" % (key, value))
        else:
          outs.append("%-15s : None" % key)
    return outs
class pcap2eth(object):
  """
  """
  data=[]
  pkts=[]
  outs=[[],[]]            # binary image
  simouts=[[],[]]         # sim binary image
  pktgrps=[[],[]]
  sims=[[],[]]            # mif
  mifouts=[[],[]]            # mif
  ts_in_cycles=[]
  IPG_LEN  = int(5.*156.25*8)+7 # 5us/156.25MHz*8 idles
  IPG_LEN_5us  = int(5.*156.25*8)+7 # 5us/156.25MHz*8 idles
  IPG_LEN_16idles  = 16 # 16 idles
  MAX_DEP  = 2048
  class eth_hdr:
    def __init__(self,pkt,debug=False):
      def vlan_hdr(vlans,pkt,debug=False):
        """
        Priority Code Point (PCP): a 3-bit field which refers to the IEEE 802.1p priority. 0 (best effort) to 7 (highest); 1 represents the lowest priority. Class of Service or CoS.
        Drop Eligible Indicator (DEI): a 1-bit field. (formerly CFI) May be used separately or in conjunction with PCP to indicate frames eligible to be dropped in the presence of congestion.
        VLAN Identifier (VID): Values of 0x000 and 0xFFF are reserved. All other values may be used as VLAN identifiers, allowing up to 4,094 VLANs. The reserved value 0x000 indicates that the frame does not belong to any VLAN; in this case, the 802.1Q tag specifies only a priority and is referred to as a priority tag. On bridges, VLAN 1 (the default VLAN ID) is often reserved for a management VLAN; this is vendor-specific.
        """
        ethertype=pkt[:2]
        ethertype="".join(map(lambda x: '%02x'%x,ethertype))
        if ethertype=='8100':   # tpid
          cos=(pkt[2]&0xe0) >> 5
          cfi=(pkt[2]&0x10) >> 4
          vlanid=(pkt[2]&0x0f)*256+pkt[3]
          if debug:
            print "cos       : %d"%cos               # pcp
            print "cfi       : %d"%cfi               # dei
            print "vlanid    : %03x"%vlanid
          vlans.append((cos,cfi,vlanid))
          (vlans,ethertype,payload)=vlan_hdr(vlans,pkt[4:])
          return vlans,ethertype,payload
        else:
          return vlans,ethertype,pkt[2:]
      self.crc=pkt[-4:]
      pkt=pkt[:-4]
      da=pkt[:6]
      self.da="".join(map(lambda x: '%02x'%x,da))
      sa=pkt[6:12]
      self.sa="".join(map(lambda x: '%02x'%x,sa))
      if debug:
        print "da        : %s"%da
        print "sa        : %s"%sa
      self.vlans=[]
      (self.vlans,self.ethertype,self.payload)=vlan_hdr([],pkt[12:])
      if debug:
        print "type      : %s"%self.ethertype

  class ip_hdr:
    """
    0                   1                   2                   3
    0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |Version|  IHL  |Type of Service|          Total Length         |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |         Identification        |Flags|      Fragment Offset    |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |  Time to Live |    Protocol   |         Header Checksum       |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |                       Source Address                          |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |                    Destination Address                        |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |                    Options                    |    Padding    |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

  Version:  4 bits 

  IHL:  4 bits Internet Header Length in 4-byte multiple

  Type of Service:  8 bits

      Bits 0-2:  Precedence.
      Bit    3:  0 = Normal Delay,      1 = Low Delay.
      Bits   4:  0 = Normal Throughput, 1 = High Throughput.
      Bits   5:  0 = Normal Relibility, 1 = High Relibility.
      Bit  6-7:  Reserved for Future Use.

         0     1     2     3     4     5     6     7
      +-----+-----+-----+-----+-----+-----+-----+-----+
      |                 |     |     |     |     |     |
      |   PRECEDENCE    |  D  |  T  |  R  |  0  |  0  |
      |                 |     |     |     |     |     |
      +-----+-----+-----+-----+-----+-----+-----+-----+

        Precedence

          111 - Network Control
          110 - Internetwork Control
          101 - CRITIC/ECP
          100 - Flash Override
          011 - Flash
          010 - Immediate
          001 - Priority
          000 - Routine

  Total Length:  16 bits Total Length is the length of the datagram, measured in octets,

  Identification:  16 bits identify fragments of a datagram.

  Flags:  3 bits

      Bit 0: reserved, must be zero
      Bit 1: (DF) 0 = May Fragment,  1 = Don't Fragment.
      Bit 2: (MF) 0 = Last Fragment, 1 = More Fragments.

          0   1   2
        +---+---+---+
        |   | D | M |
        | 0 | F | F |
        +---+---+---+

  Fragment Offset:  13 bits

  Time to Live:  8 bits

  Protocol:  8 bits

  Header Checksum:  16 bits

  Source Address:  32 bits

  Destination Address:  32 bits

  Options:  variable

    The option field is variable in length.  There may be zero or more
    options.  There are two cases for the format of an option:

      Case 1:  A single octet of option-type.

      Case 2:  An option-type octet, an option-length octet, and the
               actual option-data octets.
    Version                                     4 for IPv4
    Internet Header Length (IHL)                in bytes
    Differentiated Services Code Point (DSCP)   RFC 2474 for Differentiated services (DiffServ). 
    Explicit Congestion Notification (ECN)      allows end-to-end notification of network congestion without dropping packets
    Total Length                                defines the entire packet (fragment) size, including header and data, in bytes.
    Identification                              primarily used for uniquely identifying the group of fragments of a single IP datagram.
    Flags                                       bit 0: Reserved; must be zero.
                                                bit 1: Don't Fragment (DF)
                                                bit 2: More Fragments (MF)
    Fragment Offset                             in eight-byte blocks (64 bits)
    Time To Live (TTL)                          a hop count-down when arrives at a router, the router decrements the TTL field by one.
    Protocol
                                                Number  Name                                    Abbreviation
                                                1       Internet Control Message Protocol       ICMP
                                                2       Internet Group Management Protocol      IGMP
                                                6       Transmission Control Protocol           TCP
                                                17      User Datagram Protocol                  UDP
                                                41      IPv6 encapsulation                      ENCAP
                                                89      Open Shortest Path First                OSPF
                                                132     Stream Control Transmission Protocol    SCTP
    Source address
    Destination address
    Options                                     The options field is not often used. 
    """
    def calc_checksum(self,
                      word=5,
                      dbytes=map(lambda x: int(x,16),filter(lambda x: x!='',re.split('([0-9a-f]{2})','4500003c1c46400040060000ac100a63ac100a0c')))):
      """
       checksum=[177, 230] or b1e6
      """
      def double_checksum(dbytes):
        def carry_around_add(a, b):
          c = a + b
          return ((c & 0xffff) + (c >> 16))&0xffff
        s = 0
        for i in range(0, len(dbytes), 2):
          w = (dbytes[i] <<8) + dbytes[i+1]
          s = carry_around_add(s, w)
        return ~s & 0xffff
      sum_hword   ='%x'%reduce(lambda x,y:x+y,map(lambda x: dbytes[x]*256+dbytes[x+1],range(0,4*word,2)))
      if len(sum_hword) > 4:
        sum_endcarry=(int(sum_hword[:-4],16)+int(sum_hword[-4:],16))
      else:
        sum_endcarry=int(sum_hword,16)
      if sum_endcarry >> 16:
        sum_endcarry='%x'%sum_endcarry
        sum_endcarry=int(sum_endcarry[:-4],16)+int(sum_endcarry[-4:],16)
       
      checksum    ='%04x'%(~sum_endcarry&0xffff)
      if checksum != ("%04x"% double_checksum(dbytes)):
        print "mismatch checksum %s vs %s "%(checksum,("%04x"% double_checksum(dbytes)))
        print "len(sum_hword)=%d 0x%s"%(len(sum_hword),sum_hword)
        checksum=("%04x"% double_checksum(dbytes))
      return map(lambda x: int(x,16),filter(lambda x: x!='',re.split('([0-9a-f]{2})',checksum)))
    def check_checksum(self,
                       hdr_type,
                       word=5,
                       checksum=['44','2e'],
                       dbytes=map(lambda x: int(x,16),filter(lambda x: x!='',re.split('([0-9a-f]{2})','4500003044224000800600008c7c19acae241e2b')))):
      def double_checksum(dbytes):
        def carry_around_add(a, b):
          c = a + b
          return ((c & 0xffff) + (c >> 16))&0xffff
        s = 0
        for i in range(0, len(dbytes), 2):
          w = (dbytes[i] <<8) + dbytes[i+1]
          s = carry_around_add(s, w)
        return ~s & 0xffff
      sum_hword   ='%x'%reduce(lambda x,y:x+y,map(lambda x: dbytes[x]*256+dbytes[x+1],range(0,4*word,2)))
      if len(sum_hword) > 4:
        sum_endcarry=int(sum_hword[:-4],16)+int(sum_hword[-4:],16)
      else:
        sum_endcarry=int(sum_hword,16)
      if sum_endcarry >> 16:
        sum_endcarry='%x'%sum_endcarry
        sum_endcarry=int(sum_endcarry[:-4],16)+int(sum_endcarry[-4:],16)
      cal_checksum    ='%04x'%(~sum_endcarry&0xffff)
      if cal_checksum != ("%04x"% double_checksum(dbytes)):
        print "mismatch checksum %s vs %s "%(checksum,("%04x"% double_checksum(dbytes)))
        print "len(sum_hword)=%d 0x%s"%(len(sum_hword),sum_hword)
        cal_checksum=("%04x"% double_checksum(dbytes))
      cal_checksum= filter(lambda x: x!='',re.split('([0-9a-f]{2})',cal_checksum))
      if checksum != cal_checksum:
        print "Error: %s checksum error %s vs %s"%(hdr_type,checksum,cal_checksum)
         
    def __init__(self,dbytes):
      self.version=(dbytes[0] & 0xf0) >> 4
      self.ihl=dbytes[0] & 0xf
      self.dscp=(dbytes[1] & 0xfc) >> 2
      self.ecn=dbytes[1] & 0x3
      self.length=int(''.join(map(lambda x: '%02x'%x,dbytes[2:4])),16)
      self.Id=int(''.join(map(lambda x: '%02x'%x,dbytes[4:6])),16)
      self.flags='{0:03b}'.format((dbytes[6] & 0xe000) >> 14)
      self.ip_fragment=self.flags[2] == '1'
      self.offset=int(''.join(map(lambda x: '%02x'%x,[dbytes[6]&0x1f,dbytes[7]])),16)
      self.ttl=dbytes[8]
      self.proto=dbytes[9]
      self.checksum=map(lambda x: '%02x'%x,dbytes[10:12])
      self.saddr='.'.join(map(lambda x: '%d'%x,dbytes[12:16]))
      self.daddr='.'.join(map(lambda x: '%d'%x,dbytes[16:20]))
      if self.ihl > 5:
        self.option=''.join(map(lambda x: '%02x'%x,dbytes[20:4*self.ihl]))
      else:
        self.option=''
      #self.check_checksum('IP',self.ihl,self.checksum,dbytes[:10]+[0]*2+dbytes[12:4*self.ihl])
      self.calchecksum=self.calc_checksum(self.ihl,dbytes[:10]+[0]*2+dbytes[12:4*self.ihl])
      self.payload=dbytes[4*self.ihl:self.length]

    def pseudo_hdr(self,tcplength):
      """
      source address: 32 bits/4 bytes, taken from IP header
      destination address: 32bits/4 bytes, taken from IP header
      resevered: 8 bits/1 byte, all zeros
      protocol: 8 bits/1 byte, taken from IP header. In case of TCP, this should always be 6, which is the assigned protocol number for TCP.
      TCP Length: The length of the TCP segment, including TCP header and TCP data.
      """
      return map(lambda x: int(x),self.saddr.split('\x2e'))+ \
             map(lambda x: int(x),self.daddr.split('\x2e'))+ \
             [0]+ \
             [self.proto]+ \
             map(lambda x: int(x,16),filter(lambda x: x!='',re.split('([0-9a-f]{2})',('%04x'%tcplength))))
    def get(self):
      print """
      Version                                      %s
      Internet Header Length (IHL)                 %s
      Differentiated Services Code Point (DSCP)    %s
      Explicit Congestion Notification (ECN)       %s
      Total Length                                 %s
      Identification                               %s
      Flags                                        %s
      Fragment Offset                              %s
      Time To Live (TTL)                           %s
      Protocol                                     %s
      Header Checksum                              %s
      Source address                               %s
      Destination address                          %s
      Options                                      %s
      """%(
      self.version,
      self.ihl,
      self.dscp,
      self.ecn,
      self.length,
      self.Id,
      self.flags,
      self.offset,
      self.ttl,
      self.proto,
      self.checksum,
      self.saddr,
      self.daddr,
      self.option)
    
  class ipv6_hdr(ip_hdr):
    """
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |Version| Traffic Class |           Flow Label                  |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |         Payload Length        |  Next Header  |   Hop Limit   |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |                                                               |
   +                                                               +
   |                                                               |
   +                         Source Address                        +
   |                                                               |
   +                                                               +
   |                                                               |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |                                                               |
   +                                                               +
   |                                                               |
   +                      Destination Address                      +
   |                                                               |
   +                                                               +
   |                                                               |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

   Version              4-bit Internet Protocol version number = 6.
   Traffic Class        8-bit traffic class field.
   Flow Label           20-bit flow label.
   Payload Length       16-bit unsigned integer.  Length of the IPv6
                        payload, i.e., the rest of the packet following
                        this IPv6 header, in octets.  (Note that any
                        extension headers present are
                        considered part of the payload, i.e., included
                        in the length count.)
   Next Header          8-bit selector.  Identifies the type of header
                        immediately following the IPv6 header.  Uses the
                        same values as the IPv4 Protocol field
   Hop Limit            8-bit unsigned integer.  Decremented by 1 by
                        each node that forwards the packet. The packet
                        is discarded if Hop Limit is decremented to
                        zero.
   Source Address       128-bit address of the originator of the packet.
                        See [ADDRARCH].
   Destination Address  128-bit address of the intended recipient of the
                        packet (possibly not the ultimate recipient, if
                        a Routing header is present).

    """
    IPPROTO_HOPOPTS           = 0                                # Hop by hop header for v6 
    IPPROTO_IPV6              = 41                               # IPv6 encapsulated in IP 
    IPPROTO_ROUTING           = 43                               # Routing header for IPv6 
    IPPROTO_FRAGMENT          = 44                               # Fragment header for IPv6 
    IPPROTO_ICMPV6            = 58                               # ICMP for IPv6 
    IPPROTO_NONE              = 59                               # No next header for IPv6 
    IPPROTO_DSTOPTS           = 60                               # Destinations options 

    def pseudo_hdr(self,tcplength):
      """
      source address: 128 bits/16 bytes, taken from IP header
      destination address: 128 bits/16 bytes, taken from IP header
      TCP Length: The length of the TCP segment 32bit/4 bytes, including TCP header and TCP data. 
      resevered: 24 bits/3 byte, all zeros
      protocol: 8 bits/1 byte, taken from IP header. In case of TCP, this should always be 6, which is the assigned protocol number for TCP.
      """
      return map(lambda x: int(x),self.saddr.split(':'))+ \
             map(lambda x: int(x),self.daddr.split(':'))+ \
             map(lambda x: int(x,16),filter(lambda x: x!='',re.split('([0-9a-f]{2})',('%08x'%tcplength)))) + \
             [0,0,0]+ \
             [self.proto]

    def __init__(self,dbytes):
      self.ip_fragment=0
      self.version=(dbytes[0] & 0xf0) >> 4
      self.tc=((dbytes[0] & 0xf)<<4) | ((dbytes[1] & 0xf0)>>4)
      self.flabel=((dbytes[1] & 0x0f) << 16) | (dbytes[2] <<8) | dbytes[3]
      self.length=int(''.join(map(lambda x: '%02x'%x,dbytes[4:6])),16)
      self.nheader=dbytes[6]
      self.hoplimit=dbytes[7]
      self.saddr=':'.join(map(lambda x: '%d'%x,dbytes[8:24]))
      self.daddr=':'.join(map(lambda x: '%d'%x,dbytes[24:40]))
      self.payload=dbytes[40:]
      while True:
        if self.nheader == self.IPPROTO_IPV6:
          print "ERROR: IPv6 encapsulated in IPv6"
          exit(1)
        elif self.nheader == self.IPPROTO_NONE:
          self.proto = self.nheader
          break
        elif self.nheader == self.IPPROTO_ICMPV6:
          self.proto = self.nheader
          break
        elif self.nheader == self.IPPROTO_HOPOPTS or self.nheader == self.IPPROTO_ROUTING or self.nheader == self.IPPROTO_FRAGMENT or self.nheader == self.IPPROTO_DSTOPTS:
          self.payload=self.nheader_parse(self.payload)
        else:
          self.proto = self.nheader
          break

    def nheader_parse(self,dbytes):
      """
   +---------------+------------------------
   |  IPv6 header  | TCP header + data
   |               |
   | Next Header = |
   |      TCP      |
   +---------------+------------------------

   +---------------+----------------+------------------------
   |  IPv6 header  | Routing header | TCP header + data
   |               |                |
   | Next Header = |  Next Header = |
   |    Routing    |      TCP       |
   +---------------+----------------+------------------------

   +---------------+----------------+-----------------+-----------------
   |  IPv6 header  | Routing header | Fragment header | fragment of TCP
   |               |                |                 |  header + data
   | Next Header = |  Next Header = |  Next Header =  |
   |    Routing    |    Fragment    |       TCP       |
   +---------------+----------------+-----------------+-----------------
      """
      def parse_hopopts(dbytes):
        """
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    |  Next Header  |  Hdr Ext Len  |                               |
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+                               +
    |                                                               |
    .                                                               .
    .                            Options                            .
    .                                                               .
    |                                                               |
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

   Next Header          8-bit selector.  Identifies the type of header immediately following the Destination Options header.

   Hdr Ext Len          8-bit unsigned integer.  Length of the Destination Options header in 8-octet units, not including the first 8 octets.

   Options              Variable-length field

        """
        self.nheader=dbytes[0]
        length=dbytes[1]
        return dbytes[(length+1)*8:]
      def parse_routing(dbytes):
        """
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    |  Next Header  |  Hdr Ext Len  |  Routing Type | Segments Left |
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    |                                                               |
    .                                                               .
    .                       type-specific data                      .
    .                                                               .
    |                                                               |
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

   Next Header          Identifies the type of header immediately following the Routing header.

   Hdr Ext Len          8-bit unsigned integer.  Length of the Routing header in 8-octet units, not including the first 8 octets.

   Routing Type         8-bit identifier of a particular Routing header variant.

   Segments Left        8-bit unsigned integer.  Number of route
                        segments remaining, i.e., number of explicitly
                        listed intermediate nodes still to be visited
                        before reaching the final destination.

   type-specific data   Variable-length field, of format determined by
                        the Routing Type, and of length such that the
                        complete Routing header is an integer multiple
                        of 8 octets long.
        """
        self.nheader=dbytes[0]
        length=dbytes[1]
        return dbytes[(length+1)*8:]
      def parse_fragment(dbytes):
        """
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |  Next Header  |   Reserved    |      Fragment Offset    |Res|M|
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |                         Identification                        |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

   Next Header          8-bit selector.  Identifies the initial header
                        type of the Fragmentable Part of the original
                        packet (defined below).  Uses the same values as
                        the IPv4 Protocol field [RFC-1700 et seq.].

   Reserved             8-bit reserved field.  Initialized to zero for
                        transmission; ignored on reception.

   Fragment Offset      13-bit unsigned integer.  The offset, in 8-octet
                        units, of the data following this header,
                        relative to the start of the Fragmentable Part
                        of the original packet.

   Res                  2-bit reserved field.  Initialized to zero for
                        transmission; ignored on reception.

   M flag               1 = more fragments; 0 = last fragment.

   Identification       32 bits.  See description below.

   fragment packets:

   +------------------+--------+--------------+
   |  Unfragmentable  |Fragment|    first     |
   |       Part       | Header |   fragment   |
   +------------------+--------+--------------+

   +------------------+--------+--------------+
   |  Unfragmentable  |Fragment|    second    |
   |       Part       | Header |   fragment   |
   +------------------+--------+--------------+
                         o
                         o
                         o
   +------------------+--------+----------+
   |  Unfragmentable  |Fragment|   last   |
   |       Part       | Header | fragment |
   +------------------+--------+----------+
   except possibly the last ("rightmost") one, being an
   integer multiple of 8 octets long
        """
        self.ip_fragment=1
        self.nheader=dbytes[0]
        return dbytes[8:]
      def parse_dstopts(dbytes):
        """
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    |  Next Header  |  Hdr Ext Len  |                               |
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+                               +
    |                                                               |
    .                                                               .
    .                            Options                            .
    .                                                               .
    |                                                               |
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

   Next Header          8-bit selector.  Identifies the type of header immediately following the Destination Options header.

   Hdr Ext Len          8-bit unsigned integer.  Length of the Destination Options header in 8-octet units, not including the first 8 octets.

   Options              Variable-length field
        """
        self.nheader=dbytes[0]
        length=dbytes[1]
        return dbytes[(length+1)*8:]
      if   self.nheader == self.IPPROTO_HOPOPTS:
        self.payload=parse_hopopts(dbytes)
      elif self.nheader == self.IPPROTO_ROUTING:
        self.payload=parse_routing(dbytes)
      elif self.nheader == self.IPPROTO_FRAGMENT:
        self.payload=parse_fragment(dbytes)
      elif self.nheader == self.IPPROTO_DSTOPTS:
        self.payload=parse_dstopts(dbytes)
      

    def get(self):
      print """
      Version                                      %s
      Traffic Class (TC)                           %s
      Flow Label                                   %s
      Payload Length                               %s
      Next Header                                  %s
      Hop Limit                                    %s
      Source address                               %s
      Destination address                          %s
      """%(
      self.version,
      self.tc,
      self.flabel,
      self.length,
      self.nheader,
      self.hoplimit,
      self.saddr,
      self.daddr)

  class tcp_hdr(ip_hdr):
    """
    Source port                         identifies the sending port
    Destination port                    identifies the receiving port
    Sequence number                     has a dual role:
                                        If the SYN flag is set, then this is the initial sequence number.
                                        If the SYN flag is clear, then this is the accumulated sequence number.
    Acknowledgment number               if the ACK flag is set,the value of this field is the next sequence number that the receiver is expecting.
    Data offset                         specifies the size of the TCP header in 32-bit words.
    Reserved (3 bits)                   for future use and should be set to zero
    Flags                               contains 9 1-bit flags
      NS                                ECN-nonce concealment protection (experimental: see RFC 3540).
      CWR                               Congestion Window Reduced (CWR)
      ECE                               If the SYN flag is set, that the TCP peer is ECN capable.
                                        If the SYN flag is clear, a packet with Congestion Experienced flag in IP header set is received.
      URG                               indicates that the Urgent pointer field is significant.
      ACK                               indicates that the Acknowledgment field is significant.
      PSH                               Push function. Asks to push the buffered data to the receiving application.
      RST                               Reset the connection
      SYN                               Synchronize sequence numbers. Only the first packet sent from each end should have this flag set.
      FIN                               No more data from sender
    Window size                         the size of the receive window, which specifies the number of window size units (by default, bytes) 
    Checksum                            The 16-bit checksum field is used for error-checking of the header and data
    Urgent pointer                      if the URG flag is set, the field is an offset from the sequence number indicating the last urgent data byte
    Options
    Padding
    """
    class port_number:
      TCPMUX               =      1  # TCP Port Service Multiplexer
      COMPRESSNET          =      2  # Management Utility
      COMPRESSNET          =      3  # Compression Process
      RJE                  =      5  # Remote Job Entry
      ECHO                 =      7  # Echo
      DISCARD              =      9  # Discard
      SYSTAT               =     11  # Active Users
      DAYTIME              =     13  # Daytime
      QOTD                 =     17  # Quote of the Day
      MSP                  =     18  # Message Send Protocol (historic)
      CHARGEN              =     19  # Character Generator
      FTP_DATA             =     20  # File Transfer
      FTP                  =     21  # File Transfer
      SSH                  =     22  # The Secure Shell (SSH) Protocol
      TELNET               =     23  # Telnet
      SMTP                 =     25  # Simple Mail Transfer
      NSW_FE               =     27  # NSW User System FE
      MSG_ICP              =     29  # MSG ICP
      MSG_AUTH             =     31  # MSG Authentication
      DSP                  =     33  # Display Support Protocol
      TIME                 =     37  # Time
      RAP                  =     38  # Route Access Protocol
      RLP                  =     39  # Resource Location Protocol
      GRAPHICS             =     41  # Graphics
      NAME                 =     42  # Host Name Server
      NAMESERVER           =     42  # Host Name Server
      NICNAME              =     43  # Who Is
      MPM_FLAGS            =     44  # MPM FLAGS Protocol
      MPM                  =     45  # Message Processing Module
      MPM_SND              =     46  # MPM
      NI_FTP               =     47  # NI FTP
      AUDITD               =     48  # Digital Audit Daemon
      TACACS               =     49  # Login Host Protocol (TACACS)
      RE_MAIL_CK           =     50  # Remote Mail Checking Protocol
      XNS_TIME             =     52  # XNS Time Protocol
      DOMAIN               =     53  # Domain Name Server
      XNS_CH               =     54  # XNS Clearinghouse
      ISI_GL               =     55  # ISI Graphics Language
      XNS_AUTH             =     56  # XNS Authentication
      XNS_MAIL             =     58  # XNS Mail
      NI_MAIL              =     61  # NI MAIL
      ACAS                 =     62  # ACA Services
      WHOISPP              =     63  # whois++IANA assigned this well_formed service name as a replacement for "whois++".
#      WHOIS++              =     63  # whois++
      COVIA                =     64  # Communications Integrator (CI)
      TACACS_DS            =     65  # TACACS_Database Service
      SQL_NET              =     66  # Oracle SQL_NETIANA assigned this well_formed service name as a replacement for "sql_net".
      SQL_NET              =     66  # Oracle SQL_NET
      BOOTPS               =     67  # Bootstrap Protocol Server
      BOOTPC               =     68  # Bootstrap Protocol Client
      TFTP                 =     69  # Trivial File Transfer
      GOPHER               =     70  # Gopher
#      NETRJS_1             =     71  # Remote Job Service
#      NETRJS_2             =     72  # Remote Job Service
#      NETRJS_3             =     73  # Remote Job Service
#      NETRJS_4             =     74  # Remote Job Service
      DEOS                 =     76  # Distributed External Object Store
      VETTCP               =     78  # vettcp
      FINGER               =     79  # Finger
      HTTP                 =     80  # World Wide Web HTTP Defined TXT keys: u=<username> p=<password> path=<path to document>
      XFER                 =     82  # XFER Utility
      MIT_ML_DEV           =     83  # MIT ML Device
      CTF                  =     84  # Common Trace Facility
      MIT_ML_DEV           =     85  # MIT ML Device
      MFCOBOL              =     86  # Micro Focus Cobol
      KERBEROS             =     88  # Kerberos
      SU_MIT_TG            =     89  # SU_MIT Telnet Gateway
      DNSIX                =     90  # DNSIX Securit Attribute Token Map
      MIT_DOV              =     91  # MIT Dover Spooler
      NPP                  =     92  # Network Printing Protocol
      DCP                  =     93  # Device Control Protocol
      OBJCALL              =     94  # Tivoli Object Dispatcher
      SUPDUP               =     95  # SUPDUP
      DIXIE                =     96  # DIXIE Protocol Specification
      SWIFT_RVF            =     97  # Swift Remote Virtural File Protocol
      TACNEWS              =     98  # TAC News
      METAGRAM             =     99  # Metagram Relay
      HOSTNAME             =    101  # NIC Host Name Server
      ISO_TSAP             =    102  # ISO_TSAP Class 0
      GPPITNP              =    103  # Genesis Point_to_Point Trans Net
      ACR_NEMA             =    104  # ACR_NEMA Digital Imag. & Comm. 300
      CSO                  =    105  # CCSO name server protocol
      CSNET_NS             =    105  # Mailbox Name Nameserver
#      3COM_TSMUX           =    106  # 3COM_TSMUX
      RTELNET              =    107  # Remote Telnet Service
      SNAGAS               =    108  # SNA Gateway Access Server
      POP2                 =    109  # Post Office Protocol _ Version 2
      POP3                 =    110  # Post Office Protocol _ Version 3
      SUNRPC               =    111  # SUN Remote Procedure Call
      MCIDAS               =    112  # McIDAS Data Transmission Protocol
      IDENT                =    113  # 
      AUTH                 =    113  # Authentication Service
      SFTP                 =    115  # Simple File Transfer Protocol
      ANSANOTIFY           =    116  # ANSA REX Notify
      UUCP_PATH            =    117  # UUCP Path Service
      SQLSERV              =    118  # SQL Services
      NNTP                 =    119  # Network News Transfer Protocol
      CFDPTKT              =    120  # CFDPTKT
      ERPC                 =    121  # Encore Expedited Remote Pro.Call
      SMAKYNET             =    122  # SMAKYNET
      NTP                  =    123  # Network Time Protocol
      ANSATRADER           =    124  # ANSA REX Trader
      LOCUS_MAP            =    125  # Locus PC_Interface Net Map Ser
      NXEDIT               =    126  # NXEdit
      LOCUS_CON            =    127  # Locus PC_Interface Conn Server
      GSS_XLICEN           =    128  # GSS X License Verification
      PWDGEN               =    129  # Password Generator Protocol
      CISCO_FNA            =    130  # cisco FNATIVE
      CISCO_TNA            =    131  # cisco TNATIVE
      CISCO_SYS            =    132  # cisco SYSMAINT
      STATSRV              =    133  # Statistics Service
      INGRES_NET           =    134  # INGRES_NET Service
      EPMAP                =    135  # DCE endpoint resolution
      PROFILE              =    136  # PROFILE Naming System
      NETBIOS_NS           =    137  # NETBIOS Name Service
      NETBIOS_DGM          =    138  # NETBIOS Datagram Service
      NETBIOS_SSN          =    139  # NETBIOS Session Service
      EMFIS_DATA           =    140  # EMFIS Data Service
      EMFIS_CNTL           =    141  # EMFIS Control Service
      BL_IDM               =    142  # Britton_Lee IDM
      IMAP                 =    143  # Internet Message Access Protocol
      UMA                  =    144  # Universal Management Architecture
      UAAC                 =    145  # UAAC Protocol
      ISO_TP0              =    146  # ISO_IP0
      ISO_IP               =    147  # ISO_IP
      JARGON               =    148  # Jargon
      AED_512              =    149  # AED 512 Emulation Service
      SQL_NET              =    150  # SQL_NET
      HEMS                 =    151  # HEMS
      BFTP                 =    152  # Background File Transfer Program
      SGMP                 =    153  # SGMP
      NETSC_PROD           =    154  # NETSC
      NETSC_DEV            =    155  # NETSC
      SQLSRV               =    156  # SQL Service
      KNET_CMP             =    157  # KNET_VM Command_Message Protocol
      PCMAIL_SRV           =    158  # PCMail Server
      NSS_ROUTING          =    159  # NSS_Routing
      SGMP_TRAPS           =    160  # SGMP_TRAPS
      SNMP                 =    161  # SNMP
      SNMPTRAP             =    162  # SNMPTRAP
      CMIP_MAN             =    163  # CMIP_TCP Manager
      CMIP_AGENT           =    164  # CMIP_TCP Agent
      XNS_COURIER          =    165  # Xerox
      S_NET                =    166  # Sirius Systems
      NAMP                 =    167  # NAMP
      RSVD                 =    168  # RSVD
      SEND                 =    169  # SEND
      PRINT_SRV            =    170  # Network PostScript
      MULTIPLEX            =    171  # Network Innovations Multiplex
      CL_1                 =    172  # Network Innovations CL_1IANA assigned this well_formed service name as a replacement for "cl_1".
      CL_1                 =    172  # Network Innovations CL_1
      XYPLEX_MUX           =    173  # Xyplex
      MAILQ                =    174  # MAILQ
      VMNET                =    175  # VMNET
      GENRAD_MUX           =    176  # GENRAD_MUX
      XDMCP                =    177  # X Display Manager Control Protocol
      NEXTSTEP             =    178  # NextStep Window Server
      BGP                  =    179  # Border Gateway Protocol
      RIS                  =    180  # Intergraph
      UNIFY                =    181  # Unify
      AUDIT                =    182  # Unisys Audit SITP
      OCBINDER             =    183  # OCBinder
      OCSERVER             =    184  # OCServer
      REMOTE_KIS           =    185  # Remote_KIS
      KIS                  =    186  # KIS Protocol
      ACI                  =    187  # Application Communication Interface
      MUMPS                =    188  # Plus Five's MUMPS
      QFT                  =    189  # Queued File Transport
      GACP                 =    190  # Gateway Access Control Protocol
      PROSPERO             =    191  # Prospero Directory Service
      OSU_NMS              =    192  # OSU Network Monitoring System
      SRMP                 =    193  # Spider Remote Monitoring Protocol
      IRC                  =    194  # Internet Relay Chat Protocol
      DN6_NLM_AUD          =    195  # DNSIX Network Level Module Audit
      DN6_SMM_RED          =    196  # DNSIX Session Mgt Module Audit Redir
      DLS                  =    197  # Directory Location Service
      DLS_MON              =    198  # Directory Location Service Monitor
      SMUX                 =    199  # SMUX
      SRC                  =    200  # IBM System Resource Controller
      AT_RTMP              =    201  # AppleTalk Routing Maintenance
      AT_NBP               =    202  # AppleTalk Name Binding
      AT_3                 =    203  # AppleTalk Unused
      AT_ECHO              =    204  # AppleTalk Echo
      AT_5                 =    205  # AppleTalk Unused
      AT_ZIS               =    206  # AppleTalk Zone Information
      AT_7                 =    207  # AppleTalk Unused
      AT_8                 =    208  # AppleTalk Unused
      QMTP                 =    209  # The Quick Mail Transfer Protocol
      Z39_50               =    210  # ANSI Z39.50IANA assigned this well_formed service name as a replacement for "z39.50".
#      Z39.50               =    210  # ANSI Z39.50
#      914C_G               =    211  # Texas Instruments 914C_G TerminalIANA assigned this well_formed service name as a replacement for "914c_g".
#      914C_G               =    211  # Texas Instruments 914C_G Terminal
      ANET                 =    212  # ATEXSSTR
      IPX                  =    213  # IPX
      VMPWSCS              =    214  # VM PWSCS
      SOFTPC               =    215  # Insignia Solutions
      CAILIC               =    216  # Computer Associates Int'l License Server
      DBASE                =    217  # dBASE Unix
      MPP                  =    218  # Netix Message Posting Protocol
      UARPS                =    219  # Unisys ARPs
      IMAP3                =    220  # Interactive Mail Access Protocol v3
      FLN_SPX              =    221  # Berkeley rlogind with SPX auth
      RSH_SPX              =    222  # Berkeley rshd with SPX auth
      CDC                  =    223  # Certificate Distribution Center
      MASQDIALER           =    224  # masqdialer
      DIRECT               =    242  # Direct
      SUR_MEAS             =    243  # Survey Measurement
      INBUSINESS           =    244  # inbusiness
      LINK                 =    245  # LINK
      DSP3270              =    246  # Display Systems Protocol
      SUBNTBCST_TFTP       =    247  # SUBNTBCST_TFTPIANA assigned this well_formed service name as a replacement for "subntbcst_tftp".
      SUBNTBCST_TFTP       =    247  # SUBNTBCST_TFTP
      BHFHS                =    248  # bhfhs
      RAP                  =    256  # RAP
      SET                  =    257  # Secure Electronic Transaction
      ESRO_GEN             =    259  # Efficient Short Remote Operations
      OPENPORT             =    260  # Openport
      NSIIOPS              =    261  # IIOP Name Service over TLS_SSL
      ARCISDMS             =    262  # Arcisdms
      HDAP                 =    263  # HDAP
      BGMP                 =    264  # BGMP
      X_BONE_CTL           =    265  # X_Bone CTL
      SST                  =    266  # SCSI on ST
      TD_SERVICE           =    267  # Tobit David Service Layer
      TD_REPLICA           =    268  # Tobit David Replica
      MANET                =    269  # MANET Protocols
      PT_TLS               =    271  # IETF Network Endpoint Assessment (NEA) Posture Transport Protocol over TLS (PT_TLS)
      HTTP_MGMT            =    280  # http_mgmt
      PERSONAL_LINK        =    281  # Personal Link
      CABLEPORT_AX         =    282  # Cable Port A_X
      RESCAP               =    283  # rescap
      CORERJD              =    284  # corerjd
      FXP                  =    286  # FXP Communication
      K_BLOCK              =    287  # K_BLOCK
      NOVASTORBAKCUP       =    308  # Novastor Backup
      ENTRUSTTIME          =    309  # EntrustTime
      BHMDS                =    310  # bhmds
      ASIP_WEBADMIN        =    311  # AppleShare IP WebAdmin
      VSLMP                =    312  # VSLMP
      MAGENTA_LOGIC        =    313  # Magenta Logic
      OPALIS_ROBOT         =    314  # Opalis Robot
      DPSI                 =    315  # DPSI
      DECAUTH              =    316  # decAuth
      ZANNET               =    317  # Zannet
      PKIX_TIMESTAMP       =    318  # PKIX TimeStamp
      PTP_EVENT            =    319  # PTP Event
      PTP_GENERAL          =    320  # PTP General
      PIP                  =    321  # PIP
      RTSPS                =    322  # RTSPS
      RPKI_RTR             =    323  # Resource PKI to Router Protocol
      RPKI_RTR_TLS         =    324  # Resource PKI to Router Protocol over TLS
      TEXAR                =    333  # Texar Security Port
      PDAP                 =    344  # Prospero Data Access Protocol
      PAWSERV              =    345  # Perf Analysis Workbench
      ZSERV                =    346  # Zebra server
      FATSERV              =    347  # Fatmen Server
      CSI_SGWP             =    348  # Cabletron Management Protocol
      MFTP                 =    349  # mftp
      MATIP_TYPE_A         =    350  # MATIP Type A
      MATIP_TYPE_B         =    351  # MATIP Type B
      BHOETTY              =    351  # bhoetty
      DTAG_STE_SB          =    352  # DTAG
      BHOEDAP4             =    352  # bhoedap4
      NDSAUTH              =    353  # NDSAUTH
      BH611                =    354  # bh611
      DATEX_ASN            =    355  # DATEX_ASN
      CLOANTO_NET_1        =    356  # Cloanto Net 1
      BHEVENT              =    357  # bhevent
      SHRINKWRAP           =    358  # Shrinkwrap
      NSRMP                =    359  # Network Security Risk Management Protocol
      SCOI2ODIALOG         =    360  # scoi2odialog
      SEMANTIX             =    361  # Semantix
      SRSSEND              =    362  # SRS Send
      RSVP_TUNNEL          =    363  # RSVP TunnelIANA assigned this well_formed service name as a replacement for "rsvp_tunnel".
      RSVP_TUNNEL          =    363  # RSVP Tunnel
      AURORA_CMGR          =    364  # Aurora CMGR
      DTK                  =    365  # DTK
      ODMR                 =    366  # ODMR
      MORTGAGEWARE         =    367  # MortgageWare
      QBIKGDP              =    368  # QbikGDP
      RPC2PORTMAP          =    369  # rpc2portmap
      CODAAUTH2            =    370  # codaauth2
      CLEARCASE            =    371  # Clearcase
      ULISTPROC            =    372  # ListProcessor
      LEGENT_1             =    373  # Legent Corporation
      LEGENT_2             =    374  # Legent Corporation
      HASSLE               =    375  # Hassle
      NIP                  =    376  # Amiga Envoy Network Inquiry Proto
      TNETOS               =    377  # NEC Corporation
      DSETOS               =    378  # NEC Corporation
      IS99C                =    379  # TIA_EIA_IS_99 modem client
      IS99S                =    380  # TIA_EIA_IS_99 modem server
      HP_COLLECTOR         =    381  # hp performance data collector
      HP_MANAGED_NODE      =    382  # hp performance data managed node
      HP_ALARM_MGR         =    383  # hp performance data alarm manager
      ARNS                 =    384  # A Remote Network Server System
      IBM_APP              =    385  # IBM Application
      ASA                  =    386  # ASA Message Router Object Def.
      AURP                 =    387  # Appletalk Update_Based Routing Pro.
      UNIDATA_LDM          =    388  # Unidata LDM
      LDAP                 =    389  # Lightweight Directory Access Protocol
      UIS                  =    390  # UIS
      SYNOTICS_RELAY       =    391  # SynOptics SNMP Relay Port
      SYNOTICS_BROKER      =    392  # SynOptics Port Broker Port
      META5                =    393  # Meta5
      EMBL_NDT             =    394  # EMBL Nucleic Data Transfer
      NETCP                =    395  # NetScout Control Protocol
      NETWARE_IP           =    396  # Novell Netware over IP
      MPTN                 =    397  # Multi Protocol Trans. Net.
      KRYPTOLAN            =    398  # Kryptolan
      ISO_TSAP_C2          =    399  # ISO Transport Class 2 Non_Control over TCP
      OSB_SD               =    400  # Oracle Secure Backup
      UPS                  =    401  # Uninterruptible Power Supply
      GENIE                =    402  # Genie Protocol
      DECAP                =    403  # decap
      NCED                 =    404  # nced
      NCLD                 =    405  # ncld
      IMSP                 =    406  # Interactive Mail Support Protocol
      TIMBUKTU             =    407  # Timbuktu
      PRM_SM               =    408  # Prospero Resource Manager Sys. Man.
      PRM_NM               =    409  # Prospero Resource Manager Node Man.
      DECLADEBUG           =    410  # DECLadebug Remote Debug Protocol
      RMT                  =    411  # Remote MT Protocol
      SYNOPTICS_TRAP       =    412  # Trap Convention Port
      SMSP                 =    413  # Storage Management Services Protocol
      INFOSEEK             =    414  # InfoSeek
      BNET                 =    415  # BNet
      SILVERPLATTER        =    416  # Silverplatter
      ONMUX                =    417  # Onmux
      HYPER_G              =    418  # Hyper_G
      ARIEL1               =    419  # Ariel 1
      SMPTE                =    420  # SMPTE
      ARIEL2               =    421  # Ariel 2
      ARIEL3               =    422  # Ariel 3
      OPC_JOB_START        =    423  # IBM Operations Planning and Control Start
      OPC_JOB_TRACK        =    424  # IBM Operations Planning and Control Track
      ICAD_EL              =    425  # ICAD
      SMARTSDP             =    426  # smartsdp
      SVRLOC               =    427  # Server Location
      OCS_CMU              =    428  # OCS_CMUIANA assigned this well_formed service name as a replacement for "ocs_cmu".
      OCS_CMU              =    428  # OCS_CMU This entry is an alias to "ocs_cmu".This entry is now historic, not usable for use with manycommon service discovery mechanisms.
      OCS_AMU              =    429  # OCS_AMUIANA assigned this well_formed service name as a replacement for "ocs_amu".
      OCS_AMU              =    429  # OCS_AMU
      UTMPSD               =    430  # UTMPSD
      UTMPCD               =    431  # UTMPCD
      IASD                 =    432  # IASD
      NNSP                 =    433  # NNSP
      MOBILEIP_AGENT       =    434  # MobileIP_Agent
      MOBILIP_MN           =    435  # MobilIP_MN
      DNA_CML              =    436  # DNA_CML
      COMSCM               =    437  # comscm
      DSFGW                =    438  # dsfgw
      DASP                 =    439  # dasp
      SGCP                 =    440  # sgcp
      DECVMS_SYSMGT        =    441  # decvms_sysmgt
      CVC_HOSTD            =    442  # cvc_hostdIANA assigned this well_formed service name as a replacement for "cvc_hostd".
      CVC_HOSTD            =    442  # cvc_hostd
      HTTPS                =    443  # http protocol over TLS_SSL
      SNPP                 =    444  # Simple Network Paging Protocol
      MICROSOFT_DS         =    445  # Microsoft_DS
      DDM_RDB              =    446  # DDM_Remote Relational Database Access
      DDM_DFM              =    447  # DDM_Distributed File Management
      DDM_SSL              =    448  # DDM_Remote DB Access Using Secure Sockets
      AS_SERVERMAP         =    449  # AS Server Mapper
      TSERVER              =    450  # Computer Supported Telecomunication Applications
      SFS_SMP_NET          =    451  # Cray Network Semaphore server
      SFS_CONFIG           =    452  # Cray SFS config server
      CREATIVESERVER       =    453  # CreativeServer
      CONTENTSERVER        =    454  # ContentServer
      CREATIVEPARTNR       =    455  # CreativePartnr
      MACON_TCP            =    456  # macon_tcp
      SCOHELP              =    457  # scohelp
      APPLEQTC             =    458  # apple quick time
      AMPR_RCMD            =    459  # ampr_rcmd
      SKRONK               =    460  # skronk
      DATASURFSRV          =    461  # DataRampSrv
      DATASURFSRVSEC       =    462  # DataRampSrvSec
      ALPES                =    463  # alpes
      KPASSWD              =    464  # kpasswd
      URD                  =    465  # URL Rendesvous Directory for SSM
      DIGITAL_VRC          =    466  # digital_vrc
      MYLEX_MAPD           =    467  # mylex_mapd
      PHOTURIS             =    468  # proturis
      RCP                  =    469  # Radio Control Protocol
      SCX_PROXY            =    470  # scx_proxy
      MONDEX               =    471  # Mondex
      LJK_LOGIN            =    472  # ljk_login
      HYBRID_POP           =    473  # hybrid_pop
      TN_TL_W1             =    474  # tn_tl_w1
      TCPNETHASPSRV        =    475  # tcpnethaspsrv
      TN_TL_FD1            =    476  # tn_tl_fd1
      SS7NS                =    477  # ss7ns
      SPSC                 =    478  # spsc
      IAFSERVER            =    479  # iafserver
      IAFDBASE             =    480  # iafdbase
      PH                   =    481  # Ph service
      BGS_NSI              =    482  # bgs_nsi
      ULPNET               =    483  # ulpnet
      INTEGRA_SME          =    484  # Integra Software Management Environment
      POWERBURST           =    485  # Air Soft Power Burst
      AVIAN                =    486  # avian
      SAFT                 =    487  # saft Simple Asynchronous File Transfer
      GSS_HTTP             =    488  # gss_http
      NEST_PROTOCOL        =    489  # nest_protocol
      MICOM_PFS            =    490  # micom_pfs
      GO_LOGIN             =    491  # go_login
      TICF_1               =    492  # Transport Independent Convergence for FNA
      TICF_2               =    493  # Transport Independent Convergence for FNA
      POV_RAY              =    494  # POV_Ray
      INTECOURIER          =    495  # intecourier
      PIM_RP_DISC          =    496  # PIM_RP_DISC
      RETROSPECT           =    497  # Retrospect backup and restore service
      SIAM                 =    498  # siam
      ISO_ILL              =    499  # ISO ILL Protocol
      ISAKMP               =    500  # isakmp
      STMF                 =    501  # STMF
      MBAP                 =    502  # Modbus Application Protocol
      INTRINSA             =    503  # Intrinsa
      CITADEL              =    504  # citadel
      MAILBOX_LM           =    505  # mailbox_lm
      OHIMSRV              =    506  # ohimsrv
      CRS                  =    507  # crs
      XVTTP                =    508  # xvttp
      SNARE                =    509  # snare
      FCP                  =    510  # FirstClass Protocol
      PASSGO               =    511  # PassGo
      EXEC                 =    512  # remote process execution; authentication performed using passwords and UNIX login names
      LOGIN                =    513  # remote login a la telnet; automatic authentication performed based on priviledged port numbers and distributed data bases which identify "authentication domains"
      SHELL                =    514  # cmd like exec, but automatic authentication is performed as for login server
      PRINTER              =    515  # spooler
      VIDEOTEX             =    516  # videotex
      TALK                 =    517  # like tenex link, but across machine _ unfortunately, doesn't use link protocol (this is actually just a rendezvous port from which a tcp connection is established)
      NTALK                =    518  # 
      UTIME                =    519  # unixtime
      EFS                  =    520  # extended file name server
      RIPNG                =    521  # ripng
      ULP                  =    522  # ULP
      IBM_DB2              =    523  # IBM_DB2
      NCP                  =    524  # NCP
      TIMED                =    525  # timeserver
      TEMPO                =    526  # newdate
      STX                  =    527  # Stock IXChange
      CUSTIX               =    528  # Customer IXChange
      IRC_SERV             =    529  # IRC_SERV
      COURIER              =    530  # rpc
      CONFERENCE           =    531  # chat
      NETNEWS              =    532  # readnews
      NETWALL              =    533  # for emergency broadcasts
      WINDREAM             =    534  # windream Admin
      IIOP                 =    535  # iiop
      OPALIS_RDV           =    536  # opalis_rdv
      NMSP                 =    537  # Networked Media Streaming Protocol
      GDOMAP               =    538  # gdomap
      APERTUS_LDP          =    539  # Apertus Technologies Load Determination
      UUCP                 =    540  # uucpd
      UUCP_RLOGIN          =    541  # uucp_rlogin
      COMMERCE             =    542  # commerce
      KLOGIN               =    543  # 
      KSHELL               =    544  # krcmd
      APPLEQTCSRVR         =    545  # appleqtcsrvr
      DHCPV6_CLIENT        =    546  # DHCPv6 Client
      DHCPV6_SERVER        =    547  # DHCPv6 Server
      AFPOVERTCP           =    548  # AFP over TCP
      IDFP                 =    549  # IDFP
      NEW_RWHO             =    550  # new_who
      CYBERCASH            =    551  # cybercash
      DEVSHR_NTS           =    552  # DeviceShare
      PIRP                 =    553  # pirp
      RTSP                 =    554  # Real Time Streaming Protocol (RTSP)
      DSF                  =    555  # 
      REMOTEFS             =    556  # rfs server
      OPENVMS_SYSIPC       =    557  # openvms_sysipc
      SDNSKMP              =    558  # SDNSKMP
      TEEDTAP              =    559  # TEEDTAP
      RMONITOR             =    560  # rmonitord
      MONITOR              =    561  # 
      CHSHELL              =    562  # chcmd
      NNTPS                =    563  # nntp protocol over TLS_SSL (was snntp)
#      9PFS                 =    564  # plan 9 file service
      WHOAMI               =    565  # whoami
      STREETTALK           =    566  # streettalk
      BANYAN_RPC           =    567  # banyan_rpc
      MS_SHUTTLE           =    568  # microsoft shuttle
      MS_ROME              =    569  # microsoft rome
      METER                =    570  # demon
      METER                =    571  # udemon
      SONAR                =    572  # sonar
      BANYAN_VIP           =    573  # banyan_vip
      FTP_AGENT            =    574  # FTP Software Agent System
      VEMMI                =    575  # VEMMI
      IPCD                 =    576  # ipcd
      VNAS                 =    577  # vnas
      IPDD                 =    578  # ipdd
      DECBSRV              =    579  # decbsrv
      SNTP_HEARTBEAT       =    580  # SNTP HEARTBEAT
      BDP                  =    581  # Bundle Discovery Protocol
      SCC_SECURITY         =    582  # SCC Security
      PHILIPS_VC           =    583  # Philips Video_Conferencing
      KEYSERVER            =    584  # Key Server
      PASSWORD_CHG         =    586  # Password Change
      SUBMISSION           =    587  # Message Submission 2011_11_17
      CAL                  =    588  # CAL
      EYELINK              =    589  # EyeLink
      TNS_CML              =    590  # TNS CML
      HTTP_ALT             =    591  # FileMaker, Inc. _ HTTP Alternate (see Port 80)
      EUDORA_SET           =    592  # Eudora Set
      HTTP_RPC_EPMAP       =    593  # HTTP RPC Ep Map
      TPIP                 =    594  # TPIP
      CAB_PROTOCOL         =    595  # CAB Protocol
      SMSD                 =    596  # SMSD
      PTCNAMESERVICE       =    597  # PTC Name Service
      SCO_WEBSRVRMG3       =    598  # SCO Web Server Manager 3
      ACP                  =    599  # Aeolon Core Protocol
      IPCSERVER            =    600  # Sun IPC server
      SYSLOG_CONN          =    601  # Reliable Syslog Service
      XMLRPC_BEEP          =    602  # XML_RPC over BEEP
      IDXP                 =    603  # IDXP
      TUNNEL               =    604  # TUNNEL
      SOAP_BEEP            =    605  # SOAP over BEEP
      URM                  =    606  # Cray Unified Resource Manager
      NQS                  =    607  # nqs
      SIFT_UFT             =    608  # Sender_Initiated_Unsolicited File Transfer
      NPMP_TRAP            =    609  # npmp_trap
      NPMP_LOCAL           =    610  # npmp_local
      NPMP_GUI             =    611  # npmp_gui
      HMMP_IND             =    612  # HMMP Indication
      HMMP_OP              =    613  # HMMP Operation
      SSHELL               =    614  # SSLshell
      SCO_INETMGR          =    615  # Internet Configuration Manager
      SCO_SYSMGR           =    616  # SCO System Administration Server
      SCO_DTMGR            =    617  # SCO Desktop Administration Server
      DEI_ICDA             =    618  # DEI_ICDA
      COMPAQ_EVM           =    619  # Compaq EVM
      SCO_WEBSRVRMGR       =    620  # SCO WebServer Manager
      ESCP_IP              =    621  # ESCP
      COLLABORATOR         =    622  # Collaborator
      OOB_WS_HTTP          =    623  # DMTF out_of_band web services management protocol
      CRYPTOADMIN          =    624  # Crypto Admin
      DEC_DLM              =    625  # DEC DLMIANA assigned this well_formed service name as a replacement for "dec_dlm".
      DEC_DLM              =    625  # DEC DLM
      ASIA                 =    626  # ASIA
      PASSGO_TIVOLI        =    627  # PassGo Tivoli
      QMQP                 =    628  # QMQP
#      3COM_AMP3            =    629  # 3Com AMP3
      RDA                  =    630  # RDA
      IPP                  =    631  # IPP (Internet Printing Protocol)
      BMPP                 =    632  # bmpp
      SERVSTAT             =    633  # Service Status update (Sterling Software)
      GINAD                =    634  # ginad
      RLZDBASE             =    635  # RLZ DBase
      LDAPS                =    636  # ldap protocol over TLS_SSL (was sldap)
      LANSERVER            =    637  # lanserver
      MCNS_SEC             =    638  # mcns_sec
      MSDP                 =    639  # MSDP
      ENTRUST_SPS          =    640  # entrust_sps
      REPCMD               =    641  # repcmd
      ESRO_EMSDP           =    642  # ESRO_EMSDP V1.3
      SANITY               =    643  # SANity
      DWR                  =    644  # dwr
      PSSC                 =    645  # PSSC
      LDP                  =    646  # LDP
      DHCP_FAILOVER        =    647  # DHCP Failover
      RRP                  =    648  # Registry Registrar Protocol (RRP)
#      CADVIEW_3D           =    649  # Cadview_3d _ streaming 3d models over the internet
      OBEX                 =    650  # OBEX
      IEEE_MMS             =    651  # IEEE MMS
      HELLO_PORT           =    652  # HELLO_PORT
      REPSCMD              =    653  # RepCmd
      AODV                 =    654  # AODV
      TINC                 =    655  # TINC
      SPMP                 =    656  # SPMP
      RMC                  =    657  # RMC
      TENFOLD              =    658  # TenFold
      MAC_SRVR_ADMIN       =    660  # MacOS Server Admin
      HAP                  =    661  # HAP
      PFTP                 =    662  # PFTP
      PURENOISE            =    663  # PureNoise
      OOB_WS_HTTPS         =    664  # DMTF out_of_band secure web services management protocol
      SUN_DR               =    665  # Sun DR
      MDQS                 =    666  # 
      DOOM                 =    666  # doom Id Software
      DISCLOSE             =    667  # campaign contribution disclosures _ SDR Technologies
      MECOMM               =    668  # MeComm
      MEREGISTER           =    669  # MeRegister
      VACDSM_SWS           =    670  # VACDSM_SWS
      VACDSM_APP           =    671  # VACDSM_APP
      VPPS_QUA             =    672  # VPPS_QUA
      CIMPLEX              =    673  # CIMPLEX
      ACAP                 =    674  # ACAP
      DCTP                 =    675  # DCTP
      VPPS_VIA             =    676  # VPPS Via
      VPP                  =    677  # Virtual Presence Protocol
      GGF_NCP              =    678  # GNU Generation Foundation NCP
      MRM                  =    679  # MRM
      ENTRUST_AAAS         =    680  # entrust_aaas
      ENTRUST_AAMS         =    681  # entrust_aams
      XFR                  =    682  # XFR
      CORBA_IIOP           =    683  # CORBA IIOP
      CORBA_IIOP_SSL       =    684  # CORBA IIOP SSL
      MDC_PORTMAPPER       =    685  # MDC Port Mapper
      HCP_WISMAR           =    686  # Hardware Control Protocol Wismar
      ASIPREGISTRY         =    687  # asipregistry
      REALM_RUSD           =    688  # ApplianceWare managment protocol
      NMAP                 =    689  # NMAP
      VATP                 =    690  # Velazquez Application Transfer Protocol
      MSEXCH_ROUTING       =    691  # MS Exchange Routing
      HYPERWAVE_ISP        =    692  # Hyperwave_ISP
      CONNENDP             =    693  # almanid Connection Endpoint
      HA_CLUSTER           =    694  # ha_cluster
      IEEE_MMS_SSL         =    695  # IEEE_MMS_SSL
      RUSHD                =    696  # RUSHD
      UUIDGEN              =    697  # UUIDGEN
      OLSR                 =    698  # OLSR
      ACCESSNETWORK        =    699  # Access Network
      EPP                  =    700  # Extensible Provisioning Protocol
      LMP                  =    701  # Link Management Protocol (LMP)
      IRIS_BEEP            =    702  # IRIS over BEEP
      ELCSD                =    704  # errlog copy_server daemon
      AGENTX               =    705  # AgentX
      SILC                 =    706  # SILC
      BORLAND_DSJ          =    707  # Borland DSJ
      ENTRUST_KMSH         =    709  # Entrust Key Management Service Handler
      ENTRUST_ASH          =    710  # Entrust Administration Service Handler
      CISCO_TDP            =    711  # Cisco TDP
      TBRPF                =    712  # TBRPF
      IRIS_XPC             =    713  # IRIS over XPC
      IRIS_XPCS            =    714  # IRIS over XPCS
      IRIS_LWZ             =    715  # IRIS_LWZ
      NETVIEWDM1           =    729  # IBM NetView DM_6000 Server_Client
      NETVIEWDM2           =    730  # IBM NetView DM_6000 send_tcp
      NETVIEWDM3           =    731  # IBM NetView DM_6000 receive_tcp
      NETGW                =    741  # netGW
      NETRCS               =    742  # Network based Rev. Cont. Sys.
      FLEXLM               =    744  # Flexible License Manager
      FUJITSU_DEV          =    747  # Fujitsu Device Control
      RIS_CM               =    748  # Russell Info Sci Calendar Manager
      KERBEROS_ADM         =    749  # kerberos administration
      RFILE                =    750  # 
      PUMP                 =    751  # 
      QRH                  =    752  # 
      RRH                  =    753  # 
      TELL                 =    754  # send
      NLOGIN               =    758  # 
      CON                  =    759  # 
      NS                   =    760  # 
      RXE                  =    761  # 
      QUOTAD               =    762  # 
      CYCLESERV            =    763  # 
      OMSERV               =    764  # 
      WEBSTER              =    765  # 
      PHONEBOOK            =    767  # phone
      VID                  =    769  # 
      CADLOCK              =    770  # 
      RTIP                 =    771  # 
      CYCLESERV2           =    772  # 
      SUBMIT               =    773  # 
      RPASSWD              =    774  # 
      ENTOMB               =    775  # 
      WPAGES               =    776  # 
      MULTILING_HTTP       =    777  # Multiling HTTP
      WPGS                 =    780  # 
      MDBS_DAEMON          =    800  # IANA assigned this well_formed service name as a replacement for "mdbs_daemon".
      MDBS_DAEMON          =    800  # This entry is an alias to "mdbs_daemon".This entry is now historic, not usable for use with manycommon service discovery mechanisms.
      DEVICE               =    801  # 
      MBAP_S               =    802  # Modbus Application Protocol Secure
      FCP_UDP              =    810  # FCP
      ITM_MCELL_S          =    828  # itm_mcell_s
      PKIX_3_CA_RA         =    829  # PKIX_3 CA_RA
      NETCONF_SSH          =    830  # NETCONF over SSH
      NETCONF_BEEP         =    831  # NETCONF over BEEP
      NETCONFSOAPHTTP      =    832  # NETCONF for SOAP over HTTPS
      NETCONFSOAPBEEP      =    833  # NETCONF for SOAP over BEEP
      DHCP_FAILOVER2       =    847  # dhcp_failover 2
      GDOI                 =    848  # GDOI
      ISCSI                =    860  # iSCSI
      OWAMP_CONTROL        =    861  # OWAMP_Control
      TWAMP_CONTROL        =    862  # Two_way Active Measurement Protocol (TWAMP) Control
      RSYNC                =    873  # rsync
      ICLCNET_LOCATE       =    886  # ICL coNETion locate server
      ICLCNET_SVINFO       =    887  # ICL coNETion server infoIANA assigned this well_formed service name as a replacement for "iclcnet_svinfo".
      ICLCNET_SVINFO       =    887  # ICL coNETion server info
      ACCESSBUILDER        =    888  # AccessBuilder
      CDDBP                =    888  # CD Database Protocol
      OMGINITIALREFS       =    900  # OMG Initial Refs
      SMPNAMERES           =    901  # SMPNAMERES
      IDEAFARM_DOOR        =    902  # self documenting Telnet Door
      IDEAFARM_PANIC       =    903  # self documenting Telnet Panic Door
      KINK                 =    910  # Kerberized Internet Negotiation of Keys (KINK)
      XACT_BACKUP          =    911  # xact_backup
      APEX_MESH            =    912  # APEX relay_relay service
      APEX_EDGE            =    913  # APEX endpoint_relay service
      FTPS_DATA            =    989  # ftp protocol, data, over TLS_SSL
      FTPS                 =    990  # ftp protocol, control, over TLS_SSL
      NAS                  =    991  # Netnews Administration System
      TELNETS              =    992  # telnet protocol over TLS_SSL
      IMAPS                =    993  # imap4 protocol over TLS_SSL
      POP3S                =    995  # pop3 protocol over TLS_SSL (was spop3)
      VSINET               =    996  # vsinet
      MAITRD               =    997  # 
      BUSBOY               =    998  # 
      GARCON               =    999  # 
      PUPROUTER            =    999  # 
      CADLOCK2             =   1000  # 
      SURF                 =   1010  # surf
      EXP1                 =   1021  # RFC3692_style Experiment 1
      EXP2                 =   1022  # RFC3692_style Experiment 2
      BLACKJACK            =   1025  # network blackjack
      CAP                  =   1026  # Calendar Access Protocol
      SOLID_MUX            =   1029  # Solid Mux Server
      NETINFO_LOCAL        =   1033  # local netinfo port
      ACTIVESYNC           =   1034  # ActiveSync Notifications
      MXXRLOGIN            =   1035  # MX_XR RPC
      NSSTP                =   1036  # Nebula Secure Segment Transfer Protocol
      AMS                  =   1037  # AMS
      MTQP                 =   1038  # Message Tracking Query Protocol
      SBL                  =   1039  # Streamlined Blackhole
      NETARX               =   1040  # Netarx Netcare
      DANF_AK2             =   1041  # AK2 Product
      AFROG                =   1042  # Subnet Roaming
      BOINC_CLIENT         =   1043  # BOINC Client Control
      DCUTILITY            =   1044  # Dev Consortium Utility
      FPITP                =   1045  # Fingerprint Image Transfer Protocol
      WFREMOTERTM          =   1046  # WebFilter Remote Monitor
      NEOD1                =   1047  # Sun's NEO Object Request Broker
      NEOD2                =   1048  # Sun's NEO Object Request Broker
      TD_POSTMAN           =   1049  # Tobit David Postman VPMN
      CMA                  =   1050  # CORBA Management Agent
      OPTIMA_VNET          =   1051  # Optima VNET
      DDT                  =   1052  # Dynamic DNS Tools
      REMOTE_AS            =   1053  # Remote Assistant (RA)
      BRVREAD              =   1054  # BRVREAD
      ANSYSLMD             =   1055  # ANSYS _ License Manager
      VFO                  =   1056  # VFO
      STARTRON             =   1057  # STARTRON
      NIM                  =   1058  # nim
      NIMREG               =   1059  # nimreg
      POLESTAR             =   1060  # POLESTAR
      KIOSK                =   1061  # KIOSK
      VERACITY             =   1062  # Veracity
      KYOCERANETDEV        =   1063  # KyoceraNetDev
      JSTEL                =   1064  # JSTEL
      SYSCOMLAN            =   1065  # SYSCOMLAN
      FPO_FNS              =   1066  # FPO_FNS
      INSTL_BOOTS          =   1067  # Installation Bootstrap Proto. Serv.IANA assigned this well_formed service name as a replacement for "instl_boots".
      INSTL_BOOTS          =   1067  # Installation Bootstrap Proto. Serv. This entry is an alias to "instl_boots".This entry is now historic, not usable for use with manycommon service discovery mechanisms.
      INSTL_BOOTC          =   1068  # Installation Bootstrap Proto. Cli.IANA assigned this well_formed service name as a replacement for "instl_bootc".
      INSTL_BOOTC          =   1068  # Installation Bootstrap Proto. Cli.
      COGNEX_INSIGHT       =   1069  # COGNEX_INSIGHT
      GMRUPDATESERV        =   1070  # GMRUpdateSERV
      BSQUARE_VOIP         =   1071  # BSQUARE_VOIP
      CARDAX               =   1072  # CARDAX
      BRIDGECONTROL        =   1073  # Bridge Control
      WARMSPOTMGMT         =   1074  # Warmspot Management Protocol
      RDRMSHC              =   1075  # RDRMSHC
      DAB_STI_C            =   1076  # DAB STI_C
      IMGAMES              =   1077  # IMGames
      AVOCENT_PROXY        =   1078  # Avocent Proxy Protocol
      ASPROVATALK          =   1079  # ASPROVATalk
      SOCKS                =   1080  # Socks
      PVUNIWIEN            =   1081  # PVUNIWIEN
      AMT_ESD_PROT         =   1082  # AMT_ESD_PROT
      ANSOFT_LM_1          =   1083  # Anasoft License Manager
      ANSOFT_LM_2          =   1084  # Anasoft License Manager
      WEBOBJECTS           =   1085  # Web Objects
      CPLSCRAMBLER_LG      =   1086  # CPL Scrambler Logging
      CPLSCRAMBLER_IN      =   1087  # CPL Scrambler Internal
      CPLSCRAMBLER_AL      =   1088  # CPL Scrambler Alarm Log
      FF_ANNUNC            =   1089  # FF Annunciation
      FF_FMS               =   1090  # FF Fieldbus Message Specification
      FF_SM                =   1091  # FF System Management
      OBRPD                =   1092  # Open Business Reporting Protocol
      PROOFD               =   1093  # PROOFD
      ROOTD                =   1094  # ROOTD
      NICELINK             =   1095  # NICELink
      CNRPROTOCOL          =   1096  # Common Name Resolution Protocol
      SUNCLUSTERMGR        =   1097  # Sun Cluster Manager
      RMIACTIVATION        =   1098  # RMI Activation
      RMIREGISTRY          =   1099  # RMI Registry
      MCTP                 =   1100  # MCTP
      PT2_DISCOVER         =   1101  # PT2_DISCOVER
      ADOBESERVER_1        =   1102  # ADOBE SERVER 1
      ADOBESERVER_2        =   1103  # ADOBE SERVER 2
      XRL                  =   1104  # XRL
      FTRANHC              =   1105  # FTRANHC
      ISOIPSIGPORT_1       =   1106  # ISOIPSIGPORT_1
      ISOIPSIGPORT_2       =   1107  # ISOIPSIGPORT_2
      RATIO_ADP            =   1108  # ratio_adp
      WEBADMSTART          =   1110  # Start web admin server
      LMSOCIALSERVER       =   1111  # LM Social Server
      ICP                  =   1112  # Intelligent Communication Protocol
      LTP_DEEPSPACE        =   1113  # Licklider Transmission Protocol
      MINI_SQL             =   1114  # Mini SQL
      ARDUS_TRNS           =   1115  # ARDUS Transfer
      ARDUS_CNTL           =   1116  # ARDUS Control
      ARDUS_MTRNS          =   1117  # ARDUS Multicast Transfer
      SACRED               =   1118  # SACRED
      BNETGAME             =   1119  # Battle.net Chat_Game Protocol
      BNETFILE             =   1120  # Battle.net File Transfer Protocol
      RMPP                 =   1121  # Datalode RMPP
      AVAILANT_MGR         =   1122  # availant_mgr
      MURRAY               =   1123  # Murray
      HPVMMCONTROL         =   1124  # HP VMM Control
      HPVMMAGENT           =   1125  # HP VMM Agent
      HPVMMDATA            =   1126  # HP VMM Agent
      KWDB_COMMN           =   1127  # KWDB Remote Communication
      SAPHOSTCTRL          =   1128  # SAPHostControl over SOAP_HTTP
      SAPHOSTCTRLS         =   1129  # SAPHostControl over SOAP_HTTPS
      CASP                 =   1130  # CAC App Service Protocol
      CASPSSL              =   1131  # CAC App Service Protocol Encripted
      KVM_VIA_IP           =   1132  # KVM_via_IP Management Service
      DFN                  =   1133  # Data Flow Network
      APLX                 =   1134  # MicroAPL APLX
      OMNIVISION           =   1135  # OmniVision Communication Service
      HHB_GATEWAY          =   1136  # HHB Gateway Control
      TRIM                 =   1137  # TRIM Workgroup Service
      ENCRYPTED_ADMIN      =   1138  # encrypted admin requestsIANA assigned this well_formed service name as a replacement for "encrypted_admin".
      ENCRYPTED_ADMIN      =   1138  # encrypted admin requests
      EVM                  =   1139  # Enterprise Virtual Manager
      AUTONOC              =   1140  # AutoNOC Network Operations Protocol
      MXOMSS               =   1141  # User Message Service
      EDTOOLS              =   1142  # User Discovery Service
      IMYX                 =   1143  # Infomatryx Exchange
      FUSCRIPT             =   1144  # Fusion Script
      X9_ICUE              =   1145  # X9 iCue Show Control
      AUDIT_TRANSFER       =   1146  # audit transfer
      CAPIOVERLAN          =   1147  # CAPIoverLAN
      ELFIQ_REPL           =   1148  # Elfiq Replication Service
      BVTSONAR             =   1149  # BlueView Sonar Service
      BLAZE                =   1150  # Blaze File Server
      UNIZENSUS            =   1151  # Unizensus Login Server
      WINPOPLANMESS        =   1152  # Winpopup LAN Messenger
      C1222_ACSE           =   1153  # ANSI C12.22 Port
      RESACOMMUNITY        =   1154  # Community Service
      NFA                  =   1155  # Network File Access
      IASCONTROL_OMS       =   1156  # iasControl OMS
      IASCONTROL           =   1157  # Oracle iASControl
      DBCONTROL_OMS        =   1158  # dbControl OMS
      ORACLE_OMS           =   1159  # Oracle OMS
      OLSV                 =   1160  # DB Lite Mult_User Server
      HEALTH_POLLING       =   1161  # Health Polling
      HEALTH_TRAP          =   1162  # Health Trap
      SDDP                 =   1163  # SmartDialer Data Protocol
      QSM_PROXY            =   1164  # QSM Proxy Service
      QSM_GUI              =   1165  # QSM GUI Service
      QSM_REMOTE           =   1166  # QSM RemoteExec
      CISCO_IPSLA          =   1167  # Cisco IP SLAs Control Protocol
      VCHAT                =   1168  # VChat Conference Service
      TRIPWIRE             =   1169  # TRIPWIRE
      ATC_LM               =   1170  # AT+C License Manager
      ATC_APPSERVER        =   1171  # AT+C FmiApplicationServer
      DNAP                 =   1172  # DNA Protocol
      D_CINEMA_RRP         =   1173  # D_Cinema Request_Response
      FNET_REMOTE_UI       =   1174  # FlashNet Remote Admin
      DOSSIER              =   1175  # Dossier Server
      INDIGO_SERVER        =   1176  # Indigo Home Server
      DKMESSENGER          =   1177  # DKMessenger Protocol
      SGI_STORMAN          =   1178  # SGI Storage Manager
      B2N                  =   1179  # Backup To Neighbor
      MC_CLIENT            =   1180  # Millicent Client Proxy
#      3COMNETMAN           =   1181  # 3Com Net Management
      ACCELENET            =   1182  # AcceleNet Control
      LLSURFUP_HTTP        =   1183  # LL Surfup HTTP
      LLSURFUP_HTTPS       =   1184  # LL Surfup HTTPS
      CATCHPOLE            =   1185  # Catchpole port
      MYSQL_CLUSTER        =   1186  # MySQL Cluster Manager
      ALIAS                =   1187  # Alias Service
      HP_WEBADMIN          =   1188  # HP Web Admin
      UNET                 =   1189  # Unet Connection
      COMMLINX_AVL         =   1190  # CommLinx GPS _ AVL System
      GPFS                 =   1191  # General Parallel File System
      CAIDS_SENSOR         =   1192  # caids sensors channel
      FIVEACROSS           =   1193  # Five Across Server
      OPENVPN              =   1194  # OpenVPN
      RSF_1                =   1195  # RSF_1 clustering
      NETMAGIC             =   1196  # Network Magic
      CARRIUS_RSHELL       =   1197  # Carrius Remote Access
      CAJO_DISCOVERY       =   1198  # cajo reference discovery
      DMIDI                =   1199  # DMIDI
      SCOL                 =   1200  # SCOL
      NUCLEUS_SAND         =   1201  # Nucleus Sand Database Server
      CAICCIPC             =   1202  # caiccipc
      SSSLIC_MGR           =   1203  # License Validation
      SSSLOG_MGR           =   1204  # Log Request Listener
      ACCORD_MGC           =   1205  # Accord_MGC
      ANTHONY_DATA         =   1206  # Anthony Data
      METASAGE             =   1207  # MetaSage
      SEAGULL_AIS          =   1208  # SEAGULL AIS
      IPCD3                =   1209  # IPCD3
      EOSS                 =   1210  # EOSS
      GROOVE_DPP           =   1211  # Groove DPP
      LUPA                 =   1212  # lupa
      MPC_LIFENET          =   1213  # Medtronic_Physio_Control LIFENET
      KAZAA                =   1214  # KAZAA
      SCANSTAT_1           =   1215  # scanSTAT 1.0
      ETEBAC5              =   1216  # ETEBAC 5
      HPSS_NDAPI           =   1217  # HPSS NonDCE Gateway
      AEROFLIGHT_ADS       =   1218  # AeroFlight_ADs
      AEROFLIGHT_RET       =   1219  # AeroFlight_Ret
      QT_SERVERADMIN       =   1220  # QT SERVER ADMIN
      SWEETWARE_APPS       =   1221  # SweetWARE Apps
      NERV                 =   1222  # SNI R&D network
      TGP                  =   1223  # TrulyGlobal Protocol
      VPNZ                 =   1224  # VPNz
      SLINKYSEARCH         =   1225  # SLINKYSEARCH
      STGXFWS              =   1226  # STGXFWS
      DNS2GO               =   1227  # DNS2Go
      FLORENCE             =   1228  # FLORENCE
      ZENTED               =   1229  # ZENworks Tiered Electronic Distribution
      PERISCOPE            =   1230  # Periscope
      MENANDMICE_LPM       =   1231  # menandmice_lpm
      FIRST_DEFENSE        =   1232  # Remote systems monitoring
      UNIV_APPSERVER       =   1233  # Universal App Server
      SEARCH_AGENT         =   1234  # Infoseek Search Agent
      MOSAICSYSSVC1        =   1235  # mosaicsyssvc1
      BVCONTROL            =   1236  # bvcontrol
      TSDOS390             =   1237  # tsdos390
      HACL_QS              =   1238  # hacl_qs
      NMSD                 =   1239  # NMSD
      INSTANTIA            =   1240  # Instantia
      NESSUS               =   1241  # nessus
      NMASOVERIP           =   1242  # NMAS over IP
      SERIALGATEWAY        =   1243  # SerialGateway
      ISBCONFERENCE1       =   1244  # isbconference1
      ISBCONFERENCE2       =   1245  # isbconference2
      PAYROUTER            =   1246  # payrouter
      VISIONPYRAMID        =   1247  # VisionPyramid
      HERMES               =   1248  # hermes
      MESAVISTACO          =   1249  # Mesa Vista Co
      SWLDY_SIAS           =   1250  # swldy_sias
      SERVERGRAPH          =   1251  # servergraph
      BSPNE_PCC            =   1252  # bspne_pcc
      Q55_PCC              =   1253  # q55_pcc
      DE_NOC               =   1254  # de_noc
      DE_CACHE_QUERY       =   1255  # de_cache_query
      DE_SERVER            =   1256  # de_server
      SHOCKWAVE2           =   1257  # Shockwave 2
      OPENNL               =   1258  # Open Network Library
      OPENNL_VOICE         =   1259  # Open Network Library Voice
      IBM_SSD              =   1260  # ibm_ssd
      MPSHRSV              =   1261  # mpshrsv
      QNTS_ORB             =   1262  # QNTS_ORB
      DKA                  =   1263  # dka
      PRAT                 =   1264  # PRAT
      DSSIAPI              =   1265  # DSSIAPI
      DELLPWRAPPKS         =   1266  # DELLPWRAPPKS
      EPC                  =   1267  # eTrust Policy Compliance
      PROPEL_MSGSYS        =   1268  # PROPEL_MSGSYS
      WATILAPP             =   1269  # WATiLaPP
      OPSMGR               =   1270  # Microsoft Operations Manager
      EXCW                 =   1271  # eXcW
      CSPMLOCKMGR          =   1272  # CSPMLockMgr
      EMC_GATEWAY          =   1273  # EMC_Gateway
      T1DISTPROC           =   1274  # t1distproc
      IVCOLLECTOR          =   1275  # ivcollector
      MIVA_MQS             =   1277  # mqs
      DELLWEBADMIN_1       =   1278  # Dell Web Admin 1
      DELLWEBADMIN_2       =   1279  # Dell Web Admin 2
      PICTROGRAPHY         =   1280  # Pictrography
      HEALTHD              =   1281  # healthd
      EMPERION             =   1282  # Emperion
      PRODUCTINFO          =   1283  # Product Information
      IEE_QFX              =   1284  # IEE_QFX
      NEOIFACE             =   1285  # neoiface
      NETUITIVE            =   1286  # netuitive
      ROUTEMATCH           =   1287  # RouteMatch Com
      NAVBUDDY             =   1288  # NavBuddy
      JWALKSERVER          =   1289  # JWalkServer
      WINJASERVER          =   1290  # WinJaServer
      SEAGULLLMS           =   1291  # SEAGULLLMS
      DSDN                 =   1292  # dsdn
      PKT_KRB_IPSEC        =   1293  # PKT_KRB_IPSec
      CMMDRIVER            =   1294  # CMMdriver
      EHTP                 =   1295  # End_by_Hop Transmission Protocol
      DPROXY               =   1296  # dproxy
      SDPROXY              =   1297  # sdproxy
      LPCP                 =   1298  # lpcp
      HP_SCI               =   1299  # hp_sci
      H323HOSTCALLSC       =   1300  # H.323 Secure Call Control Signalling
      CI3_SOFTWARE_1       =   1301  # CI3_Software_1
      CI3_SOFTWARE_2       =   1302  # CI3_Software_2
      SFTSRV               =   1303  # sftsrv
      BOOMERANG            =   1304  # Boomerang
      PE_MIKE              =   1305  # pe_mike
      RE_CONN_PROTO        =   1306  # RE_Conn_Proto
      PACMAND              =   1307  # Pacmand
      ODSI                 =   1308  # Optical Domain Service Interconnect (ODSI)
      JTAG_SERVER          =   1309  # JTAG server
      HUSKY                =   1310  # Husky
      RXMON                =   1311  # RxMon
      STI_ENVISION         =   1312  # STI Envision
      BMC_PATROLDB         =   1313  # BMC_PATROLDBIANA assigned this well_formed service name as a replacement for "bmc_patroldb".
      BMC_PATROLDB         =   1313  # BMC_PATROLDB
      PDPS                 =   1314  # Photoscript Distributed Printing System
      ELS                  =   1315  # E.L.S., Event Listener Service
      EXBIT_ESCP           =   1316  # Exbit_ESCP
      VRTS_IPCSERVER       =   1317  # vrts_ipcserver
      KRB5GATEKEEPER       =   1318  # krb5gatekeeper
      AMX_ICSP             =   1319  # AMX_ICSP
      AMX_AXBNET           =   1320  # AMX_AXBNET
      PIP                  =   1321  # PIP
      NOVATION             =   1322  # Novation
      BRCD                 =   1323  # brcd
      DELTA_MCP            =   1324  # delta_mcp
      DX_INSTRUMENT        =   1325  # DX_Instrument
      WIMSIC               =   1326  # WIMSIC
      ULTREX               =   1327  # Ultrex
      EWALL                =   1328  # EWALL
      NETDB_EXPORT         =   1329  # netdb_export
      STREETPERFECT        =   1330  # StreetPerfect
      INTERSAN             =   1331  # intersan
      PCIA_RXP_B           =   1332  # PCIA RXP_B
      PASSWRD_POLICY       =   1333  # Password Policy
      WRITESRV             =   1334  # writesrv
      DIGITAL_NOTARY       =   1335  # Digital Notary Protocol
      ISCHAT               =   1336  # Instant Service Chat
      MENANDMICE_DNS       =   1337  # menandmice DNS
      WMC_LOG_SVC          =   1338  # WMC_log_svr
      KJTSITESERVER        =   1339  # kjtsiteserver
      NAAP                 =   1340  # NAAP
      QUBES                =   1341  # QuBES
      ESBROKER             =   1342  # ESBroker
      RE101                =   1343  # re101
      ICAP                 =   1344  # ICAP
      VPJP                 =   1345  # VPJP
      ALTA_ANA_LM          =   1346  # Alta Analytics License Manager
      BBN_MMC              =   1347  # multi media conferencing
      BBN_MMX              =   1348  # multi media conferencing
      SBOOK                =   1349  # Registration Network Protocol
      EDITBENCH            =   1350  # Registration Network Protocol
      EQUATIONBUILDER      =   1351  # Digital Tool Works (MIT)
      LOTUSNOTE            =   1352  # Lotus Note
      RELIEF               =   1353  # Relief Consulting
      XSIP_NETWORK         =   1354  # Five Across XSIP Network
      INTUITIVE_EDGE       =   1355  # Intuitive Edge
      CUILLAMARTIN         =   1356  # CuillaMartin Company
      PEGBOARD             =   1357  # Electronic PegBoard
      CONNLCLI             =   1358  # CONNLCLI
      FTSRV                =   1359  # FTSRV
      MIMER                =   1360  # MIMER
      LINX                 =   1361  # LinX
      TIMEFLIES            =   1362  # TimeFlies
      NDM_REQUESTER        =   1363  # Network DataMover Requester
      NDM_SERVER           =   1364  # Network DataMover Server
      ADAPT_SNA            =   1365  # Network Software Associates
      NETWARE_CSP          =   1366  # Novell NetWare Comm Service Platform
      DCS                  =   1367  # DCS
      SCREENCAST           =   1368  # ScreenCast
      GV_US                =   1369  # GlobalView to Unix Shell
      US_GV                =   1370  # Unix Shell to GlobalView
      FC_CLI               =   1371  # Fujitsu Config Protocol
      FC_SER               =   1372  # Fujitsu Config Protocol
      CHROMAGRAFX          =   1373  # Chromagrafx
      MOLLY                =   1374  # EPI Software Systems
      BYTEX                =   1375  # Bytex
      IBM_PPS              =   1376  # IBM Person to Person Software
      CICHLID              =   1377  # Cichlid License Manager
      ELAN                 =   1378  # Elan License Manager
      DBREPORTER           =   1379  # Integrity Solutions
      TELESIS_LICMAN       =   1380  # Telesis Network License Manager
      APPLE_LICMAN         =   1381  # Apple Network License Manager
      UDT_OS               =   1382  # udt_osIANA assigned this well_formed service name as a replacement for "udt_os".
      UDT_OS               =   1382  # udt_os This entry is an alias to "udt_os".This entry is now historic, not usable for use with manycommon service discovery mechanisms.
      GWHA                 =   1383  # GW Hannaway Network License Manager
      OS_LICMAN            =   1384  # Objective Solutions License Manager
      ATEX_ELMD            =   1385  # Atex Publishing License ManagerIANA assigned this well_formed service name as a replacement for "atex_elmd".
      ATEX_ELMD            =   1385  # Atex Publishing License Manager
      CHECKSUM             =   1386  # CheckSum License Manager
      CADSI_LM             =   1387  # Computer Aided Design Software Inc LM
      OBJECTIVE_DBC        =   1388  # Objective Solutions DataBase Cache
      ICLPV_DM             =   1389  # Document Manager
      ICLPV_SC             =   1390  # Storage Controller
      ICLPV_SAS            =   1391  # Storage Access Server
      ICLPV_PM             =   1392  # Print Manager
      ICLPV_NLS            =   1393  # Network Log Server
      ICLPV_NLC            =   1394  # Network Log Client
      ICLPV_WSM            =   1395  # PC Workstation Manager software
      DVL_ACTIVEMAIL       =   1396  # DVL Active Mail
      AUDIO_ACTIVMAIL      =   1397  # Audio Active Mail
      VIDEO_ACTIVMAIL      =   1398  # Video Active Mail
      CADKEY_LICMAN        =   1399  # Cadkey License Manager
      CADKEY_TABLET        =   1400  # Cadkey Tablet Daemon
      GOLDLEAF_LICMAN      =   1401  # Goldleaf License Manager
      PRM_SM_NP            =   1402  # Prospero Resource Manager
      PRM_NM_NP            =   1403  # Prospero Resource Manager
      IGI_LM               =   1404  # Infinite Graphics License Manager
      IBM_RES              =   1405  # IBM Remote Execution Starter
      NETLABS_LM           =   1406  # NetLabs License Manager
      DBSA_LM              =   1407  # DBSA License Manager
      SOPHIA_LM            =   1408  # Sophia License Manager
      HERE_LM              =   1409  # Here License Manager
      HIQ                  =   1410  # HiQ License Manager
      AF                   =   1411  # AudioFile
      INNOSYS              =   1412  # InnoSys
      INNOSYS_ACL          =   1413  # Innosys_ACL
      IBM_MQSERIES         =   1414  # IBM MQSeries
      DBSTAR               =   1415  # DBStar
      NOVELL_LU6_2         =   1416  # Novell LU6.2IANA assigned this well_formed service name as a replacement for "novell_lu6.2".
#      NOVELL_LU6.2         =   1416  # Novell LU6.2
      TIMBUKTU_SRV1        =   1417  # Timbuktu Service 1 Port
      TIMBUKTU_SRV2        =   1418  # Timbuktu Service 2 Port
      TIMBUKTU_SRV3        =   1419  # Timbuktu Service 3 Port
      TIMBUKTU_SRV4        =   1420  # Timbuktu Service 4 Port
      GANDALF_LM           =   1421  # Gandalf License Manager
      AUTODESK_LM          =   1422  # Autodesk License Manager
      ESSBASE              =   1423  # Essbase Arbor Software
      HYBRID               =   1424  # Hybrid Encryption Protocol
      ZION_LM              =   1425  # Zion Software License Manager
      SAIS                 =   1426  # Satellite_data Acquisition System 1
      MLOADD               =   1427  # mloadd monitoring tool
      INFORMATIK_LM        =   1428  # Informatik License Manager
      NMS                  =   1429  # Hypercom NMS
      TPDU                 =   1430  # Hypercom TPDU
      RGTP                 =   1431  # Reverse Gossip Transport
      BLUEBERRY_LM         =   1432  # Blueberry Software License Manager
      MS_SQL_S             =   1433  # Microsoft_SQL_Server
      MS_SQL_M             =   1434  # Microsoft_SQL_Monitor
      IBM_CICS             =   1435  # IBM CICS
      SAISM                =   1436  # Satellite_data Acquisition System 2
      TABULA               =   1437  # Tabula
      EICON_SERVER         =   1438  # Eicon Security Agent_Server
      EICON_X25            =   1439  # Eicon X25_SNA Gateway
      EICON_SLP            =   1440  # Eicon Service Location Protocol
      CADIS_1              =   1441  # Cadis License Management
      CADIS_2              =   1442  # Cadis License Management
      IES_LM               =   1443  # Integrated Engineering Software
      MARCAM_LM            =   1444  # Marcam  License Management
      PROXIMA_LM           =   1445  # Proxima License Manager
      ORA_LM               =   1446  # Optical Research Associates License Manager
      APRI_LM              =   1447  # Applied Parallel Research LM
      OC_LM                =   1448  # OpenConnect License Manager
      PEPORT               =   1449  # PEport
      DWF                  =   1450  # Tandem Distributed Workbench Facility
      INFOMAN              =   1451  # IBM Information Management
      GTEGSC_LM            =   1452  # GTE Government Systems License Man
      GENIE_LM             =   1453  # Genie License Manager
      INTERHDL_ELMD        =   1454  # interHDL License ManagerIANA assigned this well_formed service name as a replacement for "interhdl_elmd".
      INTERHDL_ELMD        =   1454  # interHDL License Manager
      ESL_LM               =   1455  # ESL License Manager
      DCA                  =   1456  # DCA
      VALISYS_LM           =   1457  # Valisys License Manager
      NRCABQ_LM            =   1458  # Nichols Research Corp.
      PROSHARE1            =   1459  # Proshare Notebook Application
      PROSHARE2            =   1460  # Proshare Notebook Application
      IBM_WRLESS_LAN       =   1461  # IBM Wireless LANIANA assigned this well_formed service name as a replacement for "ibm_wrless_lan".
      IBM_WRLESS_LAN       =   1461  # IBM Wireless LAN
      WORLD_LM             =   1462  # World License Manager
      NUCLEUS              =   1463  # Nucleus
      MSL_LMD              =   1464  # MSL License ManagerIANA assigned this well_formed service name as a replacement for "msl_lmd".
      MSL_LMD              =   1464  # MSL License Manager
      PIPES                =   1465  # Pipes Platform
      OCEANSOFT_LM         =   1466  # Ocean Software License Manager
      CSDMBASE             =   1467  # CSDMBASE
      CSDM                 =   1468  # CSDM
      AAL_LM               =   1469  # Active Analysis Limited License Manager
      UAIACT               =   1470  # Universal Analytics
      CSDMBASE             =   1471  # csdmbase
      CSDM                 =   1472  # csdm
      OPENMATH             =   1473  # OpenMath
      TELEFINDER           =   1474  # Telefinder
      TALIGENT_LM          =   1475  # Taligent License Manager
      CLVM_CFG             =   1476  # clvm_cfg
      MS_SNA_SERVER        =   1477  # ms_sna_server
      MS_SNA_BASE          =   1478  # ms_sna_base
      DBEREGISTER          =   1479  # dberegister
      PACERFORUM           =   1480  # PacerForum
      AIRS                 =   1481  # AIRS
      MITEKSYS_LM          =   1482  # Miteksys License Manager
      AFS                  =   1483  # AFS License Manager
      CONFLUENT            =   1484  # Confluent License Manager
      LANSOURCE            =   1485  # LANSource
      NMS_TOPO_SERV        =   1486  # nms_topo_servIANA assigned this well_formed service name as a replacement for "nms_topo_serv".
      NMS_TOPO_SERV        =   1486  # nms_topo_serv
      LOCALINFOSRVR        =   1487  # LocalInfoSrvr
      DOCSTOR              =   1488  # DocStor
      DMDOCBROKER          =   1489  # dmdocbroker
      INSITU_CONF          =   1490  # insitu_conf
      STONE_DESIGN_1       =   1492  # stone_design_1
      NETMAP_LM            =   1493  # netmap_lmIANA assigned this well_formed service name as a replacement for "netmap_lm".
      NETMAP_LM            =   1493  # netmap_lm
      ICA                  =   1494  # ica
      CVC                  =   1495  # cvc
      LIBERTY_LM           =   1496  # liberty_lm
      RFX_LM               =   1497  # rfx_lm
      SYBASE_SQLANY        =   1498  # Sybase SQL Any
      FHC                  =   1499  # Federico Heinz Consultora
      VLSI_LM              =   1500  # VLSI License Manager
      SAISCM               =   1501  # Satellite_data Acquisition System 3
      SHIVADISCOVERY       =   1502  # Shiva
      IMTC_MCS             =   1503  # Databeam
      EVB_ELM              =   1504  # EVB Software Engineering License Manager
      FUNKPROXY            =   1505  # Funk Software, Inc.
      UTCD                 =   1506  # Universal Time daemon (utcd)
      SYMPLEX              =   1507  # symplex
      DIAGMOND             =   1508  # diagmond
      ROBCAD_LM            =   1509  # Robcad, Ltd. License Manager
      MVX_LM               =   1510  # Midland Valley Exploration Ltd. Lic. Man.
#      3L_L1                =   1511  # 3l_l1
      WINS                 =   1512  # Microsoft's Windows Internet Name Service
      FUJITSU_DTC          =   1513  # Fujitsu Systems Business of America, Inc
      FUJITSU_DTCNS        =   1514  # Fujitsu Systems Business of America, Inc
      IFOR_PROTOCOL        =   1515  # ifor_protocol
      VPAD                 =   1516  # Virtual Places Audio data
      VPAC                 =   1517  # Virtual Places Audio control
      VPVD                 =   1518  # Virtual Places Video data
      VPVC                 =   1519  # Virtual Places Video control
      ATM_ZIP_OFFICE       =   1520  # atm zip office
      NCUBE_LM             =   1521  # nCube License Manager
      RICARDO_LM           =   1522  # Ricardo North America License Manager
      CICHILD_LM           =   1523  # cichild
      INGRESLOCK           =   1524  # ingres
      ORASRV               =   1525  # oracle
      PROSPERO_NP          =   1525  # Prospero Directory Service non_priv
      PDAP_NP              =   1526  # Prospero Data Access Prot non_priv
      TLISRV               =   1527  # oracle
      COAUTHOR             =   1529  # oracle
      RAP_SERVICE          =   1530  # rap_service
      RAP_LISTEN           =   1531  # rap_listen
      MIROCONNECT          =   1532  # miroconnect
      VIRTUAL_PLACES       =   1533  # Virtual Places Software
      MICROMUSE_LM         =   1534  # micromuse_lm
      AMPR_INFO            =   1535  # ampr_info
      AMPR_INTER           =   1536  # ampr_inter
      SDSC_LM              =   1537  # isi_lm
#      3DS_LM               =   1538  # 3ds_lm
      INTELLISTOR_LM       =   1539  # Intellistor License Manager
      RDS                  =   1540  # rds
      RDS2                 =   1541  # rds2
      GRIDGEN_ELMD         =   1542  # gridgen_elmd
      SIMBA_CS             =   1543  # simba_cs
      ASPECLMD             =   1544  # aspeclmd
      VISTIUM_SHARE        =   1545  # vistium_share
      ABBACCURAY           =   1546  # abbaccuray
      LAPLINK              =   1547  # laplink
      AXON_LM              =   1548  # Axon License Manager
      SHIVAHOSE            =   1549  # Shiva Hose
#      3M_IMAGE_LM          =   1550  # Image Storage license manager 3M Company
      HECMTL_DB            =   1551  # HECMTL_DB
      PCIARRAY             =   1552  # pciarray
      SNA_CS               =   1553  # sna_cs
      CACI_LM              =   1554  # CACI Products Company License Manager
      LIVELAN              =   1555  # livelan
      VERITAS_PBX          =   1556  # VERITAS Private Branch ExchangeIANA assigned this well_formed service name as a replacement for "veritas_pbx".
      VERITAS_PBX          =   1556  # VERITAS Private Branch Exchange
      ARBORTEXT_LM         =   1557  # ArborText License Manager
      XINGMPEG             =   1558  # xingmpeg
      WEB2HOST             =   1559  # web2host
      ASCI_VAL             =   1560  # ASCI_RemoteSHADOW
      FACILITYVIEW         =   1561  # facilityview
      PCONNECTMGR          =   1562  # pconnectmgr
      CADABRA_LM           =   1563  # Cadabra License Manager
      PAY_PER_VIEW         =   1564  # Pay_Per_View
      WINDDLB              =   1565  # WinDD
      CORELVIDEO           =   1566  # CORELVIDEO
      JLICELMD             =   1567  # jlicelmd
      TSSPMAP              =   1568  # tsspmap
      ETS                  =   1569  # ets
      ORBIXD               =   1570  # orbixd
      RDB_DBS_DISP         =   1571  # Oracle Remote Data Base
      CHIP_LM              =   1572  # Chipcom License Manager
      ITSCOMM_NS           =   1573  # itscomm_ns
      MVEL_LM              =   1574  # mvel_lm
      ORACLENAMES          =   1575  # oraclenames
      MOLDFLOW_LM          =   1576  # Moldflow License Manager
      HYPERCUBE_LM         =   1577  # hypercube_lm
      JACOBUS_LM           =   1578  # Jacobus License Manager
      IOC_SEA_LM           =   1579  # ioc_sea_lm
      TN_TL_R1             =   1580  # tn_tl_r1
      MIL_2045_47001       =   1581  # MIL_2045_47001
      MSIMS                =   1582  # MSIMS
      SIMBAEXPRESS         =   1583  # simbaexpress
      TN_TL_FD2            =   1584  # tn_tl_fd2
      INTV                 =   1585  # intv
      IBM_ABTACT           =   1586  # ibm_abtact
      PRA_ELMD             =   1587  # pra_elmdIANA assigned this well_formed service name as a replacement for "pra_elmd".
      PRA_ELMD             =   1587  # pra_elmd
      TRIQUEST_LM          =   1588  # triquest_lm
      VQP                  =   1589  # VQP
      GEMINI_LM            =   1590  # gemini_lm
      NCPM_PM              =   1591  # ncpm_pm
      COMMONSPACE          =   1592  # commonspace
      MAINSOFT_LM          =   1593  # mainsoft_lm
      SIXTRAK              =   1594  # sixtrak
      RADIO                =   1595  # radio
      RADIO_SM             =   1596  # radio_sm
      ORBPLUS_IIOP         =   1597  # orbplus_iiop
      PICKNFS              =   1598  # picknfs
      SIMBASERVICES        =   1599  # simbaservices
      ISSD                 =   1600  # issd
      AAS                  =   1601  # aas
      INSPECT              =   1602  # inspect
      PICODBC              =   1603  # pickodbc
      ICABROWSER           =   1604  # icabrowser
      SLP                  =   1605  # Salutation Manager (Salutation Protocol)
      SLM_API              =   1606  # Salutation Manager (SLM_API)
      STT                  =   1607  # stt
      SMART_LM             =   1608  # Smart Corp. License Manager
      ISYSG_LM             =   1609  # isysg_lm
      TAURUS_WH            =   1610  # taurus_wh
      ILL                  =   1611  # Inter Library Loan
      NETBILL_TRANS        =   1612  # NetBill Transaction Server
      NETBILL_KEYREP       =   1613  # NetBill Key Repository
      NETBILL_CRED         =   1614  # NetBill Credential Server
      NETBILL_AUTH         =   1615  # NetBill Authorization Server
      NETBILL_PROD         =   1616  # NetBill Product Server
      NIMROD_AGENT         =   1617  # Nimrod Inter_Agent Communication
      SKYTELNET            =   1618  # skytelnet
      XS_OPENSTORAGE       =   1619  # xs_openstorage
      FAXPORTWINPORT       =   1620  # faxportwinport
      SOFTDATAPHONE        =   1621  # softdataphone
      ONTIME               =   1622  # ontime
      JALEOSND             =   1623  # jaleosnd
      UDP_SR_PORT          =   1624  # udp_sr_port
      SVS_OMAGENT          =   1625  # svs_omagent
      SHOCKWAVE            =   1626  # Shockwave
      T128_GATEWAY         =   1627  # T.128 Gateway
      LONTALK_NORM         =   1628  # LonTalk normal
      LONTALK_URGNT        =   1629  # LonTalk urgent
      ORACLENET8CMAN       =   1630  # Oracle Net8 Cman
      VISITVIEW            =   1631  # Visit view
      PAMMRATC             =   1632  # PAMMRATC
      PAMMRPC              =   1633  # PAMMRPC
      LOAPROBE             =   1634  # Log On America Probe
      EDB_SERVER1          =   1635  # EDB Server 1
      ISDC                 =   1636  # ISP shared public data control
      ISLC                 =   1637  # ISP shared local data control
      ISMC                 =   1638  # ISP shared management control
      CERT_INITIATOR       =   1639  # cert_initiator
      CERT_RESPONDER       =   1640  # cert_responder
      INVISION             =   1641  # InVision
      ISIS_AM              =   1642  # isis_am
      ISIS_AMBC            =   1643  # isis_ambc
      SAISEH               =   1644  # Satellite_data Acquisition System 4
      SIGHTLINE            =   1645  # SightLine
      SA_MSG_PORT          =   1646  # sa_msg_port
      RSAP                 =   1647  # rsap
      CONCURRENT_LM        =   1648  # concurrent_lm
      KERMIT               =   1649  # kermit
      NKD                  =   1650  # nkdn
      SHIVA_CONFSRVR       =   1651  # shiva_confsrvrIANA assigned this well_formed service name as a replacement for "shiva_confsrvr".
      SHIVA_CONFSRVR       =   1651  # shiva_confsrvr
      XNMP                 =   1652  # xnmp
      ALPHATECH_LM         =   1653  # alphatech_lm
      STARGATEALERTS       =   1654  # stargatealerts
      DEC_MBADMIN          =   1655  # dec_mbadmin
      DEC_MBADMIN_H        =   1656  # dec_mbadmin_h
      FUJITSU_MMPDC        =   1657  # fujitsu_mmpdc
      SIXNETUDR            =   1658  # sixnetudr
      SG_LM                =   1659  # Silicon Grail License Manager
      SKIP_MC_GIKREQ       =   1660  # skip_mc_gikreq
      NETVIEW_AIX_1        =   1661  # netview_aix_1
      NETVIEW_AIX_2        =   1662  # netview_aix_2
      NETVIEW_AIX_3        =   1663  # netview_aix_3
      NETVIEW_AIX_4        =   1664  # netview_aix_4
      NETVIEW_AIX_5        =   1665  # netview_aix_5
      NETVIEW_AIX_6        =   1666  # netview_aix_6
      NETVIEW_AIX_7        =   1667  # netview_aix_7
      NETVIEW_AIX_8        =   1668  # netview_aix_8
      NETVIEW_AIX_9        =   1669  # netview_aix_9
      NETVIEW_AIX_10       =   1670  # netview_aix_10
      NETVIEW_AIX_11       =   1671  # netview_aix_11
      NETVIEW_AIX_12       =   1672  # netview_aix_12
      PROSHARE_MC_1        =   1673  # Intel Proshare Multicast
      PROSHARE_MC_2        =   1674  # Intel Proshare Multicast
      PDP                  =   1675  # Pacific Data Products
      NETCOMM1             =   1676  # netcomm1
      GROUPWISE            =   1677  # groupwise
      PROLINK              =   1678  # prolink
      DARCORP_LM           =   1679  # darcorp_lm
      MICROCOM_SBP         =   1680  # microcom_sbp
      SD_ELMD              =   1681  # sd_elmd
      LANYON_LANTERN       =   1682  # lanyon_lantern
      NCPM_HIP             =   1683  # ncpm_hip
      SNARESECURE          =   1684  # SnareSecure
      N2NREMOTE            =   1685  # n2nremote
      CVMON                =   1686  # cvmon
      NSJTP_CTRL           =   1687  # nsjtp_ctrl
      NSJTP_DATA           =   1688  # nsjtp_data
      FIREFOX              =   1689  # firefox
      NG_UMDS              =   1690  # ng_umds
      EMPIRE_EMPUMA        =   1691  # empire_empuma
      SSTSYS_LM            =   1692  # sstsys_lm
      RRIRTR               =   1693  # rrirtr
      RRIMWM               =   1694  # rrimwm
      RRILWM               =   1695  # rrilwm
      RRIFMM               =   1696  # rrifmm
      RRISAT               =   1697  # rrisat
      RSVP_ENCAP_1         =   1698  # RSVP_ENCAPSULATION_1
      RSVP_ENCAP_2         =   1699  # RSVP_ENCAPSULATION_2
      MPS_RAFT             =   1700  # mps_raft
      L2F                  =   1701  # l2f
      L2TP                 =   1701  # l2tp
      DESKSHARE            =   1702  # deskshare
      HB_ENGINE            =   1703  # hb_engine
      BCS_BROKER           =   1704  # bcs_broker
      SLINGSHOT            =   1705  # slingshot
      JETFORM              =   1706  # jetform
      VDMPLAY              =   1707  # vdmplay
      GAT_LMD              =   1708  # gat_lmd
      CENTRA               =   1709  # centra
      IMPERA               =   1710  # impera
      PPTCONFERENCE        =   1711  # pptconference
      REGISTRAR            =   1712  # resource monitoring service
      CONFERENCETALK       =   1713  # ConferenceTalk
      SESI_LM              =   1714  # sesi_lm
      HOUDINI_LM           =   1715  # houdini_lm
      XMSG                 =   1716  # xmsg
      FJ_HDNET             =   1717  # fj_hdnet
      H323GATEDISC         =   1718  # H.323 Multicast Gatekeeper Discover
      H323GATESTAT         =   1719  # H.323 Unicast Gatekeeper Signaling
      H323HOSTCALL         =   1720  # H.323 Call Control Signalling
      CAICCI               =   1721  # caicci
      HKS_LM               =   1722  # HKS License Manager
      PPTP                 =   1723  # pptp
      CSBPHONEMASTER       =   1724  # csbphonemaster
      IDEN_RALP            =   1725  # iden_ralp
      IBERIAGAMES          =   1726  # IBERIAGAMES
      WINDDX               =   1727  # winddx
      TELINDUS             =   1728  # TELINDUS
      CITYNL               =   1729  # CityNL License Management
      ROKETZ               =   1730  # roketz
      MSICCP               =   1731  # MSICCP
      PROXIM               =   1732  # proxim
      SIIPAT               =   1733  # SIMS _ SIIPAT Protocol for Alarm Transmission
      CAMBERTX_LM          =   1734  # Camber Corporation License Management
      PRIVATECHAT          =   1735  # PrivateChat
      STREET_STREAM        =   1736  # street_stream
      ULTIMAD              =   1737  # ultimad
      GAMEGEN1             =   1738  # GameGen1
      WEBACCESS            =   1739  # webaccess
      ENCORE               =   1740  # encore
      CISCO_NET_MGMT       =   1741  # cisco_net_mgmt
#      3COM_NSD             =   1742  # 3Com_nsd
      CINEGRFX_LM          =   1743  # Cinema Graphics License Manager
      NCPM_FT              =   1744  # ncpm_ft
      REMOTE_WINSOCK       =   1745  # remote_winsock
      FTRAPID_1            =   1746  # ftrapid_1
      FTRAPID_2            =   1747  # ftrapid_2
      ORACLE_EM1           =   1748  # oracle_em1
      ASPEN_SERVICES       =   1749  # aspen_services
      SSLP                 =   1750  # Simple Socket Library's PortMaster
      SWIFTNET             =   1751  # SwiftNet
      LOFR_LM              =   1752  # Leap of Faith Research License Manager
      PREDATAR_COMMS       =   1753  # Predatar Comms Service
      ORACLE_EM2           =   1754  # oracle_em2
      MS_STREAMING         =   1755  # ms_streaming
      CAPFAST_LMD          =   1756  # capfast_lmd
      CNHRP                =   1757  # cnhrp
      TFTP_MCAST           =   1758  # tftp_mcast
      SPSS_LM              =   1759  # SPSS License Manager
      WWW_LDAP_GW          =   1760  # www_ldap_gw
      CFT_0                =   1761  # cft_0
      CFT_1                =   1762  # cft_1
      CFT_2                =   1763  # cft_2
      CFT_3                =   1764  # cft_3
      CFT_4                =   1765  # cft_4
      CFT_5                =   1766  # cft_5
      CFT_6                =   1767  # cft_6
      CFT_7                =   1768  # cft_7
      BMC_NET_ADM          =   1769  # bmc_net_adm
      BMC_NET_SVC          =   1770  # bmc_net_svc
      VAULTBASE            =   1771  # vaultbase
      ESSWEB_GW            =   1772  # EssWeb Gateway
      KMSCONTROL           =   1773  # KMSControl
      GLOBAL_DTSERV        =   1774  # global_dtserv
      VDAB                 =   1775  # data interchange between visual processing containers
      FEMIS                =   1776  # Federal Emergency Management Information System
      POWERGUARDIAN        =   1777  # powerguardian
      PRODIGY_INTRNET      =   1778  # prodigy_internet
      PHARMASOFT           =   1779  # pharmasoft
      DPKEYSERV            =   1780  # dpkeyserv
      ANSWERSOFT_LM        =   1781  # answersoft_lm
      HP_HCIP              =   1782  # hp_hcip
      FINLE_LM             =   1784  # Finle License Manager
      WINDLM               =   1785  # Wind River Systems License Manager
      FUNK_LOGGER          =   1786  # funk_logger
      FUNK_LICENSE         =   1787  # funk_license
      PSMOND               =   1788  # psmond
      HELLO                =   1789  # hello
      NMSP                 =   1790  # Narrative Media Streaming Protocol
      EA1                  =   1791  # EA1
      IBM_DT_2             =   1792  # ibm_dt_2
      RSC_ROBOT            =   1793  # rsc_robot
      CERA_BCM             =   1794  # cera_bcm
      DPI_PROXY            =   1795  # dpi_proxy
      VOCALTEC_ADMIN       =   1796  # Vocaltec Server Administration
      UMA                  =   1797  # UMA
      ETP                  =   1798  # Event Transfer Protocol
      NETRISK              =   1799  # NETRISK
      ANSYS_LM             =   1800  # ANSYS_License manager
      MSMQ                 =   1801  # Microsoft Message Que
      CONCOMP1             =   1802  # ConComp1
      HP_HCIP_GWY          =   1803  # HP_HCIP_GWY
      ENL                  =   1804  # ENL
      ENL_NAME             =   1805  # ENL_Name
      MUSICONLINE          =   1806  # Musiconline
      FHSP                 =   1807  # Fujitsu Hot Standby Protocol
      ORACLE_VP2           =   1808  # Oracle_VP2
      ORACLE_VP1           =   1809  # Oracle_VP1
      JERAND_LM            =   1810  # Jerand License Manager
      SCIENTIA_SDB         =   1811  # Scientia_SDB
      RADIUS               =   1812  # RADIUS
      RADIUS_ACCT          =   1813  # RADIUS Accounting
      TDP_SUITE            =   1814  # TDP Suite
      MMPFT                =   1815  # MMPFT
      HARP                 =   1816  # HARP
      RKB_OSCS             =   1817  # RKB_OSCS
      ETFTP                =   1818  # Enhanced Trivial File Transfer Protocol
      PLATO_LM             =   1819  # Plato License Manager
      MCAGENT              =   1820  # mcagent
      DONNYWORLD           =   1821  # donnyworld
      ES_ELMD              =   1822  # es_elmd
      UNISYS_LM            =   1823  # Unisys Natural Language License Manager
      METRICS_PAS          =   1824  # metrics_pas
      DIRECPC_VIDEO        =   1825  # DirecPC Video
      ARDT                 =   1826  # ARDT
      ASI                  =   1827  # ASI
      ITM_MCELL_U          =   1828  # itm_mcell_u
      OPTIKA_EMEDIA        =   1829  # Optika eMedia
      NET8_CMAN            =   1830  # Oracle Net8 CMan Admin
      MYRTLE               =   1831  # Myrtle
      THT_TREASURE         =   1832  # ThoughtTreasure
      UDPRADIO             =   1833  # udpradio
      ARDUSUNI             =   1834  # ARDUS Unicast
      ARDUSMUL             =   1835  # ARDUS Multicast
      STE_SMSC             =   1836  # ste_smsc
      CSOFT1               =   1837  # csoft1
      TALNET               =   1838  # TALNET
      NETOPIA_VO1          =   1839  # netopia_vo1
      NETOPIA_VO2          =   1840  # netopia_vo2
      NETOPIA_VO3          =   1841  # netopia_vo3
      NETOPIA_VO4          =   1842  # netopia_vo4
      NETOPIA_VO5          =   1843  # netopia_vo5
      DIRECPC_DLL          =   1844  # DirecPC_DLL
      ALTALINK             =   1845  # altalink
      TUNSTALL_PNC         =   1846  # Tunstall PNC
      SLP_NOTIFY           =   1847  # SLP Notification
      FJDOCDIST            =   1848  # fjdocdist
      ALPHA_SMS            =   1849  # ALPHA_SMS
      GSI                  =   1850  # GSI
      CTCD                 =   1851  # ctcd
      VIRTUAL_TIME         =   1852  # Virtual Time
      VIDS_AVTP            =   1853  # VIDS_AVTP
      BUDDY_DRAW           =   1854  # Buddy Draw
      FIORANO_RTRSVC       =   1855  # Fiorano RtrSvc
      FIORANO_MSGSVC       =   1856  # Fiorano MsgSvc
      DATACAPTOR           =   1857  # DataCaptor
      PRIVATEARK           =   1858  # PrivateArk
      GAMMAFETCHSVR        =   1859  # Gamma Fetcher Server
      SUNSCALAR_SVC        =   1860  # SunSCALAR Services
      LECROY_VICP          =   1861  # LeCroy VICP
      MYSQL_CM_AGENT       =   1862  # MySQL Cluster Manager Agent
      MSNP                 =   1863  # MSNP
#      PARADYM_31PORT       =   1864  # Paradym 31 Port
      ENTP                 =   1865  # ENTP
      SWRMI                =   1866  # swrmi
      UDRIVE               =   1867  # UDRIVE
      VIZIBLEBROWSER       =   1868  # VizibleBrowser
      TRANSACT             =   1869  # TransAct
      SUNSCALAR_DNS        =   1870  # SunSCALAR DNS Service
      CANOCENTRAL0         =   1871  # Cano Central 0
      CANOCENTRAL1         =   1872  # Cano Central 1
      FJMPJPS              =   1873  # Fjmpjps
      FJSWAPSNP            =   1874  # Fjswapsnp
      WESTELL_STATS        =   1875  # westell stats
      EWCAPPSRV            =   1876  # ewcappsrv
      HP_WEBQOSDB          =   1877  # hp_webqosdb
      DRMSMC               =   1878  # drmsmc
      NETTGAIN_NMS         =   1879  # NettGain NMS
      VSAT_CONTROL         =   1880  # Gilat VSAT Control
      IBM_MQSERIES2        =   1881  # IBM WebSphere MQ Everyplace
      ECSQDMN              =   1882  # CA eTrust Common Services
      IBM_MQISDP           =   1883  # IBM MQSeries SCADA
      IDMAPS               =   1884  # Internet Distance Map Svc
      VRTSTRAPSERVER       =   1885  # Veritas Trap Server
      LEOIP                =   1886  # Leonardo over IP
      FILEX_LPORT          =   1887  # FileX Listening Port
      NCCONFIG             =   1888  # NC Config Port
      UNIFY_ADAPTER        =   1889  # Unify Web Adapter Service
      WILKENLISTENER       =   1890  # wilkenListener
      CHILDKEY_NOTIF       =   1891  # ChildKey Notification
      CHILDKEY_CTRL        =   1892  # ChildKey Control
      ELAD                 =   1893  # ELAD Protocol
      O2SERVER_PORT        =   1894  # O2Server Port
      B_NOVATIVE_LS        =   1896  # b_novative license server
      METAAGENT            =   1897  # MetaAgent
      CYMTEC_PORT          =   1898  # Cymtec secure management
      MC2STUDIOS           =   1899  # MC2Studios
      SSDP                 =   1900  # SSDP
      FJICL_TEP_A          =   1901  # Fujitsu ICL Terminal Emulator Program A
      FJICL_TEP_B          =   1902  # Fujitsu ICL Terminal Emulator Program B
      LINKNAME             =   1903  # Local Link Name Resolution
      FJICL_TEP_C          =   1904  # Fujitsu ICL Terminal Emulator Program C
      SUGP                 =   1905  # Secure UP.Link Gateway Protocol
      TPMD                 =   1906  # TPortMapperReq
      INTRASTAR            =   1907  # IntraSTAR
      DAWN                 =   1908  # Dawn
      GLOBAL_WLINK         =   1909  # Global World Link
      ULTRABAC             =   1910  # UltraBac Software communications port
      MTP                  =   1911  # Starlight Networks Multimedia Transport Protocol
      RHP_IIBP             =   1912  # rhp_iibp
      ARMADP               =   1913  # armadp
      ELM_MOMENTUM         =   1914  # Elm_Momentum
      FACELINK             =   1915  # FACELINK
      PERSONA              =   1916  # Persoft Persona
      NOAGENT              =   1917  # nOAgent
      CAN_NDS              =   1918  # IBM Tivole Directory Service _ NDS
      CAN_DCH              =   1919  # IBM Tivoli Directory Service _ DCH
      CAN_FERRET           =   1920  # IBM Tivoli Directory Service _ FERRET
      NOADMIN              =   1921  # NoAdmin
      TAPESTRY             =   1922  # Tapestry
      SPICE                =   1923  # SPICE
      XIIP                 =   1924  # XIIP
      DISCOVERY_PORT       =   1925  # Surrogate Discovery Port
      EGS                  =   1926  # Evolution Game Server
      VIDETE_CIPC          =   1927  # Videte CIPC Port
      EMSD_PORT            =   1928  # Expnd Maui Srvr Dscovr
      BANDWIZ_SYSTEM       =   1929  # Bandwiz System _ Server
      DRIVEAPPSERVER       =   1930  # Drive AppServer
      AMDSCHED             =   1931  # AMD SCHED
      CTT_BROKER           =   1932  # CTT Broker
      XMAPI                =   1933  # IBM LM MT Agent
      XAAPI                =   1934  # IBM LM Appl Agent
      MACROMEDIA_FCS       =   1935  # Macromedia Flash Communications Server MX
      JETCMESERVER         =   1936  # JetCmeServer Server Port
      JWSERVER             =   1937  # JetVWay Server Port
      JWCLIENT             =   1938  # JetVWay Client Port
      JVSERVER             =   1939  # JetVision Server Port
      JVCLIENT             =   1940  # JetVision Client Port
      DIC_AIDA             =   1941  # DIC_Aida
      RES                  =   1942  # Real Enterprise Service
      BEEYOND_MEDIA        =   1943  # Beeyond Media
      CLOSE_COMBAT         =   1944  # close_combat
      DIALOGIC_ELMD        =   1945  # dialogic_elmd
      TEKPLS               =   1946  # tekpls
      SENTINELSRM          =   1947  # SentinelSRM
      EYE2EYE              =   1948  # eye2eye
      ISMAEASDAQLIVE       =   1949  # ISMA Easdaq Live
      ISMAEASDAQTEST       =   1950  # ISMA Easdaq Test
      BCS_LMSERVER         =   1951  # bcs_lmserver
      MPNJSC               =   1952  # mpnjsc
      RAPIDBASE            =   1953  # Rapid Base
      ABR_API              =   1954  # ABR_API (diskbridge)
      ABR_SECURE           =   1955  # ABR_Secure Data (diskbridge)
      VRTL_VMF_DS          =   1956  # Vertel VMF DS
      UNIX_STATUS          =   1957  # unix_status
      DXADMIND             =   1958  # CA Administration Daemon
      SIMP_ALL             =   1959  # SIMP Channel
      NASMANAGER           =   1960  # Merit DAC NASmanager
      BTS_APPSERVER        =   1961  # BTS APPSERVER
      BIAP_MP              =   1962  # BIAP_MP
      WEBMACHINE           =   1963  # WebMachine
      SOLID_E_ENGINE       =   1964  # SOLID E ENGINE
      TIVOLI_NPM           =   1965  # Tivoli NPM
      SLUSH                =   1966  # Slush
      SNS_QUOTE            =   1967  # SNS Quote
      LIPSINC              =   1968  # LIPSinc
      LIPSINC1             =   1969  # LIPSinc 1
      NETOP_RC             =   1970  # NetOp Remote Control
      NETOP_SCHOOL         =   1971  # NetOp School
      INTERSYS_CACHE       =   1972  # Cache
      DLSRAP               =   1973  # Data Link Switching Remote Access Protocol
      DRP                  =   1974  # DRP
      TCOFLASHAGENT        =   1975  # TCO Flash Agent
      TCOREGAGENT          =   1976  # TCO Reg Agent
      TCOADDRESSBOOK       =   1977  # TCO Address Book
      UNISQL               =   1978  # UniSQL
      UNISQL_JAVA          =   1979  # UniSQL Java
      PEARLDOC_XACT        =   1980  # PearlDoc XACT
      P2PQ                 =   1981  # p2pQ
      ESTAMP               =   1982  # Evidentiary Timestamp
      LHTP                 =   1983  # Loophole Test Protocol
      BB                   =   1984  # BB
      HSRP                 =   1985  # Hot Standby Router Protocol
      LICENSEDAEMON        =   1986  # cisco license management
      TR_RSRB_P1           =   1987  # cisco RSRB Priority 1 port
      TR_RSRB_P2           =   1988  # cisco RSRB Priority 2 port
      TR_RSRB_P3           =   1989  # cisco RSRB Priority 3 port
      MSHNET               =   1989  # MHSnet system
      STUN_P1              =   1990  # cisco STUN Priority 1 port
      STUN_P2              =   1991  # cisco STUN Priority 2 port
      STUN_P3              =   1992  # cisco STUN Priority 3 port
      IPSENDMSG            =   1992  # IPsendmsg
      SNMP_TCP_PORT        =   1993  # cisco SNMP TCP port
      STUN_PORT            =   1994  # cisco serial tunnel port
      PERF_PORT            =   1995  # cisco perf port
      TR_RSRB_PORT         =   1996  # cisco Remote SRB port
      GDP_PORT             =   1997  # cisco Gateway Discovery Protocol
      X25_SVC_PORT         =   1998  # cisco X.25 service (XOT)
      TCP_ID_PORT          =   1999  # cisco identification port
      CISCO_SCCP           =   2000  # Cisco SCCP
      DC                   =   2001  # 
      GLOBE                =   2002  # 
      BRUTUS               =   2003  # Brutus Server
      MAILBOX              =   2004  # 
      BERKNET              =   2005  # 
      INVOKATOR            =   2006  # 
      DECTALK              =   2007  # 
      CONF                 =   2008  # 
      NEWS                 =   2009  # 
      SEARCH               =   2010  # 
      RAID_CC              =   2011  # raid
      TTYINFO              =   2012  # 
      RAID_AM              =   2013  # 
      TROFF                =   2014  # 
      CYPRESS              =   2015  # 
      BOOTSERVER           =   2016  # 
      CYPRESS_STAT         =   2017  # 
      TERMINALDB           =   2018  # 
      WHOSOCKAMI           =   2019  # 
      XINUPAGESERVER       =   2020  # 
      SERVEXEC             =   2021  # 
      DOWN                 =   2022  # 
      XINUEXPANSION3       =   2023  # 
      XINUEXPANSION4       =   2024  # 
      ELLPACK              =   2025  # 
      SCRABBLE             =   2026  # 
      SHADOWSERVER         =   2027  # 
      SUBMITSERVER         =   2028  # 
      HSRPV6               =   2029  # Hot Standby Router Protocol IPv6
      DEVICE2              =   2030  # 
      MOBRIEN_CHAT         =   2031  # mobrien_chat
      BLACKBOARD           =   2032  # 
      GLOGGER              =   2033  # 
      SCOREMGR             =   2034  # 
      IMSLDOC              =   2035  # 
      E_DPNET              =   2036  # Ethernet WS DP network
      APPLUS               =   2037  # APplus Application Server
      OBJECTMANAGER        =   2038  # 
      PRIZMA               =   2039  # Prizma Monitoring Service
      LAM                  =   2040  # 
      INTERBASE            =   2041  # 
      ISIS                 =   2042  # isis
      ISIS_BCAST           =   2043  # isis_bcast
      RIMSL                =   2044  # 
      CDFUNC               =   2045  # 
      SDFUNC               =   2046  # 
      DLS                  =   2047  # 
      DLS_MONITOR          =   2048  # 
      NFS                  =   2049  # Network File System _ Sun Microsystems
      AV_EMB_CONFIG        =   2050  # Avaya EMB Config Port
      EPNSDP               =   2051  # EPNSDP
      CLEARVISN            =   2052  # clearVisn Services Port
      LOT105_DS_UPD        =   2053  # Lot105 DSuper Updates
      WEBLOGIN             =   2054  # Weblogin Port
      IOP                  =   2055  # Iliad_Odyssey Protocol
      OMNISKY              =   2056  # OmniSky Port
      RICH_CP              =   2057  # Rich Content Protocol
      NEWWAVESEARCH        =   2058  # NewWaveSearchables RMI
      BMC_MESSAGING        =   2059  # BMC Messaging Service
      TELENIUMDAEMON       =   2060  # Telenium Daemon IF
      NETMOUNT             =   2061  # NetMount
      ICG_SWP              =   2062  # ICG SWP Port
      ICG_BRIDGE           =   2063  # ICG Bridge Port
      ICG_IPRELAY          =   2064  # ICG IP Relay Port
      DLSRPN               =   2065  # Data Link Switch Read Port Number
      AURA                 =   2066  # AVM USB Remote Architecture
      DLSWPN               =   2067  # Data Link Switch Write Port Number
      AVAUTHSRVPRTCL       =   2068  # Avocent AuthSrv Protocol
      EVENT_PORT           =   2069  # HTTP Event Port
      AH_ESP_ENCAP         =   2070  # AH and ESP Encapsulated in UDP packet
      ACP_PORT             =   2071  # Axon Control Protocol
      MSYNC                =   2072  # GlobeCast mSync
      GXS_DATA_PORT        =   2073  # DataReel Database Socket
      VRTL_VMF_SA          =   2074  # Vertel VMF SA
      NEWLIXENGINE         =   2075  # Newlix ServerWare Engine
      NEWLIXCONFIG         =   2076  # Newlix JSPConfig
      TSRMAGT              =   2077  # Old Tivoli Storage Manager
      TPCSRVR              =   2078  # IBM Total Productivity Center Server
      IDWARE_ROUTER        =   2079  # IDWARE Router Port
      AUTODESK_NLM         =   2080  # Autodesk NLM (FLEXlm)
      KME_TRAP_PORT        =   2081  # KME PRINTER TRAP PORT
      INFOWAVE             =   2082  # Infowave Mobility Server
      RADSEC               =   2083  # Secure Radius Service
      SUNCLUSTERGEO        =   2084  # SunCluster Geographic
      ADA_CIP              =   2085  # ADA Control
      GNUNET               =   2086  # GNUnet
      ELI                  =   2087  # ELI _ Event Logging Integration
      IP_BLF               =   2088  # IP Busy Lamp Field
      SEP                  =   2089  # Security Encapsulation Protocol _ SEP
      LRP                  =   2090  # Load Report Protocol
      PRP                  =   2091  # PRP
      DESCENT3             =   2092  # Descent 3
      NBX_CC               =   2093  # NBX CC
      NBX_AU               =   2094  # NBX AU
      NBX_SER              =   2095  # NBX SER
      NBX_DIR              =   2096  # NBX DIR
      JETFORMPREVIEW       =   2097  # Jet Form Preview
      DIALOG_PORT          =   2098  # Dialog Port
      H2250_ANNEX_G        =   2099  # H.225.0 Annex G Signalling
      AMIGANETFS           =   2100  # Amiga Network Filesystem
      RTCM_SC104           =   2101  # rtcm_sc104
      ZEPHYR_SRV           =   2102  # Zephyr server
      ZEPHYR_CLT           =   2103  # Zephyr serv_hm connection
      ZEPHYR_HM            =   2104  # Zephyr hostmanager
      MINIPAY              =   2105  # MiniPay
      MZAP                 =   2106  # MZAP
      BINTEC_ADMIN         =   2107  # BinTec Admin
      COMCAM               =   2108  # Comcam
      ERGOLIGHT            =   2109  # Ergolight
      UMSP                 =   2110  # UMSP
      DSATP                =   2111  # OPNET Dynamic Sampling Agent Transaction Protocol
      IDONIX_METANET       =   2112  # Idonix MetaNet
      HSL_STORM            =   2113  # HSL StoRM
      NEWHEIGHTS           =   2114  # NEWHEIGHTS
      KDM                  =   2115  # Key Distribution Manager
      CCOWCMR              =   2116  # CCOWCMR
      MENTACLIENT          =   2117  # MENTACLIENT
      MENTASERVER          =   2118  # MENTASERVER
      GSIGATEKEEPER        =   2119  # GSIGATEKEEPER
      QENCP                =   2120  # Quick Eagle Networks CP
      SCIENTIA_SSDB        =   2121  # SCIENTIA_SSDB
      CAUPC_REMOTE         =   2122  # CauPC Remote Control
      GTP_CONTROL          =   2123  # GTP_Control Plane (3GPP)
      ELATELINK            =   2124  # ELATELINK
      LOCKSTEP             =   2125  # LOCKSTEP
      PKTCABLE_COPS        =   2126  # PktCable_COPS
      INDEX_PC_WB          =   2127  # INDEX_PC_WB
      NET_STEWARD          =   2128  # Net Steward Control
      CS_LIVE              =   2129  # cs_live.com
      XDS                  =   2130  # XDS
      AVANTAGEB2B          =   2131  # Avantageb2b
      SOLERA_EPMAP         =   2132  # SoleraTec End Point Map
      ZYMED_ZPP            =   2133  # ZYMED_ZPP
      AVENUE               =   2134  # AVENUE
      GRIS                 =   2135  # Grid Resource Information Server
      APPWORXSRV           =   2136  # APPWORXSRV
      CONNECT              =   2137  # CONNECT
      UNBIND_CLUSTER       =   2138  # UNBIND_CLUSTER
      IAS_AUTH             =   2139  # IAS_AUTH
      IAS_REG              =   2140  # IAS_REG
      IAS_ADMIND           =   2141  # IAS_ADMIND
      TDMOIP               =   2142  # TDM OVER IP
      LV_JC                =   2143  # Live Vault Job Control
      LV_FFX               =   2144  # Live Vault Fast Object Transfer
      LV_PICI              =   2145  # Live Vault Remote Diagnostic Console Support
      LV_NOT               =   2146  # Live Vault Admin Event Notification
      LV_AUTH              =   2147  # Live Vault Authentication
      VERITAS_UCL          =   2148  # VERITAS UNIVERSAL COMMUNICATION LAYER
      ACPTSYS              =   2149  # ACPTSYS
      DYNAMIC3D            =   2150  # DYNAMIC3D
      DOCENT               =   2151  # DOCENT
      GTP_USER             =   2152  # GTP_User Plane (3GPP)
      CTLPTC               =   2153  # Control Protocol
      STDPTC               =   2154  # Standard Protocol
      BRDPTC               =   2155  # Bridge Protocol
      TRP                  =   2156  # Talari Reliable Protocol
      XNDS                 =   2157  # Xerox Network Document Scan Protocol
      TOUCHNETPLUS         =   2158  # TouchNetPlus Service
      GDBREMOTE            =   2159  # GDB Remote Debug Port
      APC_2160             =   2160  # APC 2160
      APC_2161             =   2161  # APC 2161
      NAVISPHERE           =   2162  # Navisphere
      NAVISPHERE_SEC       =   2163  # Navisphere Secure
      DDNS_V3              =   2164  # Dynamic DNS Version 3
      X_BONE_API           =   2165  # X_Bone API
      IWSERVER             =   2166  # iwserver
      RAW_SERIAL           =   2167  # Raw Async Serial Link
      EASY_SOFT_MUX        =   2168  # easy_soft Multiplexer
      BRAIN                =   2169  # Backbone for Academic Information Notification (BRAIN)
      EYETV                =   2170  # EyeTV Server Port
      MSFW_STORAGE         =   2171  # MS Firewall Storage
      MSFW_S_STORAGE       =   2172  # MS Firewall SecureStorage
      MSFW_REPLICA         =   2173  # MS Firewall Replication
      MSFW_ARRAY           =   2174  # MS Firewall Intra Array
      AIRSYNC              =   2175  # Microsoft Desktop AirSync Protocol
      RAPI                 =   2176  # Microsoft ActiveSync Remote API
      QWAVE                =   2177  # qWAVE Bandwidth Estimate
      BITSPEER             =   2178  # Peer Services for BITS
      VMRDP                =   2179  # Microsoft RDP for virtual machines
      MC_GT_SRV            =   2180  # Millicent Vendor Gateway Server
      EFORWARD             =   2181  # eforward
      CGN_STAT             =   2182  # CGN status
      CGN_CONFIG           =   2183  # Code Green configuration
      NVD                  =   2184  # NVD User
      ONBASE_DDS           =   2185  # OnBase Distributed Disk Services
      GTAUA                =   2186  # Guy_Tek Automated Update Applications
      SSMC                 =   2187  # Sepehr System Management Control
      RADWARE_RPM          =   2188  # Radware Resource Pool Manager
      RADWARE_RPM_S        =   2189  # Secure Radware Resource Pool Manager
      TIVOCONNECT          =   2190  # TiVoConnect Beacon
      TVBUS                =   2191  # TvBus Messaging
      ASDIS                =   2192  # ASDIS software management
      DRWCS                =   2193  # Dr.Web Enterprise Management Service
      MNP_EXCHANGE         =   2197  # MNP data exchange
      ONEHOME_REMOTE       =   2198  # OneHome Remote Access
      ONEHOME_HELP         =   2199  # OneHome Service Port
      ICI                  =   2200  # ICI
      ATS                  =   2201  # Advanced Training System Program
      IMTC_MAP             =   2202  # Int. Multimedia Teleconferencing Cosortium
      B2_RUNTIME           =   2203  # b2 Runtime Protocol
      B2_LICENSE           =   2204  # b2 License Server
      JPS                  =   2205  # Java Presentation Server
      HPOCBUS              =   2206  # HP OpenCall bus
      HPSSD                =   2207  # HP Status and Services
      HPIOD                =   2208  # HP I_O Backend
      RIMF_PS              =   2209  # HP RIM for Files Portal Service
      NOAAPORT             =   2210  # NOAAPORT Broadcast Network
      EMWIN                =   2211  # EMWIN
      LEECOPOSSERVER       =   2212  # LeeCO POS Server Service
      KALI                 =   2213  # Kali
      RPI                  =   2214  # RDQ Protocol Interface
      IPCORE               =   2215  # IPCore.co.za GPRS
      VTU_COMMS            =   2216  # VTU data service
      GOTODEVICE           =   2217  # GoToDevice Device Management
      BOUNZZA              =   2218  # Bounzza IRC Proxy
      NETIQ_NCAP           =   2219  # NetIQ NCAP Protocol
      NETIQ                =   2220  # NetIQ End2End
      ROCKWELL_CSP1        =   2221  # Rockwell CSP1
      ETHERNET_IP_1        =   2222  # EtherNet_IP I_OIANA assigned this well_formed service name as a replacement for "EtherNet_IP_1".
      ETHERNET_IP_1        =   2222  # EtherNet_IP I_O
      ROCKWELL_CSP2        =   2223  # Rockwell CSP2
      EFI_MG               =   2224  # Easy Flexible Internet_Multiplayer Games
      RCIP_ITU             =   2225  # Resource Connection Initiation Protocol
      DI_DRM               =   2226  # Digital Instinct DRM
      DI_MSG               =   2227  # DI Messaging Service
      EHOME_MS             =   2228  # eHome Message Server
      DATALENS             =   2229  # DataLens Service
      QUEUEADM             =   2230  # MetaSoft Job Queue Administration Service
      WIMAXASNCP           =   2231  # WiMAX ASN Control Plane Protocol
      IVS_VIDEO            =   2232  # IVS Video default
      INFOCRYPT            =   2233  # INFOCRYPT
      DIRECTPLAY           =   2234  # DirectPlay
      SERCOMM_WLINK        =   2235  # Sercomm_WLink
      NANI                 =   2236  # Nani
      OPTECH_PORT1_LM      =   2237  # Optech Port1 License Manager
      AVIVA_SNA            =   2238  # AVIVA SNA SERVER
      IMAGEQUERY           =   2239  # Image Query
      RECIPE               =   2240  # RECIPe
      IVSD                 =   2241  # IVS Daemon
      FOLIOCORP            =   2242  # Folio Remote Server
      MAGICOM              =   2243  # Magicom Protocol
      NMSSERVER            =   2244  # NMS Server
      HAO                  =   2245  # HaO
      PC_MTA_ADDRMAP       =   2246  # PacketCable MTA Addr Map
      ANTIDOTEMGRSVR       =   2247  # Antidote Deployment Manager Service
      UMS                  =   2248  # User Management Service
      RFMP                 =   2249  # RISO File Manager Protocol
      REMOTE_COLLAB        =   2250  # remote_collab
      DIF_PORT             =   2251  # Distributed Framework Port
      NJENET_SSL           =   2252  # NJENET using SSL
      DTV_CHAN_REQ         =   2253  # DTV Channel Request
      SEISPOC              =   2254  # Seismic P.O.C. Port
      VRTP                 =   2255  # VRTP _ ViRtue Transfer Protocol
      PCC_MFP              =   2256  # PCC MFP
      SIMPLE_TX_RX         =   2257  # simple text_file transfer
      RCTS                 =   2258  # Rotorcraft Communications Test System
      APC_2260             =   2260  # APC 2260
      COMOTIONMASTER       =   2261  # CoMotion Master Server
      COMOTIONBACK         =   2262  # CoMotion Backup Server
      ECWCFG               =   2263  # ECweb Configuration Service
      APX500API_1          =   2264  # Audio Precision Apx500 API Port 1
      APX500API_2          =   2265  # Audio Precision Apx500 API Port 2
      MFSERVER             =   2266  # M_Files Server
      ONTOBROKER           =   2267  # OntoBroker
      AMT                  =   2268  # AMT
      MIKEY                =   2269  # MIKEY
      STARSCHOOL           =   2270  # starSchool
      MMCALS               =   2271  # Secure Meeting Maker Scheduling
      MMCAL                =   2272  # Meeting Maker Scheduling
      MYSQL_IM             =   2273  # MySQL Instance Manager
      PCTTUNNELL           =   2274  # PCTTunneller
      IBRIDGE_DATA         =   2275  # iBridge Conferencing
      IBRIDGE_MGMT         =   2276  # iBridge Management
      BLUECTRLPROXY        =   2277  # Bt device control proxy
      S3DB                 =   2278  # Simple Stacked Sequences Database
      XMQUERY              =   2279  # xmquery
      LNVPOLLER            =   2280  # LNVPOLLER
      LNVCONSOLE           =   2281  # LNVCONSOLE
      LNVALARM             =   2282  # LNVALARM
      LNVSTATUS            =   2283  # LNVSTATUS
      LNVMAPS              =   2284  # LNVMAPS
      LNVMAILMON           =   2285  # LNVMAILMON
      NAS_METERING         =   2286  # NAS_Metering
      DNA                  =   2287  # DNA
      NETML                =   2288  # NETML
      DICT_LOOKUP          =   2289  # Lookup dict server
      SONUS_LOGGING        =   2290  # Sonus Logging Services
      EAPSP                =   2291  # EPSON Advanced Printer Share Protocol
      MIB_STREAMING        =   2292  # Sonus Element Management Services
      NPDBGMNGR            =   2293  # Network Platform Debug Manager
      KONSHUS_LM           =   2294  # Konshus License Manager (FLEX)
      ADVANT_LM            =   2295  # Advant License Manager
      THETA_LM             =   2296  # Theta License Manager (Rainbow)
      D2K_DATAMOVER1       =   2297  # D2K DataMover 1
      D2K_DATAMOVER2       =   2298  # D2K DataMover 2
      PC_TELECOMMUTE       =   2299  # PC Telecommute
      CVMMON               =   2300  # CVMMON
      CPQ_WBEM             =   2301  # Compaq HTTP
      BINDERYSUPPORT       =   2302  # Bindery Support
      PROXY_GATEWAY        =   2303  # Proxy Gateway
      ATTACHMATE_UTS       =   2304  # Attachmate UTS
      MT_SCALESERVER       =   2305  # MT ScaleServer
      TAPPI_BOXNET         =   2306  # TAPPI BoxNet
      PEHELP               =   2307  # pehelp
      SDHELP               =   2308  # sdhelp
      SDSERVER             =   2309  # SD Server
      SDCLIENT             =   2310  # SD Client
      MESSAGESERVICE       =   2311  # Message Service
      WANSCALER            =   2312  # WANScaler Communication Service
      IAPP                 =   2313  # IAPP (Inter Access Point Protocol)
      CR_WEBSYSTEMS        =   2314  # CR WebSystems
      PRECISE_SFT          =   2315  # Precise Sft.
      SENT_LM              =   2316  # SENT License Manager
      ATTACHMATE_G32       =   2317  # Attachmate G32
      CADENCECONTROL       =   2318  # Cadence Control
      INFOLIBRIA           =   2319  # InfoLibria
      SIEBEL_NS            =   2320  # Siebel NS
      RDLAP                =   2321  # RDLAP
      OFSD                 =   2322  # ofsd
#      3D_NFSD              =   2323  # 3d_nfsd
      COSMOCALL            =   2324  # Cosmocall
      ANSYSLI              =   2325  # ANSYS Licensing Interconnect
      IDCP                 =   2326  # IDCP
      XINGCSM              =   2327  # xingcsm
      NETRIX_SFTM          =   2328  # Netrix SFTM
      NVD                  =   2329  # NVD
      TSCCHAT              =   2330  # TSCCHAT
      AGENTVIEW            =   2331  # AGENTVIEW
      RCC_HOST             =   2332  # RCC Host
      SNAPP                =   2333  # SNAPP
      ACE_CLIENT           =   2334  # ACE Client Auth
      ACE_PROXY            =   2335  # ACE Proxy
      APPLEUGCONTROL       =   2336  # Apple UG Control
      IDEESRV              =   2337  # ideesrv
      NORTON_LAMBERT       =   2338  # Norton Lambert
#      3COM_WEBVIEW         =   2339  # 3Com WebView
      WRS_REGISTRY         =   2340  # WRS RegistryIANA assigned this well_formed service name as a replacement for "wrs_registry".
      WRS_REGISTRY         =   2340  # WRS Registry
      XIOSTATUS            =   2341  # XIO Status
      MANAGE_EXEC          =   2342  # Seagate Manage Exec
      NATI_LOGOS           =   2343  # nati logos
      FCMSYS               =   2344  # fcmsys
      DBM                  =   2345  # dbm
      REDSTORM_JOIN        =   2346  # Game Connection PortIANA assigned this well_formed service name as a replacement for "redstorm_join".
      REDSTORM_JOIN        =   2346  # Game Connection Port This entry is an alias to "redstorm_join".This entry is now historic, not usable for use with manycommon service discovery mechanisms.
      REDSTORM_FIND        =   2347  # Game Announcement and LocationIANA assigned this well_formed service name as a replacement for "redstorm_find".
      REDSTORM_FIND        =   2347  # Game Announcement and Location This entry is an alias to "redstorm_find".This entry is now historic, not usable for use with manycommon service discovery mechanisms.
      REDSTORM_INFO        =   2348  # Information to query for game statusIANA assigned this well_formed service name as a replacement for "redstorm_info".
      REDSTORM_INFO        =   2348  # Information to query for game status This entry is an alias to "redstorm_info".This entry is now historic, not usable for use with manycommon service discovery mechanisms.
      REDSTORM_DIAG        =   2349  # Diagnostics PortIANA assigned this well_formed service name as a replacement for "redstorm_diag".
      REDSTORM_DIAG        =   2349  # Diagnostics Port
      PSBSERVER            =   2350  # Pharos Booking Server
      PSRSERVER            =   2351  # psrserver
      PSLSERVER            =   2352  # pslserver
      PSPSERVER            =   2353  # pspserver
      PSPRSERVER           =   2354  # psprserver
      PSDBSERVER           =   2355  # psdbserver
      GXTELMD              =   2356  # GXT License Managemant
      UNIHUB_SERVER        =   2357  # UniHub Server
      FUTRIX               =   2358  # Futrix
      FLUKESERVER          =   2359  # FlukeServer
      NEXSTORINDLTD        =   2360  # NexstorIndLtd
      TL1                  =   2361  # TL1
      DIGIMAN              =   2362  # digiman
      MEDIACNTRLNFSD       =   2363  # Media Central NFSD
      OI_2000              =   2364  # OI_2000
      DBREF                =   2365  # dbref
      QIP_LOGIN            =   2366  # qip_login
      SERVICE_CTRL         =   2367  # Service Control
      OPENTABLE            =   2368  # OpenTable
      L3_HBMON             =   2370  # L3_HBMon
      HP_RDA               =   2371  # HP Remote Device Access
      LANMESSENGER         =   2372  # LanMessenger
      REMOGRAPHLM          =   2373  # Remograph License Manager
      HYDRA                =   2374  # Hydra RPC
      DOCKER               =   2375  # Docker REST API (plain text)
      DOCKER_S             =   2376  # Docker REST API (ssl)
      ETCD_CLIENT          =   2379  # etcd client communication
      ETCD_SERVER          =   2380  # etcd server to server communication
      COMPAQ_HTTPS         =   2381  # Compaq HTTPS
      MS_OLAP3             =   2382  # Microsoft OLAP
      MS_OLAP4             =   2383  # Microsoft OLAP
      SD_REQUEST           =   2384  # SD_REQUEST
      SD_DATA              =   2385  # SD_DATA
      VIRTUALTAPE          =   2386  # Virtual Tape
      VSAMREDIRECTOR       =   2387  # VSAM Redirector
      MYNAHAUTOSTART       =   2388  # MYNAH AutoStart
      OVSESSIONMGR         =   2389  # OpenView Session Mgr
      RSMTP                =   2390  # RSMTP
#      3COM_NET_MGMT        =   2391  # 3COM Net Management
      TACTICALAUTH         =   2392  # Tactical Auth
      MS_OLAP1             =   2393  # MS OLAP 1
      MS_OLAP2             =   2394  # MS OLAP 2
      LAN900_REMOTE        =   2395  # LAN900 RemoteIANA assigned this well_formed service name as a replacement for "lan900_remote".
      LAN900_REMOTE        =   2395  # LAN900 Remote
      WUSAGE               =   2396  # Wusage
      NCL                  =   2397  # NCL
      ORBITER              =   2398  # Orbiter
      FMPRO_FDAL           =   2399  # FileMaker, Inc. _ Data Access Layer
      OPEQUUS_SERVER       =   2400  # OpEquus Server
      CVSPSERVER           =   2401  # cvspserver
      TASKMASTER2000       =   2402  # TaskMaster 2000 Server
      TASKMASTER2000       =   2403  # TaskMaster 2000 Web
      IEC_104              =   2404  # IEC 60870_5_104 process control over IP
      TRC_NETPOLL          =   2405  # TRC Netpoll
      JEDISERVER           =   2406  # JediServer
      ORION                =   2407  # Orion
      RAILGUN_WEBACCL      =   2408  # CloudFlare Railgun Web Acceleration Protocol
      SNS_PROTOCOL         =   2409  # SNS Protocol
      VRTS_REGISTRY        =   2410  # VRTS Registry
      NETWAVE_AP_MGMT      =   2411  # Netwave AP Management
      CDN                  =   2412  # CDN
      ORION_RMI_REG        =   2413  # orion_rmi_reg
      BEEYOND              =   2414  # Beeyond
      CODIMA_RTP           =   2415  # Codima Remote Transaction Protocol
      RMTSERVER            =   2416  # RMT Server
      COMPOSIT_SERVER      =   2417  # Composit Server
      CAS                  =   2418  # cas
      ATTACHMATE_S2S       =   2419  # Attachmate S2S
      DSLREMOTE_MGMT       =   2420  # DSL Remote Management
      G_TALK               =   2421  # G_Talk
      CRMSBITS             =   2422  # CRMSBITS
      RNRP                 =   2423  # RNRP
      KOFAX_SVR            =   2424  # KOFAX_SVR
      FJITSUAPPMGR         =   2425  # Fujitsu App Manager
      MGCP_GATEWAY         =   2427  # Media Gateway Control Protocol Gateway
      OTT                  =   2428  # One Way Trip Time
      FT_ROLE              =   2429  # FT_ROLE
      VENUS                =   2430  # venus
      VENUS_SE             =   2431  # venus_se
      CODASRV              =   2432  # codasrv
      CODASRV_SE           =   2433  # codasrv_se
      PXC_EPMAP            =   2434  # pxc_epmap
      OPTILOGIC            =   2435  # OptiLogic
      TOPX                 =   2436  # TOP_X
      UNICONTROL           =   2437  # UniControl
      MSP                  =   2438  # MSP
      SYBASEDBSYNCH        =   2439  # SybaseDBSynch
      SPEARWAY             =   2440  # Spearway Lockers
      PVSW_INET            =   2441  # Pervasive I_net Data Server
      NETANGEL             =   2442  # Netangel
      POWERCLIENTCSF       =   2443  # PowerClient Central Storage Facility
      BTPP2SECTRANS        =   2444  # BT PP2 Sectrans
      DTN1                 =   2445  # DTN1
      BUES_SERVICE         =   2446  # bues_serviceIANA assigned this well_formed service name as a replacement for "bues_service".
      BUES_SERVICE         =   2446  # bues_service
      OVWDB                =   2447  # OpenView NNM daemon
      HPPPSSVR             =   2448  # hpppsvr
      RATL                 =   2449  # RATL
      NETADMIN             =   2450  # netadmin
      NETCHAT              =   2451  # netchat
      SNIFFERCLIENT        =   2452  # SnifferClient
      MADGE_LTD            =   2453  # madge ltd
      INDX_DDS             =   2454  # IndX_DDS
      WAGO_IO_SYSTEM       =   2455  # WAGO_IO_SYSTEM
      ALTAV_REMMGT         =   2456  # altav_remmgt
      RAPIDO_IP            =   2457  # Rapido_IP
      GRIFFIN              =   2458  # griffin
      COMMUNITY            =   2459  # Community
      MS_THEATER           =   2460  # ms_theater
      QADMIFOPER           =   2461  # qadmifoper
      QADMIFEVENT          =   2462  # qadmifevent
      LSI_RAID_MGMT        =   2463  # LSI RAID Management
      DIRECPC_SI           =   2464  # DirecPC SI
      LBM                  =   2465  # Load Balance Management
      LBF                  =   2466  # Load Balance Forwarding
      HIGH_CRITERIA        =   2467  # High Criteria
      QIP_MSGD             =   2468  # qip_msgd
      MTI_TCS_COMM         =   2469  # MTI_TCS_COMM
      TASKMAN_PORT         =   2470  # taskman port
      SEAODBC              =   2471  # SeaODBC
      C3                   =   2472  # C3
      AKER_CDP             =   2473  # Aker_cdp
      VITALANALYSIS        =   2474  # Vital Analysis
      ACE_SERVER           =   2475  # ACE Server
      ACE_SVR_PROP         =   2476  # ACE Server Propagation
      SSM_CVS              =   2477  # SecurSight Certificate Valifation Service
      SSM_CSSPS            =   2478  # SecurSight Authentication Server (SSL)
      SSM_ELS              =   2479  # SecurSight Event Logging Server (SSL)
      POWEREXCHANGE        =   2480  # Informatica PowerExchange Listener
      GIOP                 =   2481  # Oracle GIOP
      GIOP_SSL             =   2482  # Oracle GIOP SSL
      TTC                  =   2483  # Oracle TTC
      TTC_SSL              =   2484  # Oracle TTC SSL
      NETOBJECTS1          =   2485  # Net Objects1
      NETOBJECTS2          =   2486  # Net Objects2
      PNS                  =   2487  # Policy Notice Service
      MOY_CORP             =   2488  # Moy Corporation
      TSILB                =   2489  # TSILB
      QIP_QDHCP            =   2490  # qip_qdhcp
      CONCLAVE_CPP         =   2491  # Conclave CPP
      GROOVE               =   2492  # GROOVE
      TALARIAN_MQS         =   2493  # Talarian MQS
      BMC_AR               =   2494  # BMC AR
      FAST_REM_SERV        =   2495  # Fast Remote Services
      DIRGIS               =   2496  # DIRGIS
      QUADDB               =   2497  # Quad DB
      ODN_CASTRAQ          =   2498  # ODN_CasTraq
      UNICONTROL           =   2499  # UniControl
      RTSSERV              =   2500  # Resource Tracking system server
      RTSCLIENT            =   2501  # Resource Tracking system client
      KENTROX_PROT         =   2502  # Kentrox Protocol
      NMS_DPNSS            =   2503  # NMS_DPNSS
      WLBS                 =   2504  # WLBS
      PPCONTROL            =   2505  # PowerPlay Control
      JBROKER              =   2506  # jbroker
      SPOCK                =   2507  # spock
      JDATASTORE           =   2508  # JDataStore
      FJMPSS               =   2509  # fjmpss
      FJAPPMGRBULK         =   2510  # fjappmgrbulk
      METASTORM            =   2511  # Metastorm
      CITRIXIMA            =   2512  # Citrix IMA
      CITRIXADMIN          =   2513  # Citrix ADMIN
      FACSYS_NTP           =   2514  # Facsys NTP
      FACSYS_ROUTER        =   2515  # Facsys Router
      MAINCONTROL          =   2516  # Main Control
      CALL_SIG_TRANS       =   2517  # H.323 Annex E Call Control Signalling Transport
      WILLY                =   2518  # Willy
      GLOBMSGSVC           =   2519  # globmsgsvc
      PVSW                 =   2520  # Pervasive Listener
      ADAPTECMGR           =   2521  # Adaptec Manager
      WINDB                =   2522  # WinDb
      QKE_LLC_V3           =   2523  # Qke LLC V.3
      OPTIWAVE_LM          =   2524  # Optiwave License Management
      MS_V_WORLDS          =   2525  # MS V_Worlds
      EMA_SENT_LM          =   2526  # EMA License Manager
      IQSERVER             =   2527  # IQ Server
      NCR_CCL              =   2528  # NCR CCLIANA assigned this well_formed service name as a replacement for "ncr_ccl".
      NCR_CCL              =   2528  # NCR CCL
      UTSFTP               =   2529  # UTS FTP
      VRCOMMERCE           =   2530  # VR Commerce
      ITO_E_GUI            =   2531  # ITO_E GUI
      OVTOPMD              =   2532  # OVTOPMD
      SNIFFERSERVER        =   2533  # SnifferServer
      COMBOX_WEB_ACC       =   2534  # Combox Web Access
      MADCAP               =   2535  # MADCAP
      BTPP2AUDCTR1         =   2536  # btpp2audctr1
      UPGRADE              =   2537  # Upgrade Protocol
      VNWK_PRAPI           =   2538  # vnwk_prapi
      VSIADMIN             =   2539  # VSI Admin
      LONWORKS             =   2540  # LonWorks
      LONWORKS2            =   2541  # LonWorks2
      UDRAWGRAPH           =   2542  # uDraw(Graph)
      REFTEK               =   2543  # REFTEK
      NOVELL_ZEN           =   2544  # Management Daemon Refresh
      SIS_EMT              =   2545  # sis_emt
      VYTALVAULTBRTP       =   2546  # vytalvaultbrtp
      VYTALVAULTVSMP       =   2547  # vytalvaultvsmp
      VYTALVAULTPIPE       =   2548  # vytalvaultpipe
      IPASS                =   2549  # IPASS
      ADS                  =   2550  # ADS
      ISG_UDA_SERVER       =   2551  # ISG UDA Server
      CALL_LOGGING         =   2552  # Call Logging
      EFIDININGPORT        =   2553  # efidiningport
      VCNET_LINK_V10       =   2554  # VCnet_Link v10
      COMPAQ_WCP           =   2555  # Compaq WCP
      NICETEC_NMSVC        =   2556  # nicetec_nmsvc
      NICETEC_MGMT         =   2557  # nicetec_mgmt
      PCLEMULTIMEDIA       =   2558  # PCLE Multi Media
      LSTP                 =   2559  # LSTP
      LABRAT               =   2560  # labrat
      MOSAIXCC             =   2561  # MosaixCC
      DELIBO               =   2562  # Delibo
      CTI_REDWOOD          =   2563  # CTI Redwood
      HP_3000_TELNET       =   2564  # HP 3000 NS_VT block mode telnet
      COORD_SVR            =   2565  # Coordinator Server
      PCS_PCW              =   2566  # pcs_pcw
      CLP                  =   2567  # Cisco Line Protocol
      SPAMTRAP             =   2568  # SPAM TRAP
      SONUSCALLSIG         =   2569  # Sonus Call Signal
      HS_PORT              =   2570  # HS Port
      CECSVC               =   2571  # CECSVC
      IBP                  =   2572  # IBP
      TRUSTESTABLISH       =   2573  # Trust Establish
      BLOCKADE_BPSP        =   2574  # Blockade BPSP
      HL7                  =   2575  # HL7
      TCLPRODEBUGGER       =   2576  # TCL Pro Debugger
      SCIPTICSLSRVR        =   2577  # Scriptics Lsrvr
      RVS_ISDN_DCP         =   2578  # RVS ISDN DCP
      MPFONCL              =   2579  # mpfoncl
      TRIBUTARY            =   2580  # Tributary
      ARGIS_TE             =   2581  # ARGIS TE
      ARGIS_DS             =   2582  # ARGIS DS
      MON                  =   2583  # MON
      CYASERV              =   2584  # cyaserv
      NETX_SERVER          =   2585  # NETX Server
      NETX_AGENT           =   2586  # NETX Agent
      MASC                 =   2587  # MASC
      PRIVILEGE            =   2588  # Privilege
      QUARTUS_TCL          =   2589  # quartus tcl
      IDOTDIST             =   2590  # idotdist
      MAYTAGSHUFFLE        =   2591  # Maytag Shuffle
      NETREK               =   2592  # netrek
      MNS_MAIL             =   2593  # MNS Mail Notice Service
      DTS                  =   2594  # Data Base Server
      WORLDFUSION1         =   2595  # World Fusion 1
      WORLDFUSION2         =   2596  # World Fusion 2
      HOMESTEADGLORY       =   2597  # Homestead Glory
      CITRIXIMACLIENT      =   2598  # Citrix MA Client
      SNAPD                =   2599  # Snap Discovery
      HPSTGMGR             =   2600  # HPSTGMGR
      DISCP_CLIENT         =   2601  # discp client
      DISCP_SERVER         =   2602  # discp server
      SERVICEMETER         =   2603  # Service Meter
      NSC_CCS              =   2604  # NSC CCS
      NSC_POSA             =   2605  # NSC POSA
      NETMON               =   2606  # Dell Netmon
      CONNECTION           =   2607  # Dell Connection
      WAG_SERVICE          =   2608  # Wag Service
      SYSTEM_MONITOR       =   2609  # System Monitor
      VERSA_TEK            =   2610  # VersaTek
      LIONHEAD             =   2611  # LIONHEAD
      QPASA_AGENT          =   2612  # Qpasa Agent
      SMNTUBOOTSTRAP       =   2613  # SMNTUBootstrap
      NEVEROFFLINE         =   2614  # Never Offline
      FIREPOWER            =   2615  # firepower
      APPSWITCH_EMP        =   2616  # appswitch_emp
      CMADMIN              =   2617  # Clinical Context Managers
      PRIORITY_E_COM       =   2618  # Priority E_Com
      BRUCE                =   2619  # bruce
      LPSRECOMMENDER       =   2620  # LPSRecommender
      MILES_APART          =   2621  # Miles Apart Jukebox Server
      METRICADBC           =   2622  # MetricaDBC
      LMDP                 =   2623  # LMDP
      ARIA                 =   2624  # Aria
      BLWNKL_PORT          =   2625  # Blwnkl Port
      GBJD816              =   2626  # gbjd816
      MOSHEBEERI           =   2627  # Moshe Beeri
      DICT                 =   2628  # DICT
      SITARASERVER         =   2629  # Sitara Server
      SITARAMGMT           =   2630  # Sitara Management
      SITARADIR            =   2631  # Sitara Dir
      IRDG_POST            =   2632  # IRdg Post
      INTERINTELLI         =   2633  # InterIntelli
      PK_ELECTRONICS       =   2634  # PK Electronics
      BACKBURNER           =   2635  # Back Burner
      SOLVE                =   2636  # Solve
      IMDOCSVC             =   2637  # Import Document Service
      SYBASEANYWHERE       =   2638  # Sybase Anywhere
      AMINET               =   2639  # AMInet
      SAI_SENTLM           =   2640  # Sabbagh Associates Licence ManagerIANA assigned this well_formed service name as a replacement for "sai_sentlm".
      SAI_SENTLM           =   2640  # Sabbagh Associates Licence Manager
      HDL_SRV              =   2641  # HDL Server
      TRAGIC               =   2642  # Tragic
      GTE_SAMP             =   2643  # GTE_SAMP
      TRAVSOFT_IPX_T       =   2644  # Travsoft IPX Tunnel
      NOVELL_IPX_CMD       =   2645  # Novell IPX CMD
      AND_LM               =   2646  # AND License Manager
      SYNCSERVER           =   2647  # SyncServer
      UPSNOTIFYPROT        =   2648  # Upsnotifyprot
      VPSIPPORT            =   2649  # VPSIPPORT
      ERISTWOGUNS          =   2650  # eristwoguns
      EBINSITE             =   2651  # EBInSite
      INTERPATHPANEL       =   2652  # InterPathPanel
      SONUS                =   2653  # Sonus
      COREL_VNCADMIN       =   2654  # Corel VNC AdminIANA assigned this well_formed service name as a replacement for "corel_vncadmin".
      COREL_VNCADMIN       =   2654  # Corel VNC Admin
      UNGLUE               =   2655  # UNIX Nt Glue
      KANA                 =   2656  # Kana
      SNS_DISPATCHER       =   2657  # SNS Dispatcher
      SNS_ADMIN            =   2658  # SNS Admin
      SNS_QUERY            =   2659  # SNS Query
      GCMONITOR            =   2660  # GC Monitor
      OLHOST               =   2661  # OLHOST
      BINTEC_CAPI          =   2662  # BinTec_CAPI Unauthorized Use Known on port 2662
      BINTEC_TAPI          =   2663  # BinTec_TAPI
      PATROL_MQ_GM         =   2664  # Patrol for MQ GM
      PATROL_MQ_NM         =   2665  # Patrol for MQ NM
      EXTENSIS             =   2666  # extensis
      ALARM_CLOCK_S        =   2667  # Alarm Clock Server
      ALARM_CLOCK_C        =   2668  # Alarm Clock Client
      TOAD                 =   2669  # TOAD
      TVE_ANNOUNCE         =   2670  # TVE Announce
      NEWLIXREG            =   2671  # newlixreg
      NHSERVER             =   2672  # nhserver
      FIRSTCALL42          =   2673  # First Call 42
      EWNN                 =   2674  # ewnn
      TTC_ETAP             =   2675  # TTC ETAP
      SIMSLINK             =   2676  # SIMSLink
      GADGETGATE1WAY       =   2677  # Gadget Gate 1 Way
      GADGETGATE2WAY       =   2678  # Gadget Gate 2 Way
      SYNCSERVERSSL        =   2679  # Sync Server SSL
      PXC_SAPXOM           =   2680  # pxc_sapxom
      MPNJSOMB             =   2681  # mpnjsomb
      NCDLOADBALANCE       =   2683  # NCDLoadBalance
      MPNJSOSV             =   2684  # mpnjsosv
      MPNJSOCL             =   2685  # mpnjsocl
      MPNJSOMG             =   2686  # mpnjsomg
      PQ_LIC_MGMT          =   2687  # pq_lic_mgmt
      MD_CG_HTTP           =   2688  # md_cf_http
      FASTLYNX             =   2689  # FastLynx
      HP_NNM_DATA          =   2690  # HP NNM Embedded Database
      ITINTERNET           =   2691  # ITInternet ISM Server
      ADMINS_LMS           =   2692  # Admins LMS
      PWRSEVENT            =   2694  # pwrsevent
      VSPREAD              =   2695  # VSPREAD
      UNIFYADMIN           =   2696  # Unify Admin
      OCE_SNMP_TRAP        =   2697  # Oce SNMP Trap Port
      MCK_IVPIP            =   2698  # MCK_IVPIP
      CSOFT_PLUSCLNT       =   2699  # Csoft Plus Client
      TQDATA               =   2700  # tqdata
      SMS_RCINFO           =   2701  # SMS RCINFO
      SMS_XFER             =   2702  # SMS XFER
      SMS_CHAT             =   2703  # SMS CHAT
      SMS_REMCTRL          =   2704  # SMS REMCTRL
      SDS_ADMIN            =   2705  # SDS Admin
      NCDMIRRORING         =   2706  # NCD Mirroring
      EMCSYMAPIPORT        =   2707  # EMCSYMAPIPORT
      BANYAN_NET           =   2708  # Banyan_Net
      SUPERMON             =   2709  # Supermon
      SSO_SERVICE          =   2710  # SSO Service
      SSO_CONTROL          =   2711  # SSO Control
      AOCP                 =   2712  # Axapta Object Communication Protocol
      RAVENTBS             =   2713  # Raven Trinity Broker Service
      RAVENTDM             =   2714  # Raven Trinity Data Mover
      HPSTGMGR2            =   2715  # HPSTGMGR2
      INOVA_IP_DISCO       =   2716  # Inova IP Disco
      PN_REQUESTER         =   2717  # PN REQUESTER
      PN_REQUESTER2        =   2718  # PN REQUESTER 2
      SCAN_CHANGE          =   2719  # Scan & Change
      WKARS                =   2720  # wkars
      SMART_DIAGNOSE       =   2721  # Smart Diagnose
      PROACTIVESRVR        =   2722  # Proactive Server
      WATCHDOG_NT          =   2723  # WatchDog NT Protocol
      QOTPS                =   2724  # qotps
      MSOLAP_PTP2          =   2725  # MSOLAP PTP2
      TAMS                 =   2726  # TAMS
      MGCP_CALLAGENT       =   2727  # Media Gateway Control Protocol Call Agent
      SQDR                 =   2728  # SQDR
      TCIM_CONTROL         =   2729  # TCIM Control
      NEC_RAIDPLUS         =   2730  # NEC RaidPlus
      FYRE_MESSANGER       =   2731  # Fyre Messanger
      G5M                  =   2732  # G5M
      SIGNET_CTF           =   2733  # Signet CTF
      CCS_SOFTWARE         =   2734  # CCS Software
      NETIQ_MC             =   2735  # NetIQ Monitor Console
      RADWIZ_NMS_SRV       =   2736  # RADWIZ NMS SRV
      SRP_FEEDBACK         =   2737  # SRP Feedback
      NDL_TCP_OIS_GW       =   2738  # NDL TCP_OSI Gateway
      TN_TIMING            =   2739  # TN Timing
      ALARM                =   2740  # Alarm
      TSB                  =   2741  # TSB
      TSB2                 =   2742  # TSB2
      MURX                 =   2743  # murx
      HONYAKU              =   2744  # honyaku
      URBISNET             =   2745  # URBISNET
      CPUDPENCAP           =   2746  # CPUDPENCAP
      FJIPPOL_SWRLY        =   2747  # 
      FJIPPOL_POLSVR       =   2748  # 
      FJIPPOL_CNSL         =   2749  # 
      FJIPPOL_PORT1        =   2750  # 
      FJIPPOL_PORT2        =   2751  # 
      RSISYSACCESS         =   2752  # RSISYS ACCESS
      DE_SPOT              =   2753  # de_spot
      APOLLO_CC            =   2754  # APOLLO CC
      EXPRESSPAY           =   2755  # Express Pay
      SIMPLEMENT_TIE       =   2756  # simplement_tie
      CNRP                 =   2757  # CNRP
      APOLLO_STATUS        =   2758  # APOLLO Status
      APOLLO_GMS           =   2759  # APOLLO GMS
      SABAMS               =   2760  # Saba MS
      DICOM_ISCL           =   2761  # DICOM ISCL
      DICOM_TLS            =   2762  # DICOM TLS
      DESKTOP_DNA          =   2763  # Desktop DNA
      DATA_INSURANCE       =   2764  # Data Insurance
      QIP_AUDUP            =   2765  # qip_audup
      COMPAQ_SCP           =   2766  # Compaq SCP
      UADTC                =   2767  # UADTC
      UACS                 =   2768  # UACS
      EXCE                 =   2769  # eXcE
      VERONICA             =   2770  # Veronica
      VERGENCECM           =   2771  # Vergence CM
      AURIS                =   2772  # auris
      RBAKCUP1             =   2773  # RBackup Remote Backup
      RBAKCUP2             =   2774  # RBackup Remote Backup
      SMPP                 =   2775  # SMPP
      RIDGEWAY1            =   2776  # Ridgeway Systems & Software
      RIDGEWAY2            =   2777  # Ridgeway Systems & Software
      GWEN_SONYA           =   2778  # Gwen_Sonya
      LBC_SYNC             =   2779  # LBC Sync
      LBC_CONTROL          =   2780  # LBC Control
      WHOSELLS             =   2781  # whosells
      EVERYDAYRC           =   2782  # everydayrc
      AISES                =   2783  # AISES
      WWW_DEV              =   2784  # world wide web _ development
      AIC_NP               =   2785  # aic_np
      AIC_ONCRPC           =   2786  # aic_oncrpc _ Destiny MCD database
      PICCOLO              =   2787  # piccolo _ Cornerstone Software
      FRYESERV             =   2788  # NetWare Loadable Module _ Seagate Software
      MEDIA_AGENT          =   2789  # Media Agent
      PLGPROXY             =   2790  # PLG Proxy
      MTPORT_REGIST        =   2791  # MT Port Registrator
      F5_GLOBALSITE        =   2792  # f5_globalsite
      INITLSMSAD           =   2793  # initlsmsad
      LIVESTATS            =   2795  # LiveStats
      AC_TECH              =   2796  # ac_tech
      ESP_ENCAP            =   2797  # esp_encap
      TMESIS_UPSHOT        =   2798  # TMESIS_UPShot
      ICON_DISCOVER        =   2799  # ICON Discover
      ACC_RAID             =   2800  # ACC RAID
      IGCP                 =   2801  # IGCP
      VERITAS_TCP1         =   2802  # Veritas TCP1
      BTPRJCTRL            =   2803  # btprjctrl
      DVR_ESM              =   2804  # March Networks Digital Video Recorders and Enterprise Service Manager products
      WTA_WSP_S            =   2805  # WTA WSP_S
      CSPUNI               =   2806  # cspuni
      CSPMULTI             =   2807  # cspmulti
      J_LAN_P              =   2808  # J_LAN_P
      CORBALOC             =   2809  # CORBA LOC
      NETSTEWARD           =   2810  # Active Net Steward
      GSIFTP               =   2811  # GSI FTP
      ATMTCP               =   2812  # atmtcp
      LLM_PASS             =   2813  # llm_pass
      LLM_CSV              =   2814  # llm_csv
      LBC_MEASURE          =   2815  # LBC Measurement
      LBC_WATCHDOG         =   2816  # LBC Watchdog
      NMSIGPORT            =   2817  # NMSig Port
      RMLNK                =   2818  # rmlnk
      FC_FAULTNOTIFY       =   2819  # FC Fault Notification
      UNIVISION            =   2820  # UniVision
      VRTS_AT_PORT         =   2821  # VERITAS Authentication Service
      KA0WUC               =   2822  # ka0wuc
      CQG_NETLAN           =   2823  # CQG Net_LAN
      CQG_NETLAN_1         =   2824  # CQG Net_LAN 1
      SLC_SYSTEMLOG        =   2826  # slc systemlog
      SLC_CTRLRLOOPS       =   2827  # slc ctrlrloops
      ITM_LM               =   2828  # ITM License Manager
      SILKP1               =   2829  # silkp1
      SILKP2               =   2830  # silkp2
      SILKP3               =   2831  # silkp3
      SILKP4               =   2832  # silkp4
      GLISHD               =   2833  # glishd
      EVTP                 =   2834  # EVTP
      EVTP_DATA            =   2835  # EVTP_DATA
      CATALYST             =   2836  # catalyst
      REPLIWEB             =   2837  # Repliweb
      STARBOT              =   2838  # Starbot
      NMSIGPORT            =   2839  # NMSigPort
      L3_EXPRT             =   2840  # l3_exprt
      L3_RANGER            =   2841  # l3_ranger
      L3_HAWK              =   2842  # l3_hawk
      PDNET                =   2843  # PDnet
      BPCP_POLL            =   2844  # BPCP POLL
      BPCP_TRAP            =   2845  # BPCP TRAP
      AIMPP_HELLO          =   2846  # AIMPP Hello
      AIMPP_PORT_REQ       =   2847  # AIMPP Port Req
      AMT_BLC_PORT         =   2848  # AMT_BLC_PORT
      FXP                  =   2849  # FXP
      METACONSOLE          =   2850  # MetaConsole
      WEBEMSHTTP           =   2851  # webemshttp
      BEARS_01             =   2852  # bears_01
      ISPIPES              =   2853  # ISPipes
      INFOMOVER            =   2854  # InfoMover
      MSRP                 =   2855  # MSRP over TCP 2014_04_09
      CESDINV              =   2856  # cesdinv
      SIMCTLP              =   2857  # SimCtIP
      ECNP                 =   2858  # ECNP
      ACTIVEMEMORY         =   2859  # Active Memory
      DIALPAD_VOICE1       =   2860  # Dialpad Voice 1
      DIALPAD_VOICE2       =   2861  # Dialpad Voice 2
      TTG_PROTOCOL         =   2862  # TTG Protocol
      SONARDATA            =   2863  # Sonar Data
      ASTROMED_MAIN        =   2864  # main 5001 cmd
      PIT_VPN              =   2865  # pit_vpn
      IWLISTENER           =   2866  # iwlistener
      ESPS_PORTAL          =   2867  # esps_portal
      NPEP_MESSAGING       =   2868  # Norman Proprietaqry Events Protocol
      ICSLAP               =   2869  # ICSLAP
      DAISHI               =   2870  # daishi
      MSI_SELECTPLAY       =   2871  # MSI Select Play
      RADIX                =   2872  # RADIX
      DXMESSAGEBASE1       =   2874  # DX Message Base Transport Protocol
      DXMESSAGEBASE2       =   2875  # DX Message Base Transport Protocol
      SPS_TUNNEL           =   2876  # SPS Tunnel
      BLUELANCE            =   2877  # BLUELANCE
      AAP                  =   2878  # AAP
      UCENTRIC_DS          =   2879  # ucentric_ds
      SYNAPSE              =   2880  # Synapse Transport
      NDSP                 =   2881  # NDSP
      NDTP                 =   2882  # NDTP
      NDNP                 =   2883  # NDNP
      FLASHMSG             =   2884  # Flash Msg
      TOPFLOW              =   2885  # TopFlow
      RESPONSELOGIC        =   2886  # RESPONSELOGIC
      AIRONETDDP           =   2887  # aironet
      SPCSDLOBBY           =   2888  # SPCSDLOBBY
      RSOM                 =   2889  # RSOM
      CSPCLMULTI           =   2890  # CSPCLMULTI
      CINEGRFX_ELMD        =   2891  # CINEGRFX_ELMD License Manager
      SNIFFERDATA          =   2892  # SNIFFERDATA
      VSECONNECTOR         =   2893  # VSECONNECTOR
      ABACUS_REMOTE        =   2894  # ABACUS_REMOTE
      NATUSLINK            =   2895  # NATUS LINK
      ECOVISIONG6_1        =   2896  # ECOVISIONG6_1
      CITRIX_RTMP          =   2897  # Citrix RTMP
      APPLIANCE_CFG        =   2898  # APPLIANCE_CFG
      POWERGEMPLUS         =   2899  # POWERGEMPLUS
      QUICKSUITE           =   2900  # QUICKSUITE
      ALLSTORCNS           =   2901  # ALLSTORCNS
      NETASPI              =   2902  # NET ASPI
      SUITCASE             =   2903  # SUITCASE
      M2UA                 =   2904  # M2UA
      M3UA                 =   2905  # M3UA
      CALLER9              =   2906  # CALLER9
      WEBMETHODS_B2B       =   2907  # WEBMETHODS B2B
      MAO                  =   2908  # mao
      FUNK_DIALOUT         =   2909  # Funk Dialout
      TDACCESS             =   2910  # TDAccess
      BLOCKADE             =   2911  # Blockade
      EPICON               =   2912  # Epicon
      BOOSTERWARE          =   2913  # Booster Ware
      GAMELOBBY            =   2914  # Game Lobby
      TKSOCKET             =   2915  # TK Socket
      ELVIN_SERVER         =   2916  # Elvin ServerIANA assigned this well_formed service name as a replacement for "elvin_server".
      ELVIN_SERVER         =   2916  # Elvin Server This entry is an alias to "elvin_server".This entry is now historic, not usable for use with manycommon service discovery mechanisms.
      ELVIN_CLIENT         =   2917  # Elvin ClientIANA assigned this well_formed service name as a replacement for "elvin_client".
      ELVIN_CLIENT         =   2917  # Elvin Client
      KASTENCHASEPAD       =   2918  # Kasten Chase Pad
      ROBOER               =   2919  # roboER
      ROBOEDA              =   2920  # roboEDA
      CESDCDMAN            =   2921  # CESD Contents Delivery Management
      CESDCDTRN            =   2922  # CESD Contents Delivery Data Transfer
      WTA_WSP_WTP_S        =   2923  # WTA_WSP_WTP_S
      PRECISE_VIP          =   2924  # PRECISE_VIP
      MOBILE_FILE_DL       =   2926  # MOBILE_FILE_DL
      UNIMOBILECTRL        =   2927  # UNIMOBILECTRL
      REDSTONE_CPSS        =   2928  # REDSTONE_CPSS
      AMX_WEBADMIN         =   2929  # AMX_WEBADMIN
      AMX_WEBLINX          =   2930  # AMX_WEBLINX
      CIRCLE_X             =   2931  # Circle_X
      INCP                 =   2932  # INCP
#      4_TIEROPMGW          =   2933  # 4_TIER OPM GW
#      4_TIEROPMCLI         =   2934  # 4_TIER OPM CLI
      QTP                  =   2935  # QTP
      OTPATCH              =   2936  # OTPatch
      PNACONSULT_LM        =   2937  # PNACONSULT_LM
      SM_PAS_1             =   2938  # SM_PAS_1
      SM_PAS_2             =   2939  # SM_PAS_2
      SM_PAS_3             =   2940  # SM_PAS_3
      SM_PAS_4             =   2941  # SM_PAS_4
      SM_PAS_5             =   2942  # SM_PAS_5
      TTNREPOSITORY        =   2943  # TTNRepository
      MEGACO_H248          =   2944  # Megaco H_248
      H248_BINARY          =   2945  # H248 Binary
      FJSVMPOR             =   2946  # FJSVmpor
      GPSD                 =   2947  # GPS Daemon request_response protocol
      WAP_PUSH             =   2948  # WAP PUSH
      WAP_PUSHSECURE       =   2949  # WAP PUSH SECURE
      ESIP                 =   2950  # ESIP
      OTTP                 =   2951  # OTTP
      MPFWSAS              =   2952  # MPFWSAS
      OVALARMSRV           =   2953  # OVALARMSRV
      OVALARMSRV_CMD       =   2954  # OVALARMSRV_CMD
      CSNOTIFY             =   2955  # CSNOTIFY
      OVRIMOSDBMAN         =   2956  # OVRIMOSDBMAN
      JMACT5               =   2957  # JAMCT5
      JMACT6               =   2958  # JAMCT6
      RMOPAGT              =   2959  # RMOPAGT
      DFOXSERVER           =   2960  # DFOXSERVER
      BOLDSOFT_LM          =   2961  # BOLDSOFT_LM
      IPH_POLICY_CLI       =   2962  # IPH_POLICY_CLI
      IPH_POLICY_ADM       =   2963  # IPH_POLICY_ADM
      BULLANT_SRAP         =   2964  # BULLANT SRAP
      BULLANT_RAP          =   2965  # BULLANT RAP
      IDP_INFOTRIEVE       =   2966  # IDP_INFOTRIEVE
      SSC_AGENT            =   2967  # SSC_AGENT
      ENPP                 =   2968  # ENPP
      ESSP                 =   2969  # ESSP
      INDEX_NET            =   2970  # INDEX_NET
      NETCLIP              =   2971  # NetClip clipboard daemon
      PMSM_WEBRCTL         =   2972  # PMSM Webrctl
      SVNETWORKS           =   2973  # SV Networks
      SIGNAL               =   2974  # Signal
      FJMPCM               =   2975  # Fujitsu Configuration Management Service
      CNS_SRV_PORT         =   2976  # CNS Server Port
      TTC_ETAP_NS          =   2977  # TTCs Enterprise Test Access Protocol _ NS
      TTC_ETAP_DS          =   2978  # TTCs Enterprise Test Access Protocol _ DS
      H263_VIDEO           =   2979  # H.263 Video Streaming
      WIMD                 =   2980  # Instant Messaging Service
      MYLXAMPORT           =   2981  # MYLXAMPORT
      IWB_WHITEBOARD       =   2982  # IWB_WHITEBOARD
      NETPLAN              =   2983  # NETPLAN
      HPIDSADMIN           =   2984  # HPIDSADMIN
      HPIDSAGENT           =   2985  # HPIDSAGENT
      STONEFALLS           =   2986  # STONEFALLS
      IDENTIFY             =   2987  # identify
      HIPPAD               =   2988  # HIPPA Reporting Protocol
      ZARKOV               =   2989  # ZARKOV Intelligent Agent Communication
      BOSCAP               =   2990  # BOSCAP
      WKSTN_MON            =   2991  # WKSTN_MON
      AVENYO               =   2992  # Avenyo Server
      VERITAS_VIS1         =   2993  # VERITAS VIS1
      VERITAS_VIS2         =   2994  # VERITAS VIS2
      IDRS                 =   2995  # IDRS
      VSIXML               =   2996  # vsixml
      REBOL                =   2997  # REBOL
      REALSECURE           =   2998  # Real Secure
      REMOTEWARE_UN        =   2999  # RemoteWare Unassigned
      HBCI                 =   3000  # HBCI
      REMOTEWARE_CL        =   3000  # RemoteWare Client
      ORIGO_NATIVE         =   3001  # OrigoDB Server Native Interface
      EXLM_AGENT           =   3002  # EXLM Agent
      REMOTEWARE_SRV       =   3002  # RemoteWare Server
      CGMS                 =   3003  # CGMS
      CSOFTRAGENT          =   3004  # Csoft Agent
      GENIUSLM             =   3005  # Genius License Manager
      II_ADMIN             =   3006  # Instant Internet Admin
      LOTUSMTAP            =   3007  # Lotus Mail Tracking Agent Protocol
      MIDNIGHT_TECH        =   3008  # Midnight Technologies
      PXC_NTFY             =   3009  # PXC_NTFY
      GW                   =   3010  # Telerate Workstation
      TRUSTED_WEB          =   3011  # Trusted Web
      TWSDSS               =   3012  # Trusted Web Client
      GILATSKYSURFER       =   3013  # Gilat Sky Surfer
      BROKER_SERVICE       =   3014  # Broker ServiceIANA assigned this well_formed service name as a replacement for "broker_service".
      BROKER_SERVICE       =   3014  # Broker Service
      NATI_DSTP            =   3015  # NATI DSTP
      NOTIFY_SRVR          =   3016  # Notify ServerIANA assigned this well_formed service name as a replacement for "notify_srvr".
      NOTIFY_SRVR          =   3016  # Notify Server
      EVENT_LISTENER       =   3017  # Event ListenerIANA assigned this well_formed service name as a replacement for "event_listener".
      EVENT_LISTENER       =   3017  # Event Listener
      SRVC_REGISTRY        =   3018  # Service RegistryIANA assigned this well_formed service name as a replacement for "srvc_registry".
      SRVC_REGISTRY        =   3018  # Service Registry
      RESOURCE_MGR         =   3019  # Resource ManagerIANA assigned this well_formed service name as a replacement for "resource_mgr".
      RESOURCE_MGR         =   3019  # Resource Manager
      CIFS                 =   3020  # CIFS
      AGRISERVER           =   3021  # AGRI Server
      CSREGAGENT           =   3022  # CSREGAGENT
      MAGICNOTES           =   3023  # magicnotes
      NDS_SSO              =   3024  # NDS_SSOIANA assigned this well_formed service name as a replacement for "nds_sso".
      NDS_SSO              =   3024  # NDS_SSO
      AREPA_RAFT           =   3025  # Arepa Raft
      AGRI_GATEWAY         =   3026  # AGRI Gateway
      LIEBDEVMGMT_C        =   3027  # LiebDevMgmt_CIANA assigned this well_formed service name as a replacement for "LiebDevMgmt_C".
      LIEBDEVMGMT_C        =   3027  # LiebDevMgmt_C This entry is an alias to "LiebDevMgmt_C".This entry is now historic, not usable for use with manycommon service discovery mechanisms.
      LIEBDEVMGMT_DM       =   3028  # LiebDevMgmt_DMIANA assigned this well_formed service name as a replacement for "LiebDevMgmt_DM".
      LIEBDEVMGMT_DM       =   3028  # LiebDevMgmt_DM This entry is an alias to "LiebDevMgmt_DM".This entry is now historic, not usable for use with manycommon service discovery mechanisms.
      LIEBDEVMGMT_A        =   3029  # LiebDevMgmt_AIANA assigned this well_formed service name as a replacement for "LiebDevMgmt_A".
      LIEBDEVMGMT_A        =   3029  # LiebDevMgmt_A
      AREPA_CAS            =   3030  # Arepa Cas
      EPPC                 =   3031  # Remote AppleEvents_PPC Toolbox
      REDWOOD_CHAT         =   3032  # Redwood Chat
      PDB                  =   3033  # PDB
      OSMOSIS_AEEA         =   3034  # Osmosis _ Helix (R) AEEA Port
      FJSV_GSSAGT          =   3035  # FJSV gssagt
      HAGEL_DUMP           =   3036  # Hagel DUMP
      HP_SAN_MGMT          =   3037  # HP SAN Mgmt
      SANTAK_UPS           =   3038  # Santak UPS
      COGITATE             =   3039  # Cogitate, Inc.
      TOMATO_SPRINGS       =   3040  # Tomato Springs
      DI_TRACEWARE         =   3041  # di_traceware
      JOURNEE              =   3042  # journee
      BRP                  =   3043  # Broadcast Routing Protocol
      EPP                  =   3044  # EndPoint Protocol
      RESPONSENET          =   3045  # ResponseNet
      DI_ASE               =   3046  # di_ase
      HLSERVER             =   3047  # Fast Security HL Server
      PCTRADER             =   3048  # Sierra Net PC Trader
      NSWS                 =   3049  # NSWS
      GDS_DB               =   3050  # gds_dbIANA assigned this well_formed service name as a replacement for "gds_db".
      GDS_DB               =   3050  # gds_db
      GALAXY_SERVER        =   3051  # Galaxy Server
      APC_3052             =   3052  # APC 3052
      DSOM_SERVER          =   3053  # dsom_server
      AMT_CNF_PROT         =   3054  # AMT CNF PROT
      POLICYSERVER         =   3055  # Policy Server
      CDL_SERVER           =   3056  # CDL Server
      GOAHEAD_FLDUP        =   3057  # GoAhead FldUp
      VIDEOBEANS           =   3058  # videobeans
      QSOFT                =   3059  # qsoft
      INTERSERVER          =   3060  # interserver
      CAUTCPD              =   3061  # cautcpd
      NCACN_IP_TCP         =   3062  # ncacn_ip_tcp
      NCADG_IP_UDP         =   3063  # ncadg_ip_udp
      RPRT                 =   3064  # Remote Port Redirector
      SLINTERBASE          =   3065  # slinterbase
      NETATTACHSDMP        =   3066  # NETATTACHSDMP
      FJHPJP               =   3067  # FJHPJP
      LS3BCAST             =   3068  # ls3 Broadcast
      LS3                  =   3069  # ls3
      MGXSWITCH            =   3070  # MGXSWITCH
      CSD_MGMT_PORT        =   3071  # ContinuStor Manager Port
      CSD_MONITOR          =   3072  # ContinuStor Monitor Port
      VCRP                 =   3073  # Very simple chatroom prot
      XBOX                 =   3074  # Xbox game port
      ORBIX_LOCATOR        =   3075  # Orbix 2000 Locator
      ORBIX_CONFIG         =   3076  # Orbix 2000 Config
      ORBIX_LOC_SSL        =   3077  # Orbix 2000 Locator SSL
      ORBIX_CFG_SSL        =   3078  # Orbix 2000 Locator SSL
      LV_FRONTPANEL        =   3079  # LV Front Panel
      STM_PPROC            =   3080  # stm_pprocIANA assigned this well_formed service name as a replacement for "stm_pproc".
      STM_PPROC            =   3080  # stm_pproc
      TL1_LV               =   3081  # TL1_LV
      TL1_RAW              =   3082  # TL1_RAW
      TL1_TELNET           =   3083  # TL1_TELNET
      ITM_MCCS             =   3084  # ITM_MCCS
      PCIHREQ              =   3085  # PCIHReq
      JDL_DBKITCHEN        =   3086  # JDL_DBKitchen
      ASOKI_SMA            =   3087  # Asoki SMA
      XDTP                 =   3088  # eXtensible Data Transfer Protocol
      PTK_ALINK            =   3089  # ParaTek Agent Linking
      STSS                 =   3090  # Senforce Session Services
#      1CI_SMCS             =   3091  # 1Ci Server Management
      RAPIDMQ_CENTER       =   3093  # Jiiva RapidMQ Center
      RAPIDMQ_REG          =   3094  # Jiiva RapidMQ Registry
      PANASAS              =   3095  # Panasas rendevous port
      NDL_APS              =   3096  # Active Print Server Port
      UMM_PORT             =   3098  # Universal Message Manager
      CHMD                 =   3099  # CHIPSY Machine Daemon
      OPCON_XPS            =   3100  # OpCon_xps
      HP_PXPIB             =   3101  # HP PolicyXpert PIB Server
      SLSLAVEMON           =   3102  # SoftlinK Slave Mon Port
      AUTOCUESMI           =   3103  # Autocue SMI Protocol
      AUTOCUELOG           =   3104  # Autocue Logger Protocol
      CARDBOX              =   3105  # Cardbox
      CARDBOX_HTTP         =   3106  # Cardbox HTTP
      BUSINESS             =   3107  # Business protocol
      GEOLOCATE            =   3108  # Geolocate protocol
      PERSONNEL            =   3109  # Personnel protocol
      SIM_CONTROL          =   3110  # simulator control port
      WSYNCH               =   3111  # Web Synchronous Services
      KSYSGUARD            =   3112  # KDE System Guard
      CS_AUTH_SVR          =   3113  # CS_Authenticate Svr Port
      CCMAD                =   3114  # CCM AutoDiscover
      MCTET_MASTER         =   3115  # MCTET Master
      MCTET_GATEWAY        =   3116  # MCTET Gateway
      MCTET_JSERV          =   3117  # MCTET Jserv
      PKAGENT              =   3118  # PKAgent
      D2000KERNEL          =   3119  # D2000 Kernel Port
      D2000WEBSERVER       =   3120  # D2000 Webserver Port
      PCMK_REMOTE          =   3121  # The pacemaker remote (pcmk_remote) service extends high availability functionality outside of the Linux cluster into remote nodes.
      VTR_EMULATOR         =   3122  # MTI VTR Emulator port
      EDIX                 =   3123  # EDI Translation Protocol
      BEACON_PORT          =   3124  # Beacon Port
      A13_AN               =   3125  # A13_AN Interface
      CTX_BRIDGE           =   3127  # CTX Bridge Port
      NDL_AAS              =   3128  # Active API Server Port
      NETPORT_ID           =   3129  # NetPort Discovery Port
      ICPV2                =   3130  # ICPv2
      NETBOOKMARK          =   3131  # Net Book Mark
      MS_RULE_ENGINE       =   3132  # Microsoft Business Rule Engine Update Service
      PRISM_DEPLOY         =   3133  # Prism Deploy User Port
      ECP                  =   3134  # Extensible Code Protocol
      PEERBOOK_PORT        =   3135  # PeerBook Port
      GRUBD                =   3136  # Grub Server Port
      RTNT_1               =   3137  # rtnt_1 data packets
      RTNT_2               =   3138  # rtnt_2 data packets
      INCOGNITORV          =   3139  # Incognito Rendez_Vous
      ARILIAMULTI          =   3140  # Arilia Multiplexor
      VMODEM               =   3141  # VMODEM
      RDC_WH_EOS           =   3142  # RDC WH EOS
      SEAVIEW              =   3143  # Sea View
      TARANTELLA           =   3144  # Tarantella
      CSI_LFAP             =   3145  # CSI_LFAP
      BEARS_02             =   3146  # bears_02
      RFIO                 =   3147  # RFIO
      NM_GAME_ADMIN        =   3148  # NetMike Game Administrator
      NM_GAME_SERVER       =   3149  # NetMike Game Server
      NM_ASSES_ADMIN       =   3150  # NetMike Assessor Administrator
      NM_ASSESSOR          =   3151  # NetMike Assessor
      FEITIANROCKEY        =   3152  # FeiTian Port
      S8_CLIENT_PORT       =   3153  # S8Cargo Client Port
      CCMRMI               =   3154  # ON RMI Registry
      JPEGMPEG             =   3155  # JpegMpeg Port
      INDURA               =   3156  # Indura Collector
#      E3CONSULTANTS        =   3157  # CCC Listener Port
      STVP                 =   3158  # SmashTV Protocol
      NAVEGAWEB_PORT       =   3159  # NavegaWeb Tarification
      TIP_APP_SERVER       =   3160  # TIP Application Server
      DOC1LM               =   3161  # DOC1 License Manager
      SFLM                 =   3162  # SFLM
      RES_SAP              =   3163  # RES_SAP
      IMPRS                =   3164  # IMPRS
      NEWGENPAY            =   3165  # Newgenpay Engine Service
      SOSSECOLLECTOR       =   3166  # Quest Spotlight Out_Of_Process Collector
      NOWCONTACT           =   3167  # Now Contact Public Server
      POWERONNUD           =   3168  # Now Up_to_Date Public Server
      SERVERVIEW_AS        =   3169  # SERVERVIEW_AS
      SERVERVIEW_ASN       =   3170  # SERVERVIEW_ASN
      SERVERVIEW_GF        =   3171  # SERVERVIEW_GF
      SERVERVIEW_RM        =   3172  # SERVERVIEW_RM
      SERVERVIEW_ICC       =   3173  # SERVERVIEW_ICC
      ARMI_SERVER          =   3174  # ARMI Server
      T1_E1_OVER_IP        =   3175  # T1_E1_Over_IP
      ARS_MASTER           =   3176  # ARS Master
      PHONEX_PORT          =   3177  # Phonex Protocol
      RADCLIENTPORT        =   3178  # Radiance UltraEdge Port
#      H2GF_W_2M            =   3179  # H2GF W.2m Handover prot.
      MC_BRK_SRV           =   3180  # Millicent Broker Server
      BMCPATROLAGENT       =   3181  # BMC Patrol Agent
      BMCPATROLRNVU        =   3182  # BMC Patrol Rendezvous
      COPS_TLS             =   3183  # COPS_TLS
      APOGEEX_PORT         =   3184  # ApogeeX Port
      SMPPPD               =   3185  # SuSE Meta PPPD
      IIW_PORT             =   3186  # IIW Monitor User Port
      ODI_PORT             =   3187  # Open Design Listen Port
      BRCM_COMM_PORT       =   3188  # Broadcom Port
      PCLE_INFEX           =   3189  # Pinnacle Sys InfEx Port
      CSVR_PROXY           =   3190  # ConServR Proxy
      CSVR_SSLPROXY        =   3191  # ConServR SSL Proxy
      FIREMONRCC           =   3192  # FireMon Revision Control
      SPANDATAPORT         =   3193  # SpanDataPort
      MAGBIND              =   3194  # Rockstorm MAG protocol
      NCU_1                =   3195  # Network Control Unit
      NCU_2                =   3196  # Network Control Unit
      EMBRACE_DP_S         =   3197  # Embrace Device Protocol Server
      EMBRACE_DP_C         =   3198  # Embrace Device Protocol Client
      DMOD_WORKSPACE       =   3199  # DMOD WorkSpace
      TICK_PORT            =   3200  # Press_sense Tick Port
      CPQ_TASKSMART        =   3201  # CPQ_TaskSmart
      INTRAINTRA           =   3202  # IntraIntra
      NETWATCHER_MON       =   3203  # Network Watcher Monitor
      NETWATCHER_DB        =   3204  # Network Watcher DB Access
      ISNS                 =   3205  # iSNS Server Port
      IRONMAIL             =   3206  # IronMail POP Proxy
      VX_AUTH_PORT         =   3207  # Veritas Authentication Port
      PFU_PRCALLBACK       =   3208  # PFU PR Callback
      NETWKPATHENGINE      =   3209  # HP OpenView Network Path Engine Server
      FLAMENCO_PROXY       =   3210  # Flamenco Networks Proxy
      AVSECUREMGMT         =   3211  # Avocent Secure Management
      SURVEYINST           =   3212  # Survey Instrument
      NEON24X7             =   3213  # NEON 24X7 Mission Control
      JMQ_DAEMON_1         =   3214  # JMQ Daemon Port 1
      JMQ_DAEMON_2         =   3215  # JMQ Daemon Port 2
      FERRARI_FOAM         =   3216  # Ferrari electronic FOAM
      UNITE                =   3217  # Unified IP & Telecom Environment
      SMARTPACKETS         =   3218  # EMC SmartPackets
      WMS_MESSENGER        =   3219  # WMS Messenger
      XNM_SSL              =   3220  # XML NM over SSL
      XNM_CLEAR_TEXT       =   3221  # XML NM over TCP
      GLBP                 =   3222  # Gateway Load Balancing Pr
      DIGIVOTE             =   3223  # DIGIVOTE (R) Vote_Server
      AES_DISCOVERY        =   3224  # AES Discovery Port
      FCIP_PORT            =   3225  # FCIP
      ISI_IRP              =   3226  # ISI Industry Software IRP
      DWNMSHTTP            =   3227  # DiamondWave NMS Server
      DWMSGSERVER          =   3228  # DiamondWave MSG Server
      GLOBAL_CD_PORT       =   3229  # Global CD Port
      SFTDST_PORT          =   3230  # Software Distributor Port
      VIDIGO               =   3231  # VidiGo communication (previous was: Delta Solutions Direct)
      MDTP                 =   3232  # MDT port 2012_02_21
      WHISKER              =   3233  # WhiskerControl main port
      ALCHEMY              =   3234  # Alchemy Server
      MDAP_PORT            =   3235  # MDAP port
      APPARENET_TS         =   3236  # appareNet Test Server
      APPARENET_TPS        =   3237  # appareNet Test Packet Sequencer
      APPARENET_AS         =   3238  # appareNet Analysis Server
      APPARENET_UI         =   3239  # appareNet User Interface
      TRIOMOTION           =   3240  # Trio Motion Control Port
      SYSORB               =   3241  # SysOrb Monitoring Server
      SDP_ID_PORT          =   3242  # Session Description ID
      TIMELOT              =   3243  # Timelot Port
      ONESAF               =   3244  # OneSAF
      VIEO_FE              =   3245  # VIEO Fabric Executive
      DVT_SYSTEM           =   3246  # DVT SYSTEM PORT
      DVT_DATA             =   3247  # DVT DATA LINK
      PROCOS_LM            =   3248  # PROCOS LM
      SSP                  =   3249  # State Sync Protocol
      HICP                 =   3250  # HMS hicp port
      SYSSCANNER           =   3251  # Sys Scanner
      DHE                  =   3252  # DHE port
      PDA_DATA             =   3253  # PDA Data
      PDA_SYS              =   3254  # PDA System
      SEMAPHORE            =   3255  # Semaphore Connection Port
      CPQRPM_AGENT         =   3256  # Compaq RPM Agent Port
      CPQRPM_SERVER        =   3257  # Compaq RPM Server Port
      IVECON_PORT          =   3258  # Ivecon Server Port
      EPNCDP2              =   3259  # Epson Network Common Devi
      ISCSI_TARGET         =   3260  # iSCSI port
      WINSHADOW            =   3261  # winShadow
      NECP                 =   3262  # NECP
      ECOLOR_IMAGER        =   3263  # E_Color Enterprise Imager
      CCMAIL               =   3264  # cc:mail_lotus
      ALTAV_TUNNEL         =   3265  # Altav Tunnel
      NS_CFG_SERVER        =   3266  # NS CFG Server
      IBM_DIAL_OUT         =   3267  # IBM Dial Out
      MSFT_GC              =   3268  # Microsoft Global Catalog
      MSFT_GC_SSL          =   3269  # Microsoft Global Catalog with LDAP_SSL
      VERISMART            =   3270  # Verismart
      CSOFT_PREV           =   3271  # CSoft Prev Port
      USER_MANAGER         =   3272  # Fujitsu User Manager
      SXMP                 =   3273  # Simple Extensible Multiplexed Protocol
      ORDINOX_SERVER       =   3274  # Ordinox Server
      #SAMD                 =   3275  # SAMD
      MAXIM_ASICS          =   3276  # Maxim ASICs
      AWG_PROXY            =   3277  # AWG Proxy
      LKCMSERVER           =   3278  # LKCM Server
      ADMIND               =   3279  # admind
      VS_SERVER            =   3280  # VS Server
      SYSOPT               =   3281  # SYSOPT
      DATUSORB             =   3282  # Datusorb
#      APPLE REMOTE DESKTOP =   3283  # Net Assistant
#      4TALK                =   3284  # 4Talk
      PLATO                =   3285  # Plato
      E_NET                =   3286  # E_Net
      DIRECTVDATA          =   3287  # DIRECTVDATA
      COPS                 =   3288  # COPS
      ENPC                 =   3289  # ENPC
      CAPS_LM              =   3290  # CAPS LOGISTICS TOOLKIT _ LM
      SAH_LM               =   3291  # S A Holditch & Associates _ LM
      CART_O_RAMA          =   3292  # Cart O Rama
      FG_FPS               =   3293  # fg_fps
      FG_GIP               =   3294  # fg_gip
      DYNIPLOOKUP          =   3295  # Dynamic IP Lookup
      RIB_SLM              =   3296  # Rib License Manager
      CYTEL_LM             =   3297  # Cytel License Manager
      DESKVIEW             =   3298  # DeskView
      PDRNCS               =   3299  # pdrncs
      MCS_FASTMAIL         =   3302  # MCS Fastmail
      OPSESSION_CLNT       =   3303  # OP Session Client
      OPSESSION_SRVR       =   3304  # OP Session Server
      ODETTE_FTP           =   3305  # ODETTE_FTP
      MYSQL                =   3306  # MySQL
      OPSESSION_PRXY       =   3307  # OP Session Proxy
      TNS_SERVER           =   3308  # TNS Server
      TNS_ADV              =   3309  # TNS ADV
      DYNA_ACCESS          =   3310  # Dyna Access
      MCNS_TEL_RET         =   3311  # MCNS Tel Ret
      APPMAN_SERVER        =   3312  # Application Management Server
      UORB                 =   3313  # Unify Object Broker
      UOHOST               =   3314  # Unify Object Host
      CDID                 =   3315  # CDID
      AICC_CMI             =   3316  # AICC_CMI
      VSAIPORT             =   3317  # VSAI PORT
      SSRIP                =   3318  # Swith to Swith Routing Information Protocol
      SDT_LMD              =   3319  # SDT License Manager
      OFFICELINK2000       =   3320  # Office Link 2000
      VNSSTR               =   3321  # VNSSTR
      SFTU                 =   3326  # SFTU
      BBARS                =   3327  # BBARS
      EGPTLM               =   3328  # Eaglepoint License Manager
      HP_DEVICE_DISC       =   3329  # HP Device Disc
      MCS_CALYPSOICF       =   3330  # MCS Calypso ICF
      MCS_MESSAGING        =   3331  # MCS Messaging
      MCS_MAILSVR          =   3332  # MCS Mail Server
      DEC_NOTES            =   3333  # DEC Notes
      DIRECTV_WEB          =   3334  # Direct TV Webcasting
      DIRECTV_SOFT         =   3335  # Direct TV Software Updates
      DIRECTV_TICK         =   3336  # Direct TV Tickers
      DIRECTV_CATLG        =   3337  # Direct TV Data Catalog
      ANET_B               =   3338  # OMF data b
      ANET_L               =   3339  # OMF data l
      ANET_M               =   3340  # OMF data m
      ANET_H               =   3341  # OMF data h
      WEBTIE               =   3342  # WebTIE
      MS_CLUSTER_NET       =   3343  # MS Cluster Net
      BNT_MANAGER          =   3344  # BNT Manager
      INFLUENCE            =   3345  # Influence
      TRNSPRNTPROXY        =   3346  # Trnsprnt Proxy
      PHOENIX_RPC          =   3347  # Phoenix RPC
      PANGOLIN_LASER       =   3348  # Pangolin Laser
      CHEVINSERVICES       =   3349  # Chevin Services
      FINDVIATV            =   3350  # FINDVIATV
      BTRIEVE              =   3351  # Btrieve port
      SSQL                 =   3352  # Scalable SQL
      FATPIPE              =   3353  # FATPIPE
      SUITJD               =   3354  # SUITJD
      ORDINOX_DBASE        =   3355  # Ordinox Dbase
      UPNOTIFYPS           =   3356  # UPNOTIFYPS
      ADTECH_TEST          =   3357  # Adtech Test IP
      MPSYSRMSVR           =   3358  # Mp Sys Rmsvr
      WG_NETFORCE          =   3359  # WG NetForce
      KV_SERVER            =   3360  # KV Server
      KV_AGENT             =   3361  # KV Agent
      DJ_ILM               =   3362  # DJ ILM
      NATI_VI_SERVER       =   3363  # NATI Vi Server
      CREATIVESERVER       =   3364  # Creative Server
      CONTENTSERVER        =   3365  # Content Server
      CREATIVEPARTNR       =   3366  # Creative Partner
      TIP2                 =   3372  # TIP 2
      LAVENIR_LM           =   3373  # Lavenir License Manager
      CLUSTER_DISC         =   3374  # Cluster Disc
      VSNM_AGENT           =   3375  # VSNM Agent
      CDBROKER             =   3376  # CD Broker
      COGSYS_LM            =   3377  # Cogsys Network License Manager
      WSICOPY              =   3378  # WSICOPY
      SOCORFS              =   3379  # SOCORFS
      SNS_CHANNELS         =   3380  # SNS Channels
      GENEOUS              =   3381  # Geneous
      FUJITSU_NEAT         =   3382  # Fujitsu Network Enhanced Antitheft function
      ESP_LM               =   3383  # Enterprise Software Products License Manager
      HP_CLIC              =   3384  # Cluster Management Services
      QNXNETMAN            =   3385  # qnxnetman
      GPRS_DATA            =   3386  # GPRS Data
      BACKROOMNET          =   3387  # Back Room Net
      CBSERVER             =   3388  # CB Server
      MS_WBT_SERVER        =   3389  # MS WBT Server
      DSC                  =   3390  # Distributed Service Coordinator
      SAVANT               =   3391  # SAVANT
      EFI_LM               =   3392  # EFI License Management
      D2K_TAPESTRY1        =   3393  # D2K Tapestry Client to Server
      D2K_TAPESTRY2        =   3394  # D2K Tapestry Server to Server
      DYNA_LM              =   3395  # Dyna License Manager (Elam)
      PRINTER_AGENT        =   3396  # Printer AgentIANA assigned this well_formed service name as a replacement for "printer_agent".
      PRINTER_AGENT        =   3396  # Printer Agent
      CLOANTO_LM           =   3397  # Cloanto License Manager
      MERCANTILE           =   3398  # Mercantile
      CSMS                 =   3399  # CSMS
      CSMS2                =   3400  # CSMS2
      FILECAST             =   3401  # filecast
      FXAENGINE_NET        =   3402  # FXa Engine Network Port
      NOKIA_ANN_CH1        =   3405  # Nokia Announcement ch 1
      NOKIA_ANN_CH2        =   3406  # Nokia Announcement ch 2
      LDAP_ADMIN           =   3407  # LDAP admin server port
      BESAPI               =   3408  # BES Api Port
      NETWORKLENS          =   3409  # NetworkLens Event Port
      NETWORKLENSS         =   3410  # NetworkLens SSL Event
      BIOLINK_AUTH         =   3411  # BioLink Authenteon server
      XMLBLASTER           =   3412  # xmlBlaster
      SVNET                =   3413  # SpecView Networking
      WIP_PORT             =   3414  # BroadCloud WIP Port
      BCINAMESERVICE       =   3415  # BCI Name Service
      COMMANDPORT          =   3416  # AirMobile IS Command Port
      CSVR                 =   3417  # ConServR file translation
      RNMAP                =   3418  # Remote nmap
      SOFTAUDIT            =   3419  # Isogon SoftAudit
      IFCP_PORT            =   3420  # iFCP User Port
      BMAP                 =   3421  # Bull Apprise portmapper
      RUSB_SYS_PORT        =   3422  # Remote USB System Port
      XTRM                 =   3423  # xTrade Reliable Messaging
      XTRMS                =   3424  # xTrade over TLS_SSL
      AGPS_PORT            =   3425  # AGPS Access Port
      ARKIVIO              =   3426  # Arkivio Storage Protocol
      WEBSPHERE_SNMP       =   3427  # WebSphere SNMP
      TWCSS                =   3428  # 2Wire CSS
      GCSP                 =   3429  # GCSP user port
      SSDISPATCH           =   3430  # Scott Studios Dispatch
      NDL_ALS              =   3431  # Active License Server Port
      OSDCP                =   3432  # Secure Device Protocol
      OPNET_SMP            =   3433  # OPNET Service Management Platform
      OPENCM               =   3434  # OpenCM Server
      PACOM                =   3435  # Pacom Security User Port
      GC_CONFIG            =   3436  # GuardControl Exchange Protocol
      AUTOCUEDS            =   3437  # Autocue Directory Service
      SPIRAL_ADMIN         =   3438  # Spiralcraft Admin
      HRI_PORT             =   3439  # HRI Interface Port
      ANS_CONSOLE          =   3440  # Net Steward Mgmt Console
      CONNECT_CLIENT       =   3441  # OC Connect Client
      CONNECT_SERVER       =   3442  # OC Connect Server
      OV_NNM_WEBSRV        =   3443  # OpenView Network Node Manager WEB Server
      DENALI_SERVER        =   3444  # Denali Server
      MONP                 =   3445  # Media Object Network
#      3COMFAXRPC           =   3446  # 3Com FAX RPC port
      DIRECTNET            =   3447  # DirectNet IM System
      DNC_PORT             =   3448  # Discovery and Net Config
      HOTU_CHAT            =   3449  # HotU Chat
      CASTORPROXY          =   3450  # CAStorProxy
      ASAM                 =   3451  # ASAM Services
      SABP_SIGNAL          =   3452  # SABP_Signalling Protocol
      PSCUPD               =   3453  # PSC Update
      MIRA                 =   3454  # Apple Remote Access Protocol
      PRSVP                =   3455  # RSVP Port
      VAT                  =   3456  # VAT default data
      VAT_CONTROL          =   3457  # VAT default control
      D3WINOSFI            =   3458  # D3WinOSFI
      INTEGRAL             =   3459  # TIP Integral
      EDM_MANAGER          =   3460  # EDM Manger
      EDM_STAGER           =   3461  # EDM Stager
      EDM_STD_NOTIFY       =   3462  # EDM STD Notify
      EDM_ADM_NOTIFY       =   3463  # EDM ADM Notify
      EDM_MGR_SYNC         =   3464  # EDM MGR Sync
      EDM_MGR_CNTRL        =   3465  # EDM MGR Cntrl
      WORKFLOW             =   3466  # WORKFLOW
      RCST                 =   3467  # RCST
      TTCMREMOTECTRL       =   3468  # TTCM Remote Controll
      PLURIBUS             =   3469  # Pluribus
      JT400                =   3470  # jt400
      JT400_SSL            =   3471  # jt400_ssl
      JAUGSREMOTEC_1       =   3472  # JAUGS N_G Remotec 1
      JAUGSREMOTEC_2       =   3473  # JAUGS N_G Remotec 2
      TTNTSPAUTO           =   3474  # TSP Automation
      GENISAR_PORT         =   3475  # Genisar Comm Port
      NPPMP                =   3476  # NVIDIA Mgmt Protocol
      ECOMM                =   3477  # eComm link port
      STUN                 =   3478  # Session Traversal Utilities for NAT (STUN) port
      TURN                 =   3478  # TURN over TCP
      STUN_BEHAVIOR        =   3478  # STUN Behavior Discovery over TCP
      TWRPC                =   3479  # 2Wire RPC
      PLETHORA             =   3480  # Secure Virtual Workspace
      CLEANERLIVERC        =   3481  # CleanerLive remote ctrl
      VULTURE              =   3482  # Vulture Monitoring System
      SLIM_DEVICES         =   3483  # Slim Devices Protocol
      GBS_STP              =   3484  # GBS SnapTalk Protocol
      CELATALK             =   3485  # CelaTalk
      IFSF_HB_PORT         =   3486  # IFSF Heartbeat Port
      LTCTCP               =   3487  # LISA TCP Transfer Channel
      FS_RH_SRV            =   3488  # FS Remote Host Server
      DTP_DIA              =   3489  # DTP_DIA
      COLUBRIS             =   3490  # Colubris Management Port
      SWR_PORT             =   3491  # SWR Port
      TVDUMTRAY_PORT       =   3492  # TVDUM Tray Port
      NUT                  =   3493  # Network UPS Tools
      IBM3494              =   3494  # IBM 3494
      SECLAYER_TCP         =   3495  # securitylayer over tcp
      SECLAYER_TLS         =   3496  # securitylayer over tls
      IPETHER232PORT       =   3497  # ipEther232Port
      DASHPAS_PORT         =   3498  # DASHPAS user port
      SCCIP_MEDIA          =   3499  # SccIP Media
      RTMP_PORT            =   3500  # RTMP Port
      ISOFT_P2P            =   3501  # iSoft_P2P
      AVINSTALLDISC        =   3502  # Avocent Install Discovery
      LSP_PING             =   3503  # MPLS LSP_echo Port
      IRONSTORM            =   3504  # IronStorm game server
      CCMCOMM              =   3505  # CCM communications port
      APC_3506             =   3506  # APC 3506
      NESH_BROKER          =   3507  # Nesh Broker Port
      INTERACTIONWEB       =   3508  # Interaction Web
      VT_SSL               =   3509  # Virtual Token SSL Port
      XSS_PORT             =   3510  # XSS Port
      WEBMAIL_2            =   3511  # WebMail_2
      AZTEC                =   3512  # Aztec Distribution Port
      ARCPD                =   3513  # Adaptec Remote Protocol
      MUST_P2P             =   3514  # MUST Peer to Peer
      MUST_BACKPLANE       =   3515  # MUST Backplane
      SMARTCARD_PORT       =   3516  # Smartcard Port
#      802_11_IAPP          =   3517  # IEEE 802.11 WLANs WG IAPP
      ARTIFACT_MSG         =   3518  # Artifact Message Server
      NVMSGD               =   3519  # Netvion Messenger Port
      GALILEOLOG           =   3520  # Netvion Galileo Log Port
      MC3SS                =   3521  # Telequip Labs MC3SS
      NSSOCKETPORT         =   3522  # DO over NSSocketPort
      ODEUMSERVLINK        =   3523  # Odeum Serverlink
      ECMPORT              =   3524  # ECM Server port
      EISPORT              =   3525  # EIS Server port
      STARQUIZ_PORT        =   3526  # starQuiz Port
      BESERVER_MSG_Q       =   3527  # VERITAS Backup Exec Server
      JBOSS_IIOP           =   3528  # JBoss IIOP
      JBOSS_IIOP_SSL       =   3529  # JBoss IIOP_SSL
      GF                   =   3530  # Grid Friendly
      JOLTID               =   3531  # Joltid
      RAVEN_RMP            =   3532  # Raven Remote Management Control
      RAVEN_RDP            =   3533  # Raven Remote Management Data
      URLD_PORT            =   3534  # URL Daemon Port
      MS_LA                =   3535  # MS_LA
      SNAC                 =   3536  # SNAC
      NI_VISA_REMOTE       =   3537  # Remote NI_VISA port
      IBM_DIRADM           =   3538  # IBM Directory Server
      IBM_DIRADM_SSL       =   3539  # IBM Directory Server SSL
      PNRP_PORT            =   3540  # PNRP User Port
      VOISPEED_PORT        =   3541  # VoiSpeed Port
      HACL_MONITOR         =   3542  # HA cluster monitor
      QFTEST_LOOKUP        =   3543  # qftest Lookup Port
      TEREDO               =   3544  # Teredo Port
      CAMAC                =   3545  # CAMAC equipment
      SYMANTEC_SIM         =   3547  # Symantec SIM
      INTERWORLD           =   3548  # Interworld
      TELLUMAT_NMS         =   3549  # Tellumat MDR NMS
      SSMPP                =   3550  # Secure SMPP
      APCUPSD              =   3551  # Apcupsd Information Port
      TASERVER             =   3552  # TeamAgenda Server Port
      RBR_DISCOVERY        =   3553  # Red Box Recorder ADP
      QUESTNOTIFY          =   3554  # Quest Notification Server
      RAZOR                =   3555  # Vipul's Razor
      SKY_TRANSPORT        =   3556  # Sky Transport Protocol
      PERSONALOS_001       =   3557  # PersonalOS Comm Port
      MCP_PORT             =   3558  # MCP user port
      CCTV_PORT            =   3559  # CCTV control port
      INISERVE_PORT        =   3560  # INIServe port
      BMC_ONEKEY           =   3561  # BMC_OneKey
      SDBPROXY             =   3562  # SDBProxy
      WATCOMDEBUG          =   3563  # Watcom Debug
      ESIMPORT             =   3564  # Electromed SIM port
      M2PA                 =   3565  # M2PA
      QUEST_DATA_HUB       =   3566  # Quest Data Hub
      ENC_EPS              =   3567  # EMIT protocol stack
      ENC_TUNNEL_SEC       =   3568  # EMIT secure tunnel
      MBG_CTRL             =   3569  # Meinberg Control Service
      MCCWEBSVR_PORT       =   3570  # MCC Web Server Port
      MEGARDSVR_PORT       =   3571  # MegaRAID Server Port
      MEGAREGSVRPORT       =   3572  # Registration Server Port
      TAG_UPS_1            =   3573  # Advantage Group UPS Suite
      DMAF_SERVER          =   3574  # DMAF Server
      CCM_PORT             =   3575  # Coalsere CCM Port
      CMC_PORT             =   3576  # Coalsere CMC Port
      CONFIG_PORT          =   3577  # Configuration Port
      DATA_PORT            =   3578  # Data Port
      TTAT3LB              =   3579  # Tarantella Load Balancing
      NATI_SVRLOC          =   3580  # NATI_ServiceLocator
      KFXACLICENSING       =   3581  # Ascent Capture Licensing
      PRESS                =   3582  # PEG PRESS Server
      CANEX_WATCH          =   3583  # CANEX Watch System
      U_DBAP               =   3584  # U_DBase Access Protocol
      EMPRISE_LLS          =   3585  # Emprise License Server
      EMPRISE_LSC          =   3586  # License Server Console
      P2PGROUP             =   3587  # Peer to Peer Grouping
      SENTINEL             =   3588  # Sentinel Server
      ISOMAIR              =   3589  # isomair
      WV_CSP_SMS           =   3590  # WV CSP SMS Binding
      GTRACK_SERVER        =   3591  # LOCANIS G_TRACK Server
      GTRACK_NE            =   3592  # LOCANIS G_TRACK NE Port
      BPMD                 =   3593  # BP Model Debugger
      MEDIASPACE           =   3594  # MediaSpace
      SHAREAPP             =   3595  # ShareApp
      IW_MMOGAME           =   3596  # Illusion Wireless MMOG
      A14                  =   3597  # A14 (AN_to_SC_MM)
      A15                  =   3598  # A15 (AN_to_AN)
      QUASAR_SERVER        =   3599  # Quasar Accounting Server
      TRAP_DAEMON          =   3600  # text relay_answer
      VISINET_GUI          =   3601  # Visinet Gui
      INFINISWITCHCL       =   3602  # InfiniSwitch Mgr Client
      INT_RCV_CNTRL        =   3603  # Integrated Rcvr Control
      BMC_JMX_PORT         =   3604  # BMC JMX Port
      COMCAM_IO            =   3605  # ComCam IO Port
      SPLITLOCK            =   3606  # Splitlock Server
      PRECISE_I3           =   3607  # Precise I3
      TRENDCHIP_DCP        =   3608  # Trendchip control protocol
      CPDI_PIDAS_CM        =   3609  # CPDI PIDAS Connection Mon
      ECHONET              =   3610  # ECHONET
      SIX_DEGREES          =   3611  # Six Degrees Port
      HP_DATAPROTECT       =   3612  # HP Data Protector
      ALARIS_DISC          =   3613  # Alaris Device Discovery
      SIGMA_PORT           =   3614  # Satchwell Sigma
      START_NETWORK        =   3615  # Start Messaging Network
      CD3O_PROTOCOL        =   3616  # cd3o Control Protocol
      SHARP_SERVER         =   3617  # ATI SHARP Logic Engine
      AAIRNET_1            =   3618  # AAIR_Network 1
      AAIRNET_2            =   3619  # AAIR_Network 2
      EP_PCP               =   3620  # EPSON Projector Control Port
      EP_NSP               =   3621  # EPSON Network Screen Port
      FF_LR_PORT           =   3622  # FF LAN Redundancy Port
      HAIPE_DISCOVER       =   3623  # HAIPIS Dynamic Discovery
      DIST_UPGRADE         =   3624  # Distributed Upgrade Port
      VOLLEY               =   3625  # Volley
      BVCDAEMON_PORT       =   3626  # bvControl Daemon
      JAMSERVERPORT        =   3627  # Jam Server Port
      EPT_MACHINE          =   3628  # EPT Machine Interface
      ESCVPNET             =   3629  # ESC_VP.net
      CS_REMOTE_DB         =   3630  # C&S Remote Database Port
      CS_SERVICES          =   3631  # C&S Web Services Port
      DISTCC               =   3632  # distributed compiler
      WACP                 =   3633  # Wyrnix AIS port
      HLIBMGR              =   3634  # hNTSP Library Manager
      SDO                  =   3635  # Simple Distributed Objects
      SERVISTAITSM         =   3636  # SerVistaITSM
      SCSERVP              =   3637  # Customer Service Port
      EHP_BACKUP           =   3638  # EHP Backup Protocol
      XAP_HA               =   3639  # Extensible Automation
      NETPLAY_PORT1        =   3640  # Netplay Port 1
      NETPLAY_PORT2        =   3641  # Netplay Port 2
      JUXML_PORT           =   3642  # Juxml Replication port
      AUDIOJUGGLER         =   3643  # AudioJuggler
      SSOWATCH             =   3644  # ssowatch
      CYC                  =   3645  # Cyc
      XSS_SRV_PORT         =   3646  # XSS Server Port
      SPLITLOCK_GW         =   3647  # Splitlock Gateway
      FJCP                 =   3648  # Fujitsu Cooperation Port
      NMMP                 =   3649  # Nishioka Miyuki Msg Protocol
      PRISMIQ_PLUGIN       =   3650  # PRISMIQ VOD plug_in
      XRPC_REGISTRY        =   3651  # XRPC Registry
      VXCRNBUPORT          =   3652  # VxCR NBU Default Port
      TSP                  =   3653  # Tunnel Setup Protocol
      VAPRTM               =   3654  # VAP RealTime Messenger
      ABATEMGR             =   3655  # ActiveBatch Exec Agent
      ABATJSS              =   3656  # ActiveBatch Job Scheduler
      IMMEDIANET_BCN       =   3657  # ImmediaNet Beacon
      PS_AMS               =   3658  # PlayStation AMS (Secure)
      APPLE_SASL           =   3659  # Apple SASL
      CAN_NDS_SSL          =   3660  # IBM Tivoli Directory Service using SSL
      CAN_FERRET_SSL       =   3661  # IBM Tivoli Directory Service using SSL
      PSERVER              =   3662  # pserver
      DTP                  =   3663  # DIRECWAY Tunnel Protocol
      UPS_ENGINE           =   3664  # UPS Engine Port
      ENT_ENGINE           =   3665  # Enterprise Engine Port
      ESERVER_PAP          =   3666  # IBM eServer PAP
      INFOEXCH             =   3667  # IBM Information Exchange
      DELL_RM_PORT         =   3668  # Dell Remote Management
      CASANSWMGMT          =   3669  # CA SAN Switch Management
      SMILE                =   3670  # SMILE TCP_UDP Interface
      EFCP                 =   3671  # e Field Control (EIBnet)
      LISPWORKS_ORB        =   3672  # LispWorks ORB
      MEDIAVAULT_GUI       =   3673  # Openview Media Vault GUI
      WININSTALL_IPC       =   3674  # WinINSTALL IPC Port
      CALLTRAX             =   3675  # CallTrax Data Port
      VA_PACBASE           =   3676  # VisualAge Pacbase server
      ROVERLOG             =   3677  # RoverLog IPC
      IPR_DGLT             =   3678  # DataGuardianLT
#      ESCALE (NEWTON Dock) =   3679  # Newton Dock
      NPDS_TRACKER         =   3680  # NPDS Tracker
      BTS_X73              =   3681  # BTS X73 Port
      CAS_MAPI             =   3682  # EMC SmartPackets_MAPI
      BMC_EA               =   3683  # BMC EDV_EA
      FAXSTFX_PORT         =   3684  # FAXstfX
      DSX_AGENT            =   3685  # DS Expert Agent
      TNMPV2               =   3686  # Trivial Network Management
      SIMPLE_PUSH          =   3687  # simple_push
      SIMPLE_PUSH_S        =   3688  # simple_push Secure
      DAAP                 =   3689  # Digital Audio Access Protocol (iTunes)
      SVN                  =   3690  # Subversion
      MAGAYA_NETWORK       =   3691  # Magaya Network Port
      INTELSYNC            =   3692  # Brimstone IntelSync
      BMC_DATA_COLL        =   3695  # BMC Data Collection
      TELNETCPCD           =   3696  # Telnet Com Port Control
      NW_LICENSE           =   3697  # NavisWorks License System
      SAGECTLPANEL         =   3698  # SAGECTLPANEL
      KPN_ICW              =   3699  # Internet Call Waiting
      LRS_PAGING           =   3700  # LRS NetPage
      NETCELERA            =   3701  # NetCelera
      WS_DISCOVERY         =   3702  # Web Service Discovery
      ADOBESERVER_3        =   3703  # Adobe Server 3
      ADOBESERVER_4        =   3704  # Adobe Server 4
      ADOBESERVER_5        =   3705  # Adobe Server 5
      RT_EVENT             =   3706  # Real_Time Event Port
      RT_EVENT_S           =   3707  # Real_Time Event Secure Port
      SUN_AS_IIOPS         =   3708  # Sun App Svr _ Naming
      CA_IDMS              =   3709  # CA_IDMS Server
      PORTGATE_AUTH        =   3710  # PortGate Authentication
      EDB_SERVER2          =   3711  # EBD Server 2
      SENTINEL_ENT         =   3712  # Sentinel Enterprise
      TFTPS                =   3713  # TFTP over TLS
      DELOS_DMS            =   3714  # DELOS Direct Messaging
      ANOTO_RENDEZV        =   3715  # Anoto Rendezvous Port
      WV_CSP_SMS_CIR       =   3716  # WV CSP SMS CIR Channel
      WV_CSP_UDP_CIR       =   3717  # WV CSP UDP_IP CIR Channel
      OPUS_SERVICES        =   3718  # OPUS Server Port
      ITELSERVERPORT       =   3719  # iTel Server Port
      UFASTRO_INSTR        =   3720  # UF Astro. Instr. Services
      XSYNC                =   3721  # Xsync
      XSERVERAID           =   3722  # Xserve RAID
      SYCHROND             =   3723  # Sychron Service Daemon
      BLIZWOW              =   3724  # World of Warcraft
      NA_ER_TIP            =   3725  # Netia NA_ER Port
      ARRAY_MANAGER        =   3726  # Xyratex Array Manager
      E_MDU                =   3727  # Ericsson Mobile Data Unit
      E_WOA                =   3728  # Ericsson Web on Air
      FKSP_AUDIT           =   3729  # Fireking Audit Port
      CLIENT_CTRL          =   3730  # Client Control
      SMAP                 =   3731  # Service Manager
      M_WNN                =   3732  # Mobile Wnn
      MULTIP_MSG           =   3733  # Multipuesto Msg Port
      SYNEL_DATA           =   3734  # Synel Data Collection Port
      PWDIS                =   3735  # Password Distribution
      RS_RMI               =   3736  # RealSpace RMI
      XPANEL               =   3737  # XPanel Daemon
      VERSATALK            =   3738  # versaTalk Server Port
      LAUNCHBIRD_LM        =   3739  # Launchbird LicenseManager
      HEARTBEAT            =   3740  # Heartbeat Protocol
      WYSDMA               =   3741  # WysDM Agent
      CST_PORT             =   3742  # CST _ Configuration & Service Tracker
      IPCS_COMMAND         =   3743  # IP Control Systems Ltd.
      SASG                 =   3744  # SASG
      GW_CALL_PORT         =   3745  # GWRTC Call Port
      LINKTEST             =   3746  # LXPRO.COM LinkTest
      LINKTEST_S           =   3747  # LXPRO.COM LinkTest SSL
      WEBDATA              =   3748  # webData
      CIMTRAK              =   3749  # CimTrak
      CBOS_IP_PORT         =   3750  # CBOS_IP ncapsalation port
      GPRS_CUBE            =   3751  # CommLinx GPRS Cube
      VIPREMOTEAGENT       =   3752  # Vigil_IP RemoteAgent
      NATTYSERVER          =   3753  # NattyServer Port
      TIMESTENBROKER       =   3754  # TimesTen Broker Port
      SAS_REMOTE_HLP       =   3755  # SAS Remote Help Server
      CANON_CAPT           =   3756  # Canon CAPT Port
      GRF_PORT             =   3757  # GRF Server Port
      APW_REGISTRY         =   3758  # apw RMI registry
      EXAPT_LMGR           =   3759  # Exapt License Manager
      ADTEMPUSCLIENT       =   3760  # adTempus Client
      GSAKMP               =   3761  # gsakmp port
      GBS_SMP              =   3762  # GBS SnapMail Protocol
      XO_WAVE              =   3763  # XO Wave Control Port
      MNI_PROT_ROUT        =   3764  # MNI Protected Routing
      RTRACEROUTE          =   3765  # Remote Traceroute
      SITEWATCH_S          =   3766  # SSL e_watch sitewatch server
      LISTMGR_PORT         =   3767  # ListMGR Port
      RBLCHECKD            =   3768  # rblcheckd server daemon
      HAIPE_OTNK           =   3769  # HAIPE Network Keying
      CINDYCOLLAB          =   3770  # Cinderella Collaboration
      PAGING_PORT          =   3771  # RTP Paging Port
      CTP                  =   3772  # Chantry Tunnel Protocol
      CTDHERCULES          =   3773  # ctdhercules
      ZICOM                =   3774  # ZICOM
      ISPMMGR              =   3775  # ISPM Manager Port
      DVCPROV_PORT         =   3776  # Device Provisioning Port
      JIBE_EB              =   3777  # Jibe EdgeBurst
      C_H_IT_PORT          =   3778  # Cutler_Hammer IT Port
      COGNIMA              =   3779  # Cognima Replication
      NNP                  =   3780  # Nuzzler Network Protocol
      ABCVOICE_PORT        =   3781  # ABCvoice server port
      ISO_TP0S             =   3782  # Secure ISO TP0 port
      BIM_PEM              =   3783  # Impact Mgr._PEM Gateway
      BFD_CONTROL          =   3784  # BFD Control Protocol
      BFD_ECHO             =   3785  # BFD Echo Protocol
      UPSTRIGGERVSW        =   3786  # VSW Upstrigger port
      FINTRX               =   3787  # Fintrx
      ISRP_PORT            =   3788  # SPACEWAY Routing port
      REMOTEDEPLOY         =   3789  # RemoteDeploy Administration Port
      QUICKBOOKSRDS        =   3790  # QuickBooks RDS
      TVNETWORKVIDEO       =   3791  # TV NetworkVideo Data port
      SITEWATCH            =   3792  # e_Watch Corporation SiteWatch
      DCSOFTWARE           =   3793  # DataCore Software
      JAUS                 =   3794  # JAUS Robots
      MYBLAST              =   3795  # myBLAST Mekentosj port
      SPW_DIALER           =   3796  # Spaceway Dialer
      IDPS                 =   3797  # idps
      MINILOCK             =   3798  # Minilock
      RADIUS_DYNAUTH       =   3799  # RADIUS Dynamic Authorization
      PWGPSI               =   3800  # Print Services Interface
      IBM_MGR              =   3801  # ibm manager service
      VHD                  =   3802  # VHD
      SONIQSYNC            =   3803  # SoniqSync
      IQNET_PORT           =   3804  # Harman IQNet Port
      TCPDATASERVER        =   3805  # ThorGuard Server Port
      WSMLB                =   3806  # Remote System Manager
      SPUGNA               =   3807  # SpuGNA Communication Port
      SUN_AS_IIOPS_CA      =   3808  # Sun App Svr_IIOPClntAuth
      APOCD                =   3809  # Java Desktop System Configuration Agent
      WLANAUTH             =   3810  # WLAN AS server
      AMP                  =   3811  # AMP
      NETO_WOL_SERVER      =   3812  # netO WOL Server
      RAP_IP               =   3813  # Rhapsody Interface Protocol
      NETO_DCS             =   3814  # netO DCS
      LANSURVEYORXML       =   3815  # LANsurveyor XML
      SUNLPS_HTTP          =   3816  # Sun Local Patch Server
      TAPEWARE             =   3817  # Yosemite Tech Tapeware
      CRINIS_HB            =   3818  # Crinis Heartbeat
      EPL_SLP              =   3819  # EPL Sequ Layer Protocol
      SCP                  =   3820  # Siemens AuD SCP
      PMCP                 =   3821  # ATSC PMCP Standard
      ACP_DISCOVERY        =   3822  # Compute Pool Discovery
      ACP_CONDUIT          =   3823  # Compute Pool Conduit
      ACP_POLICY           =   3824  # Compute Pool Policy
      FFSERVER             =   3825  # Antera FlowFusion Process Simulation
      WARMUX               =   3826  # WarMUX game server
      NETMPI               =   3827  # Netadmin Systems MPI service
      NETEH                =   3828  # Netadmin Systems Event Handler
      NETEH_EXT            =   3829  # Netadmin Systems Event Handler External
      CERNSYSMGMTAGT       =   3830  # Cerner System Management Agent
      DVAPPS               =   3831  # Docsvault Application Service
      XXNETSERVER          =   3832  # xxNETserver
      AIPN_AUTH            =   3833  # AIPN LS Authentication
      SPECTARDATA          =   3834  # Spectar Data Stream Service
      SPECTARDB            =   3835  # Spectar Database Rights Service
      MARKEM_DCP           =   3836  # MARKEM NEXTGEN DCP
      MKM_DISCOVERY        =   3837  # MARKEM Auto_Discovery
      SOS                  =   3838  # Scito Object Server
      AMX_RMS              =   3839  # AMX Resource Management Suite
      FLIRTMITMIR          =   3840  # www.FlirtMitMir.de
      SHIPRUSH_DB_SVR      =   3841  # ShipRush Database Server
      NHCI                 =   3842  # NHCI status port
      QUEST_AGENT          =   3843  # Quest Common Agent
      RNM                  =   3844  # RNM
      V_ONE_SPP            =   3845  # V_ONE Single Port Proxy
      AN_PCP               =   3846  # Astare Network PCP
      MSFW_CONTROL         =   3847  # MS Firewall Control
      ITEM                 =   3848  # IT Environmental Monitor
      SPW_DNSPRELOAD       =   3849  # SPACEWAY DNS Preload
      QTMS_BOOTSTRAP       =   3850  # QTMS Bootstrap Protocol
      SPECTRAPORT          =   3851  # SpectraTalk Port
      SSE_APP_CONFIG       =   3852  # SSE App Configuration
      SSCAN                =   3853  # SONY scanning protocol
      STRYKER_COM          =   3854  # Stryker Comm Port
      OPENTRAC             =   3855  # OpenTRAC
      INFORMER             =   3856  # INFORMER
      TRAP_PORT            =   3857  # Trap Port
      TRAP_PORT_MOM        =   3858  # Trap Port MOM
      NAV_PORT             =   3859  # Navini Port
      SASP                 =   3860  # Server_Application State Protocol (SASP)
      WINSHADOW_HD         =   3861  # winShadow Host Discovery
      GIGA_POCKET          =   3862  # GIGA_POCKET
      ASAP_TCP             =   3863  # asap tcp port
      ASAP_TCP_TLS         =   3864  # asap_tls tcp port
      XPL                  =   3865  # xpl automation protocol
      DZDAEMON             =   3866  # Sun SDViz DZDAEMON Port
      DZOGLSERVER          =   3867  # Sun SDViz DZOGLSERVER Port
      DIAMETER             =   3868  # DIAMETER
      OVSAM_MGMT           =   3869  # hp OVSAM MgmtServer Disco
      OVSAM_D_AGENT        =   3870  # hp OVSAM HostAgent Disco
      AVOCENT_ADSAP        =   3871  # Avocent DS Authorization
      OEM_AGENT            =   3872  # OEM Agent
      FAGORDNC             =   3873  # fagordnc
      SIXXSCONFIG          =   3874  # SixXS Configuration
      PNBSCADA             =   3875  # PNBSCADA
      DL_AGENT             =   3876  # DirectoryLockdown AgentIANA assigned this well_formed service name as a replacement for "dl_agent".
      DL_AGENT             =   3876  # DirectoryLockdown Agent
      XMPCR_INTERFACE      =   3877  # XMPCR Interface Port
      FOTOGCAD             =   3878  # FotoG CAD interface
      APPSS_LM             =   3879  # appss license manager
      IGRS                 =   3880  # IGRS
      IDAC                 =   3881  # Data Acquisition and Control
      MSDTS1               =   3882  # DTS Service Port
      VRPN                 =   3883  # VR Peripheral Network
      SOFTRACK_METER       =   3884  # SofTrack Metering
      TOPFLOW_SSL          =   3885  # TopFlow SSL
      NEI_MANAGEMENT       =   3886  # NEI management port
      CIPHIRE_DATA         =   3887  # Ciphire Data Transport
      CIPHIRE_SERV         =   3888  # Ciphire Services
      DANDV_TESTER         =   3889  # D and V Tester Control Port
      NDSCONNECT           =   3890  # Niche Data Server Connect
      RTC_PM_PORT          =   3891  # Oracle RTC_PM port
      PCC_IMAGE_PORT       =   3892  # PCC_image_port
      CGI_STARAPI          =   3893  # CGI StarAPI Server
      SYAM_AGENT           =   3894  # SyAM Agent Port
      SYAM_SMC             =   3895  # SyAm SMC Service Port
      SDO_TLS              =   3896  # Simple Distributed Objects over TLS
      SDO_SSH              =   3897  # Simple Distributed Objects over SSH
      SENIP                =   3898  # IAS, Inc. SmartEye NET Internet Protocol
      ITV_CONTROL          =   3899  # ITV Port
      UDT_OS               =   3900  # Unidata UDT OSIANA assigned this well_formed service name as a replacement for "udt_os".
      UDT_OS               =   3900  # Unidata UDT OS
      NIMSH                =   3901  # NIM Service Handler
      NIMAUX               =   3902  # NIMsh Auxiliary Port
      CHARSETMGR           =   3903  # CharsetMGR
      OMNILINK_PORT        =   3904  # Arnet Omnilink Port
      MUPDATE              =   3905  # Mailbox Update (MUPDATE) protocol
      TOPOVISTA_DATA       =   3906  # TopoVista elevation data
      IMOGUIA_PORT         =   3907  # Imoguia Port
      HPPRONETMAN          =   3908  # HP Procurve NetManagement
      SURFCONTROLCPA       =   3909  # SurfControl CPA
      PRNREQUEST           =   3910  # Printer Request Port
      PRNSTATUS            =   3911  # Printer Status Port
      GBMT_STARS           =   3912  # Global Maintech Stars
      LISTCRT_PORT         =   3913  # ListCREATOR Port
      LISTCRT_PORT_2       =   3914  # ListCREATOR Port 2
      AGCAT                =   3915  # Auto_Graphics Cataloging
      WYSDMC               =   3916  # WysDM Controller
      AFTMUX               =   3917  # AFT multiplex port
      PKTCABLEMMCOPS       =   3918  # PacketCableMultimediaCOPS
      HYPERIP              =   3919  # HyperIP
      EXASOFTPORT1         =   3920  # Exasoft IP Port
      HERODOTUS_NET        =   3921  # Herodotus Net
      SOR_UPDATE           =   3922  # Soronti Update Port
      SYMB_SB_PORT         =   3923  # Symbian Service Broker
      MPL_GPRS_PORT        =   3924  # MPL_GPRS_PORT
      ZMP                  =   3925  # Zoran Media Port
      WINPORT              =   3926  # WINPort
      NATDATASERVICE       =   3927  # ScsTsr
      NETBOOT_PXE          =   3928  # PXE NetBoot Manager
      SMAUTH_PORT          =   3929  # AMS Port
      SYAM_WEBSERVER       =   3930  # Syam Web Server Port
      MSR_PLUGIN_PORT      =   3931  # MSR Plugin Port
      DYN_SITE             =   3932  # Dynamic Site System
      PLBSERVE_PORT        =   3933  # PL_B App Server User Port
      SUNFM_PORT           =   3934  # PL_B File Manager Port
      SDP_PORTMAPPER       =   3935  # SDP Port Mapper Protocol
      MAILPROX             =   3936  # Mailprox
      DVBSERVDSC           =   3937  # DVB Service Discovery
      DBCONTROL_AGENT      =   3938  # Oracle dbControl Agent poIANA assigned this well_formed service name as a replacement for "dbcontrol_agent".
      DBCONTROL_AGENT      =   3938  # Oracle dbControl Agent po
      AAMP                 =   3939  # Anti_virus Application Management Port
      XECP_NODE            =   3940  # XeCP Node Service
      HOMEPORTAL_WEB       =   3941  # Home Portal Web Server
      SRDP                 =   3942  # satellite distribution
      TIG                  =   3943  # TetraNode Ip Gateway
      SOPS                 =   3944  # S_Ops Management
      EMCADS               =   3945  # EMCADS Server Port
      BACKUPEDGE           =   3946  # BackupEDGE Server
      CCP                  =   3947  # Connect and Control Protocol for Consumer, Commercial, and Industrial Electronic Devices
      APDAP                =   3948  # Anton Paar Device Administration Protocol
      DRIP                 =   3949  # Dynamic Routing Information Protocol
      NAMEMUNGE            =   3950  # Name Munging
      PWGIPPFAX            =   3951  # PWG IPP Facsimile
      I3_SESSIONMGR        =   3952  # I3 Session Manager
      XMLINK_CONNECT       =   3953  # Eydeas XMLink Connect
      ADREP                =   3954  # AD Replication RPC
      P2PCOMMUNITY         =   3955  # p2pCommunity
      GVCP                 =   3956  # GigE Vision Control
      MQE_BROKER           =   3957  # MQEnterprise Broker
      MQE_AGENT            =   3958  # MQEnterprise Agent
      TREEHOPPER           =   3959  # Tree Hopper Networking
      BESS                 =   3960  # Bess Peer Assessment
      PROAXESS             =   3961  # ProAxess Server
      SBI_AGENT            =   3962  # SBI Agent Protocol
      THRP                 =   3963  # Teran Hybrid Routing Protocol
      SASGGPRS             =   3964  # SASG GPRS
      ATI_IP_TO_NCPE       =   3965  # Avanti IP to NCPE API
      BFLCKMGR             =   3966  # BuildForge Lock Manager
      PPSMS                =   3967  # PPS Message Service
      IANYWHERE_DBNS       =   3968  # iAnywhere DBNS
      LANDMARKS            =   3969  # Landmark Messages
      LANREVAGENT          =   3970  # LANrev Agent
      LANREVSERVER         =   3971  # LANrev Server
      ICONP                =   3972  # ict_control Protocol
      PROGISTICS           =   3973  # ConnectShip Progistics
      CITYSEARCH           =   3974  # Remote Applicant Tracking Service
      AIRSHOT              =   3975  # Air Shot
      OPSWAGENT            =   3976  # Opsware Agent
      OPSWMANAGER          =   3977  # Opsware Manager
      SECURE_CFG_SVR       =   3978  # Secured Configuration Server
      SMWAN                =   3979  # Smith Micro Wide Area Network Service
      ACMS                 =   3980  # Aircraft Cabin Management System
      STARFISH             =   3981  # Starfish System Admin
      EIS                  =   3982  # ESRI Image Server
      EISP                 =   3983  # ESRI Image Service
      MAPPER_NODEMGR       =   3984  # MAPPER network node manager
      MAPPER_MAPETHD       =   3985  # MAPPER TCP_IP server
      MAPPER_WS_ETHD       =   3986  # MAPPER workstation serverIANA assigned this well_formed service name as a replacement for "mapper_ws_ethd".
      MAPPER_WS_ETHD       =   3986  # MAPPER workstation server
      CENTERLINE           =   3987  # Centerline
      DCS_CONFIG           =   3988  # DCS Configuration Port
      BV_QUERYENGINE       =   3989  # BindView_Query Engine
      BV_IS                =   3990  # BindView_IS
      BV_SMCSRV            =   3991  # BindView_SMCServer
      BV_DS                =   3992  # BindView_DirectoryServer
      BV_AGENT             =   3993  # BindView_Agent
      ISS_MGMT_SSL         =   3995  # ISS Management Svcs SSL
      ABCSOFTWARE          =   3996  # abcsoftware_01
      AGENTSEASE_DB        =   3997  # aes_db
      DNX                  =   3998  # Distributed Nagios Executor Service
      NVCNET               =   3999  # Norman distributes scanning service
      TERABASE             =   4000  # Terabase
      NEWOAK               =   4001  # NewOak
      PXC_SPVR_FT          =   4002  # pxc_spvr_ft
      PXC_SPLR_FT          =   4003  # pxc_splr_ft
      PXC_ROID             =   4004  # pxc_roid
      PXC_PIN              =   4005  # pxc_pin
      PXC_SPVR             =   4006  # pxc_spvr
      PXC_SPLR             =   4007  # pxc_splr
      NETCHEQUE            =   4008  # NetCheque accounting
      CHIMERA_HWM          =   4009  # Chimera HWM
      SAMSUNG_UNIDEX       =   4010  # Samsung Unidex
      ALTSERVICEBOOT       =   4011  # Alternate Service Boot
      PDA_GATE             =   4012  # PDA Gate
      ACL_MANAGER          =   4013  # ACL Manager
      TAICLOCK             =   4014  # TAICLOCK
      TALARIAN_MCAST1      =   4015  # Talarian Mcast
      TALARIAN_MCAST2      =   4016  # Talarian Mcast
      TALARIAN_MCAST3      =   4017  # Talarian Mcast
      TALARIAN_MCAST4      =   4018  # Talarian Mcast
      TALARIAN_MCAST5      =   4019  # Talarian Mcast
      TRAP                 =   4020  # TRAP Port
      NEXUS_PORTAL         =   4021  # Nexus Portal
      DNOX                 =   4022  # DNOX
      ESNM_ZONING          =   4023  # ESNM Zoning Port
      TNP1_PORT            =   4024  # TNP1 User Port
      PARTIMAGE            =   4025  # Partition Image Port
      AS_DEBUG             =   4026  # Graphical Debug Server
      BXP                  =   4027  # bitxpress
      DTSERVER_PORT        =   4028  # DTServer Port
      IP_QSIG              =   4029  # IP Q signaling protocol
      JDMN_PORT            =   4030  # Accell_JSP Daemon Port
      SUUCP                =   4031  # UUCP over SSL
      VRTS_AUTH_PORT       =   4032  # VERITAS Authorization Service
      SANAVIGATOR          =   4033  # SANavigator Peer Port
      UBXD                 =   4034  # Ubiquinox Daemon
      WAP_PUSH_HTTP        =   4035  # WAP Push OTA_HTTP port
      WAP_PUSH_HTTPS       =   4036  # WAP Push OTA_HTTP secure
      RAVEHD               =   4037  # RaveHD network control
      FAZZT_PTP            =   4038  # Fazzt Point_To_Point
      FAZZT_ADMIN          =   4039  # Fazzt Administration
      YO_MAIN              =   4040  # Yo.net main service
      HOUSTON              =   4041  # Rocketeer_Houston
      LDXP                 =   4042  # LDXP
      NIRP                 =   4043  # Neighbour Identity Resolution
      LTP                  =   4044  # Location Tracking Protocol
      NPP                  =   4045  # Network Paging Protocol Known UNAUTHORIZED USE: Port 4045
      ACP_PROTO            =   4046  # Accounting Protocol
      CTP_STATE            =   4047  # Context Transfer Protocol
      WAFS                 =   4049  # Wide Area File Services
      CISCO_WAFS           =   4050  # Wide Area File Services
      CPPDP                =   4051  # Cisco Peer to Peer Distribution Protocol
      INTERACT             =   4052  # VoiceConnect Interact
      CCU_COMM_1           =   4053  # CosmoCall Universe Communications Port 1
      CCU_COMM_2           =   4054  # CosmoCall Universe Communications Port 2
      CCU_COMM_3           =   4055  # CosmoCall Universe Communications Port 3
      LMS                  =   4056  # Location Message Service
      WFM                  =   4057  # Servigistics WFM server
      KINGFISHER           =   4058  # Kingfisher protocol
      DLMS_COSEM           =   4059  # DLMS_COSEM
      DSMETER_IATC         =   4060  # DSMETER Inter_Agent Transfer ChannelIANA assigned this well_formed service name as a replacement for "dsmeter_iatc".
      DSMETER_IATC         =   4060  # DSMETER Inter_Agent Transfer Channel
      ICE_LOCATION         =   4061  # Ice Location Service (TCP)
      ICE_SLOCATION        =   4062  # Ice Location Service (SSL)
      ICE_ROUTER           =   4063  # Ice Firewall Traversal Service (TCP)
      ICE_SROUTER          =   4064  # Ice Firewall Traversal Service (SSL)
      AVANTI_CDP           =   4065  # Avanti Common DataIANA assigned this well_formed service name as a replacement for "avanti_cdp".
      AVANTI_CDP           =   4065  # Avanti Common Data
      PMAS                 =   4066  # Performance Measurement and Analysis
      IDP                  =   4067  # Information Distribution Protocol
      IPFLTBCST            =   4068  # IP Fleet Broadcast
      MINGER               =   4069  # Minger Email Address Validation Service
      TRIPE                =   4070  # Trivial IP Encryption (TrIPE)
      AIBKUP               =   4071  # Automatically Incremental Backup
      ZIETO_SOCK           =   4072  # Zieto Socket Communications
      IRAPP                =   4073  # iRAPP Server Protocol
      CEQUINT_CITYID       =   4074  # Cequint City ID UI trigger
      PERIMLAN             =   4075  # ISC Alarm Message Service
      SERAPH               =   4076  # Seraph DCS
      CSSP                 =   4078  # Coordinated Security Service Protocol
      SANTOOLS             =   4079  # SANtools Diagnostic Server
      LORICA_IN            =   4080  # Lorica inside facing
      LORICA_IN_SEC        =   4081  # Lorica inside facing (SSL)
      LORICA_OUT           =   4082  # Lorica outside facing
      LORICA_OUT_SEC       =   4083  # Lorica outside facing (SSL)
      EZMESSAGESRV         =   4085  # EZNews Newsroom Message Service
      APPLUSSERVICE        =   4087  # APplus Service
      NPSP                 =   4088  # Noah Printing Service Protocol
      OPENCORE             =   4089  # OpenCORE Remote Control Service
      OMASGPORT            =   4090  # OMA BCAST Service Guide
      EWINSTALLER          =   4091  # EminentWare Installer
      EWDGS                =   4092  # EminentWare DGS
      PVXPLUSCS            =   4093  # Pvx Plus CS Host
      SYSRQD               =   4094  # sysrq daemon
      XTGUI                =   4095  # xtgui information service
      BRE                  =   4096  # BRE (Bridge Relay Element)
      PATROLVIEW           =   4097  # Patrol View
      DRMSFSD              =   4098  # drmsfsd
      DPCP                 =   4099  # DPCP
      IGO_INCOGNITO        =   4100  # IGo Incognito Data Port
      BRLP_0               =   4101  # Braille protocol
      BRLP_1               =   4102  # Braille protocol
      BRLP_2               =   4103  # Braille protocol
      BRLP_3               =   4104  # Braille protocol
      SHOFAR               =   4105  # Shofar
      SYNCHRONITE          =   4106  # Synchronite
      J_AC                 =   4107  # JDL Accounting LAN Service
      ACCEL                =   4108  # ACCEL
      IZM                  =   4109  # Instantiated Zero_control Messaging
      G2TAG                =   4110  # G2 RFID Tag Telemetry Data
      XGRID                =   4111  # Xgrid
      APPLE_VPNS_RP        =   4112  # Apple VPN Server Reporting Protocol
      AIPN_REG             =   4113  # AIPN LS Registration
      JOMAMQMONITOR        =   4114  # JomaMQMonitor
      CDS                  =   4115  # CDS Transfer Agent
      SMARTCARD_TLS        =   4116  # smartcard_TLS
      HILLRSERV            =   4117  # Hillr Connection Manager
      NETSCRIPT            =   4118  # Netadmin Systems NETscript service
      ASSURIA_SLM          =   4119  # Assuria Log Manager
      E_BUILDER            =   4121  # e_Builder Application Communication
      FPRAMS               =   4122  # Fiber Patrol Alarm Service
      Z_WAVE               =   4123  # Z_Wave Protocol
      TIGV2                =   4124  # Rohill TetraNode Ip Gateway v2
      OPSVIEW_ENVOY        =   4125  # Opsview Envoy
      DDREPL               =   4126  # Data Domain Replication Service
      UNIKEYPRO            =   4127  # NetUniKeyServer
      NUFW                 =   4128  # NuFW decision delegation protocol
      NUAUTH               =   4129  # NuFW authentication protocol
      FRONET               =   4130  # FRONET message protocol
      STARS                =   4131  # Global Maintech Stars
      NUTS_DEM             =   4132  # NUTS DaemonIANA assigned this well_formed service name as a replacement for "nuts_dem".
      NUTS_DEM             =   4132  # NUTS Daemon This entry is an alias to "nuts_dem".This entry is now historic, not usable for use with manycommon service discovery mechanisms.
      NUTS_BOOTP           =   4133  # NUTS Bootp ServerIANA assigned this well_formed service name as a replacement for "nuts_bootp".
      NUTS_BOOTP           =   4133  # NUTS Bootp Server
      NIFTY_HMI            =   4134  # NIFTY_Serve HMI protocol
      CL_DB_ATTACH         =   4135  # Classic Line Database Server Attach
      CL_DB_REQUEST        =   4136  # Classic Line Database Server Request
      CL_DB_REMOTE         =   4137  # Classic Line Database Server Remote
      NETTEST              =   4138  # nettest
      THRTX                =   4139  # Imperfect Networks Server
      CEDROS_FDS           =   4140  # Cedros Fraud Detection SystemIANA assigned this well_formed service name as a replacement for "cedros_fds".
      CEDROS_FDS           =   4140  # Cedros Fraud Detection System
      OIRTGSVC             =   4141  # Workflow Server
      OIDOCSVC             =   4142  # Document Server
      OIDSR                =   4143  # Document Replication
      VVR_CONTROL          =   4145  # VVR Control
      TGCCONNECT           =   4146  # TGCConnect Beacon
      VRXPSERVMAN          =   4147  # Multum Service Manager
      HHB_HANDHELD         =   4148  # HHB Handheld Client
      AGSLB                =   4149  # A10 GSLB Service
      POWERALERT_NSA       =   4150  # PowerAlert Network Shutdown Agent
      MENANDMICE_NOH       =   4151  # Men & Mice Remote ControlIANA assigned this well_formed service name as a replacement for "menandmice_noh".
      MENANDMICE_NOH       =   4151  # Men & Mice Remote Control
      IDIG_MUX             =   4152  # iDigTech MultiplexIANA assigned this well_formed service name as a replacement for "idig_mux".
      IDIG_MUX             =   4152  # iDigTech Multiplex
      MBL_BATTD            =   4153  # MBL Remote Battery Monitoring
      ATLINKS              =   4154  # atlinks device discovery
      BZR                  =   4155  # Bazaar version control system
      STAT_RESULTS         =   4156  # STAT Results
      STAT_SCANNER         =   4157  # STAT Scanner Control
      STAT_CC              =   4158  # STAT Command Center
      NSS                  =   4159  # Network Security Service
      JINI_DISCOVERY       =   4160  # Jini Discovery
      OMSCONTACT           =   4161  # OMS Contact
      OMSTOPOLOGY          =   4162  # OMS Topology
      SILVERPEAKPEER       =   4163  # Silver Peak Peer Protocol
      SILVERPEAKCOMM       =   4164  # Silver Peak Communication Protocol
      ALTCP                =   4165  # ArcLink over Ethernet
      JOOST                =   4166  # Joost Peer to Peer Protocol
      DDGN                 =   4167  # DeskDirect Global Network
      PSLICSER             =   4168  # PrintSoft License Server
      IADT                 =   4169  # Automation Drive Interface Transport
      D_CINEMA_CSP         =   4170  # SMPTE Content Synchonization Protocol
      ML_SVNET             =   4171  # Maxlogic Supervisor Communication
      PCOIP                =   4172  # PC over IP
      SMCLUSTER            =   4174  # StorMagic Cluster Services
      BCCP                 =   4175  # Brocade Cluster Communication Protocol
      TL_IPCPROXY          =   4176  # Translattice Cluster IPC Proxy
      WELLO                =   4177  # Wello P2P pubsub service
      STORMAN              =   4178  # StorMan
      MAXUMSP              =   4179  # Maxum Services
      HTTPX                =   4180  # HTTPX
      MACBAK               =   4181  # MacBak
      PCPTCPSERVICE        =   4182  # Production Company Pro TCP Service
      GMMP                 =   4183  # General Metaverse Messaging Protocol
      UNIVERSE_SUITE       =   4184  # UNIVERSE SUITE MESSAGE SERVICEIANA assigned this well_formed service name as a replacement for "universe_suite".
      UNIVERSE_SUITE       =   4184  # UNIVERSE SUITE MESSAGE SERVICE
      WCPP                 =   4185  # Woven Control Plane Protocol
      BOXBACKUPSTORE       =   4186  # Box Backup Store Service
      CSC_PROXY            =   4187  # Cascade ProxyIANA assigned this well_formed service name as a replacement for "csc_proxy".
      CSC_PROXY            =   4187  # Cascade Proxy
      VATATA               =   4188  # Vatata Peer to Peer Protocol
      PCEP                 =   4189  # Path Computation Element Communication Protocol
      SIEVE                =   4190  # ManageSieve Protocol
      AZETI                =   4192  # Azeti Agent Service
      PVXPLUSIO            =   4193  # PxPlus remote file srvr
      EIMS_ADMIN           =   4199  # EIMS ADMIN
      CORELCCAM            =   4300  # Corel CCam
      D_DATA               =   4301  # Diagnostic Data
      D_DATA_CONTROL       =   4302  # Diagnostic Data Control
      SRCP                 =   4303  # Simple Railroad Command Protocol
      OWSERVER             =   4304  # One_Wire Filesystem Server
      BATMAN               =   4305  # better approach to mobile ad_hoc networking
      PINGHGL              =   4306  # Hellgate London
      VISICRON_VS          =   4307  # Visicron Videoconference Service
      COMPX_LOCKVIEW       =   4308  # CompX_LockView
      DSERVER              =   4309  # Exsequi Appliance Discovery
      MIRRTEX              =   4310  # Mir_RT exchange service
      P6SSMC               =   4311  # P6R Secure Server Management Console
      PSCL_MGT             =   4312  # Parascale Membership Manager
      PERRLA               =   4313  # PERRLA User Services
      CHOICEVIEW_AGT       =   4314  # ChoiceView Agent
      CHOICEVIEW_CLT       =   4316  # ChoiceView Client
      FDT_RCATP            =   4320  # FDT Remote Categorization Protocol
      RWHOIS               =   4321  # Remote Who Is
      TRIM_EVENT           =   4322  # TRIM Event Service
      TRIM_ICE             =   4323  # TRIM ICE Service
      BALOUR               =   4324  # Balour Game Server
      GEOGNOSISMAN         =   4325  # Cadcorp GeognoSIS Manager Service
      GEOGNOSIS            =   4326  # Cadcorp GeognoSIS Service
      JAXER_WEB            =   4327  # Jaxer Web Protocol
      JAXER_MANAGER        =   4328  # Jaxer Manager Command Protocol
      PUBLIQARE_SYNC       =   4329  # PubliQare Distributed Environment Synchronisation Engine
      DEY_SAPI             =   4330  # DEY Storage Administration REST API
      KTICKETS_REST        =   4331  # ktickets REST API for event management and ticketing systems (embedded POS devices)
      AHSP                 =   4333  # ArrowHead Service Protocol (AHSP)
      GAIA                 =   4340  # Gaia Connector Protocol
      LISP_DATA            =   4341  # LISP Data Packets
      LISP_CONS            =   4342  # LISP_CONS Control
      UNICALL              =   4343  # UNICALL
      VINAINSTALL          =   4344  # VinaInstall
      M4_NETWORK_AS        =   4345  # Macro 4 Network AS
      ELANLM               =   4346  # ELAN LM
      LANSURVEYOR          =   4347  # LAN Surveyor
      ITOSE                =   4348  # ITOSE
      FSPORTMAP            =   4349  # File System Port Map
      NET_DEVICE           =   4350  # Net Device
      PLCY_NET_SVCS        =   4351  # PLCY Net Services
      PJLINK               =   4352  # Projector Link
      F5_IQUERY            =   4353  # F5 iQuery
      QSNET_TRANS          =   4354  # QSNet Transmitter
      QSNET_WORKST         =   4355  # QSNet Workstation
      QSNET_ASSIST         =   4356  # QSNet Assistant
      QSNET_COND           =   4357  # QSNet Conductor
      QSNET_NUCL           =   4358  # QSNet Nucleus
      OMABCASTLTKM         =   4359  # OMA BCAST Long_Term Key Messages
      MATRIX_VNET          =   4360  # Matrix VNet Communication ProtocolIANA assigned this well_formed service name as a replacement for "matrix_vnet".
      MATRIX_VNET          =   4360  # Matrix VNet Communication Protocol
      WXBRIEF              =   4368  # WeatherBrief Direct
      EPMD                 =   4369  # Erlang Port Mapper Daemon
      ELPRO_TUNNEL         =   4370  # ELPRO V2 Protocol TunnelIANA assigned this well_formed service name as a replacement for "elpro_tunnel".
      ELPRO_TUNNEL         =   4370  # ELPRO V2 Protocol Tunnel
      L2C_CONTROL          =   4371  # LAN2CAN Control
      L2C_DATA             =   4372  # LAN2CAN Data
      REMCTL               =   4373  # Remote Authenticated Command Service
      PSI_PTT              =   4374  # PSI Push_to_Talk Protocol
      TOLTECES             =   4375  # Toltec EasyShare
      BIP                  =   4376  # BioAPI Interworking
      CP_SPXSVR            =   4377  # Cambridge Pixel SPx Server
      CP_SPXDPY            =   4378  # Cambridge Pixel SPx Display
      CTDB                 =   4379  # CTDB
      XANDROS_CMS          =   4389  # Xandros Community Management Service
      WIEGAND              =   4390  # Physical Access Control
      APWI_IMSERVER        =   4391  # American Printware IMServer Protocol
      APWI_RXSERVER        =   4392  # American Printware RXServer Protocol
      APWI_RXSPOOLER       =   4393  # American Printware RXSpooler Protocol
      OMNIVISIONESX        =   4395  # OmniVision communication for Virtual environments
      FLY                  =   4396  # Fly Object Space
      DS_SRV               =   4400  # ASIGRA Services
      DS_SRVR              =   4401  # ASIGRA Televaulting DS_System Service
      DS_CLNT              =   4402  # ASIGRA Televaulting DS_Client Service
      DS_USER              =   4403  # ASIGRA Televaulting DS_Client Monitoring_Management
      DS_ADMIN             =   4404  # ASIGRA Televaulting DS_System Monitoring_Management
      DS_MAIL              =   4405  # ASIGRA Televaulting Message Level Restore service
      DS_SLP               =   4406  # ASIGRA Televaulting DS_Sleeper Service
      NACAGENT             =   4407  # Network Access Control Agent
      SLSCC                =   4408  # SLS Technology Control Centre
      NETCABINET_COM       =   4409  # Net_Cabinet comunication
      ITWO_SERVER          =   4410  # RIB iTWO Application Server
      FOUND                =   4411  # Found Messaging Protocol
      NETROCKEY6           =   4425  # NetROCKEY6 SMART Plus Service
      BEACON_PORT_2        =   4426  # SMARTS Beacon Port
      DRIZZLE              =   4427  # Drizzle database server
      OMVISERVER           =   4428  # OMV_Investigation Server_Client
      OMVIAGENT            =   4429  # OMV Investigation Agent_Server
      RSQLSERVER           =   4430  # REAL SQL Server
      WSPIPE               =   4431  # adWISE Pipe
      L_ACOUSTICS          =   4432  # L_ACOUSTICS management
      VOP                  =   4433  # Versile Object Protocol
      SARIS                =   4442  # Saris
      PHAROS               =   4443  # Pharos
      KRB524               =   4444  # KRB524
      NV_VIDEO             =   4444  # NV Video default
      UPNOTIFYP            =   4445  # UPNOTIFYP
      N1_FWP               =   4446  # N1_FWP
      N1_RMGMT             =   4447  # N1_RMGMT
      ASC_SLMD             =   4448  # ASC Licence Manager
      PRIVATEWIRE          =   4449  # PrivateWire
      CAMP                 =   4450  # Common ASCII Messaging Protocol
      CTISYSTEMMSG         =   4451  # CTI System Msg
      CTIPROGRAMLOAD       =   4452  # CTI Program Load
      NSSALERTMGR          =   4453  # NSS Alert Manager
      NSSAGENTMGR          =   4454  # NSS Agent Manager
      PRCHAT_USER          =   4455  # PR Chat User
      PRCHAT_SERVER        =   4456  # PR Chat Server
      PRREGISTER           =   4457  # PR Register
      MCP                  =   4458  # Matrix Configuration Protocol
      HPSSMGMT             =   4484  # hpssmgmt service
      ASSYST_DR            =   4485  # Assyst Data Repository Service
      ICMS                 =   4486  # Integrated Client Message Service
      PREX_TCP             =   4487  # Protocol for Remote Execution over TCP
      AWACS_ICE            =   4488  # Apple Wide Area Connectivity Service ICE Bootstrap
      IPSEC_NAT_T          =   4500  # IPsec NAT_Traversal
      EHS                  =   4535  # Event Heap Server
      EHS_SSL              =   4536  # Event Heap Server SSL
      WSSAUTHSVC           =   4537  # WSS Security Service
      SWX_GATE             =   4538  # Software Data Exchange Gateway
      WORLDSCORES          =   4545  # WorldScores
      SF_LM                =   4546  # SF License Manager (Sentinel)
      LANNER_LM            =   4547  # Lanner License Manager
      SYNCHROMESH          =   4548  # Synchromesh
      AEGATE               =   4549  # Aegate PMR Service
      GDS_ADPPIW_DB        =   4550  # Perman I Interbase Server
      IEEE_MIH             =   4551  # MIH Services
      MENANDMICE_MON       =   4552  # Men and Mice Monitoring
      ICSHOSTSVC           =   4553  # ICS host services
      MSFRS                =   4554  # MS FRS Replication
      RSIP                 =   4555  # RSIP Port
      DTN_BUNDLE           =   4556  # DTN Bundle TCP CL Protocol
      HYLAFAX              =   4559  # HylaFAX
      AMAHI_ANYWHERE       =   4563  # Amahi Anywhere
      KWTC                 =   4566  # Kids Watch Time Control Service
      TRAM                 =   4567  # TRAM
      BMC_REPORTING        =   4568  # BMC Reporting
      IAX                  =   4569  # Inter_Asterisk eXchange
      DEPLOYMENTMAP        =   4570  # Service to distribute and update within a site deployment information for Oracle Communications Suite
      RID                  =   4590  # RID over HTTP_TLS
      L3T_AT_AN            =   4591  # HRPD L3T (AT_AN)
      IPT_ANRI_ANRI        =   4593  # IPT (ANRI_ANRI)
      IAS_SESSION          =   4594  # IAS_Session (ANRI_ANRI)
      IAS_PAGING           =   4595  # IAS_Paging (ANRI_ANRI)
      IAS_NEIGHBOR         =   4596  # IAS_Neighbor (ANRI_ANRI)
#      A21_AN_1XBS          =   4597  # A21 (AN_1xBS)
      A16_AN_AN            =   4598  # A16 (AN_AN)
      A17_AN_AN            =   4599  # A17 (AN_AN)
      PIRANHA1             =   4600  # Piranha1
      PIRANHA2             =   4601  # Piranha2
      MTSSERVER            =   4602  # EAX MTS Server
      MENANDMICE_UPG       =   4603  # Men & Mice Upgrade Agent
      IRP                  =   4604  # Identity Registration Protocol
      SIXCHAT              =   4605  # Direct End to End Secure Chat Protocol
      PLAYSTA2_APP         =   4658  # PlayStation2 App Port
      PLAYSTA2_LOB         =   4659  # PlayStation2 Lobby Port
      SMACLMGR             =   4660  # smaclmgr
      KAR2OUCHE            =   4661  # Kar2ouche Peer location service
      OMS                  =   4662  # OrbitNet Message Service
      NOTEIT               =   4663  # Note It! Message Service
      EMS                  =   4664  # Rimage Messaging Server
      CONTCLIENTMS         =   4665  # Container Client Message Service
      EPORTCOMM            =   4666  # E_Port Message Service
      MMACOMM              =   4667  # MMA Comm Services
      MMAEDS               =   4668  # MMA EDS Service
      EPORTCOMMDATA        =   4669  # E_Port Data Service
      LIGHT                =   4670  # Light packets transfer protocol
      ACTER                =   4671  # Bull RSF action server
      RFA                  =   4672  # remote file access server
      CXWS                 =   4673  # CXWS Operations
      APPIQ_MGMT           =   4674  # AppIQ Agent Management
      DHCT_STATUS          =   4675  # BIAP Device Status
      DHCT_ALERTS          =   4676  # BIAP Generic Alert
      BCS                  =   4677  # Business Continuity Servi
      TRAVERSAL            =   4678  # boundary traversal
      MGESUPERVISION       =   4679  # MGE UPS Supervision
      MGEMANAGEMENT        =   4680  # MGE UPS Management
      PARLIANT             =   4681  # Parliant Telephony System
      FINISAR              =   4682  # finisar
      SPIKE                =   4683  # Spike Clipboard Service
      RFID_RP1             =   4684  # RFID Reader Protocol 1.0
      AUTOPAC              =   4685  # Autopac Protocol
      MSP_OS               =   4686  # Manina Service Protocol
      NST                  =   4687  # Network Scanner Tool FTP
      MOBILE_P2P           =   4688  # Mobile P2P Service
      ALTOVACENTRAL        =   4689  # Altova DatabaseCentral
      PRELUDE              =   4690  # Prelude IDS message proto
      MTN                  =   4691  # monotone Netsync Protocol
      CONSPIRACY           =   4692  # Conspiracy messaging
      NETXMS_AGENT         =   4700  # NetXMS Agent
      NETXMS_MGMT          =   4701  # NetXMS Management
      NETXMS_SYNC          =   4702  # NetXMS Server Synchronization
      NPQES_TEST           =   4703  # Network Performance Quality Evaluation System Test Service
      ASSURIA_INS          =   4704  # Assuria Insider
      TRUCKSTAR            =   4725  # TruckStar Service
      FCIS                 =   4727  # F_Link Client Information Service
      CAPMUX               =   4728  # CA Port Multiplexer
      GEARMAN              =   4730  # Gearman Job Queue System
      REMCAP               =   4731  # Remote Capture Protocol
      RESORCS              =   4733  # RES Orchestration Catalog Services
      IPDR_SP              =   4737  # IPDR_SP
      SOLERA_LPN           =   4738  # SoleraTec Locator
      IPFIX                =   4739  # IP Flow Info Export
      IPFIXS               =   4740  # ipfix protocol over TLS
      LUMIMGRD             =   4741  # Luminizer Manager
      SICCT                =   4742  # SICCT
      OPENHPID             =   4743  # openhpi HPI service
      IFSP                 =   4744  # Internet File Synchronization Protocol
      FMP                  =   4745  # Funambol Mobile Push
      PROFILEMAC           =   4749  # Profile for Mac
      SSAD                 =   4750  # Simple Service Auto Discovery
      SPOCP                =   4751  # Simple Policy Control Protocol
      SNAP                 =   4752  # Simple Network Audio Protocol
      SIMON                =   4753  # Simple Invocation of Methods Over Network (SIMON)
      BFD_MULTI_CTL        =   4784  # BFD Multihop Control
      SMART_INSTALL        =   4786  # Smart Install Service
      SIA_CTRL_PLANE       =   4787  # Service Insertion Architecture (SIA) Control_Plane
      XMCP                 =   4788  # eXtensible Messaging Client Protocol
      IIMS                 =   4800  # Icona Instant Messenging System
      IWEC                 =   4801  # Icona Web Embedded Chat
      ILSS                 =   4802  # Icona License System Server
      NOTATEIT             =   4803  # Notateit Messaging
      HTCP                 =   4827  # HTCP
      VARADERO_0           =   4837  # Varadero_0
      VARADERO_1           =   4838  # Varadero_1
      VARADERO_2           =   4839  # Varadero_2
      OPCUA_TCP            =   4840  # OPC UA TCP Protocol
      QUOSA                =   4841  # QUOSA Virtual Library Service
      GW_ASV               =   4842  # nCode ICE_flow Library AppServer
      OPCUA_TLS            =   4843  # OPC UA TCP Protocol over TLS_SSL
      GW_LOG               =   4844  # nCode ICE_flow Library LogServer
      WCR_REMLIB           =   4845  # WordCruncher Remote Library Service
      CONTAMAC_ICM         =   4846  # Contamac ICM ServiceIANA assigned this well_formed service name as a replacement for "contamac_icm".
      CONTAMAC_ICM         =   4846  # Contamac ICM Service
      WFC                  =   4847  # Web Fresh Communication
      APPSERV_HTTP         =   4848  # App Server _ Admin HTTP
      APPSERV_HTTPS        =   4849  # App Server _ Admin HTTPS
      SUN_AS_NODEAGT       =   4850  # Sun App Server _ NA
      DERBY_REPLI          =   4851  # Apache Derby Replication
      UNIFY_DEBUG          =   4867  # Unify Debugger
      PHRELAY              =   4868  # Photon Relay
      PHRELAYDBG           =   4869  # Photon Relay Debug
      CC_TRACKING          =   4870  # Citcom Tracking Service
      WIRED                =   4871  # Wired
      TRITIUM_CAN          =   4876  # Tritium CAN Bus Bridge Service
      LMCS                 =   4877  # Lighting Management Control System
      WSDL_EVENT           =   4879  # WSDL Event Receiver
      HISLIP               =   4880  # IVI High_Speed LAN Instrument Protocol
      WMLSERVER            =   4883  # Meier_Phelps License Server
      HIVESTOR             =   4884  # HiveStor Distributed File System
      ABBS                 =   4885  # ABBS
      LYSKOM               =   4894  # LysKOM Protocol A
      RADMIN_PORT          =   4899  # RAdmin Port
      HFCS                 =   4900  # HFSQL Client_Server Database Engine
      FLR_AGENT            =   4901  # FileLocator Remote Search AgentIANA assigned this well_formed service name as a replacement for "flr_agent".
      FLR_AGENT            =   4901  # FileLocator Remote Search Agent
      MAGICCONTROL         =   4902  # magicCONROL RF and Data Interface
      LUTAP                =   4912  # Technicolor LUT Access Protocol
      LUTCP                =   4913  # LUTher Control Protocol
      BONES                =   4914  # Bones Remote Control
      FRCS                 =   4915  # Fibics Remote Control Service
      EQ_OFFICE_4940       =   4940  # Equitrac Office
      EQ_OFFICE_4941       =   4941  # Equitrac Office
      EQ_OFFICE_4942       =   4942  # Equitrac Office
      MUNIN                =   4949  # Munin Graphing Framework
      SYBASESRVMON         =   4950  # Sybase Server Monitor
      PWGWIMS              =   4951  # PWG WIMS
      SAGXTSDS             =   4952  # SAG Directory Server
      DBSYNCARBITER        =   4953  # Synchronization Arbiter
      CCSS_QMM             =   4969  # CCSS QMessageMonitor
      CCSS_QSM             =   4970  # CCSS QSystemMonitor
      WEBYAST              =   4984  # WebYast
      GERHCS               =   4985  # GER HC Standard
      MRIP                 =   4986  # Model Railway Interface Program
      SMAR_SE_PORT1        =   4987  # SMAR Ethernet Port 1
      SMAR_SE_PORT2        =   4988  # SMAR Ethernet Port 2
      PARALLEL             =   4989  # Parallel for GAUSS (tm)
      BUSYCAL              =   4990  # BusySync Calendar Synch. Protocol
      VRT                  =   4991  # VITA Radio Transport
      HFCS_MANAGER         =   4999  # HFSQL Client_Server Database Engine Manager
      COMMPLEX_MAIN        =   5000  # 
      COMMPLEX_LINK        =   5001  # 
      RFE                  =   5002  # radio free ethernet
      FMPRO_INTERNAL       =   5003  # FileMaker, Inc. _ Proprietary transport
      AVT_PROFILE_1        =   5004  # RTP media data
      AVT_PROFILE_2        =   5005  # RTP control protocol
      WSM_SERVER           =   5006  # wsm server
      WSM_SERVER_SSL       =   5007  # wsm server ssl
      SYNAPSIS_EDGE        =   5008  # Synapsis EDGE
      WINFS                =   5009  # Microsoft Windows Filesystem
      TELELPATHSTART       =   5010  # TelepathStart
      TELELPATHATTACK      =   5011  # TelepathAttack
      NSP                  =   5012  # NetOnTap Service
      FMPRO_V6             =   5013  # FileMaker, Inc. _ Proprietary transport
      FMWP                 =   5015  # FileMaker, Inc. _ Web publishing
      ZENGINKYO_1          =   5020  # zenginkyo_1
      ZENGINKYO_2          =   5021  # zenginkyo_2
      MICE                 =   5022  # mice server
      HTUILSRV             =   5023  # Htuil Server for PLD2
      SCPI_TELNET          =   5024  # SCPI_TELNET
      SCPI_RAW             =   5025  # SCPI_RAW
      STREXEC_D            =   5026  # Storix I_O daemon (data)
      STREXEC_S            =   5027  # Storix I_O daemon (stat)
      QVR                  =   5028  # Quiqum Virtual Relais
      INFOBRIGHT           =   5029  # Infobright Database Server
      SURFPASS             =   5030  # SurfPass
      SIGNACERT_AGENT      =   5032  # SignaCert Enterprise Trust Server Agent
      ASNAACCELER8DB       =   5042  # asnaacceler8db
      SWXADMIN             =   5043  # ShopWorX Administration
      LXI_EVNTSVC          =   5044  # LXI Event Service
      OSP                  =   5045  # Open Settlement Protocol
      TEXAI                =   5048  # Texai Message Service
      IVOCALIZE            =   5049  # iVocalize Web Conference
      MMCC                 =   5050  # multimedia conference control tool
      ITA_AGENT            =   5051  # ITA Agent
      ITA_MANAGER          =   5052  # ITA Manager
      RLM                  =   5053  # RLM License Server
      RLM_ADMIN            =   5054  # RLM administrative interface
      UNOT                 =   5055  # UNOT
      INTECOM_PS1          =   5056  # Intecom Pointspan 1
      INTECOM_PS2          =   5057  # Intecom Pointspan 2
      SDS                  =   5059  # SIP Directory Services
      SIP                  =   5060  # SIP 2014_04_09
      SIPS                 =   5061  # SIP_TLS 2014_04_09
      NA_LOCALISE          =   5062  # Localisation access
      CSRPC                =   5063  # centrify secure RPC
      CA_1                 =   5064  # Channel Access 1
      CA_2                 =   5065  # Channel Access 2
      STANAG_5066          =   5066  # STANAG_5066_SUBNET_INTF
      AUTHENTX             =   5067  # Authentx Service
      BITFORESTSRV         =   5068  # Bitforest Data Service
      I_NET_2000_NPR       =   5069  # I_Net 2000_NPR
      VTSAS                =   5070  # VersaTrans Server Agent Service
      POWERSCHOOL          =   5071  # PowerSchool
      AYIYA                =   5072  # Anything In Anything
      TAG_PM               =   5073  # Advantage Group Port Mgr
      ALESQUERY            =   5074  # ALES Query
      PVACCESS             =   5075  # Experimental Physics and Industrial Control System
      ONSCREEN             =   5080  # OnScreen Data Collection Service
      SDL_ETS              =   5081  # SDL _ Ent Trans Server
      QCP                  =   5082  # Qpur Communication Protocol
      QFP                  =   5083  # Qpur File Protocol
      LLRP                 =   5084  # EPCglobal Low_Level Reader Protocol
      ENCRYPTED_LLRP       =   5085  # EPCglobal Encrypted LLRP
      APRIGO_CS            =   5086  # Aprigo Collection Service
      BIOTIC               =   5087  # BIOTIC _ Binary Internet of Things Interoperable Communication
      SENTINEL_LM          =   5093  # Sentinel LM
      HART_IP              =   5094  # HART_IP
      SENTLM_SRV2SRV       =   5099  # SentLM Srv2Srv
      SOCALIA              =   5100  # Socalia service mux
      TALARIAN_TCP         =   5101  # Talarian_TCP
      OMS_NONSECURE        =   5102  # Oracle OMS non_secure
      ACTIFIO_C2C          =   5103  # Actifio C2C
      ACTIFIOUDSAGENT      =   5106  # Actifio UDS Agent
      TAEP_AS_SVC          =   5111  # TAEP AS service
      PM_CMDSVR            =   5112  # PeerMe Msg Cmd Service
      EV_SERVICES          =   5114  # Enterprise Vault Services
      AUTOBUILD            =   5115  # Symantec Autobuild Service
      GRADECAM             =   5117  # GradeCam Image Processing
      BARRACUDA_BBS        =   5120  # Barracuda Backup Protocol
      NBT_PC               =   5133  # Policy Commander
      PPACTIVATION         =   5134  # PP ActivationServer
      ERP_SCALE            =   5135  # ERP_Scale
      CTSD                 =   5137  # MyCTS server port
      RMONITOR_SECURE      =   5145  # RMONITOR SECUREIANA assigned this well_formed service name as a replacement for "rmonitor_secure".
      RMONITOR_SECURE      =   5145  # RMONITOR SECURE
      SOCIAL_ALARM         =   5146  # Social Alarm Service
      ATMP                 =   5150  # Ascend Tunnel Management Protocol
      ESRI_SDE             =   5151  # ESRI SDE Instance    IANA assigned this well_formed service name as a replacement for "esri_sde".
      ESRI_SDE             =   5151  # ESRI SDE Instance
      SDE_DISCOVERY        =   5152  # ESRI SDE Instance Discovery
      TORUXSERVER          =   5153  # ToruX Game Server
      BZFLAG               =   5154  # BZFlag game server
      ASCTRL_AGENT         =   5155  # Oracle asControl Agent
      RUGAMEONLINE         =   5156  # Russian Online Game
      MEDIAT               =   5157  # Mediat Remote Object Exchange
      SNMPSSH              =   5161  # SNMP over SSH Transport Model
      SNMPSSH_TRAP         =   5162  # SNMP Notification over SSH Transport Model
      SBACKUP              =   5163  # Shadow Backup
      VPA                  =   5164  # Virtual Protocol Adapter
      IFE_ICORP            =   5165  # ife_1corpIANA assigned this well_formed service name as a replacement for "ife_icorp".
      IFE_ICORP            =   5165  # ife_1corp
      WINPCS               =   5166  # WinPCS Service Connection
      SCTE104              =   5167  # SCTE104 Connection
      SCTE30               =   5168  # SCTE30 Connection
      PCOIP_MGMT           =   5172  # PC over IP Endpoint Management
      AOL                  =   5190  # America_Online
      AOL_1                =   5191  # AmericaOnline1
      AOL_2                =   5192  # AmericaOnline2
      AOL_3                =   5193  # AmericaOnline3
      CPSCOMM              =   5194  # CipherPoint Config Service
      AMPL_LIC             =   5195  # The protocol is used by a license server and client programs to control use of program licenses that float to networked machines
      AMPL_TABLEPROXY      =   5196  # The protocol is used by two programs that exchange "table" data used in the AMPL modeling language
      TARGUS_GETDATA       =   5200  # TARGUS GetData
      TARGUS_GETDATA1      =   5201  # TARGUS GetData 1
      TARGUS_GETDATA2      =   5202  # TARGUS GetData 2
      TARGUS_GETDATA3      =   5203  # TARGUS GetData 3
      NOMAD                =   5209  # Nomad Device Video Transfer
      NOTEZA               =   5215  # NOTEZA Data Safety Service
#      3EXMP                =   5221  # 3eTI Extensible Management Protocol for OAMP
      XMPP_CLIENT          =   5222  # XMPP Client Connection
      HPVIRTGRP            =   5223  # HP Virtual Machine Group Management
      HPVIRTCTRL           =   5224  # HP Virtual Machine Console Operations
      HP_SERVER            =   5225  # HP Server
      HP_STATUS            =   5226  # HP Status
      PERFD                =   5227  # HP System Performance Metric Service
      HPVROOM              =   5228  # HP Virtual Room Service
      JAXFLOW              =   5229  # Netflow_IPFIX_sFlow Collector and Forwarder Management
      JAXFLOW_DATA         =   5230  # JaxMP RealFlow application and protocol data
      CRUSECONTROL         =   5231  # Remote Control of Scan Software for Cruse Scanners
      CSEDAEMON            =   5232  # Cruse Scanning System Service
      ENFS                 =   5233  # Etinnae Network File Service
      EENET                =   5234  # EEnet communications
      GALAXY_NETWORK       =   5235  # Galaxy Network Service
      PADL2SIM             =   5236  # 
      MNET_DISCOVERY       =   5237  # m_net discovery
      DOWNTOOLS            =   5245  # DownTools Control Protocol
      CAACWS               =   5248  # CA Access Control Web Service
      CAACLANG2            =   5249  # CA AC Lang Service
      SOAGATEWAY           =   5250  # soaGateway
      CAEVMS               =   5251  # CA eTrust VM Service
      MOVAZ_SSC            =   5252  # Movaz SSC
      KPDP                 =   5253  # Kohler Power Device Protocol
#      3COM_NJACK_1         =   5264  # 3Com Network Jack Port 1
#      3COM_NJACK_2         =   5265  # 3Com Network Jack Port 2
      XMPP_SERVER          =   5269  # XMPP Server Connection
      CARTOGRAPHERXMP      =   5270  # Cartographer XMP
      CUELINK              =   5271  # StageSoft CueLink messaging
      PK                   =   5272  # PK
      XMPP_BOSH            =   5280  # Bidirectional_streams Over Synchronous HTTP (BOSH)
      UNDO_LM              =   5281  # Undo License Manager
      TRANSMIT_PORT        =   5282  # Marimba Transmitter Port
      PRESENCE             =   5298  # XMPP Link_Local Messaging
      NLG_DATA             =   5299  # NLG Data Service
      HACL_HB              =   5300  # HA cluster heartbeat
      HACL_GS              =   5301  # HA cluster general services
      HACL_CFG             =   5302  # HA cluster configuration
      HACL_PROBE           =   5303  # HA cluster probing
      HACL_LOCAL           =   5304  # HA Cluster Commands
      HACL_TEST            =   5305  # HA Cluster Test
      SUN_MC_GRP           =   5306  # Sun MC Group
      SCO_AIP              =   5307  # SCO AIP
      CFENGINE             =   5308  # CFengine
      JPRINTER             =   5309  # J Printer
      OUTLAWS              =   5310  # Outlaws
      PERMABIT_CS          =   5312  # Permabit Client_Server
      RRDP                 =   5313  # Real_time & Reliable Data
      OPALIS_RBT_IPC       =   5314  # opalis_rbt_ipc
      HACL_POLL            =   5315  # HA Cluster UDP Polling
      HPBLADEMS            =   5316  # HPBladeSystem Monitor Service
      HPDEVMS              =   5317  # HP Device Monitor Service
      PKIX_CMC             =   5318  # PKIX Certificate Management using CMS (CMC)
      BSFSERVER_ZN         =   5320  # Webservices_based Zn interface of BSF
      BSFSVR_ZN_SSL        =   5321  # Webservices_based Zn interface of BSF over SSL
      KFSERVER             =   5343  # Sculptor Database Server
      XKOTODRCP            =   5344  # xkoto DRCP
      STUNS                =   5349  # STUN over TLS
      TURNS                =   5349  # TURN over TLS
      STUN_BEHAVIORS       =   5349  # STUN Behavior Discovery over TLS
      DNS_LLQ              =   5352  # DNS Long_Lived Queries
      MDNS                 =   5353  # Multicast DNS
      MDNSRESPONDER        =   5354  # Multicast DNS Responder IPC
      LLMNR                =   5355  # LLMNR
      MS_SMLBIZ            =   5356  # Microsoft Small Business
      WSDAPI               =   5357  # Web Services for Devices
      WSDAPI_S             =   5358  # WS for Devices Secured
      MS_ALERTER           =   5359  # Microsoft Alerter
      MS_SIDESHOW          =   5360  # Protocol for Windows SideShow
      MS_S_SIDESHOW        =   5361  # Secure Protocol for Windows SideShow
      SERVERWSD2           =   5362  # Microsoft Windows Server WSD2 Service
      NET_PROJECTION       =   5363  # Windows Network Projection
      STRESSTESTER         =   5397  # StressTester(tm) Injector
      ELEKTRON_ADMIN       =   5398  # Elektron Administration
      SECURITYCHASE        =   5399  # SecurityChase
      EXCERPT              =   5400  # Excerpt Search
      EXCERPTS             =   5401  # Excerpt Search Secure
      MFTP                 =   5402  # OmniCast MFTP
      HPOMS_CI_LSTN        =   5403  # HPOMS_CI_LSTN
      HPOMS_DPS_LSTN       =   5404  # HPOMS_DPS_LSTN
      NETSUPPORT           =   5405  # NetSupport
      SYSTEMICS_SOX        =   5406  # Systemics Sox
      FORESYTE_CLEAR       =   5407  # Foresyte_Clear
      FORESYTE_SEC         =   5408  # Foresyte_Sec
      SALIENT_DTASRV       =   5409  # Salient Data Server
      SALIENT_USRMGR       =   5410  # Salient User Manager
      ACTNET               =   5411  # ActNet
      CONTINUUS            =   5412  # Continuus
      WWIOTALK             =   5413  # WWIOTALK
      STATUSD              =   5414  # StatusD
      NS_SERVER            =   5415  # NS Server
      SNS_GATEWAY          =   5416  # SNS Gateway
      SNS_AGENT            =   5417  # SNS Agent
      MCNTP                =   5418  # MCNTP
      DJ_ICE               =   5419  # DJ_ICE
      CYLINK_C             =   5420  # Cylink_C
      NETSUPPORT2          =   5421  # Net Support 2
      SALIENT_MUX          =   5422  # Salient MUX
      VIRTUALUSER          =   5423  # VIRTUALUSER
      BEYOND_REMOTE        =   5424  # Beyond Remote
      BR_CHANNEL           =   5425  # Beyond Remote Command Channel
      DEVBASIC             =   5426  # DEVBASIC
      SCO_PEER_TTA         =   5427  # SCO_PEER_TTA
      TELACONSOLE          =   5428  # TELACONSOLE
      BASE                 =   5429  # Billing and Accounting System Exchange
      RADEC_CORP           =   5430  # RADEC CORP
      PARK_AGENT           =   5431  # PARK AGENT
      POSTGRESQL           =   5432  # PostgreSQL Database
      PYRRHO               =   5433  # Pyrrho DBMS
      SGI_ARRAYD           =   5434  # SGI Array Services Daemon
      SCEANICS             =   5435  # SCEANICS situation and action notification
      SPSS                 =   5443  # Pearson HTTPS
      SMBDIRECT            =   5445  # Server Message Block over Remote Direct Memory Access
      SUREBOX              =   5453  # SureBox
      APC_5454             =   5454  # APC 5454
      APC_5455             =   5455  # APC 5455
      APC_5456             =   5456  # APC 5456
      SILKMETER            =   5461  # SILKMETER
      TTL_PUBLISHER        =   5462  # TTL Publisher
      TTLPRICEPROXY        =   5463  # TTL Price Proxy
      QUAILNET             =   5464  # Quail Networks Object Broker
      NETOPS_BROKER        =   5465  # NETOPS_BROKER
      FCP_ADDR_SRVR1       =   5500  # fcp_addr_srvr1
      FCP_ADDR_SRVR2       =   5501  # fcp_addr_srvr2
      FCP_SRVR_INST1       =   5502  # fcp_srvr_inst1
      FCP_SRVR_INST2       =   5503  # fcp_srvr_inst2
      FCP_CICS_GW1         =   5504  # fcp_cics_gw1
      CHECKOUTDB           =   5505  # Checkout Database
      AMC                  =   5506  # Amcom Mobile Connect
      SGI_EVENTMOND        =   5553  # SGI Eventmond Port
      SGI_ESPHTTP          =   5554  # SGI ESP HTTP
      PERSONAL_AGENT       =   5555  # Personal Agent
      FREECIV              =   5556  # Freeciv gameplay
      FARENET              =   5557  # Sandlab FARENET
      WESTEC_CONNECT       =   5566  # Westec Connect
      ENC_EPS_MC_SEC       =   5567  # EMIT protocol stack multicast_secure transport
      SDT                  =   5568  # Session Data Transport Multicast
      RDMNET_CTRL          =   5569  # PLASA E1.33, Remote Device Management (RDM) controller status notifications
      SDMMP                =   5573  # SAS Domain Management Messaging Protocol
      LSI_BOBCAT           =   5574  # SAS IO Forwarding
      ORA_OAP              =   5575  # Oracle Access Protocol
      FDTRACKS             =   5579  # FleetDisplay Tracking Service
      TMOSMS0              =   5580  # T_Mobile SMS Protocol Message 0
      TMOSMS1              =   5581  # T_Mobile SMS Protocol Message 1
      FAC_RESTORE          =   5582  # T_Mobile SMS Protocol Message 3
      TMO_ICON_SYNC        =   5583  # T_Mobile SMS Protocol Message 2
      BIS_WEB              =   5584  # BeInSync_Web
      BIS_SYNC             =   5585  # BeInSync_sync
      ATT_MT_SMS           =   5586  # Planning to send mobile terminated SMS to the specific port so that the SMS is not visible to the client
      ININMESSAGING        =   5597  # inin secure messaging
      MCTFEED              =   5598  # MCT Market Data Feed
      ESINSTALL            =   5599  # Enterprise Security Remote Install
      ESMMANAGER           =   5600  # Enterprise Security Manager
      ESMAGENT             =   5601  # Enterprise Security Agent
      A1_MSC               =   5602  # A1_MSC
      A1_BS                =   5603  # A1_BS
      A3_SDUNODE           =   5604  # A3_SDUNode
      A4_SDUNODE           =   5605  # A4_SDUNode
      EFR                  =   5618  # Fiscal Registering Protocol
      NINAF                =   5627  # Node Initiated Network Association Forma
      HTRUST               =   5628  # HTrust API
      SYMANTEC_SFDB        =   5629  # Symantec Storage Foundation for Database
      PRECISE_COMM         =   5630  # PreciseCommunication
      PCANYWHEREDATA       =   5631  # pcANYWHEREdata
      PCANYWHERESTAT       =   5632  # pcANYWHEREstat
      BEORL                =   5633  # BE Operations Request Listener
      XPRTLD               =   5634  # SF Message Service
      SFMSSO               =   5635  # SFM Authentication Subsystem
      SFM_DB_SERVER        =   5636  # SFMdb _ SFM DB server
      CSSC                 =   5637  # Symantec CSSC
      FLCRS                =   5638  # Symantec Fingerprint Lookup and Container Reference Service
      ICS                  =   5639  # Symantec Integrity Checking Service
      VFMOBILE             =   5646  # Ventureforth Mobile
      FILEMQ               =   5670  # ZeroMQ file publish_subscribe protocol
      AMQPS                =   5671  # amqp protocol over TLS_SSL
      AMQP                 =   5672  # AMQP
      JMS                  =   5673  # JACL Message Server
      HYPERSCSI_PORT       =   5674  # HyperSCSI Port
      V5UA                 =   5675  # V5UA application port
      RAADMIN              =   5676  # RA Administration
      QUESTDB2_LNCHR       =   5677  # Quest Central DB2 Launchr
      RRAC                 =   5678  # Remote Replication Agent Connection
      DCCM                 =   5679  # Direct Cable Connect Manager
      AURIGA_ROUTER        =   5680  # Auriga Router Service
      NCXCP                =   5681  # Net_coneX Control Protocol
      GGZ                  =   5688  # GGZ Gaming Zone
      QMVIDEO              =   5689  # QM video network management protocol
      RBSYSTEM             =   5693  # Robert Bosch Data Transfer
      KMIP                 =   5696  # Key Management Interoperability Protocol
      PROSHAREAUDIO        =   5713  # proshare conf audio
      PROSHAREVIDEO        =   5714  # proshare conf video
      PROSHAREDATA         =   5715  # proshare conf data
      PROSHAREREQUEST      =   5716  # proshare conf request
      PROSHARENOTIFY       =   5717  # proshare conf notify
      DPM                  =   5718  # DPM Communication Server
      DPM_AGENT            =   5719  # DPM Agent Coordinator
      MS_LICENSING         =   5720  # MS_Licensing
      DTPT                 =   5721  # Desktop Passthru Service
      MSDFSR               =   5722  # Microsoft DFS Replication Service
      OMHS                 =   5723  # Operations Manager _ Health Service
      OMSDK                =   5724  # Operations Manager _ SDK Service
      MS_ILM               =   5725  # Microsoft Identity Lifecycle Manager
      MS_ILM_STS           =   5726  # Microsoft Lifecycle Manager Secure Token Service
      ASGENF               =   5727  # ASG Event Notification Framework
      IO_DIST_DATA         =   5728  # Dist. I_O Comm. Service Data and Control
      OPENMAIL             =   5729  # Openmail User Agent Layer
      UNIENG               =   5730  # Steltor's calendar access
      IDA_DISCOVER1        =   5741  # IDA Discover Port 1
      IDA_DISCOVER2        =   5742  # IDA Discover Port 2
      WATCHDOC_POD         =   5743  # Watchdoc NetPOD Protocol
      WATCHDOC             =   5744  # Watchdoc Server
      FCOPY_SERVER         =   5745  # fcopy_server
      FCOPYS_SERVER        =   5746  # fcopys_server
      TUNATIC              =   5747  # Wildbits Tunatic
      TUNALYZER            =   5748  # Wildbits Tunalyzer
      RSCD                 =   5750  # Bladelogic Agent Service
      OPENMAILG            =   5755  # OpenMail Desk Gateway server
      X500MS               =   5757  # OpenMail X.500 Directory Server
      OPENMAILNS           =   5766  # OpenMail NewMail Server
      S_OPENMAIL           =   5767  # OpenMail Suer Agent Layer (Secure)
      OPENMAILPXY          =   5768  # OpenMail CMTS Server
      SPRAMSCA             =   5769  # x509solutions Internal CA
      SPRAMSD              =   5770  # x509solutions Secure Data
      NETAGENT             =   5771  # NetAgent
      DALI_PORT            =   5777  # DALI Port
      VTS_RPC              =   5780  # Visual Tag System RPC
#      3PAR_EVTS            =   5781  # 3PAR Event Reporting Service
#      3PAR_MGMT            =   5782  # 3PAR Management Service
#      3PAR_MGMT_SSL        =   5783  # 3PAR Management Service with SSL
#      3PAR_RCOPY           =   5785  # 3PAR Inform Remote Copy
      XTREAMX              =   5793  # XtreamX Supervised Peer message
      ICMPD                =   5813  # ICMPD
      SPT_AUTOMATION       =   5814  # Support Automation
      SHIPRUSH_D_CH        =   5841  # Z_firm ShipRush interface for web access and bidirectional data
      REVERSION            =   5842  # Reversion Backup_Restore
      WHEREHOO             =   5859  # WHEREHOO
      PPSUITEMSG           =   5863  # PlanetPress Suite Messeng
      DIAMETERS            =   5868  # Diameter over TLS_TCP
      JUTE                 =   5883  # Javascript Unit Test Environment
      RFB                  =   5900  # Remote Framebuffer
      CM                   =   5910  # Context Management
      CPDLC                =   5911  # Controller Pilot Data Link Communication
      FIS                  =   5912  # Flight Information Services
      ADS_C                =   5913  # Automatic Dependent Surveillance
      INDY                 =   5963  # Indy Application Server
      MPPOLICY_V5          =   5968  # mppolicy_v5
      MPPOLICY_MGR         =   5969  # mppolicy_mgr
      COUCHDB              =   5984  # CouchDB
      WSMAN                =   5985  # WBEM WS_Management HTTP
      WSMANS               =   5986  # WBEM WS_Management HTTP over TLS_SSL
      WBEM_RMI             =   5987  # WBEM RMI
      WBEM_HTTP            =   5988  # WBEM CIM_XML (HTTP)
      WBEM_HTTPS           =   5989  # WBEM CIM_XML (HTTPS)
      WBEM_EXP_HTTPS       =   5990  # WBEM Export HTTPS
      NUXSL                =   5991  # NUXSL
      CONSUL_INSIGHT       =   5992  # Consul InSight Security
      CVSUP                =   5999  # CVSup
      X11                  =   6000  # 6000_6063 X Window System
      NDL_AHP_SVC          =   6064  # NDL_AHP_SVC
      WINPHARAOH           =   6065  # WinPharaoh
      EWCTSP               =   6066  # EWCTSP
      GSMP_ANCP            =   6068  # GSMP_ANCP
      TRIP                 =   6069  # TRIP
      MESSAGEASAP          =   6070  # Messageasap
      SSDTP                =   6071  # SSDTP
      DIAGNOSE_PROC        =   6072  # DIAGNOSE_PROC
      DIRECTPLAY8          =   6073  # DirectPlay8
      MAX                  =   6074  # Microsoft Max
      DPM_ACM              =   6075  # Microsoft DPM Access Control Manager
      MSFT_DPM_CERT        =   6076  # Microsoft DPM WCF Certificates
      ICONSTRUCTSRV        =   6077  # iConstruct Server
      RELOAD_CONFIG        =   6084  # Peer to Peer Infrastructure Configuration
      KONSPIRE2B           =   6085  # konspire2b p2p network
      PDTP                 =   6086  # PDTP P2P
      LDSS                 =   6087  # Local Download Sharing Service
      DOGLMS               =   6088  # SuperDog License Manager
      RAXA_MGMT            =   6099  # RAXA Management
      SYNCHRONET_DB        =   6100  # SynchroNet_db
      SYNCHRONET_RTC       =   6101  # SynchroNet_rtc
      SYNCHRONET_UPD       =   6102  # SynchroNet_upd
      RETS                 =   6103  # RETS
      DBDB                 =   6104  # DBDB
      PRIMASERVER          =   6105  # Prima Server
      MPSSERVER            =   6106  # MPS Server
      ETC_CONTROL          =   6107  # ETC Control
      SERCOMM_SCADMIN      =   6108  # Sercomm_SCAdmin
      GLOBECAST_ID         =   6109  # GLOBECAST_ID
      SOFTCM               =   6110  # HP SoftBench CM
      SPC                  =   6111  # HP SoftBench Sub_Process Control
      DTSPCD               =   6112  # Desk_Top Sub_Process Control Daemon
      DAYLITESERVER        =   6113  # Daylite Server
      WRSPICE              =   6114  # WRspice IPC Service
      XIC                  =   6115  # Xic IPC Service
      XTLSERV              =   6116  # XicTools License Manager Service
      DAYLITETOUCH         =   6117  # Daylite Touch Sync
      SPDY                 =   6121  # SPDY for a faster web
      BEX_WEBADMIN         =   6122  # Backup Express Web Server
      BACKUP_EXPRESS       =   6123  # Backup Express
      PNBS                 =   6124  # Phlexible Network Backup Service
      DAMEWAREMOBGTWY      =   6130  # The DameWare Mobile Gateway Service
      NBT_WOL              =   6133  # New Boundary Tech WOL
      PULSONIXNLS          =   6140  # Pulsonix Network License Service
      META_CORP            =   6141  # Meta Corporation License Manager
      ASPENTEC_LM          =   6142  # Aspen Technology License Manager
      WATERSHED_LM         =   6143  # Watershed License Manager
      STATSCI1_LM          =   6144  # StatSci License Manager _ 1
      STATSCI2_LM          =   6145  # StatSci License Manager _ 2
      LONEWOLF_LM          =   6146  # Lone Wolf Systems License Manager
      MONTAGE_LM           =   6147  # Montage License Manager
      RICARDO_LM           =   6148  # Ricardo North America License Manager
      TAL_POD              =   6149  # tal_pod
      EFB_ACI              =   6159  # EFB Application Control Interface
      ECMP                 =   6160  # Emerson Extensible Control and Management Protocol
      PATROL_ISM           =   6161  # PATROL Internet Srv Mgr
      PATROL_COLL          =   6162  # PATROL Collector
      PSCRIBE              =   6163  # Precision Scribe Cnx Port
      LM_X                 =   6200  # LM_X License Manager by X_Formation
      RADMIND              =   6222  # Radmind Access Protocol
      JEOL_NSDTP_1         =   6241  # JEOL Network Services Data Transport Protocol 1
      JEOL_NSDTP_2         =   6242  # JEOL Network Services Data Transport Protocol 2
      JEOL_NSDTP_3         =   6243  # JEOL Network Services Data Transport Protocol 3
      JEOL_NSDTP_4         =   6244  # JEOL Network Services Data Transport Protocol 4
      TL1_RAW_SSL          =   6251  # TL1 Raw Over SSL_TLS
      TL1_SSH              =   6252  # TL1 over SSH
      CRIP                 =   6253  # CRIP
      GLD                  =   6267  # GridLAB_D User Interface
      GRID                 =   6268  # Grid Authentication
      GRID_ALT             =   6269  # Grid Authentication Alt
      BMC_GRX              =   6300  # BMC GRX
      BMC_CTD_LDAP         =   6301  # BMC CONTROL_D LDAP SERVERIANA assigned this well_formed service name as a replacement for "bmc_ctd_ldap".
      BMC_CTD_LDAP         =   6301  # BMC CONTROL_D LDAP SERVER
      UFMP                 =   6306  # Unified Fabric Management Protocol
      SCUP                 =   6315  # Sensor Control Unit Protocol
      ABB_ESCP             =   6316  # Ethernet Sensor Communications Protocol
      NAV_DATA_CMD         =   6317  # Navtech Radar Sensor Data Command
      REPSVC               =   6320  # Double_Take Replication Service
      EMP_SERVER1          =   6321  # Empress Software Connectivity Server 1
      EMP_SERVER2          =   6322  # Empress Software Connectivity Server 2
      HRD_NCS              =   6324  # HR Device Network Configuration Service
      DT_MGMTSVC           =   6325  # Double_Take Management Service
      DT_VRA               =   6326  # Double_Take Virtual Recovery Assistant
      SFLOW                =   6343  # sFlow traffic monitoring
      STRELETZ             =   6344  # Argus_Spectr security and fire_prevention systems service
      GNUTELLA_SVC         =   6346  # gnutella_svc
      GNUTELLA_RTR         =   6347  # gnutella_rtr
      ADAP                 =   6350  # App Discovery and Access Protocol
      PMCS                 =   6355  # PMCS applications
      METAEDIT_MU          =   6360  # MetaEdit+ Multi_User
      METAEDIT_SE          =   6370  # MetaEdit+ Server Administration
      METATUDE_MDS         =   6382  # Metatude Dialogue Server
      CLARIION_EVR01       =   6389  # clariion_evr01
      METAEDIT_WS          =   6390  # MetaEdit+ WebService API
      FAXCOMSERVICE        =   6417  # Faxcom Message Service
      SYSERVERREMOTE       =   6418  # SYserver remote commands
      SVDRP                =   6419  # Simple VDR Protocol
      NIM_VDRSHELL         =   6420  # NIM_VDRShell
      NIM_WAN              =   6421  # NIM_WAN
      PGBOUNCER            =   6432  # PgBouncer
      TARP                 =   6442  # Transitory Application Request Protocol
      SUN_SR_HTTPS         =   6443  # Service Registry Default HTTPS Domain
      SGE_QMASTER          =   6444  # Grid Engine Qmaster ServiceIANA assigned this well_formed service name as a replacement for "sge_qmaster".
      SGE_QMASTER          =   6444  # Grid Engine Qmaster Service
      SGE_EXECD            =   6445  # Grid Engine Execution ServiceIANA assigned this well_formed service name as a replacement for "sge_execd".
      SGE_EXECD            =   6445  # Grid Engine Execution Service
      MYSQL_PROXY          =   6446  # MySQL Proxy
      SKIP_CERT_RECV       =   6455  # SKIP Certificate Receive
      SKIP_CERT_SEND       =   6456  # SKIP Certificate Send
      LVISION_LM           =   6471  # LVision License Manager
      SUN_SR_HTTP          =   6480  # Service Registry Default HTTP Domain
      SERVICETAGS          =   6481  # Service Tags
      LDOMS_MGMT           =   6482  # Logical Domains Management Interface
      SUNVTS_RMI           =   6483  # SunVTS RMI
      SUN_SR_JMS           =   6484  # Service Registry Default JMS Domain
      SUN_SR_IIOP          =   6485  # Service Registry Default IIOP Domain
      SUN_SR_IIOPS         =   6486  # Service Registry Default IIOPS Domain
      SUN_SR_IIOP_AUT      =   6487  # Service Registry Default IIOPAuth Domain
      SUN_SR_JMX           =   6488  # Service Registry Default JMX Domain
      SUN_SR_ADMIN         =   6489  # Service Registry Default Admin Domain
      BOKS                 =   6500  # BoKS Master
      BOKS_SERVC           =   6501  # BoKS ServcIANA assigned this well_formed service name as a replacement for "boks_servc".
      BOKS_SERVC           =   6501  # BoKS Servc
      BOKS_SERVM           =   6502  # BoKS ServmIANA assigned this well_formed service name as a replacement for "boks_servm".
      BOKS_SERVM           =   6502  # BoKS Servm
      BOKS_CLNTD           =   6503  # BoKS ClntdIANA assigned this well_formed service name as a replacement for "boks_clntd".
      BOKS_CLNTD           =   6503  # BoKS Clntd
      BADM_PRIV            =   6505  # BoKS Admin Private PortIANA assigned this well_formed service name as a replacement for "badm_priv".
      BADM_PRIV            =   6505  # BoKS Admin Private Port
      BADM_PUB             =   6506  # BoKS Admin Public PortIANA assigned this well_formed service name as a replacement for "badm_pub".
      BADM_PUB             =   6506  # BoKS Admin Public Port
      BDIR_PRIV            =   6507  # BoKS Dir Server, Private PortIANA assigned this well_formed service name as a replacement for "bdir_priv".
      BDIR_PRIV            =   6507  # BoKS Dir Server, Private Port
      BDIR_PUB             =   6508  # BoKS Dir Server, Public PortIANA assigned this well_formed service name as a replacement for "bdir_pub".
      BDIR_PUB             =   6508  # BoKS Dir Server, Public Port
      MGCS_MFP_PORT        =   6509  # MGCS_MFP Port
      MCER_PORT            =   6510  # MCER Port
      NETCONF_TLS          =   6513  # NETCONF over TLS
      SYSLOG_TLS           =   6514  # Syslog over TLS
      ELIPSE_REC           =   6515  # Elipse RPC Protocol
      LDS_DISTRIB          =   6543  # lds_distrib
      LDS_DUMP             =   6544  # LDS Dump Service
      APC_6547             =   6547  # APC 6547
      APC_6548             =   6548  # APC 6548
      APC_6549             =   6549  # APC 6549
      FG_SYSUPDATE         =   6550  # fg_sysupdate
      SUM                  =   6551  # Software Update Manager
      XDSXDM               =   6558  # 
      SANE_PORT            =   6566  # SANE Control Port
      CANIT_STORE          =   6568  # CanIt Storage ManagerIANA assigned this well_formed service name as a replacement for "canit_store".
      CANIT_STORE          =   6568  # CanIt Storage Manager
      AFFILIATE            =   6579  # Affiliate
      PARSEC_MASTER        =   6580  # Parsec Masterserver
      PARSEC_PEER          =   6581  # Parsec Peer_to_Peer
      PARSEC_GAME          =   6582  # Parsec Gameserver
      JOAJEWELSUITE        =   6583  # JOA Jewel Suite
      MSHVLM               =   6600  # Microsoft Hyper_V Live Migration
      MSTMG_SSTP           =   6601  # Microsoft Threat Management Gateway SSTP
      WSSCOMFRMWK          =   6602  # Windows WSS Communication Framework
      ODETTE_FTPS          =   6619  # ODETTE_FTP over TLS_SSL
      KFTP_DATA            =   6620  # Kerberos V5 FTP Data
      KFTP                 =   6621  # Kerberos V5 FTP Control
      MCFTP                =   6622  # Multicast FTP
      KTELNET              =   6623  # Kerberos V5 Telnet
      DATASCALER_DB        =   6624  # DataScaler database
      DATASCALER_CTL       =   6625  # DataScaler control
      WAGO_SERVICE         =   6626  # WAGO Service and Update
      NEXGEN               =   6627  # Allied Electronics NeXGen
      AFESC_MC             =   6628  # AFE Stock Channel M_C
      MXODBC_CONNECT       =   6632  # eGenix mxODBC Connect
      OVSDB                =   6640  # Open vSwitch Database protocol
      OPENFLOW             =   6653  # OpenFlow
      PCS_SF_UI_MAN        =   6655  # PC SOFT _ Software factory UI_manager
      EMGMSG               =   6656  # Emergency Message Control Service
      IRCU                 =   6665  # 6665_6669 IRCU
      VOCALTEC_GOLD        =   6670  # Vocaltec Global Online Directory
      P4P_PORTAL           =   6671  # P4P Portal Service
      VISION_SERVER        =   6672  # vision_serverIANA assigned this well_formed service name as a replacement for "vision_server".
      VISION_SERVER        =   6672  # vision_server
      VISION_ELMD          =   6673  # vision_elmdIANA assigned this well_formed service name as a replacement for "vision_elmd".
      VISION_ELMD          =   6673  # vision_elmd
      VFBP                 =   6678  # Viscount Freedom Bridge Protocol
      OSAUT                =   6679  # Osorno Automation
      CLEVER_CTRACE        =   6687  # CleverView for cTrace Message Service
      CLEVER_TCPIP         =   6688  # CleverView for TCP_IP Message Service
      TSA                  =   6689  # Tofino Security Appliance
      IRCS_U               =   6697  # Internet Relay Chat via TLS_SSL 2014_02_11
      KTI_ICAD_SRVR        =   6701  # KTI_ICAD Nameserver
      E_DESIGN_NET         =   6702  # e_Design network
      E_DESIGN_WEB         =   6703  # e_Design web
      IBPROTOCOL           =   6714  # Internet Backplane Protocol
      FIBOTRADER_COM       =   6715  # Fibotrader Communications
      PRINTERCARE_CC       =   6716  # PrinterCare cloud service
      BMC_PERF_AGENT       =   6767  # BMC PERFORM AGENT
      BMC_PERF_MGRD        =   6768  # BMC PERFORM MGRD
      ADI_GXP_SRVPRT       =   6769  # ADInstruments GxP Server
      PLYSRV_HTTP          =   6770  # PolyServe http
      PLYSRV_HTTPS         =   6771  # PolyServe https
      NTZ_TRACKER          =   6777  # netTsunami Tracker
      NTZ_P2P_STORAGE      =   6778  # netTsunami p2p storage system
      DGPF_EXCHG           =   6785  # DGPF Individual Exchange
      SMC_JMX              =   6786  # Sun Java Web Console JMX
      SMC_ADMIN            =   6787  # Sun Web Console Admin
      SMC_HTTP             =   6788  # SMC_HTTP
      SMC_HTTPS            =   6789  # SMC_HTTPS
      HNMP                 =   6790  # HNMP
      HNM                  =   6791  # Halcyon Network Manager
      ACNET                =   6801  # ACNET Control System Protocol
      PENTBOX_SIM          =   6817  # PenTBox Secure IM Protocol
      AMBIT_LM             =   6831  # ambit_lm
      NETMO_DEFAULT        =   6841  # Netmo Default
      NETMO_HTTP           =   6842  # Netmo HTTP
      ICCRUSHMORE          =   6850  # ICCRUSHMORE
      ACCTOPUS_CC          =   6868  # Acctopus Command Channel
      MUSE                 =   6888  # MUSE
      JETSTREAM            =   6901  # Novell Jetstream messaging protocol
      ETHOSCAN             =   6935  # EthoScan Service
      XSMSVC               =   6936  # XenSource Management Service
      BIOSERVER            =   6946  # Biometrics Server
      OTLP                 =   6951  # OTLP
      JMACT3               =   6961  # JMACT3
      JMEVT2               =   6962  # jmevt2
      SWISMGR1             =   6963  # swismgr1
      SWISMGR2             =   6964  # swismgr2
      SWISTRAP             =   6965  # swistrap
      SWISPOL              =   6966  # swispol
      ACMSODA              =   6969  # acmsoda
      MOBILITYSRV          =   6997  # Mobility XE Protocol
      IATP_HIGHPRI         =   6998  # IATP_highPri
      IATP_NORMALPRI       =   6999  # IATP_normalPri
      AFS3_FILESERVER      =   7000  # file server itself
      AFS3_CALLBACK        =   7001  # callbacks to cache managers Known Unauthorized Use on port 7001
      AFS3_PRSERVER        =   7002  # users & groups database Known Unauthorized Use on port 7002
      AFS3_VLSERVER        =   7003  # volume location database
      AFS3_KASERVER        =   7004  # AFS_Kerberos authentication service
      AFS3_VOLSER          =   7005  # volume managment server Known Unauthorized Use on port 7005
      AFS3_ERRORS          =   7006  # error interpretation service
      AFS3_BOS             =   7007  # basic overseer process
      AFS3_UPDATE          =   7008  # server_to_server updater
      AFS3_RMTSYS          =   7009  # remote cache manager service
      UPS_ONLINET          =   7010  # onlinet uninterruptable power supplies
      TALON_DISC           =   7011  # Talon Discovery Port
      TALON_ENGINE         =   7012  # Talon Engine
      MICROTALON_DIS       =   7013  # Microtalon Discovery
      MICROTALON_COM       =   7014  # Microtalon Communications
      TALON_WEBSERVER      =   7015  # Talon Webserver
      FISA_SVC             =   7018  # FISA Service
      DOCERI_CTL           =   7019  # doceri drawing service control
      DPSERVE              =   7020  # DP Serve
      DPSERVEADMIN         =   7021  # DP Serve Admin
      CTDP                 =   7022  # CT Discovery Protocol
      CT2NMCS              =   7023  # Comtech T2 NMCS
      VMSVC                =   7024  # Vormetric service
      VMSVC_2              =   7025  # Vormetric Service II
      OP_PROBE             =   7030  # ObjectPlanet probe
      IPOSPLANET           =   7031  # IPOSPLANET retailing multi devices protocol
      ARCP                 =   7070  # ARCP
      IWG1                 =   7071  # IWGADTS Aircraft Housekeeping Message
      MARTALK              =   7073  # MarTalk protocol
      EMPOWERID            =   7080  # EmpowerID Communication
      LAZY_PTOP            =   7099  # lazy_ptop
      FONT_SERVICE         =   7100  # X Font Service
      ELCN                 =   7101  # Embedded Light Control Network
      VIRPROT_LM           =   7121  # Virtual Prototypes License Manager
      SCENIDM              =   7128  # intelligent data manager
      SCENCCS              =   7129  # Catalog Content Search
      CABSM_COMM           =   7161  # CA BSM Comm
      CAISTORAGEMGR        =   7162  # CA Storage Manager
      CACSAMBROKER         =   7163  # CA Connection Broker
      FSR                  =   7164  # File System Repository Agent
      DOC_SERVER           =   7165  # Document WCF Server
      ARUBA_SERVER         =   7166  # Aruba eDiscovery Server
      CASRMAGENT           =   7167  # CA SRM Agent
      CNCKADSERVER         =   7168  # cncKadServer DB & Inventory Services
      CCAG_PIB             =   7169  # Consequor Consulting Process Integration Bridge
      NSRP                 =   7170  # Adaptive Name_Service Resolution
      DRM_PRODUCTION       =   7171  # Discovery and Retention Mgt Production
      METALBEND            =   7172  # Port used for MetalBend programmable interface
      ZSECURE              =   7173  # zSecure Server
      CLUTILD              =   7174  # Clutild
      FODMS                =   7200  # FODMS FLIP
      DLIP                 =   7201  # DLIP
      RAMP                 =   7227  # Registry A & M Protocol
      CITRIXUPP            =   7228  # Citrix Universal Printing Port
      CITRIXUPPG           =   7229  # Citrix UPP Gateway
      DISPLAY              =   7236  # Wi_Fi Alliance Wi_Fi Display Protocol
      PADS                 =   7237  # PADS (Public Area Display System) Server
      CNAP                 =   7262  # Calypso Network Access Protocol
      WATCHME_7272         =   7272  # WatchMe Monitoring 7272
      OMA_RLP              =   7273  # OMA Roaming Location
      OMA_RLP_S            =   7274  # OMA Roaming Location SEC
      OMA_ULP              =   7275  # OMA UserPlane Location
      OMA_ILP              =   7276  # OMA Internal Location Protocol
      OMA_ILP_S            =   7277  # OMA Internal Location Secure Protocol
      OMA_DCDOCBS          =   7278  # OMA Dynamic Content Delivery over CBS
      CTXLIC               =   7279  # Citrix Licensing
      ITACTIONSERVER1      =   7280  # ITACTIONSERVER 1
      ITACTIONSERVER2      =   7281  # ITACTIONSERVER 2
      MZCA_ACTION          =   7282  # eventACTION_ussACTION (MZCA) server
      GENSTAT              =   7283  # General Statistics Rendezvous Protocol
      LCM_SERVER           =   7365  # LifeKeeper Communications
      MINDFILESYS          =   7391  # mind_file system server
      MRSSRENDEZVOUS       =   7392  # mrss_rendezvous server
      NFOLDMAN             =   7393  # nFoldMan Remote Publish
      FSE                  =   7394  # File system export of backup images
      WINQEDIT             =   7395  # winqedit
      HEXARC               =   7397  # Hexarc Command Language
      RTPS_DISCOVERY       =   7400  # RTPS Discovery
      RTPS_DD_UT           =   7401  # RTPS Data_Distribution User_Traffic
      RTPS_DD_MT           =   7402  # RTPS Data_Distribution Meta_Traffic
      IONIXNETMON          =   7410  # Ionix Network Monitor
      DAQSTREAM            =   7411  # Streaming of measurement data
      MTPORTMON            =   7421  # Matisse Port Monitor
      PMDMGR               =   7426  # OpenView DM Postmaster Manager
      OVEADMGR             =   7427  # OpenView DM Event Agent Manager
      OVLADMGR             =   7428  # OpenView DM Log Agent Manager
      OPI_SOCK             =   7429  # OpenView DM rqt communication
      XMPV7                =   7430  # OpenView DM xmpv7 api pipe
      PMD                  =   7431  # OpenView DM ovc_xmpv3 api pipe
      FAXIMUM              =   7437  # Faximum
      ORACLEAS_HTTPS       =   7443  # Oracle Application Server HTTPS
      STTUNNEL             =   7471  # Stateless Transport Tunneling Protocol
      RISE                 =   7473  # Rise: The Vieneo Province
      NEO4J                =   7474  # Neo4j Graph Database
      TELOPS_LMD           =   7491  # telops_lmd
      SILHOUETTE           =   7500  # Silhouette User
      OVBUS                =   7501  # HP OpenView Bus Daemon
      ADCP                 =   7508  # Automation Device Configuration Protocol
      ACPLT                =   7509  # ACPLT _ process automation service
      OVHPAS               =   7510  # HP OpenView Application Server
      PAFEC_LM             =   7511  # pafec_lm
      SARATOGA             =   7542  # Saratoga Transfer Protocol
      ATUL                 =   7543  # atul server
      NTA_DS               =   7544  # FlowAnalyzer DisplayServer
      NTA_US               =   7545  # FlowAnalyzer UtilityServer
      CFS                  =   7546  # Cisco Fabric service
      CWMP                 =   7547  # DSL Forum CWMP
      TIDP                 =   7548  # Threat Information Distribution Protocol
      NLS_TL               =   7549  # Network Layer Signaling Transport Layer
      SNCP                 =   7560  # Sniffer Command Protocol
      CFW                  =   7563  # Control Framework
      VSI_OMEGA            =   7566  # VSI Omega
      DELL_EQL_ASM         =   7569  # Dell EqualLogic Host Group Management
      ARIES_KFINDER        =   7570  # Aries Kfinder
      COHERENCE            =   7574  # Oracle Coherence Cluster Service
      SUN_LM               =   7588  # Sun License Manager
      INDI                 =   7624  # Instrument Neutral Distributed Interface
      SIMCO                =   7626  # SImple Middlebox COnfiguration (SIMCO) Server
      SOAP_HTTP            =   7627  # SOAP Service Port
      ZEN_PAWN             =   7628  # Primary Agent Work Notification
      XDAS                 =   7629  # OpenXDAS Wire Protocol
      HAWK                 =   7630  # HA Web Konsole
      TESLA_SYS_MSG        =   7631  # TESLA System Messaging
      PMDFMGT              =   7633  # PMDF Management
      CUSEEME              =   7648  # bonjour_cuseeme
      IMQSTOMP             =   7672  # iMQ STOMP Server
      IMQSTOMPS            =   7673  # iMQ STOMP Server over SSL
      IMQTUNNELS           =   7674  # iMQ SSL tunnel
      IMQTUNNEL            =   7675  # iMQ Tunnel
      IMQBROKERD           =   7676  # iMQ Broker Rendezvous
      SUN_USER_HTTPS       =   7677  # Sun App Server _ HTTPS
      PANDO_PUB            =   7680  # Pando Media Public Distribution
      COLLABER             =   7689  # Collaber Network Service
      KLIO                 =   7697  # KLIO communications
      EM7_SECOM            =   7700  # EM7 Secure Communications
      SYNC_EM7             =   7707  # EM7 Dynamic Updates
      SCINET               =   7708  # scientia.net
      MEDIMAGEPORTAL       =   7720  # MedImage Portal
      NSDEEPFREEZECTL      =   7724  # Novell Snap_in Deep Freeze Control
      NITROGEN             =   7725  # Nitrogen Service
      FREEZEXSERVICE       =   7726  # FreezeX Console Service
      TRIDENT_DATA         =   7727  # Trident Systems Data
      SMIP                 =   7734  # Smith Protocol over IP
      AIAGENT              =   7738  # HP Enterprise Discovery Agent
      SCRIPTVIEW           =   7741  # ScriptView Network
      MSSS                 =   7742  # Mugginsoft Script Server Service
      SSTP_1               =   7743  # Sakura Script Transfer Protocol
      RAQMON_PDU           =   7744  # RAQMON PDU
      PRGP                 =   7747  # Put_Run_Get Protocol
      CBT                  =   7777  # cbt
      INTERWISE            =   7778  # Interwise
      VSTAT                =   7779  # VSTAT
      ACCU_LMGR            =   7781  # accu_lmgr
      MINIVEND             =   7786  # MINIVEND
      POPUP_REMINDERS      =   7787  # Popup Reminders Receive
      OFFICE_TOOLS         =   7789  # Office Tools Pro Receive
      Q3ADE                =   7794  # Q3ADE Cluster Service
      PNET_CONN            =   7797  # Propel Connector port
      PNET_ENC             =   7798  # Propel Encoder port
      ALTBSDP              =   7799  # Alternate BSDP Service
      ASR                  =   7800  # Apple Software Restore
      SSP_CLIENT           =   7801  # Secure Server Protocol _ client
      RBT_WANOPT           =   7810  # Riverbed WAN Optimization Protocol
      APC_7845             =   7845  # APC 7845
      APC_7846             =   7846  # APC 7846
      CSOAUTH              =   7847  # A product key authentication protocol made by CSO
      MOBILEANALYZER       =   7869  # MobileAnalyzer& MobileMonitor
      RBT_SMC              =   7870  # Riverbed Steelhead Mobile Service
      MDM                  =   7871  # Mobile Device Management
      OWMS                 =   7878  # Opswise Message Service
      PSS                  =   7880  # Pearson
      UBROKER              =   7887  # Universal Broker
      MEVENT               =   7900  # Multicast Event
      TNOS_SP              =   7901  # TNOS Service Protocol
      TNOS_DP              =   7902  # TNOS shell Protocol
      TNOS_DPS             =   7903  # TNOS Secure DiaguardProtocol
      QO_SECURE            =   7913  # QuickObjects secure port
      T2_DRM               =   7932  # Tier 2 Data Resource Manager
      T2_BRM               =   7933  # Tier 2 Business Rules Manager
      GENERALSYNC          =   7962  # Encrypted, extendable, general_purpose synchronization protocol
      SUPERCELL            =   7967  # Supercell
      MICROMUSE_NCPS       =   7979  # Micromuse_ncps
      QUEST_VISTA          =   7980  # Quest Vista
      SOSSD_COLLECT        =   7981  # Spotlight on SQL Server Desktop Collect
      SOSSD_AGENT          =   7982  # Spotlight on SQL Server Desktop Agent
      PUSHNS               =   7997  # PUSH Notification Service
      IRDMI2               =   7999  # iRDMI2
      IRDMI                =   8000  # iRDMI
      VCOM_TUNNEL          =   8001  # VCOM Tunnel
      TERADATAORDBMS       =   8002  # Teradata ORDBMS
      MCREPORT             =   8003  # Mulberry Connect Reporting Service
      MXI                  =   8005  # MXI Generation II for z_OS
      HTTP_ALT             =   8008  # HTTP Alternate
      QBDB                 =   8019  # QB DB Dynamic Port
      INTU_EC_SVCDISC      =   8020  # Intuit Entitlement Service and Discovery
      INTU_EC_CLIENT       =   8021  # Intuit Entitlement Client
      OA_SYSTEM            =   8022  # oa_system
      CA_AUDIT_DA          =   8025  # CA Audit Distribution Agent
      CA_AUDIT_DS          =   8026  # CA Audit Distribution Server
      PRO_ED               =   8032  # ProEd
      MINDPRINT            =   8033  # MindPrint
      VANTRONIX_MGMT       =   8034  # .vantronix Management
      AMPIFY               =   8040  # Ampify Messaging Protocol
      FS_AGENT             =   8042  # FireScope Agent
      FS_SERVER            =   8043  # FireScope Server
      FS_MGMT              =   8044  # FireScope Management Interface
      ROCRAIL              =   8051  # Rocrail Client Service
      SENOMIX01            =   8052  # Senomix Timesheets Server
      SENOMIX02            =   8053  # Senomix Timesheets Client
      SENOMIX03            =   8054  # Senomix Timesheets Server
      SENOMIX04            =   8055  # Senomix Timesheets Server
      SENOMIX05            =   8056  # Senomix Timesheets Server
      SENOMIX06            =   8057  # Senomix Timesheets Client
      SENOMIX07            =   8058  # Senomix Timesheets Client
      SENOMIX08            =   8059  # Senomix Timesheets Client
      TOAD_BI_APPSRVR      =   8066  # Toad BI Application Server
      GADUGADU             =   8074  # Gadu_Gadu
      HTTP_ALT             =   8080  # HTTP Alternate (see port 80)
      SUNPROXYADMIN        =   8081  # Sun Proxy Admin Service
      US_CLI               =   8082  # Utilistor (Client)
      US_SRV               =   8083  # Utilistor (Server)
      D_S_N                =   8086  # Distributed SCADA Networking Rendezvous Port
      SIMPLIFYMEDIA        =   8087  # Simplify Media SPP Protocol
      RADAN_HTTP           =   8088  # Radan HTTP
      JAMLINK              =   8091  # Jam Link Framework
      SAC                  =   8097  # SAC Port Id
      XPRINT_SERVER        =   8100  # Xprint Server
      LDOMS_MIGR           =   8101  # Logical Domains Migration
      KZ_MIGR              =   8102  # Oracle Kernel zones migration server
      MTL8000_MATRIX       =   8115  # MTL8000 Matrix
      CP_CLUSTER           =   8116  # Check Point Clustering
      PURITYRPC            =   8117  # Purity replication clustering and remote management
      PRIVOXY              =   8118  # Privoxy HTTP proxy
      APOLLO_DATA          =   8121  # Apollo Data Port
      APOLLO_ADMIN         =   8122  # Apollo Admin Port
      PAYCASH_ONLINE       =   8128  # PayCash Online Protocol
      PAYCASH_WBP          =   8129  # PayCash Wallet_Browser
      INDIGO_VRMI          =   8130  # INDIGO_VRMI
      INDIGO_VBCP          =   8131  # INDIGO_VBCP
      DBABBLE              =   8132  # dbabble
      ISDD                 =   8148  # i_SDD file transfer
      QUANTASTOR           =   8153  # QuantaStor Management Interface
      PATROL               =   8160  # Patrol
      PATROL_SNMP          =   8161  # Patrol SNMP
      LPAR2RRD             =   8162  # LPAR2RRD client server communication
      INTERMAPPER          =   8181  # Intermapper network management system
      VMWARE_FDM           =   8182  # VMware Fault Domain Manager
      PROREMOTE            =   8183  # ProRemote
      ITACH                =   8184  # Remote iTach Connection
      LIMNERPRESSURE       =   8191  # Limner Pressure
      SPYTECHPHONE         =   8192  # SpyTech Phone Service
      BLP1                 =   8194  # Bloomberg data API
      BLP2                 =   8195  # Bloomberg feed
      VVR_DATA             =   8199  # VVR DATA
      TRIVNET1             =   8200  # TRIVNET
      TRIVNET2             =   8201  # TRIVNET
      LM_PERFWORKS         =   8204  # LM Perfworks
      LM_INSTMGR           =   8205  # LM Instmgr
      LM_DTA               =   8206  # LM Dta
      LM_SSERVER           =   8207  # LM SServer
      LM_WEBWATCHER        =   8208  # LM Webwatcher
      REXECJ               =   8230  # RexecJ Server
      SYNAPSE_NHTTPS       =   8243  # Synapse Non Blocking HTTPS
      PANDO_SEC            =   8276  # Pando Media Controlled Distribution
      SYNAPSE_NHTTP        =   8280  # Synapse Non Blocking HTTP
      BLP3                 =   8292  # Bloomberg professional
      HIPERSCAN_ID         =   8293  # Hiperscan Identification Service
      BLP4                 =   8294  # Bloomberg intelligent client
      TMI                  =   8300  # Transport Management Interface
      AMBERON              =   8301  # Amberon PPC_PPS
      HUB_OPEN_NET         =   8313  # Hub Open Network
      TNP_DISCOVER         =   8320  # Thin(ium) Network Protocol
      TNP                  =   8321  # Thin(ium) Network Protocol
      SERVER_FIND          =   8351  # Server Find
      CRUISE_ENUM          =   8376  # Cruise ENUM
      CRUISE_SWROUTE       =   8377  # Cruise SWROUTE
      CRUISE_CONFIG        =   8378  # Cruise CONFIG
      CRUISE_DIAGS         =   8379  # Cruise DIAGS
      CRUISE_UPDATE        =   8380  # Cruise UPDATE
      M2MSERVICES          =   8383  # M2m Services
      CVD                  =   8400  # cvd
      SABARSD              =   8401  # sabarsd
      ABARSD               =   8402  # abarsd
      ADMIND               =   8403  # admind
      SVCLOUD              =   8404  # SuperVault Cloud
      SVBACKUP             =   8405  # SuperVault Backup
      DLPX_SP              =   8415  # Delphix Session Protocol
      ESPEECH              =   8416  # eSpeech Session Protocol
      ESPEECH_RTP          =   8417  # eSpeech RTP Protocol
      CYBRO_A_BUS          =   8442  # CyBro A_bus Protocol
      PCSYNC_HTTPS         =   8443  # PCsync HTTPS
      PCSYNC_HTTP          =   8444  # PCsync HTTP
      COPY                 =   8445  # Port for copy peer sync feature
      NPMP                 =   8450  # npmp
      NEXENTAMV            =   8457  # Nexenta Management GUI
      CISCO_AVP            =   8470  # Cisco Address Validation Protocol
      PIM_PORT             =   8471  # PIM over Reliable Transport
      OTV                  =   8472  # Overlay Transport Virtualization (OTV)
      VP2P                 =   8473  # Virtual Point to Point
      NOTESHARE            =   8474  # AquaMinds NoteShare
      FMTP                 =   8500  # Flight Message Transfer Protocol
      CMTP_MGT             =   8501  # CYTEL Message Transfer Management
      FTNMTP               =   8502  # FTN Message Transfer Protocol
      RTSP_ALT             =   8554  # RTSP Alternate (see port 554)
      D_FENCE              =   8555  # SYMAX D_FENCE
      ENC_TUNNEL           =   8567  # EMIT tunneling protocol
      ASTERIX              =   8600  # Surveillance Data
      CANON_MFNP           =   8610  # Canon MFNP Service
      CANON_BJNP1          =   8611  # Canon BJNP Port 1
      CANON_BJNP2          =   8612  # Canon BJNP Port 2
      CANON_BJNP3          =   8613  # Canon BJNP Port 3
      CANON_BJNP4          =   8614  # Canon BJNP Port 4
      IMINK                =   8615  # Imink Service Control
      MONETRA              =   8665  # Monetra
      MONETRA_ADMIN        =   8666  # Monetra Administrative Access
      MSI_CPS_RM           =   8675  # Motorola Solutions Customer Programming Software for Radio Management
      SUN_AS_JMXRMI        =   8686  # Sun App Server _ JMX_RMI
      OPENREMOTE_CTRL      =   8688  # OpenRemote Controller HTTP_REST
      VNYX                 =   8699  # VNYX Primary Port
      NVC                  =   8711  # Nuance Voice Control
      IBUS                 =   8733  # iBus
      DEY_KEYNEG           =   8750  # DEY Storage Key Negotiation
      MC_APPSERVER         =   8763  # MC_APPSERVER
      OPENQUEUE            =   8764  # OPENQUEUE
      ULTRASEEK_HTTP       =   8765  # Ultraseek HTTP
      AMCS                 =   8766  # Agilent Connectivity Service
      DPAP                 =   8770  # Digital Photo Access Protocol (iPhoto)
      UEC                  =   8778  # Stonebranch Universal Enterprise Controller
      MSGCLNT              =   8786  # Message Client
      MSGSRVR              =   8787  # Message Server
      ACD_PM               =   8793  # Accedian Performance Measurement
      SUNWEBADMIN          =   8800  # Sun Web Server Admin Service
      TRUECM               =   8804  # truecm
      DXSPIDER             =   8873  # dxspider linking protocol
      CDDBP_ALT            =   8880  # CDDBP
      GALAXY4D             =   8881  # Galaxy4D Online Game Engine
      SECURE_MQTT          =   8883  # Secure MQTT
      DDI_TCP_1            =   8888  # NewsEDGE server TCP (TCP 1)
      DDI_TCP_2            =   8889  # Desktop Data TCP 1
      DDI_TCP_3            =   8890  # Desktop Data TCP 2
      DDI_TCP_4            =   8891  # Desktop Data TCP 3: NESS application
      DDI_TCP_5            =   8892  # Desktop Data TCP 4: FARM product
      DDI_TCP_6            =   8893  # Desktop Data TCP 5: NewsEDGE_Web application
      DDI_TCP_7            =   8894  # Desktop Data TCP 6: COAL application
      OSPF_LITE            =   8899  # ospf_lite
      JMB_CDS1             =   8900  # JMB_CDS 1
      JMB_CDS2             =   8901  # JMB_CDS 2
      MANYONE_HTTP         =   8910  # manyone_http
      MANYONE_XML          =   8911  # manyone_xml
      WCBACKUP             =   8912  # Windows Client Backup
      DRAGONFLY            =   8913  # Dragonfly System Service
      TWDS                 =   8937  # Transaction Warehouse Data Service
      UB_DNS_CONTROL       =   8953  # unbound dns nameserver control
      CUMULUS_ADMIN        =   8954  # Cumulus Admin Port
      SUNWEBADMINS         =   8989  # Sun Web Server SSL Admin Service
      HTTP_WMAP            =   8990  # webmail HTTP service
      HTTPS_WMAP           =   8991  # webmail HTTPS service
      CANTO_ROBOFLOW       =   8998  # Canto RoboFlow Control
      BCTP                 =   8999  # Brodos Crypto Trade Protocol
      CSLISTENER           =   9000  # CSlistener
      ETLSERVICEMGR        =   9001  # ETL Service Manager
      DYNAMID              =   9002  # DynamID authentication
      OGS_SERVER           =   9008  # Open Grid Services Server
      PICHAT               =   9009  # Pichat Server
      SDR                  =   9010  # Secure Data Replicator Protocol
      TAMBORA              =   9020  # TAMBORA
      PANAGOLIN_IDENT      =   9021  # Pangolin Identification
      PARAGENT             =   9022  # PrivateArk Remote Agent
      SWA_1                =   9023  # Secure Web Access _ 1
      SWA_2                =   9024  # Secure Web Access _ 2
      SWA_3                =   9025  # Secure Web Access _ 3
      SWA_4                =   9026  # Secure Web Access _ 4
      VERSIERA             =   9050  # Versiera Agent Listener
      FIO_CMGMT            =   9051  # Fusion_io Central Manager Service
      GLRPC                =   9080  # Groove GLRPC
      EMC_PP_MGMTSVC       =   9083  # EMC PowerPath Mgmt Service
      AURORA               =   9084  # IBM AURORA Performance Visualizer
      IBM_RSYSCON          =   9085  # IBM Remote System Console
      NET2DISPLAY          =   9086  # Vesa Net2Display
      CLASSIC              =   9087  # Classic Data Server
      SQLEXEC              =   9088  # IBM Informix SQL Interface
      SQLEXEC_SSL          =   9089  # IBM Informix SQL Interface _ Encrypted
      WEBSM                =   9090  # WebSM
      XMLTEC_XMLMAIL       =   9091  # xmltec_xmlmail
      XMLIPCREGSVC         =   9092  # Xml_Ipc Server Reg
      COPYCAT              =   9093  # Copycat database replication service
      HP_PDL_DATASTR       =   9100  # PDL Data Streaming Port
      PDL_DATASTREAM       =   9100  # Printer PDL Data Stream
      BACULA_DIR           =   9101  # Bacula Director
      BACULA_FD            =   9102  # Bacula File Daemon
      BACULA_SD            =   9103  # Bacula Storage Daemon
      PEERWIRE             =   9104  # PeerWire
      XADMIN               =   9105  # Xadmin Control Service
      ASTERGATE            =   9106  # Astergate Control Service
      ASTERGATEFAX         =   9107  # AstergateFax Control Service
      MXIT                 =   9119  # MXit Instant Messaging
      GRCMP                =   9122  # Global Relay compliant mobile instant messaging protocol
      GRCP                 =   9123  # Global Relay compliant instant messaging protocol
      DDDP                 =   9131  # Dynamic Device Discovery
      APANI1               =   9160  # apani1
      APANI2               =   9161  # apani2
      APANI3               =   9162  # apani3
      APANI4               =   9163  # apani4
      APANI5               =   9164  # apani5
      SUN_AS_JPDA          =   9191  # Sun AppSvr JPDA
      WAP_WSP              =   9200  # WAP connectionless session service
      WAP_WSP_WTP          =   9201  # WAP session service
      WAP_WSP_S            =   9202  # WAP secure connectionless session service
      WAP_WSP_WTP_S        =   9203  # WAP secure session service
      WAP_VCARD            =   9204  # WAP vCard
      WAP_VCAL             =   9205  # WAP vCal
      WAP_VCARD_S          =   9206  # WAP vCard Secure
      WAP_VCAL_S           =   9207  # WAP vCal Secure
      RJCDB_VCARDS         =   9208  # rjcdb vCard
      ALMOBILE_SYSTEM      =   9209  # ALMobile System Service
      OMA_MLP              =   9210  # OMA Mobile Location Protocol
      OMA_MLP_S            =   9211  # OMA Mobile Location Protocol Secure
      SERVERVIEWDBMS       =   9212  # Server View dbms access
      SERVERSTART          =   9213  # ServerStart RemoteControl
      IPDCESGBS            =   9214  # IPDC ESG BootstrapService
      INSIS                =   9215  # Integrated Setup and Install Service
      ACME                 =   9216  # Aionex Communication Management Engine
      FSC_PORT             =   9217  # FSC Communication Port
      TEAMCOHERENCE        =   9222  # QSC Team Coherence
      MON                  =   9255  # Manager On Network
      PEGASUS              =   9278  # Pegasus GPS Platform
      PEGASUS_CTL          =   9279  # Pegaus GPS System Control Interface
      PGPS                 =   9280  # Predicted GPS
      SWTP_PORT1           =   9281  # SofaWare transport port 1
      SWTP_PORT2           =   9282  # SofaWare transport port 2
      CALLWAVEIAM          =   9283  # CallWaveIAM
      VISD                 =   9284  # VERITAS Information Serve
      N2H2SERVER           =   9285  # N2H2 Filter Service Port
      CUMULUS              =   9287  # Cumulus
      ARMTECHDAEMON        =   9292  # ArmTech Daemon
      STORVIEW             =   9293  # StorView Client
      ARMCENTERHTTP        =   9294  # ARMCenter http Service
      ARMCENTERHTTPS       =   9295  # ARMCenter https Service
      VRACE                =   9300  # Virtual Racing Service
      SPHINXQL             =   9306  # Sphinx search server (MySQL listener)
      SPHINXAPI            =   9312  # Sphinx search server
      SECURE_TS            =   9318  # PKIX TimeStamp over TLS
      GUIBASE              =   9321  # guibase
      MPIDCMGR             =   9343  # MpIdcMgr
      MPHLPDMC             =   9344  # Mphlpdmc
      CTECHLICENSING       =   9346  # C Tech Licensing
      FJDMIMGR             =   9374  # fjdmimgr
      BOXP                 =   9380  # Brivs! Open Extensible Protocol
      D2DCONFIG            =   9387  # D2D Configuration Service
      D2DDATATRANS         =   9388  # D2D Data Transfer Service
      ADWS                 =   9389  # Active Directory Web Services
      OTP                  =   9390  # OpenVAS Transfer Protocol
      FJINVMGR             =   9396  # fjinvmgr
      MPIDCAGT             =   9397  # MpIdcAgt
      SEC_T4NET_SRV        =   9400  # Samsung Twain for Network Server
      SEC_T4NET_CLT        =   9401  # Samsung Twain for Network Client
      SEC_PC2FAX_SRV       =   9402  # Samsung PC2FAX for Network Server
      GIT                  =   9418  # git pack transfer service
      TUNGSTEN_HTTPS       =   9443  # WSO2 Tungsten HTTPS
      WSO2ESB_CONSOLE      =   9444  # WSO2 ESB Administration Console HTTPS
      MINDARRAY_CA         =   9445  # MindArray Systems Console Agent
      SNTLKEYSSRVR         =   9450  # Sentinel Keys Server
      ISMSERVER            =   9500  # ismserver
      MNGSUITE             =   9535  # Management Suite Remote Control
      LAES_BF              =   9536  # Surveillance buffering function
      TRISPEN_SRA          =   9555  # Trispen Secure Remote Access
      LDGATEWAY            =   9592  # LANDesk Gateway
      CBA8                 =   9593  # LANDesk Management Agent (cba8)
      MSGSYS               =   9594  # Message System
      PDS                  =   9595  # Ping Discovery Service
      MERCURY_DISC         =   9596  # Mercury Discovery
      PD_ADMIN             =   9597  # PD Administration
      VSCP                 =   9598  # Very Simple Ctrl Protocol
      ROBIX                =   9599  # Robix
      MICROMUSE_NCPW       =   9600  # MICROMUSE_NCPW
      STREAMCOMM_DS        =   9612  # StreamComm User Directory
      IADT_TLS             =   9614  # iADT Protocol over TLS
      ERUNBOOK_AGENT       =   9616  # eRunbook AgentIANA assigned this well_formed service name as a replacement for "erunbook_agent".
      ERUNBOOK_AGENT       =   9616  # eRunbook Agent
      ERUNBOOK_SERVER      =   9617  # eRunbook ServerIANA assigned this well_formed service name as a replacement for "erunbook_server".
      ERUNBOOK_SERVER      =   9617  # eRunbook Server
      CONDOR               =   9618  # Condor Collector Service
      ODBCPATHWAY          =   9628  # ODBC Pathway Service
      UNIPORT              =   9629  # UniPort SSO Controller
      PEOCTLR              =   9630  # Peovica Controller
      PEOCOLL              =   9631  # Peovica Collector
      PQSFLOWS             =   9640  # ProQueSys Flows Service
      ZOOMCP               =   9666  # Zoom Control Panel Game Server Management
      XMMS2                =   9667  # Cross_platform Music Multiplexing System
      TEC5_SDCTP           =   9668  # tec5 Spectral Device Control Protocol
      CLIENT_WAKEUP        =   9694  # T_Mobile Client Wakeup Message
      CCNX                 =   9695  # Content Centric Networking
      BOARD_ROAR           =   9700  # Board M.I.T. Service
      L5NAS_PARCHAN        =   9747  # L5NAS Parallel Channel
      BOARD_VOIP           =   9750  # Board M.I.T. Synchronous Collaboration
      RASADV               =   9753  # rasadv
      TUNGSTEN_HTTP        =   9762  # WSO2 Tungsten HTTP
      DAVSRC               =   9800  # WebDav Source Port
      SSTP_2               =   9801  # Sakura Script Transfer Protocol_2
      DAVSRCS              =   9802  # WebDAV Source TLS_SSL
      SAPV1                =   9875  # Session Announcement v1
      SD                   =   9876  # Session Director
      CYBORG_SYSTEMS       =   9888  # CYBORG Systems
      GT_PROXY             =   9889  # Port for Cable network related data proxy or repeater
      MONKEYCOM            =   9898  # MonkeyCom
      IUA                  =   9900  # IUA
      DOMAINTIME           =   9909  # domaintime
      SYPE_TRANSPORT       =   9911  # SYPECom Transport Protocol
      XYBRID_CLOUD         =   9925  # XYBRID Cloud
      APC_9950             =   9950  # APC 9950
      APC_9951             =   9951  # APC 9951
      APC_9952             =   9952  # APC 9952
      ACIS                 =   9953  # 9953
      HINP                 =   9954  # HaloteC Instrument Network Protocol
      ALLJOYN_STM          =   9955  # Contact Port for AllJoyn standard messaging
      ODNSP                =   9966  # OKI Data Network Setting Protocol
      XYBRID_RT            =   9978  # XYBRID RT Server
      DSM_SCM_TARGET       =   9987  # DSM_SCM Target Interface
      NSESRVR              =   9988  # Software Essentials Secure HTTP server
      OSM_APPSRVR          =   9990  # OSM Applet Server
      OSM_OEV              =   9991  # OSM Event Server
      PALACE_1             =   9992  # OnLive_1
      PALACE_2             =   9993  # OnLive_2
      PALACE_3             =   9994  # OnLive_3
      PALACE_4             =   9995  # Palace_4
      PALACE_5             =   9996  # Palace_5
      PALACE_6             =   9997  # Palace_6
      DISTINCT32           =   9998  # Distinct32
      DISTINCT             =   9999  # distinct
      NDMP                 =  10000  # Network Data Management Protocol
      SCP_CONFIG           =  10001  # SCP Configuration
      DOCUMENTUM           =  10002  # EMC_Documentum Content Server Product
      DOCUMENTUM_S         =  10003  # EMC_Documentum Content Server ProductIANA assigned this well_formed service name as a replacement for "documentum_s".
      DOCUMENTUM_S         =  10003  # EMC_Documentum Content Server Product
      EMCRMIRCCD           =  10004  # EMC Replication Manager Client
      EMCRMIRD             =  10005  # EMC Replication Manager Server
      NETAPP_SYNC          =  10006  # Sync replication protocol among different NetApp platforms
      MVS_CAPACITY         =  10007  # MVS Capacity
      OCTOPUS              =  10008  # Octopus Multiplexer
      SWDTP_SV             =  10009  # Systemwalker Desktop Patrol
      RXAPI                =  10010  # ooRexx rxapi services
      ZABBIX_AGENT         =  10050  # Zabbix Agent
      ZABBIX_TRAPPER       =  10051  # Zabbix Trapper
      QPTLMD               =  10055  # Quantapoint FLEXlm Licensing Service
      AMANDA               =  10080  # Amanda
      FAMDC                =  10081  # FAM Archive Server
      ITAP_DDTP            =  10100  # VERITAS ITAP DDTP
      EZMEETING_2          =  10101  # eZmeeting
      EZPROXY_2            =  10102  # eZproxy
      EZRELAY              =  10103  # eZrelay
      SWDTP                =  10104  # Systemwalker Desktop Patrol
      BCTP_SERVER          =  10107  # VERITAS BCTP, server
#      NMEA_0183            =  10110  # NMEA_0183 Navigational Data
      NETIQ_ENDPOINT       =  10113  # NetIQ Endpoint
      NETIQ_QCHECK         =  10114  # NetIQ Qcheck
      NETIQ_ENDPT          =  10115  # NetIQ Endpoint
      NETIQ_VOIPA          =  10116  # NetIQ VoIP Assessor
      IQRM                 =  10117  # NetIQ IQCResource Managament Svc
      BMC_PERF_SD          =  10128  # BMC_PERFORM_SERVICE DAEMON
      BMC_GMS              =  10129  # BMC General Manager Server
      QB_DB_SERVER         =  10160  # QB Database Server
      SNMPTLS              =  10161  # SNMP_TLS
      SNMPTLS_TRAP         =  10162  # SNMP_Trap_TLS
      TRISOAP              =  10200  # Trigence AE Soap Service
      RSMS                 =  10201  # Remote Server Management Service
      APOLLO_RELAY         =  10252  # Apollo Relay Port
      AXIS_WIMP_PORT       =  10260  # Axis WIMP Port
      BLOCKS               =  10288  # Blocks
      COSIR                =  10321  # Computer Op System Information Report
      MOS_LOWER            =  10540  # MOS Media Object Metadata Port
      MOS_UPPER            =  10541  # MOS Running Order Port
      MOS_AUX              =  10542  # MOS Low Priority Port
      MOS_SOAP             =  10543  # MOS SOAP Default Port
      MOS_SOAP_OPT         =  10544  # MOS SOAP Optional Port
      PRINTOPIA            =  10631  # Port to allow for administration and control of "Printopia" application software,      which provides printing services to mobile users
      GAP                  =  10800  # Gestor de Acaparamiento para Pocket PCs
      LPDG                 =  10805  # LUCIA Pareja Data Group
      NBD                  =  10809  # Linux Network Block Device
      HELIX                =  10860  # Helix Client_Server
      BVEAPI               =  10880  # BVEssentials HTTP API
      RMIAUX               =  10990  # Auxiliary RMI Port
      IRISA                =  11000  # IRISA
      METASYS              =  11001  # Metasys
      WEAVE                =  11095  # Nest device_to_device and device_to_service application protocol
      ORIGO_SYNC           =  11103  # OrigoDB Server Sync Interface
      NETAPP_ICMGMT        =  11104  # NetApp Intercluster Management
      NETAPP_ICDATA        =  11105  # NetApp Intercluster Data
      SGI_LK               =  11106  # SGI LK Licensing service
      SGI_DMFMGR           =  11109  # Data migration facility Manager (DMF) is a browser based interface to DMF
      SGI_SOAP             =  11110  # Data migration facility (DMF) SOAP is a web server protocol to support remote access to DMF
      VCE                  =  11111  # Viral Computing Environment (VCE)
      DICOM                =  11112  # DICOM
      SUNCACAO_SNMP        =  11161  # sun cacao snmp access point
      SUNCACAO_JMXMP       =  11162  # sun cacao JMX_remoting access point
      SUNCACAO_RMI         =  11163  # sun cacao rmi registry access point
      SUNCACAO_CSA         =  11164  # sun cacao command_streaming access point
      SUNCACAO_WEBSVC      =  11165  # sun cacao web service access point
      OEMCACAO_JMXMP       =  11172  # OEM cacao JMX_remoting access point
      T5_STRATON           =  11173  # Straton Runtime Programing
      OEMCACAO_RMI         =  11174  # OEM cacao rmi registry access point
      OEMCACAO_WEBSVC      =  11175  # OEM cacao web service access point
      SMSQP                =  11201  # smsqp
      DCSL_BACKUP          =  11202  # DCSL Network Backup Services
      WIFREE               =  11208  # WiFree Service
      MEMCACHE             =  11211  # Memory cache service
      IMIP                 =  11319  # IMIP
      IMIP_CHANNELS        =  11320  # IMIP Channels Port
      ARENA_SERVER         =  11321  # Arena Server Listen
      ATM_UHAS             =  11367  # ATM UHAS
      HKP                  =  11371  # OpenPGP HTTP Keyserver
      ASGCYPRESSTCPS       =  11489  # ASG Cypress Secure Only
      TEMPEST_PORT         =  11600  # Tempest Protocol Port
      EMC_XSW_DCONFIG      =  11623  # EMC XtremSW distributed config
      H323CALLSIGALT       =  11720  # H.323 Call Control Signalling Alternate
      EMC_XSW_DCACHE       =  11723  # EMC XtremSW distributed cache
      INTREPID_SSL         =  11751  # Intrepid SSL
      LANSCHOOL            =  11796  # LanSchool
      XORAYA               =  11876  # X2E Xoraya Multichannel protocol
      SYSINFO_SP           =  11967  # SysInfo Service Protocol
      ENTEXTXID            =  12000  # IBM Enterprise Extender SNA XID Exchange
      ENTEXTNETWK          =  12001  # IBM Enterprise Extender SNA COS Network Priority
      ENTEXTHIGH           =  12002  # IBM Enterprise Extender SNA COS High Priority
      ENTEXTMED            =  12003  # IBM Enterprise Extender SNA COS Medium Priority
      ENTEXTLOW            =  12004  # IBM Enterprise Extender SNA COS Low Priority
      DBISAMSERVER1        =  12005  # DBISAM Database Server _ Regular
      DBISAMSERVER2        =  12006  # DBISAM Database Server _ Admin
      ACCURACER            =  12007  # Accuracer Database System Server
      ACCURACER_DBMS       =  12008  # Accuracer Database System Admin
      EDBSRVR              =  12010  # ElevateDB Server
      VIPERA               =  12012  # Vipera Messaging Service
      VIPERA_SSL           =  12013  # Vipera Messaging Service over SSL Communication
      RETS_SSL             =  12109  # RETS over SSL
      NUPAPER_SS           =  12121  # NuPaper Session Service
      CAWAS                =  12168  # CA Web Access Service
      HIVEP                =  12172  # HiveP
      LINOGRIDENGINE       =  12300  # LinoGrid Engine
      RADS                 =  12302  # Remote Administration Daemon (RAD) is a system service that offers secure, remote, programmatic access to Solaris system configuration and run_time state
      WAREHOUSE_SSS        =  12321  # Warehouse Monitoring Syst SSS
      WAREHOUSE            =  12322  # Warehouse Monitoring Syst
      ITALK                =  12345  # Italk Chat System
      TSAF                 =  12753  # tsaf port
      NETPERF              =  12865  # control port for the netperf benchmark
      I_ZIPQD              =  13160  # I_ZIPQD
      BCSLOGC              =  13216  # Black Crow Software application logging
      RS_PIAS              =  13217  # R&S Proxy Installation Assistant Service
      EMC_VCAS_TCP         =  13218  # EMC Virtual CAS Service
      POWWOW_CLIENT        =  13223  # PowWow Client
      POWWOW_SERVER        =  13224  # PowWow Server
      DOIP_DATA            =  13400  # DoIP Data
      BPRD                 =  13720  # BPRD Protocol (VERITAS NetBackup)
      BPDBM                =  13721  # BPDBM Protocol (VERITAS NetBackup)
      BPJAVA_MSVC          =  13722  # BP Java MSVC Protocol
      VNETD                =  13724  # Veritas Network Utility
      BPCD                 =  13782  # VERITAS NetBackup
      VOPIED               =  13783  # VOPIED Protocol
      NBDB                 =  13785  # NetBackup Database
      NOMDB                =  13786  # Veritas_nomdb
      DSMCC_CONFIG         =  13818  # DSMCC Config
      DSMCC_SESSION        =  13819  # DSMCC Session Messages
      DSMCC_PASSTHRU       =  13820  # DSMCC Pass_Thru Messages
      DSMCC_DOWNLOAD       =  13821  # DSMCC Download Protocol
      DSMCC_CCP            =  13822  # DSMCC Channel Change Protocol
      BMDSS                =  13823  # Blackmagic Design Streaming Server
      UCONTROL             =  13894  # Ultimate Control communication protocol
      DTA_SYSTEMS          =  13929  # D_TA SYSTEMS
      MEDEVOLVE            =  13930  # MedEvolve Port Requester
      SCOTTY_FT            =  14000  # SCOTTY High_Speed Filetransfer
      SUA                  =  14001  # SUA
      SAGE_BEST_COM1       =  14033  # sage Best! Config Server 1
      SAGE_BEST_COM2       =  14034  # sage Best! Config Server 2
      VCS_APP              =  14141  # VCS Application
      ICPP                 =  14142  # IceWall Cert Protocol
      GCM_APP              =  14145  # GCM Application
      VRTS_TDD             =  14149  # Veritas Traffic Director
      VCSCMD               =  14150  # Veritas Cluster Server Command Server
      VAD                  =  14154  # Veritas Application Director
      CPS                  =  14250  # Fencing Server
      CA_WEB_UPDATE        =  14414  # CA eTrust Web Update Service
      HDE_LCESRVR_1        =  14936  # hde_lcesrvr_1
      HDE_LCESRVR_2        =  14937  # hde_lcesrvr_2
      HYDAP                =  15000  # Hypack Data Aquisition
      ONEP_TLS             =  15002  # Open Network Environment TLS
      XPILOT               =  15345  # XPilot Contact Port
#      3LINK                =  15363  # 3Link Negotiation
      CISCO_SNAT           =  15555  # Cisco Stateful NAT
      BEX_XR               =  15660  # Backup Express Restore Server
      PTP                  =  15740  # Picture Transfer Protocol
      PROGRAMMAR           =  15999  # ProGrammar Enterprise
      FMSAS                =  16000  # Administration Server Access
      FMSASCON             =  16001  # Administration Server Connector
      GSMS                 =  16002  # GoodSync Mediation Service
      JWPC                 =  16020  # Filemaker Java Web Publishing Core
      JWPC_BIN             =  16021  # Filemaker Java Web Publishing Core Binary
      SUN_SEA_PORT         =  16161  # Solaris SEA Port
      SOLARIS_AUDIT        =  16162  # Solaris Audit _ secure remote audit log
      ETB4J                =  16309  # etb4j
      PDUNCS               =  16310  # Policy Distribute, Update Notification
      PDEFMNS              =  16311  # Policy definition and update management
      NETSERIALEXT1        =  16360  # Network Serial Extension Ports One
      NETSERIALEXT2        =  16361  # Network Serial Extension Ports Two
      NETSERIALEXT3        =  16367  # Network Serial Extension Ports Three
      NETSERIALEXT4        =  16368  # Network Serial Extension Ports Four
      CONNECTED            =  16384  # Connected Corp
      XOMS                 =  16619  # X509 Objects Management Service
      NEWBAY_SNC_MC        =  16900  # Newbay Mobile Client Update Service
      SGCIP                =  16950  # Simple Generic Client Interface Protocol
      INTEL_RCI_MP         =  16991  # INTEL_RCI_MP
      AMT_SOAP_HTTP        =  16992  # Intel(R) AMT SOAP_HTTP
      AMT_SOAP_HTTPS       =  16993  # Intel(R) AMT SOAP_HTTPS
      AMT_REDIR_TCP        =  16994  # Intel(R) AMT Redirection_TCP
      AMT_REDIR_TLS        =  16995  # Intel(R) AMT Redirection_TLS
      ISODE_DUA            =  17007  # 
      VESTASDLP            =  17184  # Vestas Data Layer Protocol
      SOUNDSVIRTUAL        =  17185  # Sounds Virtual
      CHIPPER              =  17219  # Chipper
      AVTP                 =  17220  # IEEE 1722 Transport Protocol for Time Sensitive Applications
      AVDECC               =  17221  # IEEE 1722.1 AVB Discovery, Enumeration, Connection management, and Control
      INTEGRIUS_STP        =  17234  # Integrius Secure Tunnel Protocol
      SSH_MGMT             =  17235  # SSH Tectia Manager
      DB_LSP               =  17500  # Dropbox LanSync Protocol
      AILITH               =  17555  # Ailith management of routers
      EA                   =  17729  # Eclipse Aviation
      ZEP                  =  17754  # Encap. ZigBee Packets
      ZIGBEE_IP            =  17755  # ZigBee IP Transport Service
      ZIGBEE_IPS           =  17756  # ZigBee IP Transport Secure Service
      SW_ORION             =  17777  # SolarWinds Orion
      BIIMENU              =  18000  # Beckman Instruments, Inc.
      RADPDF               =  18104  # RAD PDF Service
      RACF                 =  18136  # z_OS Resource Access Control Facility
      OPSEC_CVP            =  18181  # OPSEC CVP
      OPSEC_UFP            =  18182  # OPSEC UFP
      OPSEC_SAM            =  18183  # OPSEC SAM
      OPSEC_LEA            =  18184  # OPSEC LEA
      OPSEC_OMI            =  18185  # OPSEC OMI
      OHSC                 =  18186  # Occupational Health SC
      OPSEC_ELA            =  18187  # OPSEC ELA
      CHECKPOINT_RTM       =  18241  # Check Point RTM
      ICLID                =  18242  # Checkpoint router monitoring
      CLUSTERXL            =  18243  # Checkpoint router state backup
      GV_PF                =  18262  # GV NetConfig Service
      AC_CLUSTER           =  18463  # AC Cluster
      RDS_IB               =  18634  # Reliable Datagram Service
      RDS_IP               =  18635  # Reliable Datagram Service over IP
      IQUE                 =  18769  # IQue Protocol
      INFOTOS              =  18881  # Infotos
      APC_NECMP            =  18888  # APCNECMP
      IGRID                =  19000  # iGrid Server
      SCINTILLA            =  19007  # Scintilla protocol for device services
      J_LINK               =  19020  # J_Link TCP_IP Protocol
      OPSEC_UAA            =  19191  # OPSEC UAA
      UA_SECUREAGENT       =  19194  # UserAuthority SecureAgent
      KEYSRVR              =  19283  # Key Server for SASSAFRAS
      KEYSHADOW            =  19315  # Key Shadow for SASSAFRAS
      MTRGTRANS            =  19398  # mtrgtrans
      HP_SCO               =  19410  # hp_sco
      HP_SCA               =  19411  # hp_sca
      HP_SESSMON           =  19412  # HP_SESSMON
      FXUPTP               =  19539  # FXUPTP
      SXUPTP               =  19540  # SXUPTP
      JCP                  =  19541  # JCP Client
      IEC_104_SEC          =  19998  # IEC 60870_5_104 process control _ secure
      DNP_SEC              =  19999  # Distributed Network Protocol _ Secure
      DNP                  =  20000  # DNP
      MICROSAN             =  20001  # MicroSAN
      COMMTACT_HTTP        =  20002  # Commtact HTTP
      COMMTACT_HTTPS       =  20003  # Commtact HTTPS
      OPENWEBNET           =  20005  # OpenWebNet protocol for electric network
      SS_IDI               =  20013  # Samsung Interdevice Interaction
      OPENDEPLOY           =  20014  # OpenDeploy Listener
      NBURN_ID             =  20034  # NetBurner ID PortIANA assigned this well_formed service name as a replacement for "nburn_id".
      NBURN_ID             =  20034  # NetBurner ID Port
      TMOPHL7MTS           =  20046  # TMOP HL7 Message Transfer Service
      MOUNTD               =  20048  # NFS mount protocol
      NFSRDMA              =  20049  # Network File System (NFS) over RDMA
      TOLFAB               =  20167  # TOLfab Data Change
      IPDTP_PORT           =  20202  # IPD Tunneling Port
      IPULSE_ICS           =  20222  # iPulse_ICS
      EMWAVEMSG            =  20480  # emWave Message Service
      TRACK                =  20670  # Track
      ATHAND_MMP           =  20999  # At Hand MMP
      IRTRANS              =  21000  # IRTrans Control
      NOTEZILLA_LAN        =  21010  # Notezilla.Lan Server
      RDM_TFS              =  21553  # Raima RDM TFS
      DFSERVER             =  21554  # MineScape Design File Server
      VOFR_GATEWAY         =  21590  # VoFR Gateway
      TVPM                 =  21800  # TVNC Pro Multiplexing
      WEBPHONE             =  21845  # webphone
      NETSPEAK_IS          =  21846  # NetSpeak Corp. Directory Services
      NETSPEAK_CS          =  21847  # NetSpeak Corp. Connection Services
      NETSPEAK_ACD         =  21848  # NetSpeak Corp. Automatic Call Distribution
      NETSPEAK_CPS         =  21849  # NetSpeak Corp. Credit Processing System
      SNAPENETIO           =  22000  # SNAPenetIO
      OPTOCONTROL          =  22001  # OptoControl
      OPTOHOST002          =  22002  # Opto Host Port 2
      OPTOHOST003          =  22003  # Opto Host Port 3
      OPTOHOST004          =  22004  # Opto Host Port 4
      OPTOHOST004          =  22005  # Opto Host Port 5
      DCAP                 =  22125  # dCache Access Protocol
      GSIDCAP              =  22128  # GSI dCache Access Protocol
      EASYENGINE           =  22222  # EasyEngine is CLI tool to manage WordPress Sites on Nginx server
      WNN6                 =  22273  # wnn6
      CIS                  =  22305  # CompactIS Tunnel
      CIS_SECURE           =  22343  # CompactIS Secure Tunnel
      WIBUKEY              =  22347  # WibuKey Standard WkLan
      CODEMETER            =  22350  # CodeMeter Standard
      CODEMETER_CMWAN      =  22351  # TPC_IP requests of copy protection software to a server
      CALDSOFT_BACKUP      =  22537  # CaldSoft Backup server file transfer
      VOCALTEC_WCONF       =  22555  # Vocaltec Web Conference
      TALIKASERVER         =  22763  # Talika Main Server
      AWS_BRF              =  22800  # Telerate Information Platform LAN
      BRF_GW               =  22951  # Telerate Information Platform WAN
      INOVAPORT1           =  23000  # Inova LightLink Server Type 1
      INOVAPORT2           =  23001  # Inova LightLink Server Type 2
      INOVAPORT3           =  23002  # Inova LightLink Server Type 3
      INOVAPORT4           =  23003  # Inova LightLink Server Type 4
      INOVAPORT5           =  23004  # Inova LightLink Server Type 5
      INOVAPORT6           =  23005  # Inova LightLink Server Type 6
      GNTP                 =  23053  # Generic Notification Transport Protocol
      ELXMGMT              =  23333  # Emulex HBAnyware Remote Management
      NOVAR_DBASE          =  23400  # Novar Data
      NOVAR_ALARM          =  23401  # Novar Alarm
      NOVAR_GLOBAL         =  23402  # Novar Global
      AEQUUS               =  23456  # Aequus Service
      AEQUUS_ALT           =  23457  # Aequus Service Mgmt
      AREAGUARD_NEO        =  23546  # AreaGuard Neo _ WebServer
      MED_LTP              =  24000  # med_ltp
      MED_FSP_RX           =  24001  # med_fsp_rx
      MED_FSP_TX           =  24002  # med_fsp_tx
      MED_SUPP             =  24003  # med_supp
      MED_OVW              =  24004  # med_ovw
      MED_CI               =  24005  # med_ci
      MED_NET_SVC          =  24006  # med_net_svc
      FILESPHERE           =  24242  # fileSphere
#      VISTA_4GL            =  24249  # Vista 4GL
      ILD                  =  24321  # Isolv Local Directory
      INTEL_RCI            =  24386  # Intel RCIIANA assigned this well_formed service name as a replacement for "intel_rci".
      INTEL_RCI            =  24386  # Intel RCI
      TONIDODS             =  24465  # Tonido Domain Server
      BINKP                =  24554  # BINKP
      BILOBIT              =  24577  # bilobit Service
      CANDITV              =  24676  # Canditv Message Service
      FLASHFILER           =  24677  # FlashFiler
      PROACTIVATE          =  24678  # Turbopower Proactivate
      TCC_HTTP             =  24680  # TCC User HTTP Service
      CSLG                 =  24754  # Citrix StorageLink Gateway
      FIND                 =  24922  # Find Identification of Network Devices
      ICL_TWOBASE1         =  25000  # icl_twobase1
      ICL_TWOBASE2         =  25001  # icl_twobase2
      ICL_TWOBASE3         =  25002  # icl_twobase3
      ICL_TWOBASE4         =  25003  # icl_twobase4
      ICL_TWOBASE5         =  25004  # icl_twobase5
      ICL_TWOBASE6         =  25005  # icl_twobase6
      ICL_TWOBASE7         =  25006  # icl_twobase7
      ICL_TWOBASE8         =  25007  # icl_twobase8
      ICL_TWOBASE9         =  25008  # icl_twobase9
      ICL_TWOBASE10        =  25009  # icl_twobase10
      SAUTERDONGLE         =  25576  # Sauter Dongle
      IDTP                 =  25604  # Identifier Tracing Protocol
      VOCALTEC_HOS         =  25793  # Vocaltec Address Server
      TASP_NET             =  25900  # TASP Network Comm
      NIOBSERVER           =  25901  # NIObserver
      NILINKANALYST        =  25902  # NILinkAnalyst
      NIPROBE              =  25903  # NIProbe
      QUAKE                =  26000  # quake
      SCSCP                =  26133  # Symbolic Computation Software Composability Protocol
      WNN6_DS              =  26208  # wnn6_ds
      EZPROXY              =  26260  # eZproxy
      EZMEETING            =  26261  # eZmeeting
      K3SOFTWARE_SVR       =  26262  # K3 Software_Server
      K3SOFTWARE_CLI       =  26263  # K3 Software_Client
      EXOLINE_TCP          =  26486  # EXOline_TCP
      EXOCONFIG            =  26487  # EXOconfig
      EXONET               =  26489  # EXOnet
      IMAGEPUMP            =  27345  # ImagePump
      JESMSJC              =  27442  # Job controller service
      KOPEK_HTTPHEAD       =  27504  # Kopek HTTP Head Port
      ARS_VISTA            =  27782  # ARS VISTA Application
      ASTROLINK            =  27876  # Astrolink Protocol
      TW_AUTH_KEY          =  27999  # TW Authentication_Key Distribution and
      NXLMD                =  28000  # NX License Manager
      PQSP                 =  28001  # PQ Service
      VOXELSTORM           =  28200  # VoxelStorm game server
      SIEMENSGSM           =  28240  # Siemens GSM
      OTMP                 =  29167  # ObTools Message Protocol
      BINGBANG             =  29999  # data exchange protocol for IEC61850 in wind power plants
      NDMPS                =  30000  # Secure Network Data Management Protocol
      PAGO_SERVICES1       =  30001  # Pago Services 1
      PAGO_SERVICES2       =  30002  # Pago Services 2
      AMICON_FPSU_RA       =  30003  # Amicon FPSU_IP Remote Administration
      KINGDOMSONLINE       =  30260  # Kingdoms Online (CraigAvenue)
      OVOBS                =  30999  # OpenView Service Desk Client
      AUTOTRAC_ACP         =  31020  # Autotrac ACP 245
      PACE_LICENSED        =  31400  # PACE license server
      XQOSD                =  31416  # XQoS network monitor
      TETRINET             =  31457  # TetriNET Protocol
      LM_MON               =  31620  # lm mon
      DSX_MONITOR          =  31685  # DS Expert MonitorIANA assigned this well_formed service name as a replacement for "dsx_monitor".
      DSX_MONITOR          =  31685  # DS Expert Monitor
      GAMESMITH_PORT       =  31765  # GameSmith Port
      ICEEDCP_TX           =  31948  # Embedded Device Configuration Protocol TXIANA assigned this well_formed service name as a replacement for "iceedcp_tx".
      ICEEDCP_TX           =  31948  # Embedded Device Configuration Protocol TX
      ICEEDCP_RX           =  31949  # Embedded Device Configuration Protocol RXIANA assigned this well_formed service name as a replacement for "iceedcp_rx".
      ICEEDCP_RX           =  31949  # Embedded Device Configuration Protocol RX
      IRACINGHELPER        =  32034  # iRacing helper service
      T1DISTPROC60         =  32249  # T1 Distributed Processor
      APM_LINK             =  32483  # Access Point Manager Link
      SEC_NTB_CLNT         =  32635  # SecureNotebook_CLNT
      DMEXPRESS            =  32636  # DMExpress
      FILENET_POWSRM       =  32767  # FileNet BPM WS_ReliableMessaging Client
      FILENET_TMS          =  32768  # Filenet TMS
      FILENET_RPC          =  32769  # Filenet RPC
      FILENET_NCH          =  32770  # Filenet NCH
      FILENET_RMI          =  32771  # FileNET RMI
      FILENET_PA           =  32772  # FileNET Process Analyzer
      FILENET_CM           =  32773  # FileNET Component Manager
      FILENET_RE           =  32774  # FileNET Rules Engine
      FILENET_PCH          =  32775  # Performance Clearinghouse
      FILENET_PEIOR        =  32776  # FileNET BPM IOR
      FILENET_OBROK        =  32777  # FileNet BPM CORBA
      MLSN                 =  32801  # Multiple Listing Service Network
      RETP                 =  32811  # Real Estate Transport Protocol
      IDMGRATM             =  32896  # Attachmate ID Manager
      AURORA_BALAENA       =  33123  # Aurora (Balaena Ltd)
      DIAMONDPORT          =  33331  # DiamondCentral Interface
      DGI_SERV             =  33333  # Digital Gaslight Service
      SPEEDTRACE           =  33334  # SpeedTrace TraceAgent
      TRACEROUTE           =  33434  # traceroute use
      SNIP_SLAVE           =  33656  # SNIP Slave
      TURBONOTE_2          =  34249  # TurboNote Relay Server Default Port
      P_NET_LOCAL          =  34378  # P_Net on IP local
      P_NET_REMOTE         =  34379  # P_Net on IP remote
      DHANALAKSHMI         =  34567  # dhanalakshmi.org EDI Service
      PROFINET_RT          =  34962  # PROFInet RT Unicast
      PROFINET_RTM         =  34963  # PROFInet RT Multicast
      PROFINET_CM          =  34964  # PROFInet Context Manager
      ETHERCAT             =  34980  # EtherCAT Port
      HEATHVIEW            =  35000  # HeathView
      RT_VIEWER            =  35001  # ReadyTech Viewer
      RT_SOUND             =  35002  # ReadyTech Sound Server
      RT_DEVICEMAPPER      =  35003  # ReadyTech DeviceMapper Server
      RT_CLASSMANAGER      =  35004  # ReadyTech ClassManager
      RT_LABTRACKER        =  35005  # ReadyTech LabTracker
      RT_HELPER            =  35006  # ReadyTech Helper Service
      KITIM                =  35354  # KIT Messenger
      ALTOVA_LM            =  35355  # Altova License Management
      GUTTERSNEX           =  35356  # Gutters Note Exchange
      OPENSTACK_ID         =  35357  # OpenStack ID Service
      ALLPEERS             =  36001  # AllPeers Network
      FEBOOTI_AW           =  36524  # Febooti Automation Workshop
      OBSERVIUM_AGENT      =  36602  # Observium statistics collection agent
      KASTENXPIPE          =  36865  # KastenX Pipe
      NECKAR               =  37475  # science + computing's Venus Administration Port
      GDRIVE_SYNC          =  37483  # Google Drive Sync
      UNISYS_EPORTAL       =  37654  # Unisys ClearPath ePortal
      IVS_DATABASE         =  38000  # InfoVista Server Database
      IVS_INSERTION        =  38001  # InfoVista Server Insertion
      GALAXY7_DATA         =  38201  # Galaxy7 Data Tunnel
      FAIRVIEW             =  38202  # Fairview Message Service
      AGPOLICY             =  38203  # AppGate Policy Server
      SRUTH                =  38800  # Sruth is a service for the distribution of routinely_      generated but arbitrary files based on a publish_subscribe      distribution model and implemented using a peer_to_peer transport      mechanism
      SECRMMSAFECOPYA      =  38865  # Security approval process for use of the secRMM SafeCopy program
      TURBONOTE_1          =  39681  # TurboNote Default Port
      SAFETYNETP           =  40000  # SafetyNET p
      SPTX                 =  40404  # Simplify Printing TX
      CSCP                 =  40841  # CSCP
      CSCCREDIR            =  40842  # CSCCREDIR
      CSCCFIREWALL         =  40843  # CSCCFIREWALL
      FS_QOS               =  41111  # Foursticks QoS Protocol
      TENTACLE             =  41121  # Tentacle Server
      CRESTRON_CIP         =  41794  # Crestron Control Port
      CRESTRON_CTP         =  41795  # Crestron Terminal Port
      CRESTRON_CIPS        =  41796  # Crestron Secure Control Port
      CRESTRON_CTPS        =  41797  # Crestron Secure Terminal Port
      CANDP                =  42508  # Computer Associates network discovery protocol
      CANDRP               =  42509  # CA discovery response
      CAERPC               =  42510  # CA eTrust RPC
      RECVR_RC             =  43000  # Receiver Remote Control
      REACHOUT             =  43188  # REACHOUT
      NDM_AGENT_PORT       =  43189  # NDM_AGENT_PORT
      IP_PROVISION         =  43190  # IP_PROVISION
      NOIT_TRANSPORT       =  43191  # Reconnoiter Agent Data Transport
      SHAPERAI             =  43210  # Shaper Automation Server Management
      EQ3_UPDATE           =  43439  # EQ3 firmware update
      EW_MGMT              =  43440  # Cisco EnergyWise Management
      CISCOCSDB            =  43441  # Cisco NetMgmt DB Ports
      Z_WAVE_S             =  44123  # Z_Wave Secure Tunnel
      PMCD                 =  44321  # PCP server (pmcd)
      PMCDPROXY            =  44322  # PCP server (pmcd) proxy
      PMWEBAPI             =  44323  # HTTP binding for Performance Co_Pilot client API
      COGNEX_DATAMAN       =  44444  # Cognex DataMan Management Protocol
      RBR_DEBUG            =  44553  # REALbasic Remote Debug
      ETHERNET_IP_2        =  44818  # EtherNet_IP messagingIANA assigned this well_formed service name as a replacement for "EtherNet_IP_2".
      ETHERNET_IP_2        =  44818  # EtherNet_IP messaging
      M3DA                 =  44900  # M3DA is used for efficient machine_to_machine communications
      ASMP                 =  45000  # NSi AutoStore Status Monitoring Protocol data transfer
      ASMPS                =  45001  # NSi AutoStore Status Monitoring Protocol secure data transfer
      SYNCTEST             =  45045  # Remote application control protocol
      INVISION_AG          =  45054  # InVision AG
      EBA                  =  45678  # EBA PRISE
      DAI_SHELL            =  45824  # Server for the DAI family of client_server products
      QDB2SERVICE          =  45825  # Qpuncture Data Access Service
      SSR_SERVERMGR        =  45966  # SSRServerMgr
      SPREMOTETABLET       =  46998  # Connection between a desktop computer or server and a signature tablet to capture handwritten signatures
      MEDIABOX             =  46999  # MediaBox Server
      MBUS                 =  47000  # Message Bus
      WINRM                =  47001  # Windows Remote Management Service
      DBBROWSE             =  47557  # Databeam Corporation
      DIRECTPLAYSRVR       =  47624  # Direct Play Server
      AP                   =  47806  # ALC Protocol
      BACNET               =  47808  # Building Automation and Control Networks
      NIMCONTROLLER        =  48000  # Nimbus Controller
      NIMSPOOLER           =  48001  # Nimbus Spooler
      NIMHUB               =  48002  # Nimbus Hub
      NIMGTW               =  48003  # Nimbus Gateway
      NIMBUSDB             =  48004  # NimbusDB Connector
      NIMBUSDBCTRL         =  48005  # NimbusDB Control
#      3GPP_CBSP            =  48049  # 3GPP Cell Broadcast Service Protocol
      WEANDSF              =  48050  # WeFi Access Network Discovery and Selection Function
      ISNETSERV            =  48128  # Image Systems Network Services
      BLP5                 =  48129  # Bloomberg locator
      COM_BARDAC_DW        =  48556  # com_bardac_dw
      IQOBJECT             =  48619  # iqobject
      ROBOTRACONTEUR       =  48653  # Robot Raconteur transport
      MATAHARI             =  49000  # Matahari Broker
      map = {
      'TCPMUX'             : 1    , # TCP Port Service Multiplexer
      'COMPRESSNET'        : 2    , # Management Utility
      'COMPRESSNET'        : 3    , # Compression Process
      'RJE'                : 5    , # Remote Job Entry
      'ECHO'               : 7    , # Echo
      'DISCARD'            : 9    , # Discard
      'SYSTAT'             : 11   , # Active Users
      'DAYTIME'            : 13   , # Daytime
      'QOTD'               : 17   , # Quote of the Day
      'MSP'                : 18   , # Message Send Protocol (historic)
      'CHARGEN'            : 19   , # Character Generator
      'FTP_DATA'           : 20   , # File Transfer
      'FTP'                : 21   , # File Transfer
      'SSH'                : 22   , # The Secure Shell (SSH) Protocol
      'TELNET'             : 23   , # Telnet
      'SMTP'               : 25   , # Simple Mail Transfer
      'NSW_FE'             : 27   , # NSW User System FE
      'MSG_ICP'            : 29   , # MSG ICP
      'MSG_AUTH'           : 31   , # MSG Authentication
      'DSP'                : 33   , # Display Support Protocol
      'TIME'               : 37   , # Time
      'RAP'                : 38   , # Route Access Protocol
      'RLP'                : 39   , # Resource Location Protocol
      'GRAPHICS'           : 41   , # Graphics
      'NAME'               : 42   , # Host Name Server
      'NAMESERVER'         : 42   , # Host Name Server
      'NICNAME'            : 43   , # Who Is
      'MPM_FLAGS'          : 44   , # MPM FLAGS Protocol
      'MPM'                : 45   , # Message Processing Module
      'MPM_SND'            : 46   , # MPM
      'NI_FTP'             : 47   , # NI FTP
      'AUDITD'             : 48   , # Digital Audit Daemon
      'TACACS'             : 49   , # Login Host Protocol (TACACS)
      'RE_MAIL_CK'         : 50   , # Remote Mail Checking Protocol
      'XNS_TIME'           : 52   , # XNS Time Protocol
      'DOMAIN'             : 53   , # Domain Name Server
      'XNS_CH'             : 54   , # XNS Clearinghouse
      'ISI_GL'             : 55   , # ISI Graphics Language
      'XNS_AUTH'           : 56   , # XNS Authentication
      'XNS_MAIL'           : 58   , # XNS Mail
      'NI_MAIL'            : 61   , # NI MAIL
      'ACAS'               : 62   , # ACA Services
      'WHOISPP'            : 63   , # whois++IANA assigned this well_formed service name as a replacement for "whois++".
      'WHOIS++'            : 63   , # whois++
      'COVIA'              : 64   , # Communications Integrator (CI)
      'TACACS_DS'          : 65   , # TACACS_Database Service
      'SQL_NET'            : 66   , # Oracle SQL_NETIANA assigned this well_formed service name as a replacement for "sql_net".
      'SQL_NET'            : 66   , # Oracle SQL_NET
      'BOOTPS'             : 67   , # Bootstrap Protocol Server
      'BOOTPC'             : 68   , # Bootstrap Protocol Client
      'TFTP'               : 69   , # Trivial File Transfer
      'GOPHER'             : 70   , # Gopher
      'NETRJS_1'           : 71   , # Remote Job Service
      'NETRJS_2'           : 72   , # Remote Job Service
      'NETRJS_3'           : 73   , # Remote Job Service
      'NETRJS_4'           : 74   , # Remote Job Service
      'DEOS'               : 76   , # Distributed External Object Store
      'VETTCP'             : 78   , # vettcp
      'FINGER'             : 79   , # Finger
      'HTTP'               : 80   , # World Wide Web HTTP Defined TXT keys: u=<username> p=<password> path=<path to document>
      'XFER'               : 82   , # XFER Utility
      'MIT_ML_DEV'         : 83   , # MIT ML Device
      'CTF'                : 84   , # Common Trace Facility
      'MIT_ML_DEV'         : 85   , # MIT ML Device
      'MFCOBOL'            : 86   , # Micro Focus Cobol
      'KERBEROS'           : 88   , # Kerberos
      'SU_MIT_TG'          : 89   , # SU_MIT Telnet Gateway
      'DNSIX'              : 90   , # DNSIX Securit Attribute Token Map
      'MIT_DOV'            : 91   , # MIT Dover Spooler
      'NPP'                : 92   , # Network Printing Protocol
      'DCP'                : 93   , # Device Control Protocol
      'OBJCALL'            : 94   , # Tivoli Object Dispatcher
      'SUPDUP'             : 95   , # SUPDUP
      'DIXIE'              : 96   , # DIXIE Protocol Specification
      'SWIFT_RVF'          : 97   , # Swift Remote Virtural File Protocol
      'TACNEWS'            : 98   , # TAC News
      'METAGRAM'           : 99   , # Metagram Relay
      'HOSTNAME'           : 101  , # NIC Host Name Server
      'ISO_TSAP'           : 102  , # ISO_TSAP Class 0
      'GPPITNP'            : 103  , # Genesis Point_to_Point Trans Net
      'ACR_NEMA'           : 104  , # ACR_NEMA Digital Imag. & Comm. 300
      'CSO'                : 105  , # CCSO name server protocol
      'CSNET_NS'           : 105  , # Mailbox Name Nameserver
      '3COM_TSMUX'         : 106  , # 3COM_TSMUX
      'RTELNET'            : 107  , # Remote Telnet Service
      'SNAGAS'             : 108  , # SNA Gateway Access Server
      'POP2'               : 109  , # Post Office Protocol _ Version 2
      'POP3'               : 110  , # Post Office Protocol _ Version 3
      'SUNRPC'             : 111  , # SUN Remote Procedure Call
      'MCIDAS'             : 112  , # McIDAS Data Transmission Protocol
      'IDENT'              : 113  , # 
      'AUTH'               : 113  , # Authentication Service
      'SFTP'               : 115  , # Simple File Transfer Protocol
      'ANSANOTIFY'         : 116  , # ANSA REX Notify
      'UUCP_PATH'          : 117  , # UUCP Path Service
      'SQLSERV'            : 118  , # SQL Services
      'NNTP'               : 119  , # Network News Transfer Protocol
      'CFDPTKT'            : 120  , # CFDPTKT
      'ERPC'               : 121  , # Encore Expedited Remote Pro.Call
      'SMAKYNET'           : 122  , # SMAKYNET
      'NTP'                : 123  , # Network Time Protocol
      'ANSATRADER'         : 124  , # ANSA REX Trader
      'LOCUS_MAP'          : 125  , # Locus PC_Interface Net Map Ser
      'NXEDIT'             : 126  , # NXEdit
      'LOCUS_CON'          : 127  , # Locus PC_Interface Conn Server
      'GSS_XLICEN'         : 128  , # GSS X License Verification
      'PWDGEN'             : 129  , # Password Generator Protocol
      'CISCO_FNA'          : 130  , # cisco FNATIVE
      'CISCO_TNA'          : 131  , # cisco TNATIVE
      'CISCO_SYS'          : 132  , # cisco SYSMAINT
      'STATSRV'            : 133  , # Statistics Service
      'INGRES_NET'         : 134  , # INGRES_NET Service
      'EPMAP'              : 135  , # DCE endpoint resolution
      'PROFILE'            : 136  , # PROFILE Naming System
      'NETBIOS_NS'         : 137  , # NETBIOS Name Service
      'NETBIOS_DGM'        : 138  , # NETBIOS Datagram Service
      'NETBIOS_SSN'        : 139  , # NETBIOS Session Service
      'EMFIS_DATA'         : 140  , # EMFIS Data Service
      'EMFIS_CNTL'         : 141  , # EMFIS Control Service
      'BL_IDM'             : 142  , # Britton_Lee IDM
      'IMAP'               : 143  , # Internet Message Access Protocol
      'UMA'                : 144  , # Universal Management Architecture
      'UAAC'               : 145  , # UAAC Protocol
      'ISO_TP0'            : 146  , # ISO_IP0
      'ISO_IP'             : 147  , # ISO_IP
      'JARGON'             : 148  , # Jargon
      'AED_512'            : 149  , # AED 512 Emulation Service
      'SQL_NET'            : 150  , # SQL_NET
      'HEMS'               : 151  , # HEMS
      'BFTP'               : 152  , # Background File Transfer Program
      'SGMP'               : 153  , # SGMP
      'NETSC_PROD'         : 154  , # NETSC
      'NETSC_DEV'          : 155  , # NETSC
      'SQLSRV'             : 156  , # SQL Service
      'KNET_CMP'           : 157  , # KNET_VM Command_Message Protocol
      'PCMAIL_SRV'         : 158  , # PCMail Server
      'NSS_ROUTING'        : 159  , # NSS_Routing
      'SGMP_TRAPS'         : 160  , # SGMP_TRAPS
      'SNMP'               : 161  , # SNMP
      'SNMPTRAP'           : 162  , # SNMPTRAP
      'CMIP_MAN'           : 163  , # CMIP_TCP Manager
      'CMIP_AGENT'         : 164  , # CMIP_TCP Agent
      'XNS_COURIER'        : 165  , # Xerox
      'S_NET'              : 166  , # Sirius Systems
      'NAMP'               : 167  , # NAMP
      'RSVD'               : 168  , # RSVD
      'SEND'               : 169  , # SEND
      'PRINT_SRV'          : 170  , # Network PostScript
      'MULTIPLEX'          : 171  , # Network Innovations Multiplex
      'CL_1'               : 172  , # Network Innovations CL_1IANA assigned this well_formed service name as a replacement for "cl_1".
      'CL_1'               : 172  , # Network Innovations CL_1
      'XYPLEX_MUX'         : 173  , # Xyplex
      'MAILQ'              : 174  , # MAILQ
      'VMNET'              : 175  , # VMNET
      'GENRAD_MUX'         : 176  , # GENRAD_MUX
      'XDMCP'              : 177  , # X Display Manager Control Protocol
      'NEXTSTEP'           : 178  , # NextStep Window Server
      'BGP'                : 179  , # Border Gateway Protocol
      'RIS'                : 180  , # Intergraph
      'UNIFY'              : 181  , # Unify
      'AUDIT'              : 182  , # Unisys Audit SITP
      'OCBINDER'           : 183  , # OCBinder
      'OCSERVER'           : 184  , # OCServer
      'REMOTE_KIS'         : 185  , # Remote_KIS
      'KIS'                : 186  , # KIS Protocol
      'ACI'                : 187  , # Application Communication Interface
      'MUMPS'              : 188  , # Plus Five's MUMPS
      'QFT'                : 189  , # Queued File Transport
      'GACP'               : 190  , # Gateway Access Control Protocol
      'PROSPERO'           : 191  , # Prospero Directory Service
      'OSU_NMS'            : 192  , # OSU Network Monitoring System
      'SRMP'               : 193  , # Spider Remote Monitoring Protocol
      'IRC'                : 194  , # Internet Relay Chat Protocol
      'DN6_NLM_AUD'        : 195  , # DNSIX Network Level Module Audit
      'DN6_SMM_RED'        : 196  , # DNSIX Session Mgt Module Audit Redir
      'DLS'                : 197  , # Directory Location Service
      'DLS_MON'            : 198  , # Directory Location Service Monitor
      'SMUX'               : 199  , # SMUX
      'SRC'                : 200  , # IBM System Resource Controller
      'AT_RTMP'            : 201  , # AppleTalk Routing Maintenance
      'AT_NBP'             : 202  , # AppleTalk Name Binding
      'AT_3'               : 203  , # AppleTalk Unused
      'AT_ECHO'            : 204  , # AppleTalk Echo
      'AT_5'               : 205  , # AppleTalk Unused
      'AT_ZIS'             : 206  , # AppleTalk Zone Information
      'AT_7'               : 207  , # AppleTalk Unused
      'AT_8'               : 208  , # AppleTalk Unused
      'QMTP'               : 209  , # The Quick Mail Transfer Protocol
      'Z39_50'             : 210  , # ANSI Z39.50IANA assigned this well_formed service name as a replacement for "z39.50".
      'Z39.50'             : 210  , # ANSI Z39.50
      '914C_G'             : 211  , # Texas Instruments 914C_G TerminalIANA assigned this well_formed service name as a replacement for "914c_g".
      '914C_G'             : 211  , # Texas Instruments 914C_G Terminal
      'ANET'               : 212  , # ATEXSSTR
      'IPX'                : 213  , # IPX
      'VMPWSCS'            : 214  , # VM PWSCS
      'SOFTPC'             : 215  , # Insignia Solutions
      'CAILIC'             : 216  , # Computer Associates Int'l License Server
      'DBASE'              : 217  , # dBASE Unix
      'MPP'                : 218  , # Netix Message Posting Protocol
      'UARPS'              : 219  , # Unisys ARPs
      'IMAP3'              : 220  , # Interactive Mail Access Protocol v3
      'FLN_SPX'            : 221  , # Berkeley rlogind with SPX auth
      'RSH_SPX'            : 222  , # Berkeley rshd with SPX auth
      'CDC'                : 223  , # Certificate Distribution Center
      'MASQDIALER'         : 224  , # masqdialer
      'DIRECT'             : 242  , # Direct
      'SUR_MEAS'           : 243  , # Survey Measurement
      'INBUSINESS'         : 244  , # inbusiness
      'LINK'               : 245  , # LINK
      'DSP3270'            : 246  , # Display Systems Protocol
      'SUBNTBCST_TFTP'     : 247  , # SUBNTBCST_TFTPIANA assigned this well_formed service name as a replacement for "subntbcst_tftp".
      'SUBNTBCST_TFTP'     : 247  , # SUBNTBCST_TFTP
      'BHFHS'              : 248  , # bhfhs
      'RAP'                : 256  , # RAP
      'SET'                : 257  , # Secure Electronic Transaction
      'ESRO_GEN'           : 259  , # Efficient Short Remote Operations
      'OPENPORT'           : 260  , # Openport
      'NSIIOPS'            : 261  , # IIOP Name Service over TLS_SSL
      'ARCISDMS'           : 262  , # Arcisdms
      'HDAP'               : 263  , # HDAP
      'BGMP'               : 264  , # BGMP
      'X_BONE_CTL'         : 265  , # X_Bone CTL
      'SST'                : 266  , # SCSI on ST
      'TD_SERVICE'         : 267  , # Tobit David Service Layer
      'TD_REPLICA'         : 268  , # Tobit David Replica
      'MANET'              : 269  , # MANET Protocols
      'PT_TLS'             : 271  , # IETF Network Endpoint Assessment (NEA) Posture Transport Protocol over TLS (PT_TLS)
      'HTTP_MGMT'          : 280  , # http_mgmt
      'PERSONAL_LINK'      : 281  , # Personal Link
      'CABLEPORT_AX'       : 282  , # Cable Port A_X
      'RESCAP'             : 283  , # rescap
      'CORERJD'            : 284  , # corerjd
      'FXP'                : 286  , # FXP Communication
      'K_BLOCK'            : 287  , # K_BLOCK
      'NOVASTORBAKCUP'     : 308  , # Novastor Backup
      'ENTRUSTTIME'        : 309  , # EntrustTime
      'BHMDS'              : 310  , # bhmds
      'ASIP_WEBADMIN'      : 311  , # AppleShare IP WebAdmin
      'VSLMP'              : 312  , # VSLMP
      'MAGENTA_LOGIC'      : 313  , # Magenta Logic
      'OPALIS_ROBOT'       : 314  , # Opalis Robot
      'DPSI'               : 315  , # DPSI
      'DECAUTH'            : 316  , # decAuth
      'ZANNET'             : 317  , # Zannet
      'PKIX_TIMESTAMP'     : 318  , # PKIX TimeStamp
      'PTP_EVENT'          : 319  , # PTP Event
      'PTP_GENERAL'        : 320  , # PTP General
      'PIP'                : 321  , # PIP
      'RTSPS'              : 322  , # RTSPS
      'RPKI_RTR'           : 323  , # Resource PKI to Router Protocol
      'RPKI_RTR_TLS'       : 324  , # Resource PKI to Router Protocol over TLS
      'TEXAR'              : 333  , # Texar Security Port
      'PDAP'               : 344  , # Prospero Data Access Protocol
      'PAWSERV'            : 345  , # Perf Analysis Workbench
      'ZSERV'              : 346  , # Zebra server
      'FATSERV'            : 347  , # Fatmen Server
      'CSI_SGWP'           : 348  , # Cabletron Management Protocol
      'MFTP'               : 349  , # mftp
      'MATIP_TYPE_A'       : 350  , # MATIP Type A
      'MATIP_TYPE_B'       : 351  , # MATIP Type B
      'BHOETTY'            : 351  , # bhoetty
      'DTAG_STE_SB'        : 352  , # DTAG
      'BHOEDAP4'           : 352  , # bhoedap4
      'NDSAUTH'            : 353  , # NDSAUTH
      'BH611'              : 354  , # bh611
      'DATEX_ASN'          : 355  , # DATEX_ASN
      'CLOANTO_NET_1'      : 356  , # Cloanto Net 1
      'BHEVENT'            : 357  , # bhevent
      'SHRINKWRAP'         : 358  , # Shrinkwrap
      'NSRMP'              : 359  , # Network Security Risk Management Protocol
      'SCOI2ODIALOG'       : 360  , # scoi2odialog
      'SEMANTIX'           : 361  , # Semantix
      'SRSSEND'            : 362  , # SRS Send
      'RSVP_TUNNEL'        : 363  , # RSVP TunnelIANA assigned this well_formed service name as a replacement for "rsvp_tunnel".
      'RSVP_TUNNEL'        : 363  , # RSVP Tunnel
      'AURORA_CMGR'        : 364  , # Aurora CMGR
      'DTK'                : 365  , # DTK
      'ODMR'               : 366  , # ODMR
      'MORTGAGEWARE'       : 367  , # MortgageWare
      'QBIKGDP'            : 368  , # QbikGDP
      'RPC2PORTMAP'        : 369  , # rpc2portmap
      'CODAAUTH2'          : 370  , # codaauth2
      'CLEARCASE'          : 371  , # Clearcase
      'ULISTPROC'          : 372  , # ListProcessor
      'LEGENT_1'           : 373  , # Legent Corporation
      'LEGENT_2'           : 374  , # Legent Corporation
      'HASSLE'             : 375  , # Hassle
      'NIP'                : 376  , # Amiga Envoy Network Inquiry Proto
      'TNETOS'             : 377  , # NEC Corporation
      'DSETOS'             : 378  , # NEC Corporation
      'IS99C'              : 379  , # TIA_EIA_IS_99 modem client
      'IS99S'              : 380  , # TIA_EIA_IS_99 modem server
      'HP_COLLECTOR'       : 381  , # hp performance data collector
      'HP_MANAGED_NODE'    : 382  , # hp performance data managed node
      'HP_ALARM_MGR'       : 383  , # hp performance data alarm manager
      'ARNS'               : 384  , # A Remote Network Server System
      'IBM_APP'            : 385  , # IBM Application
      'ASA'                : 386  , # ASA Message Router Object Def.
      'AURP'               : 387  , # Appletalk Update_Based Routing Pro.
      'UNIDATA_LDM'        : 388  , # Unidata LDM
      'LDAP'               : 389  , # Lightweight Directory Access Protocol
      'UIS'                : 390  , # UIS
      'SYNOTICS_RELAY'     : 391  , # SynOptics SNMP Relay Port
      'SYNOTICS_BROKER'    : 392  , # SynOptics Port Broker Port
      'META5'              : 393  , # Meta5
      'EMBL_NDT'           : 394  , # EMBL Nucleic Data Transfer
      'NETCP'              : 395  , # NetScout Control Protocol
      'NETWARE_IP'         : 396  , # Novell Netware over IP
      'MPTN'               : 397  , # Multi Protocol Trans. Net.
      'KRYPTOLAN'          : 398  , # Kryptolan
      'ISO_TSAP_C2'        : 399  , # ISO Transport Class 2 Non_Control over TCP
      'OSB_SD'             : 400  , # Oracle Secure Backup
      'UPS'                : 401  , # Uninterruptible Power Supply
      'GENIE'              : 402  , # Genie Protocol
      'DECAP'              : 403  , # decap
      'NCED'               : 404  , # nced
      'NCLD'               : 405  , # ncld
      'IMSP'               : 406  , # Interactive Mail Support Protocol
      'TIMBUKTU'           : 407  , # Timbuktu
      'PRM_SM'             : 408  , # Prospero Resource Manager Sys. Man.
      'PRM_NM'             : 409  , # Prospero Resource Manager Node Man.
      'DECLADEBUG'         : 410  , # DECLadebug Remote Debug Protocol
      'RMT'                : 411  , # Remote MT Protocol
      'SYNOPTICS_TRAP'     : 412  , # Trap Convention Port
      'SMSP'               : 413  , # Storage Management Services Protocol
      'INFOSEEK'           : 414  , # InfoSeek
      'BNET'               : 415  , # BNet
      'SILVERPLATTER'      : 416  , # Silverplatter
      'ONMUX'              : 417  , # Onmux
      'HYPER_G'            : 418  , # Hyper_G
      'ARIEL1'             : 419  , # Ariel 1
      'SMPTE'              : 420  , # SMPTE
      'ARIEL2'             : 421  , # Ariel 2
      'ARIEL3'             : 422  , # Ariel 3
      'OPC_JOB_START'      : 423  , # IBM Operations Planning and Control Start
      'OPC_JOB_TRACK'      : 424  , # IBM Operations Planning and Control Track
      'ICAD_EL'            : 425  , # ICAD
      'SMARTSDP'           : 426  , # smartsdp
      'SVRLOC'             : 427  , # Server Location
      'OCS_CMU'            : 428  , # OCS_CMUIANA assigned this well_formed service name as a replacement for "ocs_cmu".
      'OCS_CMU'            : 428  , # OCS_CMU This entry is an alias to "ocs_cmu".This entry is now historic, not usable for use with manycommon service discovery mechanisms.
      'OCS_AMU'            : 429  , # OCS_AMUIANA assigned this well_formed service name as a replacement for "ocs_amu".
      'OCS_AMU'            : 429  , # OCS_AMU
      'UTMPSD'             : 430  , # UTMPSD
      'UTMPCD'             : 431  , # UTMPCD
      'IASD'               : 432  , # IASD
      'NNSP'               : 433  , # NNSP
      'MOBILEIP_AGENT'     : 434  , # MobileIP_Agent
      'MOBILIP_MN'         : 435  , # MobilIP_MN
      'DNA_CML'            : 436  , # DNA_CML
      'COMSCM'             : 437  , # comscm
      'DSFGW'              : 438  , # dsfgw
      'DASP'               : 439  , # dasp
      'SGCP'               : 440  , # sgcp
      'DECVMS_SYSMGT'      : 441  , # decvms_sysmgt
      'CVC_HOSTD'          : 442  , # cvc_hostdIANA assigned this well_formed service name as a replacement for "cvc_hostd".
      'CVC_HOSTD'          : 442  , # cvc_hostd
      'HTTPS'              : 443  , # http protocol over TLS_SSL
      'SNPP'               : 444  , # Simple Network Paging Protocol
      'MICROSOFT_DS'       : 445  , # Microsoft_DS
      'DDM_RDB'            : 446  , # DDM_Remote Relational Database Access
      'DDM_DFM'            : 447  , # DDM_Distributed File Management
      'DDM_SSL'            : 448  , # DDM_Remote DB Access Using Secure Sockets
      'AS_SERVERMAP'       : 449  , # AS Server Mapper
      'TSERVER'            : 450  , # Computer Supported Telecomunication Applications
      'SFS_SMP_NET'        : 451  , # Cray Network Semaphore server
      'SFS_CONFIG'         : 452  , # Cray SFS config server
      'CREATIVESERVER'     : 453  , # CreativeServer
      'CONTENTSERVER'      : 454  , # ContentServer
      'CREATIVEPARTNR'     : 455  , # CreativePartnr
      'MACON_TCP'          : 456  , # macon_tcp
      'SCOHELP'            : 457  , # scohelp
      'APPLEQTC'           : 458  , # apple quick time
      'AMPR_RCMD'          : 459  , # ampr_rcmd
      'SKRONK'             : 460  , # skronk
      'DATASURFSRV'        : 461  , # DataRampSrv
      'DATASURFSRVSEC'     : 462  , # DataRampSrvSec
      'ALPES'              : 463  , # alpes
      'KPASSWD'            : 464  , # kpasswd
      'URD'                : 465  , # URL Rendesvous Directory for SSM
      'DIGITAL_VRC'        : 466  , # digital_vrc
      'MYLEX_MAPD'         : 467  , # mylex_mapd
      'PHOTURIS'           : 468  , # proturis
      'RCP'                : 469  , # Radio Control Protocol
      'SCX_PROXY'          : 470  , # scx_proxy
      'MONDEX'             : 471  , # Mondex
      'LJK_LOGIN'          : 472  , # ljk_login
      'HYBRID_POP'         : 473  , # hybrid_pop
      'TN_TL_W1'           : 474  , # tn_tl_w1
      'TCPNETHASPSRV'      : 475  , # tcpnethaspsrv
      'TN_TL_FD1'          : 476  , # tn_tl_fd1
      'SS7NS'              : 477  , # ss7ns
      'SPSC'               : 478  , # spsc
      'IAFSERVER'          : 479  , # iafserver
      'IAFDBASE'           : 480  , # iafdbase
      'PH'                 : 481  , # Ph service
      'BGS_NSI'            : 482  , # bgs_nsi
      'ULPNET'             : 483  , # ulpnet
      'INTEGRA_SME'        : 484  , # Integra Software Management Environment
      'POWERBURST'         : 485  , # Air Soft Power Burst
      'AVIAN'              : 486  , # avian
      'SAFT'               : 487  , # saft Simple Asynchronous File Transfer
      'GSS_HTTP'           : 488  , # gss_http
      'NEST_PROTOCOL'      : 489  , # nest_protocol
      'MICOM_PFS'          : 490  , # micom_pfs
      'GO_LOGIN'           : 491  , # go_login
      'TICF_1'             : 492  , # Transport Independent Convergence for FNA
      'TICF_2'             : 493  , # Transport Independent Convergence for FNA
      'POV_RAY'            : 494  , # POV_Ray
      'INTECOURIER'        : 495  , # intecourier
      'PIM_RP_DISC'        : 496  , # PIM_RP_DISC
      'RETROSPECT'         : 497  , # Retrospect backup and restore service
      'SIAM'               : 498  , # siam
      'ISO_ILL'            : 499  , # ISO ILL Protocol
      'ISAKMP'             : 500  , # isakmp
      'STMF'               : 501  , # STMF
      'MBAP'               : 502  , # Modbus Application Protocol
      'INTRINSA'           : 503  , # Intrinsa
      'CITADEL'            : 504  , # citadel
      'MAILBOX_LM'         : 505  , # mailbox_lm
      'OHIMSRV'            : 506  , # ohimsrv
      'CRS'                : 507  , # crs
      'XVTTP'              : 508  , # xvttp
      'SNARE'              : 509  , # snare
      'FCP'                : 510  , # FirstClass Protocol
      'PASSGO'             : 511  , # PassGo
      'EXEC'               : 512  , # remote process execution; authentication performed using passwords and UNIX login names
      'LOGIN'              : 513  , # remote login a la telnet; automatic authentication performed based on priviledged port numbers and distributed data bases which identify "authentication domains"
      'SHELL'              : 514  , # cmd like exec, but automatic authentication is performed as for login server
      'PRINTER'            : 515  , # spooler
      'VIDEOTEX'           : 516  , # videotex
      'TALK'               : 517  , # like tenex link, but across machine _ unfortunately, doesn't use link protocol (this is actually just a rendezvous port from which a tcp connection is established)
      'NTALK'              : 518  , # 
      'UTIME'              : 519  , # unixtime
      'EFS'                : 520  , # extended file name server
      'RIPNG'              : 521  , # ripng
      'ULP'                : 522  , # ULP
      'IBM_DB2'            : 523  , # IBM_DB2
      'NCP'                : 524  , # NCP
      'TIMED'              : 525  , # timeserver
      'TEMPO'              : 526  , # newdate
      'STX'                : 527  , # Stock IXChange
      'CUSTIX'             : 528  , # Customer IXChange
      'IRC_SERV'           : 529  , # IRC_SERV
      'COURIER'            : 530  , # rpc
      'CONFERENCE'         : 531  , # chat
      'NETNEWS'            : 532  , # readnews
      'NETWALL'            : 533  , # for emergency broadcasts
      'WINDREAM'           : 534  , # windream Admin
      'IIOP'               : 535  , # iiop
      'OPALIS_RDV'         : 536  , # opalis_rdv
      'NMSP'               : 537  , # Networked Media Streaming Protocol
      'GDOMAP'             : 538  , # gdomap
      'APERTUS_LDP'        : 539  , # Apertus Technologies Load Determination
      'UUCP'               : 540  , # uucpd
      'UUCP_RLOGIN'        : 541  , # uucp_rlogin
      'COMMERCE'           : 542  , # commerce
      'KLOGIN'             : 543  , # 
      'KSHELL'             : 544  , # krcmd
      'APPLEQTCSRVR'       : 545  , # appleqtcsrvr
      'DHCPV6_CLIENT'      : 546  , # DHCPv6 Client
      'DHCPV6_SERVER'      : 547  , # DHCPv6 Server
      'AFPOVERTCP'         : 548  , # AFP over TCP
      'IDFP'               : 549  , # IDFP
      'NEW_RWHO'           : 550  , # new_who
      'CYBERCASH'          : 551  , # cybercash
      'DEVSHR_NTS'         : 552  , # DeviceShare
      'PIRP'               : 553  , # pirp
      'RTSP'               : 554  , # Real Time Streaming Protocol (RTSP)
      'DSF'                : 555  , # 
      'REMOTEFS'           : 556  , # rfs server
      'OPENVMS_SYSIPC'     : 557  , # openvms_sysipc
      'SDNSKMP'            : 558  , # SDNSKMP
      'TEEDTAP'            : 559  , # TEEDTAP
      'RMONITOR'           : 560  , # rmonitord
      'MONITOR'            : 561  , # 
      'CHSHELL'            : 562  , # chcmd
      'NNTPS'              : 563  , # nntp protocol over TLS_SSL (was snntp)
      '9PFS'               : 564  , # plan 9 file service
      'WHOAMI'             : 565  , # whoami
      'STREETTALK'         : 566  , # streettalk
      'BANYAN_RPC'         : 567  , # banyan_rpc
      'MS_SHUTTLE'         : 568  , # microsoft shuttle
      'MS_ROME'            : 569  , # microsoft rome
      'METER'              : 570  , # demon
      'METER'              : 571  , # udemon
      'SONAR'              : 572  , # sonar
      'BANYAN_VIP'         : 573  , # banyan_vip
      'FTP_AGENT'          : 574  , # FTP Software Agent System
      'VEMMI'              : 575  , # VEMMI
      'IPCD'               : 576  , # ipcd
      'VNAS'               : 577  , # vnas
      'IPDD'               : 578  , # ipdd
      'DECBSRV'            : 579  , # decbsrv
      'SNTP_HEARTBEAT'     : 580  , # SNTP HEARTBEAT
      'BDP'                : 581  , # Bundle Discovery Protocol
      'SCC_SECURITY'       : 582  , # SCC Security
      'PHILIPS_VC'         : 583  , # Philips Video_Conferencing
      'KEYSERVER'          : 584  , # Key Server
      'PASSWORD_CHG'       : 586  , # Password Change
      'SUBMISSION'         : 587  , # Message Submission 2011_11_17
      'CAL'                : 588  , # CAL
      'EYELINK'            : 589  , # EyeLink
      'TNS_CML'            : 590  , # TNS CML
      'HTTP_ALT'           : 591  , # FileMaker, Inc. _ HTTP Alternate (see Port 80)
      'EUDORA_SET'         : 592  , # Eudora Set
      'HTTP_RPC_EPMAP'     : 593  , # HTTP RPC Ep Map
      'TPIP'               : 594  , # TPIP
      'CAB_PROTOCOL'       : 595  , # CAB Protocol
      'SMSD'               : 596  , # SMSD
      'PTCNAMESERVICE'     : 597  , # PTC Name Service
      'SCO_WEBSRVRMG3'     : 598  , # SCO Web Server Manager 3
      'ACP'                : 599  , # Aeolon Core Protocol
      'IPCSERVER'          : 600  , # Sun IPC server
      'SYSLOG_CONN'        : 601  , # Reliable Syslog Service
      'XMLRPC_BEEP'        : 602  , # XML_RPC over BEEP
      'IDXP'               : 603  , # IDXP
      'TUNNEL'             : 604  , # TUNNEL
      'SOAP_BEEP'          : 605  , # SOAP over BEEP
      'URM'                : 606  , # Cray Unified Resource Manager
      'NQS'                : 607  , # nqs
      'SIFT_UFT'           : 608  , # Sender_Initiated_Unsolicited File Transfer
      'NPMP_TRAP'          : 609  , # npmp_trap
      'NPMP_LOCAL'         : 610  , # npmp_local
      'NPMP_GUI'           : 611  , # npmp_gui
      'HMMP_IND'           : 612  , # HMMP Indication
      'HMMP_OP'            : 613  , # HMMP Operation
      'SSHELL'             : 614  , # SSLshell
      'SCO_INETMGR'        : 615  , # Internet Configuration Manager
      'SCO_SYSMGR'         : 616  , # SCO System Administration Server
      'SCO_DTMGR'          : 617  , # SCO Desktop Administration Server
      'DEI_ICDA'           : 618  , # DEI_ICDA
      'COMPAQ_EVM'         : 619  , # Compaq EVM
      'SCO_WEBSRVRMGR'     : 620  , # SCO WebServer Manager
      'ESCP_IP'            : 621  , # ESCP
      'COLLABORATOR'       : 622  , # Collaborator
      'OOB_WS_HTTP'        : 623  , # DMTF out_of_band web services management protocol
      'CRYPTOADMIN'        : 624  , # Crypto Admin
      'DEC_DLM'            : 625  , # DEC DLMIANA assigned this well_formed service name as a replacement for "dec_dlm".
      'DEC_DLM'            : 625  , # DEC DLM
      'ASIA'               : 626  , # ASIA
      'PASSGO_TIVOLI'      : 627  , # PassGo Tivoli
      'QMQP'               : 628  , # QMQP
      '3COM_AMP3'          : 629  , # 3Com AMP3
      'RDA'                : 630  , # RDA
      'IPP'                : 631  , # IPP (Internet Printing Protocol)
      'BMPP'               : 632  , # bmpp
      'SERVSTAT'           : 633  , # Service Status update (Sterling Software)
      'GINAD'              : 634  , # ginad
      'RLZDBASE'           : 635  , # RLZ DBase
      'LDAPS'              : 636  , # ldap protocol over TLS_SSL (was sldap)
      'LANSERVER'          : 637  , # lanserver
      'MCNS_SEC'           : 638  , # mcns_sec
      'MSDP'               : 639  , # MSDP
      'ENTRUST_SPS'        : 640  , # entrust_sps
      'REPCMD'             : 641  , # repcmd
      'ESRO_EMSDP'         : 642  , # ESRO_EMSDP V1.3
      'SANITY'             : 643  , # SANity
      'DWR'                : 644  , # dwr
      'PSSC'               : 645  , # PSSC
      'LDP'                : 646  , # LDP
      'DHCP_FAILOVER'      : 647  , # DHCP Failover
      'RRP'                : 648  , # Registry Registrar Protocol (RRP)
      'CADVIEW_3D'         : 649  , # Cadview_3d _ streaming 3d models over the internet
      'OBEX'               : 650  , # OBEX
      'IEEE_MMS'           : 651  , # IEEE MMS
      'HELLO_PORT'         : 652  , # HELLO_PORT
      'REPSCMD'            : 653  , # RepCmd
      'AODV'               : 654  , # AODV
      'TINC'               : 655  , # TINC
      'SPMP'               : 656  , # SPMP
      'RMC'                : 657  , # RMC
      'TENFOLD'            : 658  , # TenFold
      'MAC_SRVR_ADMIN'     : 660  , # MacOS Server Admin
      'HAP'                : 661  , # HAP
      'PFTP'               : 662  , # PFTP
      'PURENOISE'          : 663  , # PureNoise
      'OOB_WS_HTTPS'       : 664  , # DMTF out_of_band secure web services management protocol
      'SUN_DR'             : 665  , # Sun DR
      'MDQS'               : 666  , # 
      'DOOM'               : 666  , # doom Id Software
      'DISCLOSE'           : 667  , # campaign contribution disclosures _ SDR Technologies
      'MECOMM'             : 668  , # MeComm
      'MEREGISTER'         : 669  , # MeRegister
      'VACDSM_SWS'         : 670  , # VACDSM_SWS
      'VACDSM_APP'         : 671  , # VACDSM_APP
      'VPPS_QUA'           : 672  , # VPPS_QUA
      'CIMPLEX'            : 673  , # CIMPLEX
      'ACAP'               : 674  , # ACAP
      'DCTP'               : 675  , # DCTP
      'VPPS_VIA'           : 676  , # VPPS Via
      'VPP'                : 677  , # Virtual Presence Protocol
      'GGF_NCP'            : 678  , # GNU Generation Foundation NCP
      'MRM'                : 679  , # MRM
      'ENTRUST_AAAS'       : 680  , # entrust_aaas
      'ENTRUST_AAMS'       : 681  , # entrust_aams
      'XFR'                : 682  , # XFR
      'CORBA_IIOP'         : 683  , # CORBA IIOP
      'CORBA_IIOP_SSL'     : 684  , # CORBA IIOP SSL
      'MDC_PORTMAPPER'     : 685  , # MDC Port Mapper
      'HCP_WISMAR'         : 686  , # Hardware Control Protocol Wismar
      'ASIPREGISTRY'       : 687  , # asipregistry
      'REALM_RUSD'         : 688  , # ApplianceWare managment protocol
      'NMAP'               : 689  , # NMAP
      'VATP'               : 690  , # Velazquez Application Transfer Protocol
      'MSEXCH_ROUTING'     : 691  , # MS Exchange Routing
      'HYPERWAVE_ISP'      : 692  , # Hyperwave_ISP
      'CONNENDP'           : 693  , # almanid Connection Endpoint
      'HA_CLUSTER'         : 694  , # ha_cluster
      'IEEE_MMS_SSL'       : 695  , # IEEE_MMS_SSL
      'RUSHD'              : 696  , # RUSHD
      'UUIDGEN'            : 697  , # UUIDGEN
      'OLSR'               : 698  , # OLSR
      'ACCESSNETWORK'      : 699  , # Access Network
      'EPP'                : 700  , # Extensible Provisioning Protocol
      'LMP'                : 701  , # Link Management Protocol (LMP)
      'IRIS_BEEP'          : 702  , # IRIS over BEEP
      'ELCSD'              : 704  , # errlog copy_server daemon
      'AGENTX'             : 705  , # AgentX
      'SILC'               : 706  , # SILC
      'BORLAND_DSJ'        : 707  , # Borland DSJ
      'ENTRUST_KMSH'       : 709  , # Entrust Key Management Service Handler
      'ENTRUST_ASH'        : 710  , # Entrust Administration Service Handler
      'CISCO_TDP'          : 711  , # Cisco TDP
      'TBRPF'              : 712  , # TBRPF
      'IRIS_XPC'           : 713  , # IRIS over XPC
      'IRIS_XPCS'          : 714  , # IRIS over XPCS
      'IRIS_LWZ'           : 715  , # IRIS_LWZ
      'NETVIEWDM1'         : 729  , # IBM NetView DM_6000 Server_Client
      'NETVIEWDM2'         : 730  , # IBM NetView DM_6000 send_tcp
      'NETVIEWDM3'         : 731  , # IBM NetView DM_6000 receive_tcp
      'NETGW'              : 741  , # netGW
      'NETRCS'             : 742  , # Network based Rev. Cont. Sys.
      'FLEXLM'             : 744  , # Flexible License Manager
      'FUJITSU_DEV'        : 747  , # Fujitsu Device Control
      'RIS_CM'             : 748  , # Russell Info Sci Calendar Manager
      'KERBEROS_ADM'       : 749  , # kerberos administration
      'RFILE'              : 750  , # 
      'PUMP'               : 751  , # 
      'QRH'                : 752  , # 
      'RRH'                : 753  , # 
      'TELL'               : 754  , # send
      'NLOGIN'             : 758  , # 
      'CON'                : 759  , # 
      'NS'                 : 760  , # 
      'RXE'                : 761  , # 
      'QUOTAD'             : 762  , # 
      'CYCLESERV'          : 763  , # 
      'OMSERV'             : 764  , # 
      'WEBSTER'            : 765  , # 
      'PHONEBOOK'          : 767  , # phone
      'VID'                : 769  , # 
      'CADLOCK'            : 770  , # 
      'RTIP'               : 771  , # 
      'CYCLESERV2'         : 772  , # 
      'SUBMIT'             : 773  , # 
      'RPASSWD'            : 774  , # 
      'ENTOMB'             : 775  , # 
      'WPAGES'             : 776  , # 
      'MULTILING_HTTP'     : 777  , # Multiling HTTP
      'WPGS'               : 780  , # 
      'MDBS_DAEMON'        : 800  , # IANA assigned this well_formed service name as a replacement for "mdbs_daemon".
      'MDBS_DAEMON'        : 800  , # This entry is an alias to "mdbs_daemon".This entry is now historic, not usable for use with manycommon service discovery mechanisms.
      'DEVICE'             : 801  , # 
      'MBAP_S'             : 802  , # Modbus Application Protocol Secure
      'FCP_UDP'            : 810  , # FCP
      'ITM_MCELL_S'        : 828  , # itm_mcell_s
      'PKIX_3_CA_RA'       : 829  , # PKIX_3 CA_RA
      'NETCONF_SSH'        : 830  , # NETCONF over SSH
      'NETCONF_BEEP'       : 831  , # NETCONF over BEEP
      'NETCONFSOAPHTTP'    : 832  , # NETCONF for SOAP over HTTPS
      'NETCONFSOAPBEEP'    : 833  , # NETCONF for SOAP over BEEP
      'DHCP_FAILOVER2'     : 847  , # dhcp_failover 2
      'GDOI'               : 848  , # GDOI
      'ISCSI'              : 860  , # iSCSI
      'OWAMP_CONTROL'      : 861  , # OWAMP_Control
      'TWAMP_CONTROL'      : 862  , # Two_way Active Measurement Protocol (TWAMP) Control
      'RSYNC'              : 873  , # rsync
      'ICLCNET_LOCATE'     : 886  , # ICL coNETion locate server
      'ICLCNET_SVINFO'     : 887  , # ICL coNETion server infoIANA assigned this well_formed service name as a replacement for "iclcnet_svinfo".
      'ICLCNET_SVINFO'     : 887  , # ICL coNETion server info
      'ACCESSBUILDER'      : 888  , # AccessBuilder
      'CDDBP'              : 888  , # CD Database Protocol
      'OMGINITIALREFS'     : 900  , # OMG Initial Refs
      'SMPNAMERES'         : 901  , # SMPNAMERES
      'IDEAFARM_DOOR'      : 902  , # self documenting Telnet Door
      'IDEAFARM_PANIC'     : 903  , # self documenting Telnet Panic Door
      'KINK'               : 910  , # Kerberized Internet Negotiation of Keys (KINK)
      'XACT_BACKUP'        : 911  , # xact_backup
      'APEX_MESH'          : 912  , # APEX relay_relay service
      'APEX_EDGE'          : 913  , # APEX endpoint_relay service
      'FTPS_DATA'          : 989  , # ftp protocol, data, over TLS_SSL
      'FTPS'               : 990  , # ftp protocol, control, over TLS_SSL
      'NAS'                : 991  , # Netnews Administration System
      'TELNETS'            : 992  , # telnet protocol over TLS_SSL
      'IMAPS'              : 993  , # imap4 protocol over TLS_SSL
      'POP3S'              : 995  , # pop3 protocol over TLS_SSL (was spop3)
      'VSINET'             : 996  , # vsinet
      'MAITRD'             : 997  , # 
      'BUSBOY'             : 998  , # 
      'GARCON'             : 999  , # 
      'PUPROUTER'          : 999  , # 
      'CADLOCK2'           : 1000 , # 
      'SURF'               : 1010 , # surf
      'EXP1'               : 1021 , # RFC3692_style Experiment 1
      'EXP2'               : 1022 , # RFC3692_style Experiment 2
      'BLACKJACK'          : 1025 , # network blackjack
      'CAP'                : 1026 , # Calendar Access Protocol
      'SOLID_MUX'          : 1029 , # Solid Mux Server
      'NETINFO_LOCAL'      : 1033 , # local netinfo port
      'ACTIVESYNC'         : 1034 , # ActiveSync Notifications
      'MXXRLOGIN'          : 1035 , # MX_XR RPC
      'NSSTP'              : 1036 , # Nebula Secure Segment Transfer Protocol
      'AMS'                : 1037 , # AMS
      'MTQP'               : 1038 , # Message Tracking Query Protocol
      'SBL'                : 1039 , # Streamlined Blackhole
      'NETARX'             : 1040 , # Netarx Netcare
      'DANF_AK2'           : 1041 , # AK2 Product
      'AFROG'              : 1042 , # Subnet Roaming
      'BOINC_CLIENT'       : 1043 , # BOINC Client Control
      'DCUTILITY'          : 1044 , # Dev Consortium Utility
      'FPITP'              : 1045 , # Fingerprint Image Transfer Protocol
      'WFREMOTERTM'        : 1046 , # WebFilter Remote Monitor
      'NEOD1'              : 1047 , # Sun's NEO Object Request Broker
      'NEOD2'              : 1048 , # Sun's NEO Object Request Broker
      'TD_POSTMAN'         : 1049 , # Tobit David Postman VPMN
      'CMA'                : 1050 , # CORBA Management Agent
      'OPTIMA_VNET'        : 1051 , # Optima VNET
      'DDT'                : 1052 , # Dynamic DNS Tools
      'REMOTE_AS'          : 1053 , # Remote Assistant (RA)
      'BRVREAD'            : 1054 , # BRVREAD
      'ANSYSLMD'           : 1055 , # ANSYS _ License Manager
      'VFO'                : 1056 , # VFO
      'STARTRON'           : 1057 , # STARTRON
      'NIM'                : 1058 , # nim
      'NIMREG'             : 1059 , # nimreg
      'POLESTAR'           : 1060 , # POLESTAR
      'KIOSK'              : 1061 , # KIOSK
      'VERACITY'           : 1062 , # Veracity
      'KYOCERANETDEV'      : 1063 , # KyoceraNetDev
      'JSTEL'              : 1064 , # JSTEL
      'SYSCOMLAN'          : 1065 , # SYSCOMLAN
      'FPO_FNS'            : 1066 , # FPO_FNS
      'INSTL_BOOTS'        : 1067 , # Installation Bootstrap Proto. Serv.IANA assigned this well_formed service name as a replacement for "instl_boots".
      'INSTL_BOOTS'        : 1067 , # Installation Bootstrap Proto. Serv. This entry is an alias to "instl_boots".This entry is now historic, not usable for use with manycommon service discovery mechanisms.
      'INSTL_BOOTC'        : 1068 , # Installation Bootstrap Proto. Cli.IANA assigned this well_formed service name as a replacement for "instl_bootc".
      'INSTL_BOOTC'        : 1068 , # Installation Bootstrap Proto. Cli.
      'COGNEX_INSIGHT'     : 1069 , # COGNEX_INSIGHT
      'GMRUPDATESERV'      : 1070 , # GMRUpdateSERV
      'BSQUARE_VOIP'       : 1071 , # BSQUARE_VOIP
      'CARDAX'             : 1072 , # CARDAX
      'BRIDGECONTROL'      : 1073 , # Bridge Control
      'WARMSPOTMGMT'       : 1074 , # Warmspot Management Protocol
      'RDRMSHC'            : 1075 , # RDRMSHC
      'DAB_STI_C'          : 1076 , # DAB STI_C
      'IMGAMES'            : 1077 , # IMGames
      'AVOCENT_PROXY'      : 1078 , # Avocent Proxy Protocol
      'ASPROVATALK'        : 1079 , # ASPROVATalk
      'SOCKS'              : 1080 , # Socks
      'PVUNIWIEN'          : 1081 , # PVUNIWIEN
      'AMT_ESD_PROT'       : 1082 , # AMT_ESD_PROT
      'ANSOFT_LM_1'        : 1083 , # Anasoft License Manager
      'ANSOFT_LM_2'        : 1084 , # Anasoft License Manager
      'WEBOBJECTS'         : 1085 , # Web Objects
      'CPLSCRAMBLER_LG'    : 1086 , # CPL Scrambler Logging
      'CPLSCRAMBLER_IN'    : 1087 , # CPL Scrambler Internal
      'CPLSCRAMBLER_AL'    : 1088 , # CPL Scrambler Alarm Log
      'FF_ANNUNC'          : 1089 , # FF Annunciation
      'FF_FMS'             : 1090 , # FF Fieldbus Message Specification
      'FF_SM'              : 1091 , # FF System Management
      'OBRPD'              : 1092 , # Open Business Reporting Protocol
      'PROOFD'             : 1093 , # PROOFD
      'ROOTD'              : 1094 , # ROOTD
      'NICELINK'           : 1095 , # NICELink
      'CNRPROTOCOL'        : 1096 , # Common Name Resolution Protocol
      'SUNCLUSTERMGR'      : 1097 , # Sun Cluster Manager
      'RMIACTIVATION'      : 1098 , # RMI Activation
      'RMIREGISTRY'        : 1099 , # RMI Registry
      'MCTP'               : 1100 , # MCTP
      'PT2_DISCOVER'       : 1101 , # PT2_DISCOVER
      'ADOBESERVER_1'      : 1102 , # ADOBE SERVER 1
      'ADOBESERVER_2'      : 1103 , # ADOBE SERVER 2
      'XRL'                : 1104 , # XRL
      'FTRANHC'            : 1105 , # FTRANHC
      'ISOIPSIGPORT_1'     : 1106 , # ISOIPSIGPORT_1
      'ISOIPSIGPORT_2'     : 1107 , # ISOIPSIGPORT_2
      'RATIO_ADP'          : 1108 , # ratio_adp
      'WEBADMSTART'        : 1110 , # Start web admin server
      'LMSOCIALSERVER'     : 1111 , # LM Social Server
      'ICP'                : 1112 , # Intelligent Communication Protocol
      'LTP_DEEPSPACE'      : 1113 , # Licklider Transmission Protocol
      'MINI_SQL'           : 1114 , # Mini SQL
      'ARDUS_TRNS'         : 1115 , # ARDUS Transfer
      'ARDUS_CNTL'         : 1116 , # ARDUS Control
      'ARDUS_MTRNS'        : 1117 , # ARDUS Multicast Transfer
      'SACRED'             : 1118 , # SACRED
      'BNETGAME'           : 1119 , # Battle.net Chat_Game Protocol
      'BNETFILE'           : 1120 , # Battle.net File Transfer Protocol
      'RMPP'               : 1121 , # Datalode RMPP
      'AVAILANT_MGR'       : 1122 , # availant_mgr
      'MURRAY'             : 1123 , # Murray
      'HPVMMCONTROL'       : 1124 , # HP VMM Control
      'HPVMMAGENT'         : 1125 , # HP VMM Agent
      'HPVMMDATA'          : 1126 , # HP VMM Agent
      'KWDB_COMMN'         : 1127 , # KWDB Remote Communication
      'SAPHOSTCTRL'        : 1128 , # SAPHostControl over SOAP_HTTP
      'SAPHOSTCTRLS'       : 1129 , # SAPHostControl over SOAP_HTTPS
      'CASP'               : 1130 , # CAC App Service Protocol
      'CASPSSL'            : 1131 , # CAC App Service Protocol Encripted
      'KVM_VIA_IP'         : 1132 , # KVM_via_IP Management Service
      'DFN'                : 1133 , # Data Flow Network
      'APLX'               : 1134 , # MicroAPL APLX
      'OMNIVISION'         : 1135 , # OmniVision Communication Service
      'HHB_GATEWAY'        : 1136 , # HHB Gateway Control
      'TRIM'               : 1137 , # TRIM Workgroup Service
      'ENCRYPTED_ADMIN'    : 1138 , # encrypted admin requestsIANA assigned this well_formed service name as a replacement for "encrypted_admin".
      'ENCRYPTED_ADMIN'    : 1138 , # encrypted admin requests
      'EVM'                : 1139 , # Enterprise Virtual Manager
      'AUTONOC'            : 1140 , # AutoNOC Network Operations Protocol
      'MXOMSS'             : 1141 , # User Message Service
      'EDTOOLS'            : 1142 , # User Discovery Service
      'IMYX'               : 1143 , # Infomatryx Exchange
      'FUSCRIPT'           : 1144 , # Fusion Script
      'X9_ICUE'            : 1145 , # X9 iCue Show Control
      'AUDIT_TRANSFER'     : 1146 , # audit transfer
      'CAPIOVERLAN'        : 1147 , # CAPIoverLAN
      'ELFIQ_REPL'         : 1148 , # Elfiq Replication Service
      'BVTSONAR'           : 1149 , # BlueView Sonar Service
      'BLAZE'              : 1150 , # Blaze File Server
      'UNIZENSUS'          : 1151 , # Unizensus Login Server
      'WINPOPLANMESS'      : 1152 , # Winpopup LAN Messenger
      'C1222_ACSE'         : 1153 , # ANSI C12.22 Port
      'RESACOMMUNITY'      : 1154 , # Community Service
      'NFA'                : 1155 , # Network File Access
      'IASCONTROL_OMS'     : 1156 , # iasControl OMS
      'IASCONTROL'         : 1157 , # Oracle iASControl
      'DBCONTROL_OMS'      : 1158 , # dbControl OMS
      'ORACLE_OMS'         : 1159 , # Oracle OMS
      'OLSV'               : 1160 , # DB Lite Mult_User Server
      'HEALTH_POLLING'     : 1161 , # Health Polling
      'HEALTH_TRAP'        : 1162 , # Health Trap
      'SDDP'               : 1163 , # SmartDialer Data Protocol
      'QSM_PROXY'          : 1164 , # QSM Proxy Service
      'QSM_GUI'            : 1165 , # QSM GUI Service
      'QSM_REMOTE'         : 1166 , # QSM RemoteExec
      'CISCO_IPSLA'        : 1167 , # Cisco IP SLAs Control Protocol
      'VCHAT'              : 1168 , # VChat Conference Service
      'TRIPWIRE'           : 1169 , # TRIPWIRE
      'ATC_LM'             : 1170 , # AT+C License Manager
      'ATC_APPSERVER'      : 1171 , # AT+C FmiApplicationServer
      'DNAP'               : 1172 , # DNA Protocol
      'D_CINEMA_RRP'       : 1173 , # D_Cinema Request_Response
      'FNET_REMOTE_UI'     : 1174 , # FlashNet Remote Admin
      'DOSSIER'            : 1175 , # Dossier Server
      'INDIGO_SERVER'      : 1176 , # Indigo Home Server
      'DKMESSENGER'        : 1177 , # DKMessenger Protocol
      'SGI_STORMAN'        : 1178 , # SGI Storage Manager
      'B2N'                : 1179 , # Backup To Neighbor
      'MC_CLIENT'          : 1180 , # Millicent Client Proxy
      '3COMNETMAN'         : 1181 , # 3Com Net Management
      'ACCELENET'          : 1182 , # AcceleNet Control
      'LLSURFUP_HTTP'      : 1183 , # LL Surfup HTTP
      'LLSURFUP_HTTPS'     : 1184 , # LL Surfup HTTPS
      'CATCHPOLE'          : 1185 , # Catchpole port
      'MYSQL_CLUSTER'      : 1186 , # MySQL Cluster Manager
      'ALIAS'              : 1187 , # Alias Service
      'HP_WEBADMIN'        : 1188 , # HP Web Admin
      'UNET'               : 1189 , # Unet Connection
      'COMMLINX_AVL'       : 1190 , # CommLinx GPS _ AVL System
      'GPFS'               : 1191 , # General Parallel File System
      'CAIDS_SENSOR'       : 1192 , # caids sensors channel
      'FIVEACROSS'         : 1193 , # Five Across Server
      'OPENVPN'            : 1194 , # OpenVPN
      'RSF_1'              : 1195 , # RSF_1 clustering
      'NETMAGIC'           : 1196 , # Network Magic
      'CARRIUS_RSHELL'     : 1197 , # Carrius Remote Access
      'CAJO_DISCOVERY'     : 1198 , # cajo reference discovery
      'DMIDI'              : 1199 , # DMIDI
      'SCOL'               : 1200 , # SCOL
      'NUCLEUS_SAND'       : 1201 , # Nucleus Sand Database Server
      'CAICCIPC'           : 1202 , # caiccipc
      'SSSLIC_MGR'         : 1203 , # License Validation
      'SSSLOG_MGR'         : 1204 , # Log Request Listener
      'ACCORD_MGC'         : 1205 , # Accord_MGC
      'ANTHONY_DATA'       : 1206 , # Anthony Data
      'METASAGE'           : 1207 , # MetaSage
      'SEAGULL_AIS'        : 1208 , # SEAGULL AIS
      'IPCD3'              : 1209 , # IPCD3
      'EOSS'               : 1210 , # EOSS
      'GROOVE_DPP'         : 1211 , # Groove DPP
      'LUPA'               : 1212 , # lupa
      'MPC_LIFENET'        : 1213 , # Medtronic_Physio_Control LIFENET
      'KAZAA'              : 1214 , # KAZAA
      'SCANSTAT_1'         : 1215 , # scanSTAT 1.0
      'ETEBAC5'            : 1216 , # ETEBAC 5
      'HPSS_NDAPI'         : 1217 , # HPSS NonDCE Gateway
      'AEROFLIGHT_ADS'     : 1218 , # AeroFlight_ADs
      'AEROFLIGHT_RET'     : 1219 , # AeroFlight_Ret
      'QT_SERVERADMIN'     : 1220 , # QT SERVER ADMIN
      'SWEETWARE_APPS'     : 1221 , # SweetWARE Apps
      'NERV'               : 1222 , # SNI R&D network
      'TGP'                : 1223 , # TrulyGlobal Protocol
      'VPNZ'               : 1224 , # VPNz
      'SLINKYSEARCH'       : 1225 , # SLINKYSEARCH
      'STGXFWS'            : 1226 , # STGXFWS
      'DNS2GO'             : 1227 , # DNS2Go
      'FLORENCE'           : 1228 , # FLORENCE
      'ZENTED'             : 1229 , # ZENworks Tiered Electronic Distribution
      'PERISCOPE'          : 1230 , # Periscope
      'MENANDMICE_LPM'     : 1231 , # menandmice_lpm
      'FIRST_DEFENSE'      : 1232 , # Remote systems monitoring
      'UNIV_APPSERVER'     : 1233 , # Universal App Server
      'SEARCH_AGENT'       : 1234 , # Infoseek Search Agent
      'MOSAICSYSSVC1'      : 1235 , # mosaicsyssvc1
      'BVCONTROL'          : 1236 , # bvcontrol
      'TSDOS390'           : 1237 , # tsdos390
      'HACL_QS'            : 1238 , # hacl_qs
      'NMSD'               : 1239 , # NMSD
      'INSTANTIA'          : 1240 , # Instantia
      'NESSUS'             : 1241 , # nessus
      'NMASOVERIP'         : 1242 , # NMAS over IP
      'SERIALGATEWAY'      : 1243 , # SerialGateway
      'ISBCONFERENCE1'     : 1244 , # isbconference1
      'ISBCONFERENCE2'     : 1245 , # isbconference2
      'PAYROUTER'          : 1246 , # payrouter
      'VISIONPYRAMID'      : 1247 , # VisionPyramid
      'HERMES'             : 1248 , # hermes
      'MESAVISTACO'        : 1249 , # Mesa Vista Co
      'SWLDY_SIAS'         : 1250 , # swldy_sias
      'SERVERGRAPH'        : 1251 , # servergraph
      'BSPNE_PCC'          : 1252 , # bspne_pcc
      'Q55_PCC'            : 1253 , # q55_pcc
      'DE_NOC'             : 1254 , # de_noc
      'DE_CACHE_QUERY'     : 1255 , # de_cache_query
      'DE_SERVER'          : 1256 , # de_server
      'SHOCKWAVE2'         : 1257 , # Shockwave 2
      'OPENNL'             : 1258 , # Open Network Library
      'OPENNL_VOICE'       : 1259 , # Open Network Library Voice
      'IBM_SSD'            : 1260 , # ibm_ssd
      'MPSHRSV'            : 1261 , # mpshrsv
      'QNTS_ORB'           : 1262 , # QNTS_ORB
      'DKA'                : 1263 , # dka
      'PRAT'               : 1264 , # PRAT
      'DSSIAPI'            : 1265 , # DSSIAPI
      'DELLPWRAPPKS'       : 1266 , # DELLPWRAPPKS
      'EPC'                : 1267 , # eTrust Policy Compliance
      'PROPEL_MSGSYS'      : 1268 , # PROPEL_MSGSYS
      'WATILAPP'           : 1269 , # WATiLaPP
      'OPSMGR'             : 1270 , # Microsoft Operations Manager
      'EXCW'               : 1271 , # eXcW
      'CSPMLOCKMGR'        : 1272 , # CSPMLockMgr
      'EMC_GATEWAY'        : 1273 , # EMC_Gateway
      'T1DISTPROC'         : 1274 , # t1distproc
      'IVCOLLECTOR'        : 1275 , # ivcollector
      'MIVA_MQS'           : 1277 , # mqs
      'DELLWEBADMIN_1'     : 1278 , # Dell Web Admin 1
      'DELLWEBADMIN_2'     : 1279 , # Dell Web Admin 2
      'PICTROGRAPHY'       : 1280 , # Pictrography
      'HEALTHD'            : 1281 , # healthd
      'EMPERION'           : 1282 , # Emperion
      'PRODUCTINFO'        : 1283 , # Product Information
      'IEE_QFX'            : 1284 , # IEE_QFX
      'NEOIFACE'           : 1285 , # neoiface
      'NETUITIVE'          : 1286 , # netuitive
      'ROUTEMATCH'         : 1287 , # RouteMatch Com
      'NAVBUDDY'           : 1288 , # NavBuddy
      'JWALKSERVER'        : 1289 , # JWalkServer
      'WINJASERVER'        : 1290 , # WinJaServer
      'SEAGULLLMS'         : 1291 , # SEAGULLLMS
      'DSDN'               : 1292 , # dsdn
      'PKT_KRB_IPSEC'      : 1293 , # PKT_KRB_IPSec
      'CMMDRIVER'          : 1294 , # CMMdriver
      'EHTP'               : 1295 , # End_by_Hop Transmission Protocol
      'DPROXY'             : 1296 , # dproxy
      'SDPROXY'            : 1297 , # sdproxy
      'LPCP'               : 1298 , # lpcp
      'HP_SCI'             : 1299 , # hp_sci
      'H323HOSTCALLSC'     : 1300 , # H.323 Secure Call Control Signalling
      'CI3_SOFTWARE_1'     : 1301 , # CI3_Software_1
      'CI3_SOFTWARE_2'     : 1302 , # CI3_Software_2
      'SFTSRV'             : 1303 , # sftsrv
      'BOOMERANG'          : 1304 , # Boomerang
      'PE_MIKE'            : 1305 , # pe_mike
      'RE_CONN_PROTO'      : 1306 , # RE_Conn_Proto
      'PACMAND'            : 1307 , # Pacmand
      'ODSI'               : 1308 , # Optical Domain Service Interconnect (ODSI)
      'JTAG_SERVER'        : 1309 , # JTAG server
      'HUSKY'              : 1310 , # Husky
      'RXMON'              : 1311 , # RxMon
      'STI_ENVISION'       : 1312 , # STI Envision
      'BMC_PATROLDB'       : 1313 , # BMC_PATROLDBIANA assigned this well_formed service name as a replacement for "bmc_patroldb".
      'BMC_PATROLDB'       : 1313 , # BMC_PATROLDB
      'PDPS'               : 1314 , # Photoscript Distributed Printing System
      'ELS'                : 1315 , # E.L.S., Event Listener Service
      'EXBIT_ESCP'         : 1316 , # Exbit_ESCP
      'VRTS_IPCSERVER'     : 1317 , # vrts_ipcserver
      'KRB5GATEKEEPER'     : 1318 , # krb5gatekeeper
      'AMX_ICSP'           : 1319 , # AMX_ICSP
      'AMX_AXBNET'         : 1320 , # AMX_AXBNET
      'PIP'                : 1321 , # PIP
      'NOVATION'           : 1322 , # Novation
      'BRCD'               : 1323 , # brcd
      'DELTA_MCP'          : 1324 , # delta_mcp
      'DX_INSTRUMENT'      : 1325 , # DX_Instrument
      'WIMSIC'             : 1326 , # WIMSIC
      'ULTREX'             : 1327 , # Ultrex
      'EWALL'              : 1328 , # EWALL
      'NETDB_EXPORT'       : 1329 , # netdb_export
      'STREETPERFECT'      : 1330 , # StreetPerfect
      'INTERSAN'           : 1331 , # intersan
      'PCIA_RXP_B'         : 1332 , # PCIA RXP_B
      'PASSWRD_POLICY'     : 1333 , # Password Policy
      'WRITESRV'           : 1334 , # writesrv
      'DIGITAL_NOTARY'     : 1335 , # Digital Notary Protocol
      'ISCHAT'             : 1336 , # Instant Service Chat
      'MENANDMICE_DNS'     : 1337 , # menandmice DNS
      'WMC_LOG_SVC'        : 1338 , # WMC_log_svr
      'KJTSITESERVER'      : 1339 , # kjtsiteserver
      'NAAP'               : 1340 , # NAAP
      'QUBES'              : 1341 , # QuBES
      'ESBROKER'           : 1342 , # ESBroker
      'RE101'              : 1343 , # re101
      'ICAP'               : 1344 , # ICAP
      'VPJP'               : 1345 , # VPJP
      'ALTA_ANA_LM'        : 1346 , # Alta Analytics License Manager
      'BBN_MMC'            : 1347 , # multi media conferencing
      'BBN_MMX'            : 1348 , # multi media conferencing
      'SBOOK'              : 1349 , # Registration Network Protocol
      'EDITBENCH'          : 1350 , # Registration Network Protocol
      'EQUATIONBUILDER'    : 1351 , # Digital Tool Works (MIT)
      'LOTUSNOTE'          : 1352 , # Lotus Note
      'RELIEF'             : 1353 , # Relief Consulting
      'XSIP_NETWORK'       : 1354 , # Five Across XSIP Network
      'INTUITIVE_EDGE'     : 1355 , # Intuitive Edge
      'CUILLAMARTIN'       : 1356 , # CuillaMartin Company
      'PEGBOARD'           : 1357 , # Electronic PegBoard
      'CONNLCLI'           : 1358 , # CONNLCLI
      'FTSRV'              : 1359 , # FTSRV
      'MIMER'              : 1360 , # MIMER
      'LINX'               : 1361 , # LinX
      'TIMEFLIES'          : 1362 , # TimeFlies
      'NDM_REQUESTER'      : 1363 , # Network DataMover Requester
      'NDM_SERVER'         : 1364 , # Network DataMover Server
      'ADAPT_SNA'          : 1365 , # Network Software Associates
      'NETWARE_CSP'        : 1366 , # Novell NetWare Comm Service Platform
      'DCS'                : 1367 , # DCS
      'SCREENCAST'         : 1368 , # ScreenCast
      'GV_US'              : 1369 , # GlobalView to Unix Shell
      'US_GV'              : 1370 , # Unix Shell to GlobalView
      'FC_CLI'             : 1371 , # Fujitsu Config Protocol
      'FC_SER'             : 1372 , # Fujitsu Config Protocol
      'CHROMAGRAFX'        : 1373 , # Chromagrafx
      'MOLLY'              : 1374 , # EPI Software Systems
      'BYTEX'              : 1375 , # Bytex
      'IBM_PPS'            : 1376 , # IBM Person to Person Software
      'CICHLID'            : 1377 , # Cichlid License Manager
      'ELAN'               : 1378 , # Elan License Manager
      'DBREPORTER'         : 1379 , # Integrity Solutions
      'TELESIS_LICMAN'     : 1380 , # Telesis Network License Manager
      'APPLE_LICMAN'       : 1381 , # Apple Network License Manager
      'UDT_OS'             : 1382 , # udt_osIANA assigned this well_formed service name as a replacement for "udt_os".
      'UDT_OS'             : 1382 , # udt_os This entry is an alias to "udt_os".This entry is now historic, not usable for use with manycommon service discovery mechanisms.
      'GWHA'               : 1383 , # GW Hannaway Network License Manager
      'OS_LICMAN'          : 1384 , # Objective Solutions License Manager
      'ATEX_ELMD'          : 1385 , # Atex Publishing License ManagerIANA assigned this well_formed service name as a replacement for "atex_elmd".
      'ATEX_ELMD'          : 1385 , # Atex Publishing License Manager
      'CHECKSUM'           : 1386 , # CheckSum License Manager
      'CADSI_LM'           : 1387 , # Computer Aided Design Software Inc LM
      'OBJECTIVE_DBC'      : 1388 , # Objective Solutions DataBase Cache
      'ICLPV_DM'           : 1389 , # Document Manager
      'ICLPV_SC'           : 1390 , # Storage Controller
      'ICLPV_SAS'          : 1391 , # Storage Access Server
      'ICLPV_PM'           : 1392 , # Print Manager
      'ICLPV_NLS'          : 1393 , # Network Log Server
      'ICLPV_NLC'          : 1394 , # Network Log Client
      'ICLPV_WSM'          : 1395 , # PC Workstation Manager software
      'DVL_ACTIVEMAIL'     : 1396 , # DVL Active Mail
      'AUDIO_ACTIVMAIL'    : 1397 , # Audio Active Mail
      'VIDEO_ACTIVMAIL'    : 1398 , # Video Active Mail
      'CADKEY_LICMAN'      : 1399 , # Cadkey License Manager
      'CADKEY_TABLET'      : 1400 , # Cadkey Tablet Daemon
      'GOLDLEAF_LICMAN'    : 1401 , # Goldleaf License Manager
      'PRM_SM_NP'          : 1402 , # Prospero Resource Manager
      'PRM_NM_NP'          : 1403 , # Prospero Resource Manager
      'IGI_LM'             : 1404 , # Infinite Graphics License Manager
      'IBM_RES'            : 1405 , # IBM Remote Execution Starter
      'NETLABS_LM'         : 1406 , # NetLabs License Manager
      'DBSA_LM'            : 1407 , # DBSA License Manager
      'SOPHIA_LM'          : 1408 , # Sophia License Manager
      'HERE_LM'            : 1409 , # Here License Manager
      'HIQ'                : 1410 , # HiQ License Manager
      'AF'                 : 1411 , # AudioFile
      'INNOSYS'            : 1412 , # InnoSys
      'INNOSYS_ACL'        : 1413 , # Innosys_ACL
      'IBM_MQSERIES'       : 1414 , # IBM MQSeries
      'DBSTAR'             : 1415 , # DBStar
      'NOVELL_LU6_2'       : 1416 , # Novell LU6.2IANA assigned this well_formed service name as a replacement for "novell_lu6.2".
      'NOVELL_LU6.2'       : 1416 , # Novell LU6.2
      'TIMBUKTU_SRV1'      : 1417 , # Timbuktu Service 1 Port
      'TIMBUKTU_SRV2'      : 1418 , # Timbuktu Service 2 Port
      'TIMBUKTU_SRV3'      : 1419 , # Timbuktu Service 3 Port
      'TIMBUKTU_SRV4'      : 1420 , # Timbuktu Service 4 Port
      'GANDALF_LM'         : 1421 , # Gandalf License Manager
      'AUTODESK_LM'        : 1422 , # Autodesk License Manager
      'ESSBASE'            : 1423 , # Essbase Arbor Software
      'HYBRID'             : 1424 , # Hybrid Encryption Protocol
      'ZION_LM'            : 1425 , # Zion Software License Manager
      'SAIS'               : 1426 , # Satellite_data Acquisition System 1
      'MLOADD'             : 1427 , # mloadd monitoring tool
      'INFORMATIK_LM'      : 1428 , # Informatik License Manager
      'NMS'                : 1429 , # Hypercom NMS
      'TPDU'               : 1430 , # Hypercom TPDU
      'RGTP'               : 1431 , # Reverse Gossip Transport
      'BLUEBERRY_LM'       : 1432 , # Blueberry Software License Manager
      'MS_SQL_S'           : 1433 , # Microsoft_SQL_Server
      'MS_SQL_M'           : 1434 , # Microsoft_SQL_Monitor
      'IBM_CICS'           : 1435 , # IBM CICS
      'SAISM'              : 1436 , # Satellite_data Acquisition System 2
      'TABULA'             : 1437 , # Tabula
      'EICON_SERVER'       : 1438 , # Eicon Security Agent_Server
      'EICON_X25'          : 1439 , # Eicon X25_SNA Gateway
      'EICON_SLP'          : 1440 , # Eicon Service Location Protocol
      'CADIS_1'            : 1441 , # Cadis License Management
      'CADIS_2'            : 1442 , # Cadis License Management
      'IES_LM'             : 1443 , # Integrated Engineering Software
      'MARCAM_LM'          : 1444 , # Marcam  License Management
      'PROXIMA_LM'         : 1445 , # Proxima License Manager
      'ORA_LM'             : 1446 , # Optical Research Associates License Manager
      'APRI_LM'            : 1447 , # Applied Parallel Research LM
      'OC_LM'              : 1448 , # OpenConnect License Manager
      'PEPORT'             : 1449 , # PEport
      'DWF'                : 1450 , # Tandem Distributed Workbench Facility
      'INFOMAN'            : 1451 , # IBM Information Management
      'GTEGSC_LM'          : 1452 , # GTE Government Systems License Man
      'GENIE_LM'           : 1453 , # Genie License Manager
      'INTERHDL_ELMD'      : 1454 , # interHDL License ManagerIANA assigned this well_formed service name as a replacement for "interhdl_elmd".
      'INTERHDL_ELMD'      : 1454 , # interHDL License Manager
      'ESL_LM'             : 1455 , # ESL License Manager
      'DCA'                : 1456 , # DCA
      'VALISYS_LM'         : 1457 , # Valisys License Manager
      'NRCABQ_LM'          : 1458 , # Nichols Research Corp.
      'PROSHARE1'          : 1459 , # Proshare Notebook Application
      'PROSHARE2'          : 1460 , # Proshare Notebook Application
      'IBM_WRLESS_LAN'     : 1461 , # IBM Wireless LANIANA assigned this well_formed service name as a replacement for "ibm_wrless_lan".
      'IBM_WRLESS_LAN'     : 1461 , # IBM Wireless LAN
      'WORLD_LM'           : 1462 , # World License Manager
      'NUCLEUS'            : 1463 , # Nucleus
      'MSL_LMD'            : 1464 , # MSL License ManagerIANA assigned this well_formed service name as a replacement for "msl_lmd".
      'MSL_LMD'            : 1464 , # MSL License Manager
      'PIPES'              : 1465 , # Pipes Platform
      'OCEANSOFT_LM'       : 1466 , # Ocean Software License Manager
      'CSDMBASE'           : 1467 , # CSDMBASE
      'CSDM'               : 1468 , # CSDM
      'AAL_LM'             : 1469 , # Active Analysis Limited License Manager
      'UAIACT'             : 1470 , # Universal Analytics
      'CSDMBASE'           : 1471 , # csdmbase
      'CSDM'               : 1472 , # csdm
      'OPENMATH'           : 1473 , # OpenMath
      'TELEFINDER'         : 1474 , # Telefinder
      'TALIGENT_LM'        : 1475 , # Taligent License Manager
      'CLVM_CFG'           : 1476 , # clvm_cfg
      'MS_SNA_SERVER'      : 1477 , # ms_sna_server
      'MS_SNA_BASE'        : 1478 , # ms_sna_base
      'DBEREGISTER'        : 1479 , # dberegister
      'PACERFORUM'         : 1480 , # PacerForum
      'AIRS'               : 1481 , # AIRS
      'MITEKSYS_LM'        : 1482 , # Miteksys License Manager
      'AFS'                : 1483 , # AFS License Manager
      'CONFLUENT'          : 1484 , # Confluent License Manager
      'LANSOURCE'          : 1485 , # LANSource
      'NMS_TOPO_SERV'      : 1486 , # nms_topo_servIANA assigned this well_formed service name as a replacement for "nms_topo_serv".
      'NMS_TOPO_SERV'      : 1486 , # nms_topo_serv
      'LOCALINFOSRVR'      : 1487 , # LocalInfoSrvr
      'DOCSTOR'            : 1488 , # DocStor
      'DMDOCBROKER'        : 1489 , # dmdocbroker
      'INSITU_CONF'        : 1490 , # insitu_conf
      'STONE_DESIGN_1'     : 1492 , # stone_design_1
      'NETMAP_LM'          : 1493 , # netmap_lmIANA assigned this well_formed service name as a replacement for "netmap_lm".
      'NETMAP_LM'          : 1493 , # netmap_lm
      'ICA'                : 1494 , # ica
      'CVC'                : 1495 , # cvc
      'LIBERTY_LM'         : 1496 , # liberty_lm
      'RFX_LM'             : 1497 , # rfx_lm
      'SYBASE_SQLANY'      : 1498 , # Sybase SQL Any
      'FHC'                : 1499 , # Federico Heinz Consultora
      'VLSI_LM'            : 1500 , # VLSI License Manager
      'SAISCM'             : 1501 , # Satellite_data Acquisition System 3
      'SHIVADISCOVERY'     : 1502 , # Shiva
      'IMTC_MCS'           : 1503 , # Databeam
      'EVB_ELM'            : 1504 , # EVB Software Engineering License Manager
      'FUNKPROXY'          : 1505 , # Funk Software, Inc.
      'UTCD'               : 1506 , # Universal Time daemon (utcd)
      'SYMPLEX'            : 1507 , # symplex
      'DIAGMOND'           : 1508 , # diagmond
      'ROBCAD_LM'          : 1509 , # Robcad, Ltd. License Manager
      'MVX_LM'             : 1510 , # Midland Valley Exploration Ltd. Lic. Man.
      '3L_L1'              : 1511 , # 3l_l1
      'WINS'               : 1512 , # Microsoft's Windows Internet Name Service
      'FUJITSU_DTC'        : 1513 , # Fujitsu Systems Business of America, Inc
      'FUJITSU_DTCNS'      : 1514 , # Fujitsu Systems Business of America, Inc
      'IFOR_PROTOCOL'      : 1515 , # ifor_protocol
      'VPAD'               : 1516 , # Virtual Places Audio data
      'VPAC'               : 1517 , # Virtual Places Audio control
      'VPVD'               : 1518 , # Virtual Places Video data
      'VPVC'               : 1519 , # Virtual Places Video control
      'ATM_ZIP_OFFICE'     : 1520 , # atm zip office
      'NCUBE_LM'           : 1521 , # nCube License Manager
      'RICARDO_LM'         : 1522 , # Ricardo North America License Manager
      'CICHILD_LM'         : 1523 , # cichild
      'INGRESLOCK'         : 1524 , # ingres
      'ORASRV'             : 1525 , # oracle
      'PROSPERO_NP'        : 1525 , # Prospero Directory Service non_priv
      'PDAP_NP'            : 1526 , # Prospero Data Access Prot non_priv
      'TLISRV'             : 1527 , # oracle
      'COAUTHOR'           : 1529 , # oracle
      'RAP_SERVICE'        : 1530 , # rap_service
      'RAP_LISTEN'         : 1531 , # rap_listen
      'MIROCONNECT'        : 1532 , # miroconnect
      'VIRTUAL_PLACES'     : 1533 , # Virtual Places Software
      'MICROMUSE_LM'       : 1534 , # micromuse_lm
      'AMPR_INFO'          : 1535 , # ampr_info
      'AMPR_INTER'         : 1536 , # ampr_inter
      'SDSC_LM'            : 1537 , # isi_lm
      '3DS_LM'             : 1538 , # 3ds_lm
      'INTELLISTOR_LM'     : 1539 , # Intellistor License Manager
      'RDS'                : 1540 , # rds
      'RDS2'               : 1541 , # rds2
      'GRIDGEN_ELMD'       : 1542 , # gridgen_elmd
      'SIMBA_CS'           : 1543 , # simba_cs
      'ASPECLMD'           : 1544 , # aspeclmd
      'VISTIUM_SHARE'      : 1545 , # vistium_share
      'ABBACCURAY'         : 1546 , # abbaccuray
      'LAPLINK'            : 1547 , # laplink
      'AXON_LM'            : 1548 , # Axon License Manager
      'SHIVAHOSE'          : 1549 , # Shiva Hose
      '3M_IMAGE_LM'        : 1550 , # Image Storage license manager 3M Company
      'HECMTL_DB'          : 1551 , # HECMTL_DB
      'PCIARRAY'           : 1552 , # pciarray
      'SNA_CS'             : 1553 , # sna_cs
      'CACI_LM'            : 1554 , # CACI Products Company License Manager
      'LIVELAN'            : 1555 , # livelan
      'VERITAS_PBX'        : 1556 , # VERITAS Private Branch ExchangeIANA assigned this well_formed service name as a replacement for "veritas_pbx".
      'VERITAS_PBX'        : 1556 , # VERITAS Private Branch Exchange
      'ARBORTEXT_LM'       : 1557 , # ArborText License Manager
      'XINGMPEG'           : 1558 , # xingmpeg
      'WEB2HOST'           : 1559 , # web2host
      'ASCI_VAL'           : 1560 , # ASCI_RemoteSHADOW
      'FACILITYVIEW'       : 1561 , # facilityview
      'PCONNECTMGR'        : 1562 , # pconnectmgr
      'CADABRA_LM'         : 1563 , # Cadabra License Manager
      'PAY_PER_VIEW'       : 1564 , # Pay_Per_View
      'WINDDLB'            : 1565 , # WinDD
      'CORELVIDEO'         : 1566 , # CORELVIDEO
      'JLICELMD'           : 1567 , # jlicelmd
      'TSSPMAP'            : 1568 , # tsspmap
      'ETS'                : 1569 , # ets
      'ORBIXD'             : 1570 , # orbixd
      'RDB_DBS_DISP'       : 1571 , # Oracle Remote Data Base
      'CHIP_LM'            : 1572 , # Chipcom License Manager
      'ITSCOMM_NS'         : 1573 , # itscomm_ns
      'MVEL_LM'            : 1574 , # mvel_lm
      'ORACLENAMES'        : 1575 , # oraclenames
      'MOLDFLOW_LM'        : 1576 , # Moldflow License Manager
      'HYPERCUBE_LM'       : 1577 , # hypercube_lm
      'JACOBUS_LM'         : 1578 , # Jacobus License Manager
      'IOC_SEA_LM'         : 1579 , # ioc_sea_lm
      'TN_TL_R1'           : 1580 , # tn_tl_r1
      'MIL_2045_47001'     : 1581 , # MIL_2045_47001
      'MSIMS'              : 1582 , # MSIMS
      'SIMBAEXPRESS'       : 1583 , # simbaexpress
      'TN_TL_FD2'          : 1584 , # tn_tl_fd2
      'INTV'               : 1585 , # intv
      'IBM_ABTACT'         : 1586 , # ibm_abtact
      'PRA_ELMD'           : 1587 , # pra_elmdIANA assigned this well_formed service name as a replacement for "pra_elmd".
      'PRA_ELMD'           : 1587 , # pra_elmd
      'TRIQUEST_LM'        : 1588 , # triquest_lm
      'VQP'                : 1589 , # VQP
      'GEMINI_LM'          : 1590 , # gemini_lm
      'NCPM_PM'            : 1591 , # ncpm_pm
      'COMMONSPACE'        : 1592 , # commonspace
      'MAINSOFT_LM'        : 1593 , # mainsoft_lm
      'SIXTRAK'            : 1594 , # sixtrak
      'RADIO'              : 1595 , # radio
      'RADIO_SM'           : 1596 , # radio_sm
      'ORBPLUS_IIOP'       : 1597 , # orbplus_iiop
      'PICKNFS'            : 1598 , # picknfs
      'SIMBASERVICES'      : 1599 , # simbaservices
      'ISSD'               : 1600 , # issd
      'AAS'                : 1601 , # aas
      'INSPECT'            : 1602 , # inspect
      'PICODBC'            : 1603 , # pickodbc
      'ICABROWSER'         : 1604 , # icabrowser
      'SLP'                : 1605 , # Salutation Manager (Salutation Protocol)
      'SLM_API'            : 1606 , # Salutation Manager (SLM_API)
      'STT'                : 1607 , # stt
      'SMART_LM'           : 1608 , # Smart Corp. License Manager
      'ISYSG_LM'           : 1609 , # isysg_lm
      'TAURUS_WH'          : 1610 , # taurus_wh
      'ILL'                : 1611 , # Inter Library Loan
      'NETBILL_TRANS'      : 1612 , # NetBill Transaction Server
      'NETBILL_KEYREP'     : 1613 , # NetBill Key Repository
      'NETBILL_CRED'       : 1614 , # NetBill Credential Server
      'NETBILL_AUTH'       : 1615 , # NetBill Authorization Server
      'NETBILL_PROD'       : 1616 , # NetBill Product Server
      'NIMROD_AGENT'       : 1617 , # Nimrod Inter_Agent Communication
      'SKYTELNET'          : 1618 , # skytelnet
      'XS_OPENSTORAGE'     : 1619 , # xs_openstorage
      'FAXPORTWINPORT'     : 1620 , # faxportwinport
      'SOFTDATAPHONE'      : 1621 , # softdataphone
      'ONTIME'             : 1622 , # ontime
      'JALEOSND'           : 1623 , # jaleosnd
      'UDP_SR_PORT'        : 1624 , # udp_sr_port
      'SVS_OMAGENT'        : 1625 , # svs_omagent
      'SHOCKWAVE'          : 1626 , # Shockwave
      'T128_GATEWAY'       : 1627 , # T.128 Gateway
      'LONTALK_NORM'       : 1628 , # LonTalk normal
      'LONTALK_URGNT'      : 1629 , # LonTalk urgent
      'ORACLENET8CMAN'     : 1630 , # Oracle Net8 Cman
      'VISITVIEW'          : 1631 , # Visit view
      'PAMMRATC'           : 1632 , # PAMMRATC
      'PAMMRPC'            : 1633 , # PAMMRPC
      'LOAPROBE'           : 1634 , # Log On America Probe
      'EDB_SERVER1'        : 1635 , # EDB Server 1
      'ISDC'               : 1636 , # ISP shared public data control
      'ISLC'               : 1637 , # ISP shared local data control
      'ISMC'               : 1638 , # ISP shared management control
      'CERT_INITIATOR'     : 1639 , # cert_initiator
      'CERT_RESPONDER'     : 1640 , # cert_responder
      'INVISION'           : 1641 , # InVision
      'ISIS_AM'            : 1642 , # isis_am
      'ISIS_AMBC'          : 1643 , # isis_ambc
      'SAISEH'             : 1644 , # Satellite_data Acquisition System 4
      'SIGHTLINE'          : 1645 , # SightLine
      'SA_MSG_PORT'        : 1646 , # sa_msg_port
      'RSAP'               : 1647 , # rsap
      'CONCURRENT_LM'      : 1648 , # concurrent_lm
      'KERMIT'             : 1649 , # kermit
      'NKD'                : 1650 , # nkdn
      'SHIVA_CONFSRVR'     : 1651 , # shiva_confsrvrIANA assigned this well_formed service name as a replacement for "shiva_confsrvr".
      'SHIVA_CONFSRVR'     : 1651 , # shiva_confsrvr
      'XNMP'               : 1652 , # xnmp
      'ALPHATECH_LM'       : 1653 , # alphatech_lm
      'STARGATEALERTS'     : 1654 , # stargatealerts
      'DEC_MBADMIN'        : 1655 , # dec_mbadmin
      'DEC_MBADMIN_H'      : 1656 , # dec_mbadmin_h
      'FUJITSU_MMPDC'      : 1657 , # fujitsu_mmpdc
      'SIXNETUDR'          : 1658 , # sixnetudr
      'SG_LM'              : 1659 , # Silicon Grail License Manager
      'SKIP_MC_GIKREQ'     : 1660 , # skip_mc_gikreq
      'NETVIEW_AIX_1'      : 1661 , # netview_aix_1
      'NETVIEW_AIX_2'      : 1662 , # netview_aix_2
      'NETVIEW_AIX_3'      : 1663 , # netview_aix_3
      'NETVIEW_AIX_4'      : 1664 , # netview_aix_4
      'NETVIEW_AIX_5'      : 1665 , # netview_aix_5
      'NETVIEW_AIX_6'      : 1666 , # netview_aix_6
      'NETVIEW_AIX_7'      : 1667 , # netview_aix_7
      'NETVIEW_AIX_8'      : 1668 , # netview_aix_8
      'NETVIEW_AIX_9'      : 1669 , # netview_aix_9
      'NETVIEW_AIX_10'     : 1670 , # netview_aix_10
      'NETVIEW_AIX_11'     : 1671 , # netview_aix_11
      'NETVIEW_AIX_12'     : 1672 , # netview_aix_12
      'PROSHARE_MC_1'      : 1673 , # Intel Proshare Multicast
      'PROSHARE_MC_2'      : 1674 , # Intel Proshare Multicast
      'PDP'                : 1675 , # Pacific Data Products
      'NETCOMM1'           : 1676 , # netcomm1
      'GROUPWISE'          : 1677 , # groupwise
      'PROLINK'            : 1678 , # prolink
      'DARCORP_LM'         : 1679 , # darcorp_lm
      'MICROCOM_SBP'       : 1680 , # microcom_sbp
      'SD_ELMD'            : 1681 , # sd_elmd
      'LANYON_LANTERN'     : 1682 , # lanyon_lantern
      'NCPM_HIP'           : 1683 , # ncpm_hip
      'SNARESECURE'        : 1684 , # SnareSecure
      'N2NREMOTE'          : 1685 , # n2nremote
      'CVMON'              : 1686 , # cvmon
      'NSJTP_CTRL'         : 1687 , # nsjtp_ctrl
      'NSJTP_DATA'         : 1688 , # nsjtp_data
      'FIREFOX'            : 1689 , # firefox
      'NG_UMDS'            : 1690 , # ng_umds
      'EMPIRE_EMPUMA'      : 1691 , # empire_empuma
      'SSTSYS_LM'          : 1692 , # sstsys_lm
      'RRIRTR'             : 1693 , # rrirtr
      'RRIMWM'             : 1694 , # rrimwm
      'RRILWM'             : 1695 , # rrilwm
      'RRIFMM'             : 1696 , # rrifmm
      'RRISAT'             : 1697 , # rrisat
      'RSVP_ENCAP_1'       : 1698 , # RSVP_ENCAPSULATION_1
      'RSVP_ENCAP_2'       : 1699 , # RSVP_ENCAPSULATION_2
      'MPS_RAFT'           : 1700 , # mps_raft
      'L2F'                : 1701 , # l2f
      'L2TP'               : 1701 , # l2tp
      'DESKSHARE'          : 1702 , # deskshare
      'HB_ENGINE'          : 1703 , # hb_engine
      'BCS_BROKER'         : 1704 , # bcs_broker
      'SLINGSHOT'          : 1705 , # slingshot
      'JETFORM'            : 1706 , # jetform
      'VDMPLAY'            : 1707 , # vdmplay
      'GAT_LMD'            : 1708 , # gat_lmd
      'CENTRA'             : 1709 , # centra
      'IMPERA'             : 1710 , # impera
      'PPTCONFERENCE'      : 1711 , # pptconference
      'REGISTRAR'          : 1712 , # resource monitoring service
      'CONFERENCETALK'     : 1713 , # ConferenceTalk
      'SESI_LM'            : 1714 , # sesi_lm
      'HOUDINI_LM'         : 1715 , # houdini_lm
      'XMSG'               : 1716 , # xmsg
      'FJ_HDNET'           : 1717 , # fj_hdnet
      'H323GATEDISC'       : 1718 , # H.323 Multicast Gatekeeper Discover
      'H323GATESTAT'       : 1719 , # H.323 Unicast Gatekeeper Signaling
      'H323HOSTCALL'       : 1720 , # H.323 Call Control Signalling
      'CAICCI'             : 1721 , # caicci
      'HKS_LM'             : 1722 , # HKS License Manager
      'PPTP'               : 1723 , # pptp
      'CSBPHONEMASTER'     : 1724 , # csbphonemaster
      'IDEN_RALP'          : 1725 , # iden_ralp
      'IBERIAGAMES'        : 1726 , # IBERIAGAMES
      'WINDDX'             : 1727 , # winddx
      'TELINDUS'           : 1728 , # TELINDUS
      'CITYNL'             : 1729 , # CityNL License Management
      'ROKETZ'             : 1730 , # roketz
      'MSICCP'             : 1731 , # MSICCP
      'PROXIM'             : 1732 , # proxim
      'SIIPAT'             : 1733 , # SIMS _ SIIPAT Protocol for Alarm Transmission
      'CAMBERTX_LM'        : 1734 , # Camber Corporation License Management
      'PRIVATECHAT'        : 1735 , # PrivateChat
      'STREET_STREAM'      : 1736 , # street_stream
      'ULTIMAD'            : 1737 , # ultimad
      'GAMEGEN1'           : 1738 , # GameGen1
      'WEBACCESS'          : 1739 , # webaccess
      'ENCORE'             : 1740 , # encore
      'CISCO_NET_MGMT'     : 1741 , # cisco_net_mgmt
      '3COM_NSD'           : 1742 , # 3Com_nsd
      'CINEGRFX_LM'        : 1743 , # Cinema Graphics License Manager
      'NCPM_FT'            : 1744 , # ncpm_ft
      'REMOTE_WINSOCK'     : 1745 , # remote_winsock
      'FTRAPID_1'          : 1746 , # ftrapid_1
      'FTRAPID_2'          : 1747 , # ftrapid_2
      'ORACLE_EM1'         : 1748 , # oracle_em1
      'ASPEN_SERVICES'     : 1749 , # aspen_services
      'SSLP'               : 1750 , # Simple Socket Library's PortMaster
      'SWIFTNET'           : 1751 , # SwiftNet
      'LOFR_LM'            : 1752 , # Leap of Faith Research License Manager
      'PREDATAR_COMMS'     : 1753 , # Predatar Comms Service
      'ORACLE_EM2'         : 1754 , # oracle_em2
      'MS_STREAMING'       : 1755 , # ms_streaming
      'CAPFAST_LMD'        : 1756 , # capfast_lmd
      'CNHRP'              : 1757 , # cnhrp
      'TFTP_MCAST'         : 1758 , # tftp_mcast
      'SPSS_LM'            : 1759 , # SPSS License Manager
      'WWW_LDAP_GW'        : 1760 , # www_ldap_gw
      'CFT_0'              : 1761 , # cft_0
      'CFT_1'              : 1762 , # cft_1
      'CFT_2'              : 1763 , # cft_2
      'CFT_3'              : 1764 , # cft_3
      'CFT_4'              : 1765 , # cft_4
      'CFT_5'              : 1766 , # cft_5
      'CFT_6'              : 1767 , # cft_6
      'CFT_7'              : 1768 , # cft_7
      'BMC_NET_ADM'        : 1769 , # bmc_net_adm
      'BMC_NET_SVC'        : 1770 , # bmc_net_svc
      'VAULTBASE'          : 1771 , # vaultbase
      'ESSWEB_GW'          : 1772 , # EssWeb Gateway
      'KMSCONTROL'         : 1773 , # KMSControl
      'GLOBAL_DTSERV'      : 1774 , # global_dtserv
      'VDAB'               : 1775 , # data interchange between visual processing containers
      'FEMIS'              : 1776 , # Federal Emergency Management Information System
      'POWERGUARDIAN'      : 1777 , # powerguardian
      'PRODIGY_INTRNET'    : 1778 , # prodigy_internet
      'PHARMASOFT'         : 1779 , # pharmasoft
      'DPKEYSERV'          : 1780 , # dpkeyserv
      'ANSWERSOFT_LM'      : 1781 , # answersoft_lm
      'HP_HCIP'            : 1782 , # hp_hcip
      'FINLE_LM'           : 1784 , # Finle License Manager
      'WINDLM'             : 1785 , # Wind River Systems License Manager
      'FUNK_LOGGER'        : 1786 , # funk_logger
      'FUNK_LICENSE'       : 1787 , # funk_license
      'PSMOND'             : 1788 , # psmond
      'HELLO'              : 1789 , # hello
      'NMSP'               : 1790 , # Narrative Media Streaming Protocol
      'EA1'                : 1791 , # EA1
      'IBM_DT_2'           : 1792 , # ibm_dt_2
      'RSC_ROBOT'          : 1793 , # rsc_robot
      'CERA_BCM'           : 1794 , # cera_bcm
      'DPI_PROXY'          : 1795 , # dpi_proxy
      'VOCALTEC_ADMIN'     : 1796 , # Vocaltec Server Administration
      'UMA'                : 1797 , # UMA
      'ETP'                : 1798 , # Event Transfer Protocol
      'NETRISK'            : 1799 , # NETRISK
      'ANSYS_LM'           : 1800 , # ANSYS_License manager
      'MSMQ'               : 1801 , # Microsoft Message Que
      'CONCOMP1'           : 1802 , # ConComp1
      'HP_HCIP_GWY'        : 1803 , # HP_HCIP_GWY
      'ENL'                : 1804 , # ENL
      'ENL_NAME'           : 1805 , # ENL_Name
      'MUSICONLINE'        : 1806 , # Musiconline
      'FHSP'               : 1807 , # Fujitsu Hot Standby Protocol
      'ORACLE_VP2'         : 1808 , # Oracle_VP2
      'ORACLE_VP1'         : 1809 , # Oracle_VP1
      'JERAND_LM'          : 1810 , # Jerand License Manager
      'SCIENTIA_SDB'       : 1811 , # Scientia_SDB
      'RADIUS'             : 1812 , # RADIUS
      'RADIUS_ACCT'        : 1813 , # RADIUS Accounting
      'TDP_SUITE'          : 1814 , # TDP Suite
      'MMPFT'              : 1815 , # MMPFT
      'HARP'               : 1816 , # HARP
      'RKB_OSCS'           : 1817 , # RKB_OSCS
      'ETFTP'              : 1818 , # Enhanced Trivial File Transfer Protocol
      'PLATO_LM'           : 1819 , # Plato License Manager
      'MCAGENT'            : 1820 , # mcagent
      'DONNYWORLD'         : 1821 , # donnyworld
      'ES_ELMD'            : 1822 , # es_elmd
      'UNISYS_LM'          : 1823 , # Unisys Natural Language License Manager
      'METRICS_PAS'        : 1824 , # metrics_pas
      'DIRECPC_VIDEO'      : 1825 , # DirecPC Video
      'ARDT'               : 1826 , # ARDT
      'ASI'                : 1827 , # ASI
      'ITM_MCELL_U'        : 1828 , # itm_mcell_u
      'OPTIKA_EMEDIA'      : 1829 , # Optika eMedia
      'NET8_CMAN'          : 1830 , # Oracle Net8 CMan Admin
      'MYRTLE'             : 1831 , # Myrtle
      'THT_TREASURE'       : 1832 , # ThoughtTreasure
      'UDPRADIO'           : 1833 , # udpradio
      'ARDUSUNI'           : 1834 , # ARDUS Unicast
      'ARDUSMUL'           : 1835 , # ARDUS Multicast
      'STE_SMSC'           : 1836 , # ste_smsc
      'CSOFT1'             : 1837 , # csoft1
      'TALNET'             : 1838 , # TALNET
      'NETOPIA_VO1'        : 1839 , # netopia_vo1
      'NETOPIA_VO2'        : 1840 , # netopia_vo2
      'NETOPIA_VO3'        : 1841 , # netopia_vo3
      'NETOPIA_VO4'        : 1842 , # netopia_vo4
      'NETOPIA_VO5'        : 1843 , # netopia_vo5
      'DIRECPC_DLL'        : 1844 , # DirecPC_DLL
      'ALTALINK'           : 1845 , # altalink
      'TUNSTALL_PNC'       : 1846 , # Tunstall PNC
      'SLP_NOTIFY'         : 1847 , # SLP Notification
      'FJDOCDIST'          : 1848 , # fjdocdist
      'ALPHA_SMS'          : 1849 , # ALPHA_SMS
      'GSI'                : 1850 , # GSI
      'CTCD'               : 1851 , # ctcd
      'VIRTUAL_TIME'       : 1852 , # Virtual Time
      'VIDS_AVTP'          : 1853 , # VIDS_AVTP
      'BUDDY_DRAW'         : 1854 , # Buddy Draw
      'FIORANO_RTRSVC'     : 1855 , # Fiorano RtrSvc
      'FIORANO_MSGSVC'     : 1856 , # Fiorano MsgSvc
      'DATACAPTOR'         : 1857 , # DataCaptor
      'PRIVATEARK'         : 1858 , # PrivateArk
      'GAMMAFETCHSVR'      : 1859 , # Gamma Fetcher Server
      'SUNSCALAR_SVC'      : 1860 , # SunSCALAR Services
      'LECROY_VICP'        : 1861 , # LeCroy VICP
      'MYSQL_CM_AGENT'     : 1862 , # MySQL Cluster Manager Agent
      'MSNP'               : 1863 , # MSNP
      'PARADYM_31PORT'     : 1864 , # Paradym 31 Port
      'ENTP'               : 1865 , # ENTP
      'SWRMI'              : 1866 , # swrmi
      'UDRIVE'             : 1867 , # UDRIVE
      'VIZIBLEBROWSER'     : 1868 , # VizibleBrowser
      'TRANSACT'           : 1869 , # TransAct
      'SUNSCALAR_DNS'      : 1870 , # SunSCALAR DNS Service
      'CANOCENTRAL0'       : 1871 , # Cano Central 0
      'CANOCENTRAL1'       : 1872 , # Cano Central 1
      'FJMPJPS'            : 1873 , # Fjmpjps
      'FJSWAPSNP'          : 1874 , # Fjswapsnp
      'WESTELL_STATS'      : 1875 , # westell stats
      'EWCAPPSRV'          : 1876 , # ewcappsrv
      'HP_WEBQOSDB'        : 1877 , # hp_webqosdb
      'DRMSMC'             : 1878 , # drmsmc
      'NETTGAIN_NMS'       : 1879 , # NettGain NMS
      'VSAT_CONTROL'       : 1880 , # Gilat VSAT Control
      'IBM_MQSERIES2'      : 1881 , # IBM WebSphere MQ Everyplace
      'ECSQDMN'            : 1882 , # CA eTrust Common Services
      'IBM_MQISDP'         : 1883 , # IBM MQSeries SCADA
      'IDMAPS'             : 1884 , # Internet Distance Map Svc
      'VRTSTRAPSERVER'     : 1885 , # Veritas Trap Server
      'LEOIP'              : 1886 , # Leonardo over IP
      'FILEX_LPORT'        : 1887 , # FileX Listening Port
      'NCCONFIG'           : 1888 , # NC Config Port
      'UNIFY_ADAPTER'      : 1889 , # Unify Web Adapter Service
      'WILKENLISTENER'     : 1890 , # wilkenListener
      'CHILDKEY_NOTIF'     : 1891 , # ChildKey Notification
      'CHILDKEY_CTRL'      : 1892 , # ChildKey Control
      'ELAD'               : 1893 , # ELAD Protocol
      'O2SERVER_PORT'      : 1894 , # O2Server Port
      'B_NOVATIVE_LS'      : 1896 , # b_novative license server
      'METAAGENT'          : 1897 , # MetaAgent
      'CYMTEC_PORT'        : 1898 , # Cymtec secure management
      'MC2STUDIOS'         : 1899 , # MC2Studios
      'SSDP'               : 1900 , # SSDP
      'FJICL_TEP_A'        : 1901 , # Fujitsu ICL Terminal Emulator Program A
      'FJICL_TEP_B'        : 1902 , # Fujitsu ICL Terminal Emulator Program B
      'LINKNAME'           : 1903 , # Local Link Name Resolution
      'FJICL_TEP_C'        : 1904 , # Fujitsu ICL Terminal Emulator Program C
      'SUGP'               : 1905 , # Secure UP.Link Gateway Protocol
      'TPMD'               : 1906 , # TPortMapperReq
      'INTRASTAR'          : 1907 , # IntraSTAR
      'DAWN'               : 1908 , # Dawn
      'GLOBAL_WLINK'       : 1909 , # Global World Link
      'ULTRABAC'           : 1910 , # UltraBac Software communications port
      'MTP'                : 1911 , # Starlight Networks Multimedia Transport Protocol
      'RHP_IIBP'           : 1912 , # rhp_iibp
      'ARMADP'             : 1913 , # armadp
      'ELM_MOMENTUM'       : 1914 , # Elm_Momentum
      'FACELINK'           : 1915 , # FACELINK
      'PERSONA'            : 1916 , # Persoft Persona
      'NOAGENT'            : 1917 , # nOAgent
      'CAN_NDS'            : 1918 , # IBM Tivole Directory Service _ NDS
      'CAN_DCH'            : 1919 , # IBM Tivoli Directory Service _ DCH
      'CAN_FERRET'         : 1920 , # IBM Tivoli Directory Service _ FERRET
      'NOADMIN'            : 1921 , # NoAdmin
      'TAPESTRY'           : 1922 , # Tapestry
      'SPICE'              : 1923 , # SPICE
      'XIIP'               : 1924 , # XIIP
      'DISCOVERY_PORT'     : 1925 , # Surrogate Discovery Port
      'EGS'                : 1926 , # Evolution Game Server
      'VIDETE_CIPC'        : 1927 , # Videte CIPC Port
      'EMSD_PORT'          : 1928 , # Expnd Maui Srvr Dscovr
      'BANDWIZ_SYSTEM'     : 1929 , # Bandwiz System _ Server
      'DRIVEAPPSERVER'     : 1930 , # Drive AppServer
      'AMDSCHED'           : 1931 , # AMD SCHED
      'CTT_BROKER'         : 1932 , # CTT Broker
      'XMAPI'              : 1933 , # IBM LM MT Agent
      'XAAPI'              : 1934 , # IBM LM Appl Agent
      'MACROMEDIA_FCS'     : 1935 , # Macromedia Flash Communications Server MX
      'JETCMESERVER'       : 1936 , # JetCmeServer Server Port
      'JWSERVER'           : 1937 , # JetVWay Server Port
      'JWCLIENT'           : 1938 , # JetVWay Client Port
      'JVSERVER'           : 1939 , # JetVision Server Port
      'JVCLIENT'           : 1940 , # JetVision Client Port
      'DIC_AIDA'           : 1941 , # DIC_Aida
      'RES'                : 1942 , # Real Enterprise Service
      'BEEYOND_MEDIA'      : 1943 , # Beeyond Media
      'CLOSE_COMBAT'       : 1944 , # close_combat
      'DIALOGIC_ELMD'      : 1945 , # dialogic_elmd
      'TEKPLS'             : 1946 , # tekpls
      'SENTINELSRM'        : 1947 , # SentinelSRM
      'EYE2EYE'            : 1948 , # eye2eye
      'ISMAEASDAQLIVE'     : 1949 , # ISMA Easdaq Live
      'ISMAEASDAQTEST'     : 1950 , # ISMA Easdaq Test
      'BCS_LMSERVER'       : 1951 , # bcs_lmserver
      'MPNJSC'             : 1952 , # mpnjsc
      'RAPIDBASE'          : 1953 , # Rapid Base
      'ABR_API'            : 1954 , # ABR_API (diskbridge)
      'ABR_SECURE'         : 1955 , # ABR_Secure Data (diskbridge)
      'VRTL_VMF_DS'        : 1956 , # Vertel VMF DS
      'UNIX_STATUS'        : 1957 , # unix_status
      'DXADMIND'           : 1958 , # CA Administration Daemon
      'SIMP_ALL'           : 1959 , # SIMP Channel
      'NASMANAGER'         : 1960 , # Merit DAC NASmanager
      'BTS_APPSERVER'      : 1961 , # BTS APPSERVER
      'BIAP_MP'            : 1962 , # BIAP_MP
      'WEBMACHINE'         : 1963 , # WebMachine
      'SOLID_E_ENGINE'     : 1964 , # SOLID E ENGINE
      'TIVOLI_NPM'         : 1965 , # Tivoli NPM
      'SLUSH'              : 1966 , # Slush
      'SNS_QUOTE'          : 1967 , # SNS Quote
      'LIPSINC'            : 1968 , # LIPSinc
      'LIPSINC1'           : 1969 , # LIPSinc 1
      'NETOP_RC'           : 1970 , # NetOp Remote Control
      'NETOP_SCHOOL'       : 1971 , # NetOp School
      'INTERSYS_CACHE'     : 1972 , # Cache
      'DLSRAP'             : 1973 , # Data Link Switching Remote Access Protocol
      'DRP'                : 1974 , # DRP
      'TCOFLASHAGENT'      : 1975 , # TCO Flash Agent
      'TCOREGAGENT'        : 1976 , # TCO Reg Agent
      'TCOADDRESSBOOK'     : 1977 , # TCO Address Book
      'UNISQL'             : 1978 , # UniSQL
      'UNISQL_JAVA'        : 1979 , # UniSQL Java
      'PEARLDOC_XACT'      : 1980 , # PearlDoc XACT
      'P2PQ'               : 1981 , # p2pQ
      'ESTAMP'             : 1982 , # Evidentiary Timestamp
      'LHTP'               : 1983 , # Loophole Test Protocol
      'BB'                 : 1984 , # BB
      'HSRP'               : 1985 , # Hot Standby Router Protocol
      'LICENSEDAEMON'      : 1986 , # cisco license management
      'TR_RSRB_P1'         : 1987 , # cisco RSRB Priority 1 port
      'TR_RSRB_P2'         : 1988 , # cisco RSRB Priority 2 port
      'TR_RSRB_P3'         : 1989 , # cisco RSRB Priority 3 port
      'MSHNET'             : 1989 , # MHSnet system
      'STUN_P1'            : 1990 , # cisco STUN Priority 1 port
      'STUN_P2'            : 1991 , # cisco STUN Priority 2 port
      'STUN_P3'            : 1992 , # cisco STUN Priority 3 port
      'IPSENDMSG'          : 1992 , # IPsendmsg
      'SNMP_TCP_PORT'      : 1993 , # cisco SNMP TCP port
      'STUN_PORT'          : 1994 , # cisco serial tunnel port
      'PERF_PORT'          : 1995 , # cisco perf port
      'TR_RSRB_PORT'       : 1996 , # cisco Remote SRB port
      'GDP_PORT'           : 1997 , # cisco Gateway Discovery Protocol
      'X25_SVC_PORT'       : 1998 , # cisco X.25 service (XOT)
      'TCP_ID_PORT'        : 1999 , # cisco identification port
      'CISCO_SCCP'         : 2000 , # Cisco SCCP
      'DC'                 : 2001 , # 
      'GLOBE'              : 2002 , # 
      'BRUTUS'             : 2003 , # Brutus Server
      'MAILBOX'            : 2004 , # 
      'BERKNET'            : 2005 , # 
      'INVOKATOR'          : 2006 , # 
      'DECTALK'            : 2007 , # 
      'CONF'               : 2008 , # 
      'NEWS'               : 2009 , # 
      'SEARCH'             : 2010 , # 
      'RAID_CC'            : 2011 , # raid
      'TTYINFO'            : 2012 , # 
      'RAID_AM'            : 2013 , # 
      'TROFF'              : 2014 , # 
      'CYPRESS'            : 2015 , # 
      'BOOTSERVER'         : 2016 , # 
      'CYPRESS_STAT'       : 2017 , # 
      'TERMINALDB'         : 2018 , # 
      'WHOSOCKAMI'         : 2019 , # 
      'XINUPAGESERVER'     : 2020 , # 
      'SERVEXEC'           : 2021 , # 
      'DOWN'               : 2022 , # 
      'XINUEXPANSION3'     : 2023 , # 
      'XINUEXPANSION4'     : 2024 , # 
      'ELLPACK'            : 2025 , # 
      'SCRABBLE'           : 2026 , # 
      'SHADOWSERVER'       : 2027 , # 
      'SUBMITSERVER'       : 2028 , # 
      'HSRPV6'             : 2029 , # Hot Standby Router Protocol IPv6
      'DEVICE2'            : 2030 , # 
      'MOBRIEN_CHAT'       : 2031 , # mobrien_chat
      'BLACKBOARD'         : 2032 , # 
      'GLOGGER'            : 2033 , # 
      'SCOREMGR'           : 2034 , # 
      'IMSLDOC'            : 2035 , # 
      'E_DPNET'            : 2036 , # Ethernet WS DP network
      'APPLUS'             : 2037 , # APplus Application Server
      'OBJECTMANAGER'      : 2038 , # 
      'PRIZMA'             : 2039 , # Prizma Monitoring Service
      'LAM'                : 2040 , # 
      'INTERBASE'          : 2041 , # 
      'ISIS'               : 2042 , # isis
      'ISIS_BCAST'         : 2043 , # isis_bcast
      'RIMSL'              : 2044 , # 
      'CDFUNC'             : 2045 , # 
      'SDFUNC'             : 2046 , # 
      'DLS'                : 2047 , # 
      'DLS_MONITOR'        : 2048 , # 
      'NFS'                : 2049 , # Network File System _ Sun Microsystems
      'AV_EMB_CONFIG'      : 2050 , # Avaya EMB Config Port
      'EPNSDP'             : 2051 , # EPNSDP
      'CLEARVISN'          : 2052 , # clearVisn Services Port
      'LOT105_DS_UPD'      : 2053 , # Lot105 DSuper Updates
      'WEBLOGIN'           : 2054 , # Weblogin Port
      'IOP'                : 2055 , # Iliad_Odyssey Protocol
      'OMNISKY'            : 2056 , # OmniSky Port
      'RICH_CP'            : 2057 , # Rich Content Protocol
      'NEWWAVESEARCH'      : 2058 , # NewWaveSearchables RMI
      'BMC_MESSAGING'      : 2059 , # BMC Messaging Service
      'TELENIUMDAEMON'     : 2060 , # Telenium Daemon IF
      'NETMOUNT'           : 2061 , # NetMount
      'ICG_SWP'            : 2062 , # ICG SWP Port
      'ICG_BRIDGE'         : 2063 , # ICG Bridge Port
      'ICG_IPRELAY'        : 2064 , # ICG IP Relay Port
      'DLSRPN'             : 2065 , # Data Link Switch Read Port Number
      'AURA'               : 2066 , # AVM USB Remote Architecture
      'DLSWPN'             : 2067 , # Data Link Switch Write Port Number
      'AVAUTHSRVPRTCL'     : 2068 , # Avocent AuthSrv Protocol
      'EVENT_PORT'         : 2069 , # HTTP Event Port
      'AH_ESP_ENCAP'       : 2070 , # AH and ESP Encapsulated in UDP packet
      'ACP_PORT'           : 2071 , # Axon Control Protocol
      'MSYNC'              : 2072 , # GlobeCast mSync
      'GXS_DATA_PORT'      : 2073 , # DataReel Database Socket
      'VRTL_VMF_SA'        : 2074 , # Vertel VMF SA
      'NEWLIXENGINE'       : 2075 , # Newlix ServerWare Engine
      'NEWLIXCONFIG'       : 2076 , # Newlix JSPConfig
      'TSRMAGT'            : 2077 , # Old Tivoli Storage Manager
      'TPCSRVR'            : 2078 , # IBM Total Productivity Center Server
      'IDWARE_ROUTER'      : 2079 , # IDWARE Router Port
      'AUTODESK_NLM'       : 2080 , # Autodesk NLM (FLEXlm)
      'KME_TRAP_PORT'      : 2081 , # KME PRINTER TRAP PORT
      'INFOWAVE'           : 2082 , # Infowave Mobility Server
      'RADSEC'             : 2083 , # Secure Radius Service
      'SUNCLUSTERGEO'      : 2084 , # SunCluster Geographic
      'ADA_CIP'            : 2085 , # ADA Control
      'GNUNET'             : 2086 , # GNUnet
      'ELI'                : 2087 , # ELI _ Event Logging Integration
      'IP_BLF'             : 2088 , # IP Busy Lamp Field
      'SEP'                : 2089 , # Security Encapsulation Protocol _ SEP
      'LRP'                : 2090 , # Load Report Protocol
      'PRP'                : 2091 , # PRP
      'DESCENT3'           : 2092 , # Descent 3
      'NBX_CC'             : 2093 , # NBX CC
      'NBX_AU'             : 2094 , # NBX AU
      'NBX_SER'            : 2095 , # NBX SER
      'NBX_DIR'            : 2096 , # NBX DIR
      'JETFORMPREVIEW'     : 2097 , # Jet Form Preview
      'DIALOG_PORT'        : 2098 , # Dialog Port
      'H2250_ANNEX_G'      : 2099 , # H.225.0 Annex G Signalling
      'AMIGANETFS'         : 2100 , # Amiga Network Filesystem
      'RTCM_SC104'         : 2101 , # rtcm_sc104
      'ZEPHYR_SRV'         : 2102 , # Zephyr server
      'ZEPHYR_CLT'         : 2103 , # Zephyr serv_hm connection
      'ZEPHYR_HM'          : 2104 , # Zephyr hostmanager
      'MINIPAY'            : 2105 , # MiniPay
      'MZAP'               : 2106 , # MZAP
      'BINTEC_ADMIN'       : 2107 , # BinTec Admin
      'COMCAM'             : 2108 , # Comcam
      'ERGOLIGHT'          : 2109 , # Ergolight
      'UMSP'               : 2110 , # UMSP
      'DSATP'              : 2111 , # OPNET Dynamic Sampling Agent Transaction Protocol
      'IDONIX_METANET'     : 2112 , # Idonix MetaNet
      'HSL_STORM'          : 2113 , # HSL StoRM
      'NEWHEIGHTS'         : 2114 , # NEWHEIGHTS
      'KDM'                : 2115 , # Key Distribution Manager
      'CCOWCMR'            : 2116 , # CCOWCMR
      'MENTACLIENT'        : 2117 , # MENTACLIENT
      'MENTASERVER'        : 2118 , # MENTASERVER
      'GSIGATEKEEPER'      : 2119 , # GSIGATEKEEPER
      'QENCP'              : 2120 , # Quick Eagle Networks CP
      'SCIENTIA_SSDB'      : 2121 , # SCIENTIA_SSDB
      'CAUPC_REMOTE'       : 2122 , # CauPC Remote Control
      'GTP_CONTROL'        : 2123 , # GTP_Control Plane (3GPP)
      'ELATELINK'          : 2124 , # ELATELINK
      'LOCKSTEP'           : 2125 , # LOCKSTEP
      'PKTCABLE_COPS'      : 2126 , # PktCable_COPS
      'INDEX_PC_WB'        : 2127 , # INDEX_PC_WB
      'NET_STEWARD'        : 2128 , # Net Steward Control
      'CS_LIVE'            : 2129 , # cs_live.com
      'XDS'                : 2130 , # XDS
      'AVANTAGEB2B'        : 2131 , # Avantageb2b
      'SOLERA_EPMAP'       : 2132 , # SoleraTec End Point Map
      'ZYMED_ZPP'          : 2133 , # ZYMED_ZPP
      'AVENUE'             : 2134 , # AVENUE
      'GRIS'               : 2135 , # Grid Resource Information Server
      'APPWORXSRV'         : 2136 , # APPWORXSRV
      'CONNECT'            : 2137 , # CONNECT
      'UNBIND_CLUSTER'     : 2138 , # UNBIND_CLUSTER
      'IAS_AUTH'           : 2139 , # IAS_AUTH
      'IAS_REG'            : 2140 , # IAS_REG
      'IAS_ADMIND'         : 2141 , # IAS_ADMIND
      'TDMOIP'             : 2142 , # TDM OVER IP
      'LV_JC'              : 2143 , # Live Vault Job Control
      'LV_FFX'             : 2144 , # Live Vault Fast Object Transfer
      'LV_PICI'            : 2145 , # Live Vault Remote Diagnostic Console Support
      'LV_NOT'             : 2146 , # Live Vault Admin Event Notification
      'LV_AUTH'            : 2147 , # Live Vault Authentication
      'VERITAS_UCL'        : 2148 , # VERITAS UNIVERSAL COMMUNICATION LAYER
      'ACPTSYS'            : 2149 , # ACPTSYS
      'DYNAMIC3D'          : 2150 , # DYNAMIC3D
      'DOCENT'             : 2151 , # DOCENT
      'GTP_USER'           : 2152 , # GTP_User Plane (3GPP)
      'CTLPTC'             : 2153 , # Control Protocol
      'STDPTC'             : 2154 , # Standard Protocol
      'BRDPTC'             : 2155 , # Bridge Protocol
      'TRP'                : 2156 , # Talari Reliable Protocol
      'XNDS'               : 2157 , # Xerox Network Document Scan Protocol
      'TOUCHNETPLUS'       : 2158 , # TouchNetPlus Service
      'GDBREMOTE'          : 2159 , # GDB Remote Debug Port
      'APC_2160'           : 2160 , # APC 2160
      'APC_2161'           : 2161 , # APC 2161
      'NAVISPHERE'         : 2162 , # Navisphere
      'NAVISPHERE_SEC'     : 2163 , # Navisphere Secure
      'DDNS_V3'            : 2164 , # Dynamic DNS Version 3
      'X_BONE_API'         : 2165 , # X_Bone API
      'IWSERVER'           : 2166 , # iwserver
      'RAW_SERIAL'         : 2167 , # Raw Async Serial Link
      'EASY_SOFT_MUX'      : 2168 , # easy_soft Multiplexer
      'BRAIN'              : 2169 , # Backbone for Academic Information Notification (BRAIN)
      'EYETV'              : 2170 , # EyeTV Server Port
      'MSFW_STORAGE'       : 2171 , # MS Firewall Storage
      'MSFW_S_STORAGE'     : 2172 , # MS Firewall SecureStorage
      'MSFW_REPLICA'       : 2173 , # MS Firewall Replication
      'MSFW_ARRAY'         : 2174 , # MS Firewall Intra Array
      'AIRSYNC'            : 2175 , # Microsoft Desktop AirSync Protocol
      'RAPI'               : 2176 , # Microsoft ActiveSync Remote API
      'QWAVE'              : 2177 , # qWAVE Bandwidth Estimate
      'BITSPEER'           : 2178 , # Peer Services for BITS
      'VMRDP'              : 2179 , # Microsoft RDP for virtual machines
      'MC_GT_SRV'          : 2180 , # Millicent Vendor Gateway Server
      'EFORWARD'           : 2181 , # eforward
      'CGN_STAT'           : 2182 , # CGN status
      'CGN_CONFIG'         : 2183 , # Code Green configuration
      'NVD'                : 2184 , # NVD User
      'ONBASE_DDS'         : 2185 , # OnBase Distributed Disk Services
      'GTAUA'              : 2186 , # Guy_Tek Automated Update Applications
      'SSMC'               : 2187 , # Sepehr System Management Control
      'RADWARE_RPM'        : 2188 , # Radware Resource Pool Manager
      'RADWARE_RPM_S'      : 2189 , # Secure Radware Resource Pool Manager
      'TIVOCONNECT'        : 2190 , # TiVoConnect Beacon
      'TVBUS'              : 2191 , # TvBus Messaging
      'ASDIS'              : 2192 , # ASDIS software management
      'DRWCS'              : 2193 , # Dr.Web Enterprise Management Service
      'MNP_EXCHANGE'       : 2197 , # MNP data exchange
      'ONEHOME_REMOTE'     : 2198 , # OneHome Remote Access
      'ONEHOME_HELP'       : 2199 , # OneHome Service Port
      'ICI'                : 2200 , # ICI
      'ATS'                : 2201 , # Advanced Training System Program
      'IMTC_MAP'           : 2202 , # Int. Multimedia Teleconferencing Cosortium
      'B2_RUNTIME'         : 2203 , # b2 Runtime Protocol
      'B2_LICENSE'         : 2204 , # b2 License Server
      'JPS'                : 2205 , # Java Presentation Server
      'HPOCBUS'            : 2206 , # HP OpenCall bus
      'HPSSD'              : 2207 , # HP Status and Services
      'HPIOD'              : 2208 , # HP I_O Backend
      'RIMF_PS'            : 2209 , # HP RIM for Files Portal Service
      'NOAAPORT'           : 2210 , # NOAAPORT Broadcast Network
      'EMWIN'              : 2211 , # EMWIN
      'LEECOPOSSERVER'     : 2212 , # LeeCO POS Server Service
      'KALI'               : 2213 , # Kali
      'RPI'                : 2214 , # RDQ Protocol Interface
      'IPCORE'             : 2215 , # IPCore.co.za GPRS
      'VTU_COMMS'          : 2216 , # VTU data service
      'GOTODEVICE'         : 2217 , # GoToDevice Device Management
      'BOUNZZA'            : 2218 , # Bounzza IRC Proxy
      'NETIQ_NCAP'         : 2219 , # NetIQ NCAP Protocol
      'NETIQ'              : 2220 , # NetIQ End2End
      'ROCKWELL_CSP1'      : 2221 , # Rockwell CSP1
      'ETHERNET_IP_1'      : 2222 , # EtherNet_IP I_OIANA assigned this well_formed service name as a replacement for "EtherNet_IP_1".
      'ETHERNET_IP_1'      : 2222 , # EtherNet_IP I_O
      'ROCKWELL_CSP2'      : 2223 , # Rockwell CSP2
      'EFI_MG'             : 2224 , # Easy Flexible Internet_Multiplayer Games
      'RCIP_ITU'           : 2225 , # Resource Connection Initiation Protocol
      'DI_DRM'             : 2226 , # Digital Instinct DRM
      'DI_MSG'             : 2227 , # DI Messaging Service
      'EHOME_MS'           : 2228 , # eHome Message Server
      'DATALENS'           : 2229 , # DataLens Service
      'QUEUEADM'           : 2230 , # MetaSoft Job Queue Administration Service
      'WIMAXASNCP'         : 2231 , # WiMAX ASN Control Plane Protocol
      'IVS_VIDEO'          : 2232 , # IVS Video default
      'INFOCRYPT'          : 2233 , # INFOCRYPT
      'DIRECTPLAY'         : 2234 , # DirectPlay
      'SERCOMM_WLINK'      : 2235 , # Sercomm_WLink
      'NANI'               : 2236 , # Nani
      'OPTECH_PORT1_LM'    : 2237 , # Optech Port1 License Manager
      'AVIVA_SNA'          : 2238 , # AVIVA SNA SERVER
      'IMAGEQUERY'         : 2239 , # Image Query
      'RECIPE'             : 2240 , # RECIPe
      'IVSD'               : 2241 , # IVS Daemon
      'FOLIOCORP'          : 2242 , # Folio Remote Server
      'MAGICOM'            : 2243 , # Magicom Protocol
      'NMSSERVER'          : 2244 , # NMS Server
      'HAO'                : 2245 , # HaO
      'PC_MTA_ADDRMAP'     : 2246 , # PacketCable MTA Addr Map
      'ANTIDOTEMGRSVR'     : 2247 , # Antidote Deployment Manager Service
      'UMS'                : 2248 , # User Management Service
      'RFMP'               : 2249 , # RISO File Manager Protocol
      'REMOTE_COLLAB'      : 2250 , # remote_collab
      'DIF_PORT'           : 2251 , # Distributed Framework Port
      'NJENET_SSL'         : 2252 , # NJENET using SSL
      'DTV_CHAN_REQ'       : 2253 , # DTV Channel Request
      'SEISPOC'            : 2254 , # Seismic P.O.C. Port
      'VRTP'               : 2255 , # VRTP _ ViRtue Transfer Protocol
      'PCC_MFP'            : 2256 , # PCC MFP
      'SIMPLE_TX_RX'       : 2257 , # simple text_file transfer
      'RCTS'               : 2258 , # Rotorcraft Communications Test System
      'APC_2260'           : 2260 , # APC 2260
      'COMOTIONMASTER'     : 2261 , # CoMotion Master Server
      'COMOTIONBACK'       : 2262 , # CoMotion Backup Server
      'ECWCFG'             : 2263 , # ECweb Configuration Service
      'APX500API_1'        : 2264 , # Audio Precision Apx500 API Port 1
      'APX500API_2'        : 2265 , # Audio Precision Apx500 API Port 2
      'MFSERVER'           : 2266 , # M_Files Server
      'ONTOBROKER'         : 2267 , # OntoBroker
      'AMT'                : 2268 , # AMT
      'MIKEY'              : 2269 , # MIKEY
      'STARSCHOOL'         : 2270 , # starSchool
      'MMCALS'             : 2271 , # Secure Meeting Maker Scheduling
      'MMCAL'              : 2272 , # Meeting Maker Scheduling
      'MYSQL_IM'           : 2273 , # MySQL Instance Manager
      'PCTTUNNELL'         : 2274 , # PCTTunneller
      'IBRIDGE_DATA'       : 2275 , # iBridge Conferencing
      'IBRIDGE_MGMT'       : 2276 , # iBridge Management
      'BLUECTRLPROXY'      : 2277 , # Bt device control proxy
      'S3DB'               : 2278 , # Simple Stacked Sequences Database
      'XMQUERY'            : 2279 , # xmquery
      'LNVPOLLER'          : 2280 , # LNVPOLLER
      'LNVCONSOLE'         : 2281 , # LNVCONSOLE
      'LNVALARM'           : 2282 , # LNVALARM
      'LNVSTATUS'          : 2283 , # LNVSTATUS
      'LNVMAPS'            : 2284 , # LNVMAPS
      'LNVMAILMON'         : 2285 , # LNVMAILMON
      'NAS_METERING'       : 2286 , # NAS_Metering
      'DNA'                : 2287 , # DNA
      'NETML'              : 2288 , # NETML
      'DICT_LOOKUP'        : 2289 , # Lookup dict server
      'SONUS_LOGGING'      : 2290 , # Sonus Logging Services
      'EAPSP'              : 2291 , # EPSON Advanced Printer Share Protocol
      'MIB_STREAMING'      : 2292 , # Sonus Element Management Services
      'NPDBGMNGR'          : 2293 , # Network Platform Debug Manager
      'KONSHUS_LM'         : 2294 , # Konshus License Manager (FLEX)
      'ADVANT_LM'          : 2295 , # Advant License Manager
      'THETA_LM'           : 2296 , # Theta License Manager (Rainbow)
      'D2K_DATAMOVER1'     : 2297 , # D2K DataMover 1
      'D2K_DATAMOVER2'     : 2298 , # D2K DataMover 2
      'PC_TELECOMMUTE'     : 2299 , # PC Telecommute
      'CVMMON'             : 2300 , # CVMMON
      'CPQ_WBEM'           : 2301 , # Compaq HTTP
      'BINDERYSUPPORT'     : 2302 , # Bindery Support
      'PROXY_GATEWAY'      : 2303 , # Proxy Gateway
      'ATTACHMATE_UTS'     : 2304 , # Attachmate UTS
      'MT_SCALESERVER'     : 2305 , # MT ScaleServer
      'TAPPI_BOXNET'       : 2306 , # TAPPI BoxNet
      'PEHELP'             : 2307 , # pehelp
      'SDHELP'             : 2308 , # sdhelp
      'SDSERVER'           : 2309 , # SD Server
      'SDCLIENT'           : 2310 , # SD Client
      'MESSAGESERVICE'     : 2311 , # Message Service
      'WANSCALER'          : 2312 , # WANScaler Communication Service
      'IAPP'               : 2313 , # IAPP (Inter Access Point Protocol)
      'CR_WEBSYSTEMS'      : 2314 , # CR WebSystems
      'PRECISE_SFT'        : 2315 , # Precise Sft.
      'SENT_LM'            : 2316 , # SENT License Manager
      'ATTACHMATE_G32'     : 2317 , # Attachmate G32
      'CADENCECONTROL'     : 2318 , # Cadence Control
      'INFOLIBRIA'         : 2319 , # InfoLibria
      'SIEBEL_NS'          : 2320 , # Siebel NS
      'RDLAP'              : 2321 , # RDLAP
      'OFSD'               : 2322 , # ofsd
      '3D_NFSD'            : 2323 , # 3d_nfsd
      'COSMOCALL'          : 2324 , # Cosmocall
      'ANSYSLI'            : 2325 , # ANSYS Licensing Interconnect
      'IDCP'               : 2326 , # IDCP
      'XINGCSM'            : 2327 , # xingcsm
      'NETRIX_SFTM'        : 2328 , # Netrix SFTM
      'NVD'                : 2329 , # NVD
      'TSCCHAT'            : 2330 , # TSCCHAT
      'AGENTVIEW'          : 2331 , # AGENTVIEW
      'RCC_HOST'           : 2332 , # RCC Host
      'SNAPP'              : 2333 , # SNAPP
      'ACE_CLIENT'         : 2334 , # ACE Client Auth
      'ACE_PROXY'          : 2335 , # ACE Proxy
      'APPLEUGCONTROL'     : 2336 , # Apple UG Control
      'IDEESRV'            : 2337 , # ideesrv
      'NORTON_LAMBERT'     : 2338 , # Norton Lambert
      '3COM_WEBVIEW'       : 2339 , # 3Com WebView
      'WRS_REGISTRY'       : 2340 , # WRS RegistryIANA assigned this well_formed service name as a replacement for "wrs_registry".
      'WRS_REGISTRY'       : 2340 , # WRS Registry
      'XIOSTATUS'          : 2341 , # XIO Status
      'MANAGE_EXEC'        : 2342 , # Seagate Manage Exec
      'NATI_LOGOS'         : 2343 , # nati logos
      'FCMSYS'             : 2344 , # fcmsys
      'DBM'                : 2345 , # dbm
      'REDSTORM_JOIN'      : 2346 , # Game Connection PortIANA assigned this well_formed service name as a replacement for "redstorm_join".
      'REDSTORM_JOIN'      : 2346 , # Game Connection Port This entry is an alias to "redstorm_join".This entry is now historic, not usable for use with manycommon service discovery mechanisms.
      'REDSTORM_FIND'      : 2347 , # Game Announcement and LocationIANA assigned this well_formed service name as a replacement for "redstorm_find".
      'REDSTORM_FIND'      : 2347 , # Game Announcement and Location This entry is an alias to "redstorm_find".This entry is now historic, not usable for use with manycommon service discovery mechanisms.
      'REDSTORM_INFO'      : 2348 , # Information to query for game statusIANA assigned this well_formed service name as a replacement for "redstorm_info".
      'REDSTORM_INFO'      : 2348 , # Information to query for game status This entry is an alias to "redstorm_info".This entry is now historic, not usable for use with manycommon service discovery mechanisms.
      'REDSTORM_DIAG'      : 2349 , # Diagnostics PortIANA assigned this well_formed service name as a replacement for "redstorm_diag".
      'REDSTORM_DIAG'      : 2349 , # Diagnostics Port
      'PSBSERVER'          : 2350 , # Pharos Booking Server
      'PSRSERVER'          : 2351 , # psrserver
      'PSLSERVER'          : 2352 , # pslserver
      'PSPSERVER'          : 2353 , # pspserver
      'PSPRSERVER'         : 2354 , # psprserver
      'PSDBSERVER'         : 2355 , # psdbserver
      'GXTELMD'            : 2356 , # GXT License Managemant
      'UNIHUB_SERVER'      : 2357 , # UniHub Server
      'FUTRIX'             : 2358 , # Futrix
      'FLUKESERVER'        : 2359 , # FlukeServer
      'NEXSTORINDLTD'      : 2360 , # NexstorIndLtd
      'TL1'                : 2361 , # TL1
      'DIGIMAN'            : 2362 , # digiman
      'MEDIACNTRLNFSD'     : 2363 , # Media Central NFSD
      'OI_2000'            : 2364 , # OI_2000
      'DBREF'              : 2365 , # dbref
      'QIP_LOGIN'          : 2366 , # qip_login
      'SERVICE_CTRL'       : 2367 , # Service Control
      'OPENTABLE'          : 2368 , # OpenTable
      'L3_HBMON'           : 2370 , # L3_HBMon
      'HP_RDA'             : 2371 , # HP Remote Device Access
      'LANMESSENGER'       : 2372 , # LanMessenger
      'REMOGRAPHLM'        : 2373 , # Remograph License Manager
      'HYDRA'              : 2374 , # Hydra RPC
      'DOCKER'             : 2375 , # Docker REST API (plain text)
      'DOCKER_S'           : 2376 , # Docker REST API (ssl)
      'ETCD_CLIENT'        : 2379 , # etcd client communication
      'ETCD_SERVER'        : 2380 , # etcd server to server communication
      'COMPAQ_HTTPS'       : 2381 , # Compaq HTTPS
      'MS_OLAP3'           : 2382 , # Microsoft OLAP
      'MS_OLAP4'           : 2383 , # Microsoft OLAP
      'SD_REQUEST'         : 2384 , # SD_REQUEST
      'SD_DATA'            : 2385 , # SD_DATA
      'VIRTUALTAPE'        : 2386 , # Virtual Tape
      'VSAMREDIRECTOR'     : 2387 , # VSAM Redirector
      'MYNAHAUTOSTART'     : 2388 , # MYNAH AutoStart
      'OVSESSIONMGR'       : 2389 , # OpenView Session Mgr
      'RSMTP'              : 2390 , # RSMTP
      '3COM_NET_MGMT'      : 2391 , # 3COM Net Management
      'TACTICALAUTH'       : 2392 , # Tactical Auth
      'MS_OLAP1'           : 2393 , # MS OLAP 1
      'MS_OLAP2'           : 2394 , # MS OLAP 2
      'LAN900_REMOTE'      : 2395 , # LAN900 RemoteIANA assigned this well_formed service name as a replacement for "lan900_remote".
      'LAN900_REMOTE'      : 2395 , # LAN900 Remote
      'WUSAGE'             : 2396 , # Wusage
      'NCL'                : 2397 , # NCL
      'ORBITER'            : 2398 , # Orbiter
      'FMPRO_FDAL'         : 2399 , # FileMaker, Inc. _ Data Access Layer
      'OPEQUUS_SERVER'     : 2400 , # OpEquus Server
      'CVSPSERVER'         : 2401 , # cvspserver
      'TASKMASTER2000'     : 2402 , # TaskMaster 2000 Server
      'TASKMASTER2000'     : 2403 , # TaskMaster 2000 Web
      'IEC_104'            : 2404 , # IEC 60870_5_104 process control over IP
      'TRC_NETPOLL'        : 2405 , # TRC Netpoll
      'JEDISERVER'         : 2406 , # JediServer
      'ORION'              : 2407 , # Orion
      'RAILGUN_WEBACCL'    : 2408 , # CloudFlare Railgun Web Acceleration Protocol
      'SNS_PROTOCOL'       : 2409 , # SNS Protocol
      'VRTS_REGISTRY'      : 2410 , # VRTS Registry
      'NETWAVE_AP_MGMT'    : 2411 , # Netwave AP Management
      'CDN'                : 2412 , # CDN
      'ORION_RMI_REG'      : 2413 , # orion_rmi_reg
      'BEEYOND'            : 2414 , # Beeyond
      'CODIMA_RTP'         : 2415 , # Codima Remote Transaction Protocol
      'RMTSERVER'          : 2416 , # RMT Server
      'COMPOSIT_SERVER'    : 2417 , # Composit Server
      'CAS'                : 2418 , # cas
      'ATTACHMATE_S2S'     : 2419 , # Attachmate S2S
      'DSLREMOTE_MGMT'     : 2420 , # DSL Remote Management
      'G_TALK'             : 2421 , # G_Talk
      'CRMSBITS'           : 2422 , # CRMSBITS
      'RNRP'               : 2423 , # RNRP
      'KOFAX_SVR'          : 2424 , # KOFAX_SVR
      'FJITSUAPPMGR'       : 2425 , # Fujitsu App Manager
      'MGCP_GATEWAY'       : 2427 , # Media Gateway Control Protocol Gateway
      'OTT'                : 2428 , # One Way Trip Time
      'FT_ROLE'            : 2429 , # FT_ROLE
      'VENUS'              : 2430 , # venus
      'VENUS_SE'           : 2431 , # venus_se
      'CODASRV'            : 2432 , # codasrv
      'CODASRV_SE'         : 2433 , # codasrv_se
      'PXC_EPMAP'          : 2434 , # pxc_epmap
      'OPTILOGIC'          : 2435 , # OptiLogic
      'TOPX'               : 2436 , # TOP_X
      'UNICONTROL'         : 2437 , # UniControl
      'MSP'                : 2438 , # MSP
      'SYBASEDBSYNCH'      : 2439 , # SybaseDBSynch
      'SPEARWAY'           : 2440 , # Spearway Lockers
      'PVSW_INET'          : 2441 , # Pervasive I_net Data Server
      'NETANGEL'           : 2442 , # Netangel
      'POWERCLIENTCSF'     : 2443 , # PowerClient Central Storage Facility
      'BTPP2SECTRANS'      : 2444 , # BT PP2 Sectrans
      'DTN1'               : 2445 , # DTN1
      'BUES_SERVICE'       : 2446 , # bues_serviceIANA assigned this well_formed service name as a replacement for "bues_service".
      'BUES_SERVICE'       : 2446 , # bues_service
      'OVWDB'              : 2447 , # OpenView NNM daemon
      'HPPPSSVR'           : 2448 , # hpppsvr
      'RATL'               : 2449 , # RATL
      'NETADMIN'           : 2450 , # netadmin
      'NETCHAT'            : 2451 , # netchat
      'SNIFFERCLIENT'      : 2452 , # SnifferClient
      'MADGE_LTD'          : 2453 , # madge ltd
      'INDX_DDS'           : 2454 , # IndX_DDS
      'WAGO_IO_SYSTEM'     : 2455 , # WAGO_IO_SYSTEM
      'ALTAV_REMMGT'       : 2456 , # altav_remmgt
      'RAPIDO_IP'          : 2457 , # Rapido_IP
      'GRIFFIN'            : 2458 , # griffin
      'COMMUNITY'          : 2459 , # Community
      'MS_THEATER'         : 2460 , # ms_theater
      'QADMIFOPER'         : 2461 , # qadmifoper
      'QADMIFEVENT'        : 2462 , # qadmifevent
      'LSI_RAID_MGMT'      : 2463 , # LSI RAID Management
      'DIRECPC_SI'         : 2464 , # DirecPC SI
      'LBM'                : 2465 , # Load Balance Management
      'LBF'                : 2466 , # Load Balance Forwarding
      'HIGH_CRITERIA'      : 2467 , # High Criteria
      'QIP_MSGD'           : 2468 , # qip_msgd
      'MTI_TCS_COMM'       : 2469 , # MTI_TCS_COMM
      'TASKMAN_PORT'       : 2470 , # taskman port
      'SEAODBC'            : 2471 , # SeaODBC
      'C3'                 : 2472 , # C3
      'AKER_CDP'           : 2473 , # Aker_cdp
      'VITALANALYSIS'      : 2474 , # Vital Analysis
      'ACE_SERVER'         : 2475 , # ACE Server
      'ACE_SVR_PROP'       : 2476 , # ACE Server Propagation
      'SSM_CVS'            : 2477 , # SecurSight Certificate Valifation Service
      'SSM_CSSPS'          : 2478 , # SecurSight Authentication Server (SSL)
      'SSM_ELS'            : 2479 , # SecurSight Event Logging Server (SSL)
      'POWEREXCHANGE'      : 2480 , # Informatica PowerExchange Listener
      'GIOP'               : 2481 , # Oracle GIOP
      'GIOP_SSL'           : 2482 , # Oracle GIOP SSL
      'TTC'                : 2483 , # Oracle TTC
      'TTC_SSL'            : 2484 , # Oracle TTC SSL
      'NETOBJECTS1'        : 2485 , # Net Objects1
      'NETOBJECTS2'        : 2486 , # Net Objects2
      'PNS'                : 2487 , # Policy Notice Service
      'MOY_CORP'           : 2488 , # Moy Corporation
      'TSILB'              : 2489 , # TSILB
      'QIP_QDHCP'          : 2490 , # qip_qdhcp
      'CONCLAVE_CPP'       : 2491 , # Conclave CPP
      'GROOVE'             : 2492 , # GROOVE
      'TALARIAN_MQS'       : 2493 , # Talarian MQS
      'BMC_AR'             : 2494 , # BMC AR
      'FAST_REM_SERV'      : 2495 , # Fast Remote Services
      'DIRGIS'             : 2496 , # DIRGIS
      'QUADDB'             : 2497 , # Quad DB
      'ODN_CASTRAQ'        : 2498 , # ODN_CasTraq
      'UNICONTROL'         : 2499 , # UniControl
      'RTSSERV'            : 2500 , # Resource Tracking system server
      'RTSCLIENT'          : 2501 , # Resource Tracking system client
      'KENTROX_PROT'       : 2502 , # Kentrox Protocol
      'NMS_DPNSS'          : 2503 , # NMS_DPNSS
      'WLBS'               : 2504 , # WLBS
      'PPCONTROL'          : 2505 , # PowerPlay Control
      'JBROKER'            : 2506 , # jbroker
      'SPOCK'              : 2507 , # spock
      'JDATASTORE'         : 2508 , # JDataStore
      'FJMPSS'             : 2509 , # fjmpss
      'FJAPPMGRBULK'       : 2510 , # fjappmgrbulk
      'METASTORM'          : 2511 , # Metastorm
      'CITRIXIMA'          : 2512 , # Citrix IMA
      'CITRIXADMIN'        : 2513 , # Citrix ADMIN
      'FACSYS_NTP'         : 2514 , # Facsys NTP
      'FACSYS_ROUTER'      : 2515 , # Facsys Router
      'MAINCONTROL'        : 2516 , # Main Control
      'CALL_SIG_TRANS'     : 2517 , # H.323 Annex E Call Control Signalling Transport
      'WILLY'              : 2518 , # Willy
      'GLOBMSGSVC'         : 2519 , # globmsgsvc
      'PVSW'               : 2520 , # Pervasive Listener
      'ADAPTECMGR'         : 2521 , # Adaptec Manager
      'WINDB'              : 2522 , # WinDb
      'QKE_LLC_V3'         : 2523 , # Qke LLC V.3
      'OPTIWAVE_LM'        : 2524 , # Optiwave License Management
      'MS_V_WORLDS'        : 2525 , # MS V_Worlds
      'EMA_SENT_LM'        : 2526 , # EMA License Manager
      'IQSERVER'           : 2527 , # IQ Server
      'NCR_CCL'            : 2528 , # NCR CCLIANA assigned this well_formed service name as a replacement for "ncr_ccl".
      'NCR_CCL'            : 2528 , # NCR CCL
      'UTSFTP'             : 2529 , # UTS FTP
      'VRCOMMERCE'         : 2530 , # VR Commerce
      'ITO_E_GUI'          : 2531 , # ITO_E GUI
      'OVTOPMD'            : 2532 , # OVTOPMD
      'SNIFFERSERVER'      : 2533 , # SnifferServer
      'COMBOX_WEB_ACC'     : 2534 , # Combox Web Access
      'MADCAP'             : 2535 , # MADCAP
      'BTPP2AUDCTR1'       : 2536 , # btpp2audctr1
      'UPGRADE'            : 2537 , # Upgrade Protocol
      'VNWK_PRAPI'         : 2538 , # vnwk_prapi
      'VSIADMIN'           : 2539 , # VSI Admin
      'LONWORKS'           : 2540 , # LonWorks
      'LONWORKS2'          : 2541 , # LonWorks2
      'UDRAWGRAPH'         : 2542 , # uDraw(Graph)
      'REFTEK'             : 2543 , # REFTEK
      'NOVELL_ZEN'         : 2544 , # Management Daemon Refresh
      'SIS_EMT'            : 2545 , # sis_emt
      'VYTALVAULTBRTP'     : 2546 , # vytalvaultbrtp
      'VYTALVAULTVSMP'     : 2547 , # vytalvaultvsmp
      'VYTALVAULTPIPE'     : 2548 , # vytalvaultpipe
      'IPASS'              : 2549 , # IPASS
      'ADS'                : 2550 , # ADS
      'ISG_UDA_SERVER'     : 2551 , # ISG UDA Server
      'CALL_LOGGING'       : 2552 , # Call Logging
      'EFIDININGPORT'      : 2553 , # efidiningport
      'VCNET_LINK_V10'     : 2554 , # VCnet_Link v10
      'COMPAQ_WCP'         : 2555 , # Compaq WCP
      'NICETEC_NMSVC'      : 2556 , # nicetec_nmsvc
      'NICETEC_MGMT'       : 2557 , # nicetec_mgmt
      'PCLEMULTIMEDIA'     : 2558 , # PCLE Multi Media
      'LSTP'               : 2559 , # LSTP
      'LABRAT'             : 2560 , # labrat
      'MOSAIXCC'           : 2561 , # MosaixCC
      'DELIBO'             : 2562 , # Delibo
      'CTI_REDWOOD'        : 2563 , # CTI Redwood
      'HP_3000_TELNET'     : 2564 , # HP 3000 NS_VT block mode telnet
      'COORD_SVR'          : 2565 , # Coordinator Server
      'PCS_PCW'            : 2566 , # pcs_pcw
      'CLP'                : 2567 , # Cisco Line Protocol
      'SPAMTRAP'           : 2568 , # SPAM TRAP
      'SONUSCALLSIG'       : 2569 , # Sonus Call Signal
      'HS_PORT'            : 2570 , # HS Port
      'CECSVC'             : 2571 , # CECSVC
      'IBP'                : 2572 , # IBP
      'TRUSTESTABLISH'     : 2573 , # Trust Establish
      'BLOCKADE_BPSP'      : 2574 , # Blockade BPSP
      'HL7'                : 2575 , # HL7
      'TCLPRODEBUGGER'     : 2576 , # TCL Pro Debugger
      'SCIPTICSLSRVR'      : 2577 , # Scriptics Lsrvr
      'RVS_ISDN_DCP'       : 2578 , # RVS ISDN DCP
      'MPFONCL'            : 2579 , # mpfoncl
      'TRIBUTARY'          : 2580 , # Tributary
      'ARGIS_TE'           : 2581 , # ARGIS TE
      'ARGIS_DS'           : 2582 , # ARGIS DS
      'MON'                : 2583 , # MON
      'CYASERV'            : 2584 , # cyaserv
      'NETX_SERVER'        : 2585 , # NETX Server
      'NETX_AGENT'         : 2586 , # NETX Agent
      'MASC'               : 2587 , # MASC
      'PRIVILEGE'          : 2588 , # Privilege
      'QUARTUS_TCL'        : 2589 , # quartus tcl
      'IDOTDIST'           : 2590 , # idotdist
      'MAYTAGSHUFFLE'      : 2591 , # Maytag Shuffle
      'NETREK'             : 2592 , # netrek
      'MNS_MAIL'           : 2593 , # MNS Mail Notice Service
      'DTS'                : 2594 , # Data Base Server
      'WORLDFUSION1'       : 2595 , # World Fusion 1
      'WORLDFUSION2'       : 2596 , # World Fusion 2
      'HOMESTEADGLORY'     : 2597 , # Homestead Glory
      'CITRIXIMACLIENT'    : 2598 , # Citrix MA Client
      'SNAPD'              : 2599 , # Snap Discovery
      'HPSTGMGR'           : 2600 , # HPSTGMGR
      'DISCP_CLIENT'       : 2601 , # discp client
      'DISCP_SERVER'       : 2602 , # discp server
      'SERVICEMETER'       : 2603 , # Service Meter
      'NSC_CCS'            : 2604 , # NSC CCS
      'NSC_POSA'           : 2605 , # NSC POSA
      'NETMON'             : 2606 , # Dell Netmon
      'CONNECTION'         : 2607 , # Dell Connection
      'WAG_SERVICE'        : 2608 , # Wag Service
      'SYSTEM_MONITOR'     : 2609 , # System Monitor
      'VERSA_TEK'          : 2610 , # VersaTek
      'LIONHEAD'           : 2611 , # LIONHEAD
      'QPASA_AGENT'        : 2612 , # Qpasa Agent
      'SMNTUBOOTSTRAP'     : 2613 , # SMNTUBootstrap
      'NEVEROFFLINE'       : 2614 , # Never Offline
      'FIREPOWER'          : 2615 , # firepower
      'APPSWITCH_EMP'      : 2616 , # appswitch_emp
      'CMADMIN'            : 2617 , # Clinical Context Managers
      'PRIORITY_E_COM'     : 2618 , # Priority E_Com
      'BRUCE'              : 2619 , # bruce
      'LPSRECOMMENDER'     : 2620 , # LPSRecommender
      'MILES_APART'        : 2621 , # Miles Apart Jukebox Server
      'METRICADBC'         : 2622 , # MetricaDBC
      'LMDP'               : 2623 , # LMDP
      'ARIA'               : 2624 , # Aria
      'BLWNKL_PORT'        : 2625 , # Blwnkl Port
      'GBJD816'            : 2626 , # gbjd816
      'MOSHEBEERI'         : 2627 , # Moshe Beeri
      'DICT'               : 2628 , # DICT
      'SITARASERVER'       : 2629 , # Sitara Server
      'SITARAMGMT'         : 2630 , # Sitara Management
      'SITARADIR'          : 2631 , # Sitara Dir
      'IRDG_POST'          : 2632 , # IRdg Post
      'INTERINTELLI'       : 2633 , # InterIntelli
      'PK_ELECTRONICS'     : 2634 , # PK Electronics
      'BACKBURNER'         : 2635 , # Back Burner
      'SOLVE'              : 2636 , # Solve
      'IMDOCSVC'           : 2637 , # Import Document Service
      'SYBASEANYWHERE'     : 2638 , # Sybase Anywhere
      'AMINET'             : 2639 , # AMInet
      'SAI_SENTLM'         : 2640 , # Sabbagh Associates Licence ManagerIANA assigned this well_formed service name as a replacement for "sai_sentlm".
      'SAI_SENTLM'         : 2640 , # Sabbagh Associates Licence Manager
      'HDL_SRV'            : 2641 , # HDL Server
      'TRAGIC'             : 2642 , # Tragic
      'GTE_SAMP'           : 2643 , # GTE_SAMP
      'TRAVSOFT_IPX_T'     : 2644 , # Travsoft IPX Tunnel
      'NOVELL_IPX_CMD'     : 2645 , # Novell IPX CMD
      'AND_LM'             : 2646 , # AND License Manager
      'SYNCSERVER'         : 2647 , # SyncServer
      'UPSNOTIFYPROT'      : 2648 , # Upsnotifyprot
      'VPSIPPORT'          : 2649 , # VPSIPPORT
      'ERISTWOGUNS'        : 2650 , # eristwoguns
      'EBINSITE'           : 2651 , # EBInSite
      'INTERPATHPANEL'     : 2652 , # InterPathPanel
      'SONUS'              : 2653 , # Sonus
      'COREL_VNCADMIN'     : 2654 , # Corel VNC AdminIANA assigned this well_formed service name as a replacement for "corel_vncadmin".
      'COREL_VNCADMIN'     : 2654 , # Corel VNC Admin
      'UNGLUE'             : 2655 , # UNIX Nt Glue
      'KANA'               : 2656 , # Kana
      'SNS_DISPATCHER'     : 2657 , # SNS Dispatcher
      'SNS_ADMIN'          : 2658 , # SNS Admin
      'SNS_QUERY'          : 2659 , # SNS Query
      'GCMONITOR'          : 2660 , # GC Monitor
      'OLHOST'             : 2661 , # OLHOST
      'BINTEC_CAPI'        : 2662 , # BinTec_CAPI Unauthorized Use Known on port 2662
      'BINTEC_TAPI'        : 2663 , # BinTec_TAPI
      'PATROL_MQ_GM'       : 2664 , # Patrol for MQ GM
      'PATROL_MQ_NM'       : 2665 , # Patrol for MQ NM
      'EXTENSIS'           : 2666 , # extensis
      'ALARM_CLOCK_S'      : 2667 , # Alarm Clock Server
      'ALARM_CLOCK_C'      : 2668 , # Alarm Clock Client
      'TOAD'               : 2669 , # TOAD
      'TVE_ANNOUNCE'       : 2670 , # TVE Announce
      'NEWLIXREG'          : 2671 , # newlixreg
      'NHSERVER'           : 2672 , # nhserver
      'FIRSTCALL42'        : 2673 , # First Call 42
      'EWNN'               : 2674 , # ewnn
      'TTC_ETAP'           : 2675 , # TTC ETAP
      'SIMSLINK'           : 2676 , # SIMSLink
      'GADGETGATE1WAY'     : 2677 , # Gadget Gate 1 Way
      'GADGETGATE2WAY'     : 2678 , # Gadget Gate 2 Way
      'SYNCSERVERSSL'      : 2679 , # Sync Server SSL
      'PXC_SAPXOM'         : 2680 , # pxc_sapxom
      'MPNJSOMB'           : 2681 , # mpnjsomb
      'NCDLOADBALANCE'     : 2683 , # NCDLoadBalance
      'MPNJSOSV'           : 2684 , # mpnjsosv
      'MPNJSOCL'           : 2685 , # mpnjsocl
      'MPNJSOMG'           : 2686 , # mpnjsomg
      'PQ_LIC_MGMT'        : 2687 , # pq_lic_mgmt
      'MD_CG_HTTP'         : 2688 , # md_cf_http
      'FASTLYNX'           : 2689 , # FastLynx
      'HP_NNM_DATA'        : 2690 , # HP NNM Embedded Database
      'ITINTERNET'         : 2691 , # ITInternet ISM Server
      'ADMINS_LMS'         : 2692 , # Admins LMS
      'PWRSEVENT'          : 2694 , # pwrsevent
      'VSPREAD'            : 2695 , # VSPREAD
      'UNIFYADMIN'         : 2696 , # Unify Admin
      'OCE_SNMP_TRAP'      : 2697 , # Oce SNMP Trap Port
      'MCK_IVPIP'          : 2698 , # MCK_IVPIP
      'CSOFT_PLUSCLNT'     : 2699 , # Csoft Plus Client
      'TQDATA'             : 2700 , # tqdata
      'SMS_RCINFO'         : 2701 , # SMS RCINFO
      'SMS_XFER'           : 2702 , # SMS XFER
      'SMS_CHAT'           : 2703 , # SMS CHAT
      'SMS_REMCTRL'        : 2704 , # SMS REMCTRL
      'SDS_ADMIN'          : 2705 , # SDS Admin
      'NCDMIRRORING'       : 2706 , # NCD Mirroring
      'EMCSYMAPIPORT'      : 2707 , # EMCSYMAPIPORT
      'BANYAN_NET'         : 2708 , # Banyan_Net
      'SUPERMON'           : 2709 , # Supermon
      'SSO_SERVICE'        : 2710 , # SSO Service
      'SSO_CONTROL'        : 2711 , # SSO Control
      'AOCP'               : 2712 , # Axapta Object Communication Protocol
      'RAVENTBS'           : 2713 , # Raven Trinity Broker Service
      'RAVENTDM'           : 2714 , # Raven Trinity Data Mover
      'HPSTGMGR2'          : 2715 , # HPSTGMGR2
      'INOVA_IP_DISCO'     : 2716 , # Inova IP Disco
      'PN_REQUESTER'       : 2717 , # PN REQUESTER
      'PN_REQUESTER2'      : 2718 , # PN REQUESTER 2
      'SCAN_CHANGE'        : 2719 , # Scan & Change
      'WKARS'              : 2720 , # wkars
      'SMART_DIAGNOSE'     : 2721 , # Smart Diagnose
      'PROACTIVESRVR'      : 2722 , # Proactive Server
      'WATCHDOG_NT'        : 2723 , # WatchDog NT Protocol
      'QOTPS'              : 2724 , # qotps
      'MSOLAP_PTP2'        : 2725 , # MSOLAP PTP2
      'TAMS'               : 2726 , # TAMS
      'MGCP_CALLAGENT'     : 2727 , # Media Gateway Control Protocol Call Agent
      'SQDR'               : 2728 , # SQDR
      'TCIM_CONTROL'       : 2729 , # TCIM Control
      'NEC_RAIDPLUS'       : 2730 , # NEC RaidPlus
      'FYRE_MESSANGER'     : 2731 , # Fyre Messanger
      'G5M'                : 2732 , # G5M
      'SIGNET_CTF'         : 2733 , # Signet CTF
      'CCS_SOFTWARE'       : 2734 , # CCS Software
      'NETIQ_MC'           : 2735 , # NetIQ Monitor Console
      'RADWIZ_NMS_SRV'     : 2736 , # RADWIZ NMS SRV
      'SRP_FEEDBACK'       : 2737 , # SRP Feedback
      'NDL_TCP_OIS_GW'     : 2738 , # NDL TCP_OSI Gateway
      'TN_TIMING'          : 2739 , # TN Timing
      'ALARM'              : 2740 , # Alarm
      'TSB'                : 2741 , # TSB
      'TSB2'               : 2742 , # TSB2
      'MURX'               : 2743 , # murx
      'HONYAKU'            : 2744 , # honyaku
      'URBISNET'           : 2745 , # URBISNET
      'CPUDPENCAP'         : 2746 , # CPUDPENCAP
      'FJIPPOL_SWRLY'      : 2747 , # 
      'FJIPPOL_POLSVR'     : 2748 , # 
      'FJIPPOL_CNSL'       : 2749 , # 
      'FJIPPOL_PORT1'      : 2750 , # 
      'FJIPPOL_PORT2'      : 2751 , # 
      'RSISYSACCESS'       : 2752 , # RSISYS ACCESS
      'DE_SPOT'            : 2753 , # de_spot
      'APOLLO_CC'          : 2754 , # APOLLO CC
      'EXPRESSPAY'         : 2755 , # Express Pay
      'SIMPLEMENT_TIE'     : 2756 , # simplement_tie
      'CNRP'               : 2757 , # CNRP
      'APOLLO_STATUS'      : 2758 , # APOLLO Status
      'APOLLO_GMS'         : 2759 , # APOLLO GMS
      'SABAMS'             : 2760 , # Saba MS
      'DICOM_ISCL'         : 2761 , # DICOM ISCL
      'DICOM_TLS'          : 2762 , # DICOM TLS
      'DESKTOP_DNA'        : 2763 , # Desktop DNA
      'DATA_INSURANCE'     : 2764 , # Data Insurance
      'QIP_AUDUP'          : 2765 , # qip_audup
      'COMPAQ_SCP'         : 2766 , # Compaq SCP
      'UADTC'              : 2767 , # UADTC
      'UACS'               : 2768 , # UACS
      'EXCE'               : 2769 , # eXcE
      'VERONICA'           : 2770 , # Veronica
      'VERGENCECM'         : 2771 , # Vergence CM
      'AURIS'              : 2772 , # auris
      'RBAKCUP1'           : 2773 , # RBackup Remote Backup
      'RBAKCUP2'           : 2774 , # RBackup Remote Backup
      'SMPP'               : 2775 , # SMPP
      'RIDGEWAY1'          : 2776 , # Ridgeway Systems & Software
      'RIDGEWAY2'          : 2777 , # Ridgeway Systems & Software
      'GWEN_SONYA'         : 2778 , # Gwen_Sonya
      'LBC_SYNC'           : 2779 , # LBC Sync
      'LBC_CONTROL'        : 2780 , # LBC Control
      'WHOSELLS'           : 2781 , # whosells
      'EVERYDAYRC'         : 2782 , # everydayrc
      'AISES'              : 2783 , # AISES
      'WWW_DEV'            : 2784 , # world wide web _ development
      'AIC_NP'             : 2785 , # aic_np
      'AIC_ONCRPC'         : 2786 , # aic_oncrpc _ Destiny MCD database
      'PICCOLO'            : 2787 , # piccolo _ Cornerstone Software
      'FRYESERV'           : 2788 , # NetWare Loadable Module _ Seagate Software
      'MEDIA_AGENT'        : 2789 , # Media Agent
      'PLGPROXY'           : 2790 , # PLG Proxy
      'MTPORT_REGIST'      : 2791 , # MT Port Registrator
      'F5_GLOBALSITE'      : 2792 , # f5_globalsite
      'INITLSMSAD'         : 2793 , # initlsmsad
      'LIVESTATS'          : 2795 , # LiveStats
      'AC_TECH'            : 2796 , # ac_tech
      'ESP_ENCAP'          : 2797 , # esp_encap
      'TMESIS_UPSHOT'      : 2798 , # TMESIS_UPShot
      'ICON_DISCOVER'      : 2799 , # ICON Discover
      'ACC_RAID'           : 2800 , # ACC RAID
      'IGCP'               : 2801 , # IGCP
      'VERITAS_TCP1'       : 2802 , # Veritas TCP1
      'BTPRJCTRL'          : 2803 , # btprjctrl
      'DVR_ESM'            : 2804 , # March Networks Digital Video Recorders and Enterprise Service Manager products
      'WTA_WSP_S'          : 2805 , # WTA WSP_S
      'CSPUNI'             : 2806 , # cspuni
      'CSPMULTI'           : 2807 , # cspmulti
      'J_LAN_P'            : 2808 , # J_LAN_P
      'CORBALOC'           : 2809 , # CORBA LOC
      'NETSTEWARD'         : 2810 , # Active Net Steward
      'GSIFTP'             : 2811 , # GSI FTP
      'ATMTCP'             : 2812 , # atmtcp
      'LLM_PASS'           : 2813 , # llm_pass
      'LLM_CSV'            : 2814 , # llm_csv
      'LBC_MEASURE'        : 2815 , # LBC Measurement
      'LBC_WATCHDOG'       : 2816 , # LBC Watchdog
      'NMSIGPORT'          : 2817 , # NMSig Port
      'RMLNK'              : 2818 , # rmlnk
      'FC_FAULTNOTIFY'     : 2819 , # FC Fault Notification
      'UNIVISION'          : 2820 , # UniVision
      'VRTS_AT_PORT'       : 2821 , # VERITAS Authentication Service
      'KA0WUC'             : 2822 , # ka0wuc
      'CQG_NETLAN'         : 2823 , # CQG Net_LAN
      'CQG_NETLAN_1'       : 2824 , # CQG Net_LAN 1
      'SLC_SYSTEMLOG'      : 2826 , # slc systemlog
      'SLC_CTRLRLOOPS'     : 2827 , # slc ctrlrloops
      'ITM_LM'             : 2828 , # ITM License Manager
      'SILKP1'             : 2829 , # silkp1
      'SILKP2'             : 2830 , # silkp2
      'SILKP3'             : 2831 , # silkp3
      'SILKP4'             : 2832 , # silkp4
      'GLISHD'             : 2833 , # glishd
      'EVTP'               : 2834 , # EVTP
      'EVTP_DATA'          : 2835 , # EVTP_DATA
      'CATALYST'           : 2836 , # catalyst
      'REPLIWEB'           : 2837 , # Repliweb
      'STARBOT'            : 2838 , # Starbot
      'NMSIGPORT'          : 2839 , # NMSigPort
      'L3_EXPRT'           : 2840 , # l3_exprt
      'L3_RANGER'          : 2841 , # l3_ranger
      'L3_HAWK'            : 2842 , # l3_hawk
      'PDNET'              : 2843 , # PDnet
      'BPCP_POLL'          : 2844 , # BPCP POLL
      'BPCP_TRAP'          : 2845 , # BPCP TRAP
      'AIMPP_HELLO'        : 2846 , # AIMPP Hello
      'AIMPP_PORT_REQ'     : 2847 , # AIMPP Port Req
      'AMT_BLC_PORT'       : 2848 , # AMT_BLC_PORT
      'FXP'                : 2849 , # FXP
      'METACONSOLE'        : 2850 , # MetaConsole
      'WEBEMSHTTP'         : 2851 , # webemshttp
      'BEARS_01'           : 2852 , # bears_01
      'ISPIPES'            : 2853 , # ISPipes
      'INFOMOVER'          : 2854 , # InfoMover
      'MSRP'               : 2855 , # MSRP over TCP 2014_04_09
      'CESDINV'            : 2856 , # cesdinv
      'SIMCTLP'            : 2857 , # SimCtIP
      'ECNP'               : 2858 , # ECNP
      'ACTIVEMEMORY'       : 2859 , # Active Memory
      'DIALPAD_VOICE1'     : 2860 , # Dialpad Voice 1
      'DIALPAD_VOICE2'     : 2861 , # Dialpad Voice 2
      'TTG_PROTOCOL'       : 2862 , # TTG Protocol
      'SONARDATA'          : 2863 , # Sonar Data
      'ASTROMED_MAIN'      : 2864 , # main 5001 cmd
      'PIT_VPN'            : 2865 , # pit_vpn
      'IWLISTENER'         : 2866 , # iwlistener
      'ESPS_PORTAL'        : 2867 , # esps_portal
      'NPEP_MESSAGING'     : 2868 , # Norman Proprietaqry Events Protocol
      'ICSLAP'             : 2869 , # ICSLAP
      'DAISHI'             : 2870 , # daishi
      'MSI_SELECTPLAY'     : 2871 , # MSI Select Play
      'RADIX'              : 2872 , # RADIX
      'DXMESSAGEBASE1'     : 2874 , # DX Message Base Transport Protocol
      'DXMESSAGEBASE2'     : 2875 , # DX Message Base Transport Protocol
      'SPS_TUNNEL'         : 2876 , # SPS Tunnel
      'BLUELANCE'          : 2877 , # BLUELANCE
      'AAP'                : 2878 , # AAP
      'UCENTRIC_DS'        : 2879 , # ucentric_ds
      'SYNAPSE'            : 2880 , # Synapse Transport
      'NDSP'               : 2881 , # NDSP
      'NDTP'               : 2882 , # NDTP
      'NDNP'               : 2883 , # NDNP
      'FLASHMSG'           : 2884 , # Flash Msg
      'TOPFLOW'            : 2885 , # TopFlow
      'RESPONSELOGIC'      : 2886 , # RESPONSELOGIC
      'AIRONETDDP'         : 2887 , # aironet
      'SPCSDLOBBY'         : 2888 , # SPCSDLOBBY
      'RSOM'               : 2889 , # RSOM
      'CSPCLMULTI'         : 2890 , # CSPCLMULTI
      'CINEGRFX_ELMD'      : 2891 , # CINEGRFX_ELMD License Manager
      'SNIFFERDATA'        : 2892 , # SNIFFERDATA
      'VSECONNECTOR'       : 2893 , # VSECONNECTOR
      'ABACUS_REMOTE'      : 2894 , # ABACUS_REMOTE
      'NATUSLINK'          : 2895 , # NATUS LINK
      'ECOVISIONG6_1'      : 2896 , # ECOVISIONG6_1
      'CITRIX_RTMP'        : 2897 , # Citrix RTMP
      'APPLIANCE_CFG'      : 2898 , # APPLIANCE_CFG
      'POWERGEMPLUS'       : 2899 , # POWERGEMPLUS
      'QUICKSUITE'         : 2900 , # QUICKSUITE
      'ALLSTORCNS'         : 2901 , # ALLSTORCNS
      'NETASPI'            : 2902 , # NET ASPI
      'SUITCASE'           : 2903 , # SUITCASE
      'M2UA'               : 2904 , # M2UA
      'M3UA'               : 2905 , # M3UA
      'CALLER9'            : 2906 , # CALLER9
      'WEBMETHODS_B2B'     : 2907 , # WEBMETHODS B2B
      'MAO'                : 2908 , # mao
      'FUNK_DIALOUT'       : 2909 , # Funk Dialout
      'TDACCESS'           : 2910 , # TDAccess
      'BLOCKADE'           : 2911 , # Blockade
      'EPICON'             : 2912 , # Epicon
      'BOOSTERWARE'        : 2913 , # Booster Ware
      'GAMELOBBY'          : 2914 , # Game Lobby
      'TKSOCKET'           : 2915 , # TK Socket
      'ELVIN_SERVER'       : 2916 , # Elvin ServerIANA assigned this well_formed service name as a replacement for "elvin_server".
      'ELVIN_SERVER'       : 2916 , # Elvin Server This entry is an alias to "elvin_server".This entry is now historic, not usable for use with manycommon service discovery mechanisms.
      'ELVIN_CLIENT'       : 2917 , # Elvin ClientIANA assigned this well_formed service name as a replacement for "elvin_client".
      'ELVIN_CLIENT'       : 2917 , # Elvin Client
      'KASTENCHASEPAD'     : 2918 , # Kasten Chase Pad
      'ROBOER'             : 2919 , # roboER
      'ROBOEDA'            : 2920 , # roboEDA
      'CESDCDMAN'          : 2921 , # CESD Contents Delivery Management
      'CESDCDTRN'          : 2922 , # CESD Contents Delivery Data Transfer
      'WTA_WSP_WTP_S'      : 2923 , # WTA_WSP_WTP_S
      'PRECISE_VIP'        : 2924 , # PRECISE_VIP
      'MOBILE_FILE_DL'     : 2926 , # MOBILE_FILE_DL
      'UNIMOBILECTRL'      : 2927 , # UNIMOBILECTRL
      'REDSTONE_CPSS'      : 2928 , # REDSTONE_CPSS
      'AMX_WEBADMIN'       : 2929 , # AMX_WEBADMIN
      'AMX_WEBLINX'        : 2930 , # AMX_WEBLINX
      'CIRCLE_X'           : 2931 , # Circle_X
      'INCP'               : 2932 , # INCP
      '4_TIEROPMGW'        : 2933 , # 4_TIER OPM GW
      '4_TIEROPMCLI'       : 2934 , # 4_TIER OPM CLI
      'QTP'                : 2935 , # QTP
      'OTPATCH'            : 2936 , # OTPatch
      'PNACONSULT_LM'      : 2937 , # PNACONSULT_LM
      'SM_PAS_1'           : 2938 , # SM_PAS_1
      'SM_PAS_2'           : 2939 , # SM_PAS_2
      'SM_PAS_3'           : 2940 , # SM_PAS_3
      'SM_PAS_4'           : 2941 , # SM_PAS_4
      'SM_PAS_5'           : 2942 , # SM_PAS_5
      'TTNREPOSITORY'      : 2943 , # TTNRepository
      'MEGACO_H248'        : 2944 , # Megaco H_248
      'H248_BINARY'        : 2945 , # H248 Binary
      'FJSVMPOR'           : 2946 , # FJSVmpor
      'GPSD'               : 2947 , # GPS Daemon request_response protocol
      'WAP_PUSH'           : 2948 , # WAP PUSH
      'WAP_PUSHSECURE'     : 2949 , # WAP PUSH SECURE
      'ESIP'               : 2950 , # ESIP
      'OTTP'               : 2951 , # OTTP
      'MPFWSAS'            : 2952 , # MPFWSAS
      'OVALARMSRV'         : 2953 , # OVALARMSRV
      'OVALARMSRV_CMD'     : 2954 , # OVALARMSRV_CMD
      'CSNOTIFY'           : 2955 , # CSNOTIFY
      'OVRIMOSDBMAN'       : 2956 , # OVRIMOSDBMAN
      'JMACT5'             : 2957 , # JAMCT5
      'JMACT6'             : 2958 , # JAMCT6
      'RMOPAGT'            : 2959 , # RMOPAGT
      'DFOXSERVER'         : 2960 , # DFOXSERVER
      'BOLDSOFT_LM'        : 2961 , # BOLDSOFT_LM
      'IPH_POLICY_CLI'     : 2962 , # IPH_POLICY_CLI
      'IPH_POLICY_ADM'     : 2963 , # IPH_POLICY_ADM
      'BULLANT_SRAP'       : 2964 , # BULLANT SRAP
      'BULLANT_RAP'        : 2965 , # BULLANT RAP
      'IDP_INFOTRIEVE'     : 2966 , # IDP_INFOTRIEVE
      'SSC_AGENT'          : 2967 , # SSC_AGENT
      'ENPP'               : 2968 , # ENPP
      'ESSP'               : 2969 , # ESSP
      'INDEX_NET'          : 2970 , # INDEX_NET
      'NETCLIP'            : 2971 , # NetClip clipboard daemon
      'PMSM_WEBRCTL'       : 2972 , # PMSM Webrctl
      'SVNETWORKS'         : 2973 , # SV Networks
      'SIGNAL'             : 2974 , # Signal
      'FJMPCM'             : 2975 , # Fujitsu Configuration Management Service
      'CNS_SRV_PORT'       : 2976 , # CNS Server Port
      'TTC_ETAP_NS'        : 2977 , # TTCs Enterprise Test Access Protocol _ NS
      'TTC_ETAP_DS'        : 2978 , # TTCs Enterprise Test Access Protocol _ DS
      'H263_VIDEO'         : 2979 , # H.263 Video Streaming
      'WIMD'               : 2980 , # Instant Messaging Service
      'MYLXAMPORT'         : 2981 , # MYLXAMPORT
      'IWB_WHITEBOARD'     : 2982 , # IWB_WHITEBOARD
      'NETPLAN'            : 2983 , # NETPLAN
      'HPIDSADMIN'         : 2984 , # HPIDSADMIN
      'HPIDSAGENT'         : 2985 , # HPIDSAGENT
      'STONEFALLS'         : 2986 , # STONEFALLS
      'IDENTIFY'           : 2987 , # identify
      'HIPPAD'             : 2988 , # HIPPA Reporting Protocol
      'ZARKOV'             : 2989 , # ZARKOV Intelligent Agent Communication
      'BOSCAP'             : 2990 , # BOSCAP
      'WKSTN_MON'          : 2991 , # WKSTN_MON
      'AVENYO'             : 2992 , # Avenyo Server
      'VERITAS_VIS1'       : 2993 , # VERITAS VIS1
      'VERITAS_VIS2'       : 2994 , # VERITAS VIS2
      'IDRS'               : 2995 , # IDRS
      'VSIXML'             : 2996 , # vsixml
      'REBOL'              : 2997 , # REBOL
      'REALSECURE'         : 2998 , # Real Secure
      'REMOTEWARE_UN'      : 2999 , # RemoteWare Unassigned
      'HBCI'               : 3000 , # HBCI
      'REMOTEWARE_CL'      : 3000 , # RemoteWare Client
      'ORIGO_NATIVE'       : 3001 , # OrigoDB Server Native Interface
      'EXLM_AGENT'         : 3002 , # EXLM Agent
      'REMOTEWARE_SRV'     : 3002 , # RemoteWare Server
      'CGMS'               : 3003 , # CGMS
      'CSOFTRAGENT'        : 3004 , # Csoft Agent
      'GENIUSLM'           : 3005 , # Genius License Manager
      'II_ADMIN'           : 3006 , # Instant Internet Admin
      'LOTUSMTAP'          : 3007 , # Lotus Mail Tracking Agent Protocol
      'MIDNIGHT_TECH'      : 3008 , # Midnight Technologies
      'PXC_NTFY'           : 3009 , # PXC_NTFY
      'GW'                 : 3010 , # Telerate Workstation
      'TRUSTED_WEB'        : 3011 , # Trusted Web
      'TWSDSS'             : 3012 , # Trusted Web Client
      'GILATSKYSURFER'     : 3013 , # Gilat Sky Surfer
      'BROKER_SERVICE'     : 3014 , # Broker ServiceIANA assigned this well_formed service name as a replacement for "broker_service".
      'BROKER_SERVICE'     : 3014 , # Broker Service
      'NATI_DSTP'          : 3015 , # NATI DSTP
      'NOTIFY_SRVR'        : 3016 , # Notify ServerIANA assigned this well_formed service name as a replacement for "notify_srvr".
      'NOTIFY_SRVR'        : 3016 , # Notify Server
      'EVENT_LISTENER'     : 3017 , # Event ListenerIANA assigned this well_formed service name as a replacement for "event_listener".
      'EVENT_LISTENER'     : 3017 , # Event Listener
      'SRVC_REGISTRY'      : 3018 , # Service RegistryIANA assigned this well_formed service name as a replacement for "srvc_registry".
      'SRVC_REGISTRY'      : 3018 , # Service Registry
      'RESOURCE_MGR'       : 3019 , # Resource ManagerIANA assigned this well_formed service name as a replacement for "resource_mgr".
      'RESOURCE_MGR'       : 3019 , # Resource Manager
      'CIFS'               : 3020 , # CIFS
      'AGRISERVER'         : 3021 , # AGRI Server
      'CSREGAGENT'         : 3022 , # CSREGAGENT
      'MAGICNOTES'         : 3023 , # magicnotes
      'NDS_SSO'            : 3024 , # NDS_SSOIANA assigned this well_formed service name as a replacement for "nds_sso".
      'NDS_SSO'            : 3024 , # NDS_SSO
      'AREPA_RAFT'         : 3025 , # Arepa Raft
      'AGRI_GATEWAY'       : 3026 , # AGRI Gateway
      'LIEBDEVMGMT_C'      : 3027 , # LiebDevMgmt_CIANA assigned this well_formed service name as a replacement for "LiebDevMgmt_C".
      'LIEBDEVMGMT_C'      : 3027 , # LiebDevMgmt_C This entry is an alias to "LiebDevMgmt_C".This entry is now historic, not usable for use with manycommon service discovery mechanisms.
      'LIEBDEVMGMT_DM'     : 3028 , # LiebDevMgmt_DMIANA assigned this well_formed service name as a replacement for "LiebDevMgmt_DM".
      'LIEBDEVMGMT_DM'     : 3028 , # LiebDevMgmt_DM This entry is an alias to "LiebDevMgmt_DM".This entry is now historic, not usable for use with manycommon service discovery mechanisms.
      'LIEBDEVMGMT_A'      : 3029 , # LiebDevMgmt_AIANA assigned this well_formed service name as a replacement for "LiebDevMgmt_A".
      'LIEBDEVMGMT_A'      : 3029 , # LiebDevMgmt_A
      'AREPA_CAS'          : 3030 , # Arepa Cas
      'EPPC'               : 3031 , # Remote AppleEvents_PPC Toolbox
      'REDWOOD_CHAT'       : 3032 , # Redwood Chat
      'PDB'                : 3033 , # PDB
      'OSMOSIS_AEEA'       : 3034 , # Osmosis _ Helix (R) AEEA Port
      'FJSV_GSSAGT'        : 3035 , # FJSV gssagt
      'HAGEL_DUMP'         : 3036 , # Hagel DUMP
      'HP_SAN_MGMT'        : 3037 , # HP SAN Mgmt
      'SANTAK_UPS'         : 3038 , # Santak UPS
      'COGITATE'           : 3039 , # Cogitate, Inc.
      'TOMATO_SPRINGS'     : 3040 , # Tomato Springs
      'DI_TRACEWARE'       : 3041 , # di_traceware
      'JOURNEE'            : 3042 , # journee
      'BRP'                : 3043 , # Broadcast Routing Protocol
      'EPP'                : 3044 , # EndPoint Protocol
      'RESPONSENET'        : 3045 , # ResponseNet
      'DI_ASE'             : 3046 , # di_ase
      'HLSERVER'           : 3047 , # Fast Security HL Server
      'PCTRADER'           : 3048 , # Sierra Net PC Trader
      'NSWS'               : 3049 , # NSWS
      'GDS_DB'             : 3050 , # gds_dbIANA assigned this well_formed service name as a replacement for "gds_db".
      'GDS_DB'             : 3050 , # gds_db
      'GALAXY_SERVER'      : 3051 , # Galaxy Server
      'APC_3052'           : 3052 , # APC 3052
      'DSOM_SERVER'        : 3053 , # dsom_server
      'AMT_CNF_PROT'       : 3054 , # AMT CNF PROT
      'POLICYSERVER'       : 3055 , # Policy Server
      'CDL_SERVER'         : 3056 , # CDL Server
      'GOAHEAD_FLDUP'      : 3057 , # GoAhead FldUp
      'VIDEOBEANS'         : 3058 , # videobeans
      'QSOFT'              : 3059 , # qsoft
      'INTERSERVER'        : 3060 , # interserver
      'CAUTCPD'            : 3061 , # cautcpd
      'NCACN_IP_TCP'       : 3062 , # ncacn_ip_tcp
      'NCADG_IP_UDP'       : 3063 , # ncadg_ip_udp
      'RPRT'               : 3064 , # Remote Port Redirector
      'SLINTERBASE'        : 3065 , # slinterbase
      'NETATTACHSDMP'      : 3066 , # NETATTACHSDMP
      'FJHPJP'             : 3067 , # FJHPJP
      'LS3BCAST'           : 3068 , # ls3 Broadcast
      'LS3'                : 3069 , # ls3
      'MGXSWITCH'          : 3070 , # MGXSWITCH
      'CSD_MGMT_PORT'      : 3071 , # ContinuStor Manager Port
      'CSD_MONITOR'        : 3072 , # ContinuStor Monitor Port
      'VCRP'               : 3073 , # Very simple chatroom prot
      'XBOX'               : 3074 , # Xbox game port
      'ORBIX_LOCATOR'      : 3075 , # Orbix 2000 Locator
      'ORBIX_CONFIG'       : 3076 , # Orbix 2000 Config
      'ORBIX_LOC_SSL'      : 3077 , # Orbix 2000 Locator SSL
      'ORBIX_CFG_SSL'      : 3078 , # Orbix 2000 Locator SSL
      'LV_FRONTPANEL'      : 3079 , # LV Front Panel
      'STM_PPROC'          : 3080 , # stm_pprocIANA assigned this well_formed service name as a replacement for "stm_pproc".
      'STM_PPROC'          : 3080 , # stm_pproc
      'TL1_LV'             : 3081 , # TL1_LV
      'TL1_RAW'            : 3082 , # TL1_RAW
      'TL1_TELNET'         : 3083 , # TL1_TELNET
      'ITM_MCCS'           : 3084 , # ITM_MCCS
      'PCIHREQ'            : 3085 , # PCIHReq
      'JDL_DBKITCHEN'      : 3086 , # JDL_DBKitchen
      'ASOKI_SMA'          : 3087 , # Asoki SMA
      'XDTP'               : 3088 , # eXtensible Data Transfer Protocol
      'PTK_ALINK'          : 3089 , # ParaTek Agent Linking
      'STSS'               : 3090 , # Senforce Session Services
      '1CI_SMCS'           : 3091 , # 1Ci Server Management
      'RAPIDMQ_CENTER'     : 3093 , # Jiiva RapidMQ Center
      'RAPIDMQ_REG'        : 3094 , # Jiiva RapidMQ Registry
      'PANASAS'            : 3095 , # Panasas rendevous port
      'NDL_APS'            : 3096 , # Active Print Server Port
      'UMM_PORT'           : 3098 , # Universal Message Manager
      'CHMD'               : 3099 , # CHIPSY Machine Daemon
      'OPCON_XPS'          : 3100 , # OpCon_xps
      'HP_PXPIB'           : 3101 , # HP PolicyXpert PIB Server
      'SLSLAVEMON'         : 3102 , # SoftlinK Slave Mon Port
      'AUTOCUESMI'         : 3103 , # Autocue SMI Protocol
      'AUTOCUELOG'         : 3104 , # Autocue Logger Protocol
      'CARDBOX'            : 3105 , # Cardbox
      'CARDBOX_HTTP'       : 3106 , # Cardbox HTTP
      'BUSINESS'           : 3107 , # Business protocol
      'GEOLOCATE'          : 3108 , # Geolocate protocol
      'PERSONNEL'          : 3109 , # Personnel protocol
      'SIM_CONTROL'        : 3110 , # simulator control port
      'WSYNCH'             : 3111 , # Web Synchronous Services
      'KSYSGUARD'          : 3112 , # KDE System Guard
      'CS_AUTH_SVR'        : 3113 , # CS_Authenticate Svr Port
      'CCMAD'              : 3114 , # CCM AutoDiscover
      'MCTET_MASTER'       : 3115 , # MCTET Master
      'MCTET_GATEWAY'      : 3116 , # MCTET Gateway
      'MCTET_JSERV'        : 3117 , # MCTET Jserv
      'PKAGENT'            : 3118 , # PKAgent
      'D2000KERNEL'        : 3119 , # D2000 Kernel Port
      'D2000WEBSERVER'     : 3120 , # D2000 Webserver Port
      'PCMK_REMOTE'        : 3121 , # The pacemaker remote (pcmk_remote) service extends high availability functionality outside of the Linux cluster into remote nodes.
      'VTR_EMULATOR'       : 3122 , # MTI VTR Emulator port
      'EDIX'               : 3123 , # EDI Translation Protocol
      'BEACON_PORT'        : 3124 , # Beacon Port
      'A13_AN'             : 3125 , # A13_AN Interface
      'CTX_BRIDGE'         : 3127 , # CTX Bridge Port
      'NDL_AAS'            : 3128 , # Active API Server Port
      'NETPORT_ID'         : 3129 , # NetPort Discovery Port
      'ICPV2'              : 3130 , # ICPv2
      'NETBOOKMARK'        : 3131 , # Net Book Mark
      'MS_RULE_ENGINE'     : 3132 , # Microsoft Business Rule Engine Update Service
      'PRISM_DEPLOY'       : 3133 , # Prism Deploy User Port
      'ECP'                : 3134 , # Extensible Code Protocol
      'PEERBOOK_PORT'      : 3135 , # PeerBook Port
      'GRUBD'              : 3136 , # Grub Server Port
      'RTNT_1'             : 3137 , # rtnt_1 data packets
      'RTNT_2'             : 3138 , # rtnt_2 data packets
      'INCOGNITORV'        : 3139 , # Incognito Rendez_Vous
      'ARILIAMULTI'        : 3140 , # Arilia Multiplexor
      'VMODEM'             : 3141 , # VMODEM
      'RDC_WH_EOS'         : 3142 , # RDC WH EOS
      'SEAVIEW'            : 3143 , # Sea View
      'TARANTELLA'         : 3144 , # Tarantella
      'CSI_LFAP'           : 3145 , # CSI_LFAP
      'BEARS_02'           : 3146 , # bears_02
      'RFIO'               : 3147 , # RFIO
      'NM_GAME_ADMIN'      : 3148 , # NetMike Game Administrator
      'NM_GAME_SERVER'     : 3149 , # NetMike Game Server
      'NM_ASSES_ADMIN'     : 3150 , # NetMike Assessor Administrator
      'NM_ASSESSOR'        : 3151 , # NetMike Assessor
      'FEITIANROCKEY'      : 3152 , # FeiTian Port
      'S8_CLIENT_PORT'     : 3153 , # S8Cargo Client Port
      'CCMRMI'             : 3154 , # ON RMI Registry
      'JPEGMPEG'           : 3155 , # JpegMpeg Port
      'INDURA'             : 3156 , # Indura Collector
      'E3CONSULTANTS'      : 3157 , # CCC Listener Port
      'STVP'               : 3158 , # SmashTV Protocol
      'NAVEGAWEB_PORT'     : 3159 , # NavegaWeb Tarification
      'TIP_APP_SERVER'     : 3160 , # TIP Application Server
      'DOC1LM'             : 3161 , # DOC1 License Manager
      'SFLM'               : 3162 , # SFLM
      'RES_SAP'            : 3163 , # RES_SAP
      'IMPRS'              : 3164 , # IMPRS
      'NEWGENPAY'          : 3165 , # Newgenpay Engine Service
      'SOSSECOLLECTOR'     : 3166 , # Quest Spotlight Out_Of_Process Collector
      'NOWCONTACT'         : 3167 , # Now Contact Public Server
      'POWERONNUD'         : 3168 , # Now Up_to_Date Public Server
      'SERVERVIEW_AS'      : 3169 , # SERVERVIEW_AS
      'SERVERVIEW_ASN'     : 3170 , # SERVERVIEW_ASN
      'SERVERVIEW_GF'      : 3171 , # SERVERVIEW_GF
      'SERVERVIEW_RM'      : 3172 , # SERVERVIEW_RM
      'SERVERVIEW_ICC'     : 3173 , # SERVERVIEW_ICC
      'ARMI_SERVER'        : 3174 , # ARMI Server
      'T1_E1_OVER_IP'      : 3175 , # T1_E1_Over_IP
      'ARS_MASTER'         : 3176 , # ARS Master
      'PHONEX_PORT'        : 3177 , # Phonex Protocol
      'RADCLIENTPORT'      : 3178 , # Radiance UltraEdge Port
      'H2GF_W_2M'          : 3179 , # H2GF W.2m Handover prot.
      'MC_BRK_SRV'         : 3180 , # Millicent Broker Server
      'BMCPATROLAGENT'     : 3181 , # BMC Patrol Agent
      'BMCPATROLRNVU'      : 3182 , # BMC Patrol Rendezvous
      'COPS_TLS'           : 3183 , # COPS_TLS
      'APOGEEX_PORT'       : 3184 , # ApogeeX Port
      'SMPPPD'             : 3185 , # SuSE Meta PPPD
      'IIW_PORT'           : 3186 , # IIW Monitor User Port
      'ODI_PORT'           : 3187 , # Open Design Listen Port
      'BRCM_COMM_PORT'     : 3188 , # Broadcom Port
      'PCLE_INFEX'         : 3189 , # Pinnacle Sys InfEx Port
      'CSVR_PROXY'         : 3190 , # ConServR Proxy
      'CSVR_SSLPROXY'      : 3191 , # ConServR SSL Proxy
      'FIREMONRCC'         : 3192 , # FireMon Revision Control
      'SPANDATAPORT'       : 3193 , # SpanDataPort
      'MAGBIND'            : 3194 , # Rockstorm MAG protocol
      'NCU_1'              : 3195 , # Network Control Unit
      'NCU_2'              : 3196 , # Network Control Unit
      'EMBRACE_DP_S'       : 3197 , # Embrace Device Protocol Server
      'EMBRACE_DP_C'       : 3198 , # Embrace Device Protocol Client
      'DMOD_WORKSPACE'     : 3199 , # DMOD WorkSpace
      'TICK_PORT'          : 3200 , # Press_sense Tick Port
      'CPQ_TASKSMART'      : 3201 , # CPQ_TaskSmart
      'INTRAINTRA'         : 3202 , # IntraIntra
      'NETWATCHER_MON'     : 3203 , # Network Watcher Monitor
      'NETWATCHER_DB'      : 3204 , # Network Watcher DB Access
      'ISNS'               : 3205 , # iSNS Server Port
      'IRONMAIL'           : 3206 , # IronMail POP Proxy
      'VX_AUTH_PORT'       : 3207 , # Veritas Authentication Port
      'PFU_PRCALLBACK'     : 3208 , # PFU PR Callback
      'NETWKPATHENGINE'    : 3209 , # HP OpenView Network Path Engine Server
      'FLAMENCO_PROXY'     : 3210 , # Flamenco Networks Proxy
      'AVSECUREMGMT'       : 3211 , # Avocent Secure Management
      'SURVEYINST'         : 3212 , # Survey Instrument
      'NEON24X7'           : 3213 , # NEON 24X7 Mission Control
      'JMQ_DAEMON_1'       : 3214 , # JMQ Daemon Port 1
      'JMQ_DAEMON_2'       : 3215 , # JMQ Daemon Port 2
      'FERRARI_FOAM'       : 3216 , # Ferrari electronic FOAM
      'UNITE'              : 3217 , # Unified IP & Telecom Environment
      'SMARTPACKETS'       : 3218 , # EMC SmartPackets
      'WMS_MESSENGER'      : 3219 , # WMS Messenger
      'XNM_SSL'            : 3220 , # XML NM over SSL
      'XNM_CLEAR_TEXT'     : 3221 , # XML NM over TCP
      'GLBP'               : 3222 , # Gateway Load Balancing Pr
      'DIGIVOTE'           : 3223 , # DIGIVOTE (R) Vote_Server
      'AES_DISCOVERY'      : 3224 , # AES Discovery Port
      'FCIP_PORT'          : 3225 , # FCIP
      'ISI_IRP'            : 3226 , # ISI Industry Software IRP
      'DWNMSHTTP'          : 3227 , # DiamondWave NMS Server
      'DWMSGSERVER'        : 3228 , # DiamondWave MSG Server
      'GLOBAL_CD_PORT'     : 3229 , # Global CD Port
      'SFTDST_PORT'        : 3230 , # Software Distributor Port
      'VIDIGO'             : 3231 , # VidiGo communication (previous was: Delta Solutions Direct)
      'MDTP'               : 3232 , # MDT port 2012_02_21
      'WHISKER'            : 3233 , # WhiskerControl main port
      'ALCHEMY'            : 3234 , # Alchemy Server
      'MDAP_PORT'          : 3235 , # MDAP port
      'APPARENET_TS'       : 3236 , # appareNet Test Server
      'APPARENET_TPS'      : 3237 , # appareNet Test Packet Sequencer
      'APPARENET_AS'       : 3238 , # appareNet Analysis Server
      'APPARENET_UI'       : 3239 , # appareNet User Interface
      'TRIOMOTION'         : 3240 , # Trio Motion Control Port
      'SYSORB'             : 3241 , # SysOrb Monitoring Server
      'SDP_ID_PORT'        : 3242 , # Session Description ID
      'TIMELOT'            : 3243 , # Timelot Port
      'ONESAF'             : 3244 , # OneSAF
      'VIEO_FE'            : 3245 , # VIEO Fabric Executive
      'DVT_SYSTEM'         : 3246 , # DVT SYSTEM PORT
      'DVT_DATA'           : 3247 , # DVT DATA LINK
      'PROCOS_LM'          : 3248 , # PROCOS LM
      'SSP'                : 3249 , # State Sync Protocol
      'HICP'               : 3250 , # HMS hicp port
      'SYSSCANNER'         : 3251 , # Sys Scanner
      'DHE'                : 3252 , # DHE port
      'PDA_DATA'           : 3253 , # PDA Data
      'PDA_SYS'            : 3254 , # PDA System
      'SEMAPHORE'          : 3255 , # Semaphore Connection Port
      'CPQRPM_AGENT'       : 3256 , # Compaq RPM Agent Port
      'CPQRPM_SERVER'      : 3257 , # Compaq RPM Server Port
      'IVECON_PORT'        : 3258 , # Ivecon Server Port
      'EPNCDP2'            : 3259 , # Epson Network Common Devi
      'ISCSI_TARGET'       : 3260 , # iSCSI port
      'WINSHADOW'          : 3261 , # winShadow
      'NECP'               : 3262 , # NECP
      'ECOLOR_IMAGER'      : 3263 , # E_Color Enterprise Imager
      'CCMAIL'             : 3264 , # cc:mail_lotus
      'ALTAV_TUNNEL'       : 3265 , # Altav Tunnel
      'NS_CFG_SERVER'      : 3266 , # NS CFG Server
      'IBM_DIAL_OUT'       : 3267 , # IBM Dial Out
      'MSFT_GC'            : 3268 , # Microsoft Global Catalog
      'MSFT_GC_SSL'        : 3269 , # Microsoft Global Catalog with LDAP_SSL
      'VERISMART'          : 3270 , # Verismart
      'CSOFT_PREV'         : 3271 , # CSoft Prev Port
      'USER_MANAGER'       : 3272 , # Fujitsu User Manager
      'SXMP'               : 3273 , # Simple Extensible Multiplexed Protocol
      'ORDINOX_SERVER'     : 3274 , # Ordinox Server
      'SAMD'               : 3275 , # SAMD
      'MAXIM_ASICS'        : 3276 , # Maxim ASICs
      'AWG_PROXY'          : 3277 , # AWG Proxy
      'LKCMSERVER'         : 3278 , # LKCM Server
      'ADMIND'             : 3279 , # admind
      'VS_SERVER'          : 3280 , # VS Server
      'SYSOPT'             : 3281 , # SYSOPT
      'DATUSORB'           : 3282 , # Datusorb
      'APPLERemote Desktop': 3283 , # Net Assistant
      '4TALK'              : 3284 , # 4Talk
      'PLATO'              : 3285 , # Plato
      'E_NET'              : 3286 , # E_Net
      'DIRECTVDATA'        : 3287 , # DIRECTVDATA
      'COPS'               : 3288 , # COPS
      'ENPC'               : 3289 , # ENPC
      'CAPS_LM'            : 3290 , # CAPS LOGISTICS TOOLKIT _ LM
      'SAH_LM'             : 3291 , # S A Holditch & Associates _ LM
      'CART_O_RAMA'        : 3292 , # Cart O Rama
      'FG_FPS'             : 3293 , # fg_fps
      'FG_GIP'             : 3294 , # fg_gip
      'DYNIPLOOKUP'        : 3295 , # Dynamic IP Lookup
      'RIB_SLM'            : 3296 , # Rib License Manager
      'CYTEL_LM'           : 3297 , # Cytel License Manager
      'DESKVIEW'           : 3298 , # DeskView
      'PDRNCS'             : 3299 , # pdrncs
      'MCS_FASTMAIL'       : 3302 , # MCS Fastmail
      'OPSESSION_CLNT'     : 3303 , # OP Session Client
      'OPSESSION_SRVR'     : 3304 , # OP Session Server
      'ODETTE_FTP'         : 3305 , # ODETTE_FTP
      'MYSQL'              : 3306 , # MySQL
      'OPSESSION_PRXY'     : 3307 , # OP Session Proxy
      'TNS_SERVER'         : 3308 , # TNS Server
      'TNS_ADV'            : 3309 , # TNS ADV
      'DYNA_ACCESS'        : 3310 , # Dyna Access
      'MCNS_TEL_RET'       : 3311 , # MCNS Tel Ret
      'APPMAN_SERVER'      : 3312 , # Application Management Server
      'UORB'               : 3313 , # Unify Object Broker
      'UOHOST'             : 3314 , # Unify Object Host
      'CDID'               : 3315 , # CDID
      'AICC_CMI'           : 3316 , # AICC_CMI
      'VSAIPORT'           : 3317 , # VSAI PORT
      'SSRIP'              : 3318 , # Swith to Swith Routing Information Protocol
      'SDT_LMD'            : 3319 , # SDT License Manager
      'OFFICELINK2000'     : 3320 , # Office Link 2000
      'VNSSTR'             : 3321 , # VNSSTR
      'SFTU'               : 3326 , # SFTU
      'BBARS'              : 3327 , # BBARS
      'EGPTLM'             : 3328 , # Eaglepoint License Manager
      'HP_DEVICE_DISC'     : 3329 , # HP Device Disc
      'MCS_CALYPSOICF'     : 3330 , # MCS Calypso ICF
      'MCS_MESSAGING'      : 3331 , # MCS Messaging
      'MCS_MAILSVR'        : 3332 , # MCS Mail Server
      'DEC_NOTES'          : 3333 , # DEC Notes
      'DIRECTV_WEB'        : 3334 , # Direct TV Webcasting
      'DIRECTV_SOFT'       : 3335 , # Direct TV Software Updates
      'DIRECTV_TICK'       : 3336 , # Direct TV Tickers
      'DIRECTV_CATLG'      : 3337 , # Direct TV Data Catalog
      'ANET_B'             : 3338 , # OMF data b
      'ANET_L'             : 3339 , # OMF data l
      'ANET_M'             : 3340 , # OMF data m
      'ANET_H'             : 3341 , # OMF data h
      'WEBTIE'             : 3342 , # WebTIE
      'MS_CLUSTER_NET'     : 3343 , # MS Cluster Net
      'BNT_MANAGER'        : 3344 , # BNT Manager
      'INFLUENCE'          : 3345 , # Influence
      'TRNSPRNTPROXY'      : 3346 , # Trnsprnt Proxy
      'PHOENIX_RPC'        : 3347 , # Phoenix RPC
      'PANGOLIN_LASER'     : 3348 , # Pangolin Laser
      'CHEVINSERVICES'     : 3349 , # Chevin Services
      'FINDVIATV'          : 3350 , # FINDVIATV
      'BTRIEVE'            : 3351 , # Btrieve port
      'SSQL'               : 3352 , # Scalable SQL
      'FATPIPE'            : 3353 , # FATPIPE
      'SUITJD'             : 3354 , # SUITJD
      'ORDINOX_DBASE'      : 3355 , # Ordinox Dbase
      'UPNOTIFYPS'         : 3356 , # UPNOTIFYPS
      'ADTECH_TEST'        : 3357 , # Adtech Test IP
      'MPSYSRMSVR'         : 3358 , # Mp Sys Rmsvr
      'WG_NETFORCE'        : 3359 , # WG NetForce
      'KV_SERVER'          : 3360 , # KV Server
      'KV_AGENT'           : 3361 , # KV Agent
      'DJ_ILM'             : 3362 , # DJ ILM
      'NATI_VI_SERVER'     : 3363 , # NATI Vi Server
      'CREATIVESERVER'     : 3364 , # Creative Server
      'CONTENTSERVER'      : 3365 , # Content Server
      'CREATIVEPARTNR'     : 3366 , # Creative Partner
      'TIP2'               : 3372 , # TIP 2
      'LAVENIR_LM'         : 3373 , # Lavenir License Manager
      'CLUSTER_DISC'       : 3374 , # Cluster Disc
      'VSNM_AGENT'         : 3375 , # VSNM Agent
      'CDBROKER'           : 3376 , # CD Broker
      'COGSYS_LM'          : 3377 , # Cogsys Network License Manager
      'WSICOPY'            : 3378 , # WSICOPY
      'SOCORFS'            : 3379 , # SOCORFS
      'SNS_CHANNELS'       : 3380 , # SNS Channels
      'GENEOUS'            : 3381 , # Geneous
      'FUJITSU_NEAT'       : 3382 , # Fujitsu Network Enhanced Antitheft function
      'ESP_LM'             : 3383 , # Enterprise Software Products License Manager
      'HP_CLIC'            : 3384 , # Cluster Management Services
      'QNXNETMAN'          : 3385 , # qnxnetman
      'GPRS_DATA'          : 3386 , # GPRS Data
      'BACKROOMNET'        : 3387 , # Back Room Net
      'CBSERVER'           : 3388 , # CB Server
      'MS_WBT_SERVER'      : 3389 , # MS WBT Server
      'DSC'                : 3390 , # Distributed Service Coordinator
      'SAVANT'             : 3391 , # SAVANT
      'EFI_LM'             : 3392 , # EFI License Management
      'D2K_TAPESTRY1'      : 3393 , # D2K Tapestry Client to Server
      'D2K_TAPESTRY2'      : 3394 , # D2K Tapestry Server to Server
      'DYNA_LM'            : 3395 , # Dyna License Manager (Elam)
      'PRINTER_AGENT'      : 3396 , # Printer AgentIANA assigned this well_formed service name as a replacement for "printer_agent".
      'PRINTER_AGENT'      : 3396 , # Printer Agent
      'CLOANTO_LM'         : 3397 , # Cloanto License Manager
      'MERCANTILE'         : 3398 , # Mercantile
      'CSMS'               : 3399 , # CSMS
      'CSMS2'              : 3400 , # CSMS2
      'FILECAST'           : 3401 , # filecast
      'FXAENGINE_NET'      : 3402 , # FXa Engine Network Port
      'NOKIA_ANN_CH1'      : 3405 , # Nokia Announcement ch 1
      'NOKIA_ANN_CH2'      : 3406 , # Nokia Announcement ch 2
      'LDAP_ADMIN'         : 3407 , # LDAP admin server port
      'BESAPI'             : 3408 , # BES Api Port
      'NETWORKLENS'        : 3409 , # NetworkLens Event Port
      'NETWORKLENSS'       : 3410 , # NetworkLens SSL Event
      'BIOLINK_AUTH'       : 3411 , # BioLink Authenteon server
      'XMLBLASTER'         : 3412 , # xmlBlaster
      'SVNET'              : 3413 , # SpecView Networking
      'WIP_PORT'           : 3414 , # BroadCloud WIP Port
      'BCINAMESERVICE'     : 3415 , # BCI Name Service
      'COMMANDPORT'        : 3416 , # AirMobile IS Command Port
      'CSVR'               : 3417 , # ConServR file translation
      'RNMAP'              : 3418 , # Remote nmap
      'SOFTAUDIT'          : 3419 , # Isogon SoftAudit
      'IFCP_PORT'          : 3420 , # iFCP User Port
      'BMAP'               : 3421 , # Bull Apprise portmapper
      'RUSB_SYS_PORT'      : 3422 , # Remote USB System Port
      'XTRM'               : 3423 , # xTrade Reliable Messaging
      'XTRMS'              : 3424 , # xTrade over TLS_SSL
      'AGPS_PORT'          : 3425 , # AGPS Access Port
      'ARKIVIO'            : 3426 , # Arkivio Storage Protocol
      'WEBSPHERE_SNMP'     : 3427 , # WebSphere SNMP
      'TWCSS'              : 3428 , # 2Wire CSS
      'GCSP'               : 3429 , # GCSP user port
      'SSDISPATCH'         : 3430 , # Scott Studios Dispatch
      'NDL_ALS'            : 3431 , # Active License Server Port
      'OSDCP'              : 3432 , # Secure Device Protocol
      'OPNET_SMP'          : 3433 , # OPNET Service Management Platform
      'OPENCM'             : 3434 , # OpenCM Server
      'PACOM'              : 3435 , # Pacom Security User Port
      'GC_CONFIG'          : 3436 , # GuardControl Exchange Protocol
      'AUTOCUEDS'          : 3437 , # Autocue Directory Service
      'SPIRAL_ADMIN'       : 3438 , # Spiralcraft Admin
      'HRI_PORT'           : 3439 , # HRI Interface Port
      'ANS_CONSOLE'        : 3440 , # Net Steward Mgmt Console
      'CONNECT_CLIENT'     : 3441 , # OC Connect Client
      'CONNECT_SERVER'     : 3442 , # OC Connect Server
      'OV_NNM_WEBSRV'      : 3443 , # OpenView Network Node Manager WEB Server
      'DENALI_SERVER'      : 3444 , # Denali Server
      'MONP'               : 3445 , # Media Object Network
      '3COMFAXRPC'         : 3446 , # 3Com FAX RPC port
      'DIRECTNET'          : 3447 , # DirectNet IM System
      'DNC_PORT'           : 3448 , # Discovery and Net Config
      'HOTU_CHAT'          : 3449 , # HotU Chat
      'CASTORPROXY'        : 3450 , # CAStorProxy
      'ASAM'               : 3451 , # ASAM Services
      'SABP_SIGNAL'        : 3452 , # SABP_Signalling Protocol
      'PSCUPD'             : 3453 , # PSC Update
      'MIRA'               : 3454 , # Apple Remote Access Protocol
      'PRSVP'              : 3455 , # RSVP Port
      'VAT'                : 3456 , # VAT default data
      'VAT_CONTROL'        : 3457 , # VAT default control
      'D3WINOSFI'          : 3458 , # D3WinOSFI
      'INTEGRAL'           : 3459 , # TIP Integral
      'EDM_MANAGER'        : 3460 , # EDM Manger
      'EDM_STAGER'         : 3461 , # EDM Stager
      'EDM_STD_NOTIFY'     : 3462 , # EDM STD Notify
      'EDM_ADM_NOTIFY'     : 3463 , # EDM ADM Notify
      'EDM_MGR_SYNC'       : 3464 , # EDM MGR Sync
      'EDM_MGR_CNTRL'      : 3465 , # EDM MGR Cntrl
      'WORKFLOW'           : 3466 , # WORKFLOW
      'RCST'               : 3467 , # RCST
      'TTCMREMOTECTRL'     : 3468 , # TTCM Remote Controll
      'PLURIBUS'           : 3469 , # Pluribus
      'JT400'              : 3470 , # jt400
      'JT400_SSL'          : 3471 , # jt400_ssl
      'JAUGSREMOTEC_1'     : 3472 , # JAUGS N_G Remotec 1
      'JAUGSREMOTEC_2'     : 3473 , # JAUGS N_G Remotec 2
      'TTNTSPAUTO'         : 3474 , # TSP Automation
      'GENISAR_PORT'       : 3475 , # Genisar Comm Port
      'NPPMP'              : 3476 , # NVIDIA Mgmt Protocol
      'ECOMM'              : 3477 , # eComm link port
      'STUN'               : 3478 , # Session Traversal Utilities for NAT (STUN) port
      'TURN'               : 3478 , # TURN over TCP
      'STUN_BEHAVIOR'      : 3478 , # STUN Behavior Discovery over TCP
      'TWRPC'              : 3479 , # 2Wire RPC
      'PLETHORA'           : 3480 , # Secure Virtual Workspace
      'CLEANERLIVERC'      : 3481 , # CleanerLive remote ctrl
      'VULTURE'            : 3482 , # Vulture Monitoring System
      'SLIM_DEVICES'       : 3483 , # Slim Devices Protocol
      'GBS_STP'            : 3484 , # GBS SnapTalk Protocol
      'CELATALK'           : 3485 , # CelaTalk
      'IFSF_HB_PORT'       : 3486 , # IFSF Heartbeat Port
      'LTCTCP'             : 3487 , # LISA TCP Transfer Channel
      'FS_RH_SRV'          : 3488 , # FS Remote Host Server
      'DTP_DIA'            : 3489 , # DTP_DIA
      'COLUBRIS'           : 3490 , # Colubris Management Port
      'SWR_PORT'           : 3491 , # SWR Port
      'TVDUMTRAY_PORT'     : 3492 , # TVDUM Tray Port
      'NUT'                : 3493 , # Network UPS Tools
      'IBM3494'            : 3494 , # IBM 3494
      'SECLAYER_TCP'       : 3495 , # securitylayer over tcp
      'SECLAYER_TLS'       : 3496 , # securitylayer over tls
      'IPETHER232PORT'     : 3497 , # ipEther232Port
      'DASHPAS_PORT'       : 3498 , # DASHPAS user port
      'SCCIP_MEDIA'        : 3499 , # SccIP Media
      'RTMP_PORT'          : 3500 , # RTMP Port
      'ISOFT_P2P'          : 3501 , # iSoft_P2P
      'AVINSTALLDISC'      : 3502 , # Avocent Install Discovery
      'LSP_PING'           : 3503 , # MPLS LSP_echo Port
      'IRONSTORM'          : 3504 , # IronStorm game server
      'CCMCOMM'            : 3505 , # CCM communications port
      'APC_3506'           : 3506 , # APC 3506
      'NESH_BROKER'        : 3507 , # Nesh Broker Port
      'INTERACTIONWEB'     : 3508 , # Interaction Web
      'VT_SSL'             : 3509 , # Virtual Token SSL Port
      'XSS_PORT'           : 3510 , # XSS Port
      'WEBMAIL_2'          : 3511 , # WebMail_2
      'AZTEC'              : 3512 , # Aztec Distribution Port
      'ARCPD'              : 3513 , # Adaptec Remote Protocol
      'MUST_P2P'           : 3514 , # MUST Peer to Peer
      'MUST_BACKPLANE'     : 3515 , # MUST Backplane
      'SMARTCARD_PORT'     : 3516 , # Smartcard Port
      '802_11_IAPP'        : 3517 , # IEEE 802.11 WLANs WG IAPP
      'ARTIFACT_MSG'       : 3518 , # Artifact Message Server
      'NVMSGD'             : 3519 , # Netvion Messenger Port
      'GALILEOLOG'         : 3520 , # Netvion Galileo Log Port
      'MC3SS'              : 3521 , # Telequip Labs MC3SS
      'NSSOCKETPORT'       : 3522 , # DO over NSSocketPort
      'ODEUMSERVLINK'      : 3523 , # Odeum Serverlink
      'ECMPORT'            : 3524 , # ECM Server port
      'EISPORT'            : 3525 , # EIS Server port
      'STARQUIZ_PORT'      : 3526 , # starQuiz Port
      'BESERVER_MSG_Q'     : 3527 , # VERITAS Backup Exec Server
      'JBOSS_IIOP'         : 3528 , # JBoss IIOP
      'JBOSS_IIOP_SSL'     : 3529 , # JBoss IIOP_SSL
      'GF'                 : 3530 , # Grid Friendly
      'JOLTID'             : 3531 , # Joltid
      'RAVEN_RMP'          : 3532 , # Raven Remote Management Control
      'RAVEN_RDP'          : 3533 , # Raven Remote Management Data
      'URLD_PORT'          : 3534 , # URL Daemon Port
      'MS_LA'              : 3535 , # MS_LA
      'SNAC'               : 3536 , # SNAC
      'NI_VISA_REMOTE'     : 3537 , # Remote NI_VISA port
      'IBM_DIRADM'         : 3538 , # IBM Directory Server
      'IBM_DIRADM_SSL'     : 3539 , # IBM Directory Server SSL
      'PNRP_PORT'          : 3540 , # PNRP User Port
      'VOISPEED_PORT'      : 3541 , # VoiSpeed Port
      'HACL_MONITOR'       : 3542 , # HA cluster monitor
      'QFTEST_LOOKUP'      : 3543 , # qftest Lookup Port
      'TEREDO'             : 3544 , # Teredo Port
      'CAMAC'              : 3545 , # CAMAC equipment
      'SYMANTEC_SIM'       : 3547 , # Symantec SIM
      'INTERWORLD'         : 3548 , # Interworld
      'TELLUMAT_NMS'       : 3549 , # Tellumat MDR NMS
      'SSMPP'              : 3550 , # Secure SMPP
      'APCUPSD'            : 3551 , # Apcupsd Information Port
      'TASERVER'           : 3552 , # TeamAgenda Server Port
      'RBR_DISCOVERY'      : 3553 , # Red Box Recorder ADP
      'QUESTNOTIFY'        : 3554 , # Quest Notification Server
      'RAZOR'              : 3555 , # Vipul's Razor
      'SKY_TRANSPORT'      : 3556 , # Sky Transport Protocol
      'PERSONALOS_001'     : 3557 , # PersonalOS Comm Port
      'MCP_PORT'           : 3558 , # MCP user port
      'CCTV_PORT'          : 3559 , # CCTV control port
      'INISERVE_PORT'      : 3560 , # INIServe port
      'BMC_ONEKEY'         : 3561 , # BMC_OneKey
      'SDBPROXY'           : 3562 , # SDBProxy
      'WATCOMDEBUG'        : 3563 , # Watcom Debug
      'ESIMPORT'           : 3564 , # Electromed SIM port
      'M2PA'               : 3565 , # M2PA
      'QUEST_DATA_HUB'     : 3566 , # Quest Data Hub
      'ENC_EPS'            : 3567 , # EMIT protocol stack
      'ENC_TUNNEL_SEC'     : 3568 , # EMIT secure tunnel
      'MBG_CTRL'           : 3569 , # Meinberg Control Service
      'MCCWEBSVR_PORT'     : 3570 , # MCC Web Server Port
      'MEGARDSVR_PORT'     : 3571 , # MegaRAID Server Port
      'MEGAREGSVRPORT'     : 3572 , # Registration Server Port
      'TAG_UPS_1'          : 3573 , # Advantage Group UPS Suite
      'DMAF_SERVER'        : 3574 , # DMAF Server
      'CCM_PORT'           : 3575 , # Coalsere CCM Port
      'CMC_PORT'           : 3576 , # Coalsere CMC Port
      'CONFIG_PORT'        : 3577 , # Configuration Port
      'DATA_PORT'          : 3578 , # Data Port
      'TTAT3LB'            : 3579 , # Tarantella Load Balancing
      'NATI_SVRLOC'        : 3580 , # NATI_ServiceLocator
      'KFXACLICENSING'     : 3581 , # Ascent Capture Licensing
      'PRESS'              : 3582 , # PEG PRESS Server
      'CANEX_WATCH'        : 3583 , # CANEX Watch System
      'U_DBAP'             : 3584 , # U_DBase Access Protocol
      'EMPRISE_LLS'        : 3585 , # Emprise License Server
      'EMPRISE_LSC'        : 3586 , # License Server Console
      'P2PGROUP'           : 3587 , # Peer to Peer Grouping
      'SENTINEL'           : 3588 , # Sentinel Server
      'ISOMAIR'            : 3589 , # isomair
      'WV_CSP_SMS'         : 3590 , # WV CSP SMS Binding
      'GTRACK_SERVER'      : 3591 , # LOCANIS G_TRACK Server
      'GTRACK_NE'          : 3592 , # LOCANIS G_TRACK NE Port
      'BPMD'               : 3593 , # BP Model Debugger
      'MEDIASPACE'         : 3594 , # MediaSpace
      'SHAREAPP'           : 3595 , # ShareApp
      'IW_MMOGAME'         : 3596 , # Illusion Wireless MMOG
      'A14'                : 3597 , # A14 (AN_to_SC_MM)
      'A15'                : 3598 , # A15 (AN_to_AN)
      'QUASAR_SERVER'      : 3599 , # Quasar Accounting Server
      'TRAP_DAEMON'        : 3600 , # text relay_answer
      'VISINET_GUI'        : 3601 , # Visinet Gui
      'INFINISWITCHCL'     : 3602 , # InfiniSwitch Mgr Client
      'INT_RCV_CNTRL'      : 3603 , # Integrated Rcvr Control
      'BMC_JMX_PORT'       : 3604 , # BMC JMX Port
      'COMCAM_IO'          : 3605 , # ComCam IO Port
      'SPLITLOCK'          : 3606 , # Splitlock Server
      'PRECISE_I3'         : 3607 , # Precise I3
      'TRENDCHIP_DCP'      : 3608 , # Trendchip control protocol
      'CPDI_PIDAS_CM'      : 3609 , # CPDI PIDAS Connection Mon
      'ECHONET'            : 3610 , # ECHONET
      'SIX_DEGREES'        : 3611 , # Six Degrees Port
      'HP_DATAPROTECT'     : 3612 , # HP Data Protector
      'ALARIS_DISC'        : 3613 , # Alaris Device Discovery
      'SIGMA_PORT'         : 3614 , # Satchwell Sigma
      'START_NETWORK'      : 3615 , # Start Messaging Network
      'CD3O_PROTOCOL'      : 3616 , # cd3o Control Protocol
      'SHARP_SERVER'       : 3617 , # ATI SHARP Logic Engine
      'AAIRNET_1'          : 3618 , # AAIR_Network 1
      'AAIRNET_2'          : 3619 , # AAIR_Network 2
      'EP_PCP'             : 3620 , # EPSON Projector Control Port
      'EP_NSP'             : 3621 , # EPSON Network Screen Port
      'FF_LR_PORT'         : 3622 , # FF LAN Redundancy Port
      'HAIPE_DISCOVER'     : 3623 , # HAIPIS Dynamic Discovery
      'DIST_UPGRADE'       : 3624 , # Distributed Upgrade Port
      'VOLLEY'             : 3625 , # Volley
      'BVCDAEMON_PORT'     : 3626 , # bvControl Daemon
      'JAMSERVERPORT'      : 3627 , # Jam Server Port
      'EPT_MACHINE'        : 3628 , # EPT Machine Interface
      'ESCVPNET'           : 3629 , # ESC_VP.net
      'CS_REMOTE_DB'       : 3630 , # C&S Remote Database Port
      'CS_SERVICES'        : 3631 , # C&S Web Services Port
      'DISTCC'             : 3632 , # distributed compiler
      'WACP'               : 3633 , # Wyrnix AIS port
      'HLIBMGR'            : 3634 , # hNTSP Library Manager
      'SDO'                : 3635 , # Simple Distributed Objects
      'SERVISTAITSM'       : 3636 , # SerVistaITSM
      'SCSERVP'            : 3637 , # Customer Service Port
      'EHP_BACKUP'         : 3638 , # EHP Backup Protocol
      'XAP_HA'             : 3639 , # Extensible Automation
      'NETPLAY_PORT1'      : 3640 , # Netplay Port 1
      'NETPLAY_PORT2'      : 3641 , # Netplay Port 2
      'JUXML_PORT'         : 3642 , # Juxml Replication port
      'AUDIOJUGGLER'       : 3643 , # AudioJuggler
      'SSOWATCH'           : 3644 , # ssowatch
      'CYC'                : 3645 , # Cyc
      'XSS_SRV_PORT'       : 3646 , # XSS Server Port
      'SPLITLOCK_GW'       : 3647 , # Splitlock Gateway
      'FJCP'               : 3648 , # Fujitsu Cooperation Port
      'NMMP'               : 3649 , # Nishioka Miyuki Msg Protocol
      'PRISMIQ_PLUGIN'     : 3650 , # PRISMIQ VOD plug_in
      'XRPC_REGISTRY'      : 3651 , # XRPC Registry
      'VXCRNBUPORT'        : 3652 , # VxCR NBU Default Port
      'TSP'                : 3653 , # Tunnel Setup Protocol
      'VAPRTM'             : 3654 , # VAP RealTime Messenger
      'ABATEMGR'           : 3655 , # ActiveBatch Exec Agent
      'ABATJSS'            : 3656 , # ActiveBatch Job Scheduler
      'IMMEDIANET_BCN'     : 3657 , # ImmediaNet Beacon
      'PS_AMS'             : 3658 , # PlayStation AMS (Secure)
      'APPLE_SASL'         : 3659 , # Apple SASL
      'CAN_NDS_SSL'        : 3660 , # IBM Tivoli Directory Service using SSL
      'CAN_FERRET_SSL'     : 3661 , # IBM Tivoli Directory Service using SSL
      'PSERVER'            : 3662 , # pserver
      'DTP'                : 3663 , # DIRECWAY Tunnel Protocol
      'UPS_ENGINE'         : 3664 , # UPS Engine Port
      'ENT_ENGINE'         : 3665 , # Enterprise Engine Port
      'ESERVER_PAP'        : 3666 , # IBM eServer PAP
      'INFOEXCH'           : 3667 , # IBM Information Exchange
      'DELL_RM_PORT'       : 3668 , # Dell Remote Management
      'CASANSWMGMT'        : 3669 , # CA SAN Switch Management
      'SMILE'              : 3670 , # SMILE TCP_UDP Interface
      'EFCP'               : 3671 , # e Field Control (EIBnet)
      'LISPWORKS_ORB'      : 3672 , # LispWorks ORB
      'MEDIAVAULT_GUI'     : 3673 , # Openview Media Vault GUI
      'WININSTALL_IPC'     : 3674 , # WinINSTALL IPC Port
      'CALLTRAX'           : 3675 , # CallTrax Data Port
      'VA_PACBASE'         : 3676 , # VisualAge Pacbase server
      'ROVERLOG'           : 3677 , # RoverLog IPC
      'IPR_DGLT'           : 3678 , # DataGuardianLT
      'ESCALE(Newton Dock)': 3679 , # Newton Dock
      'NPDS_TRACKER'       : 3680 , # NPDS Tracker
      'BTS_X73'            : 3681 , # BTS X73 Port
      'CAS_MAPI'           : 3682 , # EMC SmartPackets_MAPI
      'BMC_EA'             : 3683 , # BMC EDV_EA
      'FAXSTFX_PORT'       : 3684 , # FAXstfX
      'DSX_AGENT'          : 3685 , # DS Expert Agent
      'TNMPV2'             : 3686 , # Trivial Network Management
      'SIMPLE_PUSH'        : 3687 , # simple_push
      'SIMPLE_PUSH_S'      : 3688 , # simple_push Secure
      'DAAP'               : 3689 , # Digital Audio Access Protocol (iTunes)
      'SVN'                : 3690 , # Subversion
      'MAGAYA_NETWORK'     : 3691 , # Magaya Network Port
      'INTELSYNC'          : 3692 , # Brimstone IntelSync
      'BMC_DATA_COLL'      : 3695 , # BMC Data Collection
      'TELNETCPCD'         : 3696 , # Telnet Com Port Control
      'NW_LICENSE'         : 3697 , # NavisWorks License System
      'SAGECTLPANEL'       : 3698 , # SAGECTLPANEL
      'KPN_ICW'            : 3699 , # Internet Call Waiting
      'LRS_PAGING'         : 3700 , # LRS NetPage
      'NETCELERA'          : 3701 , # NetCelera
      'WS_DISCOVERY'       : 3702 , # Web Service Discovery
      'ADOBESERVER_3'      : 3703 , # Adobe Server 3
      'ADOBESERVER_4'      : 3704 , # Adobe Server 4
      'ADOBESERVER_5'      : 3705 , # Adobe Server 5
      'RT_EVENT'           : 3706 , # Real_Time Event Port
      'RT_EVENT_S'         : 3707 , # Real_Time Event Secure Port
      'SUN_AS_IIOPS'       : 3708 , # Sun App Svr _ Naming
      'CA_IDMS'            : 3709 , # CA_IDMS Server
      'PORTGATE_AUTH'      : 3710 , # PortGate Authentication
      'EDB_SERVER2'        : 3711 , # EBD Server 2
      'SENTINEL_ENT'       : 3712 , # Sentinel Enterprise
      'TFTPS'              : 3713 , # TFTP over TLS
      'DELOS_DMS'          : 3714 , # DELOS Direct Messaging
      'ANOTO_RENDEZV'      : 3715 , # Anoto Rendezvous Port
      'WV_CSP_SMS_CIR'     : 3716 , # WV CSP SMS CIR Channel
      'WV_CSP_UDP_CIR'     : 3717 , # WV CSP UDP_IP CIR Channel
      'OPUS_SERVICES'      : 3718 , # OPUS Server Port
      'ITELSERVERPORT'     : 3719 , # iTel Server Port
      'UFASTRO_INSTR'      : 3720 , # UF Astro. Instr. Services
      'XSYNC'              : 3721 , # Xsync
      'XSERVERAID'         : 3722 , # Xserve RAID
      'SYCHROND'           : 3723 , # Sychron Service Daemon
      'BLIZWOW'            : 3724 , # World of Warcraft
      'NA_ER_TIP'          : 3725 , # Netia NA_ER Port
      'ARRAY_MANAGER'      : 3726 , # Xyratex Array Manager
      'E_MDU'              : 3727 , # Ericsson Mobile Data Unit
      'E_WOA'              : 3728 , # Ericsson Web on Air
      'FKSP_AUDIT'         : 3729 , # Fireking Audit Port
      'CLIENT_CTRL'        : 3730 , # Client Control
      'SMAP'               : 3731 , # Service Manager
      'M_WNN'              : 3732 , # Mobile Wnn
      'MULTIP_MSG'         : 3733 , # Multipuesto Msg Port
      'SYNEL_DATA'         : 3734 , # Synel Data Collection Port
      'PWDIS'              : 3735 , # Password Distribution
      'RS_RMI'             : 3736 , # RealSpace RMI
      'XPANEL'             : 3737 , # XPanel Daemon
      'VERSATALK'          : 3738 , # versaTalk Server Port
      'LAUNCHBIRD_LM'      : 3739 , # Launchbird LicenseManager
      'HEARTBEAT'          : 3740 , # Heartbeat Protocol
      'WYSDMA'             : 3741 , # WysDM Agent
      'CST_PORT'           : 3742 , # CST _ Configuration & Service Tracker
      'IPCS_COMMAND'       : 3743 , # IP Control Systems Ltd.
      'SASG'               : 3744 , # SASG
      'GW_CALL_PORT'       : 3745 , # GWRTC Call Port
      'LINKTEST'           : 3746 , # LXPRO.COM LinkTest
      'LINKTEST_S'         : 3747 , # LXPRO.COM LinkTest SSL
      'WEBDATA'            : 3748 , # webData
      'CIMTRAK'            : 3749 , # CimTrak
      'CBOS_IP_PORT'       : 3750 , # CBOS_IP ncapsalation port
      'GPRS_CUBE'          : 3751 , # CommLinx GPRS Cube
      'VIPREMOTEAGENT'     : 3752 , # Vigil_IP RemoteAgent
      'NATTYSERVER'        : 3753 , # NattyServer Port
      'TIMESTENBROKER'     : 3754 , # TimesTen Broker Port
      'SAS_REMOTE_HLP'     : 3755 , # SAS Remote Help Server
      'CANON_CAPT'         : 3756 , # Canon CAPT Port
      'GRF_PORT'           : 3757 , # GRF Server Port
      'APW_REGISTRY'       : 3758 , # apw RMI registry
      'EXAPT_LMGR'         : 3759 , # Exapt License Manager
      'ADTEMPUSCLIENT'     : 3760 , # adTempus Client
      'GSAKMP'             : 3761 , # gsakmp port
      'GBS_SMP'            : 3762 , # GBS SnapMail Protocol
      'XO_WAVE'            : 3763 , # XO Wave Control Port
      'MNI_PROT_ROUT'      : 3764 , # MNI Protected Routing
      'RTRACEROUTE'        : 3765 , # Remote Traceroute
      'SITEWATCH_S'        : 3766 , # SSL e_watch sitewatch server
      'LISTMGR_PORT'       : 3767 , # ListMGR Port
      'RBLCHECKD'          : 3768 , # rblcheckd server daemon
      'HAIPE_OTNK'         : 3769 , # HAIPE Network Keying
      'CINDYCOLLAB'        : 3770 , # Cinderella Collaboration
      'PAGING_PORT'        : 3771 , # RTP Paging Port
      'CTP'                : 3772 , # Chantry Tunnel Protocol
      'CTDHERCULES'        : 3773 , # ctdhercules
      'ZICOM'              : 3774 , # ZICOM
      'ISPMMGR'            : 3775 , # ISPM Manager Port
      'DVCPROV_PORT'       : 3776 , # Device Provisioning Port
      'JIBE_EB'            : 3777 , # Jibe EdgeBurst
      'C_H_IT_PORT'        : 3778 , # Cutler_Hammer IT Port
      'COGNIMA'            : 3779 , # Cognima Replication
      'NNP'                : 3780 , # Nuzzler Network Protocol
      'ABCVOICE_PORT'      : 3781 , # ABCvoice server port
      'ISO_TP0S'           : 3782 , # Secure ISO TP0 port
      'BIM_PEM'            : 3783 , # Impact Mgr._PEM Gateway
      'BFD_CONTROL'        : 3784 , # BFD Control Protocol
      'BFD_ECHO'           : 3785 , # BFD Echo Protocol
      'UPSTRIGGERVSW'      : 3786 , # VSW Upstrigger port
      'FINTRX'             : 3787 , # Fintrx
      'ISRP_PORT'          : 3788 , # SPACEWAY Routing port
      'REMOTEDEPLOY'       : 3789 , # RemoteDeploy Administration Port
      'QUICKBOOKSRDS'      : 3790 , # QuickBooks RDS
      'TVNETWORKVIDEO'     : 3791 , # TV NetworkVideo Data port
      'SITEWATCH'          : 3792 , # e_Watch Corporation SiteWatch
      'DCSOFTWARE'         : 3793 , # DataCore Software
      'JAUS'               : 3794 , # JAUS Robots
      'MYBLAST'            : 3795 , # myBLAST Mekentosj port
      'SPW_DIALER'         : 3796 , # Spaceway Dialer
      'IDPS'               : 3797 , # idps
      'MINILOCK'           : 3798 , # Minilock
      'RADIUS_DYNAUTH'     : 3799 , # RADIUS Dynamic Authorization
      'PWGPSI'             : 3800 , # Print Services Interface
      'IBM_MGR'            : 3801 , # ibm manager service
      'VHD'                : 3802 , # VHD
      'SONIQSYNC'          : 3803 , # SoniqSync
      'IQNET_PORT'         : 3804 , # Harman IQNet Port
      'TCPDATASERVER'      : 3805 , # ThorGuard Server Port
      'WSMLB'              : 3806 , # Remote System Manager
      'SPUGNA'             : 3807 , # SpuGNA Communication Port
      'SUN_AS_IIOPS_CA'    : 3808 , # Sun App Svr_IIOPClntAuth
      'APOCD'              : 3809 , # Java Desktop System Configuration Agent
      'WLANAUTH'           : 3810 , # WLAN AS server
      'AMP'                : 3811 , # AMP
      'NETO_WOL_SERVER'    : 3812 , # netO WOL Server
      'RAP_IP'             : 3813 , # Rhapsody Interface Protocol
      'NETO_DCS'           : 3814 , # netO DCS
      'LANSURVEYORXML'     : 3815 , # LANsurveyor XML
      'SUNLPS_HTTP'        : 3816 , # Sun Local Patch Server
      'TAPEWARE'           : 3817 , # Yosemite Tech Tapeware
      'CRINIS_HB'          : 3818 , # Crinis Heartbeat
      'EPL_SLP'            : 3819 , # EPL Sequ Layer Protocol
      'SCP'                : 3820 , # Siemens AuD SCP
      'PMCP'               : 3821 , # ATSC PMCP Standard
      'ACP_DISCOVERY'      : 3822 , # Compute Pool Discovery
      'ACP_CONDUIT'        : 3823 , # Compute Pool Conduit
      'ACP_POLICY'         : 3824 , # Compute Pool Policy
      'FFSERVER'           : 3825 , # Antera FlowFusion Process Simulation
      'WARMUX'             : 3826 , # WarMUX game server
      'NETMPI'             : 3827 , # Netadmin Systems MPI service
      'NETEH'              : 3828 , # Netadmin Systems Event Handler
      'NETEH_EXT'          : 3829 , # Netadmin Systems Event Handler External
      'CERNSYSMGMTAGT'     : 3830 , # Cerner System Management Agent
      'DVAPPS'             : 3831 , # Docsvault Application Service
      'XXNETSERVER'        : 3832 , # xxNETserver
      'AIPN_AUTH'          : 3833 , # AIPN LS Authentication
      'SPECTARDATA'        : 3834 , # Spectar Data Stream Service
      'SPECTARDB'          : 3835 , # Spectar Database Rights Service
      'MARKEM_DCP'         : 3836 , # MARKEM NEXTGEN DCP
      'MKM_DISCOVERY'      : 3837 , # MARKEM Auto_Discovery
      'SOS'                : 3838 , # Scito Object Server
      'AMX_RMS'            : 3839 , # AMX Resource Management Suite
      'FLIRTMITMIR'        : 3840 , # www.FlirtMitMir.de
      'SHIPRUSH_DB_SVR'    : 3841 , # ShipRush Database Server
      'NHCI'               : 3842 , # NHCI status port
      'QUEST_AGENT'        : 3843 , # Quest Common Agent
      'RNM'                : 3844 , # RNM
      'V_ONE_SPP'          : 3845 , # V_ONE Single Port Proxy
      'AN_PCP'             : 3846 , # Astare Network PCP
      'MSFW_CONTROL'       : 3847 , # MS Firewall Control
      'ITEM'               : 3848 , # IT Environmental Monitor
      'SPW_DNSPRELOAD'     : 3849 , # SPACEWAY DNS Preload
      'QTMS_BOOTSTRAP'     : 3850 , # QTMS Bootstrap Protocol
      'SPECTRAPORT'        : 3851 , # SpectraTalk Port
      'SSE_APP_CONFIG'     : 3852 , # SSE App Configuration
      'SSCAN'              : 3853 , # SONY scanning protocol
      'STRYKER_COM'        : 3854 , # Stryker Comm Port
      'OPENTRAC'           : 3855 , # OpenTRAC
      'INFORMER'           : 3856 , # INFORMER
      'TRAP_PORT'          : 3857 , # Trap Port
      'TRAP_PORT_MOM'      : 3858 , # Trap Port MOM
      'NAV_PORT'           : 3859 , # Navini Port
      'SASP'               : 3860 , # Server_Application State Protocol (SASP)
      'WINSHADOW_HD'       : 3861 , # winShadow Host Discovery
      'GIGA_POCKET'        : 3862 , # GIGA_POCKET
      'ASAP_TCP'           : 3863 , # asap tcp port
      'ASAP_TCP_TLS'       : 3864 , # asap_tls tcp port
      'XPL'                : 3865 , # xpl automation protocol
      'DZDAEMON'           : 3866 , # Sun SDViz DZDAEMON Port
      'DZOGLSERVER'        : 3867 , # Sun SDViz DZOGLSERVER Port
      'DIAMETER'           : 3868 , # DIAMETER
      'OVSAM_MGMT'         : 3869 , # hp OVSAM MgmtServer Disco
      'OVSAM_D_AGENT'      : 3870 , # hp OVSAM HostAgent Disco
      'AVOCENT_ADSAP'      : 3871 , # Avocent DS Authorization
      'OEM_AGENT'          : 3872 , # OEM Agent
      'FAGORDNC'           : 3873 , # fagordnc
      'SIXXSCONFIG'        : 3874 , # SixXS Configuration
      'PNBSCADA'           : 3875 , # PNBSCADA
      'DL_AGENT'           : 3876 , # DirectoryLockdown AgentIANA assigned this well_formed service name as a replacement for "dl_agent".
      'DL_AGENT'           : 3876 , # DirectoryLockdown Agent
      'XMPCR_INTERFACE'    : 3877 , # XMPCR Interface Port
      'FOTOGCAD'           : 3878 , # FotoG CAD interface
      'APPSS_LM'           : 3879 , # appss license manager
      'IGRS'               : 3880 , # IGRS
      'IDAC'               : 3881 , # Data Acquisition and Control
      'MSDTS1'             : 3882 , # DTS Service Port
      'VRPN'               : 3883 , # VR Peripheral Network
      'SOFTRACK_METER'     : 3884 , # SofTrack Metering
      'TOPFLOW_SSL'        : 3885 , # TopFlow SSL
      'NEI_MANAGEMENT'     : 3886 , # NEI management port
      'CIPHIRE_DATA'       : 3887 , # Ciphire Data Transport
      'CIPHIRE_SERV'       : 3888 , # Ciphire Services
      'DANDV_TESTER'       : 3889 , # D and V Tester Control Port
      'NDSCONNECT'         : 3890 , # Niche Data Server Connect
      'RTC_PM_PORT'        : 3891 , # Oracle RTC_PM port
      'PCC_IMAGE_PORT'     : 3892 , # PCC_image_port
      'CGI_STARAPI'        : 3893 , # CGI StarAPI Server
      'SYAM_AGENT'         : 3894 , # SyAM Agent Port
      'SYAM_SMC'           : 3895 , # SyAm SMC Service Port
      'SDO_TLS'            : 3896 , # Simple Distributed Objects over TLS
      'SDO_SSH'            : 3897 , # Simple Distributed Objects over SSH
      'SENIP'              : 3898 , # IAS, Inc. SmartEye NET Internet Protocol
      'ITV_CONTROL'        : 3899 , # ITV Port
      'UDT_OS'             : 3900 , # Unidata UDT OSIANA assigned this well_formed service name as a replacement for "udt_os".
      'UDT_OS'             : 3900 , # Unidata UDT OS
      'NIMSH'              : 3901 , # NIM Service Handler
      'NIMAUX'             : 3902 , # NIMsh Auxiliary Port
      'CHARSETMGR'         : 3903 , # CharsetMGR
      'OMNILINK_PORT'      : 3904 , # Arnet Omnilink Port
      'MUPDATE'            : 3905 , # Mailbox Update (MUPDATE) protocol
      'TOPOVISTA_DATA'     : 3906 , # TopoVista elevation data
      'IMOGUIA_PORT'       : 3907 , # Imoguia Port
      'HPPRONETMAN'        : 3908 , # HP Procurve NetManagement
      'SURFCONTROLCPA'     : 3909 , # SurfControl CPA
      'PRNREQUEST'         : 3910 , # Printer Request Port
      'PRNSTATUS'          : 3911 , # Printer Status Port
      'GBMT_STARS'         : 3912 , # Global Maintech Stars
      'LISTCRT_PORT'       : 3913 , # ListCREATOR Port
      'LISTCRT_PORT_2'     : 3914 , # ListCREATOR Port 2
      'AGCAT'              : 3915 , # Auto_Graphics Cataloging
      'WYSDMC'             : 3916 , # WysDM Controller
      'AFTMUX'             : 3917 , # AFT multiplex port
      'PKTCABLEMMCOPS'     : 3918 , # PacketCableMultimediaCOPS
      'HYPERIP'            : 3919 , # HyperIP
      'EXASOFTPORT1'       : 3920 , # Exasoft IP Port
      'HERODOTUS_NET'      : 3921 , # Herodotus Net
      'SOR_UPDATE'         : 3922 , # Soronti Update Port
      'SYMB_SB_PORT'       : 3923 , # Symbian Service Broker
      'MPL_GPRS_PORT'      : 3924 , # MPL_GPRS_PORT
      'ZMP'                : 3925 , # Zoran Media Port
      'WINPORT'            : 3926 , # WINPort
      'NATDATASERVICE'     : 3927 , # ScsTsr
      'NETBOOT_PXE'        : 3928 , # PXE NetBoot Manager
      'SMAUTH_PORT'        : 3929 , # AMS Port
      'SYAM_WEBSERVER'     : 3930 , # Syam Web Server Port
      'MSR_PLUGIN_PORT'    : 3931 , # MSR Plugin Port
      'DYN_SITE'           : 3932 , # Dynamic Site System
      'PLBSERVE_PORT'      : 3933 , # PL_B App Server User Port
      'SUNFM_PORT'         : 3934 , # PL_B File Manager Port
      'SDP_PORTMAPPER'     : 3935 , # SDP Port Mapper Protocol
      'MAILPROX'           : 3936 , # Mailprox
      'DVBSERVDSC'         : 3937 , # DVB Service Discovery
      'DBCONTROL_AGENT'    : 3938 , # Oracle dbControl Agent poIANA assigned this well_formed service name as a replacement for "dbcontrol_agent".
      'DBCONTROL_AGENT'    : 3938 , # Oracle dbControl Agent po
      'AAMP'               : 3939 , # Anti_virus Application Management Port
      'XECP_NODE'          : 3940 , # XeCP Node Service
      'HOMEPORTAL_WEB'     : 3941 , # Home Portal Web Server
      'SRDP'               : 3942 , # satellite distribution
      'TIG'                : 3943 , # TetraNode Ip Gateway
      'SOPS'               : 3944 , # S_Ops Management
      'EMCADS'             : 3945 , # EMCADS Server Port
      'BACKUPEDGE'         : 3946 , # BackupEDGE Server
      'CCP'                : 3947 , # Connect and Control Protocol for Consumer, Commercial, and Industrial Electronic Devices
      'APDAP'              : 3948 , # Anton Paar Device Administration Protocol
      'DRIP'               : 3949 , # Dynamic Routing Information Protocol
      'NAMEMUNGE'          : 3950 , # Name Munging
      'PWGIPPFAX'          : 3951 , # PWG IPP Facsimile
      'I3_SESSIONMGR'      : 3952 , # I3 Session Manager
      'XMLINK_CONNECT'     : 3953 , # Eydeas XMLink Connect
      'ADREP'              : 3954 , # AD Replication RPC
      'P2PCOMMUNITY'       : 3955 , # p2pCommunity
      'GVCP'               : 3956 , # GigE Vision Control
      'MQE_BROKER'         : 3957 , # MQEnterprise Broker
      'MQE_AGENT'          : 3958 , # MQEnterprise Agent
      'TREEHOPPER'         : 3959 , # Tree Hopper Networking
      'BESS'               : 3960 , # Bess Peer Assessment
      'PROAXESS'           : 3961 , # ProAxess Server
      'SBI_AGENT'          : 3962 , # SBI Agent Protocol
      'THRP'               : 3963 , # Teran Hybrid Routing Protocol
      'SASGGPRS'           : 3964 , # SASG GPRS
      'ATI_IP_TO_NCPE'     : 3965 , # Avanti IP to NCPE API
      'BFLCKMGR'           : 3966 , # BuildForge Lock Manager
      'PPSMS'              : 3967 , # PPS Message Service
      'IANYWHERE_DBNS'     : 3968 , # iAnywhere DBNS
      'LANDMARKS'          : 3969 , # Landmark Messages
      'LANREVAGENT'        : 3970 , # LANrev Agent
      'LANREVSERVER'       : 3971 , # LANrev Server
      'ICONP'              : 3972 , # ict_control Protocol
      'PROGISTICS'         : 3973 , # ConnectShip Progistics
      'CITYSEARCH'         : 3974 , # Remote Applicant Tracking Service
      'AIRSHOT'            : 3975 , # Air Shot
      'OPSWAGENT'          : 3976 , # Opsware Agent
      'OPSWMANAGER'        : 3977 , # Opsware Manager
      'SECURE_CFG_SVR'     : 3978 , # Secured Configuration Server
      'SMWAN'              : 3979 , # Smith Micro Wide Area Network Service
      'ACMS'               : 3980 , # Aircraft Cabin Management System
      'STARFISH'           : 3981 , # Starfish System Admin
      'EIS'                : 3982 , # ESRI Image Server
      'EISP'               : 3983 , # ESRI Image Service
      'MAPPER_NODEMGR'     : 3984 , # MAPPER network node manager
      'MAPPER_MAPETHD'     : 3985 , # MAPPER TCP_IP server
      'MAPPER_WS_ETHD'     : 3986 , # MAPPER workstation serverIANA assigned this well_formed service name as a replacement for "mapper_ws_ethd".
      'MAPPER_WS_ETHD'     : 3986 , # MAPPER workstation server
      'CENTERLINE'         : 3987 , # Centerline
      'DCS_CONFIG'         : 3988 , # DCS Configuration Port
      'BV_QUERYENGINE'     : 3989 , # BindView_Query Engine
      'BV_IS'              : 3990 , # BindView_IS
      'BV_SMCSRV'          : 3991 , # BindView_SMCServer
      'BV_DS'              : 3992 , # BindView_DirectoryServer
      'BV_AGENT'           : 3993 , # BindView_Agent
      'ISS_MGMT_SSL'       : 3995 , # ISS Management Svcs SSL
      'ABCSOFTWARE'        : 3996 , # abcsoftware_01
      'AGENTSEASE_DB'      : 3997 , # aes_db
      'DNX'                : 3998 , # Distributed Nagios Executor Service
      'NVCNET'             : 3999 , # Norman distributes scanning service
      'TERABASE'           : 4000 , # Terabase
      'NEWOAK'             : 4001 , # NewOak
      'PXC_SPVR_FT'        : 4002 , # pxc_spvr_ft
      'PXC_SPLR_FT'        : 4003 , # pxc_splr_ft
      'PXC_ROID'           : 4004 , # pxc_roid
      'PXC_PIN'            : 4005 , # pxc_pin
      'PXC_SPVR'           : 4006 , # pxc_spvr
      'PXC_SPLR'           : 4007 , # pxc_splr
      'NETCHEQUE'          : 4008 , # NetCheque accounting
      'CHIMERA_HWM'        : 4009 , # Chimera HWM
      'SAMSUNG_UNIDEX'     : 4010 , # Samsung Unidex
      'ALTSERVICEBOOT'     : 4011 , # Alternate Service Boot
      'PDA_GATE'           : 4012 , # PDA Gate
      'ACL_MANAGER'        : 4013 , # ACL Manager
      'TAICLOCK'           : 4014 , # TAICLOCK
      'TALARIAN_MCAST1'    : 4015 , # Talarian Mcast
      'TALARIAN_MCAST2'    : 4016 , # Talarian Mcast
      'TALARIAN_MCAST3'    : 4017 , # Talarian Mcast
      'TALARIAN_MCAST4'    : 4018 , # Talarian Mcast
      'TALARIAN_MCAST5'    : 4019 , # Talarian Mcast
      'TRAP'               : 4020 , # TRAP Port
      'NEXUS_PORTAL'       : 4021 , # Nexus Portal
      'DNOX'               : 4022 , # DNOX
      'ESNM_ZONING'        : 4023 , # ESNM Zoning Port
      'TNP1_PORT'          : 4024 , # TNP1 User Port
      'PARTIMAGE'          : 4025 , # Partition Image Port
      'AS_DEBUG'           : 4026 , # Graphical Debug Server
      'BXP'                : 4027 , # bitxpress
      'DTSERVER_PORT'      : 4028 , # DTServer Port
      'IP_QSIG'            : 4029 , # IP Q signaling protocol
      'JDMN_PORT'          : 4030 , # Accell_JSP Daemon Port
      'SUUCP'              : 4031 , # UUCP over SSL
      'VRTS_AUTH_PORT'     : 4032 , # VERITAS Authorization Service
      'SANAVIGATOR'        : 4033 , # SANavigator Peer Port
      'UBXD'               : 4034 , # Ubiquinox Daemon
      'WAP_PUSH_HTTP'      : 4035 , # WAP Push OTA_HTTP port
      'WAP_PUSH_HTTPS'     : 4036 , # WAP Push OTA_HTTP secure
      'RAVEHD'             : 4037 , # RaveHD network control
      'FAZZT_PTP'          : 4038 , # Fazzt Point_To_Point
      'FAZZT_ADMIN'        : 4039 , # Fazzt Administration
      'YO_MAIN'            : 4040 , # Yo.net main service
      'HOUSTON'            : 4041 , # Rocketeer_Houston
      'LDXP'               : 4042 , # LDXP
      'NIRP'               : 4043 , # Neighbour Identity Resolution
      'LTP'                : 4044 , # Location Tracking Protocol
      'NPP'                : 4045 , # Network Paging Protocol Known UNAUTHORIZED USE: Port 4045
      'ACP_PROTO'          : 4046 , # Accounting Protocol
      'CTP_STATE'          : 4047 , # Context Transfer Protocol
      'WAFS'               : 4049 , # Wide Area File Services
      'CISCO_WAFS'         : 4050 , # Wide Area File Services
      'CPPDP'              : 4051 , # Cisco Peer to Peer Distribution Protocol
      'INTERACT'           : 4052 , # VoiceConnect Interact
      'CCU_COMM_1'         : 4053 , # CosmoCall Universe Communications Port 1
      'CCU_COMM_2'         : 4054 , # CosmoCall Universe Communications Port 2
      'CCU_COMM_3'         : 4055 , # CosmoCall Universe Communications Port 3
      'LMS'                : 4056 , # Location Message Service
      'WFM'                : 4057 , # Servigistics WFM server
      'KINGFISHER'         : 4058 , # Kingfisher protocol
      'DLMS_COSEM'         : 4059 , # DLMS_COSEM
      'DSMETER_IATC'       : 4060 , # DSMETER Inter_Agent Transfer ChannelIANA assigned this well_formed service name as a replacement for "dsmeter_iatc".
      'DSMETER_IATC'       : 4060 , # DSMETER Inter_Agent Transfer Channel
      'ICE_LOCATION'       : 4061 , # Ice Location Service (TCP)
      'ICE_SLOCATION'      : 4062 , # Ice Location Service (SSL)
      'ICE_ROUTER'         : 4063 , # Ice Firewall Traversal Service (TCP)
      'ICE_SROUTER'        : 4064 , # Ice Firewall Traversal Service (SSL)
      'AVANTI_CDP'         : 4065 , # Avanti Common DataIANA assigned this well_formed service name as a replacement for "avanti_cdp".
      'AVANTI_CDP'         : 4065 , # Avanti Common Data
      'PMAS'               : 4066 , # Performance Measurement and Analysis
      'IDP'                : 4067 , # Information Distribution Protocol
      'IPFLTBCST'          : 4068 , # IP Fleet Broadcast
      'MINGER'             : 4069 , # Minger Email Address Validation Service
      'TRIPE'              : 4070 , # Trivial IP Encryption (TrIPE)
      'AIBKUP'             : 4071 , # Automatically Incremental Backup
      'ZIETO_SOCK'         : 4072 , # Zieto Socket Communications
      'IRAPP'              : 4073 , # iRAPP Server Protocol
      'CEQUINT_CITYID'     : 4074 , # Cequint City ID UI trigger
      'PERIMLAN'           : 4075 , # ISC Alarm Message Service
      'SERAPH'             : 4076 , # Seraph DCS
      'CSSP'               : 4078 , # Coordinated Security Service Protocol
      'SANTOOLS'           : 4079 , # SANtools Diagnostic Server
      'LORICA_IN'          : 4080 , # Lorica inside facing
      'LORICA_IN_SEC'      : 4081 , # Lorica inside facing (SSL)
      'LORICA_OUT'         : 4082 , # Lorica outside facing
      'LORICA_OUT_SEC'     : 4083 , # Lorica outside facing (SSL)
      'EZMESSAGESRV'       : 4085 , # EZNews Newsroom Message Service
      'APPLUSSERVICE'      : 4087 , # APplus Service
      'NPSP'               : 4088 , # Noah Printing Service Protocol
      'OPENCORE'           : 4089 , # OpenCORE Remote Control Service
      'OMASGPORT'          : 4090 , # OMA BCAST Service Guide
      'EWINSTALLER'        : 4091 , # EminentWare Installer
      'EWDGS'              : 4092 , # EminentWare DGS
      'PVXPLUSCS'          : 4093 , # Pvx Plus CS Host
      'SYSRQD'             : 4094 , # sysrq daemon
      'XTGUI'              : 4095 , # xtgui information service
      'BRE'                : 4096 , # BRE (Bridge Relay Element)
      'PATROLVIEW'         : 4097 , # Patrol View
      'DRMSFSD'            : 4098 , # drmsfsd
      'DPCP'               : 4099 , # DPCP
      'IGO_INCOGNITO'      : 4100 , # IGo Incognito Data Port
      'BRLP_0'             : 4101 , # Braille protocol
      'BRLP_1'             : 4102 , # Braille protocol
      'BRLP_2'             : 4103 , # Braille protocol
      'BRLP_3'             : 4104 , # Braille protocol
      'SHOFAR'             : 4105 , # Shofar
      'SYNCHRONITE'        : 4106 , # Synchronite
      'J_AC'               : 4107 , # JDL Accounting LAN Service
      'ACCEL'              : 4108 , # ACCEL
      'IZM'                : 4109 , # Instantiated Zero_control Messaging
      'G2TAG'              : 4110 , # G2 RFID Tag Telemetry Data
      'XGRID'              : 4111 , # Xgrid
      'APPLE_VPNS_RP'      : 4112 , # Apple VPN Server Reporting Protocol
      'AIPN_REG'           : 4113 , # AIPN LS Registration
      'JOMAMQMONITOR'      : 4114 , # JomaMQMonitor
      'CDS'                : 4115 , # CDS Transfer Agent
      'SMARTCARD_TLS'      : 4116 , # smartcard_TLS
      'HILLRSERV'          : 4117 , # Hillr Connection Manager
      'NETSCRIPT'          : 4118 , # Netadmin Systems NETscript service
      'ASSURIA_SLM'        : 4119 , # Assuria Log Manager
      'E_BUILDER'          : 4121 , # e_Builder Application Communication
      'FPRAMS'             : 4122 , # Fiber Patrol Alarm Service
      'Z_WAVE'             : 4123 , # Z_Wave Protocol
      'TIGV2'              : 4124 , # Rohill TetraNode Ip Gateway v2
      'OPSVIEW_ENVOY'      : 4125 , # Opsview Envoy
      'DDREPL'             : 4126 , # Data Domain Replication Service
      'UNIKEYPRO'          : 4127 , # NetUniKeyServer
      'NUFW'               : 4128 , # NuFW decision delegation protocol
      'NUAUTH'             : 4129 , # NuFW authentication protocol
      'FRONET'             : 4130 , # FRONET message protocol
      'STARS'              : 4131 , # Global Maintech Stars
      'NUTS_DEM'           : 4132 , # NUTS DaemonIANA assigned this well_formed service name as a replacement for "nuts_dem".
      'NUTS_DEM'           : 4132 , # NUTS Daemon This entry is an alias to "nuts_dem".This entry is now historic, not usable for use with manycommon service discovery mechanisms.
      'NUTS_BOOTP'         : 4133 , # NUTS Bootp ServerIANA assigned this well_formed service name as a replacement for "nuts_bootp".
      'NUTS_BOOTP'         : 4133 , # NUTS Bootp Server
      'NIFTY_HMI'          : 4134 , # NIFTY_Serve HMI protocol
      'CL_DB_ATTACH'       : 4135 , # Classic Line Database Server Attach
      'CL_DB_REQUEST'      : 4136 , # Classic Line Database Server Request
      'CL_DB_REMOTE'       : 4137 , # Classic Line Database Server Remote
      'NETTEST'            : 4138 , # nettest
      'THRTX'              : 4139 , # Imperfect Networks Server
      'CEDROS_FDS'         : 4140 , # Cedros Fraud Detection SystemIANA assigned this well_formed service name as a replacement for "cedros_fds".
      'CEDROS_FDS'         : 4140 , # Cedros Fraud Detection System
      'OIRTGSVC'           : 4141 , # Workflow Server
      'OIDOCSVC'           : 4142 , # Document Server
      'OIDSR'              : 4143 , # Document Replication
      'VVR_CONTROL'        : 4145 , # VVR Control
      'TGCCONNECT'         : 4146 , # TGCConnect Beacon
      'VRXPSERVMAN'        : 4147 , # Multum Service Manager
      'HHB_HANDHELD'       : 4148 , # HHB Handheld Client
      'AGSLB'              : 4149 , # A10 GSLB Service
      'POWERALERT_NSA'     : 4150 , # PowerAlert Network Shutdown Agent
      'MENANDMICE_NOH'     : 4151 , # Men & Mice Remote ControlIANA assigned this well_formed service name as a replacement for "menandmice_noh".
      'MENANDMICE_NOH'     : 4151 , # Men & Mice Remote Control
      'IDIG_MUX'           : 4152 , # iDigTech MultiplexIANA assigned this well_formed service name as a replacement for "idig_mux".
      'IDIG_MUX'           : 4152 , # iDigTech Multiplex
      'MBL_BATTD'          : 4153 , # MBL Remote Battery Monitoring
      'ATLINKS'            : 4154 , # atlinks device discovery
      'BZR'                : 4155 , # Bazaar version control system
      'STAT_RESULTS'       : 4156 , # STAT Results
      'STAT_SCANNER'       : 4157 , # STAT Scanner Control
      'STAT_CC'            : 4158 , # STAT Command Center
      'NSS'                : 4159 , # Network Security Service
      'JINI_DISCOVERY'     : 4160 , # Jini Discovery
      'OMSCONTACT'         : 4161 , # OMS Contact
      'OMSTOPOLOGY'        : 4162 , # OMS Topology
      'SILVERPEAKPEER'     : 4163 , # Silver Peak Peer Protocol
      'SILVERPEAKCOMM'     : 4164 , # Silver Peak Communication Protocol
      'ALTCP'              : 4165 , # ArcLink over Ethernet
      'JOOST'              : 4166 , # Joost Peer to Peer Protocol
      'DDGN'               : 4167 , # DeskDirect Global Network
      'PSLICSER'           : 4168 , # PrintSoft License Server
      'IADT'               : 4169 , # Automation Drive Interface Transport
      'D_CINEMA_CSP'       : 4170 , # SMPTE Content Synchonization Protocol
      'ML_SVNET'           : 4171 , # Maxlogic Supervisor Communication
      'PCOIP'              : 4172 , # PC over IP
      'SMCLUSTER'          : 4174 , # StorMagic Cluster Services
      'BCCP'               : 4175 , # Brocade Cluster Communication Protocol
      'TL_IPCPROXY'        : 4176 , # Translattice Cluster IPC Proxy
      'WELLO'              : 4177 , # Wello P2P pubsub service
      'STORMAN'            : 4178 , # StorMan
      'MAXUMSP'            : 4179 , # Maxum Services
      'HTTPX'              : 4180 , # HTTPX
      'MACBAK'             : 4181 , # MacBak
      'PCPTCPSERVICE'      : 4182 , # Production Company Pro TCP Service
      'GMMP'               : 4183 , # General Metaverse Messaging Protocol
      'UNIVERSE_SUITE'     : 4184 , # UNIVERSE SUITE MESSAGE SERVICEIANA assigned this well_formed service name as a replacement for "universe_suite".
      'UNIVERSE_SUITE'     : 4184 , # UNIVERSE SUITE MESSAGE SERVICE
      'WCPP'               : 4185 , # Woven Control Plane Protocol
      'BOXBACKUPSTORE'     : 4186 , # Box Backup Store Service
      'CSC_PROXY'          : 4187 , # Cascade ProxyIANA assigned this well_formed service name as a replacement for "csc_proxy".
      'CSC_PROXY'          : 4187 , # Cascade Proxy
      'VATATA'             : 4188 , # Vatata Peer to Peer Protocol
      'PCEP'               : 4189 , # Path Computation Element Communication Protocol
      'SIEVE'              : 4190 , # ManageSieve Protocol
      'AZETI'              : 4192 , # Azeti Agent Service
      'PVXPLUSIO'          : 4193 , # PxPlus remote file srvr
      'EIMS_ADMIN'         : 4199 , # EIMS ADMIN
      'CORELCCAM'          : 4300 , # Corel CCam
      'D_DATA'             : 4301 , # Diagnostic Data
      'D_DATA_CONTROL'     : 4302 , # Diagnostic Data Control
      'SRCP'               : 4303 , # Simple Railroad Command Protocol
      'OWSERVER'           : 4304 , # One_Wire Filesystem Server
      'BATMAN'             : 4305 , # better approach to mobile ad_hoc networking
      'PINGHGL'            : 4306 , # Hellgate London
      'VISICRON_VS'        : 4307 , # Visicron Videoconference Service
      'COMPX_LOCKVIEW'     : 4308 , # CompX_LockView
      'DSERVER'            : 4309 , # Exsequi Appliance Discovery
      'MIRRTEX'            : 4310 , # Mir_RT exchange service
      'P6SSMC'             : 4311 , # P6R Secure Server Management Console
      'PSCL_MGT'           : 4312 , # Parascale Membership Manager
      'PERRLA'             : 4313 , # PERRLA User Services
      'CHOICEVIEW_AGT'     : 4314 , # ChoiceView Agent
      'CHOICEVIEW_CLT'     : 4316 , # ChoiceView Client
      'FDT_RCATP'          : 4320 , # FDT Remote Categorization Protocol
      'RWHOIS'             : 4321 , # Remote Who Is
      'TRIM_EVENT'         : 4322 , # TRIM Event Service
      'TRIM_ICE'           : 4323 , # TRIM ICE Service
      'BALOUR'             : 4324 , # Balour Game Server
      'GEOGNOSISMAN'       : 4325 , # Cadcorp GeognoSIS Manager Service
      'GEOGNOSIS'          : 4326 , # Cadcorp GeognoSIS Service
      'JAXER_WEB'          : 4327 , # Jaxer Web Protocol
      'JAXER_MANAGER'      : 4328 , # Jaxer Manager Command Protocol
      'PUBLIQARE_SYNC'     : 4329 , # PubliQare Distributed Environment Synchronisation Engine
      'DEY_SAPI'           : 4330 , # DEY Storage Administration REST API
      'KTICKETS_REST'      : 4331 , # ktickets REST API for event management and ticketing systems (embedded POS devices)
      'AHSP'               : 4333 , # ArrowHead Service Protocol (AHSP)
      'GAIA'               : 4340 , # Gaia Connector Protocol
      'LISP_DATA'          : 4341 , # LISP Data Packets
      'LISP_CONS'          : 4342 , # LISP_CONS Control
      'UNICALL'            : 4343 , # UNICALL
      'VINAINSTALL'        : 4344 , # VinaInstall
      'M4_NETWORK_AS'      : 4345 , # Macro 4 Network AS
      'ELANLM'             : 4346 , # ELAN LM
      'LANSURVEYOR'        : 4347 , # LAN Surveyor
      'ITOSE'              : 4348 , # ITOSE
      'FSPORTMAP'          : 4349 , # File System Port Map
      'NET_DEVICE'         : 4350 , # Net Device
      'PLCY_NET_SVCS'      : 4351 , # PLCY Net Services
      'PJLINK'             : 4352 , # Projector Link
      'F5_IQUERY'          : 4353 , # F5 iQuery
      'QSNET_TRANS'        : 4354 , # QSNet Transmitter
      'QSNET_WORKST'       : 4355 , # QSNet Workstation
      'QSNET_ASSIST'       : 4356 , # QSNet Assistant
      'QSNET_COND'         : 4357 , # QSNet Conductor
      'QSNET_NUCL'         : 4358 , # QSNet Nucleus
      'OMABCASTLTKM'       : 4359 , # OMA BCAST Long_Term Key Messages
      'MATRIX_VNET'        : 4360 , # Matrix VNet Communication ProtocolIANA assigned this well_formed service name as a replacement for "matrix_vnet".
      'MATRIX_VNET'        : 4360 , # Matrix VNet Communication Protocol
      'WXBRIEF'            : 4368 , # WeatherBrief Direct
      'EPMD'               : 4369 , # Erlang Port Mapper Daemon
      'ELPRO_TUNNEL'       : 4370 , # ELPRO V2 Protocol TunnelIANA assigned this well_formed service name as a replacement for "elpro_tunnel".
      'ELPRO_TUNNEL'       : 4370 , # ELPRO V2 Protocol Tunnel
      'L2C_CONTROL'        : 4371 , # LAN2CAN Control
      'L2C_DATA'           : 4372 , # LAN2CAN Data
      'REMCTL'             : 4373 , # Remote Authenticated Command Service
      'PSI_PTT'            : 4374 , # PSI Push_to_Talk Protocol
      'TOLTECES'           : 4375 , # Toltec EasyShare
      'BIP'                : 4376 , # BioAPI Interworking
      'CP_SPXSVR'          : 4377 , # Cambridge Pixel SPx Server
      'CP_SPXDPY'          : 4378 , # Cambridge Pixel SPx Display
      'CTDB'               : 4379 , # CTDB
      'XANDROS_CMS'        : 4389 , # Xandros Community Management Service
      'WIEGAND'            : 4390 , # Physical Access Control
      'APWI_IMSERVER'      : 4391 , # American Printware IMServer Protocol
      'APWI_RXSERVER'      : 4392 , # American Printware RXServer Protocol
      'APWI_RXSPOOLER'     : 4393 , # American Printware RXSpooler Protocol
      'OMNIVISIONESX'      : 4395 , # OmniVision communication for Virtual environments
      'FLY'                : 4396 , # Fly Object Space
      'DS_SRV'             : 4400 , # ASIGRA Services
      'DS_SRVR'            : 4401 , # ASIGRA Televaulting DS_System Service
      'DS_CLNT'            : 4402 , # ASIGRA Televaulting DS_Client Service
      'DS_USER'            : 4403 , # ASIGRA Televaulting DS_Client Monitoring_Management
      'DS_ADMIN'           : 4404 , # ASIGRA Televaulting DS_System Monitoring_Management
      'DS_MAIL'            : 4405 , # ASIGRA Televaulting Message Level Restore service
      'DS_SLP'             : 4406 , # ASIGRA Televaulting DS_Sleeper Service
      'NACAGENT'           : 4407 , # Network Access Control Agent
      'SLSCC'              : 4408 , # SLS Technology Control Centre
      'NETCABINET_COM'     : 4409 , # Net_Cabinet comunication
      'ITWO_SERVER'        : 4410 , # RIB iTWO Application Server
      'FOUND'              : 4411 , # Found Messaging Protocol
      'NETROCKEY6'         : 4425 , # NetROCKEY6 SMART Plus Service
      'BEACON_PORT_2'      : 4426 , # SMARTS Beacon Port
      'DRIZZLE'            : 4427 , # Drizzle database server
      'OMVISERVER'         : 4428 , # OMV_Investigation Server_Client
      'OMVIAGENT'          : 4429 , # OMV Investigation Agent_Server
      'RSQLSERVER'         : 4430 , # REAL SQL Server
      'WSPIPE'             : 4431 , # adWISE Pipe
      'L_ACOUSTICS'        : 4432 , # L_ACOUSTICS management
      'VOP'                : 4433 , # Versile Object Protocol
      'SARIS'              : 4442 , # Saris
      'PHAROS'             : 4443 , # Pharos
      'KRB524'             : 4444 , # KRB524
      'NV_VIDEO'           : 4444 , # NV Video default
      'UPNOTIFYP'          : 4445 , # UPNOTIFYP
      'N1_FWP'             : 4446 , # N1_FWP
      'N1_RMGMT'           : 4447 , # N1_RMGMT
      'ASC_SLMD'           : 4448 , # ASC Licence Manager
      'PRIVATEWIRE'        : 4449 , # PrivateWire
      'CAMP'               : 4450 , # Common ASCII Messaging Protocol
      'CTISYSTEMMSG'       : 4451 , # CTI System Msg
      'CTIPROGRAMLOAD'     : 4452 , # CTI Program Load
      'NSSALERTMGR'        : 4453 , # NSS Alert Manager
      'NSSAGENTMGR'        : 4454 , # NSS Agent Manager
      'PRCHAT_USER'        : 4455 , # PR Chat User
      'PRCHAT_SERVER'      : 4456 , # PR Chat Server
      'PRREGISTER'         : 4457 , # PR Register
      'MCP'                : 4458 , # Matrix Configuration Protocol
      'HPSSMGMT'           : 4484 , # hpssmgmt service
      'ASSYST_DR'          : 4485 , # Assyst Data Repository Service
      'ICMS'               : 4486 , # Integrated Client Message Service
      'PREX_TCP'           : 4487 , # Protocol for Remote Execution over TCP
      'AWACS_ICE'          : 4488 , # Apple Wide Area Connectivity Service ICE Bootstrap
      'IPSEC_NAT_T'        : 4500 , # IPsec NAT_Traversal
      'EHS'                : 4535 , # Event Heap Server
      'EHS_SSL'            : 4536 , # Event Heap Server SSL
      'WSSAUTHSVC'         : 4537 , # WSS Security Service
      'SWX_GATE'           : 4538 , # Software Data Exchange Gateway
      'WORLDSCORES'        : 4545 , # WorldScores
      'SF_LM'              : 4546 , # SF License Manager (Sentinel)
      'LANNER_LM'          : 4547 , # Lanner License Manager
      'SYNCHROMESH'        : 4548 , # Synchromesh
      'AEGATE'             : 4549 , # Aegate PMR Service
      'GDS_ADPPIW_DB'      : 4550 , # Perman I Interbase Server
      'IEEE_MIH'           : 4551 , # MIH Services
      'MENANDMICE_MON'     : 4552 , # Men and Mice Monitoring
      'ICSHOSTSVC'         : 4553 , # ICS host services
      'MSFRS'              : 4554 , # MS FRS Replication
      'RSIP'               : 4555 , # RSIP Port
      'DTN_BUNDLE'         : 4556 , # DTN Bundle TCP CL Protocol
      'HYLAFAX'            : 4559 , # HylaFAX
      'AMAHI_ANYWHERE'     : 4563 , # Amahi Anywhere
      'KWTC'               : 4566 , # Kids Watch Time Control Service
      'TRAM'               : 4567 , # TRAM
      'BMC_REPORTING'      : 4568 , # BMC Reporting
      'IAX'                : 4569 , # Inter_Asterisk eXchange
      'DEPLOYMENTMAP'      : 4570 , # Service to distribute and update within a site deployment information for Oracle Communications Suite
      'RID'                : 4590 , # RID over HTTP_TLS
      'L3T_AT_AN'          : 4591 , # HRPD L3T (AT_AN)
      'IPT_ANRI_ANRI'      : 4593 , # IPT (ANRI_ANRI)
      'IAS_SESSION'        : 4594 , # IAS_Session (ANRI_ANRI)
      'IAS_PAGING'         : 4595 , # IAS_Paging (ANRI_ANRI)
      'IAS_NEIGHBOR'       : 4596 , # IAS_Neighbor (ANRI_ANRI)
      'A21_AN_1XBS'        : 4597 , # A21 (AN_1xBS)
      'A16_AN_AN'          : 4598 , # A16 (AN_AN)
      'A17_AN_AN'          : 4599 , # A17 (AN_AN)
      'PIRANHA1'           : 4600 , # Piranha1
      'PIRANHA2'           : 4601 , # Piranha2
      'MTSSERVER'          : 4602 , # EAX MTS Server
      'MENANDMICE_UPG'     : 4603 , # Men & Mice Upgrade Agent
      'IRP'                : 4604 , # Identity Registration Protocol
      'SIXCHAT'            : 4605 , # Direct End to End Secure Chat Protocol
      'PLAYSTA2_APP'       : 4658 , # PlayStation2 App Port
      'PLAYSTA2_LOB'       : 4659 , # PlayStation2 Lobby Port
      'SMACLMGR'           : 4660 , # smaclmgr
      'KAR2OUCHE'          : 4661 , # Kar2ouche Peer location service
      'OMS'                : 4662 , # OrbitNet Message Service
      'NOTEIT'             : 4663 , # Note It! Message Service
      'EMS'                : 4664 , # Rimage Messaging Server
      'CONTCLIENTMS'       : 4665 , # Container Client Message Service
      'EPORTCOMM'          : 4666 , # E_Port Message Service
      'MMACOMM'            : 4667 , # MMA Comm Services
      'MMAEDS'             : 4668 , # MMA EDS Service
      'EPORTCOMMDATA'      : 4669 , # E_Port Data Service
      'LIGHT'              : 4670 , # Light packets transfer protocol
      'ACTER'              : 4671 , # Bull RSF action server
      'RFA'                : 4672 , # remote file access server
      'CXWS'               : 4673 , # CXWS Operations
      'APPIQ_MGMT'         : 4674 , # AppIQ Agent Management
      'DHCT_STATUS'        : 4675 , # BIAP Device Status
      'DHCT_ALERTS'        : 4676 , # BIAP Generic Alert
      'BCS'                : 4677 , # Business Continuity Servi
      'TRAVERSAL'          : 4678 , # boundary traversal
      'MGESUPERVISION'     : 4679 , # MGE UPS Supervision
      'MGEMANAGEMENT'      : 4680 , # MGE UPS Management
      'PARLIANT'           : 4681 , # Parliant Telephony System
      'FINISAR'            : 4682 , # finisar
      'SPIKE'              : 4683 , # Spike Clipboard Service
      'RFID_RP1'           : 4684 , # RFID Reader Protocol 1.0
      'AUTOPAC'            : 4685 , # Autopac Protocol
      'MSP_OS'             : 4686 , # Manina Service Protocol
      'NST'                : 4687 , # Network Scanner Tool FTP
      'MOBILE_P2P'         : 4688 , # Mobile P2P Service
      'ALTOVACENTRAL'      : 4689 , # Altova DatabaseCentral
      'PRELUDE'            : 4690 , # Prelude IDS message proto
      'MTN'                : 4691 , # monotone Netsync Protocol
      'CONSPIRACY'         : 4692 , # Conspiracy messaging
      'NETXMS_AGENT'       : 4700 , # NetXMS Agent
      'NETXMS_MGMT'        : 4701 , # NetXMS Management
      'NETXMS_SYNC'        : 4702 , # NetXMS Server Synchronization
      'NPQES_TEST'         : 4703 , # Network Performance Quality Evaluation System Test Service
      'ASSURIA_INS'        : 4704 , # Assuria Insider
      'TRUCKSTAR'          : 4725 , # TruckStar Service
      'FCIS'               : 4727 , # F_Link Client Information Service
      'CAPMUX'             : 4728 , # CA Port Multiplexer
      'GEARMAN'            : 4730 , # Gearman Job Queue System
      'REMCAP'             : 4731 , # Remote Capture Protocol
      'RESORCS'            : 4733 , # RES Orchestration Catalog Services
      'IPDR_SP'            : 4737 , # IPDR_SP
      'SOLERA_LPN'         : 4738 , # SoleraTec Locator
      'IPFIX'              : 4739 , # IP Flow Info Export
      'IPFIXS'             : 4740 , # ipfix protocol over TLS
      'LUMIMGRD'           : 4741 , # Luminizer Manager
      'SICCT'              : 4742 , # SICCT
      'OPENHPID'           : 4743 , # openhpi HPI service
      'IFSP'               : 4744 , # Internet File Synchronization Protocol
      'FMP'                : 4745 , # Funambol Mobile Push
      'PROFILEMAC'         : 4749 , # Profile for Mac
      'SSAD'               : 4750 , # Simple Service Auto Discovery
      'SPOCP'              : 4751 , # Simple Policy Control Protocol
      'SNAP'               : 4752 , # Simple Network Audio Protocol
      'SIMON'              : 4753 , # Simple Invocation of Methods Over Network (SIMON)
      'BFD_MULTI_CTL'      : 4784 , # BFD Multihop Control
      'SMART_INSTALL'      : 4786 , # Smart Install Service
      'SIA_CTRL_PLANE'     : 4787 , # Service Insertion Architecture (SIA) Control_Plane
      'XMCP'               : 4788 , # eXtensible Messaging Client Protocol
      'IIMS'               : 4800 , # Icona Instant Messenging System
      'IWEC'               : 4801 , # Icona Web Embedded Chat
      'ILSS'               : 4802 , # Icona License System Server
      'NOTATEIT'           : 4803 , # Notateit Messaging
      'HTCP'               : 4827 , # HTCP
      'VARADERO_0'         : 4837 , # Varadero_0
      'VARADERO_1'         : 4838 , # Varadero_1
      'VARADERO_2'         : 4839 , # Varadero_2
      'OPCUA_TCP'          : 4840 , # OPC UA TCP Protocol
      'QUOSA'              : 4841 , # QUOSA Virtual Library Service
      'GW_ASV'             : 4842 , # nCode ICE_flow Library AppServer
      'OPCUA_TLS'          : 4843 , # OPC UA TCP Protocol over TLS_SSL
      'GW_LOG'             : 4844 , # nCode ICE_flow Library LogServer
      'WCR_REMLIB'         : 4845 , # WordCruncher Remote Library Service
      'CONTAMAC_ICM'       : 4846 , # Contamac ICM ServiceIANA assigned this well_formed service name as a replacement for "contamac_icm".
      'CONTAMAC_ICM'       : 4846 , # Contamac ICM Service
      'WFC'                : 4847 , # Web Fresh Communication
      'APPSERV_HTTP'       : 4848 , # App Server _ Admin HTTP
      'APPSERV_HTTPS'      : 4849 , # App Server _ Admin HTTPS
      'SUN_AS_NODEAGT'     : 4850 , # Sun App Server _ NA
      'DERBY_REPLI'        : 4851 , # Apache Derby Replication
      'UNIFY_DEBUG'        : 4867 , # Unify Debugger
      'PHRELAY'            : 4868 , # Photon Relay
      'PHRELAYDBG'         : 4869 , # Photon Relay Debug
      'CC_TRACKING'        : 4870 , # Citcom Tracking Service
      'WIRED'              : 4871 , # Wired
      'TRITIUM_CAN'        : 4876 , # Tritium CAN Bus Bridge Service
      'LMCS'               : 4877 , # Lighting Management Control System
      'WSDL_EVENT'         : 4879 , # WSDL Event Receiver
      'HISLIP'             : 4880 , # IVI High_Speed LAN Instrument Protocol
      'WMLSERVER'          : 4883 , # Meier_Phelps License Server
      'HIVESTOR'           : 4884 , # HiveStor Distributed File System
      'ABBS'               : 4885 , # ABBS
      'LYSKOM'             : 4894 , # LysKOM Protocol A
      'RADMIN_PORT'        : 4899 , # RAdmin Port
      'HFCS'               : 4900 , # HFSQL Client_Server Database Engine
      'FLR_AGENT'          : 4901 , # FileLocator Remote Search AgentIANA assigned this well_formed service name as a replacement for "flr_agent".
      'FLR_AGENT'          : 4901 , # FileLocator Remote Search Agent
      'MAGICCONTROL'       : 4902 , # magicCONROL RF and Data Interface
      'LUTAP'              : 4912 , # Technicolor LUT Access Protocol
      'LUTCP'              : 4913 , # LUTher Control Protocol
      'BONES'              : 4914 , # Bones Remote Control
      'FRCS'               : 4915 , # Fibics Remote Control Service
      'EQ_OFFICE_4940'     : 4940 , # Equitrac Office
      'EQ_OFFICE_4941'     : 4941 , # Equitrac Office
      'EQ_OFFICE_4942'     : 4942 , # Equitrac Office
      'MUNIN'              : 4949 , # Munin Graphing Framework
      'SYBASESRVMON'       : 4950 , # Sybase Server Monitor
      'PWGWIMS'            : 4951 , # PWG WIMS
      'SAGXTSDS'           : 4952 , # SAG Directory Server
      'DBSYNCARBITER'      : 4953 , # Synchronization Arbiter
      'CCSS_QMM'           : 4969 , # CCSS QMessageMonitor
      'CCSS_QSM'           : 4970 , # CCSS QSystemMonitor
      'WEBYAST'            : 4984 , # WebYast
      'GERHCS'             : 4985 , # GER HC Standard
      'MRIP'               : 4986 , # Model Railway Interface Program
      'SMAR_SE_PORT1'      : 4987 , # SMAR Ethernet Port 1
      'SMAR_SE_PORT2'      : 4988 , # SMAR Ethernet Port 2
      'PARALLEL'           : 4989 , # Parallel for GAUSS (tm)
      'BUSYCAL'            : 4990 , # BusySync Calendar Synch. Protocol
      'VRT'                : 4991 , # VITA Radio Transport
      'HFCS_MANAGER'       : 4999 , # HFSQL Client_Server Database Engine Manager
      'COMMPLEX_MAIN'      : 5000 , # 
      'COMMPLEX_LINK'      : 5001 , # 
      'RFE'                : 5002 , # radio free ethernet
      'FMPRO_INTERNAL'     : 5003 , # FileMaker, Inc. _ Proprietary transport
      'AVT_PROFILE_1'      : 5004 , # RTP media data
      'AVT_PROFILE_2'      : 5005 , # RTP control protocol
      'WSM_SERVER'         : 5006 , # wsm server
      'WSM_SERVER_SSL'     : 5007 , # wsm server ssl
      'SYNAPSIS_EDGE'      : 5008 , # Synapsis EDGE
      'WINFS'              : 5009 , # Microsoft Windows Filesystem
      'TELELPATHSTART'     : 5010 , # TelepathStart
      'TELELPATHATTACK'    : 5011 , # TelepathAttack
      'NSP'                : 5012 , # NetOnTap Service
      'FMPRO_V6'           : 5013 , # FileMaker, Inc. _ Proprietary transport
      'FMWP'               : 5015 , # FileMaker, Inc. _ Web publishing
      'ZENGINKYO_1'        : 5020 , # zenginkyo_1
      'ZENGINKYO_2'        : 5021 , # zenginkyo_2
      'MICE'               : 5022 , # mice server
      'HTUILSRV'           : 5023 , # Htuil Server for PLD2
      'SCPI_TELNET'        : 5024 , # SCPI_TELNET
      'SCPI_RAW'           : 5025 , # SCPI_RAW
      'STREXEC_D'          : 5026 , # Storix I_O daemon (data)
      'STREXEC_S'          : 5027 , # Storix I_O daemon (stat)
      'QVR'                : 5028 , # Quiqum Virtual Relais
      'INFOBRIGHT'         : 5029 , # Infobright Database Server
      'SURFPASS'           : 5030 , # SurfPass
      'SIGNACERT_AGENT'    : 5032 , # SignaCert Enterprise Trust Server Agent
      'ASNAACCELER8DB'     : 5042 , # asnaacceler8db
      'SWXADMIN'           : 5043 , # ShopWorX Administration
      'LXI_EVNTSVC'        : 5044 , # LXI Event Service
      'OSP'                : 5045 , # Open Settlement Protocol
      'TEXAI'              : 5048 , # Texai Message Service
      'IVOCALIZE'          : 5049 , # iVocalize Web Conference
      'MMCC'               : 5050 , # multimedia conference control tool
      'ITA_AGENT'          : 5051 , # ITA Agent
      'ITA_MANAGER'        : 5052 , # ITA Manager
      'RLM'                : 5053 , # RLM License Server
      'RLM_ADMIN'          : 5054 , # RLM administrative interface
      'UNOT'               : 5055 , # UNOT
      'INTECOM_PS1'        : 5056 , # Intecom Pointspan 1
      'INTECOM_PS2'        : 5057 , # Intecom Pointspan 2
      'SDS'                : 5059 , # SIP Directory Services
      'SIP'                : 5060 , # SIP 2014_04_09
      'SIPS'               : 5061 , # SIP_TLS 2014_04_09
      'NA_LOCALISE'        : 5062 , # Localisation access
      'CSRPC'              : 5063 , # centrify secure RPC
      'CA_1'               : 5064 , # Channel Access 1
      'CA_2'               : 5065 , # Channel Access 2
      'STANAG_5066'        : 5066 , # STANAG_5066_SUBNET_INTF
      'AUTHENTX'           : 5067 , # Authentx Service
      'BITFORESTSRV'       : 5068 , # Bitforest Data Service
      'I_NET_2000_NPR'     : 5069 , # I_Net 2000_NPR
      'VTSAS'              : 5070 , # VersaTrans Server Agent Service
      'POWERSCHOOL'        : 5071 , # PowerSchool
      'AYIYA'              : 5072 , # Anything In Anything
      'TAG_PM'             : 5073 , # Advantage Group Port Mgr
      'ALESQUERY'          : 5074 , # ALES Query
      'PVACCESS'           : 5075 , # Experimental Physics and Industrial Control System
      'ONSCREEN'           : 5080 , # OnScreen Data Collection Service
      'SDL_ETS'            : 5081 , # SDL _ Ent Trans Server
      'QCP'                : 5082 , # Qpur Communication Protocol
      'QFP'                : 5083 , # Qpur File Protocol
      'LLRP'               : 5084 , # EPCglobal Low_Level Reader Protocol
      'ENCRYPTED_LLRP'     : 5085 , # EPCglobal Encrypted LLRP
      'APRIGO_CS'          : 5086 , # Aprigo Collection Service
      'BIOTIC'             : 5087 , # BIOTIC _ Binary Internet of Things Interoperable Communication
      'SENTINEL_LM'        : 5093 , # Sentinel LM
      'HART_IP'            : 5094 , # HART_IP
      'SENTLM_SRV2SRV'     : 5099 , # SentLM Srv2Srv
      'SOCALIA'            : 5100 , # Socalia service mux
      'TALARIAN_TCP'       : 5101 , # Talarian_TCP
      'OMS_NONSECURE'      : 5102 , # Oracle OMS non_secure
      'ACTIFIO_C2C'        : 5103 , # Actifio C2C
      'ACTIFIOUDSAGENT'    : 5106 , # Actifio UDS Agent
      'TAEP_AS_SVC'        : 5111 , # TAEP AS service
      'PM_CMDSVR'          : 5112 , # PeerMe Msg Cmd Service
      'EV_SERVICES'        : 5114 , # Enterprise Vault Services
      'AUTOBUILD'          : 5115 , # Symantec Autobuild Service
      'GRADECAM'           : 5117 , # GradeCam Image Processing
      'BARRACUDA_BBS'      : 5120 , # Barracuda Backup Protocol
      'NBT_PC'             : 5133 , # Policy Commander
      'PPACTIVATION'       : 5134 , # PP ActivationServer
      'ERP_SCALE'          : 5135 , # ERP_Scale
      'CTSD'               : 5137 , # MyCTS server port
      'RMONITOR_SECURE'    : 5145 , # RMONITOR SECUREIANA assigned this well_formed service name as a replacement for "rmonitor_secure".
      'RMONITOR_SECURE'    : 5145 , # RMONITOR SECURE
      'SOCIAL_ALARM'       : 5146 , # Social Alarm Service
      'ATMP'               : 5150 , # Ascend Tunnel Management Protocol
      'ESRI_SDE'           : 5151 , # ESRI SDE Instance    IANA assigned this well_formed service name as a replacement for "esri_sde".
      'ESRI_SDE'           : 5151 , # ESRI SDE Instance
      'SDE_DISCOVERY'      : 5152 , # ESRI SDE Instance Discovery
      'TORUXSERVER'        : 5153 , # ToruX Game Server
      'BZFLAG'             : 5154 , # BZFlag game server
      'ASCTRL_AGENT'       : 5155 , # Oracle asControl Agent
      'RUGAMEONLINE'       : 5156 , # Russian Online Game
      'MEDIAT'             : 5157 , # Mediat Remote Object Exchange
      'SNMPSSH'            : 5161 , # SNMP over SSH Transport Model
      'SNMPSSH_TRAP'       : 5162 , # SNMP Notification over SSH Transport Model
      'SBACKUP'            : 5163 , # Shadow Backup
      'VPA'                : 5164 , # Virtual Protocol Adapter
      'IFE_ICORP'          : 5165 , # ife_1corpIANA assigned this well_formed service name as a replacement for "ife_icorp".
      'IFE_ICORP'          : 5165 , # ife_1corp
      'WINPCS'             : 5166 , # WinPCS Service Connection
      'SCTE104'            : 5167 , # SCTE104 Connection
      'SCTE30'             : 5168 , # SCTE30 Connection
      'PCOIP_MGMT'         : 5172 , # PC over IP Endpoint Management
      'AOL'                : 5190 , # America_Online
      'AOL_1'              : 5191 , # AmericaOnline1
      'AOL_2'              : 5192 , # AmericaOnline2
      'AOL_3'              : 5193 , # AmericaOnline3
      'CPSCOMM'            : 5194 , # CipherPoint Config Service
      'AMPL_LIC'           : 5195 , # The protocol is used by a license server and client programs to control use of program licenses that float to networked machines
      'AMPL_TABLEPROXY'    : 5196 , # The protocol is used by two programs that exchange "table" data used in the AMPL modeling language
      'TARGUS_GETDATA'     : 5200 , # TARGUS GetData
      'TARGUS_GETDATA1'    : 5201 , # TARGUS GetData 1
      'TARGUS_GETDATA2'    : 5202 , # TARGUS GetData 2
      'TARGUS_GETDATA3'    : 5203 , # TARGUS GetData 3
      'NOMAD'              : 5209 , # Nomad Device Video Transfer
      'NOTEZA'             : 5215 , # NOTEZA Data Safety Service
      '3EXMP'              : 5221 , # 3eTI Extensible Management Protocol for OAMP
      'XMPP_CLIENT'        : 5222 , # XMPP Client Connection
      'HPVIRTGRP'          : 5223 , # HP Virtual Machine Group Management
      'HPVIRTCTRL'         : 5224 , # HP Virtual Machine Console Operations
      'HP_SERVER'          : 5225 , # HP Server
      'HP_STATUS'          : 5226 , # HP Status
      'PERFD'              : 5227 , # HP System Performance Metric Service
      'HPVROOM'            : 5228 , # HP Virtual Room Service
      'JAXFLOW'            : 5229 , # Netflow_IPFIX_sFlow Collector and Forwarder Management
      'JAXFLOW_DATA'       : 5230 , # JaxMP RealFlow application and protocol data
      'CRUSECONTROL'       : 5231 , # Remote Control of Scan Software for Cruse Scanners
      'CSEDAEMON'          : 5232 , # Cruse Scanning System Service
      'ENFS'               : 5233 , # Etinnae Network File Service
      'EENET'              : 5234 , # EEnet communications
      'GALAXY_NETWORK'     : 5235 , # Galaxy Network Service
      'PADL2SIM'           : 5236 , # 
      'MNET_DISCOVERY'     : 5237 , # m_net discovery
      'DOWNTOOLS'          : 5245 , # DownTools Control Protocol
      'CAACWS'             : 5248 , # CA Access Control Web Service
      'CAACLANG2'          : 5249 , # CA AC Lang Service
      'SOAGATEWAY'         : 5250 , # soaGateway
      'CAEVMS'             : 5251 , # CA eTrust VM Service
      'MOVAZ_SSC'          : 5252 , # Movaz SSC
      'KPDP'               : 5253 , # Kohler Power Device Protocol
      '3COM_NJACK_1'       : 5264 , # 3Com Network Jack Port 1
      '3COM_NJACK_2'       : 5265 , # 3Com Network Jack Port 2
      'XMPP_SERVER'        : 5269 , # XMPP Server Connection
      'CARTOGRAPHERXMP'    : 5270 , # Cartographer XMP
      'CUELINK'            : 5271 , # StageSoft CueLink messaging
      'PK'                 : 5272 , # PK
      'XMPP_BOSH'          : 5280 , # Bidirectional_streams Over Synchronous HTTP (BOSH)
      'UNDO_LM'            : 5281 , # Undo License Manager
      'TRANSMIT_PORT'      : 5282 , # Marimba Transmitter Port
      'PRESENCE'           : 5298 , # XMPP Link_Local Messaging
      'NLG_DATA'           : 5299 , # NLG Data Service
      'HACL_HB'            : 5300 , # HA cluster heartbeat
      'HACL_GS'            : 5301 , # HA cluster general services
      'HACL_CFG'           : 5302 , # HA cluster configuration
      'HACL_PROBE'         : 5303 , # HA cluster probing
      'HACL_LOCAL'         : 5304 , # HA Cluster Commands
      'HACL_TEST'          : 5305 , # HA Cluster Test
      'SUN_MC_GRP'         : 5306 , # Sun MC Group
      'SCO_AIP'            : 5307 , # SCO AIP
      'CFENGINE'           : 5308 , # CFengine
      'JPRINTER'           : 5309 , # J Printer
      'OUTLAWS'            : 5310 , # Outlaws
      'PERMABIT_CS'        : 5312 , # Permabit Client_Server
      'RRDP'               : 5313 , # Real_time & Reliable Data
      'OPALIS_RBT_IPC'     : 5314 , # opalis_rbt_ipc
      'HACL_POLL'          : 5315 , # HA Cluster UDP Polling
      'HPBLADEMS'          : 5316 , # HPBladeSystem Monitor Service
      'HPDEVMS'            : 5317 , # HP Device Monitor Service
      'PKIX_CMC'           : 5318 , # PKIX Certificate Management using CMS (CMC)
      'BSFSERVER_ZN'       : 5320 , # Webservices_based Zn interface of BSF
      'BSFSVR_ZN_SSL'      : 5321 , # Webservices_based Zn interface of BSF over SSL
      'KFSERVER'           : 5343 , # Sculptor Database Server
      'XKOTODRCP'          : 5344 , # xkoto DRCP
      'STUNS'              : 5349 , # STUN over TLS
      'TURNS'              : 5349 , # TURN over TLS
      'STUN_BEHAVIORS'     : 5349 , # STUN Behavior Discovery over TLS
      'DNS_LLQ'            : 5352 , # DNS Long_Lived Queries
      'MDNS'               : 5353 , # Multicast DNS
      'MDNSRESPONDER'      : 5354 , # Multicast DNS Responder IPC
      'LLMNR'              : 5355 , # LLMNR
      'MS_SMLBIZ'          : 5356 , # Microsoft Small Business
      'WSDAPI'             : 5357 , # Web Services for Devices
      'WSDAPI_S'           : 5358 , # WS for Devices Secured
      'MS_ALERTER'         : 5359 , # Microsoft Alerter
      'MS_SIDESHOW'        : 5360 , # Protocol for Windows SideShow
      'MS_S_SIDESHOW'      : 5361 , # Secure Protocol for Windows SideShow
      'SERVERWSD2'         : 5362 , # Microsoft Windows Server WSD2 Service
      'NET_PROJECTION'     : 5363 , # Windows Network Projection
      'STRESSTESTER'       : 5397 , # StressTester(tm) Injector
      'ELEKTRON_ADMIN'     : 5398 , # Elektron Administration
      'SECURITYCHASE'      : 5399 , # SecurityChase
      'EXCERPT'            : 5400 , # Excerpt Search
      'EXCERPTS'           : 5401 , # Excerpt Search Secure
      'MFTP'               : 5402 , # OmniCast MFTP
      'HPOMS_CI_LSTN'      : 5403 , # HPOMS_CI_LSTN
      'HPOMS_DPS_LSTN'     : 5404 , # HPOMS_DPS_LSTN
      'NETSUPPORT'         : 5405 , # NetSupport
      'SYSTEMICS_SOX'      : 5406 , # Systemics Sox
      'FORESYTE_CLEAR'     : 5407 , # Foresyte_Clear
      'FORESYTE_SEC'       : 5408 , # Foresyte_Sec
      'SALIENT_DTASRV'     : 5409 , # Salient Data Server
      'SALIENT_USRMGR'     : 5410 , # Salient User Manager
      'ACTNET'             : 5411 , # ActNet
      'CONTINUUS'          : 5412 , # Continuus
      'WWIOTALK'           : 5413 , # WWIOTALK
      'STATUSD'            : 5414 , # StatusD
      'NS_SERVER'          : 5415 , # NS Server
      'SNS_GATEWAY'        : 5416 , # SNS Gateway
      'SNS_AGENT'          : 5417 , # SNS Agent
      'MCNTP'              : 5418 , # MCNTP
      'DJ_ICE'             : 5419 , # DJ_ICE
      'CYLINK_C'           : 5420 , # Cylink_C
      'NETSUPPORT2'        : 5421 , # Net Support 2
      'SALIENT_MUX'        : 5422 , # Salient MUX
      'VIRTUALUSER'        : 5423 , # VIRTUALUSER
      'BEYOND_REMOTE'      : 5424 , # Beyond Remote
      'BR_CHANNEL'         : 5425 , # Beyond Remote Command Channel
      'DEVBASIC'           : 5426 , # DEVBASIC
      'SCO_PEER_TTA'       : 5427 , # SCO_PEER_TTA
      'TELACONSOLE'        : 5428 , # TELACONSOLE
      'BASE'               : 5429 , # Billing and Accounting System Exchange
      'RADEC_CORP'         : 5430 , # RADEC CORP
      'PARK_AGENT'         : 5431 , # PARK AGENT
      'POSTGRESQL'         : 5432 , # PostgreSQL Database
      'PYRRHO'             : 5433 , # Pyrrho DBMS
      'SGI_ARRAYD'         : 5434 , # SGI Array Services Daemon
      'SCEANICS'           : 5435 , # SCEANICS situation and action notification
      'SPSS'               : 5443 , # Pearson HTTPS
      'SMBDIRECT'          : 5445 , # Server Message Block over Remote Direct Memory Access
      'SUREBOX'            : 5453 , # SureBox
      'APC_5454'           : 5454 , # APC 5454
      'APC_5455'           : 5455 , # APC 5455
      'APC_5456'           : 5456 , # APC 5456
      'SILKMETER'          : 5461 , # SILKMETER
      'TTL_PUBLISHER'      : 5462 , # TTL Publisher
      'TTLPRICEPROXY'      : 5463 , # TTL Price Proxy
      'QUAILNET'           : 5464 , # Quail Networks Object Broker
      'NETOPS_BROKER'      : 5465 , # NETOPS_BROKER
      'FCP_ADDR_SRVR1'     : 5500 , # fcp_addr_srvr1
      'FCP_ADDR_SRVR2'     : 5501 , # fcp_addr_srvr2
      'FCP_SRVR_INST1'     : 5502 , # fcp_srvr_inst1
      'FCP_SRVR_INST2'     : 5503 , # fcp_srvr_inst2
      'FCP_CICS_GW1'       : 5504 , # fcp_cics_gw1
      'CHECKOUTDB'         : 5505 , # Checkout Database
      'AMC'                : 5506 , # Amcom Mobile Connect
      'SGI_EVENTMOND'      : 5553 , # SGI Eventmond Port
      'SGI_ESPHTTP'        : 5554 , # SGI ESP HTTP
      'PERSONAL_AGENT'     : 5555 , # Personal Agent
      'FREECIV'            : 5556 , # Freeciv gameplay
      'FARENET'            : 5557 , # Sandlab FARENET
      'WESTEC_CONNECT'     : 5566 , # Westec Connect
      'ENC_EPS_MC_SEC'     : 5567 , # EMIT protocol stack multicast_secure transport
      'SDT'                : 5568 , # Session Data Transport Multicast
      'RDMNET_CTRL'        : 5569 , # PLASA E1.33, Remote Device Management (RDM) controller status notifications
      'SDMMP'              : 5573 , # SAS Domain Management Messaging Protocol
      'LSI_BOBCAT'         : 5574 , # SAS IO Forwarding
      'ORA_OAP'            : 5575 , # Oracle Access Protocol
      'FDTRACKS'           : 5579 , # FleetDisplay Tracking Service
      'TMOSMS0'            : 5580 , # T_Mobile SMS Protocol Message 0
      'TMOSMS1'            : 5581 , # T_Mobile SMS Protocol Message 1
      'FAC_RESTORE'        : 5582 , # T_Mobile SMS Protocol Message 3
      'TMO_ICON_SYNC'      : 5583 , # T_Mobile SMS Protocol Message 2
      'BIS_WEB'            : 5584 , # BeInSync_Web
      'BIS_SYNC'           : 5585 , # BeInSync_sync
      'ATT_MT_SMS'         : 5586 , # Planning to send mobile terminated SMS to the specific port so that the SMS is not visible to the client
      'ININMESSAGING'      : 5597 , # inin secure messaging
      'MCTFEED'            : 5598 , # MCT Market Data Feed
      'ESINSTALL'          : 5599 , # Enterprise Security Remote Install
      'ESMMANAGER'         : 5600 , # Enterprise Security Manager
      'ESMAGENT'           : 5601 , # Enterprise Security Agent
      'A1_MSC'             : 5602 , # A1_MSC
      'A1_BS'              : 5603 , # A1_BS
      'A3_SDUNODE'         : 5604 , # A3_SDUNode
      'A4_SDUNODE'         : 5605 , # A4_SDUNode
      'EFR'                : 5618 , # Fiscal Registering Protocol
      'NINAF'              : 5627 , # Node Initiated Network Association Forma
      'HTRUST'             : 5628 , # HTrust API
      'SYMANTEC_SFDB'      : 5629 , # Symantec Storage Foundation for Database
      'PRECISE_COMM'       : 5630 , # PreciseCommunication
      'PCANYWHEREDATA'     : 5631 , # pcANYWHEREdata
      'PCANYWHERESTAT'     : 5632 , # pcANYWHEREstat
      'BEORL'              : 5633 , # BE Operations Request Listener
      'XPRTLD'             : 5634 , # SF Message Service
      'SFMSSO'             : 5635 , # SFM Authentication Subsystem
      'SFM_DB_SERVER'      : 5636 , # SFMdb _ SFM DB server
      'CSSC'               : 5637 , # Symantec CSSC
      'FLCRS'              : 5638 , # Symantec Fingerprint Lookup and Container Reference Service
      'ICS'                : 5639 , # Symantec Integrity Checking Service
      'VFMOBILE'           : 5646 , # Ventureforth Mobile
      'FILEMQ'             : 5670 , # ZeroMQ file publish_subscribe protocol
      'AMQPS'              : 5671 , # amqp protocol over TLS_SSL
      'AMQP'               : 5672 , # AMQP
      'JMS'                : 5673 , # JACL Message Server
      'HYPERSCSI_PORT'     : 5674 , # HyperSCSI Port
      'V5UA'               : 5675 , # V5UA application port
      'RAADMIN'            : 5676 , # RA Administration
      'QUESTDB2_LNCHR'     : 5677 , # Quest Central DB2 Launchr
      'RRAC'               : 5678 , # Remote Replication Agent Connection
      'DCCM'               : 5679 , # Direct Cable Connect Manager
      'AURIGA_ROUTER'      : 5680 , # Auriga Router Service
      'NCXCP'              : 5681 , # Net_coneX Control Protocol
      'GGZ'                : 5688 , # GGZ Gaming Zone
      'QMVIDEO'            : 5689 , # QM video network management protocol
      'RBSYSTEM'           : 5693 , # Robert Bosch Data Transfer
      'KMIP'               : 5696 , # Key Management Interoperability Protocol
      'PROSHAREAUDIO'      : 5713 , # proshare conf audio
      'PROSHAREVIDEO'      : 5714 , # proshare conf video
      'PROSHAREDATA'       : 5715 , # proshare conf data
      'PROSHAREREQUEST'    : 5716 , # proshare conf request
      'PROSHARENOTIFY'     : 5717 , # proshare conf notify
      'DPM'                : 5718 , # DPM Communication Server
      'DPM_AGENT'          : 5719 , # DPM Agent Coordinator
      'MS_LICENSING'       : 5720 , # MS_Licensing
      'DTPT'               : 5721 , # Desktop Passthru Service
      'MSDFSR'             : 5722 , # Microsoft DFS Replication Service
      'OMHS'               : 5723 , # Operations Manager _ Health Service
      'OMSDK'              : 5724 , # Operations Manager _ SDK Service
      'MS_ILM'             : 5725 , # Microsoft Identity Lifecycle Manager
      'MS_ILM_STS'         : 5726 , # Microsoft Lifecycle Manager Secure Token Service
      'ASGENF'             : 5727 , # ASG Event Notification Framework
      'IO_DIST_DATA'       : 5728 , # Dist. I_O Comm. Service Data and Control
      'OPENMAIL'           : 5729 , # Openmail User Agent Layer
      'UNIENG'             : 5730 , # Steltor's calendar access
      'IDA_DISCOVER1'      : 5741 , # IDA Discover Port 1
      'IDA_DISCOVER2'      : 5742 , # IDA Discover Port 2
      'WATCHDOC_POD'       : 5743 , # Watchdoc NetPOD Protocol
      'WATCHDOC'           : 5744 , # Watchdoc Server
      'FCOPY_SERVER'       : 5745 , # fcopy_server
      'FCOPYS_SERVER'      : 5746 , # fcopys_server
      'TUNATIC'            : 5747 , # Wildbits Tunatic
      'TUNALYZER'          : 5748 , # Wildbits Tunalyzer
      'RSCD'               : 5750 , # Bladelogic Agent Service
      'OPENMAILG'          : 5755 , # OpenMail Desk Gateway server
      'X500MS'             : 5757 , # OpenMail X.500 Directory Server
      'OPENMAILNS'         : 5766 , # OpenMail NewMail Server
      'S_OPENMAIL'         : 5767 , # OpenMail Suer Agent Layer (Secure)
      'OPENMAILPXY'        : 5768 , # OpenMail CMTS Server
      'SPRAMSCA'           : 5769 , # x509solutions Internal CA
      'SPRAMSD'            : 5770 , # x509solutions Secure Data
      'NETAGENT'           : 5771 , # NetAgent
      'DALI_PORT'          : 5777 , # DALI Port
      'VTS_RPC'            : 5780 , # Visual Tag System RPC
      '3PAR_EVTS'          : 5781 , # 3PAR Event Reporting Service
      '3PAR_MGMT'          : 5782 , # 3PAR Management Service
      '3PAR_MGMT_SSL'      : 5783 , # 3PAR Management Service with SSL
      '3PAR_RCOPY'         : 5785 , # 3PAR Inform Remote Copy
      'XTREAMX'            : 5793 , # XtreamX Supervised Peer message
      'ICMPD'              : 5813 , # ICMPD
      'SPT_AUTOMATION'     : 5814 , # Support Automation
      'SHIPRUSH_D_CH'      : 5841 , # Z_firm ShipRush interface for web access and bidirectional data
      'REVERSION'          : 5842 , # Reversion Backup_Restore
      'WHEREHOO'           : 5859 , # WHEREHOO
      'PPSUITEMSG'         : 5863 , # PlanetPress Suite Messeng
      'DIAMETERS'          : 5868 , # Diameter over TLS_TCP
      'JUTE'               : 5883 , # Javascript Unit Test Environment
      'RFB'                : 5900 , # Remote Framebuffer
      'CM'                 : 5910 , # Context Management
      'CPDLC'              : 5911 , # Controller Pilot Data Link Communication
      'FIS'                : 5912 , # Flight Information Services
      'ADS_C'              : 5913 , # Automatic Dependent Surveillance
      'INDY'               : 5963 , # Indy Application Server
      'MPPOLICY_V5'        : 5968 , # mppolicy_v5
      'MPPOLICY_MGR'       : 5969 , # mppolicy_mgr
      'COUCHDB'            : 5984 , # CouchDB
      'WSMAN'              : 5985 , # WBEM WS_Management HTTP
      'WSMANS'             : 5986 , # WBEM WS_Management HTTP over TLS_SSL
      'WBEM_RMI'           : 5987 , # WBEM RMI
      'WBEM_HTTP'          : 5988 , # WBEM CIM_XML (HTTP)
      'WBEM_HTTPS'         : 5989 , # WBEM CIM_XML (HTTPS)
      'WBEM_EXP_HTTPS'     : 5990 , # WBEM Export HTTPS
      'NUXSL'              : 5991 , # NUXSL
      'CONSUL_INSIGHT'     : 5992 , # Consul InSight Security
      'CVSUP'              : 5999 , # CVSup
      'X11'                : 6000 , # 6000_6063X Window System
      'NDL_AHP_SVC'        : 6064 , # NDL_AHP_SVC
      'WINPHARAOH'         : 6065 , # WinPharaoh
      'EWCTSP'             : 6066 , # EWCTSP
      'GSMP_ANCP'          : 6068 , # GSMP_ANCP
      'TRIP'               : 6069 , # TRIP
      'MESSAGEASAP'        : 6070 , # Messageasap
      'SSDTP'              : 6071 , # SSDTP
      'DIAGNOSE_PROC'      : 6072 , # DIAGNOSE_PROC
      'DIRECTPLAY8'        : 6073 , # DirectPlay8
      'MAX'                : 6074 , # Microsoft Max
      'DPM_ACM'            : 6075 , # Microsoft DPM Access Control Manager
      'MSFT_DPM_CERT'      : 6076 , # Microsoft DPM WCF Certificates
      'ICONSTRUCTSRV'      : 6077 , # iConstruct Server
      'RELOAD_CONFIG'      : 6084 , # Peer to Peer Infrastructure Configuration
      'KONSPIRE2B'         : 6085 , # konspire2b p2p network
      'PDTP'               : 6086 , # PDTP P2P
      'LDSS'               : 6087 , # Local Download Sharing Service
      'DOGLMS'             : 6088 , # SuperDog License Manager
      'RAXA_MGMT'          : 6099 , # RAXA Management
      'SYNCHRONET_DB'      : 6100 , # SynchroNet_db
      'SYNCHRONET_RTC'     : 6101 , # SynchroNet_rtc
      'SYNCHRONET_UPD'     : 6102 , # SynchroNet_upd
      'RETS'               : 6103 , # RETS
      'DBDB'               : 6104 , # DBDB
      'PRIMASERVER'        : 6105 , # Prima Server
      'MPSSERVER'          : 6106 , # MPS Server
      'ETC_CONTROL'        : 6107 , # ETC Control
      'SERCOMM_SCADMIN'    : 6108 , # Sercomm_SCAdmin
      'GLOBECAST_ID'       : 6109 , # GLOBECAST_ID
      'SOFTCM'             : 6110 , # HP SoftBench CM
      'SPC'                : 6111 , # HP SoftBench Sub_Process Control
      'DTSPCD'             : 6112 , # Desk_Top Sub_Process Control Daemon
      'DAYLITESERVER'      : 6113 , # Daylite Server
      'WRSPICE'            : 6114 , # WRspice IPC Service
      'XIC'                : 6115 , # Xic IPC Service
      'XTLSERV'            : 6116 , # XicTools License Manager Service
      'DAYLITETOUCH'       : 6117 , # Daylite Touch Sync
      'SPDY'               : 6121 , # SPDY for a faster web
      'BEX_WEBADMIN'       : 6122 , # Backup Express Web Server
      'BACKUP_EXPRESS'     : 6123 , # Backup Express
      'PNBS'               : 6124 , # Phlexible Network Backup Service
      'DAMEWAREMOBGTWY'    : 6130 , # The DameWare Mobile Gateway Service
      'NBT_WOL'            : 6133 , # New Boundary Tech WOL
      'PULSONIXNLS'        : 6140 , # Pulsonix Network License Service
      'META_CORP'          : 6141 , # Meta Corporation License Manager
      'ASPENTEC_LM'        : 6142 , # Aspen Technology License Manager
      'WATERSHED_LM'       : 6143 , # Watershed License Manager
      'STATSCI1_LM'        : 6144 , # StatSci License Manager _ 1
      'STATSCI2_LM'        : 6145 , # StatSci License Manager _ 2
      'LONEWOLF_LM'        : 6146 , # Lone Wolf Systems License Manager
      'MONTAGE_LM'         : 6147 , # Montage License Manager
      'RICARDO_LM'         : 6148 , # Ricardo North America License Manager
      'TAL_POD'            : 6149 , # tal_pod
      'EFB_ACI'            : 6159 , # EFB Application Control Interface
      'ECMP'               : 6160 , # Emerson Extensible Control and Management Protocol
      'PATROL_ISM'         : 6161 , # PATROL Internet Srv Mgr
      'PATROL_COLL'        : 6162 , # PATROL Collector
      'PSCRIBE'            : 6163 , # Precision Scribe Cnx Port
      'LM_X'               : 6200 , # LM_X License Manager by X_Formation
      'RADMIND'            : 6222 , # Radmind Access Protocol
      'JEOL_NSDTP_1'       : 6241 , # JEOL Network Services Data Transport Protocol 1
      'JEOL_NSDTP_2'       : 6242 , # JEOL Network Services Data Transport Protocol 2
      'JEOL_NSDTP_3'       : 6243 , # JEOL Network Services Data Transport Protocol 3
      'JEOL_NSDTP_4'       : 6244 , # JEOL Network Services Data Transport Protocol 4
      'TL1_RAW_SSL'        : 6251 , # TL1 Raw Over SSL_TLS
      'TL1_SSH'            : 6252 , # TL1 over SSH
      'CRIP'               : 6253 , # CRIP
      'GLD'                : 6267 , # GridLAB_D User Interface
      'GRID'               : 6268 , # Grid Authentication
      'GRID_ALT'           : 6269 , # Grid Authentication Alt
      'BMC_GRX'            : 6300 , # BMC GRX
      'BMC_CTD_LDAP'       : 6301 , # BMC CONTROL_D LDAP SERVERIANA assigned this well_formed service name as a replacement for "bmc_ctd_ldap".
      'BMC_CTD_LDAP'       : 6301 , # BMC CONTROL_D LDAP SERVER
      'UFMP'               : 6306 , # Unified Fabric Management Protocol
      'SCUP'               : 6315 , # Sensor Control Unit Protocol
      'ABB_ESCP'           : 6316 , # Ethernet Sensor Communications Protocol
      'NAV_DATA_CMD'       : 6317 , # Navtech Radar Sensor Data Command
      'REPSVC'             : 6320 , # Double_Take Replication Service
      'EMP_SERVER1'        : 6321 , # Empress Software Connectivity Server 1
      'EMP_SERVER2'        : 6322 , # Empress Software Connectivity Server 2
      'HRD_NCS'            : 6324 , # HR Device Network Configuration Service
      'DT_MGMTSVC'         : 6325 , # Double_Take Management Service
      'DT_VRA'             : 6326 , # Double_Take Virtual Recovery Assistant
      'SFLOW'              : 6343 , # sFlow traffic monitoring
      'STRELETZ'           : 6344 , # Argus_Spectr security and fire_prevention systems service
      'GNUTELLA_SVC'       : 6346 , # gnutella_svc
      'GNUTELLA_RTR'       : 6347 , # gnutella_rtr
      'ADAP'               : 6350 , # App Discovery and Access Protocol
      'PMCS'               : 6355 , # PMCS applications
      'METAEDIT_MU'        : 6360 , # MetaEdit+ Multi_User
      'METAEDIT_SE'        : 6370 , # MetaEdit+ Server Administration
      'METATUDE_MDS'       : 6382 , # Metatude Dialogue Server
      'CLARIION_EVR01'     : 6389 , # clariion_evr01
      'METAEDIT_WS'        : 6390 , # MetaEdit+ WebService API
      'FAXCOMSERVICE'      : 6417 , # Faxcom Message Service
      'SYSERVERREMOTE'     : 6418 , # SYserver remote commands
      'SVDRP'              : 6419 , # Simple VDR Protocol
      'NIM_VDRSHELL'       : 6420 , # NIM_VDRShell
      'NIM_WAN'            : 6421 , # NIM_WAN
      'PGBOUNCER'          : 6432 , # PgBouncer
      'TARP'               : 6442 , # Transitory Application Request Protocol
      'SUN_SR_HTTPS'       : 6443 , # Service Registry Default HTTPS Domain
      'SGE_QMASTER'        : 6444 , # Grid Engine Qmaster ServiceIANA assigned this well_formed service name as a replacement for "sge_qmaster".
      'SGE_QMASTER'        : 6444 , # Grid Engine Qmaster Service
      'SGE_EXECD'          : 6445 , # Grid Engine Execution ServiceIANA assigned this well_formed service name as a replacement for "sge_execd".
      'SGE_EXECD'          : 6445 , # Grid Engine Execution Service
      'MYSQL_PROXY'        : 6446 , # MySQL Proxy
      'SKIP_CERT_RECV'     : 6455 , # SKIP Certificate Receive
      'SKIP_CERT_SEND'     : 6456 , # SKIP Certificate Send
      'LVISION_LM'         : 6471 , # LVision License Manager
      'SUN_SR_HTTP'        : 6480 , # Service Registry Default HTTP Domain
      'SERVICETAGS'        : 6481 , # Service Tags
      'LDOMS_MGMT'         : 6482 , # Logical Domains Management Interface
      'SUNVTS_RMI'         : 6483 , # SunVTS RMI
      'SUN_SR_JMS'         : 6484 , # Service Registry Default JMS Domain
      'SUN_SR_IIOP'        : 6485 , # Service Registry Default IIOP Domain
      'SUN_SR_IIOPS'       : 6486 , # Service Registry Default IIOPS Domain
      'SUN_SR_IIOP_AUT'    : 6487 , # Service Registry Default IIOPAuth Domain
      'SUN_SR_JMX'         : 6488 , # Service Registry Default JMX Domain
      'SUN_SR_ADMIN'       : 6489 , # Service Registry Default Admin Domain
      'BOKS'               : 6500 , # BoKS Master
      'BOKS_SERVC'         : 6501 , # BoKS ServcIANA assigned this well_formed service name as a replacement for "boks_servc".
      'BOKS_SERVC'         : 6501 , # BoKS Servc
      'BOKS_SERVM'         : 6502 , # BoKS ServmIANA assigned this well_formed service name as a replacement for "boks_servm".
      'BOKS_SERVM'         : 6502 , # BoKS Servm
      'BOKS_CLNTD'         : 6503 , # BoKS ClntdIANA assigned this well_formed service name as a replacement for "boks_clntd".
      'BOKS_CLNTD'         : 6503 , # BoKS Clntd
      'BADM_PRIV'          : 6505 , # BoKS Admin Private PortIANA assigned this well_formed service name as a replacement for "badm_priv".
      'BADM_PRIV'          : 6505 , # BoKS Admin Private Port
      'BADM_PUB'           : 6506 , # BoKS Admin Public PortIANA assigned this well_formed service name as a replacement for "badm_pub".
      'BADM_PUB'           : 6506 , # BoKS Admin Public Port
      'BDIR_PRIV'          : 6507 , # BoKS Dir Server, Private PortIANA assigned this well_formed service name as a replacement for "bdir_priv".
      'BDIR_PRIV'          : 6507 , # BoKS Dir Server, Private Port
      'BDIR_PUB'           : 6508 , # BoKS Dir Server, Public PortIANA assigned this well_formed service name as a replacement for "bdir_pub".
      'BDIR_PUB'           : 6508 , # BoKS Dir Server, Public Port
      'MGCS_MFP_PORT'      : 6509 , # MGCS_MFP Port
      'MCER_PORT'          : 6510 , # MCER Port
      'NETCONF_TLS'        : 6513 , # NETCONF over TLS
      'SYSLOG_TLS'         : 6514 , # Syslog over TLS
      'ELIPSE_REC'         : 6515 , # Elipse RPC Protocol
      'LDS_DISTRIB'        : 6543 , # lds_distrib
      'LDS_DUMP'           : 6544 , # LDS Dump Service
      'APC_6547'           : 6547 , # APC 6547
      'APC_6548'           : 6548 , # APC 6548
      'APC_6549'           : 6549 , # APC 6549
      'FG_SYSUPDATE'       : 6550 , # fg_sysupdate
      'SUM'                : 6551 , # Software Update Manager
      'XDSXDM'             : 6558 , # 
      'SANE_PORT'          : 6566 , # SANE Control Port
      'CANIT_STORE'        : 6568 , # CanIt Storage ManagerIANA assigned this well_formed service name as a replacement for "canit_store".
      'CANIT_STORE'        : 6568 , # CanIt Storage Manager
      'AFFILIATE'          : 6579 , # Affiliate
      'PARSEC_MASTER'      : 6580 , # Parsec Masterserver
      'PARSEC_PEER'        : 6581 , # Parsec Peer_to_Peer
      'PARSEC_GAME'        : 6582 , # Parsec Gameserver
      'JOAJEWELSUITE'      : 6583 , # JOA Jewel Suite
      'MSHVLM'             : 6600 , # Microsoft Hyper_V Live Migration
      'MSTMG_SSTP'         : 6601 , # Microsoft Threat Management Gateway SSTP
      'WSSCOMFRMWK'        : 6602 , # Windows WSS Communication Framework
      'ODETTE_FTPS'        : 6619 , # ODETTE_FTP over TLS_SSL
      'KFTP_DATA'          : 6620 , # Kerberos V5 FTP Data
      'KFTP'               : 6621 , # Kerberos V5 FTP Control
      'MCFTP'              : 6622 , # Multicast FTP
      'KTELNET'            : 6623 , # Kerberos V5 Telnet
      'DATASCALER_DB'      : 6624 , # DataScaler database
      'DATASCALER_CTL'     : 6625 , # DataScaler control
      'WAGO_SERVICE'       : 6626 , # WAGO Service and Update
      'NEXGEN'             : 6627 , # Allied Electronics NeXGen
      'AFESC_MC'           : 6628 , # AFE Stock Channel M_C
      'MXODBC_CONNECT'     : 6632 , # eGenix mxODBC Connect
      'OVSDB'              : 6640 , # Open vSwitch Database protocol
      'OPENFLOW'           : 6653 , # OpenFlow
      'PCS_SF_UI_MAN'      : 6655 , # PC SOFT _ Software factory UI_manager
      'EMGMSG'             : 6656 , # Emergency Message Control Service
      'IRCU'               : 6665 , # 6665_6669 IRCU
      'VOCALTEC_GOLD'      : 6670 , # Vocaltec Global Online Directory
      'P4P_PORTAL'         : 6671 , # P4P Portal Service
      'VISION_SERVER'      : 6672 , # vision_serverIANA assigned this well_formed service name as a replacement for "vision_server".
      'VISION_SERVER'      : 6672 , # vision_server
      'VISION_ELMD'        : 6673 , # vision_elmdIANA assigned this well_formed service name as a replacement for "vision_elmd".
      'VISION_ELMD'        : 6673 , # vision_elmd
      'VFBP'               : 6678 , # Viscount Freedom Bridge Protocol
      'OSAUT'              : 6679 , # Osorno Automation
      'CLEVER_CTRACE'      : 6687 , # CleverView for cTrace Message Service
      'CLEVER_TCPIP'       : 6688 , # CleverView for TCP_IP Message Service
      'TSA'                : 6689 , # Tofino Security Appliance
      'IRCS_U'             : 6697 , # Internet Relay Chat via TLS_SSL 2014_02_11
      'KTI_ICAD_SRVR'      : 6701 , # KTI_ICAD Nameserver
      'E_DESIGN_NET'       : 6702 , # e_Design network
      'E_DESIGN_WEB'       : 6703 , # e_Design web
      'IBPROTOCOL'         : 6714 , # Internet Backplane Protocol
      'FIBOTRADER_COM'     : 6715 , # Fibotrader Communications
      'PRINTERCARE_CC'     : 6716 , # PrinterCare cloud service
      'BMC_PERF_AGENT'     : 6767 , # BMC PERFORM AGENT
      'BMC_PERF_MGRD'      : 6768 , # BMC PERFORM MGRD
      'ADI_GXP_SRVPRT'     : 6769 , # ADInstruments GxP Server
      'PLYSRV_HTTP'        : 6770 , # PolyServe http
      'PLYSRV_HTTPS'       : 6771 , # PolyServe https
      'NTZ_TRACKER'        : 6777 , # netTsunami Tracker
      'NTZ_P2P_STORAGE'    : 6778 , # netTsunami p2p storage system
      'DGPF_EXCHG'         : 6785 , # DGPF Individual Exchange
      'SMC_JMX'            : 6786 , # Sun Java Web Console JMX
      'SMC_ADMIN'          : 6787 , # Sun Web Console Admin
      'SMC_HTTP'           : 6788 , # SMC_HTTP
      'SMC_HTTPS'          : 6789 , # SMC_HTTPS
      'HNMP'               : 6790 , # HNMP
      'HNM'                : 6791 , # Halcyon Network Manager
      'ACNET'              : 6801 , # ACNET Control System Protocol
      'PENTBOX_SIM'        : 6817 , # PenTBox Secure IM Protocol
      'AMBIT_LM'           : 6831 , # ambit_lm
      'NETMO_DEFAULT'      : 6841 , # Netmo Default
      'NETMO_HTTP'         : 6842 , # Netmo HTTP
      'ICCRUSHMORE'        : 6850 , # ICCRUSHMORE
      'ACCTOPUS_CC'        : 6868 , # Acctopus Command Channel
      'MUSE'               : 6888 , # MUSE
      'JETSTREAM'          : 6901 , # Novell Jetstream messaging protocol
      'ETHOSCAN'           : 6935 , # EthoScan Service
      'XSMSVC'             : 6936 , # XenSource Management Service
      'BIOSERVER'          : 6946 , # Biometrics Server
      'OTLP'               : 6951 , # OTLP
      'JMACT3'             : 6961 , # JMACT3
      'JMEVT2'             : 6962 , # jmevt2
      'SWISMGR1'           : 6963 , # swismgr1
      'SWISMGR2'           : 6964 , # swismgr2
      'SWISTRAP'           : 6965 , # swistrap
      'SWISPOL'            : 6966 , # swispol
      'ACMSODA'            : 6969 , # acmsoda
      'MOBILITYSRV'        : 6997 , # Mobility XE Protocol
      'IATP_HIGHPRI'       : 6998 , # IATP_highPri
      'IATP_NORMALPRI'     : 6999 , # IATP_normalPri
      'AFS3_FILESERVER'    : 7000 , # file server itself
      'AFS3_CALLBACK'      : 7001 , # callbacks to cache managers Known Unauthorized Use on port 7001
      'AFS3_PRSERVER'      : 7002 , # users & groups database Known Unauthorized Use on port 7002
      'AFS3_VLSERVER'      : 7003 , # volume location database
      'AFS3_KASERVER'      : 7004 , # AFS_Kerberos authentication service
      'AFS3_VOLSER'        : 7005 , # volume managment server Known Unauthorized Use on port 7005
      'AFS3_ERRORS'        : 7006 , # error interpretation service
      'AFS3_BOS'           : 7007 , # basic overseer process
      'AFS3_UPDATE'        : 7008 , # server_to_server updater
      'AFS3_RMTSYS'        : 7009 , # remote cache manager service
      'UPS_ONLINET'        : 7010 , # onlinet uninterruptable power supplies
      'TALON_DISC'         : 7011 , # Talon Discovery Port
      'TALON_ENGINE'       : 7012 , # Talon Engine
      'MICROTALON_DIS'     : 7013 , # Microtalon Discovery
      'MICROTALON_COM'     : 7014 , # Microtalon Communications
      'TALON_WEBSERVER'    : 7015 , # Talon Webserver
      'FISA_SVC'           : 7018 , # FISA Service
      'DOCERI_CTL'         : 7019 , # doceri drawing service control
      'DPSERVE'            : 7020 , # DP Serve
      'DPSERVEADMIN'       : 7021 , # DP Serve Admin
      'CTDP'               : 7022 , # CT Discovery Protocol
      'CT2NMCS'            : 7023 , # Comtech T2 NMCS
      'VMSVC'              : 7024 , # Vormetric service
      'VMSVC_2'            : 7025 , # Vormetric Service II
      'OP_PROBE'           : 7030 , # ObjectPlanet probe
      'IPOSPLANET'         : 7031 , # IPOSPLANET retailing multi devices protocol
      'ARCP'               : 7070 , # ARCP
      'IWG1'               : 7071 , # IWGADTS Aircraft Housekeeping Message
      'MARTALK'            : 7073 , # MarTalk protocol
      'EMPOWERID'          : 7080 , # EmpowerID Communication
      'LAZY_PTOP'          : 7099 , # lazy_ptop
      'FONT_SERVICE'       : 7100 , # X Font Service
      'ELCN'               : 7101 , # Embedded Light Control Network
      'VIRPROT_LM'         : 7121 , # Virtual Prototypes License Manager
      'SCENIDM'            : 7128 , # intelligent data manager
      'SCENCCS'            : 7129 , # Catalog Content Search
      'CABSM_COMM'         : 7161 , # CA BSM Comm
      'CAISTORAGEMGR'      : 7162 , # CA Storage Manager
      'CACSAMBROKER'       : 7163 , # CA Connection Broker
      'FSR'                : 7164 , # File System Repository Agent
      'DOC_SERVER'         : 7165 , # Document WCF Server
      'ARUBA_SERVER'       : 7166 , # Aruba eDiscovery Server
      'CASRMAGENT'         : 7167 , # CA SRM Agent
      'CNCKADSERVER'       : 7168 , # cncKadServer DB & Inventory Services
      'CCAG_PIB'           : 7169 , # Consequor Consulting Process Integration Bridge
      'NSRP'               : 7170 , # Adaptive Name_Service Resolution
      'DRM_PRODUCTION'     : 7171 , # Discovery and Retention Mgt Production
      'METALBEND'          : 7172 , # Port used for MetalBend programmable interface
      'ZSECURE'            : 7173 , # zSecure Server
      'CLUTILD'            : 7174 , # Clutild
      'FODMS'              : 7200 , # FODMS FLIP
      'DLIP'               : 7201 , # DLIP
      'RAMP'               : 7227 , # Registry A & M Protocol
      'CITRIXUPP'          : 7228 , # Citrix Universal Printing Port
      'CITRIXUPPG'         : 7229 , # Citrix UPP Gateway
      'DISPLAY'            : 7236 , # Wi_Fi Alliance Wi_Fi Display Protocol
      'PADS'               : 7237 , # PADS (Public Area Display System) Server
      'CNAP'               : 7262 , # Calypso Network Access Protocol
      'WATCHME_7272'       : 7272 , # WatchMe Monitoring 7272
      'OMA_RLP'            : 7273 , # OMA Roaming Location
      'OMA_RLP_S'          : 7274 , # OMA Roaming Location SEC
      'OMA_ULP'            : 7275 , # OMA UserPlane Location
      'OMA_ILP'            : 7276 , # OMA Internal Location Protocol
      'OMA_ILP_S'          : 7277 , # OMA Internal Location Secure Protocol
      'OMA_DCDOCBS'        : 7278 , # OMA Dynamic Content Delivery over CBS
      'CTXLIC'             : 7279 , # Citrix Licensing
      'ITACTIONSERVER1'    : 7280 , # ITACTIONSERVER 1
      'ITACTIONSERVER2'    : 7281 , # ITACTIONSERVER 2
      'MZCA_ACTION'        : 7282 , # eventACTION_ussACTION (MZCA) server
      'GENSTAT'            : 7283 , # General Statistics Rendezvous Protocol
      'LCM_SERVER'         : 7365 , # LifeKeeper Communications
      'MINDFILESYS'        : 7391 , # mind_file system server
      'MRSSRENDEZVOUS'     : 7392 , # mrss_rendezvous server
      'NFOLDMAN'           : 7393 , # nFoldMan Remote Publish
      'FSE'                : 7394 , # File system export of backup images
      'WINQEDIT'           : 7395 , # winqedit
      'HEXARC'             : 7397 , # Hexarc Command Language
      'RTPS_DISCOVERY'     : 7400 , # RTPS Discovery
      'RTPS_DD_UT'         : 7401 , # RTPS Data_Distribution User_Traffic
      'RTPS_DD_MT'         : 7402 , # RTPS Data_Distribution Meta_Traffic
      'IONIXNETMON'        : 7410 , # Ionix Network Monitor
      'DAQSTREAM'          : 7411 , # Streaming of measurement data
      'MTPORTMON'          : 7421 , # Matisse Port Monitor
      'PMDMGR'             : 7426 , # OpenView DM Postmaster Manager
      'OVEADMGR'           : 7427 , # OpenView DM Event Agent Manager
      'OVLADMGR'           : 7428 , # OpenView DM Log Agent Manager
      'OPI_SOCK'           : 7429 , # OpenView DM rqt communication
      'XMPV7'              : 7430 , # OpenView DM xmpv7 api pipe
      'PMD'                : 7431 , # OpenView DM ovc_xmpv3 api pipe
      'FAXIMUM'            : 7437 , # Faximum
      'ORACLEAS_HTTPS'     : 7443 , # Oracle Application Server HTTPS
      'STTUNNEL'           : 7471 , # Stateless Transport Tunneling Protocol
      'RISE'               : 7473 , # Rise: The Vieneo Province
      'NEO4J'              : 7474 , # Neo4j Graph Database
      'TELOPS_LMD'         : 7491 , # telops_lmd
      'SILHOUETTE'         : 7500 , # Silhouette User
      'OVBUS'              : 7501 , # HP OpenView Bus Daemon
      'ADCP'               : 7508 , # Automation Device Configuration Protocol
      'ACPLT'              : 7509 , # ACPLT _ process automation service
      'OVHPAS'             : 7510 , # HP OpenView Application Server
      'PAFEC_LM'           : 7511 , # pafec_lm
      'SARATOGA'           : 7542 , # Saratoga Transfer Protocol
      'ATUL'               : 7543 , # atul server
      'NTA_DS'             : 7544 , # FlowAnalyzer DisplayServer
      'NTA_US'             : 7545 , # FlowAnalyzer UtilityServer
      'CFS'                : 7546 , # Cisco Fabric service
      'CWMP'               : 7547 , # DSL Forum CWMP
      'TIDP'               : 7548 , # Threat Information Distribution Protocol
      'NLS_TL'             : 7549 , # Network Layer Signaling Transport Layer
      'SNCP'               : 7560 , # Sniffer Command Protocol
      'CFW'                : 7563 , # Control Framework
      'VSI_OMEGA'          : 7566 , # VSI Omega
      'DELL_EQL_ASM'       : 7569 , # Dell EqualLogic Host Group Management
      'ARIES_KFINDER'      : 7570 , # Aries Kfinder
      'COHERENCE'          : 7574 , # Oracle Coherence Cluster Service
      'SUN_LM'             : 7588 , # Sun License Manager
      'INDI'               : 7624 , # Instrument Neutral Distributed Interface
      'SIMCO'              : 7626 , # SImple Middlebox COnfiguration (SIMCO) Server
      'SOAP_HTTP'          : 7627 , # SOAP Service Port
      'ZEN_PAWN'           : 7628 , # Primary Agent Work Notification
      'XDAS'               : 7629 , # OpenXDAS Wire Protocol
      'HAWK'               : 7630 , # HA Web Konsole
      'TESLA_SYS_MSG'      : 7631 , # TESLA System Messaging
      'PMDFMGT'            : 7633 , # PMDF Management
      'CUSEEME'            : 7648 , # bonjour_cuseeme
      'IMQSTOMP'           : 7672 , # iMQ STOMP Server
      'IMQSTOMPS'          : 7673 , # iMQ STOMP Server over SSL
      'IMQTUNNELS'         : 7674 , # iMQ SSL tunnel
      'IMQTUNNEL'          : 7675 , # iMQ Tunnel
      'IMQBROKERD'         : 7676 , # iMQ Broker Rendezvous
      'SUN_USER_HTTPS'     : 7677 , # Sun App Server _ HTTPS
      'PANDO_PUB'          : 7680 , # Pando Media Public Distribution
      'COLLABER'           : 7689 , # Collaber Network Service
      'KLIO'               : 7697 , # KLIO communications
      'EM7_SECOM'          : 7700 , # EM7 Secure Communications
      'SYNC_EM7'           : 7707 , # EM7 Dynamic Updates
      'SCINET'             : 7708 , # scientia.net
      'MEDIMAGEPORTAL'     : 7720 , # MedImage Portal
      'NSDEEPFREEZECTL'    : 7724 , # Novell Snap_in Deep Freeze Control
      'NITROGEN'           : 7725 , # Nitrogen Service
      'FREEZEXSERVICE'     : 7726 , # FreezeX Console Service
      'TRIDENT_DATA'       : 7727 , # Trident Systems Data
      'SMIP'               : 7734 , # Smith Protocol over IP
      'AIAGENT'            : 7738 , # HP Enterprise Discovery Agent
      'SCRIPTVIEW'         : 7741 , # ScriptView Network
      'MSSS'               : 7742 , # Mugginsoft Script Server Service
      'SSTP_1'             : 7743 , # Sakura Script Transfer Protocol
      'RAQMON_PDU'         : 7744 , # RAQMON PDU
      'PRGP'               : 7747 , # Put_Run_Get Protocol
      'CBT'                : 7777 , # cbt
      'INTERWISE'          : 7778 , # Interwise
      'VSTAT'              : 7779 , # VSTAT
      'ACCU_LMGR'          : 7781 , # accu_lmgr
      'MINIVEND'           : 7786 , # MINIVEND
      'POPUP_REMINDERS'    : 7787 , # Popup Reminders Receive
      'OFFICE_TOOLS'       : 7789 , # Office Tools Pro Receive
      'Q3ADE'              : 7794 , # Q3ADE Cluster Service
      'PNET_CONN'          : 7797 , # Propel Connector port
      'PNET_ENC'           : 7798 , # Propel Encoder port
      'ALTBSDP'            : 7799 , # Alternate BSDP Service
      'ASR'                : 7800 , # Apple Software Restore
      'SSP_CLIENT'         : 7801 , # Secure Server Protocol _ client
      'RBT_WANOPT'         : 7810 , # Riverbed WAN Optimization Protocol
      'APC_7845'           : 7845 , # APC 7845
      'APC_7846'           : 7846 , # APC 7846
      'CSOAUTH'            : 7847 , # A product key authentication protocol made by CSO
      'MOBILEANALYZER'     : 7869 , # MobileAnalyzer& MobileMonitor
      'RBT_SMC'            : 7870 , # Riverbed Steelhead Mobile Service
      'MDM'                : 7871 , # Mobile Device Management
      'OWMS'               : 7878 , # Opswise Message Service
      'PSS'                : 7880 , # Pearson
      'UBROKER'            : 7887 , # Universal Broker
      'MEVENT'             : 7900 , # Multicast Event
      'TNOS_SP'            : 7901 , # TNOS Service Protocol
      'TNOS_DP'            : 7902 , # TNOS shell Protocol
      'TNOS_DPS'           : 7903 , # TNOS Secure DiaguardProtocol
      'QO_SECURE'          : 7913 , # QuickObjects secure port
      'T2_DRM'             : 7932 , # Tier 2 Data Resource Manager
      'T2_BRM'             : 7933 , # Tier 2 Business Rules Manager
      'GENERALSYNC'        : 7962 , # Encrypted, extendable, general_purpose synchronization protocol
      'SUPERCELL'          : 7967 , # Supercell
      'MICROMUSE_NCPS'     : 7979 , # Micromuse_ncps
      'QUEST_VISTA'        : 7980 , # Quest Vista
      'SOSSD_COLLECT'      : 7981 , # Spotlight on SQL Server Desktop Collect
      'SOSSD_AGENT'        : 7982 , # Spotlight on SQL Server Desktop Agent
      'PUSHNS'             : 7997 , # PUSH Notification Service
      'IRDMI2'             : 7999 , # iRDMI2
      'IRDMI'              : 8000 , # iRDMI
      'VCOM_TUNNEL'        : 8001 , # VCOM Tunnel
      'TERADATAORDBMS'     : 8002 , # Teradata ORDBMS
      'MCREPORT'           : 8003 , # Mulberry Connect Reporting Service
      'MXI'                : 8005 , # MXI Generation II for z_OS
      'HTTP_ALT'           : 8008 , # HTTP Alternate
      'QBDB'               : 8019 , # QB DB Dynamic Port
      'INTU_EC_SVCDISC'    : 8020 , # Intuit Entitlement Service and Discovery
      'INTU_EC_CLIENT'     : 8021 , # Intuit Entitlement Client
      'OA_SYSTEM'          : 8022 , # oa_system
      'CA_AUDIT_DA'        : 8025 , # CA Audit Distribution Agent
      'CA_AUDIT_DS'        : 8026 , # CA Audit Distribution Server
      'PRO_ED'             : 8032 , # ProEd
      'MINDPRINT'          : 8033 , # MindPrint
      'VANTRONIX_MGMT'     : 8034 , # .vantronix Management
      'AMPIFY'             : 8040 , # Ampify Messaging Protocol
      'FS_AGENT'           : 8042 , # FireScope Agent
      'FS_SERVER'          : 8043 , # FireScope Server
      'FS_MGMT'            : 8044 , # FireScope Management Interface
      'ROCRAIL'            : 8051 , # Rocrail Client Service
      'SENOMIX01'          : 8052 , # Senomix Timesheets Server
      'SENOMIX02'          : 8053 , # Senomix Timesheets Client
      'SENOMIX03'          : 8054 , # Senomix Timesheets Server
      'SENOMIX04'          : 8055 , # Senomix Timesheets Server
      'SENOMIX05'          : 8056 , # Senomix Timesheets Server
      'SENOMIX06'          : 8057 , # Senomix Timesheets Client
      'SENOMIX07'          : 8058 , # Senomix Timesheets Client
      'SENOMIX08'          : 8059 , # Senomix Timesheets Client
      'TOAD_BI_APPSRVR'    : 8066 , # Toad BI Application Server
      'GADUGADU'           : 8074 , # Gadu_Gadu
      'HTTP_ALT'           : 8080 , # HTTP Alternate (see port 80)
      'SUNPROXYADMIN'      : 8081 , # Sun Proxy Admin Service
      'US_CLI'             : 8082 , # Utilistor (Client)
      'US_SRV'             : 8083 , # Utilistor (Server)
      'D_S_N'              : 8086 , # Distributed SCADA Networking Rendezvous Port
      'SIMPLIFYMEDIA'      : 8087 , # Simplify Media SPP Protocol
      'RADAN_HTTP'         : 8088 , # Radan HTTP
      'JAMLINK'            : 8091 , # Jam Link Framework
      'SAC'                : 8097 , # SAC Port Id
      'XPRINT_SERVER'      : 8100 , # Xprint Server
      'LDOMS_MIGR'         : 8101 , # Logical Domains Migration
      'KZ_MIGR'            : 8102 , # Oracle Kernel zones migration server
      'MTL8000_MATRIX'     : 8115 , # MTL8000 Matrix
      'CP_CLUSTER'         : 8116 , # Check Point Clustering
      'PURITYRPC'          : 8117 , # Purity replication clustering and remote management
      'PRIVOXY'            : 8118 , # Privoxy HTTP proxy
      'APOLLO_DATA'        : 8121 , # Apollo Data Port
      'APOLLO_ADMIN'       : 8122 , # Apollo Admin Port
      'PAYCASH_ONLINE'     : 8128 , # PayCash Online Protocol
      'PAYCASH_WBP'        : 8129 , # PayCash Wallet_Browser
      'INDIGO_VRMI'        : 8130 , # INDIGO_VRMI
      'INDIGO_VBCP'        : 8131 , # INDIGO_VBCP
      'DBABBLE'            : 8132 , # dbabble
      'ISDD'               : 8148 , # i_SDD file transfer
      'QUANTASTOR'         : 8153 , # QuantaStor Management Interface
      'PATROL'             : 8160 , # Patrol
      'PATROL_SNMP'        : 8161 , # Patrol SNMP
      'LPAR2RRD'           : 8162 , # LPAR2RRD client server communication
      'INTERMAPPER'        : 8181 , # Intermapper network management system
      'VMWARE_FDM'         : 8182 , # VMware Fault Domain Manager
      'PROREMOTE'          : 8183 , # ProRemote
      'ITACH'              : 8184 , # Remote iTach Connection
      'LIMNERPRESSURE'     : 8191 , # Limner Pressure
      'SPYTECHPHONE'       : 8192 , # SpyTech Phone Service
      'BLP1'               : 8194 , # Bloomberg data API
      'BLP2'               : 8195 , # Bloomberg feed
      'VVR_DATA'           : 8199 , # VVR DATA
      'TRIVNET1'           : 8200 , # TRIVNET
      'TRIVNET2'           : 8201 , # TRIVNET
      'LM_PERFWORKS'       : 8204 , # LM Perfworks
      'LM_INSTMGR'         : 8205 , # LM Instmgr
      'LM_DTA'             : 8206 , # LM Dta
      'LM_SSERVER'         : 8207 , # LM SServer
      'LM_WEBWATCHER'      : 8208 , # LM Webwatcher
      'REXECJ'             : 8230 , # RexecJ Server
      'SYNAPSE_NHTTPS'     : 8243 , # Synapse Non Blocking HTTPS
      'PANDO_SEC'          : 8276 , # Pando Media Controlled Distribution
      'SYNAPSE_NHTTP'      : 8280 , # Synapse Non Blocking HTTP
      'BLP3'               : 8292 , # Bloomberg professional
      'HIPERSCAN_ID'       : 8293 , # Hiperscan Identification Service
      'BLP4'               : 8294 , # Bloomberg intelligent client
      'TMI'                : 8300 , # Transport Management Interface
      'AMBERON'            : 8301 , # Amberon PPC_PPS
      'HUB_OPEN_NET'       : 8313 , # Hub Open Network
      'TNP_DISCOVER'       : 8320 , # Thin(ium) Network Protocol
      'TNP'                : 8321 , # Thin(ium) Network Protocol
      'SERVER_FIND'        : 8351 , # Server Find
      'CRUISE_ENUM'        : 8376 , # Cruise ENUM
      'CRUISE_SWROUTE'     : 8377 , # Cruise SWROUTE
      'CRUISE_CONFIG'      : 8378 , # Cruise CONFIG
      'CRUISE_DIAGS'       : 8379 , # Cruise DIAGS
      'CRUISE_UPDATE'      : 8380 , # Cruise UPDATE
      'M2MSERVICES'        : 8383 , # M2m Services
      'CVD'                : 8400 , # cvd
      'SABARSD'            : 8401 , # sabarsd
      'ABARSD'             : 8402 , # abarsd
      'ADMIND'             : 8403 , # admind
      'SVCLOUD'            : 8404 , # SuperVault Cloud
      'SVBACKUP'           : 8405 , # SuperVault Backup
      'DLPX_SP'            : 8415 , # Delphix Session Protocol
      'ESPEECH'            : 8416 , # eSpeech Session Protocol
      'ESPEECH_RTP'        : 8417 , # eSpeech RTP Protocol
      'CYBRO_A_BUS'        : 8442 , # CyBro A_bus Protocol
      'PCSYNC_HTTPS'       : 8443 , # PCsync HTTPS
      'PCSYNC_HTTP'        : 8444 , # PCsync HTTP
      'COPY'               : 8445 , # Port for copy peer sync feature
      'NPMP'               : 8450 , # npmp
      'NEXENTAMV'          : 8457 , # Nexenta Management GUI
      'CISCO_AVP'          : 8470 , # Cisco Address Validation Protocol
      'PIM_PORT'           : 8471 , # PIM over Reliable Transport
      'OTV'                : 8472 , # Overlay Transport Virtualization (OTV)
      'VP2P'               : 8473 , # Virtual Point to Point
      'NOTESHARE'          : 8474 , # AquaMinds NoteShare
      'FMTP'               : 8500 , # Flight Message Transfer Protocol
      'CMTP_MGT'           : 8501 , # CYTEL Message Transfer Management
      'FTNMTP'             : 8502 , # FTN Message Transfer Protocol
      'RTSP_ALT'           : 8554 , # RTSP Alternate (see port 554)
      'D_FENCE'            : 8555 , # SYMAX D_FENCE
      'ENC_TUNNEL'         : 8567 , # EMIT tunneling protocol
      'ASTERIX'            : 8600 , # Surveillance Data
      'CANON_MFNP'         : 8610 , # Canon MFNP Service
      'CANON_BJNP1'        : 8611 , # Canon BJNP Port 1
      'CANON_BJNP2'        : 8612 , # Canon BJNP Port 2
      'CANON_BJNP3'        : 8613 , # Canon BJNP Port 3
      'CANON_BJNP4'        : 8614 , # Canon BJNP Port 4
      'IMINK'              : 8615 , # Imink Service Control
      'MONETRA'            : 8665 , # Monetra
      'MONETRA_ADMIN'      : 8666 , # Monetra Administrative Access
      'MSI_CPS_RM'         : 8675 , # Motorola Solutions Customer Programming Software for Radio Management
      'SUN_AS_JMXRMI'      : 8686 , # Sun App Server _ JMX_RMI
      'OPENREMOTE_CTRL'    : 8688 , # OpenRemote Controller HTTP_REST
      'VNYX'               : 8699 , # VNYX Primary Port
      'NVC'                : 8711 , # Nuance Voice Control
      'IBUS'               : 8733 , # iBus
      'DEY_KEYNEG'         : 8750 , # DEY Storage Key Negotiation
      'MC_APPSERVER'       : 8763 , # MC_APPSERVER
      'OPENQUEUE'          : 8764 , # OPENQUEUE
      'ULTRASEEK_HTTP'     : 8765 , # Ultraseek HTTP
      'AMCS'               : 8766 , # Agilent Connectivity Service
      'DPAP'               : 8770 , # Digital Photo Access Protocol (iPhoto)
      'UEC'                : 8778 , # Stonebranch Universal Enterprise Controller
      'MSGCLNT'            : 8786 , # Message Client
      'MSGSRVR'            : 8787 , # Message Server
      'ACD_PM'             : 8793 , # Accedian Performance Measurement
      'SUNWEBADMIN'        : 8800 , # Sun Web Server Admin Service
      'TRUECM'             : 8804 , # truecm
      'DXSPIDER'           : 8873 , # dxspider linking protocol
      'CDDBP_ALT'          : 8880 , # CDDBP
      'GALAXY4D'           : 8881 , # Galaxy4D Online Game Engine
      'SECURE_MQTT'        : 8883 , # Secure MQTT
      'DDI_TCP_1'          : 8888 , # NewsEDGE server TCP (TCP 1)
      'DDI_TCP_2'          : 8889 , # Desktop Data TCP 1
      'DDI_TCP_3'          : 8890 , # Desktop Data TCP 2
      'DDI_TCP_4'          : 8891 , # Desktop Data TCP 3: NESS application
      'DDI_TCP_5'          : 8892 , # Desktop Data TCP 4: FARM product
      'DDI_TCP_6'          : 8893 , # Desktop Data TCP 5: NewsEDGE_Web application
      'DDI_TCP_7'          : 8894 , # Desktop Data TCP 6: COAL application
      'OSPF_LITE'          : 8899 , # ospf_lite
      'JMB_CDS1'           : 8900 , # JMB_CDS 1
      'JMB_CDS2'           : 8901 , # JMB_CDS 2
      'MANYONE_HTTP'       : 8910 , # manyone_http
      'MANYONE_XML'        : 8911 , # manyone_xml
      'WCBACKUP'           : 8912 , # Windows Client Backup
      'DRAGONFLY'          : 8913 , # Dragonfly System Service
      'TWDS'               : 8937 , # Transaction Warehouse Data Service
      'UB_DNS_CONTROL'     : 8953 , # unbound dns nameserver control
      'CUMULUS_ADMIN'      : 8954 , # Cumulus Admin Port
      'SUNWEBADMINS'       : 8989 , # Sun Web Server SSL Admin Service
      'HTTP_WMAP'          : 8990 , # webmail HTTP service
      'HTTPS_WMAP'         : 8991 , # webmail HTTPS service
      'CANTO_ROBOFLOW'     : 8998 , # Canto RoboFlow Control
      'BCTP'               : 8999 , # Brodos Crypto Trade Protocol
      'CSLISTENER'         : 9000 , # CSlistener
      'ETLSERVICEMGR'      : 9001 , # ETL Service Manager
      'DYNAMID'            : 9002 , # DynamID authentication
      'OGS_SERVER'         : 9008 , # Open Grid Services Server
      'PICHAT'             : 9009 , # Pichat Server
      'SDR'                : 9010 , # Secure Data Replicator Protocol
      'TAMBORA'            : 9020 , # TAMBORA
      'PANAGOLIN_IDENT'    : 9021 , # Pangolin Identification
      'PARAGENT'           : 9022 , # PrivateArk Remote Agent
      'SWA_1'              : 9023 , # Secure Web Access _ 1
      'SWA_2'              : 9024 , # Secure Web Access _ 2
      'SWA_3'              : 9025 , # Secure Web Access _ 3
      'SWA_4'              : 9026 , # Secure Web Access _ 4
      'VERSIERA'           : 9050 , # Versiera Agent Listener
      'FIO_CMGMT'          : 9051 , # Fusion_io Central Manager Service
      'GLRPC'              : 9080 , # Groove GLRPC
      'EMC_PP_MGMTSVC'     : 9083 , # EMC PowerPath Mgmt Service
      'AURORA'             : 9084 , # IBM AURORA Performance Visualizer
      'IBM_RSYSCON'        : 9085 , # IBM Remote System Console
      'NET2DISPLAY'        : 9086 , # Vesa Net2Display
      'CLASSIC'            : 9087 , # Classic Data Server
      'SQLEXEC'            : 9088 , # IBM Informix SQL Interface
      'SQLEXEC_SSL'        : 9089 , # IBM Informix SQL Interface _ Encrypted
      'WEBSM'              : 9090 , # WebSM
      'XMLTEC_XMLMAIL'     : 9091 , # xmltec_xmlmail
      'XMLIPCREGSVC'       : 9092 , # Xml_Ipc Server Reg
      'COPYCAT'            : 9093 , # Copycat database replication service
      'HP_PDL_DATASTR'     : 9100 , # PDL Data Streaming Port
      'PDL_DATASTREAM'     : 9100 , # Printer PDL Data Stream
      'BACULA_DIR'         : 9101 , # Bacula Director
      'BACULA_FD'          : 9102 , # Bacula File Daemon
      'BACULA_SD'          : 9103 , # Bacula Storage Daemon
      'PEERWIRE'           : 9104 , # PeerWire
      'XADMIN'             : 9105 , # Xadmin Control Service
      'ASTERGATE'          : 9106 , # Astergate Control Service
      'ASTERGATEFAX'       : 9107 , # AstergateFax Control Service
      'MXIT'               : 9119 , # MXit Instant Messaging
      'GRCMP'              : 9122 , # Global Relay compliant mobile instant messaging protocol
      'GRCP'               : 9123 , # Global Relay compliant instant messaging protocol
      'DDDP'               : 9131 , # Dynamic Device Discovery
      'APANI1'             : 9160 , # apani1
      'APANI2'             : 9161 , # apani2
      'APANI3'             : 9162 , # apani3
      'APANI4'             : 9163 , # apani4
      'APANI5'             : 9164 , # apani5
      'SUN_AS_JPDA'        : 9191 , # Sun AppSvr JPDA
      'WAP_WSP'            : 9200 , # WAP connectionless session service
      'WAP_WSP_WTP'        : 9201 , # WAP session service
      'WAP_WSP_S'          : 9202 , # WAP secure connectionless session service
      'WAP_WSP_WTP_S'      : 9203 , # WAP secure session service
      'WAP_VCARD'          : 9204 , # WAP vCard
      'WAP_VCAL'           : 9205 , # WAP vCal
      'WAP_VCARD_S'        : 9206 , # WAP vCard Secure
      'WAP_VCAL_S'         : 9207 , # WAP vCal Secure
      'RJCDB_VCARDS'       : 9208 , # rjcdb vCard
      'ALMOBILE_SYSTEM'    : 9209 , # ALMobile System Service
      'OMA_MLP'            : 9210 , # OMA Mobile Location Protocol
      'OMA_MLP_S'          : 9211 , # OMA Mobile Location Protocol Secure
      'SERVERVIEWDBMS'     : 9212 , # Server View dbms access
      'SERVERSTART'        : 9213 , # ServerStart RemoteControl
      'IPDCESGBS'          : 9214 , # IPDC ESG BootstrapService
      'INSIS'              : 9215 , # Integrated Setup and Install Service
      'ACME'               : 9216 , # Aionex Communication Management Engine
      'FSC_PORT'           : 9217 , # FSC Communication Port
      'TEAMCOHERENCE'      : 9222 , # QSC Team Coherence
      'MON'                : 9255 , # Manager On Network
      'PEGASUS'            : 9278 , # Pegasus GPS Platform
      'PEGASUS_CTL'        : 9279 , # Pegaus GPS System Control Interface
      'PGPS'               : 9280 , # Predicted GPS
      'SWTP_PORT1'         : 9281 , # SofaWare transport port 1
      'SWTP_PORT2'         : 9282 , # SofaWare transport port 2
      'CALLWAVEIAM'        : 9283 , # CallWaveIAM
      'VISD'               : 9284 , # VERITAS Information Serve
      'N2H2SERVER'         : 9285 , # N2H2 Filter Service Port
      'CUMULUS'            : 9287 , # Cumulus
      'ARMTECHDAEMON'      : 9292 , # ArmTech Daemon
      'STORVIEW'           : 9293 , # StorView Client
      'ARMCENTERHTTP'      : 9294 , # ARMCenter http Service
      'ARMCENTERHTTPS'     : 9295 , # ARMCenter https Service
      'VRACE'              : 9300 , # Virtual Racing Service
      'SPHINXQL'           : 9306 , # Sphinx search server (MySQL listener)
      'SPHINXAPI'          : 9312 , # Sphinx search server
      'SECURE_TS'          : 9318 , # PKIX TimeStamp over TLS
      'GUIBASE'            : 9321 , # guibase
      'MPIDCMGR'           : 9343 , # MpIdcMgr
      'MPHLPDMC'           : 9344 , # Mphlpdmc
      'CTECHLICENSING'     : 9346 , # C Tech Licensing
      'FJDMIMGR'           : 9374 , # fjdmimgr
      'BOXP'               : 9380 , # Brivs! Open Extensible Protocol
      'D2DCONFIG'          : 9387 , # D2D Configuration Service
      'D2DDATATRANS'       : 9388 , # D2D Data Transfer Service
      'ADWS'               : 9389 , # Active Directory Web Services
      'OTP'                : 9390 , # OpenVAS Transfer Protocol
      'FJINVMGR'           : 9396 , # fjinvmgr
      'MPIDCAGT'           : 9397 , # MpIdcAgt
      'SEC_T4NET_SRV'      : 9400 , # Samsung Twain for Network Server
      'SEC_T4NET_CLT'      : 9401 , # Samsung Twain for Network Client
      'SEC_PC2FAX_SRV'     : 9402 , # Samsung PC2FAX for Network Server
      'GIT'                : 9418 , # git pack transfer service
      'TUNGSTEN_HTTPS'     : 9443 , # WSO2 Tungsten HTTPS
      'WSO2ESB_CONSOLE'    : 9444 , # WSO2 ESB Administration Console HTTPS
      'MINDARRAY_CA'       : 9445 , # MindArray Systems Console Agent
      'SNTLKEYSSRVR'       : 9450 , # Sentinel Keys Server
      'ISMSERVER'          : 9500 , # ismserver
      'MNGSUITE'           : 9535 , # Management Suite Remote Control
      'LAES_BF'            : 9536 , # Surveillance buffering function
      'TRISPEN_SRA'        : 9555 , # Trispen Secure Remote Access
      'LDGATEWAY'          : 9592 , # LANDesk Gateway
      'CBA8'               : 9593 , # LANDesk Management Agent (cba8)
      'MSGSYS'             : 9594 , # Message System
      'PDS'                : 9595 , # Ping Discovery Service
      'MERCURY_DISC'       : 9596 , # Mercury Discovery
      'PD_ADMIN'           : 9597 , # PD Administration
      'VSCP'               : 9598 , # Very Simple Ctrl Protocol
      'ROBIX'              : 9599 , # Robix
      'MICROMUSE_NCPW'     : 9600 , # MICROMUSE_NCPW
      'STREAMCOMM_DS'      : 9612 , # StreamComm User Directory
      'IADT_TLS'           : 9614 , # iADT Protocol over TLS
      'ERUNBOOK_AGENT'     : 9616 , # eRunbook AgentIANA assigned this well_formed service name as a replacement for "erunbook_agent".
      'ERUNBOOK_AGENT'     : 9616 , # eRunbook Agent
      'ERUNBOOK_SERVER'    : 9617 , # eRunbook ServerIANA assigned this well_formed service name as a replacement for "erunbook_server".
      'ERUNBOOK_SERVER'    : 9617 , # eRunbook Server
      'CONDOR'             : 9618 , # Condor Collector Service
      'ODBCPATHWAY'        : 9628 , # ODBC Pathway Service
      'UNIPORT'            : 9629 , # UniPort SSO Controller
      'PEOCTLR'            : 9630 , # Peovica Controller
      'PEOCOLL'            : 9631 , # Peovica Collector
      'PQSFLOWS'           : 9640 , # ProQueSys Flows Service
      'ZOOMCP'             : 9666 , # Zoom Control Panel Game Server Management
      'XMMS2'              : 9667 , # Cross_platform Music Multiplexing System
      'TEC5_SDCTP'         : 9668 , # tec5 Spectral Device Control Protocol
      'CLIENT_WAKEUP'      : 9694 , # T_Mobile Client Wakeup Message
      'CCNX'               : 9695 , # Content Centric Networking
      'BOARD_ROAR'         : 9700 , # Board M.I.T. Service
      'L5NAS_PARCHAN'      : 9747 , # L5NAS Parallel Channel
      'BOARD_VOIP'         : 9750 , # Board M.I.T. Synchronous Collaboration
      'RASADV'             : 9753 , # rasadv
      'TUNGSTEN_HTTP'      : 9762 , # WSO2 Tungsten HTTP
      'DAVSRC'             : 9800 , # WebDav Source Port
      'SSTP_2'             : 9801 , # Sakura Script Transfer Protocol_2
      'DAVSRCS'            : 9802 , # WebDAV Source TLS_SSL
      'SAPV1'              : 9875 , # Session Announcement v1
      'SD'                 : 9876 , # Session Director
      'CYBORG_SYSTEMS'     : 9888 , # CYBORG Systems
      'GT_PROXY'           : 9889 , # Port for Cable network related data proxy or repeater
      'MONKEYCOM'          : 9898 , # MonkeyCom
      'IUA'                : 9900 , # IUA
      'DOMAINTIME'         : 9909 , # domaintime
      'SYPE_TRANSPORT'     : 9911 , # SYPECom Transport Protocol
      'XYBRID_CLOUD'       : 9925 , # XYBRID Cloud
      'APC_9950'           : 9950 , # APC 9950
      'APC_9951'           : 9951 , # APC 9951
      'APC_9952'           : 9952 , # APC 9952
      'ACIS'               : 9953 , # 9953
      'HINP'               : 9954 , # HaloteC Instrument Network Protocol
      'ALLJOYN_STM'        : 9955 , # Contact Port for AllJoyn standard messaging
      'ODNSP'              : 9966 , # OKI Data Network Setting Protocol
      'XYBRID_RT'          : 9978 , # XYBRID RT Server
      'DSM_SCM_TARGET'     : 9987 , # DSM_SCM Target Interface
      'NSESRVR'            : 9988 , # Software Essentials Secure HTTP server
      'OSM_APPSRVR'        : 9990 , # OSM Applet Server
      'OSM_OEV'            : 9991 , # OSM Event Server
      'PALACE_1'           : 9992 , # OnLive_1
      'PALACE_2'           : 9993 , # OnLive_2
      'PALACE_3'           : 9994 , # OnLive_3
      'PALACE_4'           : 9995 , # Palace_4
      'PALACE_5'           : 9996 , # Palace_5
      'PALACE_6'           : 9997 , # Palace_6
      'DISTINCT32'         : 9998 , # Distinct32
      'DISTINCT'           : 9999 , # distinct
      'NDMP'               : 10000, # Network Data Management Protocol
      'SCP_CONFIG'         : 10001, # SCP Configuration
      'DOCUMENTUM'         : 10002, # EMC_Documentum Content Server Product
      'DOCUMENTUM_S'       : 10003, # EMC_Documentum Content Server ProductIANA assigned this well_formed service name as a replacement for "documentum_s".
      'DOCUMENTUM_S'       : 10003, # EMC_Documentum Content Server Product
      'EMCRMIRCCD'         : 10004, # EMC Replication Manager Client
      'EMCRMIRD'           : 10005, # EMC Replication Manager Server
      'NETAPP_SYNC'        : 10006, # Sync replication protocol among different NetApp platforms
      'MVS_CAPACITY'       : 10007, # MVS Capacity
      'OCTOPUS'            : 10008, # Octopus Multiplexer
      'SWDTP_SV'           : 10009, # Systemwalker Desktop Patrol
      'RXAPI'              : 10010, # ooRexx rxapi services
      'ZABBIX_AGENT'       : 10050, # Zabbix Agent
      'ZABBIX_TRAPPER'     : 10051, # Zabbix Trapper
      'QPTLMD'             : 10055, # Quantapoint FLEXlm Licensing Service
      'AMANDA'             : 10080, # Amanda
      'FAMDC'              : 10081, # FAM Archive Server
      'ITAP_DDTP'          : 10100, # VERITAS ITAP DDTP
      'EZMEETING_2'        : 10101, # eZmeeting
      'EZPROXY_2'          : 10102, # eZproxy
      'EZRELAY'            : 10103, # eZrelay
      'SWDTP'              : 10104, # Systemwalker Desktop Patrol
      'BCTP_SERVER'        : 10107, # VERITAS BCTP, server
      'NMEA_0183'          : 10110, # NMEA_0183 Navigational Data
      'NETIQ_ENDPOINT'     : 10113, # NetIQ Endpoint
      'NETIQ_QCHECK'       : 10114, # NetIQ Qcheck
      'NETIQ_ENDPT'        : 10115, # NetIQ Endpoint
      'NETIQ_VOIPA'        : 10116, # NetIQ VoIP Assessor
      'IQRM'               : 10117, # NetIQ IQCResource Managament Svc
      'BMC_PERF_SD'        : 10128, # BMC_PERFORM_SERVICE DAEMON
      'BMC_GMS'            : 10129, # BMC General Manager Server
      'QB_DB_SERVER'       : 10160, # QB Database Server
      'SNMPTLS'            : 10161, # SNMP_TLS
      'SNMPTLS_TRAP'       : 10162, # SNMP_Trap_TLS
      'TRISOAP'            : 10200, # Trigence AE Soap Service
      'RSMS'               : 10201, # Remote Server Management Service
      'APOLLO_RELAY'       : 10252, # Apollo Relay Port
      'AXIS_WIMP_PORT'     : 10260, # Axis WIMP Port
      'BLOCKS'             : 10288, # Blocks
      'COSIR'              : 10321, # Computer Op System Information Report
      'MOS_LOWER'          : 10540, # MOS Media Object Metadata Port
      'MOS_UPPER'          : 10541, # MOS Running Order Port
      'MOS_AUX'            : 10542, # MOS Low Priority Port
      'MOS_SOAP'           : 10543, # MOS SOAP Default Port
      'MOS_SOAP_OPT'       : 10544, # MOS SOAP Optional Port
      'PRINTOPIA'          : 10631, # Port to allow for administration and control of "Printopia" application software,      which provides printing services to mobile users
      'GAP'                : 10800, # Gestor de Acaparamiento para Pocket PCs
      'LPDG'               : 10805, # LUCIA Pareja Data Group
      'NBD'                : 10809, # Linux Network Block Device
      'HELIX'              : 10860, # Helix Client_Server
      'BVEAPI'             : 10880, # BVEssentials HTTP API
      'RMIAUX'             : 10990, # Auxiliary RMI Port
      'IRISA'              : 11000, # IRISA
      'METASYS'            : 11001, # Metasys
      'WEAVE'              : 11095, # Nest device_to_device and device_to_service application protocol
      'ORIGO_SYNC'         : 11103, # OrigoDB Server Sync Interface
      'NETAPP_ICMGMT'      : 11104, # NetApp Intercluster Management
      'NETAPP_ICDATA'      : 11105, # NetApp Intercluster Data
      'SGI_LK'             : 11106, # SGI LK Licensing service
      'SGI_DMFMGR'         : 11109, # Data migration facility Manager (DMF) is a browser based interface to DMF
      'SGI_SOAP'           : 11110, # Data migration facility (DMF) SOAP is a web server protocol to support remote access to DMF
      'VCE'                : 11111, # Viral Computing Environment (VCE)
      'DICOM'              : 11112, # DICOM
      'SUNCACAO_SNMP'      : 11161, # sun cacao snmp access point
      'SUNCACAO_JMXMP'     : 11162, # sun cacao JMX_remoting access point
      'SUNCACAO_RMI'       : 11163, # sun cacao rmi registry access point
      'SUNCACAO_CSA'       : 11164, # sun cacao command_streaming access point
      'SUNCACAO_WEBSVC'    : 11165, # sun cacao web service access point
      'OEMCACAO_JMXMP'     : 11172, # OEM cacao JMX_remoting access point
      'T5_STRATON'         : 11173, # Straton Runtime Programing
      'OEMCACAO_RMI'       : 11174, # OEM cacao rmi registry access point
      'OEMCACAO_WEBSVC'    : 11175, # OEM cacao web service access point
      'SMSQP'              : 11201, # smsqp
      'DCSL_BACKUP'        : 11202, # DCSL Network Backup Services
      'WIFREE'             : 11208, # WiFree Service
      'MEMCACHE'           : 11211, # Memory cache service
      'IMIP'               : 11319, # IMIP
      'IMIP_CHANNELS'      : 11320, # IMIP Channels Port
      'ARENA_SERVER'       : 11321, # Arena Server Listen
      'ATM_UHAS'           : 11367, # ATM UHAS
      'HKP'                : 11371, # OpenPGP HTTP Keyserver
      'ASGCYPRESSTCPS'     : 11489, # ASG Cypress Secure Only
      'TEMPEST_PORT'       : 11600, # Tempest Protocol Port
      'EMC_XSW_DCONFIG'    : 11623, # EMC XtremSW distributed config
      'H323CALLSIGALT'     : 11720, # H.323 Call Control Signalling Alternate
      'EMC_XSW_DCACHE'     : 11723, # EMC XtremSW distributed cache
      'INTREPID_SSL'       : 11751, # Intrepid SSL
      'LANSCHOOL'          : 11796, # LanSchool
      'XORAYA'             : 11876, # X2E Xoraya Multichannel protocol
      'SYSINFO_SP'         : 11967, # SysInfo Service Protocol
      'ENTEXTXID'          : 12000, # IBM Enterprise Extender SNA XID Exchange
      'ENTEXTNETWK'        : 12001, # IBM Enterprise Extender SNA COS Network Priority
      'ENTEXTHIGH'         : 12002, # IBM Enterprise Extender SNA COS High Priority
      'ENTEXTMED'          : 12003, # IBM Enterprise Extender SNA COS Medium Priority
      'ENTEXTLOW'          : 12004, # IBM Enterprise Extender SNA COS Low Priority
      'DBISAMSERVER1'      : 12005, # DBISAM Database Server _ Regular
      'DBISAMSERVER2'      : 12006, # DBISAM Database Server _ Admin
      'ACCURACER'          : 12007, # Accuracer Database System Server
      'ACCURACER_DBMS'     : 12008, # Accuracer Database System Admin
      'EDBSRVR'            : 12010, # ElevateDB Server
      'VIPERA'             : 12012, # Vipera Messaging Service
      'VIPERA_SSL'         : 12013, # Vipera Messaging Service over SSL Communication
      'RETS_SSL'           : 12109, # RETS over SSL
      'NUPAPER_SS'         : 12121, # NuPaper Session Service
      'CAWAS'              : 12168, # CA Web Access Service
      'HIVEP'              : 12172, # HiveP
      'LINOGRIDENGINE'     : 12300, # LinoGrid Engine
      'RADS'               : 12302, # Remote Administration Daemon (RAD) is a system service that offers secure, remote, programmatic access to Solaris system configuration and run_time state
      'WAREHOUSE_SSS'      : 12321, # Warehouse Monitoring Syst SSS
      'WAREHOUSE'          : 12322, # Warehouse Monitoring Syst
      'ITALK'              : 12345, # Italk Chat System
      'TSAF'               : 12753, # tsaf port
      'NETPERF'            : 12865, # control port for the netperf benchmark
      'I_ZIPQD'            : 13160, # I_ZIPQD
      'BCSLOGC'            : 13216, # Black Crow Software application logging
      'RS_PIAS'            : 13217, # R&S Proxy Installation Assistant Service
      'EMC_VCAS_TCP'       : 13218, # EMC Virtual CAS Service
      'POWWOW_CLIENT'      : 13223, # PowWow Client
      'POWWOW_SERVER'      : 13224, # PowWow Server
      'DOIP_DATA'          : 13400, # DoIP Data
      'BPRD'               : 13720, # BPRD Protocol (VERITAS NetBackup)
      'BPDBM'              : 13721, # BPDBM Protocol (VERITAS NetBackup)
      'BPJAVA_MSVC'        : 13722, # BP Java MSVC Protocol
      'VNETD'              : 13724, # Veritas Network Utility
      'BPCD'               : 13782, # VERITAS NetBackup
      'VOPIED'             : 13783, # VOPIED Protocol
      'NBDB'               : 13785, # NetBackup Database
      'NOMDB'              : 13786, # Veritas_nomdb
      'DSMCC_CONFIG'       : 13818, # DSMCC Config
      'DSMCC_SESSION'      : 13819, # DSMCC Session Messages
      'DSMCC_PASSTHRU'     : 13820, # DSMCC Pass_Thru Messages
      'DSMCC_DOWNLOAD'     : 13821, # DSMCC Download Protocol
      'DSMCC_CCP'          : 13822, # DSMCC Channel Change Protocol
      'BMDSS'              : 13823, # Blackmagic Design Streaming Server
      'UCONTROL'           : 13894, # Ultimate Control communication protocol
      'DTA_SYSTEMS'        : 13929, # D_TA SYSTEMS
      'MEDEVOLVE'          : 13930, # MedEvolve Port Requester
      'SCOTTY_FT'          : 14000, # SCOTTY High_Speed Filetransfer
      'SUA'                : 14001, # SUA
      'SAGE_BEST_COM1'     : 14033, # sage Best! Config Server 1
      'SAGE_BEST_COM2'     : 14034, # sage Best! Config Server 2
      'VCS_APP'            : 14141, # VCS Application
      'ICPP'               : 14142, # IceWall Cert Protocol
      'GCM_APP'            : 14145, # GCM Application
      'VRTS_TDD'           : 14149, # Veritas Traffic Director
      'VCSCMD'             : 14150, # Veritas Cluster Server Command Server
      'VAD'                : 14154, # Veritas Application Director
      'CPS'                : 14250, # Fencing Server
      'CA_WEB_UPDATE'      : 14414, # CA eTrust Web Update Service
      'HDE_LCESRVR_1'      : 14936, # hde_lcesrvr_1
      'HDE_LCESRVR_2'      : 14937, # hde_lcesrvr_2
      'HYDAP'              : 15000, # Hypack Data Aquisition
      'ONEP_TLS'           : 15002, # Open Network Environment TLS
      'XPILOT'             : 15345, # XPilot Contact Port
      '3LINK'              : 15363, # 3Link Negotiation
      'CISCO_SNAT'         : 15555, # Cisco Stateful NAT
      'BEX_XR'             : 15660, # Backup Express Restore Server
      'PTP'                : 15740, # Picture Transfer Protocol
      'PROGRAMMAR'         : 15999, # ProGrammar Enterprise
      'FMSAS'              : 16000, # Administration Server Access
      'FMSASCON'           : 16001, # Administration Server Connector
      'GSMS'               : 16002, # GoodSync Mediation Service
      'JWPC'               : 16020, # Filemaker Java Web Publishing Core
      'JWPC_BIN'           : 16021, # Filemaker Java Web Publishing Core Binary
      'SUN_SEA_PORT'       : 16161, # Solaris SEA Port
      'SOLARIS_AUDIT'      : 16162, # Solaris Audit _ secure remote audit log
      'ETB4J'              : 16309, # etb4j
      'PDUNCS'             : 16310, # Policy Distribute, Update Notification
      'PDEFMNS'            : 16311, # Policy definition and update management
      'NETSERIALEXT1'      : 16360, # Network Serial Extension Ports One
      'NETSERIALEXT2'      : 16361, # Network Serial Extension Ports Two
      'NETSERIALEXT3'      : 16367, # Network Serial Extension Ports Three
      'NETSERIALEXT4'      : 16368, # Network Serial Extension Ports Four
      'CONNECTED'          : 16384, # Connected Corp
      'XOMS'               : 16619, # X509 Objects Management Service
      'NEWBAY_SNC_MC'      : 16900, # Newbay Mobile Client Update Service
      'SGCIP'              : 16950, # Simple Generic Client Interface Protocol
      'INTEL_RCI_MP'       : 16991, # INTEL_RCI_MP
      'AMT_SOAP_HTTP'      : 16992, # Intel(R) AMT SOAP_HTTP
      'AMT_SOAP_HTTPS'     : 16993, # Intel(R) AMT SOAP_HTTPS
      'AMT_REDIR_TCP'      : 16994, # Intel(R) AMT Redirection_TCP
      'AMT_REDIR_TLS'      : 16995, # Intel(R) AMT Redirection_TLS
      'ISODE_DUA'          : 17007, # 
      'VESTASDLP'          : 17184, # Vestas Data Layer Protocol
      'SOUNDSVIRTUAL'      : 17185, # Sounds Virtual
      'CHIPPER'            : 17219, # Chipper
      'AVTP'               : 17220, # IEEE 1722 Transport Protocol for Time Sensitive Applications
      'AVDECC'             : 17221, # IEEE 1722.1 AVB Discovery, Enumeration, Connection management, and Control
      'INTEGRIUS_STP'      : 17234, # Integrius Secure Tunnel Protocol
      'SSH_MGMT'           : 17235, # SSH Tectia Manager
      'DB_LSP'             : 17500, # Dropbox LanSync Protocol
      'AILITH'             : 17555, # Ailith management of routers
      'EA'                 : 17729, # Eclipse Aviation
      'ZEP'                : 17754, # Encap. ZigBee Packets
      'ZIGBEE_IP'          : 17755, # ZigBee IP Transport Service
      'ZIGBEE_IPS'         : 17756, # ZigBee IP Transport Secure Service
      'SW_ORION'           : 17777, # SolarWinds Orion
      'BIIMENU'            : 18000, # Beckman Instruments, Inc.
      'RADPDF'             : 18104, # RAD PDF Service
      'RACF'               : 18136, # z_OS Resource Access Control Facility
      'OPSEC_CVP'          : 18181, # OPSEC CVP
      'OPSEC_UFP'          : 18182, # OPSEC UFP
      'OPSEC_SAM'          : 18183, # OPSEC SAM
      'OPSEC_LEA'          : 18184, # OPSEC LEA
      'OPSEC_OMI'          : 18185, # OPSEC OMI
      'OHSC'               : 18186, # Occupational Health SC
      'OPSEC_ELA'          : 18187, # OPSEC ELA
      'CHECKPOINT_RTM'     : 18241, # Check Point RTM
      'ICLID'              : 18242, # Checkpoint router monitoring
      'CLUSTERXL'          : 18243, # Checkpoint router state backup
      'GV_PF'              : 18262, # GV NetConfig Service
      'AC_CLUSTER'         : 18463, # AC Cluster
      'RDS_IB'             : 18634, # Reliable Datagram Service
      'RDS_IP'             : 18635, # Reliable Datagram Service over IP
      'IQUE'               : 18769, # IQue Protocol
      'INFOTOS'            : 18881, # Infotos
      'APC_NECMP'          : 18888, # APCNECMP
      'IGRID'              : 19000, # iGrid Server
      'SCINTILLA'          : 19007, # Scintilla protocol for device services
      'J_LINK'             : 19020, # J_Link TCP_IP Protocol
      'OPSEC_UAA'          : 19191, # OPSEC UAA
      'UA_SECUREAGENT'     : 19194, # UserAuthority SecureAgent
      'KEYSRVR'            : 19283, # Key Server for SASSAFRAS
      'KEYSHADOW'          : 19315, # Key Shadow for SASSAFRAS
      'MTRGTRANS'          : 19398, # mtrgtrans
      'HP_SCO'             : 19410, # hp_sco
      'HP_SCA'             : 19411, # hp_sca
      'HP_SESSMON'         : 19412, # HP_SESSMON
      'FXUPTP'             : 19539, # FXUPTP
      'SXUPTP'             : 19540, # SXUPTP
      'JCP'                : 19541, # JCP Client
      'IEC_104_SEC'        : 19998, # IEC 60870_5_104 process control _ secure
      'DNP_SEC'            : 19999, # Distributed Network Protocol _ Secure
      'DNP'                : 20000, # DNP
      'MICROSAN'           : 20001, # MicroSAN
      'COMMTACT_HTTP'      : 20002, # Commtact HTTP
      'COMMTACT_HTTPS'     : 20003, # Commtact HTTPS
      'OPENWEBNET'         : 20005, # OpenWebNet protocol for electric network
      'SS_IDI'             : 20013, # Samsung Interdevice Interaction
      'OPENDEPLOY'         : 20014, # OpenDeploy Listener
      'NBURN_ID'           : 20034, # NetBurner ID PortIANA assigned this well_formed service name as a replacement for "nburn_id".
      'NBURN_ID'           : 20034, # NetBurner ID Port
      'TMOPHL7MTS'         : 20046, # TMOP HL7 Message Transfer Service
      'MOUNTD'             : 20048, # NFS mount protocol
      'NFSRDMA'            : 20049, # Network File System (NFS) over RDMA
      'TOLFAB'             : 20167, # TOLfab Data Change
      'IPDTP_PORT'         : 20202, # IPD Tunneling Port
      'IPULSE_ICS'         : 20222, # iPulse_ICS
      'EMWAVEMSG'          : 20480, # emWave Message Service
      'TRACK'              : 20670, # Track
      'ATHAND_MMP'         : 20999, # At Hand MMP
      'IRTRANS'            : 21000, # IRTrans Control
      'NOTEZILLA_LAN'      : 21010, # Notezilla.Lan Server
      'RDM_TFS'            : 21553, # Raima RDM TFS
      'DFSERVER'           : 21554, # MineScape Design File Server
      'VOFR_GATEWAY'       : 21590, # VoFR Gateway
      'TVPM'               : 21800, # TVNC Pro Multiplexing
      'WEBPHONE'           : 21845, # webphone
      'NETSPEAK_IS'        : 21846, # NetSpeak Corp. Directory Services
      'NETSPEAK_CS'        : 21847, # NetSpeak Corp. Connection Services
      'NETSPEAK_ACD'       : 21848, # NetSpeak Corp. Automatic Call Distribution
      'NETSPEAK_CPS'       : 21849, # NetSpeak Corp. Credit Processing System
      'SNAPENETIO'         : 22000, # SNAPenetIO
      'OPTOCONTROL'        : 22001, # OptoControl
      'OPTOHOST002'        : 22002, # Opto Host Port 2
      'OPTOHOST003'        : 22003, # Opto Host Port 3
      'OPTOHOST004'        : 22004, # Opto Host Port 4
      'OPTOHOST004'        : 22005, # Opto Host Port 5
      'DCAP'               : 22125, # dCache Access Protocol
      'GSIDCAP'            : 22128, # GSI dCache Access Protocol
      'EASYENGINE'         : 22222, # EasyEngine is CLI tool to manage WordPress Sites on Nginx server
      'WNN6'               : 22273, # wnn6
      'CIS'                : 22305, # CompactIS Tunnel
      'CIS_SECURE'         : 22343, # CompactIS Secure Tunnel
      'WIBUKEY'            : 22347, # WibuKey Standard WkLan
      'CODEMETER'          : 22350, # CodeMeter Standard
      'CODEMETER_CMWAN'    : 22351, # TPC_IP requests of copy protection software to a server
      'CALDSOFT_BACKUP'    : 22537, # CaldSoft Backup server file transfer
      'VOCALTEC_WCONF'     : 22555, # Vocaltec Web Conference
      'TALIKASERVER'       : 22763, # Talika Main Server
      'AWS_BRF'            : 22800, # Telerate Information Platform LAN
      'BRF_GW'             : 22951, # Telerate Information Platform WAN
      'INOVAPORT1'         : 23000, # Inova LightLink Server Type 1
      'INOVAPORT2'         : 23001, # Inova LightLink Server Type 2
      'INOVAPORT3'         : 23002, # Inova LightLink Server Type 3
      'INOVAPORT4'         : 23003, # Inova LightLink Server Type 4
      'INOVAPORT5'         : 23004, # Inova LightLink Server Type 5
      'INOVAPORT6'         : 23005, # Inova LightLink Server Type 6
      'GNTP'               : 23053, # Generic Notification Transport Protocol
      'ELXMGMT'            : 23333, # Emulex HBAnyware Remote Management
      'NOVAR_DBASE'        : 23400, # Novar Data
      'NOVAR_ALARM'        : 23401, # Novar Alarm
      'NOVAR_GLOBAL'       : 23402, # Novar Global
      'AEQUUS'             : 23456, # Aequus Service
      'AEQUUS_ALT'         : 23457, # Aequus Service Mgmt
      'AREAGUARD_NEO'      : 23546, # AreaGuard Neo _ WebServer
      'MED_LTP'            : 24000, # med_ltp
      'MED_FSP_RX'         : 24001, # med_fsp_rx
      'MED_FSP_TX'         : 24002, # med_fsp_tx
      'MED_SUPP'           : 24003, # med_supp
      'MED_OVW'            : 24004, # med_ovw
      'MED_CI'             : 24005, # med_ci
      'MED_NET_SVC'        : 24006, # med_net_svc
      'FILESPHERE'         : 24242, # fileSphere
      'VISTA_4GL'          : 24249, # Vista 4GL
      'ILD'                : 24321, # Isolv Local Directory
      'INTEL_RCI'          : 24386, # Intel RCIIANA assigned this well_formed service name as a replacement for "intel_rci".
      'INTEL_RCI'          : 24386, # Intel RCI
      'TONIDODS'           : 24465, # Tonido Domain Server
      'BINKP'              : 24554, # BINKP
      'BILOBIT'            : 24577, # bilobit Service
      'CANDITV'            : 24676, # Canditv Message Service
      'FLASHFILER'         : 24677, # FlashFiler
      'PROACTIVATE'        : 24678, # Turbopower Proactivate
      'TCC_HTTP'           : 24680, # TCC User HTTP Service
      'CSLG'               : 24754, # Citrix StorageLink Gateway
      'FIND'               : 24922, # Find Identification of Network Devices
      'ICL_TWOBASE1'       : 25000, # icl_twobase1
      'ICL_TWOBASE2'       : 25001, # icl_twobase2
      'ICL_TWOBASE3'       : 25002, # icl_twobase3
      'ICL_TWOBASE4'       : 25003, # icl_twobase4
      'ICL_TWOBASE5'       : 25004, # icl_twobase5
      'ICL_TWOBASE6'       : 25005, # icl_twobase6
      'ICL_TWOBASE7'       : 25006, # icl_twobase7
      'ICL_TWOBASE8'       : 25007, # icl_twobase8
      'ICL_TWOBASE9'       : 25008, # icl_twobase9
      'ICL_TWOBASE10'      : 25009, # icl_twobase10
      'SAUTERDONGLE'       : 25576, # Sauter Dongle
      'IDTP'               : 25604, # Identifier Tracing Protocol
      'VOCALTEC_HOS'       : 25793, # Vocaltec Address Server
      'TASP_NET'           : 25900, # TASP Network Comm
      'NIOBSERVER'         : 25901, # NIObserver
      'NILINKANALYST'      : 25902, # NILinkAnalyst
      'NIPROBE'            : 25903, # NIProbe
      'QUAKE'              : 26000, # quake
      'SCSCP'              : 26133, # Symbolic Computation Software Composability Protocol
      'WNN6_DS'            : 26208, # wnn6_ds
      'EZPROXY'            : 26260, # eZproxy
      'EZMEETING'          : 26261, # eZmeeting
      'K3SOFTWARE_SVR'     : 26262, # K3 Software_Server
      'K3SOFTWARE_CLI'     : 26263, # K3 Software_Client
      'EXOLINE_TCP'        : 26486, # EXOline_TCP
      'EXOCONFIG'          : 26487, # EXOconfig
      'EXONET'             : 26489, # EXOnet
      'IMAGEPUMP'          : 27345, # ImagePump
      'JESMSJC'            : 27442, # Job controller service
      'KOPEK_HTTPHEAD'     : 27504, # Kopek HTTP Head Port
      'ARS_VISTA'          : 27782, # ARS VISTA Application
      'ASTROLINK'          : 27876, # Astrolink Protocol
      'TW_AUTH_KEY'        : 27999, # TW Authentication_Key Distribution and
      'NXLMD'              : 28000, # NX License Manager
      'PQSP'               : 28001, # PQ Service
      'VOXELSTORM'         : 28200, # VoxelStorm game server
      'SIEMENSGSM'         : 28240, # Siemens GSM
      'OTMP'               : 29167, # ObTools Message Protocol
      'BINGBANG'           : 29999, # data exchange protocol for IEC61850 in wind power plants
      'NDMPS'              : 30000, # Secure Network Data Management Protocol
      'PAGO_SERVICES1'     : 30001, # Pago Services 1
      'PAGO_SERVICES2'     : 30002, # Pago Services 2
      'AMICON_FPSU_RA'     : 30003, # Amicon FPSU_IP Remote Administration
      'KINGDOMSONLINE'     : 30260, # Kingdoms Online (CraigAvenue)
      'OVOBS'              : 30999, # OpenView Service Desk Client
      'AUTOTRAC_ACP'       : 31020, # Autotrac ACP 245
      'PACE_LICENSED'      : 31400, # PACE license server
      'XQOSD'              : 31416, # XQoS network monitor
      'TETRINET'           : 31457, # TetriNET Protocol
      'LM_MON'             : 31620, # lm mon
      'DSX_MONITOR'        : 31685, # DS Expert MonitorIANA assigned this well_formed service name as a replacement for "dsx_monitor".
      'DSX_MONITOR'        : 31685, # DS Expert Monitor
      'GAMESMITH_PORT'     : 31765, # GameSmith Port
      'ICEEDCP_TX'         : 31948, # Embedded Device Configuration Protocol TXIANA assigned this well_formed service name as a replacement for "iceedcp_tx".
      'ICEEDCP_TX'         : 31948, # Embedded Device Configuration Protocol TX
      'ICEEDCP_RX'         : 31949, # Embedded Device Configuration Protocol RXIANA assigned this well_formed service name as a replacement for "iceedcp_rx".
      'ICEEDCP_RX'         : 31949, # Embedded Device Configuration Protocol RX
      'IRACINGHELPER'      : 32034, # iRacing helper service
      'T1DISTPROC60'       : 32249, # T1 Distributed Processor
      'APM_LINK'           : 32483, # Access Point Manager Link
      'SEC_NTB_CLNT'       : 32635, # SecureNotebook_CLNT
      'DMEXPRESS'          : 32636, # DMExpress
      'FILENET_POWSRM'     : 32767, # FileNet BPM WS_ReliableMessaging Client
      'FILENET_TMS'        : 32768, # Filenet TMS
      'FILENET_RPC'        : 32769, # Filenet RPC
      'FILENET_NCH'        : 32770, # Filenet NCH
      'FILENET_RMI'        : 32771, # FileNET RMI
      'FILENET_PA'         : 32772, # FileNET Process Analyzer
      'FILENET_CM'         : 32773, # FileNET Component Manager
      'FILENET_RE'         : 32774, # FileNET Rules Engine
      'FILENET_PCH'        : 32775, # Performance Clearinghouse
      'FILENET_PEIOR'      : 32776, # FileNET BPM IOR
      'FILENET_OBROK'      : 32777, # FileNet BPM CORBA
      'MLSN'               : 32801, # Multiple Listing Service Network
      'RETP'               : 32811, # Real Estate Transport Protocol
      'IDMGRATM'           : 32896, # Attachmate ID Manager
      'AURORA_BALAENA'     : 33123, # Aurora (Balaena Ltd)
      'DIAMONDPORT'        : 33331, # DiamondCentral Interface
      'DGI_SERV'           : 33333, # Digital Gaslight Service
      'SPEEDTRACE'         : 33334, # SpeedTrace TraceAgent
      'TRACEROUTE'         : 33434, # traceroute use
      'SNIP_SLAVE'         : 33656, # SNIP Slave
      'TURBONOTE_2'        : 34249, # TurboNote Relay Server Default Port
      'P_NET_LOCAL'        : 34378, # P_Net on IP local
      'P_NET_REMOTE'       : 34379, # P_Net on IP remote
      'DHANALAKSHMI'       : 34567, # dhanalakshmi.org EDI Service
      'PROFINET_RT'        : 34962, # PROFInet RT Unicast
      'PROFINET_RTM'       : 34963, # PROFInet RT Multicast
      'PROFINET_CM'        : 34964, # PROFInet Context Manager
      'ETHERCAT'           : 34980, # EtherCAT Port
      'HEATHVIEW'          : 35000, # HeathView
      'RT_VIEWER'          : 35001, # ReadyTech Viewer
      'RT_SOUND'           : 35002, # ReadyTech Sound Server
      'RT_DEVICEMAPPER'    : 35003, # ReadyTech DeviceMapper Server
      'RT_CLASSMANAGER'    : 35004, # ReadyTech ClassManager
      'RT_LABTRACKER'      : 35005, # ReadyTech LabTracker
      'RT_HELPER'          : 35006, # ReadyTech Helper Service
      'KITIM'              : 35354, # KIT Messenger
      'ALTOVA_LM'          : 35355, # Altova License Management
      'GUTTERSNEX'         : 35356, # Gutters Note Exchange
      'OPENSTACK_ID'       : 35357, # OpenStack ID Service
      'ALLPEERS'           : 36001, # AllPeers Network
      'FEBOOTI_AW'         : 36524, # Febooti Automation Workshop
      'OBSERVIUM_AGENT'    : 36602, # Observium statistics collection agent
      'KASTENXPIPE'        : 36865, # KastenX Pipe
      'NECKAR'             : 37475, # science + computing's Venus Administration Port
      'GDRIVE_SYNC'        : 37483, # Google Drive Sync
      'UNISYS_EPORTAL'     : 37654, # Unisys ClearPath ePortal
      'IVS_DATABASE'       : 38000, # InfoVista Server Database
      'IVS_INSERTION'      : 38001, # InfoVista Server Insertion
      'GALAXY7_DATA'       : 38201, # Galaxy7 Data Tunnel
      'FAIRVIEW'           : 38202, # Fairview Message Service
      'AGPOLICY'           : 38203, # AppGate Policy Server
      'SRUTH'              : 38800, # Sruth is a service for the distribution of routinely_      generated but arbitrary files based on a publish_subscribe      distribution model and implemented using a peer_to_peer transport      mechanism
      'SECRMMSAFECOPYA'    : 38865, # Security approval process for use of the secRMM SafeCopy program
      'TURBONOTE_1'        : 39681, # TurboNote Default Port
      'SAFETYNETP'         : 40000, # SafetyNET p
      'SPTX'               : 40404, # Simplify Printing TX
      'CSCP'               : 40841, # CSCP
      'CSCCREDIR'          : 40842, # CSCCREDIR
      'CSCCFIREWALL'       : 40843, # CSCCFIREWALL
      'FS_QOS'             : 41111, # Foursticks QoS Protocol
      'TENTACLE'           : 41121, # Tentacle Server
      'CRESTRON_CIP'       : 41794, # Crestron Control Port
      'CRESTRON_CTP'       : 41795, # Crestron Terminal Port
      'CRESTRON_CIPS'      : 41796, # Crestron Secure Control Port
      'CRESTRON_CTPS'      : 41797, # Crestron Secure Terminal Port
      'CANDP'              : 42508, # Computer Associates network discovery protocol
      'CANDRP'             : 42509, # CA discovery response
      'CAERPC'             : 42510, # CA eTrust RPC
      'RECVR_RC'           : 43000, # Receiver Remote Control
      'REACHOUT'           : 43188, # REACHOUT
      'NDM_AGENT_PORT'     : 43189, # NDM_AGENT_PORT
      'IP_PROVISION'       : 43190, # IP_PROVISION
      'NOIT_TRANSPORT'     : 43191, # Reconnoiter Agent Data Transport
      'SHAPERAI'           : 43210, # Shaper Automation Server Management
      'EQ3_UPDATE'         : 43439, # EQ3 firmware update
      'EW_MGMT'            : 43440, # Cisco EnergyWise Management
      'CISCOCSDB'          : 43441, # Cisco NetMgmt DB Ports
      'Z_WAVE_S'           : 44123, # Z_Wave Secure Tunnel
      'PMCD'               : 44321, # PCP server (pmcd)
      'PMCDPROXY'          : 44322, # PCP server (pmcd) proxy
      'PMWEBAPI'           : 44323, # HTTP binding for Performance Co_Pilot client API
      'COGNEX_DATAMAN'     : 44444, # Cognex DataMan Management Protocol
      'RBR_DEBUG'          : 44553, # REALbasic Remote Debug
      'ETHERNET_IP_2'      : 44818, # EtherNet_IP messagingIANA assigned this well_formed service name as a replacement for "EtherNet_IP_2".
      'M3DA'               : 44900, # M3DA is used for efficient machine_to_machine communications
      'ASMP'               : 45000, # NSi AutoStore Status Monitoring Protocol data transfer
      'ASMPS'              : 45001, # NSi AutoStore Status Monitoring Protocol secure data transfer
      'SYNCTEST'           : 45045, # Remote application control protocol
      'INVISION_AG'        : 45054, # InVision AG
      'EBA'                : 45678, # EBA PRISE
      'DAI_SHELL'          : 45824, # Server for the DAI family of client_server products
      'QDB2SERVICE'        : 45825, # Qpuncture Data Access Service
      'SSR_SERVERMGR'      : 45966, # SSRServerMgr
      'SPREMOTETABLET'     : 46998, # Connection between a desktop computer or server and a signature tablet to capture handwritten signatures
      'MEDIABOX'           : 46999, # MediaBox Server
      'MBUS'               : 47000, # Message Bus
      'WINRM'              : 47001, # Windows Remote Management Service
      'DBBROWSE'           : 47557, # Databeam Corporation
      'DIRECTPLAYSRVR'     : 47624, # Direct Play Server
      'AP'                 : 47806, # ALC Protocol
      'BACNET'             : 47808, # Building Automation and Control Networks
      'NIMCONTROLLER'      : 48000, # Nimbus Controller
      'NIMSPOOLER'         : 48001, # Nimbus Spooler
      'NIMHUB'             : 48002, # Nimbus Hub
      'NIMGTW'             : 48003, # Nimbus Gateway
      'NIMBUSDB'           : 48004, # NimbusDB Connector
      'NIMBUSDBCTRL'       : 48005, # NimbusDB Control
      '3GPP_CBSP'          : 48049, # 3GPP Cell Broadcast Service Protocol
      'WEANDSF'            : 48050, # WeFi Access Network Discovery and Selection Function
      'ISNETSERV'          : 48128, # Image Systems Network Services
      'BLP5'               : 48129, # Bloomberg locator
      'COM_BARDAC_DW'      : 48556, # com_bardac_dw
      'IQOBJECT'           : 48619, # iqobject
      'ROBOTRACONTEUR'     : 48653, # Robot Raconteur transport
      'MATAHARI'           : 49000, # Matahari Broker
      }
      inv_map = {v: k for k, v in map.items()}
      
    def __init__(self,dbytes,pseudo_hdr):
      """
      """
      self.sport=int(''.join(map(lambda x: '%02x'%x,dbytes[0:2])),16)
      self.dport=int(''.join(map(lambda x: '%02x'%x,dbytes[2:4])),16)
      self.seqno=int(''.join(map(lambda x: '%02x'%x,dbytes[4:8])),16)
      self.ackno=int(''.join(map(lambda x: '%02x'%x,dbytes[8:12])),16)
      self.offset=(dbytes[12] & 0xf0) >> 4
      self.ns=dbytes[12] & 0x1
      self.cwr=(dbytes[13] & 0x80) >> 7
      self.ece=(dbytes[13] & 0x40) >> 6
      self.urg=(dbytes[13] & 0x20) >> 5
      self.ack=(dbytes[13] & 0x10) >> 4
      self.psh=(dbytes[13] & 0x08) >> 3
      self.rst=(dbytes[13] & 0x04) >> 2
      self.syn=(dbytes[13] & 0x02) >> 1
      self.fin=dbytes[13] & 0x01
      self.window=int(''.join(map(lambda x: '%02x'%x,dbytes[14:16])),16)
      self.checksum=map(lambda x: '%02x'%x,dbytes[16:18])
      self.urgptr=int(''.join(map(lambda x: '%02x'%x,dbytes[18:20])),16)
      if self.offset > 5:
        self.option=''.join(map(lambda x: '%02x'%x,dbytes[20:4*self.offset]))
      else:
        self.option=''
      self.payload=dbytes[4*self.offset:]
      #self.check_checksum('TCP',3+len(dbytes)//4,self.checksum,pseudo_hdr+dbytes[:16]+[0]*2+dbytes[18:])
      #print map(hex,pseudo_hdr)
      #print map(hex,dbytes[:16]+[0]*2+dbytes[18:(len(dbytes)//4)*4])
      self.calchecksum=self.calc_checksum(3+len(dbytes)//4,pseudo_hdr+dbytes[:16]+[0]*2+dbytes[18:(len(dbytes)//4)*4])

      if map(lambda x: '%02x'%x,self.calchecksum) != self.checksum:
        print "Error: %s checksum error %s vs %s"%('TCP',self.checksum,map(lambda x: '%02x'%x,self.calchecksum))
 
    def get(self):
      print """
      Source port                    %s
      Destination port               %s
      Sequence number                %s
      Acknowledgment number          %s
      Data offset                    %s
      Reserved (3 bits)              000
      Flags 
        NS                           %s
        CWR                          %s
        ECE                          %s
        URG                          %s
        ACK                          %s
        PSH                          %s
        RST                          %s
        SYN                          %s
        FIN                          %s
      Window size                    %s
      Checksum                       %s
      Urgent pointer                 %s
      Options                        %s
      """%(
      self.sport,
      self.dport,
      self.seqno,
      self.ackno,
      self.offset,
      self.ns,
      self.cwr,
      self.ece,
      self.urg,
      self.ack,
      self.psh,
      self.rst,
      self.syn,
      self.fin,
      self.window,
      self.checksum,
      self.urgptr,
      self.option
      )
  class rpc_hdr(tcp_hdr):
    class Header(datastruct): pass
    class Credential(datastruct): pass
    class Prog(datastruct): pass
    """
    if tcp
      fragment_headr
        last_fragment
        size
    xid
    type
    if type == 0 (rpc call)
      rpc_version
      program
      version
      procedure
      credential
        data
        flavor
        size
      verifier
        data
        flavor
        size
    if type == 1 (rpc reply)
      reply_status
      if reply_status == 0  
        verifier
          data
          flavor
          size
        accepted_status
        if accepted_status == 2
          program_mismatch
            low
            high
      if reply_status != 0  
        rejected_status
        if rejectted_status == 0
          program_mismatch
            low
            high
        if rejectted_status != 0
          auth_status
    """
    """
    http://tools.ietf.org/html/rfc5531
        100000  PMAP                portmapper
        100001  RSTAT               remote stats
        100002  RUSERS              remote users
        100003  NFS                 nfs
        100004  YP                  Yellow Pages
        100005  MOUNT               mount demon
        100006  DBX                 remote dbx
        100007  YPBIND              yp binder
        100008  WALL                shutdown msg
        100009  YPPASSWD            yppasswd server
        100010  ETHERSTAT           ether stats
        100011  RQUOTA              disk quotas
        100012  SPRAY               spray packets
        100013  IBM3270             3270 mapper
        100014  IBMRJE              RJE mapper
        100015  SELNSVC             selection service
        100016  RDAT                ABASE remote database access
        100017  REXEC               remote execution
        100018  ALICE               Alice Office Automation
        100019  SCHED               scheduling service
        100020  LOCK                local lock manager
        100021  NETLOCK             network lock manager
        100022  X25                 x.25 inr protocol
        100023  STATMON1            status monitor 1
        100024  STATMON2            status monitor 2
        100025  SELNLIB             selection library
        100026  BOOTPARAM           boot parameters service
        100027  MAZE                mazewars game
        100028  YPUPDATE            yp update
        100029  KEYSERVE            key server
        100030  SECURECMD           secure login
        100031  NETFWDI             nfs net forwarder init
        100032  NETFWDT             nfs net forwarder trans
        100033  SUNLINKMAP_         sunlink MAP
        100034  NETMON              network monitor
        100035  DBASE               lightweight database
        100036  PWDAUTH             password authorization
        100037  TFS                 translucent file svc
        100038  NSE                 nse server
        100039  NSE_ACTIVATE_       nse activate daemon
        150001  PCNFSD              pc passwd authorization
        200000  PYRAMIDLOCKING      Pyramid-locking
        200001  PYRAMIDSYS5         Pyramid-sys5
        200002  CADDS_IMAGE         CV cadds_image
        300001  ADT_RFLOCK          ADT file locking
    """
    program2name={
      100003 : 'NFS',
      100005 : 'MNT',
      100021 : 'NETLOCK',           # network lock manager
      100024 : 'STATMON2',          # status monitor 2
      100227 : 'NFSACL',            #
    }
    """
    LOOKUP      27%
    READ        18%
    WRITE       9%
    GETATTR     11%
    READLINK    7%
    READDIR     2%
    CREATE      1%
    REMOVE      1%
    FSSTAT      1%
    SETATTR     1%
    READDIRPLUS 9%
    ACCESS      7%
    COMMIT      5%
    """
    procedure2name={
      0  : 'NULL',
      1  : 'GETATTR',
      2  : 'SETATTR',
      3  : 'LOOKUP',
      4  : 'ACCESS',
      5  : 'LINK',
      6  : 'READ',
      7  : 'WRITE',
      8  : 'CREATE',
      9  : 'MKDIR',
      10 : 'SYMLINK',
      11 : 'MKNOD',
      12 : 'REMOVE',
      13 : 'RMDIR',
      14 : 'RENAME',
      15 : 'LINK',
      16 : 'READDIR',
      17 : 'READDIRPLUS',
      18 : 'FSSTAT',
      19 : 'FSINFO',
      20 : 'PATHCONF',
      21 : 'COMMIT',
    }
    class msg_type:
      CALL                    =0
      REPLY                   =1
      map=dict(
      CALL                    =0,
      REPLY                   =1
      )
      inv_map = {v: k for k, v in map.items()}
      
    class reply_stat:
      MSG_ACCEPTED            =0
      MSG_DENIED              =1
      map=dict(
      MSG_ACCEPTED            =0,
      MSG_DENIED              =1
      )
      inv_map = {v: k for k, v in map.items()}
    class accept_stat:
      SUCCESS                 = 0  # rpc executed successfully
      PROG_UNAVAIL            = 1  # remote has not exportd program
      PROG_MISMATCH           = 2  # remote can not support version #
      PROC_UNAVAIL            = 3  # program can not support procedure
      GARBAGE_ARGS            = 4  # procedure can not decode params
      SYSTEM_ERR              = 5  # e.g. memory allocation failure
      map=dict(
      SUCCESS                 = 0,
      PROG_UNAVAIL            = 1,
      PROG_MISMATCH           = 2,
      PROC_UNAVAIL            = 3,
      GARBAGE_ARGS            = 4,
      SYSTEM_ERR              = 5
      )
      inv_map = {v: k for k, v in map.items()}
    class reject_stat:
      RPC_MISMATCH            = 0  # rpc version number is not 2
      AUTH_ERROR              = 1  # remote can not authenticate caller
      map=dict(
      RPC_MISMATCH            = 0,
      AUTH_ERROR              = 1
      )
      inv_map = {v: k for k, v in map.items()}
    class auth_stat:
      AUTH_OK                 = 0  # success
                                   # failed at remote end
      AUTH_BADCRED            = 1  # bad credential (seal broken)
      AUTH_REJECTEDCRED       = 2  # client must begin new session
      AUTH_BADVERF            = 3  # bad verifier (seal broken)
      AUTH_REJECTEDVERF       = 4  # verifier expired or replayed
      AUTH_TOOWEAK            = 5  # rejected for security reasons
                                   # failed locally
      AUTH_INVALIDRESP        = 6  # bogus response verifier
      AUTH_FAILED             = 7  # reason unknown
                                   # AUTH_KERB errors; deprecated.  See [RFC2695]
      AUTH_KERB_GENERIC       = 8  # kerberos generic error
      AUTH_TIMEEXPIRE         = 9  # time of credential expired
      AUTH_TKT_FILE           = 10 # problem with ticket file
      AUTH_DECODE             = 11 # can't decode authenticator
      AUTH_NET_ADDR           = 12 # wrong net address in ticket
                                   # RPCSEC_GSS GSS related errors
      RPCSEC_GSS_CREDPROBLEM  = 13 # no credentials for user
      RPCSEC_GSS_CTXPROBLEM   = 14 # problem with context
      map=dict(
      AUTH_OK                 = 0,
      AUTH_BADCRED            = 1,
      AUTH_REJECTEDCRED       = 2,
      AUTH_BADVERF            = 3,
      AUTH_REJECTEDVERF       = 4,
      AUTH_TOOWEAK            = 5,
      AUTH_INVALIDRESP        = 6,
      AUTH_FAILED             = 7,
      AUTH_KERB_GENERIC       = 8,
      AUTH_TIMEEXPIRE         = 9,
      AUTH_TKT_FILE           = 10,
      AUTH_DECODE             = 11,
      AUTH_NET_ADDR           = 12,
      RPCSEC_GSS_CREDPROBLEM  = 13,
      RPCSEC_GSS_CTXPROBLEM   = 14
      )
      inv_map = {v: k for k, v in map.items()}
    class auth_flavor:
      AUTH_NONE               = 0  # no authentication, see RFC 1831
                                   # a.k.a. AUTH_NULL
      AUTH_SYS                = 1  # unix style (uid+gids), RFC 1831
                                   # a.k.a. AUTH_UNIX
      AUTH_SHORT              = 2  # short hand unix style, RFC 1831
      AUTH_DH                 = 3  # des style (encrypted timestamp)
                                   # a.k.a. AUTH_DES, see RFC 2695
      AUTH_KERB               = 4  # kerberos auth, see RFC 2695
      AUTH_RSA                = 5  # RSA authentication
      RPCSEC_GSS              = 6  # GSS-based RPC security for auth,
                                   # integrity and privacy, RPC 5403

      map=dict(
      AUTH_NONE               = 0,
      AUTH_SYS                = 1,
      AUTH_SHORT              = 2,
      AUTH_DH                 = 3,
      AUTH_KERB               = 4,
      AUTH_RSA                = 5,
      RPCSEC_GSS              = 6
      )
      inv_map = {v: k for k, v in map.items()}

    def __init__(self,dbytes,flowid=None,debug=False):
      """
      """
      self.parse_error=False
      self.segmentation=False
      def save_rpc_hdr():
        """
        """
        self._rpc=True
          
      def parse_credential(dbytes,verifier=False,debug=False):
        """
        """
        if len(dbytes) < 8:
          return dbytes,None
        ret=self.Credential(
          flavor=reduce(lambda x,y:256*x+y,dbytes[:4])
        )
        if debug:
          print "Credentials"
          print "  Flavor          : %s (%s)"%(self.auth_flavor.inv_map[ret.flavor],ret.flavor)
        dbytes=dbytes[4:]
        size=reduce(lambda x,y:256*x+y,dbytes[:4])
        dbytes=dbytes[4:]
        if len(dbytes) < size:
          return dbytes,None
        if ret.flavor == self.auth_flavor.AUTH_SYS:
          ret.size = size
          if debug:
            print "  Size            : %s"%ret.size
          ret.stamp=''.join(map(lambda x:'%02x'%x,dbytes[:4]))
          if debug:
            print "  Stamp           : 0x%s"%ret.stamp
          dbytes=dbytes[4:]
          # machine name: name_size (1 word) + name + pad
          name_size=reduce(lambda x,y:256*x+y,dbytes[:4])
          dbytes=dbytes[4:]
          ret.machine_name=''.join(map(lambda x: chr(x),dbytes[:name_size]))
          if debug:
            print "  Machine Name    : %s"%ret.machine_name
          dbytes=dbytes[((name_size+3)//4)*4:]   # word align
          ret.uid=reduce(lambda x,y:256*x+y,dbytes[:4])
          if debug:
            print "  UID             : %s"%ret.uid
          dbytes=dbytes[4:]
          ret.gid=reduce(lambda x,y:256*x+y,dbytes[:4])
          if debug:
            print "  GID             : %s"%ret.gid
          dbytes=dbytes[4:]
          # gid: gids_size (1 word) + gids in array
          gids_size=reduce(lambda x,y:256*x+y,dbytes[:4])
          dbytes=dbytes[4:]
          ret.gids=map(lambda z: reduce(lambda x,y:256*x+y,dbytes[z*4:(z+1)*4]),range(gids_size))
          if debug:
            print "  GIDs            : (%s) %s"%(gids_size,ret.gids)
          dbytes=dbytes[4*gids_size:]
        elif ret.flavor == self.auth_flavor.RPCSEC_GSS:
          if not verifier:
            ret.size=size
            if debug:
              print "  Size            : %s"%ret.size
            ret.gss_version=reduce(lambda x,y:256*x+y,dbytes[:4])
            if debug:
              print "  GSS Version     : %s"%ret.gss_version
            dbytes=dbytes[4:]
            ret.gss_proc=reduce(lambda x,y:256*x+y,dbytes[:4])
            if debug:
              print "  GSS Procedure   : %s"%ret.gss_proc
            dbytes=dbytes[4:]
            ret.gss_seq_num=reduce(lambda x,y:256*x+y,dbytes[:4])
            if debug:
              print "  GSS Seq Num     : %s"%ret.gss_seq_num
            dbytes=dbytes[4:]
            ret.gss_service=reduce(lambda x,y:256*x+y,dbytes[:4])
            if debug:
              print "  GSS Service     : %s"%ret.gss_service
            dbytes=dbytes[4:]
            # gss_context : context_size (1 word) + context + pad
            context_size=reduce(lambda x,y:256*x+y,dbytes[:4])
            dbytes=dbytes[4:]
            ret.gss_context=''.join(map(lambda x: chr(x),dbytes[:context_size]))
            if debug:
              print "  GSS Context     : %s"%ret.gss_context
            dbytes=dbytes[((context_size+3)//4)*4:]   # word align
          else:
            ret.size=size
            if debugseq_num:
              print "  Size            : %s"%ret.size
            # gss_token : token_size (1 word) + token + pad
            token_size=reduce(lambda x,y:256*x+y,dbytes[:4])
            dbytes=dbytes[4:]
            ret.gss_token=''.join(map(lambda x: chr(x),dbytes[:token_size]))
            if debug:
              print "  GSS Token       : %s"%ret.gss_token
            dbytes=dbytes[((token_size+3)//4)*4:]   # word align
        else:
          ret.size=size
          if debug:
            print "  Size            : %s"%ret.size
          if ret.size !=0:
            ret.data=''.join(map(lambda x: chr(x),dbytes[:ret.size]))
            dbytes=dbytes[((ret.size+3)//4)*4:]   # word align
        return dbytes,ret
      self.fragment_hdr=self.Header(
        last_fragment=dbytes[0]>>7,
        size=(dbytes[0]&0x7f<<24)+reduce(lambda x,y:256*x+y,dbytes[1:4])
      )
      if debug:
        print """
Fragment Header
  last fragment   : %s
  size            : %s
      """%(
        self.fragment_hdr.last_fragment,
        self.fragment_hdr.size)
      if self.fragment_hdr.last_fragment ==0:
        #flowid2bytes[flowid]=[self.fragment_hdr.size+4,dbytes[:]] # save hdr size and tcp payload
        if debug:
          print "rpc fragmentation with size of %d and tcp payload of %d"% (self.fragment_hdr.size,len(dbytes))
          #print flowid2bytes[flowid]
        return  
      if self.fragment_hdr.size > (len(dbytes)-4):
        self.segmentation=True
        flowid2bytes[flowid]=[self.fragment_hdr.size+4,dbytes[:]] # save hdr size and tcp payload
        if debug:
          print "tcp segmentation : missing bytes %d"% (self.fragment_hdr.size-len(dbytes)+4)
          print flowid2bytes[flowid]
        self.segmentation=True
        return  
      dbytes=dbytes[4:]
      self.xid = reduce(lambda x,y:256*x+y,dbytes[:4])
      if debug:
        print "XID               : %s"%self.xid
      dbytes=dbytes[4:]
      self.type = reduce(lambda x,y:256*x+y,dbytes[:4])
      if self.type !=self.msg_type.CALL and self.type != self.msg_type.REPLY:
        if debug:
          print "Error: msg type",self.type
        self.parse_error=True
        return
      if debug:
        print "Type              : %s (%s)"%(self.msg_type.inv_map[self.type],self.type)
      dbytes=dbytes[4:]
      if self.type == self.msg_type.CALL:
        # RPC call
        self.rpc_version=reduce(lambda x,y:256*x+y,dbytes[:4])
        if debug:
          print "RPC Version       : %s"%self.rpc_version
        dbytes=dbytes[4:]
        self.program    =reduce(lambda x,y:256*x+y,dbytes[:4])
        if debug:
          print "Program           : %s (%s)"%(self.program2name[self.program],self.program)
        dbytes=dbytes[4:]
        self.version    =reduce(lambda x,y:256*x+y,dbytes[:4])
        if debug:
          print "Program Version   : %s"%self.version
        dbytes=dbytes[4:]
        self.procedure  =reduce(lambda x,y:256*x+y,dbytes[:4])
        if debug:
          print "Procedure         : %s (%s)"%(self.procedure2name[self.procedure],self.procedure)
        dbytes=dbytes[4:]
        dbytes,self.credential =parse_credential(dbytes)
        if self.credential is not None:
          dbytes,self.verifier =parse_credential(dbytes,verifier=True)
          self.payload=dbytes
          if self.rpc_version ==2 and (self.credential.flavor not in [0,1] or self.verifier is not None):
            save_rpc_hdr()
      elif self.type == self.msg_type.REPLY:
        # RPC reply
        self.reply_status=reduce(lambda x,y:256*x+y,dbytes[:4])
        dbytes=dbytes[4:]
        if self.reply_status == self.reply_stat.MSG_ACCEPTED:
          dbytes,self.verifier =parse_credential(dbytes,verifier=True)
          if self.verifier is not None:
            self.accepted_status=reduce(lambda x,y:256*x+y,dbytes[:4])
            dbytes=dbytes[4:]
            if self.accepted_status == self.accept_stat.PROG_MISMATCH:
              self.prog_mismatch=Prog(
                low=reduce(lambda x,y:256*x+y,dbytes[:4]),
                high=reduce(lambda x,y:256*x+y,dbytes[4:8])
              )
              dbytes=dbytes[8:]
              self.payload=dbytes
              save_rpc_hdr()
            elif self.accepted_status is not None:
              self.payload=dbytes
              save_rpc_hdr()
        elif self.reply_status == self.reply_stat.MSG_DENIED:
          self.rejected_status=reduce(lambda x,y:256*x+y,dbytes[:4])
          dbytes=dbytes[4:]
          if self.rejected_status == self.accept_stat.PROG_MISMATCH:
            self.rpc_mismatch=Prog(
              low=reduce(lambda x,y:256*x+y,dbytes[:4]),
              high=reduce(lambda x,y:256*x+y,dbytes[4:8])
            )
            dbytes=dbytes[8:]
          elif self.rejected_status == self.accept_stat.AUTH_ERROR:
            self.auth_status=reduce(lambda x,y:256*x+y,dbytes[:4])
            dbytes=dbytes[4:]
            if self.auth_status is not None:
              self.payload=dbytes
              save_rpc_hdr()
          elif self.rejected_status is not None:
            self.payload=dbytes
            save_rpc_hdr()
        elif self.reply_status is not None:
          self.payload=dbytes
          save_rpc_hdr()
    def get(self):
      print """
Fragment Header
  %s
XID               : %s
Type              : %s (%s)
      """%(
      "\n  ".join(self.fragment_hdr.get()),
      self.xid,
      self.msg_type.inv_map[self.type],self.type)
      if self.type == self.msg_type.CALL:
        print """
RPC Version       : %s
Program           : %s (%s)
Version           : %s
Procedure         : %s (%s)
Credential
  %s
"""%(
        self.rpc_version,
        self.program2name[self.program],self.program,
        self.version,
        self.procedure2name[self.procedure],self.procedure,
        "\n  ".join(self.credential.get()))
        if self.credential is not None:
          print """
Verifier
  %s
"""%(
          "\n  ".join(self.verifier.get()))
      elif self.type == self.msg_type.REPLY:
        print "Reply Status      : %s (%s)"%(self.reply_stat.inv_map[self.reply_status],self.reply_status)
        if self.reply_status == self.reply_stat.MSG_ACCEPTED:
          print """
Verifier
  %s
"""%(
          "\n  ".join(self.verifier.get()))
          if self.verifier is not None:
            print "Accepted Status   : %s (%s)"%(self.accept_stat.inv_map[self.accepted_status],self.accepted_status)
            if self.accepted_status == self.accept_stat.PROG_MISMATCH:
              print """
Program
  %s
"""%(
          "\n  ".join(self.prog_mismatch.get()))
        elif self.reply_status == self.reply_stat.MSG_DENIED:
          print "Rejected Status      : %s (%s)"%(self.reject_stat.inv_map[self.rejected_status],self.rejected_status)
          if self.rejected_status == self.accept_stat.PROG_MISMATCH:
            print """
Program
  %s
"""%(
            "\n  ".join(self.rpc_mismatch.get()))
          elif self.rejected_status == self.accept_stat.AUTH_ERROR:
            print """
Program
  %s
"""%(
            "\n  ".join(self.auth_status.get()))
  class nfs_hdr(rpc_hdr):
    """
    """
    nfs_ftype4 = {
      1                 : 'NF4REG',
      2                 : 'NF4DIR',
      3                 : 'NF4BLK',
      4                 : 'NF4CHR',
      5                 : 'NF4LNK',
      6                 : 'NF4SOCK',
      7                 : 'NF4FIFO',
      8                 : 'NF4ATTRDIR',
      9                 : 'NF4NAMEDATTR',
    }
    nfsstat4 = {
      0                 : 'NFS4_OK',
      1                 : 'NFS4ERR_PERM',
      2                 : 'NFS4ERR_NOENT',
      5                 : 'NFS4ERR_IO',
      6                 : 'NFS4ERR_NXIO',
      13                : 'NFS4ERR_ACCESS',
      17                : 'NFS4ERR_EXIST',
      18                : 'NFS4ERR_XDEV',
      20                : 'NFS4ERR_NOTDIR',
      21                : 'NFS4ERR_ISDIR',
      22                : 'NFS4ERR_INVAL',
      27                : 'NFS4ERR_FBIG',
      28                : 'NFS4ERR_NOSPC',
      30                : 'NFS4ERR_ROFS',
      31                : 'NFS4ERR_MLINK',
      63                : 'NFS4ERR_NAMETOOLONG',
      66                : 'NFS4ERR_NOTEMPTY',
      69                : 'NFS4ERR_DQUOT',
      70                : 'NFS4ERR_STALE',
      10001             : 'NFS4ERR_BADHANDLE',
      10003             : 'NFS4ERR_BAD_COOKIE',
      10004             : 'NFS4ERR_NOTSUPP',
      10005             : 'NFS4ERR_TOOSMALL',
      10006             : 'NFS4ERR_SERVERFAULT',
      10007             : 'NFS4ERR_BADTYPE',
      10008             : 'NFS4ERR_DELAY',
      10009             : 'NFS4ERR_SAME',
      10010             : 'NFS4ERR_DENIED',
      10011             : 'NFS4ERR_EXPIRED',
      10012             : 'NFS4ERR_LOCKED',
      10013             : 'NFS4ERR_GRACE',
      10014             : 'NFS4ERR_FHEXPIRED',
      10015             : 'NFS4ERR_SHARE_DENIED',
      10016             : 'NFS4ERR_WRONGSEC',
      10017             : 'NFS4ERR_CLID_INUSE',
      10018             : 'NFS4ERR_RESOURCE',
      10019             : 'NFS4ERR_MOVED',
      10020             : 'NFS4ERR_NOFILEHANDLE',
      10021             : 'NFS4ERR_MINOR_VERS_MISMATCH',
      10022             : 'NFS4ERR_STALE_CLIENTID',
      10023             : 'NFS4ERR_STALE_STATEID',
      10024             : 'NFS4ERR_OLD_STATEID',
      10025             : 'NFS4ERR_BAD_STATEID',
      10026             : 'NFS4ERR_BAD_SEQID',
      10027             : 'NFS4ERR_NOT_SAME',
      10028             : 'NFS4ERR_LOCK_RANGE',
      10029             : 'NFS4ERR_SYMLINK',
      10030             : 'NFS4ERR_RESTOREFH',
      10031             : 'NFS4ERR_LEASE_MOVED',
      10032             : 'NFS4ERR_ATTRNOTSUPP',
      10033             : 'NFS4ERR_NO_GRACE',
      10034             : 'NFS4ERR_RECLAIM_BAD',
      10035             : 'NFS4ERR_RECLAIM_CONFLICT',
      10036             : 'NFS4ERR_BADXDR',
      10037             : 'NFS4ERR_LOCKS_HELD',
      10038             : 'NFS4ERR_OPENMODE',
      10039             : 'NFS4ERR_BADOWNER',
      10040             : 'NFS4ERR_BADCHAR',
      10041             : 'NFS4ERR_BADNAME',
      10042             : 'NFS4ERR_BAD_RANGE',
      10043             : 'NFS4ERR_LOCK_NOTSUPP',
      10044             : 'NFS4ERR_OP_ILLEGAL',
      10045             : 'NFS4ERR_DEADLOCK',
      10046             : 'NFS4ERR_FILE_OPEN',
      10047             : 'NFS4ERR_ADMIN_REVOKED',
      10048             : 'NFS4ERR_CB_PATH_DOWN',
      10049             : 'NFS4ERR_BADIOMODE',
      10050             : 'NFS4ERR_BADLAYOUT',
      10051             : 'NFS4ERR_BAD_SESSION_DIGEST',
      10052             : 'NFS4ERR_BADSESSION',
      10053             : 'NFS4ERR_BADSLOT',
      10054             : 'NFS4ERR_COMPLETE_ALREADY',
      10055             : 'NFS4ERR_CONN_NOT_BOUND_TO_SESSION',
      10056             : 'NFS4ERR_DELEG_ALREADY_WANTED',
      10057             : 'NFS4ERR_BACK_CHAN_BUSY',
      10058             : 'NFS4ERR_LAYOUTTRYLATER',
      10059             : 'NFS4ERR_LAYOUTUNAVAILABLE',
      10060             : 'NFS4ERR_NOMATCHING_LAYOUT',
      10061             : 'NFS4ERR_RECALLCONFLICT',
      10062             : 'NFS4ERR_UNKNOWN_LAYOUTTYPE',
      10063             : 'NFS4ERR_SEQ_MISORDERED',
      10064             : 'NFS4ERR_SEQUENCE_POS',
      10065             : 'NFS4ERR_REQ_TOO_BIG',
      10066             : 'NFS4ERR_REP_TOO_BIG',
      10067             : 'NFS4ERR_REP_TOO_BIG_TO_CACHE',
      10068             : 'NFS4ERR_RETRY_UNCACHED_REP',
      10069             : 'NFS4ERR_UNSAFE_COMPOUND',
      10070             : 'NFS4ERR_TOO_MANY_OPS',
      10071             : 'NFS4ERR_OP_NOT_IN_SESSION',
      10072             : 'NFS4ERR_HASH_ALG_UNSUPP',
      10073             : 'NFS4ERR_CONN_BINDING_NOT_ENFORCED',
      10074             : 'NFS4ERR_CLIENTID_BUSY',
      10075             : 'NFS4ERR_PNFS_IO_HOLE',
      10076             : 'NFS4ERR_SEQ_FALSE_RETRY',
      10077             : 'NFS4ERR_BAD_HIGH_SLOT',
      10078             : 'NFS4ERR_DEADSESSION',
      10079             : 'NFS4ERR_ENCR_ALG_UNSUPP',
      10080             : 'NFS4ERR_PNFS_NO_LAYOUT',
      10081             : 'NFS4ERR_NOT_ONLY_OP',
      10082             : 'NFS4ERR_WRONG_CRED',
      10083             : 'NFS4ERR_WRONG_TYPE',
      10084             : 'NFS4ERR_DIRDELEG_UNAVAIL',
      10085             : 'NFS4ERR_REJECT_DELEG',
      10086             : 'NFS4ERR_RETURNCONFLICT',
      10087             : 'NFS4ERR_DELEG_REVOKED',
    }
    time_how4 = {
      0                 : 'SET_TO_SERVER_TIME4',
      1                 : 'SET_TO_CLIENT_TIME4',
    }
    layouttype4 = {
      0x1               : 'LAYOUT4_NFSV4_1_FILES',
      0x2               : 'LAYOUT4_OSD2_OBJECTS',
      0x3               : 'LAYOUT4_BLOCK_VOLUME',
    }
    layoutiomode4 = {
      1                 : 'LAYOUTIOMODE4_READ',
      2                 : 'LAYOUTIOMODE4_RW',
      3                 : 'LAYOUTIOMODE4_ANY',
    }
    LAYOUT4_RET_REC_FILE                 = 1
    LAYOUT4_RET_REC_FSID                 = 2
    LAYOUT4_RET_REC_ALL                  = 3
    layoutreturn_type4 = {
      LAYOUT4_RET_REC_FILE              : 'LAYOUTRETURN4_FILE',
      LAYOUT4_RET_REC_FSID              : 'LAYOUTRETURN4_FSID',
      LAYOUT4_RET_REC_ALL               : 'LAYOUTRETURN4_ALL',
    }
    fs4_status_type = {
      1                 : 'STATUS4_FIXED',
      2                 : 'STATUS4_UPDATED',
      3                 : 'STATUS4_VERSIONED',
      4                 : 'STATUS4_WRITABLE',
      5                 : 'STATUS4_REFERRAL',
    }
    nfs_lock_type4 = {
      1                 : 'READ_LT',
      2                 : 'WRITE_LT',
      3                 : 'READW_LT',
      4                 : 'WRITEW_LT',
    }
    ssv_subkey4 = {
      1                 : 'SSV4_SUBKEY_MIC_I2T',
      2                 : 'SSV4_SUBKEY_MIC_T2I',
      3                 : 'SSV4_SUBKEY_SEAL_I2T',
      4                 : 'SSV4_SUBKEY_SEAL_T2I',
    }
    NFL4_UFLG_MASK                  = 0x0000003FL
    NFL4_UFLG_DENSE                 = 0x00000001L
    NFL4_UFLG_COMMIT_THRU_MDS       = 0x00000002L
    NFL4_UFLG_STRIPE_UNIT_SIZE_MASK = 0xFFFFFFC0L
    filelayout_hint_care4 = {
      NFL4_UFLG_DENSE           : 'NFLH4_CARE_DENSE',
      NFL4_UFLG_COMMIT_THRU_MDS : 'NFLH4_CARE_COMMIT_THRU_MDS',
      0x00000040L               : 'NFLH4_CARE_STRIPE_UNIT_SIZE',
      0x00000080L               : 'NFLH4_CARE_STRIPE_COUNT',
    }
    ACCESS4_READ                = 0x00000001L
    ACCESS4_LOOKUP              = 0x00000002L
    ACCESS4_MODIFY              = 0x00000004L
    ACCESS4_EXTEND              = 0x00000008L
    ACCESS4_DELETE              = 0x00000010L
    ACCESS4_EXECUTE             = 0x00000020L
    createmode4 = {
      0                 : 'UNCHECKED4',
      1                 : 'GUARDED4',
      2                 : 'EXCLUSIVE4',
      3                 : 'EXCLUSIVE4_1',
    }
    opentype4 = {
      0                 : 'OPEN4_NOCREATE',
      1                 : 'OPEN4_CREATE',
    }
    limit_by4 = {
      1                 : 'NFS_LIMIT_SIZE',
      2                 : 'NFS_LIMIT_BLOCKS',
    }
    open_delegation_type4 = {
      0                 : 'OPEN_DELEGATE_NONE',
      1                 : 'OPEN_DELEGATE_READ',
      2                 : 'OPEN_DELEGATE_WRITE',
      3                 : 'OPEN_DELEGATE_NONE_EXT',
    }
    open_claim_type4 = {
      0                 : 'CLAIM_NULL',
      1                 : 'CLAIM_PREVIOUS',
      2                 : 'CLAIM_DELEGATE_CUR',
      3                 : 'CLAIM_DELEGATE_PREV',
      4                 : 'CLAIM_FH',
      5                 : 'CLAIM_DELEG_CUR_FH',
      6                 : 'CLAIM_DELEG_PREV_FH',
    }
    why_no_delegation4 = {
      0                 : 'WND4_NOT_WANTED',
      1                 : 'WND4_CONTENTION',
      2                 : 'WND4_RESOURCE',
      3                 : 'WND4_NOT_SUPP_FTYPE',
      4                 : 'WND4_WRITE_DELEG_NOT_SUPP_FTYPE',
      5                 : 'WND4_NOT_SUPP_UPGRADE',
      6                 : 'WND4_NOT_SUPP_DOWNGRADE',
      7                 : 'WND4_CANCELED',
      8                 : 'WND4_IS_DIR',
    }
    OPEN4_RESULT_CONFIRM               = 0x00000002L
    OPEN4_RESULT_LOCKTYPE_POSIX        = 0x00000004L
    OPEN4_RESULT_PRESERVE_UNLINKED     = 0x00000008L
    OPEN4_RESULT_MAY_NOTIFY_LOCK       = 0x00000020L
    rpc_gss_svc_t = {
      1                 : 'RPC_GSS_SVC_NONE',
      2                 : 'RPC_GSS_SVC_INTEGRITY',
      3                 : 'RPC_GSS_SVC_PRIVACY',
    }
    stable_how4 = {
      0                 : 'UNSTABLE4',
      1                 : 'DATA_SYNC4',
      2                 : 'FILE_SYNC4',
    }
    channel_dir_from_client4 = {
      0x1               : 'CDFC4_FORE',
      0x2               : 'CDFC4_BACK',
      0x3               : 'CDFC4_FORE_OR_BOTH',
      0x7               : 'CDFC4_BACK_OR_BOTH',
    }
    channel_dir_from_server4 = {
      0x1               : 'CDFS4_FORE',
      0x2               : 'CDFS4_BACK',
      0x3               : 'CDFS4_BOTH',
    }
    EXCHGID4_FLAG_SUPP_MOVED_REFER     = 0x00000001L
    EXCHGID4_FLAG_SUPP_MOVED_MIGR      = 0x00000002L
    EXCHGID4_FLAG_BIND_PRINC_STATEID   = 0x00000100L
    EXCHGID4_FLAG_USE_NON_PNFS         = 0x00010000L
    EXCHGID4_FLAG_USE_PNFS_MDS         = 0x00020000L
    EXCHGID4_FLAG_USE_PNFS_DS          = 0x00040000L
    EXCHGID4_FLAG_MASK_PNFS            = 0x00070000L
    EXCHGID4_FLAG_UPD_CONFIRMED_REC_A  = 0x40000000L
    EXCHGID4_FLAG_CONFIRMED_R          = 0x80000000L
    state_protect_how4 = {
      0                 : 'SP4_NONE',
      1                 : 'SP4_MACH_CRED',
      2                 : 'SP4_SSV',
    }
    CREATE_SESSION4_FLAG_PERSIST       = 0x00000001L
    CREATE_SESSION4_FLAG_CONN_BACK_CHAN= 0x00000002L
    CREATE_SESSION4_FLAG_CONN_RDMA     = 0x00000004L
    gddrnf4_status = {
      0                 : 'GDD4_OK',
      1                 : 'GDD4_UNAVAIL',
    }
    secinfo_style4 = {
      0                 : 'SECINFO_STYLE4_CURRENT_FH',
      1                 : 'SECINFO_STYLE4_PARENT',
    }
    SEQ4_STATUS_CB_PATH_DOWN                     = 0x00000001L
    SEQ4_STATUS_CB_GSS_CONTEXTS_EXPIRING         = 0x00000002L
    SEQ4_STATUS_CB_GSS_CONTEXTS_EXPIRED          = 0x00000004L
    SEQ4_STATUS_EXPIRED_ALL_STATE_REVOKED        = 0x00000008L
    SEQ4_STATUS_EXPIRED_SOME_STATE_REVOKED       = 0x00000010L
    SEQ4_STATUS_ADMIN_STATE_REVOKED              = 0x00000020L
    SEQ4_STATUS_RECALLABLE_STATE_REVOKED         = 0x00000040L
    SEQ4_STATUS_LEASE_MOVED                      = 0x00000080L
    SEQ4_STATUS_RESTART_RECLAIM_NEEDED           = 0x00000100L
    SEQ4_STATUS_CB_PATH_DOWN_SESSION             = 0x00000200L
    SEQ4_STATUS_BACKCHANNEL_FAULT                = 0x00000400L
    SEQ4_STATUS_DEVID_CHANGED                    = 0x00000800L
    SEQ4_STATUS_DEVID_DELETED                    = 0x00001000L
    nfs_opnum4 = {
      3                 : 'OP_ACCESS',
      4                 : 'OP_CLOSE',
      5                 : 'OP_COMMIT',
      6                 : 'OP_CREATE',
      7                 : 'OP_DELEGPURGE',
      8                 : 'OP_DELEGRETURN',
      9                 : 'OP_GETATTR',
      10                : 'OP_GETFH',
      11                : 'OP_LINK',
      12                : 'OP_LOCK',
      13                : 'OP_LOCKT',
      14                : 'OP_LOCKU',
      15                : 'OP_LOOKUP',
      16                : 'OP_LOOKUPP',
      17                : 'OP_NVERIFY',
      18                : 'OP_OPEN',
      19                : 'OP_OPENATTR',
      20                : 'OP_OPEN_CONFIRM',
      21                : 'OP_OPEN_DOWNGRADE',
      22                : 'OP_PUTFH',
      23                : 'OP_PUTPUBFH',
      24                : 'OP_PUTROOTFH',
      25                : 'OP_READ',
      26                : 'OP_READDIR',
      27                : 'OP_READLINK',
      28                : 'OP_REMOVE',
      29                : 'OP_RENAME',
      30                : 'OP_RENEW',
      31                : 'OP_RESTOREFH',
      32                : 'OP_SAVEFH',
      33                : 'OP_SECINFO',
      34                : 'OP_SETATTR',
      35                : 'OP_SETCLIENTID',
      36                : 'OP_SETCLIENTID_CONFIRM',
      37                : 'OP_VERIFY',
      38                : 'OP_WRITE',
      39                : 'OP_RELEASE_LOCKOWNER',
      40                : 'OP_BACKCHANNEL_CTL',
      41                : 'OP_BIND_CONN_TO_SESSION',
      42                : 'OP_EXCHANGE_ID',
      43                : 'OP_CREATE_SESSION',
      44                : 'OP_DESTROY_SESSION',
      45                : 'OP_FREE_STATEID',
      46                : 'OP_GET_DIR_DELEGATION',
      47                : 'OP_GETDEVICEINFO',
      48                : 'OP_GETDEVICELIST',
      49                : 'OP_LAYOUTCOMMIT',
      50                : 'OP_LAYOUTGET',
      51                : 'OP_LAYOUTRETURN',
      52                : 'OP_SECINFO_NO_NAME',
      53                : 'OP_SEQUENCE',
      54                : 'OP_SET_SSV',
      55                : 'OP_TEST_STATEID',
      56                : 'OP_WANT_DELEGATION',
      57                : 'OP_DESTROY_CLIENTID',
      58                : 'OP_RECLAIM_COMPLETE',
      10044             : 'OP_ILLEGAL',
    }
    layoutrecall_type4 = {
      LAYOUT4_RET_REC_FILE              : 'LAYOUTRECALL4_FILE',
      LAYOUT4_RET_REC_FSID              : 'LAYOUTRECALL4_FSID',
      LAYOUT4_RET_REC_ALL               : 'LAYOUTRECALL4_ALL',
    }
    notify_type4 = {
      0                 : 'NOTIFY4_CHANGE_CHILD_ATTRS',
      1                 : 'NOTIFY4_CHANGE_DIR_ATTRS',
      2                 : 'NOTIFY4_REMOVE_ENTRY',
      3                 : 'NOTIFY4_ADD_ENTRY',
      4                 : 'NOTIFY4_RENAME_ENTRY',
      5                 : 'NOTIFY4_CHANGE_COOKIE_VERIFIER',
    }
    RCA4_TYPE_MASK_RDATA_DLG             = 0
    RCA4_TYPE_MASK_WDATA_DLG             = 1
    RCA4_TYPE_MASK_DIR_DLG               = 2
    RCA4_TYPE_MASK_FILE_LAYOUT           = 3
    RCA4_TYPE_MASK_BLK_LAYOUT_MIN        = 4
    RCA4_TYPE_MASK_BLK_LAYOUT_MAX        = 7
    RCA4_TYPE_MASK_OBJ_LAYOUT_MIN        = 8
    RCA4_TYPE_MASK_OBJ_LAYOUT_MAX        = 11
    RCA4_TYPE_MASK_OTHER_LAYOUT_MIN      = 12
    RCA4_TYPE_MASK_OTHER_LAYOUT_MAX      = 15
    notify_deviceid_type4 = {
      1                 : 'NOTIFY_DEVICEID4_CHANGE',
      2                 : 'NOTIFY_DEVICEID4_DELETE',
    }
    nfs_cb_opnum4 = {
      3                 : 'OP_CB_GETATTR',
      4                 : 'OP_CB_RECALL',
      5                 : 'OP_CB_LAYOUTRECALL',
      6                 : 'OP_CB_NOTIFY',
      7                 : 'OP_CB_PUSH_DELEG',
      8                 : 'OP_CB_RECALL_ANY',
      9                 : 'OP_CB_RECALLABLE_OBJ_AVAIL',
      10                : 'OP_CB_RECALL_SLOT',
      11                : 'OP_CB_SEQUENCE',
      12                : 'OP_CB_WANTS_CANCELLED',
      13                : 'OP_CB_NOTIFY_LOCK',
      14                : 'OP_CB_NOTIFY_DEVICEID',
      10044             : 'OP_CB_ILLEGAL',
    }
    def __init__(self,rpcobj,calcrc32,debug=False):
      """
      """
      self.dbytes=rpcobj.payload
      self.rpcobj=rpcobj
      self.calcrc32=calcrc32

    def call(self,debug=False):
      """
      """
      # fixme
      return
      def parse_object():
        self.fhlength=reduce(lambda x,y:256*x+y,self.dbytes[:4])
        if debug:
          print "File Handle Length: %s"%self.fhlength
        self.dbytes=self.dbytes[4:]
        self.fhandle=''.join(map(lambda x:'%02x'%x,self.dbytes[:self.fhlength]))
        if debug:
          print "File Handle       : %s"%self.fhandle
        self.hashv=''.join(self.calcrc32(self.dbytes[:self.fhlength])[::-1])
        if debug:
          print "Hash (CRC-32)     : 0x%s"%self.hashv
        self.dbytes=self.dbytes[self.fhlength:]
      if self.rpcobj.version == 3:
        if self.rpcobj.procedure2name[self.rpcobj.procedure]=='NULL':
          pass
        elif self.rpcobj.procedure2name[self.rpcobj.procedure]=='SETATTR': # 2
          pass
        elif self.rpcobj.procedure2name[self.rpcobj.procedure]=='LINK': # 5
          pass
        elif self.rpcobj.procedure2name[self.rpcobj.procedure]=='CREATE': # 8
          pass
        elif self.rpcobj.procedure2name[self.rpcobj.procedure]=='MKDIR': # 9
          pass
        elif self.rpcobj.procedure2name[self.rpcobj.procedure]=='SYMLINK': # 10
          pass
        elif self.rpcobj.procedure2name[self.rpcobj.procedure]=='MKNOD': # 11
          pass
        elif self.rpcobj.procedure2name[self.rpcobj.procedure]=='REMOVE': # 12
          pass
        elif self.rpcobj.procedure2name[self.rpcobj.procedure]=='RMDIR': # 13
          pass
        elif self.rpcobj.procedure2name[self.rpcobj.procedure]=='RENAME': # 14
          pass
        elif self.rpcobj.procedure2name[self.rpcobj.procedure]=='LINK': # 15
          pass
        elif self.rpcobj.procedure2name[self.rpcobj.procedure]=='READDIRPLUS': # 17
          pass
        elif self.rpcobj.procedure2name[self.rpcobj.procedure]=='FSSTAT': #18
          pass
        elif self.rpcobj.procedure2name[self.rpcobj.procedure]=='PATHCONF': # 19
          pass
        elif self.rpcobj.procedure2name[self.rpcobj.procedure]=='FSINFO': # 20
          pass
        elif self.rpcobj.procedure2name[self.rpcobj.procedure]=='ACCESS':
          parse_object()
          self.access=self.dbytes[3]
          if debug:
            print "Access            : 0x%02x"%self.access
            if self.access & self.ACCESS4_READ:
              print "        .... .... = 0x01 READ: allowed"
            if self.access & self.ACCESS4_LOOKUP:
              print "        .... .... = 0x02 LOOKUP: allowed"
            if self.access & self.ACCESS4_MODIFY:
              print "        .... .... = 0x04 MODIFY: allowed"
            if self.access & self.ACCESS4_EXTEND:
              print "        .... .... = 0x08 EXTEND: allowed"
            if self.access & self.ACCESS4_DELETE:
              print "        .... .... = 0x10 DELETE: allowed"
            if self.access & self.ACCESS4_EXECUTE:
              print "        .... .... = 0x20 EXECUTE: allowed"
        elif self.rpcobj.procedure2name[self.rpcobj.procedure]=='LOOKUP':
          parse_object()
          self.namelength=reduce(lambda x,y:256*x+y,self.dbytes[:4])
          if debug:
            print "Name Length       : %s"%self.namelength
          self.dbytes=self.dbytes[4:]
          self.name=''.join(map(lambda x:chr(x),self.dbytes[:self.namelength]))
          if debug:
            print "Name              : %s"%self.name
        elif self.rpcobj.procedure2name[self.rpcobj.procedure]=='READ':
          parse_object()
          self.offset=reduce(lambda x,y:256*x+y,self.dbytes[:8])
          if debug:
            print "File Offset       : %s"%self.offset
          self.dbytes=self.dbytes[8:]
          self.count=reduce(lambda x,y:256*x+y,self.dbytes[:4])
          if debug:
            print "Count             : %s"%self.count
          self.dbytes=self.dbytes[4:]
        elif self.rpcobj.procedure2name[self.rpcobj.procedure]=='GETATTR':
          parse_object()
        elif self.rpcobj.procedure2name[self.rpcobj.procedure]=='WRITE':
          parse_object()
          self.offset=reduce(lambda x,y:256*x+y,self.dbytes[:8])
          if debug:
            print "File Offset       : %s"%self.offset
          self.dbytes=self.dbytes[8:]
          self.count=reduce(lambda x,y:256*x+y,self.dbytes[:4])
          if debug:
            print "Count             : %s"%self.count
          self.dbytes=self.dbytes[4:]
          self.stable=reduce(lambda x,y:256*x+y,self.dbytes[:4])
          if debug:
            print "Stable            : %s (%s)"%(self.stable_how4[self.stable],self.stable)
          self.dbytes=self.dbytes[4:]
          self.datalength=reduce(lambda x,y:256*x+y,self.dbytes[:4])
          if debug:
            print "Data Length       : %s"%self.datalength
          self.dbytes=self.dbytes[4:]
          self.data=''.join(map(lambda x: '%02x'%x,self.dbytes[:self.datalength]))
          if debug:
            print "Data              : %s"%self.data
          self.dbytes=self.dbytes[self.datalength:]
          self.fill=''.join(map(lambda x: '%02x'%x,self.dbytes))
          if debug:
            print "Fill bytes         : %s"%self.fill
        #elif callobj.procedure2name[callobj.procedure]=='GETATTR':
        #  parse_object_attribute()
        
    def reply(self,callobj,debug=False):
      """
      """
      # fixme
      return
      def parse_object():
        self.fhlength=reduce(lambda x,y:256*x+y,self.dbytes[:4])
        if debug:
          print "File Handle Length: %s"%self.fhlength
        self.dbytes=self.dbytes[4:]
        self.fhandle=''.join(map(lambda x:'%02x'%x,self.dbytes[:self.fhlength]))
        if debug:
          print "File Handle       : %s"%self.fhandle
        self.hashv=''.join(self.calcrc32(self.dbytes[:self.fhlength])[::-1])
        if debug:
          print "Hash (CRC-32)     : 0x%s"%self.hashv
        self.dbytes=self.dbytes[self.fhlength:]
      def parse_status():
        self.status=reduce(lambda x,y:256*x+y,self.dbytes[:4])
        if debug:
          print "Status            : %s (%s)"%(self.nfsstat4[self.status], self.status)
        self.dbytes=self.dbytes[4:]
      def parse_object_attribute():
        if len(self.dbytes)==0: return
        self.attr_follow=reduce(lambda x,y:256*x+y,self.dbytes[:4])
        if debug:
          print "Attribute Follow  : value follows (%s)"%self.attr_follow
        self.dbytes=self.dbytes[4:]
        self.ftype=reduce(lambda x,y:256*x+y,self.dbytes[:4])
        if debug:
          print "Type              : %s (%s)"%(self.nfs_ftype4[self.ftype], self.ftype)
        self.dbytes=self.dbytes[4:]
        self.Mode=reduce(lambda x,y:256*x+y,self.dbytes[:4])
        if debug:
          print "Mode              : %s"%oct(self.Mode)
        self.dbytes=self.dbytes[4:]
        self.nlink=reduce(lambda x,y:256*x+y,self.dbytes[:4])
        if debug:
          print "nlink             : %s"%self.nlink
        self.dbytes=self.dbytes[4:]
        self.uid=reduce(lambda x,y:256*x+y,self.dbytes[:4])
        if debug:
          print "uid               : %s"%self.uid
        self.dbytes=self.dbytes[4:]
        self.gid=reduce(lambda x,y:256*x+y,self.dbytes[:4])
        if debug:
          print "gid               : %s"%self.gid
        self.dbytes=self.dbytes[4:]
        self.size=reduce(lambda x,y:256*x+y,self.dbytes[:8])
        if debug:
          print "size              : %s"%self.size
        self.dbytes=self.dbytes[8:]
        self.used=reduce(lambda x,y:256*x+y,self.dbytes[:8])
        if debug:
          print "used              : %s"%self.used
        self.dbytes=self.dbytes[8:]
        self.rdev=",".join(map(lambda z:"%d"%reduce(lambda x,y:256*x+y,self.dbytes[z*4:(z+1)*4]),range(2)))
        if debug:
          print "rdev              : %s"%self.rdev
        self.dbytes=self.dbytes[8:]
        self.fsid=reduce(lambda x,y:256*x+y,self.dbytes[:8])
        if debug:
          print "fsid              : %016x (%s)"%(self.fsid,self.fsid)
        self.dbytes=self.dbytes[8:]
        self.fileid=reduce(lambda x,y:256*x+y,self.dbytes[:8])
        if debug:
          print "fileid            : %s"%self.fileid
        self.dbytes=self.dbytes[8:]
        self.asec=reduce(lambda x,y:256*x+y,self.dbytes[:4])
        self.ansec=reduce(lambda x,y:256*x+y,self.dbytes[4:8])
        if debug:
          print "atime : %s.%s"%(datetime.datetime.fromtimestamp(self.asec).strftime('%b %d,%Y %H:%M:%S'),self.ansec)
          print "  seconds         : %s"%self.asec
          print "  nano seconds    : %s"%self.ansec
        self.dbytes=self.dbytes[8:]
        self.msec=reduce(lambda x,y:256*x+y,self.dbytes[:4])
        self.mnsec=reduce(lambda x,y:256*x+y,self.dbytes[4:8])
        if debug:
          print "mtime : %s.%s"%(datetime.datetime.fromtimestamp(self.msec).strftime('%b %d,%Y %H:%M:%S'),self.mnsec)
          print "  seconds         : %s"%self.msec
          print "  nano seconds    : %s"%self.mnsec
        self.dbytes=self.dbytes[8:]
        if len(self.dbytes)==0: return
        self.csec=reduce(lambda x,y:256*x+y,self.dbytes[:4])
        self.dbytes=self.dbytes[4:]
        if len(self.dbytes)==0: return
        self.cnsec=reduce(lambda x,y:256*x+y,self.dbytes[:4])
        if debug:
          print "ctime : %s.%s"%(datetime.datetime.fromtimestamp(self.csec).strftime('%b %d,%Y %H:%M:%S'),self.cnsec)
          print "  seconds         : %s"%self.csec
          print "  nano seconds    : %s"%self.cnsec
        self.dbytes=self.dbytes[4:]

      def parse_access_right():
        self.access_right=reduce(lambda x,y:256*x+y,self.dbytes[:4])
        if debug:
          print "Access_right      : %s"%self.access_right
        self.dbytes=self.dbytes[4:]

      def parse_attribute_before():
        self.attr_follow=reduce(lambda x,y:256*x+y,self.dbytes[:4])
        if debug:
          print "Attribute Follow  : value follows (%s)"%self.attr_follow
        self.dbytes=self.dbytes[4:]
        self.size=reduce(lambda x,y:256*x+y,self.dbytes[:8])
        if debug:
          print "size              : %s"%self.size
        self.dbytes=self.dbytes[8:]
        self.msec=reduce(lambda x,y:256*x+y,self.dbytes[:4])
        self.mnsec=reduce(lambda x,y:256*x+y,self.dbytes[4:8])
        if debug:
          print "mtime : %s.%s"%(datetime.datetime.fromtimestamp(self.msec).strftime('%b %d,%Y %H:%M:%S'),self.mnsec)
          print "  seconds         : %s"%self.msec
          print "  nano seconds    : %s"%self.mnsec
        self.dbytes=self.dbytes[8:]
        self.csec=reduce(lambda x,y:256*x+y,self.dbytes[:4])
        self.cnsec=reduce(lambda x,y:256*x+y,self.dbytes[4:8])
        if debug:
          print "ctime : %s.%s"%(datetime.datetime.fromtimestamp(self.csec).strftime('%b %d,%Y %H:%M:%S'),self.cnsec)
          print "  seconds         : %s"%self.csec
          print "  nano seconds    : %s"%self.cnsec
        self.dbytes=self.dbytes[8:]

      if callobj.version == 3:
        if callobj.procedure2name[callobj.procedure]=='ACCESS':
          parse_status()
          parse_object_attribute()
          parse_access_right()
        elif callobj.procedure2name[callobj.procedure]=='LOOKUP':
          parse_status()
          parse_object()
          parse_object_attribute()
          parse_object_attribute()
        elif callobj.procedure2name[callobj.procedure]=='READ':
          parse_status()
          parse_object_attribute()
          self.count=reduce(lambda x,y:256*x+y,self.dbytes[:4])
          if debug:
            print "Count             : %s"%self.count
          self.dbytes=self.dbytes[4:]
          self.eof="Yes" if reduce(lambda x,y:256*x+y,self.dbytes[:4]) == 1 else "No"
          if debug:
            print "EOF               : %s"%self.eof
          self.dbytes=self.dbytes[4:]
          self.datalength=reduce(lambda x,y:256*x+y,self.dbytes[:4])
          if debug:
            print "Data Length       : %s"%self.datalength
          self.dbytes=self.dbytes[4:]
          self.data=''.join(map(lambda x: '%02x'%x,self.dbytes[:self.datalength]))
          if debug:
            print "Data              : %s"%self.data
          self.dbytes=self.dbytes[self.datalength:]
          self.fill=''.join(map(lambda x: '%02x'%x,self.dbytes))
          if debug:
            print "Fill bytes         : %s"%self.fill
        elif callobj.procedure2name[callobj.procedure]=='GETATTR':
          parse_object_attribute()
        elif callobj.procedure2name[callobj.procedure]=='WRITE':
          parse_status()
          parse_attribute_before()
          parse_object_attribute()
          if len(self.dbytes)==0: return
          self.count=reduce(lambda x,y:256*x+y,self.dbytes[:4])
          if debug:
            print "Count             : %s"%self.count
          self.dbytes=self.dbytes[4:]
          self.committed=reduce(lambda x,y:256*x+y,self.dbytes[:4])
          if debug:
            print "Committed         : %s (%s)"%(self.stable_how4[self.committed],self.committed)
          self.dbytes=self.dbytes[4:]
          self.verifier=''.join(map(lambda x: '%02x'%x,self.dbytes))
          if debug:
            print "Verifier          : %s"%self.verifier



    def get_call(self):
      def parse_object():
        print "File Handle Length: %s"%self.fhlength
        print "File Handle       : %s"%self.fhandle
        print "Hash (CRC-32)     : 0x%s"%self.hashv
      if self.rpcobj.version == 3:
        if self.rpcobj.procedure2name[self.rpcobj.procedure]=='ACCESS':
          parse_object()
          print "Access            : 0x%02x"%self.access
          if self.access & self.ACCESS4_READ:
            print "        .... .... = 0x01 READ: allowed"
          if self.access & self.ACCESS4_LOOKUP:
            print "        .... .... = 0x02 LOOKUP: allowed"
          if self.access & self.ACCESS4_MODIFY:
            print "        .... .... = 0x04 MODIFY: allowed"
          if self.access & self.ACCESS4_EXTEND:
            print "        .... .... = 0x08 EXTEND: allowed"
          if self.access & self.ACCESS4_DELETE:
            print "        .... .... = 0x10 DELETE: allowed"
          if self.access & self.ACCESS4_EXECUTE:
            print "        .... .... = 0x20 EXECUTE: allowed"
        elif self.rpcobj.procedure2name[self.rpcobj.procedure]=='LOOKUP':
          parse_object()
          print "Name Length       : %s"%self.namelength
          print "Name              : %s"%self.name
        elif self.rpcobj.procedure2name[self.rpcobj.procedure]=='READ':
          parse_object()
          print "File Offset       : %s"%self.offset
          print "Count             : %s"%self.count
        elif self.rpcobj.procedure2name[self.rpcobj.procedure]=='GETATTR':
          parse_object()
        elif self.rpcobj.procedure2name[self.rpcobj.procedure]=='WRITE':
          parse_object()
          print "File Offset       : %s"%self.offset
          print "Count             : %s"%self.count
          print "Stable            : %s (%s)"%(self.stable_how4[self.stable],self.stable)
          print "Data Length       : %s"%self.datalength
          print "Data              : %s"%self.data
          print "Fill bytes         : %s"%self.fill
        #elif callobj.procedure2name[callobj.procedure]=='GETATTR':
        #  parse_object_attribute()
    def get_reply(self,callobj):
      def parse_object():
        print "File Handle Length: %s"%self.fhlength
        print "File Handle       : %s"%self.fhandle
        print "Hash (CRC-32)     : 0x%s"%self.hashv
      def parse_status():
        print "Status            : %s (%s)"%(self.nfsstat4[self.status], self.status)
      def parse_object_attribute():
        print "Attribute Follow  : value follows (%s)"%self.attr_follow
        print "Type              : %s (%s)"%(self.nfs_ftype4[self.ftype], self.ftype)
        print "Mode              : %s"%oct(self.Mode)
        print "nlink             : %s"%self.nlink
        print "uid               : %s"%self.uid
        print "gid               : %s"%self.gid
        print "size              : %s"%self.size
        print "used              : %s"%self.used
        print "rdev              : %s"%self.rdev
        print "fsid              : %016x (%s)"%(self.fsid,self.fsid)
        print "fileid            : %s"%self.fileid
        print "atime : %s.%s"%(datetime.datetime.fromtimestamp(self.asec).strftime('%b %d,%Y %H:%M:%S'),self.ansec)
        print "  seconds         : %s"%self.asec
        print "  nano seconds    : %s"%self.ansec
        print "mtime : %s.%s"%(datetime.datetime.fromtimestamp(self.msec).strftime('%b %d,%Y %H:%M:%S'),self.mnsec)
        print "  seconds         : %s"%self.msec
        print "  nano seconds    : %s"%self.mnsec
        print "ctime : %s.%s"%(datetime.datetime.fromtimestamp(self.csec).strftime('%b %d,%Y %H:%M:%S'),self.cnsec)
        print "  seconds         : %s"%self.csec
        print "  nano seconds    : %s"%self.cnsec
      def parse_access_right():
        print "Access_right      : %s"%self.access_right
      def parse_attribute_before():
        print "Attribute Follow  : value follows (%s)"%self.attr_follow
        print "size              : %s"%self.size
        print "mtime : %s.%s"%(datetime.datetime.fromtimestamp(self.msec).strftime('%b %d,%Y %H:%M:%S'),self.mnsec)
        print "  seconds         : %s"%self.msec
        print "  nano seconds    : %s"%self.mnsec
        print "ctime : %s.%s"%(datetime.datetime.fromtimestamp(self.csec).strftime('%b %d,%Y %H:%M:%S'),self.cnsec)
        print "  seconds         : %s"%self.csec
        print "  nano seconds    : %s"%self.cnsec
      if callobj.version == 3:
        if callobj.procedure2name[callobj.procedure]=='ACCESS':
          parse_status()
          parse_object_attribute()
          parse_access_right()
        elif callobj.procedure2name[callobj.procedure]=='LOOKUP':
          parse_status()
          parse_object()
          if self.nfsstat4[self.status] == 'NFS4ERR_NOENT':
            return
          else:
            parse_object_attribute()
            parse_object_attribute()
        elif callobj.procedure2name[callobj.procedure]=='READ':
          parse_status()
          parse_object_attribute()
          print "Count             : %s"%self.count
          # fixme
          if self.count==0:
            self.eof="No"
          else:
            self.eof="Yes" if reduce(lambda x,y:256*x+y,self.dbytes[:4]) == 1 else "No"
          print "EOF               : %s"%self.eof
          print "Data Length       : %s"%self.datalength
          print "Data              : %s"%self.data
          print "Fill bytes         : %s"%self.fill
        elif callobj.procedure2name[callobj.procedure]=='GETATTR':
          parse_object_attribute()
        elif callobj.procedure2name[callobj.procedure]=='WRITE':
          parse_status()
          parse_attribute_before()
          parse_object_attribute()
          print "Count             : %s"%self.count
          print "Committed         : %s (%s)"%(self.stable_how4[self.committed],self.committed)
          print "Verifier          : %s"%self.verifier
        
        
  class pcap_hdr:
    """
    Global Header 
    typedef struct pcap_hdr_s { 
     guint32 magic_number; /* magic number */ 
     guint16 version_major; /* major version number */ 
     guint16 version_minor; /* minor version number */ 
     gint32 thiszone; /* GMT to local correction */ 
     guint32 sigfigs; /* accuracy of timestamps */ 
     guint32 snaplen; /* max length of captured packets, in octets */ 
     guint32 network; /* data link type */ 
    } pcap_hdr_t; 
    """
    def __init__(self,data,debug=False):
      self.magic_number, \
      self.version_major, \
      self.version_minor, \
      self.thiszone, \
      self.sigfigs, \
      self.snaplen, \
      self.network=struct.unpack('<I2Hi3I',data) # little endian
      if self.magic_number == 0xa1b2c3d4:
        big_endian=0
        self.tresol=6
      elif self.magic_number == 0xa1b23c4d :
        big_endian=0
        self.tresol=9
      elif self.magic_number == 0xd4c3b2a1:
        big_endian=1
        self.tresol=6
      elif self.magic_number == 0x4d3cb2a1:
        big_endian=1
        self.tresol=9
      else:
        print "ERROR: Not pcap file magic number %x"%self.magic_number
        exit(1)
      if big_endian == 1: # big endian
        self.magic_number, \
        self.version_major, \
        self.version_minor, \
        self.thiszone, \
        self.sigfigs, \
        self.snaplen, \
        self.network=struct.unpack('>I2Hi3I',data) # big endian
      if debug:
        print self.magic_number,self.version_major,self.version_minor,self.thiszone,self.sigfigs,self.snaplen,self.network

    
  class pcaprec_hdr:
    """
    typedef struct pcaprec_hdr_s { 
     guint32 ts_sec; /* timestamp seconds */ 
     guint32 ts_usec; /* timestamp microseconds */ 
     guint32 incl_len; /* number of octets of packet saved in file */ 
     guint32 orig_len; /* actual length of packet */ 
    } pcaprec_hdr_t; 
    """
    def __init__(self,tresol,data,debug=False):
      self.ts_nsec=0
      if big_endian == 0: # little endian
        self.ts_sec, \
        self.ts_usec, \
        self.incl_len, \
        self.orig_len=struct.unpack('<4I',data)
      else: # big endian
        self.ts_sec, \
        self.ts_usec, \
        self.incl_len, \
        self.orig_len=struct.unpack('>4I',data)
      if tresol==9:
        self.ts_nsec=self.ts_usec%1000
        self.ts_usec=self.ts_usec//1000
      if debug:
        print self.ts_sec,self.ts_usec,self.ts_nsec,self.incl_len,self.orig_len
   
  sym2byte={
  "I" : "07",
  "S" : "fb",
  "T" : "fd",
  "E" : "fe"
  }
  preambles=[0xfb,0x55,0x55,0x55,0x55,0x55,0x55,0xd5]
  nfs_xids=[]
  xid2rpc={}
  def __init__(self,ch0file,ch1file='',merge=True,debug=False):
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
    if ch0file.endswith('ng') or ch0file.endswith('ng.gz'): # pcapng
      if merge:
        pcapngobj=pcapng_parser()
        pcapngobj.read(ch0file)
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
          if not frame_crc_error:
            if map(lambda x: int(x,16),self.calcrc32(dbytes[:-4]))!=dbytes[-4:]:
              dbytes.extend(map(lambda x: int(x,16),self.calcrc32(dbytes)))
          else:
            if map(lambda x: int(x,16),self.calcrc32(dbytes[:-4]))!=dbytes[-4:]:
              print "CRC error",dbytes[-4:],map(lambda x: int(x,16),self.calcrc32(dbytes[:-4]))
              
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
          #ts_sec,ts_usec,ts_nsec=timestamp(tsresol,ts_high,ts_low)
          #print long(ts_high<<32)+long(ts_low),ts_sec,ts_usec,ts_nsec
          self.pkts.append((ts_sec,ts_usec,ts_nsec,dbytes,0))
      else:
        for i,chfile in enumerate([ch0file,ch1file],1):
          pcapngobj=pcapng_parser()
          pcapngobj.read(chfile)
          pcapngobj.check_endian(pcapngobj.dbytes)
          pcapngobj.parse_block(pcapngobj.dbytes)
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
            if not frame_crc_error:
              if map(lambda x: int(x,16),self.calcrc32(dbytes[:-4]))!=dbytes[-4:]:
                dbytes.extend(map(lambda x: int(x,16),self.calcrc32(dbytes)))
            else:
              if map(lambda x: int(x,16),self.calcrc32(dbytes[:-4]))!=dbytes[-4:]:
                print "CRC error",dbytes[-4:],map(lambda x: int(x,16),self.calcrc32(dbytes[:-4]))
            ts=long(ts_high<<32)+long(ts_low)
            ts_s="%d"%ts
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
            #ts_sec,ts_usec,ts_nsec=timestamp(tsresol,ts_high,ts_low)
            #print long(ts_high<<32)+long(ts_low),ts_sec,ts_usec,ts_nsec
            self.pkts.append((ts_sec,ts_usec,ts_nsec,dbytes,i))
    else:
      if merge:
        pktno=1
        self.readpcap(ch0file)
        ghdr=self.pcap_hdr(self.data[:24])
        self.tresol=ghdr.tresol
        self.data=self.data[24:]
        while self.data:
          self.packet_extract(pktno,0)
          pktno+=1
      else:
        for i,chfile in enumerate([ch0file,ch1file],1):
          pktno=1
          self.readpcap(chfile)
          ghdr=self.pcap_hdr(self.data[:24])
          self.tresol=ghdr.tresol
          self.data=self.data[24:]
          while self.data:
            self.packet_extract(pktno,i)
            pktno+=1
    self.sort_pkts(merge,debug=debug)
  def sort_pkts(self,merge,debug=False):
    def simtimestamp_old(pktno,total_bytes):
      """
      long int 6-byte
      """
      return (pktno-1)*500+int((total_bytes+9)*100/156.25/8.)  # 5us gap between frame + frame time
    def simtimestamp(starttime,framegap,total_bytes):
      """
      long int 6-byte
      """
      return starttime+int((total_bytes+9)*100/156.25/8.)+framegap  # starttime + framegap + frame time
    def timestamp(sec,usec,nsec):
      """
      long int 6-byte
      """
      return (sec*1000000+usec)*100+nsec//10
    ts_sec_offset=0
    ts_usec_offset=0
    ts_nsec_offset=0
    total_bytes=0
    def find_macaddr():
      """
      find mac address appear in sa and da field 
      """
      pairs=[]
      macaddrs=[]
      excludes=[]
      for ts_sec,ts_usec,ts_nsec,dbytes,ch in self.pkts:
        ehdr=self.eth_hdr(dbytes,debug=False)
        if ehdr.da!='ffffffffffff' or (int((ehdr.da)[1],16) & 1 == 1):
          pairs.append((ehdr.sa,ehdr.da))
        else:
          excludes.append(ehdr.sa)
        if ehdr.sa not in macaddrs:
          macaddrs.append(ehdr.sa)
      for macaddr in macaddrs:
        match=True
        for sa,da in pairs:
          if macaddr != sa and macaddr != da:
            match=False
            break
        if match:
          if macaddr not in excludes:
            return macaddr
    def find_macaddr2(debug=False):
      """
      find mac address appear in sa and da field 
      """
      pairs=[]
      sas=[]
      for ts_sec,ts_usec,ts_nsec,dbytes,ch in self.pkts:
        ehdr=self.eth_hdr(dbytes,debug=False)
        if ehdr.sa not in sas:
          sas.append(ehdr.sa)
        if (ehdr.sa,ehdr.da) not in pairs:
          pairs.append((ehdr.sa,ehdr.da))
      for macaddr in sas:
        for pair in pairs: 
          if pair[1]=='ffffffffffff':
            continue
          if macaddr not in pair:
            break
          if debug:
            print pairs
            print filter(lambda x: x[0]==macaddr,pairs)
            print filter(lambda x: x[0]!=macaddr,pairs)
          return macaddr
      return None
    def find_macaddr3():
      """
      find mac address appear in sa and da field 
      """
      pairs=[]
      ch0s=[]
      ch1s=[]
      for ts_sec,ts_usec,ts_nsec,dbytes,ch in self.pkts:
        ehdr=self.eth_hdr(dbytes,debug=False)
        if False and ehdr.da=='ffffffffffff':
          if (ehdr.sa,ehdr.da) not in ch0s:
            ch0s.append((ehdr.sa,ehdr.da))
        else:
          if (ehdr.sa,ehdr.da) not in pairs:
            pairs.append((ehdr.sa,ehdr.da))
      ch0s.append(pairs[0])
      for pair in pairs:
        sa,da=pair
        if sa in map(lambda x: x[0],ch0s):
          if pair not in ch0s:
            ch0s.append(pair)
        elif da in map(lambda x: x[0],ch0s):
          if pair not in ch1s:
            ch1s.append(pair)
      for pair in pairs:
        sa,da=pair
        if True:
          if da in map(lambda x: x[1],ch0s):
            if pair not in ch0s:
              ch0s.append(pair)
          else:
            if pair not in ch1s:
              ch1s.append(pair)
      print ch0s
      print ch1s
      print pairs
      return None
    macaddr=find_macaddr()
    if macaddr == None:
      if debug:
        print "2nd try"
      macaddr=find_macaddr2()
    filer_da=macaddr
    starttime=0
    frametime=0
    framegap=0
    current_ts_in_cycle=0
    print "Total number of frames: %d"%len(self.pkts)
    if start_frame_en:
      if end_frame_en:
        print "Extract Frames: %d"%(end_frame-start_frame+1)
      else:
        print "Extract Frames: %d"%(len(self.pkts)-start_frame+1)
    else:
      if end_frame_en:
        print "Extract Frames: %d"%end_frame
      else:
        print "Extract Frames: %d"%len(self.pkts)
    for pktno,(ts_sec,ts_usec,ts_nsec,dbytes,ch) in enumerate(sorted(self.pkts,key=lambda x: (x[0]*1000000+x[1])*1000+x[2]),1):
      if start_frame_en:
        if pktno < start_frame:
          continue
      if end_frame_en:
        if pktno > end_frame:
          continue
      tcp_hdr=None
      if debug:
        print '='*80
        print "packet number : %d"%pktno
        print '='*80
      ehdr=self.eth_hdr(dbytes,debug=False)
      if int(ehdr.ethertype,16) < 0x600:  # EtherType values must be greater than or equal to 1536 (0x0600)
        print "Warning: EtherType values must be greater than or equal to 1536 (0x600) and length value is %d"%int(ehdr.ethertype,16)
      elif ehdr.ethertype=='0806': # ARP
        pass
      elif ehdr.ethertype=='8808': # Pause/PFC
        pass
      elif ehdr.ethertype=='86dd' or ehdr.ethertype=='0800': # IPv6 or IPv4
        ip_offset=len(dbytes)-4-len(ehdr.payload) # 4-byte crc
        if (ehdr.payload[0] >> 4)==4:
          ip_hdr=self.ip_hdr(ehdr.payload)
          if fix_ip_checksum and (map(lambda x: '%02x'%x,ip_hdr.calchecksum) != ip_hdr.checksum):
            print "Pkt %d: Fix IP checksum error: before %s after %s"%(pktno,map(lambda x: '%02x'%x,dbytes[ip_offset+10:ip_offset+12]),
                                                                map(lambda x: '%02x'%x,ip_hdr.calchecksum))
            dbytes[ip_offset+10:ip_offset+12]=ip_hdr.calchecksum
            if not frame_crc_error:
              dbytes[-4:]=map(lambda x: int(x,16),self.calcrc32(dbytes[:-4]))
        else:
          ip_hdr=self.ipv6_hdr(ehdr.payload)
            
        if ip_hdr.proto==6:  # tcp
          if debug:
            print ip_hdr.payload
          #print map(hex,ip_hdr.pseudo_hdr(len(ip_hdr.payload)))
          #print len(ip_hdr.pseudo_hdr(len(ip_hdr.payload)))
          #print map(hex,ip_hdr.payload)
          #print len(ip_hdr.payload)
          tcp_offset=len(dbytes)-4-len(ip_hdr.payload) # 4-byte crc
          tcp_hdr=self.tcp_hdr(ip_hdr.payload,ip_hdr.pseudo_hdr(len(ip_hdr.payload)))
          if fix_tcp_checksum and (map(lambda x: '%02x'%x,tcp_hdr.calchecksum) != tcp_hdr.checksum):
            print "Pkt %d: Fix TCP checksum error: before %s after %s"%(pktno,map(lambda x: '%02x'%x,dbytes[tcp_offset+16:tcp_offset+18]),
                                                                map(lambda x: '%02x'%x,tcp_hdr.calchecksum))
            dbytes[tcp_offset+16:tcp_offset+18]=tcp_hdr.calchecksum
            if not frame_crc_error:
              dbytes[-4:]=map(lambda x: int(x,16),self.calcrc32(dbytes[:-4]))
          if debug:
            tcp_hdr.get()
          flowid=(ip_hdr.saddr,ip_hdr.daddr,tcp_hdr.sport,tcp_hdr.dport)
          if flowid in flowid2bytes:
            if debug:
              print 1,len(flowid2bytes[flowid][1])
            flowid2bytes[flowid][1]+=tcp_hdr.payload
            if debug:
              print 2,len(flowid2bytes[flowid][1])
            if (len(flowid2bytes[flowid][1])+len(tcp_hdr.payload)) >= flowid2bytes[flowid][0]:
              rpc_dbytes=flowid2bytes[flowid][1]+tcp_hdr.payload
              del(flowid2bytes[flowid])
            else:
              rpc_dbytes=[]
          else:
            rpc_dbytes=tcp_hdr.payload
              
          if len(rpc_dbytes) > 0:
            if debug:
              print len(rpc_dbytes)
            if not (tcp_hdr.sport == tcp_hdr.port_number.map['SSH'] or \
                    tcp_hdr.dport == tcp_hdr.port_number.map['SSH'] or \
                    tcp_hdr.sport == tcp_hdr.port_number.map['HTTP'] or \
                    tcp_hdr.dport == tcp_hdr.port_number.map['HTTP'] or \
                    tcp_hdr.sport == tcp_hdr.port_number.map['DDI_TCP_1'] or \
                    tcp_hdr.dport == tcp_hdr.port_number.map['DDI_TCP_1'] or \
                    tcp_hdr.sport == tcp_hdr.port_number.map['MICROSOFT_DS'] or \
                    tcp_hdr.dport == tcp_hdr.port_number.map['MICROSOFT_DS'] or \
                    tcp_hdr.sport == tcp_hdr.port_number.map['SUNRPC'] or \
                    tcp_hdr.dport == tcp_hdr.port_number.map['SUNRPC']) :
              if False: # fixme
                rpc_hdr=self.rpc_hdr(rpc_dbytes,flowid=flowid,debug=debug)
  
                if rpc_hdr.segmentation or rpc_hdr.fragment_hdr.last_fragment ==0 or rpc_hdr.parse_error:
                  pass
                else:
                  if debug:
                    rpc_hdr.get()
                  if rpc_hdr.segmentation:
                    pass
                  elif rpc_hdr.fragment_hdr.last_fragment==0:
                    pass
                  elif rpc_hdr.fragment_hdr.size==0:
                    pass
                  else:
                    if rpc_hdr.msg_type.inv_map[rpc_hdr.type] == 'CALL':
                      filer_da=ehdr.da
                      if rpc_hdr.program2name[rpc_hdr.program] == 'NFS':
                        nfs_hdr=self.nfs_hdr(rpc_hdr,self.calcrc32)
                        nfs_hdr.call()
                        self.nfs_xids.append(rpc_hdr.xid)
                        self.xid2rpc[rpc_hdr.xid]=rpc_hdr
                        if debug:
                          nfs_hdr.get_call()
                      elif rpc_hdr.program2name[rpc_hdr.program] == 'MNT':
                        # fixme
                        pass
                    elif rpc_hdr.msg_type.inv_map[rpc_hdr.type] == 'REPLY':
                      if rpc_hdr.xid in self.nfs_xids:
                        nfs_hdr=self.nfs_hdr(rpc_hdr,self.calcrc32)
                        nfs_hdr.reply(self.xid2rpc[rpc_hdr.xid])
                        if debug:
                          nfs_hdr.get_reply(self.xid2rpc[rpc_hdr.xid])
                    elif rpc_hdr.msg_type.inv_map[rpc_hdr.type] == 'NFSACL':
                      pass
        elif ip_hdr.proto==17:  # udp
          pass
      else:
        print "Error: ether type not supported %s"%ehdr.ethertype
      #if ts_sec_offset==0 and ts_usec_offset==0 and ts_nsec_offset==0:
      if pktno == 1:
        ts_sec_offset=ts_sec
        ts_usec_offset=ts_usec
        ts_nsec_offset=ts_nsec

      starttime=simtimestamp(starttime,framegap,frametime)
      #starttime=simtimestamp_old(pktno,total_bytes)
      if debug:
        print pktno,simtimestamp_old(pktno,total_bytes),starttime,framegap

      if tcp_hdr != None:
        if tcp_hdr.syn or tcp_hdr.fin:
          if enable_txbist:
            framegap=2
          else:
            framegap=500
        else:
          if enable_txbist:
            framegap=2
          else:
            framegap=3
      else:
        if enable_txbist:
          framegap=2
        else:
          framegap=3
      ts_in_10ns=timestamp(ts_sec-ts_sec_offset, ts_usec-ts_usec_offset,ts_nsec-ts_nsec_offset)
      ts_in_cycle=ts_in_10ns*100//64
      self.ts_in_cycles.append(ts_in_cycle)
      if len(self.mifouts[0]):
        if type(self.mifouts[0][-1][1])==type(1):
          dbyte_len=self.mifouts[0][-1][1]
        else:
          dbyte_len=self.mifouts[1][-1][1]
        delay_in_cycle=ts_in_cycle-current_ts_in_cycle
        self.mifouts[0][-1][0]=delay_in_cycle
        self.mifouts[1][-1][0]=delay_in_cycle
      else:
        delay_in_cycle=0
      current_ts_in_cycle+=delay_in_cycle+1+((len(dbytes)+8+1)//8)
      if merge:
        if False and filer_da!=None:
          if filer_da==ehdr.sa:
            self.outs[0].append((len(dbytes),timestamp(ts_sec-ts_sec_offset, ts_usec-ts_usec_offset,ts_nsec-ts_nsec_offset),dbytes,ehdr.sa))
            self.simouts[0].append((len(dbytes),starttime,dbytes,ehdr.sa))
            self.sims[0].append((framegap,dbytes))
            self.mifouts[0].append([0,dbytes])
            self.sims[1].append((framegap,len(dbytes)))
            self.mifouts[1].append([0,len(dbytes)])
            self.pktgrps[0].append(pktno)
          else:
            self.outs[1].append((len(dbytes),timestamp(ts_sec-ts_sec_offset, ts_usec-ts_usec_offset,ts_nsec-ts_nsec_offset),dbytes,ehdr.sa))
            self.simouts[1].append((len(dbytes),starttime,dbytes,ehdr.sa))
            self.sims[1].append((framegap,dbytes))
            self.mifouts[1].append([0,dbytes])
            self.sims[0].append((framegap,len(dbytes)))
            self.mifouts[0].append([0,len(dbytes)])
            self.pktgrps[1].append(pktno)
        else:
          if macaddr==ehdr.sa:
            self.outs[1].append((len(dbytes),timestamp(ts_sec-ts_sec_offset, ts_usec-ts_usec_offset,ts_nsec-ts_nsec_offset),dbytes,ehdr.sa))
            self.simouts[1].append((len(dbytes),starttime,dbytes,ehdr.sa))
            self.sims[1].append((framegap,dbytes))
            self.mifouts[1].append([0,dbytes])
            self.sims[0].append((framegap,len(dbytes)))
            self.mifouts[0].append([0,len(dbytes)])
            self.pktgrps[1].append(pktno)
          else:
            self.outs[0].append((len(dbytes),timestamp(ts_sec-ts_sec_offset, ts_usec-ts_usec_offset,ts_nsec-ts_nsec_offset),dbytes,ehdr.sa))
            self.simouts[0].append((len(dbytes),starttime,dbytes,ehdr.sa))
            self.sims[0].append((framegap,dbytes))
            self.mifouts[0].append([0,dbytes])
            self.sims[1].append((framegap,len(dbytes)))
            self.mifouts[1].append([0,len(dbytes)])
            self.pktgrps[0].append(pktno)
      else:
        if ch==1:
          self.outs[0].append((len(dbytes),timestamp(ts_sec-ts_sec_offset, ts_usec-ts_usec_offset,ts_nsec-ts_nsec_offset),dbytes,ehdr.sa))
          self.simouts[0].append((len(dbytes),starttime,dbytes,ehdr.sa))
          self.sims[0].append((framegap,dbytes))
          self.mifouts[0].append([0,dbytes])
          self.sims[1].append((framegap,len(dbytes)))
          self.mifouts[1].append([0,len(dbytes)])
        elif ch==2:
          self.outs[1].append((len(dbytes),timestamp(ts_sec-ts_sec_offset, ts_usec-ts_usec_offset,ts_nsec-ts_nsec_offset),dbytes,ehdr.sa))
          self.simouts[1].append((len(dbytes),starttime,dbytes,ehdr.sa))
          self.sims[1].append((framegap,dbytes))
          self.mifouts[1].append([0,dbytes])
          self.sims[0].append((framegap,len(dbytes)))
          self.mifouts[0].append([0,len(dbytes)])
      total_bytes+=len(dbytes)
      frametime=len(dbytes)
    if merge:
       if filer_da!=macaddr:
         self.outs=[self.outs[1],self.outs[0]]
         self.simouts=[self.simouts[1],self.simouts[0]]
         self.sims=[self.sims[1],self.sims[0]]
         self.mifouts=[self.mifouts[1],self.mifouts[0]]
         self.pktgrps=[self.pktgrps[1],self.pktgrps[0]]
    if debug:
      print "macaddr",macaddr
      print self.pktgrps
  def readpcap(self,file):
    """
    packet format:
      Global Header 
      Packet Header 
      Packet Data 
      Packet Header 
      Packet Data 
      Packet Header 
      Packet Data ... 
    """
    
    try:
      INFILE=gzip.open(file,'rb')
      self.data=INFILE.read()
    except:
      INFILE=open(file,"rb")
      self.data=INFILE.read()
  
  def packet_extract(self,pktno,ch,debug=False):
    """
    typedef struct pcaprec_hdr_s { 
     guint32 ts_sec; /* timestamp seconds */ 
     guint32 ts_usec; /* timestamp microseconds */ 
     guint32 incl_len; /* number of octets of packet saved in file */ 
     guint32 orig_len; /* actual length of packet */ 
    } pcaprec_hdr_t; 
    """
    dbytes=[]
    phdr=self.pcaprec_hdr(self.tresol,self.data[:16])
    self.data=self.data[16:]
    if debug:
      print "ts sec",phdr.ts_sec
      print "ts usec",phdr.ts_usec
      print "ts nsec",phdr.ts_nsec
      print "caplen",phdr.incl_len
      print "pktlen",phdr.orig_len
    dbytes.extend(struct.unpack('%dB'%phdr.incl_len,self.data[:phdr.incl_len]))
    if len(dbytes) < 60:
      print "Warning: Ethernet frame %d length of %d is less than 60 (exclude CRC 4bytes)"%(pktno,len(dbytes))
      if fix_short_frame:
        print "Pad %d zeros to Ethernet frame"%(60-len(dbytes))
        dbytes.extend([0]*(60-len(dbytes)))
    if not frame_crc_error:
      if map(lambda x: int(x,16),self.calcrc32(dbytes[:-4]))!=dbytes[-4:]:
        dbytes.extend(map(lambda x: int(x,16),self.calcrc32(dbytes)))
    else:
      if map(lambda x: int(x,16),self.calcrc32(dbytes[:-4]))!=dbytes[-4:]:
        print "CRC error",dbytes[-4:],map(lambda x: int(x,16),self.calcrc32(dbytes[:-4]))
    self.pkts.append((phdr.ts_sec,phdr.ts_usec,phdr.ts_nsec,dbytes,ch))
    self.data=self.data[phdr.incl_len:]
  
  
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
  
  
  def header(self,depth):
    """
    """
    return """
  DEPTH=%d;
  WIDTH=72;
  ADDRESS_RADIX=UNS;
  DATA_RADIX=HEX;
  
  CONTENT BEGIN
  """%depth
          
  def genmif(self,fname,pkts):
    """   
    lword align next packet
    prepend preamble
    """   
    OUTFILE=open(fname,'w')
    lines=[]
    linecnt=0
    pktcnt=1
    for (ts_sec,ts_usec,dbytes) in pkts:
      # prepend preamble
      lines.append('%10d : 01d5555555555555fb;    --        S  pkt %d'%(linecnt,pktcnt))
      pktcnt+=1
      linecnt+=1
      while True:
        if len(dbytes) >=8 :
          lines.append('%10d : 00%s;'%(linecnt,''.join(map(lambda x: '%02x'%x,dbytes[:8][::-1]))))
          dbytes=dbytes[8:]
          linecnt+=1
        else:
          break
        
      
      if len(dbytes)==0:
        comment= 'I'*7+'T'
        control= 'ff'
        data= self.sym2byte['I']*7+self.sym2byte['T']
        idlecnt=7
      else:
        comment= 'I'*(8-len(dbytes)-1)+'T'+' '*len(dbytes)
        control= '%02x'%int('1'*(8-len(dbytes))+'0'*len(dbytes),2)
        data= self.sym2byte['I']*(8-len(dbytes)-1)+self.sym2byte['T']+''.join(map(lambda x: '%02x'%x,dbytes)[::-1])
        idlecnt=8-len(dbytes)-1
      lines.append('%10d : %s%s;    -- %s'%(linecnt,control,data,comment))
      linecnt+=1
      #print 'idlecnt %d'%idlecnt,self.IPG_LEN
      while True:
        if idlecnt> self.IPG_LEN:
          break
        else:
          lines.append('%10d : ff%s;    -- IIIIIIII'%(linecnt,'07'*8))
          linecnt+=1
          idlecnt+=8

    lines.insert(0,'''
DEPTH=%d;
WIDTH=72;
ADDRESS_RADIX=UNS;
DATA_RADIX=HEX;

CONTENT BEGIN
'''%linecnt)  
    lines.append('END;')
    #print "\n".join(lines)
    OUTFILE.write("\n".join(lines))
  
  def parse_eth_hdr(self,debug=False):
    """   
    """   
    for i,(ts_sec,ts_usec,ts_nsec,pkt,ch) in enumerate(self.pkts,1):
      ehdr=self.eth_hdr(pkt)
      if debug:
        print "="*40
        print"pkt number",i
        print "="*40
        print "da        : %s"%ehdr.da
        print "sa        : %s"%ehdr.sa
        print "ether type: %s"%ehdr.ethertype
        for (cos,cfi,vlanid) in ehdr.vlans:
          print "cos       : %d"%cos
          print "cfi       : %d"%cfi
          print "vlanid    : %03x"%vlanid
  
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
    
    
  def gensimmif_old(self,fname,pkts):
    """
    """
    OUTFILE=open(fname,'w')
    lines=[]
    linecnt=0
    pktcnt=1
    for dbytes in pkts:
      if type(dbytes)==type(1):
        #for i in range((dbytes//8)+1+3):
        for i in range((dbytes//8)+1+3+self.IPG_LEN//8-2):
          lines.append('%10d : ff%s;    -- IIIIIIII'%(linecnt,'07'*8))
          linecnt+=1
      else: 
        # prepend preamble
        lines.append('%10d : 01d5555555555555fb;    --        S  pkt %d'%(linecnt,pktcnt))
        pktcnt+=1
        linecnt+=1
        while True:
          if len(dbytes) >=8 :
            lines.append('%10d : 00%s;'%(linecnt,''.join(map(lambda x: '%02x'%x,dbytes[:8][::-1]))))
            dbytes=dbytes[8:]
            linecnt+=1
          else:
            break
        if len(dbytes)==0:
          comment= 'I'*7+'T'
          control= 'ff'
          data= self.sym2byte['I']*7+self.sym2byte['T']
          idlecnt=7
        else:
          comment= 'I'*(8-len(dbytes)-1)+'T'+' '*len(dbytes)
          control= '%02x'%int('1'*(8-len(dbytes))+'0'*len(dbytes),2)
          data= self.sym2byte['I']*(8-len(dbytes)-1)+self.sym2byte['T']+''.join(map(lambda x: '%02x'%x,dbytes)[::-1])
          idlecnt=8-len(dbytes)-1
        lines.append('%10d : %s%s;    -- %s'%(linecnt,control,data,comment))
        linecnt+=1
        #print 'idlecnt %d'%idlecnt,self.IPG_LEN
        #for icycle in range(2):
        for icycle in range(self.IPG_LEN//8):
          lines.append('%10d : ff%s;    -- IIIIIIII'%(linecnt,'07'*8))
          idlecnt+=8
          linecnt+=1

    lines.insert(0,'''
DEPTH=%d;
WIDTH=72;
ADDRESS_RADIX=UNS;
DATA_RADIX=HEX;

CONTENT BEGIN
'''%linecnt)  
    lines.append('END;')
    print fname
    #print "\n".join(lines)
    OUTFILE.write("\n".join(lines))
    OUTFILE.close()

  def genmifout(self,fname,pkts):
    """
    """
    OUTFILE=open(fname,'w')
    lines=[]
    linecnt=0
    pktcnt=1
    for framegap,dbytes in pkts:
      repeat_cnt=0
      if type(dbytes)==type(1):
        repeat_cnt+=((dbytes+8+1)//8)+1
      else: 
        # prepend preamble
        lines.append('%10d : 01d5555555555555fb;    --        S  pkt %d'%(linecnt,pktcnt))
        pktcnt+=1
        linecnt+=1
        while True:
          if len(dbytes) >=8 :
            lines.append('%10d : 00%s;'%(linecnt,''.join(map(lambda x: '%02x'%x,dbytes[:8][::-1]))))
            dbytes=dbytes[8:]
            linecnt+=1
          else:
            break
        if len(dbytes)==0:
          comment= 'I'*7+'T'
          control= 'ff'
          data= self.sym2byte['I']*7+self.sym2byte['T']
          idlecnt=7
        else:
          comment= 'I'*(8-len(dbytes)-1)+'T'+' '*len(dbytes)
          control= '%02x'%int('1'*(8-len(dbytes))+'0'*len(dbytes),2)
          data= self.sym2byte['I']*(8-len(dbytes)-1)+self.sym2byte['T']+''.join(map(lambda x: '%02x'%x,dbytes)[::-1])
          idlecnt=8-len(dbytes)-1
        lines.append('%10d : %s%s;    -- %s'%(linecnt,control,data,comment))
        linecnt+=1
      repeat_cnt+=framegap
      repeat_cnt-=1
      if repeat_cnt == -1:
        lines.append('%10d : ff%s;    -- IIIIIIII'%(linecnt,'07'*8))
        linecnt+=1
      else:
        lines.append('%10d : ff%s;    -- IIIIIIII'%(linecnt,'07'*8))
        linecnt+=1
        lines.append("%10d : %02x%016x;    -- %s"%(linecnt,0x55,repeat_cnt,'repeat %d'%(repeat_cnt)))
        linecnt+=1

    lines.insert(0,'''
DEPTH=%d;
WIDTH=72;
ADDRESS_RADIX=UNS;
DATA_RADIX=HEX;

CONTENT BEGIN
'''%linecnt)  
    lines.append('END;')
    print fname
    #print "\n".join(lines)
    OUTFILE.write("\n".join(lines))
    OUTFILE.close()
  def gensimmif(self,fname,pkts):
    """
    """
    OUTFILE=open(fname,'w')
    lines=[]
    linecnt=0
    pktcnt=1
    for framegap,dbytes in pkts:
      if type(dbytes)==type(1):
        pkt_linecnt=dbytes//8
      else:
        pkt_linecnt=len(dbytes)//8
      if limit_mif_size==1:
        if (linecnt+pkt_linecnt+8) > txbist_size:
          for icycle in range(8):
            lines.append('%10d : ff%s;    -- IIIIIIII'%(linecnt,'07'*8))
            linecnt+=1
          break
          
      if framegap==500:
        ipg=self.IPG_LEN_5us
      else:
        ipg=self.IPG_LEN_16idles
      if type(dbytes)==type(1):
        for i in range((dbytes//8)+1+3+ipg//8-2):
          lines.append('%10d : ff%s;    -- IIIIIIII'%(linecnt,'07'*8))
          linecnt+=1
      else: 
        # prepend preamble
        lines.append('%10d : 01d5555555555555fb;    --        S  pkt %d'%(linecnt,pktcnt))
        pktcnt+=1
        linecnt+=1
        while True:
          if len(dbytes) >=8 :
            lines.append('%10d : 00%s;'%(linecnt,''.join(map(lambda x: '%02x'%x,dbytes[:8][::-1]))))
            dbytes=dbytes[8:]
            linecnt+=1
          else:
            break
        if len(dbytes)==0:
          comment= 'I'*7+'T'
          control= 'ff'
          data= self.sym2byte['I']*7+self.sym2byte['T']
          idlecnt=7
        else:
          comment= 'I'*(8-len(dbytes)-1)+'T'+' '*len(dbytes)
          control= '%02x'%int('1'*(8-len(dbytes))+'0'*len(dbytes),2)
          data= self.sym2byte['I']*(8-len(dbytes)-1)+self.sym2byte['T']+''.join(map(lambda x: '%02x'%x,dbytes)[::-1])
          idlecnt=8-len(dbytes)-1
        lines.append('%10d : %s%s;    -- %s'%(linecnt,control,data,comment))
        linecnt+=1
        #print 'idlecnt %d'%idlecnt,self.IPG_LEN
        #for icycle in range(2):

        for icycle in range(ipg//8):
          lines.append('%10d : ff%s;    -- IIIIIIII'%(linecnt,'07'*8))
          idlecnt+=8
          linecnt+=1

    lines.insert(0,'''
DEPTH=%d;
WIDTH=72;
ADDRESS_RADIX=UNS;
DATA_RADIX=HEX;

CONTENT BEGIN
'''%linecnt)  
    lines.append('END;')
    print fname
    #print "\n".join(lines)
    OUTFILE.write("\n".join(lines))
    OUTFILE.close()
      
   
if __name__ == '__main__': 
  """
  """
  import sys
  argv=sys.argv
  if '-have_frame_crc_error' in argv: 
    frame_crc_error=1
    argv.remove('-have_frame_crc_error')
  if '-disable_fix_ip_checksum' in argv: 
    fix_ip_checksum=0
    argv.remove('-disable_fix_ip_checksum')
  if '-disable_fix_tcp_checksum' in argv: 
    fix_tcp_checksum=0
    argv.remove('-disable_fix_tcp_checksum')
  if '-disable_fix_short_frame' in argv: 
    fix_short_frame=0
    argv.remove('-disable_fix_short_frame')
  if '-limit_mif_size' in argv: 
    limit_mif_size=1
    argv.remove('-limit_mif_size')
  if '-enable_txbist' in argv: 
    enable_txbist=1
    argv.remove('-enable_txbist')
  if '-start_frame' in argv: 
    idx=argv.index('-start_frame')
    start_frame=int(argv[idx+1])
    start_frame_en=1
    del argv[idx+1]
    argv.remove('-start_frame')
  if '-end_frame' in argv: 
    idx=argv.index('-end_frame')
    end_frame=int(argv[idx+1])
    end_frame_en=1
    del argv[idx+1]
    argv.remove('-end_frame')
  if '-ts_mif_gen_en' in argv: 
    ts_mif_gen_en=1
    argv.remove('-ts_mif_gen_en')
  
  argc=len(argv)
  if argc==3:
    if argc > 1: pcap    = argv[1]
    if argc > 2: outf    = argv[2]
    obj=pcap2eth(pcap,debug=False)
    #print len(obj.pkts[0][3])
    #print map(lambda x: '%02x'%x,obj.pkts[0][3])
    #obj.genmif('%s.mif',obj.pkts)
    #obj.parse_eth_hdr()
    #pprint(obj.outs)
    #print obj.simouts[:2]
    #print obj.outs[:2]
    #print zip(map(lambda x: x[0],obj.mifouts[0]) , map(lambda x: x[0],obj.mifouts[1]))
    obj.genbin('%sch0.bin'%outf,obj.outs[0])
    obj.genbin('%sch1.bin'%outf,obj.outs[1])
    obj.genbin('%sch0_sim.bin'%outf,obj.simouts[0])
    obj.genbin('%sch1_sim.bin'%outf,obj.simouts[1])
    obj.gensimmif('%sch0.mif'%outf,obj.sims[0])
    obj.gensimmif('%sch1.mif'%outf,obj.sims[1])
    if ts_mif_gen_en:
      obj.genmifout('%sch0_ts.mif'%outf,obj.mifouts[0])
      obj.genmifout('%sch1_ts.mif'%outf,obj.mifouts[1])
    #print obj.ts_in_cycles
  elif argc==4:
    if argc > 1: pcap1  = argv[1]
    if argc > 2: pcap2  = argv[2]
    if argc > 3: outf   = argv[3]
    obj=pcap2eth(pcap1,pcap2,merge=False)
    #print obj.pkts 
    #obj.genmif('%s.mif',obj.pkts)
    #obj.parse_eth_hdr()
    #pprint(obj.outs)
    obj.genbin('%sch0.bin'%outf,obj.outs[0])
    obj.genbin('%sch1.bin'%outf,obj.outs[1])
    obj.genbin('%sch0_sim.bin'%outf,obj.simouts[0])
    obj.genbin('%sch1_sim.bin'%outf,obj.simouts[1])
    obj.gensimmif('%sch0.mif'%outf,obj.sims[0])
    obj.gensimmif('%sch1.mif'%outf,obj.sims[1])
    if ts_mif_gen_en:
      obj.genmifout('%sch0_ts.mif'%outf,obj.mifouts[0])
      obj.genmifout('%sch1_ts.mif'%outf,obj.mifouts[1])
