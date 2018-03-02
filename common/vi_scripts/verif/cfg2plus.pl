#!/usr/bin/perl
use File::Basename;


################################################################################
# Copyright (C) 1998-2014 Hirak Mitra
#
# I hereby grant permission to copy and/or modify this file freely.
# However, if you do so you must preserve the copyright message and
# this text which tells you you may not delete the copyright message!
# 
# !!!NOTICE!!! THIS SOFTWARE COMES WITHOUT ANY WARRANTIES AT ALL, NOT EVEN THE
# IMPLIED WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE.
################################################################################


#-------------------------------------------------------------------------------
# This next section contains the beginning code and its helper functions.
#-------------------------------------------------------------------------------
#---------------
# Loading packages
#---------------
use Env;
use Cwd;


#---------------
# Setting up signal handling
#---------------
$SIG{INT}  = \&die_gracefully;
$SIG{ABRT} = \&die_gracefully;

$start_dir		= &cwd();
$verbose		= 1;

@prog			= split /\//, $0;
$prog			= pop(@prog);
$prog_dir		= join "/", @prog;
$cmd_line		= "$0 @ARGV";
$start_dir		= &cwd();
$mypath     = "";


#---------------
# Setting up specific variables and data structures
#---------------
$in = "";
$out			= "";
*OUT			= *STDOUT;


#---------------
# Helper functions
#---------------
sub get_time
{
    ($ss,$mm,$hr,$day,$mon,$yr) = localtime(time);
    $mon++;
    $yr += 1900;
    $time_str = sprintf("%02d:%02d:%02d", $hr, $mm, $ss);
    return($time_str);
}						# get_time


sub get_date
{
    my ($ss,$mm,$hr,$day,$mon,$yr) = localtime(time);
    $mon++;
    $yr += 1900;
    $time_str = sprintf("%04d_%02d_%02d", $yr, $mon, $day);
    return($time_str);
}						# get_date


sub get_full_date
{
    my ($ss,$mm,$hr,$day,$mon,$yr) = localtime(time);
    $mon++;
    $yr += 1900;
    $time_str = sprintf("%04d_%02d_%02d:%02d:%02d:%02d", $yr, $mon, $day,  $hr, $mm, $ss);
    return($time_str);
}						# get_full_date


$die_gracefully_fn	= \&die_gracefully_fn;	# hook to real functionality

sub die_gracefully_fn
{
    print "$prog: Quitting\n";
    exit 1;
}						# die_gracefully_fn

sub die_gracefully
{
    &{ $die_gracefully_fn }(@_);
}						# die_gracefully


sub assert
{
    my ($string, $cond, $kill) = @_;

    if($cond)
    {
	my ($package, $filename, $line, $subroutine, $hasargs,
	    $wantarray, $evaltext, $is_require, $hints, $bitmask) = caller(0);

	my $cwd = &cwd();
	my @cwd = split /\//, $cwd;
	$cwd = pop(@cwd);
	$time = &get_time();
        my $msg_str = "${prog}:$filename:$line in ${cwd} @ $time: ASSERT: $string\n";
	print $msg_str;

	&die_gracefully() if($kill == 1);
    }

    return($cond);
}						# msg_fn


$msg_fn			= \&msg_fn;		# changeable hook to print function
$suppress_msg		= 0;			# if 1, then don't print message
$logging		= 0;			# if 1, then write to log
sub msg_fn
{
    my ($string, $level) = @_;
    if($level <= $verbose)
    {
	my $this = (caller(2 + $msg_depth))[3];
	my @this = split /:/, $this;
	$this = pop(@this);

	my $cwd = &cwd();
	my @cwd = split /\//, $cwd;
	$cwd = pop(@cwd);
	$time = &get_time();
        my $msg_str = "${prog}:$this in ${cwd} @ $time: $string\n";
	print $msg_str		if($suppress_msg == 0);
	print LOG $msg_str	if($logging == 1);
    }
}						# msg_fn


sub msg
{
    &{ $msg_fn }(@_);
}						# msg


#-------------------------------------------------------------------------------
# This next section contains the main entry code.
#-------------------------------------------------------------------------------
&main();


sub main
{
    &parse_args();
    &post_init_vars();
    &driver();
    exit 0;
}						# main


sub parse_args
{
    %arg_hash =
    (
	"-?"		=> \&help_exit,
	"-h"		=> \&help_exit,
	"-help"		=> \&help_exit,
        "-o"		=> sub { $out = shift(@ARGV); },
	"-v"		=> sub { $verbose = shift(@ARGV); },
    );

    for(;;)
    {
	$argv = shift(@ARGV);
	last if($argv eq "");

	if(exists $arg_hash{$argv})
	{
	    &{ $arg_hash{$argv} }();
	}
	elsif($argv =~ /^-/)
	{
	    &help_exit("Unknown switch $argv");
	}
	else
	{
	    $in = $argv;
	}
    }
   ($myname, $mypath, $mysuffix) = fileparse($out);
}						# parse_args


sub post_init_vars
{
    if($out eq "")
    {
	$out = "$in";
	$out =~ s/\./.plus./;
    }
	$cfg_db = $mypath . "uvm_cfg_db.svh";
}						# post_init_vars


sub help_exit
{
    my ($string) = @_;

    &msg($string) if($string ne "");

    print "Program cfg2plus.pl\n";
    print "This program does the following: \n";
    print "Call: $prog options ... input_file\n";
    print "Options:\n";
    print "  -h[elp]                print help message and exit\n";
    print "  -o FILE                write output to this file\n";
    print "  -v LEVEL               set verbosity to LEVEL (default $verbose)\n";

    exit 2;
}						# help_exit


#-------------------------------------------------------------------------------
# This next section contains the main execution code for the program.
#-------------------------------------------------------------------------------
sub driver
{
    &open_out();
    &open_uvm_cfg_db();
    &parse_in();
    &post_parse_in();
    &close_out();
    &close_uvm_cfg_db();
}						# driver


sub open_out
{
    return if($out eq "");
    &assert("Could not write $out", (open(OUT, ">$out") == 0), 1);
    &assert("I am writing $out", (open(OUT, ">$out") == 0), 0);
}						# open_out


sub close_out
{
    return if(1 eq "");
    close OUT;
}						# close_out

sub open_uvm_cfg_db
{
    return if($cfg_db eq "");
    &assert("Could not write $cfg_db", (open(UVM_CFG_DB, ">$cfg_db") == 0), 1);
    &assert("I am writing $cfg_db", (open(UVM_CFG_DB, ">$cfg_db") == 0), 0);
}						# open_cfg_db


sub close_uvm_cfg_db
{
    return if(1 eq "");
    close UVM_CFG_DB;
}						# close_uvm_cfg_db


sub parse_in
{
    &assert("You did not specify in", ($in eq ""), 1);
    &assert("I cannot see $in", (! (-e $in)), 1);
    # print "READING: $in\n";
    # FOO
    map { &parse_in_line($_); } split(/[\r\n]/, `cat $in`);
	 print OUT "print_once_only = 1'b1;\n";
}						# end parse_in


sub parse_in_line
{
    my ($line) = @_;
    my $new_line = $line;
    $new_line =~ s/\/\/.*//;
    $new_line =~ s/\s+$//;
    return if($new_line =~ /^$/);
#    print STDERR "$new_line\n";
    $new_line =~ s/([=;])/ $1 /g;
    my (@line) = grep(/^.+$/, split(/\s+/, $new_line));

#    print STDERR "LINE[0]=|$line[0]|  LINE[1]=|$line[1]|  LINE[2]=|$line[2]|\n";
    if((($line[0] eq "int") ||
	($line[0] eq "longint")) &&
       ($line[1] =~ /[A-Z_][A-Z0-9_]+/) &&
       ($line[2] eq "="))
    {
#	print STDERR "Doing: $line[1]\n";
   print OUT "if(\$value\$plusargs(\"$line[1]=%d\", $line[1])) begin\n";
   print OUT "  \if(print_once_only == 1'b0) \$display(\"\%m Setting $line[1]=\%d\", $line[1]);\n";
	print OUT "end\n";
	print OUT "\n";
   print UVM_CFG_DB "uvm_config_db #(int)::set(null, \"*\", \"ENV_CFG_$line[1]\", $line[1]);\n";
    }
}						# end parse_in_line

# This function is a hack to help populate CH0_NUM_PKTS and CH1_NUM_PKTS which are legacy plusargs
sub post_parse_in
{
         print OUT "// HACK: Extended support for CH0_NUM_PKTS and CH1_NUM_PKTS\n";
         print OUT "// These two statements are inteded to overwrite the CH0_NUM_PKTS and CH1_NUM_PKTS plusargs with the newer NUM_X_MSG plusargs\n";
         print OUT "// PGEN-ENABLED MODE ONLY!\n";
         print OUT "if(\$test\$plusargs(\"PGEN\")) begin // new non-uvm pgen\n";
         print OUT "    CH0_NUM_PKTS = NUM_NFS_MSG + NUM_RPC_MSG;\n";
         print OUT "    CH1_NUM_PKTS = NUM_NFS_MSG + NUM_RPC_MSG;\n";
         print OUT "    MINNUM_FLOWS = NUM_NFS_FLOWS + NUM_RPC_FLOWS + NUM_MISC_FLOWS + TCP_REUSE_FLOWS*(TCP_REUSE_TIMES-1);\n";
         print OUT "end\n";
         print OUT "if(\$test\$plusargs(\"VERIF2\")) begin // verif2 \n";
         print OUT "    CH0_NUM_PKTS = NUM_NFS_MSG + NUM_RPC_MSG;\n";
         print OUT "    CH1_NUM_PKTS = NUM_NFS_MSG;\n";
         print OUT "    \$display(\"CFG_INFO:: CH0_NUM_PKTS %0d CH1_NUM_PKTS %0d NUM_NFS_MSG %0d NUM_RPC_MSG %0d\", CH0_NUM_PKTS, CH1_NUM_PKTS, NUM_NFS_MSG, NUM_RPC_MSG);\n";
         print OUT "end\n";
}						# end post_parse_in

