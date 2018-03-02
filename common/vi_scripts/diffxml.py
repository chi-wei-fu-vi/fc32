#!/usr/bin/env python2.7
import re
import sys
import os
from xml.sax import saxutils
from xml.sax import parse
from pprint import pprint
import pprint
import copy
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

class readxml(object):
  """
  """
  def __init__(self,xml):
    self.excelobj=ExcelHandler( )
    parse(xml, self.excelobj)
    self.worksheets=self.excelobj.worksheets
    self.tables=self.excelobj.tables

  def __repr__(self):
    return pprint.pformat(self.excelobj.tables)

class diffxml(object):
  """
  """
  def __init__(self,oldxml,newxml):
    self.newxmlobj=readxml(newxml)
    self.oldxmlobj=readxml(oldxml)
    
  def diffworkbook(self):
    self.old_only_shts= list(set(self.oldxmlobj.worksheets)-set(self.newxmlobj.worksheets))
    self.new_only_shts= list(set(self.newxmlobj.worksheets)-set(self.oldxmlobj.worksheets))
    self.common_shts= list(set(self.newxmlobj.worksheets)&set(self.oldxmlobj.worksheets))
    print "missing sheets: %s"%self.old_only_shts
    print "extra sheets: %s"%self.new_only_shts

  def diffsheets(self):
    for name in self.common_shts:
      old_table=self.oldxmlobj.tables[self.oldxmlobj.worksheets.index(name)]
      new_table=self.newxmlobj.tables[self.newxmlobj.worksheets.index(name)]
      self.remove_empty_row(old_table)
      self.remove_empty_row(new_table)
      if old_table!=new_table:
        print 'sheet "%s" is difference'%name
        self.difftable(name,old_table,new_table)
  def remove_empty_row(self,table):
    row=table.pop()
    while row==['']*len(row):
      row=table.pop()


  def difftable(self,name,old,new):
    # missing row
    if len(old) > len(new):
      print "\"%s\" missing rows: %s"%(name,range(len(new)+1,len(old)+1))
    # extra row
      print "\"%s\" extra rows: %s"%(name,range(len(old)+1,len(new)+1))
    # common row
    for row in range(min(len(old),len(new))):
      # missing col
      if len(old[row]) > len(new[row]):
        print "\"%s\" missing cols: %s"%(name,range(len(new[row])+1,len(old[row])+1))
      # extra col
      if len(old[row]) < len(new[row]):
        print "\"%s\" extra cols: %s"%(name,range(len(old[row])+1,len(new[row])+1))
      for col in range(min(len(old[row]),len(new[row]))):
        if old[row][col]!= new[row][col]:
          print "\"%s\"(%d,%d) '%s' vs '%s'"%(name,row+1,col+1, old[row][col],new[row][col])



    
if __name__ == '__main__':
  argc=len(sys.argv)
  if argc > 1: oldxml=sys.argv[1]
  if argc > 2: newxml=sys.argv[2]
  obj=diffxml(oldxml,newxml)
  obj.diffworkbook()
  obj.diffsheets()

