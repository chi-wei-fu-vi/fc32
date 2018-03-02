#!/usr/bin/env python2
import os
import gzip
import zlib
import struct
import time
pkts=[]
IPG_LEN  = 12
MAX_DEP  = 2048
 
sym2byte={
"I" : "07",
"S" : "fb",
"T" : "fd",
"E" : "fe"
}
preambles=[0xfb,0x55,0x55,0x55,0x55,0x55,0x55,0xd5]
def gunzip (file,ext): 
  """
  Generate k12 text format from pcap file
  """
  INFILE=gzip.open("%s%s"%(file,ext),'rb')
  OUTFILE=open(file,'wb')
  OUTFILE.write(INFILE.read())
  OUTFILE.close()
  INFILE.close()
  
def readpcap(file):
  """
  packet format:
    Global Header 
    Packet Header 
    Packet Data 
    Packet Header 
    Packet Data 
    Packet Header 
    Packet Data ... 
  """
  INFILE=open(file,"rb")
  data=INFILE.read()
  return data

def global_header(data):
  """
  Global Header 
  typedef struct pcap_hdr_s { 
   guint32 magic_number; /* magic number */ 
   guint16 version_major; /* major version number */ 
   guint16 version_minor; /* minor version number */ 
   gint32 thiszone; /* GMT to local correction */ 
   guint32 sigfigs; /* accuracy of timestamps */ 
   guint32 snaplen; /* max length of captured packets, in octets */ 
   guint32 network; /* data link type */ 
  } pcap_hdr_t; 
  """
  magic_number,version_major,version_minor,thiszone,sigfigs,snaplen,network=struct.unpack('<I2Hi3I',data[:24])
  #print magic_number,version_major,version_minor,thiszone,sigfigs,snaplen,network
  if magic_number == 0xa1b2c3d4:
    swap=0
  elif magic_number == 0xd4c3b2a1:
    swap=1
  else:
    print "Error: Not pcap file"
    exit(1)
  #print swap
  return data[24:]
def packet_extract(data):
  """
  typedef struct pcaprec_hdr_s { 
   guint32 ts_sec; /* timestamp seconds */ 
   guint32 ts_usec; /* timestamp microseconds */ 
   guint32 incl_len; /* number of octets of packet saved in file */ 
   guint32 orig_len; /* actual length of packet */ 
  } pcaprec_hdr_t; 
  """
  bytes=[]
  ts_sec, ts_usec, incl_len, orig_len=struct.unpack('4I',data[:16])
  (tm_year, tm_mon, tm_mday, tm_hour, tm_min, tm_sec, tm_wday, tm_yday, tm_isdst)=time.localtime(ts_sec)
  #print tm_year, tm_mon, tm_mday, tm_hour, tm_min, tm_sec, tm_wday, tm_yday, tm_isdst
  #print time.localtime(ts_sec)
  #print ts_sec, ts_usec, incl_len, orig_len
  data=data[16:]
  bytes.extend(struct.unpack('%dB'%incl_len,data[:incl_len]))
  #print map(lambda x: "%02x"%x,bytes)
  pkts.append(bytes)
  return data[incl_len:]


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
        
def genmif(file):
  """   
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
  for bytes in pkts:
    # process preamble
    if (len(datas)*8 + len(data) + len(bytes)+ IPG_LEN +8+4+1) > MAX_DEP*8:
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
    idle_sz=IPG_LEN
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
   
def genmif_lword_align(file):
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
  for bytes in pkts:
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
  import sys
  argc=len(sys.argv)
  if argc > 1: gz_file   = sys.argv[1]
  (pcap,ext)=os.path.splitext(gz_file)
  print pcap,ext
  gunzip(pcap,ext)
  (name,ext)=os.path.splitext(pcap)
  data=readpcap(pcap)
  data=global_header(data)
  while data:
    data=packet_extract(data)
  #print pkts 
  #genmif(name)
  # lword align next packet
  genmif_lword_align(name)
