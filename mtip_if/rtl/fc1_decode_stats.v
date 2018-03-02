/***************************************************************************
* Copyright (c) 2012 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: fc1_decode_stats.v$
* $Author: honda.yang $
* $Date: 2013-12-13 15:12:59 -0800 (Fri, 13 Dec 2013) $
* $Revision: 4090 $
* Description: FC1 Level Statistics
*
***************************************************************************/

module fc1_decode_stats (

// Interval Stats Packager
output logic [31:0]     oINT_STATS_FC_CODE,
output logic [31:0]     oINT_STATS_LIP,
output logic [31:0]     oINT_STATS_NOS_OLS,
output logic [31:0]     oINT_STATS_LR_LRR,
output logic [31:0]     oINT_STATS_LINK_UP,
output logic            oINT_STATS_UP_LATCH,
output logic            oINT_STATS_LR_LRR_LATCH,
output logic            oINT_STATS_NOS_LOS_LATCH,

// Credit Stats
output logic            oLINK_UP_EVENT,

// Registers
output logic            oFC1_REG_DISPERRCTR_EN,
output logic            oFC1_REG_INVLDERRCTR_EN,
output logic            oFC1_REG_SOFERRCTR_EN,
output logic            oFC1_REG_EOFERRCTR_EN,
output logic            oFC1_REG_PRIMLIPCTR_EN,
output logic            oFC1_REG_PRIMNOSOLSCTR_EN,
output logic            oFC1_REG_PRIMLRLRRCTR_EN,
output logic            oFC1_REG_PRIMLINKUPCTR_EN,

// Global
input                   clk,
input                   rst_n,
input  [55:0]           iGLOBAL_TIMESTAMP,

// MoreThanIP
input  [31:0]           iRX_FC1_DATA,
input                   iRX_FC1_KCHN,
input                   iRX_FC1_ERR,
input  [11:0]           iRX_PRIMITIVE,
input                   iRX_DISP_ERR,
input                   iRX_CHAR_ERR,
input                   iFC_LINK_SYNC,

// SFP
input                   iSFP_PHY_LOSIG,

// Stats Clear Synchronization
input                   iSTATS_LATCH_CLR_RXCLK

);

///////////////////////////////////////////////////////////////////////////////
// Packages
///////////////////////////////////////////////////////////////////////////////
import mtip_if_cfg::*;
import common_cfg::*;

///////////////////////////////////////////////////////////////////////////////
// Declarations
///////////////////////////////////////////////////////////////////////////////
logic [31:0] fc1_rx_data_r;
logic fc1_rx_kchn_r, fc1_rx_err_r;
logic [11:0] fc1_rx_primitive_r;
logic fc1_rx_disp_err_r, fc1_rx_char_err_r;
logic mtip_losync_rxclk_r, sfp_losig_rxclk_r;
logic valid_input, sof_detected_r, eof_detected_r, rx_last_sof_r;
logic idle_primitive_r, nos_primitive_r, ols_primitive_r, lr_primitive_r, lrr_primitive_r;
logic nos_prim_d1_r, ols_prim_d1_r, lr_prim_d1_r, lrr_prim_d1_r;
logic enter_idle_state_r, internal_link_state_r, internal_link_state_d1_r;
logic fc_code_error, lip_primitive_r, lip_prim_d1_r;
logic idle_filter_r, idle_filter_d1_r;
logic link_up_latch_r, lr_lrr_latch_r, nos_los_latch_r;

///////////////////////////////////////////////////////////////////////////////
// Flop All Inputs
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge clk ) begin
    fc1_rx_data_r      <= iRX_FC1_DATA;
    fc1_rx_kchn_r      <= iRX_FC1_KCHN;
    fc1_rx_err_r       <= iRX_FC1_ERR;
    fc1_rx_primitive_r <= iRX_PRIMITIVE;
    fc1_rx_disp_err_r  <= iRX_DISP_ERR;
    fc1_rx_char_err_r  <= iRX_CHAR_ERR;
end

///////////////////////////////////////////////////////////////////////////////
// Synchronization
///////////////////////////////////////////////////////////////////////////////
// These signals are essentially DC levels, so missing a clock or two
// isn't an issue 
vi_sync_level #(
    .SIZE           ( 1                     ),
    .TWO_DST_FLOPS  ( 1                     ),
    .ASSERT         ( 1                     )
)
u_sync_level_losync (
    .out_level          ( mtip_losync_rxclk_r       ),
    .clk                ( clk                       ),
    .rst_n              ( rst_n                     ),
    .in_level           ( ~iFC_LINK_SYNC            )
);

vi_sync_level #(
    .SIZE           ( 1                     ),
    .TWO_DST_FLOPS  ( 1                     ),
    .ASSERT         ( 1                     )
)
u_sync_level_losig (
    .out_level          ( sfp_losig_rxclk_r         ),
    .clk                ( clk                       ),
    .rst_n              ( rst_n                     ),
    .in_level           ( iSFP_PHY_LOSIG            )
);

///////////////////////////////////////////////////////////////////////////////
// Disparity, Invalid Character Errors
///////////////////////////////////////////////////////////////////////////////
// only increment the counters when we have an optical signal AND comma-aligned data
assign valid_input = ~sfp_losig_rxclk_r & ~mtip_losync_rxclk_r;

always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n ) begin
        oFC1_REG_DISPERRCTR_EN  <= 1'b0;
        oFC1_REG_INVLDERRCTR_EN <= 1'b0;
    end
    else begin
        oFC1_REG_DISPERRCTR_EN  <= valid_input & fc1_rx_disp_err_r;
        oFC1_REG_INVLDERRCTR_EN <= valid_input & fc1_rx_char_err_r;
    end

///////////////////////////////////////////////////////////////////////////////
// SOF and EOF Detection
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge clk ) 
    sof_detected_r <= fc1_rx_kchn_r & ~fc1_rx_err_r &
                      ( ( fc1_rx_data_r == SOFc1 ) | ( fc1_rx_data_r == SOFi1 ) |
                        ( fc1_rx_data_r == SOFn1 ) | ( fc1_rx_data_r == SOFi2 ) |
                        ( fc1_rx_data_r == SOFn2 ) | ( fc1_rx_data_r == SOFi3 ) |
                        ( fc1_rx_data_r == SOFn3 ) | ( fc1_rx_data_r == SOFc4 ) |
                        ( fc1_rx_data_r == SOFi4 ) | ( fc1_rx_data_r == SOFn4 ) |
                        ( fc1_rx_data_r == SOFf  ) );

always_ff @( posedge clk ) 
    eof_detected_r <= fc1_rx_kchn_r & ~fc1_rx_err_r &
                      ( ( fc1_rx_data_r == EOFfp   ) | ( fc1_rx_data_r == EOFfn   ) |
                        ( fc1_rx_data_r == EOFdtp  ) | ( fc1_rx_data_r == EOFdtn  ) |
                        ( fc1_rx_data_r == EOFap   ) | ( fc1_rx_data_r == EOFan   ) |
                        ( fc1_rx_data_r == EOFnp   ) | ( fc1_rx_data_r == EOFnn   ) |
                        ( fc1_rx_data_r == EOFnip  ) | ( fc1_rx_data_r == EOFnin  ) |
                        ( fc1_rx_data_r == EOFdtip ) | ( fc1_rx_data_r == EOFdtin ) |
                        ( fc1_rx_data_r == EOFrtp  ) | ( fc1_rx_data_r == EOFrtn  ) |
                        ( fc1_rx_data_r == EOFrtip ) | ( fc1_rx_data_r == EOFrtin ) );

///////////////////////////////////////////////////////////////////////////////
// SOF and EOF Error 
///////////////////////////////////////////////////////////////////////////////
// ErrSOF occurs when we receive two EOFS without an SOF in the middle, indicating a missing SOF.
// ErrEOF occurs when we receive two SOFS without an EOF in the middle, indicating a missing EOF; 
always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n )
        rx_last_sof_r <= 1'b0;//default to '0' because we are expecting the first item to be a 'sof'
    else begin
        if ( sof_detected_r )
            rx_last_sof_r <= 1'b1;
        else if ( eof_detected_r )
            rx_last_sof_r <= 1'b0;
        else
            rx_last_sof_r <= rx_last_sof_r;
    end

// missing 'sof'    
always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n )
        oFC1_REG_SOFERRCTR_EN <= 1'b0;
    else
        oFC1_REG_SOFERRCTR_EN <= eof_detected_r & ~rx_last_sof_r;

//missing 'eof'
always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n )
        oFC1_REG_EOFERRCTR_EN <= 1'b0;
    else
        oFC1_REG_EOFERRCTR_EN <= sof_detected_r & rx_last_sof_r;

///////////////////////////////////////////////////////////////////////////////
// Primitive Counter Increment
///////////////////////////////////////////////////////////////////////////////
assign idle_primitive_r = fc1_rx_primitive_r[ MTIP_PRIM_IDLE ];
assign nos_primitive_r  = fc1_rx_primitive_r[ MTIP_PRIM_NOS  ];
assign ols_primitive_r  = fc1_rx_primitive_r[ MTIP_PRIM_OLS  ];
assign lr_primitive_r   = fc1_rx_primitive_r[ MTIP_PRIM_LR   ];
assign lrr_primitive_r  = fc1_rx_primitive_r[ MTIP_PRIM_LRR  ];
assign lip_primitive_r  = fc1_rx_primitive_r[ MTIP_PRIM_LIP  ];

always_ff @( posedge clk ) begin
    nos_prim_d1_r  <= nos_primitive_r;
    ols_prim_d1_r  <= ols_primitive_r;
    lr_prim_d1_r   <= lr_primitive_r;
    lrr_prim_d1_r  <= lrr_primitive_r;
    lip_prim_d1_r  <= lip_primitive_r;
end

always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n ) begin
        idle_filter_r    <= 1'b0;
        idle_filter_d1_r <= 1'b0;
    end
    else begin
        idle_filter_r    <= valid_input & idle_primitive_r;
        idle_filter_d1_r <= idle_filter_r;
    end

always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n ) begin
        oFC1_REG_PRIMLIPCTR_EN <= 1'b0;
        oFC1_REG_PRIMNOSOLSCTR_EN <= 1'b0;
        oFC1_REG_PRIMLRLRRCTR_EN <= 1'b0;
        oFC1_REG_PRIMLINKUPCTR_EN <= 1'b0;
        enter_idle_state_r <= 1'b0;
    end
    else begin
        oFC1_REG_PRIMLIPCTR_EN <= valid_input & ( lip_primitive_r & ~lip_prim_d1_r );
        oFC1_REG_PRIMNOSOLSCTR_EN <= valid_input & 
                ( ( nos_primitive_r | ols_primitive_r ) & ~( nos_prim_d1_r | ols_prim_d1_r ) );
        oFC1_REG_PRIMLRLRRCTR_EN <= valid_input &
                ( ( lr_primitive_r | lrr_primitive_r ) & ~( lr_prim_d1_r | lrr_prim_d1_r ) );
        oFC1_REG_PRIMLINKUPCTR_EN <= valid_input & oLINK_UP_EVENT;
        enter_idle_state_r <= idle_filter_r & ~idle_filter_d1_r;
    end

///////////////////////////////////////////////////////////////////////////////
// Link Up/Down
///////////////////////////////////////////////////////////////////////////////
// we get into the 'off' state with a NOS/OLS, LR/LRR, LOS, LOSI; we get into the 'up'
// state with an 'idle'; otherwise we remain in the current state.
always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n ) 
        internal_link_state_r <= 1'b0;
    else begin
        if ( mtip_losync_rxclk_r | sfp_losig_rxclk_r | oFC1_REG_PRIMNOSOLSCTR_EN | 
             oFC1_REG_PRIMLRLRRCTR_EN )
            internal_link_state_r <= 1'b0;
        else if ( enter_idle_state_r )
            internal_link_state_r <= 1'b1;
        else
            internal_link_state_r <= internal_link_state_r;
    end

always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n ) 
        internal_link_state_d1_r <= 1'b0;
    else
        internal_link_state_d1_r <= internal_link_state_r;

//create a pulse indicating a link-up event in the rxclk domain
always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n ) 
        oLINK_UP_EVENT <= 1'b0;
    else
        oLINK_UP_EVENT <= internal_link_state_r & ~internal_link_state_d1_r;

///////////////////////////////////////////////////////////////////////////////
// Interval Stats Packager Interface
///////////////////////////////////////////////////////////////////////////////
assign fc_code_error = oFC1_REG_DISPERRCTR_EN | oFC1_REG_INVLDERRCTR_EN;

vi_invl_stats_ctr #(
    .SIZE       ( 32                    )
)
u_invl_stats_fc_code_ctr (
    .latched_stats_ctr_r    ( oINT_STATS_FC_CODE        ),
    .clk                    ( clk                       ),
    .rst_n                  ( rst_n                     ),
    .latch_clr              ( iSTATS_LATCH_CLR_RXCLK    ),
    .increment              ( fc_code_error             )
);

vi_invl_stats_ctr #(
    .SIZE       ( 32                    )
)
u_invl_stats_fc_lip_ctr (
    .latched_stats_ctr_r    ( oINT_STATS_LIP            ),
    .clk                    ( clk                       ),
    .rst_n                  ( rst_n                     ),
    .latch_clr              ( iSTATS_LATCH_CLR_RXCLK    ),
    .increment              ( oFC1_REG_PRIMLIPCTR_EN    )
);

vi_invl_stats_ctr #(
    .SIZE       ( 32                    )
)
u_invl_stats_nos_ols_ctr (
    .latched_stats_ctr_r    ( oINT_STATS_NOS_OLS        ),
    .clk                    ( clk                       ),
    .rst_n                  ( rst_n                     ),
    .latch_clr              ( iSTATS_LATCH_CLR_RXCLK    ),
    .increment              ( oFC1_REG_PRIMNOSOLSCTR_EN )
);

vi_invl_stats_ctr #(
    .SIZE       ( 32                    )
)
u_invl_stats_lr_lrr_ctr (
    .latched_stats_ctr_r    ( oINT_STATS_LR_LRR         ),
    .clk                    ( clk                       ),
    .rst_n                  ( rst_n                     ),
    .latch_clr              ( iSTATS_LATCH_CLR_RXCLK    ),
    .increment              ( oFC1_REG_PRIMLRLRRCTR_EN  )
);

vi_invl_stats_ctr #(
    .SIZE       ( 32                    )
)
u_invl_stats_link_up_ctr (
    .latched_stats_ctr_r    ( oINT_STATS_LINK_UP        ),
    .clk                    ( clk                       ),
    .rst_n                  ( rst_n                     ),
    .latch_clr              ( iSTATS_LATCH_CLR_RXCLK    ),
    .increment              ( oFC1_REG_PRIMLINKUPCTR_EN )
);

///////////////////////////////////////////////////////////////////////////////
// Interval Stats Flags
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n ) 
        link_up_latch_r <= 1'b0;
    else if ( iSTATS_LATCH_CLR_RXCLK )
        link_up_latch_r <= 1'b0;
    else if ( valid_input & internal_link_state_r & ~internal_link_state_d1_r )
        link_up_latch_r <= 1'b1;

always_ff @( posedge clk )
    if ( iSTATS_LATCH_CLR_RXCLK )
        oINT_STATS_UP_LATCH <= link_up_latch_r;

always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n ) 
        lr_lrr_latch_r <= 1'b0;
    else if ( iSTATS_LATCH_CLR_RXCLK )
        lr_lrr_latch_r <= 1'b0;
    else if ( valid_input & ( lr_primitive_r | lrr_primitive_r ) )
        lr_lrr_latch_r <= 1'b1;

always_ff @( posedge clk )
    if ( iSTATS_LATCH_CLR_RXCLK )
        oINT_STATS_LR_LRR_LATCH <= lr_lrr_latch_r;

always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n ) 
        nos_los_latch_r <= 1'b0;
    else if ( iSTATS_LATCH_CLR_RXCLK )
        nos_los_latch_r <= 1'b0;
    else if ( valid_input & ( nos_primitive_r | ols_primitive_r ) )
        nos_los_latch_r <= 1'b1;

always_ff @( posedge clk )
    if ( iSTATS_LATCH_CLR_RXCLK )
        oINT_STATS_NOS_LOS_LATCH <= nos_los_latch_r;


// synopsys translate_off

///////////////////////////////////////////////////////////////////////////////
// Assertion
///////////////////////////////////////////////////////////////////////////////



// synopsys translate_on

endmodule
