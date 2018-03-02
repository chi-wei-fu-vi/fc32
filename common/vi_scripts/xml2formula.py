#!/usr/bin/env python2.7
from pprint import pprint,pformat
import xml2dict
from pcap_header import *
from oraclegen import *
class xml2formula(object):
  type2value=dict(
    DOUBLE  = 0.0,
    INT     = 0,
    LONG    = 0L,
    STRING  = '',
  )
  nfs3_procname2titlename=dict(
    NULL                        = 'NullProc',
    GETATTR                     = 'GetAttrProc',
    SETATTR                     = 'SetAttrProc',
    LOOKUP                      = 'LookupProc',
    ACCESS                      = 'AccessProc',
    READLINK                    = 'ReadLinkProc',
    READ                        = 'ReadProc',
    WRITE                       = 'WriteProc',
    CREATE                      = 'CreateProc',
    MKDIR                       = 'MkDirProc',
    SYMLINK                     = 'SymLinkProc',
    MKNOD                       = 'MkNodProc',
    REMOVE                      = 'RemoveProc',
    RMDIR                       = 'RmDirProc',
    RENAME                      = 'RenameProc',
    LINK                        = 'LinkProc',
    READDIR                     = 'ReadDirProc',
    READDIRPLUS                 = 'ReadDirPlusProc',
    FSSTAT                      = 'FsStatProc',
    FSINFO                      = 'FsInfoProc',
    PATHCONF                    = 'PathConfProc',
    COMMIT                      = 'CommitProc',
  )
  pmap_procname2titlename=dict(
    PMAPPROC_NULL               = 'NullProc',
    PMAPPROC_SET                = 'SetProc',
    PMAPPROC_UNSET              = 'UnSetProc',
    PMAPPROC_GETPORT            = 'GetPortProc',
    PMAPPROC_DUMP               = 'DumpProc',
    PMAPPROC_CALLIT             = 'CallITProc',
  )
  rpcb_procname2titlename=dict(
    RPCBPROC_SET                = 'SetProc',
    RPCBPROC_UNSET              = 'UnSetProc',
    RPCBPROC_GETADDR            = 'GetAddrProc',
    RPCBPROC_DUMP               = 'DumpProc',
    RPCBPROC_GETTIME            = 'GetTimeProc',
    RPCBPROC_UADDR2TADDR        = 'Uaddr2TaddrProc',
    RPCBPROC_TADDR2UADDR        = 'Taddr2UaddrProc',
    RPCBPROC_CALLIT             = 'CallITProc',
  )
  mnt_procname2titlename=dict(
    MOUNTPROC3_NULL             = 'NullProc',                  # null
    MOUNTPROC3_MNT              = 'MntProc',                   # add mount entry
    MOUNTPROC3_DUMP             = 'DumpProc',                  # return mount entries
    MOUNTPROC3_UMNT             = 'UmntProc',                  # remove mount entry
    MOUNTPROC3_UMNTALL          = 'UmntAllProc',               # remove all mount entries
    MOUNTPROC3_EXPORT           = 'ExportProc',                # return export list
  )
  nlm_procname2titlename=dict(
    NLMPROC4_NULL               = 'NullProc',                   # do nothing
    NLMPROC4_TEST               = 'TestProc',                   # test lock if the monitored lock is available
    NLMPROC4_LOCK               = 'LockProc',                   # establish a monitored lock
    NLMPROC4_CANCEL             = 'CancelProc',                 # cancel an outstanding blocked lock request
    NLMPROC4_UNLOCK             = 'UnLockProc',                 # remove the lock
    NLMPROC4_GRANTED            = 'GrantedProc',                # the callback procedure from the sever to grant the previous lock request
    NLMPROC4_TEST_MSG           = 'TestMsgProc',                # asynchronous RPC and the same function as the NLM4_TEST
    NLMPROC4_LOCK_MSG           = 'LockMsgProc',                # asynchronous RPC and the same function as the NLM4_LOCK
    NLMPROC4_CANCEL_MSG         = 'CancelMsgProc',              # asynchronous RPC and the same function as the NLM4_CANCEL
    NLMPROC4_UNLOCK_MSG         = 'UnLockMsgProc',              # asynchronous RPC and the same function as the NLM4_UNLOCK
    NLMPROC4_GRANTED_MSG        = 'GrantedMsgProc',             # asynchronous RPC and the same function as the NLM4_GRANTED
    NLMPROC4_TEST_RES           = 'TestResProc',                # asynchronous RPC and the return results of the NLM_TEST_MSG to the client
    NLMPROC4_LOCK_RES           = 'LockResProc',                # asynchronous RPC and the return results of the NLM_LOCK_MSG to the client
    NLMPROC4_CANCEL_RES         = 'CancelResProc',              # asynchronous RPC and the return results of the NLM_CANCEL_MSG to the client
    NLMPROC4_UNLOCK_RES         = 'UnLockResProc',              # asynchronous RPC and the return results of the NLM_UNLOCK_MSG to the client
    NLMPROC4_GRANTED_RES        = 'GrantedResProc',             # asynchronous RPC and the return results of the NLM_GRANTED_MSG to the client
    NLMPROC4_SHARE              = 'ShareProc',                  # open the file using the DOS 3.1 with the file-sharing mode
    NLMPROC4_UNSHARE            = 'UnShareProc',                # close the file "share.fh"
    NLMPROC4_NM_LOCK            = 'NmLockProc',                 # non-monitored lock which called by clients that do not run the NSM
    NLMPROC4_FREE_ALL           = 'FreeAllProc',                # informs the server that the client has been rebooted
  )
  nsm_procname2titlename=dict(
    SM_NULL                     = 'NullProc',                   # do nothing
    SM_STAT                     = 'StatProc',                   # see if the NSM agrees to monitor the given host
    SM_MON                      = 'MonProc',                    # initiates the monitoring of the given host
    SM_UNMON                    = 'UnMonProc',                  # stops monitoring the host
    SM_UNMON_ALL                = 'UnMonAllProc',               # stops monitoring all hosts
    SM_SIMU_CRASH               = 'SimuCrashProc',              # simulates a crash. The NSM releases all its current state information and reinitialises itself, incrementing its state varible.
    SM_NOTIFY                   = 'NotifyProc',                 # if a host has a state change, either a crash and reboot or the NSM has processed an SM_SIMU_CRASH call, the local NSM must notify each host on it notify list of the change in state.
  )
  rpc_progname2titlename=dict(
    RPC2_PROG_PMAP2             = 'Pmap2',                  # Port mapper or RPCB
    RPC2_PROG_NFS3              = 'Nfs3',                   # NFSv3
    RPC2_PROG_MNT3              = 'Mnt3',                   # Mountv3
    RPC2_PROG_NLM               = 'Nlm',                    # Network lock manager
    RPC2_PROG_NSM               = 'Nsm',                    # Network status monitor
    RPC2_PROG_NFSACL            = 'NfsAcl',                 # ACL
  )



  def __init__(self, shush = False, vMetrics = False):
    self.NFS3PROC_num_inv=dict((NFS3PROC_num[k], self.nfs3_procname2titlename[k]) for k in NFS3PROC_num)
    self.PMAPPROC_num_inv=dict((PMAPPROC_num[k], self.pmap_procname2titlename[k]) for k in PMAPPROC_num)
    self.RPCBPROC_num_inv=dict((RPCBPROC_num[k], self.rpcb_procname2titlename[k]) for k in RPCBPROC_num)
    self.MNTPROC_num_inv=dict((MOUNTPROC3_num[k], self.mnt_procname2titlename[k]) for k in MOUNTPROC3_num)
    self.SM_num_inv=dict((SM_num[k], self.nsm_procname2titlename[k]) for k in SM_num)
    self.NLMPROC4_num_inv=dict((NLMPROC4_num[k], self.nlm_procname2titlename[k]) for k in NLMPROC4_num)
    self.RPC_num_inv=dict((program_list_num[k], k) for k in program_list_num)
    self.RPC_num_inv=dict((program_list_num[k], self.rpc_progname2titlename[k]) for k in program_list_num)

  def find_container(self,dct,debug=False):
    """
    interfaceDefinition
        ProbeType
        XmlFileFormatVersion
        MetrixVersion
        ProbeIDType
        entityDefinition
        containerDefinition
    """
    self.containers=[]
    self.container2metric={}
    self.container2hist={}
    self.container2key={}
    self.container2vm={}
    self.container2entity={}
    self.entities=[]
    self.entity2key={}
    self.hist2minmax={}
    # parse container
    for l1 in dct['interfaceDefinition']['containerDefinition']:
      if debug:
        print l1['@name']
      container=l1['@name']
      self.containers.append(container)
      self.container2metric[container]=[]
      self.container2hist[container]=[]
      self.container2key[container]=[]
      self.container2vm[container]=[]
      # metric
      if isinstance(l1['Metric'],list):
        for l2 in l1['Metric']:
          if debug:
            print ' '*4+l2['@name']
          metric=l2['@name']
          vtype=l2['@valueType']
          print l2
          if 'description' in l2:
            desc=l2['description']
          else:
            desc=''
          self.container2metric[container].append((metric,vtype,desc))
      else:
        if debug:
          print ' '*4+l1['Metric']['@name']
        metric=l1['Metric']['@name']
        vtype=l1['Metric']['@valueType']
        if 'description' in l1['Metric']:
          desc=l1['Metric']['description']
        self.container2metric[container].append((metric,vtype,desc))
      # histogram
      if 'Histogram' in l1 and isinstance(l1['Histogram'],list):
        for l2 in l1['Histogram']:
          if debug:
            print ' '*4+l2['@name']
          hist=l2['@name']
          vtype=l2['@valueType']
          print l2
          if 'description' in l2:
            desc=l2['description']
          else:
            desc=''
          histbin=[]
          for bucket in l2['bin']:
            if '@max' not in bucket:
              histbin.append((bucket['@name'],int(bucket['@min']),'inf'))
              self.hist2minmax[bucket['@name']]=(int(bucket['@min']),'inf')
            else:
              histbin.append((bucket['@name'],int(bucket['@min']),int(bucket['@max'])))
              self.hist2minmax[bucket['@name']]=(int(bucket['@min']),int(bucket['@max']))
           
            
          self.container2hist[container].append((hist,vtype,desc,histbin))
      # key
      if debug:
        print ' '*4+'# key'
      if isinstance(l1['Key'],list):
        for l2 in l1['Key']:
          if debug:
            print ' '*4+l2['@name']
          metric=l2['@name']
          vtype=l2['@valueType']
          self.container2key[container].append((metric,vtype))
      else:
        if debug:
          print ' '*4+l1['Key']['@name']
        metric=l1['Key']['@name']
        vtype=l1['Key']['@valueType']
        self.container2key[container].append((metric,vtype))
      # entity
      if debug:
        print ' '*4+'# entity'
        print ' '*4+l1['entityJoinInfo']['@entityDefinition']
      entity=l1['entityJoinInfo']['@entityDefinition']
      for l3 in l1['entityJoinInfo']['joinKey']:
        if debug:
          print ' '*8+l3['@containerField']
      self.container2entity[container]=entity
      # virtual metric
      if 'VirtualMetric' in l1:
        if debug:
          print ' '*4+'# virtual metric'
        if isinstance(l1['VirtualMetric'],list):
          for l2 in l1['VirtualMetric']:
            if debug:
              print ' '*4+l2['@name']
            vm=l2['@name']
            vtype=l2['@valueType']
            self.container2vm[container].append((vm,vtype))
        else:
          if debug:
            print ' '*4+l1['VirtualMetric']['@name']
          vm=l1['VirtualMetric']['@name']
          vtype=l1['VirtualMetric']['@valueType']
          self.container2vm[container].append((vm,vtype))
    # entity
    for l1 in dct['interfaceDefinition']['entityDefinition']:
      if debug:
        print l1['@name']
      entity=l1['@name']
      self.entities.append(entity)
      self.entity2key[entity]=[]
      for l2 in l1['Key']:
        if debug:
          print ' '*4+l2['@name']
        key=l2['@name']
        vtype=l2['@valueType']
        self.entity2key[entity].append((key,vtype))
       
        
  def run_xml2dict(self,fname,debug=False):
    """
    """
    obj=xml2dict.xml2dict(coding='utf-8')
    root=obj.readxml(fname)
    dct=obj.root2dict(root)
    # find container
    self.find_container(dct,debug=debug)
    # create container database
    self.db=dict(
      containers        = dict(),
      end_interval      = 0,
      start_interval    = 0,
    )
    self.entitydb={}
    self.keydb={}
    self.keys={}
    self.metric2desc={}
    for container in self.containers:
      self.db['containers'][container]={}
      self.entitydb[container]={}
      self.keydb[container]={}
      self.keys[container]=[]
      self.metric2desc[container]={}
    # create metric database
    for container in self.containers:
      # metric
      for metric,vtype,desc in self.container2metric[container]:
        self.db['containers'][container][metric]=self.type2value[vtype]
        if metric.endswith('Proc'):
          self.metric2desc[container][metric]=desc
      # virtual metric
      for vm,vtype in self.container2vm[container]:
        if True: # include vm
#        if False: # exclude vm
          self.db['containers'][container][vm]=self.type2value[vtype]
    pprint(self.db)
    # create keydb
    if debug:
      print "# key db"
    for container in self.containers:
      # key
      for key,vtype in self.container2key[container]:
        self.keydb[container][key]=self.type2value[vtype]
        if key not in self.keys[container]:
          self.keys[container].append(key)
    pprint(self.keydb)
    if debug:
      print "# entity db"
    # create entitydb
    for container in self.containers:
      entity=self.container2entity[container]
      for key,vtype in self.entity2key[entity]:
        if key == 'VlanID':
          self.entitydb[container][key]=65535
        # skip probe_id
        elif key == 'probe_id':
          pass
          #self.entitydb[container][key]=self.type2value[vtype]
        elif key == 'Port':
          self.entitydb[container][key]=1
        else:
          self.entitydb[container][key]=self.type2value[vtype]
    pprint(self.entitydb)
    
  def extract_formula(self,lines,debug=False):
    """
    """
    self.formulas=[]
    self.virtualmetrics=[]
    while lines:
      line=lines.pop(0)
      line=line.strip()
      if line.startswith('<VirtualMetric'):
        idx=line.index('name="')
        metric=line[idx+6:idx+6+line[idx+6:].index('"')]
        self.virtualmetrics.append(metric)
      if line.startswith('<formula>'):
        formula=''
        while True:
          line=lines.pop(0)
          line=line.strip()
          if line.startswith('<\x2fformula>'):
            break
          if line.startswith('<Metric'):
            idx=line.index('name="')
            metric=line[idx+6:idx+6+line[idx+6:].index('"')]
            formula+=metric
          else:
            if line.startswith('\x26amp;'):
              idx=line.index("'")
              line=' & 0b' + line[idx+1:line.rindex("'")]
            formula+=line
        self.formulas.append(formula)
    self.vm2formula=dict(zip(obj.virtualmetrics,obj.formulas))
    if debug:
      pprint(zip(obj.virtualmetrics,obj.formulas))
          

  def readxml(self,fname):
    """
    """
    with open(fname,'r') as fh:
      lines=fh.readlines()
    return lines
  def codegen(self,fname,debug=False):
    """
    """
    self._proc2metric(debug=debug)
    with open('nas_metric_header.py','w') as fh:
      fh.write('''#!/usr/bin/env python2.7
import ctypes
''')
      fh.write('container2metricdb={\n')
      fh.write('\n'.join(map(lambda x: ' '*20+x,pformat(self.db).replace('{',' ',1).split('\n'))))
      fh.write('\n')
      fh.write('container2keydb={\n')
      fh.write('\n'.join(map(lambda x: ' '*17+x,pformat(self.keydb).replace('{',' ',1).split('\n'))))
      fh.write('container2hist={\n')
      fh.write('\n'.join(map(lambda x: ' '*17+x,pformat(self.container2hist).replace('{',' ',1).split('\n'))))
      # proc number to proc name
      fh.write('\nNFS3PROC_num_inv={\n')
      fh.write('\n'.join(map(lambda x: ' '*17+x,pformat(self.NFS3PROC_num_inv).replace('{',' ',1).split('\n'))))
      fh.write('\nPMAPPROC_num_inv={\n')
      fh.write('\n'.join(map(lambda x: ' '*17+x,pformat(self.PMAPPROC_num_inv).replace('{',' ',1).split('\n'))))
      fh.write('\nRPCBPROC_num_inv={\n')
      fh.write('\n'.join(map(lambda x: ' '*17+x,pformat(self.RPCBPROC_num_inv).replace('{',' ',1).split('\n'))))
      fh.write('\nMNTPROC_num_inv={\n')
      fh.write('\n'.join(map(lambda x: ' '*17+x,pformat(self.MNTPROC_num_inv).replace('{',' ',1).split('\n'))))
      fh.write('\nSM_num_inv={\n')
      fh.write('\n'.join(map(lambda x: ' '*17+x,pformat(self.SM_num_inv).replace('{',' ',1).split('\n'))))
      fh.write('\nRPC_num_inv={\n')
      fh.write('\n'.join(map(lambda x: ' '*17+x,pformat(self.RPC_num_inv).replace('{',' ',1).split('\n'))))
      fh.write('\nRPC_num_inv={\n')
      fh.write('\n'.join(map(lambda x: ' '*17+x,pformat(self.RPC_num_inv).replace('{',' ',1).split('\n'))))
      fh.write('\nNLMPROC4_num_inv={\n')
      fh.write('\n'.join(map(lambda x: ' '*17+x,pformat(self.NLMPROC4_num_inv).replace('{',' ',1).split('\n'))))
      fh.write('\nproc2metric={\n')
      fh.write('\n'.join(map(lambda x: ' '*17+x,pformat(self.proc2metric).replace('{',' ',1).split('\n'))))
      fh.write('\ncontainer2vm={\n')
      fh.write('\n'.join(map(lambda x: ' '*17+x,pformat(self.container2vm).replace('{',' ',1).split('\n'))))
      fh.write('\nvm2formula={\n')
      fh.write('\n'.join(map(lambda x: ' '*17+x,pformat(self.vm2formula).replace('{',' ',1).split('\n'))))

    with open(fname,'w') as fh:
      fh.write(self._header(debug=debug))
      fh.write(self._init(debug=debug))
      fh.write(self._DplHealth(debug=debug))
      fh.write(self._IPAddressDnsMap(debug=debug))
      fh.write(self._Link(debug=debug))
      fh.write(self._NFSFlowMetrics(debug=debug))
      fh.write(self._NFSHotFileAttr(debug=debug))
      fh.write(self._NFSHotFileMetrics(debug=debug))
      fh.write(self._NLMFlowMetrics(debug=debug))
      fh.write(self._RPCFlowMetrics(debug=debug))
      fh.write(self._SFPDiag(debug=debug))
      fh.write(self._TCPFlowMetrics(debug=debug))

      fh.write(self._plop_StatsPkg(debug=debug))
      fh.write(self._find_file_handle(debug=debug))
      fh.write(self._update_vm(debug=debug))
      fh.write(self._payload_size(debug=debug))
      fh.write(self._tail(debug=debug))
    
  def _normalize_procname(self,container,proc,debug=False):
    """
    """
    if container == 'TCPFlowMetrics':
      pass
    elif container == 'IPAddressDnsMap':
      pass
    elif container == 'NLMFlowMetrics':
      if proc not in self.NLMPROC4_num_inv.values():
        print "Error: could not find nlm proc",proc
        exit(-1) 
      pass
    elif container == 'DplHealth':
      pass
    elif container == 'Link':
      pass
      pass
    elif container == 'SFPDiag':
      pass
    elif container == 'NFSFlowMetrics' or container == 'NFSHotFileAttr' or container == 'NFSHotFileMetrics':
      if proc not in self.NFS3PROC_num_inv.values():
        fs=sorted(filter(lambda x: x.lower().startswith(proc),self.NFS3PROC_num_inv.values()),key=len)
        proc=fs[0]
    elif container == 'RPCFlowMetrics':
      pass
    return proc

  def _proc2metric(self,debug=False):
    """
    """
    self.not_other_procs=set()
    self.proc2metric={}
    for container,m2desc in self.metric2desc.items():
      for metric,desc in m2desc.items():
        if metric.endswith('Proc'):
          if metric=='OtherProc': continue
          if   desc.startswith('Count of calls:'):
            desc=desc[15:]
          elif desc.startswith('Count of procedures:'):
            desc=desc[20:]
          elif desc.startswith('Count of procedure calls:'):
            desc=desc[25:]
          elif desc.startswith('Count of ') and desc.endswith(' calls'):
            desc=desc[9:-6]
          else:
            desc=''
          desc=desc.replace('and',' ').replace(',',' ').strip()
          for proc in desc.split():
            nproc=self._normalize_procname(container,proc)
            if nproc in self.proc2metric:
              if self.proc2metric[nproc]!=metric:
                print "Error: contradictory in proc mapping",nproc,self.proc2metric[nproc],metric
                exit(-1)
            else:
              self.proc2metric[nproc]=metric
            self.not_other_procs.update([nproc])
  def _init(self,debug=False):
    """
    """
    return '''
class nas_oracle(object):

  def __init__(self, shush = False, vMetrics = False, endian='little',fsindex=3,debug=False):
    """
    """
    self.shush=shush
    self.endian=endian
    self.fsindex=fsindex
%s
  def parse_pcap(self,fname,tcp_only=False):
    """
    """
    prog2port={100000 : 111, # pmap
               100003 : 2049, # nfs3
               100005 : 0, # mnt3
               100021 : 0, # nlm
               100024 : 0, # nsm
               100227 : 0} # nfsacl

    portscanobj=pcap2portmap(fname)
    portscanobj.parse_data()
    portmap=portscanobj.prog2port
    for k,v in portmap.items():
      prog2port[k]=v
    self.tcpoleobj=pcap2tcpole(fname,prog2port=prog2port,tcp_only=tcp_only,debug=False)
    self.tcpoleobj.parse_data(debug=False)
    self.pcapobj=pcap2l4stat('msgtest.pcap',prog2port=prog2port,tcp_only=tcp_only,debug=False)
    self.pcapobj.parse_data(debug=False)
    if not self.shush:
      print self.pcapobj
'''%('\n'.join(map(lambda x: '    self.key2%s={}'%x,self.db['containers'])))


  def _header(self,debug=False):
    """
    """
    return '''#!/usr/bin/env python2.7
import copy
import json
from nas_metric_header import *
from pprint import pprint
from pcap2l4stat import *
from pcap_header import *
from pcap2portmap import *
from pcap2tcpole import *

#============================================================
# Suppress Console-Noisy Functions
#============================================================
# borrowed from http://stackoverflow.com/questions/2828953/silence-the-stdout-of-a-function-in-python-without-trashing-sys-stdout-and-resto

import contextlib

class DummyFile(object):
  def write(self, x): pass

@contextlib.contextmanager
def nostdout():
  save_stdout = sys.stdout
  sys.stdout = DummyFile()
  yield
  sys.stdout = save_stdout

#=============================================================
'''
  def _plop_StatsPkg(self,debug=False):
    return '''
  def plop_StatsPkg(self):
    """ 
    """ 
    StatsPkg=copy.deepcopy(container2metricdb)
%s
'''%('\n'.join(map(lambda x: '''
    StatsPkg['containers']['{0}']=self.key2{0}'''.format(x),self.db['containers'])))
  def _update_vm(self,debug=False):
    variable=''
    variable+= '''
  def update_vm(self,containername,statdb,endtimestamp=[1],timestamp=[0]):
    """
    """
'''
    for container,metrics in self.container2vm.items():
      if len(metrics)>0:
        variable+='\n'+ ' '*4+'''if containername == '%s':'''%container
        variable+=self.key2vm_gen(container,tab=' '*6,debug=False)
    return variable
  def _find_file_handle(self,debug=False):
    return '''
  def find_file_handle(self,nfsdb):
    """
    """
    if nfsdb==None:
      return '00'*28
    else:
      tuples=filter(lambda x: isinstance(x,tuple),nfsdb)
      fh='00'*28
      for k,v in tuples:
        if k=='File Handle':
          return fh
'''
  def _payload_size(self,debug=False):
    """
    """
    return '''
  @staticmethod
  def payload_size(db):
    return db['payload_sz']
'''
  def _tail(self,debug=False):
    return '''
if __name__=='__main__':
  import sys
  vMetrics = True
  shush = False
  writeJson = False
  # Parse the command line arguments
  if len(sys.argv) < 2:
    print "Incorrect Usage, Type -h or -help for help."
    exit()
  elif len(sys.argv) == 2:
    path = sys.argv[1] 
  elif len(sys.argv) > 2:
    i = 1
    while i < len(sys.argv):
      if sys.argv[i] == "-w":
        i += 1
        writeJson = True
        vMetrics = False
        filePath = sys.argv[i]
      elif sys.argv[i] == "-r":
        i += 1
        path = sys.argv[i]
      elif sys.argv[i] == "-s":
        shush = True
        writeJson = True
        vMetrics = False
      elif sys.argv[i] == "-m":
        vMetrics = False
      elif sys.argv[i] == "-h" or sys.argv[i] == "-help":
        print "Usage: nas_oracle <OPTIONS>"
        print "Optional Arguments"
        print "-w [PATH]   Path to directory that StatsPkg files will be written to. Otherwise, write to current directory."
        print "            Using either this flag with a directory, or the -s flag, generates a json file."
        print "-r [PATH]   Path to directory containing pcaps to be analyzed. Otherwise, read from current directory."
        print "-s          Shush console output, generate StatsPkg json file instead."
        print "-m          Exclude virtual metrics in extracted data."
        print "Alternatively, nas_oracle <filename> will show the extracted information in console without generating a file."
        print "NOTE: generating a json file excludes any virtual metrics, as virtual metrics are not part of the StatsPkg."
        exit()
      else:
        print "Incorrect Usage, Type -h or -help for help."
        exit()
      i += 1

  # Default paths
  try:
    filePath
  except NameError:
    filePath = "."
  try:
    path
  except NameError:
    path = "."

  # Turn relative paths into absolute paths
  path = os.path.abspath(path)
  filePath = os.path.abspath(filePath)

  ## Error Checking ##
  failed = False

  # Check if input path exists
  if not os.path.exists( path ):
    print "{0} Input path '{1}' does not exist...".format( ERROR, path )
    failed = True

  # Check if output path provided exists
  if not os.path.exists( filePath ):
    print "{0} Output path '{1}' does not exist...".format( ERROR, filePath )
    failed = True

  # There was an error during arg processing
  if failed:
    sys.exit(0)

  # Assuming path exists, it's either a directory or file
  # If it's a directory, iterate over the files in directory that match
  if os.path.isdir(path):
    files = []
    for some_file in sorted( os.listdir(path) ):
      if some_file.endswith('.pcap') or some_file.endswith('.pcapng'):
        files.append( some_file )
  elif os.path.isfile(path) and (path.endswith('.pcap') or path.endswith('.pcapng')):
    files = [ path ]
  else:
    print "Unexpected input path type, no analysis."
    sys.exit(0)

  for pcap_file in files:

    obj=nas_oracle(shush=shush,vMetrics=vMetrics)
    # delete obj.find_dict()
    #pprint(obj.finddb)
    #pprint(obj.db)
    obj.parse_pcap(pcap_file,tcp_only=False)
    obj.extract_DplHealth()
    obj.extract_IPAddressDnsMap()
    obj.extract_Link()
    obj.extract_NFSFlowMetrics()
    obj.extract_NFSHotFileAttr()
    obj.extract_NFSHotFileMetrics()
    obj.extract_NLMFlowMetrics()
    obj.extract_RPCFlowMetrics()
    obj.extract_SFPDiag()
    obj.extract_TCPFlowMetrics()


    if writeJson:
      StatsPkg = obj.plop_StatsPkg()

      #  Set name as "<outfile path>\<pcapname>.oracle.json"
      jsonFileName = os.path.join(filePath,"{0}.oracle.json".format( os.path.basename(pcap_file).split(".")[0] ))
      with open(jsonFileName,'w') as jsonf:
        json.dump(StatsPkg, jsonf, sort_keys=True, indent=4, separators=(',', ': '))
'''

  def _DplHealth(self,debug=False):
    return '''
  def extract_DplHealth(self,debug=False):
    """
    """
'''
  def _IPAddressDnsMap(self,debug=False):
    return '''
  def extract_IPAddressDnsMap(self,debug=False):
    """
    """
'''
  def _Link(self,debug=False):
    return '''
  def extract_Link(self,debug=False):
    """
    """
'''
  def keyid_gen(self,containername,tab=' '*2,call=True,reply=False,debug=False):
    """
        if call:
          keys.append("extract_fsid_from_file_handle(self.find_file_handle(tdb['nfs']),endian=self.endian,fsindex=self.fsindex,debug=False) if filehandle_in_tdb else %d"%default_value)
    """
    print self.keydb[containername]
    print self.keys[containername]
    variables=''
    keys=[]
    for key in self.keys[containername]:
      default_value=self.keydb[containername][key]
      if   key=='SourceIP':
        if call:
          keys.append("tdb['ip'].saddr")
        if reply:
          keys.append("tdb['ip'].daddr")
      elif key=='DestinationIP':
        if call:
          keys.append("tdb['ip'].daddr")
        if reply:
          keys.append("tdb['ip'].saddr")
      elif key=='IP':
        keys.append("tdb['ip'].daddr")
      elif key=='SourceMAC':
        if call:
          keys.append("longint_from_bytes(tdb['ether'].ether_shost,byteorder='big',signed=False)")
        if reply:
          keys.append("longint_from_bytes(tdb['ether'].ether_dhost,byteorder='big',signed=False)")
      elif key=='DestinationMAC':
        if call:
          keys.append("longint_from_bytes(tdb['ether'].ether_dhost,byteorder='big',signed=False)")
        if reply:
          keys.append("longint_from_bytes(tdb['ether'].ether_shost,byteorder='big',signed=False)")
      elif key=='VlanID':
        keys.append("tdb['vlan'][0].vlanid if tdb['vlan'] is not None else %d"%default_value)
      elif key=='FsID':
        if call:
          variables+='\n'+tab+"file_handle=self.find_file_handle(mdb['nfs'])"
          variables+='\n'+tab+'%s=%s'%(key,'extract_fsid_from_file_handle(file_handle,endian=self.endian,fsindex=self.fsindex,debug=False)')
        if reply:
          variables+='\n'+tab+"file_handle=self.find_file_handle(self.pcapobj.pcapdb[mdb['call msgno'][0]-1]['msg'][mdb['call msgno'][1]-1]['nfs'])"
          variables+='\n'+tab+'%s=%s'%(key,'extract_fsid_from_file_handle(file_handle,endian=self.endian,fsindex=self.fsindex,debug=False)')
        keys.append("FsID")
      elif key=='FileID':
        variables+='\n'+tab+'%s=%d'%(key,default_value)
        keys.append("FileID")
      elif key=='UserID':
        variables+='\n'+tab+'%s=%d'%(key,default_value)
        keys.append("UserID")
    return variables+'\n'+tab+'keyid=(%s)'%(",\n".join(keys))
  def key2vm_gen(self,containername,tab=' '*2,debug=False):
    """
    vmfuncs:
IOps
Ratio
SRTMean
    vmspecials:
NonReadWriteRatio
OtherProcIOps
OtherProcRatio
OtherProcSRTMean
SRTMean
    """
    variables=''
    funcs=set()
    specials=set()
    vmfuncs=set()
    vmspecials=set()
    for metric in self.db['containers'][containername].keys():
      metricnames=filter(lambda x: metric.startswith(x),self.proc2metric.values())
      if len(metricnames) > 0:
        if metric in zip(*self.container2vm[containername])[0]:
          vmfuncs.update([metric[max(map(lambda x: len(x),metricnames)):]])
        else:
          funcs.update([metric[max(map(lambda x: len(x),metricnames)):]])
      else:
        if metric in zip(*self.container2vm[containername])[0]:
          vmspecials.update([metric])
        else:
          specials.update([metric])
    if debug:    
      print funcs
      print vmfuncs
      print specials
      print vmspecials
    metrics=list(set(self.proc2metric.values()))
    # first pass (find metrics used in vm calculation)
    vms=[]
    for func in sorted(vmfuncs):
      for metricname in metrics:
        if '%s%s'%(metricname,func) in self.vm2formula:
          vms.append('%s%s'%(metricname,func))
    for func in sorted(vmspecials):
      if func in self.vm2formula:
        vms.append(func)
    metrics_in_formula=[]
    for vm in vms:
      formula=self.vm2formula[vm]
      operands=formula.replace('/',' ').replace('(',' ').replace(')',' ').replace('-',' ').replace('+',' ')
      for f in operands.split():
        if f in self.db['containers'][containername]:
          metrics_in_formula.append(f)
    for metricname in metrics_in_formula:
      variables+='\n'+tab+'''  {0}=statdb['{0}']'''.format(metricname)
          

    # second pass
    variables+='\n'+tab+'# virtual metric'
    for func in sorted(vmfuncs):
      for metricname in metrics:
        if '%s%s'%(metricname,func) in self.vm2formula:
          variables+='\n'+tab+'''  statdb['{0}{1}']={2}'''.format(metricname,func,self.vm2formula['%s%s'%(metricname,func)])
    variables+='\n'+tab+'# func virtual metric'
    for func in sorted(vmspecials):
      variables+='\n'+tab+'''  statdb['{0}']={1}'''.format(func,self.vm2formula[func])
      
    return variables
  def key2metric_gen(self,containername,tab=' '*2,call=True,reply=False,debug=False):
    """
    funcs:
CurPendProcedures
Error
MaxPendProcedures
MinPendProcedures
PayloadBytes
SRTMax
SRTMin
SRTTotal
Success

    specials:
CurPendProcedures
MaxPendProcedures
MinPendProcedures
OtherProc
OtherProcCurPendProcedures
OtherProcError
OtherProcMaxPendProcedures
OtherProcMinPendProcedures
OtherProcPayloadBytes
OtherProcSRTMax
OtherProcSRTMin
OtherProcSRTTotal
OtherProcSuccess
ReadPayloadBytesHistogramB[17:0]
ReadSRTHistogramB[19:0]
SRTMax
SRTMin
SRTTotal
WritePayloadBytesHistogramB[17:0]
WriteSRTHistogramB[19:0]
    """
    variables=''
    funcs=set()
    specials=set()
    vmfuncs=set()
    vmspecials=set()
    for metric in self.db['containers'][containername].keys():
      if containername=='RPCFlowMetrics':
        metricnames=filter(lambda x: metric.startswith(x),self.RPC_num_inv.values())
      else:
        metricnames=filter(lambda x: metric.startswith(x),self.proc2metric.values())
      if len(metricnames) > 0:
        if len(self.container2vm[containername])>0:
          if metric in zip(*self.container2vm[containername])[0]:
            vmfuncs.update([metric[max(map(lambda x: len(x),metricnames)):]])
          else:
            funcs.update([metric[max(map(lambda x: len(x),metricnames)):]])
        else:
          funcs.update([metric[max(map(lambda x: len(x),metricnames)):]])
      else:
        if len(self.container2vm[containername])>0:
          if metric in zip(*self.container2vm[containername])[0]:
            vmspecials.update([metric])
          else:
            specials.update([metric])
        else:
          specials.update([metric])
    if debug:    
      print funcs
      print vmfuncs
      print specials
      print vmspecials
    if containername=='RPCFlowMetrics':
      metrics=self.RPC_num_inv.values()
    else:
      metrics=list(set(self.proc2metric.values()))
    # implement func
    variables+='\n'+tab+'  # metric'
    lines=[]
    variables+='\n'+tab+'''if True:'''
    for func in sorted(funcs):
      if call:
        if 'SRTMax' in func:
          variables+='\n'+tab+'''  self.key2{1}[keyid]['%s{0}'%metricname]=max(self.key2{1}[keyid]['%s{0}'%metricname],resp_time)'''.format(func,containername)
        elif 'SRTMin' in func:
          variables+='\n'+tab+'''  self.key2{1}[keyid]['%s{0}'%metricname]=min(self.key2{1}[keyid]['%s{0}'%metricname],resp_time)'''.format(func,containername)
        elif 'SRTTotal' in func:
          variables+='\n'+tab+'''  self.key2{1}[keyid]['%s{0}'%metricname]+=resp_time'''.format(func,containername)
        else:
          variables+='\n'+tab+'''  self.key2{1}[keyid]['%s{0}'%metricname]+=1'''.format(func,containername)
      if reply:
        if 'SRTMax' in func:
          variables+='\n'+tab+'''  self.key2{1}[keyid]['%s{0}'%metricname]=max(self.key2{1}[keyid]['%s{0}'%metricname],resp_time)'''.format(func,containername)
        elif 'SRTMin' in func:
          variables+='\n'+tab+'''  self.key2{1}[keyid]['%s{0}'%metricname]=min(self.key2{1}[keyid]['%s{0}'%metricname],resp_time)'''.format(func,containername)
        elif 'SRTTotal' in func:
          variables+='\n'+tab+'''  self.key2{1}[keyid]['%s{0}'%metricname]+=resp_time'''.format(func,containername)
        else:
          variables+='\n'+tab+'''  self.key2{1}[keyid]['%s{0}'%metricname]+=1'''.format(func,containername)
    variables+='\n'+tab+'  # special metric'
    readpayloads=[]
    writepayloads=[]
    readsrts=[]
    writesrts=[]
    for func in sorted(specials):
      if 'ReadPayloadBytesHistogram' in func:
        (minv,maxv)=self.hist2minmax[func]
        readpayloads.append((minv,maxv,func))
      elif 'WritePayloadBytesHistogram' in func:
        (minv,maxv)=self.hist2minmax[func]
        writepayloads.append((minv,maxv,func))
      elif 'ReadSRTHistogram' in func:
        (minv,maxv)=self.hist2minmax[func]
        readsrts.append((minv,maxv,func))
      elif 'WriteSRTHistogram' in func:
        (minv,maxv)=self.hist2minmax[func]
        writesrts.append((minv,maxv,func))
      else:
        if call:
          if 'SRTMax' in func:
            variables+='\n'+tab+'''  self.key2{1}[keyid]['{0}']=max(self.key2{1}[keyid]['{0}'],resp_time)'''.format(func,containername)
          elif 'SRTMin' in func:
            variables+='\n'+tab+'''  self.key2{1}[keyid]['{0}']=min(self.key2{1}[keyid]['{0}'],resp_time)'''.format(func,containername)
          elif 'SRTTotal' in func:
            variables+='\n'+tab+'''  self.key2{1}[keyid]['{0}']+=resp_time'''.format(func,containername)
          else:
            variables+='\n'+tab+'''  self.key2{1}[keyid]['{0}']+=1'''.format(func,containername)
        if reply:
          if 'SRTMax' in func:
            variables+='\n'+tab+'''  self.key2{1}[keyid]['{0}']=max(self.key2{1}[keyid]['{0}'],resp_time)'''.format(func,containername)
          elif 'SRTMin' in func:
            variables+='\n'+tab+'''  self.key2{1}[keyid]['{0}']=min(self.key2{1}[keyid]['{0}'],resp_time)'''.format(func,containername)
          elif 'SRTTotal' in func:
            variables+='\n'+tab+'''  self.key2{1}[keyid]['{0}']+=resp_time'''.format(func,containername)
          else:
            variables+='\n'+tab+'''  self.key2{1}[keyid]['{0}']+=1'''.format(func,containername)
    for i,(minv,maxv,func) in enumerate(sorted(readpayloads)):
      if i == 0:
        variables+='\n'+tab+'''  if   payload_sz <= {0}:'''.format(maxv)
      elif maxv=='inf':
        variables+='\n'+tab+'''  else:'''
      else:
        variables+='\n'+tab+'''  elif payload_sz <= {0}:'''.format(maxv)
      if call:
        variables+='\n'+tab+'''    self.key2{1}[keyid]['{0}']+=1'''.format(func,containername)
      if reply:
        variables+='\n'+tab+'''    self.key2{1}[keyid]['{0}']+=1'''.format(func,containername)
    for i,(minv,maxv,func) in enumerate(sorted(writepayloads)):
      if i == 0:
        variables+='\n'+tab+'''  if   payload_sz <= {0}:'''.format(maxv)
      elif maxv=='inf':
        variables+='\n'+tab+'''  else:'''
      else:
        variables+='\n'+tab+'''  elif payload_sz <= {0}:'''.format(maxv)
      if call:
        variables+='\n'+tab+'''    self.key2{1}[keyid]['{0}']+=1'''.format(func,containername)
      if reply:
        variables+='\n'+tab+'''    self.key2{1}[keyid]['{0}']+=1'''.format(func,containername)
    for i,(minv,maxv,func) in enumerate(sorted(readsrts)):
      if i == 0:
        variables+='\n'+tab+'''  if   resp_time <= {0}:'''.format(maxv)
      elif maxv=='inf':
        variables+='\n'+tab+'''  else:'''
      else:
        variables+='\n'+tab+'''  elif resp_time <= {0}:'''.format(maxv)
      if call:
        variables+='\n'+tab+'''    self.key2{1}[keyid]['{0}']+=1'''.format(func,containername)
      if reply:
        variables+='\n'+tab+'''    self.key2{1}[keyid]['{0}']+=1'''.format(func,containername)
    for i,(minv,maxv,func) in enumerate(sorted(writesrts)):
      if i == 0:
        variables+='\n'+tab+'''  if   resp_time <= {0}:'''.format(maxv)
      elif maxv=='inf':
        variables+='\n'+tab+'''  else:'''
      else:
        variables+='\n'+tab+'''  elif resp_time <= {0}:'''.format(maxv)
      if call:
        variables+='\n'+tab+'''    self.key2{1}[keyid]['{0}']+=1'''.format(func,containername)
      if reply:
        variables+='\n'+tab+'''    self.key2{1}[keyid]['{0}']+=1'''.format(func,containername)
    for i,metric in enumerate(metrics+['OtherProc'] if containername.startswith('NFS') else []):
      if i == 0:
        variables+='\n'+tab+'''if   metricname == '{0}':'''.format(metric)
      else:
        variables+='\n'+tab+'''elif metricname == '{0}':'''.format(metric)
      variables+='\n'+tab+'''  pass'''
    variables+='\n'+tab+'''else:'''
    variables+='\n'+tab+'''  pass'''
      
    return variables
  def _NFSFlowMetrics(self,debug=False):
    return '''
  def extract_NFSFlowMetrics(self,debug=False):
    """
    """
    if self.pcapobj.prog2port[program_list_num['RPC2_PROG_NFS3']]==0: return
    for tdb in self.pcapobj.pcapdb:
      if len(tdb['msg'])==0: continue
      if self.pcapobj.prog2port[program_list_num['RPC2_PROG_NFS3']] != 0 and \
         (tdb['l4'].dest==self.pcapobj.prog2port[program_list_num['RPC2_PROG_NFS3']] or \
         tdb['l4'].source==self.pcapobj.prog2port[program_list_num['RPC2_PROG_NFS3']]):
        for mdb in tdb['msg']:
          mtype= mdb['rpc'][0].mtype
          if mtype==msg_type_num['RPC2_MSG_TYPE_CALL']: # call
            vers= mdb['rpc'][1].vers
            rpc_version= mdb['rpc'][1].rpc_version
            proc= mdb['rpc'][1].proc
            prog= mdb['rpc'][1].prog
            if prog==program_list_num['RPC2_PROG_NFS3'] and rpc_version==2 and vers==3 and proc in NFS3PROC_num_inv.keys():
              file_handle=self.find_file_handle(mdb['nfs'])
              FsID=extract_fsid_from_file_handle(file_handle,endian=self.endian,fsindex=self.fsindex,debug=False)
              keyid=(tdb['ip'].saddr,
tdb['ip'].daddr,
longint_from_bytes(tdb['ether'].ether_shost,byteorder='big',signed=False),
longint_from_bytes(tdb['ether'].ether_dhost,byteorder='big',signed=False),
tdb['vlan'][0].vlanid if tdb['vlan'] is not None else 0,
FsID)
              if keyid not in self.key2NFSFlowMetrics:
                self.key2NFSFlowMetrics[keyid]=copy.deepcopy(container2metricdb['containers']['NFSFlowMetrics'])
              if proc==0:
                metricname='OtherProc'
              else:
                procname=NFS3PROC_num_inv[proc]
                metricname=proc2metric[procname]
                # metric
              if metricname=='OtherProc':
                self.key2NFSFlowMetrics[keyid]['OtherProcCurPendProcedures']+=1
                self.key2NFSFlowMetrics[keyid]['OtherProcMaxPendProcedures']+=1
                self.key2NFSFlowMetrics[keyid]['OtherProcMinPendProcedures']+=1
              else:
                self.key2NFSFlowMetrics[keyid]['%sCurPendProcedures'%metricname]+=1
                self.key2NFSFlowMetrics[keyid]['%sMaxPendProcedures'%metricname]+=1
                self.key2NFSFlowMetrics[keyid]['%sMinPendProcedures'%metricname]+=1
              # special metric
              self.key2NFSFlowMetrics[keyid]['CurPendProcedures']+=1
              self.key2NFSFlowMetrics[keyid]['MaxPendProcedures']+=1
              self.key2NFSFlowMetrics[keyid]['MinPendProcedures']+=1
              self.key2NFSFlowMetrics[keyid]['SRTMax']=max(self.key2NFSFlowMetrics[keyid]['SRTMax'],resp_time)
              self.key2NFSFlowMetrics[keyid]['SRTMin']=min(self.key2NFSFlowMetrics[keyid]['SRTMin'],resp_time)
              self.key2NFSFlowMetrics[keyid]['SRTTotal']+=resp_time
          elif mtype==msg_type_num['RPC2_MSG_TYPE_REPLY']: # reply
            vers= self.pcapobj.pcapdb[mdb['call msgno'][0]-1]['msg'][mdb['call msgno'][1]-1]['rpc'][1].vers
            rpc_version= self.pcapobj.pcapdb[mdb['call msgno'][0]-1]['msg'][mdb['call msgno'][1]-1]['rpc'][1].rpc_version
            proc= self.pcapobj.pcapdb[mdb['call msgno'][0]-1]['msg'][mdb['call msgno'][1]-1]['rpc'][1].proc
            prog= self.pcapobj.pcapdb[mdb['call msgno'][0]-1]['msg'][mdb['call msgno'][1]-1]['rpc'][1].prog
            if prog==program_list_num['RPC2_PROG_NFS3'] and rpc_version==2 and vers==3 and proc in NFS3PROC_num_inv.keys():
              file_handle=self.find_file_handle(self.pcapobj.pcapdb[mdb['call msgno'][0]-1]['msg'][mdb['call msgno'][1]-1]['nfs'])
              FsID=extract_fsid_from_file_handle(file_handle,endian=self.endian,fsindex=self.fsindex,debug=False)
              keyid=(tdb['ip'].daddr,
tdb['ip'].saddr,
longint_from_bytes(tdb['ether'].ether_dhost,byteorder='big',signed=False),
longint_from_bytes(tdb['ether'].ether_shost,byteorder='big',signed=False),
tdb['vlan'][0].vlanid if tdb['vlan'] is not None else 0,
FsID)
              # find response time
              reply_ts=self.pcapobj.caltime(tdb['ts'].ts_sec , tdb['ts'].ts_usec)
              call_ts=self.pcapobj.caltime(self.pcapobj.pcapdb[mdb['call msgno'][0]-1]['ts'].ts_sec,self.pcapobj.pcapdb[mdb['call msgno'][0]-1]['ts'].ts_usec)
              resp_time=reply_ts-call_ts
              payload_sz= self.payload_size(mdb) + self.payload_size(self.pcapobj.pcapdb[mdb['call msgno'][0]-1]['msg'][mdb['call msgno'][1]-1])
              reply=mdb['rpc'][1].reply
              state=mdb['rpc'][-1].state
              if keyid not in self.key2NFSFlowMetrics:
                self.key2NFSFlowMetrics[keyid]=copy.deepcopy(container2metricdb['containers']['NFSFlowMetrics'])
              if proc==0:
                metricname='OtherProc'
              else:
                procname=NFS3PROC_num_inv[proc]
                metricname=proc2metric[procname]
                # metric
              # find payload size
              if metricname=='OtherProc':
                self.key2NFSFlowMetrics[keyid]['OtherProc']+=1
                self.key2NFSFlowMetrics[keyid]['OtherProcCurPendProcedures']-=1
                self.key2NFSFlowMetrics[keyid]['OtherProcMaxPendProcedures']-=1
                self.key2NFSFlowMetrics[keyid]['OtherProcMinPendProcedures']-=1
                self.key2NFSFlowMetrics[keyid]['OtherProcPayloadBytes']+=payload_sz
                self.key2NFSFlowMetrics[keyid]['OtherProcSRTMax']=max(self.key2NFSFlowMetrics[keyid]['OtherProcSRTMax'],resp_time)
                self.key2NFSFlowMetrics[keyid]['OtherProcSRTMin']=min(self.key2NFSFlowMetrics[keyid]['OtherProcSRTMin'],resp_time)
                self.key2NFSFlowMetrics[keyid]['OtherProcSRTTotal']+=resp_time
                if reply==reply_status_num['RPC2_REPLY_STATUS_MSG_ACCEPTED']:
                  if state == accepted_status_num['RPC2_ACCEPT_STATUS_SUCCESS']:
                    self.key2NFSFlowMetrics[keyid]['OtherProcSuccess']+=1
                  else:
                    self.key2NFSFlowMetrics[keyid]['OtherProcError']+=1
                else:
                  self.key2NFSFlowMetrics[keyid]['OtherProcError']+=1
              else:
                self.key2NFSFlowMetrics[keyid]['%s'%metricname]+=1
                self.key2NFSFlowMetrics[keyid]['%sCurPendProcedures'%metricname]-=1
                self.key2NFSFlowMetrics[keyid]['%sMaxPendProcedures'%metricname]-=1
                self.key2NFSFlowMetrics[keyid]['%sMinPendProcedures'%metricname]-=1
                self.key2NFSFlowMetrics[keyid]['%sPayloadBytes'%metricname]+=payload_sz
                self.key2NFSFlowMetrics[keyid]['%sSRTMax'%metricname]=max(self.key2NFSFlowMetrics[keyid]['%sSRTMax'%metricname],resp_time)
                self.key2NFSFlowMetrics[keyid]['%sSRTMin'%metricname]=mix(self.key2NFSFlowMetrics[keyid]['%sSRTMin'%metricname],resp_time)
                self.key2NFSFlowMetrics[keyid]['%sSRTTotal'%metricname]+=resp_time
                if reply==reply_status_num['RPC2_REPLY_STATUS_MSG_ACCEPTED']:
                  if state == accepted_status_num['RPC2_ACCEPT_STATUS_SUCCESS']:
                    self.key2NFSFlowMetrics[keyid]['%sSuccess'%metricname]+=1
                    # if not hasattr(mdb['nfs'][0], 'nfs3_status') or mdb['nfs'][0].nfs3_status == nfsstat3_num["NFS3_OK"]: fixme
                  else:
                    self.key2NFSFlowMetrics[keyid]['%sError'%metricname]+=1
                else:
                  self.key2NFSFlowMetrics[keyid]['%sError'%metricname]+=1
                # special metric
              self.key2NFSFlowMetrics[keyid]['CurPendProcedures']-=1
              self.key2NFSFlowMetrics[keyid]['MaxPendProcedures']-=1
              self.key2NFSFlowMetrics[keyid]['MinPendProcedures']-=1
              self.key2NFSFlowMetrics[keyid]['SRTMax']=max(self.key2NFSFlowMetrics[keyid]['SRTMax'],resp_time)
              self.key2NFSFlowMetrics[keyid]['SRTMin']=min(self.key2NFSFlowMetrics[keyid]['SRTMin'],resp_time)
              self.key2NFSFlowMetrics[keyid]['SRTTotal']+=resp_time
              if   metricname == 'ReadProc':
                if   payload_sz <= 512:
                  self.key2NFSFlowMetrics[keyid]['ReadPayloadBytesHistogramB0']+=1
                elif payload_sz <= 1024:
                  self.key2NFSFlowMetrics[keyid]['ReadPayloadBytesHistogramB1']+=1
                elif payload_sz <= 2048:
                  self.key2NFSFlowMetrics[keyid]['ReadPayloadBytesHistogramB2']+=1
                elif payload_sz <= 4096:
                  self.key2NFSFlowMetrics[keyid]['ReadPayloadBytesHistogramB3']+=1
                elif payload_sz <= 8192:
                  self.key2NFSFlowMetrics[keyid]['ReadPayloadBytesHistogramB4']+=1
                elif payload_sz <= 12288:
                  self.key2NFSFlowMetrics[keyid]['ReadPayloadBytesHistogramB5']+=1
                elif payload_sz <= 16384:
                  self.key2NFSFlowMetrics[keyid]['ReadPayloadBytesHistogramB6']+=1
                elif payload_sz <= 24576:
                  self.key2NFSFlowMetrics[keyid]['ReadPayloadBytesHistogramB7']+=1
                elif payload_sz <= 32768:
                  self.key2NFSFlowMetrics[keyid]['ReadPayloadBytesHistogramB8']+=1
                elif payload_sz <= 49152:
                  self.key2NFSFlowMetrics[keyid]['ReadPayloadBytesHistogramB9']+=1
                elif payload_sz <= 65536:
                  self.key2NFSFlowMetrics[keyid]['ReadPayloadBytesHistogramB10']+=1
                elif payload_sz <= 98304:
                  self.key2NFSFlowMetrics[keyid]['ReadPayloadBytesHistogramB11']+=1
                elif payload_sz <= 131072:
                  self.key2NFSFlowMetrics[keyid]['ReadPayloadBytesHistogramB12']+=1
                elif payload_sz <= 196608:
                  self.key2NFSFlowMetrics[keyid]['ReadPayloadBytesHistogramB13']+=1
                elif payload_sz <= 262144:
                  self.key2NFSFlowMetrics[keyid]['ReadPayloadBytesHistogramB14']+=1
                elif payload_sz <= 524288:
                  self.key2NFSFlowMetrics[keyid]['ReadPayloadBytesHistogramB15']+=1
                elif payload_sz <= 1048576:
                  self.key2NFSFlowMetrics[keyid]['ReadPayloadBytesHistogramB16']+=1
                else:
                  self.key2NFSFlowMetrics[keyid]['ReadPayloadBytesHistogramB17']+=1
              if   metricname == 'WriteProc':
                if   payload_sz <= 512:
                  self.key2NFSFlowMetrics[keyid]['WritePayloadBytesHistogramB0']+=1
                elif payload_sz <= 1024:
                  self.key2NFSFlowMetrics[keyid]['WritePayloadBytesHistogramB1']+=1
                elif payload_sz <= 2048:
                  self.key2NFSFlowMetrics[keyid]['WritePayloadBytesHistogramB2']+=1
                elif payload_sz <= 4096:
                  self.key2NFSFlowMetrics[keyid]['WritePayloadBytesHistogramB3']+=1
                elif payload_sz <= 8192:
                  self.key2NFSFlowMetrics[keyid]['WritePayloadBytesHistogramB4']+=1
                elif payload_sz <= 12288:
                  self.key2NFSFlowMetrics[keyid]['WritePayloadBytesHistogramB5']+=1
                elif payload_sz <= 16384:
                  self.key2NFSFlowMetrics[keyid]['WritePayloadBytesHistogramB6']+=1
                elif payload_sz <= 24576:
                  self.key2NFSFlowMetrics[keyid]['WritePayloadBytesHistogramB7']+=1
                elif payload_sz <= 32768:
                  self.key2NFSFlowMetrics[keyid]['WritePayloadBytesHistogramB8']+=1
                elif payload_sz <= 49152:
                  self.key2NFSFlowMetrics[keyid]['WritePayloadBytesHistogramB9']+=1
                elif payload_sz <= 65536:
                  self.key2NFSFlowMetrics[keyid]['WritePayloadBytesHistogramB10']+=1
                elif payload_sz <= 98304:
                  self.key2NFSFlowMetrics[keyid]['WritePayloadBytesHistogramB11']+=1
                elif payload_sz <= 131072:
                  self.key2NFSFlowMetrics[keyid]['WritePayloadBytesHistogramB12']+=1
                elif payload_sz <= 196608:
                  self.key2NFSFlowMetrics[keyid]['WritePayloadBytesHistogramB13']+=1
                elif payload_sz <= 262144:
                  self.key2NFSFlowMetrics[keyid]['WritePayloadBytesHistogramB14']+=1
                elif payload_sz <= 524288:
                  self.key2NFSFlowMetrics[keyid]['WritePayloadBytesHistogramB15']+=1
                elif payload_sz <= 1048576:
                  self.key2NFSFlowMetrics[keyid]['WritePayloadBytesHistogramB16']+=1
                else:
                  self.key2NFSFlowMetrics[keyid]['WritePayloadBytesHistogramB17']+=1
              if   metricname == 'ReadProc':
                if   resp_time <= 100:
                  self.key2NFSFlowMetrics[keyid]['ReadSRTHistogramB0']+=1
                elif resp_time <= 300:
                  self.key2NFSFlowMetrics[keyid]['ReadSRTHistogramB1']+=1
                elif resp_time <= 500:
                  self.key2NFSFlowMetrics[keyid]['ReadSRTHistogramB2']+=1
                elif resp_time <= 700:
                  self.key2NFSFlowMetrics[keyid]['ReadSRTHistogramB3']+=1
                elif resp_time <= 1000:
                  self.key2NFSFlowMetrics[keyid]['ReadSRTHistogramB4']+=1
                elif resp_time <= 2000:
                  self.key2NFSFlowMetrics[keyid]['ReadSRTHistogramB5']+=1
                elif resp_time <= 4000:
                  self.key2NFSFlowMetrics[keyid]['ReadSRTHistogramB6']+=1
                elif resp_time <= 6000:
                  self.key2NFSFlowMetrics[keyid]['ReadSRTHistogramB7']+=1
                elif resp_time <= 10000:
                  self.key2NFSFlowMetrics[keyid]['ReadSRTHistogramB8']+=1
                elif resp_time <= 20000:
                  self.key2NFSFlowMetrics[keyid]['ReadSRTHistogramB9']+=1
                elif resp_time <= 30000:
                  self.key2NFSFlowMetrics[keyid]['ReadSRTHistogramB10']+=1
                elif resp_time <= 50000:
                  self.key2NFSFlowMetrics[keyid]['ReadSRTHistogramB11']+=1
                elif resp_time <= 75000:
                  self.key2NFSFlowMetrics[keyid]['ReadSRTHistogramB12']+=1
                elif resp_time <= 100000:
                  self.key2NFSFlowMetrics[keyid]['ReadSRTHistogramB13']+=1
                elif resp_time <= 150000:
                  self.key2NFSFlowMetrics[keyid]['ReadSRTHistogramB14']+=1
                elif resp_time <= 250000:
                  self.key2NFSFlowMetrics[keyid]['ReadSRTHistogramB15']+=1
                elif resp_time <= 500000:
                  self.key2NFSFlowMetrics[keyid]['ReadSRTHistogramB16']+=1
                elif resp_time <= 1000000:
                  self.key2NFSFlowMetrics[keyid]['ReadSRTHistogramB17']+=1
                elif resp_time <= 4500000:
                  self.key2NFSFlowMetrics[keyid]['ReadSRTHistogramB18']+=1
                else:
                  self.key2NFSFlowMetrics[keyid]['ReadSRTHistogramB19']+=1
              if   metricname == 'WriteProc':
                if   resp_time <= 100:
                  self.key2NFSFlowMetrics[keyid]['WriteSRTHistogramB0']+=1
                elif resp_time <= 300:
                  self.key2NFSFlowMetrics[keyid]['WriteSRTHistogramB1']+=1
                elif resp_time <= 500:
                  self.key2NFSFlowMetrics[keyid]['WriteSRTHistogramB2']+=1
                elif resp_time <= 700:
                  self.key2NFSFlowMetrics[keyid]['WriteSRTHistogramB3']+=1
                elif resp_time <= 1000:
                  self.key2NFSFlowMetrics[keyid]['WriteSRTHistogramB4']+=1
                elif resp_time <= 2000:
                  self.key2NFSFlowMetrics[keyid]['WriteSRTHistogramB5']+=1
                elif resp_time <= 4000:
                  self.key2NFSFlowMetrics[keyid]['WriteSRTHistogramB6']+=1
                elif resp_time <= 6000:
                  self.key2NFSFlowMetrics[keyid]['WriteSRTHistogramB7']+=1
                elif resp_time <= 10000:
                  self.key2NFSFlowMetrics[keyid]['WriteSRTHistogramB8']+=1
                elif resp_time <= 20000:
                  self.key2NFSFlowMetrics[keyid]['WriteSRTHistogramB9']+=1
                elif resp_time <= 30000:
                  self.key2NFSFlowMetrics[keyid]['WriteSRTHistogramB10']+=1
                elif resp_time <= 50000:
                  self.key2NFSFlowMetrics[keyid]['WriteSRTHistogramB11']+=1
                elif resp_time <= 75000:
                  self.key2NFSFlowMetrics[keyid]['WriteSRTHistogramB12']+=1
                elif resp_time <= 100000:
                  self.key2NFSFlowMetrics[keyid]['WriteSRTHistogramB13']+=1
                elif resp_time <= 150000:
                  self.key2NFSFlowMetrics[keyid]['WriteSRTHistogramB14']+=1
                elif resp_time <= 250000:
                  self.key2NFSFlowMetrics[keyid]['WriteSRTHistogramB15']+=1
                elif resp_time <= 500000:
                  self.key2NFSFlowMetrics[keyid]['WriteSRTHistogramB16']+=1
                elif resp_time <= 1000000:
                  self.key2NFSFlowMetrics[keyid]['WriteSRTHistogramB17']+=1
                elif resp_time <= 4500000:
                  self.key2NFSFlowMetrics[keyid]['WriteSRTHistogramB18']+=1
                else:
                  self.key2NFSFlowMetrics[keyid]['WriteSRTHistogramB19']+=1
    #pprint(self.key2NFSFlowMetrics)
    # virtual metric calculation
    for keyid,rdb in self.key2NFSFlowMetrics.items():
       self.update_vm('NFSFlowMetrics',self.key2NFSFlowMetrics[keyid])
# ????????????????????????????
    if self.pcapobj.prog2port[program_list_num['RPC2_PROG_NFS3']]==0: return
    for tdb in self.pcapobj.pcapdb:
      if len(tdb['msg'])==0: continue
      if self.pcapobj.prog2port[program_list_num['RPC2_PROG_NFS3']] != 0 and \\
         (tdb['l4'].dest==self.pcapobj.prog2port[program_list_num['RPC2_PROG_NFS3']] or \\
         tdb['l4'].source==self.pcapobj.prog2port[program_list_num['RPC2_PROG_NFS3']]):
        for mdb in tdb['msg']:
          mtype= mdb['rpc'][0].mtype
          if mtype==msg_type_num['RPC2_MSG_TYPE_CALL']: # call
            vers= mdb['rpc'][1].vers
            rpc_version= mdb['rpc'][1].rpc_version
            proc= mdb['rpc'][1].proc
            prog= mdb['rpc'][1].prog
            if prog==program_list_num['RPC2_PROG_NFS3'] and rpc_version==2 and vers==3 and proc in NFS3PROC_num_inv.keys():''' + self.keyid_gen('NFSFlowMetrics',tab=' '*14,call=True,reply=False,debug=debug) + '''
              if keyid not in self.key2NFSFlowMetrics:
                self.key2NFSFlowMetrics[keyid]=copy.deepcopy(container2metricdb['containers']['NFSFlowMetrics'])
              if proc==0:
                metricname='OtherProc'
              else:
                procname=NFS3PROC_num_inv[proc]
                metricname=proc2metric[procname]'''+self.key2metric_gen('NFSFlowMetrics',tab=' '*14,call=True,reply=False,debug=debug)+ '''
              if   metricname == 'WriteProc':
                pass
              elif metricname == 'ReadProc':
                pass
              elif metricname == 'OtherProc':
                pass
              else:
                pass
          elif mtype==msg_type_num['RPC2_MSG_TYPE_REPLY']: # reply
            vers= self.pcapobj.pcapdb[mdb['call msgno'][0]-1]['msg'][mdb['call msgno'][1]-1]['rpc'][1].vers
            rpc_version= self.pcapobj.pcapdb[mdb['call msgno'][0]-1]['msg'][mdb['call msgno'][1]-1]['rpc'][1].rpc_version
            proc= self.pcapobj.pcapdb[mdb['call msgno'][0]-1]['msg'][mdb['call msgno'][1]-1]['rpc'][1].proc
            prog= self.pcapobj.pcapdb[mdb['call msgno'][0]-1]['msg'][mdb['call msgno'][1]-1]['rpc'][1].prog
            if prog==program_list_num['RPC2_PROG_NFS3'] and rpc_version==2 and vers==3 and proc in NFS3PROC_num_inv.keys():''' + self.keyid_gen('NFSFlowMetrics',tab=' '*14,call=False,reply=True,debug=debug) + '''
              # find response time
              reply_ts=self.pcapobj.caltime(tdb['ts'].ts_sec , tdb['ts'].ts_usec)
              call_ts=self.pcapobj.caltime(self.pcapobj.pcapdb[mdb['call msgno'][0]-1]['ts'].ts_sec,self.pcapobj.pcapdb[mdb['call msgno'][0]-1]['ts'].ts_usec)
              resp_time=reply_ts-call_ts
              if keyid not in self.key2NFSFlowMetrics:
                self.key2NFSFlowMetrics[keyid]=copy.deepcopy(container2metricdb['containers']['NFSFlowMetrics'])
              if proc==0:
                metricname='OtherProc'
              else:
                procname=NFS3PROC_num_inv[proc]
                metricname=proc2metric[procname]'''+self.key2metric_gen('NFSFlowMetrics',tab=' '*14,call=True,reply=False,debug=debug)+ '''
              if   metricname == 'WriteProc':
                pass
              elif metricname == 'ReadProc':
                pass
              elif metricname == 'OtherProc':
                pass
              else:
                pass
              #self.key2NFSFlowMetrics[keyid]['SRTTotal]+=[resp_time]
              if proc == NFS3PROC_num["READ"]:
                # Not checking if it has attribute, because if msg meets all of the above
                # conditions and still doesn't have a count3 field, an exception really should be thrown
                self.key2NFSFlowMetrics[keyid][proc]['count3']+=mdb['nfs'][4].count
              reply=mdb['rpc'][1].reply
              if reply==reply_status_num['RPC2_REPLY_STATUS_MSG_ACCEPTED']: 
                self.key2NFSFlowMetrics[keyid][proc]['accepted']+=1
                state=mdb['rpc'][-1].state
                if state == accepted_status_num['RPC2_ACCEPT_STATUS_SUCCESS']:
                  if not hasattr(mdb['nfs'][0], 'nfs3_status') or mdb['nfs'][0].nfs3_status == nfsstat3_num["NFS3_OK"]:
                    self.key2NFSFlowMetrics[keyid][proc]['success']+=1
                    self.key2NFSFlowMetrics[keyid][proc]['nfs_ok']+=1
                  else:
                    self.key2NFSFlowMetrics[keyid][proc]['denied']+=1    
              elif reply==msg_type_num['RPC2_REPLY_STATUS_MSG_DENIED']: 
                self.key2NFSFlowMetrics[keyid][proc]['denied']+=1
    #pprint(self.key2NFSFlowMetrics)
    # virtual metric calculation
    for keyid,rdb in self.key2NFSFlowMetrics.items():
       self.update_vm('NFSFlowMetrics',self.key2NFSFlowMetrics[keyid])
# ????????????????????????????????
'''
  def _NFSHotFileAttr(self,debug=False):
    return '''
  def extract_NFSHotFileAttr(self,debug=False):
    """
    """
    if self.pcapobj.prog2port[program_list_num['RPC2_PROG_NFS3']]==0: return
    for tdb in self.pcapobj.pcapdb:
      if len(tdb['msg'])==0: continue
      if self.pcapobj.prog2port[program_list_num['RPC2_PROG_NFS3']] != 0 and \\
         (tdb['l4'].dest==self.pcapobj.prog2port[program_list_num['RPC2_PROG_NFS3']] or \\
         tdb['l4'].source==self.pcapobj.prog2port[program_list_num['RPC2_PROG_NFS3']]):
        for mdb in tdb['msg']:
          mtype= mdb['rpc'][0].mtype
          if mtype==msg_type_num['RPC2_MSG_TYPE_CALL']: # call
            vers= mdb['rpc'][1].vers
            rpc_version= mdb['rpc'][1].rpc_version
            proc= mdb['rpc'][1].proc
            prog= mdb['rpc'][1].prog
            if prog==program_list_num['RPC2_PROG_NFS3'] and rpc_version==2 and vers==3 and proc in NFS3PROC_num_inv.keys():''' + self.keyid_gen('NFSHotFileAttr',tab=' '*14,call=True,reply=False,debug=debug) + '''
              if keyid not in self.key2NFSHotFileAttr:
                self.key2NFSHotFileAttr[keyid]=copy.deepcopy(container2metricdb['containers']['NFSHotFileAttr'])
              if proc==0:
                metricname='OtherProc'
              else:
                procname=NFS3PROC_num_inv[proc]
                metricname=proc2metric[procname]'''+self.key2metric_gen('NFSHotFileAttr',tab=' '*14,call=True,reply=False,debug=debug)+ '''
              if   metricname == 'WriteProc':
                pass
              elif metricname == 'ReadProc':
                pass
              elif metricname == 'OtherProc':
                pass
              else:
                pass
          elif mtype==msg_type_num['RPC2_MSG_TYPE_REPLY']: # reply
            vers= self.pcapobj.pcapdb[mdb['call msgno'][0]-1]['msg'][mdb['call msgno'][1]-1]['rpc'][1].vers
            rpc_version= self.pcapobj.pcapdb[mdb['call msgno'][0]-1]['msg'][mdb['call msgno'][1]-1]['rpc'][1].rpc_version
            proc= self.pcapobj.pcapdb[mdb['call msgno'][0]-1]['msg'][mdb['call msgno'][1]-1]['rpc'][1].proc
            prog= self.pcapobj.pcapdb[mdb['call msgno'][0]-1]['msg'][mdb['call msgno'][1]-1]['rpc'][1].prog
            if prog==program_list_num['RPC2_PROG_NFS3'] and rpc_version==2 and vers==3 and proc in NFS3PROC_num_inv.keys():''' + self.keyid_gen('NFSHotFileAttr',tab=' '*14,call=False,reply=True,debug=debug) + '''
              # find response time
              reply_ts=self.pcapobj.caltime(tdb['ts'].ts_sec , tdb['ts'].ts_usec)
              call_ts=self.pcapobj.caltime(self.pcapobj.pcapdb[mdb['call msgno'][0]-1]['ts'].ts_sec,self.pcapobj.pcapdb[mdb['call msgno'][0]-1]['ts'].ts_usec)
              resp_time=reply_ts-call_ts
              if keyid not in self.key2NFSHotFileAttr:
                self.key2NFSHotFileAttr[keyid]=copy.deepcopy(container2metricdb['containers']['NFSHotFileAttr'])
              if proc==0:
                metricname='OtherProc'
              else:
                procname=NFS3PROC_num_inv[proc]
                metricname=proc2metric[procname]'''+self.key2metric_gen('NFSHotFileAttr',tab=' '*14,call=True,reply=False,debug=debug)+ '''
              if   metricname == 'WriteProc':
                pass
              elif metricname == 'ReadProc':
                pass
              elif metricname == 'OtherProc':
                pass
              else:
                pass
              #self.key2NFSHotFileAttr[keyid]['SRTTotal]+=[resp_time]
              if proc == NFS3PROC_num["READ"]:
                # Not checking if it has attribute, because if msg meets all of the above
                # conditions and still doesn't have a count3 field, an exception really should be thrown
                self.key2NFSHotFileAttr[keyid][proc]['count3']+=mdb['nfs'][4].count
              reply=mdb['rpc'][1].reply
              if reply==reply_status_num['RPC2_REPLY_STATUS_MSG_ACCEPTED']: 
                self.key2NFSHotFileAttr[keyid][proc]['accepted']+=1
                state=mdb['rpc'][-1].state
                if state == accepted_status_num['RPC2_ACCEPT_STATUS_SUCCESS']:
                  if not hasattr(mdb['nfs'][0], 'nfs3_status') or mdb['nfs'][0].nfs3_status == nfsstat3_num["NFS3_OK"]:
                    self.key2NFSHotFileAttr[keyid][proc]['success']+=1
                    self.key2NFSHotFileAttr[keyid][proc]['nfs_ok']+=1
                  else:
                    self.key2NFSHotFileAttr[keyid][proc]['denied']+=1    
              elif reply==msg_type_num['RPC2_REPLY_STATUS_MSG_DENIED']: 
                self.key2NFSHotFileAttr[keyid][proc]['denied']+=1
    #pprint(self.key2NFSHotFileAttr)
    # virtual metric calculation
    for keyid,rdb in self.key2NFSHotFileAttr.items():
       self.update_vm('NFSHotFileAttr',self.key2NFSHotFileAttr[keyid])
'''
  def _NFSHotFileMetrics(self,debug=False):
    return '''
  def extract_NFSHotFileMetrics(self,debug=False):
    """
    """
    if self.pcapobj.prog2port[program_list_num['RPC2_PROG_NFS3']]==0: return
    for tdb in self.pcapobj.pcapdb:
      if len(tdb['msg'])==0: continue
      if self.pcapobj.prog2port[program_list_num['RPC2_PROG_NFS3']] != 0 and \\
         (tdb['l4'].dest==self.pcapobj.prog2port[program_list_num['RPC2_PROG_NFS3']] or \\
         tdb['l4'].source==self.pcapobj.prog2port[program_list_num['RPC2_PROG_NFS3']]):
        for mdb in tdb['msg']:
          mtype= mdb['rpc'][0].mtype
          if mtype==msg_type_num['RPC2_MSG_TYPE_CALL']: # call
            vers= mdb['rpc'][1].vers
            rpc_version= mdb['rpc'][1].rpc_version
            proc= mdb['rpc'][1].proc
            prog= mdb['rpc'][1].prog
            if prog==program_list_num['RPC2_PROG_NFS3'] and rpc_version==2 and vers==3 and proc in NFS3PROC_num_inv.keys():''' + self.keyid_gen('NFSHotFileMetrics',tab=' '*14,call=True,reply=False,debug=debug) + '''
              if keyid not in self.key2NFSHotFileMetrics:
                self.key2NFSHotFileMetrics[keyid]=copy.deepcopy(container2metricdb['containers']['NFSHotFileMetrics'])
              if proc==0:
                metricname='OtherProc'
              else:
                procname=NFS3PROC_num_inv[proc]
                metricname=proc2metric[procname]'''+self.key2metric_gen('NFSHotFileMetrics',tab=' '*14,call=True,reply=False,debug=debug)+ '''
              if   metricname == 'WriteProc':
                pass
              elif metricname == 'ReadProc':
                pass
              elif metricname == 'OtherProc':
                pass
              else:
                pass
          elif mtype==msg_type_num['RPC2_MSG_TYPE_REPLY']: # reply
            vers= self.pcapobj.pcapdb[mdb['call msgno'][0]-1]['msg'][mdb['call msgno'][1]-1]['rpc'][1].vers
            rpc_version= self.pcapobj.pcapdb[mdb['call msgno'][0]-1]['msg'][mdb['call msgno'][1]-1]['rpc'][1].rpc_version
            proc= self.pcapobj.pcapdb[mdb['call msgno'][0]-1]['msg'][mdb['call msgno'][1]-1]['rpc'][1].proc
            prog= self.pcapobj.pcapdb[mdb['call msgno'][0]-1]['msg'][mdb['call msgno'][1]-1]['rpc'][1].prog
            if prog==program_list_num['RPC2_PROG_NFS3'] and rpc_version==2 and vers==3 and proc in NFS3PROC_num_inv.keys():''' + self.keyid_gen('NFSHotFileMetrics',tab=' '*14,call=False,reply=True,debug=debug) + '''
              # find response time
              reply_ts=self.pcapobj.caltime(tdb['ts'].ts_sec , tdb['ts'].ts_usec)
              call_ts=self.pcapobj.caltime(self.pcapobj.pcapdb[mdb['call msgno'][0]-1]['ts'].ts_sec,self.pcapobj.pcapdb[mdb['call msgno'][0]-1]['ts'].ts_usec)
              resp_time=reply_ts-call_ts
              if keyid not in self.key2NFSHotFileMetrics:
                self.key2NFSHotFileMetrics[keyid]=copy.deepcopy(container2metricdb['containers']['NFSHotFileMetrics'])
              if proc==0:
                metricname='OtherProc'
              else:
                procname=NFS3PROC_num_inv[proc]
                metricname=proc2metric[procname]'''+self.key2metric_gen('NFSHotFileMetrics',tab=' '*14,call=True,reply=False,debug=debug)+ '''
              if   metricname == 'WriteProc':
                pass
              elif metricname == 'ReadProc':
                pass
              elif metricname == 'OtherProc':
                pass
              else:
                pass
              #self.key2NFSHotFileMetrics[keyid]['SRTTotal]+=[resp_time]
              if proc == NFS3PROC_num["READ"]:
                # Not checking if it has attribute, because if msg meets all of the above
                # conditions and still doesn't have a count3 field, an exception really should be thrown
                self.key2NFSHotFileMetrics[keyid][proc]['count3']+=mdb['nfs'][4].count
              reply=mdb['rpc'][1].reply
              if reply==reply_status_num['RPC2_REPLY_STATUS_MSG_ACCEPTED']: 
                self.key2NFSHotFileMetrics[keyid][proc]['accepted']+=1
                state=mdb['rpc'][-1].state
                if state == accepted_status_num['RPC2_ACCEPT_STATUS_SUCCESS']:
                  if not hasattr(mdb['nfs'][0], 'nfs3_status') or mdb['nfs'][0].nfs3_status == nfsstat3_num["NFS3_OK"]:
                    self.key2NFSHotFileMetrics[keyid][proc]['success']+=1
                    self.key2NFSHotFileMetrics[keyid][proc]['nfs_ok']+=1
                  else:
                    self.key2NFSHotFileMetrics[keyid][proc]['denied']+=1    
              elif reply==msg_type_num['RPC2_REPLY_STATUS_MSG_DENIED']: 
                self.key2NFSHotFileMetrics[keyid][proc]['denied']+=1
    #pprint(self.key2NFSHotFileMetrics)
    # virtual metric calculation
    for keyid,rdb in self.key2NFSHotFileMetrics.items():
       self.update_vm('NFSHotFileMetrics',self.key2NFSHotFileMetrics[keyid])
'''
  def _NLMFlowMetrics(self,debug=False):
    return '''
  def extract_NLMFlowMetrics(self,debug=False):
    """
    """
    if self.pcapobj.prog2port[program_list_num['RPC2_PROG_NLM']]==0: return
    for tdb in self.pcapobj.pcapdb:
      if len(tdb['msg'])==0: continue
      if self.pcapobj.prog2port[program_list_num['RPC2_PROG_NLM']] != 0 and \
         (tdb['l4'].dest==self.pcapobj.prog2port[program_list_num['RPC2_PROG_NLM']] or \
         tdb['l4'].source==self.pcapobj.prog2port[program_list_num['RPC2_PROG_NLM']]):
        for mdb in tdb['msg']:
          mtype= mdb['rpc'][0].mtype
          if mtype==msg_type_num['RPC2_MSG_TYPE_CALL']: # call
            vers= mdb['rpc'][1].vers
            rpc_version= mdb['rpc'][1].rpc_version
            proc= mdb['rpc'][1].proc
            prog= mdb['rpc'][1].prog
            if prog==program_list_num['RPC2_PROG_NLM'] and rpc_version==2 and vers==4 and proc in NLMPROC4_num_inv.keys():
              file_handle=self.find_file_handle(mdb['nfs'])
              FsID=extract_fsid_from_file_handle(file_handle,endian=self.endian,fsindex=self.fsindex,debug=False)
              keyid=(tdb['ip'].saddr,
tdb['ip'].daddr,
longint_from_bytes(tdb['ether'].ether_shost,byteorder='big',signed=False),
longint_from_bytes(tdb['ether'].ether_dhost,byteorder='big',signed=False),
tdb['vlan'][0].vlanid if tdb['vlan'] is not None else 0,
FsID)
              if keyid not in self.key2NLMFlowMetrics:
                self.key2NLMFlowMetrics[keyid]=copy.deepcopy(container2metricdb['containers']['NLMFlowMetrics'])
              if proc==0:
                #metricname='OtherProc'
                continue
              else:
                procname=NLMPROC4_num_inv[proc]
                metricname=proc2metric[procname]
                # metric
                if  (NLMPROC4_num[proc]=='NLMPROC4_TEST_MSG' or
                     NLMPROC4_num[proc]=='NLMPROC4_LOCK_MSG' or
                     NLMPROC4_num[proc]=='NLMPROC4_CANCEL_MSG' or
                     NLMPROC4_num[proc]=='NLMPROC4_UNLOCK_MSG' or
                     NLMPROC4_num[proc]=='NLMPROC4_GRANTED_MSG' or
                     NLMPROC4_num[proc]=='NLMPROC4_FREE_ALL'):
                  self.key2NLMFlowMetrics[keyid]['%s'%metricname]+=1
                  #self.key2NLMFlowMetrics[keyid]['%sError'%metricname]+=1
                  self.key2NLMFlowMetrics[keyid]['%sSuccess'%metricname]+=1
                elif (NLMPROC4_num[proc]=='NLMPROC4_TEST_RES' or
                      NLMPROC4_num[proc]=='NLMPROC4_LOCK_RES' or
                      NLMPROC4_num[proc]=='NLMPROC4_CANCEL_RES' or
                      NLMPROC4_num[proc]=='NLMPROC4_UNLOCK_RES' or
                      NLMPROC4_num[proc]=='NLMPROC4_GRANTED_RES'):
                  nlm_statobj=db['nlm'][1]
                  nlm_status=nlm_statobj.state
                  self.key2NLMFlowMetrics[keyid]['%s'%metricname]+=1
                  if nlm_status==NLM4_STATS_num['NLM4_GRANTED']:
                    self.key2NLMFlowMetrics[keyid]['%sSuccess'%metricname]+=1
                  else:
                    self.key2NLMFlowMetrics[keyid]['%sError'%metricname]+=1
          elif mtype==msg_type_num['RPC2_MSG_TYPE_REPLY']: # reply
            vers= self.pcapobj.pcapdb[mdb['call msgno'][0]-1]['msg'][mdb['call msgno'][1]-1]['rpc'][1].vers
            rpc_version= self.pcapobj.pcapdb[mdb['call msgno'][0]-1]['msg'][mdb['call msgno'][1]-1]['rpc'][1].rpc_version
            proc= self.pcapobj.pcapdb[mdb['call msgno'][0]-1]['msg'][mdb['call msgno'][1]-1]['rpc'][1].proc
            prog= self.pcapobj.pcapdb[mdb['call msgno'][0]-1]['msg'][mdb['call msgno'][1]-1]['rpc'][1].prog
            if prog==program_list_num['RPC2_PROG_NLM'] and rpc_version==2 and vers==4 and proc in NLMPROC4_num_inv.keys():
              file_handle=self.find_file_handle(self.pcapobj.pcapdb[mdb['call msgno'][0]-1]['msg'][mdb['call msgno'][1]-1]['nfs'])
              FsID=extract_fsid_from_file_handle(file_handle,endian=self.endian,fsindex=self.fsindex,debug=False)
              keyid=(tdb['ip'].daddr,
tdb['ip'].saddr,
longint_from_bytes(tdb['ether'].ether_dhost,byteorder='big',signed=False),
longint_from_bytes(tdb['ether'].ether_shost,byteorder='big',signed=False),
tdb['vlan'][0].vlanid if tdb['vlan'] is not None else 0,
FsID)
              # find response time
              reply_ts=self.pcapobj.caltime(tdb['ts'].ts_sec , tdb['ts'].ts_usec)
              call_ts=self.pcapobj.caltime(self.pcapobj.pcapdb[mdb['call msgno'][0]-1]['ts'].ts_sec,self.pcapobj.pcapdb[mdb['call msgno'][0]-1]['ts'].ts_usec)
              resp_time=reply_ts-call_ts
              if keyid not in self.key2NLMFlowMetrics:
                self.key2NLMFlowMetrics[keyid]=copy.deepcopy(container2metricdb['containers']['NLMFlowMetrics'])
              if proc==0:
                #metricname='OtherProc'
                pass
              else:
                procname=NLMPROC4_num_inv[proc]
                metricname=proc2metric[procname]
                # metric
              reply=mdb['rpc'][1].reply
              self.key2NLMFlowMetrics[keyid]['%s'%metricname]+=1
              if reply==reply_status_num['RPC2_REPLY_STATUS_MSG_ACCEPTED']:
                self.key2NLMFlowMetrics[keyid]['%sError'%metricname]+=1
                self.key2NLMFlowMetrics[keyid]['%sSuccess'%metricname]+=1
                if  (NLMPROC4_num[proc]=='NLMPROC4_TEST':
                     NLMPROC4_num[proc]=='NLMPROC4_LOCK' or
                     NLMPROC4_num[proc]=='NLMPROC4_CANCEL' or
                     NLMPROC4_num[proc]=='NLMPROC4_UNLOCK' or
                     NLMPROC4_num[proc]=='NLMPROC4_GRANTED' or
                     NLMPROC4_num[proc]=='NLMPROC4_SHARE' or
                     NLMPROC4_num[proc]=='NLMPROC4_UNSHARE' or
                     NLMPROC4_num[proc]=='NLMPROC4_NM_LOCK'):
                  nlm_statobj=db['nlm'][1]
                  nlm_status=nlm_statobj.state
                  if nlm_status==NLM4_STATS_num['NLM4_GRANTED']:
                    self.key2NLMFlowMetrics[keyid]['%sSuccess'%metricname]+=1
                  else:  
                    self.key2NLMFlowMetrics[keyid]['%sError'%metricname]+=1
              elif reply==msg_type_num['RPC2_REPLY_STATUS_MSG_DENIED']:
                self.key2NLMFlowMetrics[keyid]['%sError'%metricname]+=1

'''
  def _RPCFlowMetrics(self,debug=False):
    return '''
  def extract_RPCFlowMetrics(self,debug=False):
    """
    """
    # find used port in the pcap file
    prog2port=dict((k,self.prog2port[k]) for k in filter(lambda x: self.prog2port[x]!=0,self.pcapobj.prog2port.keys()))
    for tdb in self.pcapobj.pcapdb:
      if len(tdb['msg'])==0: continue
      if tdb['l4'].dest in prog2port.values() or tdb['l4'].source in prog2port.values() :
        for mdb in tdb['msg']:
          mtype= mdb['rpc'][0].mtype
          if mtype==msg_type_num['RPC2_MSG_TYPE_CALL']: # call
            vers= mdb['rpc'][1].vers
            rpc_version= mdb['rpc'][1].rpc_version
            proc= mdb['rpc'][1].proc
            prog= mdb['rpc'][1].prog
            if prog==program_list_num['RPC2_PROG_PMAP2'] and vers==2 and (proc in PMAPPROC_num.keys()):
              progname='Pmap2'
              file_handle=self.find_file_handle(mdb['pmap')
            elif prog==program_list_num['RPC2_PROG_PMAP2'] and vers==3 and (proc in RPCBPROC_num.keys()):
              progname='Pmap2'
              file_handle=self.find_file_handle(mdb['rpcb')
            elif prog==program_list_num['RPC2_PROG_PMAP2'] and vers==4 and (proc in RPCBPROC_num.keys()):
              progname='Pmap2'
              file_handle=self.find_file_handle(mdb['rpcb')
            elif prog==program_list_num['RPC2_PROG_NFS3'] and vers==3 and (proc in NFS3PROC_num.keys()):
              progname='Nfs3'
              file_handle=self.find_file_handle(mdb['nfs')
            elif prog==program_list_num['RPC2_PROG_MNT3'] and vers==3 and (proc in MOUNTPROC3_num.keys()):
              progname='Mnt3'
              file_handle=self.find_file_handle(mdb['mnt')
            elif prog==program_list_num['RPC2_PROG_NLM'] and vers==4 and (proc in NLMPROC4_num.keys()):
              progname='Nlm'
              file_handle=self.find_file_handle(mdb['nlm')
            elif prog==program_list_num['RPC2_PROG_NSM'] and vers==1 and (proc in SM_num.keys()):
              progname='Nsm'
              file_handle=self.find_file_handle(mdb['nsm')
            elif prog==program_list_num['RPC2_PROG_NFSACL'] and vers==3 and (proc in NFSACLPROC3_num.keys()):
              progname='NfsAcl'
              file_handle=self.find_file_handle(mdb['nfsacl')
            else:
              progname='BadRpc'
              file_handle='00'*28

            FsID=extract_fsid_from_file_handle(file_handle,endian=self.endian,fsindex=self.fsindex,debug=False)
            keyid=(tdb['ip'].saddr,
tdb['ip'].daddr,
longint_from_bytes(tdb['ether'].ether_shost,byteorder='big',signed=False),
longint_from_bytes(tdb['ether'].ether_dhost,byteorder='big',signed=False),
tdb['vlan'][0].vlanid if tdb['vlan'] is not None else 0,
FsID)
            payload_sz= self.payload_size(mdb)
            if keyid not in self.key2RPCFlowMetrics:
              self.key2RPCFlowMetrics[keyid]=copy.deepcopy(container2metricdb['containers']['RPCFlowMetrics'])
            metricname=proc2metric[procname]

            # metric
            if   metricname == 'BadRpc':
              self.key2RPCFlowMetrics[keyid]['BadRpc']+=1
            else:
              self.key2RPCFlowMetrics[keyid]['%s'%metricname]+=1
              self.key2RPCFlowMetrics[keyid]['%sPayloadBytes'%metricname]+=payload_sz
          elif mtype==msg_type_num['RPC2_MSG_TYPE_REPLY']: # reply
            if mdb['call msgno']==None:
              self.key2RPCFlowMetrics[keyid]['UnexpectedReplies']+=1
              continue
            vers= self.pcapobj.pcapdb[mdb['call msgno'][0]-1]['msg'][mdb['call msgno'][1]-1]['rpc'][1].vers
            rpc_version= self.pcapobj.pcapdb[mdb['call msgno'][0]-1]['msg'][mdb['call msgno'][1]-1]['rpc'][1].rpc_version
            proc= self.pcapobj.pcapdb[mdb['call msgno'][0]-1]['msg'][mdb['call msgno'][1]-1]['rpc'][1].proc
            prog= self.pcapobj.pcapdb[mdb['call msgno'][0]-1]['msg'][mdb['call msgno'][1]-1]['rpc'][1].prog
            if prog==program_list_num['RPC2_PROG_PMAP2'] and vers==2 and (proc in PMAPPROC_num.keys()):
              progname='Pmap2'
              file_handle=self.find_file_handle(mdb['pmap')
            elif prog==program_list_num['RPC2_PROG_PMAP2'] and vers==3 and (proc in RPCBPROC_num.keys()):
              progname='Pmap2'
              file_handle=self.find_file_handle(mdb['rpcb')
            elif prog==program_list_num['RPC2_PROG_PMAP2'] and vers==4 and (proc in RPCBPROC_num.keys()):
              progname='Pmap2'
              file_handle=self.find_file_handle(mdb['rpcb')
            elif prog==program_list_num['RPC2_PROG_NFS3'] and vers==3 and (proc in NFS3PROC_num.keys()):
              progname='Nfs3'
              file_handle=self.find_file_handle(mdb['nfs')
            elif prog==program_list_num['RPC2_PROG_MNT3'] and vers==3 and (proc in MOUNTPROC3_num.keys()):
              progname='Mnt3'
              file_handle=self.find_file_handle(mdb['mnt')
            elif prog==program_list_num['RPC2_PROG_NLM'] and vers==4 and (proc in NLMPROC4_num.keys()):
              progname='Nlm'
              file_handle=self.find_file_handle(mdb['nlm')
            elif prog==program_list_num['RPC2_PROG_NSM'] and vers==1 and (proc in SM_num.keys()):
              progname='Nsm'
              file_handle=self.find_file_handle(mdb['nsm')
            elif prog==program_list_num['RPC2_PROG_NFSACL'] and vers==3 and (proc in NFSACLPROC3_num.keys()):
              progname='NfsAcl'
              file_handle=self.find_file_handle(mdb['nfsacl')
            else:
              progname='BadRpc'
              file_handle='00'*28

            FsID=extract_fsid_from_file_handle(file_handle,endian=self.endian,fsindex=self.fsindex,debug=False)
            keyid=(tdb['ip'].saddr,
tdb['ip'].daddr,
longint_from_bytes(tdb['ether'].ether_shost,byteorder='big',signed=False),
longint_from_bytes(tdb['ether'].ether_dhost,byteorder='big',signed=False),
tdb['vlan'][0].vlanid if tdb['vlan'] is not None else 0,
FsID)
            if keyid not in self.key2RPCFlowMetrics:
              self.key2RPCFlowMetrics[keyid]=copy.deepcopy(container2metricdb['containers']['RPCFlowMetrics'])
            metricname=proc2metric[procname]

            #payload_sz= self.payload_size(mdb) + self.payload_size(self.pcapobj.pcapdb[mdb['call msgno'][0]-1]['msg'][mdb['call msgno'][1]-1])
            payload_sz= self.payload_size(mdb)
            # metric
            if   metricname == 'BadRpc':
              #self.key2RPCFlowMetrics[keyid]['BadRpc']+=1
              continue
            else:
              #self.key2RPCFlowMetrics[keyid]['%s'%metricname]+=1
              reply=mdb['rpc'][1].reply
              payload_sz= self.payload_size(mdb) + self.payload_size(self.pcapdb[mdb['call msgno'][0]-1]['msg'][mdb['call msgno'][1]-1])
              self.key2RPCFlowMetrics[keyid]['%sPayloadBytes'%metricname]+=payload_sz
              # special metric
              if reply==reply_status_num['RPC2_REPLY_STATUS_MSG_ACCEPTED']:
                state=mdb['rpc'][-1].state
                if state == accepted_status_num['RPC2_ACCEPT_STATUS_SUCCESS']:
                  if prog == program_list_num["RPC2_PROG_NFS3"]:
                    #if not hasattr(mdb['nfs'][0], 'nfs3_status') or mdb['nfs'][0].nfs3_status == nfsstat3_num["NFS3_OK"]:
                    #  self.key2RPCFlowMetrics[keyid]['%sSuccess'%metricname]+=1
                    #else:
                    #  self.key2RPCFlowMetrics[keyid]['%sError'%metricname]+=1
                    self.key2RPCFlowMetrics[keyid]['%sSuccess'%metricname]+=1
                  else:
                    self.key2RPCFlowMetrics[keyid]['%sSuccess'%metricname]+=1
              elif reply==msg_type_num['RPC2_REPLY_STATUS_MSG_DENIED']:
                self.key2RPCFlowMetrics[keyid]['DeniesAndNonSuccess']+=1
    #pprint(self.key2RPCFlowMetrics)
    # virtual metric calculation
    for keyid,rdb in self.key2RPCFlowMetrics.items():
       self.update_vm('RPCFlowMetrics',self.key2RPCFlowMetrics[keyid])
'''
  def _SFPDiag(self,debug=False):
    return '''
  def extract_SFPDiag(self,debug=False):
    """
    """
'''
  def _TCPFlowMetrics(self,debug=False):
    return '''
  def extract_TCPFlowMetrics(self,debug=False):
    """
    """
    if self.pcapobj.prog2port[program_list_num['RPC2_PROG_NFS3']]==0: return
    for tdb in self.pcapobj.pcapdb:
      if len(tdb['msg'])==0: continue
      if self.pcapobj.prog2port[program_list_num['RPC2_PROG_NFS3']] != 0 and \\
         (tdb['l4'].dest==self.pcapobj.prog2port[program_list_num['RPC2_PROG_NFS3']] or \\
         tdb['l4'].source==self.pcapobj.prog2port[program_list_num['RPC2_PROG_NFS3']]):
        for mdb in tdb['msg']:
          mtype= mdb['rpc'][0].mtype
          if mtype==msg_type_num['RPC2_MSG_TYPE_CALL']: # call
            vers= mdb['rpc'][1].vers
            rpc_version= mdb['rpc'][1].rpc_version
            proc= mdb['rpc'][1].proc
            prog= mdb['rpc'][1].prog
            if prog==program_list_num['RPC2_PROG_NFS3'] and rpc_version==2 and vers==3 and proc in NFS3PROC_num_inv.keys():''' + self.keyid_gen('TCPFlowMetrics',tab=' '*14,call=True,reply=False,debug=debug) + '''
              if keyid not in self.key2TCPFlowMetrics:
                self.key2TCPFlowMetrics[keyid]=copy.deepcopy(container2metricdb['containers']['TCPFlowMetrics'])
              if proc==0:
                metricname='OtherProc'
              else:
                procname=NFS3PROC_num_inv[proc]
                metricname=proc2metric[procname]'''+self.key2metric_gen('TCPFlowMetrics',tab=' '*14,call=True,reply=False,debug=debug)+ '''
              if   metricname == 'WriteProc':
                pass
              elif metricname == 'ReadProc':
                pass
              elif metricname == 'OtherProc':
                pass
              else:
                pass
          elif mtype==msg_type_num['RPC2_MSG_TYPE_REPLY']: # reply
            vers= self.pcapobj.pcapdb[mdb['call msgno'][0]-1]['msg'][mdb['call msgno'][1]-1]['rpc'][1].vers
            rpc_version= self.pcapobj.pcapdb[mdb['call msgno'][0]-1]['msg'][mdb['call msgno'][1]-1]['rpc'][1].rpc_version
            proc= self.pcapobj.pcapdb[mdb['call msgno'][0]-1]['msg'][mdb['call msgno'][1]-1]['rpc'][1].proc
            prog= self.pcapobj.pcapdb[mdb['call msgno'][0]-1]['msg'][mdb['call msgno'][1]-1]['rpc'][1].prog
            if prog==program_list_num['RPC2_PROG_NFS3'] and rpc_version==2 and vers==3 and proc in NFS3PROC_num_inv.keys():''' + self.keyid_gen('TCPFlowMetrics',tab=' '*14,call=False,reply=True,debug=debug) + '''
              # find response time
              reply_ts=self.pcapobj.caltime(tdb['ts'].ts_sec , tdb['ts'].ts_usec)
              call_ts=self.pcapobj.caltime(self.pcapobj.pcapdb[mdb['call msgno'][0]-1]['ts'].ts_sec,self.pcapobj.pcapdb[mdb['call msgno'][0]-1]['ts'].ts_usec)
              resp_time=reply_ts-call_ts
              if keyid not in self.key2TCPFlowMetrics:
                self.key2TCPFlowMetrics[keyid]=copy.deepcopy(container2metricdb['containers']['TCPFlowMetrics'])
              if proc==0:
                metricname='OtherProc'
              else:
                procname=NFS3PROC_num_inv[proc]
                metricname=proc2metric[procname]'''+self.key2metric_gen('TCPFlowMetrics',tab=' '*14,call=True,reply=False,debug=debug)+ '''
              if   metricname == 'WriteProc':
                pass
              elif metricname == 'ReadProc':
                pass
              elif metricname == 'OtherProc':
                pass
              else:
                pass
              #self.key2TCPFlowMetrics[keyid]['SRTTotal]+=[resp_time]
              if proc == NFS3PROC_num["READ"]:
                # Not checking if it has attribute, because if msg meets all of the above
                # conditions and still doesn't have a count3 field, an exception really should be thrown
                self.key2TCPFlowMetrics[keyid][proc]['count3']+=mdb['nfs'][4].count
              reply=mdb['rpc'][1].reply
              if reply==reply_status_num['RPC2_REPLY_STATUS_MSG_ACCEPTED']: 
                self.key2TCPFlowMetrics[keyid][proc]['accepted']+=1
                state=mdb['rpc'][-1].state
                if state == accepted_status_num['RPC2_ACCEPT_STATUS_SUCCESS']:
                  if not hasattr(mdb['nfs'][0], 'nfs3_status') or mdb['nfs'][0].nfs3_status == nfsstat3_num["NFS3_OK"]:
                    self.key2TCPFlowMetrics[keyid][proc]['success']+=1
                    self.key2TCPFlowMetrics[keyid][proc]['nfs_ok']+=1
                  else:
                    self.key2TCPFlowMetrics[keyid][proc]['denied']+=1    
              elif reply==msg_type_num['RPC2_REPLY_STATUS_MSG_DENIED']: 
                self.key2TCPFlowMetrics[keyid][proc]['denied']+=1
    #pprint(self.key2TCPFlowMetrics)
    # virtual metric calculation
    for keyid,rdb in self.key2TCPFlowMetrics.items():
       self.update_vm('TCPFlowMetrics',self.key2TCPFlowMetrics[keyid])
'''
if __name__=='__main__':
  import sys
  argc=len(sys.argv)
  if argc > 1: xmlf=sys.argv[1]
  if argc > 2: codef=sys.argv[2]
if __name__=='__main__':
  import sys
  argc=len(sys.argv)
  if argc > 1: xmlf=sys.argv[1]
  if argc > 2: codef=sys.argv[2]
  obj=xml2formula()
  obj.extract_formula(obj.readxml(xmlf),debug=True)
  #print obj.virtualmetrics
  #print obj.formulas
  obj.run_xml2dict(xmlf,debug=True)
  obj.codegen(codef,debug=True)
  pprint(obj.metric2desc)
  pprint(obj.proc2metric)
  pprint(obj.not_other_procs)
