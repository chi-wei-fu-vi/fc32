#!/usr/bin/perl
use Getopt::Long;
use Cwd;

my $user  = $ENV{USER};
my $clean = 0;

my %options = ();
&GetOptions(\%options, "rf=s", "l=i", "c", "cp", "fl=i", "h", "H", "help");

$this_dir = cwd();

$rundir = "";

if ((defined $options{h}) || (defined $options{H}) || (defined $options{help}))  {
	print ("===========================================\n");
	print ("Usage: regress  \n");
	print ("       -rf          : regression file. List of tests and run parameters (example: nightly or mini) \n");
	print ("       -c           : clean before sim\n");
	print ("       -cp          : clean pass. After sim if test passed removes directory.\n");
	print ("       -l           : Loop : Number of times to run through all the tests.\n");
	print ("       -fl          : Fail Limit : Number of failures before ending regression. (default 100)\n");
	print ("       -h,H,help    : Display help\n");
	print ("                    : File \"run/regr_progress.txt\" is created which updates regression progress during testing.\n");
	print ("===========================================\n");
}


if (defined $options{rf}) {
   $regfile = $options{rf};
   print("Command line arg test $regfile\n");
   open(FF,$regfile) or die("Can't open file");
   @array = <FF>;
   close FF;
}

if (defined $options{c}) {
	$clean = 1;
	print("Arg c. Doing clean.\n");
}

if (defined $options{cp}) {
	$clean_pass = 1;
	print("Arg cp. Will do clean on passing test.\n");
}

if (defined $options{cf}) {
	$clean_fail = 1;
	print("Arg cp. Will do clean on failing test.\n");
}

$fail_limit = 50;
if (defined $options{fl}) {
	$fail_limit = $options{fl};
	print("Arg fl. Fail limit before ending regression $fail_limit.\n");
}


$loops = 1;
if (defined $options{l}) {
	$loops = $options{l};
	print("Loops  $loops\n");
}

$DOCMD  = "\'set\\ SolveArrayResizeMax\\ 0\\;run\\ -all\\;quit\\;\'"; # No WLF generation
print "SCRIPT_DEBUG:: DOCMD $DOCMD\n";


if($clean == 1){
    clean_dir();
    exit 1;
}


($day,$mon,$dayofmonth,$rest) = split (/\s+/,localtime(time),4);
($hour,$min,$rest) = split (/:/,$rest,3);
my $ddd            = $mon.' '.$dayofmonth.' '.$hour.':'.$min;
$regdir            = $regfile.'_'.lc($mon).'_'.$dayofmonth.'_'.$hour.'_'.$min;
$dirname           = '../'.$regdir;

$runcmd;

$testcnt = 0;
$passcnt = 0;
$failcnt = 0;
$compcnt = 0;

my $mkfile = "./Makefile";
$gtarget   = 'sim';

print "dirname $dirname\n";
print "regdir $regdir\n";
	
unless(-e $dirname or mkdir $dirname) 
{die "Unable to create directory $dirname\n";}

chdir "../run";

chk_altlib();

$cmd      = 'svn info|grep Revision|cut -f 2 -d " " > Revision';
system($cmd);
open(FF,'Revision') or die("Can't open file");
@rev_num  = <FF>;
close FF;
$svn_rev  = @rev_num[0];
chomp $svn_rev;

$this_dir = cwd();
my @report;
my @failcmd;

sub status_check
{
    $stat     = "UNKNOWN, Either BAD RUN or \"TEST_STATUS::\" not found in log file.";
    $name     = $_[0];
    $logfile  = $test.".log";
    $this_dir = cwd();


    $cmd      = "echo ERROR: Log contained neither PASS nor FAIL!";
    $compcnt  = 0;
    open(FILE,"+<tmp_log");
    $valid_status = 0;
    while(<FILE>) {
		if( /TEST_SEED/ ) { 
      	@seed = $_ =~ /(\d+)/g;
		}
      #if( /TEST_STATUS::/ ) {
		if( /TEST_STATUS::/ ) {
         s/#//,$_;
         #($junk,$stat) = split (/:: /,$_);
         ($junk,$stat) = split (/: /,$_);
         chomp $stat;
         $valid_status = 1;
      }
		if( /PASS/ ) {
	    	   push(@report, "  $name   :    PASS\n");
            #$stat = "PASSED";
            #$cmd = "rm -rf $logfile";
	    	   $passcnt++;
            $compcnt=1;
            if($clean_pass == 1){
               $cmd = "rm -rf $rundir";
            }
		}
      elsif( /FAIL/ ) {
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
    system($cmd);
    return ($stat, @seed);
}
if($valid_status eq 0){
   $failcnt++;
}

$this_dir = cwd();
$test_cnt = 0;
$elem_cnt = 0;
$stat     = "BAD RUN";
$pass     = "PASS";
$fail     = "FAIL";
@save_array = @array;
open(PROGRESS,'>regr_progress.txt') or die("Can't open file");
print PROGRESS "Regression results for $regfile\n";
for($i = 0; $i < $loops; $i++) {
    @array = @save_array;
    while ($elem = shift(@array)){
        chomp $elem;
        $elem =~ s/#.*//;
        print PROGRESS "#$test_cnt loop: $i elem: $elem_cnt $elem\n";
        next unless length($elem);
        run_sim($elem);
        $name = split(/,/,$elem);
        my ($stat, @seed) = status_check($name);
        print PROGRESS "#$test_cnt test status $stat seed @seed\n\n";
        $elem_cnt += 1;
        $test_cnt += 1;
        if($failcnt gt $fail_limit){
           last;
        }
    }
    print "Out of loop\n";
    $elem_cnt = 0;
    if($failcnt gt $fail_limit){
       print "Error count ($failcnt) exceeded limit ($fail_limit). Quiting regression\n";
       last;
    }
}
close PROGRESS;

create_report();

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
    if ($failcnt > 0) {
    exit (-1);
    }
  

sub run_sim
{
    
$this_dir = cwd();
print "this_dir in run_sim $this_dir\n";
    ($name,$test,$cfg,$def,$mif,$target,$vsim_args) = split(/,/,$_[0]);
    my $rand = int(rand(2147483647));
    $logfile = $test.".log";
print "logfile in run_sim $logfile\n";
print "name in run_sim $name\n";
print "test in run_sim $test\n";
    $rundir  = "rundir_" . $name . "_$rand";
print "rundir in run_sim $rundir\n";

    print "\nNAME=$name TEST=$test CFG=|$cfg| DEF=$def MIF=$mif TARGET=$target VSIM_ARGS=$vsim_args\n";
	 $cmd = "make sim_all TEST=$test DOCMD=$DOCMD VERBOSITY='UVM_LOW'";
    print "\n\ncmd $cmd\n\n";
    if( $cfg ne '') {
       $cmd .= " CFG=$cfg";
    print "\n\ncmd $cmd\n\n";
    }
    if( $def ne '') {
       $cmd .= " SIMDEF=$def";
    print "\n\ncmd $cmd\n\n";
    }
    if( $mif ne '') {
       $cmd .= " MYMIF=$mif";
    print "\n\ncmd $cmd\n\n";
    }
    if( $target ne '') {
       $cmd .= " TARGET=$target";
    print "\n\ncmd $cmd\n\n";
    }
    if( $vsim_args ne '') {
       $cmd .= " VSIM_ARGS=$vsim_args";
    print "\n\ncmd $cmd\n\n";
    }
    $cmd .= " SEED=$rand";

    $runcmd  = $cmd."\n";
    $cmd    .= " | tee tmp_log";
    system($cmd);
    my ($stat, @seed) = status_check($name);
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
    my @buff         = <FILE>;
    close(FILE);

    my @lines        = grep (/sim_all/,@buff);
    ($sim_all,$dumb) = split(/:/,@lines[0],2);

    if($sim_all eq 'sim_all'){
        $gtarget     = get_target();
    }

}

sub get_target
{
    my $cmd       = 'ls -d */ > mydd';
    system($cmd);
    open(FILE,'mydd') or die("Can't open file");
    my @buff      = <FILE>;
    close(FILE);
    my @lines     = grep(/^alt*/,@buff);
    my $numal     = scalar(@lines);
    if($numal == 0){
        return "sim_all";
    } else {
        return "sim";
    }
}

sub clean_dir
{
    chdir "../";
    $cmd     = 'ls '.$regfile.'_* > tmpdir';
    system($cmd);
    open(FF,'tmpdir') or die("Can't open file");
    @array   = <FF>;
    close FF;

    @array2  = ();
    $prv_str ='';

    foreach $elem (@array) {
        if($elem =~ /^$|result/) {
        } elsif($elem =~/^$regfile/) {
            if($prv_str ne ''){
                push(@array2,$prv_str);
            }
            $prv_str = $elem;
        } else {
            $prv_str = '';
        }
    }

    if($prv_str =~/^$regfile/) {
        push(@array2,$prv_str);
    }

    foreach $elem (@array2) {
        $elem =~s/://;
        $cmd = 'rm -rf '.$elem;
        system($cmd);
    }

    system("rm tmpdir");
}

sub update_time
{
    ($day,$mon,$dayofmonth,$rest) = split (/\s+/,localtime(time),4);
    ($hour,$min,$rest)            = split (/:/,$rest,3);
}
