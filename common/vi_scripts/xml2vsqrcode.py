#!/usr/bin/env python2.7
import logging
import inspect
from pprint import pprint,pformat
from copy import deepcopy
import os
import copy
class xml2vsqrcode(object):
  primitives=[
'bit',
'byte',
'int',
'shortint',
'longint',
'byte unsigned',
'int unsigned',
'shortint unsigned',
'longint unsigned',
]
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
'uvm_seq_item_pull',
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
    self.seq_items_db=[] # item in seq_items dir
    self.vsqrinsts=[]
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
    self.config_get_db=dict()
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
uvm_sequencer=self.uvm_sequencer_codegen,
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
    if 'vi_vsqr' not in self.tree: 
      logger.error("Is not a virtual sequencer xml")
      exit(1)
    self.tree=self.tree['vi_vsqr']
    if 'uvm_sequencer' not in self.tree: 
      logger.error("Missing virtual sequencer")
      exit(1)
    self.tree=self.tree['uvm_sequencer']
    vsqrname=self.tree['@type']
    array=1
    if '@array' in self.tree:
      array=self.tree['@array']
    self.uvm_db['uvm_sequencer'].append(vsqrname)
    self.paths.add(os.path.join(vsqrname,vsqrname))
    self.fname2uvmtype[vsqrname]='uvm_sequencer'
    if vsqrname.endswith('_vsqr'):
      bname=vsqrname[:-5]
    elif vsqrname.endswith('vsqr'):
      bname=vsqrname[:-4]
    vsqrpath=os.path.join(self.dname,vsqrname)
    commonpath=os.path.join(self.dname,'common')
    seq_itemspath=os.path.join(self.dname,'seq_items')
    tbpath=os.path.join(self.dname,'tb')
    runpath=os.path.join(self.dname,'run')
    # create virtual directory path
    if os.path.exists(vsqrpath):
      logger.error("%s dir already existed,remove the dir or specify different dir"%vsqrpath)
      exit(1)
    os.makedirs(vsqrpath)
    self.walk_tree(self.tree)
    for path in self.paths:
      if '/' not in path:
        self.path2file[path]=os.path.join(path,path)+'.svh'
        inst=next((k for k, v in self.inst2path.items() if v == path), None)
        self.inst2path[inst]=os.path.join(path,path)
        fpath=self.path2file[path]  
        del(self.path2file[path])
        self.path2file[os.path.join(path,path)] = fpath 
      else:
        self.path2file[path]=path+'.svh'
    self.xref_svh_files(vsqrpath)
    self.create_svh_files(dname)
#    self.create_config_svh_files(dname)
    if options.debug or options.tb:
      #self.create_ex_seq(vsqrpath)
      self.create_commondir(commonpath,override)
      self.fetch_seq_itemsdir(seq_itemspath,override)
      self.create_seq_item_svh_files(dname)
      self.tb_qip_files.append(os.path.join('common','common_pkg.sv'))
      self.tb_qip_files.append(os.path.join('common','common_env_pkg.sv'))
      self.tb_qip_files.append(os.path.join('seq_items','seq_items_pkg.sv'))
      self.create_tbdir(tbpath,override)
      self.create_base_test(dname,vsqrname,array)
    self.create_pkg_files(dname)
    if not options.layer: self.create_seq_items_pkg_file(dname)
    if options.debug or options.tb:
      self.create_rundir(runpath,override)
      self.tb_qip_files.extend(sorted(map(lambda x: x[len(dname)+1:],filter(lambda x: x.endswith('_pkg.sv'),self.fpath2name)),key=lambda x:x.count('/'),reverse=True))
      self.tb_qip_files+=sorted(self.svs,key=lambda x:x.count('/'),reverse=True)
      self.create_test_pkg_file(dname,'test')
      self.tb_qip_files.append(os.path.join('test','test_pkg.sv'))
      self.tb_qip_files.append(os.path.join('tb','tb.sv'))
#    self.tb_qip_files.append(os.path.join('%s_tb'%bname,'%s_th.sv'%bname))
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
          
      def update_config_get_db(db,branch):
        if isinstance(branch,list):
          for subbranch in branch:
            update_config_get_db(db,subbranch)
        else:
          if pi not in db:
            db[pi]=set()
          db[pi].add((branch['@name'],branch['@type'],branch['@size']))
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
        elif k=='config_get':
          subbranch=v 
          update_config_get_db(self.config_get_db,subbranch)
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
  def get_config_members(self,uvmtype,name,inst):
    logger=func_logger(level=self.level)
    lines=[]
    for name,typ,size,seq_item,array in self.inst2members[inst]:
      typ_q=typ
      if '#' in typ_q: typ_q=typ_q[:typ_q.index('#')].rstrip()
      if '_port' in typ_q: typ_q=typ_q[:-5]
      if '_export' in typ_q: typ_q=typ_q[:-7]
      if '_fifo' in typ_q: typ_q=typ_q[:-5]
      if typ_q in xml2vsqrcode.uvm_port_fifos: continue
      if typ.startswith('virtual '): continue
      if self.type_qualify(typ) not in self.fname2uvmtype:
        if array > 1:
          logger.error("%s %s[%d] array member type is not supported for `uvm_field"%(typ,name,array))
        else:
          if typ=='integral': 
            lines.append('     `uvm_field_int(%(name)s,UVM_DEFAULT);'%dict(name=name))
          elif typ=='uvm_sequencer_arb_mode': 
            lines.append('     `uvm_field_enum(uvm_sequencer_arb_mode,%(name)s,UVM_DEFAULT);'%dict(name=name))
          else:
            logger.error("%s %s member type is not supported for `uvm_field"%(typ,name))
   
    passive='\n'.join(lines)
    active=''
    return '''%(passive)s%(active)s'''%(dict(passive=passive,active=active))
  def get_constraint_config_get_members(self,uvmtype,inst):
    lines=[]
    if not options.layer: return ''
    if inst not in self.config_get_db: return ''
    for name,typ,size in self.config_get_db[inst]:
      if typ in xml2vsqrcode.primitives:
        if typ=='bit':
          lines.append('        if ( p_sequencer.%(name)s ) { %(name)s == p_sequencer.%(name)s;}'%dict(name=name))
      else:
        lines.append('        if ( p_sequencer.%(name)s ) { %(name)s == p_sequencer.%(name)s;}'%dict(name=name))
    return '\n'.join(lines)
  def get_config_get_members(self,uvmtype,name,inst):
    lines=[]
    if not options.layer: return ''
    if inst not in self.config_get_db: return ''
    for name,typ,size in self.config_get_db[inst]:
      if typ in xml2vsqrcode.primitives:
        if typ=='bit':
          if size > 1:
            type_q='bit [%d:0]'%(int(size)-1)
          else:
            type_q='bit'
        else:
          type_q=typ
        lines.append('  %-50s %s=0;'%(type_q,name))
      else:
        type_q=typ
        lines.append("  %-50s %s=%s'(0);"%(type_q,name,type_q))
    return '\n'.join(lines)
  def get_config_config_get_members(self,uvmtype,name,inst):
    lines=[]
    if not options.layer: return ''
    if inst not in self.config_get_db: return ''
    for name,typ,size in self.config_get_db[inst]:
      if typ in xml2vsqrcode.primitives:
        lines.append('     `uvm_field_int(%s, UVM_ALL_ON )'%name)
      else:
        lines.append('     `uvm_field_enum(%s, %s, UVM_ALL_ON )'%(typ,name))
    return '\n'.join(lines)
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
    lines=[]
    for name,typ,size,seq_item,array in filter(lambda x: self.type_qualify(x[1]) not in self.fname2uvmtype,self.inst2members[inst]):
      if array > 1:
        if seq_item=='':
          lines.append('  %-50s %s[%d];'%(typ2svtyp(typ),name,array))
        else:
          lines.append('  %-50s %s[%d];'%('{}#({})'.format(typ2svtyp(typ),seq_item),name,array))
      else:
        if seq_item=='':
          if typ=='uvm_sequencer_arb':
            lines.append('  %-50s %s=%s;'%(typ2svtyp(typ),name,'SEQ_ARB_STRICT_FIFO'))
          else:
            lines.append('  %-50s %s;'%(typ2svtyp(typ),name))
        else:
          lines.append('  %-50s %s;'%('{}#({})'.format(typ2svtyp(typ),seq_item),name))
    
    return '\n'.join(lines)
  def get_create_members(self,uvmtype,name,inst):
    return '\n'.join(map(lambda x: '  %-50s %s[%d];'%(x[1],x[0],x[4]) if x[4] > 1 else
                       '  %-50s %s;'%(x[1],x[0]) ,filter(lambda x: self.type_qualify(x[1]) in self.fname2uvmtype,self.inst2members[inst])))

  def get_tlm_imp_members(self,uvmtype,name,inst):
    members=set()
    for name,typ,size,seq_item,array in self.inst2members[inst]:
      if typ.endswith(name) and typ[:-len(name)-1] in xml2vsqrcode.tlm_imps:
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
      if typ == 'uvm_sequencer_arb_mode':
        lines.append('    set_arbitration(%(name)s);'%dict(name=name))
      typ_q=typ
      if '#' in typ_q: typ_q=typ_q[:typ_q.index('#')].rstrip()
      if '_port' in typ_q: typ_q=typ_q[:-5]
      if '_export' in typ_q: typ_q=typ_q[:-7]
      if '_fifo' in typ_q: typ_q=typ_q[:-5]
      if typ_q not in xml2vsqrcode.uvm_port_fifos: continue
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

  def find_seq_item(self,inst):
    seq_item=''
    if '.' in inst:
      parent=inst[:inst.rfind('.')]
      me=inst[inst.rfind('.')+1:]
      if(filter(lambda x: x[0]==me,self.inst2members[parent])):
        seq_item=filter(lambda x: x[0]==me,self.inst2members[parent])[0][3]
    return seq_item
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
  def uvm_sequencer_codegen(self,uvmtype,name,inst):
    seq_item=self.find_seq_item(inst)
    config_members=''
    if seq_item:
      config_members=self.get_config_members(uvmtype,name,inst)
    #config_get_members=''
    config_get_members='''
  int unsigned                                       m_seg_count=1;
  int unsigned                                       m_mss=8;
  int unsigned                                       m_compound_count=1;
  int unsigned                                       m_repeat_count=1;
'''
    #config_config_get_members=''
    config_config_get_members='''
     `uvm_field_int(m_seg_count, UVM_ALL_ON )
     `uvm_field_int(m_mss, UVM_ALL_ON )
     `uvm_field_int(m_compound_count, UVM_ALL_ON )
     `uvm_field_int(m_repeat_count, UVM_ALL_ON )
'''
    if seq_item:
      config_get_members+=self.get_config_get_members(uvmtype,name,inst)
      config_config_get_members+=self.get_config_config_get_members(uvmtype,name,inst)

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
    if seq_item !='' and filter(lambda x: x[1]=='uvm_seq_item_pull_port',self.inst2members[inst]):
      ph_decls='    %(item)s item;\n'%dict(item=filter(lambda x: x[1]=='uvm_seq_item_pull_port',self.inst2members[inst])[0][3])
      main_phase='''
    fork
      forever begin
        up_seq_item_port.get_next_item(item);
        up_seq_item_fifo.analysis_export.write(item);
        up_seq_item_port.item_done();
      end
    join
'''
    if main_phase!='':
      main_phase=ph_decls+('    `uvm_info(get_type_name(), "main_phase", UVM_MEDIUM)'+
                       main_phase)
    ph_decls,shutdown_phase=self.get_shutdown_phase(uvmtype,name,inst)
    if shutdown_phase!='':
      ph_shutdown_phase=ph_decls+('    `uvm_info(get_type_name(), "shutdown_phase", UVM_MEDIUM)'+
                       shutdown_phase)
    return  '''class %(name)s extends uvm_sequencer%(seq_item)s;
%(port_members)s
%(config_get_members)s
%(create_members)s
  `uvm_component_utils_begin(%(name)s)
%(config_members)s
%(config_config_get_members)s
  `uvm_component_utils_end
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
config_get_members=config_get_members,
config_config_get_members=config_config_get_members,
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


  def virtual_sequence_codegen(self,uvmtype,sqr,sqr_inst,sqr_fpath):
    def sqr2seq(sqr):
      if 'sqr' in sqr:
        seq=sqr.replace('sqr','seq')
      elif 'sequencer' in sqr:
        seq=sqr.replace('sequencer','seq')
      else:
        seq=sqr+'_seq'
      return seq
    name=sqr2seq(sqr)
    seq_item=self.find_seq_item(sqr_inst)
    if 'sqr' in sqr:
      name=sqr.replace('sqr','seq')
    elif 'sequencer' in sqr:
      name=sqr.replace('sequencer','seq')
    else:
      name=sqr+'_seq'
    subsqrs=filter(lambda x: self.fname2uvmtype[x[1]]=='uvm_sequencer',filter(lambda x: not x[1].startswith('uvm_'),self.inst2members[sqr_inst]))
    decls='\n'.join(map(lambda x: '    %(typ)-50s %(inst)s;'%dict(typ=sqr2seq(x[1]),inst=sqr2seq(x[0])),subsqrs))
    decls+=                       '\n'
    bodys='\n'.join(map(lambda x: '    %(inst)s = %(typ)s::type_id::create("%(inst)s");'%dict(typ=sqr2seq(x[1]),inst=sqr2seq(x[0])),subsqrs))
    bodys+=                       '\n'
    bodys+=                       '    fork\n'
    bodys+='\n'.join(map(lambda x: '      %(inst)s.start(p_sequencer.%(sqrinst)s,this);'%dict(inst=sqr2seq(x[0]),sqr=x[1],sqrinst=x[0]),subsqrs))
    bodys+=                       '\n    join\n'
    codes='''class %(name)s extends uvm_sequence%(seq_item)s;
  `uvm_object_utils_begin(%(name)s)
  `uvm_object_utils_end
  `uvm_declare_p_sequencer(%(sqr)s)
  function  new(string name="%(name)s");
    super.new(name);
  endfunction : new
  virtual task body();
%(decls)s
    `uvm_info(get_type_name(), "Virtual sequence %(name)s start", UVM_MEDIUM)
%(bodys)s
  endtask : body
endclass : %(name)s'''%dict(name=name,
seq_item='#(%s)'%(seq_item if seq_item else 'uvm_sequence_item'),
sqr=sqr,
decls=decls,
bodys=bodys,
)
    fpath=os.path.join(os.path.dirname(sqr_fpath),name+'.svh')
    self.fpath2name[fpath]=name
    print fpath
    with open(fpath,'w') as fh:
          fh.write('''`ifndef %(name)s__SVH
`define %(name)s__SVH
%(codes)s
`endif // %(name)s__SVH
'''%dict(name=name.upper(),codes=codes))

  def uvm_sequence_codegen(self,uvmtype,sqr,sqr_inst,sqr_fpath):
    seq_item=self.find_seq_item(sqr_inst)
    if not seq_item:
      self.virtual_sequence_codegen(uvmtype,sqr,sqr_inst,sqr_fpath)
      return
    constraint_config_get_members=''
    if seq_item:
      constraint_config_get_members=self.get_constraint_config_get_members(uvmtype,sqr_inst)
    if 'sqr' in sqr:
      name=sqr.replace('sqr','seq')
    elif 'sequencer' in sqr:
      name=sqr.replace('sequencer','seq')
    else:
      name=sqr+'_seq'
    up_seq_item_fifo_tuple=filter(lambda x: x[1].startswith('uvm_tlm_analysis_fifo') and seq_item not in x[1],self.inst2members[sqr_inst])
    up_seq_item_fifo=''
    up_seq_item=''
    if seq_item !='' and up_seq_item_fifo_tuple:
      up_seq_item_fifo=up_seq_item_fifo_tuple[0][0]
      up_seq_item=up_seq_item_fifo_tuple[0][1]
      up_seq_item=up_seq_item[up_seq_item.index('#')+1:].strip()[1:-1]
    handle_down_traffic='''  task handle_down_traffic();
  endtask : handle_down_traffic
'''
    if up_seq_item_fifo!='':
      make_down_req='''  function void make_down_req( ref %(down_req_item)s _down_req_item[], %(up_req_item)s _up_req_item[] );
    $cast(_down_req_item[0].inst,_up_req_item[0].inst);
  endfunction : make_down_req'''%dict(up_req_item=up_seq_item,down_req_item=seq_item)
      if options.layer:
        make_down_req='''  function void make_down_req( ref %(down_req_item)s _down_req_item[], %(up_req_item)s _up_req_item[] );
    byte unsigned stream[];
    byte unsigned stream_q[$];
    foreach (_up_req_item[i]) begin
      `uvm_info(get_type_name(),_up_req_item[i].sprint(),UVM_MEDIUM);
      void'(_up_req_item[i].pack_bytes(stream));
      foreach (stream[j]) stream_q.push_back(stream[j]);
    end

    for (int j =0; j < (p_sequencer.m_seg_count-1); j++)
      for (int i =0; i < p_sequencer.m_mss; i++)
        _down_req_item[j].payload[i]=stream_q[j*p_sequencer.m_mss+i];

    for (int i =(p_sequencer.m_seg_count-1)*p_sequencer.m_mss; i < stream_q.size(); i++)
      _down_req_item[p_sequencer.m_seg_count-1].payload[i-8]=stream_q[(p_sequencer.m_seg_count-1)*p_sequencer.m_mss+i];
  endfunction : make_down_req'''%dict(up_req_item=up_seq_item,down_req_item=seq_item)
      handle_up_items='''%(make_down_req)s
  task handle_up_items();
    %(up_req_item)s   up_req_item[];
    %(down_req_item)s down_req_item[];
    up_req_item=new[p_sequencer.m_compound_count];
    down_req_item=new[p_sequencer.m_seg_count];
    foreach (up_req_item[i]) get_next_up_item( up_req_item[i] );
    foreach (down_req_item[i]) begin
      `uvm_create ( down_req_item[i] )
      down_req_item[i].randomize() with {
%(constraint_config_get_members)s
         } ;
    end
    make_down_req( down_req_item, up_req_item );
    foreach (down_req_item[i]) `uvm_send ( down_req_item[i] )
  endtask : handle_up_items
  virtual task get_next_up_item( ref %(up_req_item)s _item );
    p_sequencer.%(up_seq_item_fifo)s.get(_item);
  endtask : get_next_up_item
  virtual task try_get_next_up_item( ref %(up_req_item)s _item );
    void'(p_sequencer.%(up_seq_item_fifo)s.try_get(_item));
  endtask : try_get_next_up_item
'''%dict(make_down_req=make_down_req,up_seq_item_fifo=up_seq_item_fifo,
constraint_config_get_members=constraint_config_get_members,
up_req_item=up_seq_item,down_req_item=seq_item)
    else:
      handle_up_items='''  task handle_up_items();
    %(down_req_item)s down_req_item;
    `uvm_create ( down_req_item )
    down_req_item.randomize() with {} ;
    `uvm_send ( down_req_item )
  endtask : handle_up_items
'''%dict(down_req_item=seq_item)
    codes='''class %(name)s extends uvm_sequence%(seq_item)s;
  `uvm_object_utils_begin(%(name)s)
  `uvm_object_utils_end
  `uvm_declare_p_sequencer (%(sqr)s)
  function  new(string name="%(name)s");
    super.new(name);
  endfunction : new
  virtual task body();
    handle_down_traffic();
    repeat (p_sequencer.m_repeat_count) handle_up_items();
  endtask :  body
%(handle_up_items)s
%(handle_down_traffic)s
endclass : %(name)s'''%dict(name=name,
seq_item='#(%s)'%(seq_item if seq_item else 'uvm_sequence_item'),
sqr=sqr,
handle_down_traffic=handle_down_traffic,
handle_up_items=handle_up_items,
)
    fpath=os.path.join(os.path.dirname(sqr_fpath),name+'.svh')
    if not os.path.exists(os.path.dirname(sqr_fpath)):
      os.makedirs(os.path.dirname(sqr_fpath))
    self.fpath2name[fpath]=name
    print fpath
    with open(fpath,'w') as fh:
          fh.write('''`ifndef %(name)s__SVH
`define %(name)s__SVH
%(codes)s
`endif // %(name)s__SVH
'''%dict(name=name.upper(),codes=codes))
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
      if not inst:
        p=os.path.basename(p)
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
      codegen_callback=self.uvmtype2callback['uvm_sequencer']
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
      print self.inst2path,p
      if not inst:
        print p
        p=os.path.basename(p)
        inst=next((k for k, v in self.inst2path.items() if v == p), None)
      if inst in self.inst2seq_item:
        seq_item=self.inst2seq_item[inst]
      else:
        seq_item=''
      logger.debug("path %s file %s inst %s"%(p,f,inst))
      if not os.path.exists(fpath):
        bname=os.path.splitext(os.path.basename(fpath))[0]
        if inst=='uvm_test_top':continue
        if self.fname2uvmtype[bname]=='uvm_reg_predictor':
          continue
        if self.fname2uvmtype[bname]=='uvm_reg_block':
          self.uvm_reg_block_codegen(path,'uvm_reg_block',bname,inst)
          continue
        if self.fname2uvmtype[bname]=='uvm_sequencer':
          self.uvm_sequence_codegen('uvm_sequence',bname,inst,fpath)
        codes=self.codegen(bname,inst)
        self.fpath2name[fpath]=bname
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
      if '/' not in p: continue
      f=self.path2file[p] 
      for item in items:
        if ',' in item: item=item.split(',')[0]
        #fpath=os.path.join(path,os.path.join(os.path.dirname(f),'%s.svh'%item))
        fpath=os.path.join(path,os.path.join(os.path.join(path,"seq_items"),'%s.svh'%item))
      if options.layer:
        if item+'.svh' not in self.seq_items_db:
          self.seq_item2file[item]=fpath
      else:
        self.seq_item2file[item]=fpath
    for inst,tasks in self.reset_phase_db.items():
      if inst in self.inst2members:
        viftype=filter(lambda x: x[0]=='vif',self.inst2members[inst])[0][1]
      for task in tasks:
        task=task[0]
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
  typedef enum {PUSH_A=0,PUSH_B,ADD,SUB,MUL,DIV,POP_C} inst_t;  // delete
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
      imports+='\n  import seq_items_pkg::*;'
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

  def create_seq_items_pkg_file(self,path):
    logger=func_logger(level=self.level)
    svhs=[]
    subdirs=[]
    fdir=os.path.join(path,"seq_items")
    for fname in os.listdir(fdir):
      if fname.endswith('svh'):
        svhs.append(fname)
      elif fname.endswith('sv'):
        pass
      else:
        subdirs.append(fname)
    imports='\n'.join(map(lambda x: '  import %s_pkg::*;'%x,subdirs))
    decls='\n'.join(map(lambda x: '\n'.join(map(lambda y: '  typedef class %s;'%y,self.fpath2name[x]))
        if isinstance(self.fpath2name[x],list) else '  typedef class %s;'%self.fpath2name[x]
       ,map(lambda x: os.path.join(fdir,x),svhs)))
    includes='\n'.join(map(lambda x: '  `include "%s"'%x,svhs))
    pkgname='seq_items_pkg'
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
    imports+='\n  import seq_items_pkg::*;'
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
  def create_base_test(self,path,vsqr,array):
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
          
    def sqr2seq(sqr):
      if 'sqr' in sqr:
        seq=sqr.replace('sqr','seq')
      elif 'sequencer' in sqr:
        seq=sqr.replace('sequencer','seq')
      else:
        seq=sqr+'_seq'
      return seq
    depths=set()
    for inst,connects in self.connect_db.items():
      if inst not in filter(lambda x: self.inst2seq_item[x]=='ether_hdr',self.inst2seq_item): continue
      depths.add(inst.count('.'))
      slices=[]
      slicepath(inst,slices,0)
      if len(slices)==1 and slices[0][1]==1:
        self.vsqrinsts.append(inst)
      else:
        fmt=''
        tmps=[]
        for i,(pslice,array_size) in enumerate(slices):
          if array_size > 1:
            fmt+='%s[{}]'%pslice
            tmpps=[]
            if i==0:
              for idx in range(array_size):
                tmps.append('%s[%d]'%(pslice,idx))
            else:
              for idx in range(array_size):
                for t in tmps:
                  t+='%s[%d]'%(pslice,idx)
                  tmpps.append(t)
              tmps=copy.deepcopy(tmpps)
          else:
            if i==0:
              tmps.append(pslice)
            else:
              tmps=map(lambda x: x+pslice,tmps)
        self.vsqrinsts.extend(tmps)
        
    self.vsqrinsts=filter(lambda x: x.count('.')==max(depths), self.vsqrinsts)
    connect_phases=''
    for i,vsqrinst in enumerate(self.vsqrinsts):
      connect_phases+='    m_driver[%d].seq_item_port.connect(%s.seq_item_export);\n'%(i,vsqrinst)
    path=os.path.join(path,'test')
    if os.path.exists(path):
      logger.error("%s dir already existed"%path)
      exit(1)
    os.makedirs(path)
    fpath=os.path.join(path,'base_test.svh')
    self.fpath2name[fpath]='base_test'
    if array > 1:
      with open(fpath,'w') as fh:
        fh.write('''
`ifndef BASE_TEST__SVH
`define BASE_TEST__SVH
class base_test extends uvm_test;
  `uvm_component_utils(base_test)
  %(vsqr)s m_%(vsqr)s[%(array)s];
  test_driver m_driver[%(drv_array)s];

  function new(string name="base_test", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    foreach ( m_%(vsqr)s[i] ) begin
      m_%(vsqr)s[i] = %(vsqr)s::type_id::create($sformatf("m_%(vsqr)s[%%0d]",i), this); 
    end
    foreach ( m_driver[i] ) begin
      m_driver[i] = test_driver::type_id::create($sformatf("m_driver[%%0d]",i), this); 
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
%(connect_phases)s
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    uvm_phase main_phase = phase.find_by_name("main", 0);
    main_phase.phase_done.set_drain_time(this, 1us);
    uvm_top.print_topology();
  endfunction : end_of_elaboration_phase

  task main_phase(uvm_phase phase);
    %(vseq)s m_%(vseq)s[%(array)s];
     
    foreach ( m_%(vseq)s[i] ) begin
      m_%(vseq)s[i]=%(vseq)s::type_id::create($sformatf("m_%(vseq)s[%%0d]",i));
      m_%(vsqr)s[i].print();
    end
    phase.raise_objection(this);
    fork 
      begin
        foreach ( m_%(vseq)s[i] ) begin
          m_%(vseq)s[i].start(m_%(vsqr)s[i]);
        end
      end
    join
    #10;
    phase.drop_objection(this);
  endtask
endclass : base_test
`endif // BASE_TEST__SVH'''%dict(vsqr=vsqr,
vseq=sqr2seq(vsqr),array=array,
drv_array=len(self.vsqrinsts),
connect_phases=connect_phases,
))
    else:
      with open(fpath,'w') as fh:
        fh.write('''
`ifndef BASE_TEST__SVH
`define BASE_TEST__SVH
class base_test extends uvm_test;
  `uvm_component_utils(base_test)
  %(vsqr)s m_%(vsqr)s;
  test_driver m_driver[%(drv_array)s];

  function new(string name="base_test", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_%(vsqr)s = %(vsqr)s::type_id::create("m_%(vsqr)s", this); 
    foreach ( m_driver[i] ) begin
      m_driver[i] = test_driver::type_id::create($sformatf("m_driver[%%0d]",i), this); 
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
%(connect_phases)s
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    uvm_phase main_phase = phase.find_by_name("main", 0);
    main_phase.phase_done.set_drain_time(this, 1us);
    uvm_top.print_topology();
  endfunction : end_of_elaboration_phase

  task main_phase(uvm_phase phase);
    %(vseq)s m_%(vseq)s;
     
    m_%(vseq)s=%(vseq)s::type_id::create("m_%(vseq)s");
    m_%(vsqr)s.print();
    phase.raise_objection(this);
    fork 
      begin
        m_%(vseq)s.start(m_%(vsqr)s);
      end
    join
    #10;
    phase.drop_objection(this);
  endtask
endclass : base_test
`endif // BASE_TEST__SVH'''%dict(vsqr=vsqr,
vseq=sqr2seq(vsqr),
drv_array=len(self.vsqrinsts),
connect_phases=connect_phases,
))
    l2_csqr_inst=filter(lambda x: x.endswith('l2_csqr'),self.insts)[0]
    seq_item=self.find_seq_item(l2_csqr_inst)
    name='test_driver'
    fpath=os.path.join(path,name+'.svh')
    self.fpath2name[fpath]=name
    shutdown_phase=''
    if options.layer:
      shutdown_phase='''
  task shutdown_phase(uvm_phase phase);
    string fname;
    pcap_hdr hdr;
    byte unsigned pcap_q[$];
    byte unsigned bytestream[];
    int unsigned         ts=0;
    int fh;

    hdr=new("hdr");
    hdr.magic_number                  = 32'ha1b2c3d4;
    hdr.version_major                 = 16'h0002;
    hdr.version_minor                 = 16'h0004;
    hdr.thiszone                      = 32'h00000000;
    hdr.sigfigs                       = 32'h00000000;
    hdr.snaplen                       = 32'h0000ffff;
    hdr.network                       = 32'h00000001;
    void'(hdr.pack_bytes(bytestream));
    foreach (bytestream[j]) pcap_q.push_back(bytestream[j]);

    fname=get_full_name();
    fname={fname.substr(13,fname.len()-1),".pcap"};
    fh=$fopen(fname,"w");
    `uvm_info(get_type_name(),$sformatf("queue size %d file name %s",item_q.size(),fname),UVM_MEDIUM);
     
    foreach (item_q[i]) begin
      pcaprec_hdr rec;
      void'(item_q[i].pack_bytes(bytestream));
      rec=new("rec");
      rec.incl_len=bytestream.size();
      rec.orig_len=bytestream.size();
      rec.ts_sec=ts/1000000;
      rec.ts_usec=ts%1000000;
      rec.payload=bytestream;
      void'(rec.pack_bytes(bytestream));
      foreach (bytestream[j]) pcap_q.push_back(bytestream[j]);
      ts+=100;
    end
    foreach (pcap_q[i]) $fwrite(fh,"%c",pcap_q[i]);
    $fclose(fh);
  endtask
'''
    with open(fpath,'w') as fh:
      fh.write('''
`ifndef %(uname)s__SVH
`define %(uname)s__SVH
class %(name)s extends uvm_driver%(seq_item)s;

  // Provide implementations of virtual methods such as get_type_name and create
  `uvm_component_utils(%(name)s)
  %(seq_item_orig)s item_q[$];

  // Constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task main_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);
      `uvm_info(get_type_name(),req.sprint(),UVM_MEDIUM);
      #10;
      // rsp.set_id_info(req);   These two steps are required only if 
      // seq_item_port.put(esp); responce needs to be sent back to sequence
      item_q.push_back(req);
      seq_item_port.item_done();
    end
  endtask
%(shutdown_phase)s
endclass : %(name)s
`endif // %(uname)s__SVH'''%dict(uname=name.upper(),
name=name,
seq_item_orig=seq_item if seq_item else 'uvm_sequence_item',
seq_item='#(%s)'%(seq_item if seq_item else 'uvm_sequence_item'),
shutdown_phase=shutdown_phase,
))
  def create_tbdir(self,path,override):
    logger=func_logger(level=self.level)
    if os.path.exists(path):
      logger.error("%s dir already existed"%path)
      exit(1)
    os.makedirs(path)
    fpath=os.path.join(path,'tb.sv')
    self.fpath2name[fpath]='tb'
    print fpath
    with open(fpath,'w') as fh:
      fh.write('''
module tb;
  `include "uvm_macros.svh"
  import uvm_pkg::*;
  import test_pkg::*;

  initial
  begin
    run_test();
  end
endmodule
''')
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
    if options.layer:
      os.system("svn export http://vi-bugs/svn/pld/trunk/projects/fiji/all_links/verif3/seq_items %s"%path)
    else:
      os.makedirs(path)
    svhs=[]
    svs=[]
    subdirs=[]
    for fname in os.listdir(path):
      if fname.endswith('svh'):
        svhs.append(fname)
      elif fname.endswith('sv'):
        self.svs.append(os.path.join(os.path.basename(path),fname))
      else:
        subdirs.append(fname)
    self.seq_items_db=svhs
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
TOPLEVEL := tb
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
  def create_ex_seq(self,path):
    fpath=os.path.join(path,'seq_examples.svh')
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
  parser=argparse.ArgumentParser(add_help = True, description = "create uvm seq/sqr from xml: xml2vsqrcode.py -xml /home/chi-wei.fu/sandbox/uvm_vsqr/fiji_vsqr_array.xml -dir /home/chi-wei.fu/sandbox/uvm_vsqr/vsqr -layer -debug")
  parser.add_argument('-debug',action='store_true',help='Turn DEBUG output')
  parser.add_argument('-tb',action='store_true',help='Generate testbench')
  parser.add_argument('-dont_create_seq_item',action='store_true',help='Do not create seq item files and use item in seq_items')
  parser.add_argument('-layer',action='store_true',help='upper layer become payload of lower layer')
  parser.add_argument('-xml',action='store',help='testbench xml file')
  parser.add_argument('-dir',action='store',help='save uvm codes in the destinatin directory')
  parser.add_argument('-override',action='store_true',help='written over existing file')
  parser.add_argument('--version', action='version', version='%(prog)s 1.0')
  options=parser.parse_args()
  if options.debug:
    obj=xml2vsqrcode(logging.DEBUG)
    os.system("rm -rf %s"% options.dir)
  else:
    obj=xml2vsqrcode(logging.INFO)
    
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
    print "seq_items_db:",pformat(obj.seq_items_db)
    print "vsqrinsts:",pformat(obj.vsqrinsts)
    print "config_get_db:",pformat(obj.config_get_db)
    print "debug_db:",pformat(obj.debug_db)
