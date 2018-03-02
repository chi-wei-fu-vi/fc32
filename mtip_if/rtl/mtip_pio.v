/***************************************************************************
* Copyright (c) 2012 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: mtip_pio.v$
* $Author: honda.yang $
* $Date: 2013-05-30 11:38:08 -0700 (Thu, 30 May 2013) $
* $Revision: 2403 $
* Description: MoreThanIP PIO Interface
*
***************************************************************************/

module mtip_pio (

// MoreThanIP
output logic [31:0]     oMTIP_REG_DATA_IN,
output logic [9:0]      oMTIP_REG_ADDR,
output logic            oMTIP_REG_RD,
output logic            oMTIP_REG_WR,

// Registers
output logic [63:0]     oMTIP_MM_RD_DATA,
output logic            oMTIP_MM_RD_DATA_V,

// Global
input                   iCLK_100M,
input                   iCLK_FC_CORE,
input                   iRST_100M_N,
input                   iRST_FC_CORE_N,

// MoreThanIP
input  [31:0]           iMTIP_REG_DATA_OUT,
input                   iMTIP_REG_BUSY,

// Registers
input  [63:0]           iMTIP_MM_WR_DATA,
input  [13:0]           iMTIP_MM_ADDR,
input                   iMTIP_MM_WR_EN,
input                   iMTIP_MM_RD_EN,

// Link Registers
input                   iREG_LINKCTRL_WR_EN,
input                   iREG_LINKCTRL_SCRMENBL

);

///////////////////////////////////////////////////////////////////////////////
// Declarations
///////////////////////////////////////////////////////////////////////////////
parameter   PIO_IDLE_ST            = 0;
parameter   PIO_WRITE_ST           = 1;
parameter   PIO_READ_ST            = 2;
parameter   PIO_DONE_ST            = 3;

parameter   INIT_IDLE_ST           = 0;
parameter   INIT_RX_AEMPTY_ST      = 1;
parameter   INIT_RX_AFULL_ST       = 2;
parameter   INIT_TX_AEMPTY_ST      = 3;
parameter   INIT_TX_AFULL_ST       = 4;
parameter   INIT_RX_SECFULL_ST     = 5;
parameter   INIT_TX_SECEMPTY_ST    = 6;
parameter   INIT_TX_SECFULL_ST     = 7;
parameter   INIT_INIT_TIME_ST      = 8;
parameter   INIT_EVENT_TIME_ST     = 9;
parameter   INIT_CMD_CFG_ST        = 10;
parameter   INIT_DONE_ST           = 11;

parameter   MM_FF_IDLE_ST          = 0;
parameter   MM_FF_START_ST         = 1;
parameter   MM_FF_WAIT_ST          = 2;
parameter   MM_FF_POP_ST           = 3;
parameter   MM_FF_END_ST           = 4;

logic [3:0] pio_state_r, pio_state_nxt;
logic mtip_reg_start;
logic [11:0] init_state_r, init_state_nxt;
logic [4:0] mm_ff_state_r, mm_ff_state_nxt;
logic [31:0] init_data_nxt, mm_fifo_rd_dat_r;
logic [7:0] init_addr_nxt;
logic [9:0] mm_fifo_rd_adr_r;
logic init_sm_run_r, mm_fifo_push, mm_fifo_pop, mm_fifo_rd_start, mm_fifo_wr_start;
logic mm_fifo_rd_wen_r, mm_fifo_empty, linkctl_wr_clk100m, scrmenbl_clk100m_r;
logic [42:0] mm_fifo_wd, mm_fifo_rd_r;
logic [1:0] linkctl_wr_100m_dly_r;

///////////////////////////////////////////////////////////////////////////////
// Software Avalon MM FIFO Instantiation
///////////////////////////////////////////////////////////////////////////////
// MoreThanIP registers may be slow to access especially in lower speed FC mode.
// The FIFO buffers potential consecutive PIO accesses.
fifo1c #(
    .ADDR_WIDTH ( 3         ),
    .DEPTH      ( 8         ),
    .DATA_WIDTH ( 43        ),
    .AFUL_THRES ( 7         ),
    .AEMP_THRES ( 1         ),
    .PIPE       ( 1         )
)
u_avalon_mm_fifo (
    .clk                ( iCLK_100M             ),
    .rst_n              ( iRST_100M_N           ),
    .data               ( mm_fifo_wd            ),
    .rdreq              ( mm_fifo_pop           ),
    .wrreq              ( mm_fifo_push          ),
    .highest_clr        ( 1'b0                  ),
    .almost_empty       (                       ),
    .almost_full        (                       ),
    .empty              ( mm_fifo_empty         ),
    .full               (                       ),
    .q                  ( mm_fifo_rd_r          ),
    .usedw              (                       ),
    .highest_dw         (                       ),
    .overflow           (                       ),
    .underflow          (                       )
);

///////////////////////////////////////////////////////////////////////////////
// Synchronizer Instantiation
///////////////////////////////////////////////////////////////////////////////
vi_sync_pulse u_sync_pls_linkctl_wr (
    .out_pulse          ( linkctl_wr_clk100m            ),
    .clka               ( iCLK_FC_CORE                  ),
    .clkb               ( iCLK_100M                     ),
    .rsta_n             ( iRST_FC_CORE_N                ),
    .rstb_n             ( iRST_100M_N                   ),
    .in_pulse           ( iREG_LINKCTRL_WR_EN           )
);

vi_sync_level #(
    .SIZE       ( 1 )
)
u_sync_level_scrmenbl (
    .out_level          ( scrmenbl_clk100m_r        ),
    .clk                ( iCLK_100M                 ),
    .rst_n              ( iRST_100M_N               ),
    .in_level           ( iREG_LINKCTRL_SCRMENBL    )
);

always_ff @( posedge iCLK_100M or negedge iRST_100M_N )
    if ( ~iRST_100M_N ) 
        linkctl_wr_100m_dly_r <= 2'b0;
    else
        linkctl_wr_100m_dly_r <= {linkctl_wr_100m_dly_r[0], linkctl_wr_clk100m};

///////////////////////////////////////////////////////////////////////////////
// MTIP Init State Machine
///////////////////////////////////////////////////////////////////////////////
always_comb begin
    init_state_nxt = 12'b0;
    init_addr_nxt = 8'b0;
    init_data_nxt = 32'b0;
    unique case ( 1'b1 )
        init_state_r[ INIT_IDLE_ST ]: begin
            init_state_nxt[ INIT_RX_AEMPTY_ST ] = 1'b1;
            init_addr_nxt = 8'b0;
            init_data_nxt = 32'b0;
        end
        init_state_r[ INIT_RX_AEMPTY_ST ]: begin
            if ( pio_state_r[ PIO_DONE_ST ] )
                init_state_nxt[ INIT_RX_AFULL_ST ] = 1'b1;
            else
                init_state_nxt[ INIT_RX_AEMPTY_ST ] = 1'b1;
            init_addr_nxt = 8'h0B;
            init_data_nxt = {24'b0,8'h08};
        end
        init_state_r[ INIT_RX_AFULL_ST ]: begin
            if ( pio_state_r[ PIO_DONE_ST ] )
                init_state_nxt[ INIT_TX_AEMPTY_ST ] = 1'b1;
            else
                init_state_nxt[ INIT_RX_AFULL_ST ] = 1'b1;
            init_addr_nxt = 8'h0C;
            init_data_nxt = {24'b0,8'h08};
        end
        init_state_r[ INIT_TX_AEMPTY_ST ]: begin
            if ( pio_state_r[ PIO_DONE_ST ] )
                init_state_nxt[ INIT_TX_AFULL_ST ] = 1'b1;
            else
                init_state_nxt[ INIT_TX_AEMPTY_ST ] = 1'b1;
            init_addr_nxt = 8'h0D;
            init_data_nxt = {24'b0,8'h08};
        end
        init_state_r[ INIT_TX_AFULL_ST ]: begin
            if ( pio_state_r[ PIO_DONE_ST ] )
                init_state_nxt[ INIT_RX_SECFULL_ST ] = 1'b1;
            else
                init_state_nxt[ INIT_TX_AFULL_ST ] = 1'b1;
            init_addr_nxt = 8'h0E;
            init_data_nxt = {24'b0,8'h10};
        end
        init_state_r[ INIT_RX_SECFULL_ST ]: begin
            if ( pio_state_r[ PIO_DONE_ST ] )
                init_state_nxt[ INIT_TX_SECEMPTY_ST ] = 1'b1;
            else
                init_state_nxt[ INIT_RX_SECFULL_ST ] = 1'b1;
            init_addr_nxt = 8'h08;
            init_data_nxt = {24'b0,8'h20};
        end
        init_state_r[ INIT_TX_SECEMPTY_ST ]: begin
            if ( pio_state_r[ PIO_DONE_ST ] )
                init_state_nxt[ INIT_TX_SECFULL_ST ] = 1'b1;
            else
                init_state_nxt[ INIT_TX_SECEMPTY_ST ] = 1'b1;
            init_addr_nxt = 8'h09;
            init_data_nxt = {24'b0,8'h20};
        end
        init_state_r[ INIT_TX_SECFULL_ST ]: begin
            if ( pio_state_r[ PIO_DONE_ST ] )
                init_state_nxt[ INIT_INIT_TIME_ST ] = 1'b1;
            else
                init_state_nxt[ INIT_TX_SECFULL_ST ] = 1'b1;
            init_addr_nxt = 8'h0A;
            init_data_nxt = {24'b0,8'h20};
        end
        init_state_r[ INIT_INIT_TIME_ST ]: begin
            if ( pio_state_r[ PIO_DONE_ST ] )
                init_state_nxt[ INIT_EVENT_TIME_ST ] = 1'b1;
            else
                init_state_nxt[ INIT_INIT_TIME_ST ] = 1'b1;
            init_addr_nxt = 8'h04;
            init_data_nxt = 32'h0100;
        end
        init_state_r[ INIT_EVENT_TIME_ST ]: begin
            if ( pio_state_r[ PIO_DONE_ST ] )
                init_state_nxt[ INIT_CMD_CFG_ST ] = 1'b1;
            else
                init_state_nxt[ INIT_EVENT_TIME_ST ] = 1'b1;
            init_addr_nxt = 8'h05;
            init_data_nxt = 32'h1000;
        end
        init_state_r[ INIT_CMD_CFG_ST ]: begin
            if ( pio_state_r[ PIO_DONE_ST ] )
                init_state_nxt[ INIT_DONE_ST ] = 1'b1;
            else
                init_state_nxt[ INIT_CMD_CFG_ST ] = 1'b1;
            init_addr_nxt = 8'h02;
            //set the 'online' bit of the control register, clear the scramble-enable bit.
            init_data_nxt = {24'b0,8'h20};
        end
        init_state_r[ INIT_DONE_ST ]: begin
            init_state_nxt[ INIT_DONE_ST ] = 1'b1;
            init_addr_nxt = 8'b0;
            init_data_nxt = 32'b0;
        end
    endcase
end

always_ff @( posedge iCLK_100M or negedge iRST_100M_N )
    if ( ~iRST_100M_N ) begin
        init_state_r <= 12'b0;
        init_state_r[ INIT_IDLE_ST ] <= 1'b1;
    end
    else
        init_state_r <= init_state_nxt;

always_ff @( posedge iCLK_100M or negedge iRST_100M_N )
    if ( ~iRST_100M_N ) 
        init_sm_run_r <= 1'b0;
    else
        init_sm_run_r <= ~init_state_nxt[ INIT_IDLE_ST ] & ~init_state_nxt[ INIT_DONE_ST ];

///////////////////////////////////////////////////////////////////////////////
// Avalon MM FIFO Push
///////////////////////////////////////////////////////////////////////////////
assign mm_fifo_push = iMTIP_MM_WR_EN | iMTIP_MM_RD_EN | linkctl_wr_100m_dly_r[1];

//set the 'online' bit of the control register
assign mm_fifo_wd[31:0]  = linkctl_wr_100m_dly_r[1] ? {24'b0,4'h2,3'b0,scrmenbl_clk100m_r} : iMTIP_MM_WR_DATA[31:0];
assign mm_fifo_wd[41:32] = linkctl_wr_100m_dly_r[1] ? 10'd8 : iMTIP_MM_ADDR[9:0];
assign mm_fifo_wd[42]    = iMTIP_MM_WR_EN | linkctl_wr_100m_dly_r[1];

///////////////////////////////////////////////////////////////////////////////
// Avalon MM FIFO Pop State Machine
///////////////////////////////////////////////////////////////////////////////
always_comb begin
    mm_ff_state_nxt = 5'b0;
    unique case ( 1'b1 )
        mm_ff_state_r[ MM_FF_IDLE_ST ]: begin
            if ( ~mm_fifo_empty & ~init_sm_run_r ) 
                mm_ff_state_nxt[ MM_FF_START_ST ] = 1'b1;
            else
                mm_ff_state_nxt[ MM_FF_IDLE_ST ] = 1'b1;
        end
        mm_ff_state_r[ MM_FF_START_ST ]: begin
            mm_ff_state_nxt[ MM_FF_WAIT_ST ] = 1'b1;
        end
        mm_ff_state_r[ MM_FF_WAIT_ST ]: begin
            if ( pio_state_r[ PIO_DONE_ST ] ) 
                mm_ff_state_nxt[ MM_FF_POP_ST ] = 1'b1;
            else
                mm_ff_state_nxt[ MM_FF_WAIT_ST ] = 1'b1;
        end
        mm_ff_state_r[ MM_FF_POP_ST ]: begin
            mm_ff_state_nxt[ MM_FF_END_ST ] = 1'b1;
        end
        mm_ff_state_r[ MM_FF_END_ST ]: begin
            mm_ff_state_nxt[ MM_FF_IDLE_ST ] = 1'b1;
        end
    endcase
end

always_ff @( posedge iCLK_100M or negedge iRST_100M_N )
    if ( ~iRST_100M_N ) begin
        mm_ff_state_r <= 5'b0;
        mm_ff_state_r[ MM_FF_IDLE_ST ] <= 1'b1;
    end
    else
        mm_ff_state_r <= mm_ff_state_nxt;

///////////////////////////////////////////////////////////////////////////////
// Avalon MM FIFO Pop
///////////////////////////////////////////////////////////////////////////////
assign mm_fifo_pop = mm_ff_state_r[ MM_FF_POP_ST ];

assign mm_fifo_rd_dat_r = mm_fifo_rd_r[31:0];
assign mm_fifo_rd_adr_r = mm_fifo_rd_r[41:32];
assign mm_fifo_rd_wen_r = mm_fifo_rd_r[42];

assign mm_fifo_rd_start = ~mm_fifo_rd_wen_r & mm_ff_state_r[ MM_FF_START_ST ];
assign mm_fifo_wr_start =  mm_fifo_rd_wen_r & mm_ff_state_r[ MM_FF_START_ST ];

///////////////////////////////////////////////////////////////////////////////
// MTIP Handshake State Machine
///////////////////////////////////////////////////////////////////////////////
always_comb begin
    pio_state_nxt = 4'b0;
    unique case ( 1'b1 )
        pio_state_r[ PIO_IDLE_ST ]: begin
            if ( mm_fifo_wr_start | init_sm_run_r )
                pio_state_nxt[ PIO_WRITE_ST ] = 1'b1;
            else if ( mm_fifo_rd_start )
                pio_state_nxt[ PIO_READ_ST ] = 1'b1;
            else
                pio_state_nxt[ PIO_IDLE_ST ] = 1'b1;
        end
        pio_state_r[ PIO_WRITE_ST ]: begin
            if ( iMTIP_REG_BUSY ) 
                pio_state_nxt[ PIO_WRITE_ST ] = 1'b1;
            else
                pio_state_nxt[ PIO_DONE_ST ] = 1'b1;
        end
        pio_state_r[ PIO_READ_ST ]: begin
            if ( iMTIP_REG_BUSY ) 
                pio_state_nxt[ PIO_READ_ST ] = 1'b1;
            else
                pio_state_nxt[ PIO_DONE_ST ] = 1'b1;
        end
        pio_state_r[ PIO_DONE_ST ]: begin
            pio_state_nxt[ PIO_IDLE_ST ] = 1'b1;
        end
        default: begin
            pio_state_nxt[ PIO_IDLE_ST ] = 1'b1;
        end
    endcase
end

always_ff @( posedge iCLK_100M or negedge iRST_100M_N )
    if ( ~iRST_100M_N ) begin
        pio_state_r <= 4'b0;
        pio_state_r[ PIO_IDLE_ST ] <= 1'b1;
    end
    else
        pio_state_r <= pio_state_nxt;

///////////////////////////////////////////////////////////////////////////////
// MoreThanIP Outputs
///////////////////////////////////////////////////////////////////////////////
assign mtip_reg_start = pio_state_r[ PIO_IDLE_ST ] &
                        ( pio_state_nxt[ PIO_WRITE_ST ] | pio_state_nxt[ PIO_READ_ST ] );

always_ff @( posedge iCLK_100M )
    if ( mtip_reg_start ) begin
        if ( init_sm_run_r ) begin
            oMTIP_REG_DATA_IN <= init_data_nxt;
            oMTIP_REG_ADDR    <= {init_addr_nxt, 2'b0};
        end
        else begin
            oMTIP_REG_DATA_IN <= mm_fifo_rd_dat_r;
            oMTIP_REG_ADDR    <= mm_fifo_rd_adr_r;
        end
    end

assign oMTIP_REG_RD = pio_state_r[ PIO_READ_ST ];
assign oMTIP_REG_WR = pio_state_r[ PIO_WRITE_ST ];

///////////////////////////////////////////////////////////////////////////////
// MM Outputs
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge iCLK_100M )
    if ( pio_state_nxt[ PIO_DONE_ST ] )
        oMTIP_MM_RD_DATA <= {32'b0, iMTIP_REG_DATA_OUT};

always_ff @( posedge iCLK_100M or negedge iRST_100M_N )
    if ( ~iRST_100M_N ) 
        oMTIP_MM_RD_DATA_V <= 1'b0;
    else
        oMTIP_MM_RD_DATA_V <= pio_state_r[ PIO_READ_ST ] & pio_state_nxt[ PIO_DONE_ST ];



// synopsys translate_off

///////////////////////////////////////////////////////////////////////////////
// Assertion
///////////////////////////////////////////////////////////////////////////////



// synopsys translate_on

endmodule
