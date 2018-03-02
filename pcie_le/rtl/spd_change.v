module spd_change
#(
  parameter SIM_ONLY = 0
)
(
  input [3:0] req_LE_LINKSPEED,
	input [3:0] stat_LE_LINKSPEED,
	input       rx_is_lockedtodata,
	input clk,
	input rst_n,

	output logic mon_mask,
	output logic mtip_enable
);

localparam IDLE = 0;
localparam WAIT_SPD_CHG = 1;
localparam WAIT_LOCK = 2;
localparam WAIT_CHG_MODE = 3; 
localparam WAIT_ENA_MON = 4; 

logic [2:0] state, nstate;

logic [27:0] count;
logic chg_mode;
logic ena_mon;
logic broken_data;
logic same_speed;
logic rx_is_locked;


vi_sync_level #(.SIZE(1),
    .TWO_DST_FLOPS(1))
rx_locked_sync
  (
   .out_level    ( rx_is_locked  ),
   .clk          ( clk          ),
   .rst_n        ( rst_n        ),
   .in_level     ( rx_is_lockedtodata )
   );

always @(posedge clk or negedge rst_n)
  if (!rst_n)
		same_speed <= 1'b0;
  else
		same_speed <= req_LE_LINKSPEED == stat_LE_LINKSPEED;

always @(posedge clk or negedge rst_n)
  if (!rst_n)
		broken_data <= 1'b0;
  else
		broken_data <= ~rx_is_locked || ~same_speed;

always @(posedge clk or negedge rst_n)
  if (!rst_n)
		count <= 'h0;
  else if ((state == WAIT_CHG_MODE) || (state == WAIT_ENA_MON))
		count <= count + 1;
	else
		count <= 'h0;


generate 
if (SIM_ONLY)
begin

always @(posedge clk or negedge rst_n)
  if (!rst_n)
    chg_mode <= 1'b0;
  else
    chg_mode <= 1'b1;

always @(posedge clk or negedge rst_n)
  if (!rst_n)
    ena_mon <= 1'b0;
  else
    ena_mon <= 1'b1;

end

else
begin

always @(posedge clk or negedge rst_n)
  if (!rst_n)
    chg_mode <= 1'b0;
  else
    chg_mode <= count[26] && ~count[27] && (state == WAIT_CHG_MODE);

always @(posedge clk or negedge rst_n)
  if (!rst_n)
    ena_mon <= 1'b0;
  else
    ena_mon <= &count[27:26];

end
endgenerate

always @(posedge clk or negedge rst_n)
  if (!rst_n)
		state <= IDLE;
  else
		state <= nstate;

always @(*)
begin
  nstate = state;
	case (state)
		IDLE : 
			if (broken_data)
				nstate = WAIT_SPD_CHG;

		WAIT_SPD_CHG :
		  if (same_speed)
				nstate = WAIT_LOCK;

    WAIT_LOCK :
		  if (rx_is_locked)
				nstate = WAIT_CHG_MODE;
			else if (~same_speed)
				nstate = WAIT_SPD_CHG;

		WAIT_CHG_MODE :
			if (broken_data)
				nstate = WAIT_SPD_CHG;
		  else if (chg_mode)
				nstate = WAIT_ENA_MON;
				
		WAIT_ENA_MON :
			if (broken_data)
				nstate = WAIT_SPD_CHG;
		  else if (ena_mon)
				nstate = IDLE;

		default : nstate = IDLE;
	endcase
end

		
always @(posedge clk or negedge rst_n)
  if (!rst_n)
		mon_mask <= 1'b1;
  else 
		mon_mask <= (state != IDLE) || (~rx_is_locked || (req_LE_LINKSPEED != stat_LE_LINKSPEED));

always @(posedge clk or negedge rst_n)
  if (!rst_n)
		mtip_enable <= 1'b0;
  else 
		mtip_enable <= chg_mode ? ~(req_LE_LINKSPEED == 4'h4) : mtip_enable;

endmodule
