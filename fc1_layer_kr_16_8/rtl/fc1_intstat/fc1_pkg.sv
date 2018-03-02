//***************************************************************************
// Copyright (c) 2013,2014 Virtual Instruments.
// 25 Metro Dr, STE#400, San Jose, CA 95110
// www.virtualinstruments.com
// $HeadURL: $
// $Author: $
// $Date: $
// $Revision: $
//**************************************************************************/

package fc1_pkg;

typedef struct packed {
	logic [31:0] enc_full_cnt;
	logic [31:0] enc_empty_cnt;
	logic [31:0] corr_event_cnt;
	logic [31:0] uncorr_event_cnt;
	logic [31:0] pcs_los_cnt;
	} fc1_interval_stats;


endpackage
