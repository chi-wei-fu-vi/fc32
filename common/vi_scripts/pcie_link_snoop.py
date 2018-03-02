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
	sys.stdout.write('Waiting for ')
	sys.stdout.write(ip)
	sys.stdout.write(' to online .')
	sys.stdout.flush()
	i = 0
	while (True):
		cmd = '/bin/ping -c ' + str(count) + ' ' + ip
		(cmd_output, exitstatus) = pexpect.run(cmd, withexitstatus=1)
		sys.stdout.write('.')
		sys.stdout.flush()
		if 0 == exitstatus:
			break;
		time.sleep(5.0)
		i = i + 1;
		if (i >= 60):
			sys.stdout.write('\n')
			print 'Reboot timeout - please check probe' + ip
			sys.exit(1)
	return

# main Main MAIN
if __name__ == '__main__':
	from parse import *
	# parse arguments
	parser = argparse.ArgumentParser()
	parser.add_argument("-ip", "--ip_addr", help="IP Address of target probe")
	args = parser.parse_args()

	# verify probe is responsive
	doTheWritePing(args.ip_addr, 1, 0)

	while (True):
		# print PCI information
		cmd0 = "ssh root@{0} 'lspci -vv -d 1bb9: -s 01:00.0 |grep LnkSta:'".format(args.ip_addr)
		cmd0_output = pexpect.run(cmd0, events={'(?i)continue connecting (yes/no)?':'yes\n', '(?i)ssword:':'fpgaroot\n'})
		speed0 = search('Speed 8GT/s', cmd0_output)
		width0 = search('Width x8', cmd0_output)
		cmd1 = "ssh root@{0} 'lspci -vv -d 1bb9: -s 02:00.0 |grep LnkSta:'".format(args.ip_addr)
		cmd1_output = pexpect.run(cmd1, events={'(?i)continue connecting (yes/no)?':'yes\n', '(?i)ssword:':'fpgaroot\n'})
		speed1 = search('Speed 8GT/s', cmd1_output)
		width1 = search('Width x8', cmd1_output)
		print "==========================="
		if ((speed0 != None) and (width0 != None) and (speed1 != None) and (width1 != None)):
			print "passed "
			print "==========================="
		else:
			print "ERROR!!!!"
			print "==========================="
			f = open ('./err_log', 'w')
                	cmd0 = "ssh root@{0} 'lspci -vv -d 1bb9: -s 01:00.0 '".format(args.ip_addr)
                	cmd0_output = pexpect.run(cmd0, events={'(?i)continue connecting (yes/no)?':'yes\n', '(?i)ssword:':'fpgaroot\n'})
                	cmd1 = "ssh root@{0} 'lspci -vv -d 1bb9: -s 02:00.0 '".format(args.ip_addr)
                	cmd1_output = pexpect.run(cmd1, events={'(?i)continue connecting (yes/no)?':'yes\n', '(?i)ssword:':'fpgaroot\n'})
			f.write(cmd0_output)
			f.write(cmd1_output)
			f.close()
			sys.exit(1)
		time.sleep(2.0)

	sys.exit(0)
