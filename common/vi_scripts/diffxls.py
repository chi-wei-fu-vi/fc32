#!/bin/python
import xlrd
from pprint import pprint
import string

class diffxls(object):
  def __init__(self,oldxls,newxls):
    self.old_wb=xlrd.open_workbook(oldxls)
    self.new_wb=xlrd.open_workbook(newxls)
  def diffworkbook(self):
    self.old_only_shts= list(set(self.old_wb.sheet_names())-set(self.new_wb.sheet_names()))
    self.new_only_shts= list(set(self.new_wb.sheet_names())-set(self.old_wb.sheet_names()))
    self.common_shts= list(set(self.new_wb.sheet_names())&set(self.old_wb.sheet_names()))
    print "missing sheets: %s"%self.old_only_shts
    print "extra sheets: %s"%self.new_only_shts
  def diffsheets(self):
    for name in self.common_shts:
      old_ws=self.old_wb.sheet_by_name(name)
      new_ws=self.new_wb.sheet_by_name(name)
      old_table=self.get_ws(old_ws)
      new_table=self.get_ws(new_ws)
      if old_table!=new_table:
        print 'sheet "%s" is difference'%name
        self.difftable(name,old_table,new_table)
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
  def get_ws(self,ws):
    table=[]
    for nrow in range(ws.nrows):
      row=[]
      for ncol in range(ws.ncols):
        value=ws.cell_value(nrow,ncol)
        row.append(value)
      table.append(row)
    return table
      

   
if __name__ == '__main__':
  """
  """
  import sys
  import os
  argc=len(sys.argv)
  if argc > 1 : oldxls = sys.argv[1]
  if argc > 2 : newxls = sys.argv[2] 
  obj=diffxls(oldxls,newxls)
  obj.diffworkbook()
  obj.diffsheets()
