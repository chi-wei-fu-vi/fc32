#!/bin/env python2
import struct
class daldatapacket:
  def __init__(self):
    self.packetType = 1
    self.timestamp = 100000000
    # Frame
    self.r_ctl = 0x06
    self.did = 0x000000
    self.sid = 0x000000
    self.fc_type = 8
    self.f_ctl = 0
    self.oxid = 0x0000
    self.channel = 0
    self.length = 56
    # ScsiFrame
    self.initiator = 0x000000
    self.target = 0x000000
    # ScsiCmd
    self.lun = 0
    self.task_bits = 0x00
    self.cmd_type = 0x00

  def extract(self,bin):
    """
    """
    self.packetType=struct.unpack('B',bin[0])[0]
    self.timestamp =int("".join(map(lambda x: '%02x'%x,struct.unpack('7B',bin[1:8]))[::-1]),16)

    self.r_ctl = struct.unpack('B',bin[8])[0]
    self.did = int("".join(map(lambda x: '%02x'%x,struct.unpack('3B',bin[9:12]))[::-1]),16)
    self.sid = int("".join(map(lambda x: '%02x'%x,struct.unpack('3B',bin[12:15]))[::-1]),16)
    self.fc_type, \
    self.f_ctl, \
    self.oxid  \
    =struct.unpack('<2BH',bin[15:19])
    type=struct.unpack('<H',bin[-2:])[0]
    #print '{0:016b}'.format(type)
    self.length=type & 0x3fff
    self.channel=(type>>15) & 0x1
    self.initiator=self.sid
    self.target=self.did
    self.lun = struct.unpack('<H',bin[21:23])[0]
    self.task_bits = struct.unpack('B',bin[23])[0]
    self.cmd_type = struct.unpack('B',bin[25])[0]


  def puts(self):
    """
    """
    print """
    packetType = %d
    timestamp = %d

    r_ctl = 0x%02x
    did = 0x%06x
    sid = 0x%06x
    fc_type = 0x%02x
    f_ctl = 0x%02x
    oxid = 0x%04x
    channel = %d
    length = %d

    initiator = 0x%06x
    target = 0x%06x

    lun = 0x%04x
    task_bits = 0x%02x
    cmd_type = 0x%02x
    """ % (
    self.packetType,
    self.timestamp,
    self.r_ctl,
    self.did,
    self.sid,
    self.fc_type,
    self.f_ctl,
    self.oxid,
    self.channel,
    self.length,
    self.initiator,
    self.target,
    self.lun,
    self.task_bits,
    self.cmd_type)
  def get_channel(self):
    return self.channel
  def get(self):
    """
    """
    return (self.packetType,
    self.timestamp,
    self.r_ctl,
    self.did,
    self.sid,
    self.fc_type,
    self.f_ctl,
    self.oxid,
    self.channel,
    self.length,
    self.initiator,
    self.target,
    self.lun,
    self.task_bits,
    self.cmd_type)
