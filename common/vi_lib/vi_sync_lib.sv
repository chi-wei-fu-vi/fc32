/***************************************************************************
* Copyright (c) 2012 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: sync_lib.v$
* $Author: honda.yang $
* $Date: 2012-12-11 17:00:16 -0800 (Tue, 11 Dec 2012) $
* $Revision: 851 $
* Description: Clock synchronization library
*
***************************************************************************/


/***************************************************************************
* Binary to Gray Code Conversion
***************************************************************************/
module vi_bin2gray #(

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
module vi_gray2bin #(

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

