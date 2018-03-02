#!/usr/bin/env python2.7
import ctypes
import struct
IPPROTO_TCP = 6                                                # protocol number for TCP/IP
IPPROTO_UDP = 17                                               # rotocol number for UDP/IP

PCAPNG_SECTION_HEADER_MAGIC = 0x0a0d0d0a
BYTE_ORDER_MAGIC            = 0x1a2b3c4d
BYTE_ORDER_MAGIC_INVERSE    = 0x4d3c2b1a
class pcap_hdr_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('magic_number',ctypes.c_uint),                    # magic number
            ('version_major',ctypes.c_ushort),                 # major version number
            ('version_minor',ctypes.c_ushort),                 # minor version number
            ('thiszone',ctypes.c_int),                         # GMT to local correction
            ('sigfigs',ctypes.c_uint),                         # accuracy of timestamps
            ('snaplen',ctypes.c_uint),                         # max length of captured packets, in octets
            ('network',ctypes.c_uint),                         # data link type
           ]
assert ctypes.sizeof(pcap_hdr_t)==24,ctypes.sizeof(pcap_hdr_t)
class un_pcap_hdr_t(ctypes.Union):
  _pack_=1
  _fields_=[('pcap_hdr',pcap_hdr_t),
            ('bytes',ctypes.c_ubyte * 24)]

class pcaprec_hdr_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('ts_sec',ctypes.c_uint),                          # timestamp seconds
            ('ts_usec',ctypes.c_uint),                         # timestamp microseconds
            ('incl_len',ctypes.c_uint),                        # number of octets of packet saved in file
            ('orig_len',ctypes.c_uint),                        # actual length of packet
           ]
assert ctypes.sizeof(pcaprec_hdr_t)==16,ctypes.sizeof(pcaprec_hdr_t)
class un_pcaprec_hdr_t(ctypes.Union):
  _pack_=1
  _fields_=[('pcaprec_hdr',pcaprec_hdr_t),
            ('bytes',ctypes.c_ubyte * 16)]

ETHERMTU                  = 1500                             #  
ETHER_ADDR_LEN            = 6                                # MAC address length
ETHER_HDRLEN              = 14                               # total hdr_t length
class ether_hdr_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('ether_dhost',ctypes.c_ubyte*ETHER_ADDR_LEN),     # destination address
            ('ether_shost',ctypes.c_ubyte*ETHER_ADDR_LEN),     # source address
            ('ether_type',ctypes.c_ushort),                    # ether type
           ]
assert ctypes.sizeof(ether_hdr_t)==14,ctypes.sizeof(ether_hdr_t)
class un_ether_hdr_t(ctypes.Union):
  _pack_=1
  _fields_=[('ehdr',ether_hdr_t),
            ('bytes',ctypes.c_ubyte * 14)]

class vlan_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('cos',ctypes.c_ushort, 3),                        # [15:13]: User Priority
            ('cfi',ctypes.c_ushort, 1),                        # [12]: Canonical Format Indicator (CFI) or Drop Eligible Indicator (DEI)
            ('vlanid',ctypes.c_ushort, 12),                    # [11:0]: VLAN tag's VLAN Identifier (VID) field
            ('ether_type',ctypes.c_ushort),                    # ether type
           ]
assert ctypes.sizeof(vlan_t)==4,ctypes.sizeof(vlan_t)
class un_vlan_t(ctypes.Union):
  _pack_=1
  _fields_=[('vlan',vlan_t),
            ('bytes',ctypes.c_ubyte * 4)]

IP_MAXPACKET              = 65535                            # maximum packet size
class ip_hdr_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('version',ctypes.c_ubyte,4),                      # version
            ('ihl',ctypes.c_ubyte,4),                          # hdr_t length
            ('dscp',ctypes.c_ubyte,6),                         # differential services code point
            ('ecn',ctypes.c_ubyte,2),                          # explicit congestion notification
            ('length',ctypes.c_ushort),                        # total length
            ('id',ctypes.c_ushort),                            # identification
            ('zero',ctypes.c_ushort,1),                        # must be zero
            ('df',ctypes.c_ushort,1),                          # don't fragment
            ('mf',ctypes.c_ushort,1),                          # more fragment
            ('offset',ctypes.c_ushort,13),                     # fragment offset field
            ('ttl',ctypes.c_ubyte),                            # time to live
            ('proto',ctypes.c_ubyte),                          # protocol
            ('checksum',ctypes.c_ushort),                      # checksum
            ('saddr',ctypes.c_uint),                           # source address
            ('daddr',ctypes.c_uint),                           # dest address
           ]
assert ctypes.sizeof(ip_hdr_t)==20,ctypes.sizeof(ip_hdr_t)
class un_ip_hdr_t(ctypes.Union):
  _pack_=1
  _fields_=[('iphdr',ip_hdr_t),
            ('bytes',ctypes.c_ubyte * 20)]


class in6_addr_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('s6_addr',ctypes.c_ubyte*16),                     # IPv6 address
           ]
assert ctypes.sizeof(in6_addr_t)==16,ctypes.sizeof(in6_addr_t)

# IPv6 datagram header 
class ipv6_hdr_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[
            ('version',ctypes.c_ubyte,4),                      # first 4  bits = version #
            ('tc_msn',ctypes.c_ubyte,4),                       # next 4  bits = most significant nibble of Trafic class
            ('tc_lsn',ctypes.c_ubyte,4),                       # next 4  bits = least significant nibble of Trafic class
            ('tc_flabel_high',ctypes.c_ubyte,4),               # next high 4 bits = flow label
            ('tc_flabel_low',ctypes.c_ushort),                 # next low 16 bits = flow label
            ('length',ctypes.c_ushort),                        # Payload length
            ('nheader',ctypes.c_ubyte),                        # Next Header
            ('hlimit',ctypes.c_ubyte),                         # Hop Limit
            ('saddr',in6_addr_t),                              # Source Address
            ('daddr',in6_addr_t),                              # Destination Address
           ]
assert ctypes.sizeof(ipv6_hdr_t)==40,ctypes.sizeof(ipv6_hdr_t)
class un_ipv6_hdr_t(ctypes.Union):
  _pack_=1
  _fields_=[('ipv6',ipv6_hdr_t),
            ('bytes',ctypes.c_ubyte * 40)]


# IPv6 extension header format
class ipv6_ext_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('nheader',ctypes.c_ubyte),                 # Next Header
            ('len',ctypes.c_ubyte),                     # number of bytes in this header
            ('data',ctypes.c_ubyte*1),                  # optional data
           ]
assert ctypes.sizeof(ipv6_ext_t)==3,ctypes.sizeof(ipv6_ext_t)
class un_ipv6_ext_t(ctypes.Union):
  _pack_=1
  _fields_=[('ipv6_ext',ipv6_ext_t),
            ('bytes',ctypes.c_ubyte * 3)]


# IPv6 fragmentation header
class ipv6_ext_frag_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('nheader',ctypes.c_ubyte),              # Next Header
            ('reserved_a',ctypes.c_ubyte),           # reserved
            ('reserved_b',ctypes.c_ushort,2),        # reserved
            ('m',ctypes.c_ushort,1),                 # 1 means more fragments follow
            ('id',ctypes.c_uint),                    # ID field
           ]
assert ctypes.sizeof(ipv6_ext_frag_t)==8,ctypes.sizeof(ipv6_ext_frag_t)
class un_ipv6_ext_frag_t(ctypes.Union):
  _pack_=1
  _fields_=[('ipv6_ext_frag',ipv6_ext_frag_t),
            ('bytes',ctypes.c_ubyte * 8)]

# Routing
class ipv6_ext_routing_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('nheader',ctypes.c_ubyte),              # Next Header
            ('hdr_len',ctypes.c_ubyte),              # header length in multiple of 8 octects, not including the first 8 octects
            ('route_type',ctypes.c_ubyte),           # routing type 0,1,2
            ('seg_left',ctypes.c_ubyte),             # number of nodes this packet still has to visit before reaching it final destination
            ('type_specific_data',ctypes.c_uint),    # data that belong to this type of routing header
           ]
assert ctypes.sizeof(ipv6_ext_routing_t)==8,ctypes.sizeof(ipv6_ext_routing_t)
class un_ipv6_ext_routing_t(ctypes.Union):
  _pack_=1
  _fields_=[('ipv6_ext_routing',ipv6_ext_routing_t),
            ('bytes',ctypes.c_ubyte * 8)]
class tcp_hdr_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('source',ctypes.c_ushort),                        # sending port
            ('dest',ctypes.c_ushort),                          # receiving port
            ('seq',ctypes.c_uint),                             # initial sequence number if syn else the accumulated sequence number
            ('ack_seq',ctypes.c_uint),                         # the next sequence number if ack
            ('doff',ctypes.c_ushort,4),                        # size of the tcp hdr_t
            ('res1',ctypes.c_ushort,4),                        #
            ('res2',ctypes.c_ushort,2),                        #
            ('urg',ctypes.c_ushort,1),                         # urgent point field is significant
            ('ack',ctypes.c_ushort,1),                         # ack_seq field is significant
            ('psh',ctypes.c_ushort,1),                         # push the buffered data to receiving app
            ('rst',ctypes.c_ushort,1),                         # reset connection
            ('syn',ctypes.c_ushort,1),                         # the first packet has this flag set
            ('fin',ctypes.c_ushort,1),                         # no more data from sender
            ('window',ctypes.c_ushort),                        # the size of receive window
            ('check',ctypes.c_ushort),                         # checksum
            ('urg_ptr',ctypes.c_ushort),                       # the field is an offset from sequence number indicating the last urgent data byte
           ]
assert ctypes.sizeof(tcp_hdr_t)==20,ctypes.sizeof(tcp_hdr_t)
class un_tcp_hdr_t(ctypes.Union):
  _pack_=1
  _fields_=[('tcphdr',tcp_hdr_t),
            ('bytes',ctypes.c_ubyte * 20)]

class udp_hdr_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('source',ctypes.c_ushort),                        # source port
            ('dest',ctypes.c_ushort),                          # destination port
            ('length',ctypes.c_ushort),                        # udp length
            ('check',ctypes.c_ushort),                         # udp checksum
           ]
assert ctypes.sizeof(udp_hdr_t)==8,ctypes.sizeof(udp_hdr_t)
class un_udp_hdr_t(ctypes.Union):
  _pack_=1
  _fields_=[('udphdr',udp_hdr_t),
            ('bytes',ctypes.c_ubyte * 8)]

class tcp_pseudo_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('src_addr',ctypes.c_uint),                        # 
            ('dst_addr',ctypes.c_uint),                        # 
            ('zero',ctypes.c_ubyte),                           # 
            ('proto',ctypes.c_ubyte),                          # 
            ('length',ctypes.c_ushort),                        # 
           ]
assert ctypes.sizeof(tcp_pseudo_t)==12,ctypes.sizeof(tcp_pseudo_t)
class un_tcp_pseudo_t(ctypes.Union):
  _pack_=1
  _fields_=[('tcp_pseudo',tcp_pseudo_t),
            ('bytes',ctypes.c_ubyte * 12)]


class tcp_pseudo_ipv6_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('src_addr',ctypes.c_ubyte*16),                    # source address: 128 bits/16 bytes, taken from IPv6 header
            ('dst_addr',ctypes.c_ubyte*16),                    # destination address: 128/16 bytes, taken from IPv6 header
            ('length',ctypes.c_uint),                          # The length of the TCP segment, including TCP header and TCP data.
            ('zero',ctypes.c_ubyte*3),                         # resevered: 3 bytes, all zeros
            ('proto',ctypes.c_ubyte),                          # protocol: 8 bits/1 byte, taken from IP header.  In case of TCP, this should always be 6, which is the assigned protocol number for TCP.
           ]
assert ctypes.sizeof(tcp_pseudo_ipv6_t)==40,ctypes.sizeof(tcp_pseudo_ipv6_t)
class un_tcp_pseudo_ipv6_t(ctypes.Union):
  _pack_=1
  _fields_=[('tcp_pseudo_ipv6',tcp_pseudo_ipv6_t),
            ('bytes',ctypes.c_ubyte * 40)]
RPC_VERSION               = 2                                # 
RPC2_AUTH_DATA_SIZE       = 400                              # 
msg_type_num=dict(
  RPC2_MSG_TYPE_BOTTOM                     = -1,                  # 
  RPC2_MSG_TYPE_CALL                       = 0,                   # 
  RPC2_MSG_TYPE_REPLY                      = 1,                   # 
  RPC2_MSG_TYPE_TOP                        = 2,                   # 
)
reply_status_num=dict(
  RPC2_REPLY_STATUS_BOTTOM                 = -1,                  # 
  RPC2_REPLY_STATUS_MSG_ACCEPTED           = 0,                   # 
  RPC2_REPLY_STATUS_MSG_DENIED             = 1,                   # 
  RPC2_REPLY_STATUS_TOP                    = 2,                   # 
)
accepted_status_num=dict(
  RPC2_ACCEPT_STATUS_BOTTOM                = -1,                  # 
  RPC2_ACCEPT_STATUS_SUCCESS               = 0,                   # 
  RPC2_ACCEPT_STATUS_PROG_UNAVAIL          = 1,                   # 
  RPC2_ACCEPT_STATUS_PROG_MISMATCH         = 2,                   # 
  RPC2_ACCEPT_STATUS_PROC_UNAVAIL          = 3,                   # 
  RPC2_ACCEPT_STATUS_GARBAGE_ARGS          = 4,                   # 
  RPC2_ACCEPT_STATUS_SYSTEM_ERR            = 5,                   # 
  RPC2_ACCEPT_STATUS_TOP                   = 6,                   # 
)
rejected_status_num=dict(
  RPC2_DENY_STATUS_BOTTOM                  = -1,                  # 
  RPC2_DENY_STATUS_RPC_MISMATCH            = 0,                   # 
  RPC2_DENY_STATUS_AUTH_ERROR              = 1,                   # 
  RPC2_DENY_STATUS_TOP                     = 2,                   # 
)
auth_status_num=dict(
  RPC2_AUTH_STATUS_BOTTOM                  = -1,                  # 
  RPC2_AUTH_STATUS_OK                      = 0,                   # 
  RPC2_AUTH_STATUS_BADCRED                 = 1,                   # 
  RPC2_AUTH_STATUS_REJECTEDCRED            = 2,                   # 
  RPC2_AUTH_STATUS_BADVERF                 = 3,                   # 
  RPC2_AUTH_STATUS_REJECTEDVERF            = 4,                   # 
  RPC2_AUTH_STATUS_TOOWEAK                 = 5,                   # 
  RPC2_AUTH_STATUS_INVALIDRESP             = 6,                   # 
  RPC2_AUTH_STATUS_FAILED                  = 7,                   # 
  RPC2_AUTH_STATUS_KERB_GENERIC            = 8,                   # 
  RPC2_AUTH_STATUS_TIMEEXPIRE              = 9,                   # 
  RPC2_AUTH_STATUS_TKT_FILE                = 10,                  # 
  RPC2_AUTH_STATUS_DECODE                  = 11,                  # 
  RPC2_AUTH_STATUS_NET_ADDR                = 12,                  # 
  RPC2_AUTH_STATUS_RPCSEC_GSS_CREDPROBLEM  = 13,                  # 
  RPC2_AUTH_STATUS_RPCSEC_GSS_CTXPROBLEM   = 14,                  # 
  RPC2_AUTH_STATUS_TOP                     = 15,                  # 
)
auth_flavor_num=dict(
  RPC2_AUTHFLAVOR_BOTTOM                   = -1,                  # 
  RPC2_AUTHFLAVOR_NONE                     = 0,                   # 
  RPC2_AUTHFLAVOR_SYS                      = 1,                   # 
  RPC2_AUTHFLAVOR_SHORT                    = 2,                   # 
  RPC2_AUTHFLAVOR_DH                       = 3,                   # 
  RPC2_AUTHFLAVOR_RPCSEC_GSS               = 6,                   # 
# doesn't make sense to have a TOP, but leave it for uniformity
  RPC2_AUTHFLAVOR_TOP                      = 7,                   # 
)
program_list_num=dict(
  RPC2_PROG_PMAP2                          = 100000,              # 
  RPC2_PROG_NFS3                           = 100003,              # 
  RPC2_PROG_MNT3                           = 100005,              # 
  RPC2_PROG_NLM                            = 100021,              # 
  RPC2_PROG_NSM                            = 100024,              # 
  RPC2_PROG_NFSACL                         = 100227,              # 
)
class msg_size_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[
            ('last_frag',ctypes.c_uint,1),                     # 'record marker' represents a fragment
            ('size',ctypes.c_uint,31),                         #
           ]
assert ctypes.sizeof(msg_size_t)==4,ctypes.sizeof(msg_size_t)
class un_msg_size_t(ctypes.Union):
  _pack_=1
  _fields_=[('msg_size',msg_size_t),
            ('bytes',ctypes.c_ubyte * 4)]
class udp_msg_mtype_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[
            ('xid',ctypes.c_uint),                             # 
            ('mtype',ctypes.c_int),                            # 
           ]
assert ctypes.sizeof(udp_msg_mtype_t)==8,ctypes.sizeof(udp_msg_mtype_t)
class un_udp_msg_mtype_t(ctypes.Union):
  _pack_=1
  _fields_=[('udp_msg_mtype',udp_msg_mtype_t),
            ('bytes',ctypes.c_ubyte * 8)]
class msg_mtype_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[
            ('last_frag',ctypes.c_uint,1),                     # 'record marker' represents a fragment
            ('size',ctypes.c_uint,31),                         #
            ('xid',ctypes.c_uint),                             # 
            ('mtype',ctypes.c_int),                            # 
           ]
assert ctypes.sizeof(msg_mtype_t)==12,ctypes.sizeof(msg_mtype_t)
class un_msg_mtype_t(ctypes.Union):
  _pack_=1
  _fields_=[('msg_mtype',msg_mtype_t),
            ('bytes',ctypes.c_ubyte * 12)]
class msg_call_proc_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('rpc_version',ctypes.c_uint),                     # 
            ('prog',ctypes.c_uint),                            # 
            ('vers',ctypes.c_uint),                            # 
            ('proc',ctypes.c_uint),                            # 
           ]
assert ctypes.sizeof(msg_call_proc_t)==16,ctypes.sizeof(msg_call_proc_t)
class un_msg_call_proc_t(ctypes.Union):
  _pack_=1
  _fields_=[('msg_call_proc',msg_call_proc_t),
            ('bytes',ctypes.c_ubyte * 16)]
class opaque_auth_flavor_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('flavor',ctypes.c_uint),                          # auth_flavor_num
            ('len',ctypes.c_uint),                             # 
           ]
assert ctypes.sizeof(opaque_auth_flavor_t)==8,ctypes.sizeof(opaque_auth_flavor_t)
class un_opaque_auth_flavor_t(ctypes.Union):
  _pack_=1
  _fields_=[('opaque_auth_flavor',opaque_auth_flavor_t),
            ('bytes',ctypes.c_ubyte * 8)]
class stamp_namelen_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('stamp',ctypes.c_uint),                           #
            ('namelen',ctypes.c_uint),                         # 
           ]
assert ctypes.sizeof(stamp_namelen_t)==8,ctypes.sizeof(stamp_namelen_t)
class un_stamp_namelen_t(ctypes.Union):
  _pack_=1
  _fields_=[('stamp_namelen',stamp_namelen_t),
            ('bytes',ctypes.c_ubyte * 8)]
class uid_gidlen_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('uid',ctypes.c_uint),                             #
            ('gid',ctypes.c_uint),                             #
            ('gidlen',ctypes.c_uint),                          # 
           ]
assert ctypes.sizeof(uid_gidlen_t)==12,ctypes.sizeof(uid_gidlen_t)
class un_uid_gidlen_t(ctypes.Union):
  _pack_=1
  _fields_=[('uid_gidlen',uid_gidlen_t),
            ('bytes',ctypes.c_ubyte * 12)]
class credential_gss_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('gss_version',ctypes.c_uint),                       #
            ('gss_proc',ctypes.c_uint),                          # 
            ('gss_seqno',ctypes.c_uint),                         # 
            ('gss_service',ctypes.c_uint),                       # 
            ('context_len',ctypes.c_uint),                       # 
           ]
assert ctypes.sizeof(credential_gss_t)==20,ctypes.sizeof(credential_gss_t)
class un_credential_gss_t(ctypes.Union):
  _pack_=1
  _fields_=[('credential_gss',credential_gss_t),
            ('bytes',ctypes.c_ubyte * 20)]
class nfs_offset_count_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('nfs_offset',ctypes.c_ulong),                     #
            ('nfs_count',ctypes.c_uint),                       # 
           ]
assert ctypes.sizeof(nfs_offset_count_t)==12,ctypes.sizeof(nfs_offset_count_t)
class un_nfs_offset_count_t(ctypes.Union):
  _pack_=1
  _fields_=[('nfs_offset_count',nfs_offset_count_t),
            ('bytes',ctypes.c_ubyte * 12)]
class nfs_offset_count_datasync_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('nfs_offset',ctypes.c_ulong),                     #
            ('nfs_count',ctypes.c_uint),                       # 
            ('data_sync',ctypes.c_uint),                       # 
            ('data_length',ctypes.c_uint),                     # 
           ]
assert ctypes.sizeof(nfs_offset_count_datasync_t)==20,ctypes.sizeof(nfs_offset_count_datasync_t)
class un_nfs_offset_count_datasync_t(ctypes.Union):
  _pack_=1
  _fields_=[('nfs_offset_count_datasync',nfs_offset_count_datasync_t),
            ('bytes',ctypes.c_ubyte * 20)]
class nfs_access_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('zero',ctypes.c_uint,26),                       # 
            ('execute',ctypes.c_uint,1),                     # 
            ('delete',ctypes.c_uint,1),                      # 
            ('extend',ctypes.c_uint,1),                      # 
            ('modify',ctypes.c_uint,1),                      # 
            ('lookup',ctypes.c_uint,1),                      # 
            ('read',ctypes.c_uint,1),                        #
           ]
assert ctypes.sizeof(nfs_access_t)==4,ctypes.sizeof(nfs_access_t)
class un_nfs_access_t(ctypes.Union):
  _pack_=1
  _fields_=[('nfs_access',nfs_access_t),
            ('bytes',ctypes.c_ubyte * 4)]
class reply_stat_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('reply',ctypes.c_uint),                         # 
           ]
assert ctypes.sizeof(reply_stat_t)==4,ctypes.sizeof(reply_stat_t)
class un_reply_stat_t(ctypes.Union):
  _pack_=1
  _fields_=[('reply_stat',reply_stat_t),
            ('bytes',ctypes.c_ubyte * 4)]

MSG_VERSION               = 2                                #
NFS_PROGRAM               = 100003                           #
reply_stat_num=dict(
  MSG_ACCEPTED                             = 0,                   #
  MSG_DENIED                               = 1,                   #
)
accept_stat_num=dict(
  SUCCESS                                  = 0,                   #
  PROG_UNAVAIL                             = 1,                   #
  PROG_MISMATCH                            = 2,                   #
  PROC_UNAVAIL                             = 3,                   #
  GARBAGE_ARGS                             = 4,                   #
  SYSTEM_ERR                               = 5,                   #
)
rjcted_rply_num=dict(
  SUNRPC_RPC_MISMATCH                      = 0,                   #
  SUNRPC_AUTH_ERROR                        = 1,                   #
)

class RJ_versions_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('low',ctypes.c_uint),                             #
            ('high',ctypes.c_uint),                            #
           ]
assert ctypes.sizeof(RJ_versions_t)==8,ctypes.sizeof(RJ_versions_t)
class un_RJ_versions_t(ctypes.Union):
  _pack_=1
  _fields_=[('RJ_versions',RJ_versions_t),
            ('bytes',ctypes.c_ubyte * 8)]

class Unreject_t(ctypes.Union):
  _pack_=1
  _fields_=[('rj_ver',RJ_versions_t),                          #
            ('RJ_why',ctypes.c_uint),                          # auth_stat - why authentication did not work
           ]
assert ctypes.sizeof(Unreject_t)==8,ctypes.sizeof(Unreject_t)

# fixme class rejected_reply_t(ctypes.BigEndianStructure):
class rejected_reply_t(ctypes.Structure):
  _pack_=1
  _fields_=[('rj_stat',ctypes.c_uint),                         # reject_stat
            ('unreject',Unreject_t),                           #
           ]
assert ctypes.sizeof(rejected_reply_t)==12,ctypes.sizeof(rejected_reply_t)
class un_rejected_reply_t(ctypes.Union):
  _pack_=1
  _fields_=[('rejected_rep',rejected_reply_t),
            ('bytes',ctypes.c_ubyte * 12)]

class reply_body_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('rp_stat',ctypes.c_uint),                         # typedef enum reply_stat
            ('rp_reject',rejected_reply_t),                    # if rejected
           ]
assert ctypes.sizeof(reply_body_t)==16,ctypes.sizeof(reply_body_t)
class un_reply_body_t(ctypes.Union):
  _pack_=1
  _fields_=[('reply_body',reply_body_t),
            ('bytes',ctypes.c_ubyte * 16)]


NFS3_PORT                 = 2049                             # TCP and UDP port number
NFS3_MAXDATA              = 32768                            # 
#NFS3_MAXPATHLEN           = PATH_MAX                         # 
#NFS3_MAXNAMLEN            = NAME_MAX                         # 
NFS3_MAXGROUPS            = 16                               # 
NFS3_FHSIZE               = 64                               # the maximum size in bytes of the opaque file handle
NFS3_COOKIESIZE           = 4                                # the size in bytes of the opaque cookie size
NFS3_CREATEVERFSIZE       = 8                                # the size in bytes of the opaque cookie verifier passed by READDIR and READDIRPLUS
NFS3_COOKIEVERFSIZE       = 8                                # the size in bytes of the opaque cookie verifier used by exclusive CREATE
NFS3_WRITEVERFSIZE        = 8                                # the size in bytes of the opaque cookie verifier used by exclusive WRITE
NFS3_FIFO_DEV             = (-1)                             # 

NFS3MODE_FMT              = 0170000                          # 
NFS3MODE_DIR              = 0040000                          # 
NFS3MODE_CHR              = 0020000                          # 
NFS3MODE_BLK              = 0060000                          # 
NFS3MODE_REG              = 0100000                          # 
NFS3MODE_LNK              = 0120000                          # 
NFS3MODE_SOCK             = 0140000                          # 
NFS3MODE_FIFO             = 0010000                          # 

NFS3_ACCESS_READ          = 0x0001                           # 
NFS3_ACCESS_LOOKUP        = 0x0002                           # 
NFS3_ACCESS_MODIFY        = 0x0004                           # 
NFS3_ACCESS_EXTEND        = 0x0008                           # 
NFS3_ACCESS_DELETE        = 0x0010                           # 
NFS3_ACCESS_EXECUTE       = 0x0020                           # 
NFS3_ACCESS_FULL          = 0x003f                           # 
NFS3_FSF_LINK             = 0x0001                           # 
NFS3_FSF_SYMLINK          = 0x0002                           # 
NFS3_FSF_HOMOGENEOUS      = 0x0008                           # 
NFS3_FSF_CANSETTIME       = 0x0010                           # 
NFS3_FSF_DEFAULT          = 0x001B                           # 
NFS3_FSF_BILLYBOY         = 0x0018                           # 
NFS3_FSF_READONLY         = 0x0008                           # 

NFS3_VERSION              = 3                                # 

# NFS3 procedure
NFS3PROC_NULL             = 0                                # do nothing
NFS3PROC_GETATTR          = 1                                # get file attribute
NFS3PROC_SETATTR          = 2                                # set file attribute
NFS3PROC_LOOKUP           = 3                                # lookup file name
NFS3PROC_ACCESS           = 4                                # check access permission
NFS3PROC_READLINK         = 5                                # read from symbolic link
NFS3PROC_READ             = 6                                # read from file
NFS3PROC_WRITE            = 7                                # write to file
NFS3PROC_CREATE           = 8                                # create a file
NFS3PROC_MKDIR            = 9                                # create a directory
NFS3PROC_SYMLINK          = 10                               # create a symbolic link
NFS3PROC_MKNOD            = 11                               # create a special device
NFS3PROC_REMOVE           = 12                               # remove a file
NFS3PROC_RMDIR            = 13                               # remove a directory
NFS3PROC_RENAME           = 14                               # rename file or directory
NFS3PROC_LINK             = 15                               # create link to an object
NFS3PROC_READDIR          = 16                               # read from directory
NFS3PROC_READDIRPLUS      = 17                               # extended read from directory
NFS3PROC_FSSTAT           = 18                               # get dynamic file system information
NFS3PROC_FSINFO           = 19                               # get static file system information
NFS3PROC_PATHCONF         = 20                               # retrieve POSIX information
NFS3PROC_COMMIT           = 21                               # commit cached data on a server to stable

NFS3PROC_num=dict(
NULL             = 0,                                        # do nothing
GETATTR          = 1,                                        # get file attribute
SETATTR          = 2,                                        # set file attribute
LOOKUP           = 3,                                        # lookup file name
ACCESS           = 4,                                        # check access permission
READLINK         = 5,                                        # read from symbolic link
READ             = 6,                                        # read from file
WRITE            = 7,                                        # write to file
CREATE           = 8,                                        # create a file
MKDIR            = 9,                                        # create a directory
SYMLINK          = 10,                                       # create a symbolic link
MKNOD            = 11,                                       # create a special device
REMOVE           = 12,                                       # remove a file
RMDIR            = 13,                                       # remove a directory
RENAME           = 14,                                       # rename file or directory
LINK             = 15,                                       # create link to an object
READDIR          = 16,                                       # read from directory
READDIRPLUS      = 17,                                       # extended read from directory
FSSTAT           = 18,                                       # get dynamic file system information
FSINFO           = 19,                                       # get static file system information
PATHCONF         = 20,                                       # retrieve POSIX information
COMMIT           = 21,                                       # commit cached data on a server to stable
)
NFS_MNT3_VERSION          = 3                                # 
NFS3_FSF_READONLY_num=dict(
  NFS3_CREATE_UNCHECKED                    = 0,                   # 
  NFS3_CREATE_GUARDED                      = 1,                   # 
  NFS3_CREATE_EXCLUSIVE                    = 2,                   # 
)
nfs3_ftype_num=dict(
  NF3NON                                   = 0,                   # 
  NF3REG                                   = 1,                   # 
  NF3DIR                                   = 2,                   # 
  NF3BLK                                   = 3,                   # 
  NF3CHR                                   = 4,                   # 
  NF3LNK                                   = 5,                   # 
  NF3SOCK                                  = 6,                   # 
  NF3FIFO                                  = 7,                   # 
  NF3BAD                                   = 8,                   # 
)
nfsstat3_num=dict(
  NFS3_OK                                  = 0,                   # the call complete successfully
  NFS3ERR_PERM                             = 1,                   # not a privileged user (root) or owner of target of the operation
  NFS3ERR_NOENT                            = 2,                   # no such file or directory
  NFS3ERR_IO                               = 5,                   # i/o error (disk error)
  NFS3ERR_NXIO                             = 6,                   # i/o error. no such device or address
  NFS3ERR_ACCES                            = 13,                  # owner or privileged permission failures
  NFS3ERR_EXIST                            = 17,                  # file exists
  NFS3ERR_XDEV                             = 18,                  # attempt to do a cross-device hard link
  NFS3ERR_NODEV                            = 19,                  # no such device
  NFS3ERR_NOTDIR                           = 20,                  # not a directory
  NFS3ERR_ISDIR                            = 21,                  # is a directory
  NFS3ERR_INVAL                            = 22,                  # invalid argument or unsupported argument
  NFS3ERR_FBIG                             = 27,                  # file to big
  NFS3ERR_NOSPC                            = 28,                  # no space left on device
  NFS3ERR_ROFS                             = 30,                  # read-only file system
  NFS3ERR_MLINK                            = 31,                  # too many hard links
  NFS3ERR_NAMETOOLONG                      = 63,                  # the filename too long
  NFS3ERR_NOTEMPTY                         = 66,                  # remove directory that was not empty
  NFS3ERR_DQUOT                            = 69,                  # quota hard limit exceeded.
  NFS3ERR_STALE                            = 70,                  # invalid file handle
  NFS3ERR_REMOTE                           = 71,                  # too many levels of remote in path
  NFS3ERR_BADHANDLE                        = 10001,               # illegal NFS file handler
  NFS3ERR_NOT_SYNC                         = 10002,               # update sync mismatch was detected during a SETATR operation
  NFS3ERR_BAD_COOKIE                       = 10003,               # READDIR or READDIRPLUS cookie is stale
  NFS3ERR_NOTSUPP                          = 10004,               # operation not supported
  NFS3ERR_TOOSMALL                         = 10005,               # buffer or request is too small
  NFS3ERR_SERVERFAULT                      = 10006,               # server unmapped error value
  NFS3ERR_BADTYPE                          = 10007,               # create an object of a type not supported
  NFS3ERR_JUKEBOX                          = 10008,               # The server initiated the request, but was not able to complete it in a timely fashion. The client should wait and then try the request with a new RPC transaction ID.

)
class nfs3_status_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('nfs3_status',ctypes.c_uint),                           # 
           ]
assert ctypes.sizeof(nfs3_status_t)==4,ctypes.sizeof(nfs3_status_t)
class un_nfs3_status_t(ctypes.Union):
  _pack_=1
  _fields_=[('nfs3_status',nfs3_status_t),
            ('bytes',ctypes.c_ubyte * 4)]

class nfs3_attributes_follow_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('nfs3_attributes_follow',ctypes.c_uint),                           # 
           ]
assert ctypes.sizeof(nfs3_attributes_follow_t)==4,ctypes.sizeof(nfs3_attributes_follow_t)
class un_nfs3_attributes_follow_t(ctypes.Union):
  _pack_=1
  _fields_=[('nfs3_attributes_follow',nfs3_attributes_follow_t),
            ('bytes',ctypes.c_ubyte * 4)]
class nfs3_time_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('seconds',ctypes.c_uint),                           # fixme errstat_t 
            ('nseconds',ctypes.c_uint),                           # 
           ]
assert ctypes.sizeof(nfs3_time_t)==8,ctypes.sizeof(nfs3_time_t)
class un_nfs3_time_t(ctypes.Union):
  _pack_=1
  _fields_=[('nfs3_time',nfs3_time_t),
            ('bytes',ctypes.c_ubyte * 8)]

class specdata3_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('specdata1',ctypes.c_uint),                       # 
            ('specdata2',ctypes.c_uint),                       # 
           ]
assert ctypes.sizeof(specdata3_t)==8,ctypes.sizeof(specdata3_t)
class un_specdata3_t(ctypes.Union):
  _pack_=1
  _fields_=[('specdata3',specdata3_t),
            ('bytes',ctypes.c_ubyte * 8)]
class fattr3_1_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('type',ctypes.c_uint),                            # 
            ('mode',ctypes.c_uint),                            # 
            ('nlink',ctypes.c_uint),                           # 
            ('uid',ctypes.c_uint),                             # 
            ('gid',ctypes.c_uint),                             # 
           ]
assert ctypes.sizeof(fattr3_1_t)==20,ctypes.sizeof(fattr3_1_t)
class un_fattr3_1_t(ctypes.Union):
  _pack_=1
  _fields_=[('fattr3_1',fattr3_1_t),
            ('bytes',ctypes.c_ubyte * 20)]
class fattr3_2_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[
            ('size',ctypes.c_ulong),                           # 
            ('used',ctypes.c_ulong),                           # 
            ('rdev',specdata3_t),                              # 
            ('fsid',ctypes.c_ulong),                           # 
            ('fileid',ctypes.c_ulong),                         # 
            ('atime',nfs3_time_t),                             # 
            ('mtime',nfs3_time_t),                             # 
            ('ctime',nfs3_time_t),                             # 
           ]
assert ctypes.sizeof(fattr3_2_t)==64,ctypes.sizeof(fattr3_2_t)
class un_fattr3_2_t(ctypes.Union):
  _pack_=1
  _fields_=[('fattr3_2',fattr3_2_t),
            ('bytes',ctypes.c_ubyte * 64)]
class fattr3_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('type',ctypes.c_uint),                            # 
            ('mode',ctypes.c_uint),                            # 
            ('nlink',ctypes.c_uint),                           # 
            ('uid',ctypes.c_uint),                             # 
            ('gid',ctypes.c_uint),                             # 
            ('size',ctypes.c_ulong),                           # 
            ('used',ctypes.c_ulong),                           # 
            ('rdev',specdata3_t),                              # 
            ('fsid',ctypes.c_ulong),                           # 
            ('fileid',ctypes.c_ulong),                         # 
            ('atime',nfs3_time_t),                             # 
            ('mtime',nfs3_time_t),                             # 
            ('ctime',nfs3_time_t),                             # 
           ]
assert ctypes.sizeof(fattr3_t)==84,ctypes.sizeof(fattr3_t)
class un_fattr3_t(ctypes.Union):
  _pack_=1
  _fields_=[('fattr3',fattr3_t),
            ('bytes',ctypes.c_ubyte * 84)]
class wcc_attr_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[
            ('size',ctypes.c_ulong),                           # 
            ('mtime',nfs3_time_t),                             # 
            ('ctime',nfs3_time_t),                             # 
           ]
assert ctypes.sizeof(wcc_attr_t)==24,ctypes.sizeof(wcc_attr_t)
class un_wcc_attr_t(ctypes.Union):
  _pack_=1
  _fields_=[('wcc_attr',wcc_attr_t),
            ('bytes',ctypes.c_ubyte * 24)]







class nfs3_status_error_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('error',ctypes.c_uint),                           # fixme errstat_t 
            ('errno',ctypes.c_uint),                           # 
           ]
assert ctypes.sizeof(nfs3_status_error_t)==8,ctypes.sizeof(nfs3_status_error_t)
class un_nfs3_status_error_t(ctypes.Union):
  _pack_=1
  _fields_=[('nfs3_status_error',nfs3_status_error_t),
            ('bytes',ctypes.c_ubyte * 8)]

class accepted_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('state',ctypes.c_uint),                           # accepted_status_num
           ]
assert ctypes.sizeof(accepted_t)==4,ctypes.sizeof(accepted_t)
class un_accepted_t(ctypes.Union):
  _pack_=1
  _fields_=[('accepted',accepted_t),
            ('bytes',ctypes.c_ubyte * 4)]

class fhlen_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('fhlen',ctypes.c_uint),                         # 
           ]
assert ctypes.sizeof(fhlen_t)==4,ctypes.sizeof(fhlen_t)
class un_fhlen_t(ctypes.Union):
  _pack_=1
  _fields_=[('fhlen',fhlen_t),
            ('bytes',ctypes.c_ubyte * 4)]
class namelen_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('namelen',ctypes.c_uint),                         # 
           ]
assert ctypes.sizeof(namelen_t)==4,ctypes.sizeof(namelen_t)
class un_namelen_t(ctypes.Union):
  _pack_=1
  _fields_=[('namelen',namelen_t),
            ('bytes',ctypes.c_ubyte * 4)]

stable_how_num=dict(
  UNSTABLE                                 = 0,                   # 
  DATA_SYNC                                = 1,                   # 
  FILE_SYNC                                = 2,                   # 
)
class write3resok_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('count',ctypes.c_uint),                           # 
            ('committed',ctypes.c_uint),                       # 
           ]
assert ctypes.sizeof(write3resok_t)==8,ctypes.sizeof(write3resok_t)
class un_write3resok_t(ctypes.Union):
  _pack_=1
  _fields_=[('write3resok',write3resok_t),
            ('bytes',ctypes.c_ubyte * 8)]

class fsinfo3resok_1_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('rtmax',ctypes.c_uint),                           # 
            ('rtpref',ctypes.c_uint),                          # 
            ('rtmult',ctypes.c_uint),                          # 
            ('wtmax',ctypes.c_uint),                           # 
            ('wtpref',ctypes.c_uint),                          # 
            ('wtmult',ctypes.c_uint),                          # 
            ('dtpref',ctypes.c_uint),                          # 
           ]
#print fsinfo3resok_1_t.rtmax
#print fsinfo3resok_1_t.rtpref
#print fsinfo3resok_1_t.rtmult
#print fsinfo3resok_1_t.wtmax
#print fsinfo3resok_1_t.wtpref
#print fsinfo3resok_1_t.wtmult
#print fsinfo3resok_1_t.dtpref
assert ctypes.sizeof(fsinfo3resok_1_t)==28,ctypes.sizeof(fsinfo3resok_1_t)
class un_fsinfo3resok_1_t(ctypes.Union):
  _pack_=1
  _fields_=[('fsinfo3resok_1',fsinfo3resok_1_t),
            ('bytes',ctypes.c_ubyte * 28)]
class fsinfo3resok_2_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[
            ('maxfilesize',ctypes.c_ulong),                    # 
            ('time_delta',nfs3_time_t),                        # 
            ('properties',ctypes.c_uint),                      # 
           ]
assert ctypes.sizeof(fsinfo3resok_2_t)==20,ctypes.sizeof(fsinfo3resok_2_t)
class un_fsinfo3resok_2_t(ctypes.Union):
  _pack_=1
  _fields_=[('fsinfo3resok_2',fsinfo3resok_2_t),
            ('bytes',ctypes.c_ubyte * 20)]


class fsstat3resok_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('tbytes',ctypes.c_ulong),                         # total bytes
            ('fbytes',ctypes.c_ulong),                         # free bytes
            ('abytes',ctypes.c_ulong),                         # free bytes that available to the user
            ('tfiles',ctypes.c_ulong),                         # total file slots
            ('ffiles',ctypes.c_ulong),                         # free file slots
            ('afiles',ctypes.c_ulong),                         # free file slots that available to the user
            ('invarsec',ctypes.c_uint),                        # a measure of file system volatility
           ]
assert ctypes.sizeof(fsstat3resok_t)==52,ctypes.sizeof(fsstat3resok_t)
class un_fsstat3resok_t(ctypes.Union):
  _pack_=1
  _fields_=[('fsstat3resok',fsstat3resok_t),
            ('bytes',ctypes.c_ubyte * 52)]

class pathconf3resok_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[
            ('linkmax',ctypes.c_uint),                         # 
            ('name_max',ctypes.c_uint),                        # 
            ('no_trunc',ctypes.c_uint),                        # 
            ('chown_restricted',ctypes.c_uint),                # 
            ('case_insensitive',ctypes.c_uint),                # 
            ('case_preserving',ctypes.c_uint),                 # 
           ]
assert ctypes.sizeof(pathconf3resok_t)==24,ctypes.sizeof(pathconf3resok_t)
class un_pathconf3resok_t(ctypes.Union):
  _pack_=1
  _fields_=[('pathconf3resok',pathconf3resok_t),
            ('bytes',ctypes.c_ubyte * 24)]

class create_mode_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('mode',ctypes.c_uint),                            # 
           ]
assert ctypes.sizeof(create_mode_t)==4,ctypes.sizeof(attr_mode_t)
class un_create_mode_t(ctypes.Union):
  _pack_=1
  _fields_=[('mode',create_mode_t),
            ('bytes',ctypes.c_ubyte * 4)]
class attr_mode_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('mode',ctypes.c_uint),                            # 
           ]
assert ctypes.sizeof(attr_mode_t)==4,ctypes.sizeof(attr_mode_t)
class un_attr_mode_t(ctypes.Union):
  _pack_=1
  _fields_=[('mode',attr_mode_t),
            ('bytes',ctypes.c_ubyte * 4)]
class attr_uid_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('uid',ctypes.c_uint),                            # 
           ]
assert ctypes.sizeof(attr_uid_t)==4,ctypes.sizeof(attr_uid_t)
class un_attr_uid_t(ctypes.Union):
  _pack_=1
  _fields_=[('uid',attr_uid_t),
            ('bytes',ctypes.c_ubyte * 4)]
class msg_attr_gid_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('gid',ctypes.c_uint),                            # 
           ]
assert ctypes.sizeof(msg_attr_gid_t)==4,ctypes.sizeof(attr_gid_t)
class un_msg_attr_gid_t(ctypes.Union):
  _pack_=1
  _fields_=[('gid',msg_attr_gid_t),
            ('bytes',ctypes.c_ubyte * 4)]
class attr_gid_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('gid',ctypes.c_uint),                            # 
           ]
assert ctypes.sizeof(attr_gid_t)==4,ctypes.sizeof(attr_gid_t)
class un_attr_gid_t(ctypes.Union):
  _pack_=1
  _fields_=[('gid',attr_gid_t),
            ('bytes',ctypes.c_ubyte * 4)]
class attr_size_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('size',ctypes.c_ulong),                            # 
           ]
assert ctypes.sizeof(attr_size_t)==8,ctypes.sizeof(attr_size_t)
class un_attr_size_t(ctypes.Union):
  _pack_=1
  _fields_=[('size',attr_size_t),
            ('bytes',ctypes.c_ubyte * 8)]
class attr_atime_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[
            ('atime',nfs3_time_t),                             # 
           ]
assert ctypes.sizeof(attr_atime_t)==8,ctypes.sizeof(attr_atime_t)
class un_attr_atime_t(ctypes.Union):
  _pack_=1
  _fields_=[('atime',attr_atime_t),
            ('bytes',ctypes.c_ubyte * 8)]
class attr_mtime_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[
            ('mtime',nfs3_time_t),                             # 
           ]
assert ctypes.sizeof(attr_mtime_t)==8,ctypes.sizeof(attr_mtime_t)
class un_attr_mtime_t(ctypes.Union):
  _pack_=1
  _fields_=[('mtime',attr_mtime_t),
            ('bytes',ctypes.c_ubyte * 8)]
class set_atime_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[
            ('atime',ctypes.c_uint),                             # 
           ]
assert ctypes.sizeof(set_atime_t)==4,ctypes.sizeof(set_atime_t)
class un_set_atime_t(ctypes.Union):
  _pack_=1
  _fields_=[('atime',set_atime_t),
            ('bytes',ctypes.c_ubyte * 4)]
class set_mtime_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[
            ('mtime',ctypes.c_uint),                             # 
           ]
assert ctypes.sizeof(set_mtime_t)==4,ctypes.sizeof(set_mtime_t)
class un_set_mtime_t(ctypes.Union):
  _pack_=1
  _fields_=[('mtime',set_mtime_t),
            ('bytes',ctypes.c_ubyte * 4)]
class attr_ctime_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[
            ('ctime',nfs3_time_t),                             # 
           ]
assert ctypes.sizeof(attr_ctime_t)==8,ctypes.sizeof(attr_ctime_t)
class un_attr_ctime_t(ctypes.Union):
  _pack_=1
  _fields_=[('ctime',attr_ctime_t),
            ('bytes',ctypes.c_ubyte * 8)]


class ftype_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[
            ('ftype',ctypes.c_uint),                             # 
           ]
assert ctypes.sizeof(ftype_t)==4,ctypes.sizeof(ftype_t)
class un_ftype_t(ctypes.Union):
  _pack_=1
  _fields_=[('ftype',ftype_t),
            ('bytes',ctypes.c_ubyte * 4)]
class readdir3args_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('cookie',ctypes.c_ulong),                         # 
            ('cookieverf',ctypes.c_ulong),                     # 
            ('count',ctypes.c_uint),                           # 
           ]
assert ctypes.sizeof(readdir3args_t)==20,ctypes.sizeof(readdir3args_t)
class un_readdir3args_t(ctypes.Union):
  _pack_=1
  _fields_=[('readdir3args',readdir3args_t),
            ('bytes',ctypes.c_ubyte * 20)]

class cookie_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('cookie',ctypes.c_ulong),                     # 
           ]
assert ctypes.sizeof(cookie_t)==8,ctypes.sizeof(cookie_t)
class un_cookie_t(ctypes.Union):
  _pack_=1
  _fields_=[('cookie',cookie_t),
            ('bytes',ctypes.c_ubyte * 8)]
class fileid_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('fileid',ctypes.c_ulong),                         # 
           ]
assert ctypes.sizeof(fileid_t)==8,ctypes.sizeof(fileid_t)
class un_fileid_t(ctypes.Union):
  _pack_=1
  _fields_=[('fileid',fileid_t),
            ('bytes',ctypes.c_ubyte * 8)]
class eof_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[
            ('eof',ctypes.c_uint),                             # 
           ]
assert ctypes.sizeof(eof_t)==4,ctypes.sizeof(eof_t)
class un_eof_t(ctypes.Union):
  _pack_=1
  _fields_=[('eof',eof_t),
            ('bytes',ctypes.c_ubyte * 4)]
class readdirplus3args_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('cookie',ctypes.c_ulong),                         # 
            ('cookieverf',ctypes.c_ulong),                     # 
            ('dircount',ctypes.c_uint),                        # 
            ('maxcount',ctypes.c_uint),                        # 
           ]
assert ctypes.sizeof(readdirplus3args_t)==24,ctypes.sizeof(readdirplus3args_t)
class un_readdirplus3args_t(ctypes.Union):
  _pack_=1
  _fields_=[('readdirplus3args',readdirplus3args_t),
            ('bytes',ctypes.c_ubyte * 24)]

class read3resok_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('count',ctypes.c_uint),                           # 
            ('eof',ctypes.c_uint),                             # 
            ('data_length',ctypes.c_uint),                     # 
           ]
assert ctypes.sizeof(read3resok_t)==12,ctypes.sizeof(read3resok_t)
class un_read3resok_t(ctypes.Union):
  _pack_=1
  _fields_=[('read3resok',read3resok_t),
            ('bytes',ctypes.c_ubyte * 12)]

time_how_num=dict(
  DONT_CHANGE                              = 0,                   # 
  SET_TO_SERVER_TIME                       = 1,                   # 
  SET_TO_CLIENT_TIME                       = 2,                   # 
)


NFS_MNT3_VERSION_num=dict(
  NF3NON                                   = 0,                   # 
  NF3REG                                   = 1,                   # 
  NF3DIR                                   = 2,                   # 
  NF3BLK                                   = 3,                   # 
  NF3CHR                                   = 4,                   # 
  NF3LNK                                   = 5,                   # 
  NF3SOCK                                  = 6,                   # 
  NF3FIFO                                  = 7,                   # 
  NF3BAD                                   = 8,                   # 
)
class NFS_MNT3_VERSION_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('size',ctypes.c_ushort),                          # 
            ('data',ctypes.c_ubyte*NFS3_FHSIZE),               # 
           ]
assert ctypes.sizeof(NFS_MNT3_VERSION_t)==66,ctypes.sizeof(NFS_MNT3_VERSION_t)
class un_NFS_MNT3_VERSION_t(ctypes.Union):
  _pack_=1
  _fields_=[('NFS_MNT3_VERSI',NFS_MNT3_VERSION_t),
            ('bytes',ctypes.c_ubyte * 66)]

tcp_option_kind_num=dict(
End_of_Option_List=0,                   # length 1[RFC793]
No_Operation=1,                         # length 1[RFC793]
Maximum_Segment_Size=2,                 # length 4 [RFC793]
Window_Scale=3,                         # length 3 [RFC7323]
SACK_Permitted=4,                       # length 2 [RFC2018]
SACK=5,                                 # length N [RFC2018]
Timestamps=8,                           # length 10 [RFC7323]
Skeeter=16,                             # length 1[Stev_Knowles]
Bubba=17,                               # length 1[Stev_Knowles]
Trailer_Checksum_Option=18,             # length 3 [Subbu_Subramaniam][Monroe_Bridges]
SCPS_Capabilities=20,                   # length 1[Keith_Scott]
Selective_Negative_Acknowledgements=21, # length 1[Keith_Scott]
Record_Boundaries=22,                   # length 1[Keith_Scott]
Corruption_experienced=23,              # length 1[Keith_Scott]
SNAP=24,                                # length 1[Vladimir_Sukonnik]
TCP_Compression_Filter=26,              # length 1[Steve_Bellovin]
Quick_Start_Response=27,                # length 8 [RFC4782]
User_Timeout_Option=28,                 # length 4 [RFC5482]
TCP_Authentication_Option=29,           # length  [RFC5925]
Multipath_TCP=30,                       # length N [RFC6824]
TCP_Fast_Open_Cookie=34,                # length variable [RFC7413]
)
class tcp_max_seg_size_t(ctypes.Structure):
  _pack_=1
  _fields_=[('kind',ctypes.c_ubyte),                           # 
            ('length',ctypes.c_ubyte),                         # 
            ('seg_size',ctypes.c_ushort),                      # 
           ]
assert ctypes.sizeof(tcp_max_seg_size_t)==4,ctypes.sizeof(tcp_max_seg_size_t)
class un_tcp_max_seg_size_t(ctypes.Union):
  _pack_=1
  _fields_=[('max_seg_size',tcp_max_seg_size_t),
            ('bytes',ctypes.c_ubyte * 4)]
class tcp_permitted_t(ctypes.Structure):
  _pack_=1
  _fields_=[('kind',ctypes.c_ubyte),                           # 
            ('length',ctypes.c_ubyte),                         # 
           ]
assert ctypes.sizeof(tcp_permitted_t)==2,ctypes.sizeof(tcp_permitted_t)
class un_tcp_permitted_t(ctypes.Union):
  _pack_=1
  _fields_=[('tcp_permitted',tcp_permitted_t),
            ('bytes',ctypes.c_ubyte * 2)]
class tcp_timestamp1_t(ctypes.Structure):
  _pack_=1
  _fields_=[('kind',ctypes.c_ubyte),                           # 
            ('length',ctypes.c_ubyte),                         # 
           ]
assert ctypes.sizeof(tcp_timestamp1_t)==2,ctypes.sizeof(tcp_timestamp1_t)
class un_tcp_timestamp1_t(ctypes.Union):
  _pack_=1
  _fields_=[('tcp_timestamp',tcp_timestamp1_t),
            ('bytes',ctypes.c_ubyte * 2)]
class tcp_timestamp2_t(ctypes.Structure):
  _pack_=1
  _fields_=[
            ('ts',ctypes.c_uint),                              # 
            ('ts_echo',ctypes.c_uint),                         # 
           ]
assert ctypes.sizeof(tcp_timestamp2_t)==8,ctypes.sizeof(tcp_timestamp2_t)
class un_tcp_timestamp2_t(ctypes.Union):
  _pack_=1
  _fields_=[('tcp_timestamp',tcp_timestamp2_t),
            ('bytes',ctypes.c_ubyte * 8)]
class tcp_nop_t(ctypes.Structure):
  _pack_=1
  _fields_=[('kind',ctypes.c_ubyte),                           # 
           ]
assert ctypes.sizeof(tcp_nop_t)==1,ctypes.sizeof(tcp_nop_t)
class un_tcp_nop_t(ctypes.Union):
  _pack_=1
  _fields_=[('tcp_nop',tcp_nop_t),
            ('bytes',ctypes.c_ubyte * 1)]

# mount3
MNTPATHLEN = 1024;  # Maximum bytes in a path name
MNTNAMLEN  = 255;   # Maximum bytes in a name
FHSIZE3    = 64;    # Maximum bytes in a V3 file handle

# string dirpath  <MNTPATHLEN>
# string name     <MNTNAMLEN>
# opaque fhandle3 <FHSIZE3>


MOUNTSTAT3_num=dict(
  MNT3_OK                                  = 0,                   # no error
  MNT3ERR_PERM                             = 1,                   # Not owner
  MNT3ERR_NOENT                            = 2,                   # No such file or directory
  MNT3ERR_IO                               = 5,                   # I/O error
  MNT3ERR_ACCES                            = 13,                  # Permission denied
  MNT3ERR_NOTDIR                           = 20,                  # Not a directory
  MNT3ERR_INVAL                            = 22,                  # Invalid argument
  MNT3ERR_NAMETOOLONG                      = 63,                  # Filename too long
  MNT3ERR_NOTSUPP                          = 10004,               # Operation not supported
  MNT3ERR_SERVERFAULT                      = 10006,               # A failure on the server
)

MOUNTPROC3_num=dict(
  MOUNTPROC3_NULL                          = 0,                   # null
  MOUNTPROC3_MNT                           = 1,                   # add mount entry
  MOUNTPROC3_DUMP                          = 2,                   # return mount entries
  MOUNTPROC3_UMNT                          = 3,                   # remove mount entry
  MOUNTPROC3_UMNTALL                       = 4,                   # remove all mount entries
  MOUNTPROC3_EXPORT                        = 5,                   # return export list
)


# nlm4
LM_MAXSTRLEN = 1024            # The maximum length of the string identifying the caller
LM_MAXNAMELEN = LM_MAXSTRLEN+1 # The maximum number of bytes in the nlm_notify name argument
MAXNETOBJ_SZ = 1024
NLM4_STATS_num=dict(
  NLM4_GRANTED                             = 0,                   # The call completed success
  NLM4_DENIED                              = 1,                   # The call failed. If the client retries the call later, it may succeed
  NLM4_DENIED_NOLOCKS                      = 2,                   # The call failed because the server could not allocate the resources.
  NLM4_BLOCKED                             = 3,                   # Indicates that a blocking request cannot be granted immediately.
                                                                  # The server will issue an NLMPROC4_GRANTED callback to the client the lock is granted
  NLM4_DENIED_GRACE_PERIOD                 = 4,                   # The call failed because the server is reestablishing old locks after a reboot and
                                                                  # is not yet ready to resume normal service 
  NLM4_DEADLCK                             = 5,                   # The request could not be granted and blocking would cause deadlock
  NLM4_ROFS                                = 6,                   # The call failed because the remote file system is read-only
  NLM4_STALE_FH                            = 7,                   # The call failed because it uses an invalid file handle.
                                                                  # The file has been removed or access to file has been revoked on the server
  NLM4_FBIG                                = 8,                   # The call failed because it specified a length or offset that exceeds the range supported by server
  NLM4_FAILED                              = 9,                   # The call failed for some reason not already listed
)


NLMPROC4_num=dict(
  NLMPROC4_NULL                            = 0,                   # do nothing
  NLMPROC4_TEST                            = 1,                   # test lock if the monitored lock is available
  NLMPROC4_LOCK                            = 2,                   # establish a monitored lock
  NLMPROC4_CANCEL                          = 3,                   # cancel an outstanding blocked lock request
  NLMPROC4_UNLOCK                          = 4,                   # remove the lock
  NLMPROC4_GRANTED                         = 5,                   # the callback procedure from the sever to grant the previous lock request
  NLMPROC4_TEST_MSG                        = 6,                   # asynchronous RPC and the same function as the NLM4_TEST
  NLMPROC4_LOCK_MSG                        = 7,                   # asynchronous RPC and the same function as the NLM4_LOCK
  NLMPROC4_CANCEL_MSG                      = 8,                   # asynchronous RPC and the same function as the NLM4_CANCEL
  NLMPROC4_UNLOCK_MSG                      = 9,                   # asynchronous RPC and the same function as the NLM4_UNLOCK
  NLMPROC4_GRANTED_MSG                     = 10,                  # asynchronous RPC and the same function as the NLM4_GRANTED
  NLMPROC4_TEST_RES                        = 11,                  # asynchronous RPC and the return results of the NLM_TEST_MSG to the client
  NLMPROC4_LOCK_RES                        = 12,                  # asynchronous RPC and the return results of the NLM_LOCK_MSG to the client
  NLMPROC4_CANCEL_RES                      = 13,                  # asynchronous RPC and the return results of the NLM_CANCEL_MSG to the client
  NLMPROC4_UNLOCK_RES                      = 14,                  # asynchronous RPC and the return results of the NLM_UNLOCK_MSG to the client
  NLMPROC4_GRANTED_RES                     = 15,                  # asynchronous RPC and the return results of the NLM_GRANTED_MSG to the client
  NLMPROC4_SHARE                           = 20,                  # open the file using the DOS 3.1 with the file-sharing mode
  NLMPROC4_UNSHARE                         = 21,                  # close the file "share.fh"
  NLMPROC4_NM_LOCK                         = 22,                  # non-monitored lock which called by clients that do not run the NSM
  NLMPROC4_FREE_ALL                        = 23,                  # informs the server that the client has been rebooted
)
class nlm_stat_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('state',ctypes.c_uint),                            # lock status
           ]
assert ctypes.sizeof(nlm_stat_t)==4,ctypes.sizeof(nlm_stat_t)
class un_nlm_stat_t(ctypes.Union):
  _pack_=1
  _fields_=[('nlm_stat',nlm_stat_t),
            ('bytes',ctypes.c_ubyte * 4)]

class nlm_res_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[
#           ('cookie',netobj),                                 #  
            ('state',nlm_stat_t),                               # 
           ]
assert ctypes.sizeof(nlm_res_t)==4,ctypes.sizeof(nlm_res_t)
class un_nlm_res_t(ctypes.Union):
  _pack_=1
  _fields_=[('nlm_res',nlm_res_t),
            ('bytes',ctypes.c_ubyte * 4)]
# The nlm_holder structure identifies the holder of a particular lock
class nlm_holder_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('exclusive',ctypes.c_uint),                       # boolean indicates whether the lock is exclusively held by the current holder
            ('uppid',ctypes.c_uint),                           # a unique perprocess identifier for lock differentiation
#           ('oh',netobj),                                     # an opaque object that identifies the host 
            ('l_offset',ctypes.c_ulong),                       # offset of the file locked by this holder
            ('l_len',ctypes.c_ulong),                          # length of the file locked by this holder
           ]
assert ctypes.sizeof(nlm_holder_t)==24,ctypes.sizeof(nlm_holder_t)
class un_nlm_holder_t(ctypes.Union):
  _pack_=1
  _fields_=[('nlm_holder',nlm_holder_t),
            ('bytes',ctypes.c_ubyte * 24)]
class nlm_holder1_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('exclusive',ctypes.c_uint),                       # boolean indicates whether the lock is exclusively held by the current holder1
            ('uppid',ctypes.c_uint),                           # a unique perprocess identifier for lock differentiation
#           ('oh',netobj),                                     # an opaque object that identifies the host 
#           ('l_offset',ctypes.c_ulong),                       # offset of the file locked by this holder1
#           ('l_len',ctypes.c_ulong),                          # length of the file locked by this holder1
           ]
assert ctypes.sizeof(nlm_holder1_t)==8,ctypes.sizeof(nlm_holder1_t)
class un_nlm_holder1_t(ctypes.Union):
  _pack_=1
  _fields_=[('nlm_holder1',nlm_holder1_t),
            ('bytes',ctypes.c_ubyte * 8)]
class nlm_holder2_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[
#           ('exclusive',ctypes.c_uint),                       # boolean indicates whether the lock is exclusively held by the current holder2
#           ('uppid',ctypes.c_uint),                           # a unique perprocess identifier for lock differentiation
#           ('oh',netobj),                                     # an opaque object that identifies the host 
            ('l_offset',ctypes.c_ulong),                       # offset of the file locked by this holder2
            ('l_len',ctypes.c_ulong),                          # length of the file locked by this holder2
           ]
assert ctypes.sizeof(nlm_holder2_t)==16,ctypes.sizeof(nlm_holder2_t)
class un_nlm_holder2_t(ctypes.Union):
  _pack_=1
  _fields_=[('nlm_holder2',nlm_holder2_t),
            ('bytes',ctypes.c_ubyte * 16)]
# The nlm_lock structure defines the information needed to uniquely specify a lock
class nlm_lock_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[
#           ('caller_name', ctype.c_ubyte * LM_MAXSTRLEN),     # uniquely identifies the host making the call
#           ('fh',netobj),                                     # identify a file
#           ('oh',netobj),                                     # identify owner of a lock
            ('uppid',ctypes.c_int),                            # Unique process identifier
            ('l_offset',ctypes.c_ulong),                       # File offset (for record locking)
            ('l_len',ctypes.c_ulong),                          # Length (size of record)
           ]
assert ctypes.sizeof(nlm_lock_t)==20,ctypes.sizeof(nlm_lock_t)
class un_nlm_lock_t(ctypes.Union):
  _pack_=1
  _fields_=[('nlm_lock',nlm_lock_t),
            ('bytes',ctypes.c_ubyte * 20)]
class nlm_lock1_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[
#           ('caller_name', ctype.c_ubyte * LM_MAXSTRLEN),     # uniquely identifies the host making the call
#           ('fh',netobj),                                     # identify a file
#           ('oh',netobj),                                     # identify owner of a lock
            ('uppid',ctypes.c_int),                            # Unique process identifier
            ('l_offset',ctypes.c_ulong),                       # File offset (for record locking)
            ('l_len',ctypes.c_ulong),                          # Length (size of record)
           ]
assert ctypes.sizeof(nlm_lock1_t)==20,ctypes.sizeof(nlm_lock1_t)
class un_nlm_lock1_t(ctypes.Union):
  _pack_=1
  _fields_=[('nlm_lock1',nlm_lock1_t),
            ('bytes',ctypes.c_ubyte * 20)]
class nlm_lock2_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[
#           ('caller_name', ctype.c_ubyte * LM_MAXSTRLEN),     # uniquely identifies the host making the call
#           ('fh',netobj),                                     # identify a file
#           ('oh',netobj),                                     # identify owner of a lock
            ('uppid',ctypes.c_int),                            # Unique process identifier
            ('l_offset',ctypes.c_ulong),                       # File offset (for record locking)
            ('l_len',ctypes.c_ulong),                          # Length (size of record)
           ]
assert ctypes.sizeof(nlm_lock2_t)==20,ctypes.sizeof(nlm_lock2_t)
class un_nlm_lock2_t(ctypes.Union):
  _pack_=1
  _fields_=[('nlm_lock2',nlm_lock2_t),
            ('bytes',ctypes.c_ubyte * 20)]
# nlm_lockargs structure defines the information needed to request a lock on a server
class nlm_lockargs_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[
#           ('cookie',netobj),                                 # 
            ('block',ctypes.c_uint),                           # boolean, Flag to indicate blocking behaviour.
            ('exclusive',ctypes.c_uint),                       # boolean, If exclusive access is desired.
#           ('alock',nlm_lock_t),                              # The actual lock data (see above)
            ('reclaim',ctypes.c_uint),                         # boolean, used for recovering locks
            ('state',ctypes.c_uint),                           # specify local NSM state
           ]
assert ctypes.sizeof(nlm_lockargs_t)==16,ctypes.sizeof(nlm_lockargs_t)
class un_nlm_lockargs_t(ctypes.Union):
  _pack_=1
  _fields_=[('nlm_lockargs',nlm_lockargs_t),
            ('bytes',ctypes.c_ubyte * 16)]

class nlm_lockargs1_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[
#           ('cookie',netobj),                                 # 
            ('block',ctypes.c_uint),                           # boolean, Flag to indicate blocking behaviour.
            ('exclusive',ctypes.c_uint),                       # boolean, If exclusive access is desired.
#           ('alock',nlm_lock_t),                              # The actual lock data (see above)
#           ('reclaim',ctypes.c_uint),                         # boolean, used for recovering locks
#           ('state',ctypes.c_uint),                           # specify local NSM state
           ]
assert ctypes.sizeof(nlm_lockargs1_t)==8,ctypes.sizeof(nlm_lockargs1_t)
class un_nlm_lockargs1_t(ctypes.Union):
  _pack_=1
  _fields_=[('nlm_lockargs1',nlm_lockargs1_t),
            ('bytes',ctypes.c_ubyte * 8)]

class nlm_lockargs2_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[
#           ('cookie',netobj),                                 # 
#           ('block',ctypes.c_uint),                           # boolean, Flag to indicate blocking behaviour.
#           ('exclusive',ctypes.c_uint),                       # boolean, If exclusive access is desired.
#           ('alock',nlm_lock_t),                              # The actual lock data (see above)
            ('reclaim',ctypes.c_uint),                         # boolean, used for recovering locks
            ('state',ctypes.c_uint),                           # specify local NSM state
           ]
assert ctypes.sizeof(nlm_lockargs2_t)==8,ctypes.sizeof(nlm_lockargs2_t)
class un_nlm_lockargs2_t(ctypes.Union):
  _pack_=1
  _fields_=[('nlm_lockargs2',nlm_lockargs2_t),
            ('bytes',ctypes.c_ubyte * 8)]

# defines the information needed to cancel an outstanding lock request
class nlm_cancargs_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[
#           ('cookie',netobj),                                 # 
            ('block',ctypes.c_uint),                           # boolean
            ('exclusive',ctypes.c_uint),                       # boolean
#           ('alock',nlm_lock_t),                              # 
           ]
assert ctypes.sizeof(nlm_cancargs_t)==8,ctypes.sizeof(nlm_cancargs_t)
class un_nlm_cancargs_t(ctypes.Union):
  _pack_=1
  _fields_=[('nlm_cancargs',nlm_cancargs_t),
            ('bytes',ctypes.c_ubyte * 8)]
# the information needed to test a lock
class nlm_testargs_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[
#           ('cookie',netobj),                                 # 
            ('exclusive',ctypes.c_uint),                       # boolean
#           ('alock',nlm_lock_t),                              # 
           ]
assert ctypes.sizeof(nlm_testargs_t)==4,ctypes.sizeof(nlm_testargs_t)
class un_nlm_testargs_t(ctypes.Union):
  _pack_=1
  _fields_=[('nlm_testargs',nlm_testargs_t),
            ('bytes',ctypes.c_ubyte * 4)]

# the information needed to remove a previously established lock.
#class nlm_unlockargs(ctypes.BigEndianStructure):
#  _pack_=1
#  _fields_=[('cookie',netobj),                                 # 
#            ('alock',nlm_lock_t),                              # 
#           ]
#assert ctypes.sizeof(nlm_unlockargs)==0,ctypes.sizeof(nlm_unlockargs)
#class un_nlm_unlockargs(ctypes.Union):
#  _pack_=1
#  _fields_=[('nlm_unlockar',nlm_unlockargs),
#            ('bytes',ctypes.c_ubyte * 0)]

# defines the legal sharing mode
FSH_MODE_num=dict(
  fsm_DN                                   = 0,                   # deny none
  fsm_DR                                   = 1,                   # deny read
  fsm_DW                                   = 2,                   # deny write
  fsm_DRW                                  = 3,                   # deny read/write
)
# fsh_access defines the legal file access modes
FSH_ACCESS_num=dict(
  fsa_NONE                                 = 0,                   # for completeness
  fsa_R                                    = 1,                   # read-only
  fsa_W                                    = 2,                   # write-only
  fsa_RW                                   = 3,                   # read/write
)
# the information needed to uniquely specify a share operation
class nlm_share_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[
#           ('caller_name',ctypes.c_ubyte * LM_MAXSTRLEN)      # host
#           ('fh',netobj),                                     # file
#           ('oh',netobj),                                     # owner
            ('mode',ctypes.c_uint),                            # fsh_mode
            ('access',ctypes.c_uint),                          # fsh_access
           ]
assert ctypes.sizeof(nlm_share_t)==8,ctypes.sizeof(nlm_share_t)
class un_nlm_share_t(ctypes.Union):
  _pack_=1
  _fields_=[('nlm_share',nlm_share_t),
            ('bytes',ctypes.c_ubyte * 8)]
# This structure encodes the arguments for an NLM_SHARE or NLM_UNSHARE procedure call
class nlm_shareargs_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[
#           ('cookie',netobj),                                 # 
#           ('share',nlm_share_t),                             # actual share data
            ('reclaim',ctypes.c_uint),                         # boolean, used for recovering shares
           ]
assert ctypes.sizeof(nlm_shareargs_t)==4,ctypes.sizeof(nlm_shareargs_t)
class un_nlm_shareargs_t(ctypes.Union):
  _pack_=1
  _fields_=[('nlm_shareargs',nlm_shareargs_t),
            ('bytes',ctypes.c_ubyte * 4)]

# This structure encodes the results of an NLM_SHARE or NLM_UNSHARE procedure call
class nlm_shareres_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[
#           ('cookie',netobj),                                 # ignore
            ('state',nlm_stat_t),                               # 
            ('sequence',ctypes.c_uint),                        # ignore
           ]
assert ctypes.sizeof(nlm_shareres_t)==8,ctypes.sizeof(nlm_shareres_t)
class un_nlm_shareres_t(ctypes.Union):
  _pack_=1
  _fields_=[('nlm_shareres',nlm_shareres_t),
            ('bytes',ctypes.c_ubyte * 8)]

# This structure encodes the arguments for releasing all locks and shares a client holds
class nlm_notify_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[
#           ('name', ctypes.c_ubyte * LM_MAXNAMELEN),          #
            ('state',ctypes.c_ulong),                          # 
           ]
assert ctypes.sizeof(nlm_notify_t)==8,ctypes.sizeof(nlm_notify_t)
class un_nlm_notify_t(ctypes.Union):
  _pack_=1
  _fields_=[('nlm_notify',nlm_notify_t),
            ('bytes',ctypes.c_ubyte * 8)]
# nsm
SM_num=dict(
  SM_NULL                                  = 0,                   # do nothing
  SM_STAT                                  = 1,                   # see if the NSM agrees to monitor the given host
  SM_MON                                   = 2,                   # initiates the monitoring of the given host
  SM_UNMON                                 = 3,                   # stops monitoring the host
  SM_UNMON_ALL                             = 4,                   # stops monitoring all hosts
  SM_SIMU_CRASH                            = 5,                   # simulates a crash. The NSM releases all its current state information and reinitialises itself, incrementing its state varible.
  SM_NOTIFY                                = 6,                   # if a host has a state change, either a crash and reboot or the NSM has processed an SM_SIMU_CRASH call, the local NSM must notify each host on it notify list of the change in state.
)
SM_RES_num=dict(
  STAT_SUCC                                = 0,                   # NSM agrees to monitor.
  STAT_FAIL                                = 1,                   # NSM cannot monitor.
)
class sm_stat_res_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('res_stat',ctypes.c_uint),                        # 
            ('state',ctypes.c_uint),                           # 
           ]
assert ctypes.sizeof(sm_stat_res_t)==8,ctypes.sizeof(sm_stat_res_t)
class un_sm_stat_res_t(ctypes.Union):
  _pack_=1
  _fields_=[('sm_stat_res',sm_stat_res_t),
            ('bytes',ctypes.c_ubyte * 8)]
class sm_stat_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('state',ctypes.c_uint),                           # state number of NSM
           ]
assert ctypes.sizeof(sm_stat_t)==4,ctypes.sizeof(sm_stat_t)
class un_sm_stat_t(ctypes.Union):
  _pack_=1
  _fields_=[('sm_stat',sm_stat_t),
            ('bytes',ctypes.c_ubyte * 4)]
SM_MAXSTRLEN = 1024
class my_id_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[
#           ('my_name',ctypes.c_ubyte*SM_MAXSTRLEN),           # hostname
            ('my_prog',ctypes.c_uint),                         # RPC program number
            ('my_vers',ctypes.c_uint),                         # program version number
            ('my_proc',ctypes.c_uint),                         # procedure number
           ]
#assert ctypes.sizeof(my_id_t)==1036,ctypes.sizeof(my_id_t)
assert ctypes.sizeof(my_id_t)==12,ctypes.sizeof(my_id_t)
class un_my_id_t(ctypes.Union):
  _pack_=1
  _fields_=[('my_id',my_id_t),
#            ('bytes',ctypes.c_ubyte * 1036)]
            ('bytes',ctypes.c_ubyte * 12)]
class mon_id_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[
#           ('mon_name',ctypes.c_ubyte * SM_MAXSTRLEN),        # name of the host to be monitored
            ('my_id',my_id_t),                                 # 
           ]
#assert ctypes.sizeof(mon_id_t)==2060,ctypes.sizeof(mon_id_t)
assert ctypes.sizeof(mon_id_t)==12,ctypes.sizeof(mon_id_t)
class un_mon_id_t(ctypes.Union):
  _pack_=1
  _fields_=[('mon_id',mon_id_t),
#            ('bytes',ctypes.c_ubyte * 2060)]
            ('bytes',ctypes.c_ubyte * 12)]
class mon_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[
#           ('mon_id',mon_id_t),                               # 
            ('priv',ctypes.c_ubyte * 16),                      # private information
           ]
#assert ctypes.sizeof(mon_t)==2076,ctypes.sizeof(mon_t)
assert ctypes.sizeof(mon_t)==16,ctypes.sizeof(mon_t)
class un_mon_t(ctypes.Union):
  _pack_=1
  _fields_=[('mon',mon_t),
#            ('bytes',ctypes.c_ubyte * 2076)]
            ('bytes',ctypes.c_ubyte * 16)]
class stat_chge_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[
#           ('mon_name',ctypes.c_ubyte * 1024),                # 
            ('state',ctypes.c_uint),                           # 
           ]
#assert ctypes.sizeof(stat_chge_t)==1028,ctypes.sizeof(stat_chge_t)
assert ctypes.sizeof(stat_chge_t)==4,ctypes.sizeof(stat_chge_t)
class un_stat_chge_t(ctypes.Union):
  _pack_=1
  _fields_=[('stat_chge',stat_chge_t),
#            ('bytes',ctypes.c_ubyte * 1028)]
            ('bytes',ctypes.c_ubyte * 4)]

# port mapper
PMAPPROC_num=dict(
  PMAPPROC_NULL                            = 0,                   # do nothing
  PMAPPROC_SET                             = 1,                   # set mapping. The program passes its program number, version, protocol numer and the port on which it awaits service request.
  PMAPPROC_UNSET                           = 2,                   # unset mapping. When a program becomes unavailable, it should unregister itself with the port mapper program on the same machine
  PMAPPROC_GETPORT                         = 3,                   # get port. Given a program number, version, protocol numer, returns the port number on which the program is awaiting call request.
  PMAPPROC_DUMP                            = 4,                   # dump mapping. enumerates all entries in the port mapper's database
  PMAPPROC_CALLIT                          = 5,                   # allows a caller to call another procedure on the same machine without knowing the rpc's universal address
)
PMAP_PORT = 111    # port mapper port number
# A mapping of (program, version, protocol) to port number.
class mapping_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('prog',ctypes.c_uint),                            # 
            ('vers',ctypes.c_uint),                            # 
            ('prot',ctypes.c_uint),                            # 
            ('port',ctypes.c_uint),                            # 
           ]
assert ctypes.sizeof(mapping_t)==16,ctypes.sizeof(mapping_t)
class un_mapping_t(ctypes.Union):
  _pack_=1
  _fields_=[('mapping',mapping_t),
            ('bytes',ctypes.c_ubyte * 16)]
class bool_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('ret_val',ctypes.c_uint),                         # 
           ]
assert ctypes.sizeof(bool_t)==4,ctypes.sizeof(bool_t)
class un_bool_t(ctypes.Union):
  _pack_=1
  _fields_=[('bool',bool_t),
            ('bytes',ctypes.c_ubyte * 4)]
class port_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('number',ctypes.c_uint),                          # 
           ]
assert ctypes.sizeof(port_t)==4,ctypes.sizeof(port_t)
class un_port_t(ctypes.Union):
  _pack_=1
  _fields_=[('port',port_t),
            ('bytes',ctypes.c_ubyte * 4)]
# RPCBIND
RPCBPROC_num=dict(
  RPCBPROC_SET                             = 1,                   # set mapping. The program passes its program number, version, protocol numer and the port on which it awaits service request.
  RPCBPROC_UNSET                           = 2,                   # unset mapping. When a program becomes unavailable, it should unregister itself with the RPCBIND program on the same machine
  RPCBPROC_GETADDR                         = 3,                   # get universal address. Given a program number, version, network id, returns the universal address on which the program is awaiting call request.
  RPCBPROC_DUMP                            = 4,                   # dump mapping. enumerates all entries in the RPCBIND's database
  RPCBPROC_CALLIT                          = 5,                   # allows a caller to call another procedure on the same machine without knowing the rpc's universal address
  RPCBPROC_GETTIME                         = 6,                   # returns the local time in seconds since the midnight of the First day of January, 1970
  RPCBPROC_UADDR2TADDR                     = 7,                   # convert universal addresses to transport specific addresses 
  RPCBPROC_TADDR2UADDR                     = 8,                   # convert transport specific addresses to universal addresses
)

RPCB_PORT = 111
class rpcb_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('r_prog',ctypes.c_uint),                          # program number
            ('r_vers',ctypes.c_uint),                          # version number
#           ('r_netid',string),                                # network id
#           ('r_addr',string),                                 # universal address
#           ('r_owner',string),                                # owner of this service
           ]
assert ctypes.sizeof(rpcb_t)==8,ctypes.sizeof(rpcb_t)
class un_rpcb_t(ctypes.Union):
  _pack_=1
  _fields_=[('rpcb',rpcb_t),
            ('bytes',ctypes.c_ubyte * 8)]

class rpcb_rmtcallargs_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('prog',ctypes.c_uint),                            # program number
            ('vers',ctypes.c_uint),                            # version number
            ('proc',ctypes.c_uint),                            # procedure number
            ('argslen',ctypes.c_uint),                         # argument length
#           ('args',opaque_t),                                 # argument
           ]
assert ctypes.sizeof(rpcb_rmtcallargs_t)==16,ctypes.sizeof(rpcb_rmtcallargs_t)
class un_rpcb_rmtcallargs_t(ctypes.Union):
  _pack_=1
  _fields_=[('rpcb_rmtcallargs',rpcb_rmtcallargs_t),
            ('bytes',ctypes.c_ubyte * 16)]

class netbuf_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('maxlen',ctypes.c_uint),                          # 
#           ('buf',opaque_t),                                  # 
           ]
assert ctypes.sizeof(netbuf_t)==4,ctypes.sizeof(netbuf_t)
class un_netbuf_t(ctypes.Union):
  _pack_=1
  _fields_=[('netbuf',netbuf_t),
            ('bytes',ctypes.c_ubyte * 4)]

ctypes_format=(
ctypes.c_byte,
ctypes.c_ubyte,
ctypes.c_ubyte*2,
ctypes.c_ubyte*3,
ctypes.c_ubyte*4,
ctypes.c_ubyte*6,
ctypes.c_ubyte*8,
ctypes.c_ubyte*10,
ctypes.c_ubyte*12,
ctypes.c_ubyte*16,
ctypes.c_ubyte*20,
ctypes.c_ubyte*24,
ctypes.c_ubyte*28,
ctypes.c_short,
ctypes.c_ushort,
ctypes.c_int,
ctypes.c_uint,
ctypes.c_ulong,
ctypes.c_ulong*2,
ctypes.c_long,
ctypes.c_ulonglong,
ctypes.c_float,
ctypes.c_double,
ctypes.c_longdouble,
)

# nfsacl
NFSACLPROC2_num=dict(
  NFSACLPROC2_NULL                               = 0,                   #
  NFSACLPROC2_GETACL                             = 1,                   #
  NFSACLPROC2_SETACL                             = 2,                   #
  NFSACLPROC2_GETATTR                            = 3,                   #
  NFSACLPROC2_GETATTR_ALL                        = 4,                   #
  NFSACLPROC2_GETXATTRDIR                        = 5,                   #
)
NFSACLPROC3_num=dict(
  NFSACLPROC3_NULL                               = 0,                   #
  NFSACLPROC3_GETACL                             = 1,                   #
  NFSACLPROC3_SETACL                             = 2,                   #
  NFSACLPROC3_GETXATTRDIR                        = 3,                   #
)
class acl_mask_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[
            ('tbd',ctypes.c_uint,28),                                  #
            ('default_count',ctypes.c_uint,1),                         #
            ('default_entry',ctypes.c_uint,1),                         #
            ('count',ctypes.c_uint,1),                                 #
            ('entry',ctypes.c_uint,1),                                 #
           ]
assert ctypes.sizeof(acl_mask_t)==4,ctypes.sizeof(acl_mask_t)
class un_acl_mask_t(ctypes.Union):
  _pack_=1
  _fields_=[('acl_mask',acl_mask_t),
            ('bytes',ctypes.c_ubyte * 4)]
class acl_create_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[
            ('create',ctypes.c_uint),                                   #
           ]
assert ctypes.sizeof(acl_create_t)==4,ctypes.sizeof(acl_create_t)
class un_acl_create_t(ctypes.Union):
  _pack_=1
  _fields_=[('acl_create',acl_create_t),
            ('bytes',ctypes.c_ubyte * 4)]
class acl_count_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[
            ('count',ctypes.c_uint),                                   #
            ('entry',ctypes.c_uint),                                   #
            ('default_count',ctypes.c_uint),                           #
            ('default_entry',ctypes.c_uint),                           #
           ]
assert ctypes.sizeof(acl_count_t)==16,ctypes.sizeof(acl_count_t)
class un_acl_count_t(ctypes.Union):
  _pack_=1
  _fields_=[('acl_count',acl_count_t),
            ('bytes',ctypes.c_ubyte * 16)]

class mount_flavors_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('flavors',ctypes.c_uint),                          # flavors_num
           ]
assert ctypes.sizeof(mount_flavors_t)==4,ctypes.sizeof(mount_flavors_t)
class un_mount_flavors_t(ctypes.Union):
  _pack_=1
  _fields_=[('mount_flavors',mount_flavors_t),
            ('bytes',ctypes.c_ubyte * 4)]
class mount_flavor_t(ctypes.BigEndianStructure):
  _pack_=1
  _fields_=[('flavor',ctypes.c_uint),                          # flavor
           ]
assert ctypes.sizeof(mount_flavor_t)==4,ctypes.sizeof(mount_flavor_t)
class un_mount_flavor_t(ctypes.Union):
  _pack_=1
  _fields_=[('mount_flavor',mount_flavor_t),
            ('bytes',ctypes.c_ubyte * 4)]
def extract_fsid_from_file_handle(file_handle,endian="little",fsindex=3,debug=False):
  """
  """
  if endian=="little":
    if   fsindex==1:
      return struct.unpack('<Q',file_handle[:16].decode('hex'))[0]
    elif fsindex==2:
      return struct.unpack('<I',file_handle[40:48].decode('hex'))[0]
    elif fsindex==3:
      return struct.unpack('<I',file_handle[:8].decode('hex'))[0]
    else:
      return struct.unpack('<Q',file_handle[:16].decode('hex'))[0]
  else:
    if   fsindex==1:
      return struct.unpack('>Q',file_handle[:16].decode('hex'))[0]
    elif fsindex==2:
      return struct.unpack('>I',file_handle[40:48].decode('hex'))[0]
    elif fsindex==3:
      return struct.unpack('>I',file_handle[:8].decode('hex'))[0]
    else:
      return struct.unpack('>Q',file_handle[:16].decode('hex'))[0]
def longint_from_bytes(dbytes,byteorder='big', signed=False):
  if byteorder!='big':
    data=dbytes[::-1]
  else:
    data=dbytes[::]
  value=reduce(lambda x,y: x*256+y,data,0)
  if signed:
    if data[0] & 0x80:
      value = -(2**64-value)
  return value

