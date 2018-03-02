#!/usr/bin/env python2
import re

class fc8pkt:
  pkts=[]
  debug=0
  sofs = {
  "c1"  :        "11717b5bc",
  "c4"  :        "11919b5bc",
  "f"   :        "15858b5bc",
  "i1"  :        "15757b5bc",
  "i2"  :        "15555b5bc",
  "i3"  :        "15656b5bc",
  "i4"  :        "15959b5bc",
  "n1"  :        "13737b5bc",
  "n2"  :        "13535b5bc",
  "n3"  :        "13636b5bc",
  "n4"  :        "13939b5bc"
  }
  # The first parameter byte of the EOF primitive can have one of four different values (8A, 95, AA, or B5).
  eofs = {
  "an"         :        "1f5f595bc",
  "ap"         :        "1f5f5b5bc",
  "dtin"       :        "195958abc",
  "dtip"       :        "19595aabc",
  "dtn"        :        "1959595bc",
  "dtp"        :        "19595b5bc",
  "fn"         :        "1757595bc",
  "fp"         :        "17575b5bc",
  "nin"        :        "1d5d58abc",
  "nip"        :        "1d5d5aabc",
  "nn"         :        "1d5d595bc",
  "np"         :        "1d5d5b5bc",
  }
  primitives={
  "rrdy"        :       "14a4a95bc",
  "idle"        :       "1ffff94bc",
  "ols"         :       "1558a35bc",
  "nos"         :       "145bf55bc",
  "lr"          :       "149bf49bc",
  "lrr"         :       "149bf35bc"
  }
  dtable=[
  (0x0b9,0x346,0), # D00.0
  (0x0ae,0x351,0), # D01.0
  (0x0ad,0x352,0), # D02.0
  (0x363,0x0a3,1), # D03.0
  (0x0ab,0x354,0), # D04.0
  (0x365,0x0a5,1), # D05.0
  (0x366,0x0a6,1), # D06.0
  (0x347,0x0b8,1), # D07.0
  (0x0a7,0x358,0), # D08.0
  (0x369,0x0a9,1), # D09.0
  (0x36a,0x0aa,1), # D10.0
  (0x34b,0x08b,1), # D11.0
  (0x36c,0x0ac,1), # D12.0
  (0x34d,0x08d,1), # D13.0
  (0x34e,0x08e,1), # D14.0
  (0x0ba,0x345,0), # D15.0
  (0x0b6,0x349,0), # D16.0
  (0x371,0x0b1,1), # D17.0
  (0x372,0x0b2,1), # D18.0
  (0x353,0x093,1), # D19.0
  (0x374,0x0b4,1), # D20.0
  (0x355,0x095,1), # D21.0
  (0x356,0x096,1), # D22.0
  (0x097,0x368,0), # D23.0
  (0x0b3,0x34c,0), # D24.0
  (0x359,0x099,1), # D25.0
  (0x35a,0x09a,1), # D26.0
  (0x09b,0x364,0), # D27.0
  (0x35c,0x09c,1), # D28.0
  (0x09d,0x362,0), # D29.0
  (0x09e,0x361,0), # D30.0
  (0x0b5,0x34a,0), # D31.0
  (0x279,0x246,1), # D00.1
  (0x26e,0x251,1), # D01.1
  (0x26d,0x252,1), # D02.1
  (0x263,0x263,0), # D03.1
  (0x26b,0x254,1), # D04.1
  (0x265,0x265,0), # D05.1
  (0x266,0x266,0), # D06.1
  (0x247,0x278,0), # D07.1
  (0x267,0x258,1), # D08.1
  (0x269,0x269,0), # D09.1
  (0x26a,0x26a,0), # D10.1
  (0x24b,0x24b,0), # D11.1
  (0x26c,0x26c,0), # D12.1
  (0x24d,0x24d,0), # D13.1
  (0x24e,0x24e,0), # D14.1
  (0x27a,0x245,1), # D15.1
  (0x276,0x249,1), # D16.1
  (0x271,0x271,0), # D17.1
  (0x272,0x272,0), # D18.1
  (0x253,0x253,0), # D19.1
  (0x274,0x274,0), # D20.1
  (0x255,0x255,0), # D21.1
  (0x256,0x256,0), # D22.1
  (0x257,0x268,1), # D23.1
  (0x273,0x24c,1), # D24.1
  (0x259,0x259,0), # D25.1
  (0x25a,0x25a,0), # D26.1
  (0x25b,0x264,1), # D27.1
  (0x25c,0x25c,0), # D28.1
  (0x25d,0x262,1), # D29.1
  (0x25e,0x261,1), # D30.1
  (0x275,0x24a,1), # D31.1
  (0x2b9,0x286,1), # D00.2
  (0x2ae,0x291,1), # D01.2
  (0x2ad,0x292,1), # D02.2
  (0x2a3,0x2a3,0), # D03.2
  (0x2ab,0x294,1), # D04.2
  (0x2a5,0x2a5,0), # D05.2
  (0x2a6,0x2a6,0), # D06.2
  (0x287,0x2b8,0), # D07.2
  (0x2a7,0x298,1), # D08.2
  (0x2a9,0x2a9,0), # D09.2
  (0x2aa,0x2aa,0), # D10.2
  (0x28b,0x28b,0), # D11.2
  (0x2ac,0x2ac,0), # D12.2
  (0x28d,0x28d,0), # D13.2
  (0x28e,0x28e,0), # D14.2
  (0x2ba,0x285,1), # D15.2
  (0x2b6,0x289,1), # D16.2
  (0x2b1,0x2b1,0), # D17.2
  (0x2b2,0x2b2,0), # D18.2
  (0x293,0x293,0), # D19.2
  (0x2b4,0x2b4,0), # D20.2
  (0x295,0x295,0), # D21.2
  (0x296,0x296,0), # D22.2
  (0x297,0x2a8,1), # D23.2
  (0x2b3,0x28c,1), # D24.2
  (0x299,0x299,0), # D25.2
  (0x29a,0x29a,0), # D26.2
  (0x29b,0x2a4,1), # D27.2
  (0x29c,0x29c,0), # D28.2
  (0x29d,0x2a2,1), # D29.2
  (0x29e,0x2a1,1), # D30.2
  (0x2b5,0x28a,1), # D31.2
  (0x339,0x0c6,1), # D00.3
  (0x32e,0x0d1,1), # D01.3
  (0x32d,0x0d2,1), # D02.3
  (0x0e3,0x323,0), # D03.3
  (0x32b,0x0d4,1), # D04.3
  (0x0e5,0x325,0), # D05.3
  (0x0e6,0x326,0), # D06.3
  (0x0c7,0x338,0), # D07.3
  (0x327,0x0d8,1), # D08.3
  (0x0e9,0x329,0), # D09.3
  (0x0ea,0x32a,0), # D10.3
  (0x0cb,0x30b,0), # D11.3
  (0x0ec,0x32c,0), # D12.3
  (0x0cd,0x30d,0), # D13.3
  (0x0ce,0x30e,0), # D14.3
  (0x33a,0x0c5,1), # D15.3
  (0x336,0x0c9,1), # D16.3
  (0x0f1,0x331,0), # D17.3
  (0x0f2,0x332,0), # D18.3
  (0x0d3,0x313,0), # D19.3
  (0x0f4,0x334,0), # D20.3
  (0x0d5,0x315,0), # D21.3
  (0x0d6,0x316,0), # D22.3
  (0x317,0x0e8,1), # D23.3
  (0x333,0x0cc,1), # D24.3
  (0x0d9,0x319,0), # D25.3
  (0x0da,0x31a,0), # D26.3
  (0x31b,0x0e4,1), # D27.3
  (0x0dc,0x31c,0), # D28.3
  (0x31d,0x0e2,1), # D29.3
  (0x31e,0x0e1,1), # D30.3
  (0x335,0x0ca,1), # D31.3
  (0x139,0x2c6,0), # D00.4
  (0x12e,0x2d1,0), # D01.4
  (0x12d,0x2d2,0), # D02.4
  (0x2e3,0x123,1), # D03.4
  (0x12b,0x2d4,0), # D04.4
  (0x2e5,0x125,1), # D05.4
  (0x2e6,0x126,1), # D06.4
  (0x2c7,0x138,1), # D07.4
  (0x127,0x2d8,0), # D08.4
  (0x2e9,0x129,1), # D09.4
  (0x2ea,0x12a,1), # D10.4
  (0x2cb,0x10b,1), # D11.4
  (0x2ec,0x12c,1), # D12.4
  (0x2cd,0x10d,1), # D13.4
  (0x2ce,0x10e,1), # D14.4
  (0x13a,0x2c5,0), # D15.4
  (0x136,0x2c9,0), # D16.4
  (0x2f1,0x131,1), # D17.4
  (0x2f2,0x132,1), # D18.4
  (0x2d3,0x113,1), # D19.4
  (0x2f4,0x134,1), # D20.4
  (0x2d5,0x115,1), # D21.4
  (0x2d6,0x116,1), # D22.4
  (0x117,0x2e8,0), # D23.4
  (0x133,0x2cc,0), # D24.4
  (0x2d9,0x119,1), # D25.4
  (0x2da,0x11a,1), # D26.4
  (0x11b,0x2e4,0), # D27.4
  (0x2dc,0x11c,1), # D28.4
  (0x11d,0x2e2,0), # D29.4
  (0x11e,0x2e1,0), # D30.4
  (0x135,0x2ca,0), # D31.4
  (0x179,0x146,1), # D00.5
  (0x16e,0x151,1), # D01.5
  (0x16d,0x152,1), # D02.5
  (0x163,0x163,0), # D03.5
  (0x16b,0x154,1), # D04.5
  (0x165,0x165,0), # D05.5
  (0x166,0x166,0), # D06.5
  (0x147,0x178,0), # D07.5
  (0x167,0x158,1), # D08.5
  (0x169,0x169,0), # D09.5
  (0x16a,0x16a,0), # D10.5
  (0x14b,0x14b,0), # D11.5
  (0x16c,0x16c,0), # D12.5
  (0x14d,0x14d,0), # D13.5
  (0x14e,0x14e,0), # D14.5
  (0x17a,0x145,1), # D15.5
  (0x176,0x149,1), # D16.5
  (0x171,0x171,0), # D17.5
  (0x172,0x172,0), # D18.5
  (0x153,0x153,0), # D19.5
  (0x174,0x174,0), # D20.5
  (0x155,0x155,0), # D21.5
  (0x156,0x156,0), # D22.5
  (0x157,0x168,1), # D23.5
  (0x173,0x14c,1), # D24.5
  (0x159,0x159,0), # D25.5
  (0x15a,0x15a,0), # D26.5
  (0x15b,0x164,1), # D27.5
  (0x15c,0x15c,0), # D28.5
  (0x15d,0x162,1), # D29.5
  (0x15e,0x161,1), # D30.5
  (0x175,0x14a,1), # D31.5
  (0x1b9,0x186,1), # D00.6
  (0x1ae,0x191,1), # D01.6
  (0x1ad,0x192,1), # D02.6
  (0x1a3,0x1a3,0), # D03.6
  (0x1ab,0x194,1), # D04.6
  (0x1a5,0x1a5,0), # D05.6
  (0x1a6,0x1a6,0), # D06.6
  (0x187,0x1b8,0), # D07.6
  (0x1a7,0x198,1), # D08.6
  (0x1a9,0x1a9,0), # D09.6
  (0x1aa,0x1aa,0), # D10.6
  (0x18b,0x18b,0), # D11.6
  (0x1ac,0x1ac,0), # D12.6
  (0x18d,0x18d,0), # D13.6
  (0x18e,0x18e,0), # D14.6
  (0x1ba,0x185,1), # D15.6
  (0x1b6,0x189,1), # D16.6
  (0x1b1,0x1b1,0), # D17.6
  (0x1b2,0x1b2,0), # D18.6
  (0x193,0x193,0), # D19.6
  (0x1b4,0x1b4,0), # D20.6
  (0x195,0x195,0), # D21.6
  (0x196,0x196,0), # D22.6
  (0x197,0x1a8,1), # D23.6
  (0x1b3,0x18c,1), # D24.6
  (0x199,0x199,0), # D25.6
  (0x19a,0x19a,0), # D26.6
  (0x19b,0x1a4,1), # D27.6
  (0x19c,0x19c,0), # D28.6
  (0x19d,0x1a2,1), # D29.6
  (0x19e,0x1a1,1), # D30.6
  (0x1b5,0x18a,1), # D31.6
  (0x239,0x1c6,0), # D00.7
  (0x22e,0x1d1,0), # D01.7
  (0x22d,0x1d2,0), # D02.7
  (0x1e3,0x223,1), # D03.7
  (0x22b,0x1d4,0), # D04.7
  (0x1e5,0x225,1), # D05.7
  (0x1e6,0x226,1), # D06.7
  (0x1c7,0x238,1), # D07.7
  (0x227,0x1d8,0), # D08.7
  (0x1e9,0x229,1), # D09.7
  (0x1ea,0x22a,1), # D10.7
  (0x1cb,0x04b,1), # D11.7
  (0x1ec,0x22c,1), # D12.7
  (0x1cd,0x04d,1), # D13.7
  (0x1ce,0x04e,1), # D14.7
  (0x23a,0x1c5,0), # D15.7
  (0x236,0x1c9,0), # D16.7
  (0x3b1,0x231,1), # D17.7
  (0x3b2,0x232,1), # D18.7
  (0x1d3,0x213,1), # D19.7
  (0x3b4,0x234,1), # D20.7
  (0x1d5,0x215,1), # D21.7
  (0x1d6,0x216,1), # D22.7
  (0x217,0x1e8,0), # D23.7
  (0x233,0x1cc,0), # D24.7
  (0x1d9,0x219,1), # D25.7
  (0x1da,0x21a,1), # D26.7
  (0x21b,0x1e4,0), # D27.7
  (0x1dc,0x21c,1), # D28.7
  (0x21d,0x1e2,0), # D29.7
  (0x21e,0x1e1,0), # D30.7
  (0x235,0x1ca,0)  # D31.7
  ]
  ktable={
  0x1c : (0x0bc,0x343,0), # K28.0
  0x3c : (0x27c,0x183,1), # K28.1
  0x5c : (0x2bc,0x143,1), # K28.2
  0x7c : (0x33c,0x0c3,1), # K28.3
  0x9c : (0x13c,0x2c3,0), # K28.4
  0xbc : (0x17c,0x283,1), # K28.5
  0xdc : (0x1bc,0x243,1), # K28.6
  0xf7 : (0x057,0x3a8,0), # K23.7
  0xfb : (0x05b,0x3a4,0), # K27.7
  0xfc : (0x07c,0x383,0), # K28.7
  0xfd : (0x05d,0x3a2,0), # K29.7
  0xfe : (0x05e,0x3a1,0)  # K30.7
  }
  sofs_r={}
  eofs_r={}
  primitives_r={}
  extract_flag=0
  idle_code=[]
  rd=0
  def __init__(self,debug=0):
    """
    """
    self.debug = debug
    self.sofs_r={}
    [self.sofs_r.update({self.sofs[x]:x}) for x in self.sofs]
    self.eofs_r={}
    [self.eofs_r.update({self.eofs[x]:x}) for x in self.eofs]
    self.primitives_r={}
    [self.primitives_r.update({self.primitives[x]:x}) for x in self.primitives]
    idle_code=self.b8b10_encode('{0:04b}'.format(int(self.primitives['idle'][0],16)),map(lambda x: int(x,16),filter(lambda x: x!='',re.split('([0-9a-f][0-9a-f])',self.primitives['idle'][1:]))))

  def pkt_extract(self,file):
    """
    """
    INFILE=open(file,"r")
    lines=INFILE.readlines()
    valid=0
    self.extract_flag=1
    while lines:
      line=lines.pop(0).strip()
      if ';' not in line or ':' not in line: continue
      index=line.index(';')
      line=line[:index]
      index=line.index(':')
      line=line[index+1:].strip()
      codes=self.b8b10_encode('{0:04b}'.format(int(line[0],16)),map(lambda x: int(x,16),filter(lambda x: x!='',re.split('([0-9a-f][0-9a-f])',line[1:]))))
      if line[0] == '0': # data
        if valid:
          pkt.append((codes,self.rd,''))
      elif line[0] == '1': # primitive
        if self.sofs_r.has_key(line):
          pkt=[]
          pkt.append((codes,self.rd,'SOF' + self.sofs_r[line]))
          valid=1
        elif self.eofs_r.has_key(line):
          pkt.append((codes,self.rd,'EOF' + self.eofs_r[line]))
          self.pkts.append(pkt)
          valid=0
        elif self.primitives_r.has_key(line):
          pkt=[]
          pkt.append((codes,self.rd,self.primitives_r[line]))
          self.pkts.append(pkt)
        else:
          print "ERROR: primitive not found %s" % line
      else:
        print "ERROR: not a data and not a primitive %s" % line

  def b8b10_convert(self,file):
    """
    """
    INFILE=open(file,"r")
    lines=INFILE.readlines()
    while lines:
      line=lines.pop(0).strip()
      if ';' not in line or ':' not in line: continue
      index=line.index(';')
      line=line[:index]
      index=line.index(':')
      line=line[index+1:].strip()
      codes=self.b8b10_encode('{0:04b}'.format(int(line[0],16)),map(lambda x: int(x,16),filter(lambda x: x!='',re.split('([0-9a-f][0-9a-f])',line[1:]))))
      if line[0] == '0': # data
        self.pkts.append((codes,self.rd,''))
      elif line[0] == '1': # primitive
        if self.sofs_r.has_key(line):
          self.pkts.append((codes,self.rd,'SOF' + self.sofs_r[line]))
        elif self.eofs_r.has_key(line):
          self.pkts.append((codes,self.rd,'EOF' + self.eofs_r[line]))
        elif self.primitives_r.has_key(line):
          self.pkts.append((codes,self.rd,self.primitives_r[line]))
        else:
          print "ERROR: primitive not found %s" % line
      else:
        print "ERROR: not a data and not a primitive %s" % line

  def b8b10_encode(self,ctrl,bytes):
    """
    """
    codes=[]
    #for i,byte in enumerate(bytes):
    #  if ctrl[i] == '1': # kchar
    for i,byte in enumerate(bytes[::-1]):
      if ctrl[3-i] == '1': # kchar
        codes.append(self.ktable[byte][self.rd])
        if self.ktable[byte][2]:
          if self.rd == 0:
            self.rd = 1
          else:
            self.rd = 0
      else: # data
        #print "%x"%byte,self.rd
        codes.append(self.dtable[byte][self.rd])
        if self.dtable[byte][2]:
          if self.rd == 0:
            self.rd = 1
          else:
            self.rd = 0
    #return codes
    return codes[::-1]
  def write_mif(self,file,ipg=0):
    """
    """
    OUTFILE=open(file,"w")
    outs=[]
    lines=[]
    if self.extract_flag:
      for pkt in self.pkts:
        lines.extend(pkt)
        lines.extend(map(lambda x: (idle_code,0,'idle'),range(ipg))) 
    else:
      lines.extend(self.pkts)
    outs.append('''
DEPTH=%d;
WIDTH=72;
ADDRESS_RADIX=UNS;
DATA_RADIX=HEX;
  
CONTENT BEGIN
'''%len(lines))
    count=0
    for i,(codes,rund,comment) in enumerate(lines):
      if self.debug == 1:
        outs.append("%10d : %08x%010x;    -- %-10s %s %d"%(i,0,int("".join(map(lambda x: "{0:010b}".format(x),codes)),2),comment, " ".join(map(lambda x: "{0:03x}".format(x),codes)),rund))
      else:
        if 'SOF' in comment:
          count+=1
          outs.append("%10d : %08x%010x;    -- %-10s %s pkt %d"%(i,0,int("".join(map(lambda x: "{0:010b}".format(x),codes)),2),comment, " ".join(map(lambda x: "{0:03x}".format(x),codes)),count))
        else:
          outs.append("%10d : %08x%010x;    -- %-10s %s"%(i,0,int("".join(map(lambda x: "{0:010b}".format(x),codes)),2),comment, " ".join(map(lambda x: "{0:03x}".format(x),codes))))
    outs.append('END;')
    print "\n".join(outs)
    OUTFILE.write("\n".join(outs))
    OUTFILE.close()
    
    
      



if __name__ == "__main__":
  """
  """
  import sys
  argc=len(sys.argv)
  if argc > 1 : dommif = sys.argv[1]
  if argc > 2 : bamif  = sys.argv[2]

  
  obj= fc8pkt(0)
  obj.b8b10_convert(dommif)
  obj.write_mif(bamif)
