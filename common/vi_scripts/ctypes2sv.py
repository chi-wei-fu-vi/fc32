#!/usr/bin/env python2.7
import copy
import ctypes
from collections import OrderedDict
from pprint import pprint
import veriloglang
import re
import string
class ctypes2sv(object):
  """
  ToDo: handle nonprintable char
  """
  pythontype2bitlen=dict(
c_byte          = ctypes.sizeof(ctypes.c_byte)*8,               # 8
c_char          = ctypes.sizeof(ctypes.c_char)*8,               # 8
c_double        = ctypes.sizeof(ctypes.c_double)*8,             # 64
c_float         = ctypes.sizeof(ctypes.c_float)*8,              # 32
c_int           = ctypes.sizeof(ctypes.c_int)*8,                # 32
c_long          = ctypes.sizeof(ctypes.c_long)*8,               # 64
c_longdouble    = ctypes.sizeof(ctypes.c_longdouble)*8,         # 128
c_short         = ctypes.sizeof(ctypes.c_short)*8,              # 16
c_ubyte         = ctypes.sizeof(ctypes.c_ubyte)*8,              # 8
c_uint          = ctypes.sizeof(ctypes.c_uint)*8,               # 32
c_ulong         = ctypes.sizeof(ctypes.c_ulong)*8,              # 64
c_ulonglong     = ctypes.sizeof(ctypes.c_ulonglong)*8,          # 128
c_ushort        = ctypes.sizeof(ctypes.c_ushort)*8,             # 16
)
  pythontype2sv=dict(
c_byte          = 'byte',
c_char          = 'byte',
c_double        = 'real',
c_float         = 'shortreal',
c_int           = 'int',
c_long          = 'longint',
c_longdouble    = 'c_longdouble',                  # user defined type
c_short         = 'shortint',
c_ubyte         = 'byte unsigned',
c_uint          = 'int unsigned',
c_ulong         = 'longint unsigned',
c_ulonglong     = 'c_ulonglong',                   # user defined type
c_ushort        = 'shortint unsigned',
)

  def __init__(self):
    """
    """
    self.classdb=OrderedDict()
    self.un_classdb=OrderedDict()
    self.imports={}
    self.endians=[]
    self.structlines=[]
    self.unionlines=[]
    self.classlines=[]
    self.const2value=OrderedDict()
    self.enumdb=OrderedDict()
    self.struct2bitlen={}
  def read_ctypes(self,fname):
    """
    """
    dict_p=re.compile(r'\s*=\s*{')
    with open(fname,'r') as fh:
      lines=fh.readlines()
      line=''
      while lines:
        line=lines.pop(0)
        line=line.rstrip()
        if line=='' or line.lstrip().startswith('#'):continue
        if line.startswith('from '):
          module,item=map(str.strip,line[5:].split(' import '))
          self.imports.setdefault(module,[]).append(item)
          
 
        elif line.startswith('ctypes_format=('):
          while True:
            line=lines.pop(0)
            line=line.strip()
            if line=='' or line.lstrip().startswith('#'):continue
            if line==')': break
        elif line.startswith('class un_'):
          lines=self.extract_union(line,lines)
        elif line.startswith('class '):
          lines=self.extract_struct(line,lines)
        elif line.startswith('assert '):
          pass
        elif dict_p.search(line):
          while True:
            line=lines.pop(0)
            line=line.strip()
            if line=='' or line.lstrip().startswith('#'):continue
            if line=='}': break
        elif line.startswith('def '):
          while True:
            if len(lines)==0: break
            line=lines.pop(0)
            if line[0] != ' ':
              lines=[line]+lines
              break
        elif 'dict(' in line:
          lines=self.extract_enum(line,lines)
        elif line[0]!=' ' and '=' in line:
          k,v=map(str.strip,line.split('#')[0].split('='))
          if v[-1]=="'":v=v[:-1]+'"'
          if v[0]=="'":v='"'+v[1:]
          if v=='long(-1)':
            v="longint'(-1)"
          self.const2value[k]=v
          

  def extract_struct(self,line,lines):
    """
    """
    idx=line.index('(')
    classname=line[6:idx]
    if 'BigEndian' in line:
      endian='big'
    else:
      endian='little'
    structdb=(endian,)
    while True:
      line=lines.pop(0)
      line=line.rstrip()
      if line=='' or line.lstrip().startswith('#'):continue
      if line.startswith('  _pack'):
        continue
      if '(' in line:
        fields=line[line.index('(')+1:line.index(')')]
        fs=map(lambda x: x.strip(),fields.split(','))
        if len(fs)==2:
          if '*' in fs[1]: 
            ftype,fsize=map(lambda x:x.strip(),fs[1][7:].split('*'))
            if fsize in self.const2value:
              fsize=self.const2value[fsize]
            structdb+=((self.replace_vlog_keywords(fs[0].strip("'")),'bit [%d:0]'%(eval(fsize)*self.pythontype2bitlen[ftype]-1)),)
          else:
            structdb+=((self.replace_vlog_keywords(fs[0].strip("'")),fs[1][7:] if fs[1].startswith('ctypes.') else fs[1]),)
        elif len(fs)==3:
          bitlen=self.pythontype2bitlen[fs[1][7:]]
          bitcount=int(fs[2])
          bitfields=[(self.replace_vlog_keywords(fs[0].strip("'")),fs[1][7:],int(fs[2]))]
          while bitlen > bitcount:
            line=lines.pop(0)
            line=line.rstrip()
            if line=='' or line.lstrip().startswith('#'):continue
            if '(' in line:
              fields=line[line.index('(')+1:line.index(')')]
              fs=map(lambda x: x.strip(),fields.split(','))
              if len(fs)==2:
                structdb+=((self.replace_vlog_keywords(fs[0].strip("'")),fs[1][7:] if fs[1].startswith('ctypes.') else fs[1]),)
                break
              bitlen=self.pythontype2bitlen[fs[1][7:]]
              bitcount+=int(fs[2])
              bitfields.append((self.replace_vlog_keywords(fs[0].strip("'")),fs[1][7:],int(fs[2])))
            if line.endswith(']'): break
          structdb+=(bitfields,)
      if line.endswith(']'): break
    self.classdb[classname]=structdb 
    return lines
      

        
  def extract_enum(self,line,lines):
    """
    """
    name=line.split('#')[0].split('=')[0].strip()
    self.enumdb[name]=()
    while True:
      line=lines.pop(0)
      line=line.rstrip()
      if line=='' or line.lstrip().startswith('#'):continue
      if line.startswith(')'): break
      k,v=map(str.strip,line.split('#')[0].split('='))
      if v[-1]==',':
        v=v[:-1].strip()
      if v[-1]=="'":v=v[:-1]+'"'
      if v[0]=="'":v='"'+v[1:]
      self.enumdb[name]+=((k,v),)
    return lines
      
  def extract_union(self,line,lines):
    """
    """
    idx=line.index('(')
    classname=line[9:idx]
    structdb=()
    while True:
      line=lines.pop(0)
      line=line.rstrip()
      if line=='' or line.lstrip().startswith('#'):continue
      if '(' in line:
        fields=line[line.index('(')+1:line.index(')')]
        fs=map(lambda x: x.strip(),fields.split(','))
        if len(fs)==2:
          if '*' in fs[1]: 
            ftype,fsize=map(lambda x:x.strip(),fs[1][7:].split('*'))
            if fsize in self.const2value:
              fsize=self.const2value[fsize]
            structdb+=((self.replace_vlog_keywords(fs[0].strip("'")),eval(fsize)),)
          else:
            structdb+=((self.replace_vlog_keywords(fs[0].strip("'")),fs[1][7:] if fs[1].startswith('ctypes.') else fs[1]),)
        elif len(fs)==3:
          raise Extract_Error
      if ']' in line:
        break
      
      if len(lines)==0: break
    self.un_classdb[classname]=structdb 
    return lines

  def structgen(self):
    """
    """
    for sname,structdb in self.classdb.items():
      endian=structdb[0]
      self.endians.append(sname)
      if endian=='little':
        self.classlines.append(self.endian_swap_class(sname,structdb[1:]))
      self.structlines.append(self.create_struct(sname,structdb[1:]))
      self.structlines.append(self.create_type_array(sname,structdb[1:]))
  def uniongen(self):
    """
    """
    for sname,structdb in self.un_classdb.items():
      self.unionlines.append(self.create_union(sname,structdb))
  def endian_swap_class(self,name,db):
    """
    """
  
  def create_union(self,name,db):
    """
    """
    return """typedef union {    
%s
} un_%s;"""%('\n'.join(map(lambda x: '  %-20s %s;'%(('byte unsigned','bytes[%d]'%x[1]) if x[0]=='bytes' else (x[1],x[0])),db)),name)
  def create_struct(self,name,db):
    """
    """
    def bitfields(bits):
      return '\n'.join(map(lambda x: '  %-20s %s;'%('bit [%d:0]'%(x[2]-1) if x[2] > 1 else 'bit',x[0]),bits))
    return """typedef struct packed {    
%s
} %s;"""%('\n'.join(map(lambda x: bitfields(x) if isinstance(x,list) else '  %-20s %s;'%(self.pythontype2sv[x[1]] if x[1] in self.pythontype2sv else x[1],x[0]),db)),name)
  
  def create_type_array(self,name,db):
    """
    """
    def nestlen(db):
      return sum(map(lambda x: int(len(x)) if isinstance(x,list) else 1,db))
    def bitfields(bits):
      return ','.join(map(lambda x: '%d'%x[2],bits))
    def bitfield(bit):
      if bit.startswith('bit ['):
        return str(int(bit[5:bit.index(':')])+1)
      else:
        return str(self.struct2bitlen[bit])
    
    self.struct2bitlen[name]=sum(map(lambda x: int(sum(map(int,bitfields(x).split(','))) if isinstance(x,list) else '%d'%self.pythontype2bitlen[x[1]] if x[1] in self.pythontype2sv else bitfield(x[1])),db))
    return """byte unsigned %s_type[%d]='{%s};"""%(name,nestlen(db), ','.join(map(lambda x: bitfields(x) if isinstance(x,list) else '%d'%self.pythontype2bitlen[x[1]] if x[1] in self.pythontype2sv else bitfield(x[1]),db)))

  def enumgen(self):
    lines=[]
    for name in self.enumdb:
      lines.append('''int %s[string] = '{
%s
  };'''%(name,',\n'.join(map(lambda x: '    {0:<45s}: {1}'.format('"%s"'%x[0],self.hexnum(x[1])),self.enumdb[name]))))
    return lines
  def enumgen_2(self):
    lines=[]
    for name in self.enumdb:
      lines.append('''typedef enum {
%s
  } %s;'''%(',\n'.join(map(lambda x: '    {0:<45s}= {1}'.format(x[0],self.hexnum(x[1])),self.enumdb[name])),name))
    return lines
  def enumgen_1(self):
    lines=[]
    for name in self.enumdb:
      lines.append('''virtual class %s_wrap;
  typedef enum {
%s
  } %s;
endclass'''%(name,',\n'.join(map(lambda x: '    {0:<45s}= {1}'.format(x[0],self.castint(self.hexnum(x[1]))),self.enumdb[name])),name))
    return lines
  def write_hdr(self,fname):
    """
    """
    lines=[]
    lines.append('package %s;'%fname[:-2])
    # import
    if self.imports:
      lines.extend(reduce(lambda x,y: x+y,map(lambda x: map(lambda y: 'import %s::%s;'%(x,y), self.imports[x]),self.imports)))
    # constant
    lines.extend(map(lambda x: 'localparam %-45s = %s;'%(x,self.hexnum(self.const2value[x])),self.const2value))
    # enum
    lines.extend(self.enumgen())

    # struct
    lines.extend(self.structlines)
    # union
    lines.extend(self.unionlines)
    lines.append('endpackage')
    with open(fname,'w') as fh:
      fh.write('\n'.join(lines))

  def replace_vlog_keywords(self,name):
    """
    """
    for group in veriloglang.veriloglang.keywords:
      if name in group:
         name+='qq'
    return name

  def hexnum(self,num):
    """
    """
    res_num=''
    while True:
      if '0x' not in num: break
      idx=num.index('0x') 
      res_num+=num[:idx]
      num=num[idx+2:]
      idx=len(num)
      for i,c in enumerate(num):
        if c not in string.hexdigits:
          idx=i
          break
      res_num+="%d'h"%(idx*4)
      res_num+=num[:idx]
      num=num[idx:]
    return res_num+num
  def castint(self,num):
    """
    """
    if not num.startswith('"'):
      num="int'(%s)"%num
    return num

class Extract_Error:
  pass
      
if __name__=='__main__':
  import sys
  argc=len(sys.argv)
  if argc > 1: ctypes_hdr=sys.argv[1]
  if argc > 2: sv_hdr=sys.argv[2]
  obj=ctypes2sv()
  obj.read_ctypes(ctypes_hdr)
  #pprint(obj.classdb)
  #pprint(obj.un_classdb)
  obj.structgen()
  obj.uniongen()
  obj.write_hdr(sv_hdr)
