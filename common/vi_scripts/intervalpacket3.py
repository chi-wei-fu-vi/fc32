#!/bin/env python2
import struct
class intervalpacket3:
  def __init__(self):
    """
    """
    self.packetType = 4
    self.timestamp = 212500000
    # IntervalStats 
    self.intervalStatsType=2
    self.link=0
    self.channel=0
    # IntervalStats3
    self.pcsLossOfSync=0
    self.fecCorrectionCount=0
    self.lengthErrors=0
    self.crcErrors=0
    self.codeViolations=0
    self.linkUp=0
    self.badEof=0
    self.linkReset=0
    self.nosOrOls=0
  def extract(self,bin):
    """
    """
    self.packetType=struct.unpack('B',bin[0])[0]
    self.timestamp =int("".join(map(lambda x: '%02x'%x,struct.unpack('7B',bin[1:8]))[::-1]),16)

    self.pcsLossOfSync, \
    self.fecCorrectionCount  \
    =struct.unpack('<2I',bin[8:16])
    self.lengthErrors, \
    self.crcErrors, \
    self.codeViolations, \
    self.linkUp, \
    self.badEof, \
    self.linkReset, \
    self.nosOrOls  \
    =struct.unpack('<7I',bin[24:52])
    type=struct.unpack('<H',bin[-2:])[0]
    #print '{0:016b}'.format(type)
    self.intervalStatsType=type & 0x7
    self.channel=(type>>12) & 0x1
    self.link=(type>>8) & 0xf

  def puts(self):
    """
    """
    print """
    self.packetType = %d
    self.timestamp = %d
    
    self.intervalStatsType = %d
    self.link = %d
    self.channel = %d
   
    self.pcsLossOfSync = %d
    self.fecCorrectionCount = %d
    self.lengthErrors = %d
    self.crcErrors = %d
    self.codeViolations = %d
    self.linkUp = %d
    self.badEof = %d
    self.linkReset = %d
    self.nosOrOls = %d
    """ % (
    self.packetType,
    self.timestamp,
    self.intervalStatsType,
    self.link,
    self.channel,
    self.pcsLossOfSync,
    self.fecCorrectionCount,
    self.lengthErrors,
    self.crcErrors,
    self.codeViolations,
    self.linkUp,
    self.badEof,
    self.linkReset,
    self.nosOrOls)
  def get_channel(self):
    return self.channel
  def get_link(self):
    return self.link
  def get(self):
    return (self.packetType,
    self.timestamp,
    self.intervalStatsType,
    self.link,
    self.channel,
    self.pcsLossOfSync,
    self.fecCorrectionCount,
    self.lengthErrors,
    self.crcErrors,
    self.codeViolations,
    self.linkUp,
    self.badEof,
    self.linkReset,
    self.nosOrOls)
