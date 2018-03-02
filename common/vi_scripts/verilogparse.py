#!/usr/bin/env python2
import re
import copy
from pprint import pprint
from pprint import pformat
from veriloglang import *
from collections import deque
from verilogfunctions import *
from veriloglang import *
from verilogcheck import *
    
class verilogparse(object):
  """
  """
  includes=[]
  imports=[]
  read_lines=None
  lines_w_annotate=None
  lines_wo_annotate=None
  id_db={}
  db={}
  slashdoubles=[]
  slashstars=[]
  parenthesesstars=[]
  topdb=[]
  topdb_wo_annotate=[]
  topdb_w_beginblock=[]
  top=''
  top_wo_annotate=''
  top_w_beginblock=''

  def __init__(self):
    """
    """
    obj=veriloglang()
    obj.standard2keywords('1800-2012')
    self.kwds=obj.kwds
    #pprint(self.kwds)

  def read(self,file):
    """
    """
    def remove_slashdouble(lines):
      """
      remove comment
      recursive
      """
      comments=[]
      def remove_comment(offset,lines):
        if "//" not in lines:
          return lines
        else:
          start_idx=lines.index("//")
          end_idx=lines[start_idx:].index("\n")+start_idx
          comment=lines[start_idx:end_idx]
          lines=lines[:start_idx]+lines[end_idx:]
          comments.append((offset+start_idx,comment))
          #print((offset+start_idx,comment,lines))
          return remove_comment(offset+start_idx+len(lines[start_idx:end_idx]),lines)
      lines=remove_comment(0,lines)
      return lines
    def remove_slashstar(lines):
      """
      remove comment
      """
      comments=[]
      def remove_comment(offset,lines):
        if "/*" not in lines:
          return lines
        else:
          start_idx=lines.index("/*")
          end_idx=lines[start_idx+2:].index("*/")+start_idx+2
          comment=lines[start_idx:end_idx+2]
          lines=lines[:start_idx]+" "+lines[end_idx+2:]
          comments.append((offset+start_idx,comment))
          #print (offset+start_idx,comment,lines)
          return remove_comment(offset+start_idx+len(lines[start_idx:end_idx+2])-1,lines)
      lines=lines.replace('//*','//star')
      lines=remove_comment(0,lines)
      lines=lines.replace('//star','//*')
      return lines
    def remove_parenthesesstar(lines):
      """
      remove synthesis attributes
      """
      attributes=[]
      def remove_attribute(offset,lines):
        if r"(*" not in lines:
          return lines
        else:
          start_idx=lines.index(r"(*")
          end_idx=lines.index(r"*)")
          attribute=lines[start_idx:end_idx+2]
          lines=lines[:start_idx]+" "+lines[end_idx+2:]
          attributes.append((offset+start_idx,attribute))
          #print (offset+start_idx,attribute,lines)
          return remove_attribute(offset+start_idx+len(lines[start_idx:end_idx+2])-1,lines)
      lines=lines.replace('@(*','@(star')
      lines=remove_attribute(0,lines)
      lines=lines.replace('@(star','@(*')
      return lines
    def replace_slashdouble(lines,debug=False):
      """
      replace comment
      """
      def replace_comment(offset,lines):
        if "//" not in lines:
          return lines
        else:
          start_idx=lines.index("//")
          end_idx=lines[start_idx:].index("\n")+start_idx
          comment=lines[start_idx:end_idx]
          lines=lines[:start_idx]+'slashdouble%d'%offset+lines[end_idx:]
          self.slashdoubles.append((comment,))
          if debug:
            print 'slashdouble%d'%offset,len(self.slashdoubles),comment
          return replace_comment(offset+1,lines)
      lines=replace_comment(0,lines)
      return lines
    def replace_parenthesesstar(lines):
      """
      replace attribute
      """
      def replace_attribute(offset,lines):
        if r"(*" not in lines:
          return lines
        else:
          start_idx=lines.index(r"(*")
          end_idx=lines.index(r"*)")
          attribute=lines[start_idx:end_idx+2]
          nextword=lines[end_idx+2:].lstrip()
          lines=lines[:start_idx]+"parenthesesstar%d"%offset+lines[end_idx+2:]
          if nextword[0].isalpha():
            nextword=nextword[:nextword.index(' ')]
          else:
            nextword=''
          self.parenthesesstars.append((attribute,nextword))
          #print (offset+start_idx,attribute,lines)
          return replace_attribute(offset+1,lines)
      lines=lines.replace('@(*','@(star')
      lines=replace_attribute(0,lines)
      lines=lines.replace('@(star','@(*')
      return lines
    def replace_slashstar(lines):
      """
      replace comment
      """
      def replace_comment(offset,lines):
        if "/*" not in lines:
          return lines
        else:
          start_idx=lines.index("/*")
          end_idx=lines[start_idx+2:].index("*/")+start_idx+2
          comment=lines[start_idx:end_idx+2]
          lines=lines[:start_idx]+"slashstar%d"%offset+lines[end_idx+2:]
          self.slashstars.append((comment,))
          #print (offset+start_idx,comment,lines)
          return replace_comment(offset+1,lines)
      lines=lines.replace('//*','//star')
      lines=replace_comment(0,lines)
      lines=lines.replace('//star','//*')
      return lines

    with open(file,'r') as f:
      lines=f.read()
      self.read_lines=lines.expandtabs()
    f.close()
    self.lines_w_annotate=replace_slashstar(self.read_lines)
    self.lines_wo_annotate=remove_slashstar(self.read_lines)
    self.lines_w_annotate=replace_slashdouble(self.lines_w_annotate)
    self.lines_wo_annotate=remove_slashdouble(self.lines_wo_annotate)
    self.lines_w_annotate=replace_parenthesesstar(self.lines_w_annotate)
    self.lines_wo_annotate=remove_parenthesesstar(self.lines_wo_annotate)

  def parse_function(self,lines):
    """
    data structure for self.funcdb
{0: 'slashdouble0
--
<func>0</func>
<func>1</func>
<func>2</func>
<func>3</func>
<func>4</func>
',
 'func': [('module',
           {1: " altera_avalon_data_pattern_checker
    <func>0</func>
    <func>1</func>
    <func>2</func>
    <func>3</func>
 <func>4</func>
",
            'func': [('generate',
                      {2: '
--
    '}),
                     ('generate',
                      {2: '
--
    '}),
                     ('generate',
                      {2: '
--
    '}),
                     ('generate',
                      {2: "
--
    "}),
                     ('generate',
                      {2: "
--
    "})]}),
          ('module',
           {1: " ones_counter
--
    <func>0</func>
",
            'func': [('generate',
                      {2: "
--
    "})]}),
          ('module',
           {1: " snap_handshake_clock_crosser
--
    <func>0</func>
--
",
            'func': [('generate',
                      {2: '
--
    '})]}),
          ('module',
           {1: " pulse_to_toggle
--
"}),
          ('module',
           {1: " toggle_to_pulse
"})]}
    """
    """
    function end with
         endchecker
         endclass
         endclocking
         endconfig
         endconnectrules
         enddiscipline
         endfunction
         endgenerate
         endinterface
         endmodule
         endnature
         endpackage
         endparamset
         endprimitive
         endprogram
         endproperty
         endsequence
         endspecify
         endtask
    pairs
         covergroup endgroup
    """
    self.key2fin={fin[3:]:fin for fin in
    """
         endchecker
         endclass
         endclocking
         endconfig
         endconnectrules
         enddiscipline
         endfunction
         endgenerate
         endinterface
         endmodule
         endnature
         endpackage
         endparamset
         endprimitive
         endprogram
         endproperty
         endsequence
         endspecify
         endtask
    """.split()}
    l="""
         covergroup endgroup
    """.split()
    self.key2fin.update(zip(l[::2],l[1::2]))
    #print self.key2fin
    def findkey(lines):
      """
      exclude assert property
      """
      key=''
      pos=len(lines)+1
      offset=0
      for k in self.key2fin:
        match=re.search(r'\b%s\b'%k,lines)
        if match:
          p=match.start()
          if k=='property' and lines[:p].rstrip()[-len('assert'):]=='assert':
            offset+=p+len('property')
            lines=lines[p+len('property'):]
            continue
          if pos > (p+offset):
            pos=p+offset
            key=k
      return pos,key
    def findfin(lines,key,fin):
      """
      """
      match=re.search(r'\b%s\b'%fin,lines)
      if match:
        pfin=match.start()
      else:
        pfin=-1
      return pfin
    def bfs(lines,cnt=0,debug=False):
      """
      """
      outs=''
      nodes=[]
      db={}
      if debug:
        if len(lines) > 160:
          print lines[:80],lines[-80:]
        else:
          print lines
      while True:
        pos,key=findkey(lines)
        if key=='':
          outs+=lines
          db[cnt]=outs
          if debug:
            print outs
          cnt+=1
          if len(nodes)>0:
            db['func']=[]
          while nodes:
            key1,node=nodes.pop(0)
            db['func'].append((key1,bfs(node,cnt)))
          return db
        else:
          fin=self.key2fin[key]
          pfin=findfin(lines[pos+len(key):],key,fin)
          pfin+=pos+len(key)
          function=(key,lines[pos+len(key):pfin])
          if debug:
            if len(function[1])> 160:
              print cnt,function[0],function[1][:80],function[1][-80:],self.key2fin[function[0]]
            else:
              print cnt,function[0],function[1],self.key2fin[function[0]]
          outs+=lines[:pos]+'<func>%d</func>'%len(nodes)
          nodes.append(function)
          lines=lines[pfin+len(fin):]
          if debug:
            print cnt,lines,fin
    self.funcdb=bfs(lines,cnt=0)
    #print pformat(self.funcdb).replace('\\n','\n')

  def gen_topdb(self,debug=False):
    """
    """
    self.topdb=[]
    lvldb={}
    testdb=[]
    clonedb=copy.deepcopy(self.funcdb)
    for lvl,content in clonedb.items():
      if type(lvl) is int:
        lvldb[0]=[]
        obj=verilog_top(content)
        lvldb[0]+=[obj] 
        testdb+=[obj]
        if debug:
          if len(content) > 160:
            print content[:80],content[-80:]
          else:
            print content
         
      else:
        stack=[content]
        prev_lvl=0
        if True:
          funcs=stack.pop(0)
          while len(funcs) > 0:
            key,db=funcs.pop(0)
            for lvl in db:
              if type(lvl) is int:
                if lvl not in lvldb:
                  lvldb[lvl]=[]
                obj=eval('verilog_%s(db[lvl])'%key)
                lvldb[lvl].append(obj)
                testdb+=[obj]
                if prev_lvl > lvl:
                  if len(lvldb[lvl]) > 2:
                    lvldb[lvl]=lvldb[lvl][:-2]+[[lvldb[lvl][-2]]+[lvldb[prev_lvl]]]+[lvldb[lvl][-1]]
                  elif len(lvldb[lvl]) > 1:
                    lvldb[lvl]=[[lvldb[lvl][-2]]+[lvldb[prev_lvl]]]+[lvldb[lvl][-1]]
                  else:
                    lvldb[lvl]=[lvldb[prev_lvl]+[lvldb[lvl][-1]]]
                  if debug:
                    print prev_lvl,'del %d'%lvl
                  del lvldb[prev_lvl]
                elif prev_lvl < lvl:
                  if debug:
                    print prev_lvl,lvl
                else:  
                  if debug:
                    print prev_lvl,lvl
                prev_lvl=lvl
                if debug:
                  if len(db[lvl]) > 160:
                    print db[lvl][:80],db[lvl][-80:]
                  else:
                    print db[lvl]
              else:
                #funcs.extend(db[lvl])
                funcs=db[lvl]+funcs
                #stack=[db[lvl]]+stack
                #stack.append(db[lvl])
          #pprint(lvldb)
      for lvl in sorted(lvldb.keys(),reverse=True):
        if lvl != 0:
          lvldb[lvl-1].append(lvldb[lvl])
          del lvldb[lvl]
      
      self.topdb=lvldb[0]
    #pprint(self.topdb)
    #pprint(testdb)

  def topgen(self,debug=False):
    """
    """
    def dfs(funcs,count):
      """
      """
      attrs=[]
      if type(funcs)!=type(list()):
        return funcs.get()
      elif len(funcs)==1:
        return funcs[0].get()
      elif len(funcs)==2 and type(funcs[0])!=type(list()) and type(funcs[1])==type(list()):
        if debug:
          print count,funcs
        top,subfuncs=funcs
        for i,func in enumerate(subfuncs):
          rtns=dfs(func,count+1)
          if debug:
            print i,count,pformat(rtns).replace('\\n','\n')
          if type(rtns)==type(list()):
            attrs.extend(rtns)
          else:
            attrs.append(rtns)
        if debug:
          print '\n'.join(map(lambda x: pformat(x).replace('\\n','\n'),attrs))
        top.lines=top.backannotate_func(top.lines,attrs)
        #top.lines=top.backannotate_parenthesesstar(top.lines,self.parenthesesstars)
        #top.lines=top.backannotate_slashdouble(top.lines,self.slashdoubles)
        #top.lines=top.backannotate_slashstar(top.lines,self.slashstars)
        return top.get()
      else:
        for func in funcs:
          attrs.append(dfs(func,count+1))
        return attrs
    clonedb=copy.deepcopy(self.topdb)
    top,funcs=clonedb
    top.lines=top.backannotate_func(top.lines,[dfs(funcs,0)])
    top.lines=top.backannotate_parenthesesstar(top.lines,self.parenthesesstars)
    top.lines=top.backannotate_slashdouble(top.lines,self.slashdoubles)
    top.lines=top.backannotate_slashstar(top.lines,self.slashstars)
    return top

  def topgen_wo_comment(self,debug=False):
    """
    """
    def dfs(funcs,count):
      """
      """
      attrs=[]
      if type(funcs)!=type(list()):
        funcs.lines_wo_comment=funcs.remove_annotate(funcs.lines_wo_comment)
        funcs.remove_directive(self.kwds)
        return funcs.get_wo_comment()
      elif len(funcs)==1:
        funcs[0].lines_wo_comment=funcs[0].remove_annotate(funcs[0].lines_wo_comment)
        funcs[0].remove_directive(self.kwds)
        return funcs[0].get_wo_comment()
      elif len(funcs)==2 and type(funcs[0])!=type(list()) and type(funcs[1])==type(list()):
        if debug:
          print count,funcs
        top,subfuncs=funcs
        for i,func in enumerate(subfuncs):
          rtns=dfs(func,count+1)
          if debug:
            print i,count,pformat(rtns).replace('\\n','\n')
          if type(rtns)==type(list()):
            attrs.extend(rtns)
          else:
            attrs.append(rtns)
        if debug:
          print '\n'.join(map(lambda x: pformat(x).replace('\\n','\n'),attrs))
        top.lines_wo_comment=top.backannotate_func(top.lines_wo_comment,attrs)
        top.lines_wo_comment=top.remove_annotate(top.lines_wo_comment)
        return top.get_wo_comment()
      else:
        for func in funcs:
          attrs.append(dfs(func,count+1))
        return attrs
    self.topdb_wo_comment=copy.deepcopy(self.topdb)
    top,funcs=self.topdb_wo_comment
    top.lines_wo_comment=top.backannotate_func(top.lines_wo_comment,[dfs(funcs,0)])
    top.lines_wo_comment=top.remove_annotate(top.lines_wo_comment)
    return top
       
      
  def topgen_w_beginblock(self,debug=False):
    """
    """
    def dfs(funcs,count):
      """
      """
      attrs=[]
      if type(funcs)!=type(list()):
        return funcs.get_w_beginblock()
      elif len(funcs)==1:
        return funcs[0].get_w_beginblock()
      elif len(funcs)==2 and type(funcs[0])!=type(list()) and type(funcs[1])==type(list()):
        if debug:
          print count,funcs
        top,subfuncs=funcs
        for i,func in enumerate(subfuncs):
          rtns=dfs(func,count+1)
          if debug:
            print i,count,pformat(rtns).replace('\\n','\n')
          if type(rtns)==type(list()):
            attrs.extend(rtns)
          else:
            attrs.append(rtns)
        if debug:
          print '\n'.join(map(lambda x: pformat(x).replace('\\n','\n'),attrs))
        top.lines_w_beginblock=top.backannotate_func(top.lines_w_beginblock,attrs)
        #top.lines_w_beginblock=top.backannotate_parenthesesstar(top.lines_w_beginblock,self.parenthesesstars)
        #top.lines_w_beginblock=top.backannotate_slashdouble(top.lines_w_beginblock,self.slashdoubles)
        #top.lines_w_beginblock=top.backannotate_slashstar(top.lines_w_beginblock,self.slashstars)
        return top.get_w_beginblock()
      else:
        for func in funcs:
          attrs.append(dfs(func,count+1))
        return attrs
    self.topdb_w_beginblock=copy.deepcopy(self.topdb)
    top,funcs=self.topdb_w_beginblock
    top.lines_w_beginblock=top.backannotate_func(top.lines_w_beginblock,[dfs(funcs,0)])
    top.lines_w_beginblock=top.backannotate_parenthesesstar(top.lines_w_beginblock,self.parenthesesstars)
    top.lines_w_beginblock=top.backannotate_slashdouble(top.lines_w_beginblock,self.slashdoubles)
    top.lines_w_beginblock=top.backannotate_slashstar(top.lines_w_beginblock,self.slashstars)
    return top

  def put(self,file,debug=False):
    top=self.topgen(debug=False)
    if debug:
      print top.get()
    with open(file,'w') as f:
      f.write(top.get())
    f.close()
       
  def put_wo_comment(self,file,debug=False):
    top=self.topgen_wo_comment()
    if debug:
      print top.get_wo_comment()
    with open(file,'w') as f:
      f.write(top.get_wo_comment())
    f.close()

  def put_w_beginblock(self,file,debug=False):
    top=self.topgen_w_beginblock(debug=False)
    if debug:
      print top.get_w_beginblock()
    with open(file,'w') as f:
      f.write(top.get_w_beginblock())
    f.close()

  def check(self,debug=False):
    checkobj=verilogcheck()
    self.slashstars=checkobj.check_slashstar(self.slashstars)
    self.slashdoubles=checkobj.check_slashdouble(self.slashdoubles)
    self.parenthesesstars=checkobj.check_parenthesesstar(self.parenthesesstars)
    if debug:
      print filter(lambda x: x[1]!="",self.slashstars)
      print filter(lambda x: x[1]!="",self.slashdoubles)
      print filter(lambda x: x[2]!="",self.parenthesesstars)


  def codegen(self):
    print '''#!/usr/bin/env python2
import re
from pprint import pprint
from pprint import pformat
from veriloglang import *
from collections import deque
from verilogparse import *
'''
    print "\n".join(map(lambda x: '''
class verilog_%s(common):
  """
  """
''' %x +
'''
  keyword='%s'
  fin='%s'
'''%(x if x !='top' else '',self.key2fin[x] if x !='top' else '')+
'''
  def __init__(self,lines):
    """
    """
    self.lines=lines
    self.extract_begin_block()

  def parse(self):
    """
    """

  def format(self):
    """
    """

  def put(self):
    """
    """

          
''',['top']+self.key2fin.keys()))

class unused:
  """
  """
  def help(self):
    """
    function end with
         endchecker
         endclass
         endclocking
         endconfig
         endconnectrules
         enddiscipline
         endfunction
         endgenerate
         endinterface
         endmodule
         endnature
         endpackage
         endparamset
         endprimitive
         endprogram
         endproperty
         endsequence
         endspecify
         endtask
    section end with
         endcase
         endchecker
         endclass
         endclocking
         endconnectrules
         enddiscipline
         endfunction
         endgenerate
         endinterface
         endmodule
         endnature
         endpackage
         endparamset
         endproperty
         endsequence
         endspecify
         endtable
    section with begin end
         always
         always_ff
         always_comb
         if else
         for
         while
    section with semicolon
         assign
    directives
    io type
         input
         output
         inout
    id type
         wire
         tri
         reg
         trireg
         integer
         logic
         int
    pairs
         fork join
         covergroup endgroup
        
    """
  def db_w_func_end_gen(self,lines):
   def bracketdict(brackets="()[]{}<>"):
     """
     """
     for l,r in zip(brackets[::2],brackets[1::2]):
       counts[l]=0
       r2l[r]=l
   def bracketcount(line):
     for l in r2l.values():
       if l in line:
         counts[l]+=line.count(l)
     for r in r2l.keys():
       if r in line:
         counts[r2l[r]]-=line.count(r)
          

if __name__=='__main__':
  import sys
  argc=len(sys.argv)
  if argc > 1: infile =sys.argv[1]
  if argc > 2: outfile=sys.argv[2]
  obj=verilogparse()
  obj.read(infile)
  if True:
    obj.parse_function(obj.lines_w_annotate)
    #obj.codegen()
    obj.gen_topdb()
    #print pformat(obj.funcdb).replace('\\n','\n')
    #obj.put(outfile)
    #pprint(obj.topdb)
    #obj.put_wo_comment(outfile)
    #pprint(obj.topdb_wo_comment)
    obj.check()
    obj.put_w_beginblock(outfile)
    #pprint(obj.topdb_w_beginblock)
  if False:
    obj.pass1()
    print obj.includes
    print obj.imports
  if False:
    pprint(self.topdb_wo_comment)
    pprint(self.topdb)
    pprint(self.topdb_w_beginblock)
    print pformat(self.top).replace('\\n','\n')
    print pformat(self.top_wo_comment).replace('\\n','\n')
    print pformat(self.top_w_beginblock).replace('\\n','\n')
