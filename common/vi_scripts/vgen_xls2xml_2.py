#!/usr/bin/env python2
import xml.dom.minidom

rows=[]


def readxls(file):
  """
  """
  wb = open_workbook(file)
  ws = wb.sheet_by_index(0)
  for row in range(ws.nrows):
    #print ws.row_values(row)
    rows.append(ws.row_values(row))


def writexml(file):
  """
<!-- This is sample xml file for a single register generation. -->
<decl_reg_list> 
  <register name="my_RW_reg" offset="10'h0" default="64'h0" type="RW" usr="1">
    Brief description for the register is here.
    <field name="my_field1" loc="[3:0]"> Field description is here </field>
    <field name="my_field2" loc="[10:9]"> Field description is here </field>  
  </register>
</decl_reg_list>
  """
  OUTFILE=open(file,"w")
  doc = xml.dom.minidom.Document()

  # Create the <dec_reg_list> base element
  decl_reg_list = doc.createElement("decl_reg_list")
  doc.appendChild(decl_reg_list)

  regname_old=""
  rows.pop(0)
  for row in rows:
    (regdesc,regname,offset,default,regtype,expose_reg,depth,incsz,bitdesc,bitname,loc,bittype)= row
    if regname != regname_old:
      # Create the register element
      register = doc.createElement("register")
      register.setAttribute("name", regname)
      register.setAttribute("offset", offset)
      if default != "" : register.setAttribute("default", default)
      register.setAttribute("type", regtype)
      if expose_reg == "1": register.setAttribute("usr", expose_reg)
      if depth != "": register.setAttribute("size", depth)
      if incsz != "": register.setAttribute("incsz", incsz)
      text = doc.createTextNode(regdesc)
      register.appendChild(text)
      decl_reg_list.appendChild(register)
  
    # Create the field element
    if bitname != "":
      field = doc.createElement("field")
      field.setAttribute("name", bitname)
      if loc !="": field.setAttribute("loc", addcolon(loc))
      if bittype != "": field.setAttribute("type", bittype)
      if bitdesc != "":
        text = doc.createTextNode(bitdesc)
        field.appendChild(text)
      register.appendChild(field)
    regname_old = regname


  # Print our newly created XML
  #print doc.toprettyxml(indent="  ")
  #OUTFILE.write(doc.saveXML(decl_reg_list))
  OUTFILE.write(doc.toprettyxml(indent="  "))
  OUTFILE.close()

def addcolon(loc):
  """ 
  change [0] to [0:0]
  """ 
  if ":" not in loc:
    #print loc
    loc=loc[1:-1]
    #print loc
    loc="[%s:%s]"%(loc,loc)
    #print loc
  return loc
 

if __name__ == '__main__':
  """
  """
  import sys
  import os
  argc=len(sys.argv)
  libdir = os.path.dirname(os.path.realpath(__file__)) + "/lib"
  sys.path.append(libdir)  # for lib/xlrd module
  from xlrd import *
  if argc > 1 : xls = sys.argv[1]
  if argc > 2 : out = sys.argv[2] # xml format

  readxls(xls)
  writexml(out)



