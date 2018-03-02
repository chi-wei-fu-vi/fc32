#!/usr/bin/python
import re
import os,sys
from pprint import pprint
class pycode2sv(object):
  def __init__(self):
    """
    """
    self.readlines=[]
    self.outlines=[]
  def translate(self):
    """
    """
    # expanding tab
    self.readlines=map(lambda x:x.expandtabs(),self.readlines)
    lspace=self.find_common_leading_space(self.readlines)
    self.readlines=map(lambda x:x[lspace:],self.readlines)
    union_declaration_p=re.compile(r'un_(\w+)obj=un_(\w+_t)\(\)')
    struct_declaration_p=re.compile(r'(\w+)obj=(\w+_t)\(\)')
    union_bytes_p=re.compile(r'un_(\w+)obj.bytes=tuple\(data\[:ctypes.sizeof\((\w+)\)\]')
    hdr_obj_p=re.compile(r'(\w+)obj=un_(\w+)obj.(\w+)')
    if_debug_p=re.compile(r'if debug:')
    left_bytes_p=re.compile(r'data=data\[ctypes.sizeof\((\w+)\):\]')
    extract_bytes_p=re.compile(r'(\w+)=data\[:(\(?[\w\+\-\*\.]+\)?)\]')
    delete_bytes_p=re.compile(r'data=data\[(\(?[\w\+\-\*\.]+\)?):\]')
    tdb_p=re.compile(r"tdb\['(\w+)']=(\w+)")
    while_p=re.compile(r"while (.*):")
    elif_p=re.compile(r"elif (.*):")
    if_p=re.compile(r"if (.*):")
    else_p=re.compile(r"else:")
    intvar_p=re.compile(r"(\w+)=\w+obj.\w+")
    map_lambda_chr_p=re.compile(r"(\w+)=''\.join\(map\(lambda x\s*:\s*chr\(x\)\s*,\s*data\[:(\w+)\]\)\)")
    map_lambda_hex_p=re.compile(r"(\w+)=''\.join\(map\(lambda x\s*:\s*'%02x'%x\s*,\s*data\[:(\w+)\]\)\)")
    self.outlines.append('''
    string s;
    byte unsigned struct_property[$];
''')
    while len(self.readlines) > 0:
      line=self.readlines.pop(0)
      line=line.rstrip()
      line=line.replace("['",'["').replace("']",'"]')
      if line.lstrip().startswith('#'): continue
      if '#' in line:
        line=line[:line.index('#')].rstrip()
      if union_declaration_p.search(line):
       union_declaration_m=union_declaration_p.search(line)
       objname=union_declaration_m.group(1)
       structname=union_declaration_m.group(2)
       self.outlines.append('''    un_{2:<20s} un_{3}obj;
    {2:<20s} {3}obj;
    un_{3}obj.bytes={0}<<byte{0}this.lcl_frame[0 +: $bits({2})/8]{1}{1};
    {3}obj=un_{3}obj.{3};
    if (debug) begin
      $display("%p",un_{3}obj);
    end
    $sformat(s,"%p",un_{3}obj.{3});
    for (int i=0; i < $size({2}_type);i++)
      struct_property[i]={2}_type[i];
    pyutils::pprint_percentp(struct_property,s);
    for (int i=0; i < $bits({2})/8 ;i++)
      this.lcl_frame.delete(0);
'''.format('{','}',structname,objname))
      elif struct_declaration_p.search(line):
       struct_declaration_m=struct_declaration_p.search(line)
       objname=struct_declaration_m.group(1)
       structname=struct_declaration_m.group(2)
       self.outlines.append('''    {2:<20s} {3}obj;
    $sformat(s,"%p",{3}obj);
    for (int i=0; i < $size({2}_type);i++)
      struct_property[i]={2}_type[i];
    $display("~~~~~~~~~~~~~~~~~~~~~~~~");
    $display("content of %s","{2}");
    $display("~~~~~~~~~~~~~~~~~~~~~~~~");
    pyutils::pprint_percentp(struct_property,s);
'''.format('{','}',structname,objname))
      elif hdr_obj_p.search(line):
        pass
      elif union_bytes_p.search(line):
       self.outlines.append('''
    //un_{3}obj.bytes={0}<<byte{0}this.lcl_frame[0 +: $bits({2})/8]{1}{1};
'''.format('{','}',structname,objname))
      elif left_bytes_p.search(line):
       self.outlines.append('''
    //for (int i=0; i < $bits({2})/8 ;i++)
    //  this.lcl_frame.delete(0);
'''.format('{','}',structname,objname))
      elif extract_bytes_p.search(line):
        extract_bytes_m=extract_bytes_p.search(line)
        arrayvar=extract_bytes_m.group(1) 
        extract_idx=extract_bytes_m.group(2) 
        self.outlines.append('''
    {3}=new[{2}];
    //{3}={0}<<byte{0}this.lcl_frame[0 +: {2}]{1}{1};
    foreach ({3}[i])
      {3}[i]=this.lcl_frame[i];
    $display("[%5d:%5d] : %3d : %50s : %p",0,8*{2},{2},"{3}",{3});

'''.format('{','}',extract_idx,arrayvar))
        self.outlines.append(' '*4+'byte unsigned %s[];'%arrayvar)
      elif delete_bytes_p.search(line):
        delete_bytes_m=delete_bytes_p.search(line)
        delete_idx=delete_bytes_m.group(1) 
        self.outlines.append('''
    for (int i=0; i < {0} ;i++)
      this.lcl_frame.delete(0);
'''.format(delete_idx))
      elif tdb_p.search(line):
        pass
      elif if_debug_p.search(line):
        lspace=len(line)-len(line.lstrip())
        self.skip_code_block(lspace)
      elif elif_p.search(line):
        elif_m=elif_p.search(line)
        condition=elif_m.group(1) 
        lspace=len(line)-len(line.lstrip())
        self.outlines.append(self.elif_block(condition,lspace))
      elif if_p.search(line):
        if_m=if_p.search(line)
        condition=if_m.group(1) 
        lspace=len(line)-len(line.lstrip())
        self.outlines.append(self.if_block(condition,lspace))
      elif else_p.search(line):
        else_m=else_p.search(line)
        lspace=len(line)-len(line.lstrip())
        self.outlines.append(self.else_block(lspace))
      elif while_p.search(line):
        while_m=while_p.search(line)
        condition=while_m.group(1) 
        lspace=len(line)-len(line.lstrip())
        self.outlines.append(self.while_block(condition,lspace))
      elif map_lambda_hex_p.search(line):
        map_lambda_hex_m=map_lambda_hex_p.search(line)
        name=map_lambda_hex_m.group(1)
        namelen=map_lambda_hex_m.group(2)
        self.outlines.append('''
    byte unsigned data[];
    string {0};
    data=new [{1}];
    foreach(data[i])
      data[i]=this.lcl_frame[i];
    pyutils::getHexString({0},data);
    $display("[%5d:%5d] : %3d : %50s : %d'h%s",0,{1}*8-1,{1},"{0}",{1}*8,{0});
    //for (int i=0; i < {1} ;i++)
    //  this.lcl_frame.delete(0);
'''.format(name,namelen))
      elif map_lambda_chr_p.search(line):
        map_lambda_chr_m=map_lambda_chr_p.search(line)
        name=map_lambda_chr_m.group(1)
        namelen=map_lambda_chr_m.group(2)
        self.outlines.append('''
    string {0};
    int unsigned {1};

    for (int i=0;i < {1}; i++)
      {0}={2}{0}," "{3};
    for (int i=0;i < {1}; i++)
      {0}.putc(i,this.lcl_frame[i]);
    $display("[%5d:%5d] : %3d : %50s : %s",0,{1}*8-1,{1},"{0}",{0});
    for (int i=0;i < (({1}+3)/4)*4; i++)
      this.lcl_frame.delete(0);
'''.format(name,namelen,'{','}'))
      else:
        if intvar_p.search(line):
          intvar_m=intvar_p.search(line)
          intvar=intvar_m.group(1)
          self.outlines.append(' '*4+'int unsigned %s;'%intvar)
        self.outlines.append(' '*4+line+';')
     
  def else_block(self,lspace):
    lines=[]
    while True:
      if len(self.readlines)==0:break
      line=self.readlines.pop(0)
      line=line.rstrip()
      line=line.replace("['",'["').replace("']",'"]')
      if line=='': continue
      if lspace >= (len(line)-len(line.lstrip())):
        self.readlines.append(line)
        break
      lines.append(line)
    obj=pycode2sv()
    obj.readlines=lines
    obj.translate()
    return '''    else begin
{0}
    end'''.format('\n'.join(map(lambda x: '  %s'%x,reduce(lambda x,y: x+y,map(lambda x:x.split('\n'),obj.outlines))))) if obj.outlines else '''    else begin
    end'''

  def if_block(self,condition,lspace):
    lines=[]
    while True:
      if len(self.readlines)==0:break
      line=self.readlines.pop(0)
      line=line.rstrip()
      line=line.replace("['",'["').replace("']",'"]')
      if line=='': continue
      if lspace >= (len(line)-len(line.lstrip())):
        self.readlines.append(line)
        break
      lines.append(line)
    obj=pycode2sv()
    obj.readlines=lines
    obj.translate()
    return '''    if ({1}) begin
{0}
    end'''.format('\n'.join(map(lambda x: '  %s'%x,reduce(lambda x,y: x+y,map(lambda x:x.split('\n'),obj.outlines)))),condition) if obj.outlines else '''    if (%s) begin
    end'''%(condition)

  def elif_block(self,condition,lspace):
    lines=[]
    while True:
      if len(self.readlines)==0:break
      line=self.readlines.pop(0)
      line=line.rstrip()
      line=line.replace("['",'["').replace("']",'"]')
      if line=='': continue
      if lspace >= (len(line)-len(line.lstrip())):
        self.readlines.append(line)
        break
      lines.append(line)
    obj=pycode2sv()
    obj.readlines=lines
    obj.translate()
    return '''    else if ({1}) begin
{0}
    end'''.format('\n'.join(map(lambda x: '  %s'%x,reduce(lambda x,y: x+y,map(lambda x:x.split('\n'),obj.outlines)))),condition) if obj.outlines else '''    else if (%s) begin
    end'''%(condition)

  def while_block(self,condition,lspace):
    lines=[]
    while True:
      if len(self.readlines)==0:break
      line=self.readlines.pop(0)
      line=line.replace("['",'["').replace("']",'"]')
      line=line.rstrip()
      if line=='': continue
      if lspace >= (len(line)-len(line.lstrip())):
        self.readlines.append(line)
        break
      lines.append(line)
    obj=pycode2sv()
    obj.readlines=lines
    obj.translate()
    return '''    while ({1}) begin
{0}
    end'''.format('\n'.join(map(lambda x: '  %s'%x,reduce(lambda x,y: x+y,map(lambda x:x.split('\n'),obj.outlines)))),condition)
  def do_while_block(self,condition,lspace):
    lines=[]
    while True:
      if len(self.readlines)==0:break
      line=self.readlines.pop(0)
      line=line.rstrip()
      line=line.replace("['",'["').replace("']",'"]')
      if line=='': continue
      if lspace >= (len(line)-len(line.lstrip())):
        self.readlines.append(line)
        break
      lines.append(line)
    obj=pycode2sv()
    obj.readlines=lines
    obj.translate()
    return '''    do begin
{0}
    end while ({1});'''.format('\n'.join(map(lambda x: '  %s'%x,reduce(lambda x,y: x+y,map(lambda x:x.split('\n'),obj.outlines)))),condition)
      
  def skip_code_block(self,lspace):
    while True:
      line=self.readlines.pop(0)
      line=line.rstrip()
      line=line.replace("['",'["').replace("']",'"]')
      if line=='': continue
      if lspace >= (len(line)-len(line.lstrip())):
        self.readlines.append(line)
        break
  def find_common_leading_space(self,lines):
    min=1000
    for line in lines:
      lspace=len(line)-len(line.lstrip())
      if lspace < min:
        min=lspace
    return min
      

if __name__ == '__main__':
  """
  """
  import sys
  argc=len(sys.argv)
  obj=pycode2sv()
  if argc > 1:
    pycode=sys.argv[1]
    obj.readlines=open(pycode,'r').readlines()
  else:
    obj.readlines=sys.stdin.readlines()
  obj.translate()
  lines=reduce(lambda x,y:x+y,map(lambda x: x.split('\n'),obj.outlines))
  decl_struct_p=re.compile(r'    (\w+)_t\s+\w+obj;')
  decl_array_p=re.compile(r'    byte unsigned\s+\w+\[\];')
  decl_int_p=re.compile(r'    int unsigned\s+\w+;')
  declarations=filter(lambda x:  decl_struct_p.search(x) or decl_int_p.search(x) or decl_array_p.search(x),lines)
  un_declarations=filter(lambda x:  not(decl_struct_p.search(x) or decl_int_p.search(x) or decl_array_p.search(x)),lines)
  print '\n'.join(declarations)
  print '\n'.join(un_declarations)
