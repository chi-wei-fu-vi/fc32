#!/usr/bin/env python2.7
from xml2dict import *
from pprint import *
import os
import re
sv_reserved=[ # systemverilog reserved words
  'alias', 'always', 'always_comb', 'always_ff', 'always_latch', 'and', 'assert', 'assign', 'assume', 'automatic',
  'before', 'begin', 'bind', 'bins', 'binsof', 'bit', 'break', 'buf', 'bufif0', 'bufif1', 'byte', 'case', 'casex',
  'casez', 'cell', 'chandle', 'class', 'clocking', 'cmos', 'config', 'const', 'constraint', 'context', 'continue',
  'cover', 'covergroup', 'coverpoint', 'cross', 'deassign', 'default', 'defparam', 'design', 'disable', 'dist',
  'do', 'edge', 'else', 'end', 'endcase', 'endclass', 'endclocking', 'endconfig', 'endfunction', 'endgenerate',
  'endgroup', 'endinterface', 'endmodule', 'endpackage', 'endprimitive', 'endprogram', 'endproperty', 'endspecify',
  'endsequence', 'endtable', 'endtask', 'enum', 'event', 'expect', 'export', 'extends', 'extern', 'final',
  'first_match', 'for', 'force', 'foreach', 'forever', 'fork', 'forkjoin', 'function', 'generate', 'genvar',
  'highz0', 'highz1', 'if', 'iff', 'ifnone', 'ignore_bins', 'illegal_bins', 'import', 'incdir', 'include', 'initial',
  'inout', 'input', 'inside', 'instance', 'int', 'integer', 'interface', 'intersect', 'join', 'join_any', 'join_none',
  'large', 'liblist', 'library', 'local', 'localparam', 'logic', 'longint', 'macromodule', 'matches', 'medium',
  'modport', 'module', 'nand', 'negedge', 'new', 'nmos', 'nor', 'noshowcancelled', 'not', 'notif0', 'notif1', 'null',
  'or', 'output', 'package', 'packed', 'parameter', 'pmos', 'posedge', 'primitive', 'priority', 'program', 'property',
  'protected', 'pull0', 'pull1', 'pulldown', 'pullup', 'pulsestyle_onevent', 'pulsestyle_ondetect', 'pure', 'rand',
  'randc', 'randcase', 'randsequence', 'rcmos', 'real', 'realtime', 'ref', 'reg', 'release', 'repeat', 'return',
  'rnmos', 'rpmos', 'rtran', 'rtranif0', 'rtranif1', 'scalared', 'sequence', 'shortint', 'shortreal', 'showcancelled',
  'signed', 'small', 'solve', 'specify', 'specparam', 'static', 'string', 'strong0', 'strong1', 'struct', 'super',
  'supply0', 'supply1', 'table', 'tagged', 'task', 'this', 'throughout', 'time', 'timeprecision', 'timeunit', 'tran',
  'tranif0', 'tranif1', 'tri', 'tri0', 'tri1', 'triand', 'trior', 'trireg', 'type', 'typedef', 'union', 'unique',
  'unsigned', 'use', 'var', 'vectored', 'virtual', 'void', 'wait', 'wait_order', 'wand', 'weak0', 'weak1', 'while',
  'wildcard', 'wire', 'with', 'within', 'wor', 'xnor', 'xor'
  ]
# add global to reserved
reserved_words=sv_reserved+['global']
class xml2uvmral(object):
  '''
.volatile(1),.reset(0),.has_reset(0),.is_rand(1),
.volatile(1),.reset(0),.has_reset(1),.is_rand(1),
.volatile(1),.reset(100000000),.has_reset(1),.is_rand(1),
.volatile(1),.reset(10000),.has_reset(1),.is_rand(1),
.volatile(1),.reset(1522),.has_reset(1),.is_rand(1),
.volatile(1),.reset(16777215),.has_reset(1),.is_rand(1),
.volatile(1),.reset(1),.has_reset(1),.is_rand(1),
.volatile(1),.reset(255),.has_reset(1),.is_rand(1),
.volatile(1),.reset(2),.has_reset(1),.is_rand(1),
.volatile(1),.reset(3),.has_reset(1),.is_rand(1),
.volatile(1),.reset(4096),.has_reset(1),.is_rand(1),
.volatile(1),.reset(8),.has_reset(1),.is_rand(1),
reg_map.add_reg(.rg(ucstat_fpga_temp),.offset(9),.rights("RO"));
reg_map.add_reg(.rg(ucstat_collision_cycle_count),.offset(10),.rights("RW"));
  '''
  type2rights={
"RO"  : "RO",
"RW"  : "RW",
"W1C" : "RW",
"MEM" : "RW",
"SATC" : "RW",
"FRC" : "RW",
"LRC" : "RW",
}
  type2access={
"RO"  : "RO",
"RW"  : "RW",
"MEM" : "RW",
"SATC" : "W1C",
"FRC" : "W1C",
"LRC" : "WC",
}
  
  reg_tpl='''
class {blockname}_{regname}_reg extends uvm_reg;
  `uvm_object_utils( {blockname}_{regname}_reg )
{decl}

  //---------------------------------------------------------------------------
  // Function: new
  //---------------------------------------------------------------------------

  function new( string name = "{blockname}_{regname}_reg" );
    super.new( .name( name ), .n_bits( {size} ), .has_coverage( UVM_CVR_ADDR_MAP /*UVM_NO_COVERAGE*/ ) );
  endfunction : new

  //---------------------------------------------------------------------------
  // Function: build
  //---------------------------------------------------------------------------

  virtual function void build();
{build}
  endfunction : build
endclass: {blockname}_{regname}_reg'''

  reg_block_tpl='''  
class {blockname}_reg_block extends uvm_reg_block;
  `uvm_object_utils( {blockname}_reg_block )
{decl}
   
  uvm_reg_map reg_map;

  //---------------------------------------------------------------------------
  // Function: new
  //---------------------------------------------------------------------------

  function new( string name = "{blockname}_reg_block" );
    super.new( .name( name ), .has_coverage( UVM_CVR_ADDR_MAP /*UVM_NO_COVERAGE*/ ) );
  endfunction : new

  //---------------------------------------------------------------------------
  // Function: build
  //---------------------------------------------------------------------------

  virtual function void build();
{build}
    reg_map = create_map( .name( "reg_map" ), .base_addr( 0 ), .n_bytes( 8 ),
                          .endian( UVM_LITTLE_ENDIAN ), .byte_addressing( 1 ) );
{add_reg}
  endfunction : build

endclass: {blockname}_reg_block'''
       
  mmap_block_tpl='''class {fname} extends uvm_reg_block;
  `uvm_object_utils( {fname} )
  // register blocks
{decl}  
  uvm_reg_map reg_map;

  //---------------------------------------------------------------------------
  // Function: new
  //---------------------------------------------------------------------------

  function new( string name = "{fname}" );
    super.new( .name( name ), .has_coverage( UVM_CVR_ADDR_MAP /*UVM_NO_COVERAGE*/ ) );
  endfunction: new

   //---------------------------------------------------------------------------
   // Function: build
   //---------------------------------------------------------------------------

  virtual function void build();
{build}
    reg_map = create_map( .name( "reg_map" ), .base_addr( {base_addr} ), .n_bytes( 8 ),
                          .endian( UVM_LITTLE_ENDIAN ), .byte_addressing( 1 ) );
{submap}
  endfunction: build
endclass: {fname}'''
  def __init__(self,top_xml,ral_dir):
    """
    """
    self.top_xml=top_xml
    self.top_xml=os.path.expanduser(self.top_xml)
    self.ral_dir=ral_dir
    self.ral_dir=os.path.expanduser(self.ral_dir)
    if not os.path.exists(self.ral_dir):
      os.makedirs(self.ral_dir)
    self.xml2dict={}
    self.top_dict=self.call_xml2dict(self.top_xml)
    self.rdwr64s=[]
    self.tag2fname={}
    self.fname2tag={}
    self.xmlfname2tag={}
    self.fnames=[]
    self.reserved_words_names=[]
  def call_xml2dict(self,xml):
    xml2dictobj = xml2dict(coding='utf-8')
    root=xml2dictobj.readxml(xml)
    dct=xml2dictobj.root2dict(root)
    #pprint(dct)
    return dct

  def filter_out(self,param=''):
    update_dict={}
    def dfs(odict,udict):
      for k,v in odict.items():
        if k==param: continue
        if isinstance(v,dict):
          uv={}
          udict[k]=uv
          dfs(v,uv)
        elif isinstance(v,list):
          udict[k]=[]
          for f in v:
            if isinstance(f,dict):
              uf={}
              udict[k].append(uf)
              dfs(f,uf)
            else:
              print "Error",f
        else:
          udict[k]=v
      return
    dfs(self.top_dict,update_dict)
    #print update_dict==self.top_dict
    #pprint(update_dict)
    self.top_dict=update_dict
  def expand_leaf_xml(self):
    update_dict={}
    def dfs(odict,udict,tag):
      for k,v in odict.items():
        if k.startswith('a') and k.endswith('a'):
          tag=k
        if isinstance(v,dict):
          uv={}
          udict[k]=uv
          dfs(v,uv,tag)
        elif isinstance(v,list):
          udict[k]=[]
          for f in v:
            if isinstance(f,dict):
              uf={}
              udict[k].append(uf)
              dfs(f,uf,tag)
            else:
              print "Error",f
        else:
          if k=='@src':
            if v !='':
              if tag not in self.tag2fname:
                self.tag2fname[tag]=[]
              self.tag2fname[tag].append(v)
              self.xmlfname2tag[v]=tag
              dct=self.call_xml2dict(os.path.join(os.path.dirname(self.top_xml),v))
              self.xml2dict[v]=dct
              udict[k]=dct
          else:
            udict[k]=v
      return
    dfs(self.top_dict,update_dict,'')
    #pprint(update_dict)
    self.complete_dict=update_dict
  def mmap_block_gen(self,fname,regmaps,base_addr,leaf_node):
    if leaf_node:
      prefix=''
    else:
      #prefix=self.projname+'_'
      prefix=fname.replace('reg_block','')
    #print map(lambda x: x[4],regmaps)
    def recover_name(name):
      if name in self.reserved_words_names:
        return name[1:]
      else:
        return name
    decl='\n'.join(map(lambda x: '  rand {prefix}{srcname}_reg_block {blockname}[{array}];'.format(
                                  prefix='' if x[4] else prefix,srcname=(x[4] if x[4] else recover_name(x[0])),blockname=x[0],array=x[3] ) if x[3]!=0 else
                                 '  rand {prefix}{srcname}_reg_block {blockname};'.format(
                                  prefix='' if x[4] else prefix,srcname=(x[4] if x[4] else recover_name(x[0])),blockname=x[0] ),regmaps))
    
    build='\n'.join(map(lambda x: '''    for ( int i = 0; i < {array}; i++ ) begin
      {blockname}[i] = {prefix}{srcname}_reg_block::type_id::create( $sformatf( "{blockname}[%0d]", i ) );
      {blockname}[i].configure( .parent( this ) );
      {blockname}[i].build();
    end
'''.format(prefix='' if x[4] else prefix,srcname=(x[4] if x[4] else recover_name(x[0])),blockname=x[0],array=x[3] ) if x[3]!=0 else
'''    {blockname} = {prefix}{srcname}_reg_block::type_id::create( "{blockname}" );
    {blockname}.configure( .parent( this ) );
    {blockname}.build();'''.format(prefix='' if x[4] else prefix,srcname=(x[4] if x[4] else recover_name(x[0])),blockname=x[0]),regmaps))

    submap='\n'.join(map(lambda x: '''    for ( int i = 0; i < {array}; i++ ) begin
      reg_map.add_submap( {blockname}[i].reg_map,
                         .offset( {base_addr} + {size} * i ) );
    end
'''.format(blockname=x[0],base_addr=x[1],size=x[2],array=x[3]) if x[3]!=0 else
'''    reg_map.add_submap( {blockname}.reg_map, .offset( {base_addr} ) );'''.format(blockname=x[0],base_addr=x[1]),regmaps))
    lines=xml2uvmral.mmap_block_tpl.format(fname=fname,decl=decl,build=build,base_addr=base_addr,submap=submap)
    self.fnames.append(fname+'.svh')
    with open(os.path.join(self.ral_dir,fname+'.svh'),'w') as fh:
      #print lines
      fh.write(lines)
      
      
  def uvmral_mmap_gen(self):
    """
    generate uvm register abstract layer
    """
    def dfs(path,tag,v):
        _regmaps=[]
        #print tag,len(tag)
        #if len(tag)>0:
        #  print pformat(v)[:400]
        for k1,v1 in v.items():
          if k1 == ( tag+'a'):
            if isinstance(v1,dict):
                  _array=0
                  _srcname=''
                  _base=v1['@base']
                  _name=v1['@name'].lower()
                  _orig_name=_name
                  if _name in reserved_words:
                    _name='_'+_name
                    self.reserved_words_names.append(_name)
                  _size=v1['@size']
                  _base=re.sub("\d+'h","'h",_base)
                  _size=re.sub("\d+'h","'h",_size)
                  if 'clk' in v1: pass
                  if '@array' in v1:
                    _array=int(v1['@array'])
                  if '@src' in v1:
                    _srcname,ext=os.path.splitext(os.path.basename(v1['@src']))
                  _srcname=re.sub('_?regs?$','',_srcname)
                  _regmaps.append((_name,_base,_size,_array,_srcname))
                  if (tag+'aa') in v1:
                    _regmaps1=dfs(path+'_'+_orig_name,tag+'a',{tag+'aa':v1[tag+'aa']})
                    if tag+'a' not in self.tag2fname:
                      self.tag2fname[tag+'a']=[]
                    self.tag2fname[tag+'a'].append(path+'_'+_orig_name+'_reg_block'+'.svh')
                    self.fname2tag[path+'_'+_orig_name+'_reg_block'+'.svh']=tag+'a'
                    if 'src' in v1:
                      self.mmap_block_gen(path+'_'+_orig_name+'_reg_block',_regmaps1,0,True)
                    else:
                      self.mmap_block_gen(path+'_'+_orig_name+'_reg_block',_regmaps1,0,False)
            elif isinstance(v1,list):
              for v2 in v1:
                if isinstance(v2,dict): # a level
                  #print pformat(v2)[:400]
                  _array=0
                  _srcname=''
                  _base=v2['@base']
                  _name=v2['@name'].lower()
                  _orig_name=_name
                  if _name in reserved_words:
                    _name='_'+_name
                    self.reserved_words_names.append(_name)
                  _size=v2['@size']
                  _base=re.sub("\d+'h","'h",_base)
                  _size=re.sub("\d+'h","'h",_size)
                  if 'clk' in v2: pass
                  if '@array' in v2:
                    _array=int(v2['@array'])
                  if '@src' in v2:
                    _srcname,ext=os.path.splitext(os.path.basename(v2['@src']))
                  print '_srcname', _srcname,_name
                  _srcname=re.sub('_?regs?$','',_srcname)
                  _regmaps.append((_name,_base,_size,_array,_srcname))
                  if (tag+'aa') in v2:
                    _regmaps1=dfs(path+'_'+_orig_name,tag+'a',{tag+'aa':v2[tag+'aa']})
                    if tag+'a' not in self.tag2fname:
                      self.tag2fname[tag+'a']=[]
                    self.tag2fname[tag+'a'].append(path+'_'+_orig_name+'_reg_block'+'.svh')
                    self.fname2tag[path+'_'+_orig_name+'_reg_block'+'.svh']=tag+'a'
                    if 'src' in v2:
                      self.mmap_block_gen(path+'_'+_orig_name+'_reg_block',_regmaps1,0,True)
                    else:
                      self.mmap_block_gen(path+'_'+_orig_name+'_reg_block',_regmaps1,0,False)
                else:
                  print "ERROR3: <a%s> is not dict object"%tag,pformat(v2)[:400]
                  exit(3)
            else:
              print "ERROR2: <a%s> is not list object"%tag,pformat(v1)[:400]
              exit(2)
          else:
            print "ERROR1: don't expect anything other than <a%s>"%tag,pformat(v1)[:400]
            exit(1)
        return _regmaps
    name,ext=os.path.splitext(os.path.basename(self.top_xml))
    name=name.replace('s_top','')
    name=name.replace('_top','')
    self.projname=name.replace('_reg','')
    # top register block
    for k,v in self.top_dict.items():
      if k == 'vi_registers':
        _regmaps=dfs(self.projname,'',v)
    self.fname2tag[name+'_block.svh']=''
    self.mmap_block_gen(name+'_block',_regmaps,0,False)

  def reg_block_gen(self,srcname,regmaps):
    decl='\n'.join(map(lambda x: '  rand {srcname}_{regname}_reg {regname};'.format(
                                  srcname=srcname,regname=x[0] ),regmaps))
    
    build='\n'.join(map(lambda x: '''    {regname} = {srcname}_{regname}_reg::type_id::create( "{regname}" );
    {regname}.configure( .blk_parent( this ) );
    {regname}.build();'''.format(srcname=srcname,regname=x[0]),regmaps))
    add_reg='\n'.join(map(lambda x: '    reg_map.add_reg( .rg( {regname} ), .offset( {offset} ), .rights( "{typ}" ) );'.format(
                                  regname=x[0],offset=x[1],typ=xml2uvmral.type2rights[x[2]] ),regmaps))

    lines=xml2uvmral.reg_block_tpl.format(blockname=srcname,decl=decl,build=build,add_reg=add_reg)
    return lines

  def reg_gen(self,lines,srcname,regname,fieldmaps):
    def loc2size(loc):
      if ':' in loc:
        end,start=map(int,map(str.strip,loc.split(':')))
        return end-start+1
      else:
        return 1
       
    def loc2pos(loc):
      if ':' in loc:
        end,start=map(int,map(str.strip,loc.split(':')))
        return start
      else:
        return int(loc)
    def fieldmaps2size(loc):
      minv=65535
      maxv=0
      for _,loc,_,_,_ in fieldmaps:
        if ':' in loc:
          end,start=map(int,map(str.strip,loc.split(':')))
        else:
          end=start=int(loc)
        if end > maxv: maxv=end
        if start < minv: minv=start
      # start count from 0
      #return maxv-minv+1
      return maxv+1
    def extract_default_value(loc,value):
      allone=0xffffffffffffffff
      if ':' in loc:
        end,start=map(int,map(str.strip,loc.split(':')))
        return (value & ((allone>>start)<<start) & ~((allone>>(end+1))<<(end+1)))>>start
      else:
        return (value & (1<<int(loc))) >> int(loc)
        


    decl='\n'.join(map(lambda x: '  rand uvm_reg_field {fieldname};'.format( fieldname=x[0] ),fieldmaps))
    
    build='\n'.join(map(lambda x: '''    {fieldname} = uvm_reg_field::type_id::create( "{fieldname}" );
    {fieldname}.configure( .parent( this ), .size( {size} ), .lsb_pos( {lsb_pos} ), .access( "{access}" ),
           .volatile( 1 ), .reset( {reset} ), .has_reset( {has_reset} ), .is_rand( 1 ),
           .individually_accessible( 0 ) );'''.format(
fieldname=x[0],size=loc2size(x[1]),lsb_pos=loc2pos(x[1]),access=xml2uvmral.type2access[x[2]],
reset= extract_default_value(x[1], x[3]) if x[3] else 0,
has_reset= 1 if x[3] else 0
),fieldmaps))

    lines.append(xml2uvmral.reg_tpl.format(blockname=srcname,regname=regname,decl=decl,size=fieldmaps2size(fieldmaps),build=build))
    return lines

  def uvmral_reg_gen(self):
    """
    generate uvm register abstract layer
    """
    def parse_regxml(srcname,v,lines):
      _regmaps=[]
      if v.keys()==['register']:
        if isinstance(v['register'],list):
          v1=v['register']
          for v2 in v1:
            if isinstance(v2,dict): # a level
              #print pformat(v2)[:400]
              if '#text' in v2:
                _text   = v2['#text']
              else:
                _text   =  None
              if '@default' in v2:
                _default = v2['@default']
                if "'h" in _default:
                  _default=int(re.sub("\d+'h","",_default),16)
                elif "'d" in _default:
                  _default=int(re.sub("\d+'d","",_default))
                elif "'b" in _default:
                  _default=int(re.sub("\d+'b","",_default),2)
                else:
                  _default=int(_default)
              else:
                _default =  None
              _name   = v2['@name'].lower()
              if _name in reserved_words:
                _name='_'+_name
                self.reserved_words_names.append(_name)
              _offset = v2['@offset']
              _type   = v2['@type']
              if "'h" in _offset:
                _offset=int(re.sub("\d+'h","",_offset),16)
              elif "'d" in _offset:
                _offset=int(re.sub("\d+'d","",_offset))
              elif "'b" in _offset:
                _offset=int(re.sub("\d+'b","",_offset),2)
              else:
                _offset=int(_offset)
              _regmaps.append((_name,_offset,_type,_default,_text))
              if isinstance(v2['field'],dict):
                v3=v2['field']
                print pformat(v3)[:400]
                if '#text' in v3:
                  _text   = v3['#text']
                _loc = v3['@loc'].strip()[1:-1]
                _field_name   = v3['@name'].lower()
                if _field_name in reserved_words:
                  _field_name='_'+_field_name
                  self.reserved_words_names.append(_field_name)
                lines=self.reg_gen(lines,srcname,_name,[(_field_name,_loc,_type,_default,_text)])
              elif isinstance(v2['field'],list):
                _fieldmaps=[]
                for v3 in v2['field']:
                  print pformat(v3)[:400]
                  if '#text' in v3:
                    _text   = v3['#text']
                  print v3['@loc']
                  _loc = v3['@loc'].strip()[1:-1]
                  _field_name   = v3['@name'].lower()
                  if _field_name in reserved_words:
                    _field_name='_'+_field_name
                    self.reserved_words_names.append(_field_name)
                  _fieldmaps.append((_field_name,_loc,_type,_default,_text))
                lines=self.reg_gen(lines,srcname,_name,_fieldmaps)
              else:
                print "ERROR7: expect dict of field or list of fields", pformat(v2['field'])[:800]
                exit(7)
            else:
              print "ERROR6: expect dict of register's attributes", pformat(v2)[:800]
              exit(6)
        else:
          print "ERROR5: expect list of registers", pformat(v['register'])[:800]
          exit(5)
      else:
        print "ERROR4: wrong type of xml", pformat(v)[:800]
        exit(4)
      return _regmaps,lines
    # top register block
    for k,v in self.xml2dict.items():
      lines=[]
      _srcname,ext=os.path.splitext(os.path.basename(k))
      _srcname=re.sub('_?regs?$','',_srcname)
      for k1,v1 in v.items():
        if k1 == 'decl_reg_list':
          _regmaps,lines=parse_regxml(_srcname,v1,lines)
      lines.append(self.reg_block_gen(_srcname,_regmaps))
      self.fnames.append(_srcname+'_reg_block.svh')
      self.fname2tag[_srcname+'_reg_block.svh']=self.xmlfname2tag[k]
      with open(os.path.join(self.ral_dir,_srcname+'_reg_block.svh'),'w') as fh:
        print '\n'.join(lines)
        fh.write('\n'.join(lines))
    with open(os.path.join(self.ral_dir,self.projname+'_reg_pkg.sv'),'w') as fh:
      fh.write('''
package {projname}_reg_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "reg_item_subscriber.svh"
{includes}
endpackage : {projname}_reg_pkg'''.format(projname=self.projname,
includes='\n'.join(map(lambda x: '  `include "%s"'%x,sorted(self.fnames,key=lambda x:self.fname2tag[x],reverse=True))
)))
      

if __name__=='__main__':
  '''
  xml2uvmral.py fiji_regs_top.xml
  '''
  import sys
  argc=len(sys.argv)
  if argc > 1: top_xml=sys.argv[1]
  if argc > 2: ral_dir=sys.argv[2]
  obj=xml2uvmral(top_xml,ral_dir)
  obj.filter_out('vi_appendix')
  obj.expand_leaf_xml()
  pprint(obj.top_dict)
  #pprint(obj.xml2dict)
  #pprint(obj.complete_dict)
  obj.uvmral_mmap_gen()
  obj.uvmral_reg_gen()
  print "system verilog reserved words used in reg map",obj.reserved_words_names
