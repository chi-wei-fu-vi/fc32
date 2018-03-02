#!/usr/bin/env python2
import xml.dom.minidom
import argparse
import re
import zlib
from pprint import pprint
scrambled=True
da        = 0x90e2ba16deb1
sa        = 0x90e2ba16deb0
vlantype  = 0x8100
cos       = 3   # 3 bits
cfi       = 0   # 1 bits
vlanid    = 0x005 
ethertype = 0x8906
reserved  = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
sof_flag  = None
eof_flag  = None
SOF       = 0x2e
EOF       = 0x42

IPG_LEN  = 12
MAX_DEP  = 2048
 
sof = {
"c1" : "1717b5bc",
"i1" : "15757b5bc",
"n1" : "13737b5bc",
"i2" : "15555b5bc",
"n2" : "13535b5bc",
"i3" : "15656b5bc",
"n3": "13636b5bc",
"f" : "15858b5bc"
}
eof = {
"t_+" : "17575b5bc",
"t_-" : "1757595bc",
"dt_+" : "19595b5bc",
"dt_-" : "1959595bc",
"a_+" : "1f5f5b5bc",
"a_-" : "1f5f595bc",
"n_+" : "1d5d5b5bc",
"n_-" : "1d5d595bc",
"dti_+" : "19595aabc",
"dti_-" : "195958abc",
"ni_+" : "1d5d5aabc",
"ni_-" : "1d5d58abc"
}
sof_r={
 '13535b5bc': 'n2',
 '13636b5bc': 'n3',
 '13737b5bc': 'n1',
 '15555b5bc': 'i2',
 '15656b5bc': 'i3',
 '15757b5bc': 'i1',
 '15858b5bc': 'f',
 '1717b5bc': 'c1'}
eof_r={
 '1757595bc': 't_-',
 '17575b5bc': 't_+',
 '195958abc': 'dti_-',
 '1959595bc': 'dt_-',
 '19595aabc': 'dti_+',
 '19595b5bc': 'dt_+',
 '1d5d58abc': 'ni_-',
 '1d5d595bc': 'n_-',
 '1d5d5aabc': 'ni_+',
 '1d5d5b5bc': 'n_+',
 '1f5f595bc': 'a_-',
 '1f5f5b5bc': 'a_+'}

fcoe_sof = {
"i2" : "2d",
"n2" : "35",
"i3" : "2e",
"n3": "36",
"f" : "28"
}
fcoe_eof = {
"n" : "41",
"t" : "42",
"ni" : "49",
"a" : "50"
}

sym2byte={
"I" : "07",
"S" : "fb",
"T" : "fd",
"E" : "fe"
}
preambles=[0xfb,0x55,0x55,0x55,0x55,0x55,0x55,0xd5]

scr_seed = 0x0029438798327338 # the scramber seed specified by the FC specification
headers=[]
trailers=[]
pkts=[]
ethpkts=[]

def scramble5832_par(bytes):
  """
         radix-10            radix-16        radix-2 
  seed : 11614723698225976 , 29438798327338, 0000101001010000111000011110011000001100100111001100111000
  poly : x^58 + x^39 + 1
  """
  #lfsr=11614723698225976L
  lfsr=0x0029438798327338
  newbytes=[]
  while bytes:  
    word=bytes[:4]
    word.reverse()
    datain=int("".join(map(lambda x: "%02x"%x,word)),16)
    x58to27=(long(lfsr) >> 26) & 0xffffffff
    x39to8 =(long(lfsr) >> 7)  & 0xffffffff
    dataout=x58to27 ^ x39to8 ^ datain
    newword=filter(lambda x:x!='',re.split('([0-9a-f][0-9a-f])','%08x'%dataout))
    newword.reverse()
    newbytes.extend(map(lambda x: int(x,16),newword))
    lfsr=((long(lfsr) << 32) | long(dataout)) & 0x03ffffffffffffff
    bytes=bytes[4:]
  return newbytes
  

def descramble5832_par(bytes):
  """
         radix-10            radix-16        radix-2 
  seed : 11614723698225976 , 29438798327338, 0000101001010000111000011110011000001100100111001100111000
  poly : x^58 + x^39 + 1
  """
  #lfsr=11614723698225976L
  lfsr=0x0029438798327338
  newbytes=[]
  while bytes:  
    word=bytes[:4]
    word.reverse()
    datain=int("".join(map(lambda x: "%02x"%x,word)),16)
    x58to27=(long(lfsr) >> 26) & 0xffffffff
    x39to8 =(long(lfsr) >> 7)  & 0xffffffff
    dataout=x58to27 ^ x39to8 ^ datain
    newword=filter(lambda x:x!='',re.split('([0-9a-f][0-9a-f])','%08x'%dataout))
    newword.reverse()
    newbytes.extend(map(lambda x: int(x,16),newword))
    lfsr=((long(lfsr) << 32) | long(datain)) & 0x03ffffffffffffff
    bytes=bytes[4:]
  return newbytes
    
  
def calcrc32(bytes):
  """
  Calculate crc32
  """
  crcval=zlib.crc32("")
  for byte in bytes:  
    crcval=zlib.crc32(chr(byte),crcval)
  if crcval >= 0:
    crcval="%08x" % crcval
  else:
    crcval=-crcval
    crcval= "%08x" % ((crcval ^ 0xFFFFFFFF) + 1)
  return reverse_byte(crcval)


def reverse_byte(value):
  """
  """
  outs=[]
  while value:
    outs.append(value[:2])
    value=value[2:]
  outs.reverse()
  return outs

def parse_pkt(lines):
  """
1 : 15656b5bc; --SOFi3
2 : 000000001;
......
52 : 06c5a4144;
53 : 0a9f8361a;
54 : 1d5d595bc; --EOFn(-)
  """
  data=[]
  while lines:
    line=lines.pop(0).strip()
    if 'EOF' in line:
      pkts.append(data)
      index=line.index(';')
      line=line[:index]
      index=line.index(':')
      line=line[index+1:].strip()
      if len(line) !=9: print "Error : not 9 hex digits %s" %line
      if line[0] != '1': print "Error: not eof %s" % line
      eof_flag=line
      return (eof_flag,lines)
    else:
      index=line.index(':')
      line=line[index+2:-1]
      if len(line) !=9: print "Error : not 9 hex digits %s" %line
      if line[0] != '0': print "Error: not data %s" % line
      fourbytes=filter(lambda x:x!='',re.split('([0-9a-f][0-9a-f])',line[1:]))
      fourbytes.reverse()
      data.extend(map(lambda x: int(x,16),fourbytes))

      
def read_dommif(file):
  """
  """
  global sof_flag
  global eof_flag
  INFILE=open(file,"r")
  lines=INFILE.readlines()
  while lines:
    line=lines.pop(0).strip()
    if 'SOF' in line:
      index=line.index(';')
      line=line[:index]
      index=line.index(':')
      line=line[index+1:].strip()
      if len(line) !=9: print "Error : not 9 hex digits %s" %line
      if line[0] != '1': print "Error: not sof %s" % line
      sof_flag=line
      (eof_flag,lines)=parse_pkt(lines)

def descramble_and_ethpktgen():
  """
  """
  for pkt in pkts:
    outs=endian_reverse(descramble5832_par(endian_reverse(pkt)))
    ethpkt=[]
    if len(pkt)%4: print "Error fc packet length violation",pkt
    ethpkt.extend(map(lambda x:int(x,16),headers))
    ethpkt.extend(outs)
    ethpkt.extend(map(lambda x:int(x,16),trailers))
    ethpkts.append(ethpkt)

def ethpktgen():
  """
  """
  for pkt in pkts:
    ethpkt=[]
    if len(pkt)%4: print "Error fc packet length violation",pkt
    ethpkt.extend(map(lambda x:int(x,16),headers))
    ethpkt.extend(pkt)
    ethpkt.extend(map(lambda x:int(x,16),trailers))
    ethpkts.append(ethpkt)
    
    
def assemble_header():
  """
  """
  global da
  global sa
  global vlantype
  global cos
  global cfi
  global vlanid
  global ethertype
  global reserved
  global SOF
  headers.extend(filter(lambda x:x!='',re.split('([0-9a-f][0-9a-f])','%012x'%da)))
  headers.extend(filter(lambda x:x!='',re.split('([0-9a-f][0-9a-f])','%012x'%sa)))
  headers.extend(filter(lambda x:x!='',re.split('([0-9a-f][0-9a-f])','%04x'%vlantype)))
  headers.extend(filter(lambda x:x!='',re.split('([0-9a-f][0-9a-f])','%04x'%(cos<<13|cfi<<12|vlanid))))
  headers.extend(filter(lambda x:x!='',re.split('([0-9a-f][0-9a-f])','%04x'%ethertype)))
  headers.extend(map(lambda x: '%02x'%x,reserved))
  if sof_flag is None:
    headers.append('%02x'%SOF)
  else:
    headers.append(fcoe_sof[sof_r[sof_flag]])
  #print "".join(headers)

def assemble_trailer():
  """
  """
  global eof_flag
  if eof_flag is None:
    trailers.append('%02x'%EOF)
  else:
    flag=eof_r[eof_flag]
    index=flag.index('_')
    flag=flag[:index]
    trailers.append(fcoe_eof[flag])
  trailers.extend(map(lambda x: '%02x'%x,[0,0,0]))
  #print "".join(trailers)

def endian_reverse(bytes):
  """
  """
  data=[]
  while bytes:
    fourbytes=bytes[:4]
    fourbytes.reverse()
    data.extend(fourbytes)
    bytes=bytes[4:]
  return data




def calcrc32(bytes):
  """
  Calculate crc32
  """
  crcval=zlib.crc32("")
  for byte in bytes:  
    crcval=zlib.crc32(chr(byte),crcval)
  if crcval >= 0:
    crcval="%08x" % crcval
  else:
    crcval=-crcval
    crcval= "%08x" % ((crcval ^ 0xFFFFFFFF) + 1)
  return reverse_byte(crcval)

def reverse_byte(value):
  """
  """
  outs=[]
  while value:
    outs.append(value[:2])
    value=value[2:]
  outs.reverse()
  return outs

def header(depth):
  """
  """
  return """
DEPTH=%d;
WIDTH=72;
ADDRESS_RADIX=UNS;
DATA_RADIX=HEX;

CONTENT BEGIN
"""%depth
        
   
def write_emmif(file):
  """   
  lword align next packet
  prepend preamble
  postpend crc
  """   
  global IPG_LEN
  global MAX_DEP
  OUTFILE=open(file,'w')
  datas=[]
  ctrls=[]
  comments=[]
  data=[]
  ctrl=0
  comment=""
  pktnum = 0
  for bytes in ethpkts:
    pktnum += 1
    # process preamble
    if (IPG_LEN-(8-(len(bytes)+8+4+1)%8))%8 == 0:
      idle_sz=IPG_LEN
    else:
      idle_sz=IPG_LEN+(8-(IPG_LEN-(8-(len(bytes)+8+4+1)%8))%8)
    if (len(datas)*8 + len(data) + len(bytes)+ idle_sz +8+4+1) > MAX_DEP*8:
      break
    count=0
    while count != 8:
      sz=len(data)
      avail_slot=8-sz
      if avail_slot > (8-count): # not include /S/
        data.extend(preambles[count:])
        comment=' '*(8-count)+comment
        count=8
      elif avail_slot == (8-count): # possible include /S/
        if count == 0:
          ctrl+= (1 << sz)
          comment="S"+comment
          comment=' '*(avail_slot-1)+comment
        else:
          comment=' '*(avail_slot)+comment
          comment="S"+comment
        data.extend(preambles[count:])
        data.reverse()
        datas.append(data)
        ctrls.append(ctrl)
        if 'S' in comment:
          comment="%s  pkt %d"%(comment,pktnum)
        comments.append(comment)
        data=[]
        ctrl=0
        comment=""
        count=8
      else: # avail_slot < (8-count)
        if count == 0:
          ctrl+= (1 << sz)
          comment="S"+comment
          comment=' '*(avail_slot-1)+comment
        else:
          comment=' '*(avail_slot)+comment
        data.extend(preambles[count:count+avail_slot])
        data.reverse()
        datas.append(data)
        ctrls.append(ctrl)
        if 'S' in comment:
          comment="%s  pkt %d"%(comment,pktnum)
        comments.append(comment)
        data=[]
        ctrl=0
        comment=""
        count+=avail_slot
    # process data
    count=0
    payload_sz=len(bytes)
    while count != payload_sz:
      sz=len(data)
      avail_slot=8-sz
      if avail_slot > (payload_sz-count):
        data.extend(bytes[count:])
        comment=' '*(payload_sz-count)+comment
        count=payload_sz
      elif avail_slot == (payload_sz-count):
        comment=' '*(avail_slot)+comment
        data.extend(bytes[count:])
        data.reverse()
        datas.append(data)
        ctrls.append(ctrl)
        comments.append(comment)
        data=[]
        ctrl=0
        comment=""
        count=payload_sz
      else: # avail_slot < (payload_sz-count)
        comment=' '*(avail_slot)+comment
        data.extend(bytes[count:count+avail_slot])
        data.reverse()
        datas.append(data)
        ctrls.append(ctrl)
        comments.append(comment)
        data=[]
        ctrl=0
        comment=""
        count+=avail_slot
    # process crc
    crcs=[]
    crcs.extend(map(lambda x: int(x,16),calcrc32(bytes)))
    count=0
    while count != 4:
      sz=len(data)
      avail_slot=8-sz
      if avail_slot > (4-count):
        data.extend(crcs[count:])
        comment=' '*(4-count)+comment
        count=4
      elif avail_slot == (4-count):
        comment=' '*(avail_slot)+comment
        data.extend(crcs[count:])
        data.reverse()
        datas.append(data)
        ctrls.append(ctrl)
        comments.append(comment)
        data=[]
        ctrl=0
        comment=""
        count=4
      else: # avail_slot < (4-count)
        comment=' '*(avail_slot)+comment
        data.extend(crcs[count:count+avail_slot])
        data.reverse()
        datas.append(data)
        ctrls.append(ctrl)
        comments.append(comment)
        data=[]
        ctrl=0
        comment=""
        count+=avail_slot
    # add /T/
    sz=len(data)
    ctrl+= (1 << sz)
    data.append(0xfd)
    comment="T"+comment
    if sz == 7:
      data.reverse()
      datas.append(data)
      ctrls.append(ctrl)
      comments.append(comment)
      data=[]
      ctrl=0
      comment=""
    # add /I/
    count=0
    if (IPG_LEN-(8-len(data)))%8 == 0:
      idle_sz=IPG_LEN
    else:
      idle_sz=IPG_LEN+(8-(IPG_LEN-(8-len(data)))%8)
    while count != idle_sz:
      sz=len(data)
      avail_slot=8-sz
      if avail_slot > (idle_sz-count):
        for i in range(idle_sz-count):
          data.append(0x07)
          comment="I"+comment
          ctrl+= (1 << (sz+i))
        count=idle_sz
      elif avail_slot == (idle_sz-count):
        for i in range(idle_sz-count):
          data.append(0x07)
          comment="I"+comment
          ctrl+= (1 << (sz+i))
        data.reverse()
        datas.append(data)
        ctrls.append(ctrl)
        comments.append(comment)
        data=[]
        ctrl=0
        comment=""
        count=idle_sz
      else: # avail_slot < (idle_sz-count)
        for i in range(avail_slot):
          data.append(0x07)
          comment="I"+comment
          ctrl+= (1 << (sz+i))
        data.reverse()
        datas.append(data)
        ctrls.append(ctrl)
        comments.append(comment)
        data=[]
        ctrl=0
        comment=""
        count+=avail_slot
      
  # fill idle
  sz=len(data)
  if sz > 0:
    for i in range(8-sz):
      data.append(0x07)
      ctrl+= (1 << (sz+i))
      comment="I"+comment
    data.reverse()
    datas.append(data)
    ctrls.append(ctrl)
    comments.append(comment)

  lines=[]
  sublines=[]
  for count,data in enumerate(datas):
    ctrl=ctrls[count]
    comment=comments[count]
    if comment == ' '*8:
      sublines.append("%10d : %02x%s;"%(count,ctrl,"".join(map(lambda x: "%02x"%x,data))))
    else:
      sublines.append("%10d : %02x%s;    -- %s"%(count,ctrl,"".join(map(lambda x: "%02x"%x,data)),comment))
    
  lines.append(header(count+1))
  lines.extend(sublines)
  lines.append("END;")
  #print "\n".join(lines)
  OUTFILE.write("\n".join(lines))

   
   

if __name__ == "__main__":
  """
  """
  parser = argparse.ArgumentParser(description='Generating emerald mif file from dominica mif file',formatter_class=argparse.RawTextHelpFormatter)
  parser.add_argument("dominica_mif",type=str,help='Specify dominica mif file')
  parser.add_argument("emerald_mif",type=str,help='Specify emerald mif file')
  args = parser.parse_args()
  dommif=args.dominica_mif
  emmif =args.emerald_mif
  read_dommif(dommif)
  assemble_header()
  assemble_trailer()
  if 'scramble' in dommif:
    descramble_and_ethpktgen()
  else:
    ethpktgen()
  if len(ethpkts) > 0:
    write_emmif(emmif)
  else:
    print "Error: No FCOE packet found"
