#!/usr/bin/env python2
import re
import os.path
import glob
from pprint import pprint
sims=[]
vlogs=[]
qips=[]
altips=[]
viips=[]
viip2path={}
vlibs=[]
sdcs=[]
top=None
cmdpath=None
searchs=[]
synpath=None
qsfname=None
directives={
"BALIDIR"               :       "../../../../../bali_dal/prototype",
"SIMDEF"                :       "",
"PCIEDIR"               :       "${BALIDIR}/pcie/verif/run",
"PCIEBFM"               :       "../env/ref/ext_bfm_pcie",
"TBDIR"                 :       "../env",
"AUTODIR"               :       "../../rtl/auto",
"AUTODIR_EXTRA"         :       "../../../../../common/vi_design/ucstats/rtl/auto",
"AUTOREG"               :       "../../../../../common/vi_scripts/auto_reg_wire.pl",
"SCRPDIR"               :       "../../../../../common/vi_scripts",
"CFGDIR"                :       "../cfg",
"TESTDIR"               :       "../tests",
"TEST"                  :       "no_test",
"MYMIF"                 :       "no_mif",
"CFG"                   :       "",
"DOCMD"                 :       "'run -all;quit'",
"COV"                   :       "0",
"COV_DOCMD"             :       "'coveragesave-onexitcov_${TEST}.ucdb;run -all;quit'",
"SEED"                  :       "12345"
}
def update_directives():
  """
  """
  global cmdpath
  directives["BALIDIR"]              =       "%s"%find_dirpattern('bali_dal/prototype')
  directives["AUTODIR_EXTRA"]        =       "%s/ucstats/rtl/auto"%find_dirpattern('common/vi_design')
  directives["AUTOREG"]              =       "%s/auto_reg_wire.pl"%cmdpath
  directives["SCRPDIR"]              =       "%s"%cmdpath

def find_dirpattern(pattern):
  paths=[]
  paths.extend(vlogs)
  paths.extend(searchs)
  paths.extend(qips)
  for path in paths:
    if pattern in path:
      index=path.index(pattern)
      path=path[:index]
      print path
      if path !="":
        path=os.path.relpath(os.path.join(os.path.join(synpath,path),pattern))
        print path
      else:
        path=os.path.relpath(os.path.join(synpath,pattern))
      return path
def readqsf(file):
  """
  Read qsf file
  """
  global top
  INFILE=open(file,"r")
  for line in INFILE.readlines():
    line = line.strip()
    line = re.sub("\s+"," ",line)
    if line.startswith("#"):
      pass
    elif "set_global_assignment -name TOP_LEVEL_ENTITY " in line:
      index=line.index("ENTITY ")
      line=line[index+7:]
      if " " in line:
        index=line.index(" ")
        top=line[:index]
      else:
        top=line
    elif "set_global_assignment -name SYSTEMVERILOG_FILE " in line:
      index=line.index("FILE ")
      line=line[index+5:]
      if " " in line:
        index=line.index(" ")
        vlog_file=line[:index]
      else:
        vlog_file=line
      if vlog_file not in vlogs:
        vlogs.append(vlog_file)

    elif "set_global_assignment -name VERILOG_FILE " in line:
      index=line.index("FILE ")
      line=line[index+5:]
      if " " in line:
        index=line.index(" ")
        vlog_file=line[:index]
      else:
        vlog_file=line
      if vlog_file not in vlogs:
        vlogs.append(vlog_file)
    elif "set_global_assignment -name QIP_FILE " in line:
      index=line.index("FILE ")
      line=line[index+5:]
      if " " in line:
        index=line.index(" ")
        qip_file=line[:index]
      else:
        qip_file=line
      if qip_file not in qips:
        qips.append(qip_file)
    elif "set_global_assignment -name SEARCH_PATH " in line:
      index=line.index("PATH ")
      line=line[index+5:]
      if " " in line:
        index=line.index(" ")
        search_path=line[:index]
      else:
        search_path=line
      if search_path not in searchs:
        searchs.append(search_path)
    elif "set_global_assignment -name SDC_FILE " in line:
      index=line.index("FILE ")
      line=line[index+5:]
      if " " in line:
        index=line.index(" ")
        sdc_file=line[:index]
      else:
        sdc_file=line
      if sdc_file not in sdcs:
        sdcs.append(sdc_file)
    else:
      pass
def vlog2vitop(vlog):
  """
  Compile verilog files
  """
  global cmdpath
  paths=[]
  name= os.path.basename(vlog)
  path= os.path.relpath(os.path.join(synpath,os.path.dirname(vlog)))
  paths.append(path)
  if os.path.exists('%s/%s'%(path,name)):
    print "%s/%s"%(path,name)
    if os.path.exists('%s/auto'%path):
      paths.append("%s/auto"%path)
      paths.append(os.path.relpath(os.path.join(cmdpath,"../vi_include")))
      return "\tvlog +incdir+%s +define+${SIMDEF} -work vitop -sv %s/%s"%("+".join(paths),path,name)
    elif (name.find("top.sv") > -1):
      return "\tvlog +incdir+%s+${TBDIR} +define+${SIMDEF} -work vitop -sv %s/%s"%(path,path,name)
    else:
      return "\tvlog +incdir+%s +define+${SIMDEF} -work vitop -sv %s/%s"%(path,path,name)
  else:
    return ""
  
def qip2sims(qip):
  """
  """
  name= os.path.basename(qip)[:-4]
  path= os.path.relpath(os.path.join(synpath,os.path.dirname(qip)))
  if os.path.exists('%s/%s'%(path,name)):
    files=[]
    files.extend(map(lambda x: os.path.basename(x), glob.glob("%s/%s/*.txt"%(path,name))))
    if "plain_files.txt" in files:
      if os.path.exists("%s/%s_sim"%(path,name)) and os.path.exists("%s/%s_sim/mentor/msim_setup.tcl"%(path,name)):
        sims.append(name)


def qip2altip(qip):
  """
  Find plain txt or Create compile list
  """
  lines=[]
  name= os.path.basename(qip)[:-4]
  path= os.path.relpath(os.path.join(synpath,os.path.dirname(qip)))
  rtldir="%s_DIR"%name.upper()
  if os.path.exists('%s/%s'%(path,name)):
    #print "%s/%s/*.txt"%(path,name)
    files=[]
    files.extend(map(lambda x: os.path.basename(x), glob.glob("%s/%s/*.txt"%(path,name))))
    
    #print files
    if "plain_files.txt" not in files:
      if name not in vlibs:
        vlibs.append(name)
      else:
        print "Error: duplicate vlib name %s" % name
      viips.append(name)
      viip2path[name]=path
    else:
      if name not in vlibs:
        vlibs.append(name)
      else:
        print "Error: duplicate vlib name %s" % name
      altips.append(name)
      lines.append("\tvlib %s"%name)
      if name in sims:
#        lines.append("""
#\twhile read LINE; do \\
#\t  echo ${%s}_sim/$$(echo $$LINE| grep -v '^#' | grep 'QSYS_SIMDIR' | grep '%s' | sed -e 's+.*QSYS_SIMDIR++' -e 's+".*++'); \\
#\tdone < ${%s}_sim/mentor/msim_setup.tcl
#"""%(rtldir,name,rtldir))
        lines.append("""
ifeq (${%s_SIM},1)
\twhile read LINE; do \\
\t  vlog +incdir+${%s} +define+${SIMDEF} -sv -work %s ${%s}_sim/$$(echo $$LINE| grep -v '^#' | grep 'QSYS_SIMDIR' | grep '%s' | sed -e 's+.*QSYS_SIMDIR++' -e 's+".*++'); \\
\tdone < ${%s}_sim/mentor/msim_setup.tcl
endif
ifeq (${%s_SIM},0)
\twhile read LINE; do \\
\t  vlog +incdir+${%s} +define+${SIMDEF} -sv -work %s ${%s}/../$$(echo $$LINE| grep -v '^#' | grep 'VERILOG_FILE' | sed -e 's+.*qip_path)  *"*++' -e 's+"*]++'); \\
\tdone < ${%s}/../%s.qip
endif
"""%(name.upper(),rtldir,name,rtldir,name,rtldir,
name.upper(),rtldir,name,rtldir,rtldir,name))
      else:
#        if os.path.exists("%s/%s.v"%(path,name)):
#          lines.append("\tvlog +incdir+${%s} +define+${SIMDEF} -sv -work %s ${%s}/../%s.v"%("%s_DIR"%name.upper(),name,"%s_DIR"%name.upper(),name))
        lines.append("""
\twhile read LINE; do \\
\t  vlog +incdir+${%s} +define+${SIMDEF} -sv -work %s ${%s}/../$$(echo $$LINE| grep -v '^#' | grep 'VERILOG_FILE' | sed -e 's+.*qip_path)  *"*++' -e 's+"*]++'); \\
\tdone < ${%s}/../%s.qip
"""%(rtldir,name,rtldir,rtldir,name))
#        for file in files:
#          lines.append("""
#\twhile read LINE; do \\
#\t  vlog +incdir+${%s} +define+${SIMDEF} -sv -work %s ${%s}/$$LINE; \\
#\tdone < ${%s}/%s
#"""%("%s_DIR"%name.upper(),name,"%s_DIR"%name.upper(),"%s_DIR"%name.upper(),file))

  else:  
    #print "%s/*.txt"%path
    files=[]
    files.extend(map(lambda x: os.path.basename(x), glob.glob("%s/*.txt"%(path))))
    #print files
    if "plain_files.txt" not in files:
      if name not in vlibs:
        vlibs.append(name)
      else:
        print "Error: duplicate vlib name %s" % name
      viips.append(name)
      viip2path[name]=path
    else:
      if name not in vlibs:
        vlibs.append(name)
      else:
        print "Error: duplicate vlib name %s" % name
      altips.append(name)
      lines.append("\tvlib %s"%name)
      lines.append("""
\twhile read LINE; do \\
\t  vlog +incdir+${%s} +define+${SIMDEF} -sv -work %s ${%s}/../$$(echo $$LINE| grep -v '^#' | grep 'VERILOG_FILE' | sed -e 's+.*qip_path)  *"*++' -e 's+"*]++'); \\
\tdone < ${%s}/../%s.qip
"""%(rtldir,name,rtldir,rtldir,name))
#      for file in files:
#        lines.append("""
#\twhile read LINE; do \\
#\t  vlog +incdir+${%s} +define+${SIMDEF} -sv -work %s ${%s}/$$LINE; \\
#\tdone < ${%s}/%s
#"""%("%s_DIR"%name.upper(),name,"%s_DIR"%name.upper(),"%s_DIR"%name.upper(),file))
  return lines
def qip2viip(name):
  """
  Find plain txt or Create compile list
  """
  lines=[]
  path=viip2path[name]
  incdirs=find_incdir(name)
  lines.append("\tvlib %s"%name)
  rtldir="%s_DIR"%name.upper()
  if len(incdirs) == 0:
    lines.append("""
\twhile read LINE; do \\
\t  vlog +incdir+${%s} +define+${SIMDEF} -sv -work %s ${%s}/$$(echo $$LINE| grep -v '^#' | grep 'VERILOG_FILE' | sed -e 's+.*qip_path)  *"*++' -e 's+"*]++'); \\
\tdone < ${%s}/%s.qip
"""%(rtldir,name,rtldir,rtldir,name))
  else:
    lines.append("""
\twhile read LINE; do \\
\t  vlog +incdir+${%s}+${%s}/%s +define+${SIMDEF} -sv -work %s ${%s}/$$(echo $$LINE| grep -v '^#' | grep 'VERILOG_FILE' | sed -e 's+.*qip_path)  *"*++' -e 's+"*]++'); \\
\tdone < ${%s}/%s.qip
"""%(rtldir,rtldir,("+${%s}/"%rtldir).join(incdirs),name,rtldir,rtldir,name))
  #\t  echo \"$$(echo $$LINE| grep -v '^#' | grep 'VERILOG_FILE' | sed -e 's+.*qip_path)  *"*++' -e 's+"*]++')\" \\
  #\t  vlog +incdir+${%s} +define+${SIMDEF} -sv -work %s ${%s}/$$MLINE; \\
  #\tdone < ${%s}/%s.qip
  return lines

def find_incdir(name):
  """
  Find include files
  """
  lines=[]
  rtls=[]
  path=viip2path[name]
  if os.path.exists('%s/inc'%path): lines.append('inc')
  if os.path.exists('%s/auto'%path): lines.append('auto')
  if os.path.exists('%s/bali_pcie_app/inc'%path): lines.append('bali_pcie_app/inc')
  #pprint('%s/inc'%path)
  INFILE=open("%s/%s.qip"%(path,name),"r")
  for line in INFILE.readlines():
    line=line.strip()
    if 'VERILOG_FILE' in line:
      index=line.index('qip_path)')
      line=line[index+9:-1]
      line=line.strip()
      rtl=line.replace('"','')
      if rtl not in rtls: rtls.append(rtl)
  for rtl in rtls:
    if rtl.startswith('..'):
      path=os.path.dirname(rtl)
      if path not in lines: lines.append(path)
  return lines
  

def write_makefile(file):
  """
  Create Makefile
  """
  global synpath
  global qsfname
  OUTFILE=open(file,"w")
  lines=[]
  # library declaration
  # dummy operation to get sims
  for qip in qips:
    qip2sims(qip)
  for sim in sims:
    lines.append("%-30s := 0"%("%s_SIM"%sim.upper()))
  lines.append("%-30s = %s"%("SIM_LIB_DIR","""${QUARTUS_ROOTDIR}/eda/sim_lib"""))
  for qip in qips:
    name= os.path.basename(qip)[:-4]
    path= os.path.relpath(os.path.join(synpath,os.path.dirname(qip)))
    if os.path.exists('%s/%s'%(path,name)):
      lines.append("%-30s = %s/%s"%("%s_DIR"%name.upper(),path,name))
    else:  
      lines.append("%-30s = %s"%("%s_DIR"%name.upper(),path))
  lines.append("")
  lines.extend(map(lambda x: "%-30s = %s"%(x,directives[x]),filter(lambda x: x == "BALIDIR",directives)))
  lines.append("")
  lines.extend(map(lambda x: "%-30s = %s"%(x,directives[x]),filter(lambda x: x != "BALIDIR",directives)))
  lines.append("")
  lines.append("%-29s := %s"%("DATE","$(shell date +%T)"))

  # Altera sim lib
  vlibs.append("altlib")
  lines.append("""
altlib:
	vlib altlib
	vlog -sv -work altlib ${SIM_LIB_DIR}/220model.v
	vlog -sv -work altlib ${SIM_LIB_DIR}/sgate.v
	vlog -sv -work altlib ${SIM_LIB_DIR}/altera_lnsim.sv
	vlog -sv -work altlib ${SIM_LIB_DIR}/altera_primitives.v
	vlog -sv -work altlib ${SIM_LIB_DIR}/altera_mf.v	
	vlog -sv -work altlib ${SIM_LIB_DIR}/stratixv_atoms.v	
	vlog -sv -work altlib ${SIM_LIB_DIR}/mentor/stratixv_atoms_ncrypt.v	
	vlog -sv -work altlib ${SIM_LIB_DIR}/stratixv_hssi_atoms.v	
	vlog -sv -work altlib ${SIM_LIB_DIR}/mentor/stratixv_hssi_atoms_ncrypt.v	
	vlog -sv -work altlib ${SIM_LIB_DIR}/stratixv_pcie_hip_atoms.v
	vlog -sv -work altlib ${SIM_LIB_DIR}/mentor/stratixv_pcie_hip_atoms_ncrypt.v
""")
  # Altera ip lib
  lines.append("""
altip:
""")
  for qip in qips:
    lines.extend(qip2altip(qip))
  # auto
  if os.path.exists('../../doc/'):
    xmls=glob.glob('../../doc/*.xml')
    if len(xmls) != 0:
      lines.append("""
auto:
\tpushd ../../syn/;make auto;popd
\t${SCRPDIR}/make_vgen.py %s %s vgen_only
"""%(xmls[0],qsfname))
    else:
      lines.append("""
auto:
	echo "skip auto"
  """)
  else:
    lines.append("""
auto:
	echo "skip auto"
""")
  # VI ip lib
  lines.append("""
viip:
""")
  for name in viips:
    lines.extend(qip2viip(name))
  # VI top and glue logic
  vlibs.append("vitop")
  lines.append("""
vitop:
	vlib vitop
""")
  for vlog in vlogs:
    lines.append(vlog2vitop(vlog))

  # vsim options
  lines.append("%-30s = %s" % ("VSIM","vsim -L %s %s" % ( " -L ".join(vlibs), "+transport_int_delays +transport_path_delays +notimingchecks -t ps +noAssertions -novopt -c envlib.tb_top -l ${TEST}.log -wlf ${TEST}.wlf -do ${DOCMD} -sv_seed ${SEED}")))

  # clean
  lines.append("""
clean_env:
	rm -rf envlib
clean_altlib:
	rm -rf altlib %s
clean_viip:
	rm -rf %s
clean_vitop:
	rm -rf vitop
clean_all: clean_altlib clean_viip clean_env clean_vitop
"""%(" ".join(altips)," ".join(viips)))

  lines.append("""
get_cfg:
ifeq ("${SIMDEF}","RANDOM")
	cp ${CFGDIR}/rnd_cfg.svh ./my_env_cfg.svh
else	
	cp ${CFGDIR}/env_cfg.svh ./my_env_cfg.svh
	${SCRPDIR}/rtcfg ./my_env_cfg.svh "${CFG}"
endif

env: get_cfg
	vlib envlib
	while read LINE; do \
	  vlog -mfcu -incr +libext+.v +incdir+${TBDIR}+./ +define+${SIMDEF} -sv -work envlib ${PCIEBFM}/$$LINE -v ${SIM_LIB_DIR}/stratixiv_hssi_atoms.v; \
	done < ${PCIEBFM}/filelist
	vlog +libext+.sv -y ${ETH_MAC_DIR} -y ${TBDIR}/ref/bfm_linkengine +incdir+${TBDIR}+./+${TESTDIR} +define+${SIMDEF} -sv -work envlib ../tests/${TEST}.sv -f filelist_env
	vlog +incdir+${TBDIR} +define+${SIMDEF} -sv -work envlib ${TBDIR}/env_top.sv

sim: clean_vitop clean_viip clean_env auto viip vitop env
	@echo "TEST_SEED = ${SEED}"
	${VSIM}

sim_all: clean_all altlib altip sim
sim_env: clean_env env
	${VSIM}
""")

  print "\n".join(lines)
  OUTFILE.write("\n".join(lines))

if __name__ == '__main__':
  """
  """
  import sys
  argc=len(sys.argv)
  if argc >1 : qsf=sys.argv[1]
  if argc >2 : makefile=sys.argv[2]

  cmdpath=os.path.relpath(os.path.dirname(sys.argv[0]))
  
  synpath=os.path.dirname(qsf)
  qsfname=os.path.basename(qsf)

  readqsf(qsf)

  update_directives()
  print directives

  write_makefile(makefile)
  #pprint(top)
  #pprint(vlogs)
  #pprint(searchs)
  #pprint(qips)
  #pprint(sdcs)
  #pprint(viips)
  #pprint(sims)

