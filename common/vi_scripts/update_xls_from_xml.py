#!/usr/bin/env python2
import copy
import xlrd
import xlwt
import xlutils.copy
from xml.sax import saxutils
from xml.sax import parse

from pprint import pprint
class ExcelHandler(saxutils.handler.ContentHandler):

  def __init__(self):
    self.chars = [  ]
    self.cells = [  ]
    self.rows = [  ]
    self.tables = [  ]
    self.worksheets =[]
  def characters(self, content):
    self.chars.append(content)
  def startElement(self, name, atts):
    if name=="Cell":
      self.chars = [  ]
    elif name=="Row":
      self.cells=[  ]
    elif name=="Table":
      self.rows = [  ]
    elif name=="ss:Worksheet" or name=="Worksheet":
      #print atts.items()
      #print atts.getValue('ss:Name')
      if 'ss:Name' in atts:
        self.worksheets.append(atts.getValue('ss:Name'))
      else:
        self.worksheets.append(atts.getValue('Name'))
  def endElement(self, name):
    if name=="Cell":
      self.cells.append(''.join(self.chars))
    elif name=="Row":
      self.rows.append(self.cells)
    elif name=="Table":
      self.tables.append(self.rows)

class update_xls_from_xml(object):

  def __init__(self,from_xml,to_xls,wr_xls):

    self.from_xml=from_xml
    self.to_xls=to_xls
    self.wr_xls=wr_xls
    self.excelobj=ExcelHandler()
    self.to_xls_tables=[]
    self.to_xls_ttables=[]
    self.update_ws={}
    
  def readxls(self):
    """
    """
    with xlrd.open_workbook(self.to_xls,formatting_info=True) as to_wb:
      self.to_xls_wsnames=to_wb._sheet_names
      self.wr_wb=xlutils.copy.copy(to_wb)
      for idx,ws in enumerate(to_wb.sheets()):
        sheet=[]
        tsheet=[]
        for ridx in range(ws.nrows):
          sheet.append(ws.row_values(ridx))
          tsheet.append(ws.row_types(ridx))
        self.to_xls_tables.append(sheet)
        self.to_xls_ttables.append(tsheet)
      

  def readxml(self):
    """
    """
    parse(self.from_xml,self.excelobj)
    self.from_xml_wsnames=self.excelobj.worksheets
    self.from_xml_tables=self.excelobj.tables

  def diff_tables(self):
    """
    """
    self.xls_only_shts= list(set(self.to_xls_wsnames)-set(self.from_xml_wsnames))
    self.xml_only_shts= list(set(self.from_xml_wsnames)-set(self.to_xls_wsnames))
    self.common_shts= list(set(self.from_xml_wsnames)&set(self.to_xls_wsnames))
    if len(self.xls_only_shts)>0:
      print "ERROR: extra worksheets in xls",self.xls_only_shts
    if len(self.xml_only_shts)>0:
      print "ERROR: extra worksheets in xml",self.xml_only_shts
    if len(self.xls_only_shts)>0 or len(self.xml_only_shts)>0:
      exit(-1)
    for wsname in self.common_shts:
      xls_sidx=self.to_xls_wsnames.index(wsname)
      xml_sidx=self.from_xml_wsnames.index(wsname)
      xls_ws=self.to_xls_tables[xls_sidx]
      xml_ws=self.from_xml_tables[xml_sidx]
      #print wsname
      for ridx in range(max(len(xls_ws),len(xml_ws))):
        if len(xls_ws) > len(xml_ws):
          pass
        elif len(xls_ws) < len(xml_ws):
          for cidx in range(len(xml_ws[rdix])):
            if xml_ws[cidx]!='':
              if wsname not in self.update_ws:
                self.update_ws[wsname]=[]
              self.update_ws[wsname].append(('lt',ridx,cidx,'',xml_ws[ridx][cidx]))
        else:
          for cidx in range(min(len(xls_ws[ridx]),len(xml_ws[ridx]))):
            if xls_ws[ridx][cidx]!=xml_ws[ridx][cidx] and not self.checkeq(xls_ws[ridx][cidx],xml_ws[ridx][cidx]):
              if wsname not in self.update_ws:
                self.update_ws[wsname]=[]
              self.update_ws[wsname].append(('eq',ridx,cidx,xls_ws[ridx][cidx],xml_ws[ridx][cidx]))
              #print xls_ws[ridx][cidx],xml_ws[ridx][cidx]

          if len(xls_ws[ridx])<len(xml_ws[ridx]):
            for cidx in range(len(xls_ws[ridx]),len(xml_ws[ridx])):
              if xml_ws[ridx][cidx]!='':
                if wsname not in self.update_ws:
                  self.update_ws[wsname]=[]
                self.update_ws[wsname].append(('eq',ridx,cidx,'',xml_ws[ridx][cidx]))
          


  def checkeq(self,xls_value,xml_value):
    """
    ('eq', 2, 126, 9000.0, u'9000')
    ('eq', 1, 1, 1, u'1')
    ('eq', 9, 4, u'\u201c00\u201d*1500', u'"00"*1500'),
    """
    if isinstance(xls_value,float) and isinstance(xml_value,unicode):
      return xls_value == float(xml_value)
    if isinstance(xls_value,int) and isinstance(xml_value,unicode):
      return xls_value == int(xml_value)
    if isinstance(xls_value,unicode) and isinstance(xml_value,unicode):
      print xls_value.replace(u'\u201c','"').replace(u'\u201d','"'),xml_value
      return xls_value.replace(u'\u201c','"').replace(u'\u201d','"') == xml_value
    return xls_value==xml_value
   
  def update_from_xml(self):
    """
    """
    for wsname,update_list in self.update_ws.items():
      ws=self.wr_wb.get_sheet(self.wr_wb._Workbook__worksheet_idx_from_name[wsname])
      for _,ridx,cidx,_,value in update_list:
        ws.write(ridx,cidx,value)
    # fix hyperlink (bug in xlutils.copy)
    ws=self.wr_wb.get_sheet(self.wr_wb._Workbook__worksheet_idx_from_name['index'])
    xls_sidx=self.to_xls_wsnames.index('index')
    table=self.to_xls_tables[xls_sidx]
    ttable=self.to_xls_ttables[xls_sidx]
    for ridx in range(ws.last_used_row+1):
      for cidx in range(ws.last_used_col+1):
        value=table[ridx][cidx]
        typ=ttable[ridx][cidx]
        
        print ridx,cidx,value,typ
        if value.endswith('interface') or value.endswith('gen'):
          ws.write(ridx,cidx,xlwt.Formula('HYPERLINK("#{0}!A1";"{0}")'.format(value)))
          
    self.wr_wb.save(self.wr_xls)

if __name__=='__main__':
  """
  copy to_xls to wr_xls and insert worksheets from from_xml which are not existed in to_xls to wr_xls.
  """
  import sys
  argc=len(sys.argv)
  if argc > 1: from_xml=sys.argv[1]
  if argc > 2: to_xls=sys.argv[2]
  if argc > 3: wr_xls=sys.argv[3]
  obj=update_xls_from_xml(from_xml,to_xls,wr_xls)
  obj.readxls()
  obj.readxml()
  obj.diff_tables()
  obj.update_from_xml()
  #pprint(obj.update_ws)
