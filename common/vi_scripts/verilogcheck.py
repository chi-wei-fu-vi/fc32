#!/usr/bin/env python2
import re
import copy
from pprint import pprint
from pprint import pformat
from veriloglang import *
class verilogcheck(object):
  logic_directives=(
    'ALLOW_SYNCH_CTRL_USAGE',
    'AUTO_GLOBAL_CLOCK',
    'AUTO_SHIFT_REGISTER_RECOGNITION',
    'DONT_MERGE_REGISTER',
    'FORCED_IF_ASYNCHRONOUS',
    'MERGE_TX_PLL_DRIVEN_BY_REGISTERS_WITH_SAME_CLEAR',
    'POWER_UP_LEVEL',
    'PRESERVE_FANOUT_FREE_NODE',
    'PRESERVE_REGISTER',
    'REMOVE_DUPLICATE_REGISTERS',
    'SYNCHRONIZER_IDENTIFICATION'
  )
  module_directives=(
    'ADV_NETLIST_OPT_SYNTH_WYSIWYG_REMAP',
    'ALLOW_ANY_RAM_SIZE_FOR_RECOGNITION',
    'ALLOW_CHILD_PARTITIONS',
    'OPTIMIZE_POWER_DURING_SYNTHESIS=NORMAL_COMPILATION',
    'PHYSICAL_SYNTHESIS_COMBO_LOGIC',
    'PHYSICAL_SYNTHESIS_REGISTER_RETIMING',
    'pll_type_fnl',
    'pll_type_sdc',
    'REMOVE_REDUNDANT_LOGIC_CELLS',
    'suppress_da_rule_internal',
    'SYNC_AN_CONSTRAINT',
    'SYNC_BLOCK_LOCK_CONSTRAINT',
    'SYNC_HIBER_CONSTRAINT',
    'SYNCHRONIZER_IDENTIFICATION',
    'SYNC_RXDATA_READY_CONSTRAINT',
    'SYNC_RXFIFO_FULL_CONSTRAINT',
    'SYNC_RXSCRAMBLER_ERROR_CONSTRAINT',
    'SYNC_RXSYNCHEAD_ERROR_CONSTRAINT',
    'SYNC_TXFIFO_FULL_CONSTRAINT'
  )
  sdc_directives=(
    'TX_SDC_CONSTRAINTS',
    'RX_SDC_CONSTRAINTS',
    'SDC_1588_CONSTRAINTS',
    'SDC_8G_TO_FEC',
    'SDC_STATEMENT'
  )
  common_directives=(
    'MESSAGE_DISABLE',
    'ADV_NETLIST_OPT_ALLOWED',
    'suppress_da_rule_internal',
    'ALLOW_ANY_ROM_SIZE_FOR_RECOGNITION',
    'AUTO_ROM_RECOGNITION'
    'ALLOW_ANY_RAM_SIZE_FOR_RECOGNITION',
    'AUTO_RAM_RECOGNITION=ON',
    'AUTO_SHIFT_REGISTER_RECOGNITION',
    'BLOCK_RAM_TO_MLAB_CELL_CONVERSION',
    'disable_da_rule',
    'AUTO_MERGE_PLLS OFF',
    'FITTER_ADJUST_HC_SHORT_PATH_GUARDBAND',
    'IP_TOOL_NAME',
    'IP_TOOL_VERSION',
    'ALLOW_SYNCH_CTRL_USAGE',
    'AUTO_CLOCK_ENABLE_RECOGNITION',
    'MERGE_TX_PLL_DRIVEN_BY_REGISTERS_WITH_SAME_CLEAR'
    'AUTO_GLOBAL_REGISTER_CONTROLS'
  )
  def __init__(self):
    """
    """
    obj=veriloglang()
    obj.standard2keywords('1800-2012')
    self.kwds=obj.kwds

  def check_slashdouble(self,comments):
    """
    synthesis attribute register_powerup of reset_n is 0 
    synthesis full_case 
    synthesis full_case parallel_case 
    synthesis get minimum depth 
    synthesis_off 
    synthesis_on 
    synthesis read_comments_as_HDL off 
    synthesis read_comments_as_HDL on 
    synthesis_resources = 
    synthesis syn_black_box 
    synthesis translate off 
    synthesis translate_off 
    synthesis translate on 
    synthesis translate_on 
    synthesis verilog_input_version verilog_2001 
    
    altera message_level level1
    altera message_off 10030
    altera message_on 10036
    altera translate_off
    altera translate_on
    """
    outs=[]
    for attrs in comments:
      comment=attrs[0][2:].lstrip()
      if comment.startswith('ALTERA_ATTRIBUTE') or comment.startswith('altera_attribute'):
        outs.append(attrs+('E00023',))
      elif comment.startswith('synthesis ') or comment.startswith('synthesis translate'):
        outs.append(attrs+('E00023',))
      elif comment.startswith('altera message_') or comment.startswith('altera translate_'):
        outs.append(attrs+('E00023',))
      else:
        outs.append(attrs+('',))
    return outs
  def check_slashstar(self,comments):
    """
ALTERA_ATTRIBUTE = "-name SDC_STATEMENT \"set_false_path -from [get_registers *hxaui_0*hxaui_alt4gxb*hxaui_alt4gxb_alt4gxb_dksa_component*] -to [get_registers *xaui_phy*hxaui_csr*tx_phase_comp_fifo_error_c[*]]\" "
    """
    outs=[]
    for attrs in comments:
      comment=attrs[0][2:].lstrip()
      if comment.startswith('ALTERA_ATTRIBUTE') or comment.startswith('altera_attribute'):
        outs.append(attrs+('E00024',))
      elif comment.startswith('synthesis ') or comment.startswith('synthesis translate'):
        outs.append(attrs+('E00024',))
      elif comment.startswith('altera message_') or comment.startswith('altera translate_'):
        outs.append(attrs+('E00024',))
      else:
        outs.append(attrs+('',))
    return outs
      
  def check_parenthesesstar(self,comments):
    """
    """
    def extract_directives(rules):
      """
      """
      outs=[]
      for rule in rules:
        rule=rule.strip()
        if (rule.startswith('"') and rule.endswith('"')) or \
           (rule.startswith("'") and rule.endswith("'")): 
          rule=rule[1:-1].strip()
        outs.append(rule)
      return outs
   
    outs=[]
    for attrs in comments:
      comment=attrs[0][2:].lstrip()
      nextword=attrs[1]
      if nextword == '':
        if 'translate_on' in comment or \
           'translate_off' in comment or \
           'translate on' in comment or \
           'translate off' in comment:
          outs.append(attrs+('',))
        else:
          outs.append(attrs+('E00026',))
      else:
        if 'RX_SDC_CONSTRAINTS' in comment or 'TX_SDC_CONSTRAINTS' in comment or 'SDC_STATEMENT' in comment:
          outs.append(attrs+('E00025',))
        elif comment.startswith('ALTERA_ATTRIBUTE') or comment.startswith('altera_attribute'):
          comment=comment[16:].strip()
          if comment.startswith('{') and comment.endswith('}'):
            rules=comment[1:-1].split(';')
          else:
            rules=[comment]
          rules=extract_directives(rules)
          if nextword == 'logic' or nextword == 'reg':
            error=False
            for rule in rules:
              match=False
              for directive in self.logic_directives: 
                if directive in rule:
                  match=True
                  break
              if not match:
                error=True
                break
            if error:
              outs.append(attrs+('E00026',))
          elif nextword == 'module':
            error=False
            for rule in rules:
              match=False
              for directive in self.module_directives: 
                if directive in rule:
                  match=True
                  break
              if not match:
                error=True
                break
            if error:
              outs.append(attrs+('E00026',))
          elif nextword not in self.kwds:
            outs.append(attrs+('',))
          else:
            outs.append(attrs+('',))
        elif comment.startswith('synthesis ') or comment.startswith('synthesis translate'):
          outs.append(attrs+('E00024',))
        elif comment.startswith('altera message_') or comment.startswith('altera translate_'):
          outs.append(attrs+('E00024',))
        else:
          outs.append(attrs+('',))
    return outs
