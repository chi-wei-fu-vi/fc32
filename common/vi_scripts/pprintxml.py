#!/usr/bin/python
import xml.dom.minidom
from pprint import pprint
from pprint import pformat
import re
class pprintxml(object):
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
  def __init__(self):
    """
    """
  def read(self,fname):
    """
    """
    self.doc=xml.dom.minidom.parse(fname)
  def remove_tag(self):
    """
    """
    for tag in self.style_tags:
      for element in self.doc.getElementsByTagName(tag):
        parentNode = element.parentNode
        #parentNode.insertBefore(self.doc.createComment(element.toxml()),element)
        parentNode.removeChild(element)
  def remove_data_tag(self):
    """
    """
    for element in self.doc.getElementsByTagName('Data'):
      value=element.firstChild.nodeValue.strip()
      parentNode = element.parentNode
      #parentNode.insertBefore(self.doc.createComment(element.toxml()),element)
      parentNode.removeChild(element)
      if value is None:
        textNode=self.doc.createTextNode('')
        parentNode.appendChild(textNode)
      else:
        textNode=self.doc.createTextNode(value)
        parentNode.appendChild(textNode)
  def remove_attrs(self):
    """
    """
    def remove(p):
      for node in p.childNodes:
        remove(node)
        if node.attributes:
          for key in node.attributes.keys():
            if key !='ss:Name':
              node.removeAttribute(key)
    remove(self.doc)

  def write(self,fname):
    """
    """
    with open(fname,'w') as f:
      f.write(self.doc.toprettyxml().replace(u'\u201c','"').replace(u'\u201d','"'))
      f.close()
    

if __name__ == '__main__':
  """
  """
  import sys
  argc=len(sys.argv)
  if argc >1 : inxml   =sys.argv[1]
  if argc >2 : outxml  =sys.argv[2]
  obj=pprintxml()
  obj.read(inxml)
  obj.remove_tag()
  obj.remove_attrs()
  obj.remove_data_tag()
  obj.write(outxml)
