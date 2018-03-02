#!/usr/bin/env python2

import os
import sys
import pexpect
import re
import curses
import signal
import time
import argparse
import select

g_link = 0
g_link_ctrl = ''
g_link_max = 0
g_link_min = 0
g_const_links_per_screen = 8
g_const_ascii_esc = 0x1b
g_const_title = 'Link Engine Test '

def cleanup(exitcode):
    curses.echo()
    curses.curs_set(1)
    stdscr.keypad(0)
    stdscr.nodelay(0)
    curses.endwin()
    if (True == child.isalive()):
        child.send('q\n')
        start = time.clock()
        while True:
            if (False == child.isalive()):
                break
            line0 = child.readline()
            #print line0
            now = time.clock()
            delta = now - start
            if (delta > 1.5):
                break
        if (True == child.isalive()):
            print "terminating child"
            child.terminate()
    if (True == child1.isalive()):
        child1.terminate()
    sys.exit(exitcode)

def sighdlr_int(signal, frame):
    cleanup(0)

def handle_user_input(child):
    global g_link, g_link_max, g_link_min, g_const_links_per_screen, g_link_ctrl

    c = stdscr.getch()
    if (c == ord('q')):
        print "\r\nterminated by user"
        cleanup(0)
    elif (c == curses.KEY_RIGHT) and (g_link < (g_link_max - g_const_links_per_screen + 1)):
        g_link = g_link + 1
    elif (c == curses.KEY_LEFT) and (g_link > g_link_min):
        g_link = g_link - 1
    elif (c == ord('r')):
        child.send('r\n')
    elif (c == ord('c')):
        stdscr.addstr(0, 0, g_const_title + ' LinkCtrl=' + g_link_ctrl)
        stdscr.refresh()
        value = "{0:04x}".format(int(g_link_ctrl, 16))
        start_col = len(g_const_title + ' LinkCtrl=') + 2
        curses.curs_set(1)
        stdscr.move(0, start_col)
        col = start_col
        while 1:
            c = stdscr.getch()
            if c == ord('\n'):
                g_link_ctrl = '0x' + value
                child.send('c ' + g_link_ctrl + '\n')
                break
            if c == g_const_ascii_esc:
                break
            if ((c == curses.KEY_LEFT) or (c == curses.KEY_BACKSPACE) or (c == curses.KEY_DC)) and (col > start_col):
                col = col - 1
            elif (c == curses.KEY_RIGHT) or (c == ord(' ')):
                col += 1
            elif ((c >= ord('0')) and (c <= ord('9'))) or ((c >= ord('a')) and (c <= ord('f'))):
                value = value[:(col - start_col)] + "{0:c}".format(c) + value[(col - start_col + 1):]
                col += 1
            stdscr.addstr(0, start_col, value, curses.A_STANDOUT)
            stdscr.move(0, col)
            stdscr.refresh()
        stdscr.addstr(0, 0, g_const_title)
        stdscr.clrtoeol()
        curses.curs_set(0)

# main Main MAIN
if __name__ == '__main__':

    # parse arguments
    parser = argparse.ArgumentParser()
    parser.add_argument("links", nargs='?', default='0..3', help="link_range 0..3")
    parser.add_argument("-c",    default='0x213', help="Initial LinkCtrl 0x<value>")
    parser.add_argument("-d",    type=int, help="debug level [1-5]")
    parser.add_argument("-seq",  action='store_true', help="sequence num checking enabled")
    args = parser.parse_args()
    #print "links:", args.links
    #print "debug:", args.d
    #print "ctrl:",  args.c
    #print "seq:",   args.seq

    g_link_ctrl = args.c

    link_range = re.compile(r"(\d+)\.\.(\d+)")
    rc = link_range.search(args.links)
    if rc == None:
        print "unknown link range", args.links
        sys.exit(-1)

    g_link_max = int(rc.group(2))
    g_link_min = int(rc.group(1))
    g_link = g_link_min
    #print "g_link_max:", g_link_max
    #print "g_link_min:", g_link_min
    #print "g_link:", g_link

    bin_dir = '/usr/local/vi/bin/'
    #bin_dir = './'
    link_test_cmd = bin_dir + 'link_test %s -c %s' % (args.links, args.c)
    if args.d != None:
        link_test_cmd += " -d %d" % (args.d)
    if args.seq == True:
        link_test_cmd += " -seq" 
    #print "cmd:", link_test_cmd

    # Setup ncurses
    stdscr = curses.initscr()
    g_row_max = stdscr.getmaxyx()[0]
    curses.noecho()
    curses.curs_set(0)
    stdscr.keypad(1)
    stdscr.nodelay(1)

    # Setup Ctrl+c signal handler
    signal.signal(signal.SIGINT, sighdlr_int)

    import datetime
    fd=open("link_test%s"%(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")), "w")
    try:
        child  = pexpect.spawn(link_test_cmd, logfile=None)
        if os.path.exists('./speed_change.py'):
          child1 = pexpect.spawn("./speed_change.py", logfile=None)
        else:   
          child1 = pexpect.spawn("/usr/local/vi/bin/vi_scripts/speed_change.py", logfile=None)
    except:
        fd.write("Error1: Could not spawn new threads\n")
        fd.close()
        cleanup(-1)
    child.setecho(False)
    le1 = re.compile(r"le1\s+(\d+)\s+(\S+):(\S+)\s+(\S+):(\S+)\s+(\S+):(\S+)\s+(\S+):(\S+)\s+(\S+):(\S+)\s+(\S+):(\S+)\s+(\S+):(\S+)")
    le0 = re.compile(r"le0\s+(\d+)\s+(\d)\s+(\S+):(\S+)\s+(\S+):(\S+)\s+(\S+):(\S+)\s+(\S+):(\S+)\s+(\S+):(\S+)\s+(\S+):(\S+)\s+(\S+):(\S+)\s+(\S+):(\S+)\s+(\S+):(\S+)\s+(\S+):(\S+)\s+(\S+):(\S+)")
    stdscr.addstr(0, 0, g_const_title)
    stdscr.clrtoeol()
    fpga_intervals=[0,0,0,0,0,0,0,0]
    while(1):
        handle_user_input(child)
        line0 = child.readline()
        if line0 == "":
            print "link_test terminated"
            cleanup(1)
        line = line0.rstrip()
        rc1 = le1.search(line)
        if rc1 != None:
            link = int(rc1.group(1))
            #fd.write("link %d\n"%(link))
            if (link % 12) == 0:
              fpgaid=link / 12
              interval=int(rc1.group(11))
              fd.write("%d %d %d\n"%(fpgaid,interval,fpga_intervals[fpgaid]))
              if interval==fpga_intervals[fpgaid]:
                fd.write("LOCKUP : link_test terminated\n")
                print "LOCKUP : link_test terminated"
                cleanup(2)
              fpga_intervals[fpgaid]=interval
              if False:
                row=2
                for g in range(2,15,2):
                  fd.write("%d %d %s\n"%(row,g,rc1.group(g)))
                  fd.write("%d %d %s\n"%(row,g+1,rc1.group(g+1)))
                  row=row+1
            
            if (link >= (g_link + g_const_links_per_screen)):
                continue;
            if (link < g_link):
                continue;
            row = 2
            col = 10 * (link - g_link) + 16
            for g in range(2, 15, 2):
                try:
                    if (16 == col):
                        stdscr.addstr(row, 0, "%-15s" % rc1.group(g))
                        #fd.write("%d %d %s\n"%(row,0,rc1.group(g)))
                           
                    stdscr.addstr(row, col, "%s  " % rc1.group(g + 1))
                    #fd.write("%d %d %s\n"%(row,col,rc1.group(g+1)))
                except:
                    pass
                stdscr.clrtoeol()
                row = row + 1
        else:
            rc0 = le0.search(line)
            if rc0 != None:
                link = int(rc0.group(1))
                channel = int(rc0.group(2))
                if (link >= (g_link + g_const_links_per_screen)):
                    continue;
                if (link < g_link):
                    continue;
                #stdscr.addstr(1, 0, "%-8d" % int(time.time() - startTime))
                stdscr.addstr(1, 0, "        ")
                row = 10
                col = 10 * (link - g_link) + 16
                try:
                    stdscr.addstr(1, col, "link[%d]" % link)
                except:
                    pass
                stdscr.clrtoeol()
                # link_test produces one line per channel (two lines per link)
                for g in range(3, 25, 2):
                    y = row + channel - 1
                    try:
                        if (16 == col):
                            stdscr.addstr(y, 0, "%d:%-15s" % (channel, rc0.group(g)))
                            #fd.write("%d %d %s\n"%(row,0,rc0.group(g)))
                        stdscr.addstr(y, col, "%-8s  " % rc0.group(g + 1))
                        #fd.write("%d %d %s\n"%(y,col,rc0.group(g+1)))
                    except:
                        pass
                    stdscr.clrtoeol()
                    row = row + 2
        stdscr.refresh()

cleanup(0)
