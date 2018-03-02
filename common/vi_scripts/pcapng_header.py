#!/usr/bin/env python2.7
import ctypes
# https://www.winpcap.org/ntar/draft/PCAP-DumpFileFormat.html#sectionshb
# General Block Structure (gbs)
#  0                   1                   2                   3
#  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# |                          Block Type                           |
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# |                      Block Total Length                       |
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# /                          Block Body                           /
# /          /* variable length, aligned to 32 bits */            /
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# |                      Block Total Length                       |
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
class uint64_t(ctypes.BigEndianStructure):
  _pack=1
  _fields_=[('value',ctypes.c_ulong),                          # unique value that identifies the block
           ]
assert ctypes.sizeof(uint64_t)==8,ctypes.sizeof(uint64_t)
class un_uint64_t(ctypes.Union):
  _pack=1
  _fields_=[('uint64',uint64_t),
            ('bytes',ctypes.c_ubyte * 8)]
class uint32_t(ctypes.BigEndianStructure):
  _pack=1
  _fields_=[('value',ctypes.c_uint),                           # unique value that identifies the block
           ]
assert ctypes.sizeof(uint32_t)==4,ctypes.sizeof(uint32_t)
class un_uint32_t(ctypes.Union):
  _pack=1
  _fields_=[('uint32',uint32_t),
            ('bytes',ctypes.c_ubyte * 4)]
class uint16_t(ctypes.BigEndianStructure):
  _pack=1
  _fields_=[('value',ctypes.c_ushort),                           # unique value that identifies the block
           ]
assert ctypes.sizeof(uint16_t)==2,ctypes.sizeof(uint16_t)
class un_uint16_t(ctypes.Union):
  _pack=1
  _fields_=[('uint16',uint16_t),
            ('bytes',ctypes.c_ubyte * 2)]
class pcapng_gbs_t(ctypes.BigEndianStructure):
  _pack=1
  _fields_=[('block_type',ctypes.c_uint),                      # unique value that identifies the block
            ('block_total_length',ctypes.c_uint),              # length include all the bytes in the block
#            ('block_body',ctypes.c_ubyte*64),                  # body aligned to word boundary
#            ('block_total_length',ctypes.c_uint),              # duplicate length allows backward navigation
           ]
assert ctypes.sizeof(pcapng_gbs_t)==8,ctypes.sizeof(pcapng_gbs_t)
class un_pcapng_gbs_t(ctypes.Union):
  _pack=1
  _fields_=[('pcapng_gbs',pcapng_gbs_t),
            ('bytes',ctypes.c_ubyte * 8)]
PCAPNG_BLOCK_TYPE_num_inv={
  0x00000000                      : 'Reserved ???',
  0x00000001                      : 'Interface Description Block',
  0x00000002                      : 'Packet Block',
  0x00000003                      : 'Simple Packet Block',
  0x00000004                      : 'Name Resolution BlockName Resolution Block (optional)',
  0x00000005                      : 'Interface Statistics Block',
  0x00000006                      : 'Enhanced Packet Block',
  0x00000007                      : 'IRIG Timestamp Block (requested by Gianluca Varenni <gianluca.varenni@cacetech.com>, CACE Technologies LLC)',
  0x00000008                      : 'Arinc 429 in AFDX Encapsulation Information Block (requested by Gianluca Varenni <gianluca.varenni@cacetech.com>, CACE Technologies LLC)',
  0x0A0D0D0A                      : 'Section Header Block',
# 0x0A0D0A00-0x0A0D0AFF           : 'Reserved. Used to detect trace files corrupted because of file transfers using the HTTP protocol in text mode.',
# 0x000A0D0A-0xFF0A0D0A           : 'Reserved. Used to detect trace files corrupted because of file transfers using the HTTP protocol in text mode.',
# 0x000A0D0D-0xFF0A0D0D           : 'Reserved. Used to detect trace files corrupted because of file transfers using the HTTP protocol in text mode.',
# 0x0D0D0A00-0x0D0D0AFF           : 'Reserved. Used to detect trace files corrupted because of file transfers using the FTP protocol in text mode.',
}
# section header block (mandatory)
#   0                   1                   2                   3
#   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
#   +---------------------------------------------------------------+
# 0 |                   Block Type = 0x0A0D0D0A                     |
#   +---------------------------------------------------------------+
# 4 |                      Block Total Length                       |
#   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# 8 |                      Byte-Order Magic                         |
#   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
#12 |          Major Version        |         Minor Version         |
#   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
#16 |                                                               |
#   |                          Section Length                       |
#   |                                                               |
#   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
#24 /                                                               /
#   /                      Options (variable)                       /
#   /                                                               /
#   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
#   |                      Block Total Length                       |
#   +---------------------------------------------------------------+
class pcapng_section_header_block_t(ctypes.BigEndianStructure):
  _pack=1
  _fields_=[('block_type',ctypes.c_uint),                      # 0x0A0D0D0A
            ('block_total_length',ctypes.c_uint),              # length include all the bytes in the block
            ('byte_order_magic',ctypes.c_uint),                # byte order magic number 0x1A2B3C4D
            ('major_version',ctypes.c_ushort),                 # major version 1
            ('minor_version',ctypes.c_ushort),                 # minor version 0
            ('section_length',ctypes.c_ulong),                 # length in bytes of the following section, excluding the section header block
#            ('options',ctypes.c_ubyte*64),                     # list options (variable length)
#            ('block_total_length',ctypes.c_uint),              # duplicate length allows backward navigation
           ]
assert ctypes.sizeof(pcapng_section_header_block_t)==24,ctypes.sizeof(pcapng_section_header_block_t)
class un_pcapng_section_header_block_t(ctypes.Union):
  _pack=1
  _fields_=[('pcapng_section_header_block',pcapng_section_header_block_t),
            ('bytes',ctypes.c_ubyte * 24)]


# Interface Description Block (mandatory)
#    0                   1                   2                   3
#    0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
#   +---------------------------------------------------------------+
# 0 |                    Block Type = 0x00000001                    |
#   +---------------------------------------------------------------+
# 4 |                      Block Total Length                       |
#   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# 8 |           LinkType            |           Reserved            |
#   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
#12 |                            SnapLen                            |
#   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
#16 /                                                               /
#   /                      Options (variable)                       /
#   /                                                               /
#   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
#   |                      Block Total Length                       |
#   +---------------------------------------------------------------+
class pcapng_interface_descr_block_t(ctypes.BigEndianStructure):
  _pack=1
  _fields_=[('block_type',ctypes.c_uint),                      # 0x00000001
            ('block_total_length',ctypes.c_uint),              # length include all the bytes in the block
            ('linktype',ctypes.c_ushort),                      # link layer code
            ('reserved',ctypes.c_ushort),                      # reserved
            ('snaplen',ctypes.c_uint),                         # maximum number of bytes dumped from each packet
#            ('options',ctypes.c_ubyte*64),                     # list options (variable length)
#            ('block_total_length',ctypes.c_uint),              # duplicate length allows backward navigation
           ]
assert ctypes.sizeof(pcapng_interface_descr_block_t)==16,ctypes.sizeof(pcapng_interface_descr_block_t)
class un_pcapng_interface_descr_block_t(ctypes.Union):
  _pack=1
  _fields_=[('pcapng_interface_descr_block',pcapng_interface_descr_block_t),
            ('bytes',ctypes.c_ubyte * 16)]
# Enhanced Packet Block (optional)
#    0                   1                   2                   3
#    0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
#    +---------------------------------------------------------------+
#  0 |                    Block Type = 0x00000006                    |
#    +---------------------------------------------------------------+
#  4 |                      Block Total Length                       |
#    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
#  8 |                         Interface ID                          |
#    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# 12 |                        Timestamp (High)                       |
#    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# 16 |                        Timestamp (Low)                        |
#    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# 20 |                         Captured Len                          |
#    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# 24 |                          Packet Len                           |
#    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# 28 /                                                               /
#    /                          Packet Data                          /
#    /          /* variable length, aligned to 32 bits */            /
#    /                                                               /
#    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
#    /                                                               /
#    /                      Options (variable)                       /
#    /                                                               /
#    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
#    |                      Block Total Length                       |
#    +---------------------------------------------------------------+
class pcapng_enhanced_pkt_block_t(ctypes.BigEndianStructure):
  _pack=1
  _fields_=[('block_type',ctypes.c_uint),                      # 0x00000006
            ('block_total_length',ctypes.c_uint),              # length include all the bytes in the block
            ('intf_id',ctypes.c_uint),                         # specify the interface the packet comes from
            ('ts_high',ctypes.c_uint),                         # high 32-bit of timestamp
            ('ts_low',ctypes.c_uint),                          # low 32-bit of timestamp
            ('captured_len',ctypes.c_uint),                    # number of bytes captured
            ('packet_len',ctypes.c_uint),                      # actual length of packet
#            ('packet_data',ctypes.c_ubyte*64),                 # data in bytes
#            ('options',ctypes.c_ubyte*64),                     # list options (variable length)
#            ('block_total_length',ctypes.c_uint),              # duplicate length allows backward navigation
           ]
assert ctypes.sizeof(pcapng_enhanced_pkt_block_t)==28,ctypes.sizeof(pcapng_enhanced_pkt_block_t)
class un_pcapng_enhanced_pkt_block_t(ctypes.Union):
  _pack=1
  _fields_=[('pcapng_enhanced_pkt_block',pcapng_enhanced_pkt_block_t),
            ('bytes',ctypes.c_ubyte * 28)]
# Simple Packet Block (optional)
#    0                   1                   2                   3
#    0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
#   +---------------------------------------------------------------+
# 0 |                    Block Type = 0x00000003                    |
#   +---------------------------------------------------------------+
# 4 |                      Block Total Length                       |
#   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# 8 |                          Packet Len                           |
#   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
#12 /                                                               /
#   /                          Packet Data                          /
#   /          /* variable length, aligned to 32 bits */            /
#   /                                                               /
#   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
#   |                      Block Total Length                       |
#   +---------------------------------------------------------------+
class pcapng_simple_pkt_block_t(ctypes.BigEndianStructure):
  _pack=1
  _fields_=[('block_type',ctypes.c_uint),                      # 0x00000006
            ('block_total_length',ctypes.c_uint),              # length include all the bytes in the block
            ('packet_len',ctypes.c_uint),                      # actual length of packet
#            ('packet_data',ctypes.c_ubyte*64),                 # data in bytes
#            ('block_total_length',ctypes.c_uint),              # duplicate length allows backward navigation
           ]
assert ctypes.sizeof(pcapng_simple_pkt_block_t)==12,ctypes.sizeof(pcapng_simple_pkt_block_t)
class un_pcapng_simple_pkt_block_t(ctypes.Union):
  _pack=1
  _fields_=[('pcapng_simple_pkt_block',pcapng_simple_pkt_block_t),
            ('bytes',ctypes.c_ubyte * 12)]
# Packet Block (obsolete)
#     0                   1                   2                   3
#     0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
#    +---------------------------------------------------------------+
#  0 |                    Block Type = 0x00000002                    |
#    +---------------------------------------------------------------+
#  4 |                      Block Total Length                       |
#    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
#  8 |         Interface ID          |          Drops Count          |
#    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# 12 |                        Timestamp (High)                       |
#    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# 16 |                        Timestamp (Low)                        |
#    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# 20 |                         Captured Len                          |
#    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# 24 |                          Packet Len                           |
#    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# 28 /                                                               /
#    /                          Packet Data                          /
#    /          /* variable length, aligned to 32 bits */            /
#    /                                                               /
#    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
#    /                                                               /
#    /                      Options (variable)                       /
#    /                                                               /
#    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
#    |                      Block Total Length                       |
#    +---------------------------------------------------------------+
class pcapng_pkt_block_t(ctypes.BigEndianStructure):
  _pack=1
  _fields_=[('block_type',ctypes.c_uint),                      # 0x00000002
            ('block_total_length',ctypes.c_uint),              # length include all the bytes in the block
            ('intf_id',ctypes.c_ushort),                       # specify the interface the packet comes from
            ('drop_count',ctypes.c_ushort),                    # drop count between this packet and preceding packet
            ('ts_high',ctypes.c_uint),                         # high 32-bit of timestamp
            ('ts_low',ctypes.c_uint),                          # low 32-bit of timestamp
            ('captured_len',ctypes.c_uint),                    # number of bytes captured
            ('packet_len',ctypes.c_uint),                      # actual length of packet
#            ('packet_data',ctypes.c_ubyte*64),                 # data in bytes
#            ('options',ctypes.c_ubyte*64),                     # list options (variable length)
#            ('block_total_length',ctypes.c_uint),              # duplicate length allows backward navigation
           ]
assert ctypes.sizeof(pcapng_pkt_block_t)==28,ctypes.sizeof(pcapng_pkt_block_t)
class un_pcapng_pkt_block_t(ctypes.Union):
  _pack=1
  _fields_=[('pcapng_pkt_block',pcapng_pkt_block_t),
            ('bytes',ctypes.c_ubyte * 28)]
# Name resolution block (optional)
#     0                   1                   2                   3
#     0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
#    +---------------------------------------------------------------+
#  0 |                    Block Type = 0x00000004                    |
#    +---------------------------------------------------------------+
#  4 |                      Block Total Length                       |
#    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
#  8 |      Record Type              |         Record Length         |
#    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# 12 /                       Record Value                            /
#    /          /* variable length, aligned to 32 bits */            /
#    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
#    .                                                               .
#    .                  . . . other records . . .                    .
#    .                                                               .
#    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
#    |  Record Type == end_of_recs   |  Record Length == 00          |
#    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
#    /                                                               /
#    /                      Options (variable)                       /
#    /                                                               /
#    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
#    |                      Block Total Length                       |
#    +---------------------------------------------------------------+
class pcapng_nrb_record_t(ctypes.BigEndianStructure):
  _pack=1
  _fields_=[
            ('record_type',ctypes.c_ushort),                   # record type
            ('record_len',ctypes.c_ushort),                    # record length
           ]
assert ctypes.sizeof(pcapng_nrb_record_t)==4,ctypes.sizeof(pcapng_nrb_record_t)
class un_pcapng_nrb_record_t(ctypes.Union):
  _pack=1
  _fields_=[('pcapng_nrb_record',pcapng_nrb_record_t),
            ('bytes',ctypes.c_ubyte * 4)]
class pcapng_name_resolution_block_t(ctypes.BigEndianStructure):
  _pack=1
  _fields_=[('block_type',ctypes.c_uint),                      # 0x00000004
            ('block_total_length',ctypes.c_uint),              # length include all the bytes in the block
#            ('record_type',ctypes.c_ushort),                   # record type
#            ('record_len',ctypes.c_ushort),                    # record length
#            ('record_value',ctypes.c_ubyte*64),                # record value (variable length)
#            ('record_type',ctypes.c_ushort),                   # record type
#            ('record_len',ctypes.c_ushort),                    # record length
#            ('record_value',ctypes.c_ubyte*64),                # record value (variable length)
#            ('record_type',ctypes.c_ushort),                   # record type == end_of_recs
#            ('record_len',ctypes.c_ushort),                    # record length == 00
#            ('options',ctypes.c_ubyte*64),                     # list options (variable length)
#            ('block_total_length',ctypes.c_uint),              # duplicate length allows backward navigation
           ]
assert ctypes.sizeof(pcapng_name_resolution_block_t)==8,ctypes.sizeof(pcapng_name_resolution_block_t)
class un_pcapng_name_resolution_block_t(ctypes.Union):
  _pack=1
  _fields_=[('pcapng_name_resolution_block',pcapng_name_resolution_block_t),
            ('bytes',ctypes.c_ubyte * 8)]
# record type
PCAPNG_RECORD_TYPE_num=dict(
  NRES_ENDOFRECORD     =  0,   # end of name resolution records
  NRES_IP4RECORD       =  1,   # IPv4 address in the 1st 4 bytes, followed by DNS entries for that address
  NRES_IP6RECORD       =  2,   # IPv6 address in the 1st 16 bytes, followed by DNS entries for that address
)
# Interface statistics block (optional)
#     0                   1                   2                   3
#     0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
#    +---------------------------------------------------------------+
#  0 |                   Block Type = 0x00000005                     |
#    +---------------------------------------------------------------+
#  4 |                      Block Total Length                       |
#    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
#  8 |                         Interface ID                          |
#    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# 12 |                        Timestamp (High)                       |
#    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# 16 |                        Timestamp (Low)                        |
#    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# 20 /                                                               /
#    /                      Options (variable)                       /
#    /                                                               /
#    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
#    |                      Block Total Length                       |
#    +---------------------------------------------------------------+

class pcapng_interface_stat_block_t(ctypes.BigEndianStructure):
  _pack=1
  _fields_=[('block_type',ctypes.c_uint),                      # 0x00000005
            ('block_total_length',ctypes.c_uint),              # length include all the bytes in the block
            ('intf_id',ctypes.c_uint),                         # specify the interface the packet comes from
            ('ts_high',ctypes.c_uint),                         # high 32-bit of timestamp
            ('ts_low',ctypes.c_uint),                          # low 32-bit of timestamp
#            ('options',ctypes.c_ubyte*64),                     # list options (variable length)
#            ('block_total_length',ctypes.c_uint),              # duplicate length allows backward navigation
           ]
assert ctypes.sizeof(pcapng_interface_stat_block_t)==20,ctypes.sizeof(pcapng_interface_stat_block_t)
class un_pcapng_interface_stat_block_t(ctypes.Union):
  _pack=1
  _fields_=[('pcapng_interface_stat_block',pcapng_interface_stat_block_t),
            ('bytes',ctypes.c_ubyte * 20)]
# Compression block (experimental)
#  0                   1                   2                   3
#  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
# +---------------------------------------------------------------+
# |                        Block Type = ?                         |
# +---------------------------------------------------------------+
# |                      Block Total Length                       |
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# |  Compr. Type  |                                               |
# +-+-+-+-+-+-+-+-+                                               |
# |                                                               |
# |                       Compressed Data                         |
# |                                                               |
# |              /* variable length, byte-aligned */              |
# |                                                               |
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# |                      Block Total Length                       |
# +---------------------------------------------------------------+
class pcapng_compress_block_t(ctypes.BigEndianStructure):
  _pack=1
  _fields_=[('block_type',ctypes.c_uint),                      # unique value that identifies the block
            ('block_total_length',ctypes.c_uint),              # length include all the bytes in the block
            ('compr_type',ctypes.c_ubyte),                      # specify compression algorithm
#            ('compr_data',ctypes.c_ubyte*63),                  # compression data aligned to word boundary
#            ('block_total_length',ctypes.c_uint),              # duplicate length allows backward navigation
           ]
assert ctypes.sizeof(pcapng_compress_block_t)==12,ctypes.sizeof(pcapng_compress_block_t)
class un_pcapng_compress_block_t(ctypes.Union):
  _pack=1
  _fields_=[('pcapng_compress_block',pcapng_compress_block_t),
            ('bytes',ctypes.c_ubyte * 12)]
# Encryption block (experimental)
#  0                   1                   2                   3
#  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
# +---------------------------------------------------------------+
# |                        Block Type = ?                         |
# +---------------------------------------------------------------+
# |                      Block Total Length                       |
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# |  Encr. Type   |                                               |
# +-+-+-+-+-+-+-+-+                                               |
# |                                                               |
# |                       Encrypted Data                          |
# |                                                               |
# |              /* variable length, byte-aligned */              |
# |                                                               |
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# |                      Block Total Length                       |
# +---------------------------------------------------------------+
class pcapng_encrypt_block_t(ctypes.BigEndianStructure):
  _pack=1
  _fields_=[('block_type',ctypes.c_uint),                      # unique value that identifies the block
            ('block_total_length',ctypes.c_uint),              # length include all the bytes in the block
            ('encr_type',ctypes.c_ubyte),                      # specify encryption algorithm
#            ('encr_data',ctypes.c_ubyte*63),                  # encryption data aligned to word boundary
#            ('block_total_length',ctypes.c_uint),              # duplicate length allows backward navigation
           ]
assert ctypes.sizeof(pcapng_encrypt_block_t)==12,ctypes.sizeof(pcapng_encrypt_block_t)
class un_pcapng_encrypt_block_t(ctypes.Union):
  _pack=1
  _fields_=[('pcapng_encrypt_block',pcapng_encrypt_block_t),
            ('bytes',ctypes.c_ubyte * 12)]
# Fixed length block (experimental)
#  0                   1                   2                   3
#  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
# +---------------------------------------------------------------+
# |                        Block Type = ?                         |
# +---------------------------------------------------------------+
# |                      Block Total Length                       |
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# |          Cell Size            |                               |
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+                               |
# |                                                               |
# |                        Fixed Size Data                        |
# |                                                               |
# |              /* variable length, byte-aligned */              |
# |                                                               |
# |                                                               |
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# |                      Block Total Length                       |
# +---------------------------------------------------------------+
class pcapng_fixed_length_block_t(ctypes.BigEndianStructure):
  _pack=1
  _fields_=[('block_type',ctypes.c_uint),                      # unique value that identifies the block
            ('block_total_length',ctypes.c_uint),              # length include all the bytes in the block
            ('cell_size',ctypes.c_ushort),                     # sixe of the blocks contained in the data field
#            ('data',ctypes.c_ubyte*63),                        # data of this block
#            ('block_total_length',ctypes.c_uint),              # duplicate length allows backward navigation
           ]
assert ctypes.sizeof(pcapng_fixed_length_block_t)==12,ctypes.sizeof(pcapng_fixed_length_block_t)
class un_pcapng_fixed_length_block_t(ctypes.Union):
  _pack=1
  _fields_=[('pcapng_fixed_length_block',pcapng_fixed_length_block_t),
            ('bytes',ctypes.c_ubyte * 12)]
# Options
#  0                   1                   2                   3
#  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# |      Option Code              |         Option Length         |
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# /                       Option Value                            /
# /          /* variable length, aligned to 32 bits */            /
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# /                                                               /
# /                 . . . other options . . .                     /
# /                                                               /
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# |   Option Code == opt_endofopt  |  Option Length == 0          |
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
class pcapng_options_t(ctypes.BigEndianStructure):
  _pack=1
  _fields_=[('option_code',ctypes.c_ushort),                   # option type
            ('option_length',ctypes.c_ushort),                 # actual size of option_value without padding bytes
#            ('option_value',ctypes.c_ubyte*64),                # option value aligned with a 32-bit boundary
           ]
assert ctypes.sizeof(pcapng_options_t)==4,ctypes.sizeof(pcapng_options_t)
class un_pcapng_options_t(ctypes.Union):
  _pack=1
  _fields_=[('pcapng_options',pcapng_options_t),
            ('bytes',ctypes.c_ubyte * 4)]
padding_len    = lambda data_len: (0-data_len)&0x03   # The padding zero to align 4-byte boundary, in bytes
# option code
PCAPNG_OPT_CODE_num=dict(
  OPT_ENDOFOPT  = 0,    # It delimits the end of the optional fields.
  OPT_COMMENT   = 1,    # A UTF-8 string containing a comment that is associated to the current block.
                        # "This packet is the beginning of all of our problems" 
                        # "Packets 17-23 showing a bogus TCP retransmission, as reported in bugzilla entry 1486!"
)
# section header block options
PCAPNG_SHB_OPTION_num=dict(
  SHB_HARDWARE  = 2,      # An UTF-8 string containing the description of the hardware used to create this section.
  SHB_OS        = 3,      # An UTF-8 string containing the name of the operating system used to create this section.
  SHB_USERAPPL  = 4,      # An UTF-8 string containing the name of the application used to create this section.
)
# interface description block options
PCAPNG_IDB_OPTION_num=dict(
  IF_NAME               = 2,            # A UTF-8 string containing the name of the device used to capture data.
  IF_DESCRIPTION        = 3,            # A UTF-8 string containing the description of the device used to capture data.
  IF_IPv4addr           = 4,            # Interface network address and netmask.
  IF_IPv6addr           = 5,            # Interface network address and prefix length (stored in the last byte).
  IF_MACaddr            = 6,            # Interface Hardware MAC address (48 bits).
  IF_EUIaddr            = 7,            # Interface Hardware EUI address (64 bits).
  IF_SPEED              = 8,            # Interface speed (in bps).
  IF_TSRESOL            = 9,            # Resolution of timestamps.
  IF_TZONE              = 10,           # Time zone for GMT support
  IF_FILTER             = 11,           # The filter (e.g. "capture only TCP traffic") used to capture traffic.
  IF_OS                 = 12,           # A UTF-8 string containing the name of the operating system of the machine
  IF_FCSLEN             = 13,           # An integer value that specified the length of the Frame Check Sequence
  IF_TSOFFSET           = 14,           # A 64 bits integer value that specifies an offset
)
# enhanced packet block options
PCAPNG_EPB_OPTION_num=dict(
  EPB_FLAGS      = 2,   # A flags word containing link-layer information. A complete specification of the allowed flags can be found in Appendix A.     0
  EPB_HASH       = 3,   # This option contains a hash of the packet. The first byte specifies the hashing algorithm, while the following bytes contain the actual hash
  EPB_DROPCOUNT  = 4,   # A 64bit integer value specifying the number of packets lost (by the interface and the operating system) between this packet and the preceding one.
)
# name resolution block options
PCAPNG_NRB_OPTION_num=dict(
  NS_DNSNAME     = 2,   # UTF-8 string containing the name of the machine (DNS server) used to perform the name resolution.
  NS_DNSIP4addr  = 3,   # The IPv4 address of the DNS server.
  NS_DNSIP6addr  = 4,   # The IPv6 address of the DNS server.

)
# interface statistics block options
PCAPNG_ISB_num=dict(
  ISB_STARTTIME   = 2,    # 8 Time in which the capture started
  ISB_ENDTIME     = 3,    # 8 Time in which the capture ended
  ISB_IFRECV      = 4,    # 8 Number of packets received
  ISB_IFDROP      = 5,    # 8 Number of packets dropped by the interface due to lack of resources
  ISB_FILTERACCEPT= 6,    # 8 Number of packets accepted by filter
  ISB_OSDROP      = 7,    # 8 Number of packets dropped by the operating system
  ISB_USRDELIV    = 8,    # 8 Number of packets delivered to the user
)
# link type code
PCAPNG_LINK_TYPE_num=dict(
  LINKTYPE_NULL                      = 0,    # No link layer information. A packet saved with this link layer contains a raw L3 packet preceded by a 32-bit host-byte-order AF_ value indicating the specific L3 type.
  LINKTYPE_ETHERNET                  = 1,    # D/I/X and 802.3 Ethernet
  LINKTYPE_EXP_ETHERNET              = 2,    # Experimental Ethernet (3Mb)
  LINKTYPE_AX25                      = 3,    # Amateur Radio AX.25
  LINKTYPE_PRONET                    = 4,    # Proteon ProNET Token Ring
  LINKTYPE_CHAOS                     = 5,    # Chaos
  LINKTYPE_TOKEN_RING                = 6,    # IEEE 802 Networks
  LINKTYPE_ARCNET                    = 7,    # ARCNET, with BSD-style header
  LINKTYPE_SLIP                      = 8,    # Serial Line IP
  LINKTYPE_PPP                       = 9,    # Point-to-point Protocol
  LINKTYPE_FDDI                      = 10,   # FDDI
  LINKTYPE_PPP_HDLC                  = 50,   # PPP in HDLC-like framing
  LINKTYPE_PPP_ETHER                 = 51,   # NetBSD PPP-over-Ethernet
  LINKTYPE_SYMANTEC_FIREWALL         = 99,   # Symantec Enterprise Firewall
  LINKTYPE_ATM_RFC1483               = 100,  # LLC/SNAP-encapsulated ATM
  LINKTYPE_RAW                       = 101,  # Raw IP
  LINKTYPE_SLIP_BSDOS                = 102,  # BSD/OS SLIP BPF header
  LINKTYPE_PPP_BSDOS                 = 103,  # BSD/OS PPP BPF header
  LINKTYPE_C_HDLC                    = 104,  # Cisco HDLC
  LINKTYPE_IEEE802_11                = 105,  # IEEE 802.11 (wireless)
  LINKTYPE_ATM_CLIP                  = 106,  # Linux Classical IP over ATM
  LINKTYPE_FRELAY                    = 107,  # Frame Relay
  LINKTYPE_LOOP                      = 108,  # OpenBSD loopback
  LINKTYPE_ENC                       = 109,  # OpenBSD IPSEC enc
  LINKTYPE_LANE8023                  = 110,  # ATM LANE + 802.3 (Reserved for future use)
  LINKTYPE_HIPPI                     = 111,  # NetBSD HIPPI (Reserved for future use)
  LINKTYPE_HDLC                      = 112,  # NetBSD HDLC framing (Reserved for future use)
  LINKTYPE_LINUX_SLL                 = 113,  # Linux cooked socket capture
  LINKTYPE_LTALK                     = 114,  # Apple LocalTalk hardware
  LINKTYPE_ECONET                    = 115,  # Acorn Econet
  LINKTYPE_IPFILTER                  = 116,  # Reserved for use with OpenBSD ipfilter
  LINKTYPE_PFLOG                     = 117,  # OpenBSD DLT_PFLOG
  LINKTYPE_CISCO_IOS                 = 118,  # For Cisco-internal use
  LINKTYPE_PRISM_HEADER              = 119,  # 802.11+Prism II monitor mode
  LINKTYPE_AIRONET_HEADER            = 120,  # FreeBSD Aironet driver stuff
  LINKTYPE_HHDLC                     = 121,  # Reserved for Siemens HiPath HDLC
  LINKTYPE_IP_OVER_FC                = 122,  # RFC 2625 IP-over-Fibre Channel
  LINKTYPE_SUNATM                    = 123,  # Solaris+SunATM
  LINKTYPE_RIO                       = 124,  # RapidIO
  LINKTYPE_PCI_EXP                   = 125,  # PCI Express
  LINKTYPE_AURORA                    = 126,  # Xilinx Aurora link layer
  LINKTYPE_IEEE802_11_RADIO          = 127,  # 802.11 plus BSD radio header
  LINKTYPE_TZSP                      = 128,  # Tazmen Sniffer Protocol
  LINKTYPE_ARCNET_LINUX              = 129,  # Linux-style headers
  LINKTYPE_JUNIPER_MLPPP             = 130,  # Juniper-private data link type
  LINKTYPE_JUNIPER_MLFR              = 131,  # Juniper-private data link type
  LINKTYPE_JUNIPER_ES                = 132,  # Juniper-private data link type
  LINKTYPE_JUNIPER_GGSN              = 133,  # Juniper-private data link type
  LINKTYPE_JUNIPER_MFR               = 134,  # Juniper-private data link type
  LINKTYPE_JUNIPER_ATM2              = 135,  # Juniper-private data link type
  LINKTYPE_JUNIPER_SERVICES          = 136,  # Juniper-private data link type
  LINKTYPE_JUNIPER_ATM1              = 137,  # Juniper-private data link type
  LINKTYPE_APPLE_IP_OVER_IEEE1394    = 138,  # Apple IP-over-IEEE 1394 cooked header
  LINKTYPE_MTP2_WITH_PHDR            = 139,  # ???
  LINKTYPE_MTP2                      = 140,  # ???
  LINKTYPE_MTP3                      = 141,  # ???
  LINKTYPE_SCCP                      = 142,  # ???
  LINKTYPE_DOCSIS                    = 143,  # DOCSIS MAC frames
  LINKTYPE_LINUX_IRDA                = 144,  # Linux-IrDA
  LINKTYPE_IBM_SP                    = 145,  # Reserved for IBM SP switch and IBM Next Federation switch.
  LINKTYPE_IBM_SN                    = 146,  # Reserved for IBM SP switch and IBM Next Federation switch.
)
