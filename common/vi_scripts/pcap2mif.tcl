#!/usr/bin/tclsh

set IPG_LEN 12
set MAX_DEP 2047

proc xgmii_ctrl xgmii_raw {
  set sum 0
	set len [llength $xgmii_raw]
  for {set i 0} {$i < $len} {incr i} {
  	set item [lindex $xgmii_raw $i]
  	if {$item == "I"} {
    	set sum [expr $sum + 2**($len - $i - 1)]
  	} elseif {$item == "S"} {
    	set sum [expr $sum + 2**($len - $i - 1)]
  	} elseif {$item == "T"} {
    	set sum [expr $sum + 2**($len - $i - 1)]
  	} elseif {$item == "E"} {
    	set sum [expr $sum + 2**($len - $i - 1)]
  	} 
  }
	return [format %02X $sum]
}

proc xgmii_data xgmii_raw {
  set data {}
  set len [llength $xgmii_raw]
  for {set i 0} {$i < $len} {incr i} {
    set item [lindex $xgmii_raw $i]
    if {$item == "I"} {
      lappend data "07"
    } elseif {$item == "S"} {
      lappend data "fb"
    } elseif {$item == "T"} {
      lappend data "fd"
    } elseif {$item == "E"} {
      lappend data "fe"
    } else {
      lappend data $item
    }
  }
  return $data
}

proc onehot_zero num {
	if {$num == 1} {return "07070707070707"}
	if {$num == 2} {return "070707070707"}
	if {$num == 3} {return "0707070707"}
	if {$num == 4} {return "07070707"}
	if {$num == 5} {return "070707"}
	if {$num == 6} {return "0707"}
	if {$num == 7} {return "07"}
}
proc onehot num {
	if {$num == 1} {return "80"}
	if {$num == 2} {return "c0"}
	if {$num == 3} {return "e0"}
	if {$num == 4} {return "f0"}
	if {$num == 5} {return "f8"}
	if {$num == 6} {return "fc"}
	if {$num == 7} {return "fe"}
}


set compressed_fn [lindex $argv 0]
if {[catch {exec gunzip -Nfv $compressed_fn} results options]} {
   set details [dict get $options -errorcode]
   if {[lindex $details 0] eq "CHILDSTATUS"} {
      set status [lindex $details 2]
   } else {
   }
}
set sfn_ext ""
if ([regexp -indices {replaced with} $results loc]) {
  set sfn_ext [string range $results [expr [lindex $loc 1] + 4] end]
}

set sfn [lindex [split $sfn_ext '.'] 0]
set dfn_mif "$sfn.mif"
set dfn_k12 "$sfn.k12"
set dfn_k12f "$sfn.k12f"

#Generate k12 text format for pcap file
set status 0
if {[catch {exec editcap -F k12text $sfn_ext $dfn_k12} results options]} {
   set details [dict get $options -errorcode]
   if {[lindex $details 0] eq "CHILDSTATUS"} {
      set status [lindex $details 2]
   } else {
			puts "Got some God awful error..."
      exit 2
   }
}

#source file now set to .k12 file
set sfh [open $dfn_k12 r]
set dfh [open $dfn_k12f w]
set data [read $sfh]
set lines [split $data "\n"]

#remove divider and timestamp
set pkts "" 
set num_frame [llength $lines]
foreach line $lines {
  if ([regexp -indices {\|0} $line loc]) {
		set line [string range $line [expr [lindex $loc 1] + 5] end]
		#prepend preamble and write pkt
	  puts -nonewline $dfh "S|55|55|55|55|55|55|d5|"
		puts -nonewline $dfh $line
		puts -nonewline $dfh "T"
    
    #lword align next frame
		set pkt_len [expr 9 + [llength [split $line "|"]]]
                set remainder [expr $pkt_len % 8]
                if {$remainder > 0} {
		  set total_idle [expr 8 - $remainder + $IPG_LEN] 
                } else {
		  set total_idle $IPG_LEN 
                }
		for {set i 0} {$i < $total_idle} {incr i} {
		  puts -nonewline $dfh "|I"
		}
		puts $dfh ""
  }
}
close $sfh
if {[catch {exec rm -f $dfn_k12} results options]} {
   set details [dict get $options -errorcode]
   if {[lindex $details 0] eq "CHILDSTATUS"} {
      set status [lindex $details 2]
   } else {
      puts "Got some God awful error..."
      exit 2
   }
}
close $dfh

#source file now set to .k12f file
set sfh [open $dfn_k12f r]
set dfh [open $dfn_mif w]
set data [read $sfh]
set lines [split $data "\n"]

#make byte stream
set byte_st {}
foreach line $lines {
	set bytes [lrange [split $line "|"] 0 end-1]
  set byte_st [concat $byte_st $bytes]
}

#byte stream length, word length, remainder
set bs_blen [llength $byte_st]
set bs_wlen_rem [expr $bs_blen % 8]

if {$bs_wlen_rem > 0} {
# pad it to lword boundary
  for {set i 0} {$i < 8 - $bs_wlen_rem} {incr i} {
	  lappend $byte_st I
  }
}
# update new byte length
set bs_blen [llength $byte_st]
set bs_wlen [expr $bs_blen / 8]

# ERROR check for wlen > MAX_DEP
if {$bs_wlen > $MAX_DEP} {
  set mp1 [expr $MAX_DEP + 1]
	error "Pattern is too long.  Maximum depth is set to $mp1 cycles"
  exit 1
}

#format and write to output file
puts $dfh "DEPTH = $bs_wlen;"
puts $dfh "WIDTH = 72;"
puts $dfh "ADDRESS_RADIX = DEC;"
puts $dfh "DATA_RADIX = HEX;"
puts $dfh "CONTENT"
puts $dfh "BEGIN"

for {set i 0} {$i < $bs_wlen} {incr i} {
set lpt [expr $i * 8]
set hpt [expr $lpt + 7]
set xgmii_raw [lrange $byte_st $lpt $hpt]
set xgmii_c [xgmii_ctrl $xgmii_raw]
set xgmii_d [xgmii_data $xgmii_raw]
	puts -nonewline $dfh "$i : $xgmii_c"
	puts -nonewline $dfh [join $xgmii_d ""]
	puts $dfh ";"
}
puts $dfh "END"

close $sfh
if {[catch {exec rm -f $dfn_k12f} results options]} {
   set details [dict get $options -errorcode]
   if {[lindex $details 0] eq "CHILDSTATUS"} {
      set status [lindex $details 2]
   } else {
      puts "Got some God awful error..."
      exit 2
   }
}
close $dfh
