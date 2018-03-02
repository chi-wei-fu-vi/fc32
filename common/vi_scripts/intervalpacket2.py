#!/bin/env python2
import struct
class intervalpacket2:
  def __init__(self):
    """
    """
    self.packetType = 4
    self.timestamp = 212500000
    # IntervalStats 
    self.intervalStatsType=1
    self.link=0
    self.channel=0
    # IntervalStats2 
    self.sfpTxPower=0
    self.sfpRxPower=0
    self.sfpTemp=0
    self.sfpVoltage=0
    self.sfpTxBias=0
    self.sfpAlarmFlags=0
    self.sfpWarningFlags=0
    self.endCreditValue=0
    self.linkSpeed=8
    self.eyeHight=0
    self.eyeWidth=0
    self.frameDropCnt=0

  def extract(self,bin):
    """
    """
    self.packetType=struct.unpack('B',bin[0])[0]
    self.timestamp =int("".join(map(lambda x: '%02x'%x,struct.unpack('7B',bin[1:8]))[::-1]),16)
    self.sfpTxPower, \
    self.sfpRxPower, \
    self.sfpTemp, \
    =struct.unpack('<3H',bin[8:14])
    self.sfpAlarmFlags, \
    self.sfpWarningFlags, \
    self.endCreditValue, \
    self.linkSpeed, \
    self.eyeHight, \
    self.eyeWidth, \
    self.frameDropCnt, \
    self.sfpVoltage, \
    self.sfpTxBias, \
    =struct.unpack('<4I2BI2H',bin[16:42])
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
 
    sfpTxPower = %d
    sfpRxPower = %d
    sfpTemp = %d
    sfpVoltage = %d
    sfpTxBias = %d
    sfpAlarmFlags = %d
    sfpWarningFlags = %d
    endCreditValue = %d
    linkSpeed = %d
    eyeHight = %d
    eyeWidth = %d
    frameDropCnt = %d
    """ % (
    self.packetType,
    self.timestamp,
    self.intervalStatsType,
    self.link,
    self.channel,
    self.sfpTxPower,
    self.sfpRxPower,
    self.sfpTemp,
    self.sfpVoltage,
    self.sfpTxBias,
    self.sfpAlarmFlags,
    self.sfpWarningFlags,
    self.endCreditValue,
    self.linkSpeed,
    self.eyeHight,
    self.eyeWidth,
    self.frameDropCnt)
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
    self.sfpTxPower,
    self.sfpRxPower,
    self.sfpTemp,
    self.sfpVoltage,
    self.sfpTxBias,
    self.sfpAlarmFlags,
    self.sfpWarningFlags,
    self.endCreditValue,
    self.linkSpeed,
    self.eyeHight,
    self.eyeWidth,
    self.frameDropCnt)
