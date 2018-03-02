#!/bin/env python2
from pprint import pprint
class fc_frame_extract:
  def __init__(self,template):
    """
    """
    self.template=template
  def extract(self,pkt):
    """
    """
    self.extrdata=[]
    for i in self.template:
      if i < len(pkt): 
        self.extrdata.append(pkt[i])
      else:  
        self.extrdata.append(0)
if __name__ == '__main__':
  fc_template=[0, 3, 2, 1, 7, 6, 5, 8, 9, 17, 16, 27, 26, 25, 24, 34, 35, 36, 43, 42, 41, 40, 47, 50, 58, 61, 60, 69, 68]
  pfc_template=[7, 6, 11, 10, 9, 8, 17, 19, 18, 21, 20, 23, 22, 25, 24, 27, 26, 29, 28, 31, 30, 33, 32]
  obj=fc_frame_extract(fc_template)
  pkt=[6, 119, 119, 119, 0, 17, 17, 17, 8, 0, 0, 0, 0, 0, 0, 0, 171, 205, 255, 255, 0, 0, 0, 0, 0, 33, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  print len(pkt)
  obj.extract(pkt)
  print map(lambda x: '%02x'%x,obj.extrdata)
