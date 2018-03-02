/***************************************************************************
* Copyright (c) 2011 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: $
* $Author: $
* $Date: $
* $Revision: $
* Description:
*
***************************************************************************/
module dynamicReconfig #(
  parameter                                   AVALON = 0,
  parameter                                   LINKS  = 13
) (
  // global signals
  input  wire                                 clk,
  input  wire                                 reset,
  input  wire                                 soft_reset,
  input  wire                                 mif_retry,
  input  wire                                 direct_access,

  // global signals
  input  wire  [LINKS-1:0][3:0]               data_rate,
  output logic [LINKS-1:0][3:0]               status_data_rate,
  output logic [3:0]                          status_error,
  output logic                                timeout_error,
  output logic [31:0]                         min_linkspeed_reconfig,
  output logic [31:0]                         max_linkspeed_reconfig,

  // mm interface
  input  wire  [10:0]                         mm_address,
  output logic [31:0]                         mm_readdata,
  output logic                                mm_ack,
  output logic                                mm_waitrequest,
  input  wire                                 mm_read,
  input  wire                                 mm_write,
  input  wire  [31:0]                         mm_writedata,

  // user reconfiguration management interface
  output logic [8:0]                          reconfig_mgmt_address,
  input  wire  [2:0]                          reconfig_mgmt_waitrequest,
  input  wire                                 reconfig_busy,
  output logic [2:0]                          reconfig_mgmt_read,
  input  wire  [2:0][31:0]                    reconfig_mgmt_readdata,
  output logic [2:0]                          reconfig_mgmt_write,
  output logic [31:0]                         reconfig_mgmt_writedata 
);

  // local parameter
  // Data Rate
  import           dynamicReconfig_pkg::DataRate4G;             // 2'b10
  import           dynamicReconfig_pkg::DataRate8G;             // 2'b11
  import           dynamicReconfig_pkg::DataRate16G;            // 2'b00
  import           dynamicReconfig_pkg::DefaultRate;            // DataRate16G

  // MIF ROM base address
  import           dynamicReconfig_pkg::ROM4GAddr;              // 11'h000
  import           dynamicReconfig_pkg::ROM8GAddr;              // 11'h200
  import           dynamicReconfig_pkg::ROM16GAddr;             // 11'h400

  // Reconfigure base address for each register groups

  import           dynamicReconfig_pkg::AnalogControlAddr;      // 1 << 3
  import           dynamicReconfig_pkg::EyeQAddr;               // 2 << 3
  import           dynamicReconfig_pkg::DFEAddr;                // 3 << 3

  import           dynamicReconfig_pkg::AEQAddr;                // 5 << 3
  import           dynamicReconfig_pkg::ATXPLLAddr;             // 6 << 3
  import           dynamicReconfig_pkg::StreamerAddr;           // 7 << 3
  import           dynamicReconfig_pkg::PLLAddr;                // 8 << 3

  // Direct Registers
  import           dynamicReconfig_pkg::LogicalChanNo;          // 3'd0
  import           dynamicReconfig_pkg::PhysicalChanNo;         // 3'd1
  import           dynamicReconfig_pkg::ControlStatus;          // 3'd2
  import           dynamicReconfig_pkg::AddrOffset;             // 3'd3
  import           dynamicReconfig_pkg::DataReg;                // 3'd4

  // Stream direct register bit map
  import           dynamicReconfig_pkg::StreamerErrorMask;      // 32'h0000_0200
  import           dynamicReconfig_pkg::StreamerBusyMask;       // 32'h0000_0100
  import           dynamicReconfig_pkg::StreamerMode0Mask;      // 32'h0000_0000
  import           dynamicReconfig_pkg::StreamerMode1Mask;      // 32'h0000_0004
  import           dynamicReconfig_pkg::StreamerReadMask;       // 32'h0000_0002
  import           dynamicReconfig_pkg::StreamerWriteMask;      // 32'h0000_0001


  // Streamer indirect registers
  import           dynamicReconfig_pkg::MIFBaseAddr;            // 16'h0000
  import           dynamicReconfig_pkg::MIFControl;             // 16'h0001
  import           dynamicReconfig_pkg::MIFStatus;              // 16'h0002

  // Stream indirect register bit map
  import           dynamicReconfig_pkg::MIFClrErrMask;          // 32'h0000_0004
  import           dynamicReconfig_pkg::MIFAddrModeMask;        // 32'h0000_0002
  import           dynamicReconfig_pkg::MIFStartMask;           // 32'h0000_0001

  import           dynamicReconfig_pkg::MIFChMisMatchMask;      // 32'h0000_0010
  import           dynamicReconfig_pkg::MIFRecnfgErrMask;       // 32'h0000_0004
  import           dynamicReconfig_pkg::MIFCodeErrMask;         // 32'h0000_0002
  import           dynamicReconfig_pkg::MIFInvalidRegErrMask;   // 32'h0000_0001

  // main state machine
  typedef enum bit[2:0] {
    ST_IDLE,
    ST_EVEN_CHL,
    ST_ODD_CHL,
    ST_DREAD,
    ST_DWRITE,
    ST_UPDATE,
    ST_DONE
  } stateType;

  // MIF state machine
  typedef enum bit[3:0] {
    ST_MIF_IDLE,
    ST_MIF_DWRITE_CHNO,
    ST_MIF_DWRITE_MODE,
    ST_MIF_IWRITE_BASEADDR,
    ST_MIF_IWRITE_CLEAR,
    ST_MIF_IWRITE_START,
    ST_MIF_DREAD_BUSY,
    ST_MIF_RECONF_BUSY,
    ST_MIF_IWRITE_DUMMY,
    ST_MIF_IWRITE_CHECK
  } mifStateType;

  // indirect read state
  typedef enum bit[1:0] {
    ST_IRD_IDLE,
    ST_IRD_WR_OFFSET,
    ST_IRD_RD_START,
    ST_IRD_RD_DATA
  } irdStateType;

  // indirect write state
  typedef enum bit[1:0] {
    ST_IWR_IDLE,
    ST_IWR_WR_OFFSET,
    ST_IWR_WR_DATA,
    ST_IWR_WR_START
  } iwrStateType;

  // direct read/write state machine
  typedef enum bit[1:0] {
    ST_DRW_IDLE,
    ST_DRW_READ,
    ST_DRW_WRITE
  } drwStateType;

  stateType                             main_state;
  mifStateType                          mif_state;
  iwrStateType                          iwr_state;
  irdStateType                          ird_state;
  drwStateType                          drw_state;

  // support mode 0 - stream mif
  logic                                 bus_waitrequest;
  logic                                 bus_read;
  logic                                 bus_write;
  logic  [31:0]                         bus_writedata;
  logic  [LINKS:0]                      bus_req;               // host access and link data rate changes
  logic  [LINKS:0]                      bus_grant;
  logic  [LINKS:0]                      bus_take;
  logic  [3:0]                          change_data_rate;
  logic  [4:0]                          main_chan_no;

  logic  [LINKS:1][3:0]                 link_index;
  logic  [LINKS:0][3:0]                 link_no;

  logic                                 ird_drd_start;
  logic                                 ird_dwr_start;
  logic                                 iwr_drd_start;
  logic                                 iwr_dwr_start;
  logic                                 main_drd_start;
  logic                                 main_dwr_start;
  logic                                 main_mif_start;
  logic                                 mif_drd_start;
  logic                                 mif_dwr_start;
  logic                                 mif_ird_start;
  logic                                 mif_iwr_start;

  logic  [6:0]                          ird_address;
  logic  [6:0]                          iwr_address;
  logic  [6:0]                          mif_address;
  logic  [31:0]                         ird_readdata;
  logic  [31:0]                         mif_writedata;
  logic  [31:0]                         ird_writedata;
  logic  [31:0]                         iwr_writedata;
  logic  [31:0]                         drd_readdata;
  logic                                 drd_done;
  logic                                 dwr_done;
  logic                                 ird_done;
  logic                                 iwr_done;
  logic                                 mif_done;
  logic                                 mif_error;
  logic                                 mif_retry_sync_d;
  logic                                 mif_timeout;
  logic  [LINKS:1]                      rate_mismatch;
  logic  [15:0]                         timeout_cntr;
  genvar                                gi;

  logic                                 soft_reset_sync;
  logic                                 mif_retry_sync;
  logic                                 direct_access_sync;
  logic  [LINKS-1:0][3:0]               data_rate_sync;

   logic [31:0] 			reconfig_timer;
   logic [LINKS-1:0][3:0] 		data_rate_q;
   logic [LINKS-1:0] 			rate_change_vec;
   logic 				reconfig_busy_q, reconfig_done, rate_change;


vi_sync_1c #(
  . TWO_DST_FLOPS                            ( 0                                        ),
  . SIZE                                     ( LINKS*4+3                                ) 
) vi_sync_1c_inst (
  . out                                      ( { soft_reset_sync,mif_retry_sync,direct_access_sync,data_rate_sync } ), // output [SIZE-1:0]
  . clk_dst                                  ( clk                                                                  ), // input 
  . rst_n_dst                                ( !reset                                                               ), // input 
  . in                                       ( { soft_reset,mif_retry,direct_access,data_rate }                     )  // input [SIZE-1:0]
);



 

  // arbitration logic
  always_ff @(posedge clk)
    if (reset) begin
      status_data_rate                          <= {LINKS{DefaultRate}};
      change_data_rate                          <= {LINKS{DefaultRate}};
    end
    else if (main_state == ST_IDLE) begin
      for (int i = 0; i < LINKS; i = i + 1)
        if (bus_grant[i+1]) change_data_rate    <= {data_rate_sync[i]};
    end
    else if (mif_error || mif_timeout)
      change_data_rate                          <= 4'hF;
    else if (main_state == ST_UPDATE) begin
      for (int i = 0; i < LINKS; i = i + 1)
        if (bus_grant[i+1]) status_data_rate[i]   <= change_data_rate;
    end


  // what happens if host issue another write before completion of the current write.
  generate
    if (AVALON) begin: avalon_mm
      always_ff @(posedge clk)
        if (reset) begin
          bus_req                                   <= {(LINKS+1){1'b0}};
          bus_read                                  <= 1'b0;
          bus_write                                 <= 1'b0;
          bus_waitrequest                           <= 1'b0;
        end
        else begin
          bus_read                                  <= mm_read;
          bus_write                                 <= mm_write;
          bus_writedata                             <= mm_writedata;
          bus_req[0]                                <= bus_req[0] ? !(bus_grant[0] && main_state == ST_DONE) : (mm_read && !bus_read) || (mm_write && !bus_write);
          bus_req[1 +: LINKS]                       <= rate_mismatch[1 +: LINKS];
          bus_waitrequest                           <= bus_waitrequest ? !(drd_done || dwr_done) : (mm_read && !bus_read) || (mm_write && !bus_write);
        end
      assign mm_waitrequest                          = bus_waitrequest || (mm_read && !bus_read) || (mm_write && !bus_write);
    end
    else begin: pcie_mm
      always_ff @(posedge clk)
        if (reset) begin
          bus_req                                   <= {(LINKS+1){1'b0}};
          bus_read                                  <= 1'b0;
          bus_write                                 <= 1'b0;
        end
        else begin
          bus_read                                  <= bus_read    ? !(bus_grant[0] && main_state == ST_DONE) : mm_read;
          bus_write                                 <= bus_write   ? !(bus_grant[0] && main_state == ST_DONE) : mm_write;
          bus_writedata                             <= bus_write   ? mm_writedata : bus_writedata;
          bus_req[0]                                <= bus_req[0] ? !(bus_grant[0] && main_state == ST_DONE) : mm_read || mm_write;
          bus_req[1 +: LINKS]                       <= rate_mismatch[1 +: LINKS];
        end
      assign mm_waitrequest                          = 1'b0;
    end
  endgenerate
  // priority decoder
  assign bus_take[0] = bus_req[0] && direct_access_sync;
  generate
    for (gi = 1; gi < (LINKS+1); gi = gi + 1) begin : bus_take_gen
      assign bus_take[gi]  = direct_access_sync ? 0 : bus_req[gi] & (~| (bus_req & {gi{1'b1}})); // no req from high-priority inputs
      assign rate_mismatch[gi] = (data_rate_sync[gi-1] != status_data_rate[gi-1]) && (status_data_rate[gi-1] != 4'hF || mif_retry_sync);
    end
  endgenerate

  always_ff @(posedge clk)
    if (reset)
      bus_grant                                 <= {(LINKS+1){1'b0}};
    else if (bus_grant == 0 && !reconfig_busy)
      bus_grant                                 <= bus_take;
    else if (main_state == ST_DONE)
      bus_grant                                 <= 0;


  // Main state machine
  assign link_no[0] = 0;
  generate
    for (gi = 1; gi < (LINKS+1); gi = gi + 1) begin : link_no_gen
      assign link_index[gi] = bus_grant[gi] ? gi-1 : 0;
      assign link_no[gi]    = link_no[gi-1] | link_index[gi];
    end
  endgenerate
  always @(posedge clk)
    if (reset) begin
      main_state                        <= ST_IDLE;
      main_mif_start                    <= 1'b0;
      main_drd_start                    <= 1'b0;
      main_dwr_start                    <= 1'b0;
      main_chan_no                      <= 5'b0;
      mm_readdata                       <= 32'b0;
      mm_ack                            <= 1'b0;
    end
    else begin
      main_mif_start                    <= 1'b0;
      main_drd_start                    <= 1'b0;
      main_dwr_start                    <= 1'b0;
      mm_ack                            <= 1'b0;
      case (main_state)
        ST_IDLE                    : begin
          if (bus_grant[0] && bus_read) begin
            main_state                  <= ST_DREAD;
            main_drd_start              <= 1'b1;
          end
          else if (bus_grant[0] && bus_write) begin
            main_state                  <= ST_DWRITE;
            main_dwr_start              <= 1'b1;
          end
          else if (|bus_grant[1 +: LINKS]) begin
            main_state                  <= ST_EVEN_CHL;
            main_mif_start              <= 1'b1;
            main_chan_no                <= {link_no[LINKS],1'b0};
          end
        end
        ST_EVEN_CHL          : begin
          if (mif_error) begin
            main_state                  <= ST_UPDATE;
          end
          else if (mif_done) begin
            main_state                  <= ST_ODD_CHL;
            main_mif_start              <= 1'b1;
            main_chan_no                <= {link_no[LINKS],1'b1};
          end
        end
        ST_ODD_CHL           : begin
          if (mif_done) begin
            main_state                  <= ST_UPDATE;
          end
        end
        ST_DREAD             : begin
          if (drd_done) begin
            main_state                  <= ST_DONE;
            mm_readdata[0 +: 32]        <= drd_readdata[0 +: 32];
            mm_ack                      <= 1'b1;
          end
        end
        ST_DWRITE            : begin
          if (dwr_done) begin
            main_state                  <= ST_DONE;
            mm_ack                      <= 1'b1;
          end
        end
        ST_UPDATE            : begin
          main_state                    <= ST_DONE;
        end
        ST_DONE              : begin
          main_state                    <= ST_IDLE;
        end
      endcase
    end

  // streamer state machine
  always @(posedge clk)
    if (reset) begin
      mif_state                         <= ST_MIF_IDLE;
      mif_done                          <= 1'b0;
      mif_drd_start                     <= 1'b0;
      mif_dwr_start                     <= 1'b0;
      mif_iwr_start                     <= 1'b0;
      mif_ird_start                     <= 1'b0;
      mif_address                       <= 7'b0;
      mif_error                         <= 1'b0;
      status_error                      <= 4'b0;
      mif_writedata                     <= 32'b0;
      timeout_cntr                      <= 8'b0;
      mif_timeout                       <= 1'b0;
      timeout_error                     <= 1'b0;
      mif_retry_sync_d                  <= 1'b0;
    end
    else begin
      mif_done                          <= 1'b0;
      mif_drd_start                     <= 1'b0;
      mif_dwr_start                     <= 1'b0;
      mif_iwr_start                     <= 1'b0;
      mif_ird_start                     <= 1'b0;
      mif_error                         <= 1'b0;
      mif_timeout                       <= 1'b0;
      mif_retry_sync_d                  <= mif_retry_sync;
      if (mif_retry_sync && !mif_retry_sync_d)
        status_error                    <= 4'b0;
      case (mif_state)
        ST_MIF_IDLE             : begin
          if (main_mif_start) begin
            mif_state                    <= ST_MIF_IWRITE_CLEAR;
            mif_iwr_start                <= 1'b1;
            mif_address                  <= MIFControl;
            mif_writedata                <= MIFClrErrMask;
          end
        end
        ST_MIF_IWRITE_CLEAR     : begin
          if (iwr_done) begin
            mif_state                    <= ST_MIF_DWRITE_CHNO;
            mif_dwr_start                <= 1'b1;
            mif_address                  <= LogicalChanNo;
            mif_writedata                <= main_chan_no;
          end
        end
        ST_MIF_DWRITE_CHNO      : begin
          if (dwr_done) begin
            mif_state                    <= ST_MIF_DWRITE_MODE;
            mif_dwr_start                <= 1'b1;
            mif_address                  <= ControlStatus;
            mif_writedata                <= 1'b0;
          end
        end
        ST_MIF_DWRITE_MODE      : begin
          if (dwr_done) begin
             mif_state                    <= ST_MIF_IWRITE_BASEADDR;
             mif_iwr_start                <= 1'b1;
             mif_address                  <= MIFBaseAddr;            // 16'h0000
             case (change_data_rate)
               DataRate4G : begin
                 mif_writedata            <= {21'b0,ROM4GAddr};
               end             // 2'b00
               DataRate8G : begin
                 mif_writedata            <= {21'b0,ROM8GAddr};
               end             // 2'b01
               DataRate16G : begin
                 mif_writedata            <= {21'b0,ROM16GAddr};
               end             // 2'b10
             endcase
          end
        end
        ST_MIF_IWRITE_BASEADDR  : begin
          if (iwr_done) begin
            mif_state                    <= ST_MIF_IWRITE_START;
            mif_iwr_start                <= 1'b1;
            mif_address                  <= MIFControl;
            mif_writedata                <= MIFStartMask;
          end
        end
        ST_MIF_IWRITE_START     : begin
          if (iwr_done) begin
            mif_state                    <= ST_MIF_DREAD_BUSY;
            mif_drd_start                <= 1'b1;
            mif_address                  <= ControlStatus;
          end
        end
        ST_MIF_DREAD_BUSY       : begin
          if (drd_done) begin
            mif_state                    <= ST_MIF_RECONF_BUSY;
            timeout_cntr                 <= 8'b0;
          end
        end
        ST_MIF_RECONF_BUSY      : begin
          if (timeout_cntr == 16'hFFFF) begin
            mif_state                    <= ST_MIF_IDLE;
            timeout_error                <= 1'b1;
          end
          else if (!reconfig_busy) begin
            mif_state                    <= ST_MIF_IWRITE_DUMMY;
            mif_ird_start                <= 1'b1;
            mif_address                  <= MIFStatus;
          end
          else begin
            timeout_cntr                 <= timeout_cntr + 1;
          end
        end
        ST_MIF_IWRITE_DUMMY     : begin
          if (ird_done) begin
            mif_state                    <= ST_MIF_IWRITE_CHECK;
            mif_ird_start                <= 1'b1;
            mif_address                  <= MIFStatus;
          end
        end
        ST_MIF_IWRITE_CHECK     : begin
          if (ird_done) begin
            mif_state                    <= ST_MIF_IDLE;
            mif_done                     <= 1'b1;
            if (ird_readdata & ( MIFChMisMatchMask | MIFRecnfgErrMask | MIFCodeErrMask | MIFInvalidRegErrMask )) begin // error occurs
              mif_error                  <= 1'b1;
              status_error               <= {ird_readdata[4],ird_readdata[2:0]};
            end
          end
        end
      endcase
    end
  // indirect read state machine
  always @(posedge clk)
    if (reset) begin
      ird_state                         <= ST_IRD_IDLE;
      ird_dwr_start                     <= 1'b0;
      ird_drd_start                     <= 1'b0;
      ird_done                          <= 1'b0;
      ird_address                       <= 7'b0; 
      ird_writedata                     <= 32'b0; 
      ird_readdata                      <= 32'b0; 
    end
    else begin
      ird_dwr_start                     <= 1'b0;
      ird_drd_start                     <= 1'b0;
      ird_done                          <= 1'b0;
      case (ird_state)
        ST_IRD_IDLE             : begin
          if (mif_ird_start) begin
            ird_state                   <= ST_IRD_WR_OFFSET;
            ird_dwr_start               <= 1'b1;
            ird_address                 <= AddrOffset;             // 3'd3
            ird_writedata               <= mif_address;
          end
        end
        ST_IRD_WR_OFFSET        : begin
          if (dwr_done) begin
            ird_state                   <= ST_IRD_RD_START;
            ird_dwr_start               <= 1'b1;
            ird_address                 <= ControlStatus;          // 3'd2
            ird_writedata               <= StreamerReadMask;       // 32'h0000_0002
          end
        end
        ST_IRD_RD_START         : begin
          if (dwr_done) begin
            ird_state                   <= ST_IRD_RD_DATA;
            ird_drd_start               <= 1'b1;
            ird_address                 <= DataReg;                // 3'd4
          end
        end
        ST_IRD_RD_DATA          : begin
          if (drd_done) begin
            ird_state                   <= ST_IRD_IDLE;
            ird_readdata                <= drd_readdata;
            ird_done                    <= 1'b1;
          end
        end
      endcase
    end

  // indirect write state machine
  always @(posedge clk)
    if (reset) begin
      iwr_state                         <= ST_IWR_IDLE;
      iwr_dwr_start                     <= 1'b0;
      iwr_drd_start                     <= 1'b0;
      iwr_done                          <= 1'b0;
      iwr_address                       <= 7'b0; 
      iwr_writedata                     <= 32'b0; 
    end
    else begin
      iwr_dwr_start                     <= 1'b0;
      iwr_drd_start                     <= 1'b0;
      iwr_done                          <= 1'b0;
      case (iwr_state)
        ST_IWR_IDLE             : begin
          if (mif_iwr_start) begin
            iwr_state                   <= ST_IWR_WR_OFFSET;
            iwr_dwr_start               <= 1'b1;
            iwr_address                 <= AddrOffset;             // 3'd3
            iwr_writedata               <= mif_address;
          end
        end
        ST_IWR_WR_OFFSET        : begin
          if (dwr_done) begin
            iwr_state                   <= ST_IWR_WR_DATA;
            iwr_dwr_start               <= 1'b1;
            iwr_address                 <= DataReg;             // 3'd4
            iwr_writedata               <= mif_writedata;      // 32'h0000_0001
          end
        end
        ST_IWR_WR_DATA          : begin
          if (dwr_done) begin
            iwr_state                   <= ST_IWR_WR_START;
            iwr_dwr_start               <= 1'b1;
            iwr_address                 <= ControlStatus;          // 3'd2
            iwr_writedata               <= StreamerWriteMask;      // 32'h0000_0001
          end
        end
        ST_IWR_WR_START         : begin
          if (dwr_done) begin
            iwr_state                   <= ST_IWR_IDLE;
            iwr_done                    <= 1'b1;
          end
        end
      endcase
    end

  // direct read/write state machine
  always @(posedge clk)
    if (reset) begin
      drd_done                          <= 1'b0;
      drd_readdata                      <= 32'b0;
      drw_state                         <= ST_DRW_IDLE;
      dwr_done                          <= 1'b0;
      reconfig_mgmt_address             <= 9'b0;
      reconfig_mgmt_read                <= 3'b0;
      reconfig_mgmt_write               <= 3'b0;
      reconfig_mgmt_writedata           <= 32'b0;
    end
    else begin
      drd_done                          <= 1'b0;
      dwr_done                          <= 1'b0;
      case (drw_state)
        ST_DRW_IDLE             : begin
          reconfig_mgmt_address         <= 9'b0;
          case (1)
            ird_drd_start               : begin
              drw_state                 <= ST_DRW_READ;
              reconfig_mgmt_address     <= {2'b0,ird_address};
              reconfig_mgmt_read        <= 3'b001;
            end
            iwr_drd_start               : begin
              drw_state                 <= ST_DRW_READ;
              reconfig_mgmt_address     <= {2'b0,iwr_address};
              reconfig_mgmt_read        <= 3'b001;
            end
            main_drd_start              : begin
              drw_state                 <= ST_DRW_READ;
              reconfig_mgmt_address     <= mm_address[8:0]; // fix me
              reconfig_mgmt_read        <= { mm_address[10:9] == 2'd2, mm_address[10:9] == 2'd1, mm_address[10:9] == 2'd0 };
            end
            mif_drd_start               : begin
              drw_state                 <= ST_DRW_READ;
              reconfig_mgmt_address     <= {2'b0,mif_address};
              reconfig_mgmt_read        <= 3'b001;
            end
            ird_dwr_start               : begin
              drw_state                 <= ST_DRW_WRITE;
              reconfig_mgmt_address     <= {2'b0,ird_address};
              reconfig_mgmt_write       <= 3'b001;
              reconfig_mgmt_writedata   <= ird_writedata;
            end
            iwr_dwr_start               : begin
              drw_state                 <= ST_DRW_WRITE;
              reconfig_mgmt_address     <= {2'b0,iwr_address};
              reconfig_mgmt_write       <= 3'b001;
              reconfig_mgmt_writedata   <= iwr_writedata;
            end
            main_dwr_start              : begin
              drw_state                 <= ST_DRW_WRITE;
              reconfig_mgmt_address     <= mm_address[8:0]; // fix me
              reconfig_mgmt_write       <= { mm_address[10:9] == 2'd2, mm_address[10:9] == 2'd1, mm_address[10:9] == 2'd0 };
              reconfig_mgmt_writedata   <= bus_writedata[0 +: 32];
            end
            mif_dwr_start               : begin
              drw_state                 <= ST_DRW_WRITE;
              reconfig_mgmt_address     <= {2'b0,mif_address};
              reconfig_mgmt_write       <= 3'b001;
              reconfig_mgmt_writedata   <= mif_writedata;
            end
          endcase
        end
        ST_DRW_READ             : begin
          if (|(~reconfig_mgmt_waitrequest & reconfig_mgmt_read)) begin
            drw_state                   <= ST_DRW_IDLE;
            drd_done                    <= 1'b1;
            casex (reconfig_mgmt_read)
              3'bxx1: drd_readdata      <= reconfig_mgmt_readdata[0];
              3'bx10: drd_readdata      <= reconfig_mgmt_readdata[1];
              3'b100: drd_readdata      <= reconfig_mgmt_readdata[2];
            endcase
            reconfig_mgmt_read          <= 3'b0;
          end
        end
        ST_DRW_WRITE            : begin
          if (|(~reconfig_mgmt_waitrequest & reconfig_mgmt_write)) begin
            drw_state                   <= ST_DRW_IDLE;
            dwr_done                    <= 1'b1;
            reconfig_mgmt_write         <= 3'b0;
          end
        end
      endcase
    end // else: !if(reset)

    // Reconfig timers
    always_ff @(posedge clk) begin
       max_linkspeed_reconfig[31:0] <= reset ? 32'd0 :
				       (reconfig_done & (reconfig_timer[31:0]>max_linkspeed_reconfig[31:0])) ? reconfig_timer[31:0] :
				       max_linkspeed_reconfig[31:0];
       min_linkspeed_reconfig[31:0] <= reset ? 32'hFFFF_FFFF :
				       (reconfig_done & (reconfig_timer[31:0]<min_linkspeed_reconfig[31:0])) ? reconfig_timer[31:0] :
				       min_linkspeed_reconfig[31:0];
       reconfig_timer[31:0] <= reset         ? 32'd0 :
			       rate_change   ? 32'd1 :
			       reconfig_done ? 32'd0 :
			       ( reconfig_timer[31:0]!=32'hFFFF_FFFF) & (reconfig_timer[31:0]!=32'd0) ? reconfig_timer[31:0]+32'd1 :
			       reconfig_timer[31:0];
       reconfig_busy_q    <= reconfig_busy;
    end // always_ff @

    assign reconfig_done = (reconfig_busy_q & ~reconfig_busy);

    generate
       for (gi = 0; gi < LINKS; gi = gi + 1) begin : gen_rate_change
	  always_ff @(posedge clk)
	    data_rate_q[gi]  <= data_rate_sync[gi];
	  assign rate_change_vec[gi]  = (data_rate_q[gi]!=data_rate_sync[gi]);
       end
    endgenerate

    assign rate_change = |rate_change_vec[LINKS-1:0];
    
endmodule
