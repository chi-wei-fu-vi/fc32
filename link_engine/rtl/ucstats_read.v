/***************************************************************************
* Copyright (c) 2012 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: ucstats_read.v$
* $Author: honda.yang $
* $Date: 2013-07-23 09:59:09 -0700 (Tue, 23 Jul 2013) $
* $Revision: 2942 $
* Description: uC Stats Read
*
***************************************************************************/

module ucstats_read (

// Interval Stats
output logic [1:0]      oUCR_STATS_FIFO_PUSH,
output logic [31:0]     oUCR_STATS_ALARM,
output logic [31:0]     oUCR_STATS_WARN,
output logic [15:0]     oUCR_STATS_TXPWR,
output logic [15:0]     oUCR_STATS_RXPWR,
output logic [15:0]     oUCR_STATS_TEMP,

// uC Stats
output logic [5:0]      oLE_UCSTATS_ADDR,

// Global
input                   clk,
input                   rst_n,

// Interval Stats
input                   iINT_STATS_UC_START,
input                   iINT_STATS_UC_CH_ID,

// uC Stats
input  [31:0]           iUCSTATS_DATA

);

///////////////////////////////////////////////////////////////////////////////
// Packages
///////////////////////////////////////////////////////////////////////////////
import common_cfg::*;

///////////////////////////////////////////////////////////////////////////////
// Declarations
///////////////////////////////////////////////////////////////////////////////
parameter   UC_RD_IDLE_ST               = 0;
parameter   UC_TX_RX_PWR_ST             = 1;
parameter   UC_TEMP_ST                  = 2;
parameter   UC_ALARM_ST                 = 3;
parameter   UC_WARN_ST                  = 4;
parameter   UC_RD_DONE_ST               = 5;

parameter   SFP_TEMP_ADDR               = 5'h0a;
parameter   SFP_PWR_ADDR                = 5'h0b;
parameter   SFP_WARN_ADDR               = 5'h0c;
parameter   SFP_ALARM_ADDR              = 5'h0d;

logic [5:0] uc_rd_state_nxt, uc_rd_state_r;
logic [4:0] ucstats_addr;
logic [3:0] alarm_pipe_r, warn_pipe_r, power_pipe_r, temp_pipe_r;

///////////////////////////////////////////////////////////////////////////////
// uC Stats Read State Machine
///////////////////////////////////////////////////////////////////////////////
// uC stats are read by all link engines in sequential order. All link engines
// are connected in daisy chains. After the first link engine is done, it 
// tells the next link engine to start reading.
always_comb begin
    uc_rd_state_nxt = 6'b0;
    unique case ( 1'b1 )
        uc_rd_state_r[ UC_RD_IDLE_ST ]: begin
            ucstats_addr = 5'h0;
            if ( iINT_STATS_UC_START )
                uc_rd_state_nxt[ UC_TX_RX_PWR_ST ] = 1'b1;
            else
                uc_rd_state_nxt[ UC_RD_IDLE_ST ] = 1'b1;
        end
        uc_rd_state_r[ UC_TX_RX_PWR_ST ]: begin
            ucstats_addr = SFP_PWR_ADDR;
            uc_rd_state_nxt[ UC_TEMP_ST ] = 1'b1;
        end
        uc_rd_state_r[ UC_TEMP_ST ]: begin
            ucstats_addr = SFP_TEMP_ADDR;
            uc_rd_state_nxt[ UC_ALARM_ST ] = 1'b1;
        end
        uc_rd_state_r[ UC_ALARM_ST ]: begin
            ucstats_addr = SFP_ALARM_ADDR;
            uc_rd_state_nxt[ UC_WARN_ST ] = 1'b1;
        end
        uc_rd_state_r[ UC_WARN_ST ]: begin
            ucstats_addr = SFP_WARN_ADDR;
            uc_rd_state_nxt[ UC_RD_DONE_ST ] = 1'b1;
        end
        uc_rd_state_r[ UC_RD_DONE_ST ]: begin
            ucstats_addr = 5'h0;
            uc_rd_state_nxt[ UC_RD_IDLE_ST ] = 1'b1;
        end
        default: begin
            ucstats_addr = 5'h0;
            uc_rd_state_nxt[ UC_RD_IDLE_ST ] = 1'b1;
        end
    endcase
end

always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) begin
        uc_rd_state_r <= 6'b0;
        uc_rd_state_r[ UC_RD_IDLE_ST ] <= 1'b1;
    end
    else
        uc_rd_state_r <= uc_rd_state_nxt;

///////////////////////////////////////////////////////////////////////////////
// uC Stats Read Address Counter
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        oLE_UCSTATS_ADDR <= 6'b0;
    else
        oLE_UCSTATS_ADDR <= {iINT_STATS_UC_CH_ID, ucstats_addr};

///////////////////////////////////////////////////////////////////////////////
// Interval Stats Data
///////////////////////////////////////////////////////////////////////////////
// oLE_UCSTATS_ADDR is delayed one cycle in the ucstats_pipe.v for merging
// all ucstats addresses. iUCSTATS_DATA comes back 3 cycles after oLE_UCSTATS_ADDR.
always_ff @( posedge clk ) 
    if ( ~rst_n ) begin
        alarm_pipe_r  <= 4'b0;
        warn_pipe_r   <= 4'b0;
        power_pipe_r  <= 4'b0;
        temp_pipe_r   <= 4'b0;
    end
    else begin
        alarm_pipe_r  <= {alarm_pipe_r[2:0], uc_rd_state_r[ UC_ALARM_ST ]};
        warn_pipe_r   <= {warn_pipe_r[2:0], uc_rd_state_r[ UC_WARN_ST ]};
        power_pipe_r  <= {power_pipe_r[2:0], uc_rd_state_r[ UC_TX_RX_PWR_ST ]};
        temp_pipe_r   <= {temp_pipe_r[2:0], uc_rd_state_r[ UC_TEMP_ST ]};
    end

always_ff @( posedge clk ) 
    if ( alarm_pipe_r[3] )
        oUCR_STATS_ALARM <= iUCSTATS_DATA;

always_ff @( posedge clk ) 
    if ( warn_pipe_r[3] )
        oUCR_STATS_WARN <= iUCSTATS_DATA;

always_ff @( posedge clk ) 
    if ( power_pipe_r[3] ) begin
        oUCR_STATS_TXPWR <= iUCSTATS_DATA[31:16];
        oUCR_STATS_RXPWR <= iUCSTATS_DATA[15:0];
    end

always_ff @( posedge clk ) 
    if ( temp_pipe_r[3] )
        oUCR_STATS_TEMP <= iUCSTATS_DATA[15:0];

always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) begin
        oUCR_STATS_FIFO_PUSH <= 2'b0;
    end
    else begin
        oUCR_STATS_FIFO_PUSH[0] <= alarm_pipe_r[3];
        oUCR_STATS_FIFO_PUSH[1] <= warn_pipe_r[3];
    end



// synopsys translate_off

///////////////////////////////////////////////////////////////////////////////
// Assertion
///////////////////////////////////////////////////////////////////////////////



// synopsys translate_on

endmodule
