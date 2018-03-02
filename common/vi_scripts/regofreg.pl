#!/usr/bin/perl
use Cwd;

my $num_reg = 8;
#$mysvndir="/home/jdon/regress/trunk";
$mysvndir = cwd();
$regd1="./dominica_dal/prototype/link_engine/verif/regress";
$regd2="./bali_dal/prototype/pcie/verif/regress";
$regd3="./bali_dal/prototype/eth_pcs/verif/regress/";
$regd4="./dominica_dal/design/top/verif/regress/";
$regd5="./dominica_dal/design/txbist32b/verif/run";
$regd6="./dominica_dal/design/xbar/verif/run";
#start offset
my $cur_reg = 0;
update_time();
my $rp_file_name = ">report_".lc($mon).'_'.$dayofmonth;
open(FF,$rp_file_name) or die("Can't open file");
print FF "********** regression status ************\n";
print FF " reg name   : svn rev : start       : end\n";

while ($cur_reg < $num_reg) {
    
    system("svn update");
    update_time();
    my $ddd = $mon.' '.$dayofmonth.' '.$hour.':'.$min;

    $cmd = 'svn info|grep Revision|cut -f 2 -d " " > Revision';
    system($cmd);

    open(FILE,'Revision') or die("Can't open file");
    @rev_num = <FILE>;
    close (FILE);
    $svn_rev = @rev_num[0];
    chomp $svn_rev;    

    if($cur_reg == 0) {
        $reg_name = "link_engine";
        $rdir=$regd1;
        $runcmd = './regress.pl rnd_reg';
    } elsif($cur_reg == 1) {
        $reg_name = "pcie_daily ";
        $rdir=$regd2;
        $runcmd = './regress.pl daily';
    } elsif($cur_reg == 2) {
        $reg_name = "pcie_random";
        $rdir=$regd2;
        $runcmd = './regress.pl rnd_reg';
    } elsif($cur_reg == 3) {
        $reg_name = "top_nightly";
        $rdir=$regd4;
        $runcmd = './regress.pl nightly';
    } elsif($cur_reg == 4) {
        $reg_name = "top_daily  ";
        $rdir=$regd4;
        $runcmd = './regress.pl daily';
    } elsif($cur_reg == 5) {
        $reg_name = "top_mini  ";
        $rdir=$regd4;
        $runcmd = './regress.pl mini';
    } elsif($cur_reg == 6) {
        $reg_name = "top_random  ";
        $rdir=$regd4;
        $runcmd = './regress.pl random';
    } elsif($cur_reg == 7) {
        $reg_name = "dom_txbist ";
        $rdir=$regd5;
        $runcmd = './regress.pl daily';
    } elsif($cur_reg == 8) {
        $reg_name = "dom_xbar ";
        $rdir=$regd6;
        $runcmd = './regress.pl nightly';
    } else {
        $reg_name = "pcs        ";
        $rdir=$regd3;
        $runcmd = './regress.pl daily';
    }
    chdir $rdir;
#    print "dbg1\n";
#    system("pushd $rdir");
    print FF "$reg_name : $svn_rev    : $ddd";
    system($runcmd.' '.$reg_name);
#    print "dbg2\n";

    $cmd = 'grep result result.txt|cut -f 2 -d ":" > regresult';
    system($cmd);
    open(FILE,'regresult') or die("Can't open file");
    @tmpres=<FILE>;
    close (FILE);
    $result = @tmpres[0];


    update_time();
    my $ddd = $mon.' '.$dayofmonth.' '.$hour.':'.$min;
    print FF " : $ddd : $result\n";
    
    $cur_reg++;
#    system("popd");
    chdir $mysvndir;
}

print FF "*****************************************\n";
close (FF);

sub update_time
{
    ($day,$mon,$dayofmonth,$rest) = split (/\s+/,localtime(time),4);
    ($hour,$min,$rest) = split (/:/,$rest,3);
}
