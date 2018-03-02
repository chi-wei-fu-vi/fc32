module ts_fifo_wrap (
        input   CLK_CORE,
        input   RST_CORE_N,
        
        input   FMAC_ST_SOP,
        input   FMAC_ST_VALID,
        input   [55:0] GLOBAL_TIMESTAMP,
        //input   [75:0] TIME_FIFO_WR_DATA,
        input   EXTR_FCE_TS_FIFO_POP,
        
        output  [75:0] FCE_DAT_FUTURE_TS,
        output  FCE_DAT_FTS_VALID,
        output  [75:0] FCE_EXTR_FUTURE_TS,
        
        output  [4:0] REG_TSFIFOSTAT_WORDS,
        output  REG_TSFIFOSTAT_OVERFLOW,
        output  REG_TSFIFOSTAT_UNDERFLOW
        
);

///////////////////////////////////////////////////////////////////////////////
// Packages
///////////////////////////////////////////////////////////////////////////////
import common_cfg::*;



reg     [55:0] global_timestamp;
reg     dp_time_fifo_push;

always_ff @ (posedge CLK_CORE)
begin
        global_timestamp <= GLOBAL_TIMESTAMP;
        dp_time_fifo_push <= FMAC_ST_SOP && FMAC_ST_VALID;
end

timestamp_bus time_fifo_wr_data;
assign  time_fifo_wr_data.timestamp    =  global_timestamp;
assign  time_fifo_wr_data.index        =  3'h1;
assign  time_fifo_wr_data.vlan_vld     =  'h0;
assign  time_fifo_wr_data.vlan         =  'h0;
assign  time_fifo_wr_data.fcmap        =  'h0;
assign  time_fifo_wr_data.reserved     =  'h0;

    bit [7:0]       reserved;
    bit [23:0]      fcmap;
    bit [15:0]      vlan;
    bit             vlan_vld;
    bit [2:0]       index;
    bit [55:0]      timestamp;

/* timestamp_fifo AUTO_TEMPLATE (
     // Outputs
     .oFUTURE_TS    (         ), 
     .oFTS_VALID    (      ), 
     .oEXTR_FUTURE_TS ( FCE_EXTR_FUTURE_TS[75:0]        ), 
     .oREG_TSFIFOSTAT_WORDS ( REG_TSFIFOSTAT_WORDS[4:0]              ), 
     .oREG_TSFIFOSTAT_OVERFLOW( REG_TSFIFOSTAT_OVERFLOW              ), 
     .oREG_TSFIFOSTAT_UNDERFLOW( REG_TSFIFOSTAT_UNDERFLOW              ), 
     
     .clk     ( CLK_CORE          ), 
     .rst_n     ( RST_CORE_N        ), 
     .iTS_FIFO_PUSH   ( dp_time_fifo_push     ), 
     .iTS_FIFO_WD   ( time_fifo_wr_data     ), 
     .iTS_FIFO_POP    ( EXTR_FCE_TS_FIFO_POP ),
   );
*/

timestamp_fifo u_timestamp_fifo (
        /*AUTOINST*/
        // Outputs
        .oFUTURE_TS		       ( FCE_DAT_FUTURE_TS    ),    // Templated
        .oFTS_VALID		       ( FCE_DAT_FTS_VALID    ),              // Templated
        .oEXTR_FUTURE_TS	       ( FCE_EXTR_FUTURE_TS[75:0]        ),     // Templated
        .oREG_TSFIFOSTAT_WORDS	       ( REG_TSFIFOSTAT_WORDS[4:0]              ),      // Templated
        .oREG_TSFIFOSTAT_OVERFLOW      ( REG_TSFIFOSTAT_OVERFLOW              ),        // Templated
        .oREG_TSFIFOSTAT_UNDERFLOW     ( REG_TSFIFOSTAT_UNDERFLOW              ),       // Templated
        // Inputs
        .clk			       ( CLK_CORE          ),   // Templated
        .rst_n			       ( RST_CORE_N        ),   // Templated
        .iTS_FIFO_PUSH		       ( dp_time_fifo_push     ),       // Templated
        .iTS_FIFO_WD		       ( time_fifo_wr_data     ), // Templated
        .iTS_FIFO_POP		       ( EXTR_FCE_TS_FIFO_POP ));       // Templated
// Local Variables:
// verilog-library-directories:("." "../lib/" )
// verilog-library-extensions:(".v" ".sv" ".h")
// End:

endmodule
