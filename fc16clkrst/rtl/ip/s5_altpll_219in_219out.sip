set_global_assignment -entity "s5_altpll_219in_219out" -library "lib_s5_altpll_219in_219out" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "s5_altpll_219in_219out" -library "lib_s5_altpll_219in_219out" -name IP_TOOL_VERSION "13.1"
set_global_assignment -entity "s5_altpll_219in_219out" -library "lib_s5_altpll_219in_219out" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_s5_altpll_219in_219out" -name SPD_FILE [file join $::quartus(sip_path) "s5_altpll_219in_219out.spd"]

set_global_assignment -library "lib_s5_altpll_219in_219out" -name MISC_FILE [file join $::quartus(sip_path) "s5_altpll_219in_219out_sim/s5_altpll_219in_219out.vo"]
