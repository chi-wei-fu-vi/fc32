#!/usr/bin/env python2.7
import logging
import inspect
from pprint import pprint,pformat
from copy import deepcopy
import os
class xml2uvmcode(object):
  tlm_imps=[
'uvm_blocking_put_imp',
'uvm_nonblocking_put_imp',
'uvm_put_imp',
'uvm_blocking_get_imp',
'uvm_nonblocking_get_imp',
'uvm_get_imp',
'uvm_blocking_peek_imp',
'uvm_nonblocking_peek_imp',
'uvm_peek_imp',
'uvm_blocking_get_peek_imp',
'uvm_nonblocking_get_peek_imp',
'uvm_get_peek_imp',
'uvm_blocking_master_imp',
'uvm_nonblocking_master_imp',
'uvm_master_imp',
'uvm_blocking_slave_imp',
'uvm_nonblocking_slave_imp',
'uvm_slave_imp',
'uvm_blocking_transport_imp',
'uvm_nonblocking_transport_imp',
'uvm_transport_imp',
'uvm_analysis_imp',
]
  uvm_port_fifos=[
'uvm_blocking_put',
'uvm_nonblocking_put',
'uvm_put',
'uvm_blocking_get',
'uvm_nonblocking_get',
'uvm_get',
'uvm_blocking_peek',
'uvm_nonblocking_peek',
'uvm_peek',
'uvm_blocking_get_peek',
'uvm_nonblocking_get_peek',
'uvm_get_peek',
'uvm_blocking_master',
'uvm_nonblocking_master',
'uvm_master',
'uvm_blocking_slave',
'uvm_nonblocking_slave',
'uvm_slave',
'uvm_blocking_transport',
'uvm_nonblocking_transport',
'uvm_transport',
'uvm_analysis',
'uvm_tlm_analysis',
]
  def __init__(self,level):
    """
    """
    self.level=level
    self.tb_qip_files=[]
    self.env2config=set()
    self.envinsthasvif_db=set()
    self.config_db=dict(
)
    self.uvm_custom_db=dict(
uvm_analysis_export=[],
uvm_analysis_imp=[],
uvm_analysis_port=[],
uvm_get_peek_imp=[],
uvm_put_imp=[],
uvm_seq_item_pull_imp=[],
uvm_seq_item_pull_port=[],
uvm_sequencer_arb_mode=[],
uvm_tlm_analysis_fifo=[],
array=[],
integral=[]
)
    self.item4example_seq_db=set()
    self.fpath2name={}
    self.vif_db=dict()
    self.svs=[]
    self.assign_vif_db=dict()
    self.connect_db=dict()
    self.reset_phase_db=dict()
    self.configure_phase_db=dict()
    self.main_phase_db=dict()
    self.shutdown_phase_db=dict()
    self.uvm_inherit_db=dict(
uvm_analysis_export=[],
uvm_analysis_imp=[],
uvm_analysis_port=[],
uvm_get_peek_imp=[],
uvm_put_imp=[],
uvm_seq_item_pull_imp=[],
uvm_seq_item_pull_port=[],
uvm_sequencer_arb_mode=[],
uvm_tlm_analysis_fifo=[],
array=[],
integral=[]
)
    self.uvm_db=dict(
uvm_agent=[],
uvm_component=[],
uvm_driver=[],
uvm_env=[],
uvm_monitor=[],
uvm_sequencer=[],
uvm_subscriber=[],

uvm_reg_predictor=[],
uvm_reg_adapter=[],
uvm_reg_block=[],
uvm_analysis_export=[],
uvm_analysis_imp=[],
uvm_analysis_port=[],
uvm_get_peek_imp=[],
uvm_put_imp=[],
uvm_seq_item_pull_imp=[],
uvm_seq_item_pull_port=[],
uvm_sequencer_arb_mode=[],
uvm_tlm_analysis_fifo=[]
)
    self.uvmtype2callback=dict(
config=self.config_codegen,
uvm_agent=self.uvm_agent_codegen,
uvm_component=self.uvm_component_codegen,
uvm_driver=self.uvm_driver_codegen,
uvm_env=self.uvm_env_codegen,
uvm_monitor=self.uvm_monitor_codegen,
uvm_sequencer=self.uvm_sequencer_codegen,
uvm_subscriber=self.uvm_subscriber_codegen,
uvm_reg_adapter=self.uvm_reg_adapter_codegen,
#uvm_reg_block=None,

uvm_reg_predictor=None,
uvm_analysis_export=None,
uvm_analysis_imp=None,
uvm_analysis_port=None,
uvm_get_peek_imp=None,
uvm_put_imp=None,
uvm_seq_item_pull_imp=None,
uvm_seq_item_pull_port=None,
uvm_sequencer_arb_mode=None,
uvm_tlm_analysis_fifo=None
)
    self.debug_db=set()
    self.paths=set()
    self.insts=set()
    self.uvm_envs=set()
    self.inst2env={}
    self.inst2path={}
    self.inst2seq_item={}
    self.inst2seq_items={}
    self.seq_item2file={}
    self.seq_item2tasks={}
    self.inst2members={}
    self.subdirs=set()
    self.path2file={}
    self.fname2uvmtype={}
    self.if_files=[]         # TBD
    self.seq_files=[]        # TBD
    self.seq_item_files=[]   # TBD
  def readxml(self,fname):
    logger=func_logger(level=self.level)
    obj=xml2dict(coding='utf-8')
    root=obj.readxml(fname)
    if isinstance(obj.root2dict(root),dict):
      self.tree=obj.root2dict(root)
      logger.debug(pformat(self.tree))
  def writecode(self,dname,override=False):
    self.dname=dname
    logger=func_logger(level=self.level)
    if 'vi_testbench' not in self.tree: 
      logger.error("Is not a testbench xml")
      exit(1)
    self.tree=self.tree['vi_testbench']
    if 'uvm_test' not in self.tree: 
      logger.error("Missing uvm test top")
      exot(1)
    self.tree=self.tree['uvm_test']
    testname=self.tree['@type']
    if testname.endswith('_test'):
      bname=testname[:-5]
    elif testname.endswith('test'):
      bname=testname[:-4]
    testpath=os.path.join(self.dname,testname)
    tbpath=os.path.join(self.dname,'%s_tb'%bname)
    thpath=os.path.join(self.dname,'%s_th'%bname)
    runpath=os.path.join(self.dname,'run')
    commonpath=os.path.join(self.dname,'common')
    seq_itemspath=os.path.join(self.dname,'seq_items')
    self.create_testdir(testpath,override)
    uvmpath=os.path.join(self.dname,bname)
    self.create_uvmdir(dname,override)
    self.xref_svh_files(dname)
    self.create_svh_files(dname)
    self.create_config_svh_files(dname)
    self.create_seq_item_svh_files(dname)
    self.create_interface_sv_files(dname)
    self.create_base_test(dname,bname)
    self.create_ex_seq(dname,bname)
    self.create_pkg_files(dname)
    self.create_tbdir(tbpath,bname,override)
    self.create_rundir(runpath,override)
    self.fetch_seq_itemsdir(seq_itemspath,override)
    self.create_commondir(commonpath,override)
    self.tb_qip_files.append(os.path.join('common','common_pkg.sv'))
    self.tb_qip_files.append(os.path.join('common','common_env_pkg.sv'))
    self.tb_qip_files.append(os.path.join('seq_items','seq_items_pkg.sv'))
    self.tb_qip_files.extend(sorted(map(lambda x: x[len(dname)+1:],filter(lambda x: x.endswith('_pkg.sv'),self.fpath2name)),key=lambda x:x.count('/'),reverse=True))
    self.tb_qip_files+=sorted(self.svs,key=lambda x:x.count('/'),reverse=True)
    self.create_test_pkg_file(dname,'%s_test'%bname)
    self.tb_qip_files.append(os.path.join('%s_test'%bname,'%s_test_pkg.sv'%bname))
    self.tb_qip_files.append(os.path.join('%s_tb'%bname,'%s_tb.sv'%bname))
    self.tb_qip_files.append(os.path.join('%s_tb'%bname,'%s_th.sv'%bname))
    tb_qip=os.path.join(self.dname,'tb.qip')
    with open(tb_qip,'w') as fh:
      fh.write('\n'.join(map(lambda x:'set_global_assignment -library "tb" -name VERILOG_FILE [file join $::quartus(qip_path) "%s"]'%x,self.tb_qip_files)))
  def walk_tree(self,tree):
    logger=func_logger(level=self.level)
    def process_item(branch,path,inst,lvl):
      name=''
      typ=''
      size=''
      seq_item=''
      array=0
      if '@name' in branch:
        name=branch['@name']
      else:
        logger.error('missing name attribute for %s'%path)
        exit(1)
      if '@type' in branch:
        typ=branch['@type']
      else:
        logger.error('missing type attribute for %s'%path)
        exit(1)
      if '@size' in branch:
        size=branch['@size']
      else:
        logger.error('missing size attribute for %s'%path)
        exit(1)
      if '@seq_item' in branch:
        seq_item=branch['@seq_item']
      if '@array' in branch:
        array=int(branch['@array'])
      pp=os.path.join(path,typ)
      if inst=='':
        pi='{}'.format(name)
      else:
        pi='{}.{}'.format(inst,name)
      self.paths.add(pp)
      pi_wo_index=pi
      if array>1:
        pi='{}[{}]'.format(pi,array)
      self.insts.add(pi)
      self.inst2members[pi]=set()
      self.inst2path[pi]=pp
      self.inst2seq_item[pi]=seq_item
      if seq_item!='':
        if pi not in self.inst2seq_items:
          self.inst2seq_items[pi]=set()
        self.inst2seq_items[pi].add(seq_item)

      def update_config_db_old(db,branch):
        if isinstance(branch,list):
          for subbranch in branch:
            return
            update_connect_db(db,subbranch)
            update_reset_phase_db(db,subbranch)
            update_configure_phase_db(db,subbranch)
            update_main_phase_db(db,subbranch)
            update_shutdown_phase_db(db,subbranch)
        else:
          if pi not in self.config_db:
            self.config_db[pi]=set()
          if '.' in pi:
            parent=pi[:pi.rfind('.')]
            me=pi[inst.rfind('.')+1:]
            if parent not in self.config_db:
              self.config_db[parent]=set()
            self.config_db[parent].add(pi)
          return
      def update_config_db(db,branch):
        if pi not in db:
          db[pi]=set()
        if isinstance(branch,list):
          map(lambda x: db[pi].add('{}.{}[{}]'.format(pi,x['@name'],x['@array'])) if '@array' in x and int(x['@array']) > 1 else
            db[pi].add('{}.{}'.format(pi,x['@name'])),branch)
        else:
          if '@array' in branch and int(branch['@array'])>1:
            db[pi].add('{}.{}[{}]'.format(pi,branch['@name'],branch['@array']))
          else:
            db[pi].add('{}.{}'.format(pi,branch['@name']))
      def update_uvm_db(clsname,branch):
        if isinstance(branch,list):
          map(lambda x: self.uvm_db[clsname].append('{}.{}[{}]'.format(pi,x['@name'],x['@array'])) if '@array' in x and int(x['@array']) > 1 else
            self.uvm_db[clsname].append('{}.{}'.format(pi,x['@name'])),branch)
          map(lambda x: self.inst2members[pi].add((x['@name'],x['@type'],x['@size'],
               x['@seq_item'] if '@seq_item' in x else '',int(x['@array']))) if '@array' in x and int(x['@array']) > 1 else
            self.inst2members[pi].add((x['@name'],x['@type'],x['@size'],
                                       x['@seq_item'] if '@seq_item' in x else '',1)) ,branch)
          for subbranch in filter(lambda x: '@seq_item' in x,branch):
            if '@array' in subbranch and int(subbranch['@array'])>1:
              subpi='{}.{}[{}]'.format(pi,subbranch['@name'],subbranch['@array'])
              if subpi not in self.inst2seq_items:
                self.inst2seq_items[subpi]=set()
              self.inst2seq_items[subpi].add(subbranch['@seq_item'])
            else:
              subpi='{}.{}'.format(pi,subbranch['@name'])
              if subpi not in self.inst2seq_items:
                self.inst2seq_items[subpi]=set()
              self.inst2seq_items[subpi].add(subbranch['@seq_item'])
        else:
          if '@array' in branch and int(branch['@array'])>1:
            self.uvm_db[clsname].append('{}.{}[{}]'.format(pi,branch['@name'],branch['@array']))
            self.inst2members[pi].add((branch['@name'],branch['@type'],branch['@size'],
                                       branch['@seq_item'] if '@seq_item' in branch else '',int(branch['@array'])))
            if '@seq_item' in branch:
              subpi='{}.{}[{}]'.format(pi,branch['@name'],branch['@array'])
              if subpi not in self.inst2seq_items:
                self.inst2seq_items[subpi]=set()
              self.inst2seq_items[subpi].add(branch['@seq_item'])
          else:
            self.uvm_db[clsname].append('{}.{}'.format(pi,branch['@name']))
            self.inst2members[pi].add((branch['@name'],branch['@type'],branch['@size'],
                                       branch['@seq_item'] if '@seq_item' in branch else '',1))
            if '@seq_item' in branch:
              subpi='{}.{}'.format(pi,branch['@name'])
              if subpi not in self.inst2seq_items:
                self.inst2seq_items[subpi]=set()
              self.inst2seq_items[subpi].add(branch['@seq_item'])
      def update_connect_db(db,branch):
        if isinstance(branch,list):
          for subbranch in branch:
            update_connect_db(db,subbranch)
        else:
          if pi not in db:
            db[pi]=set()
          db[pi].add((branch['@requirer'],branch['@provider']))
          return
          
      def update_reset_phase_db(db,branch):
        if isinstance(branch,list):
          for subbranch in branch:
            update_reset_phase_db(db,subbranch)
        else:
          if pi not in db:
            db[pi]=set()
          db[pi].add((branch['@task'],))
          return
      def update_configure_phase_db(db,branch):
        if isinstance(branch,list):
          for subbranch in branch:
            update_configure_phase_db(db,subbranch)
        else:
          if pi not in db:
            db[pi]=set()
          db[pi].add((branch['@task'],))
          return
      def update_main_phase_db(db,branch):
        if isinstance(branch,list):
          for subbranch in branch:
            update_main_phase_db(db,subbranch)
        else:
          if pi not in db:
            db[pi]=set()
          db[pi].add((branch['@task'],))
          return
      def update_shutdown_phase_db(db,branch):
        if isinstance(branch,list):
          for subbranch in branch:
            update_shutdown_phase_db(db,subbranch)
        else:
          if pi not in db:
            db[pi]=set()
          db[pi].add((branch['@task'],))
          return
      def update_vif_db(db,assign_db,branch):
        if isinstance(branch,list):
          for subbranch in branch:
            update_vif_db(db,subbranch)
        else:
          k=branch['@type']
          if '@array' in branch and int(branch['@array'])>1:
            self.inst2members[pi].add((branch['@name'],branch['@type'],branch['@size'],
                                       branch['@seq_item'] if '@seq_item' in branch else '',int(branch['@array'])))
          else:
            self.inst2members[pi].add((branch['@name'],branch['@type'],branch['@size'],
                                       branch['@seq_item'] if '@seq_item' in branch else '',1))
          if k not in db:
            db[k]=[]
          db[k].append('{}.{}'.format(pi,branch['@name']))
          vif=branch['@name']
          typ=branch['@type']
          if '.' in pi:
            parent=pi[:pi.rfind('.')]
            me=pi[pi.rfind('.')+1:]
            if parent not in assign_db:
              assign_db[parent]=set()
            assign_db[parent].add((me,vif,typ))
          return
          
      def update_uvm_custom_inherit_db(db,branch):
        if isinstance(branch,list):
          for subbranch in branch:
            update_uvm_custom_inherit_db(db,subbranch)
        else:
          k=branch['@type']
          if id(db)==id(self.uvm_custom_db):
            if '@array' in branch and int(branch['@array'])>1:
              self.inst2members[pi].add((branch['@name'],branch['@type'],branch['@size'],
                                         branch['@seq_item'] if '@seq_item' in branch else '',int(branch['@array'])))
              if '@seq_item' in branch:
                subpi='{}.{}[{}]'.format(pi,branch['@name'],branch['@array'])
                if subpi not in self.inst2seq_items:
                  self.inst2seq_items[subpi]=set()
                self.inst2seq_items[subpi].add(branch['@seq_item'])
            else:
              self.inst2members[pi].add((branch['@name'],branch['@type'],branch['@size'],
                                         branch['@seq_item'] if '@seq_item' in branch else '',1))
              if '@seq_item' in branch:
                subpi='{}.{}'.format(pi,branch['@name'])
                if subpi not in self.inst2seq_items:
                  self.inst2seq_items[subpi]=set()
                self.inst2seq_items[subpi].add(branch['@seq_item'])
          if k.startswith('uvm_analysis_export'):
            db['uvm_analysis_export'].append('{}.{}'.format(pi,branch['@name']))
          elif k.startswith('uvm_analysis_imp'):
            db['uvm_analysis_imp'].append('{}.{}'.format(pi,branch['@name']))
          elif k.startswith('uvm_analysis_port'):
            db['uvm_analysis_port'].append('{}.{}'.format(pi,branch['@name']))
          elif k.startswith('uvm_get_peek_imp'):
            db['uvm_get_peek_imp'].append('{}.{}'.format(pi,branch['@name']))
          elif k.startswith('uvm_put_imp'):
            db['uvm_put_imp'].append('{}.{}'.format(pi,branch['@name']))
          elif k.startswith('uvm_seq_item_pull_imp'):
            db['uvm_seq_item_pull_imp'].append('{}.{}'.format(pi,branch['@name']))
          elif k.startswith('uvm_seq_item_pull_port'):
            db['uvm_seq_item_pull_port'].append('{}.{}'.format(pi,branch['@name']))
          elif k=='uvm_sequencer_arb_mode':
            db['uvm_sequencer_arb_mode'].append('{}.{}'.format(pi,branch['@name']))
          elif k.startswith('uvm_tlm_analysis_fifo'):
            db['uvm_sequencer_arb_mode'].append('{}.{}'.format(pi,branch['@name']))
          elif k.startswith('integral'):
            db['integral'].append('{}.{}'.format(pi,branch['@name']))
          elif k.startswith('array'):
            db['array'].append('{}.{}'.format(pi,branch['@name']))
          #elif k.startswith('uvm_reg_predictor'):
          #  db['uvm_reg_predictor'].append('{}.{}'.format(pi,branch['@name']))
          else:
            logger.error('UPDATE SCRIPT TO SUPPORT NEW XML TAG %s'%k)
            exit(1)
          return

      for k,v in branch.items(): 
        subbranch=None
        if k=='@name' or k=='@type' or k=='@size' or k=='@seq_item'or k=='@array':
          pass
        elif k=='@provider' or k=='@requirer':
          pass
        elif k=='inherit':
          subbranch=v 
          update_uvm_custom_inherit_db(self.uvm_inherit_db,subbranch)
          subbranch=None
        elif k=='custom':
          subbranch=v 
          update_uvm_custom_inherit_db(self.uvm_custom_db,subbranch)
          subbranch=None
        elif k=='interface':
          subbranch=v 
          update_vif_db(self.vif_db,self.assign_vif_db,subbranch)
          subbranch=None
        elif k=='connect_phase':
          subbranch=v 
          update_connect_db(self.connect_db,subbranch)
          subbranch=None
        elif k=='reset_phase':
          subbranch=v 
          update_reset_phase_db(self.reset_phase_db,subbranch)
          subbranch=None
        elif k=='configure_phase':
          subbranch=v 
          update_configure_phase_db(self.configure_phase_db,subbranch)
          subbranch=None
        elif k=='main_phase':
          subbranch=v 
          update_main_phase_db(self.main_phase_db,subbranch)
          subbranch=None
        elif k=='shutdown_phase':
          subbranch=v 
          update_shutdown_phase_db(self.shutdown_phase_db,subbranch)
          subbranch=None
        elif k.startswith('uvm_env'):
          subbranch=v 
          if isinstance(subbranch,list):
            map(lambda x: self.uvm_envs.add(x['@type']),subbranch)
            for subsubbranch in subbranch:
              self.inst2env['%s.%s'%(pi,subsubbranch['@name'])]=subsubbranch['@type']
          else:
            self.uvm_envs.add(subbranch['@type'])
            self.inst2env['%s.%s'%(pi,subbranch['@name'])]=subbranch['@type']
          update_uvm_db('uvm_env',subbranch)
          update_config_db(self.config_db,subbranch)
              
        elif k.startswith('uvm_agent'):
          subbranch=v 
          update_uvm_db('uvm_agent',subbranch)
        elif k.startswith('uvm_driver'):
          subbranch=v 
          update_uvm_db('uvm_driver',subbranch)
        elif k.startswith('uvm_monitor'):
          subbranch=v 
          update_uvm_db('uvm_monitor',subbranch)
        elif k.startswith('uvm_component'):
          subbranch=v 
          update_uvm_db('uvm_component',subbranch)
        elif k=='uvm_sequencer':
          subbranch=v 
          update_uvm_db('uvm_sequencer',subbranch)
        elif k.startswith('uvm_subscriber'):
          subbranch=v 
          update_uvm_db('uvm_subscriber',subbranch)
        elif k.startswith('uvm_reg_predictor'):
          subbranch=v 
          update_uvm_db('uvm_reg_predictor',subbranch)
        elif k.startswith('uvm_reg_block'):
          subbranch=v 
          update_uvm_db('uvm_reg_block',subbranch)
        elif k.startswith('uvm_reg_adapter'):
          subbranch=v 
          update_uvm_db('uvm_reg_adapter',subbranch)

        elif k.startswith('uvm_analysis_export'):
          subbranch=v 
          update_uvm_db('uvm_analysis_export',subbranch)
        elif k.startswith('uvm_analysis_imp'):
          subbranch=v 
          update_uvm_db('uvm_analysis_imp',subbranch)
        elif k.startswith('uvm_analysis_port'):
          subbranch=v 
          update_uvm_db('uvm_analysis_port',subbranch)
        elif k.startswith('uvm_get_peek_imp'):
          subbranch=v 
          update_uvm_db('uvm_get_peek_imp',subbranch)
        elif k.startswith('uvm_put_imp'):
          subbranch=v 
          update_uvm_db('uvm_put_imp',subbranch)
        elif k.startswith('uvm_seq_item_pull_imp'):
          subbranch=v 
          update_uvm_db('uvm_seq_item_pull_imp',subbranch)
        elif k=='uvm_seq_item_pull_port':
          subbranch=v 
          update_uvm_db('uvm_seq_item_pull_port',subbranch)
        elif k=='uvm_sequencer_arb_mode':
          subbranch=v 
          update_uvm_db('uvm_sequencer_arb_mode',subbranch)
        elif k=='uvm_tlm_analysis_fifo':
          subbranch=v 
          update_uvm_db('uvm_sequencer_arb_mode',subbranch)
        else:
          logger.error('UPDATE SCRIPT TO SUPPORT NEW XML TAG %s'%k)
          exit(1)
        if subbranch:
          dfs(subbranch,pp,pi,lvl+1) 
      
    def dfs(branch,path,inst,lvl):
      """
      """
      logger.debug('path %s (%s) lvl %d\nbranch %s'%(path,inst,lvl,pformat(branch)[:400]))
      if lvl > 100:
        return
      if isinstance(branch,list):
        logger.debug('branch is a list')
        for f in branch:
          process_item(f,path,inst,lvl)
      elif isinstance(branch,dict):
        logger.debug('branch is a dict')
        process_item(branch,path,inst,lvl)
      else:
        return
    dfs(tree,'','',0)
  def create_testdir(self,path,override):
    logger=func_logger(level=self.level)
    if os.path.exists(path):
      logger.error("%s dir already existed,remove the dir or specify different dir"%path)
      exit(1)
    os.makedirs(path)
    logger.debug("create %s dir"%path)
    self.walk_tree(self.tree)
 
  def create_uvmdir(self,path,override):
    logger=func_logger(level=self.level)
    #if os.path.exists(path):
    #  logger.error("%s dir already existed"%path)
    #  exit(1)
    #os.makedirs(path)
    #logger.debug("create %s dir"%path)
    self.create_uvm_hier()
    for subdir in self.subdirs:
      p=os.path.join(path,subdir)
      if os.path.exists(p):
        logger.debug("%s subdir already existed"%p)
        #exit(1)
      else:
        os.makedirs(p)
      logger.debug("create %s subdir"%p)
     
  def create_uvm_hier(self):
    logger=func_logger(level=self.level)
    for path in self.paths:
      fs=path.split('/') 
      subpath=''
      for f in fs[1:]:
        if '#' in f:
          fpure=f[:f.index('#')].replace(' ','')
        else:
          fpure=f
        if fpure in self.uvm_envs:
          subpath=os.path.join(subpath,fpure.replace('_env',''))
      if '/' in subpath or True:
        self.subdirs.add(subpath)
        if fpure in self.uvm_envs:
          self.path2file[path]=os.path.join(subpath,fpure+'.svh')
        else:
          self.path2file[path]=os.path.join(subpath,fpure+'.svh')
  def get_config_members(self,uvmtype,name,inst):
    if inst !='uvm_test_top' and inst in self.config_db:
      return map(lambda x: (x,os.path.basename(self.inst2path[x]).replace('_env','_config'),x[x.rfind('.')+1:].replace('_env','_config')),self.config_db[inst])
    else:
      return []
  def type_qualify(self,typ):
    if '#' in typ:
      return typ[:typ.index('#')].rstrip()
    else:
      return typ
  def get_port_members(self,uvmtype,name,inst):
    def typ2svtyp(typ):
      if typ=='integral':
        return 'int'
      else:
        return typ
    return '\n'.join(map(lambda x: ('  %-50s %s[%d];'%(typ2svtyp(x[1]),x[0],x[4]) if x[3]=='' else
                                    '  %-50s %s[%d];'%('{}#({})'.format(typ2svtyp(x[1]),x[3]),x[0],x[4]))
                                 if x[4] > 1 else
                                   ('  %-50s %s;'%(typ2svtyp(x[1]),x[0]) if x[3]=='' else
                                    '  %-50s %s;'%('{}#({})'.format(typ2svtyp(x[1]),x[3]),x[0])),
                        filter(lambda x: self.type_qualify(x[1]) not in self.fname2uvmtype,self.inst2members[inst])))
  def get_create_members(self,uvmtype,name,inst):
    return '\n'.join(map(lambda x: '  %-50s %s[%d];'%(x[1],x[0],x[4]) if x[4] > 1 else
                       '  %-50s %s;'%(x[1],x[0]) ,filter(lambda x: self.type_qualify(x[1]) in self.fname2uvmtype,self.inst2members[inst])))

  def get_tlm_imp_members(self,uvmtype,name,inst):
    members=set()
    for name,typ,size,seq_item,array in self.inst2members[inst]:
      if typ.endswith(name) and typ[:-len(name)-1] in xml2uvmcode.tlm_imps:
        members.add((name,typ,size,seq_item,array,typ[:-len(name)-1]))
    decls='\n'.join(map(lambda x: '`%s_decl(_%s)'%(x[5],x[0]),members))
    queues='\n'.join(map(lambda x: '  %-50s %s_q[$];'%(x[3].split(',')[0],x[0]),members))
    writefuncs='\n'.join(map(lambda x: '''  function void write_%(name)s(%(item)s item);
    `uvm_info(get_type_name(),$sformatf("%(name)s item:\\n%%s0s", item.sprint()),UVM_MEDIUM );
    %(name)s_q.push_front( item );
  endfunction : write_%(name)s'''%dict(name=x[0],item=x[3].split(',')[0],),members))
    return decls,queues,writefuncs,members
  def get_inst_port_members(self,uvmtype,name,inst):
    lines=[]
    for name,typ,size,seq_item,array in self.inst2members[inst]:
      typ_q=typ
      if '#' in typ_q: typ_q=typ_q[:typ_q.index('#')].rstrip()
      if '_port' in typ_q: typ_q=typ_q[:-5]
      if '_export' in typ_q: typ_q=typ_q[:-7]
      if '_fifo' in typ_q: typ_q=typ_q[:-5]
      if typ_q not in xml2uvmcode.uvm_port_fifos: continue
      if typ.startswith('virtual '): continue
      if self.type_qualify(typ) not in self.fname2uvmtype:
        if array > 1:
          lines.append('''    foreach(%(name)s[i])
      %(name)s[i]=new($sformatf("%(name)s[%%0d]",i),this);'''%dict(name=name,))
        else:
          lines.append('    %(name)s=new("%(name)s",this);'%dict(name=name))
    passive='\n'.join(lines)
    active=''
    return '''
%(passive)s%(active)s
'''%(dict(
passive=passive,
active=active))
  def get_inst_create_members(self,uvmtype,name,inst):
    lines=[]
    for name,typ,size,seq_item,array in self.inst2members[inst]:
      if self.type_qualify(typ) in self.fname2uvmtype:
        if array > 1:
          lines.append('''    foreach(%(name)s[i])
      %(name)s[i]=%(typ)s::type_id::create($sformatf("%(name)s[%%0d]",i),this);'''%dict(name=name,typ=typ,))
        else:
          lines.append('    %(name)s=%(typ)s::type_id::create("%(name)s",this);'%dict(name=name,typ=typ))
    passive='\n'.join(lines)
    active=''
    return '''
%(passive)s%(active)s
'''%(dict(
passive=passive,
active=active))
  def get_assign_vif(self,uvmtype,name,inst):
    if inst in self.assign_vif_db:
      return '\n'.join(map(lambda x : '    %s.%s = m_config.%s;'%(x[0],x[1],x[1]),self.assign_vif_db[inst]))
    else:
      return ''
  def get_uvm_reg_block_members(self,uvmtype,name,inst):
    return filter(lambda x: self.type_qualify(x[1]) in self.fname2uvmtype and 
       self.fname2uvmtype[self.type_qualify(x[1])] == 'uvm_reg_block',self.inst2members[inst])
  def get_uvm_reg_predictor_members(self,uvmtype,name,inst):
    return filter(lambda x: self.type_qualify(x[1]) in self.fname2uvmtype and 
       self.fname2uvmtype[self.type_qualify(x[1])] == 'uvm_reg_predictor',self.inst2members[inst])
  def get_uvm_reg_adapter_members(self,uvmtype,name,inst):
    return filter(lambda x: self.type_qualify(x[1]) in self.fname2uvmtype and 
       self.fname2uvmtype[self.type_qualify(x[1])] == 'uvm_reg_adapter',self.inst2members[inst])
  
  def get_connect_port(self,uvmtype,name,inst):
    if inst in self.connect_db:
      return '\n'.join(map(lambda x : '    %s.connect(%s);'%x,self.connect_db[inst]))
    else:
      return ''

  def uvm_agent_codegen(self,uvmtype,name,inst):
    decls,queues,writefuncs,decl_members=self.get_tlm_imp_members(uvmtype,name,inst)
    #config_members=self.get_config_members(uvmtype,name,inst)
    config_members=''
    envinst=inst[:inst.rfind('.')]
    if envinst.endswith(']'):
      envinst=inst[:inst.rfind('[')]
    configname=self.inst2env[envinst].replace('_env','_config')
    config_inst='  %-50s m_config;'%(configname)
    port_members=self.get_port_members(uvmtype,name,inst)
    create_members=self.get_create_members(uvmtype,name,inst)
    inst_port_members=self.get_inst_port_members(uvmtype,name,inst)
    inst_create_members=self.get_inst_create_members(uvmtype,name,inst)
    assign_vif=self.get_assign_vif(uvmtype,name,inst)
    connect_port=self.get_connect_port(uvmtype,name,inst)
    return  '''%(decls)s
class %(name)s extends uvm_agent;
  `uvm_component_utils_begin(%(name)s)
%(config_members)s
  `uvm_component_utils_end
%(queues)s
%(port_members)s
%(config_inst)s
%(create_members)s
  function  new(string name, uvm_component parent);
    super.new(name, parent);%(inst_port_members)s
  endfunction : new
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);%(inst_create_members)s
    if (!uvm_config_db #(%(configname)s)::get(this, "", "config", m_config))
      `uvm_error(get_type_name(), "%(configname)s config not found")

  endfunction : build_phase
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
%(assign_vif)s
%(connect_port)s
  endfunction : connect_phase
%(writefuncs)s
endclass : %(name)s'''%dict(name=name,
config_members=config_members,
configname=configname,
config_inst=config_inst,
port_members=port_members,
create_members=create_members,
inst_port_members=inst_port_members,
inst_create_members=inst_create_members,
assign_vif=assign_vif,
connect_port=connect_port,
decls=decls,
queues=queues,
writefuncs=writefuncs,
)
  def uvm_component_codegen(self,uvmtype,name,inst):
    decls,queues,writefuncs,decl_members=self.get_tlm_imp_members(uvmtype,name,inst)
    config_members=''
    port_members=self.get_port_members(uvmtype,name,inst)
    create_members=self.get_create_members(uvmtype,name,inst)
    inst_port_members=self.get_inst_port_members(uvmtype,name,inst)
    return  '''%(decls)s
class %(name)s extends uvm_component;
  `uvm_component_utils_begin(%(name)s)
%(config_members)s
  `uvm_component_utils_end
%(queues)s
%(port_members)s
  function  new(string name, uvm_component parent);
    super.new(name, parent);%(inst_port_members)s
  endfunction : new
%(writefuncs)s
endclass : %(name)s'''%dict(name=name,
config_members=config_members,
port_members=port_members,
inst_port_members=inst_port_members,
decls=decls,
queues=queues,
writefuncs=writefuncs,
)
  def find_seq_item(self,inst):
    seq_item=''
    if '.' in inst:
      parent=inst[:inst.rfind('.')]
      me=inst[inst.rfind('.')+1:]
      if(filter(lambda x: x[0]==me,self.inst2members[parent])):
        seq_item=filter(lambda x: x[0]==me,self.inst2members[parent])[0][3]
    return seq_item
  def uvm_driver_codegen(self,uvmtype,name,inst):
    decls,queues,writefuncs,decl_members=self.get_tlm_imp_members(uvmtype,name,inst)
    seq_item=self.find_seq_item(inst)
    #config_members=self.get_config_members(uvmtype,name,inst)
    config_members=''
    port_members=self.get_port_members(uvmtype,name,inst)
    create_members=self.get_create_members(uvmtype,name,inst)
    inst_port_members=self.get_inst_port_members(uvmtype,name,inst)
    inst_create_members=self.get_inst_create_members(uvmtype,name,inst)
    assign_vif=self.get_assign_vif(uvmtype,name,inst)
    connect_port=self.get_connect_port(uvmtype,name,inst)
    ph_decls,reset_phase=self.get_reset_phase(uvmtype,name,inst)
    if reset_phase!='':
      reset_phase=ph_decls+('    `uvm_info(get_type_name(), "reset_phase", UVM_MEDIUM)'+
                       reset_phase)
    ph_decls,configure_phase=self.get_configure_phase(uvmtype,name,inst)
    if configure_phase!='':
      configure_phase=ph_decls+('    `uvm_info(get_type_name(), "configure_phase", UVM_MEDIUM)'+
                       configure_phase)
    ph_decls,main_phase=self.get_main_phase(uvmtype,name,inst)
    if main_phase!='':
      main_phase=ph_decls+('    `uvm_info(get_type_name(), "main_phase", UVM_MEDIUM)'+
                       main_phase)
    ph_decls,shutdown_phase=self.get_shutdown_phase(uvmtype,name,inst)
    if shutdown_phase!='':
      shutdown_phase=ph_decls+('    `uvm_info(get_type_name(), "shutdown_phase", UVM_MEDIUM)'+
                       shutdown_phase)
    return  '''%(decls)s
class %(name)s extends uvm_driver%(seq_item)s;
  `uvm_component_utils_begin(%(name)s)
%(config_members)s
  `uvm_component_utils_end
%(queues)s
%(port_members)s
%(create_members)s
  function  new(string name, uvm_component parent);
    super.new(name, parent);%(inst_port_members)s
  endfunction : new
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);%(inst_create_members)s
  endfunction : build_phase
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
%(assign_vif)s
%(connect_port)s
  endfunction : connect_phase
%(writefuncs)s
  task reset_phase(uvm_phase phase);
%(reset_phase)s
  endtask : reset_phase
  task configure_phase(uvm_phase phase);
%(configure_phase)s
  endtask : configure_phase
  task main_phase(uvm_phase phase);
%(main_phase)s
  endtask : main_phase
  task shutdown_phase(uvm_phase phase);
%(shutdown_phase)s
  endtask : shutdown_phase
endclass : %(name)s'''%dict(name=name,
seq_item='#(%s)'%seq_item if seq_item else '',
config_members=config_members,
port_members=port_members,
create_members=create_members,
inst_port_members=inst_port_members,
inst_create_members=inst_create_members,
assign_vif=assign_vif,
connect_port=connect_port,
reset_phase=reset_phase,
configure_phase=configure_phase,
main_phase=main_phase,
shutdown_phase=shutdown_phase,
decls=decls,
queues=queues,
writefuncs=writefuncs,
)
  '''
    phase.raise_objection(this);
    `uvm_info(get_type_name(), "main_phase", UVM_MEDIUM)
    forever begin
      seq_item_port.get_next_item(req);
      `uvm_info(get_type_name(), {"req item\n",req.sprint()}, UVM_MEDIUM)
      req.do_drive();
      seq_item_port.item_done();
    end
    phase.raise_objection(this);
'''
  def get_reset_phase(self,uvmtype,name,inst):
    decls=''
    if inst in self.reset_phase_db:
      return decls,'''
    %s;
'''%list(self.reset_phase_db[inst])[0]
    else:
      return decls,''
    
  def get_configure_phase(self,uvmtype,name,inst):
    logger=func_logger(level=self.level)
    decls=''
    if inst in self.configure_phase_db:
      taskarg=typ=list(self.configure_phase_db[inst])[0][0]
      if '::' not in typ:
        logger.error('task format %s is not correct,expect type::task(virtual_if,item)'%taskarg)
        exit(1)
      task=typ[typ.index('::')+2:]
      typ=typ[:typ.index('::')]
      if '(' not in task and not task.endswith(')'):
        logger.error('task format %s is not correct,expect type::task(virtual_if,item)'%taskarg)
        exit(1)
      vif=task[task.index('(')+1:-1]
      task=task[:task.index('(')]
      if ',' not in vif:
        logger.error('task format %s is not correct,expect type::task(virtual_if,item)'%taskarg)
        exit(1)
      item=vif[vif.index(',')+1:]
      vif=vif[:vif.index(',')]
      if uvmtype=='uvm_driver':
        return decls,'''
    forever
    begin
      %(typ)s %(item)s;
      @(vif.master_cb);
      seq_item_port.get_next_item(%(item)s);
      `uvm_info(get_type_name(), {"%(item)s item\\n",%(item)s.sprint()}, UVM_MEDIUM)
      %(item)s.%(task)s(%(vif)s,%(item)s);
      seq_item_port.item_done();
    end
'''%dict(typ=typ,task=task,vif=vif,item=item)
      else:
        return decls,'''
    forever
    begin
      %(typ)s %(item)s;
      @(vif.master_cb);
      %(item)s.%(task)s(%(vif)s,%(item)s);
    end
'''%dict(typ=typ,task=task,vif=vif,item=item)
    else:
      return decls,''
  def get_main_phase(self,uvmtype,name,inst):
    logger=func_logger(level=self.level)
    decls=''
    if inst in self.main_phase_db:
      taskarg=typ=list(self.main_phase_db[inst])[0][0]
      if '::' not in typ:
        logger.error('task format %s is not correct,expect type::task(virtual_if,item)'%taskarg)
        exit(1)
      task=typ[typ.index('::')+2:]
      typ=typ[:typ.index('::')]
      if '(' not in task and not task.endswith(')'):
        logger.error('task format %s is not correct,expect type::task(virtual_if,item)'%taskarg)
        exit(1)
      vif=task[task.index('(')+1:-1]
      task=task[:task.index('(')]
      if ',' not in vif:
        logger.error('task format %s is not correct,expect type::task(virtual_if,item)'%taskarg)
        exit(1)
      item=vif[vif.index(',')+1:]
      vif=vif[:vif.index(',')]
      if uvmtype=='uvm_driver':
        return decls,'''
    forever
    begin
      %(typ)s %(item)s;
      @(vif.master_cb);
      seq_item_port.get_next_item(%(item)s);
      `uvm_info(get_type_name(), {"%(item)s item\\n",%(item)s.sprint()}, UVM_MEDIUM)
      %(item)s.%(task)s(%(vif)s,%(item)s);
      seq_item_port.item_done();
    end
'''%dict(typ=typ,task=task,vif=vif,item=item)
      else:
        return decls,'''
    forever
    begin
      %(typ)s %(item)s;
      @(vif.master_cb);
      %(item)s.%(task)s(%(vif)s,%(item)s);
    end
'''%dict(typ=typ,task=task,vif=vif,item=item)
    else:
      return decls,''
  def get_shutdown_phase(self,uvmtype,name,inst):
    decls=''
    if inst in self.shutdown_phase_db:
      return decls,'''
    %s(vif);
'''%list(self.shutdown_phase_db[inst])[0]
    else:
      return decls,''
  def uvm_env_codegen(self,uvmtype,name,inst):
    decls,queues,writefuncs,decl_members=self.get_tlm_imp_members(uvmtype,name,inst)
    config_members='  %-50s m_config;'%(name.replace('_env','_config'))
    port_members=self.get_port_members(uvmtype,name,inst)
    create_members=self.get_create_members(uvmtype,name,inst)
    inst_port_members=self.get_inst_port_members(uvmtype,name,inst)
    inst_create_members=self.get_inst_create_members(uvmtype,name,inst)
    reg_block_builds=''
    reg_block_connects=''
    for rinst in self.get_uvm_reg_block_members(uvmtype,name,inst):
      reg_block_builds+='    %s.build();\n'%rinst[0]
      reg_block_builds+='    %s.lock_model();\n'%rinst[0]
      reg_block_connects+='''
    %(predictor)s.map     = %(reg_block)s.reg_map;
    %(predictor)s.adapter = %(adapter)s;
    %(reg_block)s.reg_map.set_sequencer( .sequencer( %(agent)s.m_sequencer ), .adapter( %(adapter)s ));
    %(reg_block)s.reg_map.set_auto_predict( .on( 0 ) );
'''%dict(reg_block=rinst[0],
predictor=filter(lambda x: x[0].startswith(rinst),self.get_uvm_reg_predictor_members(uvmtype,name,inst))[0][0], 
adapter=filter(lambda x: x[0].startswith(rinst),self.get_uvm_reg_adapter_members(uvmtype,name,inst))[0][0], 
agent=filter(lambda x: x[1] in self.fname2uvmtype and self.fname2uvmtype[x[1]]=='uvm_agent',self.inst2members[inst])[0][0])
    get_configs='''    if (!uvm_config_db #(%(name)s)::get(this, "", "config", m_config))
      `uvm_error(get_type_name(), "Unable to get %(name)s")
'''%dict(name=name.replace('_env','_config'))
    for rinst in self.get_uvm_reg_block_members(uvmtype,name,inst):
      get_configs+='    m_config.%(reg_block)s = %(reg_block)s;'%dict(
          reg_block=rinst[0])
    set_configs=''
    for envinst,envs in self.config_db.items():
      if envinst==inst:
        for subinst in envs:
          subinst=subinst[subinst.rfind('.')+1:]
          configinst=subinst.replace('_env','_config')
          if '[' in subinst:
            subinst=subinst[:subinst.rfind('[')]
            configinst=subinst.replace('_env','_config')
            set_configs+='''    foreach(%(env)s[i]) begin
      uvm_config_db #(%(type)s)::set(this,$sformatf("%(env)s[%%0d]",i),"config",m_config.%(name)s[i]);
    end
'''%dict(type=configinst[2:],name=configinst,env=subinst,)
          else:
            set_configs+='    uvm_config_db #(%(type)s)::set(this, "%(env)s", "config", m_config.%(name)s);\n'%dict(
type=configinst[2:],name=configinst,env=subinst)
    if set_configs=='':
      for iname,itype,isize,iseq_item,iarray in self.inst2members[inst]:
        if '#' in itype:
          itype=itype[:itype.index('#')].rstrip()
        if itype in self.fname2uvmtype and self.fname2uvmtype[itype] in ['uvm_agent','uvm_subscriber']:
          if iarray > 1:
            set_configs+='''
'''
          else:
            set_configs+='    uvm_config_db #(%(type)s)::set(this, "%(name)s", "config", m_config);\n'%dict(
type=name.replace('_env','_config'),name=iname)
    assign_vif=self.get_assign_vif(uvmtype,name,inst)
    connect_port=self.get_connect_port(uvmtype,name,inst)
    ph_decls,reset_phase=self.get_reset_phase(uvmtype,name,inst)
    if reset_phase!='':
      reset_phase=ph_decls+('    `uvm_info(get_type_name(), "reset_phase", UVM_MEDIUM)'+
                       reset_phase)
    ph_decls,configure_phase=self.get_configure_phase(uvmtype,name,inst)
    if configure_phase!='':
      configure_phase=ph_decls+('    `uvm_info(get_type_name(), "configure_phase", UVM_MEDIUM)'+
                       configure_phase)
    ph_decls,main_phase=self.get_main_phase(uvmtype,name,inst)
    if main_phase!='':
      main_phase=ph_decls+('    `uvm_info(get_type_name(), "main_phase", UVM_MEDIUM)'+
                       main_phase)
    ph_decls,shutdown_phase=self.get_shutdown_phase(uvmtype,name,inst)
    if shutdown_phase!='':
      shutdown_phase=ph_decls+('    `uvm_info(get_type_name(), "shutdown_phase", UVM_MEDIUM)'+
                       shutdown_phase)
    return  '''%(decls)s
class %(name)s extends uvm_env;
  `uvm_component_utils_begin(%(name)s)
  `uvm_component_utils_end
%(queues)s
%(port_members)s
%(create_members)s
%(config_members)s
  function  new(string name="%(name)s", uvm_component parent);
    super.new(name, parent);%(inst_port_members)s
  endfunction : new
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);%(inst_create_members)s
%(get_configs)s
%(set_configs)s
%(reg_block_builds)s
  endfunction : build_phase
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
%(assign_vif)s
%(reg_block_connects)s
%(connect_port)s
  endfunction : connect_phase
%(writefuncs)s
  task reset_phase(uvm_phase phase);
%(reset_phase)s
  endtask : reset_phase
  task configure_phase(uvm_phase phase);
%(configure_phase)s
  endtask : configure_phase
  task main_phase(uvm_phase phase);
%(main_phase)s
  endtask : main_phase
  task shutdown_phase(uvm_phase phase);
%(shutdown_phase)s
  endtask : shutdown_phase
endclass : %(name)s'''%dict(name=name,
config_members=config_members,
port_members=port_members,
create_members=create_members,
inst_port_members=inst_port_members,
inst_create_members=inst_create_members,
reg_block_builds=reg_block_builds,
get_configs=get_configs,
set_configs=set_configs,
assign_vif=assign_vif,
reg_block_connects=reg_block_connects,
connect_port=connect_port,
reset_phase=reset_phase,
configure_phase=configure_phase,
main_phase=main_phase,
shutdown_phase=shutdown_phase,
decls=decls,
queues=queues,
writefuncs=writefuncs,
)
  def config_codegen(self,uvmtype,name,inst):
    config_members=''
    vif_members=''
    create_members=''
    inst_create_members=''
    reg_block_members=''
    if inst!='uvm_test_top':
      if filter(lambda x: x[1].endswith('reg_block'),self.inst2members[inst]):
         
        (rbinst,rbname,_,rbitem,rbarray)=filter(lambda x: x[1].endswith('reg_block'),self.inst2members[inst])[0]
        if self.fname2uvmtype[rbname]=='uvm_reg_block':
          if rbarray > 1:
            reg_block_members='  %(rbname)-50s %(rbinst)s[%(rbarray)s];'%dict(rbname=rbname,rbinst=rbinst,rbarray=rbarray)
          else:
            reg_block_members='  %(rbname)-50s %(rbinst)s;'%dict(rbname=rbname,rbinst=rbinst)
    for agtinst,drvmon in self.assign_vif_db.items():
      envinst=agtinst[:agtinst.rfind('.')]
      self.envinsthasvif_db.add(envinst)   # env instance has vif interface
      if envinst==inst:
        for clsinst,vinst,vtype in drvmon:
          vif_members+='  %-50s %s;\n'%(vtype,vinst) 
          break
    if vif_members!='':
      vif_members+='''  uvm_active_passive_enum                            is_active = UVM_ACTIVE;
  bit                                                coverage_enable;
  bit                                                checks_enable;
'''

    for envinst,clsname,clsinst in self.get_config_members(uvmtype,name,inst):
      config_members+='  %-50s %s;\n'%(clsname,clsinst) 
      if envinst not in self.envinsthasvif_db:
        if '[' in clsinst:
          binst=clsinst[:clsinst.find('[')]
          inst_create_members+='''
      foreach(%(clsinst)s[i]) begin
        %(clsinst)s[i]                 = %(clsname)s::type_id::create($sformatf("%(clsinst)s[%%0d]",i));
      end'''%dict(clsinst=binst,clsname=clsname,)
        else:
          inst_create_members+='''
      %(clsinst)s=%(clsname)s::type_id::create("%(clsinst)s");'''%dict(clsname=clsname,clsinst=clsinst)
      else:
        if '[' in clsinst:
          binst=clsinst[:clsinst.find('[')]
          inst_create_members+='''
      foreach(%(clsinst)s[i]) begin
        %(clsinst)s[i]                 = %(clsname)s::type_id::create($sformatf("%(clsinst)s[%%0d]",i));
        %(clsinst)s[i].is_active       = UVM_ACTIVE;
        %(clsinst)s[i].checks_enable   = 0;
        %(clsinst)s[i].coverage_enable = 0;
      end'''%dict(clsinst=binst,clsname=clsname,)
        else:
          inst_create_members+='''
      %(clsinst)s=%(clsname)s::type_id::create("%(clsinst)s");
      %(clsinst)s.is_active       = UVM_ACTIVE;
      %(clsinst)s.checks_enable   = 0;
      %(clsinst)s.coverage_enable = 0;'''%dict(clsname=clsname,clsinst=clsinst)

    port_members=''
    inst_port_members=''
    assign_vif=self.get_assign_vif(uvmtype,name,inst)
    body_phase=''
    return  '''class %(name)s extends uvm_object;
  `uvm_object_utils(%(name)s)
%(config_members)s
%(vif_members)s
%(reg_block_members)s
  function  new(string name="");
    super.new(name);%(inst_port_members)s
%(inst_create_members)s
  endfunction : new
  task body();
  endtask : body
endclass : %(name)s'''%dict(name=name,
config_members=config_members,
vif_members=vif_members,
reg_block_members=reg_block_members,
port_members=port_members,
inst_port_members=inst_port_members,
inst_create_members=inst_create_members,
assign_vif=assign_vif,
body_phase=body_phase
)
  def uvm_monitor_codegen(self,uvmtype,name,inst):
    decls,queues,writefuncs,decl_members=self.get_tlm_imp_members(uvmtype,name,inst)
    seq_item=self.find_seq_item(inst)
    config_members='\n'.join(self.get_config_members(uvmtype,name,inst))
    port_members=self.get_port_members(uvmtype,name,inst)
    create_members=self.get_create_members(uvmtype,name,inst)
    inst_port_members=self.get_inst_port_members(uvmtype,name,inst)
    inst_create_members=self.get_inst_create_members(uvmtype,name,inst)
    assign_vif=self.get_assign_vif(uvmtype,name,inst)
    connect_port=self.get_connect_port(uvmtype,name,inst)
    ph_decls,reset_phase=self.get_reset_phase(uvmtype,name,inst)
    if reset_phase!='':
      reset_phase=ph_decls+('    `uvm_info(get_type_name(), "reset_phase", UVM_MEDIUM)'+
                       reset_phase)
    ph_decls,configure_phase=self.get_configure_phase(uvmtype,name,inst)
    if configure_phase!='':
      configure_phase=ph_decls+('    `uvm_info(get_type_name(), "configure_phase", UVM_MEDIUM)'+
                       configure_phase)
    ph_decls,main_phase=self.get_main_phase(uvmtype,name,inst)
    if main_phase!='':
      main_phase=ph_decls+('    `uvm_info(get_type_name(), "main_phase", UVM_MEDIUM)'+
                       main_phase)
    ph_decls,shutdown_phase=self.get_shutdown_phase(uvmtype,name,inst)
    if shutdown_phase!='':
      shutdown_phase=ph_decls+('    `uvm_info(get_type_name(), "shutdown_phase", UVM_MEDIUM)'+
                       shutdown_phase)
    return  '''%(decls)s
class %(name)s extends uvm_monitor%(seq_item)s;
  `uvm_component_utils_begin(%(name)s)
%(config_members)s
  `uvm_component_utils_end
%(queues)s
%(port_members)s
%(create_members)s
  function  new(string name="%(name)s", uvm_component parent);
    super.new(name, parent);%(inst_port_members)s
  endfunction : new
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);%(inst_create_members)s
  endfunction : build_phase
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
%(assign_vif)s
%(connect_port)s
  endfunction : connect_phase
%(writefuncs)s
  task reset_phase(uvm_phase phase);
%(reset_phase)s
  endtask : reset_phase
  task configure_phase(uvm_phase phase);
%(configure_phase)s
  endtask : configure_phase
  task main_phase(uvm_phase phase);
%(main_phase)s
  endtask : main_phase
  task shutdown_phase(uvm_phase phase);
%(shutdown_phase)s
  endtask : shutdown_phase
endclass : %(name)s'''%dict(name=name,
seq_item='#(%s)'%seq_item if seq_item else '',
config_members=config_members,
port_members=port_members,
create_members=create_members,
inst_port_members=inst_port_members,
inst_create_members=inst_create_members,
assign_vif=assign_vif,
connect_port=connect_port,
reset_phase=reset_phase,
configure_phase=configure_phase,
main_phase=main_phase,
shutdown_phase=shutdown_phase,
decls=decls,
queues=queues,
writefuncs=writefuncs,
)
  def uvm_reg_block_codegen(self,path,uvmtype,name,inst): # to be implemented
    logger=func_logger(level=self.level)
    logger.debug("inst %s name %s path %s"%(inst,name,self.inst2path[inst]))
    fpath=self.path2file[self.inst2path[inst]]
    fdir=os.path.dirname(fpath)
    fname=os.path.basename(fpath)
    ralpath=os.path.join(fdir,'ral')
    os.makedirs(os.path.join(path,ralpath))
    fpath=os.path.join(path,os.path.join(ralpath,fname))
    codes='''class %(name)s extends uvm_reg_block;
  `uvm_object_utils( %(name)s )
  // register blocks
  uvm_reg_map reg_map;

  //---------------------------------------------------------------------------
  // Function: new
  //---------------------------------------------------------------------------

  function new( string name = "%(name)s" );
    super.new( .name( name ), .has_coverage( UVM_CVR_ADDR_MAP /*UVM_NO_COVERAGE*/ ) );
  endfunction: new

   //---------------------------------------------------------------------------
   // Function: build
   //---------------------------------------------------------------------------

  virtual function void build();
    reg_map = create_map( .name( "reg_map" ), .base_addr( 0 ), .n_bytes( 8 ),
                          .endian( UVM_LITTLE_ENDIAN ), .byte_addressing( 1 ) );
  endfunction: build
endclass: %(name)s'''%dict(name=name)
    self.path2file[self.inst2path[inst]]=fpath
    self.fpath2name[fpath]=name
    with open(fpath,'w') as fh:
          fh.write('''`ifndef %(name)s__SVH
`define %(name)s__SVH
%(codes)s
`endif // %(name)s__SVH
'''%dict(name=name.upper(),codes=codes))
  def uvm_reg_adapter_codegen(self,uvmtype,name,inst):
    logger=func_logger(level=self.level)
    seq_item=self.find_seq_item(inst)
    return  '''class %(name)s extends uvm_reg_adapter;
  `uvm_object_utils(%(name)s)

  function new(string name = "");
     super.new(name);
  endfunction : new

  function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    %(seq_item)s m_item = %(seq_item)s::type_id::create("m_item");
/*    
    m_item.addr = rw.addr;
    if (rw.kind == UVM_READ) begin
      m_item.kind = %(seq_item)s::MM_READ;
    end
    else begin
      m_item.kind = %(seq_item)s::MM_WRITE;
      m_item.data = rw.data;
    end
    `uvm_info(get_type_name(), $sformatf("trans2bus rw::kind: %%s, addr: %%d, data: %%h, status: %%s", rw.kind, rw.addr, rw.data, rw.status), UVM_HIGH)
*/
    return m_item;
  endfunction : reg2bus


  function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
    %(seq_item)s m_item;
    if (!$cast(m_item, bus_item))
      `uvm_fatal(get_type_name(),"Provided bus_item is not of the correct type")
/*
    if (m_item.kind == %(seq_item)s::MM_READ) begin
      rw.kind   = UVM_READ;
    end
    else begin
      rw.kind   = UVM_WRITE;
    end
    rw.addr   = m_item.addr;
    rw.data   = m_item.data;
    rw.status = UVM_IS_OK;
    `uvm_info(get_type_name(), $sformatf("bus2reg rw::kind: %%s, addr: %%d, data: %%h, status: %%s", rw.kind, rw.addr, rw.data, rw.status), UVM_HIGH)
*/
  endfunction : bus2reg
endclass : %(name)s'''%dict(name=name,seq_item=seq_item,)
  def uvm_sequencer_codegen(self,uvmtype,name,inst):
    seq_item=self.find_seq_item(inst)
    #config_members=self.get_config_members(uvmtype,name,inst)
    config_members=''
    port_members=self.get_port_members(uvmtype,name,inst)
    create_members=self.get_create_members(uvmtype,name,inst)
    inst_port_members=self.get_inst_port_members(uvmtype,name,inst)
    inst_create_members=self.get_inst_create_members(uvmtype,name,inst)
    assign_vif=self.get_assign_vif(uvmtype,name,inst)
    connect_port=self.get_connect_port(uvmtype,name,inst)
    ph_decls,reset_phase=self.get_reset_phase(uvmtype,name,inst)
    if reset_phase!='':
      reset_phase=ph_decls+('    `uvm_info(get_type_name(), "reset_phase", UVM_MEDIUM)'+
                       reset_phase)
    ph_decls,configure_phase=self.get_configure_phase(uvmtype,name,inst)
    if configure_phase!='':
      configure_phase=ph_decls+('    `uvm_info(get_type_name(), "configure_phase", UVM_MEDIUM)'+
                       configure_phase)
    ph_decls,main_phase=self.get_main_phase(uvmtype,name,inst)
    if main_phase!='':
      main_phase=ph_decls+('    `uvm_info(get_type_name(), "main_phase", UVM_MEDIUM)'+
                       main_phase)
    ph_decls,shutdown_phase=self.get_shutdown_phase(uvmtype,name,inst)
    if shutdown_phase!='':
      ph_shutdown_phase=ph_decls+('    `uvm_info(get_type_name(), "shutdown_phase", UVM_MEDIUM)'+
                       shutdown_phase)
    return  '''class %(name)s extends uvm_sequencer%(seq_item)s;
  `uvm_component_utils_begin(%(name)s)
%(config_members)s
  `uvm_component_utils_end
%(port_members)s
%(create_members)s
  function  new(string name="%(name)s", uvm_component parent);
    super.new(name, parent);%(inst_port_members)s
  endfunction : new
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);%(inst_create_members)s
  endfunction : build_phase
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
%(assign_vif)s
%(connect_port)s
  endfunction : connect_phase
  task reset_phase(uvm_phase phase);
%(reset_phase)s
  endtask : reset_phase
  task configure_phase(uvm_phase phase);
%(configure_phase)s
  endtask : configure_phase
  task main_phase(uvm_phase phase);
%(main_phase)s
  endtask : main_phase
  task shutdown_phase(uvm_phase phase);
%(shutdown_phase)s
  endtask : shutdown_phase
endclass : %(name)s'''%dict(name=name,
seq_item='#(%s)'%(seq_item if seq_item else 'uvm_sequence_item'),
config_members=config_members,
port_members=port_members,
create_members=create_members,
inst_port_members=inst_port_members,
inst_create_members=inst_create_members,
assign_vif=assign_vif,
connect_port=connect_port,
reset_phase=reset_phase,
configure_phase=configure_phase,
main_phase=main_phase,
shutdown_phase=shutdown_phase,
)
  def uvm_subscriber_codegen(self,uvmtype,name,inst):
    parent=inst[:inst.rfind('.')]
    decls,queues,writefuncs,decl_members=self.get_tlm_imp_members(uvmtype,name,inst)
    seq_item=self.find_seq_item(inst)
    writefuncs+='''  function void write(%(seq_item)s t );
    m_item = t;
    if (m_config.coverage_enable)
    begin
      m_cov.sample();
      // Check coverage - could use m_cov.option.goal instead of 100 if your simulator supports it
      if (m_cov.get_inst_coverage() >= 100) m_is_covered = 1;
    end
  endfunction : write'''%dict(seq_item=seq_item)
    item_members='  %(seq_item)-50s m_item;'%dict(seq_item=seq_item)
    config_members=''
    envinst,configinst,fpath=filter(lambda x: x[0]==parent,self.env2config)[0]
    if envinst.endswith(']'): envinst=envinst[:envinst.rfind('[')]
    envtyp=self.inst2env[envinst]
    config_members='  %(envtyp)-50s m_config;'%dict(envtyp=envtyp.replace('_env','_config'))
    port_members=self.get_port_members(uvmtype,name,inst)
    create_members=self.get_create_members(uvmtype,name,inst)
    inst_port_members=self.get_inst_port_members(uvmtype,name,inst)
    inst_create_members='''
    if (!uvm_config_db #(%(envtyp)s)::get(this, "", "config", m_config))
      `uvm_error(get_type_name(), "%(envtyp)s config not found")
'''%dict(envtyp=envtyp.replace('_env','_config'))
    assign_vif=self.get_assign_vif(uvmtype,name,inst)
    connect_port=self.get_connect_port(uvmtype,name,inst)
    return  '''%(decls)s
class %(name)s extends uvm_subscriber%(seq_item)s;
  `uvm_component_utils_begin(%(name)s)
  `uvm_component_utils_end
%(config_members)s
  bit                                                m_is_covered;
%(queues)s
%(port_members)s
%(create_members)s
%(item_members)s
  covergroup m_cov;
    option.per_instance = 1;
  endgroup
  function  new(string name="%(name)s", uvm_component parent);
    super.new(name, parent);%(inst_port_members)s
    m_is_covered = 0;
    m_cov=new();
  endfunction : new
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);%(inst_create_members)s
  endfunction : build_phase
%(writefuncs)s
  function void report_phase(uvm_phase phase);
    if (m_config.coverage_enable)
      `uvm_info(get_type_name(), $sformatf("Coverage score = %%3.1f%%%%", m_cov.get_inst_coverage()), UVM_MEDIUM)
    else
      `uvm_info(get_type_name(), "Coverage disabled for this agent", UVM_MEDIUM)
  endfunction : report_phase
endclass : %(name)s'''%dict(name=name,
seq_item='#(%s)'%seq_item if seq_item else '',
config_members=config_members,
port_members=port_members,
create_members=create_members,
item_members=item_members,
inst_create_members=inst_create_members,
inst_port_members=inst_port_members,
decls=decls,
queues=queues,
writefuncs=writefuncs,
)
  def xref_codegen(self,name,inst):
    logger=func_logger(level=self.level)
    codegen_callback=None
    for uvmtype,insts in self.uvm_db.items():
      if inst in insts:
        self.fname2uvmtype[name]=uvmtype
        break
    
  def xref_svh_files(self,path):
    logger=func_logger(level=self.level)
    for p,f in self.path2file.items():
      fpath=os.path.join(path,f)
      inst=next((k for k, v in self.inst2path.items() if v == p), None)
      logger.debug("path %s file %s inst %s"%(p,f,inst))
      if not os.path.exists(fpath):
        bname=os.path.splitext(os.path.basename(fpath))[0]
        self.xref_codegen(bname,inst)
    
  def codegen(self,name,inst):
    logger=func_logger(level=self.level)
    codegen_callback=None
    for uvmtype,insts in self.uvm_db.items():
      if inst in insts:
        codegen_callback=self.uvmtype2callback[uvmtype]
        break
    if not codegen_callback:
      logger.error('could not find uvm type for instance %s'%inst)
      exit(1)
    return codegen_callback(uvmtype,name,inst)
    
  def create_svh_files(self,path):
    logger=func_logger(level=self.level)
    for p,f in self.path2file.items():
      fpath=os.path.join(path,f)
      inst=next((k for k, v in self.inst2path.items() if v == p), None)
      if inst in self.config_db:
        self.env2config.add((inst,inst.replace('env','config'),fpath.replace('env.svh','config.svh')))
      for parent,children in self.config_db.items():
        if inst in children:
          self.env2config.add((inst,inst.replace('env','config'),fpath.replace('env.svh','config.svh')))
    for p,f in self.path2file.items():
      fpath=os.path.join(path,f)
      inst=next((k for k, v in self.inst2path.items() if v == p), None)
      seq_item=self.inst2seq_item[inst]
      logger.debug("path %s file %s inst %s"%(p,f,inst))
      if not os.path.exists(fpath):
        bname=os.path.splitext(os.path.basename(fpath))[0]
        if inst=='uvm_test_top':continue
        if self.fname2uvmtype[bname]=='uvm_reg_predictor':
          continue
        if self.fname2uvmtype[bname]=='uvm_reg_block':
          self.uvm_reg_block_codegen(path,'uvm_reg_block',bname,inst)
          continue
        codes=self.codegen(bname,inst)
        self.fpath2name[fpath]=bname
        with open(fpath,'w') as fh:
          fh.write('''`ifndef %(bname)s__SVH
`define %(bname)s__SVH
%(codes)s
`endif // %(bname)s__SVH
'''%dict(bname=bname.upper(),codes=codes))
  def create_config_svh_files(self,path):
    logger=func_logger(level=self.level)
    for env_inst,config_inst,fpath in self.env2config:
      logger.debug("path %s inst %s"%(fpath,config_inst))
      if not os.path.exists(fpath):
        bname=os.path.splitext(os.path.basename(fpath))[0]
        codegen_callback=self.uvmtype2callback['config']
        if not codegen_callback:
          logger.error('could not find uvm type for instance %s'%inst)
          exit(1)
        codes=codegen_callback('config',bname,env_inst)
        self.fpath2name[fpath]=bname
        if bname in self.fname2uvmtype: continue
        with open(fpath,'w') as fh:
          fh.write('''`ifndef %(bname)s__SVH
`define %(bname)s__SVH
%(codes)s
`endif // %(bname)s__SVH
'''%dict(bname=bname.upper(),codes=codes))
  def create_seq_item_svh_files(self,path):
    logger=func_logger(level=self.level)
    for inst,items in self.inst2seq_items.items():
      if inst not in self.inst2path:
        inst=inst[:inst.rfind('.')]
      p=self.inst2path[inst]
      f=self.path2file[p] 
      for item in items:
        if ',' in item: item=item.split(',')[0]
        fpath=os.path.join(path,os.path.join(os.path.dirname(f),'%s.svh'%item))
      self.seq_item2file[item]=fpath
    for inst,tasks in self.reset_phase_db.items():
      if inst in self.inst2members:
        viftype=filter(lambda x: x[0]=='vif',self.inst2members[inst])[0][1]
      for task in tasks:
        task=task[0]
        #self.debug_db.add((inst,task,viftype))
        if '::' in task:
          item=task[:task.index('::')]
          task=task[task.index('::')+2:]
          args=task[task.index('(')+1:-1].split(',')
          task=task[:task.index('(')]
          if item not in self.seq_item2tasks:
            self.seq_item2tasks[item]=set()
          if len(args)==2: # imply vif and item
            self.seq_item2tasks[item].add((task,((viftype,args[0]),(item,args[1]),)))
          elif len(args)==1: # imply vif
            self.seq_item2tasks[item].add((task,((viftype,args[0]),)))
          else: # not supported
            logger.error('could not find uvm type for instance %s'%inst)
            
    for inst,tasks in self.configure_phase_db.items():
      if inst in self.inst2members:
        viftype=filter(lambda x: x[0]=='vif',self.inst2members[inst])[0][1]
      for task in tasks:
        task=task[0]
        #self.debug_db.add((inst,task,viftype))
        if '::' in task:
          item=task[:task.index('::')]
          task=task[task.index('::')+2:]
          args=task[task.index('(')+1:-1].split(',')
          task=task[:task.index('(')]
          if item not in self.seq_item2tasks:
            self.seq_item2tasks[item]=set()
          if len(args)==2: # imply vif and item
            self.seq_item2tasks[item].add((task,((viftype,args[0]),(item,args[1]),)))
          elif len(args)==1: # imply vif
            self.seq_item2tasks[item].add((task,((viftype,args[0]),)))
          else: # not supported
            logger.error('could not find uvm type for instance %s'%inst)
    for inst,tasks in self.main_phase_db.items():
      if inst in self.inst2members:
        viftype=filter(lambda x: x[0]=='vif',self.inst2members[inst])[0][1]
      for task in tasks:
        task=task[0]
        #self.debug_db.add((inst,task,viftype))
        if '::' in task:
          item=task[:task.index('::')]
          task=task[task.index('::')+2:]
          args=task[task.index('(')+1:-1].split(',')
          task=task[:task.index('(')]
          if item not in self.seq_item2tasks:
            self.seq_item2tasks[item]=set()
          if len(args)==2: # imply vif and item
            self.seq_item2tasks[item].add((task,((viftype,args[0]),(item,args[1]),)))
          elif len(args)==1: # imply vif
            self.seq_item2tasks[item].add((task,((viftype,args[0]),)))
          else: # not supported
            logger.error('could not find uvm type for instance %s'%inst)
    for inst,tasks in self.shutdown_phase_db.items():
      if inst in self.inst2members:
        viftype=filter(lambda x: x[0]=='vif',self.inst2members[inst])[0][1]
      for task in tasks:
        task=task[0]
        #self.debug_db.add((inst,task,viftype))
        if '::' in task:
          item=task[:task.index('::')]
          task=task[task.index('::')+2:]
          args=task[task.index('(')+1:-1].split(',')
          task=task[:task.index('(')]
          if item not in self.seq_item2tasks:
            self.seq_item2tasks[item]=set()
          if len(args)==2: # imply vif and item
            self.seq_item2tasks[item].add((task,((viftype,args[0]),(item,args[1]),)))
          elif len(args)==1: # imply vif
            self.seq_item2tasks[item].add((task,((viftype,args[0]),)))
          else: # not supported
            logger.error('could not find uvm type for instance %s'%inst)
    for item,fpath in self.seq_item2file.items():
       port_members=''
       config_members=''
       constraint_members=''
       funcs='''
  function void do_copy(uvm_object rhs);
    %(item)s rhs_;
    if (!$cast(rhs_, rhs))
      `uvm_fatal(get_type_name(), "Cast of rhs object failed")
  endfunction : do_copy


  function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    %(item)s rhs_;
    if (!$cast(rhs_, rhs))
      `uvm_fatal(get_type_name(), "Cast of rhs object failed")
    comparer.result = 1;
    do_compare = 1;
  endfunction : do_compare
/*
  function void do_print(uvm_printer printer);
    if (printer.knobs.sprint == 0)
      `uvm_info(get_type_name(), convert2string(), UVM_MEDIUM)
    else
      printer.m_string = convert2string();
  endfunction : do_print
*/

  function void do_record(uvm_recorder recorder);
    super.do_record(recorder);
  endfunction : do_record

  function void do_pack(uvm_packer packer);
    super.do_pack(packer);
  endfunction : do_pack

  function void do_unpack(uvm_packer packer);
    super.do_unpack(packer);
  endfunction : do_unpack
  function string convert2string();
    string s;
    $sformat(s, "%%s\\n", super.convert2string());
    return s;
  endfunction : convert2string
'''%dict(item=item,)
       tasks=''
       if item in self.seq_item2tasks:
         tasks='\n'.join(map(lambda x: '''  static task %(name)s(%(args)s);
  endtask
'''%dict(name=x[0],args=','.join(map(lambda y: '%s %s'%y,x[1]))),self.seq_item2tasks[item]))
       if port_members=='':
         port_members='''
  typedef enum {PUSH_A,PUSH_B,ADD,SUB,MUL,DIV,POP_C} inst_t;  // delete
  rand inst_t inst; // delete'''
         config_members='''    `uvm_field_enum(inst_t,inst, UVM_ALL_ON)       // delete'''
         self.item4example_seq_db.add(item)

       codes='''class %(item)s extends uvm_sequence_item;
%(port_members)s
%(constraint_members)s
  `uvm_object_utils_begin(%(item)s)
%(config_members)s
  `uvm_object_utils_end
  function new(string name="");
    super.new(name);
  endfunction : new
%(funcs)s
%(tasks)s
endclass : %(item)s'''%dict(item=item,
port_members=port_members,
constraint_members=constraint_members,
config_members=config_members,
funcs=funcs,
tasks=tasks,
)
       self.fpath2name[fpath]=item
       with open(fpath,'w') as fh:
         fh.write('''`ifndef %(item)s__SVH
`define %(item)s__SVH
%(codes)s
`endif // %(item)s__SVH
'''%(dict(item=item.upper(),codes=codes)))
    
  def create_interface_sv_files(self,path):
    logger=func_logger(level=self.level)
    def dfs(inst,lvl):
      if lvl > 100:
        return inst
      if inst.endswith('_env'):
        return inst
      elif inst.endswith(']'):
        tinst=inst[:inst.rfind('[')]
        if tinst.endswith('_env'):
          return inst
      else:
        lvl+=1
        return dfs(inst[:inst.rfind('.')],lvl)
    for vif,insts in self.vif_db.items():
      if_name=vif.split()[1]
      vinst=dfs(insts[0],0)
      fdir=os.path.dirname(self.path2file[self.inst2path[vinst]])
      fpath=os.path.join(path,os.path.join(fdir,if_name+'.sv'))
      codes='''interface %(if_name)s(input bit clk);
  timeunit      1ns;
  timeprecision 1ns;

  import common_pkg::*;
  import common_env_pkg::*;

  //Master Clocking block - used for Drivers
  clocking master_cb @(posedge clk);
    default input #1step output #1step;
    //output pushbutton;
  endclocking: master_cb

  //Slave Clocking Block - used for any Slave BFMs
  clocking slave_cb @(posedge clk);
    default input #1step output #1step;
  endclocking: slave_cb

  //Monitor Clocking block - For sampling by monitor components
  clocking monitor_cb @(posedge clk);
    default input #1step output #1step;
    //input led;
  endclocking: monitor_cb

  modport master(clocking master_cb);
  modport slave(clocking slave_cb);
  modport monitor(clocking monitor_cb);
endinterface : %(if_name)s'''%dict(if_name=if_name) 
      self.fpath2name[fpath]=if_name
      with open(fpath,'w') as fh:
         fh.write('''`ifndef %(if_name)s__SVH
`define %(if_name)s__SV
%(codes)s
`endif // %(if_name)s__SV
'''%(dict(if_name=if_name.upper(),codes=codes)))
      
  def create_pkg_files(self,path):
    logger=func_logger(level=self.level)
    dirs=set()
    for fpath in self.path2file.values():
      dirs.add(os.path.dirname(fpath))
    self.svs=[]
    for dpath in dirs:
      svhs=[]
      subdirs=[]
      if dpath=='': continue
      fdir=os.path.join(path,dpath)
      for fname in os.listdir(fdir):
        if fname.endswith('svh'):
          svhs.append(fname)
        elif fname.endswith('sv'):
          self.svs.append(os.path.join(dpath,fname))
        else:
          subdirs.append(fname)
      imports='\n'.join(map(lambda x: '  import %s_pkg::*;'%x,subdirs))
      decls='\n'.join(map(lambda x: '\n'.join(map(lambda y: '  typedef class %s;'%y,self.fpath2name[x]))
          if isinstance(self.fpath2name[x],list) else '  typedef class %s;'%self.fpath2name[x]
         ,map(lambda x: os.path.join(fdir,x),svhs)))
      includes='\n'.join(map(lambda x: '  `include "%s"'%x,svhs))
      pkgname='%s_pkg'%os.path.basename(dpath)
      fpath=os.path.join(fdir,'%s.sv'%pkgname)
      self.fpath2name[fpath]=pkgname
      with open(fpath,'w') as fh:
        fh.write('''package %(pkgname)s;
  `include "uvm_macros.svh"
  import uvm_pkg::*;

  import common_pkg::*;
  import common_env_pkg::*;
%(imports)s
%(decls)s
%(includes)s
endpackage : %(pkgname)s'''%dict(pkgname=pkgname,
imports=imports,
decls=decls,
includes=includes))

  def create_test_pkg_file(self,path,dpath):
    logger=func_logger(level=self.level)
    dirs=set()
    svhs=[]
    subdirs=[]
    fdir=os.path.join(path,dpath)
    for fname in os.listdir(fdir):
      if fname.endswith('svh'):
        svhs.append(fname)
      else:
        subdirs.append(fname)
    imports='\n'.join(map(lambda x: '  import %s::*;'%x,filter(lambda x:x.endswith('_pkg'),filter(lambda x: not isinstance(x,list),self.fpath2name.values()))))
    if subdirs:
      imports+='\n'+'\n'.join(map(lambda x: '  import %s::*;'%x,subdirs))
    decls='\n'.join(map(lambda x: '\n'.join(map(lambda y: '  typedef class %s;'%y,self.fpath2name[x]))
          if isinstance(self.fpath2name[x],list) else '  typedef class %s;'%self.fpath2name[x]
         ,map(lambda x: os.path.join(fdir,x),svhs)))
    includes='\n'.join(map(lambda x: '  `include "%s"'%x,svhs))
    pkgname='%s_pkg'%os.path.basename(dpath)
    fpath=os.path.join(fdir,'%s.sv'%pkgname)
    self.fpath2name[fpath]=pkgname
    with open(fpath,'w') as fh:
      fh.write('''package %(pkgname)s;
  `include "uvm_macros.svh"
  import uvm_pkg::*;

  import common_pkg::*;
  import common_env_pkg::*;
%(imports)s
%(decls)s
%(includes)s
endpackage : %(pkgname)s'''%dict(pkgname=pkgname,
imports=imports,
decls=decls,
includes=includes))
  def get_top_seq_in_given_phase(self,phase_db):
    logger=func_logger(level=self.level)
    def slicepath(path,slices,lvl):
      if lvl > 100:
        slices.append((path,1))
        return
      if path=='':
        return
      if '[' in path:
        slices.append((path[:path.index('[')], int(path[path.index('[')+1:path.index(']')])))
        lvl+=1
        slicepath(path[path.index(']')+1:],slices,lvl)
      else:
        slices.append((path,1))
        return
    contents=''
    decls=''
    for inst in phase_db:
      if not inst.endswith('_driver'): continue
      func,=next(iter(phase_db[inst]))
      item=func.split('::')[0]
      sqrinst=inst.replace('_driver','_sequencer')
      if sqrinst.startswith('uvm_test_top.'):
        sqrinst=sqrinst[13:]
      logger.debug("isnt %s func %s item %s sqrinst %s"%(inst,func,item,sqrinst))
      slices=[]
      slicepath(sqrinst,slices,0)
      if len(slices)==1 and slices[0][1]==1:
        contents+='    m_seq_%(item)s=seq_%(item)s::type_id::create("m_seq_%(item)s");\n'%dict(item=item,sqrinst=sqrinst)
        contents+='    m_seq_%(item)s.start(%(sqrinst)s);\n'%dict(item=item,sqrinst=sqrinst)
        decls+='    seq_%(item)-30s m_seq_%(item)s;\n'%dict(item=item)
      else:
        npath=''
        idx=''
        idx_fmt=''
        idx_list=[]
        hidx=''
        tabcnt=0;
        forloops=''
        for i,(pslice,array) in enumerate(slices):
          if array > 1:
            forloops+='    %(tab)sfor(int i%(i)s=0;i%(i)s < %(array)s;i%(i)s++)\n'%dict(tab='  '*tabcnt,i=i,array=array)
            npath+='%s[i%d]'%(pslice,i)
            idx+='[i%d]'%i
            idx_fmt+='[%0d]'
            idx_list.append('i%d'%i)
            hidx+='[%d]'%array
            tabcnt+=1;
          else:
            npath+=pslice
        contents+=forloops
        contents+='    %(tab)sm_seq_%(item)s%(idx)s=seq_%(item)s::type_id::create($sformatf("m_seq_%(item)s%(idx_fmt)s",%(idx_list)s));\n'%dict(tab='  '*tabcnt,npath=npath,idx=idx,idx_fmt=idx_fmt,idx_list=','.join(idx_list),item=item)
        contents+=forloops
        contents+='    %(tab)sm_seq_%(item)s%(idx)s.start(%(npath)s);\n'%dict(tab='  '*tabcnt,npath=npath,idx=idx,item=item)
        decls+='    seq_%(item)-30s m_seq_%(item)s %(hidx)s;\n'%dict(item=item,hidx=hidx)
    return decls,contents
  def create_base_test(self,path,bname):
    fpath=os.path.join(path,'%s_test/base_test.svh'%bname)
    self.fpath2name[fpath]='base_test'
    reset_phase_decl=''
    reset_phase=''
    # no need to have sequence support in reset phase
    #reset_phase_decl,reset_phase=self.get_top_seq_in_given_phase(self.reset_phase_db)
    if reset_phase!='':
      reset_phase='''    phase.raise_objection(this);
    `uvm_info(get_type_name(), "reset_phase", UVM_MEDIUM)\n'''+reset_phase
      reset_phase+='    phase.drop_objection(this);\n'
    reset_phase=reset_phase_decl+reset_phase
    configure_phase_decl=''
    configure_phase=''
    configure_phase_decl,configure_phase=self.get_top_seq_in_given_phase(self.configure_phase_db)
    if configure_phase!='':
      configure_phase='''    phase.raise_objection(this);
    `uvm_info(get_type_name(), "configure_phase", UVM_MEDIUM)\n'''+configure_phase
      configure_phase+='    phase.drop_objection(this);\n'
    configure_phase=configure_phase_decl+configure_phase
    main_phase_decl=''
    main_phase=''
    main_phase_decl,main_phase=self.get_top_seq_in_given_phase(self.main_phase_db)
    if main_phase!='':
      main_phase='''    phase.raise_objection(this);
    `uvm_info(get_type_name(), "main_phase", UVM_MEDIUM)\n'''+main_phase
      main_phase+='    phase.drop_objection(this);\n'
    main_phase=main_phase_decl+main_phase
    shutdown_phase_decl=''
    shutdown_phase=''
    shutdown_phase_decl,shutdown_phase=self.get_top_seq_in_given_phase(self.shutdown_phase_db)
    if shutdown_phase!='':
      shutdown_phase='''    phase.raise_objection(this);
    `uvm_info(get_type_name(), "shutdown_phase", UVM_MEDIUM)\n'''+shutdown_phase
      shutdown_phase+='    phase.drop_objection(this);\n'
    shutdown_phase=shutdown_phase_decl+shutdown_phase
    with open(fpath,'w') as fh:
      fh.write('''
`ifndef BASE_TEST__SVH
`define BASE_TEST__SVH
class base_test extends uvm_test;
  `uvm_component_utils(base_test)

  %(bname)s_env m_%(bname)s_env;

  function new(string name="base_test", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    uvm_reg::include_coverage("*", UVM_CVR_ALL);
    m_%(bname)s_env = %(bname)s_env::type_id::create("m_%(bname)s_env", this);
    common_env_pkg::utils::cfg_printer(uvm_default_printer);
  endfunction : build_phase

  function void end_of_elaboration_phase(uvm_phase phase);
    uvm_phase main_phase = phase.find_by_name("main", 0);
    main_phase.phase_done.set_drain_time(this, 1us);
    uvm_top.print_topology();
  endfunction : end_of_elaboration_phase

  function void start_of_simulation_phase(uvm_phase phase);
  endfunction : start_of_simulation_phase

  task reset_phase(uvm_phase phase);
%(reset_phase)s
  endtask : reset_phase
  task configure_phase(uvm_phase phase);
%(configure_phase)s
  endtask : configure_phase
  task main_phase(uvm_phase phase);
%(main_phase)s
  endtask : main_phase
  task shutdown_phase(uvm_phase phase);
%(shutdown_phase)s
  endtask : shutdown_phase
endclass : base_test
`endif // BASE_TEST__SVH'''%dict(bname=bname,
reset_phase=reset_phase,
configure_phase=configure_phase,
main_phase=main_phase,
shutdown_phase=shutdown_phase,
))
  def create_tbdir(self,path,bname,override):
    def slicepath(path,slices,lvl):
      if lvl > 100:
        slices.append((path,1))
        return
      if path=='':
        return
      if '[' in path:
        slices.append((path[:path.index('[')], int(path[path.index('[')+1:path.index(']')])))
        lvl+=1
        slicepath(path[path.index(']')+1:],slices,lvl)
      else:
        slices.append((path,1))
        return
    logger=func_logger(level=self.level)
    if os.path.exists(path):
      logger.error("%s dir already existed"%path)
      exit(1)
    os.makedirs(path)
    logger.debug("create %s subdir"%path)
    th=os.path.join(path,"%s_th.sv"%bname)
    tb=os.path.join(path,"%s_tb.sv"%bname)
    vif_assignments=''
    hif_assignments=''
    for inst,vifs in self.assign_vif_db.items():
      superinst=inst[:inst.rfind('.')]
      _,vifname,viftype=next(iter(vifs))
      _,hif=viftype.split()
      config_inst=superinst[superinst.index('.')+1:].replace('_env','_config') # pop uvm_test_top
      slices=[]
      slicepath(config_inst,slices,0)
      if len(slices)==1 and slices[0][1]==1:
        vif_assignments+='    %(config_inst)s.%(vifname)s = th.%(hif)s_0;\n'%dict(config_inst=config_inst,vifname=vifname,hif=hif)

        hif_assignments+='  %(hif)-30s %(hif)s_0 ( clk );\n'%dict(hif=hif)
      else:
        npath=''
        idx=''
        hidx=''
        for i,(pslice,array) in enumerate(slices):
          vif_assignments+='    %(tab)sfor(int i%(i)s=0;i%(i)s < %(array)s;i%(i)s++)\n'%dict(tab='  '*i,i=i,array=array)
          if array > 1:
            npath+='%s[i%d]'%(pslice,i)
            idx+='[i%d]'%i
            hidx+='[%d]'%array
          else:
            npath+=pslice
        vif_assignments+='    %(tab)s%(npath)s.%(vifname)s = th.%(hif)s%(idx)s;\n'%dict(tab='  '*(i+1),npath=npath,idx=idx,vifname=vifname,hif=hif)
        hif_assignments+='  %(hif)-30s %(hif)s %(hidx)s ( clk );\n'%dict(hif=hif,hidx=hidx)
        
    self.fpath2name[th]=bname+'_th'
    with open(th,'w') as fh:
      fh.write('''
module %(bname)s_th;
  timeunit      1ns;
  timeprecision 1ps;
  logic clk;
  initial begin
    clk = 0;
    forever #( 10000 * 1ps ) clk = ! clk;
  end
%(hif_assignments)s
endmodule
'''%dict(bname=bname,
hif_assignments=hif_assignments,
))
    self.fpath2name[th]=bname+'_tb'
    with open(tb,'w') as fh:
      fh.write('''
module %(bname)s_tb;
  timeunit      1ns;
  timeprecision 1ps;
  `include "uvm_macros.svh"
  import uvm_pkg::*;

  import common_pkg::*;
  import common_env_pkg::*;
  import %(bname)s_test_pkg::*;
  import %(bname)s_pkg::%(bname)s_config;

  // Configuration object for top-level environment
  %(bname)s_config m_%(bname)s_config;

  // Test harness
  %(bname)s_th th();

  initial
  begin
    // Create and populate top-level configuration object
    m_%(bname)s_config = %(bname)s_config::type_id::create("m_%(bname)s_config");
    if ( !m_%(bname)s_config.randomize() )
      `uvm_error("%(bname)s_tb", "Failed to randomize top-level configuration object" )

%(vif_assignments)s

    uvm_config_db #(%(bname)s_config)::set(null, "", "config", m_%(bname)s_config);
    run_test();
  end
endmodule
'''%dict(bname=bname,
vif_assignments=vif_assignments,
))
  def create_commondir(self,path,override):
    logger=func_logger(level=self.level)
    if os.path.exists(path):
      logger.error("%s dir already existed"%path)
      exit(1)
    os.makedirs(path)
    logger.debug("create %s dir"%path)
    common_env_pkg=os.path.join(path,'common_env_pkg.sv')
    common_pkg=os.path.join(path,'common_pkg.sv')
    os.system("svn export http://vi-bugs/svn/pld/trunk/projects/fiji/all_links/verif3/common/common_env_pkg.sv %s"%common_env_pkg)
    os.system("svn export http://vi-bugs/svn/pld/trunk/projects/fiji/all_links/verif3/common/common_pkg.sv %s"%common_pkg)
  def fetch_seq_itemsdir(self,path,override):
    logger=func_logger(level=self.level)
    os.system("svn export http://vi-bugs/svn/pld/trunk/projects/fiji/all_links/verif3/seq_items %s"%path)
  def create_rundir(self,path,override):
    logger=func_logger(level=self.level)
    if os.path.exists(path):
      logger.error("%s dir already existed"%path)
      exit(1)
    os.makedirs(path)
    logger.debug("create %s dir"%path)
    run_make=os.path.join(path,'Makefile')
    with open(run_make,'w') as fh:
      fh.write('''
###############################################################################
# qip base makefile
###############################################################################
TOPLEVEL_LANG ?= verilog
PWD=$(shell pwd)
WPWD=$(shell pwd)
PYTHONPATH:=$(WPWD)/../env:$(PYTHONPATH)
RUNSIM_DO:=runsim.do
DO_CMD:='do runsim.do;compile_vsim;quit'
RUN_CMD=
SolveArrayResizeMax:=set SolveArrayResizeMax 0  # default value 2000
ifneq ($(SolveArrayResizeMax),)
RUN_CMD+=$(SolveArrayResizeMax);
endif
RUN_CMD+=run -all
#ALL_CMD:='do runsim.do;compile_vsim;run_vsim'
TOPLEVEL := toplevel_tb
TEST ?= base_test
VSIM_ARGS ?=



ARCH?=$(shell uname -m)
export ARCH

OS=$(shell uname)
export OS

ifdef VERILOG_INCLUDE_DIRS
VLOG_ARGS += +incdir+$(VERILOG_INCLUDE_DIRS)
endif

ifdef EXTRA_ARGS
VLOG_ARGS += $(EXTRA_ARGS)
endif

SIM_CMD = vsim -c
VSIM_ARGS =
#VSIM_ARGS +=-onfinish exit
#VSIM_ARGS +=-solvefaildebug
#VSIM_ARGS +=-solveverbose
VSIM_ARGS +=-l $(TEST).log
VSIM_ARGS +=-wlf $(TEST).wlf
UVM_ARGS =+UVM_TESTNAME=$(TEST)
#UVM_ARGS =+UVM_CONFIG_DB_TRACE
#UVM_ARGS +=+UVM_RESOURCE_DB_TRACE
#UVM_ARGS +=+UVM_CONFIG_DB_TRACE
UVM_ARGS +=+UVM_VERBOSITY=UVM_FULL
#UVM_ARGS +=+UVM_VERBOSITY=UVM_MEDIUM
#UVM_ARGS +=+UVM_OVM_RUN_SEMANTIC


.PHONY: $(RUNSIM_DO)
all:
	$(SIM_CMD) -do $(DO_CMD) -l compile.log 2>&1
	$(SIM_CMD) $(QUESTARUN_OPTS) -do "$(RUN_CMD)" 2>&1
compile:
	$(SIM_CMD) -do $(DO_CMD) -l compile.log 2>&1
run:
	$(SIM_CMD) $(QUESTARUN_OPTS) -do "$(RUN_CMD)" 2>&1
$(RUNSIM_DO) : ;



###############################################################################
# PROJECT VAR
###############################################################################
SIM_LIB_DIR:=${QUARTUS_ROOTDIR}/eda/sim_lib
TOPXML:=$(abspath ../../../top/doc/fiji_regs_top.xml)
RALDIR:=$(abspath ../toplevel/mm/ral)
SHARED_INCDIR:=$(abspath ../../../../../common/vi_include)
SHARED_LIBDIR:=$(abspath ../../../../../common/vi_lib)
SHARED_IPDIR:=$(abspath ../../../../../common/vi_ip)
#TBDIR:=../env
VGEN:=$(abspath ../../../../../common/vi_scripts/vgen.py)
PCAP2ETH:=$(abspath ../../../../../common/vi_scripts/pcap2eth.py)
XML2UVMRAL:=$(abspath ../../../../../common/vi_scripts/xml2uvmral.py)
SCRPDIR:=../../../../scripts
CFGDIR:=../cfg
CFG =
SIMDEF =
#DOCMD ='log -r /*; run -all; quit'
DOCMD ='log -r /*; run -all'
COV = 0
DATE := $(shell date +%T)
COV_DOCMD   = 'coverage save -onexit cov_${TEST}.ucdb; run -all; quit'
SEED = 12345
#ALTLIB_SOURCE= 220model.v sgate.v altera_lnsim.sv altera_primitives.v altera_mf.v stratixv_atoms.v stratixv_atoms_ncrypt.v stratixv_hssi_atoms.v stratixv_hssi_atoms_ncrypt.v stratixv_pcie_hip_atoms.v stratixv_pcie_hip_atoms_ncrypt.v
ALTLIB_SOURCE= 220model.v sgate.v altera_lnsim.sv altera_primitives.v altera_mf.v stratixv_atoms.v stratixv_hssi_atoms.v

###############################################################################
# functions
###############################################################################
define \\n
\\\\n

endef
map=(forach x,$2,$(call $1,$x))
reduce=$(if $(strip $2),$(call reduce,$1,$(wordlist 2,$(words $2),$2),$(call $1,$(firstword $2),$3)),$3)
check_uniq=$(if $(filter $1,$2),$2,$2 $1)
define READLINES_shell=
while read LINE; do \\
  case $$LINE in
    *MIF_FILE*);;
    *QIP_FILE*);;
    *VERILOG_FILE*) echo $$LINE| awk '{print $$9}' | sed -e 's:]::g' -e 's:"::g' -e "s:'::g" -e 's:^:$(QIP_PATH):';;
  esac;
done < $(QIP_FILE)
endef
define READLINES_template=
$(shell while read LINE; do \\
  case $$LINE in \\
    (set*QIP_FILE*\\[file*join*$::quartus*qip_path*\\]) echo $$LINE | sed -e 's:.*qip_path. ::' -e 's:]::g' -e 's:"::g' -e "s:'::g" -e 's:^:$(2):' >> $(3);; \\
    (set*MIF_FILE*\\[file*join*$::quartus*qip_path*\\]) echo $$LINE | sed -e 's:.*qip_path. ::' -e 's:]::g' -e 's:"::g' -e "s:'::g" -e 's:^:$(2):' >> $(4);; \\
    (set*VERILOG_FILE*\\[file*join*$::quartus*qip_path*\\]) echo $$LINE | sed -e 's:.*qip_path. ::' -e 's:]::g' -e 's:"::g' -e "s:'::g" -e 's:^:$(2):' >> $(5);; \\
  esac; \\
done < $(1))
endef
define QUESTALIB_template=
if [file exists $(1)] {vdel -lib $(1) -all}\\\\n
vlib $(1)\\\\n
 $(foreach x,$(2),$(addprefix vlog -fsmdebug -novopt -timescale 1ns/100ps +incdir+$5 +define+$4 -sv -work $(1) $(3)/,$x$(\\n)))
endef
define QUESTARUN_template=
vsim -novopt $(1) -L altlib  +transport_int_delays +transport_path_delays +notimingchecks -t ps $(2).$(3) $(4) $(5) -sv_seed $(6)\\\\n
endef
define QUESTARUN_OPTS_template=
-novopt $(1) -L altlib  +transport_int_delays +transport_path_delays +notimingchecks -t ps $(2).$(3) $(4) $(5) -sv_seed $(6)
endef
QUESTASIM_template=vsim -novopt $(1) $(2) -L altlib +transport_int_delays +transport_path_delays +notimingchecks -t ps $3.$4 -l $(5).log -wlf $(5).wlf -c -sv_seed $(7) -do $(6)
QIPS_template=$(shell grep '^set' $(1)|grep QIP | sed -e 's:.*qip_path. ::' -e 's:]::g' -e 's:"::g' -e "s:'::g")
MIFS_template=$(shell grep '^set' $(1)|grep MIF | sed -e 's:.*qip_path. ::' -e 's:]::g' -e 's:"::g' -e "s:'::g")
VERILOGS_template=$(addprefix $(dir $(1)),$(shell grep '^set' $(1)|grep VERILOG | sed -e 's:.*qip_path. ::' -e 's:]::g' -e 's:"::g' -e "s:'::g"))
MKDIRS_template=$(shell for d in $(1); \\
                  do \\
                    [[ -d $$d ]] || mkdir -p $$d; \\
                  done)
XMLREGS_template=$(subst regs.v,regs.xml,$(filter %regs.v,$(1)))
ASSERT_template=$(if $(1),,$(error Assertion failed: $2))
ASSERT_FILE_EXISTS_template=$(call ASSERT_TEMPLATE,$(wildcard $(1)),$(1) does not exist)
ASSERT_NOT_NULL_template=$(call ASSERT_TEMPLATE,$($(1)),The variable "$(1)" is null)
COMMA := ,
ECHO_ARGS=$(subst ' ','$(COMMA) ',$(foreach a,1 2 3 4 5 6 7 8 9,'$($a)'))
VGEN_template=$(foreach f,$(1),$(shell $(VGEN) $(f)))
define QIP_FILE_template=
QIP_PATH=$(dir $(1))
VERILOG_SOURCES=$(call VERILOGS_template,$(1))
XMLREGS_SOURCES=$(call XMLREGS_template,$(VERILOG_SOURCES))
$(call VGEN_template,$(XMLREGS_SOURCES))
SOURCES=$(call reduce,check_uniq,$(VERILOG_SOURCES))
$(shell echo -e  $(call QUESTALIB_template,$(subst .qip,lib,$(notdir $(1))),$(SOURCES),.,$(SIMDEF),$(QIP_PATH))>>$(RUNSIM_DO))
endef
define QIP_FILE_template=
VERILOG_SOURCES=$(call VERILOGS_template,$(1))
XMLREGS_SOURCES=$(call XMLREGS_template,$(call VERILOGS_template,$(1)))
$(call VGEN_template,$(call XMLREGS_template,$(call VERILOGS_template,$(1))))
$(shell echo -e  $(call QUESTALIB_template,$(subst .qip,lib,$(notdir $(1))),$(call reduce,check_uniq,$(call VERILOGS_template,$(1))),.,$(SIMDEF),$(dir $(1)))>>$(RUNSIM_DO))
endef
###############################################################################
# create questa do file
###############################################################################
# altera lib
# directories which containing rtl qip file
VI_LIB_DIR                     = ../../../../../common/vi_lib
MAC_DIR                        = ../../../mac/rtl
PARSER_DIR                     = ../../../parser/rtl
TCAM_DIR                       = ../../../tcam/rtl
FLMAN_DIR                      = ../../../flow_manager/rtl
FLMEM_DIR                      = ../../../flow_memory/rtl
EXTR_DIR                       = ../../../extractor/rtl
LINK_ENGINE_DIR                = ../../../link_engine/rtl
CHIPREGS_DIR                   = ../../../chipregs/rtl
ALL_LINKS_DIR                  = ../../../all_links/rtl
RECORDER_DIR                   = ../../../recorder/rtl
COMMON_DIR                     = ../../../common/rtl

$(shell rm -f $(RUNSIM_DO))
$(shell echo -e  'proc compile_vsim {} {' > $(RUNSIM_DO))
## altlib
SOURCES=$(call reduce,check_uniq,$(ALTLIB_SOURCE))
ifneq ($(DEBUG),)
$(info $(call QUESTALIB_template,altlib,$(SOURCES),$(SIM_LIB_DIR),$(SIMDEF),$(SIM_LIB_DIR)))
endif
$(shell echo -e $(call QUESTALIB_template,altlib,$(SOURCES),$(SIM_LIB_DIR),$(SIMDEF),$(SIM_LIB_DIR))>> $(RUNSIM_DO))
# work lib
QIP_PATH=$(dir $(QIP_FILE))
ifneq ($(DEBUG),)
$(info $(shell $(READLINES_shell) > xyz))
endif
ifneq ($(DEBUG),)
$(info $(call READLINES_template,$(QIP_FILE),$(QIP_PATH),qips,mifs,verilogs))
endif
$(shell rm -f qips)
$(shell rm -f mifs)
$(shell rm -f verilogs)
ifneq ($(DEBUG),)
$(info $(call QIPS_template,$(QIP_FILE)))
endif
ifneq ($(DEBUG),)
$(info $(call MIFS_template,$(QIP_FILE)))
endif
ifneq ($(DEBUG),)
$(info $(call VERILOGS_template,$(QIP_FILE)))
endif
###################
## rtl qip files ##
###################
QIP_FILES+=../tb.qip
$(info $(foreach a,$(QIP_FILES),$(call QIP_FILE_template,$(a))))
WORKLIBS=$(foreach a,$(QIP_FILES),$(subst .qip,lib,$(notdir $(a))))
ifneq ($(DEBUG),)
$(info $(WORKLIBS))
endif
$(shell echo -e  '}\\nproc run_vsim {} {' >> $(RUNSIM_DO))
ifneq ($(PCAP),)
$(shell $(PCAP2ETH) $(PCAP) test > log)
VSIM_ARGS+=+MIF_CH0=testch0.mif
VSIM_ARGS+=+MIF_CH1=testch1.mif
endif
$(shell echo -e $(call QUESTARUN_template,$(subst .qip,lib,$(foreach a,$(WORKLIBS),-L $(a))),tblib,$(TOPLEVEL),$(UVM_ARGS),$(VSIM_ARGS),$(SEED))>> $(RUNSIM_DO))
$(shell echo -e $(DOCMD)>> $(RUNSIM_DO))
$(shell echo -e  '}' >> $(RUNSIM_DO))
$(shell $(XML2UVMRAL) $(TOPXML) $(RALDIR) > ral.log)
QUESTARUN_OPTS=$(call QUESTARUN_OPTS_template,$(subst .qip,lib,$(foreach a,$(WORKLIBS),-L $(a))),tblib,$(TOPLEVEL),$(UVM_ARGS),$(VSIM_ARGS),$(SEED))
''')
  def create_ex_seq(self,path,bname):
    fpath=os.path.join(path,'%s_test/seq_examples.svh'%bname)
    self.fpath2name[fpath]=map(lambda x: 'seq_%s'%x,self.item4example_seq_db)
    codes=''
    for i,item in enumerate(list(self.item4example_seq_db)):
      codes+='''
class seq_%(item)s extends uvm_sequence #(%(item)s);
  int num_inst = 4;
  %(item)s req;

  `uvm_object_utils_begin(seq_%(item)s)    
    `uvm_field_int(num_inst, UVM_ALL_ON)
  `uvm_object_utils_end
  
  function new(string name="seq_%(item)s");
    super.new(name);
  endfunction
  

  virtual task body();
    m_sequencer.print();
    `uvm_info(get_full_name(),$sformatf("Num of transactions %%d",num_inst),UVM_LOW);
    repeat(num_inst) begin
      `uvm_do_with(req, { inst == %(instruction)s; });
    end
  endtask
endclass : seq_%(item)s 
'''%dict(item=item,instruction=['PUSH_A','PUSH_B','ADD','SUB','MUL','DIV','POP_C'][i%7])
   
    with open(fpath,'w') as fh:
      fh.write('''
`ifndef %(name)s__SVH
`define %(name)s__SVH
%(codes)s
`endif // %(name)s__SVH'''%dict(name='SEQ_EXAMPLES', codes=codes,))
     
def func_logger(level=logging.INFO):
  func_name=inspect.stack()[1][3]
  logger=logging.getLogger(func_name)
  logger.setLevel(level)
  logFormat=logging.Formatter("%(name)s:%(lineno)s %(levelname)s %(message)s")

  sh=logging.StreamHandler(sys.stdout)
  sh.setFormatter(logFormat)
  logger.addHandler(sh)
  return logger
  
import xml.etree.ElementTree as ET
from pprint import pformat
from pprint import pprint
from collections import *
class xml2dict(object):

  def __init__(self, coding='UTF-8'):
    self._coding = coding

  def root2dict(self,t):
    d = {t.tag: {} if t.attrib else None}
    children = list(t)
    if children:
      dd = defaultdict(list)
      for dc in map(self.root2dict, children):
        for k, v in dc.iteritems():
          dd[k].append(v)
      d = {t.tag: {k:v[0] if len(v) == 1 else v for k, v in dd.iteritems()}}
    if t.attrib:
      d[t.tag].update(('@' + k, v) for k, v in t.attrib.iteritems())
    if t.text:
      text = t.text.strip()
      if children or t.attrib:
        if text:
          d[t.tag]['#text'] = text
      else:
        d[t.tag] = text
    return d

  def readxml(self,fname):
    """
    """
    tree = ET.parse(fname)
    root = tree.getroot()
    return root

  def writedict(self,root,fname):
    with open(fname,'w') as fh:
      #pprint(root)
      fh.write(pformat(root))


if __name__=='__main__':   
  import sys
  import argparse
  argc=len(sys.argv)
  parser=argparse.ArgumentParser(add_help = True, description = "create uvm testbench from  testbench.xml, for example, xml2uvmcode.py -xml /home/chi-wei.fu/work/checkout/pld_new1/projects/fiji/all_links/verif3/fiji_testbench.xml -dir /tmp/verif3 -debug")
  parser.add_argument('-debug',action='store_true',help='Turn DEBUG output')
  parser.add_argument('-xml',action='store',help='testbench xml file')
  parser.add_argument('-dir',action='store',help='save uvm codes in the destinatin directory')
  parser.add_argument('-override',action='store_true',help='written over existing file')
  parser.add_argument('--version', action='version', version='%(prog)s 1.0')
  options=parser.parse_args()
  if options.debug:
    obj=xml2uvmcode(logging.DEBUG)
    os.system("rm -rf %s"% options.dir)
  else:
    obj=xml2uvmcode(logging.INFO)
    
  obj.readxml(options.xml)
  if options.override:
    obj.writecode(options.dir,override=True)
  else:
    obj.writecode(options.dir)
  if options.debug:
    print "paths:",pformat(obj.paths)
    print "insts:",pformat(obj.insts)
    print "uvm_envs:",pformat(obj.uvm_envs)
    print "inst2env:",pformat(obj.inst2env)
    print "subdirs:",pformat(obj.subdirs)
    print "files:",pformat(obj.path2file.values())
    print "path2file:",pformat(obj.path2file)
    print "uvm_db:",pformat(obj.uvm_db)
    print "uvm_custom_db:",pformat(obj.uvm_custom_db)
    print "uvm_inherit_db:",pformat(obj.uvm_inherit_db)
    print "inst2members:",pformat(obj.inst2members)
    print "inst2path:",pformat(obj.inst2path)
    print "fname2uvmtype:",pformat(obj.fname2uvmtype)
    print "vif_db:",pformat(obj.vif_db)
    print "inst2seq_item:",pformat(obj.inst2seq_item)
    print "connect_db:",pformat(obj.connect_db)
    print "assign_vif_db:",pformat(obj.assign_vif_db)
    print "config_db:",pformat(obj.config_db)
    print "env2config:",pformat(obj.env2config)
    print "reset_phase_db:",pformat(obj.reset_phase_db)
    print "configure_phase_db:",pformat(obj.configure_phase_db)
    print "main_phase_db:",pformat(obj.main_phase_db)
    print "shutdown_phase_db:",pformat(obj.shutdown_phase_db)
    print "inst2seq_items:",pformat(obj.inst2seq_items)
    print "seq_item2file:",pformat(obj.seq_item2file)
    print "seq_item2tasks:",pformat(obj.seq_item2tasks)
    print "fpath2name:",pformat(obj.fpath2name)
    print "svs:",pformat(obj.svs)
    print "envinsthasvif_db:",pformat(obj.envinsthasvif_db)
    print "item4example_seq_db:",pformat(obj.item4example_seq_db)
    print "debug_db:",pformat(obj.debug_db)
