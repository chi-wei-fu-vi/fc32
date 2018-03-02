/********x******************************************************************
* Copyright (c) 2013 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: fc16_pcie_le.v$
* $Author: honda.yang $
* $Date: 2013-07-01 16:50:28 -0700 (Mon, 01 Jul 2013) $
* $Revision: 2749 $
* Description: Top level of Twelve Link Engines and PCIe modules
*
***************************************************************************/
import fc1_pkg::*;

module fc16_pcie_le #(
        parameter   PCIE_GEN3      =  0, 
        parameter   LINKS          =  12,
        parameter   PORTS          =  12,
				parameter   SIM_ONLY       =  0  )             // One link has control and data ports

(
        output  [69:0] fc_reconfig_to_xcvr,
        input   [45:0] fc_reconfig_from_xcvr,
        input  [LINKS*2-1:0] rx_is_lockedtodata,
        input  [LINKS*2-1:0] fcrxrst_n,

        //////////////////////////////////////////////////////////////////////
        // Resets
        //////////////////////////////////////////////////////////////////////
        input   iRST_NPOR_n,
        input   iPIN_PERST_n,
				input   iRST_PCIE_APP_N,
        
        input   [LINKS-1:0]   iRST_RX_N,
        input   [LINKS-1:0]   iRST_CORE_N,
        input   [LINKS-1:0]   iRST_CORE219_N,
        input   iRST_100M_N,
        input   [LINKS-1:0]   iRST_PCIE_N,
				input   [LINKS-1:0]   iRST_LINK_FC_CORE_N,
				input               iRST_CHIP_PCIE_N,


        
        //////////////////////////////////////////////////////////////////////
        // Clocks
        //////////////////////////////////////////////////////////////////////
        input   iREF_CLK,
        input   iRECONFIG_XCVR_CLK,
        
        input   [LINKS*2-1:0]  iCLK_RX, /* 219MHz */
        input   iCLK_CORE,              /* 212MHz */
        input   iCLK_CORE219,              /* 219MHz */
        input   iCLK_100M,
        input   iCLK_PCIE_GLOBAL,
        
        output  oCLK_PCIE_CORECLKOUT_HIP,
        
        //////////////////////////////////////////////////////////////////////
        // Global
        //////////////////////////////////////////////////////////////////////
        input   [55:0]        iGLOBAL_TIMESTAMP,
        input   iEND_OF_INTERVAL,
        output  [LINKS-1:0][63:0]                         fmac0_xbar_rx_data,
        output  [LINKS-1:0][1:0]                          fmac0_xbar_rx_sh,
        output  [LINKS-1:0]                               fmac0_xbar_rx_valid,
        output  [LINKS-1:0][63:0]                         fmac1_xbar_rx_data,
        output  [LINKS-1:0][1:0]                          fmac1_xbar_rx_sh,
        output  [LINKS-1:0]                               fmac1_xbar_rx_valid,

				output  [LINKS-1:0]   oREG_LINKCTRL_RATESEL,
        
        //////////////////////////////////////////////////////////////////////
        // PCIE High-speed serial lines - direct to pins
        //////////////////////////////////////////////////////////////////////
        input   iHIP_SERIAL_RX_IN0,
        input   iHIP_SERIAL_RX_IN1,
        input   iHIP_SERIAL_RX_IN2,
        input   iHIP_SERIAL_RX_IN3,
        input   iHIP_SERIAL_RX_IN4,
        input   iHIP_SERIAL_RX_IN5,
        input   iHIP_SERIAL_RX_IN6,
        input   iHIP_SERIAL_RX_IN7,
        
        output  wire    oHIP_SERIAL_TX_OUT0,
        output  wire    oHIP_SERIAL_TX_OUT1,
        output  wire    oHIP_SERIAL_TX_OUT2,
        output  wire    oHIP_SERIAL_TX_OUT3,
        output  wire    oHIP_SERIAL_TX_OUT4,
        output  wire    oHIP_SERIAL_TX_OUT5,
        output  wire    oHIP_SERIAL_TX_OUT6,
        output  wire    oHIP_SERIAL_TX_OUT7,
        
        //////////////////////////////////////////////////////////////////////
        //               PIPE simulation I/F (Gen1/2 only)
        //////////////////////////////////////////////////////////////////////
        input   hip_pipe_sim_pipe_pclk_in,
        output  [1:0]        hip_pipe_sim_pipe_rate,
        output  [4:0]        hip_pipe_sim_ltssmstate,
        output  [7:0][2:0]   hip_pipe_eidleinfersel,
        output  [7:0][1:0]   hip_pipe_powerdown,
        output  [7:0]        hip_pipe_rxpolarity,
        output  [7:0]        hip_pipe_txcompl,
        output  [7:0][7:0]   hip_pipe_txdata,
        output  [7:0]        hip_pipe_txdatak,
        output  [7:0]        hip_pipe_txdetectrx,
        output  [7:0]        hip_pipe_txelecidle,
        output  [7:0]        hip_pipe_txdeemph,
        output  [7:0][2:0]   hip_pipe_txmargin,
        output  [7:0]        hip_pipe_txswing,
        input   [7:0]         hip_pipe_phystatus,
        input   [7:0][7:0]    hip_pipe_rxdata,
        input   [7:0]         hip_pipe_rxdatak,
        input   [7:0]         hip_pipe_rxelecidle,
        input   [7:0][2:0]    hip_pipe_rxstatus,
        input   [7:0]         hip_pipe_rxvalid,
        
        //////////////////////////////////////////////////////////////////////
        // test/sim control
        //////////////////////////////////////////////////////////////////////
        input   [31:0]        iHIP_CTRL_TEST_IN,
        input   iHIP_CTRL_SIMU_MODE_PIPE,
        
        //////////////////////////////////////////////////////////////////////
        // debug status
        //////////////////////////////////////////////////////////////////////
        output  [3:0]        oLANE_ACT,
        output  [4:0]        oLTSSM,
        output  [1:0]        oCURRENT_SPEED,
        output  oAPP_RST_n_STATUS,
        output  [31:0]       oPCIE_MISC_STATUS,
        output logic [2*LINKS-1:0]            mtip_enable,
        
        //////////////////////////////////////////////////////////////////////
        // MM DECODE I/F
        //////////////////////////////////////////////////////////////////////
        output  [63:0]       oPCIE2MM_WR_DATA,
        output  [20:0]       oPCIE2MM_ADDRESS,
        output  oPCIE2MM_WR_EN,
        output  oPCIE2MM_RD_EN,
        input   [63:0]        iMM2PCIE_RD_DATA,
        input   iMM2PCIE_RD_DATA_V,
        
        //////////////////////////////////////////////////////////////////////
        // MM I/F
        //////////////////////////////////////////////////////////////////////
        input   [LINKS-1:0][63:0]   iLE_MM_WR_DATA,
        input   [LINKS-1:0][20:0]   iLE_MM_ADDR,
        input   [LINKS-1:0]         iLE_MM_WR_EN,
        input   [LINKS-1:0]         iLE_MM_RD_EN,
        output  [LINKS-1:0][63:0]  oLE_MM_RD_DATA,
        output  [LINKS-1:0]        oLE_MM_RD_DATA_V,
        
        input   [63:0]              iBIST_MM_WR_DATA,
        input   [20:0]              iBIST_MM_ADDR,
        input   iBIST_MM_WR_EN,
        input   iBIST_MM_RD_EN,
        output  [63:0]             oBIST_MM_RD_DATA,
        output  oBIST_MM_RD_DATA_V,
        
        input   [63:0]              iPCIE_MM_WR_DATA,
        input   [20:0]              iPCIE_MM_ADDR,
        input   iPCIE_MM_WR_EN,
        input   iPCIE_MM_RD_EN,
        output  [63:0]             oPCIE_MM_RD_DATA,
        output  oPCIE_MM_RD_DATA_V,
        
        //////////////////////////////////////////////////////////////////////
        // SFP
        //////////////////////////////////////////////////////////////////////
        input   [2*LINKS-1:0]       iSFP_PHY_LOSIG,
        //input   [2*LINKS-1:0]       iLOSYNC,
        
        //////////////////////////////////////////////////////////////////////
        // Serdes
        //////////////////////////////////////////////////////////////////////
        output  [LINKS-1:0][3:0]  oLE_LINKSPEED,
        input   [LINKS-1:0][3:0]  iLE_LINKSPEED,
        
        input   [2*LINKS-1:0]         iFC1_RX_BLOCK_SYNC,
        input   [2*LINKS-1:0]         iFC1_RX_VAL,
        input   [2*LINKS-1:0][1:0]    iFC1_RX_SH,
        input   [2*LINKS-1:0][63:0]   iFC1_RX_DATA,
        //input   fc1_interval_stats [2*LINKS-1:0] iFC1_INT_STATS,
        input logic [2*LINKS-1:0] [31:0] iINT_STATS_FC1_CORR_EVENT_CNT,
        input logic [2*LINKS-1:0] [31:0] iINT_STATS_FC1_UNCORR_EVENT_CNT,
        input logic [2*LINKS-1:0] [31:0] iINT_STATS_FC1_PCS_LOS_CNT,

        
        output  [2*LINKS-1:0][63:0]  oSERDES_MM_WR_DATA,
        output  [2*LINKS-1:0][13:0]  oSERDES_MM_ADDR,
        output  [2*LINKS-1:0]        oSERDES_MM_WR_EN,
        output  [2*LINKS-1:0]        oSERDES_MM_RD_EN,
        input   [2*LINKS-1:0][63:0]   iSERDES_MM_RD_DATA,
        input   [2*LINKS-1:0]         iSERDES_MM_RD_DATA_V,
        
        output  [2*LINKS-1:0][63:0]  oFC1_LAYER_KR_MM_WR_DATA,
        output  [2*LINKS-1:0][13:0]  oFC1_LAYER_KR_MM_ADDR,
        output  [2*LINKS-1:0]        oFC1_LAYER_KR_MM_WR_EN,
        output  [2*LINKS-1:0]        oFC1_LAYER_KR_MM_RD_EN,
        input   [2*LINKS-1:0][63:0]   iFC1_LAYER_KR_MM_RD_DATA,
        input   [2*LINKS-1:0]         iFC1_LAYER_KR_MM_RD_DATA_V,
        
        input   [2*LINKS-1:0][63:0] rx_parallel_data_pma,

        //////////////////////////////////////////////////////////////////////
        // uC Stats
        //////////////////////////////////////////////////////////////////////
        input   [31:0]        iUCSTATS_DATA,
        input   iUCSTATS_GNT,
        output  oLE_UCSTATS_REQ,
        output  [9:0]        oLE_UCSTATS_ADDR,
        output  oLE_UCSTATS_DONE,
        
        input   [31:0]        iUCSTATS_MM_RD_DATA,
        output  [9:0]        oLE_UCSTATS_MM_ADDR
        
);

///////////////////////////////////////////////////////////////////////////////
// Manual Declaration
///////////////////////////////////////////////////////////////////////////////
logic                        interval_any_link_r;
logic [255:0]                bist_dplbuf_data;
logic [LINKS-1:0][255:0]     le_ctl_dat_dplbuf_data;
logic [LINKS-1:0][5:0]       le_ucstats_addr;
logic [LINKS:0]                 le_uc_rd_done;
logic [LINKS-1:0]            le_dat_dplbuf_data_v;
logic [LINKS-1:0]            dat_dplbuf_gnt;
logic [LINKS-1:0]            le_dat_dplbuf_req;
logic                        dplbuf_any_data_vld;
logic [LINKS-1:0]            le_ctl_dplbuf_data_v;
logic [PORTS-1:0]            bist_dplbuf_data_v;
logic [LINKS-1:0]            le_ctl_dplbuf_req;
logic [LINKS-1:0]            ctl_dplbuf_gnt;
logic [LINKS-1:0]            le_ucstats_req;
logic                        ucstats_le_gnt;
logic [31:0]                 ucs_le_mm_rd_data;
logic [2*LINKS-1:0]          ucs_le_mm_rd_data_v;
logic [2*LINKS-1:0]          le_ucs_mm_rd_en;
logic [2*LINKS-1:0][4:0]     le_ucs_mm_addr;
logic [LINKS-1:0][3:0]       le_monitormode;
logic                        all_monitor_mode_off_r;
logic                        all_monitor_mode_off_s;
logic                        end_interval_mask;
reg     [20:0]                 pcie2mm_address_hold;
reg     [63:0]                 pcie2mm_wr_data_hold;
wire    [63:0]                 mm2pcie_rd_data_sync;
reg     [31:0]                 mm2pcie_wr_ack_delay;
wire    mm2pcie_ack_sync;
wire    [20:0]                 pcie2mm_address;       
wire    [63:0]                 pcie2mm_wr_data;
wire    pcie2mm_rd_en_a;       
wire    pcie2mm_wr_en_a;       
wire    [PORTS-1:0]            bist_dplbuf_req;       
wire    [63:0]                 pcie2mm_wr_data_tmp;   
wire    [255:0]                pcie_dplbuf_data;      
wire    [PORTS-1:0]            pcie_dplbuf_data_v;    
wire    [PORTS-1:0]            pcie_dplbuf_gnt;       
wire    [PORTS-1:0]            pcie_dplbuf_req;       

logic [2*LINKS-1:0]            mon_mask;
///////////////////////////////////////////////////////////////////////////////
// End of Interval Mask
///////////////////////////////////////////////////////////////////////////////
// If all link engines have monitor mode OFF, iEND_OF_INTERVAL is gated off.
// Otherwise oLE_UCSTATS_DONE is asserted by the link engine at the end of
// daisy chain.
function all_mode_off;
input   [LINKS-1:0][3:0] monitormode;
integer i;
logic result;
begin
        result =  1'b1;
        for (i =  0; i < LINKS; i++)
        result =  result & ( monitormode[i] == 4'b0 );
        all_mode_off   =  result;
end
endfunction

always @( posedge iCLK_CORE ) begin
  all_monitor_mode_off_s <= all_mode_off( le_monitormode );
  all_monitor_mode_off_r <= all_monitor_mode_off_s;
end

assign  end_interval_mask  =  iEND_OF_INTERVAL & ~all_monitor_mode_off_r;

// End of Interval goes to the first LE
assign  le_uc_rd_done[0]   =  end_interval_mask;

///////////////////////////////////////////////////////////////////////////////
// Multiple Link Engine Instantiation
///////////////////////////////////////////////////////////////////////////////
genvar ii;
generate
for ( ii   =  0; ii<LINKS; ii++ ) begin: le_generate

spd_change #(.SIM_ONLY(SIM_ONLY))
spd_change_inst0 (
  .req_LE_LINKSPEED (oLE_LINKSPEED[ii]),
	.stat_LE_LINKSPEED (iLE_LINKSPEED[ii]),
	.rx_is_lockedtodata(rx_is_lockedtodata[ii*2]),
	.clk(iCLK_CORE),
	.rst_n(iRST_CORE_N[ii]),
	.mon_mask (mon_mask[ii*2]),
	.mtip_enable  (mtip_enable[ii*2])
);

spd_change #(.SIM_ONLY(SIM_ONLY))
spd_change_inst1 (
  .req_LE_LINKSPEED (oLE_LINKSPEED[ii]),
  .stat_LE_LINKSPEED (iLE_LINKSPEED[ii]),
  .rx_is_lockedtodata(rx_is_lockedtodata[ii*2+1]),
  .clk(iCLK_CORE),
  .rst_n(iRST_CORE_N[ii]),
  .mon_mask (mon_mask[ii*2+1]),
  .mtip_enable  (mtip_enable[ii*2+1])
);



        link_engine #(
                . SIM_ONLY                                           ( SIM_ONLY                                           ),
                . LINK_ID                                            ( ii                                                 )
        ) u_link_engine (
				.fcrxrst_n(fcrxrst_n[ii*2+1:ii*2]),
				.mon_mask(mon_mask[ii*2+1:ii*2]),
        .mtip_enable(mtip_enable[ii*2+1:ii*2]),
        .rx_is_lockedtodata (rx_is_lockedtodata[ii*2+1:ii*2]),
        .fmac0_xbar_rx_data(fmac0_xbar_rx_data[ii]),
        .fmac0_xbar_rx_sh(fmac0_xbar_rx_sh[ii]),
        .fmac0_xbar_rx_valid(fmac0_xbar_rx_valid[ii]),
        .fmac1_xbar_rx_data(fmac1_xbar_rx_data[ii]),
        .fmac1_xbar_rx_sh(fmac1_xbar_rx_sh[ii]),
        .fmac1_xbar_rx_valid(fmac1_xbar_rx_valid[ii]),
        .oREG_LINKCTRL_RATESEL(oREG_LINKCTRL_RATESEL[ii]),
                . iCLK_RX                                            ( iCLK_RX[ii*2+1:ii*2]                               ),    // input [1:0]
                . iCLK_CORE                                          ( iCLK_CORE                                          ),    // input
                . iCLK_CORE219                                       ( iCLK_CORE219                                          ),    // input
                . iCLK_PCIE                                          ( iCLK_PCIE_GLOBAL                                   ),    // input
                . iCLK_100M                                          ( iCLK_100M                                          ),    // input
								. iRST_LINK_FC_CORE_N                                ( iRST_LINK_FC_CORE_N[ii]                            ),
                . iRST_100M_N                                        ( iRST_100M_N                                        ),    // input
                . iRST_RX_N                                          ( iRST_RX_N[ii]                                      ),    // input
                . iRST_CORE_N                                        ( iRST_CORE_N[ii]                                    ),    // input
                . iRST_CORE219_N                                     ( iRST_CORE219_N[ii]                                    ),    // input
                . iRST_PCIE_N                                        ( iRST_PCIE_N[ii]                                    ),    // input
                . iLINK_ID                                           ( ii                                                 ),    // input [3:0]
                . iGLOBAL_TIMESTAMP                                  ( iGLOBAL_TIMESTAMP                                  ),    // input [55:0]
                . iEND_OF_INTERVAL                                   ( end_interval_mask                                  ),    // input
                . iMM_WR_DATA                                        ( iLE_MM_WR_DATA[ii]                                 ),    // input [63:0]
                . iMM_ADDR                                           ( iLE_MM_ADDR[ii]                                    ),    // input [16:0]
                . iMM_WR_EN                                          ( iLE_MM_WR_EN[ii]                                   ),    // input
                . iMM_RD_EN                                          ( iLE_MM_RD_EN[ii]                                   ),    // input
                . oMM_RD_DATA                                        ( oLE_MM_RD_DATA[ii]                                 ),    // output [63:0]
                . oMM_RD_DATA_V                                      ( oLE_MM_RD_DATA_V[ii]                               ),    // output
                . rx_parallel_data_pma                               ( rx_parallel_data_pma[ii*2+1:ii*2]                          ),    // input [1:0][63:0]
                . iFC1_RX_BLOCK_SYNC                                 ( iFC1_RX_BLOCK_SYNC[ii*2+1:ii*2]                    ),    // input [1:0]
                . iFC1_RX_VAL                                        ( iFC1_RX_VAL[ii*2+1:ii*2]                           ),    // input [1:0]
                . iFC1_RX_SH                                         ( iFC1_RX_SH[ii*2+1:ii*2]                            ),    // input [1:0][1:0]
                . iFC1_RX_DATA                                       ( iFC1_RX_DATA[ii*2+1:ii*2]                          ),    // input [1:0][63:0]
                //. iCH0_INT_STATS_FC1                                 ( iFC1_INT_STATS[ii*2]                               ),    // fc1_interval_stats    
                //. iCH1_INT_STATS_FC1                                 ( iFC1_INT_STATS[ii*2+1]                             ),    // fc1_interval_stats    
        .iINT_STATS_FC1_CORR_EVENT_CNT(iINT_STATS_FC1_CORR_EVENT_CNT[ii*2+1:ii*2]),
        .iINT_STATS_FC1_UNCORR_EVENT_CNT(iINT_STATS_FC1_UNCORR_EVENT_CNT[ii*2+1:ii*2]),
        .iINT_STATS_FC1_PCS_LOS_CNT(iINT_STATS_FC1_PCS_LOS_CNT[ii*2+1:ii*2]),

                //. iLOSYNC                                            ( iLOSYNC[ii*2+1:ii*2]                               ),    // input [1:0]
                . iSFP_PHY_LOSIG                                     ( iSFP_PHY_LOSIG[ii*2+1:ii*2]                        ),    // input [1:0]
                . oLE_LINKSPEED                                      ( oLE_LINKSPEED[ii]                                  ),    // output [3:0]
                . iLE_LINKSPEED                                      ( iLE_LINKSPEED[ii]                                  ),    // input [3:0]
                . oSERDES_MM_WR_DATA                                 ( oSERDES_MM_WR_DATA[ii*2+1:ii*2]                    ),    // output [1:0][63:0]
                . oSERDES_MM_ADDR                                    ( oSERDES_MM_ADDR[ii*2+1:ii*2]                       ),    // output [1:0][13:0]
                . oSERDES_MM_WR_EN                                   ( oSERDES_MM_WR_EN[ii*2+1:ii*2]                      ),    // output [1:0]
                . oSERDES_MM_RD_EN                                   ( oSERDES_MM_RD_EN[ii*2+1:ii*2]                      ),    // output [1:0]
                . iSERDES_MM_RD_DATA                                 ( iSERDES_MM_RD_DATA[ii*2+1:ii*2]                    ),    // input [1:0][63:0]
                . iSERDES_MM_RD_DATA_V                               ( iSERDES_MM_RD_DATA_V[ii*2+1:ii*2]                  ),    // input [1:0]
                . oFC1_LAYER_KR_MM_WR_DATA                           ( oFC1_LAYER_KR_MM_WR_DATA[ii*2+1:ii*2]              ),    // output [1:0][63:0]
                . oFC1_LAYER_KR_MM_ADDR                              ( oFC1_LAYER_KR_MM_ADDR[ii*2+1:ii*2]                 ),    // output [1:0][13:0]
                . oFC1_LAYER_KR_MM_WR_EN                             ( oFC1_LAYER_KR_MM_WR_EN[ii*2+1:ii*2]                ),    // output [1:0]
                . oFC1_LAYER_KR_MM_RD_EN                             ( oFC1_LAYER_KR_MM_RD_EN[ii*2+1:ii*2]                ),    // output [1:0]
                . iFC1_LAYER_KR_MM_RD_DATA                           ( iFC1_LAYER_KR_MM_RD_DATA[ii*2+1:ii*2]              ),    // input [1:0][63:0]
                . iFC1_LAYER_KR_MM_RD_DATA_V                         ( iFC1_LAYER_KR_MM_RD_DATA_V[ii*2+1:ii*2]            ),    // input [1:0]
                . iDPLBUF_ANY_DATA_VLD                               ( dplbuf_any_data_vld                                ),    // input
                . iDAT_DPLBUF_GNT                                    ( dat_dplbuf_gnt[ii]                                 ),    // input
                . iCTL_DPLBUF_GNT                                    ( ctl_dplbuf_gnt[ii]                                 ),    // input
                . oDAT_DPLBUF_REQ                                    ( le_dat_dplbuf_req[ii]                              ),    // output
                . oDAT_DPLBUF_DATA_V                                 ( le_dat_dplbuf_data_v[ii]                           ),    // output
                . oCTL_DPLBUF_REQ                                    ( le_ctl_dplbuf_req[ii]                              ),    // output
                . oCTL_DAT_DPLBUF_DATA                               ( le_ctl_dat_dplbuf_data[ii]                         ),    // output [255:0]
                . oCTL_DPLBUF_DATA_V                                 ( le_ctl_dplbuf_data_v[ii]                           ),    // output
                . iUCSTATS_DATA                                      ( iUCSTATS_DATA                                      ),    // input [31:0]
                . iUCSTATS_GNT                                       ( ucstats_le_gnt                                     ),    // input
                . oLE_UCSTATS_REQ                                    ( le_ucstats_req[ii]                                 ),    // output
                . oLE_UCSTATS_ADDR                                   ( le_ucstats_addr[ii]                                ),    // output [5:0]
                . iUCS_LE_MM_RD_DATA                                 ( ucs_le_mm_rd_data                                  ),    // input [31:0]
                . iUCS_LE_MM_RD_DATA_V                               ( ucs_le_mm_rd_data_v[ii*2+1:ii*2]                   ),    // input [1:0]
                . oLE_UCS_MM_RD_EN                                   ( le_ucs_mm_rd_en[ii*2+1:ii*2]                       ),    // output [1:0]
                . oLE_UCS_MM_ADDR                                    ( le_ucs_mm_addr[ii*2+1:ii*2]                        ),    // output [1:0][4:0]
                . iLE_UC_RD_START                                    ( le_uc_rd_done[ii]                                  ),    // input
                . iINTERVAL_ANY_LINK                                 ( interval_any_link_r                                ),    // input
                . oLE_UC_RD_DONE                                     ( le_uc_rd_done[ii+1]                                ),    // output
                . oLE_MONITORMODE                                    ( le_monitormode[ii]                                 )     // output [3:0]
        );
end
endgenerate

//always_ff @( posedge iCLK_CORE or negedge iRST_CORE_N )
//    if ( ~iRST_CORE_N )
//        interval_any_link_r <= 1'b0;
//    else begin
//    end
always_ff @( posedge iCLK_CORE)
if ( interval_any_link_r )
        interval_any_link_r <= ~oLE_UCSTATS_DONE;
else
        interval_any_link_r <= end_interval_mask;


///////////////////////////////////////////////////////////////////////////////
// UCSTATS Pipeline Instantiation
///////////////////////////////////////////////////////////////////////////////
/* ucstats_pipe AUTO_TEMPLATE (
    // Inputs
    .iLE_UCSTATS_REQ        ( le_ucstats_req[11:0]                      ),
    .iLE_UCSTATS_ADDR       ( le_ucstats_addr[11:0]                     ),
    .iLAST_LE_UC_RD_DONE    ( le_uc_rd_done[LINKS]                      ),
    .iCLK                   ( iCLK_CORE                                ),
    .iRST_n                 ( iRST_CORE_N                         ),
    .iLE_UCS_MM_RD_EN       ( le_ucs_mm_rd_en                           ),
    .iLE_UCS_MM_ADDR        ( le_ucs_mm_addr[2*LINKS-1:0]               ),
    // Outputs
    .oUCSTATS_LE_GNT        ( ucstats_le_gnt[]                          ),
    .oUCS_LE_MM_RD_DATA     ( ucs_le_mm_rd_data[]                       ),
    .oUCS_LE_MM_RD_DATA_V   ( ucs_le_mm_rd_data_v[]                     ),
   );
*/
ucstats_pipe #( 
        .LINKS         ( LINKS             ) 
) 
u_ucstats_pipe (
        .oUCS_LE_MM_RD_DATA_V	       ( ucs_le_mm_rd_data_v[2*LINKS-1:0]      ),
        /*AUTOINST*/
        // Outputs
        .oLE_UCSTATS_REQ	       (oLE_UCSTATS_REQ),
        .oLE_UCSTATS_ADDR	       (oLE_UCSTATS_ADDR[9:0]),
        .oLE_UCSTATS_DONE	       (oLE_UCSTATS_DONE),
        .oLE_UCSTATS_MM_ADDR	       (oLE_UCSTATS_MM_ADDR[9:0]),
        .oUCSTATS_LE_GNT	       ( ucstats_le_gnt                          ),     // Templated
        .oUCS_LE_MM_RD_DATA	       ( ucs_le_mm_rd_data[31:0]                       ),       // Templated
        // Inputs
        .iCLK			       ( iCLK_CORE                                ),    // Templated
        .iRST_n			       ( iRST_CORE_N                         ),         // Templated
        .iLE_UCSTATS_REQ	       ( le_ucstats_req[11:0]                      ),   // Templated
        .iLE_UCSTATS_ADDR	       ( le_ucstats_addr[11:0]                     ),   // Templated
        .iLAST_LE_UC_RD_DONE	       ( le_uc_rd_done[LINKS]                      ),   // Templated
        .iLE_UCS_MM_RD_EN	       ( le_ucs_mm_rd_en                           ),   // Templated
        .iLE_UCS_MM_ADDR	       ( le_ucs_mm_addr[2*LINKS-1:0]               ),   // Templated
        .iUCSTATS_GNT		       (iUCSTATS_GNT),
        .iUCSTATS_MM_RD_DATA	       (iUCSTATS_MM_RD_DATA[31:0]));

///////////////////////////////////////////////////////////////////////////////
// PCIE BIST Instantiation
///////////////////////////////////////////////////////////////////////////////
/* pcie_mwr_bist_wrap AUTO_TEMPLATE (
    // Inputs
    .iCLK               ( iCLK_PCIE_GLOBAL                          ),
    .iRST               ( ~iRST_NPOR_n                              ),
    .iDPLBUF_GNT        ( pcie_dplbuf_gnt[]                         ),
    .iMM_ADDRESS        ( iBIST_MM_ADDR[]                           ),
    .iMM_\(.*\)         ( iBIST_MM_\1[]                             ),
    // Outputs
    .oMM_\(.*\)         ( oBIST_MM_\1[]                             ),
    .oDPLBUF_DATA       ( bist_dplbuf_data[255:0]                   ),
    .o\(.*\)            ( bist_@"(downcase(substring vl-name 1))"[] ),
   );
*/
pcie_mwr_bist_wrap #(
        .LINKS         ( LINKS             )
)
u_pcie_mwr_bist_wrap (
        /*AUTOINST*/
        // Outputs
        .oMM_RD_DATA	       ( oBIST_MM_RD_DATA[63:0]                             ),  // Templated
        .oMM_RD_DATA_V	       ( oBIST_MM_RD_DATA_V                             ),      // Templated
        .oDPLBUF_REQ	       ( bist_dplbuf_req[LINKS-1:0] ),  // Templated
        .oDPLBUF_DATA	       ( bist_dplbuf_data[255:0]                   ),   // Templated
        .oDPLBUF_DATA_V	       ( bist_dplbuf_data_v[LINKS-1:0] ),               // Templated
        // Inputs
        .iRST		       ( ~iRST_NPOR_n                              ),   // Templated
        .iCLK		       ( iCLK_PCIE_GLOBAL                          ),   // Templated
        .iMM_WR_DATA	       ( iBIST_MM_WR_DATA[63:0]                             ),  // Templated
        .iMM_ADDRESS	       ( iBIST_MM_ADDR[9:0]                           ),        // Templated
        .iMM_WR_EN	       ( iBIST_MM_WR_EN                             ),          // Templated
        .iMM_RD_EN	       ( iBIST_MM_RD_EN                             ),          // Templated
        .iDPLBUF_GNT	       ( pcie_dplbuf_gnt[LINKS-1:0]                         )); // Templated

///////////////////////////////////////////////////////////////////////////////
// PCIE DPLBUF Pipeline Instantiation
///////////////////////////////////////////////////////////////////////////////
/* dplbuf_pipe AUTO_TEMPLATE (
    // Inputs
    .iLE_DPLBUF_REQ         ( le_dat_dplbuf_req[LINKS-1:0]          ),
    .iLE_DPLBUF_DATA_V      ( le_dat_dplbuf_data_v[LINKS-1:0]    ),
    .iLE_DPLBUF_DATA        ( le_ctl_dat_dplbuf_data[11:0]                                          ),
    .iCLK                   ( iCLK_PCIE_GLOBAL                                                      ),
    .iRST_n                 ( iRST_NPOR_n                                                           ),
    .iPCIE_DPLBUF_GNT       ( pcie_dplbuf_gnt[]                                                     ),
    .i\(.*\)                ( @"(downcase(substring vl-name 1))"[]                                  ),
    // Outputs
    .oDPLBUF_ANY_DATA_VLD   ( dplbuf_any_data_vld[]                                                 ),
    .oDAT_DPLBUF_GNT        ( dat_dplbuf_gnt[LINKS-1:0]                ),
    .oPCIE\(.*\)            ( @"(downcase(substring vl-name 1))"[]                                  ),
   );
*/

dplbuf_pipe #(
        .LINKS         ( LINKS             ),
        .PORTS         ( PORTS             )
)
u_dplbuf_pipe (
        /*AUTOINST*/
        // Outputs
        .oPCIE_DPLBUF_DATA	       ( pcie_dplbuf_data[255:0]                                  ),    // Templated
        .oPCIE_DPLBUF_DATA_V	       ( pcie_dplbuf_data_v[PORTS-1:0]                                  ),      // Templated
        .oPCIE_DPLBUF_REQ	       ( pcie_dplbuf_req[PORTS-1:0]                                  ),         // Templated
        .oDPLBUF_ANY_DATA_VLD	       ( dplbuf_any_data_vld                                                 ), // Templated
        .oDAT_DPLBUF_GNT		       ( dat_dplbuf_gnt[LINKS-1:0]                ),       // Templated
        // Inputs
        .iCLK			               ( iCLK_PCIE_GLOBAL                                                      ),       // Templated
        .iRST_n			               ( iRST_NPOR_n                                                           ),       // Templated
        .iLE_DPLBUF_DATA		       ( le_ctl_dat_dplbuf_data[11:0]                                          ),       // Templated
        .iLE_DPLBUF_REQ		               ( le_dat_dplbuf_req[LINKS-1:0]          ),       // Templated
        .iLE_DPLBUF_DATA_V	               ( le_dat_dplbuf_data_v[LINKS-1:0]    ),       // Templated
        .iBIST_DPLBUF_DATA	               ( bist_dplbuf_data[255:0]                                  ),    // Templated
        .iBIST_DPLBUF_REQ	               ( bist_dplbuf_req[PORTS-1:0]                                  ), // Templated
        .iBIST_DPLBUF_DATA_V	               ( bist_dplbuf_data_v[PORTS-1:0]                                  ),      // Templated
        .iPCIE_DPLBUF_GNT	               ( pcie_dplbuf_gnt[PORTS-1:0]                                                     ));     // Templated


generate 

if (SIM_ONLY) begin
///////////////////////////////////////////////////////////////////////////////
// PCIE Instantiation
///////////////////////////////////////////////////////////////////////////////
/* bali_pcie_gen2x8_wrap AUTO_TEMPLATE (
    // Outputs
    .oDPLBUF_GNT            ( pcie_dplbuf_gnt[]                 ),
    // Inputs
    .iRST_PCIE_N            ( {2{iRST_PCIE_N[LINKS-1:0]}}       ),
    .iDPLBUF_REQ            ( pcie_dplbuf_req[]                 ),
    .iDPLBUF_DATA           ( pcie_dplbuf_data[]                ),
    .iDPLBUF_DATA_V         ( pcie_dplbuf_data_v[]              ),
    .hip_pipe_\(.*\)@       ( hip_pipe_\1[\2]                   ),
    .iMM2PCIE_ACK           ( mm2pcie_ack_sync                  ), 
    .iMM2PCIE_RD_DATA       ( mm2pcie_rd_data_sync[63:0]        ),
    .iMM2PCIE_RD_DATA_V     ( mm2pcie_ack_sync                  ),
    .iMM_\(.*\)             ( iPCIE_MM_\1[]                     ),
    .oMM_RD_DATA            ( oPCIE_MM_RD_DATA[]                ),
    .oMM_RD_DATA_V          ( oPCIE_MM_RD_DATA_V                ),
    .oPCIE2MM_WR_EN	        ( pcie2mm_wr_en_a                   ), 
    .oPCIE2MM_RD_EN	        ( pcie2mm_rd_en_a                   ), 
    .oPCIE2MM_WR_DATA       ( pcie2mm_wr_data[]                 ),
    .oPCIE2MM_ADDRESS       ( pcie2mm_address[]                 ),
   );
*/
pcie_gen2x8_13_1 #(
        .PORTS         ( PORTS             ),
        .BALI          ( 1                 )
) 
u_bali_pcie_gen2x8_wrap (
        //.fc_reconfig_to_xcvr   (fc_reconfig_to_xcvr),
        //.fc_reconfig_from_xcvr (fc_reconfig_from_xcvr),
        /*AUTOINST*/
        // Outputs
        .oCLK_PCIE_CORECLKOUT_HIP      (oCLK_PCIE_CORECLKOUT_HIP),
        .oLANE_ACT		       (oLANE_ACT[3:0]),
        .oLTSSM		               (oLTSSM[4:0]),
        .oCURRENT_SPEED	               (oCURRENT_SPEED[1:0]),
        .oAPP_RST_n_STATUS	       (oAPP_RST_n_STATUS),
        .oPCIE_MISC_STATUS	       (oPCIE_MISC_STATUS[31:0]),
        .oPCIE2MM_WR_DATA	       ( pcie2mm_wr_data[63:0]                 ),       // Templated
        .oPCIE2MM_ADDRESS	       ( pcie2mm_address[20:0]                 ),       // Templated
        .oPCIE2MM_WR_EN	               ( pcie2mm_wr_en_a                   ),           // Templated
        .oPCIE2MM_RD_EN	               ( pcie2mm_rd_en_a                   ),           // Templated
        .oMM_RD_DATA		       ( oPCIE_MM_RD_DATA[63:0]                ),       // Templated
        .oMM_RD_DATA_V		       ( oPCIE_MM_RD_DATA_V                ),           // Templated
        .oDPLBUF_GNT		       ( pcie_dplbuf_gnt[PORTS-1:0]                 ),  // Templated
        .oHIP_SERIAL_TX_OUT0	       (oHIP_SERIAL_TX_OUT0),
        .oHIP_SERIAL_TX_OUT1	       (oHIP_SERIAL_TX_OUT1),
        .oHIP_SERIAL_TX_OUT2	       (oHIP_SERIAL_TX_OUT2),
        .oHIP_SERIAL_TX_OUT3	       (oHIP_SERIAL_TX_OUT3),
        .oHIP_SERIAL_TX_OUT4	       (oHIP_SERIAL_TX_OUT4),
        .oHIP_SERIAL_TX_OUT5	       (oHIP_SERIAL_TX_OUT5),
        .oHIP_SERIAL_TX_OUT6	       (oHIP_SERIAL_TX_OUT6),
        .oHIP_SERIAL_TX_OUT7	       (oHIP_SERIAL_TX_OUT7),
        .hip_pipe_sim_pipe_rate        (hip_pipe_sim_pipe_rate[1:0]),
        .hip_pipe_sim_ltssmstate       (hip_pipe_sim_ltssmstate[4:0]),
        .hip_pipe_eidleinfersel0       ( hip_pipe_eidleinfersel[0]                   ), // Templated
        .hip_pipe_eidleinfersel1       ( hip_pipe_eidleinfersel[1]                   ), // Templated
        .hip_pipe_eidleinfersel2       ( hip_pipe_eidleinfersel[2]                   ), // Templated
        .hip_pipe_eidleinfersel3       ( hip_pipe_eidleinfersel[3]                   ), // Templated
        .hip_pipe_eidleinfersel4       ( hip_pipe_eidleinfersel[4]                   ), // Templated
        .hip_pipe_eidleinfersel5       ( hip_pipe_eidleinfersel[5]                   ), // Templated
        .hip_pipe_eidleinfersel6       ( hip_pipe_eidleinfersel[6]                   ), // Templated
        .hip_pipe_eidleinfersel7       ( hip_pipe_eidleinfersel[7]                   ), // Templated
        .hip_pipe_powerdown0	       ( hip_pipe_powerdown[0]                   ),     // Templated
        .hip_pipe_powerdown1	       ( hip_pipe_powerdown[1]                   ),     // Templated
        .hip_pipe_powerdown2	       ( hip_pipe_powerdown[2]                   ),     // Templated
        .hip_pipe_powerdown3	       ( hip_pipe_powerdown[3]                   ),     // Templated
        .hip_pipe_powerdown4	       ( hip_pipe_powerdown[4]                   ),     // Templated
        .hip_pipe_powerdown5	       ( hip_pipe_powerdown[5]                   ),     // Templated
        .hip_pipe_powerdown6	       ( hip_pipe_powerdown[6]                   ),     // Templated
        .hip_pipe_powerdown7	       ( hip_pipe_powerdown[7]                   ),     // Templated
        .hip_pipe_rxpolarity0	       ( hip_pipe_rxpolarity[0]                   ),    // Templated
        .hip_pipe_rxpolarity1	       ( hip_pipe_rxpolarity[1]                   ),    // Templated
        .hip_pipe_rxpolarity2	       ( hip_pipe_rxpolarity[2]                   ),    // Templated
        .hip_pipe_rxpolarity3	       ( hip_pipe_rxpolarity[3]                   ),    // Templated
        .hip_pipe_rxpolarity4	       ( hip_pipe_rxpolarity[4]                   ),    // Templated
        .hip_pipe_rxpolarity5	       ( hip_pipe_rxpolarity[5]                   ),    // Templated
        .hip_pipe_rxpolarity6	       ( hip_pipe_rxpolarity[6]                   ),    // Templated
        .hip_pipe_rxpolarity7	       ( hip_pipe_rxpolarity[7]                   ),    // Templated
        .hip_pipe_txcompl0	       ( hip_pipe_txcompl[0]                   ),       // Templated
        .hip_pipe_txcompl1	       ( hip_pipe_txcompl[1]                   ),       // Templated
        .hip_pipe_txcompl2	       ( hip_pipe_txcompl[2]                   ),       // Templated
        .hip_pipe_txcompl3	       ( hip_pipe_txcompl[3]                   ),       // Templated
        .hip_pipe_txcompl4	       ( hip_pipe_txcompl[4]                   ),       // Templated
        .hip_pipe_txcompl5	       ( hip_pipe_txcompl[5]                   ),       // Templated
        .hip_pipe_txcompl6	       ( hip_pipe_txcompl[6]                   ),       // Templated
        .hip_pipe_txcompl7	       ( hip_pipe_txcompl[7]                   ),       // Templated
        .hip_pipe_txdata0	       ( hip_pipe_txdata[0]                   ),        // Templated
        .hip_pipe_txdata1	       ( hip_pipe_txdata[1]                   ),        // Templated
        .hip_pipe_txdata2	       ( hip_pipe_txdata[2]                   ),        // Templated
        .hip_pipe_txdata3	       ( hip_pipe_txdata[3]                   ),        // Templated
        .hip_pipe_txdata4	       ( hip_pipe_txdata[4]                   ),        // Templated
        .hip_pipe_txdata5	       ( hip_pipe_txdata[5]                   ),        // Templated
        .hip_pipe_txdata6	       ( hip_pipe_txdata[6]                   ),        // Templated
        .hip_pipe_txdata7	       ( hip_pipe_txdata[7]                   ),        // Templated
        .hip_pipe_txdatak0	       ( hip_pipe_txdatak[0]                   ),       // Templated
        .hip_pipe_txdatak1	       ( hip_pipe_txdatak[1]                   ),       // Templated
        .hip_pipe_txdatak2	       ( hip_pipe_txdatak[2]                   ),       // Templated
        .hip_pipe_txdatak3	       ( hip_pipe_txdatak[3]                   ),       // Templated
        .hip_pipe_txdatak4	       ( hip_pipe_txdatak[4]                   ),       // Templated
        .hip_pipe_txdatak5	       ( hip_pipe_txdatak[5]                   ),       // Templated
        .hip_pipe_txdatak6	       ( hip_pipe_txdatak[6]                   ),       // Templated
        .hip_pipe_txdatak7	       ( hip_pipe_txdatak[7]                   ),       // Templated
        .hip_pipe_txdetectrx0	       ( hip_pipe_txdetectrx[0]                   ),    // Templated
        .hip_pipe_txdetectrx1	       ( hip_pipe_txdetectrx[1]                   ),    // Templated
        .hip_pipe_txdetectrx2	       ( hip_pipe_txdetectrx[2]                   ),    // Templated
        .hip_pipe_txdetectrx3	       ( hip_pipe_txdetectrx[3]                   ),    // Templated
        .hip_pipe_txdetectrx4	       ( hip_pipe_txdetectrx[4]                   ),    // Templated
        .hip_pipe_txdetectrx5	       ( hip_pipe_txdetectrx[5]                   ),    // Templated
        .hip_pipe_txdetectrx6	       ( hip_pipe_txdetectrx[6]                   ),    // Templated
        .hip_pipe_txdetectrx7	       ( hip_pipe_txdetectrx[7]                   ),    // Templated
        .hip_pipe_txelecidle0	       ( hip_pipe_txelecidle[0]                   ),    // Templated
        .hip_pipe_txelecidle1	       ( hip_pipe_txelecidle[1]                   ),    // Templated
        .hip_pipe_txelecidle2	       ( hip_pipe_txelecidle[2]                   ),    // Templated
        .hip_pipe_txelecidle3	       ( hip_pipe_txelecidle[3]                   ),    // Templated
        .hip_pipe_txelecidle4	       ( hip_pipe_txelecidle[4]                   ),    // Templated
        .hip_pipe_txelecidle5	       ( hip_pipe_txelecidle[5]                   ),    // Templated
        .hip_pipe_txelecidle6	       ( hip_pipe_txelecidle[6]                   ),    // Templated
        .hip_pipe_txelecidle7	       ( hip_pipe_txelecidle[7]                   ),    // Templated
        .hip_pipe_txdeemph0	       ( hip_pipe_txdeemph[0]                   ),      // Templated
        .hip_pipe_txdeemph1	       ( hip_pipe_txdeemph[1]                   ),      // Templated
        .hip_pipe_txdeemph2	       ( hip_pipe_txdeemph[2]                   ),      // Templated
        .hip_pipe_txdeemph3	       ( hip_pipe_txdeemph[3]                   ),      // Templated
        .hip_pipe_txdeemph4	       ( hip_pipe_txdeemph[4]                   ),      // Templated
        .hip_pipe_txdeemph5	       ( hip_pipe_txdeemph[5]                   ),      // Templated
        .hip_pipe_txdeemph6	       ( hip_pipe_txdeemph[6]                   ),      // Templated
        .hip_pipe_txdeemph7	       ( hip_pipe_txdeemph[7]                   ),      // Templated
        .hip_pipe_txmargin0	       ( hip_pipe_txmargin[0]                   ),      // Templated
        .hip_pipe_txmargin1	       ( hip_pipe_txmargin[1]                   ),      // Templated
        .hip_pipe_txmargin2	       ( hip_pipe_txmargin[2]                   ),      // Templated
        .hip_pipe_txmargin3	       ( hip_pipe_txmargin[3]                   ),      // Templated
        .hip_pipe_txmargin4	       ( hip_pipe_txmargin[4]                   ),      // Templated
        .hip_pipe_txmargin5	       ( hip_pipe_txmargin[5]                   ),      // Templated
        .hip_pipe_txmargin6	       ( hip_pipe_txmargin[6]                   ),      // Templated
        .hip_pipe_txmargin7	       ( hip_pipe_txmargin[7]                   ),      // Templated
        .hip_pipe_txswing0	       ( hip_pipe_txswing[0]                   ),       // Templated
        .hip_pipe_txswing1	       ( hip_pipe_txswing[1]                   ),       // Templated
        .hip_pipe_txswing2	       ( hip_pipe_txswing[2]                   ),       // Templated
        .hip_pipe_txswing3	       ( hip_pipe_txswing[3]                   ),       // Templated
        .hip_pipe_txswing4	       ( hip_pipe_txswing[4]                   ),       // Templated
        .hip_pipe_txswing5	       ( hip_pipe_txswing[5]                   ),       // Templated
        .hip_pipe_txswing6	       ( hip_pipe_txswing[6]                   ),       // Templated
        .hip_pipe_txswing7	       ( hip_pipe_txswing[7]                   ),       // Templated
        // Inputs
				.iRST_CHIP_PCIE_N      (iRST_CHIP_PCIE_N),
        .iRST_NPOR_n		       (iRST_NPOR_n),
        .iPIN_PERST_n		       (iPIN_PERST_n),
        .iRST_100M_N		       (iRST_100M_N),
        .iRST_PCIE_N		       ( {2{iRST_PCIE_N[LINKS-1:0]}}       ),   // Templated
        .iREF_CLK		       (iREF_CLK),
        .iCLK_PCIE_GLOBAL	       (iCLK_PCIE_GLOBAL),
        .iCLK_100M		       (iCLK_100M),
        .iRECONFIG_XCVR_CLK	       (iRECONFIG_XCVR_CLK),
        .iHIP_CTRL_TEST_IN	       (iHIP_CTRL_TEST_IN[31:0]),
        .iHIP_CTRL_SIMU_MODE_PIPE      (iHIP_CTRL_SIMU_MODE_PIPE),
        .iMM2PCIE_ACK		       ( mm2pcie_ack_sync                  ),   // Templated
        .iMM2PCIE_RD_DATA	       ( mm2pcie_rd_data_sync[63:0]        ),   // Templated
        .iMM_WR_DATA		       ( iPCIE_MM_WR_DATA[63:0]                     ),  // Templated
        .iMM_ADDR		       ( iPCIE_MM_ADDR[20:0]                     ),     // Templated
        .iMM_WR_EN		       ( iPCIE_MM_WR_EN                     ),          // Templated
        .iMM_RD_EN		       ( iPCIE_MM_RD_EN                     ),          // Templated
        .iDPLBUF_REQ		       ( pcie_dplbuf_req[PORTS-1:0]                 ),  // Templated
        .iDPLBUF_DATA		       ( pcie_dplbuf_data[255:0]                ),      // Templated
        .iDPLBUF_DATA_V	               ( pcie_dplbuf_data_v[PORTS-1:0]              ),  // Templated
        .iHIP_SERIAL_RX_IN0	       (iHIP_SERIAL_RX_IN0),
        .iHIP_SERIAL_RX_IN1	       (iHIP_SERIAL_RX_IN1),
        .iHIP_SERIAL_RX_IN2	       (iHIP_SERIAL_RX_IN2),
        .iHIP_SERIAL_RX_IN3	       (iHIP_SERIAL_RX_IN3),
        .iHIP_SERIAL_RX_IN4	       (iHIP_SERIAL_RX_IN4),
        .iHIP_SERIAL_RX_IN5	       (iHIP_SERIAL_RX_IN5),
        .iHIP_SERIAL_RX_IN6	       (iHIP_SERIAL_RX_IN6),
        .iHIP_SERIAL_RX_IN7	       (iHIP_SERIAL_RX_IN7),
        .hip_pipe_sim_pipe_pclk_in     (hip_pipe_sim_pipe_pclk_in),
        .hip_pipe_phystatus0	       ( hip_pipe_phystatus[0]                   ),     // Templated
        .hip_pipe_phystatus1	       ( hip_pipe_phystatus[1]                   ),     // Templated
        .hip_pipe_phystatus2	       ( hip_pipe_phystatus[2]                   ),     // Templated
        .hip_pipe_phystatus3	       ( hip_pipe_phystatus[3]                   ),     // Templated
        .hip_pipe_phystatus4	       ( hip_pipe_phystatus[4]                   ),     // Templated
        .hip_pipe_phystatus5	       ( hip_pipe_phystatus[5]                   ),     // Templated
        .hip_pipe_phystatus6	       ( hip_pipe_phystatus[6]                   ),     // Templated
        .hip_pipe_phystatus7	       ( hip_pipe_phystatus[7]                   ),     // Templated
        .hip_pipe_rxdata0	       ( hip_pipe_rxdata[0]                   ),        // Templated
        .hip_pipe_rxdata1	       ( hip_pipe_rxdata[1]                   ),        // Templated
        .hip_pipe_rxdata2	       ( hip_pipe_rxdata[2]                   ),        // Templated
        .hip_pipe_rxdata3	       ( hip_pipe_rxdata[3]                   ),        // Templated
        .hip_pipe_rxdata4	       ( hip_pipe_rxdata[4]                   ),        // Templated
        .hip_pipe_rxdata5	       ( hip_pipe_rxdata[5]                   ),        // Templated
        .hip_pipe_rxdata6	       ( hip_pipe_rxdata[6]                   ),        // Templated
        .hip_pipe_rxdata7	       ( hip_pipe_rxdata[7]                   ),        // Templated
        .hip_pipe_rxdatak0	       ( hip_pipe_rxdatak[0]                   ),       // Templated
        .hip_pipe_rxdatak1	       ( hip_pipe_rxdatak[1]                   ),       // Templated
        .hip_pipe_rxdatak2	       ( hip_pipe_rxdatak[2]                   ),       // Templated
        .hip_pipe_rxdatak3	       ( hip_pipe_rxdatak[3]                   ),       // Templated
        .hip_pipe_rxdatak4	       ( hip_pipe_rxdatak[4]                   ),       // Templated
        .hip_pipe_rxdatak5	       ( hip_pipe_rxdatak[5]                   ),       // Templated
        .hip_pipe_rxdatak6	       ( hip_pipe_rxdatak[6]                   ),       // Templated
        .hip_pipe_rxdatak7	       ( hip_pipe_rxdatak[7]                   ),       // Templated
        .hip_pipe_rxelecidle0	       ( hip_pipe_rxelecidle[0]                   ),    // Templated
        .hip_pipe_rxelecidle1	       ( hip_pipe_rxelecidle[1]                   ),    // Templated
        .hip_pipe_rxelecidle2	       ( hip_pipe_rxelecidle[2]                   ),    // Templated
        .hip_pipe_rxelecidle3	       ( hip_pipe_rxelecidle[3]                   ),    // Templated
        .hip_pipe_rxelecidle4	       ( hip_pipe_rxelecidle[4]                   ),    // Templated
        .hip_pipe_rxelecidle5	       ( hip_pipe_rxelecidle[5]                   ),    // Templated
        .hip_pipe_rxelecidle6	       ( hip_pipe_rxelecidle[6]                   ),    // Templated
        .hip_pipe_rxelecidle7	       ( hip_pipe_rxelecidle[7]                   ),    // Templated
        .hip_pipe_rxstatus0	       ( hip_pipe_rxstatus[0]                   ),      // Templated
        .hip_pipe_rxstatus1	       ( hip_pipe_rxstatus[1]                   ),      // Templated
        .hip_pipe_rxstatus2	       ( hip_pipe_rxstatus[2]                   ),      // Templated
        .hip_pipe_rxstatus3	       ( hip_pipe_rxstatus[3]                   ),      // Templated
        .hip_pipe_rxstatus4	       ( hip_pipe_rxstatus[4]                   ),      // Templated
        .hip_pipe_rxstatus5	       ( hip_pipe_rxstatus[5]                   ),      // Templated
        .hip_pipe_rxstatus6	       ( hip_pipe_rxstatus[6]                   ),      // Templated
        .hip_pipe_rxstatus7	       ( hip_pipe_rxstatus[7]                   ),      // Templated
        .hip_pipe_rxvalid0	       ( hip_pipe_rxvalid[0]                   ),       // Templated
        .hip_pipe_rxvalid1	       ( hip_pipe_rxvalid[1]                   ),       // Templated
        .hip_pipe_rxvalid2	       ( hip_pipe_rxvalid[2]                   ),       // Templated
        .hip_pipe_rxvalid3	       ( hip_pipe_rxvalid[3]                   ),       // Templated
        .hip_pipe_rxvalid4	       ( hip_pipe_rxvalid[4]                   ),       // Templated
        .hip_pipe_rxvalid5	       ( hip_pipe_rxvalid[5]                   ),       // Templated
        .hip_pipe_rxvalid6	       ( hip_pipe_rxvalid[6]                   ),       // Templated
        .hip_pipe_rxvalid7	       ( hip_pipe_rxvalid[7]                   ));      // Templated

end

//GEN3 instantiation
else if (PCIE_GEN3) begin

///////////////////////////////////////////////////////////////////////////////
// PCIE Instantiation
///////////////////////////////////////////////////////////////////////////////
/* bali_pcie_gen3x8_wrap AUTO_TEMPLATE (
    // Outputs
    .oDPLBUF_GNT            ( pcie_dplbuf_gnt[]                 ),
    // Inputs
    .iRST_PCIE_N            ( {2{iRST_PCIE_N[LINKS-1:0]}}       ),
    .iDPLBUF_REQ            ( pcie_dplbuf_req[]                 ),
    .iDPLBUF_DATA           ( pcie_dplbuf_data[]                ),
    .iDPLBUF_DATA_V         ( pcie_dplbuf_data_v[]              ),
    .hip_pipe_\(.*\)@       ( hip_pipe_\1[\2]                   ),
    .iMM2PCIE_ACK           ( mm2pcie_ack_sync                  ), 
    .iMM2PCIE_RD_DATA       ( mm2pcie_rd_data_sync[63:0]        ),
    .iMM2PCIE_RD_DATA_V     ( mm2pcie_ack_sync                  ),
    .iMM_\(.*\)             ( iPCIE_MM_\1[]                     ),
    .oMM_RD_DATA            ( oPCIE_MM_RD_DATA[]                ),
    .oMM_RD_DATA_V          ( oPCIE_MM_RD_DATA_V                ),
    .oPCIE2MM_WR_EN	        ( pcie2mm_wr_en_a                   ), 
    .oPCIE2MM_RD_EN	        ( pcie2mm_rd_en_a                   ), 
    .oPCIE2MM_WR_DATA       ( pcie2mm_wr_data[]                 ),
    .oPCIE2MM_ADDRESS       ( pcie2mm_address[]                 ),
   );
*/
pcie4_uscale_plus_1 your_instance_name (
  .pci_exp_txn(pci_exp_txn),                                                                      // output wire [7 : 0] pci_exp_txn
  .pci_exp_txp(pci_exp_txp),                                                                      // output wire [7 : 0] pci_exp_txp
  .pci_exp_rxn(pci_exp_rxn),                                                                      // input wire [7 : 0] pci_exp_rxn
  .pci_exp_rxp(pci_exp_rxp),                                                                      // input wire [7 : 0] pci_exp_rxp
  .user_clk(user_clk),                                                                            // output wire user_clk
  .user_reset(user_reset),                                                                        // output wire user_reset
  .user_lnk_up(user_lnk_up),                                                                      // output wire user_lnk_up
  .s_axis_rq_tdata(s_axis_rq_tdata),                                                              // input wire [255 : 0] s_axis_rq_tdata
  .s_axis_rq_tkeep(s_axis_rq_tkeep),                                                              // input wire [7 : 0] s_axis_rq_tkeep
  .s_axis_rq_tlast(s_axis_rq_tlast),                                                              // input wire s_axis_rq_tlast
  .s_axis_rq_tready(s_axis_rq_tready),                                                            // output wire [3 : 0] s_axis_rq_tready
  .s_axis_rq_tuser(s_axis_rq_tuser),                                                              // input wire [61 : 0] s_axis_rq_tuser
  .s_axis_rq_tvalid(s_axis_rq_tvalid),                                                            // input wire s_axis_rq_tvalid
  .m_axis_rc_tdata(m_axis_rc_tdata),                                                              // output wire [255 : 0] m_axis_rc_tdata
  .m_axis_rc_tkeep(m_axis_rc_tkeep),                                                              // output wire [7 : 0] m_axis_rc_tkeep
  .m_axis_rc_tlast(m_axis_rc_tlast),                                                              // output wire m_axis_rc_tlast
  .m_axis_rc_tready(m_axis_rc_tready),                                                            // input wire m_axis_rc_tready
  .m_axis_rc_tuser(m_axis_rc_tuser),                                                              // output wire [74 : 0] m_axis_rc_tuser
  .m_axis_rc_tvalid(m_axis_rc_tvalid),                                                            // output wire m_axis_rc_tvalid
  .m_axis_cq_tdata(m_axis_cq_tdata),                                                              // output wire [255 : 0] m_axis_cq_tdata
  .m_axis_cq_tkeep(m_axis_cq_tkeep),                                                              // output wire [7 : 0] m_axis_cq_tkeep
  .m_axis_cq_tlast(m_axis_cq_tlast),                                                              // output wire m_axis_cq_tlast
  .m_axis_cq_tready(m_axis_cq_tready),                                                            // input wire m_axis_cq_tready
  .m_axis_cq_tuser(m_axis_cq_tuser),                                                              // output wire [87 : 0] m_axis_cq_tuser
  .m_axis_cq_tvalid(m_axis_cq_tvalid),                                                            // output wire m_axis_cq_tvalid
  .s_axis_cc_tdata(s_axis_cc_tdata),                                                              // input wire [255 : 0] s_axis_cc_tdata
  .s_axis_cc_tkeep(s_axis_cc_tkeep),                                                              // input wire [7 : 0] s_axis_cc_tkeep
  .s_axis_cc_tlast(s_axis_cc_tlast),                                                              // input wire s_axis_cc_tlast
  .s_axis_cc_tready(s_axis_cc_tready),                                                            // output wire [3 : 0] s_axis_cc_tready
  .s_axis_cc_tuser(s_axis_cc_tuser),                                                              // input wire [32 : 0] s_axis_cc_tuser
  .s_axis_cc_tvalid(s_axis_cc_tvalid),                                                            // input wire s_axis_cc_tvalid
  .pcie_rq_seq_num0(pcie_rq_seq_num0),                                                            // output wire [5 : 0] pcie_rq_seq_num0
  .pcie_rq_seq_num_vld0(pcie_rq_seq_num_vld0),                                                    // output wire pcie_rq_seq_num_vld0
  .pcie_rq_seq_num1(pcie_rq_seq_num1),                                                            // output wire [5 : 0] pcie_rq_seq_num1
  .pcie_rq_seq_num_vld1(pcie_rq_seq_num_vld1),                                                    // output wire pcie_rq_seq_num_vld1
  .pcie_rq_tag0(pcie_rq_tag0),                                                                    // output wire [7 : 0] pcie_rq_tag0
  .pcie_rq_tag1(pcie_rq_tag1),                                                                    // output wire [7 : 0] pcie_rq_tag1
  .pcie_rq_tag_av(pcie_rq_tag_av),                                                                // output wire [3 : 0] pcie_rq_tag_av
  .pcie_rq_tag_vld0(pcie_rq_tag_vld0),                                                            // output wire pcie_rq_tag_vld0
  .pcie_rq_tag_vld1(pcie_rq_tag_vld1),                                                            // output wire pcie_rq_tag_vld1
  .pcie_tfc_nph_av(pcie_tfc_nph_av),                                                              // output wire [3 : 0] pcie_tfc_nph_av
  .pcie_tfc_npd_av(pcie_tfc_npd_av),                                                              // output wire [3 : 0] pcie_tfc_npd_av
  .pcie_cq_np_req(pcie_cq_np_req),                                                                // input wire [1 : 0] pcie_cq_np_req
  .pcie_cq_np_req_count(pcie_cq_np_req_count),                                                    // output wire [5 : 0] pcie_cq_np_req_count
  .cfg_phy_link_down(cfg_phy_link_down),                                                          // output wire cfg_phy_link_down
  .cfg_phy_link_status(cfg_phy_link_status),                                                      // output wire [1 : 0] cfg_phy_link_status
  .cfg_negotiated_width(cfg_negotiated_width),                                                    // output wire [2 : 0] cfg_negotiated_width
  .cfg_current_speed(cfg_current_speed),                                                          // output wire [1 : 0] cfg_current_speed
  .cfg_max_payload(cfg_max_payload),                                                              // output wire [1 : 0] cfg_max_payload
  .cfg_max_read_req(cfg_max_read_req),                                                            // output wire [2 : 0] cfg_max_read_req
  .cfg_function_status(cfg_function_status),                                                      // output wire [15 : 0] cfg_function_status
  .cfg_function_power_state(cfg_function_power_state),                                            // output wire [11 : 0] cfg_function_power_state
  .cfg_vf_status(cfg_vf_status),                                                                  // output wire [503 : 0] cfg_vf_status
  .cfg_vf_power_state(cfg_vf_power_state),                                                        // output wire [755 : 0] cfg_vf_power_state
  .cfg_link_power_state(cfg_link_power_state),                                                    // output wire [1 : 0] cfg_link_power_state
  .cfg_mgmt_addr(cfg_mgmt_addr),                                                                  // input wire [9 : 0] cfg_mgmt_addr
  .cfg_mgmt_function_number(cfg_mgmt_function_number),                                            // input wire [7 : 0] cfg_mgmt_function_number
  .cfg_mgmt_write(cfg_mgmt_write),                                                                // input wire cfg_mgmt_write
  .cfg_mgmt_write_data(cfg_mgmt_write_data),                                                      // input wire [31 : 0] cfg_mgmt_write_data
  .cfg_mgmt_byte_enable(cfg_mgmt_byte_enable),                                                    // input wire [3 : 0] cfg_mgmt_byte_enable
  .cfg_mgmt_read(cfg_mgmt_read),                                                                  // input wire cfg_mgmt_read
  .cfg_mgmt_read_data(cfg_mgmt_read_data),                                                        // output wire [31 : 0] cfg_mgmt_read_data
  .cfg_mgmt_read_write_done(cfg_mgmt_read_write_done),                                            // output wire cfg_mgmt_read_write_done
  .cfg_mgmt_debug_access(cfg_mgmt_debug_access),                                                  // input wire cfg_mgmt_debug_access
  .cfg_err_cor_out(cfg_err_cor_out),                                                              // output wire cfg_err_cor_out
  .cfg_err_nonfatal_out(cfg_err_nonfatal_out),                                                    // output wire cfg_err_nonfatal_out
  .cfg_err_fatal_out(cfg_err_fatal_out),                                                          // output wire cfg_err_fatal_out
  .cfg_local_error_valid(cfg_local_error_valid),                                                  // output wire cfg_local_error_valid
  .cfg_local_error_out(cfg_local_error_out),                                                      // output wire [4 : 0] cfg_local_error_out
  .cfg_ltssm_state(cfg_ltssm_state),                                                              // output wire [5 : 0] cfg_ltssm_state
  .cfg_rx_pm_state(cfg_rx_pm_state),                                                              // output wire [1 : 0] cfg_rx_pm_state
  .cfg_tx_pm_state(cfg_tx_pm_state),                                                              // output wire [1 : 0] cfg_tx_pm_state
  .cfg_rcb_status(cfg_rcb_status),                                                                // output wire [3 : 0] cfg_rcb_status
  .cfg_obff_enable(cfg_obff_enable),                                                              // output wire [1 : 0] cfg_obff_enable
  .cfg_pl_status_change(cfg_pl_status_change),                                                    // output wire cfg_pl_status_change
  .cfg_tph_requester_enable(cfg_tph_requester_enable),                                            // output wire [3 : 0] cfg_tph_requester_enable
  .cfg_tph_st_mode(cfg_tph_st_mode),                                                              // output wire [11 : 0] cfg_tph_st_mode
  .cfg_vf_tph_requester_enable(cfg_vf_tph_requester_enable),                                      // output wire [251 : 0] cfg_vf_tph_requester_enable
  .cfg_vf_tph_st_mode(cfg_vf_tph_st_mode),                                                        // output wire [755 : 0] cfg_vf_tph_st_mode
  .cfg_msg_received(cfg_msg_received),                                                            // output wire cfg_msg_received
  .cfg_msg_received_data(cfg_msg_received_data),                                                  // output wire [7 : 0] cfg_msg_received_data
  .cfg_msg_received_type(cfg_msg_received_type),                                                  // output wire [4 : 0] cfg_msg_received_type
  .cfg_msg_transmit(cfg_msg_transmit),                                                            // input wire cfg_msg_transmit
  .cfg_msg_transmit_type(cfg_msg_transmit_type),                                                  // input wire [2 : 0] cfg_msg_transmit_type
  .cfg_msg_transmit_data(cfg_msg_transmit_data),                                                  // input wire [31 : 0] cfg_msg_transmit_data
  .cfg_msg_transmit_done(cfg_msg_transmit_done),                                                  // output wire cfg_msg_transmit_done
  .cfg_fc_ph(cfg_fc_ph),                                                                          // output wire [7 : 0] cfg_fc_ph
  .cfg_fc_pd(cfg_fc_pd),                                                                          // output wire [11 : 0] cfg_fc_pd
  .cfg_fc_nph(cfg_fc_nph),                                                                        // output wire [7 : 0] cfg_fc_nph
  .cfg_fc_npd(cfg_fc_npd),                                                                        // output wire [11 : 0] cfg_fc_npd
  .cfg_fc_cplh(cfg_fc_cplh),                                                                      // output wire [7 : 0] cfg_fc_cplh
  .cfg_fc_cpld(cfg_fc_cpld),                                                                      // output wire [11 : 0] cfg_fc_cpld
  .cfg_fc_sel(cfg_fc_sel),                                                                        // input wire [2 : 0] cfg_fc_sel
  .cfg_dsn(cfg_dsn),                                                                              // input wire [63 : 0] cfg_dsn
  .cfg_bus_number(cfg_bus_number),                                                                // output wire [7 : 0] cfg_bus_number
  .cfg_power_state_change_ack(cfg_power_state_change_ack),                                        // input wire cfg_power_state_change_ack
  .cfg_power_state_change_interrupt(cfg_power_state_change_interrupt),                            // output wire cfg_power_state_change_interrupt
  .cfg_err_cor_in(cfg_err_cor_in),                                                                // input wire cfg_err_cor_in
  .cfg_err_uncor_in(cfg_err_uncor_in),                                                            // input wire cfg_err_uncor_in
  .cfg_flr_in_process(cfg_flr_in_process),                                                        // output wire [3 : 0] cfg_flr_in_process
  .cfg_flr_done(cfg_flr_done),                                                                    // input wire [3 : 0] cfg_flr_done
  .cfg_vf_flr_in_process(cfg_vf_flr_in_process),                                                  // output wire [251 : 0] cfg_vf_flr_in_process
  .cfg_vf_flr_func_num(cfg_vf_flr_func_num),                                                      // input wire [7 : 0] cfg_vf_flr_func_num
  .cfg_vf_flr_done(cfg_vf_flr_done),                                                              // input wire [0 : 0] cfg_vf_flr_done
  .cfg_link_training_enable(cfg_link_training_enable),                                            // input wire cfg_link_training_enable
  .cfg_interrupt_int(cfg_interrupt_int),                                                          // input wire [3 : 0] cfg_interrupt_int
  .cfg_interrupt_pending(cfg_interrupt_pending),                                                  // input wire [3 : 0] cfg_interrupt_pending
  .cfg_interrupt_sent(cfg_interrupt_sent),                                                        // output wire cfg_interrupt_sent
  .cfg_interrupt_msi_enable(cfg_interrupt_msi_enable),                                            // output wire [3 : 0] cfg_interrupt_msi_enable
  .cfg_interrupt_msi_mmenable(cfg_interrupt_msi_mmenable),                                        // output wire [11 : 0] cfg_interrupt_msi_mmenable
  .cfg_interrupt_msi_mask_update(cfg_interrupt_msi_mask_update),                                  // output wire cfg_interrupt_msi_mask_update
  .cfg_interrupt_msi_data(cfg_interrupt_msi_data),                                                // output wire [31 : 0] cfg_interrupt_msi_data
  .cfg_interrupt_msi_select(cfg_interrupt_msi_select),                                            // input wire [1 : 0] cfg_interrupt_msi_select
  .cfg_interrupt_msi_int(cfg_interrupt_msi_int),                                                  // input wire [31 : 0] cfg_interrupt_msi_int
  .cfg_interrupt_msi_pending_status(cfg_interrupt_msi_pending_status),                            // input wire [31 : 0] cfg_interrupt_msi_pending_status
  .cfg_interrupt_msi_pending_status_data_enable(cfg_interrupt_msi_pending_status_data_enable),    // input wire cfg_interrupt_msi_pending_status_data_enable
  .cfg_interrupt_msi_pending_status_function_num(cfg_interrupt_msi_pending_status_function_num),  // input wire [1 : 0] cfg_interrupt_msi_pending_status_function_num
  .cfg_interrupt_msi_sent(cfg_interrupt_msi_sent),                                                // output wire cfg_interrupt_msi_sent
  .cfg_interrupt_msi_fail(cfg_interrupt_msi_fail),                                                // output wire cfg_interrupt_msi_fail
  .cfg_interrupt_msi_attr(cfg_interrupt_msi_attr),                                                // input wire [2 : 0] cfg_interrupt_msi_attr
  .cfg_interrupt_msi_tph_present(cfg_interrupt_msi_tph_present),                                  // input wire cfg_interrupt_msi_tph_present
  .cfg_interrupt_msi_tph_type(cfg_interrupt_msi_tph_type),                                        // input wire [1 : 0] cfg_interrupt_msi_tph_type
  .cfg_interrupt_msi_tph_st_tag(cfg_interrupt_msi_tph_st_tag),                                    // input wire [7 : 0] cfg_interrupt_msi_tph_st_tag
  .cfg_interrupt_msi_function_number(cfg_interrupt_msi_function_number),                          // input wire [7 : 0] cfg_interrupt_msi_function_number
  .cfg_pm_aspm_l1_entry_reject(cfg_pm_aspm_l1_entry_reject),                                      // input wire cfg_pm_aspm_l1_entry_reject
  .cfg_pm_aspm_tx_l0s_entry_disable(cfg_pm_aspm_tx_l0s_entry_disable),                            // input wire cfg_pm_aspm_tx_l0s_entry_disable
  .cfg_hot_reset_out(cfg_hot_reset_out),                                                          // output wire cfg_hot_reset_out
  .cfg_config_space_enable(cfg_config_space_enable),                                              // input wire cfg_config_space_enable
  .cfg_req_pm_transition_l23_ready(cfg_req_pm_transition_l23_ready),                              // input wire cfg_req_pm_transition_l23_ready
  .cfg_hot_reset_in(cfg_hot_reset_in),                                                            // input wire cfg_hot_reset_in
  .cfg_ds_port_number(cfg_ds_port_number),                                                        // input wire [7 : 0] cfg_ds_port_number
  .cfg_ds_bus_number(cfg_ds_bus_number),                                                          // input wire [7 : 0] cfg_ds_bus_number
  .cfg_ds_device_number(cfg_ds_device_number),                                                    // input wire [4 : 0] cfg_ds_device_number
  .sys_clk(sys_clk),                                                                              // input wire sys_clk
  .sys_clk_gt(sys_clk_gt),                                                                        // input wire sys_clk_gt
  .sys_reset(sys_reset),                                                                          // input wire sys_reset
  .common_commands_in(common_commands_in),                                                        // input wire [25 : 0] common_commands_in
  .pipe_rx_0_sigs(pipe_rx_0_sigs),                                                                // input wire [83 : 0] pipe_rx_0_sigs
  .pipe_rx_1_sigs(pipe_rx_1_sigs),                                                                // input wire [83 : 0] pipe_rx_1_sigs
  .pipe_rx_2_sigs(pipe_rx_2_sigs),                                                                // input wire [83 : 0] pipe_rx_2_sigs
  .pipe_rx_3_sigs(pipe_rx_3_sigs),                                                                // input wire [83 : 0] pipe_rx_3_sigs
  .pipe_rx_4_sigs(pipe_rx_4_sigs),                                                                // input wire [83 : 0] pipe_rx_4_sigs
  .pipe_rx_5_sigs(pipe_rx_5_sigs),                                                                // input wire [83 : 0] pipe_rx_5_sigs
  .pipe_rx_6_sigs(pipe_rx_6_sigs),                                                                // input wire [83 : 0] pipe_rx_6_sigs
  .pipe_rx_7_sigs(pipe_rx_7_sigs),                                                                // input wire [83 : 0] pipe_rx_7_sigs
  .pipe_rx_8_sigs(pipe_rx_8_sigs),                                                                // input wire [83 : 0] pipe_rx_8_sigs
  .pipe_rx_9_sigs(pipe_rx_9_sigs),                                                                // input wire [83 : 0] pipe_rx_9_sigs
  .pipe_rx_10_sigs(pipe_rx_10_sigs),                                                              // input wire [83 : 0] pipe_rx_10_sigs
  .pipe_rx_11_sigs(pipe_rx_11_sigs),                                                              // input wire [83 : 0] pipe_rx_11_sigs
  .pipe_rx_12_sigs(pipe_rx_12_sigs),                                                              // input wire [83 : 0] pipe_rx_12_sigs
  .pipe_rx_13_sigs(pipe_rx_13_sigs),                                                              // input wire [83 : 0] pipe_rx_13_sigs
  .pipe_rx_14_sigs(pipe_rx_14_sigs),                                                              // input wire [83 : 0] pipe_rx_14_sigs
  .pipe_rx_15_sigs(pipe_rx_15_sigs),                                                              // input wire [83 : 0] pipe_rx_15_sigs
  .common_commands_out(common_commands_out),                                                      // output wire [25 : 0] common_commands_out
  .pipe_tx_0_sigs(pipe_tx_0_sigs),                                                                // output wire [83 : 0] pipe_tx_0_sigs
  .pipe_tx_1_sigs(pipe_tx_1_sigs),                                                                // output wire [83 : 0] pipe_tx_1_sigs
  .pipe_tx_2_sigs(pipe_tx_2_sigs),                                                                // output wire [83 : 0] pipe_tx_2_sigs
  .pipe_tx_3_sigs(pipe_tx_3_sigs),                                                                // output wire [83 : 0] pipe_tx_3_sigs
  .pipe_tx_4_sigs(pipe_tx_4_sigs),                                                                // output wire [83 : 0] pipe_tx_4_sigs
  .pipe_tx_5_sigs(pipe_tx_5_sigs),                                                                // output wire [83 : 0] pipe_tx_5_sigs
  .pipe_tx_6_sigs(pipe_tx_6_sigs),                                                                // output wire [83 : 0] pipe_tx_6_sigs
  .pipe_tx_7_sigs(pipe_tx_7_sigs),                                                                // output wire [83 : 0] pipe_tx_7_sigs
  .pipe_tx_8_sigs(pipe_tx_8_sigs),                                                                // output wire [83 : 0] pipe_tx_8_sigs
  .pipe_tx_9_sigs(pipe_tx_9_sigs),                                                                // output wire [83 : 0] pipe_tx_9_sigs
  .pipe_tx_10_sigs(pipe_tx_10_sigs),                                                              // output wire [83 : 0] pipe_tx_10_sigs
  .pipe_tx_11_sigs(pipe_tx_11_sigs),                                                              // output wire [83 : 0] pipe_tx_11_sigs
  .pipe_tx_12_sigs(pipe_tx_12_sigs),                                                              // output wire [83 : 0] pipe_tx_12_sigs
  .pipe_tx_13_sigs(pipe_tx_13_sigs),                                                              // output wire [83 : 0] pipe_tx_13_sigs
  .pipe_tx_14_sigs(pipe_tx_14_sigs),                                                              // output wire [83 : 0] pipe_tx_14_sigs
  .pipe_tx_15_sigs(pipe_tx_15_sigs),                                                              // output wire [83 : 0] pipe_tx_15_sigs
  .gt_pcieuserratedone(gt_pcieuserratedone),                                                      // input wire [7 : 0] gt_pcieuserratedone
  .gt_loopback(gt_loopback),                                                                      // input wire [23 : 0] gt_loopback
  .gt_txprbsforceerr(gt_txprbsforceerr),                                                          // input wire [7 : 0] gt_txprbsforceerr
  .gt_txinhibit(gt_txinhibit),                                                                    // input wire [7 : 0] gt_txinhibit
  .gt_txprbssel(gt_txprbssel),                                                                    // input wire [31 : 0] gt_txprbssel
  .gt_rxprbssel(gt_rxprbssel),                                                                    // input wire [31 : 0] gt_rxprbssel
  .gt_rxprbscntreset(gt_rxprbscntreset),                                                          // input wire [7 : 0] gt_rxprbscntreset
  .gt_txelecidle(gt_txelecidle),                                                                  // output wire [7 : 0] gt_txelecidle
  .gt_txresetdone(gt_txresetdone),                                                                // output wire [7 : 0] gt_txresetdone
  .gt_rxresetdone(gt_rxresetdone),                                                                // output wire [7 : 0] gt_rxresetdone
  .gt_rxpmaresetdone(gt_rxpmaresetdone),                                                          // output wire [7 : 0] gt_rxpmaresetdone
  .gt_txphaligndone(gt_txphaligndone),                                                            // output wire [7 : 0] gt_txphaligndone
  .gt_txphinitdone(gt_txphinitdone),                                                              // output wire [7 : 0] gt_txphinitdone
  .gt_txdlysresetdone(gt_txdlysresetdone),                                                        // output wire [7 : 0] gt_txdlysresetdone
  .gt_rxphaligndone(gt_rxphaligndone),                                                            // output wire [7 : 0] gt_rxphaligndone
  .gt_rxdlysresetdone(gt_rxdlysresetdone),                                                        // output wire [7 : 0] gt_rxdlysresetdone
  .gt_rxsyncdone(gt_rxsyncdone),                                                                  // output wire [7 : 0] gt_rxsyncdone
  .gt_eyescandataerror(gt_eyescandataerror),                                                      // output wire [7 : 0] gt_eyescandataerror
  .gt_rxprbserr(gt_rxprbserr),                                                                    // output wire [7 : 0] gt_rxprbserr
  .gt_dmonfiforeset(gt_dmonfiforeset),                                                            // input wire [7 : 0] gt_dmonfiforeset
  .gt_dmonitorclk(gt_dmonitorclk),                                                                // input wire [7 : 0] gt_dmonitorclk
  .gt_dmonitorout(gt_dmonitorout),                                                                // output wire [127 : 0] gt_dmonitorout
  .gt_rxcommadet(gt_rxcommadet),                                                                  // output wire [7 : 0] gt_rxcommadet
  .gt_phystatus(gt_phystatus),                                                                    // output wire [7 : 0] gt_phystatus
  .gt_rxvalid(gt_rxvalid),                                                                        // output wire [7 : 0] gt_rxvalid
  .gt_rxcdrlock(gt_rxcdrlock),                                                                    // output wire [7 : 0] gt_rxcdrlock
  .gt_pcierateidle(gt_pcierateidle),                                                              // output wire [7 : 0] gt_pcierateidle
  .gt_pcieuserratestart(gt_pcieuserratestart),                                                    // output wire [7 : 0] gt_pcieuserratestart
  .gt_gtpowergood(gt_gtpowergood),                                                                // output wire [7 : 0] gt_gtpowergood
  .gt_cplllock(gt_cplllock),                                                                      // output wire [7 : 0] gt_cplllock
  .gt_rxoutclk(gt_rxoutclk),                                                                      // output wire [7 : 0] gt_rxoutclk
  .gt_rxrecclkout(gt_rxrecclkout),                                                                // output wire [7 : 0] gt_rxrecclkout
  .gt_qpll1lock(gt_qpll1lock),                                                                    // output wire [1 : 0] gt_qpll1lock
  .gt_qpll0lock(gt_qpll0lock),                                                                    // output wire [1 : 0] gt_qpll0lock
  .gt_rxstatus(gt_rxstatus),                                                                      // output wire [23 : 0] gt_rxstatus
  .gt_rxbufstatus(gt_rxbufstatus),                                                                // output wire [23 : 0] gt_rxbufstatus
  .gt_bufgtdiv(gt_bufgtdiv),                                                                      // output wire [8 : 0] gt_bufgtdiv
  .phy_txeq_ctrl(phy_txeq_ctrl),                                                                  // output wire [15 : 0] phy_txeq_ctrl
  .phy_txeq_preset(phy_txeq_preset),                                                              // output wire [31 : 0] phy_txeq_preset
  .phy_rst_fsm(phy_rst_fsm),                                                                      // output wire [3 : 0] phy_rst_fsm
  .phy_txeq_fsm(phy_txeq_fsm),                                                                    // output wire [23 : 0] phy_txeq_fsm
  .phy_rxeq_fsm(phy_rxeq_fsm),                                                                    // output wire [23 : 0] phy_rxeq_fsm
  .phy_rst_idle(phy_rst_idle),                                                                    // output wire phy_rst_idle
  .phy_rrst_n(phy_rrst_n),                                                                        // output wire phy_rrst_n
  .phy_prst_n(phy_prst_n),                                                                        // output wire phy_prst_n
  .gt_gen34_eios_det(gt_gen34_eios_det),                                                          // output wire [7 : 0] gt_gen34_eios_det
  .gt_txoutclk(gt_txoutclk),                                                                      // output wire [7 : 0] gt_txoutclk
  .gt_txoutclkfabric(gt_txoutclkfabric),                                                          // output wire [7 : 0] gt_txoutclkfabric
  .gt_rxoutclkfabric(gt_rxoutclkfabric),                                                          // output wire [7 : 0] gt_rxoutclkfabric
  .gt_txoutclkpcs(gt_txoutclkpcs),                                                                // output wire [7 : 0] gt_txoutclkpcs
  .gt_rxoutclkpcs(gt_rxoutclkpcs),                                                                // output wire [7 : 0] gt_rxoutclkpcs
  .gt_txpmareset(gt_txpmareset),                                                                  // input wire [7 : 0] gt_txpmareset
  .gt_rxpmareset(gt_rxpmareset),                                                                  // input wire [7 : 0] gt_rxpmareset
  .gt_txpcsreset(gt_txpcsreset),                                                                  // input wire [7 : 0] gt_txpcsreset
  .gt_rxpcsreset(gt_rxpcsreset),                                                                  // input wire [7 : 0] gt_rxpcsreset
  .gt_rxbufreset(gt_rxbufreset),                                                                  // input wire [7 : 0] gt_rxbufreset
  .gt_rxcdrreset(gt_rxcdrreset),                                                                  // input wire [7 : 0] gt_rxcdrreset
  .gt_rxdfelpmreset(gt_rxdfelpmreset),                                                            // input wire [7 : 0] gt_rxdfelpmreset
  .gt_txprogdivresetdone(gt_txprogdivresetdone),                                                  // output wire [7 : 0] gt_txprogdivresetdone
  .gt_txpmaresetdone(gt_txpmaresetdone),                                                          // output wire [7 : 0] gt_txpmaresetdone
  .gt_txsyncdone(gt_txsyncdone),                                                                  // output wire [7 : 0] gt_txsyncdone
  .gt_rxprbslocked(gt_rxprbslocked),                                                              // output wire [7 : 0] gt_rxprbslocked
  .drp_rdy(drp_rdy),                                                                              // output wire drp_rdy
  .drp_do(drp_do),                                                                                // output wire [15 : 0] drp_do
  .drp_clk(drp_clk),                                                                              // input wire drp_clk
  .drp_en(drp_en),                                                                                // input wire drp_en
  .drp_we(drp_we),                                                                                // input wire drp_we
  .drp_addr(drp_addr),                                                                            // input wire [9 : 0] drp_addr
  .drp_di(drp_di),                                                                                // input wire [15 : 0] drp_di
  .phy_rdy_out(phy_rdy_out)                                                                      // output wire phy_rdy_out
);
// INST_TAG_END ------ End INSTANTIATION Template ---------

// You must compile the wrapper file pcie4_uscale_plus_1.v when simulating
// the core, pcie4_uscale_plus_1. When compiling the wrapper file, be sure to
// reference the Verilog simulation library.

pcie_gen3x8_13_1 #(
        .PORTS         ( PORTS             ),
        .BALI          ( 1                 )
) 
u_bali_pcie_gen3x8_wrap (
        .fc_reconfig_to_xcvr   (fc_reconfig_to_xcvr),
        .fc_reconfig_from_xcvr (fc_reconfig_from_xcvr),
				.iRST_CHIP_PCIE_N      (iRST_CHIP_PCIE_N),
        /*AUTOINST*/
        // Outputs
        .oCLK_PCIE_CORECLKOUT_HIP      (oCLK_PCIE_CORECLKOUT_HIP),
        .oLANE_ACT		       (oLANE_ACT[3:0]),
        .oLTSSM		               (oLTSSM[4:0]),
        .oCURRENT_SPEED	               (oCURRENT_SPEED[1:0]),
        .oAPP_RST_n_STATUS	       (oAPP_RST_n_STATUS),
        .oPCIE_MISC_STATUS	       (oPCIE_MISC_STATUS[31:0]),
        .oPCIE2MM_WR_DATA	       ( pcie2mm_wr_data[63:0]                 ),       // Templated
        .oPCIE2MM_ADDRESS	       ( pcie2mm_address[20:0]                 ),       // Templated
        .oPCIE2MM_WR_EN	               ( pcie2mm_wr_en_a                   ),           // Templated
        .oPCIE2MM_RD_EN	               ( pcie2mm_rd_en_a                   ),           // Templated
        .oMM_RD_DATA		       ( oPCIE_MM_RD_DATA[63:0]                ),       // Templated
        .oMM_RD_DATA_V		       ( oPCIE_MM_RD_DATA_V                ),           // Templated
        .oDPLBUF_GNT		       ( pcie_dplbuf_gnt[PORTS-1:0]                 ),  // Templated
        .oHIP_SERIAL_TX_OUT0	       (oHIP_SERIAL_TX_OUT0),
        .oHIP_SERIAL_TX_OUT1	       (oHIP_SERIAL_TX_OUT1),
        .oHIP_SERIAL_TX_OUT2	       (oHIP_SERIAL_TX_OUT2),
        .oHIP_SERIAL_TX_OUT3	       (oHIP_SERIAL_TX_OUT3),
        .oHIP_SERIAL_TX_OUT4	       (oHIP_SERIAL_TX_OUT4),
        .oHIP_SERIAL_TX_OUT5	       (oHIP_SERIAL_TX_OUT5),
        .oHIP_SERIAL_TX_OUT6	       (oHIP_SERIAL_TX_OUT6),
        .oHIP_SERIAL_TX_OUT7	       (oHIP_SERIAL_TX_OUT7),
        .hip_pipe_sim_pipe_rate        (hip_pipe_sim_pipe_rate[1:0]),
        .hip_pipe_sim_ltssmstate       (hip_pipe_sim_ltssmstate[4:0]),
        .hip_pipe_eidleinfersel0       ( hip_pipe_eidleinfersel[0]                   ), // Templated
        .hip_pipe_eidleinfersel1       ( hip_pipe_eidleinfersel[1]                   ), // Templated
        .hip_pipe_eidleinfersel2       ( hip_pipe_eidleinfersel[2]                   ), // Templated
        .hip_pipe_eidleinfersel3       ( hip_pipe_eidleinfersel[3]                   ), // Templated
        .hip_pipe_eidleinfersel4       ( hip_pipe_eidleinfersel[4]                   ), // Templated
        .hip_pipe_eidleinfersel5       ( hip_pipe_eidleinfersel[5]                   ), // Templated
        .hip_pipe_eidleinfersel6       ( hip_pipe_eidleinfersel[6]                   ), // Templated
        .hip_pipe_eidleinfersel7       ( hip_pipe_eidleinfersel[7]                   ), // Templated
        .hip_pipe_powerdown0	       ( hip_pipe_powerdown[0]                   ),     // Templated
        .hip_pipe_powerdown1	       ( hip_pipe_powerdown[1]                   ),     // Templated
        .hip_pipe_powerdown2	       ( hip_pipe_powerdown[2]                   ),     // Templated
        .hip_pipe_powerdown3	       ( hip_pipe_powerdown[3]                   ),     // Templated
        .hip_pipe_powerdown4	       ( hip_pipe_powerdown[4]                   ),     // Templated
        .hip_pipe_powerdown5	       ( hip_pipe_powerdown[5]                   ),     // Templated
        .hip_pipe_powerdown6	       ( hip_pipe_powerdown[6]                   ),     // Templated
        .hip_pipe_powerdown7	       ( hip_pipe_powerdown[7]                   ),     // Templated
        .hip_pipe_rxpolarity0	       ( hip_pipe_rxpolarity[0]                   ),    // Templated
        .hip_pipe_rxpolarity1	       ( hip_pipe_rxpolarity[1]                   ),    // Templated
        .hip_pipe_rxpolarity2	       ( hip_pipe_rxpolarity[2]                   ),    // Templated
        .hip_pipe_rxpolarity3	       ( hip_pipe_rxpolarity[3]                   ),    // Templated
        .hip_pipe_rxpolarity4	       ( hip_pipe_rxpolarity[4]                   ),    // Templated
        .hip_pipe_rxpolarity5	       ( hip_pipe_rxpolarity[5]                   ),    // Templated
        .hip_pipe_rxpolarity6	       ( hip_pipe_rxpolarity[6]                   ),    // Templated
        .hip_pipe_rxpolarity7	       ( hip_pipe_rxpolarity[7]                   ),    // Templated
        .hip_pipe_txcompl0	       ( hip_pipe_txcompl[0]                   ),       // Templated
        .hip_pipe_txcompl1	       ( hip_pipe_txcompl[1]                   ),       // Templated
        .hip_pipe_txcompl2	       ( hip_pipe_txcompl[2]                   ),       // Templated
        .hip_pipe_txcompl3	       ( hip_pipe_txcompl[3]                   ),       // Templated
        .hip_pipe_txcompl4	       ( hip_pipe_txcompl[4]                   ),       // Templated
        .hip_pipe_txcompl5	       ( hip_pipe_txcompl[5]                   ),       // Templated
        .hip_pipe_txcompl6	       ( hip_pipe_txcompl[6]                   ),       // Templated
        .hip_pipe_txcompl7	       ( hip_pipe_txcompl[7]                   ),       // Templated
        .hip_pipe_txdata0	       ( hip_pipe_txdata[0]                   ),        // Templated
        .hip_pipe_txdata1	       ( hip_pipe_txdata[1]                   ),        // Templated
        .hip_pipe_txdata2	       ( hip_pipe_txdata[2]                   ),        // Templated
        .hip_pipe_txdata3	       ( hip_pipe_txdata[3]                   ),        // Templated
        .hip_pipe_txdata4	       ( hip_pipe_txdata[4]                   ),        // Templated
        .hip_pipe_txdata5	       ( hip_pipe_txdata[5]                   ),        // Templated
        .hip_pipe_txdata6	       ( hip_pipe_txdata[6]                   ),        // Templated
        .hip_pipe_txdata7	       ( hip_pipe_txdata[7]                   ),        // Templated
        .hip_pipe_txdatak0	       ( hip_pipe_txdatak[0]                   ),       // Templated
        .hip_pipe_txdatak1	       ( hip_pipe_txdatak[1]                   ),       // Templated
        .hip_pipe_txdatak2	       ( hip_pipe_txdatak[2]                   ),       // Templated
        .hip_pipe_txdatak3	       ( hip_pipe_txdatak[3]                   ),       // Templated
        .hip_pipe_txdatak4	       ( hip_pipe_txdatak[4]                   ),       // Templated
        .hip_pipe_txdatak5	       ( hip_pipe_txdatak[5]                   ),       // Templated
        .hip_pipe_txdatak6	       ( hip_pipe_txdatak[6]                   ),       // Templated
        .hip_pipe_txdatak7	       ( hip_pipe_txdatak[7]                   ),       // Templated
        .hip_pipe_txdetectrx0	       ( hip_pipe_txdetectrx[0]                   ),    // Templated
        .hip_pipe_txdetectrx1	       ( hip_pipe_txdetectrx[1]                   ),    // Templated
        .hip_pipe_txdetectrx2	       ( hip_pipe_txdetectrx[2]                   ),    // Templated
        .hip_pipe_txdetectrx3	       ( hip_pipe_txdetectrx[3]                   ),    // Templated
        .hip_pipe_txdetectrx4	       ( hip_pipe_txdetectrx[4]                   ),    // Templated
        .hip_pipe_txdetectrx5	       ( hip_pipe_txdetectrx[5]                   ),    // Templated
        .hip_pipe_txdetectrx6	       ( hip_pipe_txdetectrx[6]                   ),    // Templated
        .hip_pipe_txdetectrx7	       ( hip_pipe_txdetectrx[7]                   ),    // Templated
        .hip_pipe_txelecidle0	       ( hip_pipe_txelecidle[0]                   ),    // Templated
        .hip_pipe_txelecidle1	       ( hip_pipe_txelecidle[1]                   ),    // Templated
        .hip_pipe_txelecidle2	       ( hip_pipe_txelecidle[2]                   ),    // Templated
        .hip_pipe_txelecidle3	       ( hip_pipe_txelecidle[3]                   ),    // Templated
        .hip_pipe_txelecidle4	       ( hip_pipe_txelecidle[4]                   ),    // Templated
        .hip_pipe_txelecidle5	       ( hip_pipe_txelecidle[5]                   ),    // Templated
        .hip_pipe_txelecidle6	       ( hip_pipe_txelecidle[6]                   ),    // Templated
        .hip_pipe_txelecidle7	       ( hip_pipe_txelecidle[7]                   ),    // Templated
        .hip_pipe_txdeemph0	       ( hip_pipe_txdeemph[0]                   ),      // Templated
        .hip_pipe_txdeemph1	       ( hip_pipe_txdeemph[1]                   ),      // Templated
        .hip_pipe_txdeemph2	       ( hip_pipe_txdeemph[2]                   ),      // Templated
        .hip_pipe_txdeemph3	       ( hip_pipe_txdeemph[3]                   ),      // Templated
        .hip_pipe_txdeemph4	       ( hip_pipe_txdeemph[4]                   ),      // Templated
        .hip_pipe_txdeemph5	       ( hip_pipe_txdeemph[5]                   ),      // Templated
        .hip_pipe_txdeemph6	       ( hip_pipe_txdeemph[6]                   ),      // Templated
        .hip_pipe_txdeemph7	       ( hip_pipe_txdeemph[7]                   ),      // Templated
        .hip_pipe_txmargin0	       ( hip_pipe_txmargin[0]                   ),      // Templated
        .hip_pipe_txmargin1	       ( hip_pipe_txmargin[1]                   ),      // Templated
        .hip_pipe_txmargin2	       ( hip_pipe_txmargin[2]                   ),      // Templated
        .hip_pipe_txmargin3	       ( hip_pipe_txmargin[3]                   ),      // Templated
        .hip_pipe_txmargin4	       ( hip_pipe_txmargin[4]                   ),      // Templated
        .hip_pipe_txmargin5	       ( hip_pipe_txmargin[5]                   ),      // Templated
        .hip_pipe_txmargin6	       ( hip_pipe_txmargin[6]                   ),      // Templated
        .hip_pipe_txmargin7	       ( hip_pipe_txmargin[7]                   ),      // Templated
        .hip_pipe_txswing0	       ( hip_pipe_txswing[0]                   ),       // Templated
        .hip_pipe_txswing1	       ( hip_pipe_txswing[1]                   ),       // Templated
        .hip_pipe_txswing2	       ( hip_pipe_txswing[2]                   ),       // Templated
        .hip_pipe_txswing3	       ( hip_pipe_txswing[3]                   ),       // Templated
        .hip_pipe_txswing4	       ( hip_pipe_txswing[4]                   ),       // Templated
        .hip_pipe_txswing5	       ( hip_pipe_txswing[5]                   ),       // Templated
        .hip_pipe_txswing6	       ( hip_pipe_txswing[6]                   ),       // Templated
        .hip_pipe_txswing7	       ( hip_pipe_txswing[7]                   ),       // Templated
        // Inputs
        .iRST_NPOR_n		       (iRST_NPOR_n),
        .iPIN_PERST_n		       (iPIN_PERST_n),
        .iRST_100M_N		       (iRST_100M_N),
        .iRST_PCIE_N		       ( {2{iRST_PCIE_N[LINKS-1:0]}}       ),   // Templated
        .iREF_CLK		       (iREF_CLK),
        .iCLK_PCIE_GLOBAL	       (iCLK_PCIE_GLOBAL),
        .iCLK_100M		       (iCLK_100M),
        .iRECONFIG_XCVR_CLK	       (iRECONFIG_XCVR_CLK),
        .iHIP_CTRL_TEST_IN	       (iHIP_CTRL_TEST_IN[31:0]),
        .iHIP_CTRL_SIMU_MODE_PIPE      (iHIP_CTRL_SIMU_MODE_PIPE),
        .iMM2PCIE_ACK		       ( mm2pcie_ack_sync                  ),   // Templated
        .iMM2PCIE_RD_DATA	       ( mm2pcie_rd_data_sync[63:0]        ),   // Templated
        .iMM_WR_DATA		       ( iPCIE_MM_WR_DATA[63:0]                     ),  // Templated
        .iMM_ADDR		       ( iPCIE_MM_ADDR[20:0]                     ),     // Templated
        .iMM_WR_EN		       ( iPCIE_MM_WR_EN                     ),          // Templated
        .iMM_RD_EN		       ( iPCIE_MM_RD_EN                     ),          // Templated
        .iDPLBUF_REQ		       ( pcie_dplbuf_req[PORTS-1:0]                 ),  // Templated
        .iDPLBUF_DATA		       ( pcie_dplbuf_data[255:0]                ),      // Templated
        .iDPLBUF_DATA_V	               ( pcie_dplbuf_data_v[PORTS-1:0]              ),  // Templated
        .iHIP_SERIAL_RX_IN0	       (iHIP_SERIAL_RX_IN0),
        .iHIP_SERIAL_RX_IN1	       (iHIP_SERIAL_RX_IN1),
        .iHIP_SERIAL_RX_IN2	       (iHIP_SERIAL_RX_IN2),
        .iHIP_SERIAL_RX_IN3	       (iHIP_SERIAL_RX_IN3),
        .iHIP_SERIAL_RX_IN4	       (iHIP_SERIAL_RX_IN4),
        .iHIP_SERIAL_RX_IN5	       (iHIP_SERIAL_RX_IN5),
        .iHIP_SERIAL_RX_IN6	       (iHIP_SERIAL_RX_IN6),
        .iHIP_SERIAL_RX_IN7	       (iHIP_SERIAL_RX_IN7),
        .hip_pipe_sim_pipe_pclk_in     (hip_pipe_sim_pipe_pclk_in),
        .hip_pipe_phystatus0	       ( hip_pipe_phystatus[0]                   ),     // Templated
        .hip_pipe_phystatus1	       ( hip_pipe_phystatus[1]                   ),     // Templated
        .hip_pipe_phystatus2	       ( hip_pipe_phystatus[2]                   ),     // Templated
        .hip_pipe_phystatus3	       ( hip_pipe_phystatus[3]                   ),     // Templated
        .hip_pipe_phystatus4	       ( hip_pipe_phystatus[4]                   ),     // Templated
        .hip_pipe_phystatus5	       ( hip_pipe_phystatus[5]                   ),     // Templated
        .hip_pipe_phystatus6	       ( hip_pipe_phystatus[6]                   ),     // Templated
        .hip_pipe_phystatus7	       ( hip_pipe_phystatus[7]                   ),     // Templated
        .hip_pipe_rxdata0	       ( hip_pipe_rxdata[0]                   ),        // Templated
        .hip_pipe_rxdata1	       ( hip_pipe_rxdata[1]                   ),        // Templated
        .hip_pipe_rxdata2	       ( hip_pipe_rxdata[2]                   ),        // Templated
        .hip_pipe_rxdata3	       ( hip_pipe_rxdata[3]                   ),        // Templated
        .hip_pipe_rxdata4	       ( hip_pipe_rxdata[4]                   ),        // Templated
        .hip_pipe_rxdata5	       ( hip_pipe_rxdata[5]                   ),        // Templated
        .hip_pipe_rxdata6	       ( hip_pipe_rxdata[6]                   ),        // Templated
        .hip_pipe_rxdata7	       ( hip_pipe_rxdata[7]                   ),        // Templated
        .hip_pipe_rxdatak0	       ( hip_pipe_rxdatak[0]                   ),       // Templated
        .hip_pipe_rxdatak1	       ( hip_pipe_rxdatak[1]                   ),       // Templated
        .hip_pipe_rxdatak2	       ( hip_pipe_rxdatak[2]                   ),       // Templated
        .hip_pipe_rxdatak3	       ( hip_pipe_rxdatak[3]                   ),       // Templated
        .hip_pipe_rxdatak4	       ( hip_pipe_rxdatak[4]                   ),       // Templated
        .hip_pipe_rxdatak5	       ( hip_pipe_rxdatak[5]                   ),       // Templated
        .hip_pipe_rxdatak6	       ( hip_pipe_rxdatak[6]                   ),       // Templated
        .hip_pipe_rxdatak7	       ( hip_pipe_rxdatak[7]                   ),       // Templated
        .hip_pipe_rxelecidle0	       ( hip_pipe_rxelecidle[0]                   ),    // Templated
        .hip_pipe_rxelecidle1	       ( hip_pipe_rxelecidle[1]                   ),    // Templated
        .hip_pipe_rxelecidle2	       ( hip_pipe_rxelecidle[2]                   ),    // Templated
        .hip_pipe_rxelecidle3	       ( hip_pipe_rxelecidle[3]                   ),    // Templated
        .hip_pipe_rxelecidle4	       ( hip_pipe_rxelecidle[4]                   ),    // Templated
        .hip_pipe_rxelecidle5	       ( hip_pipe_rxelecidle[5]                   ),    // Templated
        .hip_pipe_rxelecidle6	       ( hip_pipe_rxelecidle[6]                   ),    // Templated
        .hip_pipe_rxelecidle7	       ( hip_pipe_rxelecidle[7]                   ),    // Templated
        .hip_pipe_rxstatus0	       ( hip_pipe_rxstatus[0]                   ),      // Templated
        .hip_pipe_rxstatus1	       ( hip_pipe_rxstatus[1]                   ),      // Templated
        .hip_pipe_rxstatus2	       ( hip_pipe_rxstatus[2]                   ),      // Templated
        .hip_pipe_rxstatus3	       ( hip_pipe_rxstatus[3]                   ),      // Templated
        .hip_pipe_rxstatus4	       ( hip_pipe_rxstatus[4]                   ),      // Templated
        .hip_pipe_rxstatus5	       ( hip_pipe_rxstatus[5]                   ),      // Templated
        .hip_pipe_rxstatus6	       ( hip_pipe_rxstatus[6]                   ),      // Templated
        .hip_pipe_rxstatus7	       ( hip_pipe_rxstatus[7]                   ),      // Templated
        .hip_pipe_rxvalid0	       ( hip_pipe_rxvalid[0]                   ),       // Templated
        .hip_pipe_rxvalid1	       ( hip_pipe_rxvalid[1]                   ),       // Templated
        .hip_pipe_rxvalid2	       ( hip_pipe_rxvalid[2]                   ),       // Templated
        .hip_pipe_rxvalid3	       ( hip_pipe_rxvalid[3]                   ),       // Templated
        .hip_pipe_rxvalid4	       ( hip_pipe_rxvalid[4]                   ),       // Templated
        .hip_pipe_rxvalid5	       ( hip_pipe_rxvalid[5]                   ),       // Templated
        .hip_pipe_rxvalid6	       ( hip_pipe_rxvalid[6]                   ),       // Templated
        .hip_pipe_rxvalid7	       ( hip_pipe_rxvalid[7]                   ));      // Templated
end

//GEN2 instantiation
else begin

///////////////////////////////////////////////////////////////////////////////
// PCIE Instantiation
///////////////////////////////////////////////////////////////////////////////
/* bali_pcie_gen2x8_wrap AUTO_TEMPLATE (
    // Outputs
    .oDPLBUF_GNT            ( pcie_dplbuf_gnt[]                 ),
    // Inputs
    .iRST_PCIE_N            ( {2{iRST_PCIE_N[LINKS-1:0]}}       ),
    .iDPLBUF_REQ            ( pcie_dplbuf_req[]                 ),
    .iDPLBUF_DATA           ( pcie_dplbuf_data[]                ),
    .iDPLBUF_DATA_V         ( pcie_dplbuf_data_v[]              ),
    .hip_pipe_\(.*\)@       ( hip_pipe_\1[\2]                   ),
    .iMM2PCIE_ACK           ( mm2pcie_ack_sync                  ), 
    .iMM2PCIE_RD_DATA       ( mm2pcie_rd_data_sync[63:0]        ),
    .iMM2PCIE_RD_DATA_V     ( mm2pcie_ack_sync                  ),
    .iMM_\(.*\)             ( iPCIE_MM_\1[]                     ),
    .oMM_RD_DATA            ( oPCIE_MM_RD_DATA[]                ),
    .oMM_RD_DATA_V          ( oPCIE_MM_RD_DATA_V                ),
    .oPCIE2MM_WR_EN	        ( pcie2mm_wr_en_a                   ), 
    .oPCIE2MM_RD_EN	        ( pcie2mm_rd_en_a                   ), 
    .oPCIE2MM_WR_DATA       ( pcie2mm_wr_data[]                 ),
    .oPCIE2MM_ADDRESS       ( pcie2mm_address[]                 ),
   );
*/
pcie_gen2x8_13_1 #(
        .PORTS         ( PORTS             ),
        .BALI          ( 1                 )
) 
u_bali_pcie_gen2x8_wrap (
        .fc_reconfig_to_xcvr   (fc_reconfig_to_xcvr),
        .fc_reconfig_from_xcvr (fc_reconfig_from_xcvr),
				.iRST_CHIP_PCIE_N      (iRST_CHIP_PCIE_N),
        /*AUTOINST*/
        // Outputs
        .oCLK_PCIE_CORECLKOUT_HIP      (oCLK_PCIE_CORECLKOUT_HIP),
        .oLANE_ACT		       (oLANE_ACT[3:0]),
        .oLTSSM		               (oLTSSM[4:0]),
        .oCURRENT_SPEED	               (oCURRENT_SPEED[1:0]),
        .oAPP_RST_n_STATUS	       (oAPP_RST_n_STATUS),
        .oPCIE_MISC_STATUS	       (oPCIE_MISC_STATUS[31:0]),
        .oPCIE2MM_WR_DATA	       ( pcie2mm_wr_data[63:0]                 ),       // Templated
        .oPCIE2MM_ADDRESS	       ( pcie2mm_address[20:0]                 ),       // Templated
        .oPCIE2MM_WR_EN	               ( pcie2mm_wr_en_a                   ),           // Templated
        .oPCIE2MM_RD_EN	               ( pcie2mm_rd_en_a                   ),           // Templated
        .oMM_RD_DATA		       ( oPCIE_MM_RD_DATA[63:0]                ),       // Templated
        .oMM_RD_DATA_V		       ( oPCIE_MM_RD_DATA_V                ),           // Templated
        .oDPLBUF_GNT		       ( pcie_dplbuf_gnt[PORTS-1:0]                 ),  // Templated
        .oHIP_SERIAL_TX_OUT0	       (oHIP_SERIAL_TX_OUT0),
        .oHIP_SERIAL_TX_OUT1	       (oHIP_SERIAL_TX_OUT1),
        .oHIP_SERIAL_TX_OUT2	       (oHIP_SERIAL_TX_OUT2),
        .oHIP_SERIAL_TX_OUT3	       (oHIP_SERIAL_TX_OUT3),
        .oHIP_SERIAL_TX_OUT4	       (oHIP_SERIAL_TX_OUT4),
        .oHIP_SERIAL_TX_OUT5	       (oHIP_SERIAL_TX_OUT5),
        .oHIP_SERIAL_TX_OUT6	       (oHIP_SERIAL_TX_OUT6),
        .oHIP_SERIAL_TX_OUT7	       (oHIP_SERIAL_TX_OUT7),
        .hip_pipe_sim_pipe_rate        (hip_pipe_sim_pipe_rate[1:0]),
        .hip_pipe_sim_ltssmstate       (hip_pipe_sim_ltssmstate[4:0]),
        .hip_pipe_eidleinfersel0       ( hip_pipe_eidleinfersel[0]                   ), // Templated
        .hip_pipe_eidleinfersel1       ( hip_pipe_eidleinfersel[1]                   ), // Templated
        .hip_pipe_eidleinfersel2       ( hip_pipe_eidleinfersel[2]                   ), // Templated
        .hip_pipe_eidleinfersel3       ( hip_pipe_eidleinfersel[3]                   ), // Templated
        .hip_pipe_eidleinfersel4       ( hip_pipe_eidleinfersel[4]                   ), // Templated
        .hip_pipe_eidleinfersel5       ( hip_pipe_eidleinfersel[5]                   ), // Templated
        .hip_pipe_eidleinfersel6       ( hip_pipe_eidleinfersel[6]                   ), // Templated
        .hip_pipe_eidleinfersel7       ( hip_pipe_eidleinfersel[7]                   ), // Templated
        .hip_pipe_powerdown0	       ( hip_pipe_powerdown[0]                   ),     // Templated
        .hip_pipe_powerdown1	       ( hip_pipe_powerdown[1]                   ),     // Templated
        .hip_pipe_powerdown2	       ( hip_pipe_powerdown[2]                   ),     // Templated
        .hip_pipe_powerdown3	       ( hip_pipe_powerdown[3]                   ),     // Templated
        .hip_pipe_powerdown4	       ( hip_pipe_powerdown[4]                   ),     // Templated
        .hip_pipe_powerdown5	       ( hip_pipe_powerdown[5]                   ),     // Templated
        .hip_pipe_powerdown6	       ( hip_pipe_powerdown[6]                   ),     // Templated
        .hip_pipe_powerdown7	       ( hip_pipe_powerdown[7]                   ),     // Templated
        .hip_pipe_rxpolarity0	       ( hip_pipe_rxpolarity[0]                   ),    // Templated
        .hip_pipe_rxpolarity1	       ( hip_pipe_rxpolarity[1]                   ),    // Templated
        .hip_pipe_rxpolarity2	       ( hip_pipe_rxpolarity[2]                   ),    // Templated
        .hip_pipe_rxpolarity3	       ( hip_pipe_rxpolarity[3]                   ),    // Templated
        .hip_pipe_rxpolarity4	       ( hip_pipe_rxpolarity[4]                   ),    // Templated
        .hip_pipe_rxpolarity5	       ( hip_pipe_rxpolarity[5]                   ),    // Templated
        .hip_pipe_rxpolarity6	       ( hip_pipe_rxpolarity[6]                   ),    // Templated
        .hip_pipe_rxpolarity7	       ( hip_pipe_rxpolarity[7]                   ),    // Templated
        .hip_pipe_txcompl0	       ( hip_pipe_txcompl[0]                   ),       // Templated
        .hip_pipe_txcompl1	       ( hip_pipe_txcompl[1]                   ),       // Templated
        .hip_pipe_txcompl2	       ( hip_pipe_txcompl[2]                   ),       // Templated
        .hip_pipe_txcompl3	       ( hip_pipe_txcompl[3]                   ),       // Templated
        .hip_pipe_txcompl4	       ( hip_pipe_txcompl[4]                   ),       // Templated
        .hip_pipe_txcompl5	       ( hip_pipe_txcompl[5]                   ),       // Templated
        .hip_pipe_txcompl6	       ( hip_pipe_txcompl[6]                   ),       // Templated
        .hip_pipe_txcompl7	       ( hip_pipe_txcompl[7]                   ),       // Templated
        .hip_pipe_txdata0	       ( hip_pipe_txdata[0]                   ),        // Templated
        .hip_pipe_txdata1	       ( hip_pipe_txdata[1]                   ),        // Templated
        .hip_pipe_txdata2	       ( hip_pipe_txdata[2]                   ),        // Templated
        .hip_pipe_txdata3	       ( hip_pipe_txdata[3]                   ),        // Templated
        .hip_pipe_txdata4	       ( hip_pipe_txdata[4]                   ),        // Templated
        .hip_pipe_txdata5	       ( hip_pipe_txdata[5]                   ),        // Templated
        .hip_pipe_txdata6	       ( hip_pipe_txdata[6]                   ),        // Templated
        .hip_pipe_txdata7	       ( hip_pipe_txdata[7]                   ),        // Templated
        .hip_pipe_txdatak0	       ( hip_pipe_txdatak[0]                   ),       // Templated
        .hip_pipe_txdatak1	       ( hip_pipe_txdatak[1]                   ),       // Templated
        .hip_pipe_txdatak2	       ( hip_pipe_txdatak[2]                   ),       // Templated
        .hip_pipe_txdatak3	       ( hip_pipe_txdatak[3]                   ),       // Templated
        .hip_pipe_txdatak4	       ( hip_pipe_txdatak[4]                   ),       // Templated
        .hip_pipe_txdatak5	       ( hip_pipe_txdatak[5]                   ),       // Templated
        .hip_pipe_txdatak6	       ( hip_pipe_txdatak[6]                   ),       // Templated
        .hip_pipe_txdatak7	       ( hip_pipe_txdatak[7]                   ),       // Templated
        .hip_pipe_txdetectrx0	       ( hip_pipe_txdetectrx[0]                   ),    // Templated
        .hip_pipe_txdetectrx1	       ( hip_pipe_txdetectrx[1]                   ),    // Templated
        .hip_pipe_txdetectrx2	       ( hip_pipe_txdetectrx[2]                   ),    // Templated
        .hip_pipe_txdetectrx3	       ( hip_pipe_txdetectrx[3]                   ),    // Templated
        .hip_pipe_txdetectrx4	       ( hip_pipe_txdetectrx[4]                   ),    // Templated
        .hip_pipe_txdetectrx5	       ( hip_pipe_txdetectrx[5]                   ),    // Templated
        .hip_pipe_txdetectrx6	       ( hip_pipe_txdetectrx[6]                   ),    // Templated
        .hip_pipe_txdetectrx7	       ( hip_pipe_txdetectrx[7]                   ),    // Templated
        .hip_pipe_txelecidle0	       ( hip_pipe_txelecidle[0]                   ),    // Templated
        .hip_pipe_txelecidle1	       ( hip_pipe_txelecidle[1]                   ),    // Templated
        .hip_pipe_txelecidle2	       ( hip_pipe_txelecidle[2]                   ),    // Templated
        .hip_pipe_txelecidle3	       ( hip_pipe_txelecidle[3]                   ),    // Templated
        .hip_pipe_txelecidle4	       ( hip_pipe_txelecidle[4]                   ),    // Templated
        .hip_pipe_txelecidle5	       ( hip_pipe_txelecidle[5]                   ),    // Templated
        .hip_pipe_txelecidle6	       ( hip_pipe_txelecidle[6]                   ),    // Templated
        .hip_pipe_txelecidle7	       ( hip_pipe_txelecidle[7]                   ),    // Templated
        .hip_pipe_txdeemph0	       ( hip_pipe_txdeemph[0]                   ),      // Templated
        .hip_pipe_txdeemph1	       ( hip_pipe_txdeemph[1]                   ),      // Templated
        .hip_pipe_txdeemph2	       ( hip_pipe_txdeemph[2]                   ),      // Templated
        .hip_pipe_txdeemph3	       ( hip_pipe_txdeemph[3]                   ),      // Templated
        .hip_pipe_txdeemph4	       ( hip_pipe_txdeemph[4]                   ),      // Templated
        .hip_pipe_txdeemph5	       ( hip_pipe_txdeemph[5]                   ),      // Templated
        .hip_pipe_txdeemph6	       ( hip_pipe_txdeemph[6]                   ),      // Templated
        .hip_pipe_txdeemph7	       ( hip_pipe_txdeemph[7]                   ),      // Templated
        .hip_pipe_txmargin0	       ( hip_pipe_txmargin[0]                   ),      // Templated
        .hip_pipe_txmargin1	       ( hip_pipe_txmargin[1]                   ),      // Templated
        .hip_pipe_txmargin2	       ( hip_pipe_txmargin[2]                   ),      // Templated
        .hip_pipe_txmargin3	       ( hip_pipe_txmargin[3]                   ),      // Templated
        .hip_pipe_txmargin4	       ( hip_pipe_txmargin[4]                   ),      // Templated
        .hip_pipe_txmargin5	       ( hip_pipe_txmargin[5]                   ),      // Templated
        .hip_pipe_txmargin6	       ( hip_pipe_txmargin[6]                   ),      // Templated
        .hip_pipe_txmargin7	       ( hip_pipe_txmargin[7]                   ),      // Templated
        .hip_pipe_txswing0	       ( hip_pipe_txswing[0]                   ),       // Templated
        .hip_pipe_txswing1	       ( hip_pipe_txswing[1]                   ),       // Templated
        .hip_pipe_txswing2	       ( hip_pipe_txswing[2]                   ),       // Templated
        .hip_pipe_txswing3	       ( hip_pipe_txswing[3]                   ),       // Templated
        .hip_pipe_txswing4	       ( hip_pipe_txswing[4]                   ),       // Templated
        .hip_pipe_txswing5	       ( hip_pipe_txswing[5]                   ),       // Templated
        .hip_pipe_txswing6	       ( hip_pipe_txswing[6]                   ),       // Templated
        .hip_pipe_txswing7	       ( hip_pipe_txswing[7]                   ),       // Templated
        // Inputs
        .iRST_NPOR_n		       (iRST_NPOR_n),
        .iPIN_PERST_n		       (iPIN_PERST_n),
        .iRST_100M_N		       (iRST_100M_N),
        .iRST_PCIE_N		       ( {2{iRST_PCIE_N[LINKS-1:0]}}       ),   // Templated
        .iREF_CLK		       (iREF_CLK),
        .iCLK_PCIE_GLOBAL	       (iCLK_PCIE_GLOBAL),
        .iCLK_100M		       (iCLK_100M),
        .iRECONFIG_XCVR_CLK	       (iRECONFIG_XCVR_CLK),
        .iHIP_CTRL_TEST_IN	       (iHIP_CTRL_TEST_IN[31:0]),
        .iHIP_CTRL_SIMU_MODE_PIPE      (iHIP_CTRL_SIMU_MODE_PIPE),
        .iMM2PCIE_ACK		       ( mm2pcie_ack_sync                  ),   // Templated
        .iMM2PCIE_RD_DATA	       ( mm2pcie_rd_data_sync[63:0]        ),   // Templated
        .iMM_WR_DATA		       ( iPCIE_MM_WR_DATA[63:0]                     ),  // Templated
        .iMM_ADDR		       ( iPCIE_MM_ADDR[20:0]                     ),     // Templated
        .iMM_WR_EN		       ( iPCIE_MM_WR_EN                     ),          // Templated
        .iMM_RD_EN		       ( iPCIE_MM_RD_EN                     ),          // Templated
        .iDPLBUF_REQ		       ( pcie_dplbuf_req[PORTS-1:0]                 ),  // Templated
        .iDPLBUF_DATA		       ( pcie_dplbuf_data[255:0]                ),      // Templated
        .iDPLBUF_DATA_V	               ( pcie_dplbuf_data_v[PORTS-1:0]              ),  // Templated
        .iHIP_SERIAL_RX_IN0	       (iHIP_SERIAL_RX_IN0),
        .iHIP_SERIAL_RX_IN1	       (iHIP_SERIAL_RX_IN1),
        .iHIP_SERIAL_RX_IN2	       (iHIP_SERIAL_RX_IN2),
        .iHIP_SERIAL_RX_IN3	       (iHIP_SERIAL_RX_IN3),
        .iHIP_SERIAL_RX_IN4	       (iHIP_SERIAL_RX_IN4),
        .iHIP_SERIAL_RX_IN5	       (iHIP_SERIAL_RX_IN5),
        .iHIP_SERIAL_RX_IN6	       (iHIP_SERIAL_RX_IN6),
        .iHIP_SERIAL_RX_IN7	       (iHIP_SERIAL_RX_IN7),
        .hip_pipe_sim_pipe_pclk_in     (hip_pipe_sim_pipe_pclk_in),
        .hip_pipe_phystatus0	       ( hip_pipe_phystatus[0]                   ),     // Templated
        .hip_pipe_phystatus1	       ( hip_pipe_phystatus[1]                   ),     // Templated
        .hip_pipe_phystatus2	       ( hip_pipe_phystatus[2]                   ),     // Templated
        .hip_pipe_phystatus3	       ( hip_pipe_phystatus[3]                   ),     // Templated
        .hip_pipe_phystatus4	       ( hip_pipe_phystatus[4]                   ),     // Templated
        .hip_pipe_phystatus5	       ( hip_pipe_phystatus[5]                   ),     // Templated
        .hip_pipe_phystatus6	       ( hip_pipe_phystatus[6]                   ),     // Templated
        .hip_pipe_phystatus7	       ( hip_pipe_phystatus[7]                   ),     // Templated
        .hip_pipe_rxdata0	       ( hip_pipe_rxdata[0]                   ),        // Templated
        .hip_pipe_rxdata1	       ( hip_pipe_rxdata[1]                   ),        // Templated
        .hip_pipe_rxdata2	       ( hip_pipe_rxdata[2]                   ),        // Templated
        .hip_pipe_rxdata3	       ( hip_pipe_rxdata[3]                   ),        // Templated
        .hip_pipe_rxdata4	       ( hip_pipe_rxdata[4]                   ),        // Templated
        .hip_pipe_rxdata5	       ( hip_pipe_rxdata[5]                   ),        // Templated
        .hip_pipe_rxdata6	       ( hip_pipe_rxdata[6]                   ),        // Templated
        .hip_pipe_rxdata7	       ( hip_pipe_rxdata[7]                   ),        // Templated
        .hip_pipe_rxdatak0	       ( hip_pipe_rxdatak[0]                   ),       // Templated
        .hip_pipe_rxdatak1	       ( hip_pipe_rxdatak[1]                   ),       // Templated
        .hip_pipe_rxdatak2	       ( hip_pipe_rxdatak[2]                   ),       // Templated
        .hip_pipe_rxdatak3	       ( hip_pipe_rxdatak[3]                   ),       // Templated
        .hip_pipe_rxdatak4	       ( hip_pipe_rxdatak[4]                   ),       // Templated
        .hip_pipe_rxdatak5	       ( hip_pipe_rxdatak[5]                   ),       // Templated
        .hip_pipe_rxdatak6	       ( hip_pipe_rxdatak[6]                   ),       // Templated
        .hip_pipe_rxdatak7	       ( hip_pipe_rxdatak[7]                   ),       // Templated
        .hip_pipe_rxelecidle0	       ( hip_pipe_rxelecidle[0]                   ),    // Templated
        .hip_pipe_rxelecidle1	       ( hip_pipe_rxelecidle[1]                   ),    // Templated
        .hip_pipe_rxelecidle2	       ( hip_pipe_rxelecidle[2]                   ),    // Templated
        .hip_pipe_rxelecidle3	       ( hip_pipe_rxelecidle[3]                   ),    // Templated
        .hip_pipe_rxelecidle4	       ( hip_pipe_rxelecidle[4]                   ),    // Templated
        .hip_pipe_rxelecidle5	       ( hip_pipe_rxelecidle[5]                   ),    // Templated
        .hip_pipe_rxelecidle6	       ( hip_pipe_rxelecidle[6]                   ),    // Templated
        .hip_pipe_rxelecidle7	       ( hip_pipe_rxelecidle[7]                   ),    // Templated
        .hip_pipe_rxstatus0	       ( hip_pipe_rxstatus[0]                   ),      // Templated
        .hip_pipe_rxstatus1	       ( hip_pipe_rxstatus[1]                   ),      // Templated
        .hip_pipe_rxstatus2	       ( hip_pipe_rxstatus[2]                   ),      // Templated
        .hip_pipe_rxstatus3	       ( hip_pipe_rxstatus[3]                   ),      // Templated
        .hip_pipe_rxstatus4	       ( hip_pipe_rxstatus[4]                   ),      // Templated
        .hip_pipe_rxstatus5	       ( hip_pipe_rxstatus[5]                   ),      // Templated
        .hip_pipe_rxstatus6	       ( hip_pipe_rxstatus[6]                   ),      // Templated
        .hip_pipe_rxstatus7	       ( hip_pipe_rxstatus[7]                   ),      // Templated
        .hip_pipe_rxvalid0	       ( hip_pipe_rxvalid[0]                   ),       // Templated
        .hip_pipe_rxvalid1	       ( hip_pipe_rxvalid[1]                   ),       // Templated
        .hip_pipe_rxvalid2	       ( hip_pipe_rxvalid[2]                   ),       // Templated
        .hip_pipe_rxvalid3	       ( hip_pipe_rxvalid[3]                   ),       // Templated
        .hip_pipe_rxvalid4	       ( hip_pipe_rxvalid[4]                   ),       // Templated
        .hip_pipe_rxvalid5	       ( hip_pipe_rxvalid[5]                   ),       // Templated
        .hip_pipe_rxvalid6	       ( hip_pipe_rxvalid[6]                   ),       // Templated
        .hip_pipe_rxvalid7	       ( hip_pipe_rxvalid[7]                   ));      // Templated
end

endgenerate

///////////////////////////////////////////////////////////////////////////////
// mm reg out sync
///////////////////////////////////////////////////////////////////////////////
/* vi_sync_csr AUTO_TEMPLATE 
     (// Outputs
      .oACK_A				(mm2pcie_ack_sync),
      .oRD_DATA_A			(mm2pcie_rd_data_sync[]),
      .oWREN_B				(oPCIE2MM_WR_EN),
      .oRDEN_B				(oPCIE2MM_RD_EN),
      .oWR_DATA_B			(oPCIE2MM_WR_DATA[]),
      .oADDR_B				(oPCIE2MM_ADDRESS[]),
      // Inputs
      .iRST_N_A				(iRST_NPOR_n),
      .iCLK_A				(iCLK_PCIE_GLOBAL),
      .iWREN_A				(pcie2mm_wr_en_a),
      .iRDEN_A				(pcie2mm_rd_en_a),
      .iADDR_A				(pcie2mm_address_hold[]),
      .iWR_DATA_A			(pcie2mm_wr_data_hold[]),
      .iRST_N_B				(iRST_CORE_N),
      .iCLK_B				(iCLK_CORE), 
      .iRD_DATA_B			(iMM2PCIE_RD_DATA[]),
      .iACK_B				(iMM2PCIE_RD_DATA_V),
    );
*/

vi_sync_csr pcie_out_sync 
(       /*AUTOINST*/
        // Outputs
        .oACK_A				       (mm2pcie_ack_sync),	        // Templated
        .oRD_DATA_A			       (mm2pcie_rd_data_sync[63:0]),    // Templated
        .oWREN_B				       (oPCIE2MM_WR_EN),	        // Templated
        .oRDEN_B				       (oPCIE2MM_RD_EN),	        // Templated
        .oWR_DATA_B			               (oPCIE2MM_WR_DATA[63:0]),        // Templated
        .oADDR_B				       (oPCIE2MM_ADDRESS[20:0]),        // Templated
        // Inputs
        .iRST_N_A				       (iRST_NPOR_n),		        // Templated
        .iCLK_A				               (iCLK_PCIE_GLOBAL),	        // Templated
        .iWREN_A				       (pcie2mm_wr_en_a),	        // Templated
        .iRDEN_A				       (pcie2mm_rd_en_a),	        // Templated
        .iADDR_A				       (pcie2mm_address_hold[20:0]),    // Templated
        .iWR_DATA_A			               (pcie2mm_wr_data_hold[63:0]),    // Templated
        .iRST_N_B				       (iRST_CORE_N),	                // Templated
        .iCLK_B				               (iCLK_CORE),		        // Templated
        .iRD_DATA_B			               (iMM2PCIE_RD_DATA[63:0]),        // Templated
        .iACK_B				               (iMM2PCIE_RD_DATA_V));	        // Templated


// hold address and write_data constant through operation
always @(posedge iCLK_PCIE_GLOBAL or negedge iRST_NPOR_n) begin
        pcie2mm_address_hold[20:0] <= ~iRST_NPOR_n                     ? 21'd0 :
        (pcie2mm_wr_en_a | pcie2mm_rd_en_a) ? pcie2mm_address[20:0] :
        pcie2mm_address_hold[20:0];
        pcie2mm_wr_data_hold[63:0] <= ~iRST_NPOR_n                     ? 64'd0 :
        pcie2mm_wr_en_a                     ? pcie2mm_wr_data[63:0] :
        pcie2mm_wr_data_hold[63:0];
        // FIXME:  Temporary hack until we have WR_ACK
        mm2pcie_wr_ack_delay[31:0] <= ~iRST_NPOR_n                     ? 32'd0 :
        {mm2pcie_wr_ack_delay[30:0],pcie2mm_wr_en_a};
end 



endmodule

// Local Variables:
// verilog-library-directories:("." "../../link_engine/rtl" "../../../../bali_dal/prototype/pcie/rtl" "../../link_engine/lib" "../../../../common/vi_lib")
// verilog-library-extensions:(".v" ".sv" ".h")
// End:
