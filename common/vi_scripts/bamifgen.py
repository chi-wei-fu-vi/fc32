#!/usr/bin/env python2
import re
from pprint import pprint
class bamifgen:
  IPG_LEN  = 12
  MAX_DEP  = 2048

  fc16_dup_primitives=[
  'nos',          # 0x45bf55
  'ols',          # 0x558a35
  'lr',           # 0x49bf49
  'lrr',          # 0x49bf35
  ]
  fc16_types=[
  0x1e,           # error  rcvr
  0x1e,           # idle   idle
  0x33,           # idle   sof
  0x66,           # other  sof
  0x55,           # other  other
  0x78,           # sof    data
  0x4b,           # other  idle
  0xb4,           # eof    idle
  0x2d,           # idle   other
  0xff,           # data   eof
  ]
  fc16_sofs={
  'i2'    :       '5555b5',               # SOF Initiate Class 2
  'n2'    :       '3535b5',               # SOF Normal Class 2
  'i3'    :       '5656b5',               # SOF Initiate Class 3
  'n3'    :       '3636b5',               # SOF Normal Class 3
  'f'     :       '5858b5',               # SOF Fabric
  }
  fc16_eofs={
  't'     :       '757595',               # EOF Terminate
  'a'     :       'f5f595',               # EOF Abort
  'n'     :       'd5d595',               # EOF Normal
  'ni'    :       'd5d58a',               # EOF Normal-Invalid
  }
  fc16_primitives={
  'rrdy'  :       '4a4a95',               # receiver ready
  #'vcrdy' :       '????f5',               # virtual circuit ready
  'vcrdy' :       '0000f5',               # virtual circuit ready
  'bbscs' :       '969695',               # buffer-to-buffer state change (SOF)
  'bbscr' :       'd6d695',               # buffer-to-buffer state change (R_RDY)
  'nos'   :       '45bf55',               # not operational
  'ols'   :       '558a35',               # offline
  'lr'    :       '49bf49',               # link reset
  'lrr'   :       '49bf35',               # link reset response
  }
  fc16_sofs_r={}
  fc16_eofs_r={}
  fc16_primitives_r={}

  ctrlch2ctrl={
  'I'    :       0x00,
  'E'    :       0x1E,
  'R'    :       0x2D,
  'R1'   :       0x33,
  'N'    :       0x4B,
  'K'    :       0x55,
  'R4'   :       0x66,
  'R5'   :       0x78
  }

  byte2seqcode={
  0x9C    :       0x0,
  0x4C    :       0xF
  }

  def __init__(self,
               pkts=[[0]*64],
               IPG_LEN = 12,
               MAX_DEP  = 2048):
    self.pkts=pkts
    self.IPG_LEN=IPG_LEN
    self.MAX_DEP=MAX_DEP
   
    self.fc16_sofs_r={}
    [self.fc16_sofs_r.update({self.fc16_sofs[x]:x}) for x in self.fc16_sofs]
    self.fc16_eofs_r={}
    [self.fc16_eofs_r.update({self.fc16_eofs[x]:x}) for x in self.fc16_eofs]
    self.fc16_primitives_r={}
    [self.fc16_primitives_r.update({self.fc16_primitives[x]:x}) for x in self.fc16_primitives]
 
  def mifgen(self):
    """   
    prepend preamble
    """   
    words=[]
    self.outpkts=[]
    for bytes in self.pkts:
      words.append(('','SOFi3'))
      if len(bytes) % 4:
        print "Error: size of packet is not multiple of 4 bytes %s"%bytes
      while bytes:
        words.append((bytes[:4],''))
        bytes=bytes[4:]
      words.append(('','EOFn'))
      words.extend(map(lambda x: ('','idle'),range(self.IPG_LEN//4)))
      if self.IPG_LEN % 4:
        words.append(('','idle'))
    if len(words) % 2:
      words.append(('','idle'))
        
    while words:
      self.outpkts.append(self.b72b66_encode(words.pop(0),words.pop(0)))

  def b72b66_encode(self,fword,sword):

    """
    64B/66B Block Formats

    Data Block Format                Sync
    D0 D1 D2 D3 D4 D5 D6 D7          01

    Data Block Format                Sync   Block Type
    C0 C1 C2 C3 C4 C5 C6 C7          10     0x1e         C0 C1 C2 C3 C4 C5 C6 C7    # error rcvr
    C0 C1 C2 C3 C4 C5 C6 C7          10     0x1e         C0 C1 C2 C3 C4 C5 C6 C7    # idle  idle
    C0 C1 C2 C3 S4 M5 M6 M7          10     0x33         C0 C1 C2 C3 -  M5 M6 M7    # idle  sof
    O0 M1 M2 M3 S4 M5 M6 M7          10     0x66         M1 M2 M3 O0 -  M5 M6 M7    # other sof
    O0 M1 M2 M3 O4 M5 M6 M7          10     0x55         M1 M2 M3 O0 O4 M5 M6 M7    # other other
    S0 M1 M2 M3 D4 D5 D6 D7          10     0x78         M1 M2 M3 D4 D5 D6 D7       # sof   data
    O0 M1 M2 M3 C4 C5 C6 C7          10     0x4b         M1 M2 M3 O0 C4 C5 C6 C7    # other idle
    M0 M1 M2 T3 C4 C5 C6 C7          10     0xb4         M0 M1 M2 -  C4 C5 C6 C7    # eof   idle
    C0 C1 C2 C3 O4 M5 M6 M7          10     0x2d         C0 C1 C2 C3 O4 M5 M6 M7    # idle  other
    D0 D1 D2 D3 M4 M5 M6 T7          10     0xff         D0 D1 D2 D3 M4 M5 M6       # data  eof
    """
    sync='10'
    (fbytes,ftype)=fword
    (sbytes,stype)=sword
    codes=[]
    # all control (usally idles)
    # C0 C1 C2 C3 C4 C5 C6 C7          10     0x1e         C0 C1 C2 C3 C4 C5 C6 C7    # idle  idle
    if ftype=='idle' and stype=='idle':
      dtype=0x1e
      codes.append('{0:08b}'.format(dtype))
      codes.extend(map(lambda x: '{0:07b}'.format(self.ctrlch2ctrl['I']),range(0,7+1)))
    # control char upto data 3 but an ordered set from data 4 onwards
    # C0 C1 C2 C3 O4 M5 M6 M7          10     0x2d         C0 C1 C2 C3 O4 M5 M6 M7    # idle  other
    elif ftype=='idle' and (stype=='rrdy' or stype=='vcrdy' or stype=='bbscs' or stype=='bbscr' or stype=='nos' or stype =='ols' or stype=='lr' or stype == 'lrr'):
      dtype=0x2d
      codes.append('{0:08b}'.format(dtype))
      codes.extend(map(lambda x: '{0:07b}'.format(self.ctrlch2ctrl['I']),range(0,3+1)))
      codes.append('{0:04b}'.format(self.byte2seqcode[0x9c]))
      codes.extend(map(lambda x: '{0:08b}'.format(x),map(lambda x: int(x,16),filter(lambda x: x!='',re.split('([0-9a-f][0-9a-f])',self.fc16_primitives[stype])))[::-1]))
    # start of packet in data 4
    # C0 C1 C2 C3 S4 M5 M6 M7          10     0x33         C0 C1 C2 C3 -  M5 M6 M7    # idle  sof
    elif ftype=='idle' and stype.startswith('SOF'):
      dtype=0x33
      codes.append('{0:08b}'.format(dtype))
      codes.extend(map(lambda x: '{0:07b}'.format(self.ctrlch2ctrl['I']),range(0,3+1)))
      codes.append('0'*4)
      codes.extend(map(lambda x: '{0:08b}'.format(x),map(lambda x: int(x,16),filter(lambda x: x!='',re.split('([0-9a-f][0-9a-f])',self.fc16_sofs[stype[3:]])))[::-1]))
    # order set in data 0 to data 3 and start of packet in data 4
    # O0 M1 M2 M3 S4 M5 M6 M7          10     0x66         M1 M2 M3 O0 -  M5 M6 M7    # other sof
    elif (ftype=='rrdy' or ftype=='vcrdy' or ftype=='bbscs' or ftype=='bbscr' or ftype=='nos' or ftype =='ols' or ftype=='lr' or ftype == 'lrr') and stype.startswith('SOF'):
      dtype=0x66
      codes.append('{0:08b}'.format(dtype))
      codes.extend(map(lambda x: '{0:08b}'.format(x),map(lambda x: int(x,16),filter(lambda x: x!='',re.split('([0-9a-f][0-9a-f])',self.fc16_primitives[ftype])))[::-1]))
      codes.append('{0:04b}'.format(self.byte2seqcode[0x9c]))
      codes.append('0'*4)
      codes.extend(map(lambda x: '{0:08b}'.format(x),map(lambda x: int(x,16),filter(lambda x: x!='',re.split('([0-9a-f][0-9a-f])',self.fc16_sofs[stype[3:]])))[::-1]))
    # order set in data 0 and data 4
    # O0 M1 M2 M3 O4 M5 M6 M7          10     0x55         M1 M2 M3 O0 O4 M5 M6 M7    # other other
    elif (ftype=='rrdy' or ftype=='vcrdy' or ftype=='bbscs' or ftype=='bbscr' or ftype=='nos' or ftype =='ols' or ftype=='lr' or ftype == 'lrr') and \
         (stype=='rrdy' or stype=='vcrdy' or stype=='bbscs' or stype=='bbscr' or stype=='nos' or stype =='ols' or stype=='lr' or stype == 'lrr'):
      dtype=0x55
      codes.append('{0:08b}'.format(dtype))
      codes.extend(map(lambda x: '{0:08b}'.format(x),map(lambda x: int(x,16),filter(lambda x: x!='',re.split('([0-9a-f][0-9a-f])',self.fc16_primitives[ftype])))[::-1]))
      codes.append('{0:04b}'.format(self.byte2seqcode[0x9c]))
      codes.append('{0:04b}'.format(self.byte2seqcode[0x9c]))
      codes.extend(map(lambda x: '{0:08b}'.format(x),map(lambda x: int(x,16),filter(lambda x: x!='',re.split('([0-9a-f][0-9a-f])',self.fc16_primitives[stype])))[::-1]))
    # start of packet in data 0
    # S0 M1 M2 M3 D4 D5 D6 D7          10     0x78         M1 M2 M3 D4 D5 D6 D7       # sof   data
    elif ftype.startswith('SOF') and stype=='':
      dtype=0x78
      codes.append('{0:08b}'.format(dtype))
      codes.extend(map(lambda x: '{0:08b}'.format(x),map(lambda x: int(x,16),filter(lambda x: x!='',re.split('([0-9a-f][0-9a-f])',self.fc16_sofs[ftype[3:]])))[::-1]))
      codes.extend(map(lambda x: '{0:08b}'.format(x),sbytes))
    # order set in data 0 and control chars in data 4 to 7
    # O0 M1 M2 M3 C4 C5 C6 C7          10     0x4b         M1 M2 M3 O0 C4 C5 C6 C7    # other idle
    elif (ftype=='rrdy' or ftype=='vcrdy' or ftype=='bbscs' or ftype=='bbscr' or ftype=='nos' or ftype =='ols' or ftype=='lr' or ftype == 'lrr') and stype=='idle' :
      dtype=0x4b
      codes.append('{0:08b}'.format(dtype))
      codes.extend(map(lambda x: '{0:08b}'.format(x),map(lambda x: int(x,16),filter(lambda x: x!='',re.split('([0-9a-f][0-9a-f])',self.fc16_primitives[ftype])))[::-1]))
      codes.append('{0:04b}'.format(self.byte2seqcode[0x9c]))
      codes.extend(map(lambda x: '{0:07b}'.format(self.ctrlch2ctrl['I']),range(4,7+1)))
    # terminate in data 3
    # M0 M1 M2 T3 C4 C5 C6 C7          10     0xb4         M0 M1 M2 -  C4 C5 C6 C7    # eof   idle
    elif ftype.startswith('EOF') and stype=='idle':
      dtype=0xb4
      codes.append('{0:08b}'.format(dtype))
      codes.extend(map(lambda x: '{0:08b}'.format(x),map(lambda x: int(x,16),filter(lambda x: x!='',re.split('([0-9a-f][0-9a-f])',self.fc16_eofs[ftype[3:]])))[::-1]))
      codes.extend('0'*4)
      codes.extend(map(lambda x: '{0:07b}'.format(self.ctrlch2ctrl['I']),range(4,7+1)))
    # terminate in data 7
    # D0 D1 D2 D3 M4 M5 M6 T7          10     0xff         D0 D1 D2 D3 M4 M5 M6       # data  eof
    elif ftype=='' and stype.startswith('EOF'):
      dtype=0xff
      codes.append('{0:08b}'.format(dtype))
      codes.extend(map(lambda x: '{0:08b}'.format(x),fbytes))
      codes.extend(map(lambda x: '{0:08b}'.format(x),map(lambda x: int(x,16),filter(lambda x: x!='',re.split('([0-9a-f][0-9a-f])',self.fc16_eofs[stype[3:]])))[::-1]))
    # all data
    elif ftype=='' and stype=='':
      dtype=0x00
      codes.extend(map(lambda x: '{0:08b}'.format(x),fbytes))
      codes.extend(map(lambda x: '{0:08b}'.format(x),sbytes))
      sync='01'
    else:
      dtype=0x01
      print "ERROR: invalid 72bit raw data %s %s %s %s"%(fbytes,ftype,sbytes,stype)
      codes=['00000000']*8
      sync='00'
    return sync,dtype,codes

  def write_mif(self,file):
    """
    """
    OUTFILE=open(file,"w")
    outs=[]
    count=0
    outs.append('''
DEPTH=%d;
WIDTH=72;
ADDRESS_RADIX=UNS;
DATA_RADIX=HEX;

CONTENT BEGIN
'''%len(self.outpkts))
    for i,(sync,dtype,codes) in enumerate(self.outpkts):
      comment=self.extr_comment(dtype,codes)
      #outs.append("%10d : %02x%016x; -- %s"%(i,int(sync,2),int("".join(codes[::-1]),2),"%02x"%dtype + " " + "".join(codes)))
      if "SOF" in comment:
        count+=1
        outs.append("%10d : %02x%016x; -- %s pkt %d"%(i,int(sync,2),int("".join(codes[::-1]),2),comment,count))
      else:
        outs.append("%10d : %02x%016x; -- %s"%(i,int(sync,2),int("".join(codes[::-1]),2),comment))
    outs.append('END;')
    print "\n".join(outs)
    OUTFILE.write("\n".join(outs))
    OUTFILE.close()

  def extr_comment(self,dtype,codes):
    """
    """
    fs=[]
    if   dtype == 0x1e: # idle  idle
      fs=['idle','idle']
    elif dtype == 0x33: # idle  sof
      fs=['idle','sof']
      fs[1]="SOF"+self.fc16_sofs_r["".join(map(lambda x:"%02x"%(int(x,2)),codes[-3:][::-1]))]
    elif dtype == 0x66: # other sof
      fs=['other','sof']
      fs[0]=self.fc16_primitives_r["".join(map(lambda x:"%02x"%(int(x,2)),codes[1:4][::-1]))]
      fs[1]="SOF"+self.fc16_sofs_r["".join(map(lambda x:"%02x"%(int(x,2)),codes[-3:][::-1]))]
    elif dtype == 0x55: # other other
      fs=['other','other']
      fs[0]=self.fc16_primitives_r["".join(map(lambda x:"%02x"%(int(x,2)),codes[1:4][::-1]))]
      fs[1]=self.fc16_primitives_r["".join(map(lambda x:"%02x"%(int(x,2)),codes[-3:][::-1]))]
    elif dtype == 0x78: # sof   data
      fs=['sof','data']
      fs[0]="SOF"+self.fc16_sofs_r["".join(map(lambda x:"%02x"%(int(x,2)),codes[1:4][::-1]))]
    elif dtype == 0x4b: # other idle
      fs=['other','idle']
      fs[0]=self.fc16_primitives_r["".join(map(lambda x:"%02x"%(int(x,2)),codes[1:4][::-1]))]
    elif dtype == 0xb4: # eof   idle
      fs=['eof','idle']
      fs[0]="EOF"+self.fc16_eofs_r["".join(map(lambda x:"%02x"%(int(x,2)),codes[1:4][::-1]))]
    elif dtype == 0x2d: # idle  other
      fs=['idle','other']
      fs[1]=self.fc16_primitives_r["".join(map(lambda x:"%02x"%(int(x,2)),codes[-3:][::-1]))]
    elif dtype == 0xff: # data  eof
      fs=['data','eof']
      fs[1]="EOF"+self.fc16_eofs_r["".join(map(lambda x:"%02x"%(int(x,2)),codes[-3:][::-1]))]
    return "".join(map(lambda x:"%-10s"%x,fs[::-1]))

    
      
   
if __name__ == '__main__': 
  """
  """
  import sys
  argc=len(sys.argv)
  file='test.mif'
  if argc > 1: file   = sys.argv[1]
  pkts=[
[144, 226, 186, 22, 222, 177, 144, 226, 186, 22, 222, 176, 129, 0, 96, 5, 137, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 46, 6, 0, 0, 1, 0, 0, 0, 2, 8, 41, 0, 0, 0, 0, 0, 0, 0, 57, 255, 255, 0, 0, 0, 0, 8, 81, 35, 10, 66, 0, 0, 0, 254, 51, 130, 240],
[144, 226, 186, 22, 222, 177, 144, 226, 186, 22, 222, 176, 129, 0, 96, 5, 137, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 46, 6, 0, 0, 1, 0, 0, 0, 2, 8, 41, 0, 0, 0, 0, 0, 0, 0, 57, 255, 255, 0, 0, 0, 0, 8, 81, 35, 10, 66, 0, 0, 0, 254, 51, 130, 240]
]
  obj = bamifgen(pkts=pkts)
  obj.mifgen()
  obj.write_mif(file)


  
