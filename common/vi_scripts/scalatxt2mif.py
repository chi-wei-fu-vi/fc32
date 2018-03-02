#!/bin/env python2
from scalatxt2pkt import *
from fc16datapktgen import *
from dommifgen import *
from balimifgen import *
from pprint import pprint
import os
import math
class scalatxt2mif:
  debug=False
  pkts=[[],[]]
  t212_5=1.0/212.5*1000 #ns
  def __init__(self,fpgatype='bali',txtf='test.txt',mif='test.mif'):
    """
    """
    self.fpgatype=fpgatype 
    self.scala=scalatxt2pkt(txtf)
    self.scala.extract()
    self.pktgen()
    self.intpktcheck()
    name=os.path.splitext(os.path.basename(mif))[0]
    if self.fpgatype=="dom":
      self.dommif(name)
    elif self.fpgatype=="bali":
      self.balimif(name)
    else:
      exit(1)

  def intpktcheck(self):
    """
    """
    def zerocheck(pkts,type):
      """
      """
      signals=[( 'lossOfSignal', 'lossOfSync', 'lip', 'nosOrOls', 'linkReset', 'linkUp', 'codeViolations', 'crcErrors',
                  'frameErrors', 'badEof', 'timeAtMinCredit', 'minCredit', 'maxCredit'),
               ( 'sfpTxPower', 'sfpRxPower', 'sfpTemp', 'sfpVoltage', 'sfpTxBias', 'sfpAlarmFlags', 'sfpWarningFlags',
                  'endCreditValue', 'linkSpeed', 'eyeHight', 'eyeWidth', 'frameDropCnt'),
               ( 'pcsLossOfSync', 'fecCorrectionCount', 'lengthErrors', 'crcErrors', 'codeViolations', 'linkUp', 'badEof',
                  'linkReset', 'nosOrOls')]



      for pkt in pkts:
        fs=[]
        for signal,value in zip(signals[type],pkt):
          if value!=0 and signal != 'linkSpeed':
            fs.append("%s=%d"%(signal,value))
        print " ".join(fs)
            
         
    zerocheck(self.scala.intpkts[0],0)
    zerocheck(self.scala.intpkts[1],1)
    zerocheck(self.scala.intpkts[2],2)

  def pktgen(self):
    """
    """
    def els_pktgen(length):
      """
      """
      payload=[0]*(length-24-4)  # length-header-crc
      payload[0]=(elsCmd >> 24) & 0xff
      payload[1]=(elsCmd >> 16) & 0xff
      payload[2]=(elsCmd >>  8) & 0xff
      payload[3]=(elsCmd >>  0) & 0xff
      return payload
    def cmd_pktgen(length):
      """
      """
      payload=[0]*(length-24-4)  # length-header-crc
      payload[0]=lun>>8
      payload[1]=lun & 0xff
      payload[10]=task_bits
      payload[12]=cmd_type
      return payload
    def status_pktgen(length):
      """
      """
      payload=[0]*(length-24-4)  # length-header-crc
      payload[10]=error_bits
      payload[11]=status
      payload[16]=(sns_len >> 24) & 0xff
      payload[17]=(sns_len >> 16) & 0xff
      payload[18]=(sns_len >>  8) & 0xff
      payload[19]=(sns_len >>  0) & 0xff
      #payload[27]=rsp_len
      payload[30]=(sense_key >> 8) & 0xff
      payload[38]=(sense_key >> 0) & 0xff
      if (length-24-4) > 40:
        payload[40]=(ascq >> 8) & 0xff
        payload[41]=(additional_sense >> 8) & 0xff
      if (length-24-4) > 48:
        payload[48]=ascq & 0xff
        payload[49]=additional_sense & 0xff
      return payload
    for pkt in self.scala.datapkts:
      if len(pkt) == 10:
        (packetType, timestamp, r_ctl, did, sid, fc_type, f_ctl, oxid, channel, length)= pkt
        payload=[0]*(length-24-4)  # length-header-crc
      elif len(pkt) == 11: # to be implemented
        (packetType, timestamp, r_ctl, did, sid, fc_type, f_ctl, oxid, channel, length,elsCmd)= pkt
        payload=[0]*(length-24-4)  # length-header-crc
      elif len(pkt) == 18:
        (packetType, timestamp, r_ctl, did, sid, fc_type, f_ctl, oxid, channel, length, initiator, target,
         error_bits, status, sns_len, sense_key, additional_sense, ascq)=pkt
        payload=status_pktgen(80)
      elif len(pkt)==15:
        (packetType, timestamp, r_ctl, did, sid, fc_type, f_ctl, oxid, channel, length, initiator, target, lun, task_bits, cmd_type)= pkt
        payload=cmd_pktgen(length)
      else:
        print "ERROR: packet type with length %d is not supported"%len(pkt)
        exit(1)
      obj=fc16datapktgen(
               random_flag  = False,
               allzero_flag = False,
               allone_flag  = False,
               count_flag   = False,
               sof          = '2e',
               r_ctl        = '%02x' % r_ctl,
               d_id         = '%06x' % did,
               reserved     = '00',
               s_id         = '%06x' % sid,
               type         = '%02x' % fc_type,
               f_ctrl       = '%02x0000' % f_ctl,
               seq_id       = '00',
               df_ctl       = '00',
               seq_cnt      = '0000',
               ox_id        = '%04x' % oxid,
               rx_id        = 'ffff',
               parameter    = '00000000',
               crc          = None,
               payload_sz   = payload,
               eof          = '41')
      pkt=obj.pktgen()
      #print length,payload,pkt[25:-1]
      self.pkts[channel].append((timestamp,pkt))
      

    
  def dommif(self,name):
    """
    """
    mifs=[[],[]]
    for channel,packets in enumerate(self.pkts):
      OUTFILE=open('%s_ch%d.mif'%(name,channel),'w')
      pktcount=0
      linecount=0
      outs=[]
      prev_time=0
      for curr_time,pkt in packets:
        delta=curr_time-prev_time
        idle_cycles=math.ceil(delta*10/self.t212_5+0.5)
        prev_time=curr_time
        outs.append("%10d : 1ffff94bc; -- ARB(FF)"%linecount)
        linecount+=1
        if (idle_cycles/212.5/1000) > 1:
          outs.append("%10d : 5%08x; -- repeat %d %d ms"%(linecount,idle_cycles,idle_cycles,(idle_cycles/212.5/1000)))
        else:
          outs.append("%10d : 5%08x; -- repeat %d"%(linecount,idle_cycles,idle_cycles))
        linecount+=1
        obj=dommifgen(pkts=[pkt])
        obj.mifgen()
        for i,word in enumerate(obj.words):
          comment=obj.comments[i]
          if comment !='':
            if 'pkt' in comment:
              pktcount+=1
              comment='pkt %d'%pktcount
            outs.append("%10d : %s; -- %s"%(linecount,word,comment))
          else:
            outs.append("%10d : %s;"%(linecount,word))
          linecount+=1

      for i in range(6):
        outs.append("%10d : 1ffff94bc; -- ARB(FF)"%linecount)
        linecount+=1
      outs.insert(0,"""DEPTH=%d;
WIDTH=36;
ADDRESS_RADIX=UNS;
DATA_RADIX=HEX;

CONTENT BEGIN"""%linecount)

      outs.append("END;")
      #print "\n".join(outs)
      OUTFILE.write("\n".join(outs))


  def balimif(self,name):
    """
    """
    mifs=[[],[]]
    def compress(pkts):
      zippkt=[]
      prev=(0,)
      repeat_cnt=0
      for sync,dtype,codes in pkts:
        comment=obj.extr_comment(dtype,codes)
        curr=(int(sync,2),int("".join(codes[::-1]),2),comment)
        if curr!=prev:
          zippkt.append(((repeat_cnt,)+prev))
          prev=curr
          repeat_cnt=0
        else:
          repeat_cnt+=1
      zippkt.append(((repeat_cnt,)+curr))
      zippkt.pop(0)   
      #pprint(zippkt)
      return zippkt
    for channel,packets in enumerate(self.pkts):
      OUTFILE=open('%s_ch%d.mif'%(name,channel),'w')
      pktcount=0
      linecount=0
      outs=[]
      prev_time=0
      for curr_time,pkt in packets:
        delta=curr_time-prev_time
        idle_cycles=math.ceil(delta*10/self.t212_5+0.5)
        prev_time=curr_time
        outs.append("%10d : 01000000000000001e; -- idle      idle"%linecount)
        linecount+=1
        if (idle_cycles/212.5/1000) > 1:
          outs.append("%10d : 55%016x; -- repeat %d %d ms"%(linecount,idle_cycles-1,idle_cycles-1,(idle_cycles/212.5/1000)))
        elif idle_cycles < 3:
          outs.append("%10d : 01000000000000001e; -- idle      idle"%linecount)
        elif idle_cycles < 6:
          for i in range(idle_cycles):
            outs.append("%10d : 01000000000000001e; -- idle      idle"%linecount)
        else:
          outs.append("%10d : 55%016x; -- repeat %d"%(linecount,idle_cycles-1,idle_cycles-1))
        linecount+=1
        obj=balimifgen(pkts=[pkt],IPG_LEN=0)
        obj.mifgen()
        if True:
          zippkt=compress(obj.outpkts)
          for repeat_cnt,sync,data,comment in zippkt:
            if "SOF" in comment:
              pktcount+=1
              outs.append("%10d : %02x%016x; -- %s pkt %d"%(linecount,sync,data,comment,pktcount))
              linecount+=1
            else:
              if repeat_cnt < 3:
                for i in range(repeat_cnt+1):
                  if comment=='':
                    outs.append("%10d : %02x%016x;"%(linecount,sync,data))
                  else:
                    outs.append("%10d : %02x%016x; -- %s"%(linecount,sync,data,comment))
                  linecount+=1
              else:
                if comment=='':
                  outs.append("%10d : %02x%016x;"%(linecount,sync,data))
                else:
                  outs.append("%10d : %02x%016x; -- %s"%(linecount,sync,data,comment))
                linecount+=1
                outs.append("%10d : 55%016x; -- repeat %d"%(linecount,repeat_cnt,repeat_cnt))
                linecount+=1
        else:
          for sync,dtype,codes in obj.outpkts:
            comment=obj.extr_comment(dtype,codes)
            if "SOF" in comment:
              pktcount+=1
              outs.append("%10d : %02x%016x; -- %s pkt %d"%(linecount,int(sync,2),int("".join(codes[::-1]),2),comment,pktcount))
            else:
              if comment=='':
                outs.append("%10d : %02x%016x;"%(linecount,int(sync,2),int("".join(codes[::-1]),2)))
              else:
                outs.append("%10d : %02x%016x; -- %s"%(linecount,int(sync,2),int("".join(codes[::-1]),2),comment))
            linecount+=1

      for i in range(6):
        outs.append("%10d : 01000000000000001e; -- idle      idle"%linecount)
        linecount+=1
      outs.insert(0,"""DEPTH=%d;
WIDTH=72;
ADDRESS_RADIX=UNS;
DATA_RADIX=HEX;

CONTENT BEGIN"""%linecount)

      outs.append("END;")
      #print "\n".join(outs)
      OUTFILE.write("\n".join(outs))

  def debug_dump(self):
    """
    """
    for packetType, timestamp, intervalStatsType, link, channel, lossOfSignal, lossOfSync, lip, nosOrOls, linkReset, linkUp, codeViolations, crcErrors, frameErrors, badEof, timeAtMinCredit, minCredit, maxCredit in self.scala.intpkts[0]:
      print packetType, timestamp, intervalStatsType, link, channel, lossOfSignal, lossOfSync, lip, nosOrOls, linkReset, linkUp, codeViolations, crcErrors, frameErrors, badEof, timeAtMinCredit, minCredit, maxCredit

    for packetType, timestamp, intervalStatsType, link, channel, sfpTxPower, sfpRxPower, sfpTemp, sfpVoltage, sfpTxBias, sfpAlarmFlags, sfpWarningFlags, endCreditValue, linkSpeed, eyeHight, eyeWidth, frameDropCnt in self.scala.intpkts[1]:
      print packetType, timestamp, intervalStatsType, link, channel, sfpTxPower, sfpRxPower, sfpTemp, sfpVoltage, sfpTxBias, sfpAlarmFlags, sfpWarningFlags, endCreditValue, linkSpeed, eyeHight, eyeWidth, frameDropCnt
    if self.fpgatype=='bali':
      for packetType, timestamp, intervalStatsType, link, channel, pcsLossOfSync, fecCorrectionCount, lengthErrors, crcErrors, codeViolations, linkUp, badEof, linkReset, nosOrOls in self.scala.intpkts[2]:
        print packetType, timestamp, intervalStatsType, link, channel, pcsLossOfSync, fecCorrectionCount, lengthErrors, crcErrors, codeViolations, linkUp, badEof, linkReset, nosOrOls

    for packetType, timestamp, r_ctl, did, sid, fc_type, f_ctl, oxid, channel, length, initiator, target, lun, task_bits, cmd_type in self.scala.datapkts:
      print packetType, timestamp, r_ctl, "%06x"%did, "%06x"%sid, "%02x"%fc_type, "%02x"%f_ctl, "%02x"%oxid, channel, length, "%06x"%initiator, "%06x"%target, "%04x"%lun, task_bits, "%02x"%cmd_type
if __name__=='__main__':
  import sys
  argc=len(sys.argv)
  if argc > 1: txtf=sys.argv[1]
  if argc > 2: mif =sys.argv[1]
  obj=scalatxt2mif("bali",txtf,mif)
  #obj=scalatxt2mif("dom",txtf,mif)
  #obj.debug_dump()
    
  #pprint(obj.pkts[0])
  #pprint(obj.pkts[1])
