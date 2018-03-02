#!/usr/bin/env python2
import os, sys
import xml.dom.minidom
import random
import subprocess
import string
import re
from pprint import pprint
debug=False
param={}
srcs=[]
src2param={}
decpaths=[]
decpath2src={}
def reg_db(path,file) :
  """
  """
  doc=xml.dom.minidom.parse("%s/%s"%(path,file))
  #print doc.toprettyxml().strip()
  l0=doc.lastChild
  topname=l0.nodeName
  if topname != 'decl_reg_list':
    if debug: print "Error 1 : xml file is not decl reg list Xml"
    exit(1)
  src2param[file]={}
  for l1 in l0.childNodes:
    if l1.nodeType == l0.TEXT_NODE: # 3
      if l1.nodeValue.strip() == "":
        continue
      else:
        if debug: print "Error 2 : text node is not empty",l1.nodeValue.strip()
    elif l1.nodeType == l0.ELEMENT_NODE: #1
      #print l1.nodeType ,l1.toprettyxml().strip()
      #print l1.nodeName
      default=''
      name=''
      offset=''
      size=''
      typ=''
      usr=''
      for item in l1.attributes.items():
        k=item[0]
        v=item[1]
        #print k,v
        if k == "default": default = v
        if k == "name": name = v
        if k == "offset": offset = v
        if k == "size": size = v
        if k == "type": typ = v
        if k == "usr": usr = v
      if name !='':
        src2param[file][name]={}
        if default != '':
          src2param[file][name]['default']=default
        if offset != '':
          src2param[file][name]['offset']=offset
        if size != '':
          src2param[file][name]['size']=size
        if typ != '':
          src2param[file][name]['typ']=typ
        if usr != '':
          src2param[file][name]['usr']=usr
      else:
        if debug: print "Error 3 : no name attribute",l1.toprettyxml().strip()
        continue
      for l2 in l1.childNodes:
        #print l2.nodeType ,l2.toprettyxml().strip()
        #print "l2",l2.nodeName
        if l2.nodeType == l0.TEXT_NODE: # 3
          if l2.nodeValue.strip() == "":
            continue
          else:
            descr=l2.nodeValue.strip()
            if descr !='':
              src2param[file][name]['descr']=descr
        elif l2.nodeType == l0.ELEMENT_NODE: #1
          #print l2.nodeType ,l2.toprettyxml().strip()
          name2=''
          loc=''
          typ=''
          for item in l2.attributes.items():
            k=item[0]
            v=item[1]
            #print k,v
            if k == "name": name2 = v
            if k == "loc": loc = v
            if k == "type": typ = v
          if name2 !='':
            src2param[file][name][name2]={}
            if loc != '':
              src2param[file][name][name2]['loc']=loc
            if typ != '':
              src2param[file][name][name2]['typ']=typ
          else:
            if debug: print "Error 4 : no name attribute",l2.toprettyxml().strip()
            continue
          for l3 in l2.childNodes:
            #print l3.nodeType ,l3.toprettyxml().strip()
            #print "l3",l3.nodeName
            if l3.nodeType == l0.TEXT_NODE: # 3
              if l3.nodeValue.strip() == "":
                continue
              else:
                descr=l3.nodeValue.strip()
                if descr !='':
                  src2param[file][name][name2]['descr']=descr
            elif l3.nodeType == l0.ELEMENT_NODE: #1
                if debug: print "Error 5 : extra branch in the tree",l3.nodeValue.strip()

def create_db(file) :
  """
  """
  doc=xml.dom.minidom.parse(file)
  #print doc.toprettyxml().strip()
  l0=doc.lastChild
  topname=l0.nodeName
  if topname != 'vi_registers':
    if debug: print "Error 6 : xml file is not VI register Xml"
    exit(2)
  for l1 in l0.childNodes:
    if l1.nodeType == l0.TEXT_NODE: # 3
      if l1.nodeValue.strip() == "":
        continue
      else:
        if debug: print "Error 7 : text node is not empty",l1.nodeValue.strip()
    elif l1.nodeType == l0.ELEMENT_NODE: #1
      #print l1.nodeType ,l1.toprettyxml().strip()
      #print l1.nodeName
      name=''
      base=''
      array=''
      sp=''
      size=''
      src=''
      for item in l1.attributes.items():
        k=item[0]
        v=item[1]
        #print k,v
        if k == "array": array = v
        if k == "base": base = v
        if k == "name": name = v
        if k == "sp": sp = v
        if k == "size": size = v
        if k == "src": src = v
      if name !='':
        param[name]={}
        if base != '':
          param[name]['base']=base
        if sp != '':
          param[name]['sp']=sp
        if size != '':
          param[name]['size']=size
        if array != '':
          param[name]['array']=array
        if src != '':
          param[name]['src']=src
          if src not in srcs:
            srcs.append(src)
          else:
            if debug: print "Error 8 : duplicate source file",src
      else:
        if debug: print "Error 9 : no name attribute",l1.toprettyxml().strip()
        continue
      for l2 in l1.childNodes:
        #print l2.nodeType ,l2.toprettyxml().strip()
        #print "l2",l2.nodeName
        if l2.nodeType == l0.TEXT_NODE: # 3
          if l2.nodeValue.strip() == "":
            continue
          else:
            if debug: print "Error 10 : text node is not empty",l2.nodeValue.strip()
        elif l2.nodeType == l0.ELEMENT_NODE: #1
          #print l2.nodeType ,l2.toprettyxml().strip()
          name2=''
          base=''
          array=''
          sp=''
          size=''
          clk=''
          src=''
          for item in l2.attributes.items():
            k=item[0]
            v=item[1]
            #print k,v
            if k == "array": array = v
            if k == "base": base = v
            if k == "name": name2 = v
            if k == "sp": sp = v
            if k == "size": size = v
            if k == "clk": clk = v
            if k == "src": src = v
          if name2 !='':
            param[name][name2]={}
            if base != '':
              param[name][name2]['base']=base
            if sp != '':
              param[name][name2]['sp']=sp
            if size != '':
              param[name][name2]['size']=size
            if array != '':
              param[name][name2]['array']=array
            if src != '':
              param[name][name2]['src']=src
              if src not in srcs:
                srcs.append(src)
              else:
                if debug: print "Error 11 : duplicate source file",src
            if clk != '':
              param[name][name2]['clk']=clk
          else:
            if debug: print "Error 12 : no name attribute",l2.toprettyxml().strip()
            continue

          for l3 in l2.childNodes:
            #print l3.nodeType ,l3.toprettyxml().strip()
            #print l3.nodeName
            if l3.nodeType == l0.TEXT_NODE: # 3
              if l3.nodeValue.strip() == "":
                continue
              else:
                if debug: print "Error 13 : text node is not empty",l3.nodeValue.strip()
            elif l3.nodeType == l0.ELEMENT_NODE: #1
              #print l3.nodeType ,l3.toprettyxml().strip()
              name3=''
              base=''
              src=''
              array=''
              sp=''
              size=''
              clk=''
              for item in l3.attributes.items():
                k=item[0]
                v=item[1]
                #print k,v
                if k == "array": array = v
                if k == "base": base = v
                if k == "name": name3 = v
                if k == "sp": sp = v
                if k == "size": size = v
                if k == "clk": clk = v
                if k == "src": src = v
              if name3 !='':
                param[name][name2][name3]={}
                if base != '':
                  param[name][name2][name3]['base']=base
                if sp != '':
                  param[name][name2][name3]['sp']=sp
                if size != '':
                  param[name][name2][name3]['size']=size
                if array != '':
                  param[name][name2][name3]['array']=array
                if src != '':
                  param[name][name2][name3]['src']=src
                  if src not in srcs:
                    srcs.append(src)
                  else:
                    if debug: print "Error 14 : duplicate source file",src
                if clk != '':
                  param[name][name2][name3]['clk']=clk
              else:
                if debug: print "Error 15 : no name attribute",l3.toprettyxml().strip()
                continue

def decpathgen ():
  """
  """
  paths=[]
  path2src={}
  for k1,v1 in param.items():
    segs=[]
    #print k1
    #pprint(v1)
    #print v1.keys()
    if 'array' in v1.keys():
      #print "loop count",v1['array']
      array=v1['array']
      segs.append("%s[%s]"%(k1,array))
    else:
      segs.append(k1)
    for k2,v2 in v1.items():
      if not isinstance(v2,dict):
        pass
      else:
        #pprint(v2)
        if 'array' in v2.keys():
          #print "loop count",v2['array']
          array=v2['array']
          segs.append("%s[%s]"%(k2,array))
        else:
          segs.append(k2)
        if 'src' in v2.keys():
          path=".".join(segs)
          #print 2,path
          paths.append(path)
          path2src[path]=v2['src']
          segs.pop()
          continue
        for k3,v3 in v2.items():
          if not isinstance(v3,dict):
            #print k3,v3
            pass
          else:
            #print k3,v3
            if 'array' in v3.keys():
              #print "loop count",v3['array']
              array=v3['array']
              segs.append("%s[%s]"%(k3,array))
            else:
              segs.append(k3)
            if 'src' not in v3.keys():
              if debug: print "Error 16: no registers in this path %s" % ".".join(segs)
              segs.pop()
            else:
              path=".".join(segs)
              paths.append(path)
              #print 3,path
              path2src[path]=v3['src']
              segs.pop()
        segs.pop()
  for path in paths:
   if '[' in path:
     index1=path.index('[')
     index2=path.index(']')
     firstpath=path[:index1]
     secondpath=path[index2+1:]
     loop1=int(path[index1+1:index2])
     #print firstpath,secondpath,loop1
     if '[' in secondpath:
       index1=secondpath.index('[')
       index2=secondpath.index(']')
       midpath=secondpath[:index1]
       thirdpath=secondpath[index2+1:]
       loop2=int(secondpath[index1+1:index2])
       if '[' in thirdpath:
         index1=thirdpath.index('[')
         index2=thirdpath.index(']')
         mid2path=thirdpath[:index1]
         endpath=thirdpath[index2+1:]
         loop3=int(thirdpath[index1+1:index2])
         for i in range(loop1):
           for j in range(loop2):
             for k in range(loop3):
               decpaths.append("%s[%d]%s[%d]%s[%d]%s"%(firstpath,i,midpath,j,mid2path,k,endpath))
               decpath2src["%s[%d]%s[%d]%s[%d]%s"%(firstpath,i,midpath,j,mid2path,k,endpath)]=path2src[path]
       else:
         for i in range(loop1):
           for j in range(loop2):
             decpaths.append("%s[%d]%s[%d]%s"%(firstpath,i,midpath,j,thirdpath))
             decpath2src["%s[%d]%s[%d]%s"%(firstpath,i,midpath,j,thirdpath)]=path2src[path]
     else:
       for i in range(loop1):
         decpaths.append("%s[%d]%s"%(firstpath,i,secondpath))
         decpath2src["%s[%d]%s"%(firstpath,i,secondpath)]=path2src[path]
   else:
     decpaths.append(path)
     decpath2src[path]=path2src[path]
     
    
   
    
def leaf_db(path):
  """  
  """  
  for src in srcs:
    #print "%s/%s"%(path,src)
    reg_db(path,src)
  
def read_default_registers ():
  """
  """
  for dec in decpaths:
    src=decpath2src[dec]
    #print src
    try :
      regtree=src2param[src]
    except KeyError:
      if debug: print "Error 17: src",src
      exit(3)
    for regname in src2param[src]:
      try:
        default=default2value(src2param[src][regname]['default'])
        #print "rdwr %s.%s" % (dec,regname)
        cmd= "rdwr %s.%s" % (dec,regname)
        cmd=re.sub('xx.._','',cmd)
        print cmd
        proc = subprocess.Popen( cmd, shell=True, stdout = subprocess.PIPE, stderr = subprocess.PIPE )
        out,error=proc.communicate()
        print out
        print error
        print default
        if proc.returncode !=0:
          print "ERROR: read/write error %s %s" % (out,error)
          #exit(4)
        try:
          index=out.index(':')
          value=out[index+1:].strip()
          index=value.index(' ')
          value=value[:index]
          if int(value,16) != default:
            print "Default Mismatch: %s %s %x" % (cmd,out,default)
          else:
            print "Default Match: %s %s %x" % (cmd,out,default)
        except ValueError:
          pass
      except KeyError:
        if debug: print "Error 19: no default value",regname,src2param[src][regname]

def default2value(number):
  """
  """
  if "'h" in number:
    print number
    index=number.index("'h")
    number=int(number[index+2:],16)
  elif "'d" in number:
    index=number.index("'d")
    number=int(number[index+2:],10)
  else:
    if debug: print "Error 20: default format %s"%number
    number=0
  return number

if __name__ == '__main__':
  """
  """
  top_regs=''
  argc=len(sys.argv)
  if argc > 1 : top_regs = sys.argv[1]

  if top_regs != '' :
    create_db(top_regs)
    xmlpath=os.path.dirname(top_regs)
  else :
    create_db('/src/pld/trunk/dominica_dal/design/top/doc/dom_regs_top.xml')
    xmlpath=os.path.dirname('/src/pld/trunk/dominica_dal/design/top/doc/dom_regs_top.xml')

  leaf_db(xmlpath)

  decpathgen ()

  read_default_registers()


  #pprint(param)
  #pprint(srcs)
  #pprint(src2param)
  #pprint(decpaths)
  #pprint(decpath2src)
  
