module se_violation
(
input clk,
input rst_n,
input sop,
input eop,
input valid,
input active,
output logic violation,
output logic eop_bb
);

logic sop_v;
logic eop_v;
logic  sop_r;
logic inframe;
logic [7:0] valid_r;

logic [12:0] tocnt;
logic timeout;

assign sop_v = sop & valid;
assign eop_v = eop & valid;

always @(posedge clk or negedge rst_n)
  if (!rst_n)
		sop_r <= 'h0;
	else if (valid)
		sop_r <= sop;

always @(posedge clk or negedge rst_n)
  if (!rst_n)
		inframe <= 1'b0;
	else if (sop_v)
		inframe <= 1'b1;
	else if (eop_v | timeout)
		inframe <= 1'b0;

always @(posedge clk or negedge rst_n)
  if (!rst_n)
		tocnt <= 'h0;
	else if (inframe)
		tocnt <= tocnt + 1;
	else
		tocnt <= 'h0;

always @(posedge clk or negedge rst_n)
  if (!rst_n)
		timeout <= 'h0;
	else
		timeout <= tocnt[12];
		
/* violation is :
 * 1) min frame violation
 * 2) sop eop share same cycle
 * 3) change speed while in frame
 * 4) too many idle while in frame
 */
assign violation = timeout ||
                   ((sop_v | eop_v) & sop_r) || 
                   (sop_v & eop_v) ||
                   (inframe & (~active | sop_v));

assign eop_bb  = ~inframe & eop_v;

endmodule
