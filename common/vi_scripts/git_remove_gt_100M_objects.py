#!/usr/bin/env python
import os
from subprocess import *
class git_remove_gt_1M_objects(object):
  def __init__(self):
    """
    """
    self.fss=[]
    self.largefiles=[]
    if not os.path.exists('.git'):
      print "Error: not git repository"
      #exit(1)
  def findlargefiles(self):
    """
    """
    for rev in self.cmd('git rev-list master').split('\n'):
      if rev=='':continue
      for fs in self.cmd('git ls-tree -lr %s'%rev).split('\n'):
        if fs=='':continue
        self.fss.append(fs)
        size=int(fs.split(' ',3)[3].split('\t')[0])
        fname=fs.split(' ',3)[3].split('\t')[1]
        if size > 100*1024*1024: # size larger than 100M
          print fs.split(' ',3)[3]
          self.largefiles.append(fname)
  def findblob(self):
    """
    """
    #for line in self.cmd("git log --pretty=format:'%T %h %s'").split('\n'):
    for line in  self.cmd1(["git","log","--pretty=format:'%T %h %s'"]).split('\n'):
      if line=='':continue
      tree,commit,subject=line[1:-1].split(' ',2)
      for blob in self.cmd('git ls-tree -r %s'%tree).split('\n'):
        if blob=='':continue
        _,fname=blob.split('\t')
        if fname in self.largefiles:
          print commit,subject  
  def gitcleaner(self):
    """
    """
    # remove all  paths passed as arguments from the history of the repo
    print 'git filter-branch --index-filter "git rm -rf --cached --ignore-unmatch %s" HEAD'%(' '.join(self.largefiles))
    os.system('git filter-branch --index-filter "git rm -rf --cached --ignore-unmatch %s" HEAD'%(' '.join(self.largefiles)))
    # remove the temporary history git-filter-branch otherwise leaves behind for a long time
    print 'rm -rf .git/refs/original/ && git reflog expire --all && git gc --aggressive --prune'
    os.system('rm -rf .git/refs/original/ && git reflog expire --all && git gc --aggressive --prune')


  @staticmethod
  def cmd(cmd):
    return str(Popen(cmd.split(),stdout=PIPE).communicate()[0])
    #return Popen(cmd.split(),stdout=PIPE).communicate()[0]
  @staticmethod
  def cmd1(cmd):
    return str(Popen(cmd,stdout=PIPE).communicate()[0])
    #return Popen(cmd.split(),stdout=PIPE).communicate()[0]

if __name__=='__main__':
  import sys
  argc=len(sys.argv)
  if argc > 1: rpt=sys.argv[1]
  obj=git_remove_gt_1M_objects()
  obj.findlargefiles()
  #print '\n'.join(obj.fss)
  #print '\n'.join(obj.largefiles)
  obj.findblob()
  obj.gitcleaner()
