#!/usr/bin/env python
# Reload FPGA and DAL driver on <probe_ip_address>
# Usage: probectl.py [-f <bitfile>] [-d <dal_driver>] <probe_ip_address>

import sys
import time
import argparse
import pexpect
import parse

# doTheWritePing()
# return 0 if <ip> responds to ping within ~60 seconds, exit otherwise
def doTheWritePing(ip, count=1, noTimeout=0):
	i = 0
	sys.stdout.write('Looking for host at ')
	sys.stdout.write(ip)
	while (True):
		cmd = '/bin/ping -c ' + str(count) + ' ' + ip
		(cmd_output, exitstatus) = pexpect.run(cmd, withexitstatus=1)
		sys.stdout.write('.')
		sys.stdout.flush()
		if 0 == exitstatus:
			print "host found"
			break;
		time.sleep(1.0)
		i = i + 1;
		if (i >= 60) and (noTimeout==0):
			sys.stdout.write('\n')
			print 'Reboot timeout - please check probe' + ip
			localtime = time.asctime( time.localtime(time.time()) )
			print "Script timed out at time {0}".format(localtime)
			sys.exit(1)
	print ""
	time.sleep(5.0)
	return

# waitDown()
# return 0 if <ip> responds to ping within ~60 seconds, exit otherwise
def waitDown(ip, count=1, noTimeout=0):
  i = 0
  sys.stdout.write('waiting for host at ')
  sys.stdout.write(ip)
  sys.stdout.write(' to shut down ')
  while (True):
    cmd = '/bin/ping -c ' + str(count) + ' ' + ip
    (cmd_output, exitstatus) = pexpect.run(cmd, withexitstatus=1)
    sys.stdout.write('.')
    sys.stdout.flush()
    if 1 == exitstatus:
      print "host down"
      break;
    time.sleep(1.0)
    i = i + 1;
    if (i >= 300) and (noTimeout==0):
      sys.stdout.write('\n')
      print 'Reboot timeout - please check probe' + ip
      localtime = time.asctime( time.localtime(time.time()) )
      print "Script timed out at time {0}".format(localtime)
      sys.exit(1)
  print ""
  time.sleep(5.0)
  return


root_password = 'V1.admin\n'
# main Main MAIN
if __name__ == '__main__':
	from parse import *
	# parse arguments
	parser = argparse.ArgumentParser()
	parser.add_argument("-ip", "--ip_addr", help="IP Address of target probe")
	parser.add_argument("-c", "--cycle", help="Number of cycles to attach detach")
	parser.add_argument("-st", "--start", help="Start on cycle N, in case launch server crashed")
	parser.add_argument("-s", "--speed", help="Expected speed for the link.  Possible values are [5, 8]")
	args = parser.parse_args()

	if (args.speed):
		speed = int(args.speed, base=10)
	else:
		speed = 5

	if (args.start):
		start = int(args.start, base=10)
	else:
		localtime = time.asctime( time.localtime(time.time()) )
		print "Script started at time {0}".format(localtime)
		start = 0

	# power cycle probe to get to known state
	cmd0 = "ssh root@{0} 'ipmitool chassis power cycle'".format(args.ip_addr)
	cmd0_output = pexpect.run(cmd0, events={'(?i)continue connecting (yes/no)?':'yes\n', '(?i)ssword:':root_password})

	# verify probe is responsive
	waitDown(args.ip_addr, 1, 1)
	for i in range(start, int(args.cycle, base=10)):
		time.sleep(330.0)
		doTheWritePing(args.ip_addr, 2, 1)
		time.sleep(30.0)
		j = i + 1;

		# print PCI information
		cmd0 = "ssh root@{0} 'lspci -vv -d 1bb9: -s 01:00.0 |grep LnkSta'".format(args.ip_addr)
		cmd1 = "ssh root@{0} 'lspci -vv -d 1bb9: -s 02:00.0 |grep LnkSta'".format(args.ip_addr)
		cmd2 = "ssh root@{0} 'lspci -vv -d 1bb9: -s 01:00.0 |grep DevSta'".format(args.ip_addr)
		cmd3 = "ssh root@{0} 'lspci -vv -d 1bb9: -s 02:00.0 |grep DevSta'".format(args.ip_addr)
		cmd4 = "ssh root@{0} 'lspci -vv -d 1bb9: -s 81:00.0 |grep LnkSta'".format(args.ip_addr)
		cmd5 = "ssh root@{0} 'lspci -vv -d 1bb9: -s 82:00.0 |grep LnkSta'".format(args.ip_addr)
		cmd6 = "ssh root@{0} 'lspci -vv -d 1bb9: -s 81:00.0 |grep DevSta'".format(args.ip_addr)
		cmd7 = "ssh root@{0} 'lspci -vv -d 1bb9: -s 82:00.0 |grep DevSta'".format(args.ip_addr)
		cmd0_output = pexpect.run(cmd0, events={'(?i)continue connecting (yes/no)?':'yes\n', '(?i)ssword:':root_password})
		cmd1_output = pexpect.run(cmd1, events={'(?i)continue connecting (yes/no)?':'yes\n', '(?i)ssword:':root_password})
		cmd2_output = pexpect.run(cmd2, events={'(?i)continue connecting (yes/no)?':'yes\n', '(?i)ssword:':root_password})
		cmd3_output = pexpect.run(cmd3, events={'(?i)continue connecting (yes/no)?':'yes\n', '(?i)ssword:':root_password})
		cmd4_output = pexpect.run(cmd4, events={'(?i)continue connecting (yes/no)?':'yes\n', '(?i)ssword:':root_password})
		cmd5_output = pexpect.run(cmd5, events={'(?i)continue connecting (yes/no)?':'yes\n', '(?i)ssword:':root_password})
		cmd6_output = pexpect.run(cmd6, events={'(?i)continue connecting (yes/no)?':'yes\n', '(?i)ssword:':root_password})
		cmd7_output = pexpect.run(cmd7, events={'(?i)continue connecting (yes/no)?':'yes\n', '(?i)ssword:':root_password})
		speed0 = search('Speed {:d}GT/s', cmd0_output)
		width0 = search('Width x{:d}', cmd0_output)
		CorrErr0 = search('CorrErr+', cmd2_output)
		UncorrErr0 = search('UncorrErr+', cmd2_output)
		FatalErr0 = search('FatalErr+', cmd2_output)
		speed1 = search('Speed {:d}GT/s', cmd1_output)
		width1 = search('Width x{:d}', cmd1_output)
		CorrErr1 = search('CorrErr+', cmd3_output)
		UncorrErr1 = search('UncorrErr+', cmd3_output)
		FatalErr1 = search('FatalErr+', cmd3_output)
		speed2 = search('Speed {:d}GT/s', cmd4_output)
		width2 = search('Width x{:d}', cmd4_output)
		CorrErr2 = search('CorrErr+', cmd6_output)
		UncorrErr2 = search('UncorrErr+', cmd6_output)
		FatalErr2 = search('FatalErr+', cmd6_output)
		speed3 = search('Speed {:d}GT/s', cmd5_output)
		width3 = search('Width x{:d}', cmd5_output)
		CorrErr3 = search('CorrErr+', cmd7_output)
		UncorrErr3 = search('UncorrErr+', cmd7_output)
		FatalErr3 = search('FatalErr+', cmd7_output)

		fpga0Good = (speed0 != None) and (CorrErr0 == None) and (UncorrErr0 == None) and (FatalErr0 == None)
		fpga1Good = (speed1 != None) and (CorrErr1 == None) and (UncorrErr1 == None) and (FatalErr1 == None)
		fpga2Good = (speed2 != None) and (CorrErr2 == None) and (UncorrErr2 == None) and (FatalErr2 == None)
		fpga3Good = (speed3 != None) and (CorrErr3 == None) and (UncorrErr3 == None) and (FatalErr3 == None)

		if fpga0Good and fpga1Good and fpga2Good and fpga3Good:
			print "FPGA 0 speed = ", speed0[0], "Gbps, width = ", width0[0], " lanes"
			print cmd2_output[12:]
			print "---------------------------"
			print "FPGA 1 speed = ", speed1[0], "Gbps, width = ", width1[0], " lanes"
			print cmd3_output[12:]
			print "---------------------------"
			print "FPGA 2 speed = ", speed2[0], "Gbps, width = ", width2[0], " lanes"
			print cmd3_output[12:]
			print "---------------------------"
			print "FPGA 3 speed = ", speed3[0], "Gbps, width = ", width3[0], " lanes"
			print cmd3_output[12:]

			if ((speed0[0] == speed) and (width0[0] == 8) and (speed1[0] == speed) and (width1[0] == 8) and (speed2[0] == speed) and (width2[0] == 8) and (speed3[0] == speed) and (width3[0] == 8)):
				print "passed on loop ", j, " of ", int(args.cycle, base=10)
				print "==========================="
			else:
				print "failed on loop ", j, " of ", int(args.cycle, base=10)
				localtime = time.asctime( time.localtime(time.time()) )
				print "ERROR!!! at time {0}".format(localtime)
				print "==========================="
				print cmd0_output[12:]
				print cmd1_output[12:]
				print cmd2_output[12:]
				print cmd3_output[12:]
				print cmd4_output[12:]
				print cmd5_output[12:]
				print cmd6_output[12:]
				print cmd7_output[12:]
				sys.exit(1)
		else:
			print "failed on loop ", j, " of ", int(args.cycle, base=10)
			localtime = time.asctime( time.localtime(time.time()) )
			print "ERROR!!! at time {0}".format(localtime)
			print "==========================="
			print cmd0_output
			print cmd2_output[12:]
			print "---------------------------"
			print cmd1_output
			print cmd3_output[12:]
			print "---------------------------"
			print cmd2_output
			print cmd3_output[12:]
			print "---------------------------"
			print cmd3_output
			print cmd3_output[12:]
			sys.exit(1)
		
		cmd0 = "ssh root@{0} 'ipmitool chassis power cycle'".format(args.ip_addr)
		cmd0_output = pexpect.run(cmd0, events={'(?i)continue connecting (yes/no)?':'yes\n', '(?i)ssword:':root_password})
		waitDown(args.ip_addr, 1, 1)
	print "################################################################################################"
	localtime = time.asctime( time.localtime(time.time()) )
	print "Script ended at time {0}".format(localtime)
	sys.exit(0)
