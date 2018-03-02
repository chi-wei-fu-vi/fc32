proc set_instance_assignmenset_instance_assignment {args} {
}
proc set_global_assignment {args} {
  
  set kv [lrange $args 0 end-1]
  set value [lrange $args end-0 end]
  if {[catch {array set aArgs $kv} err]} {
    puts "Error : $err"
    return 0
  }
  if { [info exists aArgs(-library)] } {

      set library $aArgs(-library)
      puts $library

  }
  if { [info exists aArgs(-name)] } {

    switch $aArgs(-name) { 

      "SYSTEMVERILOG_FILE" {
         puts "add_files $value"
         add_files $value
         set_property file_type SystemVerilog [get_files $value]
         set_property library $library [get_files $value]
      }

      "VERILOG_FILE" {
         puts "add_files $value"
         add_files $value
         set_property file_type Verilog [get_files $value]
         set_property library $library [get_files $value]
      }

      "VHDL_FILE" {
         puts "add_files $value"
         add_files $value
         set_property file_type VHDL [get_files $value]
         set_property library $library [get_files $value]
         #set fbasename [file rootname [file tail $value]]
         #set fdirname [ file dir [ file dirname $value] ]
         #puts "add_files -quiet $fdirname/$fbasename.xci"
         #add_files -quiet "$fdirname/$fbasename.xci"
      }

      "SEARCH_PATH" {
         puts "append include_dirs $value"
         if { [info exists incdir_list] } {
           set incdir_list [list]
         }
         lappend incdir_list [file normalize $value]
      }

      "XCI_PATH" {
         puts "add xci path $value"
         add_files -quiet $value
      }

      "QIP_FILE" {
         puts "QIP_FILE $value"
         set tmp_qip_path $::quartus(qip_path)
         set ::quartus(qip_path) [ file normalize [ file dirname $value ] ]
         source $value
         set ::quartus(qip_path) $tmp_qip_path
      }

      "SDC_FILE" {
         puts "SDC_FILE $value"
         add_files -fileset constrs_1 $value
         add_files -norecurse -fileset [get_filesets constrs_1] $files
      }
      "XDC_FILE" {
         puts "XDC_FILE $value"
         add_files -norecurse -fileset [get_filesets constrs_1] $files
      }

      "MISC_FILE" {
         puts "MISC_FILE"
      }

      "SOURCE_FILE" {
         puts "SOURCE_FILE"
      }

      "SOPCINFO_FILE" {
         puts "SOPCINFO_FILE"
      }

      "SLD_INFO" {
         puts "SLD_INFO"
      }

      "IP_TOOL_NAME" {
         puts "IP_TOOL_NAME"
      }

      "IP_TOOL_VERSION" {
         puts "IP_TOOL_VERSION"
      }

      "IP_TOOL_ENV" {
         puts "IP_TOOL_ENV"
      }
    }

  }
}
