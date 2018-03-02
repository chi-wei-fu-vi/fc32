#!/usr/bin/env python2
import xml.dom.minidom
from pprint import pprint
class reg_xml(object):
  """
  """
  file=''
  debug=0
  def __init__(self,
               fname,
               debug=0):
    """
    """
    self.debug=debug
    self.src2param={}
    self.gen_reg_xml(xml.dom.minidom.parse(fname))


  def print_db(self):
    """
    """
    pprint(self.src2param)

  def gen_reg_xml(self,doc):
    """
    """
    l0=doc.lastChild
    topname=l0.nodeName
    for l1 in l0.childNodes:
      if l1.nodeType == l0.TEXT_NODE: # 3
        if l1.nodeValue.strip() == "":
          continue
        else:
          if self.debug: print "Error 2 : text node is not empty",l1.nodeValue.strip()
      elif l1.nodeType == l0.ELEMENT_NODE: #1
        #print l1.nodeType ,l1.toprettyxml().strip()
        regex_range=''
        default=''
        name=''
        offset=''
        size=''
        typ=''
        usr=''
        incsz=''
        for item in l1.attributes.items():
          k=item[0]
          v=item[1]
          if k == "regex_range": regex_range = v
          if k == "default": default = v
          if k == "name": name = v
          if k == "offset": offset = v
          if k == "size": size = v
          if k == "type": typ = v
          if k == "usr": usr = v
          if k == "incsz": incsz = v
        if name !='':
          self.src2param[name]={}
          if regex_range != '':
            self.src2param[name]['_regex_range']=regex_range
          if default != '':
            self.src2param[name]['_default']=default
          if offset != '':
            self.src2param[name]['_offset']=offset
          if size != '':
            self.src2param[name]['_size']=size
          if typ != '':
            self.src2param[name]['_typ']=typ
          if usr != '':
            self.src2param[name]['_usr']=usr
          if incsz != '':
            self.src2param[name]['_incsz']=incsz
        else:
          if self.debug: print "Error 3 : no name attribute",l1.toprettyxml().strip()
          continue
        for l2 in l1.childNodes:
          if l2.nodeType == l0.TEXT_NODE: # 3
            if l2.nodeValue.strip() == "":
              continue
            else:
              descr=l2.nodeValue.strip()
              if descr !='':
                self.src2param[name]['_descr']=descr
          elif l2.nodeType == l0.ELEMENT_NODE: #1
            name2=''
            loc=''
            typ=''
            for item in l2.attributes.items():
              k=item[0]
              v=item[1]
              if k == "name": name2 = v
              if k == "loc": loc = v
              if k == "type": typ = v
            if name2 !='':
              self.src2param[name][name2]={}
              if loc != '':
                self.src2param[name][name2]['_loc']=loc
              if typ != '':
                self.src2param[name][name2]['_typ']=typ
            else:
              if self.debug: print "Error 4 : no name attribute",l2.toprettyxml().strip()
              continue
            for l3 in l2.childNodes:
              if l3.nodeType == l0.TEXT_NODE: # 3
                if l3.nodeValue.strip() == "":
                  continue
                else:
                  descr=l3.nodeValue.strip()
                  if descr !='':
                    self.src2param[name][name2]['_descr']=descr
              elif l3.nodeType == l0.ELEMENT_NODE: #1
                  if self.debug: print "Error 5 : extra branch in the tree",l3.nodeValue.strip()
    return self.src2param
  def __eq__(self,other):
    return self.src2param == other.src2param


if __name__ == '__main__':
  """
  """
  import sys
  argc=len(sys.argv)
  if argc > 1: newxml = sys.argv[1]
  if argc > 2: oldxml = sys.argv[2]
  newobj=reg_xml(newxml)
  oldobj=reg_xml(oldxml)
  if newobj==oldobj :
    print "%s and %s are the same"%(newxml,oldxml)
  else:
    print "ERROR: %s and %s are different"%(newxml,oldxml)
