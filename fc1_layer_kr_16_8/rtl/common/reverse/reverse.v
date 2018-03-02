/********************************CONFIDENTIAL****************************
* Copyright (c) 2013 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: $
* $Author: leon.zhou $
* $Date: 2013-11-13 14:43:41 -0800 (Wed, 13 Nov 2013) $
* $Revision: 3883 $
* Description:
*
* Upper level dependencies:
* Lower level dependencies:
*
* Revision History Notes:
*
*
***************************************************************************/


module reverse 
#(
	parameter WIDTH    =  64
)
(
	input   ENA,
	input   [WIDTH-1:0] IN,
	output  [WIDTH-1:0] OUT
);

wire    [WIDTH-1:0] d_reverse;

genvar i;
generate for (i    =  0; i<WIDTH; i++)
begin : reverse_assign
	assign  d_reverse[i]   =  IN[WIDTH-1-i];
end
endgenerate

assign  OUT    =  ENA ? d_reverse : IN;

endmodule
