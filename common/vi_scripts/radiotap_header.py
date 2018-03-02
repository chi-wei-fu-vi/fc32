#!/usr/bin/env python2.7
import ctypes
class radiotap_present_t(ctypes.Structure):
  _pack=1
  _fields_=[
            ('tsft',ctypes.c_uint,1),                         # Specifies if the Time Synchronization Function Timer field is present
            ('flags',ctypes.c_uint,1),                        # Specifies if the channel flags field is present
            ('rate',ctypes.c_uint,1),                         # Specifies if the transmit/receive rate field is present
            ('channel',ctypes.c_uint,1),                      # Specifies if the transmit/receive frequency field is present
            ('fhss',ctypes.c_uint,1),                         # Specifies if the hop set and pattern is present for frequency hopping radios
            ('dbm_antsignal',ctypes.c_uint,1),                # Specifies if the antenna signal strength in dBm is present
            ('dbm_antnoise',ctypes.c_uint,1),                 # Specifies if the RF noise power at antenna field is present
            ('lock_quality',ctypes.c_uint,1),                 # Specifies if the signal quality field is present
            ('tx_attenuation',ctypes.c_uint,1),               # Specifies if the transmit power distance from max power field is present
            ('db_tx_attenuation',ctypes.c_uint,1),            # Specifies if the transmit power distance from max power (in dB) field is present
            ('dbm_tx_power',ctypes.c_uint,1),                 # Specifies if the transmit power (in dBm) field is present
            ('antenna',ctypes.c_uint,1),                      # Specifies if the antenna number field is present
            ('db_antsignal',ctypes.c_uint,1),                 # Specifies if the RF signal power at antenna in dB field is present
            ('db_antnoise',ctypes.c_uint,1),                  # Specifies if the RF signal power at antenna in dBm field is present
            ('rxflags',ctypes.c_uint,1),                      # Specifies if the RX flags field is present
            ('reserved_a',ctypes.c_uint,1),                   #
            ('reserved_a',ctypes.c_uint,1),                   #
            ('reserved_a',ctypes.c_uint,1),                   #
            ('fcs',ctypes.c_uint,1),                          # Specifies if the FCS field is present
            ('xchannel',ctypes.c_uint,1),                     # Specifies if the extended channel info field is present
            ('mcs',ctypes.c_uint,1),                          # Specifies if the HT field is present
            ('ampdu',ctypes.c_uint,1),                        # Specifies if the A-MPDU status field is present
            ('vht',ctypes.c_uint,1),                          # Specifies if the VHT field is present
            ('reserved_a',ctypes.c_uint,1),                   #
            ('reserved_a',ctypes.c_uint,1),                   #
            ('reserved_a',ctypes.c_uint,1),                   #
            ('reserved_a',ctypes.c_uint,1),                   #
            ('reserved_a',ctypes.c_uint,1),                   #
            ('reserved_a',ctypes.c_uint,1),                   #
            ('rtap_ns',ctypes.c_uint,1),                      # Specifies a reset to the radiotap namespace
            ('vendor_ns',ctypes.c_uint,1),                    # Specifies that the next bitmap is in a vendor namespace
            ('ext',ctypes.c_uint,1),                          # Specifies if there are any extensions to the header present
           ]
assert ctypes.sizeof(radiotap_present_t)==4,ctypes.sizeof(radiotap_present_t)
class un_radiotap_present_t(ctypes.Union):
  _pack=1
  _fields_=[('radiotap_present',radiotap_present_t),
            ('bytes',ctypes.c_ubyte * 4)]
class radiotap_hdr_t(ctypes.Structure):
  _pack=1
  _fields_=[
            ('version',ctypes.c_ubyte),                        # Version of radiotap header format
            ('pad',ctypes.c_ubyte),                            # Padding
            ('length',ctypes.c_ushort),                        # Length of header including version,  pad,  length and data fields
            ('present',radiotap_present_t),                    # Bitmask indicating which fields are present
           ]
assert ctypes.sizeof(radiotap_hdr_t)==8,ctypes.sizeof(radiotap_hdr_t)
class un_radiotap_hdr_t(ctypes.Union):
  _pack=1
  _fields_=[('radiotap_hdr',radiotap_hdr_t),
            ('bytes',ctypes.c_ubyte * 8)]
# Value in us of the MAC's 64-bit 802.11 Time Synchronization Function timer when the first bit of the MPDU arrived at the MAC.
class present_tsft_t(ctypes.Structure):
  _pack=1
  _fields_=[
            ('tsft',ctypes.c_ulong),                         # Specifies if the Time Synchronization Function Timer field is present
           ]
assert ctypes.sizeof(present_tsft_t)==8,ctypes.sizeof(present_tsft_t)
class un_present_tsft_t(ctypes.Union):
  _pack=1
  _fields_=[('present_tsft',present_tsft_t),
            ('bytes',ctypes.c_ubyte * 8)]

class present_flags_t(ctypes.Structure):
  _pack=1
  _fields_=[
            ('cfp',ctypes.c_ubyte,1),                          # Sent/Received during CFP
            ('preamble',ctypes.c_ubyte,1),                     # Sent/Received with short preamble
            ('wep',ctypes.c_ubyte,1),                          # Sent/Received with WEP encryption
            ('frag',ctypes.c_ubyte,1),                         # Sent/Received with fragmentation
            ('fcs',ctypes.c_ubyte,1),                          # Frame includes FCS at end
            ('datapad',ctypes.c_ubyte,1),                      # Frame has padding between 802.11 header and payload
            ('badfcs',ctypes.c_ubyte,1),                       # Frame received with bad FCS
            ('shortgi',ctypes.c_ubyte,1),                      # Frame Sent/Received with HT short Guard Interval
           ]
assert ctypes.sizeof(present_flags_t)==1,ctypes.sizeof(present_flags_t)
class un_present_flags_t(ctypes.Union):
  _pack=1
  _fields_=[('present_flags',present_flags_t),
            ('bytes',ctypes.c_ubyte * 1)]
class present_rate_t(ctypes.Structure):
  _pack=1
  _fields_=[
            ('data_rate',ctypes.c_ubyte),                      # Data Rate in 500Kbps
           ]
assert ctypes.sizeof(present_rate_t)==1,ctypes.sizeof(present_rate_t)
class un_present_rate_t(ctypes.Union):
  _pack=1
  _fields_=[('present_rate',present_rate_t),
            ('bytes',ctypes.c_ubyte * 1)]

class radiotap_channel_flags_t(ctypes.Structure):
  _pack=1
  _fields_=[
            ('reserved_a',ctypes.c_ushort,4),                   #
            ('turbo',ctypes.c_ushort,1),                        # Channel Flags Turbo
            ('cck',ctypes.c_ushort,1),                          # Channel Flags Complementary Code Keying (CCK) Modulation
            ('ofdm',ctypes.c_ushort,1),                         # Channel Flags Orthogonal Frequency-Division Multiplexing (OFDM)
            ('2ghz',ctypes.c_ushort,1),                         # Channel Flags 2 GHz spectrum
            ('5ghz',ctypes.c_ushort,1),                         # Channel Flags 5 GHz spectrum
            ('passive',ctypes.c_ushort,1),                      # Channel Flags Passive
            ('dynamic',ctypes.c_ushort,1),                      # Channel Flags Dynamic CCK-OFDM Channel
            ('gfsk',ctypes.c_ushort,1),                         # Channel Flags Gaussian Frequency Shift Keying (GFSK) Modulation
            ('reserved_b',ctypes.c_ushort,4),                   #
           ]
assert ctypes.sizeof(radiotap_channel_flags_t)==2,ctypes.sizeof(radiotap_channel_flags_t)
class un_radiotap_channel_flags_t(ctypes.Union):
  _pack=1
  _fields_=[('radiotap_channel_flags',radiotap_channel_flags_t),
            ('bytes',ctypes.c_ubyte * 2)]
class present_channel_t(ctypes.Structure):
  _pack=1
  _fields_=[
            ('frequency',ctypes.c_ushort),                      # transmit/receive frequency
            ('flags',radiotap_channel_flags_t),                 # channel type
           ]
assert ctypes.sizeof(present_channel_t)==4,ctypes.sizeof(present_channel_t)
class un_present_channel_t(ctypes.Union):
  _pack=1
  _fields_=[('present_channel',present_channel_t),
            ('bytes',ctypes.c_ubyte * 4)]

PHDR_802_11_PHY_num=dict(
  PHDR_802_11_PHY_UNKNOWN   = 0,                                # PHY not known 
  PHDR_802_11_PHY_11_FHSS   = 1,                                # 802.11 FHSS 
  PHDR_802_11_PHY_11_IR     = 2,                                # 802.11 IR 
  PHDR_802_11_PHY_11_DSSS   = 3,                                # 802.11 DSSS 
  PHDR_802_11_PHY_11B       = 4,                                # 802.11b 
  PHDR_802_11_PHY_11A       = 5,                                # 802.11a 
  PHDR_802_11_PHY_11G       = 6,                                # 802.11g 
  PHDR_802_11_PHY_11N       = 7,                                # 802.11n 
  PHDR_802_11_PHY_11AC      = 8,                                # 802.11ac 
)

class present_fhss_t(ctypes.Structure):
  _pack=1
  _fields_=[
            ('hopset',ctypes.c_ubyte),                         # Frequency Hopping Spread Spectrum hopset
            ('pattern',ctypes.c_ubyte),                        # Frequency Hopping Spread Spectrum hop pattern
           ]
assert ctypes.sizeof(present_fhss_t)==2,ctypes.sizeof(present_fhss_t)
class un_present_fhss_t(ctypes.Union):
  _pack=1
  _fields_=[('present_fhss',present_fhss_t),
            ('bytes',ctypes.c_ubyte * 2)]

class present_dbm_antsignal_t(ctypes.Structure):
  _pack=1
  _fields_=[
            ('dbm_antsignal',ctypes.c_byte),                   # RF signal power at the antenna. This field contains a single signed 8-bit value, which indicates the RF signal power at the antenna, in decibels difference from 1mW
           ]
assert ctypes.sizeof(present_dbm_antsignal_t)==1,ctypes.sizeof(present_dbm_antsignal_t)
class un_present_dbm_antsignal_t(ctypes.Union):
  _pack=1
  _fields_=[('present_dbm_antsignal',present_dbm_antsignal_t),
            ('bytes',ctypes.c_ubyte * 1)]

class present_dbm_antnoise_t(ctypes.Structure):
  _pack=1
  _fields_=[
            ('dbm_antnoise',ctypes.c_byte),                    # RF signal power at the antenna. This field contains a single signed 8-bit value, which indicates the RF signal power at the antenna, in decibels difference from 1mW
           ]
assert ctypes.sizeof(present_dbm_antnoise_t)==1,ctypes.sizeof(present_dbm_antnoise_t)
class un_present_dbm_antnoise_t(ctypes.Union):
  _pack=1
  _fields_=[('present_dbm_antnoise',present_dbm_antnoise_t),
            ('bytes',ctypes.c_ubyte * 1)]

class present_lock_quality_t(ctypes.Structure):
  _pack=1
  _fields_=[
            ('quality',ctypes.c_ushort),                      # Quality of Barker code lock. Unitless. Monotonically nondecreasing with "better" lock strength. Called "Signal Quality" in datasheets
           ]
assert ctypes.sizeof(present_lock_quality_t)==2,ctypes.sizeof(present_lock_quality_t)
class un_present_lock_quality_t(ctypes.Union):
  _pack=1
  _fields_=[('present_lock_quality',present_lock_quality_t),
            ('bytes',ctypes.c_ubyte * 2)]

class present_tx_attenuation_t(ctypes.Structure):
  _pack=1
  _fields_=[
            ('tx_attenuation',ctypes.c_ushort),               # Transmit power expressed as unitless distance from max power set at factory calibration. 0 is max power. Monotonically nondecreasing with lower power levels.
           ]
assert ctypes.sizeof(present_tx_attenuation_t)==2,ctypes.sizeof(present_tx_attenuation_t)
class un_present_tx_attenuation_t(ctypes.Union):
  _pack=1
  _fields_=[('present_tx_attenuation',present_tx_attenuation_t),
            ('bytes',ctypes.c_ubyte * 2)]

class present_db_tx_attenuation_t(ctypes.Structure):
  _pack=1
  _fields_=[
            ('db_tx_attenuation',ctypes.c_ushort),            # Transmit power expressed as decibel distance from max power set at factory calibration. 0 is max power. Monotonically nondecreasing with lower power levels.
           ]
assert ctypes.sizeof(present_db_tx_attenuation_t)==2,ctypes.sizeof(present_db_tx_attenuation_t)
class un_present_db_tx_attenuation_t(ctypes.Union):
  _pack=1
  _fields_=[('present_db_tx_attenuation',present_db_tx_attenuation_t),
            ('bytes',ctypes.c_ubyte * 2)]

class present_dbm_tx_power_t(ctypes.Structure):
  _pack=1
  _fields_=[
            ('dbm_tx_power',ctypes.c_byte),                   # Transmit power expressed as dBm (decibels from a 1 milliwatt reference). This is the absolute power level measured at the antenna port
           ]
assert ctypes.sizeof(present_dbm_tx_power_t)==1,ctypes.sizeof(present_dbm_tx_power_t)
class un_present_dbm_tx_power_t(ctypes.Union):
  _pack=1
  _fields_=[('present_dbm_tx_power',present_dbm_tx_power_t),
            ('bytes',ctypes.c_ubyte * 1)]

class present_antenna_t(ctypes.Structure):
  _pack=1
  _fields_=[
            ('antenna',ctypes.c_ubyte),                      # Unitless indication of the Rx/Tx antenna for this packet. The first antenna is antenna 0
           ]
assert ctypes.sizeof(present_antenna_t)==1,ctypes.sizeof(present_antenna_t)
class un_present_antenna_t(ctypes.Union):
  _pack=1
  _fields_=[('present_antenna',present_antenna_t),
            ('bytes',ctypes.c_ubyte * 1)]

class present_db_antsignal_t(ctypes.Structure):
  _pack=1
  _fields_=[
            ('db_antsignal',ctypes.c_ubyte),                 # RF signal power at the antenna, decibel difference from an arbitrary, fixed reference
           ]
assert ctypes.sizeof(present_db_antsignal_t)==1,ctypes.sizeof(present_db_antsignal_t)
class un_present_db_antsignal_t(ctypes.Union):
  _pack=1
  _fields_=[('present_db_antsignal',present_db_antsignal_t),
            ('bytes',ctypes.c_ubyte * 1)]

class present_db_antnoise_t(ctypes.Structure):
  _pack=1
  _fields_=[
            ('db_antnoise',ctypes.c_ubyte),                  # RF noise power at the antenna, decibel difference from an arbitrary, fixed referenc
           ]
assert ctypes.sizeof(present_db_antnoise_t)==1,ctypes.sizeof(present_db_antnoise_t)
class un_present_db_antnoise_t(ctypes.Union):
  _pack=1
  _fields_=[('present_db_antnoise',present_db_antnoise_t),
            ('bytes',ctypes.c_ubyte * 1)]

class radiotap_rxflags_t(ctypes.Structure):
  _pack=1
  _fields_=[
            ('reserved_a',ctypes.c_ushort,1),                   #
            ('badplcp',ctypes.c_ushort,1),                      # Frame with bad PLCP CRC
            ('reserved_b',ctypes.c_ushort,14),                  #
           ]
assert ctypes.sizeof(radiotap_rxflags_t)==2,ctypes.sizeof(radiotap_rxflags_t)
class un_radiotap_rxflags_t(ctypes.Union):
  _pack=1
  _fields_=[('radiotap_rxflags',radiotap_rxflags_t),
            ('bytes',ctypes.c_ubyte * 1)]
class present_rxflags_t(ctypes.Structure):
  _pack=1
  _fields_=[
            ('rxflags',radiotap_rxflags_t),                    # RX flags
           ]
assert ctypes.sizeof(present_rxflags_t)==2,ctypes.sizeof(present_rxflags_t)
class un_present_rxflags_t(ctypes.Union):
  _pack=1
  _fields_=[('present_rxflags',present_rxflags_t),
            ('bytes',ctypes.c_ubyte * 2)]

class present_fcs_t(ctypes.Structure):
  _pack=1
  _fields_=[
            ('fcs',ctypes.c_uint),                            # This field should not be added since FCS-at-end is more natural.
           ]
assert ctypes.sizeof(present_fcs_t)==4,ctypes.sizeof(present_fcs_t)
class un_present_fcs_t(ctypes.Union):
  _pack=1
  _fields_=[('present_fcs',present_fcs_t),
            ('bytes',ctypes.c_ubyte * 4)]
# This field is parsed by wireshark, but only partially (it ignores maxpower).
# Origin of the field is unknown. Used by FreeBSD and OS X.
# Channel numbers are problematic -- using the channel's center frequency would be much better.
# The flags define some things that can be inferred (2 vs. 5 GHz).
# Things like the "Channel Type Passive" don't make sense per packet.
# As used, this field conflates channel properties (which need not be stored per packet but are more or less fixed)
# with packet properties (like the modulation).
class radiotap_xchannel_flags_t(ctypes.Structure):
  _pack=1
  _fields_=[
            ('reserved_a',ctypes.c_uint,4),                   #

            ('turbo',ctypes.c_uint,1),                        # Channel Flags Turbo
            ('cck',ctypes.c_uint,1),                          # Channel Flags Complementary Code Keying (CCK) Modulation
            ('ofdm',ctypes.c_uint,1),                         # Channel Flags Orthogonal Frequency-Division Multiplexing (OFDM)
            ('2ghz',ctypes.c_uint,1),                         # Channel Flags 2 GHz spectrum

            ('5ghz',ctypes.c_uint,1),                         # Channel Flags 5 GHz spectrum
            ('dynamic',ctypes.c_uint,1),                      # Channel Flags Dynamic CCK-OFDM Channel
            ('passive',ctypes.c_uint,1),                      # Channel Flags Passive
            ('gfsk',ctypes.c_uint,1),                         # Channel Flags Gaussian Frequency Shift Keying (GFSK) Modulation

            ('gsm',ctypes.c_uint,1),                          # Channel Flags GSM
            ('sturbo',ctypes.c_uint,1),                       # Channel Flags Status Turbo
            ('half',ctypes.c_uint,1),                         # Channel Flags Half Rate
            ('quarter',ctypes.c_uint,1),                      # Channel Flags Quarter Rate

            ('ht20',ctypes.c_uint,1),                         # Channel Flags HT/20
            ('ht40u',ctypes.c_uint,1),                        # Channel Flags HT/40+
            ('ht40d',ctypes.c_uint,1),                        # Channel Flags HT/40-
            ('reserved_b',ctypes.c_uint,13),                   #
           ]
assert ctypes.sizeof(radiotap_xchannel_flags_t)==4,ctypes.sizeof(radiotap_xchannel_flags_t)
class un_radiotap_xchannel_flags_t(ctypes.Union):
  _pack=1
  _fields_=[('radiotap_xchannel_flags',radiotap_xchannel_flags_t),
            ('bytes',ctypes.c_ubyte * 4)]
class present_xchannel_t(ctypes.Structure):
  _pack=1
  _fields_=[
            ('flags',radiotap_xchannel_flags_t),                # Channel flags
            ('freq',ctypes.c_ushort),                           # Channel frequency
            ('channel',ctypes.c_ubyte),                         # Channel number
            ('maxpower',ctypes.c_ubyte),                        # Max transmit power
           ]
assert ctypes.sizeof(present_xchannel_t)==8,ctypes.sizeof(present_xchannel_t)
class un_present_xchannel_t(ctypes.Union):
  _pack=1
  _fields_=[('present_xchannel',present_xchannel_t),
            ('bytes',ctypes.c_ubyte * 8)]

class radiotap_mcs_known_t(ctypes.Structure):
  _pack=1
  _fields_=[
            ('have_bw',ctypes.c_ubyte,1),                      # Bandwidth
            ('have_index',ctypes.c_ubyte,1),                   # MCS index information present
            ('have_gi',ctypes.c_ubyte,1),                      # Sent/Received guard interval information present
            ('have_format',ctypes.c_ubyte,1),                  # Format information present
            ('have_fec',ctypes.c_ubyte,1),                     # Forward error correction type information present
            ('have_stbc',ctypes.c_ubyte,1),                    # Space Time Block Coding streams information present
            ('have_ness',ctypes.c_ubyte,1),                    # Number of extension spatial streams information present
            ('ness_bit1',ctypes.c_ubyte,1),                    # Bit 0 of number of extension spatial streams information
           ]
assert ctypes.sizeof(radiotap_mcs_known_t)==1,ctypes.sizeof(radiotap_mcs_known_t)
class un_radiotap_mcs_known_t(ctypes.Union):
  _pack=1
  _fields_=[('radiotap_mcs_known',radiotap_mcs_known_t),
            ('bytes',ctypes.c_ubyte * 1)]

class radiotap_mcs_flags_t(ctypes.Structure):
  _pack=1
  _fields_=[
            ('bw',ctypes.c_ubyte,2),                           # Bandwidth - 0: 20, 1: 40, 2: 20L, 3: 20U
            ('gi',ctypes.c_ubyte,1),                           # Sent/Received guard interval - 0: long GI, 1: short GI
            ('format',ctypes.c_ubyte,1),                       # HT format - 0: mixed, 1: greenfield
            ('fec',ctypes.c_ubyte,1),                          # Forward error correction type 0: BCC, 1: LDPC
            ('stbc',ctypes.c_ubyte,2),                         # Number of Space Time Block Code streams
            ('ness_bit1',ctypes.c_ubyte,1),                    # Bit 0 of number of extension spatial streams information
           ]
assert ctypes.sizeof(radiotap_mcs_flags_t)==1,ctypes.sizeof(radiotap_mcs_flags_t)
class un_radiotap_mcs_flags_t(ctypes.Union):
  _pack=1
  _fields_=[('radiotap_mcs_flags',radiotap_mcs_flags_t),
            ('bytes',ctypes.c_ubyte * 1)]


class present_mcs_t(ctypes.Structure):
  _pack=1
  _fields_=[
            ('known',radiotap_mcs_known_t),                     # MCS known
            ('flags',radiotap_mcs_flags_t),                     # MCS flags
            ('index',ctypes.c_ubyte),                           # MCS index
           ]
assert ctypes.sizeof(present_mcs_t)==3,ctypes.sizeof(present_mcs_t)
class un_present_mcs_t(ctypes.Union):
  _pack=1
  _fields_=[('present_mcs',present_mcs_t),
            ('bytes',ctypes.c_ubyte * 3)]
# The reference number is generated by the capture device and is the same across each subframe of an A-MPDU.
# Since the capture device might be capable of capturing multiple channels or data from multiple (concurrent)
# captures could be merged, the reference number is not guaranteed to be unique across different channels.
# As a result, applications should use the channel information together with the reference number to identify
# the subframes belonging to the same A-MPDU.
class radiotap_ampdu_flags_t(ctypes.Structure):
  _pack=1
  _fields_=[
            ('report_zerolen',ctypes.c_ushort,1),               # Driver reports 0-length subframes in this A-MPDU
            ('is_zerolen',ctypes.c_ushort,1),                   # This is a 0-length subframe
            ('lastknown',ctypes.c_ushort,1),                    # Last subframe of this A-MPDU is known
            ('last',ctypes.c_ushort,1),                         # This is the last subframe of this A-MPDU
            ('delim_crc_error',ctypes.c_ushort,1),              # Delimiter CRC error on this subframe
            ('delim_crc_value',ctypes.c_ushort,1),              # delimiter CRC value known: the delimiter CRC value field is valid
            ('reserved_a',ctypes.c_ushort,10),                  #
           ]
assert ctypes.sizeof(radiotap_ampdu_flags_t)==2,ctypes.sizeof(radiotap_ampdu_flags_t)
class un_radiotap_ampdu_flags_t(ctypes.Union):
  _pack=1
  _fields_=[('radiotap_ampdu_flags',radiotap_ampdu_flags_t),
            ('bytes',ctypes.c_ubyte * 2)]
class present_ampdu_t(ctypes.Structure):
  _pack=1
  _fields_=[
            ('reference',ctypes.c_uint),                       # A-MPDU reference number
            ('flags',radiotap_ampdu_flags_t),                  # A-MPDU status flags
            ('delim_crc',ctypes.c_ubyte),                      # A-MPDU subframe delimiter CRC
            ('reserved_a',ctypes.c_ubyte),                     #
           ]
assert ctypes.sizeof(present_ampdu_t)==8,ctypes.sizeof(present_ampdu_t)
class un_present_ampdu_t(ctypes.Union):
  _pack=1
  _fields_=[('present_ampdu',present_ampdu_t),
            ('bytes',ctypes.c_ubyte * 8)]

class radiotap_vht_known_t(ctypes.Structure):
  _pack=1
  _fields_=[
            ('have_stbc',ctypes.c_ushort,1),                    # Space Time Block Coding information present
            ('have_txop_ps',ctypes.c_ushort,1),                 # TXOP_PS_NOT_ALLOWED information present
            ('have_gi',ctypes.c_ushort,1),                      # Short/Long guard interval information present
            ('have_sgi_nsym_da',ctypes.c_ushort,1),             # Short guard interval Nsym disambiguation information present
            ('ldpc_extra',ctypes.c_ushort,1),                   # LDPC extra OFDM symbol
            ('have_beamformed',ctypes.c_ushort,1),              # Beamformed
            ('bw',ctypes.c_ushort,1),                           # Bandwidth
            ('gid',ctypes.c_ushort,1),                          # Group Id
            ('paid',ctypes.c_ushort,1),                         # Partial AID
            ('reserved_a',ctypes.c_ushort,7),                   #
           ]
assert ctypes.sizeof(radiotap_vht_known_t)==2,ctypes.sizeof(radiotap_vht_known_t)
class un_radiotap_vht_known_t(ctypes.Union):
  _pack=1
  _fields_=[('radiotap_vht_known',radiotap_vht_known_t),
            ('bytes',ctypes.c_ubyte * 2)]
class radiotap_vht_flags_t(ctypes.Structure):
  _pack=1
  _fields_=[
            ('stbc',ctypes.c_ubyte,1),                        # Space Time Block Coding flag 0: no spatial streams of any user has STBC
                                                               #                              1: all spatial streams of all users have STBC
            ('txop_ps',ctypes.c_ubyte,1),                     # Flag indicating whether STAs may doze during TXOP
                                                               # 0: STAs may doze during TXOP.
                                                               # 1: STAs may not doze during TXOP or transmitter is non-AP.
            ('gi',ctypes.c_ubyte,1),                          # Short/Long guard interval 0: long GI 1: Short GI
            ('sgi_nsym_da',ctypes.c_ubyte,1),                 # Short Guard Interval Nsym disambiguation 0: NSYM mod 10 != 9 or short GI not used.
                                                               # 1: NSYM mod 10 =9
            ('ldpc_extra',ctypes.c_ubyte,1),                  # LDPC extra OFDM symbol one or more users are using LDPC and the encoding process resulted in extra OFDM symbol(s)
            ('beamformed',ctypes.c_ubyte,1),                  # Beamformed Valid for SU PPDUs only
            ('reserved_a',ctypes.c_ubyte,2),                 #
           ]
assert ctypes.sizeof(radiotap_vht_flags_t)==1,ctypes.sizeof(radiotap_vht_flags_t)
class un_radiotap_vht_flags_t(ctypes.Union):
  _pack=1
  _fields_=[('radiotap_vht_flags',radiotap_vht_flags_t),
            ('bytes',ctypes.c_ubyte * 1)]
class radiotap_vht_bw_t(ctypes.Structure):
  _pack=1
  _fields_=[
            ('bw',ctypes.c_ubyte,5),                         # Space Time Block Coding flag 0: no spatial streams of any user has STBC
            ('reserved_a',ctypes.c_ubyte,3),                 #
           ]
assert ctypes.sizeof(radiotap_vht_bw_t)==1,ctypes.sizeof(radiotap_vht_bw_t)
class un_radiotap_vht_bw_t(ctypes.Union):
  _pack=1
  _fields_=[('radiotap_vht_bw',radiotap_vht_bw_t),
            ('bytes',ctypes.c_ubyte * 1)]
class radiotap_vht_nss_t(ctypes.Structure):
  _pack=1
  _fields_=[
            ('nss',ctypes.c_ubyte,4),                            # Number of spatial streams, range 1-8
            ('mcs',ctypes.c_ubyte,4),                            # MCS rate index, range 0-9
           ]
assert ctypes.sizeof(radiotap_vht_nss_t)==1,ctypes.sizeof(radiotap_vht_nss_t)
class un_radiotap_vht_nss_t(ctypes.Union):
  _pack=1
  _fields_=[('radiotap_vht_nss',radiotap_vht_nss_t),
            ('bytes',ctypes.c_ubyte * 1)]
class present_vht_t(ctypes.Structure):
  _pack=1
  _fields_=[
            ('known',radiotap_vht_known_t),                    # Bit mask indicating what VHT information is present
            ('flags',radiotap_vht_flags_t),                    # flags
            ('bandwidth',radiotap_vht_bw_t),                   # bandwidth
            ('mcs_nss',radiotap_vht_nss_t * 4),                # NSS
            ('coding',ctypes.c_ubyte),                         # group id
            ('group_id',ctypes.c_ubyte),                       # the group ID can be used to differentiate between SU PPDUs (group ID is 0 or 63) and MU PPDUs (group ID is 1 through 62).
            ('partial_aid',ctypes.c_ushort),                   # The partial_aid field contains the partial AID. Only applicable to SU PPDUs
           ]
assert ctypes.sizeof(present_vht_t)==12,ctypes.sizeof(present_vht_t)
class un_present_vht_t(ctypes.Union):
  _pack=1
  _fields_=[('present_vht',present_vht_t),
            ('bytes',ctypes.c_ubyte * 12)]

#class present_rtap_ns_t(ctypes.Structure):
#  _pack=1
#  _fields_=[
#           ]
#assert ctypes.sizeof(present_rtap_ns_t)==4,ctypes.sizeof(present_rtap_ns_t)
#class un_present_rtap_ns_t(ctypes.Union):
#  _pack=1
#  _fields_=[('present_rtap_ns',present_rtap_ns_t),
#            ('bytes',ctypes.c_ubyte * 4)]

class present_vendor_ns_t(ctypes.Structure):
  _pack=1
  _fields_=[
            ('vendor_oui',ctypes.c_ubyte*3),                   # Vendor OUI
            ('vendor_subns',ctypes.c_ubyte),                   # Vendor-specified sub namespace
            ('vendor_data_len',ctypes.c_ushort),               # Length of vendor-specified data
           ]
assert ctypes.sizeof(present_vendor_ns_t)==6,ctypes.sizeof(present_vendor_ns_t)
class un_present_vendor_ns_t(ctypes.Union):
  _pack=1
  _fields_=[('present_vendor_ns',present_vendor_ns_t),
            ('bytes',ctypes.c_ubyte * 6)]

#class present_ext_t(ctypes.Structure):
#  _pack=1
#  _fields_=[
#           ]
#assert ctypes.sizeof(present_ext_t)==4,ctypes.sizeof(present_ext_t)
#class un_present_ext_t(ctypes.Union):
#  _pack=1
#  _fields_=[('present_ext',present_ext_t),
#            ('bytes',ctypes.c_ubyte * 4)]


