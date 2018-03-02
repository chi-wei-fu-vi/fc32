#!/usr/bin/perl
use Getopt::Long;

my $regfile=$ARGV[0];
my $regprefix = $ARGV[1];
my $user = $ENV{USER};
my $clean = 0;

GetOptions('c' => sub {$clean=1});

if($clean == 1){
    clean_dir();
    exit 1;
}
open(FF,$regfile) or die("Can't open file");
@array = <FF>;
close FF;


($day,$mon,$dayofmonth,$rest) = split (/\s+/,localtime(time),4);
($hour,$min,$rest) = split (/:/,$rest,3);
my $ddd = $mon.' '.$dayofmonth.' '.$hour.':'.$min;
$regdir = $regfile.'_'.lc($mon).'_'.$dayofmonth.'_'.$hour.'_'.$min;
$dirname = '../'.$regdir;

$runcmd;

$testcnt=0;
$passcnt=0;
$failcnt=0;
$compcnt=0;

my $mkfile = "./Makefile";
$gtarget = 'sim';

	
unless(-e $dirname or mkdir $dirname) 
{die "Unable to create $directory\n";}

chdir "../run";

chk_altlib();

$cmd = 'svn info|grep Revision|cut -f 2 -d " " > Revision';
system($cmd);
open(FF,'Revision') or die("Can't open file");
@rev_num = <FF>;
close FF;
$svn_rev = @rev_num[0];
chomp $svn_rev;

my @report;
my @failcmd;

push(@report, "******** Regression Result : date ( $ddd :svn $svn_rev) ********\n\n");

#open(DLOG,'>regdbg')  or die("Can't open file");


while ($elem = shift(@array)){

    chomp $elem;
    $elem=~ s/#.*//;

    next unless length($elem);

   # print DLOG "run sim with $elem\n";
    run_sim($elem);
}

create_report();
my$regname=$regprefix.' '.$regfile;
if($user eq 'jdon') {
    system("mail -s \"[reg] $regname : regression result\" jaedon.kim\@virtualinstruments\.com < result.txt");
}
if($user eq 'bchuan') {
    system("mail -s \"[reg] $regname : regression result\" boon.chuan\@virtualinstruments\.com < result.txt");
}
system("mail -s \"[reg] $regname : regression result\" janani.nagarajan\@virtualinstruments\.com < result.txt");
system("mail -s \"[reg] $regname : regression result\" tim.beyers\@virtualinstruments\.com < result.txt");

if(@ARGV > 1) {
    chdir "../regress";
    if($failcnt > 0) {
        $sumresult=" result : fail";
    } else {
        $sumresult=" result : pass";
    }
    
    open(FF,'>result.txt') or die("Can't open file");
    print FF $sumresult;
    close(FF);
}
# close DLOG;
 #print "Fail Count = $failcnt";
    if ($failcnt > 0) {
    exit (-1);
    }
  
sub run_sim
{
    
    ($name,$test,$cfg,$def,$mif,$target) = split(/,/,$_[0]);
    my $rand = int(rand(2147483647));
#    print DLOG "$name / $test / $cfg / $def\n";
    $logfile = $test.".log";
    if( $target eq '') {
        $target=$gtarget;
    }
    if( $def eq '') {
	$cmd = "make TEST=$test CFG=$cfg $target SEED=$rand";
    } elsif ($mif eq '') {
	$cmd = "make TEST=$test CFG=$cfg $target SIMDEF=$def SEED=$rand";
    } else {
	$cmd = "make TEST=$test CFG=$cfg $target SIMDEF=$def MYMIF=$mif SEED=$rand";
    } 

    $runcmd = $cmd."\n";
    $cmd .= " | tee tmp_log";
  #  print DLOG "$cmd\n";
    system($cmd);
    
  #  print DLOG "open tmp_log\n";
    $compcnt=0;
    open(FILE,"+<tmp_log");
    while(<FILE>) {
	if( /TEST_SEED/ ) { @seed = $_ =~ /(\d+)/g;
			#    print DLOG "seed = @seed\n";
	}
	if( /PASS/ ) {
	 #   print DLOG "$name : test pass\n";
	    push(@report, "  $name   :    PASS\n");
	    $cmd = "rm -rf $logfile";
	    $passcnt++;
            $compcnt=1;
        
	}
	if( /FAIL/ ) {
	  #  print DLOG "$name : test fail (@seed)\n";
	    push(@report, "  $name   :    FAIL (@seed)\n"); 	
	    $faillog = $name."_".$logfile;
	    $cmd = "mv $logfile ../$regdir/$faillog";
	    $failcnt++;
            $compcnt=1;
            push(@failcmd," $name : \n $runcmd\n");
 
	}
    }
           
    close(FILE);
    if ($compcnt != 1) {
      push(@report, "  $name   :    COMPILE FAIL (@seed)\n");
      $failcnt++;
    }
            
    $testcnt++;
 #  print DLOG "$cmd\n";
    system($cmd);
    
}

sub create_report
{
    if($failcnt > 0 ) {
        push(@report,"\n********* Fail Command *************************\n\n");
        push(@report,@failcmd);
    }
    push(@report,"\n************************************************\n\n");
    push(@report," NUM OF PASS TEST : $passcnt\n");
    push(@report," NUM OF FAIL TEST : $failcnt\n");
    push(@report," TOTAL       TEST : $testcnt\n\n");
    
    update_time();
    my $ddd = $mon.' '.$dayofmonth.' '.$hour.':'.$min;
    push(@report, "******** Regression Complete : date ( $ddd ) ********\n\n");
    push(@report,"************************************************\n");

    chdir "$dirname";
    open(FF,'>result.txt') or die("Can't open file");
    

    foreach (@report){
	print FF $_; 
    }
    close(FF);
}


sub chk_altlib
{
    open(FILE,$mkfile) or die("Can't open file");
    my @buff = <FILE>;
    close(FILE);

    my @lines = grep (/sim_all/,@buff);
    ($sim_all,$dumb) = split(/:/,@lines[0],2);

    if($sim_all eq 'sim_all'){
        $gtarget = get_target();
    }

}

sub get_target
{
    my $cmd = 'ls -d */ > mydd';
    system($cmd);
    open(FILE,'mydd') or die("Can't open file");
    my @buff = <FILE>;
    close(FILE);
    my @lines = grep(/^alt*/,@buff);
    my $numal = scalar(@lines);
    if($numal == 0){
        return "sim_all";
    } else {
        return "sim";
    }
}

sub clean_dir
{
    chdir "../";
    $cmd = 'ls '.$regfile.'_* > tmpdir';
    system($cmd);
    open(FF,'tmpdir') or die("Can't open file");
    @array = <FF>;
    close FF;

    @array2 = ();
    $prv_str='';

    foreach $elem (@array) {
        if($elem =~ /^$|result/) {
        } elsif($elem =~/^$regfile/) {
#        print 'assa:'.$elem;
            if($prv_str ne ''){
                push(@array2,$prv_str);
            }
            $prv_str = $elem;
        } else {
            $prv_str='';
        }
    }

    if($prv_str =~/^$regfile/) {
        push(@array2,$prv_str);
    }

    foreach $elem (@array2) {
        $elem =~s/://;
#    print 'assa:'.$elem;
        $cmd = 'rm -rf '.$elem;
        system($cmd);
    }

    system("rm tmpdir");

}

sub update_time
{
    ($day,$mon,$dayofmonth,$rest) = split (/\s+/,localtime(time),4);
    ($hour,$min,$rest) = split (/:/,$rest,3);
}
