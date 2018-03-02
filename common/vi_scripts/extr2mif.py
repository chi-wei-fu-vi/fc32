#!/usr/bin/env python
import os
import re
import xlrd
datas=[]
partitions=[
'FCoE data',
'Pause frame',
'Reserved',
'Reserved'
]
extr_bytes=[[],[],[],[]]
extr_extrs=[[],[],[],[]]
extr_grps=[[],[],[],[]]

header='''
WIDTH=72;
DEPTH=256;
ADDRESS_RADIX=HEX;
DATA_RADIX=HEX;
CONTENT BEGIN'''
def writemif(file):
  """
  """
  lines=[]
  lines.append(header)
  OUTFILE=open(file,'w')
  for p,bytes in enumerate(extr_bytes):
    if len(bytes)==0:
      datas.extend(['%016x'%0]*64)
      continue
    max_dwd=max(bytes)//8 + 1
    grp_idx=0
    for i in range(max_dwd):
      opcode=1
      offset=i
      bytes=[0]*4+[4]*4
      extr=0
      for j in range(2):
        f4bytes=map(lambda x:x-i*8,filter(lambda x:x<(i*8+4*(j+1)) and x >= (i*8+4*j),extr_bytes[p]))
        size=len(f4bytes)
        f4extrs=extr_extrs[p][grp_idx:grp_idx+size]
        f4grps =extr_grps[p][grp_idx:grp_idx+size]
        grp_idx+=size
        #print size,f4bytes,f4extrs,f4grps
        
        if True:
          for b in range(size):
            bytes[4-size+b+j*4]=f4bytes[b]
            extr+=1<<(3+size-b-j*4)
        else:
          for byte,b in zip(f4bytes,f4extrs):
            bytes[b]=byte
            extr+=1<<(7-b)
     
      #print bytes
      #print '{0:08b}'.format(extr)
      #print '{0:021b}_{1:s}_{2:08b}_{3:09b}_{4:02b}'.format(0,"".join(map(lambda x: '{0:03b}'.format(x),bytes)),extr,offset,opcode)
      data_b='{0:021b}{1:s}{2:08b}{3:09b}{4:02b}'.format(0,"".join(map(lambda x: '{0:03b}'.format(x),bytes)),extr,offset,opcode)
      data_h="".join(map(lambda x: "%x"%int(x,2),filter(lambda x: x!='',re.split('([01][01][01][01])',data_b))))
      #print data_h
      datas.append(data_h)
    datas.extend(['%016x'%0]*(64-max_dwd))


       
  lines.extend(map(lambda x: '%10x   :  %02x%s;'%(x,0,datas[x]),range(len(datas))))
  lines.append('END;')
  #print "\n".join(lines)
  OUTFILE.write("\n".join(lines))
  OUTFILE.close()

    
def read_xls(file):
  """
  """
  types=['Empty', 'Text', 'Number', 'Date', 'Boolean', 'Error', 'Blank']
  wb=xlrd.open_workbook(file)
  for wsname in wb.sheet_names():
    order2byte={}
    p=partitions.index(wsname)
    ws=wb.sheet_by_name(wsname)
    grp_idx=0
    grps=[]
    #print p,wsname,ws.nrows
    for row in range(ws.nrows):
      for col,order in enumerate(ws.row(row)):
        if col < 4:
          type=ws.cell_type(row,col)
          if type != xlrd.XL_CELL_EMPTY and type != xlrd.XL_CELL_BLANK:
            if type == xlrd.XL_CELL_TEXT:
              value=ws.cell_value(row,col)
              grp=ws.cell_value(row,col+4)
              if grp not in grps:
                grps.append(grp)
                grp_idx+=1
              #print types[type],order,value
              byte=row*4+col
              order2byte[int(value)]=byte
              extr_extrs[p].append(byte)
              extr_grps[p].append(grp_idx)
              
              
              #print value,byte
            elif type == xlrd.XL_CELL_NUMBER:
              value=ws.cell_value(row,col)
              grp=ws.cell_value(row,col+4)
              if grp not in grps:
                grps.append(grp)
                grp_idx+=1
              #print types[type],order,value
              byte=row*4+col
              order2byte[int(value)]=byte
              extr_extrs[p].append(byte)
              extr_grps[p].append(grp_idx)
              
              
              #print value,byte
            else:
              print "ERROR: wrong type %s"%types[int(type)]
    for order in sorted(order2byte):
      byte=order2byte[order]
      #print order,byte
      extr_bytes[p].append(byte)
        
        
  
      
    

    


if __name__ == '__main__':
  import sys
  libdir = os.path.dirname(os.path.realpath(__file__)) + "/lib"
  sys.path.append(libdir)
  argc=len(sys.argv)
  if argc > 1: xls = sys.argv[1]
  if argc > 2: mif = sys.argv[2]
  read_xls(xls)
  writemif(mif)
  
  print extr_bytes
  print extr_extrs
  #print extr_grps
  #print datas 
