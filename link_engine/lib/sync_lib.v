/***************************************************************************
* Copyright (c) 2012 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: sync_lib.v$
* $Author: honda.yang $
* $Date: 2013-07-23 14:41:48 -0700 (Tue, 23 Jul 2013) $
* $Revision: 2958 $
* Description: Clock synchronization library
*
***************************************************************************/


/***************************************************************************
* Binary to Gray Code Conversion
***************************************************************************/
module bin2gray #(

parameter SIZE = 4 )

(

output logic [SIZE-1:0]     gray,
input  [SIZE-1:0]           bin

);

assign gray = (bin>>1) ^ bin;

endmodule



/***************************************************************************
* Gray to Binary Code Conversion
***************************************************************************/
module gray2bin #(

parameter SIZE = 4 )

(

output logic [SIZE-1:0]     bin,
input  [SIZE-1:0]           gray

);

integer i;

always_comb
    for (i=0; i<SIZE; i=i+1)
        bin[i] = ^( gray>>i );

endmodule


/***************************************************************************
* Multi-bits Transfer Synchronizer
***************************************************************************/
module sync_xfr #(

parameter SIZE = 4 )

(

output logic [SIZE-1:0]    out_bus,

input                      clk,
input                      rst_n,

input                      xfr,
input  [SIZE-1:0]          in_bus

);

(* altera_attribute = "-name SDC_STATEMENT \"set_false_path -to [get_registers *out_sync_bus*]\"" *) logic [SIZE-1:0] out_sync_bus;

always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n ) 
        out_sync_bus <= {SIZE{1'b0}};
    else if ( xfr )
        out_sync_bus <= in_bus;

assign out_bus = out_sync_bus;

endmodule


