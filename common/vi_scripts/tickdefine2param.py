#!/usr/bin/env python2
import os
from pprint import pprint
vfiles=[]
file2incs={}
incfiles=[]
makefiles=[]
tmpdir='tmp'
oldinc2new={}
oldinc2newpkg={}
newincs=[]
make_lines=[]
def findfile(top):
  """
  """
  for (path,dirs,files) in os.walk(top,topdown=True):
    excludes=[]
    if 'svn' not in path:
      print path
      basename=os.path.basename(path)
      dirname=os.path.dirname(path)
      print dirname,basename
      #dirs=filter(lambda x: 'svn' not in x,dirs)
      #print dirs
      if 'plain_files.txt' in files:
        INFILE=open(os.path.join(path,'plain_files.txt'),'r')
        excludes.extend(map(lambda x: (x.replace('./','')).strip(),INFILE.readlines()))
        INFILE.close()
      if 'qencrypt_files.txt' in files:
        INFILE=open(os.path.join(path,'qencrypt_files.txt'),'r')
        excludes.extend(map(lambda x: (x.replace('./','')).strip(),INFILE.readlines()))
        INFILE.close()
      #print excludes

      files=filter(lambda x: 'svn' not in x,files)
      files=filter(lambda x: x.endswith('.v') or x.endswith('.sv'),files)
      files=filter(lambda x: x not in excludes,files)
      if files:
        files=map(lambda x: os.path.join(path,x),files)
        #print files
        vfiles.extend(files)
def firstpass():
  """
  find include files and define ticks in the files
  """
  for file in vfiles:
    incs=[]
    INFILE=open(file,'r')
    for line in INFILE.readlines():
      line=line.strip()
      if line.startswith('`include'):
        if '"' in line:
          index=line.index('"')
          name=line[index+1:]
          index=name.index('"')
          name=name[:index]
        else:
          index=line.index("'")
          name=line[index+1:]
          index=name.index("'")
          name=name[:index]
        #print file,line,name
        incs.append(name)
        if name not in incfiles:
          incfiles.append(name)
      if incs:
        file2incs[file]=incs
    INFILE.close()

def findendif(lines):
  """
  """
  outs=[]
  while lines:
    line=lines.pop(0)
    origline=line.rstrip()
    line=origline.lstrip()
    lblankline=len(origline)-len(line)
    if line.startswith("`endif"):
      newline='%s%s'%(" "*(lblankline),line)
      outs.append(newline)
      return (lines,outs)
    elif line.startswith("`else"):
      newline='%s%s'%(" "*(lblankline),line)
      outs.append(newline)
    else:
      newline='%s%s'%(" "*(2+lblankline),line)
      outs.append(newline)
    
def findmodule(lines):
  """
  """
  outs=[]
  while lines:
    line=lines.pop(0)
    origline=line.rstrip()
    line=origline.lstrip()
    lblankline=len(origline)-len(line)
    if line.startswith("endmodule"):
      newline='%s%s'%(" "*(lblankline),line)
      outs.append(newline)
      return (lines,outs)
    else:
      newline='%s%s'%(" "*(2+lblankline),line)
      outs.append(newline)

def findheader(lines):
  """
  """
  outs=[]
  while lines:
    line=lines.pop(0)
    line=line.rstrip()
    if line.endswith('*/'):
      outs.append(line)
      return (lines,outs)
    else:
      outs.append(line)

def secondpass():
  """
  """
  make_lines.append("all: difffile")
  make_lines.append("cpinc:")
  for file in incfiles:
    incs=[]
    pkgs=[]
    firstline=True
    headers=[]
    path=filter(lambda x : x.endswith(file),vfiles)[0]
    print path
    INFILE=open(path,'r')
    lines=INFILE.readlines()
    dirname=os.path.dirname(path)
    basename=os.path.basename(path)
    name=os.path.splitext(basename)[0]
    if '_inc' in name: name=name[:-4]
    while lines:
      line=lines.pop(0)
      line=line.expandtabs()
      origline=line.rstrip()
      line=origline.lstrip()
      lblankline=len(origline)-len(line)
      #print lblankline
      if firstline:
        if line.startswith('/*') and not line.endswith('*/'):
          headers.append(line)
          (lines,hdrs)=findheader(lines)
          headers.extend(hdrs)
          pkgs.extend(headers)
          pkgs.append("package %s_pkg;"%name)
          incs.extend(headers)
          firstline=False
          continue
        else:
          pkgs.append("package %s_pkg;"%name)
          firstline=False
      if line.startswith("module"):
        newline='%s%s'%(" "*(lblankline),line)
        incs.append(newline)
        (lines,modules)=findmodule(lines)
        incs.extend(modules)
      elif line.startswith("`ifdef"):
        newline='%s%s'%(" "*(lblankline),line)
        incs.append(newline)
        (lines,ifendifs)=findendif(lines)
        incs.extend(ifendifs)
      elif line.startswith("`ifndef"):
        newline='%s%s'%(" "*(lblankline),line)
        incs.append(newline)
        (lines,ifendifs)=findendif(lines)
        incs.extend(ifendifs)
      elif line.startswith("`define"):
        #print line
        line=line[8:].lstrip()
        if ' ' not in line:
          newline='%s`define %s'%(" "*(lblankline),line)
          incs.append(newline)
          continue
        index=line.index(' ')
        param=line[:index].strip()
        origvalue=line[index:]
        value=origvalue.lstrip()
        value=value.replace("`","")
        lblankvalue=len(origvalue)-len(value)
        if '//' in value:
          index=value.index('//')
          origvalue=value[:index]
          comment=value[index:] 
          value=origvalue.rstrip()
          rblankvalue=len(origvalue)-len(value)
          newline='%slocalparam %s%s= %s;%s%s'%(" "*(2+lblankline),param," "*lblankvalue,value," "*rblankvalue,comment)
          pkgs.append(newline)
        else:
          newline='%slocalparam %s%s= %s;'%(" "*(2+lblankline),param," "*lblankvalue,value)
          pkgs.append(newline)
      else:
        newline='%s%s'%(" "*(2+lblankline),line)
        pkgs.append(newline)
    pkgs.append("endpackage")
    print name
    news=[]
    make_lines.append("\techo 'rm ../%s'"%path)
    make_lines.append("\trm ../%s"%path)
    if len(pkgs) > len(headers):
      pkg_f=open("tmp/%s_pkg.sv"%name,"w")
      make_lines.append("\techo 'cp %s_pkg.sv ../%s'"%(name,dirname))
      make_lines.append("\tcp %s_pkg.sv ../%s"%(name,dirname))
      pkg_f.write("\n".join(pkgs))
      news.append("%s_pkg.sv"%name)
      oldinc2newpkg[file]="%s_pkg.sv"%name
    if len(incs) > len(headers):
      inc_f=open("tmp/%s_inc.sv"%name,"w")
      make_lines.append("\techo 'cp %s_inc.sv ../%s'"%(name,dirname))
      make_lines.append("\tcp %s_inc.sv ../%s"%(name,dirname))
      inc_f.write("\n".join(incs))
      news.append("%s_inc.sv"%name)
      if "%s_inc.sv"%name not in newincs:
        newincs.append("%s_inc.sv"%name)

    oldinc2new[file]=news
    inc_f.close()
    pkg_f.close()
        
def thirdpass():
  """
  """
  make_f=open("tmp/Makefile","w")
  cpcmds=[]
  diffcmds=[]
  cpcmds.append("copyfile:")
  diffcmds.append("difffile:")
  for (file,incs) in file2incs.items():
    print file
    outs=[]
    imports=map(lambda x: oldinc2newpkg[x],incs)
    INFILE=open(file,'r')
    lines=INFILE.readlines()
    while lines:
      line=lines.pop(0)
      line=line.expandtabs()
      origline=line.rstrip()
      line=origline.lstrip()
      lblankline=len(origline)-len(line)
      if line.startswith('module '):
        first_paren_semiconlon=True
      if line.startswith('/*') and not line.endswith('*/'):
        outs.append(line)
        (lines,hdrs)=findheader(lines)
        outs.extend(hdrs)
      elif line.startswith("`ifdef SIM"):
        print "chiwei",line
        print line
        print line
        (lines,ifendifs)=findendif(lines)
        continue
      elif line.startswith("`ifndef"):
        outs.append(line)
      elif line.startswith("`ifdef"):
        outs.append(line)
      elif line.startswith("`else"):
        outs.append(line)
      elif line.startswith("`endif"):
        outs.append(line)
      elif line.startswith("`timescale"):
        outs.append(line)
      elif line.startswith("`include "):
        pass
      elif line.startswith("`define "):
        print "Error: tick define in rtl %s %s"%(file,line)
      elif line.endswith(");") and first_paren_semiconlon:
        first_paren_semiconlon=False
        outs.append("%s%s"%(" "*lblankline,line))
        outs.extend(map(lambda x:"import %s::*;"%x, map(lambda x: x.replace(".v",""), map(lambda x: x.replace(".sv",""),imports))))
      else:
        line=line.replace('`','')
        outs.append("%s%s"%(" "*lblankline,line))
    basename=os.path.basename(file)
    OUTFILE=open("tmp/%s"%basename,"w")
    OUTFILE.write("\n".join(outs))
    OUTFILE.close()
    cpcmds.append("\techo 'cp %s ../%s'"%(basename,file))
    cpcmds.append("\tcp %s ../%s"%(basename,file))
    diffcmds.append("\techo 'diff -w %s ../%s'"%(basename,file))
    diffcmds.append("\tdiff -w %s ../%s"%(basename,file))
  make_lines.extend(cpcmds)
  make_lines.extend(diffcmds)
  make_f.write("\n".join(make_lines))
  make_f.close()
   

       



if __name__ == '__main__':
  import sys
  argc = len(sys.argv)
  if argc > 1: dirpath = sys.argv[1]
  if not os.path.exists(tmpdir): os.mkdir(tmpdir)
  #print dirpath
  findfile(dirpath)
  firstpass()
  #print incfiles
  #print file2incs
  secondpass()
  #print oldinc2new
  #print oldinc2newpkg
  #print newincs
  thirdpass()

  pprint(file2incs)
