#!/bin/env python2
import struct
class intervalpacket1:
  def __init__(self):
    """
    """
    self.packetType = 4
    self.timestamp = 425000000
    # IntervalStats 
    self.intervalStatsType=0
    self.link=0
    self.channel=0
    # IntervalStats1 
    self.lossOfSignal=0
    self.lossOfSync=0
    self.lip=0
    self.nosOrOls=0
    self.linkReset=0
    self.linkUp=0
    self.codeViolations=0
    self.crcErrors=0
    self.frameErrors=0
    self.badEof=0
    self.timeAtMinCredit=0
    self.minCredit=0
    self.maxCredit=0

  def extract(self,bin):
    """
    """
    reserved=None

    self.packetType=struct.unpack('B',bin[0])[0]
    self.timestamp =int("".join(map(lambda x: '%02x'%x,struct.unpack('7B',bin[1:8]))[::-1]),16)
    self.lossOfSignal, \
    self.lossOfSync, \
    self.lip, \
    self.nosOrOls, \
    self.linkReset, \
    self.linkUp, \
    self.codeViolations, \
    self.crcErrors, \
    self.frameErrors, \
    self.badEof, \
    self.timeAtMinCredit, \
    self.minCredit, \
    self.maxCredit \
    =struct.unpack('<13I',bin[8:-4])
    type=struct.unpack('<H',bin[-2:])[0]
    #print '{0:016b}'.format(type)
    self.intervalStatsType=type & 0x7
    self.channel=(type>>12) & 0x1
    self.link=(type>>8) & 0xf

    
  def puts(self):
    """
    """
    print """
    packetType = %d
    timestamp = %d

    intervalStatsType = %d
    link = %d
    channel = %d

    lossOfSignal = %d
    lossOfSync = %d
    lip = %d
    nosOrOls = %d
    linkReset = %d
    linkUp = %d
    codeViolations = %d
    crcErrors = %d
    frameErrors = %d
    badEof = %d
    timeAtMinCredit = %d
    minCredit = %d
    maxCredit = %d
"""% (
    self.packetType,
    self.timestamp,
    # IntervalStats 
    self.intervalStatsType,
    self.link,
    self.channel,
    # IntervalStats1 
    self.lossOfSignal,
    self.lossOfSync,
    self.lip,
    self.nosOrOls,
    self.linkReset,
    self.linkUp,
    self.codeViolations,
    self.crcErrors,
    self.frameErrors,
    self.badEof,
    self.timeAtMinCredit,
    self.minCredit,
    self.maxCredit)
  def get_channel(self):
    return self.channel
  def get_link(self):
    return self.link
  def get(self):
    return (self.packetType,
    self.timestamp,
    # IntervalStats 
    self.intervalStatsType,
    self.link,
    self.channel,
    # IntervalStats1 
    self.lossOfSignal,
    self.lossOfSync,
    self.lip,
    self.nosOrOls,
    self.linkReset,
    self.linkUp,
    self.codeViolations,
    self.crcErrors,
    self.frameErrors,
    self.badEof,
    self.timeAtMinCredit,
    self.minCredit,
    self.maxCredit)
