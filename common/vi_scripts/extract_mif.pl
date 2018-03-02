#!/usr/bin/perl
use Getopt::Long;
use strict;
use warnings;

#This script is used to extract the contents of the passed in MIF file and dump out the contents of the frame in a packet array format, that will be used as expected data in the verification testbench, to be compared with RTL outputs. 

my $regfile=$ARGV[0];
my @array;
my $line_cnt;
my $pkt_cnt=0;

open(FF, $regfile) or die("Can't open file");
open(FFOut , "> pkt_data.v") or die("Can't open file");

while (my $elem = <FF>) {
    if  ($elem =~ m/pkt/) {
	$pkt_cnt = $elem;
        $pkt_cnt =~ s/.*pkt //;
    }
     if  ($elem =~ m/block/) {
	$pkt_cnt = $elem;
        $pkt_cnt =~ s/.*block //;
     }
    if  ($elem =~ m/[0-9]* :/) {
        $elem =~ s/[0-9]* : /72'h/;
        $elem =~ s/;(\s+).*$/;/;
        push (@array, $elem);
    }
 }

print FFOut "initial begin\n";
chomp(@array);
$line_cnt=0;
foreach(@array) {
        print FFOut "pkt[$line_cnt] = $array[$line_cnt++]\n";
}

$line_cnt--;
chomp($pkt_cnt);
print FFOut "ENV_RAM_END = $line_cnt;\n";
print FFOut "ENV_NUM_TXPKTS = $pkt_cnt;\n";
print FFOut "end";

close (FF);
close (FFOut);
