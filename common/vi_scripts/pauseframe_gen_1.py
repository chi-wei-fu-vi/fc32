#!/usr/bin/env python2
import xml.dom.minidom
import argparse
import re
import zlib
from pprint import pprint
import crcmod
da        = 0x0180c2000001
sa        = 0x90e2ba16deb0
ethertype = 0x8808
opcode    = 0x0001
parameter = 0x0000 # 0x0-0xffff
reserved  = [0]*42

IPG_LEN  = 12
MAX_DEP  = 2048
 
sym2byte={
"I" : "07",
"S" : "fb",
"T" : "fd",
"E" : "fe"
}
preambles=[0xfb,0x55,0x55,0x55,0x55,0x55,0x55,0xd5]

headers=[]
trailers=[]
ethpkts=[]

  
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



def pausepktgen():
  """
  """
  global da
  global sa
  global ethertype
  global opcode
  global parameter
  global reserved
  pkt=[]
  pkt.extend(map(lambda x: int(x,16),filter(lambda x:x!='',re.split('([0-9a-f][0-9a-f])','%012x'%da))))
  pkt.extend(map(lambda x: int(x,16),filter(lambda x:x!='',re.split('([0-9a-f][0-9a-f])','%012x'%sa))))
  pkt.extend(map(lambda x: int(x,16),filter(lambda x:x!='',re.split('([0-9a-f][0-9a-f])','%04x'%ethertype))))
  pkt.extend(map(lambda x: int(x,16),filter(lambda x:x!='',re.split('([0-9a-f][0-9a-f])','%04x'%opcode))))
  pkt.extend(map(lambda x: int(x,16),filter(lambda x:x!='',re.split('([0-9a-f][0-9a-f])','%04x'%parameter))))
  pkt.extend(reserved)
  #pkt.extend(map(lambda x: int(x,16),calcrc32(pkt))
  ethpkts.append(pkt)
    

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
  OUTFILE=open("%s.mif"%file,'w')
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
  print "\n".join(lines)
  OUTFILE.write("\n".join(lines))

   
if __name__ == '__main__':
  """
  """

  parser = argparse.ArgumentParser(description='Generating pause frame mif file',formatter_class=argparse.RawTextHelpFormatter)
  parser.add_argument("emerald_mif",type=str,help='Specify emerald mif file')
  args = parser.parse_args()
  emmif =args.emerald_mif
  pausepktgen()
  write_emmif(emmif)
