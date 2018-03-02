#!/usr/bin/env python2
import re
import copy
from pprint import pprint
from pprint import pformat
from veriloglang import *
from collections import deque
from verilogfunctions import *
class verilogcommon(object):
  directives=[]
  begindb=[]
  not_supported=[
 'iff',
 'ifnone'
]
  block_delimiter=[
   'for',
   'if',
   'initial',
   'repeat',
   'while',
   'always_comb',
   'always_ff',
   'always_latch',
   'assert'
]
  block_pairs={
    'fork'        : ['join','join_any','join_none'],
    'case'        : 'endcase',
    'casex'       : 'endcase',
    'casez'       : 'endcase',
    'do'          : 'while'
}
  comment_types=dict(
    func="<func>\d+</func>",
    parenthesesstar="parenthesesstar\d+",
    slashstar="slashstar\d+",
    slashdouble="slashdouble\d+"
  ) 
  class beginblock:
    def __init__(self,lines,level):
      """
      """
      self.lines=lines
      self.level=level
    def backannotate_beginblock(self,inlines,attrs,debug=False):
      """
      """
      def flat(attrs):
        """
        """
        outs=[]
        for attr in attrs:
          if type(attr)==type(list()):
            outs+=attr
          else:
            outs+=[attr]
        return outs
      outlines=''
      attrs=flat(attrs)
      ptr=0
      for i,match in enumerate(re.finditer(r"beginendblock\d+",inlines)):
        if debug:
          print "{i} : '{g}' was found between the indices {s}".format(i=i,g=match.group(), s=match.span())
        (start,end)=match.span()
        outlines+=inlines[ptr:start]
        outlines+='begin'+attrs[i]+'end'
        ptr=end
      outlines+=inlines[ptr:]
      return outlines

    def lint(self):
      """
      """
    def get(self):
      """
      """
      return self.lines
    def get_w_lint(self):
      """
      """

  def backannotate_func(self,inlines,attrs,debug=False):
    """
    """
    def flat(attrs):
      """
      """
      outs=[]
      for attr in attrs:
        if type(attr)==type(list()):
          outs+=attr
        else:
          outs+=[attr]
      return outs
    outlines=''
    attrs=flat(attrs)
    ptr=0
    for i,match in enumerate(re.finditer(r"<func>\d+</func>",inlines)):
      if debug:
        print "{i} : '{g}' was found between the indices {s}".format(i=i,g=match.group(), s=match.span())
      (start,end)=match.span()
      outlines+=inlines[ptr:start]
      outlines+=attrs[i]
      ptr=end
    outlines+=inlines[ptr:]
    return outlines

  def backannotate_parenthesesstar(self,inlines,attrs,report=False,debug=False):
    """
    """
    outlines=''
    ptr=0
    for i,match in enumerate(re.finditer(r"parenthesesstar(\d+)",inlines)):
      if debug:
        print "{i} : '{g}' was found between the indices {s}".format(i=i,g=match.group(), s=match.span())
      (start,end)=match.span()
      outlines+=inlines[ptr:start]
      if report and attrs[int(match.group(1))][1]!='':
        outlines+=' REPORT%s'%attrs[int(match.group(1))][1]+' '+attrs[int(match.group(1))][0]
      else:
        outlines+=attrs[int(match.group(1))][0]
      #outlines+=attrs[i][0]
      ptr=end
    outlines+=inlines[ptr:]
    return outlines
    

  def backannotate_slashstar(self,inlines,attrs,report=False,debug=False):
    """
    """
    outlines=''
    ptr=0
    for i,match in enumerate(re.finditer(r"slashstar(\d+)",inlines)):
      if debug:
        print "{i} : '{g}' was found between the indices {s}".format(i=i,g=match.group(), s=match.span())
      (start,end)=match.span()
      outlines+=inlines[ptr:start]
      if report and attrs[int(match.group(1))][1]!='':
        outlines+=' REPORT%s'%attrs[int(match.group(1))][1]+' '+attrs[int(match.group(1))][0]
      else:
        outlines+=attrs[int(match.group(1))][0]
      #outlines+=attrs[i][0]
      ptr=end
    outlines+=inlines[ptr:]
    return outlines

  def backannotate_slashdouble(self,inlines,attrs,report=False,debug=False):
    """
    """
    outlines=''
    ptr=0
    for i,match in enumerate(re.finditer(r"slashdouble(\d+)",inlines)):
      if debug:
        print "{i} : '{g}' was found between the indices {s}".format(i=i,g=match.group(), s=match.span())
      (start,end)=match.span()
      outlines+=inlines[ptr:start]
      if report and attrs[int(match.group(1))][1]!='':
        outlines+=' REPORT%s'%attrs[int(match.group(1))][1]+' '+attrs[int(match.group(1))][0]
      else:
        outlines+=attrs[int(match.group(1))][0]
      #outlines+=attrs[i][0]
      ptr=end
    outlines+=inlines[ptr:]
    return outlines

  def remove_annotate(self,inlines,debug=False):
    """
    """
    for k,p in self.comment_types.items():
      ptr=0
      outlines=''
      for i,match in enumerate(re.finditer(p,inlines)):
        if debug:
          print "{p} {i} : '{g}' was found between the indices {s}".format(p=p,i=i,g=match.group(), s=match.span())
        (start,end)=match.span()
        outlines+=inlines[ptr:start]
        ptr=end
      outlines+=inlines[ptr:]
      inlines=copy.deepcopy(outlines)
    return outlines

  def extract_beginblock(self,debug=False):
    """
    """
    def is_begin_end_block(lines,debug=False):
      """
      """
      if debug:
        print len(re.findall(r"\bbegin\b",lines,re.MULTILINE)) , len(re.findall(r"\bend\b",lines,re.MULTILINE))
      return len(re.findall(r"\bbegin\b",lines,re.MULTILINE)) == len(re.findall(r"\bend\b",lines,re.MULTILINE))
    def dfs_beginblock(lines,level,debug=False):
      """
      """
      if not re.search(r"\bbegin\b",lines,re.MULTILINE):
        obj=self.beginblock(lines,level)
        return [obj]
      else:
        cnt=0
        objs=[]
        while re.search(r"\bbegin\b",lines,re.MULTILINE):
          bb,be= re.search(r"\bbegin\b",lines,re.MULTILINE).span()
          end=0
          while re.search(r"\bend\b",lines[end:],re.MULTILINE):
            eb,ee=re.search(r"\bend\b",lines[end:],re.MULTILINE).span()
            end+=ee
            if is_begin_end_block(lines[bb:end]):
              if debug:
                print "^%s$"%lines[bb:end]
              nextlines=lines[bb+5:end-3]
              lines=lines[:bb]+'beginendblock%d'%cnt+lines[end:]
              cnt+=1
              objs+=dfs_beginblock(nextlines,level+1)
              break
        obj=self.beginblock(lines,level)
        return [obj,objs]
    self.begindb=dfs_beginblock(self.lines_w_beginblock,0)
    if debug:
      print self.begindb

  def rep_beginblock(self,debug=False):
    """
    """
    def dfs(blocks,level):
      """
      """
      def top_subblocks(level,top,subblocks):
        """
        """
        attrs=[]
        for i,block in enumerate(subblocks):
          rtns=dfs(block,level+1)
          if debug:
            print i,level,pformat(rtns).replace('\\n','\n')
          if type(rtns)==type(list()):
            attrs[-1]=top.backannotate_beginblock(attrs[-1],rtns)
          else:
            attrs.append(rtns)
        if debug:
          print '\n'.join(map(lambda x: pformat(x).replace('\\n','\n'),attrs))
        top.lines=top.backannotate_beginblock(top.lines,attrs)
        return top.get()
      attrs=[]
      if type(blocks)!=type(list()):
        return blocks.get()
      elif len(blocks)==1:
        return [blocks[0].get()]
      else:
        i=0
        while i < len(blocks):
          if i==len(blocks)-1:
            rtn=dfs(blocks[i],level+1)
            attrs.append(rtn)
            i+=1
          else:
            if type(blocks[i+1])==type(list()):
              attrs.append(top_subblocks(level,blocks[i],blocks[i+1]))
              i+=2
            else:
              rtn=dfs(blocks[i],level+1)
              attrs.append(rtn)
              i+=1
        return attrs
    repbegindb=copy.deepcopy(self.begindb)
    if len(repbegindb) > 1:
      top,blocks=repbegindb
      self.lines_w_beginblock=top.backannotate_beginblock(top.lines,[dfs(blocks,0)])
    else:
      self.lines_w_beginblock=repbegindb[0].get()

       
        

  def remove_directive(self,kwds):
    """
    """
    def section_end_newline(section):
      """
      section end with newline
      """
      directives=[]
      lines=section.split("\n")
      line=lines.pop().strip()
      while len(lines) > 0:
        sentence='' 
        while line.endswith('\x5c'):
          sentence+=' ' + line[:-1]
          line=lines.pop().strip()
        if sentence=='': 
          sentence+=line
        else:
          sentence+=' ' + line
        if sentence.startswith("`"):
          directives+=[sentence]
          return directives,''
        else:
          return directives,line
    lines_wo_tick=[]
    self.directives=[]
    self.ids=[]
    for i,section in enumerate(self.lines_wo_comment.split(";")):
      section=section.strip()
      if section.startswith("`"):
        directives,section=section_end_newline(section)
        section=self.directives.extend(directives)
      lines_wo_tick.append(section) 
    self.lines_wo_tick=';'.join(lines_wo_tick)
         

  def get(self):
    """
    """
    return self.keyword + self.lines + self.fin

  def get_wo_comment(self):
    """
    """
    return self.keyword + self.lines_wo_comment + self.fin

  def get_w_beginblock(self):
    """
    """
    return self.keyword + self.lines_w_beginblock + self.fin

  def verilogcommon_unuseds(self):
    """
    """
    def extract_port():
      """
      input
      output
      inout
      """
      
      
    def extract_net():
      """
      logic    : 4-state variable, user-defined size (replaces reg)
      enum     : a variable with a specified set of legal values
      int      : 32-bit 2-state var (use with for-loops, replaces integer)
      
      Avoid 2-state types in synthesizable models - they can hide serious design bugs!
      bit      : single bit 2-state variable
      byte     : 8-bit 2-state variable
      shortint : 16-bit 2-state variable
      longint  : 64-bit 2-state variable
      
      packed array
      logic [3:0][7:0] b;
      
      unpacked array
      logic [7:0] a1 [0:1][0:3];
      logic [7:0] a2 [2][4]; // c-like declaration
      a1 = '{'{7,3,0,5},'{default:'1}};
      a2 = a1; // copy entire array
      """
    def extract_struct():
      """
      """
    def extract_typedef():
      """
      """
    def extract_enum():
      """
      """

    
