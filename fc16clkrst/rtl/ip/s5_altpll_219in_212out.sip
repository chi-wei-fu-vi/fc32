set_global_assignment -entity "s5_altpll_219in_212out" -library "lib_s5_altpll_219in_212out" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "s5_altpll_219in_212out" -library "lib_s5_altpll_219in_212out" -name IP_TOOL_VERSION "13.1"
set_global_assignment -entity "s5_altpll_219in_212out" -library "lib_s5_altpll_219in_212out" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_s5_altpll_219in_212out" -name SPD_FILE [file join $::quartus(sip_path) "s5_altpll_219in_212out.spd"]

set_global_assignment -library "lib_s5_altpll_219in_212out" -name MISC_FILE [file join $::quartus(sip_path) "s5_altpll_219in_212out_sim/s5_altpll_219in_212out.vo"]
