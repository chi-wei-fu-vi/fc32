#!/usr/bin/env python2
import re
from pprint import pprint
from pprint import pformat
from collections import namedtuple
class veriloglang(object):
  """
verification
  assertions
  test program blocks
  clocking domains
  process control
  mailboxes
  semaphores
  constrained random values
  direct C function calls
  classes
  inheritance
  strings
  references
  dynamic arrays
  associative arrays
  queues
  checkers
  2-state types
  shortreal type
  globals
  let macros

design:
  enum
  typedef
  structures
  unions
  2-state types
  packages
  $unit
  ++ -- += -= *= /= 
  >>= <<= >>>= <<<=
  &= |= ^= %=
  ==? !=?
  inside
  streaming
  casting
  break 
  continue
  return 
  do-while
  case inside
  aliasing
  const
  interfaces
  nested hierarchy
  unrestricted ports
  automatic port connect
  enhanced literals
  time values and units
  specialized procedures
  packed arrays
  array assignments
  unique/priority case/if
  void functions
  function input defaults
  function array args
  parameterized types



verilog-1995
  initial
  disable
  events 
  wait # @
  fork-join
  $finish $fopen $fclose
  $display $write 
  $monitor
  `define `ifdef `else
  `include `timescale
  wire reg
  integer real
  time
  packed arrays
  2D memory
  + = * / 
  %
  >> <<
  modules
  parameters
  function/tasks
  always @
  assign
  begin-end
  while
  for forever
  if-else
  repeat


verilog-2001
  ANSI C style ports
  generate
  localparam
  constant functions 
  standard file I/O
  $value$plusargs
  `ifndef `elsif `line
  @*
  (* attributes *)
  configurations
  memory part selects
  variable part select
  multi dimensional arrays 
  signed types
  automatic
  ** (power operator)

Verilog-2005
  uwire
  `begin_keywords
  `pragma
  $clog2
  """
  kwds=()
  keywords_cls=namedtuple('keywords','v1364_1995 v1364_2001 v1364_2005 v1800_2005 v1800_2009 v1800_2012 VAMS')
  keywords=keywords_cls(
v1364_1995=('always',
          'and',
          'assign',
          'begin',
          'buf',
          'bufif0',
          'bufif1',
          'case',
          'casex',
          'casez',
          'cmos',
          'deassign',
          'default',
          'defparam',
          'disable',
          'else',
          'end',
          'endcase',
          'endfunction',
          'endmodule',
          'endprimitive',
          'endspecify',
          'endtable',
          'endtask',
          'event',
          'for',
          'force',
          'forever',
          'fork',
          'function',
          'highz0',
          'highz1',
          'if',
          'initial',
          'inout',
          'input',
          'integer',
          'join',
          'large',
          'macromodule',
          'medium',
          'module',
          'nand',
          'negedge',
          'nmos',
          'nor',
          'not',
          'notif0',
          'notif1',
          'or',
          'output',
          'parameter',
          'pmos',
          'posedge',
          'primitive',
          'pull0',
          'pull1',
          'pulldown',
          'pullup',
          'rcmos',
          'real',
          'realtime',
          'reg',
          'release',
          'repeat',
          'rnmos',
          'rpmos',
          'rtran',
          'rtranif0',
          'rtranif1',
          'scalared',
          'small',
          'specify',
          'strength',
          'strong0',
          'strong1',
          'supply0',
          'supply1',
          'table',
          'task',
          'time',
          'tran',
          'tranif0',
          'tranif1',
          'tri',
          'tri0',
          'tri1',
          'triand',
          'trior',
          'trireg',
          'vectored',
          'wait',
          'wand',
          'weak0',
          'weak1',
          'while',
          'wire',
          'wor',
          'xnor',
          'xor'),
v1364_2001=('automatic',
          'cell',
          'config',
          'design',
          'edge',
          'endconfig',
          'endgenerate',
          'generate',
          'genvar',
          'ifnone',
          'incdir',
          'include',
          'instance',
          'liblist',
          'library',
          'localparam',
          'noshowcancelled',
          'pulsestyle_ondetect',
          'pulsestyle_onevent',
          'showcancelled',
          'signed',
          'specparam',
          'unsigned',
          'use'),
v1364_2005=('uwire',),
v1800_2005=('alias',
          'always_comb',
          'always_ff',
          'always_latch',
          'assert',
          'assume',
          'before',
          'bind',
          'bins',
          'binsof',
          'bit',
          'break',
          'byte',
          'chandle',
          'class',
          'clocking',
          'const',
          'constraint',
          'context',
          'continue',
          'cover',
          'covergroup',
          'coverpoint',
          'cross',
          'dist',
          'do',
          'endclass',
          'endclocking',
          'endgroup',
          'endinterface',
          'endpackage',
          'endprogram',
          'endproperty',
          'endsequence',
          'enum',
          'expect',
          'export',
          'extends',
          'extern',
          'final',
          'first_match',
          'foreach',
          'forkjoin',
          'iff',
          'ignore_bins',
          'illegal_bins',
          'import',
          'inside',
          'int',
          'interface',
          'intersect',
          'join_any',
          'join_none',
          'local',
          'logic',
          'longint',
          'matches',
          'modport',
          'new',
          'null',
          'package',
          'packed',
          'priority',
          'program',
          'property',
          'protected',
          'pure',
          'rand',
          'randc',
          'randcase',
          'randsequence',
          'ref',
          'return',
          'sequence',
          'shortint',
          'shortreal',
          'solve',
          'static',
          'string',
          'struct',
          'super',
          'tagged',
          'this',
          'throughout',
          'timeprecision',
          'timeunit',
          'type',
          'typedef',
          'union',
          'unique',
          'var',
          'virtual',
          'void',
          'wait_order',
          'wildcard',
          'with',
          'within'),
v1800_2009=('accept_on',
          'checker',
          'endchecker',
          'eventually',
          'global',
          'implies',
          'let',
          'nexttime',
          'reject_on',
          'restrict',
          's_always',
          's_eventually',
          's_nexttime',
          's_until',
          's_until_with',
          'strong',
          'sync_accept_on',
          'sync_reject_on',
          'unique0',
          'until',
          'until_with',
          'untyped',
          'weak'),
v1800_2012=('implements', 'nettype', 'interconnect', 'soft'),
VAMS=('above',
          'abs',
          'absdelay',
          'abstol',
          'ac_stim',
          'access',
          'acos',
          'acosh',
          'aliasparam',
          'analog',
          'analysis',
          'asin',
          'asinh',
          'assert',
          'atan',
          'atan2',
          'atanh',
          'branch',
          'ceil',
          'connect',
          'connectmodule',
          'connectrules',
          'continuous',
          'cos',
          'cosh',
          'cross',
          'ddt',
          'ddt_nature',
          'ddx',
          'discipline',
          'discrete',
          'domain',
          'driver_update',
          'endconnectrules',
          'enddiscipline',
          'endnature',
          'endparamset',
          'exclude',
          'exp',
          'final_step',
          'flicker_noise',
          'floor',
          'flow',
          'from',
          'ground',
          'hypot',
          'idt',
          'idt_nature',
          'idtmod',
          'inf',
          'initial_step',
          'laplace_nd',
          'laplace_np',
          'laplace_zd',
          'laplace_zp',
          'last_crossing',
          'limexp',
          'ln',
          'log',
          'max',
          'merged',
          'min',
          'nature',
          'net_resolution',
          'noise_table',
          'paramset',
          'potential',
          'pow',
          'resolveto',
          'sin',
          'sinh',
          'slew',
          'split',
          'sqrt',
          'string',
          'tan',
          'tanh',
          'timer',
          'transition',
          'units',
          'white_noise',
          'wreal',
          'zi_nd',
          'zi_np',
          'zi_zd',
          'zi_zp'))
  directives_cls=namedtuple('directives','v1364_1995 v1364_2001 v1364_2005')
  directives=directives_cls(
v1364_1995=('`celldefine',
          '`define',                            # Preprocessor
          '`else',                              # Preprocessor
          '`endcelldefine',
          '`endif',                             # Preprocessor
          '`ifdef',                             # Preprocessor
          '`include',                           # Preprocessor
          '`nounconnected_drive',
          '`resetall',
          '`timescale',
          '`unconnected_drive',
          '`undef',                             # Preprocessor
          '`undefineall',                       # Preprocessor
          '`accelerate',                        # Verilog-XL
          '`autoexpand_vectornets',             # Verilog-XL
          '`default_decay_time',
          '`default_trireg_strength',
          '`delay_mode_distributed',
          '`delay_mode_path',
          '`delay_mode_unit',
          '`delay_mode_zero',
          '`disable_portfaults',                # Verilog-XL
          '`enable_portfaults',                 # Verilog-XL
          '`endprotect',                        # Vendor tools
          '`endprotected',                      # Vendor tools
          '`expand_vectornets',                 # Verilog-XL
          '`noaccelerate',                      # Verilog-XL
          '`noexpand_vectornets',               # Verilog-XL
          '`noremove_gatenames',                # Verilog-XL
          '`noremove_netnames',                 # Verilog-XL
          '`nosuppress_faults',                 # Verilog-XL
          '`nounconnected_drive',               # Verilog-XL
          '`portcoerce',                        # Verilog-XL
          '`protect',                           # Vendor tools
          '`protected',                         # Vendor tools
          '`remove_gatenames',                  # Verilog-XL
          '`remove_netnames',                   # Verilog-XL
          '`suppress_faults'),                  # Verilog-XL
v1364_2001=('`default_nettype', '`elsif', '`undef', '`ifndef', '`file', '`line'),
v1364_2005=('`pragma`default_discipline', '`default_transition'))
  gateprims_cls=namedtuple('gateprims','v1364_1995')
  gateprims=gateprims_cls(
v1364_1995=('and',
          'buf',
          'bufif0',
          'bufif1',
          'cmos',
          'nand',
          'nmos',
          'nor',
          'not',
          'notif0',
          'notif1',
          'or',
          'pmos',
          'pulldown',
          'pullup',
          'rcmos',
          'rnmos',
          'rpmos',
          'rtran',
          'rtranif0',
          'rtranif1',
          'tran',
          'tranif0',
          'tranif1',
          'xnor',
          'xor'))
  def standard2keywords(self,standard):
    """
    """
    stds=[]
    if (standard == '1995') or standard == ('1364-1995') :
      stds = ('1364_1995')
    elif (standard == '2001' or standard == '1364-2001' or standard == '1364-2001-noconfig') :
      stds = ('1364_2001', '1364_1995')
    elif (standard == '1364-2005') :
      stds = ('1364_2005', '1364_2001', '1364_1995')
    elif (standard == 'sv31' or standard == '1800-2005') :
      stds = ('1800_2005', '1364_2005', '1364_2001', '1364_1995')
    elif (standard == '1800-2009') :
      stds = ('1800_2009', '1800_2005', '1364_2005', '1364_2001', '1364_1995')
    elif (standard == 'latest' or standard == '1800-2012') :
      stds = ('1800_2012', '1800_2009', '1800_2005', '1364_2005', '1364_2001', '1364_1995')
    elif standard.endswith('AMS') :
      stds = ('VAMS', '1364_2005', '1364_2001', '1364_1995')
    else :
      print "Error: bad standard value %s"%standard
    stds=map(lambda x: 'v%s'%x if x[0].isdigit() else x,stds)
    for std in stds:
      if std in self.keywords._fields:
        self.kwds+=tuple(eval('self.keywords.%s'%(std)))
        
    

if __name__=='__main__':
  import sys
  argc=len(sys.argv)
  if argc > 1: infile=sys.argv[1]
  for f in veriloglang.keywords._fields:
    pprint(eval('veriloglang.keywords.%s'%f))
  for n,f in zip(veriloglang.keywords._fields,veriloglang.keywords):
    print "%s=%s"%(n,pformat(f,10).replace('[','(').replace(']',')'))
  for n,f in zip(veriloglang.directives._fields,veriloglang.directives):
    print "%s=%s"%(n,pformat(f,10).replace('[','(').replace(']',')'))
  for n,f in zip(veriloglang.gateprims._fields,veriloglang.gateprims):
    print "%s=%s"%(n,pformat(f,10).replace('[','(').replace(']',')'))
  obj=veriloglang()
  obj.standard2keywords('1800-2012')
  print sorted(obj.kwds)
