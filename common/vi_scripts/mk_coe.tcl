proc chr { char} {
  #puts $char
  binary scan $char H* char
  #puts $char
  return $char
}
proc grep_line { lines pattern } {
  set result ""
  foreach line [split $lines "\n"] {
    if { [regexp .*$pattern $line] } {
      set result $line
      break
    }
  }
  if { [string length $result] == 0 } {
    error "No match $pattern in $lines"
  }
  return $result 
}
proc strip_whitspace { line } {
 set line [string trim $str "  \t"]
 return $line
}
proc get_svn_rev { folder } {
  #puts [exec svn "info" $folder]
  set lines [exec svn "info" $folder]
  set pattern "Last Changed Rev:"
  #puts [string range [grep_line $lines $pattern] 18 end]
  return [string range [grep_line $lines $pattern] 18 end]

}

proc get_git_date { folder } {
  set last_date_lines [split [exec git whatchanged -1 --format="%ci" -p $folder ] "\n"]
  #puts $last_date_lines
  set s0 [lindex $last_date_lines 0]

  set s1 [string trim $s0 \" ]

  set last_date [string trim [exec  date -d $s1 +"%y%m%d%H%M" ] \"]
  puts "last commit date:$last_date"
  return $last_date
}


proc get_git_last_commit { folder } {
  set commit_id [string trim [exec git log --format="%H" -n 1 $folder] \"]
  puts $commit_id

  return $commit_id
}


set svn_check "0"
if { [catch {exec svn info} lines options ] } {
   set details [dict get $options -errorcode]
   #puts "options: $options"
   #puts "details: $details"
   set svn_check [lindex $details 2]
   puts "svn_check: $svn_check" 
}



if { "$svn_check" != "0"} {
    set SVN "0"
} else {
  if { [file exists ../../../../../common] == 1} {
    set SVN [get_svn_rev "../../../../../common"]
  } elseif { [file exists ../../../../common] == 1} {
    set SVN [get_svn_rev "../../../../common"]
  } elseif { [file exists ../../../common] == 1} {
    set SVN [get_svn_rev "../../../common"]
  }
  #set SVN [get_svn_rev "http://vi-bugs/svn/pld/trunk"]
}
puts "SVN:$SVN"
set DATE [clock format [clock seconds] -format {%y%m%d}]
puts "date:$DATE"

if { [file exists .build_num] == 1} {
  set INFILE [open .build_num r]
  set BUILD_NUM [expr [gets $INFILE]]
  close $INFILE
  #puts $BUILD_NUM
  incr BUILD_NUM
  set OUTFILE [open .build_num w]
  puts $OUTFILE [format "%d" $BUILD_NUM]
  set BUILD_NUM [format "%02d" $BUILD_NUM]
  close $OUTFILE
} else {
  set OUTFILE [open .build_num w]
  puts $OUTFILE "[format "%d" 0]"
  set BUILD_NUM "00"
  close $OUTFILE
}
puts "build:$BUILD_NUM"
# fix me
if {0} {
  set ID [chr D]
  set ID [chr T]
  set ID [chr C]
  set ID [chr J]
  set ID [chr H]
  set ID [chr K]
  set ID [chr G]
  set ID [chr X]
}
if { [catch { set ID [exec id "-n" "-u"] } res] } {
  post_message -type error $res
  set idx [string first "\n" $res]
  #puts $idx
  set ID [string range $res 0 $idx-1]
  #puts $ID
  
}
if { [string compare $ID "duane.snider" ] == 0} {
  # hex val of ASCII 'D'
  set ID [chr D]
  set ID "44"
} elseif { [string compare $ID "tim.beyers" ] == 0} {
  # hex val of ASCII 'T'
  set ID [chr T]
  set ID "54"
} elseif { [string compare $ID "chi-wei.fu" ] == 0} {
  # hex val of ASCII 'C'
  set ID [chr C]
  set ID "43"
} elseif { [string compare $ID "jay.madireddy" ] == 0} {
  # hex val of ASCII 'J'
  set ID [chr J]
  set ID "4a"
} elseif { [string compare $ID "honda.yang" ] == 0} {
  # hex val of ASCII 'H'
  set ID [chr H]
  set ID "48"
} elseif { [string compare $ID "jaedon.kim" ] == 0} {
  # hex val of ASCII 'K'
  set ID [chr K]
  set ID "4b"
} elseif { [string compare $ID "gshen" ] == 0} {
  # hex val of ASCII 'G'
  set ID [chr G]
  set ID "47"
} elseif { [string compare $ID "lzhou" ] == 0} {
  # hex val of ASCII 'L'
  set ID [chr L]
  set ID "50"
} else {
  # hex val of ASCII 'X'
  set ID [chr X]
  set ID "58"
}
puts "id:$ID"

# SVN FPGA_VERSION=yymmddssssssaabb
# s = svn          - binary coded decimal
# a = author id    - 
# b = build number - binary coded decimat
if { "$SVN" != "0"} {
  set FPGA_VERSION [format "%s%s%s%s" $DATE $SVN $ID $BUILD_NUM]
} else {
  # GIT FPGA_VERSION=yymmddhhssxxxxxx
  # yymmddhhss - last commit timestamp
  # xxxxxx - last commit id least significant nibbles
  set GIT_DATE [get_git_date "."]
  set GIT_COMMIT_ID [get_git_last_commit "."]

  set len [string length $GIT_COMMIT_ID]
  set sub_commit_id [string range $GIT_COMMIT_ID [expr $len - 6] $len]

  set FPGA_VERSION [format "%s%s" $GIT_DATE $sub_commit_id]
}
puts "FPGA_VERSION:$FPGA_VERSION"

puts [exec pwd]
# fix me
set OUTFILE [open fpga_rev_rom.coe w]
set lines "memory_initialization_radix = 16;
memory_initialization_vector =
$FPGA_VERSION,
0000000000000000,
0000000000000000,
0000000000000000,
0000000000000000,
0000000000000000,
0000000000000000,
0000000000000000,
0000000000000000,
0000000000000000,
0000000000000000,
0000000000000000,
0000000000000000,
0000000000000000,
0000000000000000,
0000000000000000,
0000000000000000,
0000000000000000,
0000000000000000,
0000000000000000,
0000000000000000,
0000000000000000,
0000000000000000,
0000000000000000,
0000000000000000,
0000000000000000,
0000000000000000,
0000000000000000,
0000000000000000,
0000000000000000,
0000000000000000,
0000000000000000;
"
puts $OUTFILE [format "%s" $lines]
close $OUTFILE
exit
