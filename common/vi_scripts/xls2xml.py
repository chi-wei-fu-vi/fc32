#!/bin/python
from pprint import pformat
from pprint import pprint
import re
import string
import xlrd
from xml.dom import minidom
import xml.etree.ElementTree as ET


class xls2xml(object):
  style_tags=[
'Column',
'Styles',
'Colors',
'ExcelWorkbook',
'OfficeDocumentSettings',
]
  style_attrs=[
'ss:StyleID',
]
  def __init__(self,xls):
    self.wb=xlrd.open_workbook(xls)
    self.shts= self.wb.sheet_names()
    self.xmldict=dict(Workbook = dict(Worksheet = []))
  def read_sheets(self):
    for name in self.shts:
      sht={'@Name' : name, 'Table' : {}, 'WorksheetOptions': None}
      ws=self.wb.sheet_by_name(name)
      table=self.get_ws(ws)
      sht['Table']=table
      self.xmldict['Workbook']['Worksheet'].append(sht)
      
  def get_ws(self,ws):
    table=dict(Row = [])
    for nrow in range(ws.nrows):
      row=dict(Cell = [])
      for ncol in range(ws.ncols):
        value=ws.cell_value(nrow,ncol)
        if isinstance(value,unicode):
          value=value.replace(u'\u201c','"')
          value=value.replace(u'\u201d','"')
        elif isinstance(value,int):
          value=str(value)
        elif isinstance(value,float):
          value=str(int(value))
        

        if value!='':
          row['Cell'].append(value)
        else:
          row['Cell'].append(None)
      table['Row'].append(row)
    return table

  def writexml(self,xml):
    root=self.dict2root(self.xmldict)
    with open(xml,'w') as fh:
      doc=minidom.parseString(ET.tostring(root))
      fh.write(doc.toprettyxml())
  def writedict(self,json):
    with open(json,'w') as fh:
      fh.write(pformat(self.xmldict))


  def dict2root(self,d):
    def to_node(d, node):
      if not d:
        pass
      elif isinstance(d, basestring):
        node.text = d
      elif isinstance(d, dict):
        for k,v in d.items():
          assert isinstance(k, basestring)
          if k.startswith('#'):
            assert k == '#text' and isinstance(v, basestring)
            node.text = v
          elif k.startswith('@'):
            assert isinstance(v, basestring)
            node.set(k[1:], v)
          elif isinstance(v, list):
            for e in v:
              to_node(e, ET.SubElement(node, k))
          else:
            to_node(v, ET.SubElement(node, k))
      else:
        print "Error",type(d),d
        #assert d == 'invalid type', (type(d), d)
    assert isinstance(d, dict) and len(d) == 1
    tag, body = next(iter(d.items()))
    node = ET.Element(tag)
    to_node(body, node)
    return node

    

      

   
if __name__ == '__main__':
  """
  """
  import sys
  import os
  argc=len(sys.argv)
  if argc > 1 : xls = sys.argv[1]
  if argc > 2 : xml = sys.argv[2] 
  if argc > 3 : json = sys.argv[3] 
  obj=xls2xml(xls)
  obj.read_sheets()
  obj.writexml(xml)
  if argc > 3:
    obj.writedict(json)
