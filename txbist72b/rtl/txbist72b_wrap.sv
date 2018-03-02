/***********************************************************************************************************
* Copyright (c) 2012,2013 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Author$
* $Date$
* $Revision$
* $HeadURL$
***********************************************************************************************************/

module txbist72b_wrap #(
  parameter   EMERALD                         = 0,
  parameter   DOMINICA                        = 0,
  parameter    BALI                   = 1
) (
  input        [3:0]                          linkspeed,
  input                                       clk,
  input        [1:0][9:0]                     cr_txbist_addr,
  input        [1:0]                          cr_txbist_rd_en,
  input        [1:0][63:0]                    cr_txbist_wr_data,
  input        [1:0]                          cr_txbist_wr_en,
  input                                       end_of_interval,
  input                                       rst,
  input                                       rst_n,
  output       [1:0]                          cr_txbist_ack,
  output       [1:0][63:0]                    cr_txbist_rd_data,
  output       [1:0][71:0]                    txbist_data,
  output       [1:0]                          txbist_data_val 
   );

   // control register numbers
  localparam RD_ADDR                    = 10'd13;
  localparam WR_DATA                    = 10'd8;
  localparam WR_ADDR                    = 10'd9;
  localparam TX_CTL                     = 10'd7;

  logic  [1:0]                          iREG_TXBIST_TX_PRIM_CNT_EN;
  logic  [1:0]                          iREG_TXBIST_TX_FRAME_CNT_EN;
  logic  [1:0]                          iREG_TXBIST_CRC_ERR_INJ_CNT_EN;
  logic  [1:0][63:0]                    iREG_TXBIST_RD_DATA;
  logic  [1:0][63:0]                    oREG__SCRATCH;
  logic  [1:0][15:0]                    oREG_TXBIST_IPG_MIN;
  logic  [1:0][3:0]                     oREG_TXBIST_IPG_OFFSET;
  logic  [1:0][13:0]                    oREG_TXBIST_RAM_END;
  logic  [1:0][31:0]                    oREG_TXBIST_LOOP_CNT;
  logic  [1:0][63:0]                    oREG_TXBIST_REG_PRIMITIVE;
  logic  [1:0][63:0]                    oREG_TXBIST_IDLE_PRIMITIVE;
  logic  [1:0]                          oREG_TXBIST_CTL_BISTOUT_EN;
  logic  [1:0]                          oREG_TXBIST_CTL_CONTROL_SPACE;
  logic  [1:0]                          oREG_TXBIST_CTL_CRC_ERR_INJ;
  logic  [1:0]                          oREG_TXBIST_CTL_CRC_AUTO_EN;
  logic  [1:0]                          oREG_TXBIST_CTL_10B_ERR_INJ;
  logic  [1:0]                          oREG_TXBIST_CTL_INTERVAL_SYNC_EN;
  logic  [1:0][2:0]                     oREG_TXBIST_CTL_MODE;
  logic  [1:0]                          oREG_TXBIST_CTL_FEC_MODE;
  logic  [1:0]                          oREG_TXBIST_CTL_SYNC_START;
  logic                                 global_sync;
  logic  [1:0][63:0]                    oREG_TXBIST_WR_DATA;
  logic  [1:0][13:0]                    oREG_TXBIST_WR_ADDR;
  logic  [1:0][13:0]                    oREG_TXBIST_RD_ADDR;
  logic  [1:0]                          cr_ram_rd_d;
  logic  [1:0]                          cr_ram_rd_en_edge;
  logic  [1:0]                          cr_ram_rd_en_edge_q;
  logic  [1:0]                          cr_ram_rd;
  logic  [1:0]                          cr_ram_wr_addr_ld_d0;
  logic  [1:0]                          cr_ram_wr_addr_ld_d1;
  logic  [1:0]                          cr_ram_wr_addr_ld;
  logic  [1:0]                          cr_ram_wr_d;
  logic  [1:0]                          cr_ram_wr_en_edge_d0;
  logic  [1:0]                          cr_ram_wr_en_edge_d1;
  logic  [1:0]                          cr_ram_wr_en_edge;
  logic  [1:0]                          cr_ram_wr;

  generate
    genvar gi;
    for (gi = 0; gi < 2; gi = gi + 1) begin : txbist
      txbist_regs #(
        . LITE                                               ( 0                                                  )
      ) txbist_regs_inst (
        . clk                                                ( clk                                                ), // input
        . rst_n                                              ( rst_n                                              ), // input
        . wr_en                                              ( cr_txbist_wr_en[gi]                                ), // input
        . rd_en                                              ( cr_txbist_rd_en[gi]                                ), // input
        . addr                                               ( cr_txbist_addr[gi][9:0]                            ), // input [9:0]
        . wr_data                                            ( cr_txbist_wr_data[gi][63:0]                        ), // input [63:0]
        . rd_data                                            ( cr_txbist_rd_data[gi][63:0]                        ), // output [63:0]
        . rd_data_v                                          ( cr_txbist_ack[gi]                                  ), // output
        . oREG__SCRATCH                                       ( oREG__SCRATCH[gi]                                   ), // output [63:0]
        . oREG_TXBIST_IPG_MIN                                ( oREG_TXBIST_IPG_MIN[gi][15:0]                      ), // output [15:0]
        . oREG_TXBIST_IPG_OFFSET                             ( oREG_TXBIST_IPG_OFFSET[gi][3:0]                    ), // output [3:0]
        . oREG_TXBIST_RAM_END                                ( oREG_TXBIST_RAM_END[gi][13:0]                      ), // output [13:0]
        . oREG_TXBIST_LOOP_CNT                               ( oREG_TXBIST_LOOP_CNT[gi][31:0]                     ), // output [31:0]
        . oREG_TXBIST_REG_PRIMITIVE                          ( oREG_TXBIST_REG_PRIMITIVE[gi][63:0]                ), // output [35:0]
        . oREG_TXBIST_IDLE_PRIMITIVE                         ( oREG_TXBIST_IDLE_PRIMITIVE[gi][63:0]               ), // output [35:0]
        . oREG_TXBIST_CTL_BISTOUT_EN                         ( oREG_TXBIST_CTL_BISTOUT_EN[gi]                     ), // output
        . oREG_TXBIST_CTL_CONTROL_SPACE                      ( oREG_TXBIST_CTL_CONTROL_SPACE[gi]                  ), // output
        . oREG_TXBIST_CTL_CRC_ERR_INJ                        ( oREG_TXBIST_CTL_CRC_ERR_INJ[gi]                    ), // output
        . oREG_TXBIST_CTL_CRC_AUTO_EN                        ( oREG_TXBIST_CTL_CRC_AUTO_EN[gi]                    ), // output
        . oREG_TXBIST_CTL_10B_ERR_INJ                        ( oREG_TXBIST_CTL_10B_ERR_INJ[gi]                    ), // output
        . oREG_TXBIST_CTL_INTERVAL_SYNC_EN                   ( oREG_TXBIST_CTL_INTERVAL_SYNC_EN[gi]               ), // output
        . oREG_TXBIST_CTL_MODE                               ( oREG_TXBIST_CTL_MODE[gi][2:0]                      ), // output [2:0]
        . oREG_TXBIST_CTL_FEC_MODE                           ( oREG_TXBIST_CTL_FEC_MODE[gi]                       ), // output [2:0]
        . oREG_TXBIST_CTL_SYNC_START                         ( oREG_TXBIST_CTL_SYNC_START[gi]                       ), // output [2:0]
        . oREG_TXBIST_WR_DATA                                ( oREG_TXBIST_WR_DATA[gi][63:0]                      ), // output [63:0]
        . oREG_TXBIST_WR_ADDR                                ( oREG_TXBIST_WR_ADDR[gi][13:0]                      ), // output [13:0]
        . iREG_TXBIST_TX_PRIM_CNT_EN                         ( iREG_TXBIST_TX_PRIM_CNT_EN[gi]                     ), // input
        . iREG_TXBIST_TX_FRAME_CNT_EN                        ( iREG_TXBIST_TX_FRAME_CNT_EN[gi]                    ), // input
        . iREG_TXBIST_CRC_ERR_INJ_CNT_EN                     ( iREG_TXBIST_CRC_ERR_INJ_CNT_EN[gi]                 ), // input
        . oREG_TXBIST_RD_ADDR                                ( oREG_TXBIST_RD_ADDR[gi][13:0]                      ), // output [13:0]
        . iREG_TXBIST_RD_DATA                                ( iREG_TXBIST_RD_DATA[gi][63:0]                      )  // input [63:0]
      );
      
      txbist72b_gen #(
        . CH                                                 ( gi                                                 ),
        . EMERALD                                            ( EMERALD                                            ),
        . DOMINICA                                           ( DOMINICA                                           ),
        . BALI                                 ( BALI                                )
      ) txbist72b_gen_inst (
        . linkspeed                                          ( linkspeed                                          ),
        . cr_ram_wr_addr_ld                                  ( cr_ram_wr_addr_ld_d1[gi]                           ), // input
        . cr_ram_rd_en_edge                                  ( cr_ram_rd_en_edge_q[gi]                            ), // input
        . cr_ram_wr_en_edge                                  ( cr_ram_wr_en_edge_d1[gi]                           ), // input
      
        . oREG_TXBIST_WR_DATA                                ( oREG_TXBIST_WR_DATA[gi][63:0]                      ), // input [63:0]
        . oREG_TXBIST_RD_ADDR                                ( oREG_TXBIST_RD_ADDR[gi][13:0]                      ), // input [13:0]
        . oREG_TXBIST_WR_ADDR                                ( oREG_TXBIST_WR_ADDR[gi][13:0]                      ), // input [13:0]
        . oREG_TXBIST_REG_PRIMITIVE                          ( oREG_TXBIST_REG_PRIMITIVE[gi][63:0]                ), // input [35:0]
        . oREG_TXBIST_IDLE_PRIMITIVE                         ( oREG_TXBIST_IDLE_PRIMITIVE[gi][63:0]               ), // input [35:0]
        . oREG_TXBIST_CTL_MODE                               ( oREG_TXBIST_CTL_MODE[gi][2:0]                      ), // input [2:0]
        . oREG_TXBIST_CTL_FEC_MODE                           ( oREG_TXBIST_CTL_FEC_MODE[gi]                       ), // input [2:0]
        . oREG_TXBIST_CTL_SYNC_START                         ( oREG_TXBIST_CTL_SYNC_START[gi]                     ), // input [2:0]
        . global_sync                                        ( global_sync                                        ), // input [2:0]
        . oREG_TXBIST_IPG_MIN                                ( oREG_TXBIST_IPG_MIN[gi][15:0]                      ), // input [15:0]
        . oREG_TXBIST_IPG_OFFSET                             ( oREG_TXBIST_IPG_OFFSET[gi][3:0]                    ), // input [3:0]
        . oREG_TXBIST_CTL_10B_ERR_INJ                        ( oREG_TXBIST_CTL_10B_ERR_INJ[gi]                    ), // input
        . oREG_TXBIST_CTL_INTERVAL_SYNC_EN                   ( oREG_TXBIST_CTL_INTERVAL_SYNC_EN[gi]               ), // input
        . oREG_TXBIST_RAM_END                                ( oREG_TXBIST_RAM_END[gi][13:0]                      ), // input [13:0]
        . oREG_TXBIST_LOOP_CNT                               ( oREG_TXBIST_LOOP_CNT[gi][31:0]                     ), // input [31:0]
        . oREG_TXBIST_CTL_CRC_ERR_INJ                        ( oREG_TXBIST_CTL_CRC_ERR_INJ[gi]                    ), // input
        . oREG_TXBIST_CTL_CRC_AUTO_EN                        ( oREG_TXBIST_CTL_CRC_AUTO_EN[gi]                    ), // input
        . iREG_TXBIST_RD_DATA                                ( iREG_TXBIST_RD_DATA[gi][63:0]                      ), // output [63:0]
        . iREG_TXBIST_CRC_ERR_INJ_CNT_EN                     ( iREG_TXBIST_CRC_ERR_INJ_CNT_EN[gi]                 ), // output
        . iREG_TXBIST_TX_FRAME_CNT_EN                        ( iREG_TXBIST_TX_FRAME_CNT_EN[gi]                    ), // output
        . iREG_TXBIST_TX_PRIM_CNT_EN                         ( iREG_TXBIST_TX_PRIM_CNT_EN[gi]                     ), // output
        . oREG_TXBIST_CTL_CONTROL_SPACE                      ( oREG_TXBIST_CTL_CONTROL_SPACE[gi]                  ), // input
        . oREG_TXBIST_CTL_BISTOUT_EN                         ( oREG_TXBIST_CTL_BISTOUT_EN[gi]                     ), // input

        . rst_n                                              ( rst_n                                              ), // input
        . rst                                                ( rst                                                ), // input
        . clk                                                ( clk                                                ), // input
        . end_of_interval                                    ( end_of_interval                                    ), // input
        . txbist_data_val                                    ( txbist_data_val[gi]                                ), // output
        . txbist_data                                        ( txbist_data[gi][71:0]                              )  // output [71:0]
      );
      
      //-------------
      // glue logic
      //-------------
      // snoop the control register interface to detect writes to certain registers.  Generate
      // pulses based on control register writes to trigger RAM reads/writes.
      
      assign cr_ram_rd_d[gi] = (cr_txbist_wr_en[gi] & (cr_txbist_addr[gi][9:0]==RD_ADDR));
      
      always @(posedge clk or negedge rst_n) begin
        cr_ram_rd[gi]            <= ~rst_n                             ? 1'b0 : cr_ram_rd_d[gi];
        cr_ram_rd_en_edge[gi]    <= ~rst_n                             ? 1'b0 :
                (~cr_ram_rd[gi] & cr_ram_rd_d[gi]) ? 1'b1 : 1'b0;
        cr_ram_rd_en_edge_q[gi]  <= ~rst_n                             ? 1'b0 : cr_ram_rd_en_edge[gi];
      end
      
      assign cr_ram_wr_d[gi] = (cr_txbist_wr_en[gi] & (cr_txbist_addr[gi][9:0]==WR_DATA));
      
      always @(posedge clk or negedge rst_n) begin
        cr_ram_wr_addr_ld[gi]    <= ~rst_n                                                     ? 1'b0 : 
                   (cr_txbist_wr_en[gi] & (cr_txbist_addr[gi][9:0]==WR_ADDR)) ? 1'b1 : 1'b0;
        cr_ram_wr[gi]            <= ~rst_n                                                     ? 1'b0 : cr_ram_wr_d[gi];
        cr_ram_wr_en_edge[gi]    <= ~rst_n                                                     ? 1'b0 :
                  (~cr_ram_wr[gi] & cr_ram_wr_d[gi])                         ? 1'b1 : 1'b0;
        // various enables have to be delayed to correspond with correct values on data/address registers
        cr_ram_wr_en_edge_d0[gi] <= ~rst_n                                                     ? 1'b0 : cr_ram_wr_en_edge[gi];
        cr_ram_wr_addr_ld_d0[gi] <= ~rst_n                                                     ? 1'b0 : cr_ram_wr_addr_ld[gi];
        cr_ram_wr_en_edge_d1[gi] <= ~rst_n                                                     ? 1'b0 : cr_ram_wr_en_edge_d0[gi];
        cr_ram_wr_addr_ld_d1[gi] <= ~rst_n                                                     ? 1'b0 : cr_ram_wr_addr_ld_d0[gi];
      end
    end
  endgenerate

      always @(posedge clk or negedge rst_n)
        if (!rst_n)
          global_sync <= 1'b0;
        else 
          global_sync <= &oREG_TXBIST_CTL_SYNC_START;

endmodule

