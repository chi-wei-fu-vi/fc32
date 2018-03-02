
proc Analysis___Synthesis__Analysis___Synthesis_IP_Cores_Summary { } {
  puts "Create report : Analysis & Synthesis||Analysis & Synthesis IP Cores Summary"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Analysis___Synthesis__Analysis___Synthesis_IP_Cores_Summary.csv w]
  set panel_id [get_report_panel_id "Analysis & Synthesis||Analysis & Synthesis IP Cores Summary"]
  if { -1 == $panel_id } {
    close $fh
    file delete Analysis___Synthesis__Analysis___Synthesis_IP_Cores_Summary.csv
    return -1
  }

  set AVendor_index [get_report_panel_column_index -id $panel_id "Vendor"]
  set AIP_Core_Name_index [get_report_panel_column_index -id $panel_id "IP Core Name"]
  set AVersion_index [get_report_panel_column_index -id $panel_id "Version"]
  set ARelease_Date_index [get_report_panel_column_index -id $panel_id "Release Date"]
  set ALicense_Type_index [get_report_panel_column_index -id $panel_id "License Type"]
  set AEntity_Instance_index [get_report_panel_column_index -id $panel_id "Entity Instance"]
  set AIP_Include_File_index [get_report_panel_column_index -id $panel_id "IP Include File"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AVendor_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AIP_Core_Name_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AVersion_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARelease_Date_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ALicense_Type_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AEntity_Instance_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AIP_Include_File_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Multiplexer_Statistics__Multiplexer_Restructuring_Statistics__Restructuring_Performed_ { } {
  puts "Create report : Analysis & Synthesis||Analysis & Synthesis Optimization Results||Multiplexer Statistics||Multiplexer Restructuring Statistics (Restructuring Performed)"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Multiplexer_Statistics__Multiplexer_Restructuring_Statistics__Restructuring_Performed_.csv w]
  set panel_id [get_report_panel_id "Analysis & Synthesis||Analysis & Synthesis Optimization Results||Multiplexer Statistics||Multiplexer Restructuring Statistics (Restructuring Performed)"]
  if { -1 == $panel_id } {
    close $fh
    file delete Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Multiplexer_Statistics__Multiplexer_Restructuring_Statistics__Restructuring_Performed_.csv
    return -1
  }

  set AMultiplexer_Inputs_index [get_report_panel_column_index -id $panel_id "Multiplexer Inputs"]
  set ABus_Width_index [get_report_panel_column_index -id $panel_id "Bus Width"]
  set ABaseline_Area_index [get_report_panel_column_index -id $panel_id "Baseline Area"]
  set AArea_if_Restructured_index [get_report_panel_column_index -id $panel_id "Area if Restructured"]
  set ASaving_if_Restructured_index [get_report_panel_column_index -id $panel_id "Saving if Restructured"]
  set ARegistered_index [get_report_panel_column_index -id $panel_id "Registered"]
  set AExample_Multiplexer_Output_index [get_report_panel_column_index -id $panel_id "Example Multiplexer Output"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AMultiplexer_Inputs_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ABus_Width_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ABaseline_Area_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AArea_if_Restructured_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASaving_if_Restructured_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARegistered_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AExample_Multiplexer_Output_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Register_Statistics__General_Register_Statistics { } {
  puts "Create report : Analysis & Synthesis||Analysis & Synthesis Optimization Results||Register Statistics||General Register Statistics"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Register_Statistics__General_Register_Statistics.csv w]
  set panel_id [get_report_panel_id "Analysis & Synthesis||Analysis & Synthesis Optimization Results||Register Statistics||General Register Statistics"]
  if { -1 == $panel_id } {
    close $fh
    file delete Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Register_Statistics__General_Register_Statistics.csv
    return -1
  }

  set AStatistic_index [get_report_panel_column_index -id $panel_id "Statistic"]
  set AValue_index [get_report_panel_column_index -id $panel_id "Value"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AStatistic_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AValue_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Register_Statistics__Inverted_Register_Statistics { } {
  puts "Create report : Analysis & Synthesis||Analysis & Synthesis Optimization Results||Register Statistics||Inverted Register Statistics"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Register_Statistics__Inverted_Register_Statistics.csv w]
  set panel_id [get_report_panel_id "Analysis & Synthesis||Analysis & Synthesis Optimization Results||Register Statistics||Inverted Register Statistics"]
  if { -1 == $panel_id } {
    close $fh
    file delete Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Register_Statistics__Inverted_Register_Statistics.csv
    return -1
  }

  set AInverted_Register_index [get_report_panel_column_index -id $panel_id "Inverted Register"]
  set AFan_out_index [get_report_panel_column_index -id $panel_id "Fan out"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AInverted_Register_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFan_out_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Register_Statistics__Registers_Protected_by_Synthesis { } {
  puts "Create report : Analysis & Synthesis||Analysis & Synthesis Optimization Results||Register Statistics||Registers Protected by Synthesis"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Register_Statistics__Registers_Protected_by_Synthesis.csv w]
  set panel_id [get_report_panel_id "Analysis & Synthesis||Analysis & Synthesis Optimization Results||Register Statistics||Registers Protected by Synthesis"]
  if { -1 == $panel_id } {
    close $fh
    file delete Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Register_Statistics__Registers_Protected_by_Synthesis.csv
    return -1
  }

  set ARegister_Name_index [get_report_panel_column_index -id $panel_id "Register Name"]
  set AProtected_by_Synthesis_Attribute_or_Preserve_Register_Assignment_index [get_report_panel_column_index -id $panel_id "Protected by Synthesis Attribute or Preserve Register Assignment"]
  set ANot_to_be_Touched_by_Netlist_Optimizations_index [get_report_panel_column_index -id $panel_id "Not to be Touched by Netlist Optimizations"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARegister_Name_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AProtected_by_Synthesis_Attribute_or_Preserve_Register_Assignment_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ANot_to_be_Touched_by_Netlist_Optimizations_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Register_Statistics__Registers_Removed_During_Synthesis { } {
  puts "Create report : Analysis & Synthesis||Analysis & Synthesis Optimization Results||Register Statistics||Registers Removed During Synthesis"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Register_Statistics__Registers_Removed_During_Synthesis.csv w]
  set panel_id [get_report_panel_id "Analysis & Synthesis||Analysis & Synthesis Optimization Results||Register Statistics||Registers Removed During Synthesis"]
  if { -1 == $panel_id } {
    close $fh
    file delete Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Register_Statistics__Registers_Removed_During_Synthesis.csv
    return -1
  }

  set ARegister_name_index [get_report_panel_column_index -id $panel_id "Register name"]
  set AReason_for_Removal_index [get_report_panel_column_index -id $panel_id "Reason for Removal"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARegister_name_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AReason_for_Removal_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Register_Statistics__Removed_Registers_Triggering_Further_Register_Optimizations { } {
  puts "Create report : Analysis & Synthesis||Analysis & Synthesis Optimization Results||Register Statistics||Removed Registers Triggering Further Register Optimizations"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Register_Statistics__Removed_Registers_Triggering_Further_Register_Optimizations.csv w]
  set panel_id [get_report_panel_id "Analysis & Synthesis||Analysis & Synthesis Optimization Results||Register Statistics||Removed Registers Triggering Further Register Optimizations"]
  if { -1 == $panel_id } {
    close $fh
    file delete Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Register_Statistics__Removed_Registers_Triggering_Further_Register_Optimizations.csv
    return -1
  }

  set ARegister_name_index [get_report_panel_column_index -id $panel_id "Register name"]
  set AReason_for_Removal_index [get_report_panel_column_index -id $panel_id "Reason for Removal"]
  set ARegisters_Removed_due_to_This_Register_index [get_report_panel_column_index -id $panel_id "Registers Removed due to This Register"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARegister_name_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AReason_for_Removal_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARegisters_Removed_due_to_This_Register_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Registers_Packed_Into_Inferred_Megafunctions { } {
  puts "Create report : Analysis & Synthesis||Analysis & Synthesis Optimization Results||Registers Packed Into Inferred Megafunctions"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Registers_Packed_Into_Inferred_Megafunctions.csv w]
  set panel_id [get_report_panel_id "Analysis & Synthesis||Analysis & Synthesis Optimization Results||Registers Packed Into Inferred Megafunctions"]
  if { -1 == $panel_id } {
    close $fh
    file delete Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Registers_Packed_Into_Inferred_Megafunctions.csv
    return -1
  }

  set ARegister_Name_index [get_report_panel_column_index -id $panel_id "Register Name"]
  set AMegafunction_index [get_report_panel_column_index -id $panel_id "Megafunction"]
  set AType_index [get_report_panel_column_index -id $panel_id "Type"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARegister_Name_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AMegafunction_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AType_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Analysis___Synthesis__Analysis___Synthesis_RAM_Summary { } {
  puts "Create report : Analysis & Synthesis||Analysis & Synthesis RAM Summary"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Analysis___Synthesis__Analysis___Synthesis_RAM_Summary.csv w]
  set panel_id [get_report_panel_id "Analysis & Synthesis||Analysis & Synthesis RAM Summary"]
  if { -1 == $panel_id } {
    close $fh
    file delete Analysis___Synthesis__Analysis___Synthesis_RAM_Summary.csv
    return -1
  }

  set AName_index [get_report_panel_column_index -id $panel_id "Name"]
  set AType_index [get_report_panel_column_index -id $panel_id "Type"]
  set AMode_index [get_report_panel_column_index -id $panel_id "Mode"]
  set APort_A_Depth_index [get_report_panel_column_index -id $panel_id "Port A Depth"]
  set APort_A_Width_index [get_report_panel_column_index -id $panel_id "Port A Width"]
  set APort_B_Depth_index [get_report_panel_column_index -id $panel_id "Port B Depth"]
  set APort_B_Width_index [get_report_panel_column_index -id $panel_id "Port B Width"]
  set ASize_index [get_report_panel_column_index -id $panel_id "Size"]
  set AMIF_index [get_report_panel_column_index -id $panel_id "MIF"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AName_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AType_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AMode_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $APort_A_Depth_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $APort_A_Width_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $APort_B_Depth_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $APort_B_Width_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASize_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AMIF_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Analysis___Synthesis__Analysis___Synthesis_Resource_Usage_Summary { } {
  puts "Create report : Analysis & Synthesis||Analysis & Synthesis Resource Usage Summary"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Analysis___Synthesis__Analysis___Synthesis_Resource_Usage_Summary.csv w]
  set panel_id [get_report_panel_id "Analysis & Synthesis||Analysis & Synthesis Resource Usage Summary"]
  if { -1 == $panel_id } {
    close $fh
    file delete Analysis___Synthesis__Analysis___Synthesis_Resource_Usage_Summary.csv
    return -1
  }

  set AResource_index [get_report_panel_column_index -id $panel_id "Resource"]
  set AUsage_index [get_report_panel_column_index -id $panel_id "Usage"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AResource_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AUsage_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Analysis___Synthesis__Analysis___Synthesis_Resource_Utilization_by_Entity { } {
  puts "Create report : Analysis & Synthesis||Analysis & Synthesis Resource Utilization by Entity"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Analysis___Synthesis__Analysis___Synthesis_Resource_Utilization_by_Entity.csv w]
  set panel_id [get_report_panel_id "Analysis & Synthesis||Analysis & Synthesis Resource Utilization by Entity"]
  if { -1 == $panel_id } {
    close $fh
    file delete Analysis___Synthesis__Analysis___Synthesis_Resource_Utilization_by_Entity.csv
    return -1
  }

  set ACompilation_Hierarchy_Node_index [get_report_panel_column_index -id $panel_id "Compilation Hierarchy Node"]
  set ALC_Combinationals_index [get_report_panel_column_index -id $panel_id "LC Combinationals"]
  set ALC_Registers_index [get_report_panel_column_index -id $panel_id "LC Registers"]
  set ABlock_Memory_Bits_index [get_report_panel_column_index -id $panel_id "Block Memory Bits"]
  set ADSP_Blocks_index [get_report_panel_column_index -id $panel_id "DSP Blocks"]
  set APins_index [get_report_panel_column_index -id $panel_id "Pins"]
  set AVirtual_Pins_index [get_report_panel_column_index -id $panel_id "Virtual Pins"]
  set AFull_Hierarchy_Name_index [get_report_panel_column_index -id $panel_id "Full Hierarchy Name"]
  set ALibrary_Name_index [get_report_panel_column_index -id $panel_id "Library Name"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ACompilation_Hierarchy_Node_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ALC_Combinationals_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ALC_Registers_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ABlock_Memory_Bits_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ADSP_Blocks_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $APins_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AVirtual_Pins_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFull_Hierarchy_Name_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ALibrary_Name_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Analysis___Synthesis__Analysis___Synthesis_Source_Files_Read { } {
  puts "Create report : Analysis & Synthesis||Analysis & Synthesis Source Files Read"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Analysis___Synthesis__Analysis___Synthesis_Source_Files_Read.csv w]
  set panel_id [get_report_panel_id "Analysis & Synthesis||Analysis & Synthesis Source Files Read"]
  if { -1 == $panel_id } {
    close $fh
    file delete Analysis___Synthesis__Analysis___Synthesis_Source_Files_Read.csv
    return -1
  }

  set AFile_Name_with_User_Entered_Path_index [get_report_panel_column_index -id $panel_id "File Name with User-Entered Path"]
  set AUsed_in_Netlist_index [get_report_panel_column_index -id $panel_id "Used in Netlist"]
  set AFile_Type_index [get_report_panel_column_index -id $panel_id "File Type"]
  set AFile_Name_with_Absolute_Path_index [get_report_panel_column_index -id $panel_id "File Name with Absolute Path"]
  set ALibrary_index [get_report_panel_column_index -id $panel_id "Library"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFile_Name_with_User_Entered_Path_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AUsed_in_Netlist_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFile_Type_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFile_Name_with_Absolute_Path_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ALibrary_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Analysis___Synthesis__Analysis___Synthesis_Summary { } {
  puts "Create report : Analysis & Synthesis||Analysis & Synthesis Summary"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Analysis___Synthesis__Analysis___Synthesis_Summary.csv w]
  set panel_id [get_report_panel_id "Analysis & Synthesis||Analysis & Synthesis Summary"]
  if { -1 == $panel_id } {
    close $fh
    file delete Analysis___Synthesis__Analysis___Synthesis_Summary.csv
    return -1
  }

  set AAnalysis___Synthesis_Status_index [get_report_panel_column_index -id $panel_id "Analysis & Synthesis Status"]
  set ASuccessful___Tue_May_21_20_45_23_2013_index [get_report_panel_column_index -id $panel_id "Successful - Tue May 21 20:45:23 2013"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AAnalysis___Synthesis_Status_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASuccessful___Tue_May_21_20_45_23_2013_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Analysis___Synthesis__Elapsed_Time_Per_Partition { } {
  puts "Create report : Analysis & Synthesis||Elapsed Time Per Partition"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Analysis___Synthesis__Elapsed_Time_Per_Partition.csv w]
  set panel_id [get_report_panel_id "Analysis & Synthesis||Elapsed Time Per Partition"]
  if { -1 == $panel_id } {
    close $fh
    file delete Analysis___Synthesis__Elapsed_Time_Per_Partition.csv
    return -1
  }

  set APartition_Name_index [get_report_panel_column_index -id $panel_id "Partition Name"]
  set AElapsed_Time_index [get_report_panel_column_index -id $panel_id "Elapsed Time"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $APartition_Name_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AElapsed_Time_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Analysis___Synthesis__Parallel_Compilation { } {
  puts "Create report : Analysis & Synthesis||Parallel Compilation"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Analysis___Synthesis__Parallel_Compilation.csv w]
  set panel_id [get_report_panel_id "Analysis & Synthesis||Parallel Compilation"]
  if { -1 == $panel_id } {
    close $fh
    file delete Analysis___Synthesis__Parallel_Compilation.csv
    return -1
  }

  set AProcessors_index [get_report_panel_column_index -id $panel_id "Processors"]
  set ANumber_index [get_report_panel_column_index -id $panel_id "Number"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AProcessors_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ANumber_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Analysis___Synthesis__Settings__Analysis___Synthesis_Default_Parameter_Settings { } {
  puts "Create report : Analysis & Synthesis||Settings||Analysis & Synthesis Default Parameter Settings"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Analysis___Synthesis__Settings__Analysis___Synthesis_Default_Parameter_Settings.csv w]
  set panel_id [get_report_panel_id "Analysis & Synthesis||Settings||Analysis & Synthesis Default Parameter Settings"]
  if { -1 == $panel_id } {
    close $fh
    file delete Analysis___Synthesis__Settings__Analysis___Synthesis_Default_Parameter_Settings.csv
    return -1
  }

  set AName_index [get_report_panel_column_index -id $panel_id "Name"]
  set ASetting_index [get_report_panel_column_index -id $panel_id "Setting"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AName_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASetting_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Analysis___Synthesis__Settings__Analysis___Synthesis_Settings { } {
  puts "Create report : Analysis & Synthesis||Settings||Analysis & Synthesis Settings"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Analysis___Synthesis__Settings__Analysis___Synthesis_Settings.csv w]
  set panel_id [get_report_panel_id "Analysis & Synthesis||Settings||Analysis & Synthesis Settings"]
  if { -1 == $panel_id } {
    close $fh
    file delete Analysis___Synthesis__Settings__Analysis___Synthesis_Settings.csv
    return -1
  }

  set AOption_index [get_report_panel_column_index -id $panel_id "Option"]
  set ASetting_index [get_report_panel_column_index -id $panel_id "Setting"]
  set ADefault_Value_index [get_report_panel_column_index -id $panel_id "Default Value"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AOption_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASetting_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ADefault_Value_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Assembler__Assembler_Device_Options____dse_temp_rev_sof { } {
  puts "Create report : Assembler||Assembler Device Options: __dse_temp_rev.sof"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Assembler__Assembler_Device_Options____dse_temp_rev_sof.csv w]
  set panel_id [get_report_panel_id "Assembler||Assembler Device Options: __dse_temp_rev.sof"]
  if { -1 == $panel_id } {
    close $fh
    file delete Assembler__Assembler_Device_Options____dse_temp_rev_sof.csv
    return -1
  }

  set AOption_index [get_report_panel_column_index -id $panel_id "Option"]
  set ASetting_index [get_report_panel_column_index -id $panel_id "Setting"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AOption_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASetting_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Assembler__Assembler_Encrypted_IP_Cores_Summary { } {
  puts "Create report : Assembler||Assembler Encrypted IP Cores Summary"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Assembler__Assembler_Encrypted_IP_Cores_Summary.csv w]
  set panel_id [get_report_panel_id "Assembler||Assembler Encrypted IP Cores Summary"]
  if { -1 == $panel_id } {
    close $fh
    file delete Assembler__Assembler_Encrypted_IP_Cores_Summary.csv
    return -1
  }

  set AVendor_index [get_report_panel_column_index -id $panel_id "Vendor"]
  set AIP_Core_Name_index [get_report_panel_column_index -id $panel_id "IP Core Name"]
  set ALicense_Type_index [get_report_panel_column_index -id $panel_id "License Type"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AVendor_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AIP_Core_Name_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ALicense_Type_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Assembler__Assembler_Generated_Files { } {
  puts "Create report : Assembler||Assembler Generated Files"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Assembler__Assembler_Generated_Files.csv w]
  set panel_id [get_report_panel_id "Assembler||Assembler Generated Files"]
  if { -1 == $panel_id } {
    close $fh
    file delete Assembler__Assembler_Generated_Files.csv
    return -1
  }

  set AFile_Name_________________index [get_report_panel_column_index -id $panel_id "File Name                "]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFile_Name_________________index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Assembler__Assembler_Settings { } {
  puts "Create report : Assembler||Assembler Settings"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Assembler__Assembler_Settings.csv w]
  set panel_id [get_report_panel_id "Assembler||Assembler Settings"]
  if { -1 == $panel_id } {
    close $fh
    file delete Assembler__Assembler_Settings.csv
    return -1
  }

  set AOption_index [get_report_panel_column_index -id $panel_id "Option"]
  set ASetting_index [get_report_panel_column_index -id $panel_id "Setting"]
  set ADefault_Value_index [get_report_panel_column_index -id $panel_id "Default Value"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AOption_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASetting_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ADefault_Value_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Assembler__Assembler_Summary { } {
  puts "Create report : Assembler||Assembler Summary"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Assembler__Assembler_Summary.csv w]
  set panel_id [get_report_panel_id "Assembler||Assembler Summary"]
  if { -1 == $panel_id } {
    close $fh
    file delete Assembler__Assembler_Summary.csv
    return -1
  }

  set AAssembler_Status_index [get_report_panel_column_index -id $panel_id "Assembler Status"]
  set ASuccessful___Wed_May_22_00_17_21_2013_index [get_report_panel_column_index -id $panel_id "Successful - Wed May 22 00:17:21 2013"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AAssembler_Status_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASuccessful___Wed_May_22_00_17_21_2013_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Fitter__Estimated_Delay_Added_for_Hold_Timing__Estimated_Delay_Added_for_Hold_Timing_Details { } {
  puts "Create report : Fitter||Estimated Delay Added for Hold Timing||Estimated Delay Added for Hold Timing Details"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Fitter__Estimated_Delay_Added_for_Hold_Timing__Estimated_Delay_Added_for_Hold_Timing_Details.csv w]
  set panel_id [get_report_panel_id "Fitter||Estimated Delay Added for Hold Timing||Estimated Delay Added for Hold Timing Details"]
  if { -1 == $panel_id } {
    close $fh
    file delete Fitter__Estimated_Delay_Added_for_Hold_Timing__Estimated_Delay_Added_for_Hold_Timing_Details.csv
    return -1
  }

  set ASource_Register_index [get_report_panel_column_index -id $panel_id "Source Register"]
  set ADestination_Register_index [get_report_panel_column_index -id $panel_id "Destination Register"]
  set ADelay_Added_in_ns_index [get_report_panel_column_index -id $panel_id "Delay Added in ns"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASource_Register_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ADestination_Register_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ADelay_Added_in_ns_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Fitter__Estimated_Delay_Added_for_Hold_Timing__Estimated_Delay_Added_for_Hold_Timing_Summary { } {
  puts "Create report : Fitter||Estimated Delay Added for Hold Timing||Estimated Delay Added for Hold Timing Summary"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Fitter__Estimated_Delay_Added_for_Hold_Timing__Estimated_Delay_Added_for_Hold_Timing_Summary.csv w]
  set panel_id [get_report_panel_id "Fitter||Estimated Delay Added for Hold Timing||Estimated Delay Added for Hold Timing Summary"]
  if { -1 == $panel_id } {
    close $fh
    file delete Fitter__Estimated_Delay_Added_for_Hold_Timing__Estimated_Delay_Added_for_Hold_Timing_Summary.csv
    return -1
  }

  set ASource_Clock_s__index [get_report_panel_column_index -id $panel_id "Source Clock(s)"]
  set ADestination_Clock_s__index [get_report_panel_column_index -id $panel_id "Destination Clock(s)"]
  set ADelay_Added_in_ns_index [get_report_panel_column_index -id $panel_id "Delay Added in ns"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASource_Clock_s__index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ADestination_Clock_s__index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ADelay_Added_in_ns_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Fitter__Fitter_Device_Options { } {
  puts "Create report : Fitter||Fitter Device Options"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Fitter__Fitter_Device_Options.csv w]
  set panel_id [get_report_panel_id "Fitter||Fitter Device Options"]
  if { -1 == $panel_id } {
    close $fh
    file delete Fitter__Fitter_Device_Options.csv
    return -1
  }

  set AOption_index [get_report_panel_column_index -id $panel_id "Option"]
  set ASetting_index [get_report_panel_column_index -id $panel_id "Setting"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AOption_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASetting_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Fitter__Fitter_Incremental_Compilation_Section__Incremental_Compilation_Partition_Settings { } {
  puts "Create report : Fitter||Fitter Incremental Compilation Section||Incremental Compilation Partition Settings"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Fitter__Fitter_Incremental_Compilation_Section__Incremental_Compilation_Partition_Settings.csv w]
  set panel_id [get_report_panel_id "Fitter||Fitter Incremental Compilation Section||Incremental Compilation Partition Settings"]
  if { -1 == $panel_id } {
    close $fh
    file delete Fitter__Fitter_Incremental_Compilation_Section__Incremental_Compilation_Partition_Settings.csv
    return -1
  }

  set APartition_Name_index [get_report_panel_column_index -id $panel_id "Partition Name"]
  set APartition_Type_index [get_report_panel_column_index -id $panel_id "Partition Type"]
  set ANetlist_Type_Used_index [get_report_panel_column_index -id $panel_id "Netlist Type Used"]
  set APreservation_Level_Used_index [get_report_panel_column_index -id $panel_id "Preservation Level Used"]
  set ANetlist_Type_Requested_index [get_report_panel_column_index -id $panel_id "Netlist Type Requested"]
  set APreservation_Level_Requested_index [get_report_panel_column_index -id $panel_id "Preservation Level Requested"]
  set AContents_index [get_report_panel_column_index -id $panel_id "Contents"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $APartition_Name_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $APartition_Type_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ANetlist_Type_Used_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $APreservation_Level_Used_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ANetlist_Type_Requested_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $APreservation_Level_Requested_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AContents_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Fitter__Fitter_Incremental_Compilation_Section__Incremental_Compilation_Placement_Preservation { } {
  puts "Create report : Fitter||Fitter Incremental Compilation Section||Incremental Compilation Placement Preservation"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Fitter__Fitter_Incremental_Compilation_Section__Incremental_Compilation_Placement_Preservation.csv w]
  set panel_id [get_report_panel_id "Fitter||Fitter Incremental Compilation Section||Incremental Compilation Placement Preservation"]
  if { -1 == $panel_id } {
    close $fh
    file delete Fitter__Fitter_Incremental_Compilation_Section__Incremental_Compilation_Placement_Preservation.csv
    return -1
  }

  set APartition_Name_index [get_report_panel_column_index -id $panel_id "Partition Name"]
  set A#_Nodes_index [get_report_panel_column_index -id $panel_id "# Nodes"]
  set A#_Preserved_Nodes_index [get_report_panel_column_index -id $panel_id "# Preserved Nodes"]
  set APreservation_Level_Used_index [get_report_panel_column_index -id $panel_id "Preservation Level Used"]
  set ANetlist_Type_Used_index [get_report_panel_column_index -id $panel_id "Netlist Type Used"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $APartition_Name_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $A#_Nodes_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $A#_Preserved_Nodes_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $APreservation_Level_Used_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ANetlist_Type_Used_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Fitter__Fitter_Incremental_Compilation_Section__Incremental_Compilation_Preservation_Summary { } {
  puts "Create report : Fitter||Fitter Incremental Compilation Section||Incremental Compilation Preservation Summary"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Fitter__Fitter_Incremental_Compilation_Section__Incremental_Compilation_Preservation_Summary.csv w]
  set panel_id [get_report_panel_id "Fitter||Fitter Incremental Compilation Section||Incremental Compilation Preservation Summary"]
  if { -1 == $panel_id } {
    close $fh
    file delete Fitter__Fitter_Incremental_Compilation_Section__Incremental_Compilation_Preservation_Summary.csv
    return -1
  }

  set AType_index [get_report_panel_column_index -id $panel_id "Type"]
  set AValue_index [get_report_panel_column_index -id $panel_id "Value"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AType_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AValue_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Fitter__Fitter_Netlist_Optimizations { } {
  puts "Create report : Fitter||Fitter Netlist Optimizations"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Fitter__Fitter_Netlist_Optimizations.csv w]
  set panel_id [get_report_panel_id "Fitter||Fitter Netlist Optimizations"]
  if { -1 == $panel_id } {
    close $fh
    file delete Fitter__Fitter_Netlist_Optimizations.csv
    return -1
  }

  set ANode_index [get_report_panel_column_index -id $panel_id "Node"]
  set AAction_index [get_report_panel_column_index -id $panel_id "Action"]
  set AOperation_index [get_report_panel_column_index -id $panel_id "Operation"]
  set AReason_index [get_report_panel_column_index -id $panel_id "Reason"]
  set ANode_Port_index [get_report_panel_column_index -id $panel_id "Node Port"]
  set ANode_Port_Name_index [get_report_panel_column_index -id $panel_id "Node Port Name"]
  set ADestination_Node_index [get_report_panel_column_index -id $panel_id "Destination Node"]
  set ADestination_Port_index [get_report_panel_column_index -id $panel_id "Destination Port"]
  set ADestination_Port_Name_index [get_report_panel_column_index -id $panel_id "Destination Port Name"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ANode_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AAction_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AOperation_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AReason_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ANode_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ANode_Port_Name_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ADestination_Node_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ADestination_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ADestination_Port_Name_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Fitter__Fitter_Settings { } {
  puts "Create report : Fitter||Fitter Settings"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Fitter__Fitter_Settings.csv w]
  set panel_id [get_report_panel_id "Fitter||Fitter Settings"]
  if { -1 == $panel_id } {
    close $fh
    file delete Fitter__Fitter_Settings.csv
    return -1
  }

  set AOption_index [get_report_panel_column_index -id $panel_id "Option"]
  set ASetting_index [get_report_panel_column_index -id $panel_id "Setting"]
  set ADefault_Value_index [get_report_panel_column_index -id $panel_id "Default Value"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AOption_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASetting_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ADefault_Value_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Fitter__Fitter_Summary { } {
  puts "Create report : Fitter||Fitter Summary"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Fitter__Fitter_Summary.csv w]
  set panel_id [get_report_panel_id "Fitter||Fitter Summary"]
  if { -1 == $panel_id } {
    close $fh
    file delete Fitter__Fitter_Summary.csv
    return -1
  }

  set AFitter_Status_index [get_report_panel_column_index -id $panel_id "Fitter Status"]
  set ASuccessful___Wed_May_22_00_09_58_2013_index [get_report_panel_column_index -id $panel_id "Successful - Wed May 22 00:09:58 2013"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFitter_Status_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASuccessful___Wed_May_22_00_09_58_2013_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Fitter__I_O_Assignment_Warnings { } {
  puts "Create report : Fitter||I/O Assignment Warnings"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Fitter__I_O_Assignment_Warnings.csv w]
  set panel_id [get_report_panel_id "Fitter||I/O Assignment Warnings"]
  if { -1 == $panel_id } {
    close $fh
    file delete Fitter__I_O_Assignment_Warnings.csv
    return -1
  }

  set APin_Name_index [get_report_panel_column_index -id $panel_id "Pin Name"]
  set AReason_index [get_report_panel_column_index -id $panel_id "Reason"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $APin_Name_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AReason_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Fitter__I_O_Rules_Section__I_O_Rules_Details { } {
  puts "Create report : Fitter||I/O Rules Section||I/O Rules Details"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Fitter__I_O_Rules_Section__I_O_Rules_Details.csv w]
  set panel_id [get_report_panel_id "Fitter||I/O Rules Section||I/O Rules Details"]
  if { -1 == $panel_id } {
    close $fh
    file delete Fitter__I_O_Rules_Section__I_O_Rules_Details.csv
    return -1
  }

  set AStatus_index [get_report_panel_column_index -id $panel_id "Status"]
  set AID_index [get_report_panel_column_index -id $panel_id "ID"]
  set ACategory_index [get_report_panel_column_index -id $panel_id "Category"]
  set ARule_Description_index [get_report_panel_column_index -id $panel_id "Rule Description"]
  set ASeverity_index [get_report_panel_column_index -id $panel_id "Severity"]
  set AInformation_index [get_report_panel_column_index -id $panel_id "Information"]
  set AArea_index [get_report_panel_column_index -id $panel_id "Area"]
  set AExtra_Information_index [get_report_panel_column_index -id $panel_id "Extra Information"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AStatus_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AID_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ACategory_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARule_Description_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASeverity_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AInformation_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AArea_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AExtra_Information_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Fitter__I_O_Rules_Section__I_O_Rules_Matrix { } {
  puts "Create report : Fitter||I/O Rules Section||I/O Rules Matrix"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Fitter__I_O_Rules_Section__I_O_Rules_Matrix.csv w]
  set panel_id [get_report_panel_id "Fitter||I/O Rules Section||I/O Rules Matrix"]
  if { -1 == $panel_id } {
    close $fh
    file delete Fitter__I_O_Rules_Section__I_O_Rules_Matrix.csv
    return -1
  }

  set APin_Rules_index [get_report_panel_column_index -id $panel_id "Pin/Rules"]
  set AIO_000001_index [get_report_panel_column_index -id $panel_id "IO_000001"]
  set AIO_000002_index [get_report_panel_column_index -id $panel_id "IO_000002"]
  set AIO_000003_index [get_report_panel_column_index -id $panel_id "IO_000003"]
  set AIO_000004_index [get_report_panel_column_index -id $panel_id "IO_000004"]
  set AIO_000005_index [get_report_panel_column_index -id $panel_id "IO_000005"]
  set AIO_000006_index [get_report_panel_column_index -id $panel_id "IO_000006"]
  set AIO_000007_index [get_report_panel_column_index -id $panel_id "IO_000007"]
  set AIO_000008_index [get_report_panel_column_index -id $panel_id "IO_000008"]
  set AIO_000009_index [get_report_panel_column_index -id $panel_id "IO_000009"]
  set AIO_000010_index [get_report_panel_column_index -id $panel_id "IO_000010"]
  set AIO_000011_index [get_report_panel_column_index -id $panel_id "IO_000011"]
  set AIO_000012_index [get_report_panel_column_index -id $panel_id "IO_000012"]
  set AIO_000013_index [get_report_panel_column_index -id $panel_id "IO_000013"]
  set AIO_000014_index [get_report_panel_column_index -id $panel_id "IO_000014"]
  set AIO_000015_index [get_report_panel_column_index -id $panel_id "IO_000015"]
  set AIO_000018_index [get_report_panel_column_index -id $panel_id "IO_000018"]
  set AIO_000019_index [get_report_panel_column_index -id $panel_id "IO_000019"]
  set AIO_000020_index [get_report_panel_column_index -id $panel_id "IO_000020"]
  set AIO_000021_index [get_report_panel_column_index -id $panel_id "IO_000021"]
  set AIO_000022_index [get_report_panel_column_index -id $panel_id "IO_000022"]
  set AIO_000023_index [get_report_panel_column_index -id $panel_id "IO_000023"]
  set AIO_000024_index [get_report_panel_column_index -id $panel_id "IO_000024"]
  set AIO_000026_index [get_report_panel_column_index -id $panel_id "IO_000026"]
  set AIO_000027_index [get_report_panel_column_index -id $panel_id "IO_000027"]
  set AIO_000045_index [get_report_panel_column_index -id $panel_id "IO_000045"]
  set AIO_000046_index [get_report_panel_column_index -id $panel_id "IO_000046"]
  set AIO_000047_index [get_report_panel_column_index -id $panel_id "IO_000047"]
  set AIO_000034_index [get_report_panel_column_index -id $panel_id "IO_000034"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $APin_Rules_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AIO_000001_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AIO_000002_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AIO_000003_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AIO_000004_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AIO_000005_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AIO_000006_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AIO_000007_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AIO_000008_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AIO_000009_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AIO_000010_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AIO_000011_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AIO_000012_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AIO_000013_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AIO_000014_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AIO_000015_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AIO_000018_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AIO_000019_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AIO_000020_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AIO_000021_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AIO_000022_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AIO_000023_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AIO_000024_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AIO_000026_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AIO_000027_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AIO_000045_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AIO_000046_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AIO_000047_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AIO_000034_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Fitter__I_O_Rules_Section__I_O_Rules_Summary { } {
  puts "Create report : Fitter||I/O Rules Section||I/O Rules Summary"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Fitter__I_O_Rules_Section__I_O_Rules_Summary.csv w]
  set panel_id [get_report_panel_id "Fitter||I/O Rules Section||I/O Rules Summary"]
  if { -1 == $panel_id } {
    close $fh
    file delete Fitter__I_O_Rules_Section__I_O_Rules_Summary.csv
    return -1
  }

  set AI_O_Rules_Statistic_index [get_report_panel_column_index -id $panel_id "I/O Rules Statistic"]
  set ATotal_index [get_report_panel_column_index -id $panel_id "Total"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AI_O_Rules_Statistic_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ATotal_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Fitter__Ignored_Assignments { } {
  puts "Create report : Fitter||Ignored Assignments"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Fitter__Ignored_Assignments.csv w]
  set panel_id [get_report_panel_id "Fitter||Ignored Assignments"]
  if { -1 == $panel_id } {
    close $fh
    file delete Fitter__Ignored_Assignments.csv
    return -1
  }

  set AName_index [get_report_panel_column_index -id $panel_id "Name"]
  set AIgnored_Entity_index [get_report_panel_column_index -id $panel_id "Ignored Entity"]
  set AIgnored_From_index [get_report_panel_column_index -id $panel_id "Ignored From"]
  set AIgnored_To_index [get_report_panel_column_index -id $panel_id "Ignored To"]
  set AIgnored_Value_index [get_report_panel_column_index -id $panel_id "Ignored Value"]
  set AIgnored_Source_index [get_report_panel_column_index -id $panel_id "Ignored Source"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AName_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AIgnored_Entity_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AIgnored_From_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AIgnored_To_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AIgnored_Value_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AIgnored_Source_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Fitter__Operating_Settings_and_Conditions { } {
  puts "Create report : Fitter||Operating Settings and Conditions"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Fitter__Operating_Settings_and_Conditions.csv w]
  set panel_id [get_report_panel_id "Fitter||Operating Settings and Conditions"]
  if { -1 == $panel_id } {
    close $fh
    file delete Fitter__Operating_Settings_and_Conditions.csv
    return -1
  }

  set ASetting_index [get_report_panel_column_index -id $panel_id "Setting"]
  set AValue_index [get_report_panel_column_index -id $panel_id "Value"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASetting_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AValue_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Fitter__Parallel_Compilation { } {
  puts "Create report : Fitter||Parallel Compilation"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Fitter__Parallel_Compilation.csv w]
  set panel_id [get_report_panel_id "Fitter||Parallel Compilation"]
  if { -1 == $panel_id } {
    close $fh
    file delete Fitter__Parallel_Compilation.csv
    return -1
  }

  set AProcessors_index [get_report_panel_column_index -id $panel_id "Processors"]
  set ANumber_index [get_report_panel_column_index -id $panel_id "Number"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AProcessors_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ANumber_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Fitter__Resource_Section__All_Package_Pins { } {
  puts "Create report : Fitter||Resource Section||All Package Pins"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Fitter__Resource_Section__All_Package_Pins.csv w]
  set panel_id [get_report_panel_id "Fitter||Resource Section||All Package Pins"]
  if { -1 == $panel_id } {
    close $fh
    file delete Fitter__Resource_Section__All_Package_Pins.csv
    return -1
  }

  set ALocation_index [get_report_panel_column_index -id $panel_id "Location"]
  set APad_Number_index [get_report_panel_column_index -id $panel_id "Pad Number"]
  set AI_O_Bank_index [get_report_panel_column_index -id $panel_id "I/O Bank"]
  set APin_Name_Usage_index [get_report_panel_column_index -id $panel_id "Pin Name/Usage"]
  set ADir__index [get_report_panel_column_index -id $panel_id "Dir."]
  set AI_O_Standard_index [get_report_panel_column_index -id $panel_id "I/O Standard"]
  set AVoltage_index [get_report_panel_column_index -id $panel_id "Voltage"]
  set AI_O_Type_index [get_report_panel_column_index -id $panel_id "I/O Type"]
  set AUser_Assignment_index [get_report_panel_column_index -id $panel_id "User Assignment"]
  set ABus_Hold_index [get_report_panel_column_index -id $panel_id "Bus Hold"]
  set AWeak_Pull_Up_index [get_report_panel_column_index -id $panel_id "Weak Pull Up"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ALocation_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $APad_Number_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AI_O_Bank_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $APin_Name_Usage_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ADir__index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AI_O_Standard_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AVoltage_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AI_O_Type_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AUser_Assignment_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ABus_Hold_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AWeak_Pull_Up_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Fitter__Resource_Section__Bidir_Pins { } {
  puts "Create report : Fitter||Resource Section||Bidir Pins"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Fitter__Resource_Section__Bidir_Pins.csv w]
  set panel_id [get_report_panel_id "Fitter||Resource Section||Bidir Pins"]
  if { -1 == $panel_id } {
    close $fh
    file delete Fitter__Resource_Section__Bidir_Pins.csv
    return -1
  }

  set AName_index [get_report_panel_column_index -id $panel_id "Name"]
  set APin_#_index [get_report_panel_column_index -id $panel_id "Pin #"]
  set AI_O_Bank_index [get_report_panel_column_index -id $panel_id "I/O Bank"]
  set AX_coordinate_index [get_report_panel_column_index -id $panel_id "X coordinate"]
  set AY_coordinate_index [get_report_panel_column_index -id $panel_id "Y coordinate"]
  set AZ_coordinate_index [get_report_panel_column_index -id $panel_id "Z coordinate"]
  set ACombinational_Fan_Out_index [get_report_panel_column_index -id $panel_id "Combinational Fan-Out"]
  set ARegistered_Fan_Out_index [get_report_panel_column_index -id $panel_id "Registered Fan-Out"]
  set AGlobal_index [get_report_panel_column_index -id $panel_id "Global"]
  set AOutput_Register_index [get_report_panel_column_index -id $panel_id "Output Register"]
  set ASlew_Rate_index [get_report_panel_column_index -id $panel_id "Slew Rate"]
  set AOpen_Drain_index [get_report_panel_column_index -id $panel_id "Open Drain"]
  set ABus_Hold_index [get_report_panel_column_index -id $panel_id "Bus Hold"]
  set AWeak_Pull_Up_index [get_report_panel_column_index -id $panel_id "Weak Pull Up"]
  set AI_O_Standard_index [get_report_panel_column_index -id $panel_id "I/O Standard"]
  set ACurrent_Strength_index [get_report_panel_column_index -id $panel_id "Current Strength"]
  set AInput_Termination_index [get_report_panel_column_index -id $panel_id "Input Termination"]
  set AOutput_Termination_index [get_report_panel_column_index -id $panel_id "Output Termination"]
  set ATermination_Control_Block_index [get_report_panel_column_index -id $panel_id "Termination Control Block"]
  set AOutput_Buffer_Delay_index [get_report_panel_column_index -id $panel_id "Output Buffer Delay"]
  set AOutput_Buffer_Delay_Control_index [get_report_panel_column_index -id $panel_id "Output Buffer Delay Control"]
  set ALocation_assigned_by_index [get_report_panel_column_index -id $panel_id "Location assigned by"]
  set ALoad_index [get_report_panel_column_index -id $panel_id "Load"]
  set AOutput_Enable_Source_index [get_report_panel_column_index -id $panel_id "Output Enable Source"]
  set AOutput_Enable_Group_index [get_report_panel_column_index -id $panel_id "Output Enable Group"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AName_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $APin_#_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AI_O_Bank_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AX_coordinate_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AY_coordinate_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AZ_coordinate_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ACombinational_Fan_Out_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARegistered_Fan_Out_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AGlobal_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AOutput_Register_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASlew_Rate_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AOpen_Drain_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ABus_Hold_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AWeak_Pull_Up_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AI_O_Standard_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ACurrent_Strength_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AInput_Termination_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AOutput_Termination_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ATermination_Control_Block_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AOutput_Buffer_Delay_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AOutput_Buffer_Delay_Control_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ALocation_assigned_by_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ALoad_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AOutput_Enable_Source_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AOutput_Enable_Group_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Fitter__Resource_Section__Control_Signals { } {
  puts "Create report : Fitter||Resource Section||Control Signals"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Fitter__Resource_Section__Control_Signals.csv w]
  set panel_id [get_report_panel_id "Fitter||Resource Section||Control Signals"]
  if { -1 == $panel_id } {
    close $fh
    file delete Fitter__Resource_Section__Control_Signals.csv
    return -1
  }

  set AName_index [get_report_panel_column_index -id $panel_id "Name"]
  set ALocation_index [get_report_panel_column_index -id $panel_id "Location"]
  set AFan_Out_index [get_report_panel_column_index -id $panel_id "Fan-Out"]
  set AUsage_index [get_report_panel_column_index -id $panel_id "Usage"]
  set AGlobal_index [get_report_panel_column_index -id $panel_id "Global"]
  set AGlobal_Resource_Used_index [get_report_panel_column_index -id $panel_id "Global Resource Used"]
  set AGlobal_Line_Name_index [get_report_panel_column_index -id $panel_id "Global Line Name"]
  set AEnable_Signal_Source_Name_index [get_report_panel_column_index -id $panel_id "Enable Signal Source Name"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AName_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ALocation_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFan_Out_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AUsage_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AGlobal_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AGlobal_Resource_Used_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AGlobal_Line_Name_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AEnable_Signal_Source_Name_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Fitter__Resource_Section__Delay_Chain_Summary { } {
  puts "Create report : Fitter||Resource Section||Delay Chain Summary"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Fitter__Resource_Section__Delay_Chain_Summary.csv w]
  set panel_id [get_report_panel_id "Fitter||Resource Section||Delay Chain Summary"]
  if { -1 == $panel_id } {
    close $fh
    file delete Fitter__Resource_Section__Delay_Chain_Summary.csv
    return -1
  }

  set AName_index [get_report_panel_column_index -id $panel_id "Name"]
  set APin_Type_index [get_report_panel_column_index -id $panel_id "Pin Type"]
  set AD1_index [get_report_panel_column_index -id $panel_id "D1"]
  set AD2_index [get_report_panel_column_index -id $panel_id "D2"]
  set AD3_0_index [get_report_panel_column_index -id $panel_id "D3_0"]
  set AD3_1_index [get_report_panel_column_index -id $panel_id "D3_1"]
  set AT4__DDIO_MUX__index [get_report_panel_column_index -id $panel_id "T4 (DDIO_MUX)"]
  set AD4_index [get_report_panel_column_index -id $panel_id "D4"]
  set AT8_0__DQS__index [get_report_panel_column_index -id $panel_id "T8_0 (DQS)"]
  set AT8_1__NDQS__index [get_report_panel_column_index -id $panel_id "T8_1 (NDQS)"]
  set AD5_index [get_report_panel_column_index -id $panel_id "D5"]
  set AD6_index [get_report_panel_column_index -id $panel_id "D6"]
  set AD6_OE_index [get_report_panel_column_index -id $panel_id "D6 OE"]
  set AD5_OCT_index [get_report_panel_column_index -id $panel_id "D5 OCT"]
  set AD6_OCT_index [get_report_panel_column_index -id $panel_id "D6 OCT"]
  set AT11__Postamble__index [get_report_panel_column_index -id $panel_id "T11 (Postamble)"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AName_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $APin_Type_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AD1_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AD2_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AD3_0_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AD3_1_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AT4__DDIO_MUX__index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AD4_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AT8_0__DQS__index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AT8_1__NDQS__index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AD5_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AD6_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AD6_OE_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AD5_OCT_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AD6_OCT_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AT11__Postamble__index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Fitter__Resource_Section__Fitter_Partition_Statistics { } {
  puts "Create report : Fitter||Resource Section||Fitter Partition Statistics"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Fitter__Resource_Section__Fitter_Partition_Statistics.csv w]
  set panel_id [get_report_panel_id "Fitter||Resource Section||Fitter Partition Statistics"]
  if { -1 == $panel_id } {
    close $fh
    file delete Fitter__Resource_Section__Fitter_Partition_Statistics.csv
    return -1
  }

  set AStatistic_index [get_report_panel_column_index -id $panel_id "Statistic"]
  set ATop_index [get_report_panel_column_index -id $panel_id "Top"]
  set Ahard_block_auto_generated_inst_index [get_report_panel_column_index -id $panel_id "hard_block:auto_generated_inst"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AStatistic_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ATop_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $Ahard_block_auto_generated_inst_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Fitter__Resource_Section__Fitter_RAM_Summary { } {
  puts "Create report : Fitter||Resource Section||Fitter RAM Summary"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Fitter__Resource_Section__Fitter_RAM_Summary.csv w]
  set panel_id [get_report_panel_id "Fitter||Resource Section||Fitter RAM Summary"]
  if { -1 == $panel_id } {
    close $fh
    file delete Fitter__Resource_Section__Fitter_RAM_Summary.csv
    return -1
  }

  set AName_index [get_report_panel_column_index -id $panel_id "Name"]
  set AType_index [get_report_panel_column_index -id $panel_id "Type"]
  set AMode_index [get_report_panel_column_index -id $panel_id "Mode"]
  set AClock_Mode_index [get_report_panel_column_index -id $panel_id "Clock Mode"]
  set APort_A_Depth_index [get_report_panel_column_index -id $panel_id "Port A Depth"]
  set APort_A_Width_index [get_report_panel_column_index -id $panel_id "Port A Width"]
  set APort_B_Depth_index [get_report_panel_column_index -id $panel_id "Port B Depth"]
  set APort_B_Width_index [get_report_panel_column_index -id $panel_id "Port B Width"]
  set APort_A_Input_Registers_index [get_report_panel_column_index -id $panel_id "Port A Input Registers"]
  set APort_A_Output_Registers_index [get_report_panel_column_index -id $panel_id "Port A Output Registers"]
  set APort_B_Input_Registers_index [get_report_panel_column_index -id $panel_id "Port B Input Registers"]
  set APort_B_Output_Registers_index [get_report_panel_column_index -id $panel_id "Port B Output Registers"]
  set ASize_index [get_report_panel_column_index -id $panel_id "Size"]
  set AImplementation_Port_A_Depth_index [get_report_panel_column_index -id $panel_id "Implementation Port A Depth"]
  set AImplementation_Port_A_Width_index [get_report_panel_column_index -id $panel_id "Implementation Port A Width"]
  set AImplementation_Port_B_Depth_index [get_report_panel_column_index -id $panel_id "Implementation Port B Depth"]
  set AImplementation_Port_B_Width_index [get_report_panel_column_index -id $panel_id "Implementation Port B Width"]
  set AImplementation_Bits_index [get_report_panel_column_index -id $panel_id "Implementation Bits"]
  set AM20K_blocks_index [get_report_panel_column_index -id $panel_id "M20K blocks"]
  set AMLAB_cells_index [get_report_panel_column_index -id $panel_id "MLAB cells"]
  set AMIF_index [get_report_panel_column_index -id $panel_id "MIF"]
  set ALocation_index [get_report_panel_column_index -id $panel_id "Location"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AName_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AType_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AMode_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Mode_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $APort_A_Depth_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $APort_A_Width_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $APort_B_Depth_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $APort_B_Width_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $APort_A_Input_Registers_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $APort_A_Output_Registers_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $APort_B_Input_Registers_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $APort_B_Output_Registers_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASize_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AImplementation_Port_A_Depth_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AImplementation_Port_A_Width_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AImplementation_Port_B_Depth_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AImplementation_Port_B_Width_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AImplementation_Bits_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AM20K_blocks_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AMLAB_cells_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AMIF_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ALocation_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Fitter__Resource_Section__Fitter_Resource_Usage_Summary { } {
  puts "Create report : Fitter||Resource Section||Fitter Resource Usage Summary"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Fitter__Resource_Section__Fitter_Resource_Usage_Summary.csv w]
  set panel_id [get_report_panel_id "Fitter||Resource Section||Fitter Resource Usage Summary"]
  if { -1 == $panel_id } {
    close $fh
    file delete Fitter__Resource_Section__Fitter_Resource_Usage_Summary.csv
    return -1
  }

  set AResource_index [get_report_panel_column_index -id $panel_id "Resource"]
  set AUsage_index [get_report_panel_column_index -id $panel_id "Usage"]
  set A%_index [get_report_panel_column_index -id $panel_id "%"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AResource_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AUsage_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $A%_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Fitter__Resource_Section__Fitter_Resource_Utilization_by_Entity { } {
  puts "Create report : Fitter||Resource Section||Fitter Resource Utilization by Entity"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Fitter__Resource_Section__Fitter_Resource_Utilization_by_Entity.csv w]
  set panel_id [get_report_panel_id "Fitter||Resource Section||Fitter Resource Utilization by Entity"]
  if { -1 == $panel_id } {
    close $fh
    file delete Fitter__Resource_Section__Fitter_Resource_Utilization_by_Entity.csv
    return -1
  }

  set ACompilation_Hierarchy_Node_index [get_report_panel_column_index -id $panel_id "Compilation Hierarchy Node"]
  set AALMs_needed___A_B_C__index [get_report_panel_column_index -id $panel_id "ALMs needed \[=A-B+C\]"]
  set A_A__ALMs_used_in_final_placement_index [get_report_panel_column_index -id $panel_id "\[A\] ALMs used in final placement"]
  set A_B__Estimate_of_ALMs_recoverable_by_dense_packing_index [get_report_panel_column_index -id $panel_id "\[B\] Estimate of ALMs recoverable by dense packing"]
  set A_C__Estimate_of_ALMs_unavailable_index [get_report_panel_column_index -id $panel_id "\[C\] Estimate of ALMs unavailable"]
  set AALMs_used_for_memory_index [get_report_panel_column_index -id $panel_id "ALMs used for memory"]
  set ACombinational_ALUTs_index [get_report_panel_column_index -id $panel_id "Combinational ALUTs"]
  set ADedicated_Logic_Registers_index [get_report_panel_column_index -id $panel_id "Dedicated Logic Registers"]
  set AI_O_Registers_index [get_report_panel_column_index -id $panel_id "I/O Registers"]
  set ABlock_Memory_Bits_index [get_report_panel_column_index -id $panel_id "Block Memory Bits"]
  set AM20Ks_index [get_report_panel_column_index -id $panel_id "M20Ks"]
  set ADSP_Blocks_index [get_report_panel_column_index -id $panel_id "DSP Blocks"]
  set APins_index [get_report_panel_column_index -id $panel_id "Pins"]
  set AVirtual_Pins_index [get_report_panel_column_index -id $panel_id "Virtual Pins"]
  set AFull_Hierarchy_Name_index [get_report_panel_column_index -id $panel_id "Full Hierarchy Name"]
  set ALibrary_Name_index [get_report_panel_column_index -id $panel_id "Library Name"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ACompilation_Hierarchy_Node_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AALMs_needed___A_B_C__index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $A_A__ALMs_used_in_final_placement_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $A_B__Estimate_of_ALMs_recoverable_by_dense_packing_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $A_C__Estimate_of_ALMs_unavailable_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AALMs_used_for_memory_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ACombinational_ALUTs_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ADedicated_Logic_Registers_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AI_O_Registers_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ABlock_Memory_Bits_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AM20Ks_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ADSP_Blocks_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $APins_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AVirtual_Pins_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFull_Hierarchy_Name_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ALibrary_Name_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Fitter__Resource_Section__GXB_Reports__Optimized_GXB_Elements { } {
  puts "Create report : Fitter||Resource Section||GXB Reports||Optimized GXB Elements"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Fitter__Resource_Section__GXB_Reports__Optimized_GXB_Elements.csv w]
  set panel_id [get_report_panel_id "Fitter||Resource Section||GXB Reports||Optimized GXB Elements"]
  if { -1 == $panel_id } {
    close $fh
    file delete Fitter__Resource_Section__GXB_Reports__Optimized_GXB_Elements.csv
    return -1
  }

  set APreserved_Component_index [get_report_panel_column_index -id $panel_id "Preserved Component"]
  set ARemoved_Component_index [get_report_panel_column_index -id $panel_id "Removed Component"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $APreserved_Component_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARemoved_Component_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Fitter__Resource_Section__GXB_Reports__Receiver_Channel { } {
  puts "Create report : Fitter||Resource Section||GXB Reports||Receiver Channel"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Fitter__Resource_Section__GXB_Reports__Receiver_Channel.csv w]
  set panel_id [get_report_panel_id "Fitter||Resource Section||GXB Reports||Receiver Channel"]
  if { -1 == $panel_id } {
    close $fh
    file delete Fitter__Resource_Section__GXB_Reports__Receiver_Channel.csv
    return -1
  }

  set AName_index [get_report_panel_column_index -id $panel_id "Name"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AName_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Fitter__Resource_Section__GXB_Reports__Transceiver_Reconfiguration_Report { } {
  puts "Create report : Fitter||Resource Section||GXB Reports||Transceiver Reconfiguration Report"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Fitter__Resource_Section__GXB_Reports__Transceiver_Reconfiguration_Report.csv w]
  set panel_id [get_report_panel_id "Fitter||Resource Section||GXB Reports||Transceiver Reconfiguration Report"]
  if { -1 == $panel_id } {
    close $fh
    file delete Fitter__Resource_Section__GXB_Reports__Transceiver_Reconfiguration_Report.csv
    return -1
  }

  set AComponent_index [get_report_panel_column_index -id $panel_id "Component"]
  set AType_index [get_report_panel_column_index -id $panel_id "Type"]
  set AInstance_Name_index [get_report_panel_column_index -id $panel_id "Instance Name"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AComponent_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AType_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AInstance_Name_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Fitter__Resource_Section__GXB_Reports__Transmitter_Channel { } {
  puts "Create report : Fitter||Resource Section||GXB Reports||Transmitter Channel"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Fitter__Resource_Section__GXB_Reports__Transmitter_Channel.csv w]
  set panel_id [get_report_panel_id "Fitter||Resource Section||GXB Reports||Transmitter Channel"]
  if { -1 == $panel_id } {
    close $fh
    file delete Fitter__Resource_Section__GXB_Reports__Transmitter_Channel.csv
    return -1
  }

  set AName_index [get_report_panel_column_index -id $panel_id "Name"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AName_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Fitter__Resource_Section__GXB_Reports__Transmitter_PLL { } {
  puts "Create report : Fitter||Resource Section||GXB Reports||Transmitter PLL"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Fitter__Resource_Section__GXB_Reports__Transmitter_PLL.csv w]
  set panel_id [get_report_panel_id "Fitter||Resource Section||GXB Reports||Transmitter PLL"]
  if { -1 == $panel_id } {
    close $fh
    file delete Fitter__Resource_Section__GXB_Reports__Transmitter_PLL.csv
    return -1
  }

  set AName_index [get_report_panel_column_index -id $panel_id "Name"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AName_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Fitter__Resource_Section__Global___Other_Fast_Signals { } {
  puts "Create report : Fitter||Resource Section||Global & Other Fast Signals"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Fitter__Resource_Section__Global___Other_Fast_Signals.csv w]
  set panel_id [get_report_panel_id "Fitter||Resource Section||Global & Other Fast Signals"]
  if { -1 == $panel_id } {
    close $fh
    file delete Fitter__Resource_Section__Global___Other_Fast_Signals.csv
    return -1
  }

  set AName_index [get_report_panel_column_index -id $panel_id "Name"]
  set ALocation_index [get_report_panel_column_index -id $panel_id "Location"]
  set AFan_Out_index [get_report_panel_column_index -id $panel_id "Fan-Out"]
  set AGlobal_Resource_Used_index [get_report_panel_column_index -id $panel_id "Global Resource Used"]
  set AGlobal_Line_Name_index [get_report_panel_column_index -id $panel_id "Global Line Name"]
  set AEnable_Signal_Source_Name_index [get_report_panel_column_index -id $panel_id "Enable Signal Source Name"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AName_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ALocation_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFan_Out_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AGlobal_Resource_Used_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AGlobal_Line_Name_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AEnable_Signal_Source_Name_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Fitter__Resource_Section__I_O_Bank_Usage { } {
  puts "Create report : Fitter||Resource Section||I/O Bank Usage"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Fitter__Resource_Section__I_O_Bank_Usage.csv w]
  set panel_id [get_report_panel_id "Fitter||Resource Section||I/O Bank Usage"]
  if { -1 == $panel_id } {
    close $fh
    file delete Fitter__Resource_Section__I_O_Bank_Usage.csv
    return -1
  }

  set AI_O_Bank_index [get_report_panel_column_index -id $panel_id "I/O Bank"]
  set AUsage_index [get_report_panel_column_index -id $panel_id "Usage"]
  set AVCCIO_Voltage_index [get_report_panel_column_index -id $panel_id "VCCIO Voltage"]
  set AVREF_Voltage_index [get_report_panel_column_index -id $panel_id "VREF Voltage"]
  set AVCCPD_Voltage_index [get_report_panel_column_index -id $panel_id "VCCPD Voltage"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AI_O_Bank_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AUsage_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AVCCIO_Voltage_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AVREF_Voltage_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AVCCPD_Voltage_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Fitter__Resource_Section__Input_Pins { } {
  puts "Create report : Fitter||Resource Section||Input Pins"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Fitter__Resource_Section__Input_Pins.csv w]
  set panel_id [get_report_panel_id "Fitter||Resource Section||Input Pins"]
  if { -1 == $panel_id } {
    close $fh
    file delete Fitter__Resource_Section__Input_Pins.csv
    return -1
  }

  set AName_index [get_report_panel_column_index -id $panel_id "Name"]
  set APin_#_index [get_report_panel_column_index -id $panel_id "Pin #"]
  set AI_O_Bank_index [get_report_panel_column_index -id $panel_id "I/O Bank"]
  set AX_coordinate_index [get_report_panel_column_index -id $panel_id "X coordinate"]
  set AY_coordinate_index [get_report_panel_column_index -id $panel_id "Y coordinate"]
  set AZ_coordinate_index [get_report_panel_column_index -id $panel_id "Z coordinate"]
  set ACombinational_Fan_Out_index [get_report_panel_column_index -id $panel_id "Combinational Fan-Out"]
  set ARegistered_Fan_Out_index [get_report_panel_column_index -id $panel_id "Registered Fan-Out"]
  set AGlobal_index [get_report_panel_column_index -id $panel_id "Global"]
  set ABus_Hold_index [get_report_panel_column_index -id $panel_id "Bus Hold"]
  set AWeak_Pull_Up_index [get_report_panel_column_index -id $panel_id "Weak Pull Up"]
  set AI_O_Standard_index [get_report_panel_column_index -id $panel_id "I/O Standard"]
  set ATermination_index [get_report_panel_column_index -id $panel_id "Termination"]
  set ATermination_Control_Block_index [get_report_panel_column_index -id $panel_id "Termination Control Block"]
  set ALocation_assigned_by_index [get_report_panel_column_index -id $panel_id "Location assigned by"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AName_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $APin_#_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AI_O_Bank_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AX_coordinate_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AY_coordinate_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AZ_coordinate_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ACombinational_Fan_Out_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARegistered_Fan_Out_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AGlobal_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ABus_Hold_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AWeak_Pull_Up_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AI_O_Standard_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ATermination_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ATermination_Control_Block_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ALocation_assigned_by_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Fitter__Resource_Section__Logic_and_Routing_Section__Interconnect_Usage_Summary { } {
  puts "Create report : Fitter||Resource Section||Logic and Routing Section||Interconnect Usage Summary"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Fitter__Resource_Section__Logic_and_Routing_Section__Interconnect_Usage_Summary.csv w]
  set panel_id [get_report_panel_id "Fitter||Resource Section||Logic and Routing Section||Interconnect Usage Summary"]
  if { -1 == $panel_id } {
    close $fh
    file delete Fitter__Resource_Section__Logic_and_Routing_Section__Interconnect_Usage_Summary.csv
    return -1
  }

  set AInterconnect_Resource_Type_index [get_report_panel_column_index -id $panel_id "Interconnect Resource Type"]
  set AUsage_index [get_report_panel_column_index -id $panel_id "Usage"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AInterconnect_Resource_Type_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AUsage_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Fitter__Resource_Section__Logic_and_Routing_Section__Other_Routing_Usage_Summary { } {
  puts "Create report : Fitter||Resource Section||Logic and Routing Section||Other Routing Usage Summary"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Fitter__Resource_Section__Logic_and_Routing_Section__Other_Routing_Usage_Summary.csv w]
  set panel_id [get_report_panel_id "Fitter||Resource Section||Logic and Routing Section||Other Routing Usage Summary"]
  if { -1 == $panel_id } {
    close $fh
    file delete Fitter__Resource_Section__Logic_and_Routing_Section__Other_Routing_Usage_Summary.csv
    return -1
  }

  set AOther_Routing_Resource_Type_index [get_report_panel_column_index -id $panel_id "Other Routing Resource Type"]
  set AUsage_index [get_report_panel_column_index -id $panel_id "Usage"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AOther_Routing_Resource_Type_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AUsage_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Fitter__Resource_Section__Non_Global_High_Fan_Out_Signals { } {
  puts "Create report : Fitter||Resource Section||Non-Global High Fan-Out Signals"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Fitter__Resource_Section__Non_Global_High_Fan_Out_Signals.csv w]
  set panel_id [get_report_panel_id "Fitter||Resource Section||Non-Global High Fan-Out Signals"]
  if { -1 == $panel_id } {
    close $fh
    file delete Fitter__Resource_Section__Non_Global_High_Fan_Out_Signals.csv
    return -1
  }

  set AName_index [get_report_panel_column_index -id $panel_id "Name"]
  set AFan_Out_index [get_report_panel_column_index -id $panel_id "Fan-Out"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AName_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFan_Out_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Fitter__Resource_Section__Output_Pins { } {
  puts "Create report : Fitter||Resource Section||Output Pins"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Fitter__Resource_Section__Output_Pins.csv w]
  set panel_id [get_report_panel_id "Fitter||Resource Section||Output Pins"]
  if { -1 == $panel_id } {
    close $fh
    file delete Fitter__Resource_Section__Output_Pins.csv
    return -1
  }

  set AName_index [get_report_panel_column_index -id $panel_id "Name"]
  set APin_#_index [get_report_panel_column_index -id $panel_id "Pin #"]
  set AI_O_Bank_index [get_report_panel_column_index -id $panel_id "I/O Bank"]
  set AX_coordinate_index [get_report_panel_column_index -id $panel_id "X coordinate"]
  set AY_coordinate_index [get_report_panel_column_index -id $panel_id "Y coordinate"]
  set AZ_coordinate_index [get_report_panel_column_index -id $panel_id "Z coordinate"]
  set AOutput_Register_index [get_report_panel_column_index -id $panel_id "Output Register"]
  set ASlew_Rate_index [get_report_panel_column_index -id $panel_id "Slew Rate"]
  set AOpen_Drain_index [get_report_panel_column_index -id $panel_id "Open Drain"]
  set ATRI_Primitive_index [get_report_panel_column_index -id $panel_id "TRI Primitive"]
  set ABus_Hold_index [get_report_panel_column_index -id $panel_id "Bus Hold"]
  set AWeak_Pull_Up_index [get_report_panel_column_index -id $panel_id "Weak Pull Up"]
  set AI_O_Standard_index [get_report_panel_column_index -id $panel_id "I/O Standard"]
  set ACurrent_Strength_index [get_report_panel_column_index -id $panel_id "Current Strength"]
  set ATermination_index [get_report_panel_column_index -id $panel_id "Termination"]
  set ATermination_Control_Block_index [get_report_panel_column_index -id $panel_id "Termination Control Block"]
  set AOutput_Buffer_Pre_emphasis_index [get_report_panel_column_index -id $panel_id "Output Buffer Pre-emphasis"]
  set AVoltage_Output_Differential_index [get_report_panel_column_index -id $panel_id "Voltage Output Differential"]
  set AOutput_Buffer_Delay_index [get_report_panel_column_index -id $panel_id "Output Buffer Delay"]
  set AOutput_Buffer_Delay_Control_index [get_report_panel_column_index -id $panel_id "Output Buffer Delay Control"]
  set ALocation_assigned_by_index [get_report_panel_column_index -id $panel_id "Location assigned by"]
  set AOutput_Enable_Source_index [get_report_panel_column_index -id $panel_id "Output Enable Source"]
  set AOutput_Enable_Group_index [get_report_panel_column_index -id $panel_id "Output Enable Group"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AName_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $APin_#_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AI_O_Bank_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AX_coordinate_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AY_coordinate_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AZ_coordinate_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AOutput_Register_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASlew_Rate_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AOpen_Drain_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ATRI_Primitive_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ABus_Hold_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AWeak_Pull_Up_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AI_O_Standard_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ACurrent_Strength_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ATermination_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ATermination_Control_Block_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AOutput_Buffer_Pre_emphasis_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AVoltage_Output_Differential_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AOutput_Buffer_Delay_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AOutput_Buffer_Delay_Control_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ALocation_assigned_by_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AOutput_Enable_Source_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AOutput_Enable_Group_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Fitter__Resource_Section__PLL_Usage_Summary { } {
  puts "Create report : Fitter||Resource Section||PLL Usage Summary"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Fitter__Resource_Section__PLL_Usage_Summary.csv w]
  set panel_id [get_report_panel_id "Fitter||Resource Section||PLL Usage Summary"]
  if { -1 == $panel_id } {
    close $fh
    file delete Fitter__Resource_Section__PLL_Usage_Summary.csv
    return -1
  }


  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]

      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Fitter__Resource_Section__Pad_To_Core_Delay_Chain_Fanout { } {
  puts "Create report : Fitter||Resource Section||Pad To Core Delay Chain Fanout"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Fitter__Resource_Section__Pad_To_Core_Delay_Chain_Fanout.csv w]
  set panel_id [get_report_panel_id "Fitter||Resource Section||Pad To Core Delay Chain Fanout"]
  if { -1 == $panel_id } {
    close $fh
    file delete Fitter__Resource_Section__Pad_To_Core_Delay_Chain_Fanout.csv
    return -1
  }

  set ASource_Pin___Fanout_index [get_report_panel_column_index -id $panel_id "Source Pin / Fanout"]
  set APad_To_Core_Index_index [get_report_panel_column_index -id $panel_id "Pad To Core Index"]
  set ASetting_index [get_report_panel_column_index -id $panel_id "Setting"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASource_Pin___Fanout_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $APad_To_Core_Index_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASetting_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Flow_Elapsed_Time { } {
  puts "Create report : Flow Elapsed Time"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Flow_Elapsed_Time.csv w]
  set panel_id [get_report_panel_id "Flow Elapsed Time"]
  if { -1 == $panel_id } {
    close $fh
    file delete Flow_Elapsed_Time.csv
    return -1
  }

  set AModule_Name_index [get_report_panel_column_index -id $panel_id "Module Name"]
  set AElapsed_Time_index [get_report_panel_column_index -id $panel_id "Elapsed Time"]
  set AAverage_Processors_Used_index [get_report_panel_column_index -id $panel_id "Average Processors Used"]
  set APeak_Virtual_Memory_index [get_report_panel_column_index -id $panel_id "Peak Virtual Memory"]
  set ATotal_CPU_Time__on_all_processors__index [get_report_panel_column_index -id $panel_id "Total CPU Time (on all processors)"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AModule_Name_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AElapsed_Time_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AAverage_Processors_Used_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $APeak_Virtual_Memory_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ATotal_CPU_Time__on_all_processors__index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Flow_Non_Default_Global_Settings { } {
  puts "Create report : Flow Non-Default Global Settings"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Flow_Non_Default_Global_Settings.csv w]
  set panel_id [get_report_panel_id "Flow Non-Default Global Settings"]
  if { -1 == $panel_id } {
    close $fh
    file delete Flow_Non_Default_Global_Settings.csv
    return -1
  }

  set AAssignment_Name_index [get_report_panel_column_index -id $panel_id "Assignment Name"]
  set AValue_index [get_report_panel_column_index -id $panel_id "Value"]
  set ADefault_Value_index [get_report_panel_column_index -id $panel_id "Default Value"]
  set AEntity_Name_index [get_report_panel_column_index -id $panel_id "Entity Name"]
  set ASection_Id_index [get_report_panel_column_index -id $panel_id "Section Id"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AAssignment_Name_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AValue_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ADefault_Value_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AEntity_Name_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASection_Id_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Flow_OS_Summary { } {
  puts "Create report : Flow OS Summary"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Flow_OS_Summary.csv w]
  set panel_id [get_report_panel_id "Flow OS Summary"]
  if { -1 == $panel_id } {
    close $fh
    file delete Flow_OS_Summary.csv
    return -1
  }

  set AModule_Name_index [get_report_panel_column_index -id $panel_id "Module Name"]
  set AMachine_Hostname_index [get_report_panel_column_index -id $panel_id "Machine Hostname"]
  set AOS_Name_index [get_report_panel_column_index -id $panel_id "OS Name"]
  set AOS_Version_index [get_report_panel_column_index -id $panel_id "OS Version"]
  set AProcessor_type_index [get_report_panel_column_index -id $panel_id "Processor type"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AModule_Name_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AMachine_Hostname_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AOS_Name_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AOS_Version_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AProcessor_type_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Flow_Settings { } {
  puts "Create report : Flow Settings"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Flow_Settings.csv w]
  set panel_id [get_report_panel_id "Flow Settings"]
  if { -1 == $panel_id } {
    close $fh
    file delete Flow_Settings.csv
    return -1
  }

  set AOption_index [get_report_panel_column_index -id $panel_id "Option"]
  set ASetting_index [get_report_panel_column_index -id $panel_id "Setting"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AOption_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASetting_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Flow_Summary { } {
  puts "Create report : Flow Summary"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Flow_Summary.csv w]
  set panel_id [get_report_panel_id "Flow Summary"]
  if { -1 == $panel_id } {
    close $fh
    file delete Flow_Summary.csv
    return -1
  }

  set AFlow_Status_index [get_report_panel_column_index -id $panel_id "Flow Status"]
  set ASuccessful___Fri_May_24_08_56_47_2013_index [get_report_panel_column_index -id $panel_id "Successful - Fri May 24 08:56:47 2013"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFlow_Status_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASuccessful___Fri_May_24_08_56_47_2013_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Non_Default_Global_Settings { } {
  puts "Create report : Non-Default Global Settings"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Non_Default_Global_Settings.csv w]
  set panel_id [get_report_panel_id "Non-Default Global Settings"]
  if { -1 == $panel_id } {
    close $fh
    file delete Non_Default_Global_Settings.csv
    return -1
  }

  set AAssignment_index [get_report_panel_column_index -id $panel_id "Assignment"]
  set ADefault_Value_index [get_report_panel_column_index -id $panel_id "Default Value"]
  set ADesign_Value_index [get_report_panel_column_index -id $panel_id "Design Value"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AAssignment_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ADefault_Value_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ADesign_Value_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Restore_Archived_Project__Files_Not_Restored { } {
  puts "Create report : Restore Archived Project||Files Not Restored"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Restore_Archived_Project__Files_Not_Restored.csv w]
  set panel_id [get_report_panel_id "Restore Archived Project||Files Not Restored"]
  if { -1 == $panel_id } {
    close $fh
    file delete Restore_Archived_Project__Files_Not_Restored.csv
    return -1
  }

  set AFile_Name_index [get_report_panel_column_index -id $panel_id "File Name"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFile_Name_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Restore_Archived_Project__Files_Restored { } {
  puts "Create report : Restore Archived Project||Files Restored"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Restore_Archived_Project__Files_Restored.csv w]
  set panel_id [get_report_panel_id "Restore Archived Project||Files Restored"]
  if { -1 == $panel_id } {
    close $fh
    file delete Restore_Archived_Project__Files_Restored.csv
    return -1
  }

  set AFile_Name_index [get_report_panel_column_index -id $panel_id "File Name"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFile_Name_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc Restore_Archived_Project__Restore_Archived_Project_Summary { } {
  puts "Create report : Restore Archived Project||Restore Archived Project Summary"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/Restore_Archived_Project__Restore_Archived_Project_Summary.csv w]
  set panel_id [get_report_panel_id "Restore Archived Project||Restore Archived Project Summary"]
  if { -1 == $panel_id } {
    close $fh
    file delete Restore_Archived_Project__Restore_Archived_Project_Summary.csv
    return -1
  }

  set ARestore_Archived_Project_Status_index [get_report_panel_column_index -id $panel_id "Restore Archived Project Status"]
  set ASuccessful___Fri_May_24_08_56_47_2013_index [get_report_panel_column_index -id $panel_id "Successful - Fri May 24 08:56:47 2013"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARestore_Archived_Project_Status_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASuccessful___Fri_May_24_08_56_47_2013_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer_GUI__Advanced_I_O_Timing__Board_Trace_Model_Assignments { } {
  puts "Create report : TimeQuest Timing Analyzer GUI||Advanced I/O Timing||Board Trace Model Assignments"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer_GUI__Advanced_I_O_Timing__Board_Trace_Model_Assignments.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer GUI||Advanced I/O Timing||Board Trace Model Assignments"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer_GUI__Advanced_I_O_Timing__Board_Trace_Model_Assignments.csv
    return -1
  }

  set APin_index [get_report_panel_column_index -id $panel_id "Pin"]
  set AI_O_Standard_index [get_report_panel_column_index -id $panel_id "I/O Standard"]
  set ANear_Tline_Length_index [get_report_panel_column_index -id $panel_id "Near Tline Length"]
  set ANear_Tline_L_per_Length_index [get_report_panel_column_index -id $panel_id "Near Tline L per Length"]
  set ANear_Tline_C_per_Length_index [get_report_panel_column_index -id $panel_id "Near Tline C per Length"]
  set ANear_Series_R_index [get_report_panel_column_index -id $panel_id "Near Series R"]
  set ANear_Differential_R_index [get_report_panel_column_index -id $panel_id "Near Differential R"]
  set ANear_Pull_up_R_index [get_report_panel_column_index -id $panel_id "Near Pull-up R"]
  set ANear_Pull_down_R_index [get_report_panel_column_index -id $panel_id "Near Pull-down R"]
  set ANear_C_index [get_report_panel_column_index -id $panel_id "Near C"]
  set AFar_Tline_Length_index [get_report_panel_column_index -id $panel_id "Far Tline Length"]
  set AFar_Tline_L_per_Length_index [get_report_panel_column_index -id $panel_id "Far Tline L per Length"]
  set AFar_Tline_C_per_Length_index [get_report_panel_column_index -id $panel_id "Far Tline C per Length"]
  set AFar_Series_R_index [get_report_panel_column_index -id $panel_id "Far Series R"]
  set AFar_Pull_up_R_index [get_report_panel_column_index -id $panel_id "Far Pull-up R"]
  set AFar_Pull_down_R_index [get_report_panel_column_index -id $panel_id "Far Pull-down R"]
  set AFar_C_index [get_report_panel_column_index -id $panel_id "Far C"]
  set ATermination_Voltage_index [get_report_panel_column_index -id $panel_id "Termination Voltage"]
  set AFar_Differential_R_index [get_report_panel_column_index -id $panel_id "Far Differential R"]
  set AEBD_File_Name_index [get_report_panel_column_index -id $panel_id "EBD File Name"]
  set AEBD_Signal_Name_index [get_report_panel_column_index -id $panel_id "EBD Signal Name"]
  set AEBD_Far_end_index [get_report_panel_column_index -id $panel_id "EBD Far-end"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $APin_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AI_O_Standard_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ANear_Tline_Length_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ANear_Tline_L_per_Length_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ANear_Tline_C_per_Length_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ANear_Series_R_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ANear_Differential_R_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ANear_Pull_up_R_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ANear_Pull_down_R_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ANear_C_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFar_Tline_Length_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFar_Tline_L_per_Length_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFar_Tline_C_per_Length_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFar_Series_R_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFar_Pull_up_R_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFar_Pull_down_R_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFar_C_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ATermination_Voltage_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFar_Differential_R_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AEBD_File_Name_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AEBD_Signal_Name_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AEBD_Far_end_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer_GUI__Advanced_I_O_Timing__Input_Transition_Times { } {
  puts "Create report : TimeQuest Timing Analyzer GUI||Advanced I/O Timing||Input Transition Times"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer_GUI__Advanced_I_O_Timing__Input_Transition_Times.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer GUI||Advanced I/O Timing||Input Transition Times"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer_GUI__Advanced_I_O_Timing__Input_Transition_Times.csv
    return -1
  }

  set APin_index [get_report_panel_column_index -id $panel_id "Pin"]
  set AI_O_Standard_index [get_report_panel_column_index -id $panel_id "I/O Standard"]
  set A10_90_Rise_Time_index [get_report_panel_column_index -id $panel_id "10-90 Rise Time"]
  set A90_10_Fall_Time_index [get_report_panel_column_index -id $panel_id "90-10 Fall Time"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $APin_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AI_O_Standard_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $A10_90_Rise_Time_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $A90_10_Fall_Time_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer_GUI__Advanced_I_O_Timing__Signal_Integrity_Metrics__Signal_Integrity_Metrics__Slow_900mv_85c_Model_ { } {
  puts "Create report : TimeQuest Timing Analyzer GUI||Advanced I/O Timing||Signal Integrity Metrics||Signal Integrity Metrics (Slow 900mv 85c Model)"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer_GUI__Advanced_I_O_Timing__Signal_Integrity_Metrics__Signal_Integrity_Metrics__Slow_900mv_85c_Model_.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer GUI||Advanced I/O Timing||Signal Integrity Metrics||Signal Integrity Metrics (Slow 900mv 85c Model)"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer_GUI__Advanced_I_O_Timing__Signal_Integrity_Metrics__Signal_Integrity_Metrics__Slow_900mv_85c_Model_.csv
    return -1
  }

  set APin_index [get_report_panel_column_index -id $panel_id "Pin"]
  set AI_O_Standard_index [get_report_panel_column_index -id $panel_id "I/O Standard"]
  set ABoard_Delay_on_Rise_index [get_report_panel_column_index -id $panel_id "Board Delay on Rise"]
  set ABoard_Delay_on_Fall_index [get_report_panel_column_index -id $panel_id "Board Delay on Fall"]
  set ASteady_State_Voh_at_FPGA_Pin_index [get_report_panel_column_index -id $panel_id "Steady State Voh at FPGA Pin"]
  set ASteady_State_Vol_at_FPGA_Pin_index [get_report_panel_column_index -id $panel_id "Steady State Vol at FPGA Pin"]
  set AVoh_Max_at_FPGA_Pin_index [get_report_panel_column_index -id $panel_id "Voh Max at FPGA Pin"]
  set AVol_Min_at_FPGA_Pin_index [get_report_panel_column_index -id $panel_id "Vol Min at FPGA Pin"]
  set ARingback_Voltage_on_Rise_at_FPGA_Pin_index [get_report_panel_column_index -id $panel_id "Ringback Voltage on Rise at FPGA Pin"]
  set ARingback_Voltage_on_Fall_at_FPGA_Pin_index [get_report_panel_column_index -id $panel_id "Ringback Voltage on Fall at FPGA Pin"]
  set A10_90_Rise_Time_at_FPGA_Pin_index [get_report_panel_column_index -id $panel_id "10-90 Rise Time at FPGA Pin"]
  set A90_10_Fall_Time_at_FPGA_Pin_index [get_report_panel_column_index -id $panel_id "90-10 Fall Time at FPGA Pin"]
  set AMonotonic_Rise_at_FPGA_Pin_index [get_report_panel_column_index -id $panel_id "Monotonic Rise at FPGA Pin"]
  set AMonotonic_Fall_at_FPGA_Pin_index [get_report_panel_column_index -id $panel_id "Monotonic Fall at FPGA Pin"]
  set ASteady_State_Voh_at_Far_end_index [get_report_panel_column_index -id $panel_id "Steady State Voh at Far-end"]
  set ASteady_State_Vol_at_Far_end_index [get_report_panel_column_index -id $panel_id "Steady State Vol at Far-end"]
  set AVoh_Max_at_Far_end_index [get_report_panel_column_index -id $panel_id "Voh Max at Far-end"]
  set AVol_Min_at_Far_end_index [get_report_panel_column_index -id $panel_id "Vol Min at Far-end"]
  set ARingback_Voltage_on_Rise_at_Far_end_index [get_report_panel_column_index -id $panel_id "Ringback Voltage on Rise at Far-end"]
  set ARingback_Voltage_on_Fall_at_Far_end_index [get_report_panel_column_index -id $panel_id "Ringback Voltage on Fall at Far-end"]
  set A10_90_Rise_Time_at_Far_end_index [get_report_panel_column_index -id $panel_id "10-90 Rise Time at Far-end"]
  set A90_10_Fall_Time_at_Far_end_index [get_report_panel_column_index -id $panel_id "90-10 Fall Time at Far-end"]
  set AMonotonic_Rise_at_Far_end_index [get_report_panel_column_index -id $panel_id "Monotonic Rise at Far-end"]
  set AMonotonic_Fall_at_Far_end_index [get_report_panel_column_index -id $panel_id "Monotonic Fall at Far-end"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $APin_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AI_O_Standard_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ABoard_Delay_on_Rise_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ABoard_Delay_on_Fall_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASteady_State_Voh_at_FPGA_Pin_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASteady_State_Vol_at_FPGA_Pin_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AVoh_Max_at_FPGA_Pin_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AVol_Min_at_FPGA_Pin_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARingback_Voltage_on_Rise_at_FPGA_Pin_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARingback_Voltage_on_Fall_at_FPGA_Pin_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $A10_90_Rise_Time_at_FPGA_Pin_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $A90_10_Fall_Time_at_FPGA_Pin_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AMonotonic_Rise_at_FPGA_Pin_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AMonotonic_Fall_at_FPGA_Pin_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASteady_State_Voh_at_Far_end_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASteady_State_Vol_at_Far_end_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AVoh_Max_at_Far_end_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AVol_Min_at_Far_end_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARingback_Voltage_on_Rise_at_Far_end_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARingback_Voltage_on_Fall_at_Far_end_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $A10_90_Rise_Time_at_Far_end_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $A90_10_Fall_Time_at_Far_end_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AMonotonic_Rise_at_Far_end_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AMonotonic_Fall_at_Far_end_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer_GUI__SDC_File_List { } {
  puts "Create report : TimeQuest Timing Analyzer GUI||SDC File List"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer_GUI__SDC_File_List.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer GUI||SDC File List"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer_GUI__SDC_File_List.csv
    return -1
  }

  set ASDC_File_Path_index [get_report_panel_column_index -id $panel_id "SDC File Path"]
  set AStatus_index [get_report_panel_column_index -id $panel_id "Status"]
  set ARead_at_index [get_report_panel_column_index -id $panel_id "Read at"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASDC_File_Path_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AStatus_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARead_at_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer_GUI__TimeQuest_Timing_Analyzer_Summary { } {
  puts "Create report : TimeQuest Timing Analyzer GUI||TimeQuest Timing Analyzer Summary"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer_GUI__TimeQuest_Timing_Analyzer_Summary.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer GUI||TimeQuest Timing Analyzer Summary"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer_GUI__TimeQuest_Timing_Analyzer_Summary.csv
    return -1
  }

  set AQuartus_II_Version_index [get_report_panel_column_index -id $panel_id "Quartus II Version"]
  set AVersion_12_1_Build_177_11_07_2012_SJ_Full_Version_index [get_report_panel_column_index -id $panel_id "Version 12.1 Build 177 11/07/2012 SJ Full Version"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AQuartus_II_Version_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AVersion_12_1_Build_177_11_07_2012_SJ_Full_Version_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Advanced_I_O_Timing__Board_Trace_Model_Assignments { } {
  puts "Create report : TimeQuest Timing Analyzer||Advanced I/O Timing||Board Trace Model Assignments"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Advanced_I_O_Timing__Board_Trace_Model_Assignments.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Advanced I/O Timing||Board Trace Model Assignments"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Advanced_I_O_Timing__Board_Trace_Model_Assignments.csv
    return -1
  }

  set APin_index [get_report_panel_column_index -id $panel_id "Pin"]
  set AI_O_Standard_index [get_report_panel_column_index -id $panel_id "I/O Standard"]
  set ANear_Tline_Length_index [get_report_panel_column_index -id $panel_id "Near Tline Length"]
  set ANear_Tline_L_per_Length_index [get_report_panel_column_index -id $panel_id "Near Tline L per Length"]
  set ANear_Tline_C_per_Length_index [get_report_panel_column_index -id $panel_id "Near Tline C per Length"]
  set ANear_Series_R_index [get_report_panel_column_index -id $panel_id "Near Series R"]
  set ANear_Differential_R_index [get_report_panel_column_index -id $panel_id "Near Differential R"]
  set ANear_Pull_up_R_index [get_report_panel_column_index -id $panel_id "Near Pull-up R"]
  set ANear_Pull_down_R_index [get_report_panel_column_index -id $panel_id "Near Pull-down R"]
  set ANear_C_index [get_report_panel_column_index -id $panel_id "Near C"]
  set AFar_Tline_Length_index [get_report_panel_column_index -id $panel_id "Far Tline Length"]
  set AFar_Tline_L_per_Length_index [get_report_panel_column_index -id $panel_id "Far Tline L per Length"]
  set AFar_Tline_C_per_Length_index [get_report_panel_column_index -id $panel_id "Far Tline C per Length"]
  set AFar_Series_R_index [get_report_panel_column_index -id $panel_id "Far Series R"]
  set AFar_Pull_up_R_index [get_report_panel_column_index -id $panel_id "Far Pull-up R"]
  set AFar_Pull_down_R_index [get_report_panel_column_index -id $panel_id "Far Pull-down R"]
  set AFar_C_index [get_report_panel_column_index -id $panel_id "Far C"]
  set ATermination_Voltage_index [get_report_panel_column_index -id $panel_id "Termination Voltage"]
  set AFar_Differential_R_index [get_report_panel_column_index -id $panel_id "Far Differential R"]
  set AEBD_File_Name_index [get_report_panel_column_index -id $panel_id "EBD File Name"]
  set AEBD_Signal_Name_index [get_report_panel_column_index -id $panel_id "EBD Signal Name"]
  set AEBD_Far_end_index [get_report_panel_column_index -id $panel_id "EBD Far-end"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $APin_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AI_O_Standard_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ANear_Tline_Length_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ANear_Tline_L_per_Length_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ANear_Tline_C_per_Length_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ANear_Series_R_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ANear_Differential_R_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ANear_Pull_up_R_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ANear_Pull_down_R_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ANear_C_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFar_Tline_Length_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFar_Tline_L_per_Length_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFar_Tline_C_per_Length_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFar_Series_R_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFar_Pull_up_R_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFar_Pull_down_R_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFar_C_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ATermination_Voltage_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFar_Differential_R_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AEBD_File_Name_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AEBD_Signal_Name_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AEBD_Far_end_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Advanced_I_O_Timing__Input_Transition_Times { } {
  puts "Create report : TimeQuest Timing Analyzer||Advanced I/O Timing||Input Transition Times"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Advanced_I_O_Timing__Input_Transition_Times.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Advanced I/O Timing||Input Transition Times"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Advanced_I_O_Timing__Input_Transition_Times.csv
    return -1
  }

  set APin_index [get_report_panel_column_index -id $panel_id "Pin"]
  set AI_O_Standard_index [get_report_panel_column_index -id $panel_id "I/O Standard"]
  set A10_90_Rise_Time_index [get_report_panel_column_index -id $panel_id "10-90 Rise Time"]
  set A90_10_Fall_Time_index [get_report_panel_column_index -id $panel_id "90-10 Fall Time"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $APin_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AI_O_Standard_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $A10_90_Rise_Time_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $A90_10_Fall_Time_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Advanced_I_O_Timing__Signal_Integrity_Metrics__Signal_Integrity_Metrics__Fast_900mv_0c_Model_ { } {
  puts "Create report : TimeQuest Timing Analyzer||Advanced I/O Timing||Signal Integrity Metrics||Signal Integrity Metrics (Fast 900mv 0c Model)"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Advanced_I_O_Timing__Signal_Integrity_Metrics__Signal_Integrity_Metrics__Fast_900mv_0c_Model_.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Advanced I/O Timing||Signal Integrity Metrics||Signal Integrity Metrics (Fast 900mv 0c Model)"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Advanced_I_O_Timing__Signal_Integrity_Metrics__Signal_Integrity_Metrics__Fast_900mv_0c_Model_.csv
    return -1
  }

  set APin_index [get_report_panel_column_index -id $panel_id "Pin"]
  set AI_O_Standard_index [get_report_panel_column_index -id $panel_id "I/O Standard"]
  set ABoard_Delay_on_Rise_index [get_report_panel_column_index -id $panel_id "Board Delay on Rise"]
  set ABoard_Delay_on_Fall_index [get_report_panel_column_index -id $panel_id "Board Delay on Fall"]
  set ASteady_State_Voh_at_FPGA_Pin_index [get_report_panel_column_index -id $panel_id "Steady State Voh at FPGA Pin"]
  set ASteady_State_Vol_at_FPGA_Pin_index [get_report_panel_column_index -id $panel_id "Steady State Vol at FPGA Pin"]
  set AVoh_Max_at_FPGA_Pin_index [get_report_panel_column_index -id $panel_id "Voh Max at FPGA Pin"]
  set AVol_Min_at_FPGA_Pin_index [get_report_panel_column_index -id $panel_id "Vol Min at FPGA Pin"]
  set ARingback_Voltage_on_Rise_at_FPGA_Pin_index [get_report_panel_column_index -id $panel_id "Ringback Voltage on Rise at FPGA Pin"]
  set ARingback_Voltage_on_Fall_at_FPGA_Pin_index [get_report_panel_column_index -id $panel_id "Ringback Voltage on Fall at FPGA Pin"]
  set A10_90_Rise_Time_at_FPGA_Pin_index [get_report_panel_column_index -id $panel_id "10-90 Rise Time at FPGA Pin"]
  set A90_10_Fall_Time_at_FPGA_Pin_index [get_report_panel_column_index -id $panel_id "90-10 Fall Time at FPGA Pin"]
  set AMonotonic_Rise_at_FPGA_Pin_index [get_report_panel_column_index -id $panel_id "Monotonic Rise at FPGA Pin"]
  set AMonotonic_Fall_at_FPGA_Pin_index [get_report_panel_column_index -id $panel_id "Monotonic Fall at FPGA Pin"]
  set ASteady_State_Voh_at_Far_end_index [get_report_panel_column_index -id $panel_id "Steady State Voh at Far-end"]
  set ASteady_State_Vol_at_Far_end_index [get_report_panel_column_index -id $panel_id "Steady State Vol at Far-end"]
  set AVoh_Max_at_Far_end_index [get_report_panel_column_index -id $panel_id "Voh Max at Far-end"]
  set AVol_Min_at_Far_end_index [get_report_panel_column_index -id $panel_id "Vol Min at Far-end"]
  set ARingback_Voltage_on_Rise_at_Far_end_index [get_report_panel_column_index -id $panel_id "Ringback Voltage on Rise at Far-end"]
  set ARingback_Voltage_on_Fall_at_Far_end_index [get_report_panel_column_index -id $panel_id "Ringback Voltage on Fall at Far-end"]
  set A10_90_Rise_Time_at_Far_end_index [get_report_panel_column_index -id $panel_id "10-90 Rise Time at Far-end"]
  set A90_10_Fall_Time_at_Far_end_index [get_report_panel_column_index -id $panel_id "90-10 Fall Time at Far-end"]
  set AMonotonic_Rise_at_Far_end_index [get_report_panel_column_index -id $panel_id "Monotonic Rise at Far-end"]
  set AMonotonic_Fall_at_Far_end_index [get_report_panel_column_index -id $panel_id "Monotonic Fall at Far-end"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $APin_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AI_O_Standard_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ABoard_Delay_on_Rise_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ABoard_Delay_on_Fall_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASteady_State_Voh_at_FPGA_Pin_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASteady_State_Vol_at_FPGA_Pin_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AVoh_Max_at_FPGA_Pin_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AVol_Min_at_FPGA_Pin_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARingback_Voltage_on_Rise_at_FPGA_Pin_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARingback_Voltage_on_Fall_at_FPGA_Pin_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $A10_90_Rise_Time_at_FPGA_Pin_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $A90_10_Fall_Time_at_FPGA_Pin_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AMonotonic_Rise_at_FPGA_Pin_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AMonotonic_Fall_at_FPGA_Pin_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASteady_State_Voh_at_Far_end_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASteady_State_Vol_at_Far_end_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AVoh_Max_at_Far_end_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AVol_Min_at_Far_end_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARingback_Voltage_on_Rise_at_Far_end_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARingback_Voltage_on_Fall_at_Far_end_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $A10_90_Rise_Time_at_Far_end_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $A90_10_Fall_Time_at_Far_end_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AMonotonic_Rise_at_Far_end_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AMonotonic_Fall_at_Far_end_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Advanced_I_O_Timing__Signal_Integrity_Metrics__Signal_Integrity_Metrics__Slow_900mv_0c_Model_ { } {
  puts "Create report : TimeQuest Timing Analyzer||Advanced I/O Timing||Signal Integrity Metrics||Signal Integrity Metrics (Slow 900mv 0c Model)"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Advanced_I_O_Timing__Signal_Integrity_Metrics__Signal_Integrity_Metrics__Slow_900mv_0c_Model_.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Advanced I/O Timing||Signal Integrity Metrics||Signal Integrity Metrics (Slow 900mv 0c Model)"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Advanced_I_O_Timing__Signal_Integrity_Metrics__Signal_Integrity_Metrics__Slow_900mv_0c_Model_.csv
    return -1
  }

  set APin_index [get_report_panel_column_index -id $panel_id "Pin"]
  set AI_O_Standard_index [get_report_panel_column_index -id $panel_id "I/O Standard"]
  set ABoard_Delay_on_Rise_index [get_report_panel_column_index -id $panel_id "Board Delay on Rise"]
  set ABoard_Delay_on_Fall_index [get_report_panel_column_index -id $panel_id "Board Delay on Fall"]
  set ASteady_State_Voh_at_FPGA_Pin_index [get_report_panel_column_index -id $panel_id "Steady State Voh at FPGA Pin"]
  set ASteady_State_Vol_at_FPGA_Pin_index [get_report_panel_column_index -id $panel_id "Steady State Vol at FPGA Pin"]
  set AVoh_Max_at_FPGA_Pin_index [get_report_panel_column_index -id $panel_id "Voh Max at FPGA Pin"]
  set AVol_Min_at_FPGA_Pin_index [get_report_panel_column_index -id $panel_id "Vol Min at FPGA Pin"]
  set ARingback_Voltage_on_Rise_at_FPGA_Pin_index [get_report_panel_column_index -id $panel_id "Ringback Voltage on Rise at FPGA Pin"]
  set ARingback_Voltage_on_Fall_at_FPGA_Pin_index [get_report_panel_column_index -id $panel_id "Ringback Voltage on Fall at FPGA Pin"]
  set A10_90_Rise_Time_at_FPGA_Pin_index [get_report_panel_column_index -id $panel_id "10-90 Rise Time at FPGA Pin"]
  set A90_10_Fall_Time_at_FPGA_Pin_index [get_report_panel_column_index -id $panel_id "90-10 Fall Time at FPGA Pin"]
  set AMonotonic_Rise_at_FPGA_Pin_index [get_report_panel_column_index -id $panel_id "Monotonic Rise at FPGA Pin"]
  set AMonotonic_Fall_at_FPGA_Pin_index [get_report_panel_column_index -id $panel_id "Monotonic Fall at FPGA Pin"]
  set ASteady_State_Voh_at_Far_end_index [get_report_panel_column_index -id $panel_id "Steady State Voh at Far-end"]
  set ASteady_State_Vol_at_Far_end_index [get_report_panel_column_index -id $panel_id "Steady State Vol at Far-end"]
  set AVoh_Max_at_Far_end_index [get_report_panel_column_index -id $panel_id "Voh Max at Far-end"]
  set AVol_Min_at_Far_end_index [get_report_panel_column_index -id $panel_id "Vol Min at Far-end"]
  set ARingback_Voltage_on_Rise_at_Far_end_index [get_report_panel_column_index -id $panel_id "Ringback Voltage on Rise at Far-end"]
  set ARingback_Voltage_on_Fall_at_Far_end_index [get_report_panel_column_index -id $panel_id "Ringback Voltage on Fall at Far-end"]
  set A10_90_Rise_Time_at_Far_end_index [get_report_panel_column_index -id $panel_id "10-90 Rise Time at Far-end"]
  set A90_10_Fall_Time_at_Far_end_index [get_report_panel_column_index -id $panel_id "90-10 Fall Time at Far-end"]
  set AMonotonic_Rise_at_Far_end_index [get_report_panel_column_index -id $panel_id "Monotonic Rise at Far-end"]
  set AMonotonic_Fall_at_Far_end_index [get_report_panel_column_index -id $panel_id "Monotonic Fall at Far-end"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $APin_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AI_O_Standard_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ABoard_Delay_on_Rise_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ABoard_Delay_on_Fall_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASteady_State_Voh_at_FPGA_Pin_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASteady_State_Vol_at_FPGA_Pin_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AVoh_Max_at_FPGA_Pin_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AVol_Min_at_FPGA_Pin_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARingback_Voltage_on_Rise_at_FPGA_Pin_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARingback_Voltage_on_Fall_at_FPGA_Pin_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $A10_90_Rise_Time_at_FPGA_Pin_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $A90_10_Fall_Time_at_FPGA_Pin_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AMonotonic_Rise_at_FPGA_Pin_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AMonotonic_Fall_at_FPGA_Pin_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASteady_State_Voh_at_Far_end_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASteady_State_Vol_at_Far_end_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AVoh_Max_at_Far_end_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AVol_Min_at_Far_end_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARingback_Voltage_on_Rise_at_Far_end_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARingback_Voltage_on_Fall_at_Far_end_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $A10_90_Rise_Time_at_Far_end_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $A90_10_Fall_Time_at_Far_end_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AMonotonic_Rise_at_Far_end_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AMonotonic_Fall_at_Far_end_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Advanced_I_O_Timing__Signal_Integrity_Metrics__Signal_Integrity_Metrics__Slow_900mv_85c_Model_ { } {
  puts "Create report : TimeQuest Timing Analyzer||Advanced I/O Timing||Signal Integrity Metrics||Signal Integrity Metrics (Slow 900mv 85c Model)"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Advanced_I_O_Timing__Signal_Integrity_Metrics__Signal_Integrity_Metrics__Slow_900mv_85c_Model_.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Advanced I/O Timing||Signal Integrity Metrics||Signal Integrity Metrics (Slow 900mv 85c Model)"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Advanced_I_O_Timing__Signal_Integrity_Metrics__Signal_Integrity_Metrics__Slow_900mv_85c_Model_.csv
    return -1
  }

  set APin_index [get_report_panel_column_index -id $panel_id "Pin"]
  set AI_O_Standard_index [get_report_panel_column_index -id $panel_id "I/O Standard"]
  set ABoard_Delay_on_Rise_index [get_report_panel_column_index -id $panel_id "Board Delay on Rise"]
  set ABoard_Delay_on_Fall_index [get_report_panel_column_index -id $panel_id "Board Delay on Fall"]
  set ASteady_State_Voh_at_FPGA_Pin_index [get_report_panel_column_index -id $panel_id "Steady State Voh at FPGA Pin"]
  set ASteady_State_Vol_at_FPGA_Pin_index [get_report_panel_column_index -id $panel_id "Steady State Vol at FPGA Pin"]
  set AVoh_Max_at_FPGA_Pin_index [get_report_panel_column_index -id $panel_id "Voh Max at FPGA Pin"]
  set AVol_Min_at_FPGA_Pin_index [get_report_panel_column_index -id $panel_id "Vol Min at FPGA Pin"]
  set ARingback_Voltage_on_Rise_at_FPGA_Pin_index [get_report_panel_column_index -id $panel_id "Ringback Voltage on Rise at FPGA Pin"]
  set ARingback_Voltage_on_Fall_at_FPGA_Pin_index [get_report_panel_column_index -id $panel_id "Ringback Voltage on Fall at FPGA Pin"]
  set A10_90_Rise_Time_at_FPGA_Pin_index [get_report_panel_column_index -id $panel_id "10-90 Rise Time at FPGA Pin"]
  set A90_10_Fall_Time_at_FPGA_Pin_index [get_report_panel_column_index -id $panel_id "90-10 Fall Time at FPGA Pin"]
  set AMonotonic_Rise_at_FPGA_Pin_index [get_report_panel_column_index -id $panel_id "Monotonic Rise at FPGA Pin"]
  set AMonotonic_Fall_at_FPGA_Pin_index [get_report_panel_column_index -id $panel_id "Monotonic Fall at FPGA Pin"]
  set ASteady_State_Voh_at_Far_end_index [get_report_panel_column_index -id $panel_id "Steady State Voh at Far-end"]
  set ASteady_State_Vol_at_Far_end_index [get_report_panel_column_index -id $panel_id "Steady State Vol at Far-end"]
  set AVoh_Max_at_Far_end_index [get_report_panel_column_index -id $panel_id "Voh Max at Far-end"]
  set AVol_Min_at_Far_end_index [get_report_panel_column_index -id $panel_id "Vol Min at Far-end"]
  set ARingback_Voltage_on_Rise_at_Far_end_index [get_report_panel_column_index -id $panel_id "Ringback Voltage on Rise at Far-end"]
  set ARingback_Voltage_on_Fall_at_Far_end_index [get_report_panel_column_index -id $panel_id "Ringback Voltage on Fall at Far-end"]
  set A10_90_Rise_Time_at_Far_end_index [get_report_panel_column_index -id $panel_id "10-90 Rise Time at Far-end"]
  set A90_10_Fall_Time_at_Far_end_index [get_report_panel_column_index -id $panel_id "90-10 Fall Time at Far-end"]
  set AMonotonic_Rise_at_Far_end_index [get_report_panel_column_index -id $panel_id "Monotonic Rise at Far-end"]
  set AMonotonic_Fall_at_Far_end_index [get_report_panel_column_index -id $panel_id "Monotonic Fall at Far-end"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $APin_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AI_O_Standard_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ABoard_Delay_on_Rise_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ABoard_Delay_on_Fall_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASteady_State_Voh_at_FPGA_Pin_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASteady_State_Vol_at_FPGA_Pin_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AVoh_Max_at_FPGA_Pin_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AVol_Min_at_FPGA_Pin_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARingback_Voltage_on_Rise_at_FPGA_Pin_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARingback_Voltage_on_Fall_at_FPGA_Pin_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $A10_90_Rise_Time_at_FPGA_Pin_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $A90_10_Fall_Time_at_FPGA_Pin_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AMonotonic_Rise_at_FPGA_Pin_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AMonotonic_Fall_at_FPGA_Pin_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASteady_State_Voh_at_Far_end_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASteady_State_Vol_at_Far_end_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AVoh_Max_at_Far_end_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AVol_Min_at_Far_end_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARingback_Voltage_on_Rise_at_Far_end_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARingback_Voltage_on_Fall_at_Far_end_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $A10_90_Rise_Time_at_Far_end_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $A90_10_Fall_Time_at_Far_end_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AMonotonic_Rise_at_Far_end_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AMonotonic_Fall_at_Far_end_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Clock_Transfers__Hold_Transfers { } {
  puts "Create report : TimeQuest Timing Analyzer||Clock Transfers||Hold Transfers"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Clock_Transfers__Hold_Transfers.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Clock Transfers||Hold Transfers"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Clock_Transfers__Hold_Transfers.csv
    return -1
  }

  set AFrom_Clock_index [get_report_panel_column_index -id $panel_id "From Clock"]
  set ATo_Clock_index [get_report_panel_column_index -id $panel_id "To Clock"]
  set ARR_Paths_index [get_report_panel_column_index -id $panel_id "RR Paths"]
  set AFR_Paths_index [get_report_panel_column_index -id $panel_id "FR Paths"]
  set ARF_Paths_index [get_report_panel_column_index -id $panel_id "RF Paths"]
  set AFF_Paths_index [get_report_panel_column_index -id $panel_id "FF Paths"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFrom_Clock_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ATo_Clock_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARR_Paths_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFR_Paths_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARF_Paths_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFF_Paths_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Clock_Transfers__Recovery_Transfers { } {
  puts "Create report : TimeQuest Timing Analyzer||Clock Transfers||Recovery Transfers"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Clock_Transfers__Recovery_Transfers.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Clock Transfers||Recovery Transfers"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Clock_Transfers__Recovery_Transfers.csv
    return -1
  }

  set AFrom_Clock_index [get_report_panel_column_index -id $panel_id "From Clock"]
  set ATo_Clock_index [get_report_panel_column_index -id $panel_id "To Clock"]
  set ARR_Paths_index [get_report_panel_column_index -id $panel_id "RR Paths"]
  set AFR_Paths_index [get_report_panel_column_index -id $panel_id "FR Paths"]
  set ARF_Paths_index [get_report_panel_column_index -id $panel_id "RF Paths"]
  set AFF_Paths_index [get_report_panel_column_index -id $panel_id "FF Paths"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFrom_Clock_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ATo_Clock_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARR_Paths_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFR_Paths_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARF_Paths_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFF_Paths_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Clock_Transfers__Removal_Transfers { } {
  puts "Create report : TimeQuest Timing Analyzer||Clock Transfers||Removal Transfers"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Clock_Transfers__Removal_Transfers.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Clock Transfers||Removal Transfers"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Clock_Transfers__Removal_Transfers.csv
    return -1
  }

  set AFrom_Clock_index [get_report_panel_column_index -id $panel_id "From Clock"]
  set ATo_Clock_index [get_report_panel_column_index -id $panel_id "To Clock"]
  set ARR_Paths_index [get_report_panel_column_index -id $panel_id "RR Paths"]
  set AFR_Paths_index [get_report_panel_column_index -id $panel_id "FR Paths"]
  set ARF_Paths_index [get_report_panel_column_index -id $panel_id "RF Paths"]
  set AFF_Paths_index [get_report_panel_column_index -id $panel_id "FF Paths"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFrom_Clock_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ATo_Clock_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARR_Paths_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFR_Paths_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARF_Paths_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFF_Paths_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Clock_Transfers__Setup_Transfers { } {
  puts "Create report : TimeQuest Timing Analyzer||Clock Transfers||Setup Transfers"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Clock_Transfers__Setup_Transfers.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Clock Transfers||Setup Transfers"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Clock_Transfers__Setup_Transfers.csv
    return -1
  }

  set AFrom_Clock_index [get_report_panel_column_index -id $panel_id "From Clock"]
  set ATo_Clock_index [get_report_panel_column_index -id $panel_id "To Clock"]
  set ARR_Paths_index [get_report_panel_column_index -id $panel_id "RR Paths"]
  set AFR_Paths_index [get_report_panel_column_index -id $panel_id "FR Paths"]
  set ARF_Paths_index [get_report_panel_column_index -id $panel_id "RF Paths"]
  set AFF_Paths_index [get_report_panel_column_index -id $panel_id "FF Paths"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFrom_Clock_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ATo_Clock_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARR_Paths_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFR_Paths_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARF_Paths_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFF_Paths_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Clocks { } {
  puts "Create report : TimeQuest Timing Analyzer||Clocks"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Clocks.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Clocks"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Clocks.csv
    return -1
  }

  set AClock_Name_index [get_report_panel_column_index -id $panel_id "Clock Name"]
  set AType_index [get_report_panel_column_index -id $panel_id "Type"]
  set APeriod_index [get_report_panel_column_index -id $panel_id "Period"]
  set AFrequency_index [get_report_panel_column_index -id $panel_id "Frequency"]
  set ARise_index [get_report_panel_column_index -id $panel_id "Rise"]
  set AFall_index [get_report_panel_column_index -id $panel_id "Fall"]
  set ADuty_Cycle_index [get_report_panel_column_index -id $panel_id "Duty Cycle"]
  set ADivide_by_index [get_report_panel_column_index -id $panel_id "Divide by"]
  set AMultiply_by_index [get_report_panel_column_index -id $panel_id "Multiply by"]
  set APhase_index [get_report_panel_column_index -id $panel_id "Phase"]
  set AOffset_index [get_report_panel_column_index -id $panel_id "Offset"]
  set AEdge_List_index [get_report_panel_column_index -id $panel_id "Edge List"]
  set AEdge_Shift_index [get_report_panel_column_index -id $panel_id "Edge Shift"]
  set AInverted_index [get_report_panel_column_index -id $panel_id "Inverted"]
  set AMaster_index [get_report_panel_column_index -id $panel_id "Master"]
  set ASource_index [get_report_panel_column_index -id $panel_id "Source"]
  set ATargets_index [get_report_panel_column_index -id $panel_id "Targets"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Name_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AType_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $APeriod_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFrequency_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARise_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFall_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ADuty_Cycle_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ADivide_by_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AMultiply_by_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $APhase_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AOffset_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AEdge_List_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AEdge_Shift_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AInverted_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AMaster_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASource_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ATargets_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Clock_to_Output_Times { } {
  puts "Create report : TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Datasheet Report||Clock to Output Times"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Clock_to_Output_Times.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Datasheet Report||Clock to Output Times"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Clock_to_Output_Times.csv
    return -1
  }

  set AData_Port_index [get_report_panel_column_index -id $panel_id "Data Port"]
  set AClock_Port_index [get_report_panel_column_index -id $panel_id "Clock Port"]
  set ARise_index [get_report_panel_column_index -id $panel_id "Rise"]
  set AFall_index [get_report_panel_column_index -id $panel_id "Fall"]
  set AClock_Edge_index [get_report_panel_column_index -id $panel_id "Clock Edge"]
  set AClock_Reference_index [get_report_panel_column_index -id $panel_id "Clock Reference"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AData_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARise_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFall_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Edge_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Reference_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Hold_Times { } {
  puts "Create report : TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Datasheet Report||Hold Times"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Hold_Times.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Datasheet Report||Hold Times"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Hold_Times.csv
    return -1
  }

  set AData_Port_index [get_report_panel_column_index -id $panel_id "Data Port"]
  set AClock_Port_index [get_report_panel_column_index -id $panel_id "Clock Port"]
  set ARise_index [get_report_panel_column_index -id $panel_id "Rise"]
  set AFall_index [get_report_panel_column_index -id $panel_id "Fall"]
  set AClock_Edge_index [get_report_panel_column_index -id $panel_id "Clock Edge"]
  set AClock_Reference_index [get_report_panel_column_index -id $panel_id "Clock Reference"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AData_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARise_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFall_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Edge_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Reference_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Minimum_Clock_to_Output_Times { } {
  puts "Create report : TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Datasheet Report||Minimum Clock to Output Times"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Minimum_Clock_to_Output_Times.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Datasheet Report||Minimum Clock to Output Times"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Minimum_Clock_to_Output_Times.csv
    return -1
  }

  set AData_Port_index [get_report_panel_column_index -id $panel_id "Data Port"]
  set AClock_Port_index [get_report_panel_column_index -id $panel_id "Clock Port"]
  set ARise_index [get_report_panel_column_index -id $panel_id "Rise"]
  set AFall_index [get_report_panel_column_index -id $panel_id "Fall"]
  set AClock_Edge_index [get_report_panel_column_index -id $panel_id "Clock Edge"]
  set AClock_Reference_index [get_report_panel_column_index -id $panel_id "Clock Reference"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AData_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARise_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFall_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Edge_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Reference_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Minimum_Output_Disable_Times { } {
  puts "Create report : TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Datasheet Report||Minimum Output Disable Times"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Minimum_Output_Disable_Times.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Datasheet Report||Minimum Output Disable Times"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Minimum_Output_Disable_Times.csv
    return -1
  }

  set AData_Port_index [get_report_panel_column_index -id $panel_id "Data Port"]
  set AClock_Port_index [get_report_panel_column_index -id $panel_id "Clock Port"]
  set A0_to_Hi_Z_index [get_report_panel_column_index -id $panel_id "0 to Hi-Z"]
  set A1_to_Hi_Z_index [get_report_panel_column_index -id $panel_id "1 to Hi-Z"]
  set AClock_Edge_index [get_report_panel_column_index -id $panel_id "Clock Edge"]
  set AClock_Reference_index [get_report_panel_column_index -id $panel_id "Clock Reference"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AData_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $A0_to_Hi_Z_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $A1_to_Hi_Z_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Edge_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Reference_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Minimum_Output_Enable_Times { } {
  puts "Create report : TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Datasheet Report||Minimum Output Enable Times"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Minimum_Output_Enable_Times.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Datasheet Report||Minimum Output Enable Times"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Minimum_Output_Enable_Times.csv
    return -1
  }

  set AData_Port_index [get_report_panel_column_index -id $panel_id "Data Port"]
  set AClock_Port_index [get_report_panel_column_index -id $panel_id "Clock Port"]
  set ARise_index [get_report_panel_column_index -id $panel_id "Rise"]
  set AFall_index [get_report_panel_column_index -id $panel_id "Fall"]
  set AClock_Edge_index [get_report_panel_column_index -id $panel_id "Clock Edge"]
  set AClock_Reference_index [get_report_panel_column_index -id $panel_id "Clock Reference"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AData_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARise_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFall_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Edge_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Reference_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Output_Disable_Times { } {
  puts "Create report : TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Datasheet Report||Output Disable Times"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Output_Disable_Times.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Datasheet Report||Output Disable Times"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Output_Disable_Times.csv
    return -1
  }

  set AData_Port_index [get_report_panel_column_index -id $panel_id "Data Port"]
  set AClock_Port_index [get_report_panel_column_index -id $panel_id "Clock Port"]
  set A0_to_Hi_Z_index [get_report_panel_column_index -id $panel_id "0 to Hi-Z"]
  set A1_to_Hi_Z_index [get_report_panel_column_index -id $panel_id "1 to Hi-Z"]
  set AClock_Edge_index [get_report_panel_column_index -id $panel_id "Clock Edge"]
  set AClock_Reference_index [get_report_panel_column_index -id $panel_id "Clock Reference"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AData_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $A0_to_Hi_Z_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $A1_to_Hi_Z_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Edge_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Reference_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Output_Enable_Times { } {
  puts "Create report : TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Datasheet Report||Output Enable Times"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Output_Enable_Times.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Datasheet Report||Output Enable Times"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Output_Enable_Times.csv
    return -1
  }

  set AData_Port_index [get_report_panel_column_index -id $panel_id "Data Port"]
  set AClock_Port_index [get_report_panel_column_index -id $panel_id "Clock Port"]
  set ARise_index [get_report_panel_column_index -id $panel_id "Rise"]
  set AFall_index [get_report_panel_column_index -id $panel_id "Fall"]
  set AClock_Edge_index [get_report_panel_column_index -id $panel_id "Clock Edge"]
  set AClock_Reference_index [get_report_panel_column_index -id $panel_id "Clock Reference"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AData_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARise_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFall_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Edge_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Reference_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Setup_Times { } {
  puts "Create report : TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Datasheet Report||Setup Times"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Setup_Times.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Datasheet Report||Setup Times"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Setup_Times.csv
    return -1
  }

  set AData_Port_index [get_report_panel_column_index -id $panel_id "Data Port"]
  set AClock_Port_index [get_report_panel_column_index -id $panel_id "Clock Port"]
  set ARise_index [get_report_panel_column_index -id $panel_id "Rise"]
  set AFall_index [get_report_panel_column_index -id $panel_id "Fall"]
  set AClock_Edge_index [get_report_panel_column_index -id $panel_id "Clock Edge"]
  set AClock_Reference_index [get_report_panel_column_index -id $panel_id "Clock Reference"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AData_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARise_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFall_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Edge_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Reference_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Hold_Summary { } {
  puts "Create report : TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Hold Summary"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Hold_Summary.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Hold Summary"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Hold_Summary.csv
    return -1
  }

  set AClock_index [get_report_panel_column_index -id $panel_id "Clock"]
  set ASlack_index [get_report_panel_column_index -id $panel_id "Slack"]
  set AEnd_Point_TNS_index [get_report_panel_column_index -id $panel_id "End Point TNS"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASlack_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AEnd_Point_TNS_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Metastability_Report__Synchronizer_Summary { } {
  puts "Create report : TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Metastability Report||Synchronizer Summary"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Metastability_Report__Synchronizer_Summary.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Metastability Report||Synchronizer Summary"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Metastability_Report__Synchronizer_Summary.csv
    return -1
  }

  set ASource_Node_index [get_report_panel_column_index -id $panel_id "Source Node"]
  set ASynchronization_Node_index [get_report_panel_column_index -id $panel_id "Synchronization Node"]
  set AWorst_Case_MTBF__Years__index [get_report_panel_column_index -id $panel_id "Worst-Case MTBF (Years)"]
  set ATypical_MTBF__Years__index [get_report_panel_column_index -id $panel_id "Typical MTBF (Years)"]
  set AIncluded_in_Design_MTBF_index [get_report_panel_column_index -id $panel_id "Included in Design MTBF"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASource_Node_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASynchronization_Node_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AWorst_Case_MTBF__Years__index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ATypical_MTBF__Years__index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AIncluded_in_Design_MTBF_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Minimum_Pulse_Width_Summary { } {
  puts "Create report : TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Minimum Pulse Width Summary"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Minimum_Pulse_Width_Summary.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Minimum Pulse Width Summary"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Minimum_Pulse_Width_Summary.csv
    return -1
  }

  set AClock_index [get_report_panel_column_index -id $panel_id "Clock"]
  set ASlack_index [get_report_panel_column_index -id $panel_id "Slack"]
  set AEnd_Point_TNS_index [get_report_panel_column_index -id $panel_id "End Point TNS"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASlack_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AEnd_Point_TNS_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Recovery_Summary { } {
  puts "Create report : TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Recovery Summary"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Recovery_Summary.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Recovery Summary"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Recovery_Summary.csv
    return -1
  }

  set AClock_index [get_report_panel_column_index -id $panel_id "Clock"]
  set ASlack_index [get_report_panel_column_index -id $panel_id "Slack"]
  set AEnd_Point_TNS_index [get_report_panel_column_index -id $panel_id "End Point TNS"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASlack_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AEnd_Point_TNS_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Removal_Summary { } {
  puts "Create report : TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Removal Summary"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Removal_Summary.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Removal Summary"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Removal_Summary.csv
    return -1
  }

  set AClock_index [get_report_panel_column_index -id $panel_id "Clock"]
  set ASlack_index [get_report_panel_column_index -id $panel_id "Slack"]
  set AEnd_Point_TNS_index [get_report_panel_column_index -id $panel_id "End Point TNS"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASlack_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AEnd_Point_TNS_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Setup_Summary { } {
  puts "Create report : TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Setup Summary"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Setup_Summary.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Setup Summary"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Setup_Summary.csv
    return -1
  }

  set AClock_index [get_report_panel_column_index -id $panel_id "Clock"]
  set ASlack_index [get_report_panel_column_index -id $panel_id "Slack"]
  set AEnd_Point_TNS_index [get_report_panel_column_index -id $panel_id "End Point TNS"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASlack_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AEnd_Point_TNS_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Multicorner_Datasheet_Report_Summary__Clock_to_Output_Times { } {
  puts "Create report : TimeQuest Timing Analyzer||Multicorner Datasheet Report Summary||Clock to Output Times"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Multicorner_Datasheet_Report_Summary__Clock_to_Output_Times.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Multicorner Datasheet Report Summary||Clock to Output Times"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Multicorner_Datasheet_Report_Summary__Clock_to_Output_Times.csv
    return -1
  }

  set AData_Port_index [get_report_panel_column_index -id $panel_id "Data Port"]
  set AClock_Port_index [get_report_panel_column_index -id $panel_id "Clock Port"]
  set ARise_index [get_report_panel_column_index -id $panel_id "Rise"]
  set AFall_index [get_report_panel_column_index -id $panel_id "Fall"]
  set AClock_Edge_index [get_report_panel_column_index -id $panel_id "Clock Edge"]
  set AClock_Reference_index [get_report_panel_column_index -id $panel_id "Clock Reference"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AData_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARise_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFall_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Edge_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Reference_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Multicorner_Datasheet_Report_Summary__Hold_Times { } {
  puts "Create report : TimeQuest Timing Analyzer||Multicorner Datasheet Report Summary||Hold Times"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Multicorner_Datasheet_Report_Summary__Hold_Times.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Multicorner Datasheet Report Summary||Hold Times"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Multicorner_Datasheet_Report_Summary__Hold_Times.csv
    return -1
  }

  set AData_Port_index [get_report_panel_column_index -id $panel_id "Data Port"]
  set AClock_Port_index [get_report_panel_column_index -id $panel_id "Clock Port"]
  set ARise_index [get_report_panel_column_index -id $panel_id "Rise"]
  set AFall_index [get_report_panel_column_index -id $panel_id "Fall"]
  set AClock_Edge_index [get_report_panel_column_index -id $panel_id "Clock Edge"]
  set AClock_Reference_index [get_report_panel_column_index -id $panel_id "Clock Reference"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AData_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARise_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFall_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Edge_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Reference_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Multicorner_Datasheet_Report_Summary__Minimum_Clock_to_Output_Times { } {
  puts "Create report : TimeQuest Timing Analyzer||Multicorner Datasheet Report Summary||Minimum Clock to Output Times"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Multicorner_Datasheet_Report_Summary__Minimum_Clock_to_Output_Times.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Multicorner Datasheet Report Summary||Minimum Clock to Output Times"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Multicorner_Datasheet_Report_Summary__Minimum_Clock_to_Output_Times.csv
    return -1
  }

  set AData_Port_index [get_report_panel_column_index -id $panel_id "Data Port"]
  set AClock_Port_index [get_report_panel_column_index -id $panel_id "Clock Port"]
  set ARise_index [get_report_panel_column_index -id $panel_id "Rise"]
  set AFall_index [get_report_panel_column_index -id $panel_id "Fall"]
  set AClock_Edge_index [get_report_panel_column_index -id $panel_id "Clock Edge"]
  set AClock_Reference_index [get_report_panel_column_index -id $panel_id "Clock Reference"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AData_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARise_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFall_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Edge_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Reference_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Multicorner_Datasheet_Report_Summary__Setup_Times { } {
  puts "Create report : TimeQuest Timing Analyzer||Multicorner Datasheet Report Summary||Setup Times"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Multicorner_Datasheet_Report_Summary__Setup_Times.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Multicorner Datasheet Report Summary||Setup Times"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Multicorner_Datasheet_Report_Summary__Setup_Times.csv
    return -1
  }

  set AData_Port_index [get_report_panel_column_index -id $panel_id "Data Port"]
  set AClock_Port_index [get_report_panel_column_index -id $panel_id "Clock Port"]
  set ARise_index [get_report_panel_column_index -id $panel_id "Rise"]
  set AFall_index [get_report_panel_column_index -id $panel_id "Fall"]
  set AClock_Edge_index [get_report_panel_column_index -id $panel_id "Clock Edge"]
  set AClock_Reference_index [get_report_panel_column_index -id $panel_id "Clock Reference"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AData_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARise_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFall_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Edge_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Reference_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Multicorner_Timing_Analysis_Summary { } {
  puts "Create report : TimeQuest Timing Analyzer||Multicorner Timing Analysis Summary"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Multicorner_Timing_Analysis_Summary.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Multicorner Timing Analysis Summary"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Multicorner_Timing_Analysis_Summary.csv
    return -1
  }

  set AClock_index [get_report_panel_column_index -id $panel_id "Clock"]
  set ASetup_index [get_report_panel_column_index -id $panel_id "Setup"]
  set AHold_index [get_report_panel_column_index -id $panel_id "Hold"]
  set ARecovery_index [get_report_panel_column_index -id $panel_id "Recovery"]
  set ARemoval_index [get_report_panel_column_index -id $panel_id "Removal"]
  set AMinimum_Pulse_Width_index [get_report_panel_column_index -id $panel_id "Minimum Pulse Width"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASetup_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AHold_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARecovery_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARemoval_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AMinimum_Pulse_Width_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Parallel_Compilation { } {
  puts "Create report : TimeQuest Timing Analyzer||Parallel Compilation"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Parallel_Compilation.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Parallel Compilation"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Parallel_Compilation.csv
    return -1
  }

  set AProcessors_index [get_report_panel_column_index -id $panel_id "Processors"]
  set ANumber_index [get_report_panel_column_index -id $panel_id "Number"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AProcessors_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ANumber_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__SDC_File_List { } {
  puts "Create report : TimeQuest Timing Analyzer||SDC File List"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__SDC_File_List.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||SDC File List"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__SDC_File_List.csv
    return -1
  }

  set ASDC_File_Path_index [get_report_panel_column_index -id $panel_id "SDC File Path"]
  set AStatus_index [get_report_panel_column_index -id $panel_id "Status"]
  set ARead_at_index [get_report_panel_column_index -id $panel_id "Read at"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASDC_File_Path_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AStatus_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARead_at_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Clock_to_Output_Times { } {
  puts "Create report : TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Datasheet Report||Clock to Output Times"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Clock_to_Output_Times.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Datasheet Report||Clock to Output Times"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Clock_to_Output_Times.csv
    return -1
  }

  set AData_Port_index [get_report_panel_column_index -id $panel_id "Data Port"]
  set AClock_Port_index [get_report_panel_column_index -id $panel_id "Clock Port"]
  set ARise_index [get_report_panel_column_index -id $panel_id "Rise"]
  set AFall_index [get_report_panel_column_index -id $panel_id "Fall"]
  set AClock_Edge_index [get_report_panel_column_index -id $panel_id "Clock Edge"]
  set AClock_Reference_index [get_report_panel_column_index -id $panel_id "Clock Reference"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AData_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARise_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFall_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Edge_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Reference_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Hold_Times { } {
  puts "Create report : TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Datasheet Report||Hold Times"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Hold_Times.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Datasheet Report||Hold Times"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Hold_Times.csv
    return -1
  }

  set AData_Port_index [get_report_panel_column_index -id $panel_id "Data Port"]
  set AClock_Port_index [get_report_panel_column_index -id $panel_id "Clock Port"]
  set ARise_index [get_report_panel_column_index -id $panel_id "Rise"]
  set AFall_index [get_report_panel_column_index -id $panel_id "Fall"]
  set AClock_Edge_index [get_report_panel_column_index -id $panel_id "Clock Edge"]
  set AClock_Reference_index [get_report_panel_column_index -id $panel_id "Clock Reference"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AData_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARise_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFall_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Edge_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Reference_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Minimum_Clock_to_Output_Times { } {
  puts "Create report : TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Datasheet Report||Minimum Clock to Output Times"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Minimum_Clock_to_Output_Times.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Datasheet Report||Minimum Clock to Output Times"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Minimum_Clock_to_Output_Times.csv
    return -1
  }

  set AData_Port_index [get_report_panel_column_index -id $panel_id "Data Port"]
  set AClock_Port_index [get_report_panel_column_index -id $panel_id "Clock Port"]
  set ARise_index [get_report_panel_column_index -id $panel_id "Rise"]
  set AFall_index [get_report_panel_column_index -id $panel_id "Fall"]
  set AClock_Edge_index [get_report_panel_column_index -id $panel_id "Clock Edge"]
  set AClock_Reference_index [get_report_panel_column_index -id $panel_id "Clock Reference"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AData_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARise_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFall_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Edge_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Reference_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Minimum_Output_Disable_Times { } {
  puts "Create report : TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Datasheet Report||Minimum Output Disable Times"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Minimum_Output_Disable_Times.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Datasheet Report||Minimum Output Disable Times"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Minimum_Output_Disable_Times.csv
    return -1
  }

  set AData_Port_index [get_report_panel_column_index -id $panel_id "Data Port"]
  set AClock_Port_index [get_report_panel_column_index -id $panel_id "Clock Port"]
  set A0_to_Hi_Z_index [get_report_panel_column_index -id $panel_id "0 to Hi-Z"]
  set A1_to_Hi_Z_index [get_report_panel_column_index -id $panel_id "1 to Hi-Z"]
  set AClock_Edge_index [get_report_panel_column_index -id $panel_id "Clock Edge"]
  set AClock_Reference_index [get_report_panel_column_index -id $panel_id "Clock Reference"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AData_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $A0_to_Hi_Z_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $A1_to_Hi_Z_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Edge_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Reference_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Minimum_Output_Enable_Times { } {
  puts "Create report : TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Datasheet Report||Minimum Output Enable Times"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Minimum_Output_Enable_Times.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Datasheet Report||Minimum Output Enable Times"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Minimum_Output_Enable_Times.csv
    return -1
  }

  set AData_Port_index [get_report_panel_column_index -id $panel_id "Data Port"]
  set AClock_Port_index [get_report_panel_column_index -id $panel_id "Clock Port"]
  set ARise_index [get_report_panel_column_index -id $panel_id "Rise"]
  set AFall_index [get_report_panel_column_index -id $panel_id "Fall"]
  set AClock_Edge_index [get_report_panel_column_index -id $panel_id "Clock Edge"]
  set AClock_Reference_index [get_report_panel_column_index -id $panel_id "Clock Reference"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AData_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARise_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFall_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Edge_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Reference_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Output_Disable_Times { } {
  puts "Create report : TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Datasheet Report||Output Disable Times"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Output_Disable_Times.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Datasheet Report||Output Disable Times"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Output_Disable_Times.csv
    return -1
  }

  set AData_Port_index [get_report_panel_column_index -id $panel_id "Data Port"]
  set AClock_Port_index [get_report_panel_column_index -id $panel_id "Clock Port"]
  set A0_to_Hi_Z_index [get_report_panel_column_index -id $panel_id "0 to Hi-Z"]
  set A1_to_Hi_Z_index [get_report_panel_column_index -id $panel_id "1 to Hi-Z"]
  set AClock_Edge_index [get_report_panel_column_index -id $panel_id "Clock Edge"]
  set AClock_Reference_index [get_report_panel_column_index -id $panel_id "Clock Reference"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AData_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $A0_to_Hi_Z_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $A1_to_Hi_Z_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Edge_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Reference_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Output_Enable_Times { } {
  puts "Create report : TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Datasheet Report||Output Enable Times"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Output_Enable_Times.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Datasheet Report||Output Enable Times"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Output_Enable_Times.csv
    return -1
  }

  set AData_Port_index [get_report_panel_column_index -id $panel_id "Data Port"]
  set AClock_Port_index [get_report_panel_column_index -id $panel_id "Clock Port"]
  set ARise_index [get_report_panel_column_index -id $panel_id "Rise"]
  set AFall_index [get_report_panel_column_index -id $panel_id "Fall"]
  set AClock_Edge_index [get_report_panel_column_index -id $panel_id "Clock Edge"]
  set AClock_Reference_index [get_report_panel_column_index -id $panel_id "Clock Reference"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AData_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARise_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFall_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Edge_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Reference_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Setup_Times { } {
  puts "Create report : TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Datasheet Report||Setup Times"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Setup_Times.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Datasheet Report||Setup Times"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Setup_Times.csv
    return -1
  }

  set AData_Port_index [get_report_panel_column_index -id $panel_id "Data Port"]
  set AClock_Port_index [get_report_panel_column_index -id $panel_id "Clock Port"]
  set ARise_index [get_report_panel_column_index -id $panel_id "Rise"]
  set AFall_index [get_report_panel_column_index -id $panel_id "Fall"]
  set AClock_Edge_index [get_report_panel_column_index -id $panel_id "Clock Edge"]
  set AClock_Reference_index [get_report_panel_column_index -id $panel_id "Clock Reference"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AData_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARise_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFall_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Edge_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Reference_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Fmax_Summary { } {
  puts "Create report : TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Fmax Summary"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Fmax_Summary.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Fmax Summary"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Fmax_Summary.csv
    return -1
  }

  set AFmax_index [get_report_panel_column_index -id $panel_id "Fmax"]
  set ARestricted_Fmax_index [get_report_panel_column_index -id $panel_id "Restricted Fmax"]
  set AClock_Name_index [get_report_panel_column_index -id $panel_id "Clock Name"]
  set ANote_index [get_report_panel_column_index -id $panel_id "Note"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFmax_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARestricted_Fmax_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Name_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ANote_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Hold_Summary { } {
  puts "Create report : TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Hold Summary"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Hold_Summary.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Hold Summary"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Hold_Summary.csv
    return -1
  }

  set AClock_index [get_report_panel_column_index -id $panel_id "Clock"]
  set ASlack_index [get_report_panel_column_index -id $panel_id "Slack"]
  set AEnd_Point_TNS_index [get_report_panel_column_index -id $panel_id "End Point TNS"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASlack_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AEnd_Point_TNS_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Metastability_Report__Synchronizer_Summary { } {
  puts "Create report : TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Metastability Report||Synchronizer Summary"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Metastability_Report__Synchronizer_Summary.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Metastability Report||Synchronizer Summary"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Metastability_Report__Synchronizer_Summary.csv
    return -1
  }

  set ASource_Node_index [get_report_panel_column_index -id $panel_id "Source Node"]
  set ASynchronization_Node_index [get_report_panel_column_index -id $panel_id "Synchronization Node"]
  set AWorst_Case_MTBF__Years__index [get_report_panel_column_index -id $panel_id "Worst-Case MTBF (Years)"]
  set ATypical_MTBF__Years__index [get_report_panel_column_index -id $panel_id "Typical MTBF (Years)"]
  set AIncluded_in_Design_MTBF_index [get_report_panel_column_index -id $panel_id "Included in Design MTBF"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASource_Node_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASynchronization_Node_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AWorst_Case_MTBF__Years__index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ATypical_MTBF__Years__index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AIncluded_in_Design_MTBF_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Minimum_Pulse_Width_Summary { } {
  puts "Create report : TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Minimum Pulse Width Summary"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Minimum_Pulse_Width_Summary.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Minimum Pulse Width Summary"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Minimum_Pulse_Width_Summary.csv
    return -1
  }

  set AClock_index [get_report_panel_column_index -id $panel_id "Clock"]
  set ASlack_index [get_report_panel_column_index -id $panel_id "Slack"]
  set AEnd_Point_TNS_index [get_report_panel_column_index -id $panel_id "End Point TNS"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASlack_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AEnd_Point_TNS_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Recovery_Summary { } {
  puts "Create report : TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Recovery Summary"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Recovery_Summary.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Recovery Summary"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Recovery_Summary.csv
    return -1
  }

  set AClock_index [get_report_panel_column_index -id $panel_id "Clock"]
  set ASlack_index [get_report_panel_column_index -id $panel_id "Slack"]
  set AEnd_Point_TNS_index [get_report_panel_column_index -id $panel_id "End Point TNS"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASlack_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AEnd_Point_TNS_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Removal_Summary { } {
  puts "Create report : TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Removal Summary"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Removal_Summary.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Removal Summary"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Removal_Summary.csv
    return -1
  }

  set AClock_index [get_report_panel_column_index -id $panel_id "Clock"]
  set ASlack_index [get_report_panel_column_index -id $panel_id "Slack"]
  set AEnd_Point_TNS_index [get_report_panel_column_index -id $panel_id "End Point TNS"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASlack_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AEnd_Point_TNS_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Setup_Summary { } {
  puts "Create report : TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Setup Summary"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Setup_Summary.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Setup Summary"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Setup_Summary.csv
    return -1
  }

  set AClock_index [get_report_panel_column_index -id $panel_id "Clock"]
  set ASlack_index [get_report_panel_column_index -id $panel_id "Slack"]
  set AEnd_Point_TNS_index [get_report_panel_column_index -id $panel_id "End Point TNS"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASlack_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AEnd_Point_TNS_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Clock_to_Output_Times { } {
  puts "Create report : TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Datasheet Report||Clock to Output Times"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Clock_to_Output_Times.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Datasheet Report||Clock to Output Times"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Clock_to_Output_Times.csv
    return -1
  }

  set AData_Port_index [get_report_panel_column_index -id $panel_id "Data Port"]
  set AClock_Port_index [get_report_panel_column_index -id $panel_id "Clock Port"]
  set ARise_index [get_report_panel_column_index -id $panel_id "Rise"]
  set AFall_index [get_report_panel_column_index -id $panel_id "Fall"]
  set AClock_Edge_index [get_report_panel_column_index -id $panel_id "Clock Edge"]
  set AClock_Reference_index [get_report_panel_column_index -id $panel_id "Clock Reference"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AData_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARise_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFall_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Edge_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Reference_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Hold_Times { } {
  puts "Create report : TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Datasheet Report||Hold Times"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Hold_Times.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Datasheet Report||Hold Times"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Hold_Times.csv
    return -1
  }

  set AData_Port_index [get_report_panel_column_index -id $panel_id "Data Port"]
  set AClock_Port_index [get_report_panel_column_index -id $panel_id "Clock Port"]
  set ARise_index [get_report_panel_column_index -id $panel_id "Rise"]
  set AFall_index [get_report_panel_column_index -id $panel_id "Fall"]
  set AClock_Edge_index [get_report_panel_column_index -id $panel_id "Clock Edge"]
  set AClock_Reference_index [get_report_panel_column_index -id $panel_id "Clock Reference"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AData_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARise_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFall_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Edge_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Reference_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Minimum_Clock_to_Output_Times { } {
  puts "Create report : TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Datasheet Report||Minimum Clock to Output Times"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Minimum_Clock_to_Output_Times.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Datasheet Report||Minimum Clock to Output Times"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Minimum_Clock_to_Output_Times.csv
    return -1
  }

  set AData_Port_index [get_report_panel_column_index -id $panel_id "Data Port"]
  set AClock_Port_index [get_report_panel_column_index -id $panel_id "Clock Port"]
  set ARise_index [get_report_panel_column_index -id $panel_id "Rise"]
  set AFall_index [get_report_panel_column_index -id $panel_id "Fall"]
  set AClock_Edge_index [get_report_panel_column_index -id $panel_id "Clock Edge"]
  set AClock_Reference_index [get_report_panel_column_index -id $panel_id "Clock Reference"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AData_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARise_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFall_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Edge_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Reference_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Minimum_Output_Disable_Times { } {
  puts "Create report : TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Datasheet Report||Minimum Output Disable Times"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Minimum_Output_Disable_Times.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Datasheet Report||Minimum Output Disable Times"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Minimum_Output_Disable_Times.csv
    return -1
  }

  set AData_Port_index [get_report_panel_column_index -id $panel_id "Data Port"]
  set AClock_Port_index [get_report_panel_column_index -id $panel_id "Clock Port"]
  set A0_to_Hi_Z_index [get_report_panel_column_index -id $panel_id "0 to Hi-Z"]
  set A1_to_Hi_Z_index [get_report_panel_column_index -id $panel_id "1 to Hi-Z"]
  set AClock_Edge_index [get_report_panel_column_index -id $panel_id "Clock Edge"]
  set AClock_Reference_index [get_report_panel_column_index -id $panel_id "Clock Reference"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AData_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $A0_to_Hi_Z_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $A1_to_Hi_Z_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Edge_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Reference_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Minimum_Output_Enable_Times { } {
  puts "Create report : TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Datasheet Report||Minimum Output Enable Times"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Minimum_Output_Enable_Times.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Datasheet Report||Minimum Output Enable Times"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Minimum_Output_Enable_Times.csv
    return -1
  }

  set AData_Port_index [get_report_panel_column_index -id $panel_id "Data Port"]
  set AClock_Port_index [get_report_panel_column_index -id $panel_id "Clock Port"]
  set ARise_index [get_report_panel_column_index -id $panel_id "Rise"]
  set AFall_index [get_report_panel_column_index -id $panel_id "Fall"]
  set AClock_Edge_index [get_report_panel_column_index -id $panel_id "Clock Edge"]
  set AClock_Reference_index [get_report_panel_column_index -id $panel_id "Clock Reference"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AData_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARise_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFall_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Edge_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Reference_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Output_Disable_Times { } {
  puts "Create report : TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Datasheet Report||Output Disable Times"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Output_Disable_Times.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Datasheet Report||Output Disable Times"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Output_Disable_Times.csv
    return -1
  }

  set AData_Port_index [get_report_panel_column_index -id $panel_id "Data Port"]
  set AClock_Port_index [get_report_panel_column_index -id $panel_id "Clock Port"]
  set A0_to_Hi_Z_index [get_report_panel_column_index -id $panel_id "0 to Hi-Z"]
  set A1_to_Hi_Z_index [get_report_panel_column_index -id $panel_id "1 to Hi-Z"]
  set AClock_Edge_index [get_report_panel_column_index -id $panel_id "Clock Edge"]
  set AClock_Reference_index [get_report_panel_column_index -id $panel_id "Clock Reference"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AData_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $A0_to_Hi_Z_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $A1_to_Hi_Z_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Edge_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Reference_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Output_Enable_Times { } {
  puts "Create report : TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Datasheet Report||Output Enable Times"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Output_Enable_Times.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Datasheet Report||Output Enable Times"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Output_Enable_Times.csv
    return -1
  }

  set AData_Port_index [get_report_panel_column_index -id $panel_id "Data Port"]
  set AClock_Port_index [get_report_panel_column_index -id $panel_id "Clock Port"]
  set ARise_index [get_report_panel_column_index -id $panel_id "Rise"]
  set AFall_index [get_report_panel_column_index -id $panel_id "Fall"]
  set AClock_Edge_index [get_report_panel_column_index -id $panel_id "Clock Edge"]
  set AClock_Reference_index [get_report_panel_column_index -id $panel_id "Clock Reference"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AData_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARise_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFall_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Edge_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Reference_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Setup_Times { } {
  puts "Create report : TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Datasheet Report||Setup Times"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Setup_Times.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Datasheet Report||Setup Times"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Setup_Times.csv
    return -1
  }

  set AData_Port_index [get_report_panel_column_index -id $panel_id "Data Port"]
  set AClock_Port_index [get_report_panel_column_index -id $panel_id "Clock Port"]
  set ARise_index [get_report_panel_column_index -id $panel_id "Rise"]
  set AFall_index [get_report_panel_column_index -id $panel_id "Fall"]
  set AClock_Edge_index [get_report_panel_column_index -id $panel_id "Clock Edge"]
  set AClock_Reference_index [get_report_panel_column_index -id $panel_id "Clock Reference"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AData_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Port_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARise_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFall_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Edge_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Reference_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Fmax_Summary { } {
  puts "Create report : TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Fmax Summary"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Fmax_Summary.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Fmax Summary"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Fmax_Summary.csv
    return -1
  }

  set AFmax_index [get_report_panel_column_index -id $panel_id "Fmax"]
  set ARestricted_Fmax_index [get_report_panel_column_index -id $panel_id "Restricted Fmax"]
  set AClock_Name_index [get_report_panel_column_index -id $panel_id "Clock Name"]
  set ANote_index [get_report_panel_column_index -id $panel_id "Note"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AFmax_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ARestricted_Fmax_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_Name_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ANote_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Hold_Summary { } {
  puts "Create report : TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Hold Summary"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Hold_Summary.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Hold Summary"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Hold_Summary.csv
    return -1
  }

  set AClock_index [get_report_panel_column_index -id $panel_id "Clock"]
  set ASlack_index [get_report_panel_column_index -id $panel_id "Slack"]
  set AEnd_Point_TNS_index [get_report_panel_column_index -id $panel_id "End Point TNS"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASlack_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AEnd_Point_TNS_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Metastability_Report__Synchronizer_Summary { } {
  puts "Create report : TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Metastability Report||Synchronizer Summary"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Metastability_Report__Synchronizer_Summary.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Metastability Report||Synchronizer Summary"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Metastability_Report__Synchronizer_Summary.csv
    return -1
  }

  set ASource_Node_index [get_report_panel_column_index -id $panel_id "Source Node"]
  set ASynchronization_Node_index [get_report_panel_column_index -id $panel_id "Synchronization Node"]
  set AWorst_Case_MTBF__Years__index [get_report_panel_column_index -id $panel_id "Worst-Case MTBF (Years)"]
  set ATypical_MTBF__Years__index [get_report_panel_column_index -id $panel_id "Typical MTBF (Years)"]
  set AIncluded_in_Design_MTBF_index [get_report_panel_column_index -id $panel_id "Included in Design MTBF"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASource_Node_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASynchronization_Node_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AWorst_Case_MTBF__Years__index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ATypical_MTBF__Years__index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AIncluded_in_Design_MTBF_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Minimum_Pulse_Width_Summary { } {
  puts "Create report : TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Minimum Pulse Width Summary"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Minimum_Pulse_Width_Summary.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Minimum Pulse Width Summary"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Minimum_Pulse_Width_Summary.csv
    return -1
  }

  set AClock_index [get_report_panel_column_index -id $panel_id "Clock"]
  set ASlack_index [get_report_panel_column_index -id $panel_id "Slack"]
  set AEnd_Point_TNS_index [get_report_panel_column_index -id $panel_id "End Point TNS"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASlack_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AEnd_Point_TNS_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Recovery_Summary { } {
  puts "Create report : TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Recovery Summary"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Recovery_Summary.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Recovery Summary"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Recovery_Summary.csv
    return -1
  }

  set AClock_index [get_report_panel_column_index -id $panel_id "Clock"]
  set ASlack_index [get_report_panel_column_index -id $panel_id "Slack"]
  set AEnd_Point_TNS_index [get_report_panel_column_index -id $panel_id "End Point TNS"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASlack_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AEnd_Point_TNS_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Removal_Summary { } {
  puts "Create report : TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Removal Summary"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Removal_Summary.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Removal Summary"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Removal_Summary.csv
    return -1
  }

  set AClock_index [get_report_panel_column_index -id $panel_id "Clock"]
  set ASlack_index [get_report_panel_column_index -id $panel_id "Slack"]
  set AEnd_Point_TNS_index [get_report_panel_column_index -id $panel_id "End Point TNS"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASlack_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AEnd_Point_TNS_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Setup_Summary { } {
  puts "Create report : TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Setup Summary"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Setup_Summary.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Setup Summary"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Setup_Summary.csv
    return -1
  }

  set AClock_index [get_report_panel_column_index -id $panel_id "Clock"]
  set ASlack_index [get_report_panel_column_index -id $panel_id "Slack"]
  set AEnd_Point_TNS_index [get_report_panel_column_index -id $panel_id "End Point TNS"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AClock_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASlack_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AEnd_Point_TNS_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__TimeQuest_Timing_Analyzer_Summary { } {
  puts "Create report : TimeQuest Timing Analyzer||TimeQuest Timing Analyzer Summary"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__TimeQuest_Timing_Analyzer_Summary.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||TimeQuest Timing Analyzer Summary"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__TimeQuest_Timing_Analyzer_Summary.csv
    return -1
  }

  set AQuartus_II_Version_index [get_report_panel_column_index -id $panel_id "Quartus II Version"]
  set AVersion_12_1_Build_177_11_07_2012_SJ_Full_Version_index [get_report_panel_column_index -id $panel_id "Version 12.1 Build 177 11/07/2012 SJ Full Version"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AQuartus_II_Version_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AVersion_12_1_Build_177_11_07_2012_SJ_Full_Version_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc TimeQuest_Timing_Analyzer__Unconstrained_Paths { } {
  puts "Create report : TimeQuest Timing Analyzer||Unconstrained Paths"
  load_package report
  load_report
  if {[file isdirectory csv_files]} {
  } else {
    file mkdir csv_files
  }
  set fh [open csv_files/TimeQuest_Timing_Analyzer__Unconstrained_Paths.csv w]
  set panel_id [get_report_panel_id "TimeQuest Timing Analyzer||Unconstrained Paths"]
  if { -1 == $panel_id } {
    close $fh
    file delete TimeQuest_Timing_Analyzer__Unconstrained_Paths.csv
    return -1
  }

  set AProperty_index [get_report_panel_column_index -id $panel_id "Property"]
  set ASetup_index [get_report_panel_column_index -id $panel_id "Setup"]
  set AHold_index [get_report_panel_column_index -id $panel_id "Hold"]

  if { -1 != $panel_id } {
    #delete_report_panel -id $panel_id
    # Get the number of rows
    set num_rows [get_number_of_rows -id $panel_id]
    for { set i 0 } { $i < $num_rows } { incr i } {
      set row_data [get_report_panel_row -id $panel_id -row $i]
      set fs [list]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AProperty_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $ASetup_index]
      #lappend fs [get_report_panel_data -id $panel_id -row $i -col $AHold_index]
      #set row_data [join $fs ","]
      puts $fh [join $row_data ","]
    }
  }
  close $fh
  unload_report
}


proc run_report { projname } {
  puts $projname
  if [is_project_open] {
  } else {
    project_open $projname
    create_timing_netlist
    read_sdc
    update_timing_netlist
  }
  Analysis___Synthesis__Analysis___Synthesis_IP_Cores_Summary
  Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Multiplexer_Statistics__Multiplexer_Restructuring_Statistics__Restructuring_Performed_
  Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Register_Statistics__General_Register_Statistics
  Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Register_Statistics__Inverted_Register_Statistics
  Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Register_Statistics__Registers_Protected_by_Synthesis
  Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Register_Statistics__Registers_Removed_During_Synthesis
  Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Register_Statistics__Removed_Registers_Triggering_Further_Register_Optimizations
  Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Registers_Packed_Into_Inferred_Megafunctions
  Analysis___Synthesis__Analysis___Synthesis_RAM_Summary
  Analysis___Synthesis__Analysis___Synthesis_Resource_Usage_Summary
  Analysis___Synthesis__Analysis___Synthesis_Resource_Utilization_by_Entity
  Analysis___Synthesis__Analysis___Synthesis_Source_Files_Read
  Analysis___Synthesis__Analysis___Synthesis_Summary
  Analysis___Synthesis__Elapsed_Time_Per_Partition
  Analysis___Synthesis__Parallel_Compilation
  Analysis___Synthesis__Settings__Analysis___Synthesis_Default_Parameter_Settings
  Analysis___Synthesis__Settings__Analysis___Synthesis_Settings
  Assembler__Assembler_Device_Options____dse_temp_rev_sof
  Assembler__Assembler_Encrypted_IP_Cores_Summary
  Assembler__Assembler_Generated_Files
  Assembler__Assembler_Settings
  Assembler__Assembler_Summary
  Fitter__Estimated_Delay_Added_for_Hold_Timing__Estimated_Delay_Added_for_Hold_Timing_Details
  Fitter__Estimated_Delay_Added_for_Hold_Timing__Estimated_Delay_Added_for_Hold_Timing_Summary
  Fitter__Fitter_Device_Options
  Fitter__Fitter_Incremental_Compilation_Section__Incremental_Compilation_Partition_Settings
  Fitter__Fitter_Incremental_Compilation_Section__Incremental_Compilation_Placement_Preservation
  Fitter__Fitter_Incremental_Compilation_Section__Incremental_Compilation_Preservation_Summary
  Fitter__Fitter_Netlist_Optimizations
  Fitter__Fitter_Settings
  Fitter__Fitter_Summary
  Fitter__I_O_Assignment_Warnings
  Fitter__I_O_Rules_Section__I_O_Rules_Details
  Fitter__I_O_Rules_Section__I_O_Rules_Matrix
  Fitter__I_O_Rules_Section__I_O_Rules_Summary
  Fitter__Ignored_Assignments
  Fitter__Operating_Settings_and_Conditions
  Fitter__Parallel_Compilation
  Fitter__Resource_Section__All_Package_Pins
  Fitter__Resource_Section__Bidir_Pins
  Fitter__Resource_Section__Control_Signals
  Fitter__Resource_Section__Delay_Chain_Summary
  Fitter__Resource_Section__Fitter_Partition_Statistics
  Fitter__Resource_Section__Fitter_RAM_Summary
  Fitter__Resource_Section__Fitter_Resource_Usage_Summary
  Fitter__Resource_Section__Fitter_Resource_Utilization_by_Entity
  Fitter__Resource_Section__GXB_Reports__Optimized_GXB_Elements
  Fitter__Resource_Section__GXB_Reports__Receiver_Channel
  Fitter__Resource_Section__GXB_Reports__Transceiver_Reconfiguration_Report
  Fitter__Resource_Section__GXB_Reports__Transmitter_Channel
  Fitter__Resource_Section__GXB_Reports__Transmitter_PLL
  Fitter__Resource_Section__Global___Other_Fast_Signals
  Fitter__Resource_Section__I_O_Bank_Usage
  Fitter__Resource_Section__Input_Pins
  Fitter__Resource_Section__Logic_and_Routing_Section__Interconnect_Usage_Summary
  Fitter__Resource_Section__Logic_and_Routing_Section__Other_Routing_Usage_Summary
  Fitter__Resource_Section__Non_Global_High_Fan_Out_Signals
  Fitter__Resource_Section__Output_Pins
  Fitter__Resource_Section__PLL_Usage_Summary
  Fitter__Resource_Section__Pad_To_Core_Delay_Chain_Fanout
  Flow_Elapsed_Time
  Flow_Non_Default_Global_Settings
  Flow_OS_Summary
  Flow_Settings
  Flow_Summary
  Non_Default_Global_Settings
  Restore_Archived_Project__Files_Not_Restored
  Restore_Archived_Project__Files_Restored
  Restore_Archived_Project__Restore_Archived_Project_Summary
  TimeQuest_Timing_Analyzer_GUI__Advanced_I_O_Timing__Board_Trace_Model_Assignments
  TimeQuest_Timing_Analyzer_GUI__Advanced_I_O_Timing__Input_Transition_Times
  TimeQuest_Timing_Analyzer_GUI__Advanced_I_O_Timing__Signal_Integrity_Metrics__Signal_Integrity_Metrics__Slow_900mv_85c_Model_
  TimeQuest_Timing_Analyzer_GUI__SDC_File_List
  TimeQuest_Timing_Analyzer_GUI__TimeQuest_Timing_Analyzer_Summary
  TimeQuest_Timing_Analyzer__Advanced_I_O_Timing__Board_Trace_Model_Assignments
  TimeQuest_Timing_Analyzer__Advanced_I_O_Timing__Input_Transition_Times
  TimeQuest_Timing_Analyzer__Advanced_I_O_Timing__Signal_Integrity_Metrics__Signal_Integrity_Metrics__Fast_900mv_0c_Model_
  TimeQuest_Timing_Analyzer__Advanced_I_O_Timing__Signal_Integrity_Metrics__Signal_Integrity_Metrics__Slow_900mv_0c_Model_
  TimeQuest_Timing_Analyzer__Advanced_I_O_Timing__Signal_Integrity_Metrics__Signal_Integrity_Metrics__Slow_900mv_85c_Model_
  TimeQuest_Timing_Analyzer__Clock_Transfers__Hold_Transfers
  TimeQuest_Timing_Analyzer__Clock_Transfers__Recovery_Transfers
  TimeQuest_Timing_Analyzer__Clock_Transfers__Removal_Transfers
  TimeQuest_Timing_Analyzer__Clock_Transfers__Setup_Transfers
  TimeQuest_Timing_Analyzer__Clocks
  TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Clock_to_Output_Times
  TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Hold_Times
  TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Minimum_Clock_to_Output_Times
  TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Minimum_Output_Disable_Times
  TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Minimum_Output_Enable_Times
  TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Output_Disable_Times
  TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Output_Enable_Times
  TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Setup_Times
  TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Hold_Summary
  TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Metastability_Report__Synchronizer_Summary
  TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Minimum_Pulse_Width_Summary
  TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Recovery_Summary
  TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Removal_Summary
  TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Setup_Summary
  TimeQuest_Timing_Analyzer__Multicorner_Datasheet_Report_Summary__Clock_to_Output_Times
  TimeQuest_Timing_Analyzer__Multicorner_Datasheet_Report_Summary__Hold_Times
  TimeQuest_Timing_Analyzer__Multicorner_Datasheet_Report_Summary__Minimum_Clock_to_Output_Times
  TimeQuest_Timing_Analyzer__Multicorner_Datasheet_Report_Summary__Setup_Times
  TimeQuest_Timing_Analyzer__Multicorner_Timing_Analysis_Summary
  TimeQuest_Timing_Analyzer__Parallel_Compilation
  TimeQuest_Timing_Analyzer__SDC_File_List
  TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Clock_to_Output_Times
  TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Hold_Times
  TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Minimum_Clock_to_Output_Times
  TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Minimum_Output_Disable_Times
  TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Minimum_Output_Enable_Times
  TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Output_Disable_Times
  TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Output_Enable_Times
  TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Setup_Times
  TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Fmax_Summary
  TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Hold_Summary
  TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Metastability_Report__Synchronizer_Summary
  TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Minimum_Pulse_Width_Summary
  TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Recovery_Summary
  TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Removal_Summary
  TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Setup_Summary
  TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Clock_to_Output_Times
  TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Hold_Times
  TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Minimum_Clock_to_Output_Times
  TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Minimum_Output_Disable_Times
  TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Minimum_Output_Enable_Times
  TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Output_Disable_Times
  TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Output_Enable_Times
  TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Setup_Times
  TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Fmax_Summary
  TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Hold_Summary
  TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Metastability_Report__Synchronizer_Summary
  TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Minimum_Pulse_Width_Summary
  TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Recovery_Summary
  TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Removal_Summary
  TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Setup_Summary
  TimeQuest_Timing_Analyzer__TimeQuest_Timing_Analyzer_Summary
  TimeQuest_Timing_Analyzer__Unconstrained_Paths
}
run_report [lindex $argv 0]
