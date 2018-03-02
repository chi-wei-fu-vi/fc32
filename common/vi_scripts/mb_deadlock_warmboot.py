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


# main Main MAIN
if __name__ == '__main__':
	from parse import *
	# parse arguments
	parser = argparse.ArgumentParser()
	parser.add_argument("-ip", "--ip_addr", help="IP Address of target probe")
	parser.add_argument("-c", "--cycle", help="Number of cycles to attach detach")
	parser.add_argument("-s", "--start", help="Start on cycle N, in case launch server crashed")
	args = parser.parse_args()

	if (args.start):
		start = int(args.start, base=10)
	else:
		localtime = time.asctime( time.localtime(time.time()) )
		print "Script started at time {0}".format(localtime)
		start = 0

	# verify probe is responsive
	doTheWritePing(args.ip_addr, 1, 1)
	for i in range(start, int(args.cycle, base=10)):
		j = i + 1;
		print "rebooting...."
		cmd = "ssh root@{0} 'reboot'".format(args.ip_addr)
		cmd_output = pexpect.run(cmd, events={'(?i)continue connecting (yes/no)?':'yes\n', '(?i)ssword:':'fpgaroot\n'})
		time.sleep(5.0)

		# verify probe is responsive
		doTheWritePing(args.ip_addr, 1, 0)
		print "passed on loop ", j, " of ", int(args.cycle, base=10)
		print "==========================="

	print "################################################################################################"
	localtime = time.asctime( time.localtime(time.time()) )
	print "Script ended at time {0}".format(localtime)
	sys.exit(0)
