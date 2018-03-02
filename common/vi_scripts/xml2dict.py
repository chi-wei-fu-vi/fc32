#!/usr/bin/env python2.7
# encoding: utf-8
import xml.etree.ElementTree as ET
from pprint import pformat
from pprint import pprint
from collections import *
class xml2dict(object):

  def __init__(self, coding='UTF-8'):
    self._coding = coding

  def root2dict(self,t):
    d = {t.tag: {} if t.attrib else None}
    children = list(t)
    if children:
      dd = defaultdict(list)
      for dc in map(self.root2dict, children):
        for k, v in dc.iteritems():
          dd[k].append(v)
      d = {t.tag: {k:v[0] if len(v) == 1 else v for k, v in dd.iteritems()}}
    if t.attrib:
      d[t.tag].update(('@' + k, v) for k, v in t.attrib.iteritems())
    if t.text:
      text = t.text.strip()
      if children or t.attrib:
        if text:
          d[t.tag]['#text'] = text
      else:
        d[t.tag] = text
    return d

  def readxml(self,fname):
    """
    """
    tree = ET.parse(fname)
    root = tree.getroot()
    return root

  def writedict(self,root,fname):
    with open(fname,'w') as fh:
      #pprint(root)
      fh.write(pformat(root))


if __name__ == '__main__':
  
  import sys
  argc=len(sys.argv)
  if argc > 1: xml=sys.argv[1]
  if argc > 2: dct=sys.argv[2]

  obj = xml2dict(coding='utf-8')
  root=obj.readxml(xml)
  root=obj.root2dict(root) 
  obj.writedict(root,dct)
