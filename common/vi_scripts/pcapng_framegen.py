#!/usr/bin/env python2.7
import ctypes
import struct
from pprint import pprint
from pcapng_header import *
class pcapng_framegen(object):
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
    self.blocks=[]

  def value2byte(self,value,size):
    """
    convert unsigned integer to bytes
    """
    if size==8:
      un_uint64obj=un_uint64_t()
      uint64obj=un_uint64obj.uint64
      uint64obj.value=value
      return list(un_uint64obj.bytes)
    elif size==4:
      un_uint32obj=un_uint32_t()
      uint32obj=un_uint32obj.uint32
      uint32obj.value=value
      return list(un_uint32obj.bytes)
    elif size==2:
      un_uint16obj=un_uint16_t()
      uint16obj=un_uint16obj.uint16
      uint16obj.value=value
      return list(un_uint16obj.bytes)
    else:
      print "ERROR: size of byte array is not support",size
      return []

  
  def shb_options_framegen(self,
                           option_code          = 0,
                           option_length        = 0,
                           option_data          = [],
                          ):
    """
    generate shb options section frame
    """
    dbytes=[]
    un_pcapng_optionsobj=un_pcapng_options_t()
    pcapng_optionsobj=un_pcapng_optionsobj.pcapng_options
    pcapng_optionsobj.option_code             = option_code
    if not isinstance(option_data,int):
      option_length=len(option_data)
    pcapng_optionsobj.option_length           = option_length
    if   option_code == PCAPNG_OPT_CODE_num["OPT_ENDOFOPT"]:                  # 0
      if option_length > 0:
        print "Error: end of option and length is not zero %d"%option_length
      else:
        dbytes+=(list(un_pcapng_optionsobj.bytes))
    elif option_code == PCAPNG_OPT_CODE_num["OPT_COMMENT"]:                   # 1
      dbytes+=(list(un_pcapng_optionsobj.bytes))
      dbytes+=map(lambda x: ord(x),option_data)
      dbytes+=[0]*padding_len(option_length)        # 4-byte align
    elif option_code == PCAPNG_SHB_OPTION_num["SHB_HARDWARE"]:                # 2
      dbytes+=(list(un_pcapng_optionsobj.bytes))
      dbytes+=map(lambda x: ord(x),option_data)
      dbytes+=[0]*padding_len(option_length)        # 4-byte align
    elif option_code == PCAPNG_SHB_OPTION_num["SHB_OS"]:                      # 3
      dbytes+=(list(un_pcapng_optionsobj.bytes))
      dbytes+=map(lambda x: ord(x),option_data)
      dbytes+=[0]*padding_len(option_length)        # 4-byte align
    elif option_code == PCAPNG_SHB_OPTION_num["SHB_USERAPPL"]:                # 4
      dbytes+=(list(un_pcapng_optionsobj.bytes))
      dbytes+=map(lambda x: ord(x),option_data)
      dbytes+=[0]*padding_len(option_length)        # 4-byte align
    else:
      print "ERROR: shb option code %d is not supported"%option_code
    return dbytes
  
  def idb_options_framegen(self,
                           option_code          = 0,
                           option_length        = 0,
                           option_data          = [],
                          ):
    """
    generate idb options section frame
    """
    dbytes=[]
    un_pcapng_optionsobj=un_pcapng_options_t()
    pcapng_optionsobj=un_pcapng_optionsobj.pcapng_options
    pcapng_optionsobj.option_code             = option_code
    if not isinstance(option_data,int):
      option_length=len(option_data)
    pcapng_optionsobj.option_length           = option_length
    if   option_code == PCAPNG_OPT_CODE_num["OPT_ENDOFOPT"]:                  # 0
      if option_length > 0:
        print "Error: end of option and length is not zero %d"%option_length
      else:
        dbytes+=(list(un_pcapng_optionsobj.bytes))
    elif option_code == PCAPNG_OPT_CODE_num["OPT_COMMENT"]:                   # 1
      dbytes+=(list(un_pcapng_optionsobj.bytes))
      dbytes+=map(lambda x: ord(x),option_data)
      dbytes+=[0]*padding_len(option_length)        # 4-byte align
    elif option_code == PCAPNG_IDB_OPTION_num["IF_NAME"]:                     # 2
      dbytes+=(list(un_pcapng_optionsobj.bytes))
      dbytes+=map(lambda x: ord(x),option_data)
      dbytes+=[0]*padding_len(option_length)        # 4-byte align
    elif option_code == PCAPNG_IDB_OPTION_num["IF_DESCRIPTION"]:              # 3
      dbytes+=(list(un_pcapng_optionsobj.bytes))
      dbytes+=map(lambda x: ord(x),option_data)
      dbytes+=[0]*padding_len(option_length)        # 4-byte align
    elif option_code == PCAPNG_IDB_OPTION_num["IF_IPv4addr"]:                 # 4
      dbytes+=(list(un_pcapng_optionsobj.bytes))
      dbytes+=option_data
      dbytes+=[0]*padding_len(option_length)        # 4-byte align
      if option_length!=8:
        print "Error: if_ipv4addr option_lenght is not 8 but %d"%option_length
    elif option_code == PCAPNG_IDB_OPTION_num["IF_IPv6addr"]:                 # 5
      dbytes+=(list(un_pcapng_optionsobj.bytes))
      dbytes+=option_data
      dbytes+=[0]*padding_len(option_length)        # 4-byte align
      if option_length!=17:
        print "Error: if_ipv6addr option_lenght is not 17 but %d"%option_length
    elif option_code == PCAPNG_IDB_OPTION_num["IF_MACaddr"]:                  # 6
      dbytes+=(list(un_pcapng_optionsobj.bytes))
      dbytes+=option_data
      dbytes+=[0]*padding_len(option_length)        # 4-byte align
      if option_length!=6:
        print "Error: if_macaddr option_lenght is not 6 but %d"%option_length
    elif option_code == PCAPNG_IDB_OPTION_num["IF_EUIaddr"]:                  # 7
      dbytes+=(list(un_pcapng_optionsobj.bytes))
      dbytes+=option_data
      dbytes+=[0]*padding_len(option_length)        # 4-byte align
      if option_length!=8:
        print "Error: if_euiaddr option_lenght is not 8 but %d"%option_length
    elif option_code == PCAPNG_IDB_OPTION_num["IF_SPEED"]:                    # 8
      dbytes+=(list(un_pcapng_optionsobj.bytes))
      dbytes+=self.value2byte(option_data,8)
      dbytes+=[0]*padding_len(option_length)        # 4-byte align
      if option_length!=8:
        print "Error: if_speed option_lenght is not 8 but %d"%option_length
    elif option_code == PCAPNG_IDB_OPTION_num["IF_TSRESOL"]:                  # 9
      dbytes+=(list(un_pcapng_optionsobj.bytes))
      dbytes+=option_data
      dbytes+=[0]*padding_len(option_length)        # 4-byte align
      if option_length!=1:
        print "Error: if_tsresol option_lenght is not 1 but %d"%option_length
    elif option_code == PCAPNG_IDB_OPTION_num["IF_TZONE"]:                    # 10
      dbytes+=(list(un_pcapng_optionsobj.bytes))
      dbytes+=self.value2byte(option_data,4)
      dbytes+=[0]*padding_len(option_length)        # 4-byte align
      if option_length!=4:
        print "Error: if_tzone option_lenght is not 4 but %d"%option_length
    elif option_code == PCAPNG_IDB_OPTION_num["IF_FILTER"]:                   # 11
      option_length=len(option_data[1])+1
      pcapng_optionsobj.option_length           = option_length
      dbytes+=(list(un_pcapng_optionsobj.bytes))
      dbytes+=option_data[0]
      dbytes+=map(lambda x: ord(x),option_data[0])
      dbytes+=[0]*padding_len(option_length)        # 4-byte align
    elif option_code == PCAPNG_IDB_OPTION_num["IF_OS"]:                       # 12
      dbytes+=(list(un_pcapng_optionsobj.bytes))
      dbytes+=map(lambda x: ord(x),option_data)
      dbytes+=[0]*padding_len(option_length)        # 4-byte align
    elif option_code == PCAPNG_IDB_OPTION_num["IF_FCSLEN"]:                   # 13
      dbytes+=(list(un_pcapng_optionsobj.bytes))
      dbytes+=option_data
      dbytes+=[0]*padding_len(option_length)        # 4-byte align
      if option_length!=1:
        print "Error: if_fcslen option_lenght is not 1 but %d"%option_length
    elif option_code == PCAPNG_IDB_OPTION_num["IF_TSOFFSET"]:                  # 14
      dbytes+=(list(un_pcapng_optionsobj.bytes))
      dbytes+=self,value2byte(option_data,8)
      dbytes+=[0]*padding_len(option_length)        # 4-byte align
      if option_length!=8:
        print "Error: if_tsoffset option_lenght is not 8 but %d"%option_length
    return dbytes 

  def epb_options_framegen(self,
                           option_code          = 0,
                           option_length        = 0,
                           option_data          = [],
                          ):
    """
    generate epb options section frame
    """
    dbytes=[]
    un_pcapng_optionsobj=un_pcapng_options_t()
    pcapng_optionsobj=un_pcapng_optionsobj.pcapng_options
    pcapng_optionsobj.option_code             = option_code
    if not isinstance(option_data,int):
      option_length=len(option_data)
    pcapng_optionsobj.option_length           = option_length
    if   option_code == PCAPNG_OPT_CODE_num["OPT_ENDOFOPT"]:                  # 0
      if option_length > 0:
        print "Error: end of option and length is not zero %d"%option_length
      else:
        dbytes+=(list(un_pcapng_optionsobj.bytes))
    elif option_code == PCAPNG_OPT_CODE_num["OPT_COMMENT"]:                   # 1
      dbytes+=(list(un_pcapng_optionsobj.bytes))
      dbytes+=map(lambda x: ord(x),option_data)
      dbytes+=[0]*padding_len(option_length)        # 4-byte align
    elif option_code == PCAPNG_EPB_OPTION_num["EPB_FLAGS"]:                   # 2
      dbytes+=(list(un_pcapng_optionsobj.bytes))
      dbytes+=self.value2byte(option_data,4)
      dbytes+=[0]*padding_len(option_length)        # 4-byte align
      if option_length!=4:
        print "Error: epb_dropcount option_lenght is not 4 but %d"%option_length
    elif option_code == PCAPNG_EPB_OPTION_num["EPB_HASH"]:                    # 3
      dbytes+=(list(un_pcapng_optionsobj.bytes))
      dbytes+=option_data
      dbytes+=[0]*padding_len(option_length)        # 4-byte align
    elif option_code == PCAPNG_EPB_OPTION_num["EPB_DROPCOUNT"]:               # 4
      dbytes+=(list(un_pcapng_optionsobj.bytes))
      dbytes+=self,value2byte(option_data,8)
      dbytes+=[0]*padding_len(option_length)        # 4-byte align
      if option_length!=8:
        print "Error: epb_dropcount option_lenght is not 8 but %d"%option_length
    return dbytes

  def nrb_options_framegen(self,
                           option_code          = 0,
                           option_length        = 0,
                           option_data          = [],
                          ):
    """
    generate nrb options section frame
    """
    dbytes=[]
    un_pcapng_optionsobj=un_pcapng_options_t()
    pcapng_optionsobj=un_pcapng_optionsobj.pcapng_options
    pcapng_optionsobj.option_code             = option_code
    if not isinstance(option_data,int):
      option_length=len(option_data)
    pcapng_optionsobj.option_length           = option_length
    if   option_code == PCAPNG_OPT_CODE_num["OPT_ENDOFOPT"]:                  # 0
      if option_length > 0:
        print "Error: end of option and length is not zero %d"%option_length
      else:
        dbytes+=(list(un_pcapng_optionsobj.bytes))
    elif option_code == PCAPNG_OPT_CODE_num["OPT_COMMENT"]:                   # 1
      dbytes+=(list(un_pcapng_optionsobj.bytes))
      dbytes+=map(lambda x: ord(x),option_data)
      dbytes+=[0]*padding_len(option_length)        # 4-byte align
    elif option_code == PCAPNG_NRB_OPTION_num["NS_DNSNAME"]:                  # 2
      dbytes+=(list(un_pcapng_optionsobj.bytes))
      dbytes+=map(lambda x: ord(x),option_data)
      dbytes+=[0]*padding_len(option_length)        # 4-byte align
    elif option_code == PCAPNG_NRB_OPTION_num["NS_DNSIP4addr"]:               # 3
      dbytes+=(list(un_pcapng_optionsobj.bytes))
      dbytes+=option_data
      dbytes+=[0]*padding_len(option_length)        # 4-byte align
      if option_length!=4:
        print "Error: ns_dsip4addr option_lenght is not 4 but %d"%option_length
    elif option_code == PCAPNG_NRB_OPTION_num["NS_DNSIP6addr"]:               # 4
      dbytes+=(list(un_pcapng_optionsobj.bytes))
      dbytes+=option_data
      dbytes+=[0]*padding_len(option_length)        # 4-byte align
      if option_length!=16:
        print "Error: ns_dsip6addr option_lenght is not 16 but %d"%option_length
    return dbytes
  
  def isb_options_framegen(self,
                           option_code          = 0,
                           option_length        = 0,
                           option_data          = [],
                          ):
    """
    generate isb options section frame
    """
    dbytes=[]
    un_pcapng_optionsobj=un_pcapng_options_t()
    pcapng_optionsobj=un_pcapng_optionsobj.pcapng_options
    pcapng_optionsobj.option_code             = option_code
    if not isinstance(option_data,int):
      option_length=len(option_data)
    pcapng_optionsobj.option_length           = option_length
    if   option_code == PCAPNG_OPT_CODE_num["OPT_ENDOFOPT"]:                  # 0
      if option_length > 0:
        print "Error: end of option and length is not zero %d"%option_length
      else:
        dbytes+=(list(un_pcapng_optionsobj.bytes))
    elif option_code == PCAPNG_OPT_CODE_num["OPT_COMMENT"]:                   # 1
      dbytes+=(list(un_pcapng_optionsobj.bytes))
      dbytes+=map(lambda x: ord(x),option_data)
      dbytes+=[0]*padding_len(option_length)        # 4-byte align
    elif option_code == PCAPNG_ISB_num["ISB_STARTTIME"]:                      # 2
      dbytes+=(list(un_pcapng_optionsobj.bytes))
      dbytes+=self.value2byte(option_data,8)
      dbytes+=[0]*padding_len(option_length)        # 4-byte align
      if option_length!=8:
        print "Error: isb_starttime option_lenght is not 8 but %d"%option_length
    elif option_code == PCAPNG_ISB_num["ISB_ENDTIME"]:                        # 3
      dbytes+=(list(un_pcapng_optionsobj.bytes))
      dbytes+=self.value2byte(option_data,8)
      dbytes+=[0]*padding_len(option_length)        # 4-byte align
      if option_length!=8:
        print "Error: isb_endtime option_lenght is not 8 but %d"%option_length
    elif option_code == PCAPNG_ISB_num["ISB_IFRECV"]:                         # 4
      dbytes+=(list(un_pcapng_optionsobj.bytes))
      dbytes+=self.value2byte(option_data,8)
      dbytes+=[0]*padding_len(option_length)        # 4-byte align
      if option_length!=8:
        print "Error: isb_ifrecv option_lenght is not 8 but %d"%option_length
    elif option_code == PCAPNG_ISB_num["ISB_IFDROP"]:                         # 5
      dbytes+=(list(un_pcapng_optionsobj.bytes))
      dbytes+=self.value2byte(option_data,8)
      dbytes+=[0]*padding_len(option_length)        # 4-byte align
      if option_length!=8:
        print "Error: isb_ifdrop option_lenght is not 8 but %d"%option_length
    elif option_code == PCAPNG_ISB_num["ISB_FILTERACCEPT"]:                   # 6
      dbytes+=(list(un_pcapng_optionsobj.bytes))
      dbytes+=self.value2byte(option_data,8)
      dbytes+=[0]*padding_len(option_length)        # 4-byte align
      if option_length!=8:
        print "Error: isb_filteraccept option_lenght is not 8 but %d"%option_length
    elif option_code == PCAPNG_ISB_num["ISB_OSDROP"]:                         # 7
      dbytes+=(list(un_pcapng_optionsobj.bytes))
      dbytes+=self.value2byte(option_data,8)
      dbytes+=[0]*padding_len(option_length)        # 4-byte align
      if option_length!=8:
        print "Error: isb_osdrop option_lenght is not 8 but %d"%option_length
    elif option_code == PCAPNG_ISB_num["ISB_USRDELIV"]:                       # 8
      dbytes+=(list(un_pcapng_optionsobj.bytes))
      dbytes+=self.value2byte(option_data,8)
      dbytes+=[0]*padding_len(option_length)        # 4-byte align
      if option_length!=8:
        print "Error: isb_usrdeliv option_lenght is not 8 but %d"%option_length
    return dbytes
 
  def nrb_rec_gen(self,
                  record_type          = 0,
                  record_len           = 0,
                  record_data          = [],
                 ):
    """
    generate nrb record data
    """
    dbytes=[]
    un_pcapng_nrb_recordobj=un_pcapng_nrb_record_t()
    pcapng_nrb_recordobj=un_pcapng_nrb_recordobj.pcapng_nrb_record
    pcapng_nrb_recordobj.record_type             = record_type
    record_len=len(record_data)
    pcapng_nrb_recordobj.record_len              = record_len
    if   record_type == PCAPNG_RECORD_TYPE_num["NRES_ENDOFRECORD"]:              # 0
      if record_len > 0:
        print "Error: end of record and length is not zero %d"%record_len
      else:
        dbytes+=(list(un_pcapng_nrb_recordobj.bytes))
    elif record_type == PCAPNG_RECORD_TYPE_num["NRES_IP4RECORD"]:                # 1
      record_len=len(record_data[1])+16
      pcapng_recordsobj.record_len           = record_len
      dbytes+=(list(un_pcapng_recordsobj.bytes))
      dbytes+=record_data[0]
      dbytes+=map(lambda x: ord(x),record_data[1])
      dbytes+=[0]*padding_len(record_len)        # 4-byte align
    return dbytes
      

  def shb_framegen(self,
                   block_type           = 0x0a0d0d0a,
                   block_total_length   = 28,
                   byte_order_magic     = 0x1a2b3c4d,
                   major_version        = 1,
                   minor_version        = 0,
                   section_length       = 0xffffffffffffffff,
                   options              = [],
                  ):
    """
    generate section header block frame
    """
    un_pcapng_section_header_blockobj=un_pcapng_section_header_block_t()
    pcapng_section_header_blockobj=un_pcapng_section_header_blockobj.pcapng_section_header_block
    pcapng_section_header_blockobj.block_type                   = block_type
    block_total_length                                          = ctypes.sizeof(pcapng_section_header_block_t)+4+len(options)
    pcapng_section_header_blockobj.block_total_length           = block_total_length
    pcapng_section_header_blockobj.byte_order_magic             = byte_order_magic
    pcapng_section_header_blockobj.major_version                = major_version
    pcapng_section_header_blockobj.minor_version                = minor_version
    pcapng_section_header_blockobj.section_length               = section_length
    self.blocks.append(list(un_pcapng_section_header_blockobj.bytes)+options+self.value2byte(block_total_length,4))
        

  def idb_framegen(self,
                   block_type           = 1,
                   block_total_length   = 20,
                   linktype             = 0,
                   snaplen              = 0,
                   options              = [],
                  ):
    """
    generate insterface description block frame
    """
    un_pcapng_interface_descr_blockobj=un_pcapng_interface_descr_block_t()
    pcapng_interface_descr_blockobj=un_pcapng_interface_descr_blockobj.pcapng_interface_descr_block
    pcapng_interface_descr_blockobj.block_type          = block_type
    block_total_length                                  = ctypes.sizeof(pcapng_interface_descr_block_t)+4+len(options)
    pcapng_interface_descr_blockobj.block_total_length  = block_total_length
    pcapng_interface_descr_blockobj.linktype            = linktype
    pcapng_interface_descr_blockobj.snaplen             = snaplen
    self.blocks.append(list(un_pcapng_interface_descr_blockobj.bytes)+options+self.value2byte(block_total_length,4))

  def epb_framegen(self,
                   block_type           = 6,
                   block_total_length   = 168,
                   intf_id              = 0,
                   ts_high              = 0,
                   ts_low               = 0,
                   captured_len         = 123,
                   packet_len           = 123,
                   payload              = [0]*123,
                   options              = [0, 2, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0],
                  ):
    """
    generate enhanced packet block frame
    """
    un_pcapng_enhanced_pkt_blockobj=un_pcapng_enhanced_pkt_block_t()
    pcapng_enhanced_pkt_blockobj=un_pcapng_enhanced_pkt_blockobj.pcapng_enhanced_pkt_block
    pcapng_enhanced_pkt_blockobj.block_type             = block_type
    if isinstance(payload,str):
      payload=map(lambda x: int(payload[x:x+2],16),range(0,len(payload),2))
    block_total_length                                  = ctypes.sizeof(pcapng_enhanced_pkt_block_t)+4+len(payload)+padding_len(len(payload))+len(options)
    pcapng_enhanced_pkt_blockobj.block_total_length     = block_total_length
    pcapng_enhanced_pkt_blockobj.intf_id                = intf_id
    pcapng_enhanced_pkt_blockobj.ts_high                = ts_high
    pcapng_enhanced_pkt_blockobj.ts_low                 = ts_low
    pcapng_enhanced_pkt_blockobj.captured_len           = len(payload)
    pcapng_enhanced_pkt_blockobj.packet_len             = packet_len
    #pcapng_enhanced_pkt_blockobj.packet_len             = len(payload)
    if padding_len(len(payload)):       # 4-byte align
      payload_w_padding=payload+[0]*padding_len(len(payload))
    else:
      payload_w_padding=payload
    self.blocks.append(list(un_pcapng_enhanced_pkt_blockobj.bytes)+payload_w_padding+options+self.value2byte(block_total_length,4))

  def pb_framegen(self,
                   block_type           = 2,
                   block_total_length   = 168,
                   intf_id              = 0,
                   drop_count           = 0,
                   ts_high              = 0,
                   ts_low               = 0,
                   captured_len         = 123,
                   packet_len           = 123,
                   payload              = [0]*123,
                   options              = [0, 2, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0],
                  ):
    """
    generate enhanced packet block frame
    """
    un_pcapng_pkt_blockobj=un_pcapng_pkt_block_t()
    pcapng_pkt_blockobj=un_pcapng_pkt_blockobj.pcapng_pkt_block
    pcapng_pkt_blockobj.block_type             = block_type
    if isinstance(payload,str):
      payload=map(lambda x: int(payload[x:x+2],16),range(0,len(payload),2))
    block_total_length                         = ctypes.sizeof(pcapng_pkt_block_t)+4+len(payload)+padding_len(len(payload))+len(options)
    pcapng_pkt_blockobj.block_total_length     = block_total_length
    pcapng_pkt_blockobj.intf_id                = intf_id
    pcapng_pkt_blockobj.drop_count             = drop_count
    pcapng_pkt_blockobj.ts_high                = ts_high
    pcapng_pkt_blockobj.ts_low                 = ts_low
    pcapng_pkt_blockobj.captured_len           = len(payload)
    #pcapng_pkt_blockobj.packet_len             = packet_len
    pcapng_pkt_blockobj.packet_len             = len(payload)
    if padding_len(len(payload)):       # 4-byte align
      payload_w_padding=payload+[0]*padding_len(len(payload))
    self.blocks.append(list(un_pcapng_pkt_blockobj.bytes)+payload_w_padding+options+self.value2byte(block_total_length,4))

  def spb_framegen(self,
                   block_type           = 3,
                   block_total_length   = 139,
                   packet_len           = 139,
                   payload              = [0]*139,
                  ):
    """
    generate simple packet block frame
    """
    un_pcapng_simple_pkt_blockobj=un_pcapng_simple_pkt_block_t()
    pcapng_simple_pkt_blockobj=un_pcapng_simple_pkt_blockobj.pcapng_simple_pkt_block
    pcapng_simple_pkt_blockobj.block_type               = block_type
    if isinstance(payload,str):
      payload=map(lambda x: int(payload[x:x+2],16),range(0,len(payload),2))
    block_total_length                                  = ctypes.sizeof(pcapng_simple_pkt_block_t)+4+len(payload)+padding_len(len(payload))
    pcapng_simple_pkt_blockobj.block_total_length       = block_total_length
    #pcapng_simple_pkt_blockobj.packet_len               = packet_len
    pcapng_simple_pkt_blockobj.packet_len               = len(payload)
    if padding_len(len(payload)):       # 4-byte align
      payload_w_padding=payload+[0]*padding_len(len(payload))
    self.blocks.append(list(un_pcapng_simple_pkt_blockobj.bytes)+payload_w_padding+self.value2byte(block_total_length,4))


  def nrb_framegen(self,
                   block_type           = 4,
                   block_total_length   = 12,
                   records              = [],
                   options              = [],
                  ):
    """
    generate name resolution block frame
    """
    un_pcapng_name_resolution_blockobj=un_pcapng_name_resolution_block_t()
    pcapng_name_resolution_blockobj=un_pcapng_name_resolution_blockobj.pcapng_name_resolution_block
    pcapng_name_resolution_blockobj.block_type          = block_type
    block_total_length                                  = ctypes.sizeof(pcapng_name_resolution_block_t)+4+len(records)+len(options)
    pcapng_name_resolution_blockobj.block_total_length  = block_total_length
    self.blocks.append(list(un_pcapng_name_resolution_blockobj.bytes)+records+options+self.value2byte(block_total_length,4))
      
  def isb_framegen(self,
                   block_type           = 5,
                   block_total_length   = 24,
                   intf_id              = 0,
                   ts_high              = 0,
                   ts_low               = 0,
                   options              = [],
                  ):
    """
    generate interface statistics block frame
    """
    un_pcapng_interface_stat_blockobj=un_pcapng_interface_stat_block_t()
    pcapng_interface_stat_blockobj=un_pcapng_interface_stat_blockobj.pcapng_interface_stat_block
    pcapng_interface_stat_blockobj.block_type           = block_type
    block_total_length                                  = ctypes.sizeof(pcapng_interface_stat_block_t)+4+len(options)
    pcapng_interface_stat_blockobj.block_total_length   = block_total_length
    pcapng_interface_stat_blockobj.intf_id              = intf_id
    pcapng_interface_stat_blockobj.ts_high              = ts_high
    pcapng_interface_stat_blockobj.ts_low               = ts_low
    self.blocks.append(list(un_pcapng_interface_stat_blockobj.bytes)+options+self.value2byte(block_total_length,4))
  def write(self,fname):
    """
    read pcapng file
    """
    with open(fname,'wb') as fh:
      for block in self.blocks:
        fh.write(struct.pack("%dB"%len(block),*block))
      

    
    
if __name__ == '__main__':
  import sys
  argc=len(sys.argv)
  if argc > 1: pcapng=sys.argv[1]
  obj=pcapng_framegen()
  if False:
    obj.shb_framegen(
                     block_type           = 0x0a0d0d0a,
                     block_total_length   = 28,
                     byte_order_magic     = 0x1a2b3c4d,
                     major_version        = 1,
                     minor_version        = 0,
                     section_length       = 0xffffffffffffffff,
                     options              = [],
                    )
    options=[]
    options+=obj.idb_options_framegen(
                             option_code          = PCAPNG_IDB_OPTION_num['IF_NAME'],
                             option_length        = 26,
                             option_data          = 'Stupid ethernet interface ',
                            )
    options+=obj.idb_options_framegen(
                             option_code          = PCAPNG_IDB_OPTION_num['IF_TSRESOL'],
                             option_length        = 1,
                             option_data          = [9],
                            )
    options+=obj.idb_options_framegen(
                             option_code          = PCAPNG_OPT_CODE_num['OPT_ENDOFOPT'],
                             option_length        = 0,
                             option_data          = [],
                            )
    obj.idb_framegen(
                     block_type           = 1,
                     block_total_length   = 64,
                     linktype             = 2,
                     snaplen              = 96,
                     options              = options,
                    )
    options=[]
    options+= obj.epb_options_framegen(
                             option_code          = PCAPNG_EPB_OPTION_num['EPB_FLAGS'],
                             option_length        = 4,
                             option_data          = 0,
                            )
    options+= obj.epb_options_framegen(
                             option_code          = PCAPNG_OPT_CODE_num['OPT_ENDOFOPT'],
                             option_length        = 0,
                             option_data          = [],
                            )
    obj.epb_framegen(
                     block_type           = 6,
                     block_total_length   = 168,
                     intf_id              = 0,
                     ts_high              = 0,
                     ts_low               = 0,
                     captured_len         = 123,
                     packet_len           = 1000,
                     payload              = '685311f33b000000978f00f33b0000000000000000000000000000000000000000000000000000000100000000000000d0f1ffbf7f000000d04f11f33b000000600500f33b000000fc0600f33b000000600200f33b0000005806400000000000685311f33b000000685311f3020000000000000000000000000000',
                     options              = options,
                    )
  obj.write(pcapng)
  if True:
    obj.shb_framegen(
                     block_type           = 0x0a0d0d0a,
                     block_total_length   = 28,
                     byte_order_magic     = 0x1a2b3c4d,
                     major_version        = 1,
                     minor_version        = 0,
                     section_length       = 0xffffffffffffffff,
                     options              = [],
                    )
    options=[]
    options+=obj.idb_options_framegen(
                             option_code          = PCAPNG_IDB_OPTION_num['IF_NAME'],
                             option_length        = 26,
                             option_data          = 'Stupid ethernet interface ',
                            )
    options+=obj.idb_options_framegen(
                             option_code          = PCAPNG_IDB_OPTION_num['IF_TSRESOL'],
                             option_length        = 1,
                             option_data          = [9],
                            )
    options+=obj.idb_options_framegen(
                             option_code          = PCAPNG_OPT_CODE_num['OPT_ENDOFOPT'],
                             option_length        = 0,
                             option_data          = [],
                            )
    obj.idb_framegen(
                     block_type           = 1,
                     block_total_length   = 64,
                     linktype             = 1,
                     snaplen              = 65535,
                     options              = options,
                    )
    options=[]
    options+= obj.epb_options_framegen(
                             option_code          = PCAPNG_EPB_OPTION_num['EPB_FLAGS'],
                             option_length        = 4,
                             option_data          = 0,
                            )
    options+= obj.epb_options_framegen(
                             option_code          = PCAPNG_OPT_CODE_num['OPT_ENDOFOPT'],
                             option_length        = 0,
                             option_data          = [],
                            )
    obj.epb_framegen(
                     block_type           = 6,
                     block_total_length   = 104,
                     intf_id              = 0,
                     ts_high              = 331319,
                     ts_low               = 588240967,
                     captured_len         = 70,
                     packet_len           = 70,
                     payload              = '0090fa6ae3ee000a0a40cd000800450000385e350000400686e10a0a40cd0a0a40c9807d08013cbd82b10000000090020b50daac0000020405b40402080a19591771a20fc5a0',
                     options              = options,
                    )
  obj.write(pcapng)
