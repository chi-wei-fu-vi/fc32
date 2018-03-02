#!/usr/bin/env python2.7
import ctypes
import struct
import gzip
import importlib
from pprint import pprint
class pcapng_parser(object):
  """
  Section Header
  |
  +- Interface Description
  |  +- Simple Packet
  |  +- Enhanced Packet
  |  +- Interface Statistics
  |
  +- Name Resolution

  layout:
    |--   1st Section   --|--   2nd Section   --|--  3rd Section  --|
    |                                                               |
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    | SHB v1.0  |  Data   | SHB V1.1  |  Data   | SHB V1.0  |  Data |
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  classical libpcap file
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    | SHB | IDB | EPB | EPB |    ...    | EPB |
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  complex file:
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    | SHB | IDB | IDB | IDB | EPB | EPB | NRB |    ...    | EPB | ISB | NRB | EPB | EPB |
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  """
  def __init__(self):
    """
    """
    self.module=importlib.import_module('pcapng_header')
    self.blocks=[]
    self.pkts=[]
    self.tsresol=None

  def byte2value(self,dbytes):
    """
    convert byte array to unsigned integer
    """
    if len(dbytes)==8:
      un_uint64obj=self.module.un_uint64_t()
      un_uint64obj.bytes=tuple(dbytes[:ctypes.sizeof(self.module.uint64_t)])
      uint64obj=un_uint64obj.uint64
      value=uint64obj.value
    elif len(dbytes)==4:
      un_uint32obj=self.module.un_uint32_t()
      un_uint32obj.bytes=tuple(dbytes[:ctypes.sizeof(self.module.uint32_t)])
      uint32obj=un_uint32obj.uint32
      value=uint32obj.value
    elif len(dbytes)==2:
      un_uint16obj=self.module.un_uint16_t()
      un_uint16obj.bytes=tuple(dbytes[:ctypes.sizeof(self.module.uint16_t)])
      uint16obj=un_uint16obj.uint16
      value=uint16obj.value
    else:
      print "ERROR: size of byte array is not support",dbytes
    return value
  def parse_options(self,dbytes,debug=False):
    """
    parse options section
    packet block
    """
    while len(dbytes) > 4:
      un_pcapng_optionsobj=self.module.un_pcapng_options_t()
      un_pcapng_optionsobj.bytes=tuple(dbytes[:ctypes.sizeof(self.module.pcapng_options_t)])
      pcapng_optionsobj=un_pcapng_optionsobj.pcapng_options
      option_code=pcapng_optionsobj.option_code
      option_length=pcapng_optionsobj.option_length
      if option_code==0: # end of option
        dbytes=dbytes[4:]
        break
      option_length_w_padding=option_length+self.module.padding_len(option_length)        # 4-byte align
      if option_length > 0:
        option_data=dbytes[4:4+option_length]
        if debug: print "  option_code",option_code
        if debug: print "  option_length",option_length
        if   option_code == self.module.PCAPNG_OPT_CODE_num["OPT_ENDOFOPT"]:                  # 0
          pass
        elif option_code == self.module.PCAPNG_OPT_CODE_num["OPT_COMMENT"]:                   # 1
          if debug: print "  comment",''.join(map(lambda x: chr(x),option_data))
        else:
          if debug: print "  option_data",''.join(map(lambda x: chr(x),option_data))
          if debug: print "  option_data",''.join(map(lambda x: '%02x'%x,option_data))
      dbytes=dbytes[4+option_length_w_padding:]

  
  def parse_shb_options(self,dbytes,debug=False):
    """
    parse shb options section
    """
    while len(dbytes) > 4:
      un_pcapng_optionsobj=self.module.un_pcapng_options_t()
      un_pcapng_optionsobj.bytes=tuple(dbytes[:ctypes.sizeof(self.module.pcapng_options_t)])
      pcapng_optionsobj=un_pcapng_optionsobj.pcapng_options
      option_code=pcapng_optionsobj.option_code
      option_length=pcapng_optionsobj.option_length
      if option_code==0: # end of option
        dbytes=dbytes[4:]
        break
      option_length_w_padding=option_length+self.module.padding_len(option_length)        # 4-byte align
      if option_length > 0:
        option_data=dbytes[4:4+option_length]
        if debug: print "  option_code",option_code
        if debug: print "  option_length",option_length
        if   option_code == self.module.PCAPNG_OPT_CODE_num["OPT_ENDOFOPT"]:                  # 0
          pass
        elif option_code == self.module.PCAPNG_OPT_CODE_num["OPT_COMMENT"]:                   # 1
          if debug: print "  option_data",''.join(map(lambda x: chr(x),option_data))
        elif option_code == self.module.PCAPNG_SHB_OPTION_num["SHB_HARDWARE"]:                # 2
          if debug: print "  comment",''.join(map(lambda x: chr(x),option_data))
        elif option_code == self.module.PCAPNG_SHB_OPTION_num["SHB_OS"]:                      # 3
          if debug: print "  os",''.join(map(lambda x: chr(x),option_data))
        elif option_code == self.module.PCAPNG_SHB_OPTION_num["SHB_USERAPPL"]:                # 4
          if debug: print "  userappl",''.join(map(lambda x: chr(x),option_data))
        else:
          if debug: print "  option_data",''.join(map(lambda x: chr(x),option_data))
          if debug: print "  option_data",''.join(map(lambda x: '%02x'%x,option_data))
      dbytes=dbytes[4+option_length_w_padding:]
  
  def parse_idb_options(self,dbytes,debug=False):
    """
    parse idb options section
    """
    while len(dbytes) > 4:
      un_pcapng_optionsobj=self.module.un_pcapng_options_t()
      un_pcapng_optionsobj.bytes=tuple(dbytes[:ctypes.sizeof(self.module.pcapng_options_t)])
      pcapng_optionsobj=un_pcapng_optionsobj.pcapng_options
      option_code=pcapng_optionsobj.option_code
      option_length=pcapng_optionsobj.option_length
      if option_code==0: # end of option
        dbytes=dbytes[4:]
        break
      option_length_w_padding=option_length+self.module.padding_len(option_length)        # 4-byte align
      if option_length > 0:
        option_data=dbytes[4:4+option_length]
        if debug: print "  option_code",option_code
        if debug: print "  option_length",option_length
        if   option_code == self.module.PCAPNG_OPT_CODE_num["OPT_ENDOFOPT"]:                  # 0
          pass
        elif option_code == self.module.PCAPNG_OPT_CODE_num["OPT_COMMENT"]:                   # 1
          if debug: print "  comment",''.join(map(lambda x: chr(x),option_data))
        elif option_code == self.module.PCAPNG_IDB_OPTION_num["IF_NAME"]:                     # 2
          if debug: print "  if_name",''.join(map(lambda x: chr(x),option_data))
        elif option_code == self.module.PCAPNG_IDB_OPTION_num["IF_DESCRIPTION"]:              # 3
          if debug: print "  if_description",''.join(map(lambda x: chr(x),option_data))
        elif option_code == self.module.PCAPNG_IDB_OPTION_num["IF_IPv4addr"]:                 # 4
          if debug: print "  IPv4addr",''.join(map(lambda x: '%02x'%x,option_data))
        elif option_code == self.module.PCAPNG_IDB_OPTION_num["IF_IPv6addr"]:                 # 5
          if debug: print "  IPv6addr",''.join(map(lambda x: '%02x'%x,option_data))
        elif option_code == self.module.PCAPNG_IDB_OPTION_num["IF_MACaddr"]:                  # 6
          if debug: print "  if_MACaddr",''.join(map(lambda x: '%02x'%x,option_data))
        elif option_code == self.module.PCAPNG_IDB_OPTION_num["IF_EUIaddr"]:                  # 7
          if debug: print "  if_EUIaddr",''.join(map(lambda x: '%02x'%x,option_data))
        elif option_code == self.module.PCAPNG_IDB_OPTION_num["IF_SPEED"]:                    # 8
          if debug: print "  if_speed",''.join(map(lambda x: '%02x'%x,option_data))
          if debug: print "  if_speed",self.byte2value(option_data)
        elif option_code == self.module.PCAPNG_IDB_OPTION_num["IF_TSRESOL"]:                  # 9
          if debug: print "  if_tsresol",option_data[0]
          self.tsresol=option_data[0]
        elif option_code == self.module.PCAPNG_IDB_OPTION_num["IF_TZONE"]:                    # 10
          if debug: print "  if_tzone",''.join(map(lambda x: '%02x'%x,option_data))
        elif option_code == self.module.PCAPNG_IDB_OPTION_num["IF_FILTER"]:                   # 11
          if debug: print "  if_filter",''.join(map(lambda x: chr(x),option_data))
          #if debug: print "  if_filter",''.join(map(lambda x: '%02x'%x,option_data))
        elif option_code == self.module.PCAPNG_IDB_OPTION_num["IF_OS"]:                       # 12
          if debug: print "  if_os",''.join(map(lambda x: chr(x),option_data))
        elif option_code == self.module.PCAPNG_IDB_OPTION_num["IF_FCSLEN"]:                   # 13
          if debug: print "  if_fcslen",option_data[0]
        elif option_code == self.module.PCAPNG_IDB_OPTION_num["IF_TSOFFSET"]:                 # 14
          if debug: print "  if_tsoffset",self.byte2value(option_data)
        else:
          if debug: print "  option_data",''.join(map(lambda x: chr(x),option_data))
          if debug: print "  option_data",''.join(map(lambda x: '%02x'%x,option_data))
      dbytes=dbytes[4+option_length_w_padding:]
  

  def parse_epb_options(self,dbytes,debug=False):
    """
    parse epb options section
    """
    while len(dbytes) > 4:
      un_pcapng_optionsobj=self.module.un_pcapng_options_t()
      un_pcapng_optionsobj.bytes=tuple(dbytes[:ctypes.sizeof(self.module.pcapng_options_t)])
      pcapng_optionsobj=un_pcapng_optionsobj.pcapng_options
      option_code=pcapng_optionsobj.option_code
      option_length=pcapng_optionsobj.option_length
      if option_code==0: # end of option
        dbytes=dbytes[4:]
        break
      option_length_w_padding=option_length+self.module.padding_len(option_length)        # 4-byte align
      if option_length > 0:
        option_data=dbytes[4:4+option_length]
        if debug: print "  option_code",option_code
        if debug: print "  option_length",option_length
        if   option_code == self.module.PCAPNG_OPT_CODE_num["OPT_ENDOFOPT"]:                  # 0
          pass
        elif option_code == self.module.PCAPNG_OPT_CODE_num["OPT_COMMENT"]:                   # 1
          if debug: print "  comment",''.join(map(lambda x: chr(x),option_data))
        elif option_code == self.module.PCAPNG_EPB_OPTION_num["EPB_FLAGS"]:                   # 2
          if debug: print "  epb_flags",''.join(map(lambda x: '%02x'%x,option_data))
        elif option_code == self.module.PCAPNG_EPB_OPTION_num["EPB_HASH"]:                    # 3
          if debug: print "  epb_hash",''.join(map(lambda x: '%02x'%x,option_data))
        elif option_code == self.module.PCAPNG_EPB_OPTION_num["EPB_DROPCOUNT"]:               # 4
          if debug: print "  epb_dropcount",self.byte2value(option_data)
        else:
          if debug: print "  option_data",''.join(map(lambda x: chr(x),option_data))
          if debug: print "  option_data",''.join(map(lambda x: '%02x'%x,option_data))
      dbytes=dbytes[4+option_length_w_padding:]
  
  def parse_nrb_options(self,dbytes,debug=False):
    """
    parse nrb options section
    """
    while len(dbytes) > 4:
      un_pcapng_optionsobj=self.module.un_pcapng_options_t()
      un_pcapng_optionsobj.bytes=tuple(dbytes[:ctypes.sizeof(self.module.pcapng_options_t)])
      pcapng_optionsobj=un_pcapng_optionsobj.pcapng_options
      option_code=pcapng_optionsobj.option_code
      option_length=pcapng_optionsobj.option_length
      if option_code==0: # end of option
        dbytes=dbytes[4:]
        break
      option_length_w_padding=option_length+self.module.padding_len(option_length)        # 4-byte align
      if option_length > 0:
        option_data=dbytes[4:4+option_length]
        if debug: print "  option_code",option_code
        if debug: print "  option_length",option_length
        if   option_code == self.module.PCAPNG_OPT_CODE_num["OPT_ENDOFOPT"]:                  # 0
          pass
        elif option_code == self.module.PCAPNG_OPT_CODE_num["OPT_COMMENT"]:                   # 1
          if debug: print "  comment",''.join(map(lambda x: chr(x),option_data))
        elif option_code == self.module.PCAPNG_NRB_OPTION_num["NS_DNSNAME"]:                  # 2
          if debug: print "  ns_dnsname",''.join(map(lambda x: chr(x),option_data))
        elif option_code == self.module.PCAPNG_NRB_OPTION_num["NS_DNSIP4addr"]:               # 3
          if debug: print "  ns_dnsip4addr",''.join(map(lambda x: '%02x'%x,option_data[:4]))
          if debug: print "  ns_dnsip4addr",''.join(map(lambda x: chr(x),option_data[4:]))
        elif option_code == self.module.PCAPNG_NRB_OPTION_num["NS_DNSIP6addr"]:               # 4
          if debug: print "  ns_dnsip4addr",''.join(map(lambda x: '%02x'%x,option_data[:16]))
          if debug: print "  ns_dnsip4addr",''.join(map(lambda x: chr(x),option_data[16:]))
        else:
          if debug: print "  option_data",''.join(map(lambda x: chr(x),option_data))
          if debug: print "  option_data",''.join(map(lambda x: '%02x'%x,option_data))
      dbytes=dbytes[4+option_length_w_padding:]
  
  def parse_isb_options(self,dbytes,debug=False):
    """
    parse isb options section
    """
    while len(dbytes) > 4:
      un_pcapng_optionsobj=self.module.un_pcapng_options_t()
      un_pcapng_optionsobj.bytes=tuple(dbytes[:ctypes.sizeof(self.module.pcapng_options_t)])
      pcapng_optionsobj=un_pcapng_optionsobj.pcapng_options
      option_code=pcapng_optionsobj.option_code
      option_length=pcapng_optionsobj.option_length
      if option_code==0: # end of option
        dbytes=dbytes[4:]
        break
      option_length_w_padding=option_length+self.module.padding_len(option_length)        # 4-byte align
      if option_length > 0:
        option_data=dbytes[4:4+option_length]
        if debug: print "  option_code",option_code
        if debug: print "  option_length",option_length
        if   option_code == self.module.PCAPNG_OPT_CODE_num["OPT_ENDOFOPT"]:                  # 0
          pass
        elif option_code == self.module.PCAPNG_OPT_CODE_num["OPT_COMMENT"]:                   # 1
          if debug: print "  comment",''.join(map(lambda x: chr(x),option_data))
        elif option_code == self.module.PCAPNG_ISB_num["ISB_STARTTIME"]:                      # 2
          if debug: print "  isb_starttime",self.byte2value(option_data)
        elif option_code == self.module.PCAPNG_ISB_num["ISB_ENDTIME"]:                        # 3
          if debug: print "  isb_endtime",self.byte2value(option_data)
        elif option_code == self.module.PCAPNG_ISB_num["ISB_IFRECV"]:                         # 4
          if debug: print "  isb_ifrecv",self.byte2value(option_data)
        elif option_code == self.module.PCAPNG_ISB_num["ISB_IFDROP"]:                         # 5
          if debug: print "  isb_ifdrop",self.byte2value(option_data)
        elif option_code == self.module.PCAPNG_ISB_num["ISB_FILTERACCEPT"]:                   # 6
          if debug: print "  isb_filteraccept",self.byte2value(option_data)
        elif option_code == self.module.PCAPNG_ISB_num["ISB_OSDROP"]:                         # 7
          if debug: print "  isb_osdrop",self.byte2value(option_data)
        elif option_code == self.module.PCAPNG_ISB_num["ISB_USRDELIV"]:                       # 8
          if debug: print "  isb_usrdeliv",self.byte2value(option_data)
        else:
          if debug: print "  option_data",''.join(map(lambda x: chr(x),option_data))
          if debug: print "  option_data",''.join(map(lambda x: '%02x'%x,option_data))
      dbytes=dbytes[4+option_length_w_padding:]
 
      

  def parse_shb(self,blk_len,dbytes,debug=False):
    """
    parse section header block
    """
    un_pcapng_section_header_blockobj=self.module.un_pcapng_section_header_block_t()
    un_pcapng_section_header_blockobj.bytes=tuple(dbytes[:ctypes.sizeof(self.module.pcapng_section_header_block_t)])
    pcapng_section_header_blockobj=un_pcapng_section_header_blockobj.pcapng_section_header_block
    blk_type=pcapng_section_header_blockobj.block_type
    blk_len=pcapng_section_header_blockobj.block_total_length
    blk_magic=pcapng_section_header_blockobj.byte_order_magic
    major=pcapng_section_header_blockobj.major_version
    minor=pcapng_section_header_blockobj.minor_version
    section_len=pcapng_section_header_blockobj.section_length
    if debug: print "section header block:"
    if debug: print "  blk_type",blk_type
    if debug: print "  blk_len",blk_len
    if debug: print "  blk_magic",blk_magic
    if debug: print "  major",major
    if debug: print "  minor",minor
    if debug: print "  section_len",section_len
    if blk_len !=28: # options list
      options=dbytes[24:blk_len-4]
      self.parse_shb_options(options)
      if debug: print "  options",options
    if debug:
      if debug: print blk_type,blk_len,blk_magic,major,minor,section_len
        
    if dbytes[:blk_len][-4:]!=dbytes[4:8]:
      if debug: print "header length %s not match trailer length %s" %(''.join(map(lambda x:'%02x'%x,dbytes[:blk_len][-4:])), ''.join(map(lambda x:'%02x'%x,dbytes[4:8])))

    return dbytes[blk_len:]
  def parse_idb(self,blk_len,dbytes,debug=False):
    """
    parse interface description block
    """
    un_pcapng_interface_descr_blockobj=self.module.un_pcapng_interface_descr_block_t()
    un_pcapng_interface_descr_blockobj.bytes=tuple(dbytes[:ctypes.sizeof(self.module.pcapng_interface_descr_block_t)])
    pcapng_interface_descr_blockobj=un_pcapng_interface_descr_blockobj.pcapng_interface_descr_block
    blk_type=pcapng_interface_descr_blockobj.block_type
    blk_len=pcapng_interface_descr_blockobj.block_total_length
    linktype=pcapng_interface_descr_blockobj.linktype
    snaplen=pcapng_interface_descr_blockobj.snaplen
    if debug: print "interface description block:"
    if debug: print "  blk_type",blk_type
    if debug: print "  blk_len",blk_len
    if debug: print "  linktype",linktype
    if debug: print "  snaplen",snaplen
    if blk_len > 20:
      options=dbytes[16:blk_len-4]
      self.parse_idb_options(options)
      if debug: print "  options",options

  def parse_pb(self,blk_len,dbytes,debug=False):
    """
    parse packet block
    """
    un_pcapng_pkt_blockobj=self.module.un_pcapng_pkt_block_t()
    un_pcapng_pkt_blockobj.bytes=tuple(dbytes[:ctypes.sizeof(self.module.pcapng_pkt_block_t)])
    pcapng_pkt_blockobj=un_pcapng_pkt_blockobj.pcapng_pkt_block
    blk_type=pcapng_pkt_blockobj.block_type
    blk_len=pcapng_pkt_blockobj.block_total_length
    intf_id=pcapng_pkt_blockobj.intf_id
    drop_count=pcapng_pkt_blockobj.drop_count
    ts_high=pcapng_pkt_blockobj.ts_high
    ts_low=pcapng_pkt_blockobj.ts_low
    captured_len=pcapng_pkt_blockobj.captured_len
    packet_len=pcapng_pkt_blockobj.packet_len
    if debug: print "packet block:"
    if debug: print "  blk_type",blk_type
    if debug: print "  blk_len",blk_len
    if debug: print "  intf_id",intf_id
    if debug: print "  drop_count",drop_count
    if debug: print "  ts_high",ts_high
    if debug: print "  ts_low",ts_low
    if debug: print "  captured_len",captured_len
    if debug: print "  packet_len",packet_len
    captured_len_w_padding=captured_len+self.module.padding_len(captured_len)        # 4-byte align
    if captured_len > 0:
      captured_data=dbytes[28:28+captured_len_w_padding]
      if debug: print "  captured_data",''.join(map(lambda x: '%02x'%x,captured_data))
      self.pkts.append((ts_high,ts_low,dbytes[28:28+captured_len]))
    if blk_len > (captured_len_w_padding+32):
      options=dbytes[28+captured_len_w_padding:blk_len-4]
      self.parse_epb_options(options)
      if debug: print "  options",options

  def parse_epb(self,blk_len,dbytes,debug=False):
    """
    parse enhanced packet block
    """
    un_pcapng_enhanced_pkt_blockobj=self.module.un_pcapng_enhanced_pkt_block_t()
    un_pcapng_enhanced_pkt_blockobj.bytes=tuple(dbytes[:ctypes.sizeof(self.module.pcapng_enhanced_pkt_block_t)])
    pcapng_enhanced_pkt_blockobj=un_pcapng_enhanced_pkt_blockobj.pcapng_enhanced_pkt_block
    blk_type=pcapng_enhanced_pkt_blockobj.block_type
    blk_len=pcapng_enhanced_pkt_blockobj.block_total_length
    intf_id=pcapng_enhanced_pkt_blockobj.intf_id
    ts_high=pcapng_enhanced_pkt_blockobj.ts_high
    ts_low=pcapng_enhanced_pkt_blockobj.ts_low
    captured_len=pcapng_enhanced_pkt_blockobj.captured_len
    packet_len=pcapng_enhanced_pkt_blockobj.packet_len
    if debug: print "enhanced packet block:"
    if debug: print "  blk_type",blk_type
    if debug: print "  blk_len",blk_len
    if debug: print "  intf_id",intf_id
    if debug: print "  ts_high",ts_high
    if debug: print "  ts_low",ts_low
    if debug: print "  captured_len",captured_len
    if debug: print "  packet_len",packet_len
    captured_len_w_padding=captured_len+self.module.padding_len(captured_len)        # 4-byte align
    if captured_len > 0:
      captured_data=dbytes[28:28+captured_len_w_padding]
      if debug: print "  captured_data",''.join(map(lambda x: '%02x'%x,captured_data))
      self.pkts.append((ts_high,ts_low,dbytes[28:28+captured_len]))
    if blk_len > (captured_len_w_padding+32):
      options=dbytes[28+captured_len_w_padding:blk_len-4]
      self.parse_epb_options(options)
      if debug: print "  options",options

  def parse_spb(self,blk_len,dbytes,debug=False):
    """
    parse simple packet block
    """
    un_pcapng_simple_pkt_blockobj=self.module.un_pcapng_simple_pkt_block_t()
    un_pcapng_simple_pkt_blockobj.bytes=tuple(dbytes[:ctypes.sizeof(self.module.pcapng_simple_pkt_block_t)])
    pcapng_simple_pkt_blockobj=un_pcapng_simple_pkt_blockobj.pcapng_simple_pkt_block
    blk_type=pcapng_simple_pkt_blockobj.block_type
    blk_len=pcapng_simple_pkt_blockobj.block_total_length
    packet_len=pcapng_simple_pkt_blockobj.packet_len
    if debug: print "simple packet block:"
    if debug: print "  blk_type",blk_type
    if debug: print "  blk_len",blk_len
    if debug: print "  packet_len",packet_len
    if packet_len > 0:
      packet_data=dbytes[12:12+packet_len]
      if debug: print "  packet_data",''.join(map(lambda x: '%02x'%x,packet_data))
  def parse_nrb(self,blk_len,dbytes,debug=False):
    """
    parse name resolution block
    """
    un_pcapng_name_resolution_blockobj=self.module.un_pcapng_name_resolution_block_t()
    un_pcapng_name_resolution_blockobj.bytes=tuple(dbytes[:ctypes.sizeof(self.module.pcapng_name_resolution_block_t)])
    pcapng_name_resolution_blockobj=un_pcapng_name_resolution_blockobj.pcapng_name_resolution_block
    blk_type=pcapng_name_resolution_blockobj.block_type
    blk_len=pcapng_name_resolution_blockobj.block_total_length
    if debug: print "name resolution block:"
    if debug: print "  blk_type",blk_type
    if debug: print "  blk_len",blk_len
    dbytes=dbytes[8:]
    while len(dbytes) > 4:
      un_pcapng_nrb_recordobj=self.module.un_pcapng_nrb_record_t()
      un_pcapng_nrb_recordobj.bytes=tuple(dbytes[:ctypes.sizeof(self.module.pcapng_nrb_record_t)])
      pcapng_nrb_recordobj=un_pcapng_nrb_recordobj.pcapng_nrb_record
      record_type=pcapng_nrb_recordobj.record_type
      record_len=pcapng_nrb_recordobj.record_len
      if record_type==0: # end of record
        dbytes=dbytes[4:]
        break
      record_len_w_padding=record_len+self.module.padding_len(record_len)        # 4-byte align
      if record_len > 0:
        record_data=dbytes[4:4+record_len]
        if debug: print "  record_type",record_type
        if debug: print "  record_len",record_len
        if debug: print "  record_data",''.join(map(lambda x: chr(x),record_data))
      dbytes=dbytes[4+record_len_w_padding:]
    if len(dbytes) > 4:
      options=dbytes[:-4]
      self.parse_nrb_options(options)
      if debug: print "  options",options
      
  def parse_isb(self,blk_len,dbytes,debug=False):
    """
    parse interface statistics block
    """
    un_pcapng_interface_stat_blockobj=self.module.un_pcapng_interface_stat_block_t()
    un_pcapng_interface_stat_blockobj.bytes=tuple(dbytes[:ctypes.sizeof(self.module.pcapng_interface_stat_block_t)])
    pcapng_interface_stat_blockobj=un_pcapng_interface_stat_blockobj.pcapng_interface_stat_block
    blk_type=pcapng_interface_stat_blockobj.block_type
    blk_len=pcapng_interface_stat_blockobj.block_total_length
    intf_id=pcapng_interface_stat_blockobj.intf_id
    ts_high=pcapng_interface_stat_blockobj.ts_high
    ts_low=pcapng_interface_stat_blockobj.ts_low
    if debug: print "enhanced packet block:"
    if debug: print "  blk_type",blk_type
    if debug: print "  blk_len",blk_len
    if debug: print "  intf_id",intf_id
    if debug: print "  ts_high",ts_high
    if debug: print "  ts_low",ts_low
    if blk_len > 24:
      options=dbytes[20+captured_len:blk_len-4]
      self.parse_isb_options(options)
      if debug: print "  options",options
  def read(self,fname):
    """
    read pcapng file
    """
    try:
      with gzip.open(fname,'rb') as fh:
        dbytes=fh.read()
        self.dbytes=struct.unpack('%dB'%len(dbytes),dbytes)
    except:
      with open(fname,'rb') as fh:
        dbytes=fh.read()
        self.dbytes=struct.unpack('%dB'%len(dbytes),dbytes)
      
  def check_endian(self,dbytes,debug=False):
    """
    """
    un_pcapng_section_header_blockobj=self.module.un_pcapng_section_header_block_t()
    un_pcapng_section_header_blockobj.bytes=tuple(dbytes[:ctypes.sizeof(self.module.pcapng_section_header_block_t)])
    pcapng_section_header_blockobj=un_pcapng_section_header_blockobj.pcapng_section_header_block
    blk_type=pcapng_section_header_blockobj.block_type
    blk_magic=pcapng_section_header_blockobj.byte_order_magic
    if blk_type != 0x0a0d0d0a:
      if debug: print "this is not pcapng"
      exit(1)
    if blk_magic==0x1a2b3c4d:
      if debug: print "this big endian"
      self.module=importlib.import_module('pcapng_header')
      bigendian=True
    else:
      if debug: print "this little endian"
      self.module=importlib.import_module('pcapng_le_header')
      bigendian=False
    return bigendian

  def parse_block(self,dbytes,debug=False):
    """
    """
    while len(dbytes) >=8:
      un_pcapng_gbsobj=self.module.un_pcapng_gbs_t()
      un_pcapng_gbsobj.bytes=tuple(dbytes[:ctypes.sizeof(self.module.pcapng_gbs_t)])
      pcapng_gbsobj=un_pcapng_gbsobj.pcapng_gbs
      blk_type=pcapng_gbsobj.block_type
      blk_len=pcapng_gbsobj.block_total_length
      if blk_len > len(dbytes):
        print "ERROR: expect block size %d is larger than the captured data %d"%(blk_len,len(dbytes))
        break
      blk_len_w_padding=blk_len+self.module.padding_len(blk_len)        # 4-byte align
      self.blocks.append((blk_type,blk_len,dbytes[:blk_len_w_padding-4]))
      dbytes=dbytes[blk_len_w_padding:]
    if len(dbytes) >0:
      print "ERROR: the leftover data %d"%len(dbytes)
    if debug: print len(self.blocks)
    for blockno,(blk_type,blk_len,data) in enumerate(self.blocks,1):
      if debug: print 'block no:',blockno
      if   blk_type == 0x00000000: # Reserved
        print "ERROR: Reserved block type"
      elif blk_type == 0x00000001: # Interface Description Block
        self.parse_idb(blk_len,data,debug=debug)
      elif blk_type == 0x00000002: # Packet Block (obsolete)
        #print "ERROR: Obsolete packet block type"
        self.parse_pb(blk_len,data,debug=debug)
      elif blk_type == 0x00000003: # Simple Packet Block
        self.parse_spb(blk_len,data,debug=debug)
      elif blk_type == 0x00000004: # Name Resolution Block (optional)
        self.parse_nrb(blk_len,data,debug=debug)
      elif blk_type == 0x00000005: # Interface Statistics Block
        self.parse_isb(blk_len,data,debug=debug)
      elif blk_type == 0x00000006: # Enhanced PacketBlock
        self.parse_epb(blk_len,data,debug=debug)
      elif blk_type == 0x00000007: # IRIG Timestamp Block
        print "ERROR: IRIG Timestamp block type is not supported"
      elif blk_type == 0x00000008: # Arinc 429 in AFDX Encapsulation Information Block
        print "ERROR: AFDX Encapsulation Information block type is not supported"
      elif blk_type == 0x0a0d0d0a: # SectionHeaderBlock
        self.parse_shb(blk_len,data,debug=debug)
    
    
if __name__ == '__main__':
  import sys
  argc=len(sys.argv)
  if argc > 1: pcapng=sys.argv[1]
  if argc > 2: pcap=sys.argv[1]
  obj=pcapng_parser()
  obj.read(pcapng)
  obj.check_endian(obj.dbytes,debug=True)
  obj.parse_block(obj.dbytes,debug=True)
  #pprint(obj.blocks)
  
    
