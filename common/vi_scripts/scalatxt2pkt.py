#!/bin/env python2
from pprint import pprint

class scalatxt2pkt(object):
  class datapkt(object):
    def __init__(self):
      self.packetType   = 1
      self.timestamp    = 100000000
      self.channel      = 0
      self.DID          = 0x000000
      self.f_ctl        = 0
      self.fc_type      = 0
      self.length       = 24
      self.oxid         = 0x0000
      self.r_ctl        = 0x00
      self.SID          = 0x000000
  
    def puts(self):
      """
      """
      print """
      packetType = %d
      timestamp = %d
  
      r_ctl = 0x%02x
      DID = 0x%06x
      SID = 0x%06x
      fc_type = 0x%02x
      f_ctl = 0x%02x
      oxid = 0x%04x
      channel = %d
      length = %d
      """ % (
      self.packetType,
      self.timestamp,
      self.r_ctl,
      self.DID,
      self.SID,
      self.fc_type,
      self.f_ctl,
      self.oxid,
      self.channel,
      self.length)
  
    def get(self):
      """
      """
      return (self.packetType,
      self.timestamp,
      self.r_ctl,
      self.DID,
      self.SID,
      self.fc_type,
      self.f_ctl,
      self.oxid,
      self.channel,
      self.length)
  
  class scsi(datapkt):
    def __init__(self):
      super(scalatxt2pkt.scsi,self).__init__()
      self.initiator    = 0x000001
      self.target       = 0x2b0200
  
    def puts(self):
      """
      """
      super(scalatxt2pkt.scsi,self).puts()
      print """
      self.initiator    = %d
      self.target       = %d
      """ % (self.initiator,
      self.target)
  
    def get(self):
      """
      """
      return super(scalatxt2pkt.scsi,self).get() + (self.initiator, self.target)
  
  class scsicmd(scsi):
    def __init__(self):
      super(scalatxt2pkt.scsicmd,self).__init__()
      self.lun          = 5
      self.task_bits    = 0x00
      self.cmd_type     = 0x0a
  
    def puts(self):
      """
      """
      super(scalatxt2pkt.scsicmd,self).puts()
      print """
      self.lun          = %d
      self.task_bits    = %d
      self.cmd_type     = %d
      """ % (
      self.lun,
      self.task_bits,
      self.cmd_type)
  
    def get(self):
      """
      """
      return super(scalatxt2pkt.scsicmd,self).get() + (self.lun, self.task_bits, self.cmd_type)
  
  class scsistatus(scsi):
    def __init__(self):
      super(scalatxt2pkt.scsistatus,self).__init__()
      self.error_bits           = 0
      self.status               = 18
      self.sns_len              = 0
      self.sense_key            = 0
      self.additional_sense     = 0
      self.ascq                 = 0
    def puts(self):
      """
      """
      super(scalatxt2pkt.scsistatus,self).puts()
      print """
      self.error_bits           = %d
      self.status               = %d
      self.sns_len              = %d
      self.sense_key            = %d
      self.additional_sense     = %d
      self.ascq                 = %d
      """ % (
      self.error_bits,
      self.status,
      self.sns_len,
      self.sense_key,
      self.additional_sense,
      self.ascq)
  
    def get(self):
      """
      """
      return super(scalatxt2pkt.scsistatus,self).get() + (self.error_bits,
      self.status,
      self.sns_len,
      self.sense_key,
      self.additional_sense,
      self.ascq)
  
  class els(datapkt):
    def __init__(self):
      super(scalatxt2pkt.els,self).__init__()
      self.elsCmd	= 0x03000000
  
    def puts(self):
      """
      """
      super(scalatxt2pkt.els,self).puts()
      print """
      elsCmd = %d
      """ % (
      self.elsCmd)
  
    def get(self):
      """
      """
      return super(scalatxt2pkt.els,self).get() + (self.elsCmd,)
  
  class interpkt(object):
    def __init__(self):
      self.packetType           = 4
      self.timestamp            = 100000000
      self.intervalStatsType    = 0
      self.link                 = 0
      self.channel              = 0
    def puts(self):
      """
      """
      print """
      packetType = %d
      timestamp = %d
  
      intervalStatsType = %d
      link = %d
      channel = %d
      """%(
      self.packetType,
      self.timestamp,
      # IntervalStats 
      self.intervalStatsType,
      self.link,
      self.channel,
      )
    def get(self):
      """
      """
      return (self.packetType,
      self.timestamp,
      # IntervalStats 
      self.intervalStatsType,
      self.link,
      self.channel,
      )
  
  class interpkt1(interpkt):
    def __init__(self):
      super(scalatxt2pkt.interpkt1,self).__init__()
      self.badEof               = 0
      self.codeViolations       = 0
      self.crcErrors            = 0
      self.frameErrors          = 0
      self.linkReset            = 0
      self.linkUp               = 0
      self.lip                  = 0
      self.lossOfSignal         = 0
      self.lossOfSync           = 0
      self.maxCredit            = 0
      self.minCredit            = 0
      self.nosOrOls             = 0
      self.timeAtMinCredit      = 0
  
    def puts(self):
      """
      """
      super(scalatxt2pkt.interpkt1,self).puts()
      print """
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
  
    def get(self):
      return super(scalatxt2pkt.interpkt1,self).get() + (self.lossOfSignal,
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
  
  
  class interpkt2(interpkt):
    def __init__(self):
      super(scalatxt2pkt.interpkt2,self).__init__()
      self.endCreditValue       = 0
      self.linkSpeed            = 16
      self.sfpAlarmFlags        = 0
      self.sfpRxPower           = 0
      self.sfpTemp              = 0
      self.sfpTxBias            = 0
      self.sfpTxPower           = 0
      self.sfpVoltage           = 0
      self.sfpWarningFlags      = 0
      self.eyeHight             = 0
      self.eyeWidth             = 0
      self.frameDropCnt         = 0
  
    def puts(self):
      """
      """
      super(scalatxt2pkt.interpkt2,self).puts()
      print """
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
  
    def get(self):
      return super(scalatxt2pkt.interpkt2,self).get() + (self.sfpTxPower,
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
  
  
  class interpkt3(interpkt):
    def __init__(self):
      super(scalatxt2pkt.interpkt3,self).__init__()
      self.badEof               = 0
      self.codeViolations       = 0
      self.crcErrors            = 0
      self.fecCorrectionCount   = 0
      self.lengthErrors         = 0
      self.linkReset            = 0
      self.linkUp               = 0
      self.nosOrOls             = 0
      self.pcsLossOfSync        = 0
  
    def puts(self):
      """
      """
      super(scalatxt2pkt.interpkt3,self).puts()
      print """
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
      self.pcsLossOfSync,
      self.fecCorrectionCount,
      self.lengthErrors,
      self.crcErrors,
      self.codeViolations,
      self.linkUp,
      self.badEof,
      self.linkReset,
      self.nosOrOls)
  
    def get(self):
      return super(scalatxt2pkt.interpkt3,self).get() + (self.pcsLossOfSync,
      self.fecCorrectionCount,
      self.lengthErrors,
      self.crcErrors,
      self.codeViolations,
      self.linkUp,
      self.badEof,
      self.linkReset,
      self.nosOrOls)


  datapkts=[]
  intpkts=[[],[],[]]
  debug=False
  def __init__(self,file):
    """
    """
    with open(file,'r') as f:
      self.lines=(' '.join(filter(lambda x: x!='',
                     map(lambda x: x.strip(),
                     filter(lambda x: not x.startswith('//'),f.readlines()))))).split('DalDataPacket { ')[1:]
    f.close()
    #pprint(self.lines)
  def extract(self):
    """
    """
    for line in  self.lines:
      if not line.startswith('packetType = '):
        print "ERROR: file format is not supported"
        exit(1)
      packetType=int(line[13:line.index(',')])
      line=line[line.index(',')+1:].strip()
      #print packetType,line
      if not line.startswith('timestamp = '):
        print "ERROR: file format is not supported"
        exit(2)
      timestamp=int(line[12:12+line[12:].index(' ')])
      line=line[12+line[12:].index(' ')+1:]
      #print timestamp,line
      if packetType == 1:
        self.datapacket(packetType,timestamp,line)
      elif packetType == 4:
        self.intpacket(packetType,timestamp,line)

  def datapacket(self,packetType,timestamp,line):
    """
    """
    if not line.startswith('Frame('):
        print "ERROR: file format is not supported"
        exit(3)
    for frame in filter(lambda x: x!='',line.split(')')):
       frame=frame.strip()
    if 'ScsiFrame' in line:
      line=line.replace(') ScsiFrame(',', ')
      if 'ScsiCmd' in line:
        line=line.replace(') ScsiCmd(',', ')
        pkt=line[6:-1].split(', ')
        #print pkt
        pktobj= self.scsicmd()
        for f in pkt:
          f='pktobj.'+f
          idx=f.index('=')
          f="%sint(%s)"%(f[:idx+1],f[idx+1:])
          exec(f)
        #pktobj.puts()
        self.datapkts.append(pktobj.get())
        return
      elif 'ScsiStatus' in line:
        #print line
        line=line.replace(') ScsiStatus(',', ')
        pkt=line[6:-1].split(', ')
        #print pkt
        pktobj= self.scsistatus()
        for f in pkt:
          f='pktobj.'+f
          idx=f.index('=')
          f="%sint(%s)"%(f[:idx+1],f[idx+1:])
          exec(f)
        #pktobj.puts()
        self.datapkts.append(pktobj.get())
        return
      else:
        pkt=line[6:-1].split(', ')
        pktobj= self.datapkt()
        for f in pkt:
          f='pktobj.'+f
          idx=f.index('=')
          f="%sint(%s)"%(f[:idx+1],f[idx+1:])
          exec(f)
        self.datapkts.append(pktobj.get())
        return
    elif 'ELS' in line:
      #print line
      line=line.replace(') ELS Frame(',', ')
      pkt=line[6:-1].split(', ')
      #print pkt
      pktobj= self.els()
      for f in pkt:
        f='pktobj.'+f
        idx=f.index('=')
        f="%sint(%s)"%(f[:idx+1],f[idx+1:])
        exec(f)
      #pktobj.puts()
      self.datapkts.append(pktobj.get())
      return
    else:
      pkt=line[6:-1].split(', ')
      pktobj= self.datapkt()
      for f in pkt:
        f='pktobj.'+f
        idx=f.index('=')
        f="%sint(%s)"%(f[:idx+1],f[idx+1:])
        exec(f)
      self.datapkts.append(pktobj.get())
      #pktobj.puts()
      #pprint(pkt)

  def intpacket(self,packetType,timestamp,line):
    """
    """
    for pkt in filter(lambda x: not x=='',line.split('IntervalStats')):
      pkt=pkt.strip()
      if pkt.startswith('('):
        pktheader=pkt[1:-1].strip().split(', ')
      else:
        Type=pkt[0]
        #print pkt
        pkt=pkt[3:-1].strip().split(', ')
        if Type=='1':
          pktobj= self.interpkt1()
        elif Type=='2':
          pktobj= self.interpkt2()
          #pktobj.puts()
        elif Type=='3':
          pktobj= self.interpkt3()
        else:
          print "ERROR:interval stat type = %s is not supported"%Type
        for f in (pktheader+pkt):
          f='pktobj.'+f
          idx=f.index('=')
          f="%sint(%s)"%(f[:idx+1],f[idx+1:])
          exec(f)
        pktobj.packetType = packetType
        pktobj.timestamp = timestamp
        if Type=='1':
          self.intpkts[0].append(pktobj.get())
        elif Type=='2':
          #pktobj.puts()
          self.intpkts[1].append(pktobj.get())
        elif Type=='3':
          self.intpkts[2].append(pktobj.get())
        else:
          print "ERROR:interval stat type = %s is not supported"%Type
         
         
         

if __name__=='__main__':
  import sys
  argc=len(sys.argv)
  if argc > 1: txtf=sys.argv[1]
  obj=scalatxt2pkt(txtf)
  obj.extract()
  pprint(obj.datapkts)
  pprint(obj.intpkts)
  
