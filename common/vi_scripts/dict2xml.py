#!/usr/bin/env python2.7
import xml.etree.ElementTree as ET
from xml.dom import minidom

class dict2xml(object):
  def __init__(self):
    """
    """
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
        assert d == 'invalid type', (type(d), d)
    assert isinstance(d, dict) and len(d) == 1
    tag, body = next(iter(d.items()))
    node = ET.Element(tag)
    to_node(body, node)
    return node
  def readdict(self,fname):
    """
    """
    with open(fname,'r') as fh:
      input_dict=eval(fh.read())
    return input_dict
  def writexml(self,fname,root):
    """
    """
    with open(fname,'w') as fh:
      doc=minidom.parseString(ET.tostring(root))
      fh.write(doc.toprettyxml())
      

if __name__=='__main__':
  import sys
  argc=len(sys.argv)
  if argc > 1: jsonf=sys.argv[1]
  if argc > 2: xmlf=sys.argv[2]
  if argc > 1:
    obj=dict2xml()
    root=obj.dict2root(obj.readdict(jsonf))
    obj.writexml(xmlf,root)
    
  else:
    input_dict={
 'root': {'e': [None,
                'text',
                {'@name': 'value'},
                {'#text': 'text', '@name': 'value'},
                {'a': 'text', 'b': 'text'},
                {'a': ['text', 'text']},
                {'#text': 'text', 'a': 'text'}]}}
    obj=dict2xml()
    root=obj.dict2root(input_dict)
    print root
    print dir(root)
    print dir(ET)
    print ET.dump(root)
    
    print(ET.tostring(obj.dict2root(input_dict)))
    print(ET.tostring(root))
    print dir(minidom)
    doc=minidom.parseString(ET.tostring(root))
    print doc.toprettyxml()
