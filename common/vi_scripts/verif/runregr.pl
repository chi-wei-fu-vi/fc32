#!/usr/bin/perl
use Getopt::Long;
use Cwd;

my $user  = $ENV{USER};
my $clean = 0;

my %options = ();
&GetOptions(\%options, "rf=s", "l=i", "c", "cp=i", "fl=i", "h", "H", "db", "help");

$this_dir = cwd();
$verif2   = 0;
$verif2 = $this_dir =~ /verif2/;

$test = "";
$rundir = "";

if ((defined $options{h}) || (defined $options{H}) || (defined $options{help}))  {
	print ("===========================================\n");
	print ("Usage: regress  \n");
	print ("       -rf          : regression file. List of tests and run parameters/plusargs \n");
	print ("       -c           : clean before sim\n");
	print ("       -cp (1,0)    : clean pass. After sim if test passed removes directory. (default = 1 = clean)\n");
	print ("       -l           : Loop : Number of times to run through all the tests.\n");
	print ("       -fl          : Fail Limit : Number of failures before ending regression. (default 5)\n");
	print ("       -db          : Turn on script debug. (default off)\n");
	print ("       -h,H,help    : Display help\n");
	print ("                    : File \"run/regr_progress.txt\" is created which updates regression progress during testing.\n");
	print ("===========================================\n");
}

$debug = 0;
if (defined $options{db}) {
   $debug = 1;
}


if (defined $options{rf}) {
   $regrfile = $options{rf};
   if($debug ) {print("SCRIPT_DBG:: Command line arg test $regrfile Line:", __LINE__, "\n");}
   if(-e $regrfile) {
      open(FF,$regrfile) or die("Can't open file");
   } 
   else {
      print("ERROR:: Can not find $regrfile Line:", __LINE__, "\n");
      exit;
   }

   @array = <FF>;
   close FF;
}

if (defined $options{c}) {
	$clean = 1;
   if($debug) {print("SCRIPT_DBG:: Arg c     ????? . Doing clean. Line:", __LINE__, "\n");}
}

$clean_pass = 1;
if (defined $options{cp}) {
	$clean_pass = $options{cp};
}
if($debug) {print("SCRIPT_DBG:: Arg cp clean_pass = $clean_pass.  Will do clean on passing test if = 1. Line:", __LINE__, "\n");}


$fail_limit = 5;
if (defined $options{fl}) {
	$fail_limit = $options{fl};
   if($debug) {print("SCRIPT_DBG:: Arg fl. Fail limit before ending regression $fail_limit. Line:", __LINE__, "\n");}
}


$loops = 1;
if (defined $options{l}) {
	$loops = $options{l};
   if($debug) {print("SCRIPT_DBG:: Loops  $loops Line:", __LINE__, "\n");}
}

$DOCMD  = "\'set\\ SolveArrayResizeMax\\ 0\\;run\\ -all\\;quit\\;\'"; # No WLF generation


if($clean == 1){
   clean_dir();
}


($day,$mon,$dayofmonth,$rest) = split (/\s+/,localtime(time),4);
($hour,$min,$rest) = split (/:/,$rest,3);
my $ddd            = $mon.' '.$dayofmonth.' '.$hour.':'.$min;
$regrdir           = $regrfile.'_'.lc($mon).'_'.$dayofmonth.'_'.$hour.'_'.$min;
$dirname           = '../'.$regrdir;

$runcmd;

$testcnt = 0;
$passcnt = 0;
$failcnt = 0;
$compcnt = 0;

my $mkfile = "./Makefile";
$gtarget   = 'sim';

	
unless(-e $regrdir or mkdir $regrdir) 
{die "Unable to create directory $regrdir\n";}


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
#my @failcmd;
@failcmd;

sub status_check {
   open(MY_RUNDIR,'my_rundir') or die("Can't open file");
   my @my_rd      = <MY_RUNDIR>;
   $my_rundir  = @my_rd[0];
   chomp $my_rundir;
   close MY_RUNDIR;
   if($debug) {print "SCRIPT_DBG:: status_check  test $test  my_rundir $my_rundir Line:", __LINE__,"\n";}
   $stat     = "UNKNOWN, Either BAD RUN or \"TEST_STATUS::\" not found in log file.";
   $name     = $_[0];
   if(-e "$my_rundir/journal.log") {
      if($debug) {print "SCRIPT_DBG:: status_check  found journal.log Line:", __LINE__,"\n";}
      system("rm $my_rundir/journal.log*");
   }
   $this_dir = cwd();
   if($debug) {print "A SCRIPT_DBG:: status_check this_dir $this_dir Line:", __LINE__,"\n";}
   $cmd = 'ls ' . $my_rundir . ' | grep "\.log" >& my_log';
   system($cmd);
   if($debug) {print "SCRIPT_DBG:: status_check open my_log Line:", __LINE__,"\n";}
   open(MY_LOG,'<my_log') or die("Can't open file my_log");
   my @my_l      = <MY_LOG>;
   $my_lg  = @my_l[0];
   chomp $my_lg;
   $logfile  = "$my_rundir/$my_lg";
   if($debug) {print "SCRIPT_DBG:: status_check my_lg $my_lg Line:", __LINE__,"\n";}
   close MY_LOG;
   $this_dir = cwd();
   if($debug) {print "SCRIPT_DBG:: status_check this_dir $this_dir logfile $logfile Line:", __LINE__,"\n";}

   if($debug) {print "SCRIPT_DBG:: my_rundir $my_rundir logfile  $logfile  Line:",__LINE__,"\n";}

   $cmd      = "echo ERROR: Log contained neither PASS nor FAIL!";
   $compcnt  = 0;
   open(FILE,"+<$logfile") or die("Can't open file $logfile\n");
   $valid_status = 0;
   $stat = "";
   while(<FILE>) {
      if($debug) {print "PARSE logfile A $logfile   $_\n";}
      if($_ =~ /-sv_seed\ (\d+)/) {
         $seed = $1;
         if($debug){ print "PARSE logfile seed $seed \n";}
      }
		if( /TEST_STATUS::/ ) {
         s/#//,$_;
         ($junk,$stat) = split (/:: /,$_);
         if($debug) {print "SCRIPT_DBG:: PARSE logfile C  stat $stat line: ", __LINE__, "\n";}
         chomp $stat;
         $valid_status = 1;
      }
      if($debug) {print "SCRIPT_DBG:: PARSE before PASSED stat $stat line:", __LINE__, "\n";}
		if( $stat =~ /PASSED/ ) {
         if($debug) {print "SCRIPT_DBG:: PARSE PASSED stat $stat clean_pass $clean_pass line:", __LINE__, "\n";}
	    	 push(@report, "  $name   :    PASSED\n");
	    	 $passcnt++;
          $compcnt=1;
          if($clean_pass == 1){
             if($debug) {print "SCRIPT_DBG:: PARSE PASSED clean_pass stat $stat  test $test regrdir $regrdir line:", __LINE__, "\n";}
             $cmd = "rm -rf $regrdir;";
             if($verif2 eq 1){
                $cmd .= "rm -rf $my_rundir;";
                if($debug) {print "SCRIPT_DBG:: cmd $cmd\n"};
                #$cmd .= " rm -rf $rundir;"; 
             }
          }
		 }
       elsif( $stat =~ /FAILED/ ) {
          if($debug) {print "SCRIPT_DBG:: PARSE FAILED test $test logfile $logfile regdir $regdir     E  FAILED \n";}
	    	 push(@report, "  $name   :    FAILED ($seed)\n"); 	
          $cmd = "cp $logfile $regrdir/";
	    	 $failcnt++;
       	 $compcnt=1;
       	 push(@failcmd," $name : \n $runcmd\n");
      }
      if($valid_status eq 1){
         last;
      }
	 }
    close(FILE);
    if ($compcnt != 1) {
      push(@report, "  $name   :    COMPILE FAIL ($seed)\n");
      $failcnt++;
    }
            
    $testcnt++;
    if($debug) {print "SCRIPT_DBG:: FINAL cmd $cmd\n";}
    system($cmd);
    if(-e my_log) {
       system( "rm my_log");
    }
    if(-e my_rundir) {
       system( "rm my_rundir");
    }
    return ($stat, $seed);
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
print PROGRESS "Regression results for $regrfile\n";
for($i = 0; $i < $loops; $i++) {
    @array = @save_array;
    while ($elem = shift(@array)){
        chomp $elem;
        if($debug) {print "SCRIPT_DBG:: elem before $elem Line:", __LINE__, "\n";}
        $elem =~ s/#.*//;
        if($debug) {print "SCRIPT_DBG:: elem after $elem Line:", __LINE__, "\n";}
        print PROGRESS "#$test_cnt loop: $i elem: $elem_cnt $elem\n";
        next unless length($elem);
        run_sim($elem);
        if($debug) {print "SCRIPT_DBG:: finished run_sim  test $test Line:", __LINE__, "\n";}
        my ($stat, $seed) = status_check($test);
        print PROGRESS "#$test_cnt test status $stat seed $seed\n\n";
        $elem_cnt += 1;
        $test_cnt += 1;
        if($failcnt gt $fail_limit){
           last;
        }
    }
    if($debug) {print "SCRIPT_DBG:: Out of loop\n";}
    $elem_cnt = 0;
    if($failcnt gt $fail_limit){
       print "Error count ($failcnt) exceeded limit ($fail_limit). Quiting regression\n";
       last;
    }
    elsif($failcnt eq 0) {
       print "Regression completed with no errors\n";
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
    
    open(FF,'>result.txt') or die("Can't open file result.txt");
    print FF $sumresult;
    close(FF);
}
    if ($failcnt > 0) {
    exit (-1);
    }
  

sub run_sim
{
    
    $this_dir = cwd();
    if($debug) {print "SCRIPT_DBG:: this_dir in run_sim $this_dir Line:", __LINE__, "\n";}
    $sim_cmd = $_[0];
    if($debug) {print "\n\n\n\nSCRIPT_DBG:: run_sim sim_cmd  $sim_cmd \nLine:", __LINE__, "\n\n\n";}
    ($junk,$rest) = split(/TEST=/,$sim_cmd);
    ($test,$junk) = split(/ /,$rest);
    if($debug) {print "\n\nSCRIPT_DBG::      test $test \n\n";}
    if($debug) {print "\nSCRIPT_DBG:: mk $mk   \n\ntest_pl $test_pl Line:", __LINE__, "\n";}
    if($debug) {print "\nSCRIPT_DBG:: name $name   test $test Line:", __LINE__, "\n";}
    $rand_seed = int(rand(2147483647));
    $logfile = $test.".log";
    if($debug) {print "SCRIPT_DBG:: logfile in run_sim $logfile    rand $rand  Line:", __LINE__, "\n";}
    if($debug) {print "SCRIPT_DBG:: name in run_sim $name Line:", __LINE__, "\n";}
    if($debug) {print "SCRIPT_DBG:: test in run_sim $test Line:", __LINE__, "\n";}
    if($debug) {print "SCRIPT_DBG:: verif2 $verif2  Line:", __LINE__, "\n";}
    if($verif2 eq 1){
       $rundir  = "rundir_" . $test . "_$rand_seed/";
       if($debug) {print "A SCRIPT_DBG:: rundir in run_sim $rundir Line:", __LINE__, "\n";}
    }
    if($debug) {print "SCRIPT_DBG:: rundir in run_sim $rundir Line:", __LINE__, "\n";}

    if($debug) {print "SCRIPT_DBG:: this_dir in run_sim $this_dir Line", __LINE__, "\n";}
    $sim_cmd .= " SEED=$rand_seed";
    if($debug) {print "\n\nSCRIPT_DBG:: rand_seed $rand_seed Line:", __LINE__, "\n\n";}
    if($debug) {print "\n\nSCRIPT_DBG:: sim_cmd $sim_cmd \nLine:", __LINE__, "\n\n";}

    $runcmd  = $sim_cmd."\n";
    system($sim_cmd);
    if($debug) {print "\n\nSCRIPT_DBG:: Finished sim_cmd $sim_cmd \nLine:", __LINE__, "\n\n";}
}

sub create_report
{
   if($debug) {print "SCRIPT_DBG:: HACK create_report\n";}
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
   if($debug) {print "SCRIPT_DBG:: in clean_dir $regrfile  Line: ", __LINE__, "\n";}
   chdir "../";
   $cmd     = 'ls '.$regrfile._*' > tmpdir';
   system($cmd);
   open(FF,'tmpdir') or die("Can't open file");
   @array   = <FF>;
   close FF;

   @array2  = ();
   $prv_str ='';

   foreach $elem (@array) {
      if($elem =~ /^$|result/) {
      } elsif($elem =~/^$regrfile/) {
         if($prv_str ne ''){
           push(@array2,$prv_str);
         }
         $prv_str = $elem;
      } else {
         $prv_str = '';
      }
   }

   if($prv_str =~/^$regrfile/) {
      push(@array2,$prv_str);
   }

   foreach $elem (@array2) {
      $elem =~s/://;
      $cmd = 'rm -rf '.$elem;
      system($cmd);
   }

   system("rm tmpdir");
}

sub update_time {
   ($day,$mon,$dayofmonth,$rest) = split (/\s+/,localtime(time),4);
   ($hour,$min,$rest)            = split (/:/,$rest,3);
}
