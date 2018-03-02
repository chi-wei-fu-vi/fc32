
`timescale 1 ns / 1 ns

module alt_xcvr_reconfig #(
  parameter device_family = "Stratix V",

  // reconfig blocks to enable or disable
  parameter enable_offset = 1,  // always need offset cancellation to calibrate buffers
  parameter enable_lc     = 1,  // LC Tuning
  parameter enable_dcd    = 0,  // DCD
  parameter enable_dcd_power_up = 1, // 0: manual trigger; 1: manual trigger + auto run upon power up
  parameter enable_analog = 0,  // manual tuning of buffer analog parameters
  parameter enable_eyemon = 0,  // EyeQ
  parameter enable_ber    = 0, //Enables the BER Counter
  parameter enable_dfe    = 0,  // DFE
  parameter enable_adce   = 0,  // ADCE
  parameter enable_mif    = 0,  // MIF streaming
  parameter enable_pll    = 0,  // PLL reconfig
  parameter enable_direct = 1,  // Direct Basic access

  // number of physical reconfig interfaces
  parameter number_of_reconfig_interfaces = 1
) (
  input  wire                                 mgmt_clk_clk,
  input  wire                                 mgmt_rst_reset,

  // user reconfiguration management interface
  input  wire  [6:0]                          reconfig_mgmt_address,
  output wire                                 reconfig_mgmt_waitrequest,
  input  wire                                 reconfig_mgmt_read,
  output wire  [31:0]                         reconfig_mgmt_readdata,
  input  wire                                 reconfig_mgmt_write,
  input  wire  [31:0]                         reconfig_mgmt_writedata,
  output wire                                 reconfig_busy,

  // calibration port
  input  wire                                 cal_busy_in,
  output wire                                 tx_cal_busy,
  output wire                                 rx_cal_busy,

  //MIF storage interface
  output wire  [31:0]                         reconfig_mif_address,
  output wire                                 reconfig_mif_read,
  input  wire                                 reconfig_mif_waitrequest,
  input  wire  [15:0]                         reconfig_mif_readdata,

  // bundled reconfig buses

  output wire  [770 -1:0] reconfig_to_xcvr,              //   all native xcvr reconfig sinks
  input  wire  [506 -1:0] reconfig_from_xcvr             //   all native xcvr reconfig sources
);


  assign reconfig_mgmt_waitrequest = 0;
  assign reconfig_mgmt_readdata = 0;
  assign reconfig_busy = 0;
  assign tx_cal_busy = 0;
  assign rx_cal_busy = 0;
  assign reconfig_mif_address = 0;
  assign reconfig_mif_read = 0;
  assign reconfig_to_xcvr = 0;
endmodule
