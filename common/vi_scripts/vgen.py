#!/usr/bin/env python2

import xml.dom.minidom
import sys, os
libdir = os.path.dirname(os.path.realpath(__file__)) + "/lib"
sys.path.append(libdir)  # for lib/xlwt module
import re
import math
import xlwt
#import collections
from datetime import datetime

from xlwt import *
import argparse
from argparse import RawTextHelpFormatter
from pprint import pprint
from copy import deepcopy

class common(object):
  reg_attrs=[ '_regex_range','_default', '_descr', '_offset', '_size', '_typ', '_usr', '_incsz' ]
  reg_types=['RW', 'RO', 'FRC', 'LRC', 'TRC', 'SATC', 'MEM']
  bit_attrs=[ '_descr', '_loc', '_typ' ]
  bit_types=['RW', 'SC']
  module_attrs=[ 'array', 'base', 'size', 'sp', 'src', 'clk' ]
  title_row = easyxf('font:height 240')
  title_ad = easyxf('font:height 240, color red;')
  title_rm = easyxf('font:height 240, color red, struck-out on;')
  title_desc = easyxf('font:name Courier New')
  title_desc_ad = easyxf('font:name Courier New,color red;')
  title_desc_rm = easyxf('font:name Courier New,color red, struck-out on;')

  cell = easyxf('font:name Courier New;''borders:left thin, right thin,bottom thin;')
  style_ad = easyxf('font:name Courier New,color red;''borders:left thin, right thin,bottom thin, left-color red, right-color red, bottom-color red;')
  style_rm = easyxf('font:name Courier New,color red, struck-out on;''borders:left thin, right thin,bottom thin, left-color red, right-color red, bottom-color red;')
  cell_rw = easyxf('font:name Courier New;''borders:left thin, right thin,bottom thin;''pattern:pattern solid, fore-color bright-green;')
  cell_ro = easyxf('font:name Courier New;''borders:left thin, right thin,bottom thin;''pattern:pattern solid, fore-color gold;')
  cell_sc = easyxf('font:name Courier New;''borders:left thin, right thin,bottom thin;''pattern:pattern solid, fore-color ice-blue;')
  cell_rv = easyxf('font:name Courier New;''borders:left thin, right thin,bottom thin;''pattern:pattern solid, fore-color ivory;')
  cell_frc = easyxf('font:name Courier New;''borders:left thin, right thin,bottom thin;''pattern:pattern solid, fore-color aqua;')
  cell_lrc = easyxf('font:name Courier New;''borders:left thin, right thin,bottom thin;''pattern:pattern solid, fore-color orange;')
  cell_sat = easyxf('font:name Courier New;''borders:left thin, right thin,bottom thin;''pattern:pattern solid, fore-color light_turquoise;')
  type2style={
    "RW"        :               cell_rw,
    "RO"        :               cell_ro,
    "SC"        :               cell_sc,
    "RV"        :               cell_rv,
    "MEM"       :               cell_rv,
    "FRC"       :               cell_frc,
    "LRC"       :               cell_lrc,
    "SATC"      :               cell_sat
  }

  t_hdr_style = easyxf('font:name Courier New,bold on;''pattern:pattern solid, fore-color grey25;''borders:left thin,right thin, top thin, bottom double;')


  def tostart(self,loc):
    """
    """
    loc=loc[1:-1]
    if ':' in loc:
      idx=loc.index(':')
      loc=loc[idx+1:]
    return int(loc)

  def toend(self,loc):
    """
    """
    loc=loc[1:-1]
    if ':' in loc:
      idx=loc.index(':')
      loc=loc[:idx]
    return int(loc)

  def dim2size(self,loc):
    """
    """
    loc=loc[1:-1]
    if ':' in loc:
      idx=loc.index(':')
      end=loc[:idx]
      start=loc[idx+1:]
      return int(end)-int(start)+1
    else:
      return 1

  def dim2mask(self,loc):
    """
    """
    loc=loc[1:-1]
    if ':' in loc:
      idx=loc.index(':')
      end=loc[:idx]
      start=loc[idx+1:]
      return '0x%016x'%int('1'*(int(end)-int(start)+1)+'0'*int(start),2)
    else:
      return '0x%016x'%(1<<loc)

  def vlognum2int(self,num):
    """
    """
    if "'h" in num:
      idx=num.index("'h")
      num=int(num[idx+2:],16)
    elif "'d" in num:
      idx=num.index("'d")
      num=int(num[idx+2:],10)
    elif "'b" in num:
      idx=num.index("'b")
      num=int(num[idx+2:],2)
    else:
      num=int(num)
    return num
  def vlognumadd(self,n1,n2):
    return self.vlognum2int(n1) + self.vlognum2int(n2)

  def size2dim(self,size):
    """
    """
    return '[%d:0]'%(int(math.log(self.vlognum2int(size),2)+0.5)-1)

  def dim2disp(self,dim):
    start=self.tostart(dim)
    end=self.toend(dim)
    if start==end:
      return ''
    else:
      return dim
  def dim2disp_wo_offset(self,dim):
    start=self.tostart(dim)
    end=self.toend(dim)
    if start==end:
      return ''
    else:
      if start==0:
        return dim
      else:
        return '[%d:0]'%(end-start)
  def dim2index(self,dim):
    start=self.tostart(dim)
    end=self.toend(dim)
    if start==end:
      return '[%d]'%start
    else:
      return dim

  def vlognum2dim(self,num):
    """
    """
    if "'h" in num:
      idx=num.index("'h")
      num=int(num[:idx])
    elif "'d" in num:
      idx=num.index("'d")
      num=int(num[:idx])
    elif "'b" in num:
      idx=num.index("'b")
      num=int(num[:idx])
    else:
      num=21
    return num

  def wrapline(self,line,size):
    """
    """
    outs=[]
    fs=[]
    count=0
    if len(line) > size:
      for f in line.split():
        count+=len(f)+1
        if count > size:
          outs.append(fs)
          fs=[]
          fs.append(f)
          count=len(f)+1
        else:
          fs.append(f)
      outs.append(fs)
      return '\n'.join(map(lambda x: ' '.join(x),outs)),len(outs)
    else:
      return line,1

  def regheader1(self,reg,offset,typ,default,size,descr):
    self.ws.write(self.row,1,"Reg name : %s (%s)"%(reg,typ),self.title_row)
    self.row+=1
    self.ws.write(self.row,1,"Addr : 0x%06x(0x%06x)"%(offset,offset<<3),self.title_row)
    self.row+=1
    if typ=='MEM':
      self.ws.write(self.row,1,"Size : %s"%(size),self.title_row)
    else:
      self.ws.write(self.row,1,"Default : %s"%(default),self.title_row)
    self.row+=1
    if descr!='':
      descr,height=self.wrapline(descr,40)
      self.ws.row(self.row).height+=255*(height-1)
    self.ws.write(self.row,2,descr,self.title_desc)
    self.row+=2

    self.ws.write(self.row,0,'Name',self.t_hdr_style)
    self.ws.write(self.row,1,'Bits',self.t_hdr_style)
    self.ws.write(self.row,2,'Type',self.t_hdr_style)
    self.ws.write(self.row,3,'Description',self.t_hdr_style)
    self.row+=1
  def regheader(self,reg,attrs,name):
    """
    """
    self.ws.write(self.row,1,"Reg name : %s (%s)"%(reg,attrs['_typ']),self.title_row)
    self.row+=1
    self.ws.write(self.row,1,"Offset : 0x%04x"%(self.vlognum2int(attrs['_offset'])),self.title_row)
    if attrs['_typ']=='MEM':
      self.ws.write(self.row,3,"Size : %s"%(attrs['_size']),self.title_row)
    else:
      self.ws.write(self.row,3,"Default : %s"%(attrs['_default']),self.title_row)
      self.row+=1
      if '_regex_range' not in attrs:
        attrs['_regex_range'] = ''
      self.ws.write(self.row,1,"Regex range : %s"%(attrs['_regex_range']),self.title_row)
    self.row+=1
    descr=''
    if '_descr' in attrs:
      descr,height=self.wrapline(attrs['_descr'],40)
      self.ws.row(self.row).height+=255*(height-1)
    self.ws.write(self.row,2,descr,self.title_desc)
    self.row+=2

    self.ws.write(self.row,0,'Name',self.t_hdr_style)
    self.ws.write(self.row,1,'Bits',self.t_hdr_style)
    self.ws.write(self.row,2,'Type',self.t_hdr_style)
    self.ws.write(self.row,3,'Description',self.t_hdr_style)
    self.row+=1

  def write_row(self,name,loc,typ,descr):
    """
    """
    descr,height=self.wrapline(descr,40)
    self.ws.row(self.row).height+=255*(height-1)
    self.ws.write(self.row,0,name,self.cell)
    self.ws.write(self.row,1,loc,self.cell)
    self.ws.write(self.row,2,typ,self.type2style[typ])
    self.ws.write(self.row,3,descr,self.cell)

class decode(common):
  outfmt    ='  output logic {0:<15s} {1:s}'
  infmt     ='  input        {0:<15s} {1:s}'
  wirefmt   ='  wire   {0:<15s}       {1:s};'
  logicfmt  ='  logic  {0:<15s}       {1:s};'
  initfmt   ='    {0:<25s} = 0;'
  assignfmt ='  assign {0:<25s} = {1:s};'
  muxfmt    ="""      %s: begin  // %s
        %-25s = lwen;
        %-25s = lren;
        ldata                    = %s;
        ldata_v                  = %s;
      end"""
  controlfmt="""      %s: begin  // %s
        %-25s = lwen;
        %-25s = lren;
        ldata_v                  = %s;
      end"""
  udatafmt  ="""      %s: begin  // %s
        ldata[63:32]             = %s[63:32];
      end"""
  ldatafmt  ="""      %s: begin  // %s
        ldata[31:0]              = %s[31:0];
      end"""
  pulsesyncfmt ="""
  ///////////////////////////////////////////
  //
  // Pulse Sync for %s
  //
  ///////////////////////////////////////////
  vi_sync_csr sync_%s (
    . iRST_N_A                                           ( rst_n                                              ), // input
    . iCLK_A                                             ( clk                                                ), // input
    . iWREN_A                                            ( %-50s ), // input
    . iRDEN_A                                            ( %-50s ), // input
    . iADDR_A                                            ( laddr                                              ), // input [20:0]
    . iWR_DATA_A                                         ( lwdata                                             ), // input [63:0]
    . oACK_A                                             ( %-50s ), // output
    . oRD_DATA_A                                         ( %-50s ), // output [63:0]
    . iRST_N_B                                           ( %-50s ), // input
    . iCLK_B                                             ( %-50s ), // input
    . iRD_DATA_B                                         ( %-50s ), // input [63:0]
    . iACK_B                                             ( %-50s ), // input
    . oWREN_B                                            ( %-50s ), // output
    . oRDEN_B                                            ( %-50s ), // output
    . oWR_DATA_B                                         ( %-50s ), // output [63:0]
    . oADDR_B                                            ( %-50s )  // output [20:0]
  );
"""
  buss   ="""
  always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      rd_data           <= 0;
      rd_data_v         <= 0;
      laddr             <= 'h0;
      lwen              <= 0;
      lren              <= 0;
      lwdata            <= 'h0;
    end
    else begin
      rd_data           <= ldata;
      ldata_vd          <= ldata_v;
      rd_data_v         <= ldata_vd;
      laddr             <= iMM_ADDR;
      lwen              <= iMM_WR_EN;
      lren              <= iMM_RD_EN;
      lwdata            <= iMM_WR_DATA;
    end
  end
  assign oMM_RD_DATA     = rd_data;
  assign oMM_RD_DATA_V   = rd_data_v;
"""
  mm_if={
  'in':[
    ('clk',''),
    ('rst_n',''),
    ('iMM_WR_EN',''),
    ('iMM_RD_EN',''),
    ('iMM_ADDR','[]'),
    ('iMM_WR_DATA','[63:0]')
  ],
  'out':[
    ('oMM_RD_DATA','[63:0]'),
    ('oMM_RD_DATA_V','')
  ]
}
  outmm_w_clk_if={
  'in':[
    ('_RD_DATA','[63:0]'),
    ('_RD_DATA_V',''),
    ('_clk',''),
    ('_rst_n','')
  ],
  'out':[
    ('_ADDR','[]'),
    ('_WR_DATA','[63:0]'),
    ('_WR_EN',''),
    ('_RD_EN','')
  ],
  'wire':[
    ('_rd_data','[63:0]'),
    ('_rd_data_v','')
  ]
}
  outmm_if={
  'in':[
    ('_RD_DATA','[63:0]'),
    ('_RD_DATA_V','')
  ],
  'out':[
    ('_ADDR','[]'),
    ('_WR_DATA','[63:0]'),
    ('_WR_EN',''),
    ('_RD_EN','')
  ]
}
  base_nets=[
    ('rd_data','[63:0]'),
    ('rd_data_v',''),
    ('laddr','[]'),
    ('ldata','[63:0]'),
    ('ldata_v',''),
    ('ldata_vd',''),
    ('lwen',''),
    ('lren',''),
    ('lwdata','[63:0]')
  ]
  def __init__(self,modules,db):
    """
    """
    self.modules=modules
    self.db=db
    self.maxdim=max(map(lambda x: self.vlognum2dim(db[x]['size']),modules))
    #print self.size,self.modules,self.db
    self.outs=[]
    self.ins=[]
    self.wires=[]
    self.logics=[]
    self.addrdecs=[]
    self.inits=[]
    self.muxs=[]
    self.controls=[]
    self.udatas=[]
    self.ldatas=[]
    self.assigns=[]
    self.bodys=[]
    self.memrd_vs=[]
    self.memrd_en_latchs=[]
    self.ins.extend(map(lambda x: self.infmt.format(self.dim_subst(x[1]),x[0]),self.mm_if['in']))
    self.outs.extend(map(lambda x: self.outfmt.format(self.dim_subst(x[1]),x[0]),self.mm_if['out']))
    self.logics.extend(map(lambda x: self.logicfmt.format(self.dim_subst(x[1]),x[0]),self.base_nets))

  def dim_subst(self,dim):
    """
    """
    if dim=='[]':
      return '[%d:0]'%(self.maxdim-1)
    else:
      return dim



  def codegen(self):
    """
    """
    lines=[]
    for module in sorted(self.modules,key=lambda x: self.vlognum2int(self.db[x]['base'])):
      size=self.vlognum2int(self.db[module]['size'])
      base=self.vlognum2int(self.db[module]['base'])
      addrfmt="{0:d}'b{1:0%db}{2:s}"%(self.maxdim-int(math.log(size,2)))
      if 'array' in self.db[module]:
        for idx in range(int(self.db[module]['array'])):
          if 'clk' in self.db[module]:
            self.ins.extend(map(lambda x: self.infmt.format(self.dim_subst(x[1]),module.upper()+str(idx)+x[0]),self.outmm_w_clk_if['in']))
            self.outs.extend(map(lambda x: self.outfmt.format(self.dim_subst(x[1]),module.upper()+str(idx)+x[0]),self.outmm_w_clk_if['out']))
            self.wires.extend(map(lambda x: self.wirefmt.format(self.dim_subst(x[1]),'l'+module+str(idx)+x[0]),self.outmm_w_clk_if['wire']))
            self.assigns.append(self.pulsesyncfmt%(module.upper()+str(idx),
                                                   module.upper()+str(idx),
                                                   "l%s%d_wren"%(module,idx),
                                                   "l%s%d_rden"%(module,idx),
                                                   "l%s%d_rd_data_v"%(module,idx),
                                                   "l%s%d_rd_data"%(module,idx),
                                                   "%s%d_rst_n"%(module.upper(),idx),
                                                   "%s%d_clk"%(module.upper(),idx),
                                                   "%s%d_RD_DATA"%(module.upper(),idx),
                                                   "%s%d_RD_DATA_V"%(module.upper(),idx),
                                                   "%s%d_WR_EN"%(module.upper(),idx),
                                                   "%s%d_RD_EN"%(module.upper(),idx),
                                                   "%s%d_WR_DATA"%(module.upper(),idx),
                                                   "%s%d_ADDR"%(module.upper(),idx)))
            self.muxs.append(self.muxfmt%(addrfmt.format(self.maxdim,int(base/size+idx),'z'*int(math.log(size,2))),
                                          module+str(idx),
                                          'l'+module+str(idx)+'_wren',
                                          'l'+module+str(idx)+'_rden',
                                          'l'+module+str(idx)+'_rd_data',
                                          'l'+module+str(idx)+'_rd_data_v'))
          else:
            self.ins.extend(map(lambda x: self.infmt.format(self.dim_subst(x[1]),module.upper()+str(idx)+x[0]),self.outmm_if['in']))
            self.outs.extend(map(lambda x: self.outfmt.format(self.dim_subst(x[1]),module.upper()+str(idx)+x[0]),self.outmm_if['out']))
            self.assigns.append(self.assignfmt.format('%s_ADDR'%(module.upper()+str(idx)),'laddr'))
            self.assigns.append(self.assignfmt.format('%s_WR_EN'%(module.upper()+str(idx)),'l%s_wren'%(module+str(idx))))
            self.assigns.append(self.assignfmt.format('%s_RD_EN'%(module.upper()+str(idx)),'l%s_rden'%(module+str(idx))))
            self.assigns.append(self.assignfmt.format('%s_WR_DATA'%(module.upper()+str(idx)),'lwdata'))
            self.muxs.append(self.muxfmt%(addrfmt.format(self.maxdim,int(base/size+idx),'z'*int(math.log(size,2))),
                                          module+str(idx),
                                          'l'+module+str(idx)+'_wren',
                                          'l'+module+str(idx)+'_rden',
                                          module.upper()+str(idx)+'_RD_DATA',
                                          module.upper()+str(idx)+'_RD_DATA_V'))
          self.logics.append(self.logicfmt.format('','l%s%d_wren'%(module,idx)))
          self.logics.append(self.logicfmt.format('','l%s%d_rden'%(module,idx)))
          self.inits.append(self.initfmt.format('l%s%d_wren'%(module,idx)))
          self.inits.append(self.initfmt.format('l%s%d_rden'%(module,idx)))
#          self.controls.append(self.controlfmt%(addrfmt.format(self.maxdim,int(base/size+idx),'z'*int(math.log(size,2))),
#                                                module+str(idx),
#                                                'l'+module+str(idx)+'_wren',
#                                                'l'+module+str(idx)+'_rden',
#                                                module.upper()+str(idx)+'_RD_DATA_V'))
#          self.udatas.append(self.udatafmt%(addrfmt.format(self.maxdim,int(base/size+idx),'z'*int(math.log(size,2))),
#                                            module+str(idx),
#                                            module.upper()+str(idx)+'_RD_DATA'))
#          self.ldatas.append(self.ldatafmt%(addrfmt.format(self.maxdim,int(base/size+idx),'z'*int(math.log(size,2))),
#                                            module+str(idx),
#                                            module.upper()+str(idx)+'_RD_DATA'))
      else:
        if 'clk' in self.db[module]:
          self.ins.extend(map(lambda x: self.infmt.format(self.dim_subst(x[1]),module.upper()+x[0]),self.outmm_w_clk_if['in']))
          self.outs.extend(map(lambda x: self.outfmt.format(self.dim_subst(x[1]),module.upper()+x[0]),self.outmm_w_clk_if['out']))
          self.wires.extend(map(lambda x: self.wirefmt.format(self.dim_subst(x[1]),'l'+module+x[0]),self.outmm_w_clk_if['wire']))
          self.assigns.append(self.pulsesyncfmt%(module.upper(),
                                                 module.upper(),
                                                 "l%s_wren"%module,
                                                 "l%s_rden"%module,
                                                 "l%s_rd_data_v"%module,
                                                 "l%s_rd_data"%module,
                                                 "%s_rst_n"%module.upper(),
                                                 "%s_clk"%module.upper(),
                                                 "%s_RD_DATA"%module.upper(),
                                                 "%s_RD_DATA_V"%module.upper(),
                                                 "%s_WR_EN"%module.upper(),
                                                 "%s_RD_EN"%module.upper(),
                                                 "%s_WR_DATA"%module.upper(),
                                                 "%s_ADDR"%module.upper()))
          self.muxs.append(self.muxfmt%(addrfmt.format(self.maxdim,int(base/size),'z'*int(math.log(size,2))),
                                        module,
                                        'l'+module+'_wren',
                                        'l'+module+'_rden',
                                        'l'+module+'_rd_data',
                                        'l'+module+'_rd_data_v'))
        else:
          self.ins.extend(map(lambda x: self.infmt.format(self.dim_subst(x[1]),module.upper()+x[0]),self.outmm_if['in']))
          self.outs.extend(map(lambda x: self.outfmt.format(self.dim_subst(x[1]),module.upper()+x[0]),self.outmm_if['out']))
          self.assigns.append(self.assignfmt.format('%s_ADDR'%(module.upper()),'laddr'))
          self.assigns.append(self.assignfmt.format('%s_WR_EN'%(module.upper()),'l%s_wren'%module))
          self.assigns.append(self.assignfmt.format('%s_RD_EN'%(module.upper()),'l%s_rden'%module))
          self.assigns.append(self.assignfmt.format('%s_WR_DATA'%(module.upper()),'lwdata'))
          self.muxs.append(self.muxfmt%(addrfmt.format(self.maxdim,int(base/size),'z'*int(math.log(size,2))),
                                        module,
                                        'l'+module+'_wren',
                                        'l'+module+'_rden',
                                        module.upper()+'_RD_DATA',
                                        module.upper()+'_RD_DATA_V'))
        self.logics.append(self.logicfmt.format('','l%s_wren'%module))
        self.logics.append(self.logicfmt.format('','l%s_rden'%module))
        self.inits.append(self.initfmt.format('l%s_wren'%module))
        self.inits.append(self.initfmt.format('l%s_rden'%module))
#        self.controls.append(self.controlfmt%(addrfmt.format(self.maxdim,int(base/size),'z'*int(math.log(size,2))),
#                                              module,
#                                              'l'+module+'_wren',
#                                              'l'+module+'_rden',
#                                              module.upper()+'_RD_DATA_V'))
#        self.udatas.append(self.udatafmt%(addrfmt.format(self.maxdim,int(base/size),'z'*int(math.log(size,2))),
#                                          module,
#                                          module.upper()+'_RD_DATA'))
#        self.ldatas.append(self.ldatafmt%(addrfmt.format(self.maxdim,int(base/size),'z'*int(math.log(size,2))),
#                                          module,
#                                          module.upper()+'_RD_DATA'))
    lines.append("%s"%(',\n'.join(self.outs+self.ins)))
    lines.append(");")
    lines.append("")
    lines.extend(self.wires+self.logics)
    self.bodys.append("  always_comb begin")
    self.bodys.extend(self.inits)
    self.bodys.append("    unique casez(laddr)")
    self.bodys.extend(self.muxs)
    self.bodys.append("""
      default: begin
        ldata                    = {32'h5555_AAAA,%d'b0,laddr};
        ldata_v                  = lren;
      end
    endcase
  end"""%(32-self.maxdim))
#    self.bodys.append("  always_comb begin")
#    self.bodys.extend(self.inits)
#    self.bodys.append("    unique casez(laddr)")
#    self.bodys.extend(self.controls)
#    self.bodys.append("""
#      default: begin
#        ldata_v                  = lren;
#      end
#    endcase
#  end""")
#    self.bodys.append("  always_comb begin")
#    self.bodys.append("    unique casez(laddr)")
#    self.bodys.extend(self.udatas)
#    self.bodys.append("""
#      default: begin
#        ldata[63:32]             = {32'h5555_AAAA};
#      end
#    endcase
#  end""")
#    self.bodys.append("  always_comb begin")
#    self.bodys.append("    unique casez(laddr)")
#    self.bodys.extend(self.ldatas)
#    self.bodys.append("""
#      default: begin
#        ldata[31:0]              = {%d'b0,laddr};
#      end
#    endcase
#  end"""%(32-self.maxdim))
    self.bodys.append(self.buss)
    self.bodys.extend(self.assigns)
    lines.extend(self.bodys)
    lines.append("")
    lines.append("endmodule")

    #print "\n".join(lines)
    return lines

class vlog(common):
  """
  """
  outfmt    ='  output logic {0:<15s} {1:s}'
  infmt     ='  input        {0:<15s} {1:s}'
  wirefmt   ='  wire   {0:<15s}       {1:s};'
  logicfmt  ='  logic  {0:<15s}       {1:s};'

  addrdecfmt     ="  assign {0:<40s} = (addr[9:0] == {1:<10s}) & ({2:s}_en == 1'b1);"
  addrdecwrclrfmt="  assign {0:<40s} = (addr[9:0] == {1:<10s}) & (lwr_en == 1'b1) & (lwr_data[0] == 1'b1);"
  addrdecmemfmt  ="  assign {0:<40s} = (addr[9:0] >= {1:<10s}) & (addr[9:0] < {2:<10d}) & ({3:s}_en == 1'b1);"
  rdmux1fmt ="      %-40s : ldata = %s;"
  rdmux2fmt ="      %-40s : ldata = {%d'b0,%s};"
  rdmux3fmt ="      %-40s : ldata = {%s,%d'b0};"
  rdmux4fmt ="      %-40s : ldata = {%d'b0,%s,%d'b0};"
  rwregfmt  =""" // rw: %s
  always_ff @(posedge clk or negedge rst_n)
  begin
    if (~rst_n) begin
       %-40s <= %s;
    end else begin
       %-40s <= (%s == 1'b1)? lwr_data%s : %s;
    end
  end
"""
  rwusrregfmt  =""" // rw: %s
  always_ff @(posedge clk or negedge rst_n)
  begin
    if (~rst_n) begin
       %-40s <= %s;
       %-40s <= 1'b0;
    end else begin
       %-40s <= (%s == 1'b1)? lwr_data%s : %s;
       %-40s <= %s;
    end
  end
"""
  rwregheadfmt  =""" // rw: %s
  always_ff @(posedge clk or negedge rst_n)
  begin
    if (~rst_n) begin
       %-40s <= %s;
    end else begin"""
  rwregbodyfmt  ="""       %-40s <= (%s == 1'b1)? lwr_data%s : %s;"""
  rwregtailfmt  ="""    end
  end
"""
  rwusrregheadfmt  =""" // rw: %s
  always_ff @(posedge clk or negedge rst_n)
  begin
    if (~rst_n) begin
       %-40s <= %s;
       %-40s <= 1'b0;
    end else begin"""
  rwusrregtailfmt  ="""       %-40s <= %s;
    end
  end
"""
  rwassignfmt  ="  assign %-40s = %s%s;"
  roassignfmt  =""" // ro: %s
  assign %-40s = %s;
"""
  assignfmt ='  assign {0:<40s} = {1:s};'
  frcfmt  =""" // frc: %s
  always_ff @(posedge clk or negedge rst_n)
  begin
    if (~rst_n)
      %-40s <= %d'h0;
    else if (%s == 1'b1)
      %-40s <= %d'h0;
    else
      %-40s <= (%s == 1'b1)? %s + 1 : %s;
  end
"""
  frcincszfmt  =""" // frc: %s
  always_ff @(posedge clk or negedge rst_n)
  begin
    if (~rst_n)
      %-40s <= %d'h0;
    else if (%s == 1'b1)
      %-40s <= %d'h0;
    else
      %-40s <= (%s == 1'b1)? %s + %s : %s;
  end
"""
  lrcfmt  =""" // lrc: %s
  always_ff @(posedge clk or negedge rst_n)
  begin
    if (~rst_n)
      begin
        %-40s <= %d'h0;
        %-40s <= %d'h0;
      end
    else if (%s == 1'b1)
      begin
        %-40s <= %d'h0;
        %-40s <= %d'h0;
      end else begin
        if(%s) begin
          %-40s <= (%s == 1'b1)? %d'h1 : %d'h0;
          %-40s <= %s;
        end else begin
          %-40s <= (%s == 1'b1)? %s + 'h1 : %s;
        end
    end
  end
"""
  satcfmt  =""" // satc: %s
  always_ff @(posedge clk or negedge rst_n)
  begin
    if (~rst_n)
      %-40s <= %d'h0;
    else if (%s == 1'b1)
      %-40s <= %d'h0;
    else
      %-40s <= (%s == 1'b1 && %s != {%d{1'b1}})? %s + 1 : %s;
  end
"""
  memfmt  =""" // mem: %s
  always_ff @(posedge clk or negedge rst_n)
  begin
    if (~rst_n) begin
       %-40s <= 1'b0;
       %-40s <= 'b0;
       %-40s <= 'b0;
       %-40s <= 'b0;
       %-40s <= 'b0;
    end else begin
       %-40s <= (%s | %s)? ~%s : %s;
       %-40s <= (addr - %s);
       %-40s <= %s;
       %-40s <= wr_data;
       %-40s <= %s;
    end
  end
  assign %-40s = %s;
  assign %-40s = %s;
  assign %-40s = %s;
  assign %-40s = %s;
"""
  fifofmt  =""" // mem: %s
  always_ff @(posedge clk or negedge rst_n)
  begin
    if (~rst_n) begin
       %-40s <= 1'b0;
       %-40s <= 'b0;
       %-40s <= 'b0;
       %-40s <= 'b0;
    end else begin
       %-40s <= (%s | %s)? ~%s : %s;
       %-40s <= %s;
       %-40s <= wr_data;
       %-40s <= %s;
    end
  end
  assign %-40s = %s;
  assign %-40s = %s;
  assign %-40s = %s;
"""
  mm_if={
  'in':[
    ('clk',''),
    ('rst_n',''),
    ('wr_en',''),
    ('rd_en',''),
    ('addr','[9:0]'),
    ('wr_data','[63:0]')
  ],
  'out':[
    ('rd_data','[63:0]'),
    ('rd_data_v','')
  ]
}
  base_nets=[
    ('memrd_en_latch',''),
    ('lwr_en',''),
    ('lwr_data','[63:0]'),
    ('ldata','[63:0]'),
    ('memrd_en',''),
    ('memrd_v','')
  ]
  def __init__(self,db):
    """
    """
    self.db=db
    self.outs=[]
    self.ins=[]
    self.wires=[]
    self.logics=[]
    self.addrdecs=[]
    self.rdmuxs=[]
    self.bodys=[]
    self.memrd_vs=[]
    self.memrd_en_latchs=[]
    self.ins.extend(map(lambda x: self.infmt.format(x[1],x[0]),self.mm_if['in']))
    self.outs.extend(map(lambda x: self.outfmt.format(x[1],x[0]),self.mm_if['out']))
    self.logics.extend(map(lambda x: self.logicfmt.format(x[1],x[0]),self.base_nets))
    self.parse()

  def rdmux_statement(self,sel,name,end,start,single_bit_field=False):
    """
    """
    if start==0:
       if end==63:
        self.rdmuxs.append(self.rdmux1fmt%(sel,name))
       else:
        self.rdmuxs.append(self.rdmux2fmt%(sel,(63-end),name))
    else:
       if end==63:
        self.rdmuxs.append(self.rdmux3fmt%(sel,name,start))
       else:
        if single_bit_field and name.startswith('WREG'):
          self.rdmuxs.append(self.rdmux4fmt%(sel,(63-end),name,start))
        else:
          self.rdmuxs.append(self.rdmux4fmt%(sel,(63-end),"%s[%d:%d]"%(name,end,start),start))
  def default_w_offset(self,default,end,start):
    """
    """
    return "%d'h%x"%(end-start+1,(self.vlognum2int(default) >> start))

  def single_bit_field_reg(self,reg,attrs):
    """
    """
    name=filter(lambda x: x not in self.reg_attrs,attrs.keys())[0]
    name_upper=reg.upper()
    #name_upper=name.upper()
    if '_default' not in attrs:
      attrs['_default'] = "64'h0"
    if   attrs['_typ']=='RW':
      if '_usr' in attrs:
        self.outs.append(self.outfmt.format('','oREG_%s_WR_EN'%name_upper))
      self.outs.append(self.outfmt.format(self.dim2disp_wo_offset(attrs[name]['_loc']),'oREG_%s'%name_upper))
      self.logics.append(self.logicfmt.format(self.dim2disp_wo_offset(attrs[name]['_loc']),'WREG_%s'%name_upper))
      if '_usr' in attrs:
        self.logics.append(self.logicfmt.format('','%s_wr_sel_d'%name_upper))
      self.wires.append(self.wirefmt.format('','%s_wr_sel'%name_upper))
      self.wires.append(self.wirefmt.format('','%s_rd_sel'%name_upper))
      self.addrdecs.append(self.addrdecfmt.format('%s_wr_sel'%name_upper,attrs['_offset'],'lwr'))
      self.addrdecs.append(self.addrdecfmt.format('%s_rd_sel'%name_upper,attrs['_offset'],'rd'))
      self.rdmux_statement('%s_rd_sel'%name_upper,'WREG_%s'%name_upper,self.toend(attrs[name]['_loc']),self.tostart(attrs[name]['_loc']),single_bit_field=True)
      if '_typ' in attrs[name]:
        if attrs[name]['_typ']=='SC':
          rwregtmpl=('%s'%name_upper,
                     'WREG_%s'%name_upper,
                       self.default_w_offset(attrs['_default'],self.toend(attrs[name]['_loc']),self.tostart(attrs[name]['_loc'])),
                     'WREG_%s'%name_upper,
                      '%s_wr_sel'%name_upper,
                      attrs[name]['_loc'],
                      "%d'b0"%(self.toend(attrs[name]['_loc'])-self.tostart(attrs[name]['_loc'])+1))
        else:
          rwregtmpl=('%s'%name_upper,
                     'WREG_%s'%name_upper,
                       self.default_w_offset(attrs['_default'],self.toend(attrs[name]['_loc']),self.tostart(attrs[name]['_loc'])),
                     'WREG_%s'%name_upper,
                      '%s_wr_sel'%name_upper,
                      attrs[name]['_loc'],
                      'WREG_%s'%name_upper)
      else:
        rwregtmpl=('%s'%name_upper,
                   'WREG_%s'%name_upper,
                     self.default_w_offset(attrs['_default'],self.toend(attrs[name]['_loc']),self.tostart(attrs[name]['_loc'])),
                   'WREG_%s'%name_upper,
                    '%s_wr_sel'%name_upper,
                    attrs[name]['_loc'],
                    'WREG_%s'%name_upper)
      if '_usr' in attrs:
        self.bodys.append(self.rwusrregfmt%(rwregtmpl[:3]+('%s_wr_sel_d'%name_upper,)+rwregtmpl[3:]+('%s_wr_sel_d'%name_upper,'%s_wr_sel'%name_upper)))
      else:
        self.bodys.append(self.rwregfmt%rwregtmpl)
      rwassigntmpl=('oREG_%s'%name_upper,
                 'WREG_%s'%name_upper,
                 '%s'%self.dim2disp_wo_offset(attrs[name]['_loc']))
      self.bodys.append(self.rwassignfmt%rwassigntmpl)
      if '_usr' in attrs:
        self.bodys.append(self.assignfmt.format('oREG_%s_WR_EN'%name_upper,'%s_wr_sel_d'%name_upper))
    elif attrs['_typ']== 'RO':
      self.ins.append(self.infmt.format(self.dim2disp_wo_offset(attrs[name]['_loc']),'iREG_%s'%name_upper))
      self.wires.append(self.wirefmt.format('','%s_rd_sel'%name_upper))
      self.wires.append(self.wirefmt.format(self.dim2disp_wo_offset(attrs[name]['_loc']),'%s'%name_upper))
      self.addrdecs.append(self.addrdecfmt.format('%s_rd_sel'%name_upper,attrs['_offset'],'rd'))
      self.rdmux_statement('%s_rd_sel'%name_upper,name_upper,self.toend(attrs[name]['_loc']),self.tostart(attrs[name]['_loc']),single_bit_field=True)
      self.bodys.append(self.roassignfmt%(name_upper,name_upper,"%s%s"%('iREG_%s'%name_upper,self.dim2disp_wo_offset(attrs[name]['_loc']))))
    elif attrs['_typ']== 'FRC':
      self.ins.append(self.infmt.format('','iREG_%s_EN'%name_upper))
      if '_usr' in attrs:
        self.outs.append(self.outfmt.format(self.dim2disp_wo_offset(attrs[name]['_loc']),'oREG_%s_USR'%name_upper))
      if '_incsz' in attrs:
        self.ins.append(self.infmt.format('[%d:0]'%(int(attrs['_incsz'])-1),'iREG_%s_INC'%name_upper))
      self.logics.append(self.logicfmt.format(self.dim2disp_wo_offset(attrs[name]['_loc']),'%s'%name_upper))
      self.wires.append(self.wirefmt.format('','%s_wr_sel'%name_upper))
      self.wires.append(self.wirefmt.format('','%s_rd_sel'%name_upper))
      self.addrdecs.append(self.addrdecfmt.format('%s_rd_sel'%name_upper,attrs['_offset'],'rd'))
      self.addrdecs.append(self.addrdecwrclrfmt.format('%s_wr_sel'%name_upper,attrs['_offset']))
      self.rdmux_statement('%s_rd_sel'%name_upper,name_upper,self.toend(attrs[name]['_loc']),self.tostart(attrs[name]['_loc']),single_bit_field=True)
      if '_incsz' in attrs:
        frcincsztmpl=('%s'%name_upper,
                 '%s'%name_upper,
                  self.dim2size(self.dim2disp_wo_offset(attrs[name]['_loc'])),
                 '%s_wr_sel'%name_upper,
                 '%s'%name_upper,
                    self.dim2size(self.dim2disp_wo_offset(attrs[name]['_loc'])),

                 '%s'%name_upper,
                  'iREG_%s_EN'%name_upper,
                  '%s'%name_upper,
                  'iREG_%s_INC'%name_upper,
                  '%s'%name_upper)
        self.bodys.append(self.frcincszfmt%frcincsztmpl)
      else:
        frctmpl=('%s'%name_upper,
                 '%s'%name_upper,
                  self.dim2size(self.dim2disp_wo_offset(attrs[name]['_loc'])),
                 '%s_wr_sel'%name_upper,
                 '%s'%name_upper,
                    self.dim2size(self.dim2disp_wo_offset(attrs[name]['_loc'])),

                 '%s'%name_upper,
                  'iREG_%s_EN'%name_upper,
                  '%s'%name_upper,
                  '%s'%name_upper)
        self.bodys.append(self.frcfmt%frctmpl)
      if '_usr' in attrs:
        self.bodys.append("  assign oREG_%s_USR = %s_rd;"%(name_upper,name_upper))
    elif attrs['_typ']== 'LRC':
      self.ins.append(self.infmt.format('','iREG_%s_EN'%name_upper))
      self.ins.append(self.infmt.format('','iREG_%s_LATCH'%name_upper))
      if '_usr' in attrs:
        self.outs.append(self.outfmt.format(self.dim2disp_wo_offset(attrs[name]['_loc']),'oREG_%s_USR'%name_upper))
      self.logics.append(self.logicfmt.format(self.dim2disp_wo_offset(attrs[name]['_loc']),'%s'%name_upper))
      self.wires.append(self.wirefmt.format('','%s_wr_sel'%name_upper))
      self.wires.append(self.wirefmt.format('','%s_rd_sel'%name_upper))
      self.logics.append(self.logicfmt.format(self.dim2disp_wo_offset(attrs[name]['_loc']),'%s_rd'%name_upper))
      self.addrdecs.append(self.addrdecfmt.format('%s_rd_sel'%name_upper,attrs['_offset'],'rd'))
      self.addrdecs.append(self.addrdecwrclrfmt.format('%s_wr_sel'%name_upper,attrs['_offset']))
      self.rdmux_statement('%s_rd_sel'%name_upper,'%s_rd'%name_upper,self.toend(attrs[name]['_loc']),self.tostart(attrs[name]['_loc']),single_bit_field=True)
      lrctmpl=('%s'%name_upper,
               '%s'%name_upper,
                self.dim2size(self.dim2disp_wo_offset(attrs[name]['_loc'])),
               '%s_rd'%name_upper,
                self.dim2size(self.dim2disp_wo_offset(attrs[name]['_loc'])),
               '%s_wr_sel'%name_upper,
               '%s'%name_upper,
                self.dim2size(self.dim2disp_wo_offset(attrs[name]['_loc'])),
               '%s_rd'%name_upper,
                self.dim2size(self.dim2disp_wo_offset(attrs[name]['_loc'])),

               'iREG_%s_LATCH'%name_upper,
               '%s'%name_upper,
                'iREG_%s_EN'%name_upper,
                self.dim2size(self.dim2disp_wo_offset(attrs[name]['_loc'])),
                self.dim2size(self.dim2disp_wo_offset(attrs[name]['_loc'])),
               '%s_rd'%name_upper,
                '%s'%name_upper,
               '%s'%name_upper,
                'iREG_%s_EN'%name_upper,
               '%s'%name_upper,
               '%s'%name_upper)
      self.bodys.append(self.lrcfmt%lrctmpl)
      if '_usr' in attrs:
        self.bodys.append("  assign oREG_%s_USR = %s_rd;"%(name_upper,name_upper))
    elif attrs['_typ']== 'TRC':
      pass
    elif attrs['_typ']== 'SATC':
      self.ins.append(self.infmt.format('','iREG_%s_EN'%name_upper))
      self.logics.append(self.logicfmt.format(self.dim2disp_wo_offset(attrs[name]['_loc']),'%s'%name_upper))
      self.wires.append(self.wirefmt.format('','%s_wr_sel'%name_upper))
      self.wires.append(self.wirefmt.format('','%s_rd_sel'%name_upper))
      self.addrdecs.append(self.addrdecfmt.format('%s_rd_sel'%name_upper,attrs['_offset'],'rd'))
      self.addrdecs.append(self.addrdecwrclrfmt.format('%s_wr_sel'%name_upper,attrs['_offset']))
      self.rdmux_statement('%s_rd_sel'%name_upper,name_upper,self.toend(attrs[name]['_loc']),self.tostart(attrs[name]['_loc']),single_bit_field=True)
      satctmpl=('%s'%name_upper,
               '%s'%name_upper,
               self.dim2size(self.dim2disp_wo_offset(attrs[name]['_loc'])),
               '%s_wr_sel'%name_upper,
               '%s'%name_upper,
               self.dim2size(self.dim2disp_wo_offset(attrs[name]['_loc'])),
               '%s'%name_upper,
               'iREG_%s_EN'%name_upper,
               '%s'%name_upper,
               self.dim2size(self.dim2disp_wo_offset(attrs[name]['_loc'])),
               '%s'%name_upper,
               '%s'%name_upper)
      self.bodys.append(self.satcfmt%satctmpl)
    elif attrs['_typ']== 'MEM':
      if self.vlognum2int(attrs['_size']) == 1:
        self.ins.append(self.infmt.format('','iREG_%s_V'%name_upper))
        self.ins.append(self.infmt.format(attrs[name]['_loc'],'iREG_%s_RD'%name_upper))
        self.outs.append(self.outfmt.format(attrs[name]['_loc'],'oREG_%s_WR'%name_upper))
        self.outs.append(self.outfmt.format('','oREG_%s_WR_EN'%name_upper))
        self.outs.append(self.outfmt.format('','oREG_%s_RD_EN'%name_upper))

        self.wires.append(self.wirefmt.format('','%s_wr_sel'%name_upper))
        self.wires.append(self.wirefmt.format('','%s_rd_sel'%name_upper))

        self.logics.append(self.logicfmt.format('','%s_rd_wait'%name_upper))
        self.logics.append(self.logicfmt.format(self.dim2disp_wo_offset(attrs[name]['_loc']),'%s_wr_d'%name_upper))
        self.logics.append(self.logicfmt.format('','%s_wen_d'%name_upper))
        self.logics.append(self.logicfmt.format('','%s_ren_d'%name_upper))

        self.addrdecs.append(self.addrdecfmt.format('%s_rd_sel'%name_upper,attrs['_offset'],'rd'))
        self.addrdecs.append(self.addrdecfmt.format('%s_wr_sel'%name_upper,attrs['_offset'],'lwr'))
        self.rdmux_statement('%s_rd_wait'%name_upper,'iREG_%s_RD'%name_upper,self.toend(attrs[name]['_loc']),self.tostart(attrs[name]['_loc']),single_bit_field=True)
        self.memrd_vs.append('iREG_%s_V'%name_upper)
        self.memrd_en_latchs.append('%s_rd_sel'%name_upper)
        fifotmpl=('%s'%name_upper,
                 '%s_rd_wait'%name_upper,
                 '%s_wr_d'%name_upper,
                 '%s_wen_d'%name_upper,
                 '%s_ren_d'%name_upper,

                 '%s_rd_wait'%name_upper,
                   '%s_rd_sel'%name_upper,
                   'iREG_%s_V'%name_upper,
                   '%s_rd_wait'%name_upper,
                   '%s_rd_wait'%name_upper,
                 '%s_wen_d'%name_upper,
                   '%s_wr_sel'%name_upper,
                 '%s_wr_d'%name_upper,
                 '%s_ren_d'%name_upper,
                   '%s_rd_sel'%name_upper,

                 'oREG_%s_WR'%name_upper,
                   '%s_wr_d'%name_upper,
                 'oREG_%s_WR_EN'%name_upper,
                   '%s_wen_d'%name_upper,
                 'oREG_%s_RD_EN'%name_upper,
                   '%s_ren_d'%name_upper)
        self.bodys.append(self.fifofmt%fifotmpl)
      else:
        self.ins.append(self.infmt.format('','iREG_%s_V'%name_upper))
        self.ins.append(self.infmt.format(attrs[name]['_loc'],'iREG_%s_RD'%name_upper))
        self.outs.append(self.outfmt.format(self.size2dim(attrs['_size']),'oREG_%s_ADDR'%name_upper))
        self.outs.append(self.outfmt.format(attrs[name]['_loc'],'oREG_%s_WR'%name_upper))
        self.outs.append(self.outfmt.format('','oREG_%s_WR_EN'%name_upper))
        self.outs.append(self.outfmt.format('','oREG_%s_RD_EN'%name_upper))

        self.wires.append(self.wirefmt.format('','%s_wr_sel'%name_upper))
        self.wires.append(self.wirefmt.format('','%s_rd_sel'%name_upper))

        self.logics.append(self.logicfmt.format('','%s_rd_wait'%name_upper))
        self.logics.append(self.logicfmt.format(self.size2dim(attrs['_size']),'%s_addr_d'%name_upper))
        self.logics.append(self.logicfmt.format(self.dim2disp_wo_offset(attrs[name]['_loc']),'%s_wr_d'%name_upper))
        self.logics.append(self.logicfmt.format('','%s_wen_d'%name_upper))
        self.logics.append(self.logicfmt.format('','%s_ren_d'%name_upper))

        self.addrdecs.append(self.addrdecmemfmt.format('%s_rd_sel'%name_upper,attrs['_offset'],self.vlognumadd(attrs['_offset'],attrs['_size']),'rd'))
        self.addrdecs.append(self.addrdecmemfmt.format('%s_wr_sel'%name_upper,attrs['_offset'],self.vlognumadd(attrs['_offset'],attrs['_size']),'lwr'))
        self.rdmux_statement('%s_rd_wait'%name_upper,'iREG_%s_RD'%name_upper,self.toend(attrs[name]['_loc']),self.tostart(attrs[name]['_loc']),single_bit_field=True)
        self.memrd_vs.append('iREG_%s_V'%name_upper)
        self.memrd_en_latchs.append('%s_rd_sel'%name_upper)
        memtmpl=('%s'%name_upper,
                 '%s_rd_wait'%name_upper,
                 '%s_addr_d'%name_upper,
                 '%s_wr_d'%name_upper,
                 '%s_wen_d'%name_upper,
                 '%s_ren_d'%name_upper,

                 '%s_rd_wait'%name_upper,
                   '%s_rd_sel'%name_upper,
                   'iREG_%s_V'%name_upper,
                   '%s_rd_wait'%name_upper,
                   '%s_rd_wait'%name_upper,
                 '%s_addr_d'%name_upper,
                   attrs['_offset'],
                 '%s_wen_d'%name_upper,
                   '%s_wr_sel'%name_upper,
                 '%s_wr_d'%name_upper,
                 '%s_ren_d'%name_upper,
                   '%s_rd_sel'%name_upper,

                 'oREG_%s_ADDR'%name_upper,
                   '%s_addr_d'%name_upper,
                 'oREG_%s_WR'%name_upper,
                   '%s_wr_d'%name_upper,
                 'oREG_%s_WR_EN'%name_upper,
                   '%s_wen_d'%name_upper,
                 'oREG_%s_RD_EN'%name_upper,
                   '%s_ren_d'%name_upper)
        self.bodys.append(self.memfmt%memtmpl)
  def concatenate_bits(self,regname,bitfields):
    """
    """
    prev=-1
    fs=[]
    for name,dim in bitfields:
      start=self.tostart(dim)
      end=self.toend(dim)
      if start != (prev+1):
        fs.append("%d'b0"%(start-(prev+1)))
      fs.append('iREG_%s_%s'%(regname,name.upper()))
      prev=end
    fs.reverse()
    return '{%s}'%(','.join(fs))

  def multiple_bit_field_reg(self,reg,attrs,bitfields):
    """
    """
    name=filter(lambda x: x not in self.reg_attrs,attrs.keys())[0]
    name_upper=reg.upper()
    #name_upper=name.upper()
    regsize=self.toend(bitfields[-1][1])+1
    if '_default' not in attrs:
      attrs['_default'] = "64'h0"
    if   attrs['_typ']=='RW':
      if '_usr' in attrs:
        self.outs.append(self.outfmt.format('','oREG_%s_WR_EN'%name_upper))
      self.outs.extend(map(lambda x: self.outfmt.format(self.dim2disp_wo_offset(bitfields[x][1]),'oREG_%s_%s'%(name_upper,bitfields[x][0].upper())),range(len(bitfields))))

      self.logics.append(self.logicfmt.format('[%d:0]'%(regsize-1),'WREG_%s'%name_upper))
      if '_usr' in attrs:
        self.logics.append(self.logicfmt.format('','%s_wr_sel_d'%name_upper))
      self.wires.append(self.wirefmt.format('','%s_wr_sel'%name_upper))
      self.wires.append(self.wirefmt.format('','%s_rd_sel'%name_upper))
      self.addrdecs.append(self.addrdecfmt.format('%s_rd_sel'%name_upper,attrs['_offset'],'rd'))
      self.addrdecs.append(self.addrdecfmt.format('%s_wr_sel'%name_upper,attrs['_offset'],'lwr'))
      self.rdmux_statement('%s_rd_sel'%name_upper,'WREG_%s'%name_upper,self.toend(bitfields[-1][1]),self.tostart(bitfields[0][1]),single_bit_field=False)
      rwregheadtmpl=('%s'%name_upper,
                     'WREG_%s'%name_upper,
                      self.default_w_offset(attrs['_default'],regsize-1,0))
      if '_usr' in attrs:
        self.bodys.append(self.rwusrregheadfmt%(rwregheadtmpl+('%s_wr_sel_d'%name_upper,)))
      else:
        self.bodys.append(self.rwregheadfmt%rwregheadtmpl)
      for bitname,dim in bitfields:
        if '_typ' in attrs[bitname]:
          if attrs[bitname]['_typ']=='SC':
            rwregbodytmpl=('%s%s'%('WREG_%s'%name_upper,self.dim2index(dim)),'%s_wr_sel'%name_upper,self.dim2index(dim),"%d'b0"%self.dim2size(dim))
            self.bodys.append(self.rwregbodyfmt%rwregbodytmpl)
          else:
            rwregbodytmpl=('%s%s'%('WREG_%s'%name_upper,self.dim2index(dim)),'%s_wr_sel'%name_upper,self.dim2index(dim),'%s%s'%('WREG_%s'%name_upper,self.dim2index(dim)))
            self.bodys.append(self.rwregbodyfmt%rwregbodytmpl)
        else:
          rwregbodytmpl=('%s%s'%('WREG_%s'%name_upper,self.dim2index(dim)),'%s_wr_sel'%name_upper,self.dim2index(dim),'%s%s'%('WREG_%s'%name_upper,self.dim2index(dim)))
          self.bodys.append(self.rwregbodyfmt%rwregbodytmpl)
      if '_usr' in attrs:
        self.bodys.append(self.rwusrregtailfmt%('%s_wr_sel_d'%name_upper,'%s_wr_sel'%name_upper))
      else:
        self.bodys.append(self.rwregtailfmt)
      self.bodys.extend(map(lambda x: self.rwassignfmt% ('oREG_%s_%s'%(name_upper,bitfields[x][0].upper()),
                                                         'WREG_%s'%name_upper,
                                                         '%s'%self.dim2index(bitfields[x][1])),range(len(bitfields))))
      if '_usr' in attrs:
        self.bodys.append(self.assignfmt.format('oREG_%s_WR_EN'%name_upper,'%s_wr_sel_d'%name_upper))
    elif attrs['_typ']== 'RO':
      self.ins.extend(map(lambda x: self.infmt.format(self.dim2disp_wo_offset(bitfields[x][1]),'iREG_%s_%s'%(name_upper,bitfields[x][0].upper())),range(len(bitfields))))
      self.wires.append(self.wirefmt.format('','%s_rd_sel'%name_upper))
      self.wires.append(self.wirefmt.format('[%d:0]'%(regsize-1),'%s'%name_upper))
      self.addrdecs.append(self.addrdecfmt.format('%s_rd_sel'%name_upper,attrs['_offset'],'rd'))
      self.rdmux_statement('%s_rd_sel'%name_upper,name_upper,self.toend(bitfields[-1][1]),self.tostart(bitfields[0][1]),single_bit_field=False)
      self.bodys.append(self.roassignfmt%(name_upper,name_upper,self.concatenate_bits(name_upper,bitfields)))
  def parse(self):
    """
    """
    self.name=os.path.splitext(os.path.basename(self.db.keys()[0]))[0]
    self.dir=os.path.dirname(self.db.keys()[0])
    self.regs=self.db.values()[0]
    #pprint(self.regs)
    #for reg,attrs in self.regs.items():
    for reg in sorted(self.regs,key=lambda x: self.vlognum2int(self.regs[x]['_offset'])):
      attrs=self.regs[reg]
      bitfields=[]
      if len(filter(lambda x: x not in self.reg_attrs,attrs.keys()))==1: # single bit field
        self.single_bit_field_reg(reg,attrs)
      else:
        bit_attrs={}
        for k in filter(lambda x: x in self.reg_attrs,sorted(attrs.keys())): # reg attr
          pass
        for k in filter(lambda x: x not in self.reg_attrs,sorted(attrs.keys())): # bit field
          bit_attrs[k]=attrs[k]
        for bit in sorted(bit_attrs,key=lambda bit: self.tostart(bit_attrs[bit]['_loc'])):
          bitfields.append((bit,bit_attrs[bit]['_loc']))
        self.multiple_bit_field_reg(reg,attrs,bitfields)


  def write(self,file):
    """
    """
    OUTFILE=open(file,'w')
    lines=[]
    lines.append("""/********************************CONFIDENTIAL****************************
* Copyright (c) 2014 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: $
* $Author: $
* $Date: $
* $Revision: $
* Description:
* This module contains configuration registers and counters.
* This was generated from eth_mac/doc/eth_mac_regs.xml and vgen script. Do not manually modify it
* All manual changes will be overwritten by script whenever new file is generated.

***************************************************************************/
module %s #(
  parameter LITE=0
) (
%s
);
"""%(self.name,',\n'.join(self.outs+self.ins)))
    lines.append("")
    lines.extend(self.wires+self.logics)
    lines.append("")
    lines.append("// address decode")
    lines.extend(self.addrdecs)
    if len(self.memrd_vs)==0:
      lines.append("  assign memrd_v = 1'b0;")
    else:
      lines.append("  assign memrd_v = %s;"%(' | '.join(self.memrd_vs)))
    lines.append("""
  always_comb begin
    case(1'b1)
%s
      default : ldata = {32'h5555_AAAA,{22{1'b0}},addr[9:0]};
    endcase
  end
"""%('\n'.join(self.rdmuxs)))
    if len(self.memrd_en_latchs)==0:
      lines.append("""// memrd latch
  assign memrd_en_latch = 1'b0;

// global ff
  always_ff @(posedge clk or negedge rst_n)
  begin
    if (~rst_n) begin
       rd_data <= 64'h0;
       rd_data_v <= 1'b0;
       memrd_en <=  1'b0;
       lwr_en <=  1'b0;
       lwr_data <= 64'h0;
    end else begin
       lwr_en <= wr_en;
       lwr_data <= wr_data;
       memrd_en <= (memrd_en_latch | memrd_v)? ~memrd_en : memrd_en;
       rd_data <= (memrd_v | rd_en)? ldata : rd_data;
       rd_data_v <= ((wr_en|rd_en) & ~memrd_en_latch) | memrd_v;
    end
  end
""")
    else:
      lines.append("""// memrd latch
  always_comb begin
    case (1'b1)
%s
      default : memrd_en_latch = 1'b0;
    endcase
  end

// global ff
  always_ff @(posedge clk or negedge rst_n)
  begin
    if (~rst_n) begin
       rd_data <= 64'h0;
       rd_data_v <= 1'b0;
       memrd_en <=  1'b0;
       lwr_en <=  1'b0;
       lwr_data <= 64'h0;
    end else begin
       lwr_en <= wr_en;
       lwr_data <= wr_data;
       memrd_en <= (memrd_en_latch | memrd_v)? ~memrd_en : memrd_en;
       rd_data <= (memrd_v | rd_en)? ldata : rd_data;
       rd_data_v <= ((wr_en|rd_en) & ~memrd_en_latch) | memrd_v;
    end
  end
"""%('\n'.join(map(lambda x: "      %-40s : memrd_en_latch = 1'b1;"%x,self.memrd_en_latchs))))
    lines.extend(self.bodys)
    lines.append("endmodule")
    #print "\n".join(lines)
    OUTFILE.write("\n".join(lines))

class reg_db(object):
  """
  """
  file=''
  debug=0
  def __init__(self,
               dir,
               name,
               debug=0):
    """
    """
    self.dir=dir
    self.name=name
    if self.name=='':
      self.doc=''
    else:
      self.file=os.path.join(self.dir,self.name)
      self.doc=xml.dom.minidom.parse(self.file)
    self.src2param={}
    self.param={}
    self.srcs=[]
    self.nosrcs=[]
    self.debug=debug

  def isRegister(self):
    return self.doc.lastChild.nodeName == 'decl_reg_list'

  def isProject(self):
    return self.doc.lastChild.nodeName == 'vi_registers'

  def get_file(self):
    return self.file

  def print_db(self):
    """
    """
    pprint(self.src2param)
    pprint(self.param)
    pprint(self.srcs)

  def gen_reg_db(self,file):
    """
    """
    l0=self.doc.lastChild
    topname=l0.nodeName
    self.src2param[file]={}
    for l1 in l0.childNodes:
      if l1.nodeType == l0.TEXT_NODE: # 3
        if l1.nodeValue.strip() == "":
          continue
        else:
          if self.debug: print "Error 2 : text node is not empty",l1.nodeValue.strip()
      elif l1.nodeType == l0.ELEMENT_NODE: #1
        #print l1.nodeType ,l1.toprettyxml().strip()
        regex_range=''
        default=''
        name=''
        offset=''
        size=''
        typ=''
        usr=''
        incsz=''
        for item in l1.attributes.items():
          k=item[0]
          v=item[1]
          if k == "regex_range": regex_range = v
          if k == "default": default = v
          if k == "name": name = v
          if k == "offset": offset = v
          if k == "size": size = v
          if k == "type": typ = v
          if k == "usr": usr = v
          if k == "incsz": incsz = v
        if name !='':
          self.src2param[file][name]={}
          if regex_range != '':
            self.src2param[file][name]['_regex_range']=regex_range
          if default != '':
            self.src2param[file][name]['_default']=default
          if offset != '':
            self.src2param[file][name]['_offset']=offset
          if size != '':
            self.src2param[file][name]['_size']=size
          if typ != '':
            self.src2param[file][name]['_typ']=typ
          if usr != '':
            self.src2param[file][name]['_usr']=usr
          if incsz != '':
            self.src2param[file][name]['_incsz']=incsz
        else:
          if self.debug: print "Error 3 : no name attribute",l1.toprettyxml().strip()
          continue
        for l2 in l1.childNodes:
          if l2.nodeType == l0.TEXT_NODE: # 3
            if l2.nodeValue.strip() == "":
              continue
            else:
              descr=l2.nodeValue.strip()
              if descr !='':
                self.src2param[file][name]['_descr']=descr
          elif l2.nodeType == l0.ELEMENT_NODE: #1
            name2=''
            loc=''
            typ=''
            for item in l2.attributes.items():
              k=item[0]
              v=item[1]
              if k == "name": name2 = v
              if k == "loc": loc = v
              if k == "type": typ = v
            if name2 !='':
              self.src2param[file][name][name2]={}
              if loc != '':
                self.src2param[file][name][name2]['_loc']=loc
              if typ != '':
                self.src2param[file][name][name2]['_typ']=typ
            else:
              if self.debug: print "Error 4 : no name attribute",l2.toprettyxml().strip()
              continue
            for l3 in l2.childNodes:
              if l3.nodeType == l0.TEXT_NODE: # 3
                if l3.nodeValue.strip() == "":
                  continue
                else:
                  descr=l3.nodeValue.strip()
                  if descr !='':
                    self.src2param[file][name][name2]['_descr']=descr
              elif l3.nodeType == l0.ELEMENT_NODE: #1
                  if self.debug: print "Error 5 : extra branch in the tree",l3.nodeValue.strip()

  def gen_proj_db(self,file):
    """
    """
    l0=self.doc.lastChild
    for l1 in l0.childNodes:
      if l1.nodeType == l0.TEXT_NODE: # 3
        if l1.nodeValue.strip() == "":
          continue
        else:
          if self.debug: print "Error 7 : text node is not empty",l1.nodeValue.strip()
      elif l1.nodeType == l0.ELEMENT_NODE: #1
        name=''
        base=''
        array=''
        sp=''
        size=''
        src=0
        clk=''
        for item in l1.attributes.items():
          k=item[0]
          v=item[1]
          if k == "array": array = v
          if k == "base": base = v
          if k == "name": name = v
          if k == "sp": sp = v
          if k == "size": size = v
          if k == "src": src = v
          if k == "clk": clk = v
        if name !='':
          self.param[name]={}
          if base != '':
            self.param[name]['base']=base
          if sp != '':
            self.param[name]['sp']=sp
          if size != '':
            self.param[name]['size']=size
          if array != '':
            self.param[name]['array']=array
          if clk != '':
            self.param[name]['clk']=clk
          if (src != '') and (src != 0):
            src=os.path.join(self.dir,src)
            self.param[name]['src']=src
            if src not in self.srcs:
              self.srcs.append(src)
            else:
              if self.debug: print "Error 8 : duplicate source file",src
          elif src == '':
            self.nosrcs.append((name,)) # stub for address decoder but no registers
        else:
          if self.debug: print "Error 9 : no name attribute",l1.toprettyxml().strip()
          continue
        for l2 in l1.childNodes:
          if l2.nodeType == l0.TEXT_NODE: # 3
            if l2.nodeValue.strip() == "":
              continue
            else:
              if self.debug: print "Error 10 : text node is not empty",l2.nodeValue.strip()
          elif l2.nodeType == l0.ELEMENT_NODE: #1
            name2=''
            base=''
            array=''
            sp=''
            size=''
            clk=''
            src=0
            for item in l2.attributes.items():
              k=item[0]
              v=item[1]
              if k == "array": array = v
              if k == "base": base = v
              if k == "name": name2 = v
              if k == "sp": sp = v
              if k == "size": size = v
              if k == "clk": clk = v
              if k == "src": src = v
            if name2 !='':
              self.param[name][name2]={}
              if base != '':
                self.param[name][name2]['base']=base
              if sp != '':
                self.param[name][name2]['sp']=sp
              if size != '':
                self.param[name][name2]['size']=size
              if array != '':
                self.param[name][name2]['array']=array
              if (src != '') and (src != 0):
                src=os.path.join(self.dir,src)
                self.param[name][name2]['src']=src
                if src not in self.srcs:
                  self.srcs.append(src)
                else:
                  if self.debug: print "Error 11 : duplicate source file",src
              elif src == '':
                self.nosrcs.append((name,name2)) # stub for address decoder but no registers
              if clk != '':
                self.param[name][name2]['clk']=clk
            else:
              if self.debug: print "Error 12 : no name attribute",l2.toprettyxml().strip()
              continue

            for l3 in l2.childNodes:
              if l3.nodeType == l0.TEXT_NODE: # 3
                if l3.nodeValue.strip() == "":
                  continue
                else:
                  if self.debug: print "Error 13 : text node is not empty",l3.nodeValue.strip()
              elif l3.nodeType == l0.ELEMENT_NODE: #1
                name3=''
                base=''
                src=0
                array=''
                sp=''
                size=''
                clk=''
                for item in l3.attributes.items():
                  k=item[0]
                  v=item[1]
                  if k == "array": array = v
                  if k == "base": base = v
                  if k == "name": name3 = v
                  if k == "sp": sp = v
                  if k == "size": size = v
                  if k == "clk": clk = v
                  if k == "src": src = v
                if name3 !='':
                  self.param[name][name2][name3]={}
                  if base != '':
                    self.param[name][name2][name3]['base']=base
                  if sp != '':
                    self.param[name][name2][name3]['sp']=sp
                  if size != '':
                    self.param[name][name2][name3]['size']=size
                  if array != '':
                    self.param[name][name2][name3]['array']=array
                  if (src != '') and (src !=0):
                    src=os.path.join(self.dir,src)
                    self.param[name][name2][name3]['src']=src
                    if src not in self.srcs:
                      self.srcs.append(src)
                    else:
                      if self.debug: print "Error 14 : duplicate source file",src
                  elif src == '':
                    self.nosrcs.append((name,name2,name3)) # stub for address decoder but no registers
                  if clk != '':
                    self.param[name][name2][name3]['clk']=clk
                else:
                  if self.debug: print "Error 15 : no name attribute",l3.toprettyxml().strip()
                  continue

class reg_table(vlog,common):
  def __init__(self,db,debug):
    """
    """
    self.debug=debug
    self.wb=xlwt.Workbook()
    self.ws=self.wb.add_sheet('self.name')
    self.ws.col(0).width=4800
    self.ws.col(3).width=11000
    self.db=db
    self.row=0
    self.parse()


  def single_bit_field_reg(self,reg,attrs):
    """
    """
    name=filter(lambda x: x not in self.reg_attrs,attrs.keys())[0]
    self.regheader(reg,attrs,name)
    if '_descr' not in attrs[name]:
      attrs[name]['_descr']=''
    if self.debug:
      print name,attrs[name]['_loc'],attrs['_typ'],attrs[name]['_descr']
    if self.toend(attrs[name]['_loc'])!=63:
      self.write_row('RSVD','[63:%d]'%(self.toend(attrs[name]['_loc'])+1),'RV','Reserved')
      self.row+=1
    descr=attrs[name]['_descr']
    self.write_row(name,attrs[name]['_loc'],attrs['_typ'],descr)
    self.row+=1
    if self.tostart(attrs[name]['_loc'])!=0:
      self.write_row('RSVD','[%d:0]'%(self.tostart(attrs[name]['_loc'])-1),'RV','Reserved')
      self.row+=1
    self.row+=2


  def multiple_bit_field_reg(self,reg,attrs,bitfields):
    """
    """
    name=filter(lambda x: x not in self.reg_attrs,attrs.keys())[0]
    self.regheader(reg,attrs,name)
    bitfields.reverse()
    if self.debug:
      for bitname,loc in bitfields:
        if '_descr' not in attrs[bitname]:
          attrs[bitname]['_descr']=''
        if '_typ' in attrs[bitname]:
          print bitname,loc,attrs[bitname]['_typ'],attrs[bitname]['_descr']
        else:
          print bitname,loc,attrs['_typ'],attrs[bitname]['_descr']
    prev=63
    for bitname,loc in bitfields:
      if prev!=self.toend(loc):
        self.write_row('RSVD','[%d:%d]'%(prev,self.toend(loc)+1),'RV','Reserved')
        self.row+=1
      descr=''
      if '_descr' in attrs[bitname]:
        descr=attrs[bitname]['_descr']
      if '_typ' in attrs[bitname]:
        self.write_row(bitname,loc,attrs[bitname]['_typ'],descr)
      else:
        self.write_row(bitname,loc,attrs['_typ'],descr)
      prev=self.tostart(loc)-1
      self.row+=1
    if prev!=-1:
      self.write_row('RSVD','[%d:0]'%(prev+1),'RV','Reserved')
      self.row+=1

    self.row+=1
  def write(self,file):
    """
    """
    self.wb.save(file)

class pytable(common):
  class pyreg(vlog):
    def __init__(self,path,db,debug):
      """
      """
      self.debug=debug
      self.db=db
      self.path=path
      self.bitfields={}
      self.register_defaults={}
      self.register_regex_ranges={}
      self.parse()


    def header(self,reg,attrs,name):
      """
      """
      if '_regex_range' not in attrs:
        attrs['_regex_range']=''
      if '_default' not in attrs:
        attrs['_default']=''
      if self.debug:
        print "Reg name: %s (%s)"%(reg,attrs['_typ'])
        if attrs['_typ']=='MEM':
          print "Offset: %04x Size: %s"%(self.vlognum2int(attrs['_offset']),attrs['_size'])
        else:
          print "Offset: %04x Default: %s"%(self.vlognum2int(attrs['_offset']),attrs['_default'])
      self.register_defaults[os.path.join(self.path,reg)]=attrs['_default']
      self.register_regex_ranges[os.path.join(self.path,reg)]=attrs['_regex_range']
      self.bitfields[os.path.join(self.path,reg)]=[]

    def single_bit_field_reg(self,reg,attrs):
      """
      """
      name=filter(lambda x: x not in self.reg_attrs,attrs.keys())[0]
      self.header(reg,attrs,name)
      if '_descr' not in attrs[name]:
        attrs[name]['_descr']=''
      if self.debug:
        print name,attrs[name]['_loc'],attrs['_typ'],attrs[name]['_descr']
      self.bitfields[os.path.join(self.path,reg)].append((name,self.dim2mask(attrs[name]['_loc'])))


    def multiple_bit_field_reg(self,reg,attrs,bitfields):
      """
      """
      name=filter(lambda x: x not in self.reg_attrs,attrs.keys())[0]
      self.header(reg,attrs,name)
      bitfields.reverse()
      if self.debug:
        for bitname,loc in bitfields:
          if '_descr' not in attrs[bitname]:
            attrs[bitname]['_descr']=''
          if '_typ' in attrs[bitname]:
            print bitname,loc,attrs[bitname]['_typ'],attrs[bitname]['_descr']
          else:
            print bitname,loc,attrs['_typ'],attrs[bitname]['_descr']
      for bitname,loc in bitfields:
        self.bitfields[os.path.join(self.path,reg)].append((bitname,self.dim2mask(attrs[bitname]['_loc'])))

  def __init__(self,param,module_attrs,debug):
    """
    """
    self.debug=debug
    self.param=param
    self.module_attrs=module_attrs
    self.bitfields=[]
    self.register_defaults=[]
    self.register_regex_ranges=[]
    #pprint(self.param)
    self.extract()
    self.gen_reg_db()
    self.gen_table()

  def gen_table(self):
    """
    """
    for path,src in self.path2src.items():
      if src!='':
        self.pyregobj=self.pyreg(path,self.src2param[src],self.debug)
        self.register_defaults.append(self.pyregobj.register_defaults)
        self.register_regex_ranges.append(self.pyregobj.register_regex_ranges)
        self.bitfields.append(self.pyregobj.bitfields)
        #pprint(self.bitfields)
        #pprint(self.register_defaults)
        #pprint(self.register_regex_ranges)

  def gen_reg_db(self):
    """
    """
    self.src2param={}
    #print self.path2src
    for src in filter(lambda x: x!='',self.path2src.values()):
      dbobj=reg_db('',src)
      dbobj.gen_reg_db(dbobj.get_file())
      self.src2param[src]=dbobj.src2param
    #pprint(self.src2param)

  def extract(self):
    """
    """
    self.path2src={}
    path=''
    def extract_path(attrs,db,path):
      modules=filter(lambda x: x not in attrs,db)
      if len(modules)==0:
        if 'src' in db:
          self.path2src[path]=db['src']
        else:
          self.path2src[path]=''
        return
      else:
        for inst in modules:
          if inst.startswith('xx'):
            path1=os.path.join(path,inst[5:])
          else:
            path1=os.path.join(path,inst)
          extract_path(attrs,db[inst],path1)
    extract_path(self.module_attrs,self.param,path)
    #pprint(self.path2src)

  def write(self,file):
    """
    """
    OUTFILE=open(file,'w')
    lines=[]
    sublines=[]
    lines.append("""#!/usr/bin/env python2
# DAL Register Utility

# NOTE: This file was generated by '{0}' - DO NOT EDIT -
#          - {1} -""".format(os.path.realpath(__file__), datetime.now().strftime("%Y-%m-%d %H:%M:%S")))


    if 'bitfields' in file:
      lines.append("""

# Bitfield Definitions
bitfields = {""")
      for module in self.bitfields:
        for reg in module:
          sublines.append("""\t'%s' : {
%s
        }"""%(reg,",\n".join(map(lambda x:"\t\t%s: '%s'"%(x[1],x[0]),module[reg]))))
    else:
      lines.append("""

# Register Default Values/Ranges
register_defaults = {""")
      for i,module in enumerate(self.register_defaults):
        for reg in module:
          sublines.append("""\t'%s' : {
\t\t'default':     "%s",
\t\t'regex_range': "%s",
        }"""%(reg,module[reg],self.register_regex_ranges[i][reg]))
    lines.append(',\n'.join(sublines))
    lines.append("""}



# Standalone Execution
if __name__ == '__main__':
\tERROR = '^[[5;1;31mERROR^[[0m:'
\tprint "{0} This is not a standalone script, it is used by dal_regs.py".format( ERROR )""")
    OUTFILE.write('\n'.join(lines))
    OUTFILE.write('\n\n') # Final line should be empty


class cheader(pytable,common):

  def write(self,file):
    """
    """
    OUTFILE=open(file,'w')
    #pprint(self.bitfields)
    #pprint(self.register_defaults)
    #pprint(self.param)
    #pprint(self.path2src)
    #pprint(self.src2param)
    lines=[]
    lines.append("""// C Register Map/Symbol Table - Used to populate DAL driver sysfs tree

// NOTE: This file was generated by '{0}' - DO NOT EDIT -
//          - {1} -
#include "reg_map.h"
#ifndef NULL
#define NULL (void *)0
#endif
""".format(os.path.realpath(__file__), datetime.now().strftime("%Y-%m-%d %H:%M:%S")))
    self.pregscount=0
    self.regscount=0
    self.fldcount=0
    self.fldscount=0
    self.regcount=0
    self.regss={}
    def extract_reg(xml,tabs):
      """
      """
      outs=[]
      count=0
      regs=[]
      for reg in sorted(self.src2param[xml][xml],key=lambda x: self.vlognum2int(self.src2param[xml][xml][x]['_offset'])):
        regdb=self.src2param[xml][xml][reg]
        bits=filter(lambda x: x not in self.reg_attrs,regdb)
        flds=[]
        for bit in sorted(bits,key=lambda x: self.tostart(regdb[x]['_loc']),reverse=True):
          outs.append('static %s fld_t fld%04d = { %-35s %3d,%3d };'%(' '*(len(tabs)+2),
                                                                        self.fldcount,
                                                                        '"%s",'%bit,
                                                                        self.toend(regdb[bit]['_loc']),
                                                                        self.tostart(regdb[bit]['_loc'])))
          flds.append('&fld%04d'%self.fldcount)
          self.fldcount+=1
        outs.append('static %s fld_t *flds%04d[] = { %s };'%(' '*len(tabs),
                                                             self.fldscount,
                                                             ', '.join(flds)))
        outs.append('static %s reg_t   reg%04d   = { 0, %-35s %6s, %5s,%2d, flds%04d };'%(' '*len(tabs),
                                                                                            self.regcount,
                                                                                            '"%s",'%reg,
                                                                                            '0x%x'%(self.vlognum2int(regdb['_offset'])<<3),
                                                                                            '"%s"'%regdb['_typ'],
                                                                                            len(flds),
                                                                                            self.fldscount))
	outs.append('') # Add spacer for readability
        regs.append('(void *)&reg%04d'% self.regcount)
        self.fldscount+=1
        self.regcount+=1
        count+=1
      outs.append('static %s void  *regs%03d_[] = { %s };'%(' '*len(tabs),
                                                           self.pregscount,
                                                           ', '.join(regs)))


      #self.regss.append('(void *)&regs%03d'% self.pregscount)
      #self.pregscount+=1
      return count,outs

    def extract_module(module,db,tabs):
      module_wo_x=re.sub("xx.._","",module)
      if 'src' in db:
        count,reglines=extract_reg(db['src'],tabs)
        #print count,reglines
        lines.extend(reglines)
        if 'array' in db:
          #print tabs,module,db['base'],db['size'],db['array']
          lines.append('static %s regs_t regs%03d    = { 1, %-16s 0x%06x, 0x%06x, %2d, %2d, regs%03d_ };'%(' '*(len(tabs)),
                                                                              self.regscount,
                                                                              '"%s",'%module_wo_x,
                                                                              self.vlognum2int(db['base'])<<3,
                                                                              self.vlognum2int(db['size'])<<3,
                                                                              #0,
                                                                              self.vlognum2int(db['array']),
                                                                              count,
                                                                              self.regscount))
        else:
          #print tabs,module,db['base'],db['size']
          lines.append('static %s regs_t regs%03d    = { 1, %-16s 0x%06x, 0x%06x, %2d, %2d, regs%03d_ };'%(' '*(len(tabs)),
                                                                              self.regscount,
                                                                              '"%s",'%module_wo_x,
                                                                              self.vlognum2int(db['base'])<<3,
                                                                              #self.vlognum2int(db['size'])<<3,
                                                                              0,
                                                                              0,
                                                                              count,
                                                                              self.regscount))
        lines.append('')
        self.regscount+=1
        return
      else:
        modules=filter(lambda x: x not in vgen.module_attrs,db)
        for inst in sorted(modules,key=lambda x : self.vlognum2int(db[x]['base'])):
          extract_module(inst,db[inst],tabs+'  ')
          if tabs not in self.regss:
            self.regss[tabs]=[]
          self.regss[tabs].append('(void *)&regs%03d'% self.pregscount)
          self.pregscount+=1
        if tabs=='':
          lines.append('') # Spacer
          lines.append('// Root of sysfs register tree')
          lines.append('static void *all_[] = { %s };'%(', '.join(self.regss[tabs])))
        elif tabs in self.regss:
          lines.append('static %s void  *regs%03d_[] = { %s };'%(' '*len(tabs),
                                                            self.pregscount,
                                                            ', '.join(self.regss[tabs])))

        self.regss[tabs]=[]
        if module !='top':
          if 'array' in db:
            #print tabs,module,sorted(modules,key=lambda x: self.vlognum2int(db[x]['base'])),db['base'],db['size'],db['array']
            lines.append('static %s regs_t regs%03d    = { 1, %-16s 0x%06x, 0x%06x, %2d, %2d, regs%03d_ };'%(' '*(len(tabs)),
                                                                              self.regscount,
                                                                              '"%s",'%module_wo_x,
                                                                              self.vlognum2int(db['base'])<<3,
                                                                              self.vlognum2int(db['size'])<<3,
                                                                              #0,
                                                                              self.vlognum2int(db['array']),
                                                                              len(modules),   # fix me
                                                                              self.regscount))
          else:
            lines.append('static %s regs_t regs%03d    = { 1, %-16s 0x%06x, 0x%06x, %2d, %2d, regs%03d_ };'%(' '*(len(tabs)),
                                                                              self.regscount,
                                                                              '"%s",'%module_wo_x,
                                                                              self.vlognum2int(db['base'])<<3,
                                                                              #self.vlognum2int(db['size'])<<3,
                                                                              0,
                                                                              0,
                                                                              len(modules),   # fix me
                                                                              self.regscount))
            #print tabs,module,sorted(modules,key=lambda x: self.vlognum2int(db[x]['base'])),db['base'],db['size']
          lines.append('')
          self.regscount+=1
    extract_module('top',self.param,'')

    lines.append('regs_t all = { 1, "all_regs", 0, 0, 0, 4, all_ };')
    print '\n'.join(lines)
    OUTFILE.write('\n'.join(lines))
    OUTFILE.write('\n\n') # Final line should be empty

class missing_desc(pytable,common):
  def put(self):
    """
    """
    regmaps=[]
    #regtables=collections.OrderedDict()
    regtables={}
    regtables_keys=[]
    self.pregscount=0
    self.regscount=0
    self.fldcount=0
    self.fldscount=0
    self.regcount=0
    self.regss={}
    def extract_reg(regtable,xml,tabs,baseaddr):
      """
      """
      for reg in sorted(self.src2param[xml][xml],key=lambda x: self.vlognum2int(self.src2param[xml][xml][x]['_offset'])):
        regdb=self.src2param[xml][xml][reg]
        bits=filter(lambda x: x not in self.reg_attrs,regdb)
        flds=[]
        prev=63
        for bit in sorted(bits,key=lambda x: self.tostart(regdb[x]['_loc']),reverse=True):
          loc=regdb[bit]['_loc']
          if prev!=self.toend(loc):
            flds.append(('RSVD','[%d:%d]'%(prev,self.toend(loc)+1),'RV','Reserved'))
          if '_descr' in regdb[bit]:
            flds.append((bit,loc,regdb['_typ'],regdb[bit]['_descr']))
          else:
            flds.append((bit,loc,regdb['_typ'],''))
          prev=self.tostart(loc)-1
        if prev!=-1:
          flds.append(('RSVD','[%d:0]'%(prev+1),'RV','Reserved'))
        descr=''
        if '_descr' in regdb:
          descr=regdb['_descr']
        if '_size' in regdb:
          regtable.append((reg,baseaddr+self.vlognum2int(regdb['_offset']),regdb['_typ'],regdb['_default'],descr,regdb['_size'],flds))
        else:
          regtable.append((reg,baseaddr+self.vlognum2int(regdb['_offset']),regdb['_typ'],regdb['_default'],descr,'',flds))

      # register worksheet

    def extract_module(module,db,tabs,path,baseaddr):
      if 'src' in db:
        #print path,'0x%06x'%baseaddr
        path_wo_x=re.sub("xx.._","",path)
        regmaps.append((path_wo_x,'0x%06x'%baseaddr))
        regtables_keys.append(path_wo_x)
        regtables[path_wo_x]=[]
        extract_reg(regtables[path_wo_x],db['src'],tabs,baseaddr)
        self.regscount+=1
        return
      else:
        modules=filter(lambda x: x not in vgen.module_attrs,db)
        for inst in sorted(modules,key=lambda x : self.vlognum2int(db[x]['base'])):
          extract_module(inst,db[inst],tabs+'  ',os.path.join(path,inst),baseaddr+self.vlognum2int(db[inst]['base']))
          if tabs not in self.regss:
            self.regss[tabs]=[]
          self.regss[tabs].append('(void *)&regs%03d'% self.pregscount)
          self.pregscount+=1

        self.regss[tabs]=[]
    extract_module('top',self.param,'','',0)

    #for path,regtable in regtables.items():
    for path in regtables_keys:
      regtable=regtables[path]
      for reg,addr,typ,default,descr,size,flds in regtable:
        if descr=='':
          print os.path.join(path,reg)
        if len(flds) > 0:
          for fld in flds:
            if fld[-1] == '':
              print "%s (%s)"%(fld[0],os.path.join(path,reg))


class topdoc(pytable,common):
  def write(self,file):
    """
    """
    regmaps=[]
    #regtables=collections.OrderedDict()
    regtables={}
    regtables_keys=[]
    self.pregscount=0
    self.regscount=0
    self.fldcount=0
    self.fldscount=0
    self.regcount=0
    self.regss={}
    def extract_reg(regtable,xml,tabs,baseaddr):
      """
      """
      for reg in sorted(self.src2param[xml][xml],key=lambda x: self.vlognum2int(self.src2param[xml][xml][x]['_offset'])):
        regdb=self.src2param[xml][xml][reg]
        bits=filter(lambda x: x not in self.reg_attrs,regdb)
        flds=[]
        prev=63
        for bit in sorted(bits,key=lambda x: self.tostart(regdb[x]['_loc']),reverse=True):
          loc=regdb[bit]['_loc']
          if prev!=self.toend(loc):
            flds.append(('RSVD','[%d:%d]'%(prev,self.toend(loc)+1),'RV','Reserved'))
          if '_descr' in regdb[bit]:
            flds.append((bit,loc,regdb['_typ'],regdb[bit]['_descr']))
          else:
            flds.append((bit,loc,regdb['_typ'],''))
          prev=self.tostart(loc)-1
        if prev!=-1:
          flds.append(('RSVD','[%d:0]'%(prev+1),'RV','Reserved'))
        descr=''
        if '_descr' in regdb:
          descr=regdb['_descr']
        if '_size' in regdb:
          regtable.append((reg,baseaddr+self.vlognum2int(regdb['_offset']),regdb['_typ'],regdb['_default'],descr,regdb['_size'],flds))
        else:
          regtable.append((reg,baseaddr+self.vlognum2int(regdb['_offset']),regdb['_typ'],regdb['_default'],descr,'',flds))

      # register worksheet

    def extract_module(module,db,tabs,path,baseaddr):
      if 'src' in db:
        #print path,'0x%06x'%baseaddr
        path_wo_x=re.sub("xx.._","",path)
        regmaps.append((path_wo_x,'0x%06x'%baseaddr))
        regtables_keys.append(path_wo_x)
        regtables[path_wo_x]=[]
        extract_reg(regtables[path_wo_x],db['src'],tabs,baseaddr)
        self.regscount+=1
        return
      else:
        modules=filter(lambda x: x not in vgen.module_attrs,db)
        for inst in sorted(modules,key=lambda x : self.vlognum2int(db[x]['base'])):
          if 'array' in db[inst]:
            for i in range(int(db[inst]['array'])):
              extract_module(inst,db[inst],tabs+'  ',os.path.join(path,'%s%d'%(inst,i)),baseaddr+self.vlognum2int(db[inst]['base'])+ i*self.vlognum2int(db[inst]['size']))
          else:
            extract_module(inst,db[inst],tabs+'  ',os.path.join(path,inst),baseaddr+self.vlognum2int(db[inst]['base']))
          if tabs not in self.regss:
            self.regss[tabs]=[]
          self.regss[tabs].append('(void *)&regs%03d'% self.pregscount)
          self.pregscount+=1

        self.regss[tabs]=[]
    extract_module('top',self.param,'','',0)

    wb=xlwt.Workbook()
    self.ws=wb.add_sheet('REG MAP')
    head="""DAL REGISTER MAP (SVN: 7234    DATE: %s)"""%(datetime.now().strftime("%Y-%m-%dT%H:%M:%S"))
    self.ws.col(0).width=11000
    self.ws.col(1).width=11000
    self.row=0
    self.ws.write(self.row,1,head,self.title_row)
    self.row=2
    self.ws.write(self.row,0,"Reg Group Name",self.t_hdr_style)
    self.ws.write(self.row,1,"Base Address (0x)",self.t_hdr_style)
    self.row+=1
    for name,addr in regmaps:
      #print name,addr
      #self.ws.write(self.row,0,name.upper().replace('/','_'),self.cell)
      self.ws.write(self.row,0,xlwt.Formula('HYPERLINK("%s","%s")'%(
"#%s!A1"%name.upper().replace('/','_'), name.upper().replace('/','_')
)),self.cell)
      self.ws.write(self.row,1,addr,self.cell)
      self.row+=1
    #for path,regtable in regtables.items():
    for path in regtables_keys:
      regtable=regtables[path]
      wsname=path.replace('/','_')
      self.ws=wb.add_sheet(wsname.upper())
      self.ws.col(0).width=4800
      self.ws.col(3).width=11000
      #pprint(regtable)
      self.row=0
      for reg,addr,typ,default,descr,size,flds in regtable:
        self.ws.write(self.row,1,"Group : %s"%path,self.title_row)
        self.row+=1
        self.regheader1(reg,addr,typ,default,size,descr)
        for fld in flds:
          self.write_row(*fld)
          self.row+=1
        self.row+=2
    wb.save(file)

class vgen(common):
  """
  call reg_db to create register tree
  call vlog to generate verilog file
  """
  def __init__(self,xmldir,xmlname,debug):
    """
    """
    self.debug=debug
    self.dir=xmldir
    self.topdir=xmldir
    self.xmlname=xmlname
    self.dbobj=reg_db(self.dir,self.xmlname)

    if self.dbobj.isRegister():
      self.dbobj.gen_reg_db(self.dbobj.get_file())
      vlogobj=vlog(self.dbobj.src2param)
      xmlpath=self.dbobj.src2param.keys()[0]
      self.name=os.path.splitext(os.path.basename(xmlpath))[0]
      self.dir=os.path.dirname(xmlpath)
      vlogobj.write(os.path.join(self.dir,self.name)+'.v')

    elif self.dbobj.isProject():
      self.dbobj.gen_proj_db(self.dbobj.get_file())
      self.param=self.dbobj.param
      self.srcs=self.dbobj.srcs
      self.nosrcs=self.dbobj.nosrcs
      self.name=os.path.splitext(os.path.basename(self.xmlname))[0]
      self.dir=os.path.dirname(self.xmlname)
      #print self.name
      #print self.dir
      #pprint(self.param)
      #self.dbobj.print_db()
    else:
      print "ERROR2 : XML not support %s"%self.dbobj.get_file()
      exit(1)

  def create_dec(self):
    """
    """
    header="""/********************************CONFIDENTIAL****************************
* Copyright (c) 2014 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: $
* $Author: $
* $Date: $
* $Revision: $
* Description:
* This module decodes address and mux/demux read/write data among configuration registers.
* This was generated from bist_addr_decoder.xml and vgen script. Do not manually modify it
* All manual changes will be overwritten by script whenever new file is generated.
***************************************************************************/
"""
    def extract_dec(attrs,db,inst):
      modules=filter(lambda x: x not in attrs,db)
      if len(modules)==0:
        return
      else:
        decobj=decode(modules,db)
        codes=decobj.codegen()
        if 'array' in db:
          #print inst,db['array'],modules
          #pprint(db)
          for idx in range(int(db['array'])):
            OUTFILE=open('%s%d_addr_decoder.v'%(inst,idx),'w')
            OUTFILE.write(header)
            OUTFILE.write("module %s%d_addr_decoder (\n"%(inst,idx))
            OUTFILE.write('\n'.join(codes))
            OUTFILE.close()
        else:
          #print inst,modules
          #pprint(db)
          OUTFILE=open('%s_addr_decoder.v'%inst,'w')
          OUTFILE.write(header)
          OUTFILE.write("module %s_addr_decoder (\n"%inst)
          OUTFILE.write('\n'.join(codes))
          OUTFILE.close()
        for inst in modules:
          extract_dec(attrs,db[inst],inst)
    inst='top'
    extract_dec(self.module_attrs,self.param,inst)

  def create_sv(self):
    """
    """

  def exclude_nosrcs(self,db):
    """
    """
    for fs in self.nosrcs:
      if len(fs)==1:
        del db[fs[0]]
      elif len(fs)==2:
        del db [fs[0]][fs[1]]
      elif len(fs)==3:
        del db [fs[0]][fs[1]][fs[2]]
    return db
    

  def gen_c(self):
    """
    """
    #print self.nosrcs
    param=self.exclude_nosrcs(deepcopy(self.param))
    #pprint(param)
    cheaderobj=cheader(param,self.module_attrs,self.debug)
    cheaderobj.write('reg_map0.c')

  def gen_doc(self):
    """
    """

  def gen_overwitten_doc(self):
    """
    """
    topdocobj=topdoc(self.param,self.module_attrs,self.debug)
    topdocobj.write(os.path.join(self.dir,self.name)+'.xls')

  def gen_py(self):
    """
    """
    #print self.nosrcs
    param=self.exclude_nosrcs(deepcopy(self.param))
    #pprint(param)
    pytableobj=pytable(param,self.module_attrs,self.debug)
    pytableobj.write('bitfields.py')
    pytableobj.write('register_defaults.py')

  def gen_reg_table(self):
    """
    """
    regtablobj=reg_table(self.dbobj.src2param,self.debug)
    regtablobj.write(os.path.join(self.dir,self.name)+'.xls')

  def master_and_csv(self):
    """
    """

  def reg_dump(self):
    """
    """

  def list_xml(self):
    """
    """
    xmldir=os.path.abspath(self.topdir)
    print "\n".join(map(lambda x: os.path.join(os.path.abspath(self.dir),x),[os.path.join(xmldir,self.xmlname)]+self.srcs))

  def gen_missing_desc(self):
    """
    """
    missing_descobj=missing_desc(self.param,self.module_attrs,self.debug)
    missing_descobj.put()



def main():
  debug=0
  # Configure Argument Parser
  parser = argparse.ArgumentParser(
                      description='Register generation script',
                      formatter_class=RawTextHelpFormatter
                      )


  # Default Options
  parser.add_argument('filename',
                      metavar='<filename>',
                      type=str,
                      nargs='+',
                      help='Path to the xml file containing the register descriptions.'
                      )


  # Specific Options
  parser.add_argument('-a',
                      dest='master_and_csv',
                      action='store_true',
                      default=False,
                      help='Creates master file.'
                      )

  parser.add_argument('--addr','-addr',
                      dest='create_dec',
                      action='store_true',
                      default=False,
                      help='vgen.py <xml> (start depth) (end depth) \n0: highest rank in the tree such as global, bist .. \n2: lowest rank such as dplbuf. \nif start/end depths are not specified, default will be 0(start) 2(end)'
                      )

  parser.add_argument('--sv','-sv',
                      dest='create_sv',
                      action='store_true',
                      default=False,
                      help='TODO'
                      )

  parser.add_argument('-c', '--generate-c-files',
                      dest='gen_c',
                      action='store_true',
                      default=False,
                      help='Generates C style variables to use with driver code.'
                      )

  parser.add_argument('-p', '--generate-python-files',
                      dest='gen_py',
                      action='store_true',
                      default=False,
                      help='Generates Python files for bitfield and register defaults for use with dal_regs.py and reg_rd.py.'
                      )

  parser.add_argument('-d', '--generate-doc',
                      dest='gen_doc',
                      action='store_true',
                      default=False,
                      help='Generates top level .xls document, does not overwrite.'
                      )

  parser.add_argument('-dn','--generate-doc-overwrite',
                      dest='gen_overwitten_doc',
                      action='store_true',
                      default=False,
                      help='Generates top level .xls document, overwrites the old .xls file.'
                      )

  parser.add_argument('-t', '--generate-reg-table',
                      dest='gen_reg_table',
                      action='store_true',
                      default=False,
                      help='Generate register table.'
                      )

  parser.add_argument('-reg_dump',
                      dest='reg_dump',
                      action='store_true',
                      default=False,
                      help='parse the .xml tree and dump contents to stdout'
                      )

  parser.add_argument('-l', '--list-xml-files',
                      dest='list_xml',
                      action='store_true',
                      default=False,
                      help='List the paths of all the .xml files as part of the xml tree.'
                      )

  parser.add_argument('--missing-description',
                      dest='missing_desc',
                      action='store_true',
                      default=False,
                      help='Lists the registers that do not have a description.'
                      )


  # Parse Arguments
  args = parser.parse_args()
  #pprint(args)

  if not os.path.exists(args.filename[0]):
    print "ERROR1 : Could not find %s"%args.filename[0]
    exit(1)

  xmlname=os.path.basename(args.filename[0])
  xmldir= os.path.dirname(args.filename[0])

  xmlobj=vgen(xmldir,xmlname,debug)

  if args.create_dec:
    xmlobj.create_dec()
  elif args.create_sv:
    xmlobj.create_sv()
  elif args.gen_c:
    xmlobj.gen_c()
  elif args.gen_doc:
    xmlobj.gen_doc()
  elif args.gen_overwitten_doc:
    xmlobj.gen_overwitten_doc()
  elif args.gen_py:
    xmlobj.gen_py()
  elif args.gen_reg_table:
    xmlobj.gen_reg_table()
  elif args.master_and_csv:
    xmlobj.master_and_csv()
  elif args.reg_dump:
    xmlobj.reg_dump()
  elif args.list_xml:
    xmlobj.list_xml()
  elif args.missing_desc:
    xmlobj.gen_missing_desc()




if __name__ == '__main__':
  """
  """
  main()

