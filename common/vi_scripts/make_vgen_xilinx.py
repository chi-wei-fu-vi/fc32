#!/usr/bin/env python2
import datetime
import os, sys
import xml.dom.minidom
import random
import subprocess
import string
import re
import glob
import shutil
from pprint import pprint
cmdpath=None
xmlpath=None
debug=False
param={}
srcs=[]
src2param={}
decpaths=[]
decpath2src={}
device=None
family=None
timestamp=None
seed=None
def reg_db(path,file) :
  """
  """
  doc=xml.dom.minidom.parse("%s/%s"%(path,file))
  #print doc.toprettyxml().strip()
  l0=doc.lastChild
  topname=l0.nodeName
  if topname != 'decl_reg_list':
    if debug: print "Error 1 : xml file is not decl reg list Xml"
    sys.exit(1)
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
    sys.exit(2)
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
  
def findcmdpath(path):
  """
  """
  global cmdpath
  script_dir="common/vi_scripts"
  cmdpath=os.path.abspath("../../%s"%script_dir)
  return
  script_dir="common/vi_scripts"
  cmd='svn info %s' % path
  print cmd
  proc = subprocess.Popen( cmd, shell=True, stdout = subprocess.PIPE, stderr = subprocess.PIPE )
  out,error=proc.communicate()
  if proc.returncode !=0:
    print "ERROR: add execute priviledge %s %s" % (cmd,error)
  else:
    cmdpath="." # Start at the current directory
    commonDir="common"
    print "Searching backwards from the current directory for path to {0}".format(commonDir)
    while True:
      # Look for the common directory (once we reach it, it's the cmdpath we want)
      if os.path.exists("{0}/{1}/vi_scripts".format(cmdpath, commonDir)):
        break
      # Otherwise, go up a directory and try again
      else:
        cmdpath="{0}/..".format(cmdpath)
      # Check to see if we are at / already
      if os.path.abspath(cmdpath) == "/":
        print "{0} directory not found...".format(commonDir)
        sys.exit(200)
    cmdpath=os.path.join(cmdpath,script_dir)
    print cmdpath
    cmdpath=os.path.abspath(cmdpath)
    print cmdpath
  
  
  

def run_vgen ():
  """
  """
  global cmdpath
  global xmlpath
  print cmdpath
  cmd='chmod u+x %s/vgen_xls2xml_2.py' % cmdpath
  print cmd
  proc = subprocess.Popen( cmd, shell=True, stdout = subprocess.PIPE, stderr = subprocess.PIPE )
  out,error=proc.communicate()
  if proc.returncode !=0:
    print "ERROR: add execute priviledge %s %s" % (cmd,error)
  cmd='chmod u+x %s/vgen.py' % cmdpath
  print cmd
  proc = subprocess.Popen( cmd, shell=True, stdout = subprocess.PIPE, stderr = subprocess.PIPE )
  out,error=proc.communicate()
  if proc.returncode !=0:
    print "ERROR: add execute priviledge %s %s" % (cmd,error)
  for src in srcs:
    src=os.path.relpath(os.path.join(xmlpath,src))
    print src
    basename=os.path.basename(os.path.join(xmlpath,src))
    dirname=os.path.dirname(src)
    name, ext = os.path.splitext(basename)
    print name,ext
    xlsxf=os.path.join(dirname,"%s.xlsx"%name)
    if os.path.exists(xlsxf):
      mv_xml(src,"%s.old"%src)
      print xlsxf
      cmd= "%s %s %s" % ("%s/vgen_xls2xml_2.py"%cmdpath,xlsxf,src)
      print cmd
      proc = subprocess.Popen( cmd, shell=True, stdout = subprocess.PIPE, stderr = subprocess.PIPE )
      out,error=proc.communicate()
      if proc.returncode !=0:
        print "ERROR: xlsx to xml conversion %s %s" % (out,error)
      else:
        newobj=reg_xml(src)
        oldobj=reg_xml("%s.old"%src)
        if not(newobj==oldobj) :
          print "ERROR: xml generated from %s and original %s are different"%(xlsxf,src)
        
        
        

    cmd= "pushd %s;%s %s;popd" % (dirname,os.path.relpath("%s/vgen.py"%cmdpath,dirname),basename)
    print cmd
    proc = subprocess.Popen( cmd, shell=True, stdout = subprocess.PIPE, stderr = subprocess.PIPE )
    out,error=proc.communicate()
    if proc.returncode !=0:
      print "ERROR: vgen %s %s" % (out,error)
    # move file to auto dir if auto exist
    #mv_to_auto(name,dirname)

def mv_to_auto(name,dirname):
  """
  """
  #if name in [ "chipregs", "pma_1ch_regs", "txbist32b_regs", "ucstats_regs", "xbar_regs"]:
  if os.path.exists(os.path.join(dirname,"../rtl/auto")):
    file="%s/%s.v"%(dirname,name)
    dst="%s/rtl/auto/%s.v"%(os.path.dirname(dirname),name)
    if os.path.exists(file):
      print "mv %s %s"%(file,dst)
      shutil.move(file,dst)
    else:
      print "Error: register file is not exist %s"%file
      sys.exit(3)
      
def create_workarea (project):
  """
  """
  global timestamp
  now=datetime.datetime.now()
  timestamp=now.strftime("%Y%m%dT%H%M%S")
  workfolder ='work%s'%timestamp
  if os.path.exists(workfolder):
    cmd='rm -rf %s'%workfolder
    print cmd
    proc = subprocess.Popen( cmd, shell=True, stdout = subprocess.PIPE, stderr = subprocess.PIPE )
    out,error=proc.communicate()
    if proc.returncode !=0:
      print "ERROR: %s %s" % (out,error)
  cmd='mkdir %(workfolder)s' % dict(workfolder=workfolder)
  print cmd
  proc = subprocess.Popen( cmd, shell=True, stdout = subprocess.PIPE, stderr = subprocess.PIPE )
  out,error=proc.communicate()
  if proc.returncode !=0:
    print "ERROR: %s %s" % (out,error)
  cmd='cp %(project)s.qip  %(project)s.tcl %(project)s.xdc %(workfolder)s' % dict(project=project,workfolder=workfolder)
  print cmd
  proc = subprocess.Popen( cmd, shell=True, stdout = subprocess.PIPE, stderr = subprocess.PIPE )
  out,error=proc.communicate()
  if proc.returncode !=0:
    print "ERROR: %s %s" % (out,error)

def update_qsf():
  """
  """
  global family
  global device
  global timestamp
  global seed
  files=glob.glob("*qsf")
  paths=[]
  qips=[]
  for file in files:
    lines=[]
    INFILE=open(file,"r")
    workfolder='work%s'%timestamp
    OUTFILE=open("%s/%s"%(workfolder,file),"w")
    for x in INFILE.readlines():
      x=x.strip()
      if x.startswith  ('set_global_assignment -name FAMILY '):
        family=x[35:]
      elif x.startswith('set_global_assignment -name DEVICE '):
        device=x[35:]
      elif x.startswith('set_global_assignment -name SEARCH_PATH '):
        paths.append(x[40:])
      elif x.startswith('set_global_assignment -name QIP_FILE '):
        qips.append(x[37:])
      elif x.startswith('set_global_assignment -name SEED '):
        seed=x[33:]
      lines.append(x.replace('\x2e\x2e\x2f',''))
    OUTFILE.write("\n".join(lines))
    INFILE.close()
    OUTFILE.close()
  #print paths
  for path in paths:
    path=path.strip()
    dst='%s/%s'%(workfolder,path.replace('\x2e\x2e\x2f',''))
    if not os.path.exists(dst):
      if not os.path.exists(os.path.dirname(dst)):
        print "mkdir %s" % os.path.dirname(dst)
        os.mkdir(os.path.dirname(dst))
      print "mkdir %s" % dst
      os.mkdir(dst)
    files=glob.glob("%s/*"%path)
    #print files
    for file in files:
      dst='%s/%s'%(workfolder,file.replace('\x2e\x2e\x2f',''))
      if os.path.islink(file):
        print "cp %s %s" % (file,dst)
        shutil.copy(file,dst)
      elif os.path.isfile(file):
        print "cp %s %s" % (file,dst)
        shutil.copy(file,dst)
  #print qips
  for qip in qips:
    qip=qip.strip()
    qip='%s/%s'%(workfolder,qip.replace('\x2e\x2e\x2f',''))
    if not os.path.exists(qip):
      print "Error: %s file is not exist" % qip
    else:
      outs=[]
      INFILE=open(qip,'r')
      qip_path=os.path.dirname(qip)
      for line in INFILE.readlines():
        line=line.strip()
        if line.startswith('#'):
          pass
        elif '_FILE' in line:
          if 'quartus(qip_path) ' in line:
            index=line.index('quartus(qip_path) ')
            prefix=line[:index+18]
            name=line[index+18:-1].replace('"','').replace("'",'').strip()
          else:
            index=line.index('_FILE ')
            prefix=line[:index+6] + '[file join $::quartus(qip_path) '
            name=line[index+6:].replace("'","").replace('"','').strip()
          if os.path.isfile(os.path.join(qip_path,name)):
            outs.append('%s"%s"]'%(prefix,name))
          elif name.startswith('\x2e\x2e\x2f'):
            name=name[3:]   
            if os.path.isfile(os.path.join(qip_path,name)):
              outs.append('%s"%s"]'%(prefix,name))
            elif name.startswith('\x2e\x2e\x2f'):
              name=name[3:]   
              if os.path.isfile(os.path.join(qip_path,name)):
                outs.append('%s"%s"]'%(prefix,name))
              else:
                print os.path.join(qip_path,name)
                #print "Error: path %s %s is not exist" % (qip,name)
        else:
          outs.append(line)
      #print "\n".join(outs)
      INFILE.close()
      OUTFILE=open(qip,'w')
      OUTFILE.write("\n".join(outs))
      OUTFILE.close()
          
      
    

  
def create_makefile(file,project):
  """
  """
  global family
  global device
  global timestamp
  global seed
  workfolder='work%s'%timestamp
  OUTFILE=open("%s/Makefile"%workfolder,"w")
  OUTFILE.write("""
###################################################################
# Project Configuration: 
# 
# Specify the name of the design (project), the Quartus II Settings
# File (.qsf), and the list of source files used.
###################################################################
PROJECT = %s
SOURCE_FILES =
SEED = %s
ASSIGNMENT_FILES = %s.qpf %s.qsf 

###################################################################
# Main Targets
#
# all: build everything
# clean: remove output files and database
###################################################################

all: smart.log $(PROJECT).asm.rpt $(PROJECT).sta.rpt 

clean:
	rm -rf *.rpt *.chg *.log *.htm *.eqn *.pin *.sof *.pof db incremental_db

map: smart.log $(PROJECT).map.rpt
fit: smart.log $(PROJECT).fit.rpt
asm: smart.log $(PROJECT).asm.rpt
sta: smart.log $(PROJECT).sta.rpt
smart: smart.log

###################################################################
# Executable Configuration
###################################################################

MAP_ARGS = --family=%s

FIT_ARGS = --part=%s --seed=$(SEED)
ASM_ARGS =
STA_ARGS =

###################################################################
# Target implementations
###################################################################

STAMP = echo done >

$(PROJECT).map.rpt: map.chg $(SOURCE_FILES) 
	quartus_map $(MAP_ARGS) $(PROJECT)
	$(STAMP) fit.chg

$(PROJECT).fit.rpt: fit.chg $(PROJECT).map.rpt
	quartus_cdb --merge $(PROJECT)
	quartus_fit $(FIT_ARGS) $(PROJECT)
	$(STAMP) asm.chg
	$(STAMP) sta.chg

$(PROJECT).asm.rpt: asm.chg $(PROJECT).fit.rpt
	quartus_asm $(ASM_ARGS) $(PROJECT)
	quartus_cpf -c $(PROJECT).sof $(PROJECT).rbf

$(PROJECT).sta.rpt: sta.chg $(PROJECT).fit.rpt
	quartus_sta $(STA_ARGS) $(PROJECT) 

smart.log: $(ASSIGNMENT_FILES)
	quartus_sh --determine_smart_action $(PROJECT) > smart.log

###################################################################
# Project initialization
###################################################################

$(ASSIGNMENT_FILES):
	quartus_sh --prepare $(PROJECT)

map.chg:
	$(STAMP) map.chg
fit.chg:
	$(STAMP) fit.chg
sta.chg:
	$(STAMP) sta.chg
asm.chg:
	$(STAMP) asm.chg
"""%(project,seed,project,project,family,device))
  OUTFILE.close()
  if os.path.exists('work'):
    if os.path.islink('work'):
      cmd='rm work;ln -s %s work'%workfolder
      print cmd
      proc = subprocess.Popen( cmd, shell=True, stdout = subprocess.PIPE, stderr = subprocess.PIPE )
      out,error=proc.communicate()
      if proc.returncode !=0:
        print "ERROR: %s %s" % (cmd,error)
    else:
      cmd='mv work work.backup;ln -s %s work'%workfolder
      print cmd
      proc = subprocess.Popen( cmd, shell=True, stdout = subprocess.PIPE, stderr = subprocess.PIPE )
      out,error=proc.communicate()
      if proc.returncode !=0:
        print "ERROR: %s %s" % (cmd,error)
  else:
    cmd='ln -s %s work'%workfolder
    print cmd
    proc = subprocess.Popen( cmd, shell=True, stdout = subprocess.PIPE, stderr = subprocess.PIPE )
    out,error=proc.communicate()
    if proc.returncode !=0:
      print "ERROR: %s %s" % (cmd,error)
  cmd='pushd work;make clean;popd'
  print cmd
  proc = subprocess.Popen( cmd, shell=True, stdout = subprocess.PIPE, stderr = subprocess.PIPE )
  out,error=proc.communicate()
  if proc.returncode !=0:
    print "ERROR: %s %s" % (cmd,error)
def mv_xml(xml,xml_old):
  with open(xml,'r') as f:
    lines=f.read()
  f.close()
  with open(xml_old,'w') as f:
    f.write(lines)
  f.close()


class reg_xml(object):
  """
  """
  file=''
  debug=0
  def __init__(self,
               fname,
               debug=0):
    """
    """
    self.debug=debug
    self.src2param={}
    self.gen_reg_db(xml.dom.minidom.parse(fname))


  def print_db(self):
    """
    """
    pprint(self.src2param)

  def gen_reg_db(self,doc):
    """
    """
    l0=doc.lastChild
    topname=l0.nodeName
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
          self.src2param[name]={}
          if regex_range != '':
            self.src2param[name]['_regex_range']=regex_range
          if default != '':
            self.src2param[name]['_default']=default
          if offset != '':
            self.src2param[name]['_offset']=offset
          if size != '':
            self.src2param[name]['_size']=size
          if typ != '':
            self.src2param[name]['_typ']=typ
          if usr != '':
            self.src2param[name]['_usr']=usr
          if incsz != '':
            self.src2param[name]['_incsz']=incsz
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
                self.src2param[name]['_descr']=descr
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
              self.src2param[name][name2]={}
              if loc != '':
                self.src2param[name][name2]['_loc']=loc
              if typ != '':
                self.src2param[name][name2]['_typ']=typ
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
                    self.src2param[name][name2]['_descr']=descr
              elif l3.nodeType == l0.ELEMENT_NODE: #1
                  if self.debug: print "Error 5 : extra branch in the tree",l3.nodeValue.strip()
    return self.src2param
  def __eq__(self,other):
    #pprint(self.src2param)
    #pprint(other.src2param)
    return self.src2param == other.src2param


if __name__ == '__main__':
  """
  """
  top_regs=''
  argc=len(sys.argv)
  if argc > 1 : top_regs = sys.argv[1]
  if argc > 2 : project  = sys.argv[2]
  if argc > 3 : option   = sys.argv[3]

  if False:
    timestamp=''
    #update_qsf()
    exit(0)

  xmlpath=os.path.dirname(top_regs)
  create_db(top_regs)
  srcs=map(lambda x :os.path.relpath(os.path.abspath(os.path.join(xmlpath,x)),xmlpath),srcs)

  findcmdpath(xmlpath)
  run_vgen ()

  leaf_db(xmlpath)

  decpathgen ()

  if argc > 3:
    if option == "vgen_only":
      print "Complete verilog registers generation"
    else:

      #create_workarea(project)
  
      #update_qsf()

      create_makefile("work/Makefile",project)
  else:
    create_workarea(project)
  
    #update_qsf()

    create_makefile("work/Makefile",project)


  #pprint(param)
  #pprint(srcs)
  #pprint(src2param)
  #pprint(decpaths)
  #pprint(decpath2src)
  
