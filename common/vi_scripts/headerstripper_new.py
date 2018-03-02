#!/usr/bin/env python2.7
# By Ryan Fu 2015
# Makes two lists containing tuples, each tuple containing frame time and list of corresponding payload.
# One list for packets coming from source, One list for packets coming from other devices.
# Known to run for tshark versions 1.10.3 and 1.12.6, if different version and script isn't behaving check outputs
# for tshark
import subprocess
import sys
import re

# lists
filterlist=[]
sourcelist=[] 
otherlist=[]



def process(myfile):
    lines=subprocess.check_output("tshark -x -r {0} ".format(myfile),shell=True)
    eths = subprocess.check_output("tshark -r {0} -T fields -e eth.addr -e rpc.msgtyp".format(myfile),shell=True)
    times=subprocess.check_output("tshark -r {0} -T fields -e eth.addr -e frame.time".format(myfile),shell=True)

    ethsource='' # source of ethernet address
    # finds mac address of rpc reply
    for eth in eths.splitlines():
        tempList=eth.split()
        if len(tempList)==2 and tempList[1]=='1':
            ethsource=tempList[0]
            break
    # each time contains eth address followed by frame time
    listtimes=[time for time in times.splitlines()]

    tmpstr=''
    count=0
    # formats payload and stores each packet into a list
    for line in lines.splitlines():
      if line == '': # looks for empty line, because tshark splits packets by empty line
        tmpstr=tmpstr.replace(' ','')
        tmplist=[int(tmpstr[x:x+2],16)for x in range (0,len(tmpstr),2)]
        filterlist.append((listtimes[count],tmplist))
        tmpstr=''
        tmplist=[]
        count+=1
      else:
        tmpstr+=line[6:53]
    # splits list up into two list, this time with mac address stripped from the first list value
    decimalindex=0
    for x in filterlist:
        string= ' '.join(x[0].split()[1:])
        m = re.search('(?<=\.)\w+', string)
        if x[0].split()[0]==ethsource: # checks if packet is from source or other
            sourcelist.append(('.'+m.group(0),x[1]))
        else:
            otherlist.append(('.'+m.group(0),x[1]))  
    return sourcelist, otherlist


def main():
    myfile=sys.argv[1]
    sourcelist, otherlist=process (myfile)

    #print 'sourcelist'
    #print sourcelist
    #print 'otherlist'
    #print otherlist

if __name__=='__main__':
  main()
    

    


