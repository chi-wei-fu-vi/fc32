#!/usr/bin/env python2
import re
from pprint import pprint
from pprint import pformat
from veriloglang import *
from collections import deque
from verilogparse import *
from verilogcommon import *


class verilog_top(verilogcommon):
  """
  """
  keyword=''
  fin=''

  def __init__(self,lines):
    """
    """
    self.lines=lines
    self.lines_wo_comment=lines
    self.lines_w_beginblock=lines
    self.lines_wo_tick=lines
    self.extract_beginblock()
    self.rep_beginblock()

  def parse(self):
    """
    """

  def format(self):
    """
    """

  def put(self):
    """
    """

          


class verilog_discipline(verilogcommon):
  """
  """

  keyword='discipline'
  fin='enddiscipline'

  def __init__(self,lines):
    """
    """
    self.lines=lines
    self.lines_wo_comment=lines
    self.lines_w_beginblock=lines
    self.lines_wo_tick=lines
    self.extract_beginblock()
    self.rep_beginblock()

  def parse(self):
    """
    """

  def format(self):
    """
    """

  def put(self):
    """
    """

          


class verilog_function(verilogcommon):
  """
  """

  keyword='function'
  fin='endfunction'

  def __init__(self,lines):
    """
    """
    self.lines=lines
    self.lines_wo_comment=lines
    self.lines_w_beginblock=lines
    self.lines_wo_tick=lines
    self.extract_beginblock()
    self.rep_beginblock()

  def parse(self):
    """
    """

  def format(self):
    """
    """

  def put(self):
    """
    """

          


class verilog_generate(verilogcommon):
  """
  """

  keyword='generate'
  fin='endgenerate'

  def __init__(self,lines):
    """
    """
    self.lines=lines
    self.lines_wo_comment=lines
    self.lines_w_beginblock=lines
    self.lines_wo_tick=lines
    self.extract_beginblock()
    self.rep_beginblock()

  def parse(self):
    """
    """

  def format(self):
    """
    """

  def put(self):
    """
    """

          


class verilog_task(verilogcommon):
  """
  """

  keyword='task'
  fin='endtask'

  def __init__(self,lines):
    """
    """
    self.lines=lines
    self.lines_wo_comment=lines
    self.lines_w_beginblock=lines
    self.lines_wo_tick=lines
    self.extract_beginblock()
    self.rep_beginblock()

  def parse(self):
    """
    """

  def format(self):
    """
    """

  def put(self):
    """
    """

          


class verilog_paramset(verilogcommon):
  """
  """

  keyword='paramset'
  fin='endparamset'

  def __init__(self,lines):
    """
    """
    self.lines=lines
    self.lines_wo_comment=lines
    self.lines_w_beginblock=lines
    self.lines_wo_tick=lines
    self.extract_beginblock()
    self.rep_beginblock()

  def parse(self):
    """
    """

  def format(self):
    """
    """

  def put(self):
    """
    """

          


class verilog_clocking(verilogcommon):
  """
  """

  keyword='clocking'
  fin='endclocking'

  def __init__(self,lines):
    """
    """
    self.lines=lines
    self.lines_wo_comment=lines
    self.lines_w_beginblock=lines
    self.lines_wo_tick=lines
    self.extract_beginblock()
    self.rep_beginblock()

  def parse(self):
    """
    """

  def format(self):
    """
    """

  def put(self):
    """
    """

          


class verilog_nature(verilogcommon):
  """
  """

  keyword='nature'
  fin='endnature'

  def __init__(self,lines):
    """
    """
    self.lines=lines
    self.lines_wo_comment=lines
    self.lines_w_beginblock=lines
    self.lines_wo_tick=lines
    self.extract_beginblock()
    self.rep_beginblock()

  def parse(self):
    """
    """

  def format(self):
    """
    """

  def put(self):
    """
    """

          


class verilog_covergroup(verilogcommon):
  """
  """

  keyword='covergroup'
  fin='endgroup'

  def __init__(self,lines):
    """
    """
    self.lines=lines
    self.lines_wo_comment=lines
    self.lines_w_beginblock=lines
    self.lines_wo_tick=lines
    self.extract_beginblock()
    self.rep_beginblock()

  def parse(self):
    """
    """

  def format(self):
    """
    """

  def put(self):
    """
    """

          


class verilog_package(verilogcommon):
  """
  """

  keyword='package'
  fin='endpackage'

  def __init__(self,lines):
    """
    """
    self.lines=lines
    self.lines_wo_comment=lines
    self.lines_w_beginblock=lines
    self.lines_wo_tick=lines
    self.extract_beginblock()
    self.rep_beginblock()

  def parse(self):
    """
    """

  def format(self):
    """
    """

  def put(self):
    """
    """

          


class verilog_sequence(verilogcommon):
  """
  """

  keyword='sequence'
  fin='endsequence'

  def __init__(self,lines):
    """
    """
    self.lines=lines
    self.lines_wo_comment=lines
    self.lines_w_beginblock=lines
    self.lines_wo_tick=lines
    self.extract_beginblock()
    self.rep_beginblock()

  def parse(self):
    """
    """

  def format(self):
    """
    """

  def put(self):
    """
    """

          


class verilog_primitive(verilogcommon):
  """
  """

  keyword='primitive'
  fin='endprimitive'

  def __init__(self,lines):
    """
    """
    self.lines=lines
    self.lines_wo_comment=lines
    self.lines_w_beginblock=lines
    self.lines_wo_tick=lines
    self.extract_beginblock()
    self.rep_beginblock()

  def parse(self):
    """
    """

  def format(self):
    """
    """

  def put(self):
    """
    """

          


class verilog_module(verilogcommon):
  """
  """

  keyword='module'
  fin='endmodule'

  def __init__(self,lines):
    """
    """
    self.lines=lines
    self.lines_wo_comment=lines
    self.lines_w_beginblock=lines
    self.lines_wo_tick=lines
    self.extract_beginblock()
    self.rep_beginblock()

  def parse(self):
    """
    """

  def format(self):
    """
    """

  def put(self):
    """
    """

          


class verilog_connectrules(verilogcommon):
  """
  """

  keyword='connectrules'
  fin='endconnectrules'

  def __init__(self,lines):
    """
    """
    self.lines=lines
    self.lines_wo_comment=lines
    self.lines_w_beginblock=lines
    self.lines_wo_tick=lines
    self.extract_beginblock()
    self.rep_beginblock()

  def parse(self):
    """
    """

  def format(self):
    """
    """

  def put(self):
    """
    """

          


class verilog_checker(verilogcommon):
  """
  """

  keyword='checker'
  fin='endchecker'

  def __init__(self,lines):
    """
    """
    self.lines=lines
    self.lines_wo_comment=lines
    self.lines_w_beginblock=lines
    self.lines_wo_tick=lines
    self.extract_beginblock()
    self.rep_beginblock()

  def parse(self):
    """
    """

  def format(self):
    """
    """

  def put(self):
    """
    """

          


class verilog_program(verilogcommon):
  """
  """

  keyword='program'
  fin='endprogram'

  def __init__(self,lines):
    """
    """
    self.lines=lines
    self.lines_wo_comment=lines
    self.lines_w_beginblock=lines
    self.lines_wo_tick=lines
    self.extract_beginblock()
    self.rep_beginblock()

  def parse(self):
    """
    """

  def format(self):
    """
    """

  def put(self):
    """
    """

          


class verilog_interface(verilogcommon):
  """
  """

  keyword='interface'
  fin='endinterface'

  def __init__(self,lines):
    """
    """
    self.lines=lines
    self.lines_wo_comment=lines
    self.lines_w_beginblock=lines
    self.lines_wo_tick=lines
    self.extract_beginblock()
    self.rep_beginblock()

  def parse(self):
    """
    """

  def format(self):
    """
    """

  def put(self):
    """
    """

          


class verilog_property(verilogcommon):
  """
  """

  keyword='property'
  fin='endproperty'

  def __init__(self,lines):
    """
    """
    self.lines=lines
    self.lines_wo_comment=lines
    self.lines_w_beginblock=lines
    self.lines_wo_tick=lines
    self.extract_beginblock()
    self.rep_beginblock()

  def parse(self):
    """
    """

  def format(self):
    """
    """

  def put(self):
    """
    """

          


class verilog_config(verilogcommon):
  """
  """

  keyword='config'
  fin='endconfig'

  def __init__(self,lines):
    """
    """
    self.lines=lines
    self.lines_wo_comment=lines
    self.lines_w_beginblock=lines
    self.lines_wo_tick=lines
    self.extract_beginblock()
    self.rep_beginblock()

  def parse(self):
    """
    """

  def format(self):
    """
    """

  def put(self):
    """
    """

          


class verilog_class(verilogcommon):
  """
  """

  keyword='class'
  fin='endclass'

  def __init__(self,lines):
    """
    """
    self.lines=lines
    self.lines_wo_comment=lines
    self.lines_w_beginblock=lines
    self.lines_wo_tick=lines
    self.extract_beginblock()
    self.rep_beginblock()

  def parse(self):
    """
    """

  def format(self):
    """
    """

  def put(self):
    """
    """

          


class verilog_specify(verilogcommon):
  """
  """

  keyword='specify'
  fin='endspecify'

  def __init__(self,lines):
    """
    """
    self.lines=lines
    self.lines_wo_comment=lines
    self.lines_w_beginblock=lines
    self.lines_wo_tick=lines
    self.extract_beginblock()
    self.rep_beginblock()

  def parse(self):
    """
    """

  def format(self):
    """
    """

  def put(self):
    """
    """

