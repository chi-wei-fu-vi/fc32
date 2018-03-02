/*WARNING****WARNING****WARNING****
This File is auto-generated.  DO NOT EDIT.
All changes will be lost....
WARNING****WARNING****WARNING******/


module bit_slip (
	input   RST,
	input   CLK,
	input   [63:0] PMA_DIN,
	input   ENDIAN_SWAP,
	input   CSR_DEC_INV,
	input   SLIP,
	
	output  reg     [63:0] SLIP_DOUT,
	output  reg     SLIP_DOUT_VAL,
	output  reg     SLIP_PN_START,
	
	output  reg     [12:0] CSR_STAT_SLIP_COUNT,
	output  DEC_BITSLIP

);

reg     [5:0] ptr;
reg     dval, dval_s0, dval_s1;

reg     [63:0] pma_din_preswap, pma_din_s0, pma_din_s1, slip_dout, slip_dout_r;
reg     slip_dout_val_r, slip_pn_start_r;
wire    [63:0] pma_din_swap;

wire    endian_swap;

  assign DEC_BITSLIP = 1'b0;

always @(posedge CLK)
if (RST)
	CSR_STAT_SLIP_COUNT <= 'h0;
else if (SLIP)
	CSR_STAT_SLIP_COUNT <= CSR_STAT_SLIP_COUNT + 1;

/* PMA input side swap control
*/
reg pma_din_preval;

always @(posedge CLK)
if (RST)
begin
	pma_din_preswap <= 'h0;
        pma_din_preval <= 1'b0;
end
else
begin
	pma_din_preswap <= PMA_DIN;
        pma_din_preval <= 1'b1;
end

vi_sync_level
#(.SIZE(1)) end_swap_sync (
    .out_level(endian_swap),
    .clk(CLK),
    .rst_n(~RST),
    .in_level(ENDIAN_SWAP)
);

reverse #(64) dec_in_reverse_inst (.ENA(endian_swap), .IN      (pma_din_preswap), .OUT (pma_din_swap));


/* pointer keeps track of current start position
	 * dval indicates 1 cycles of bubble in case pointer is all zero and a slip
	 * is needed
*/
always @(posedge CLK)
if (RST)
begin
	ptr <= 'h0;
	dval <= 'h0;
end
else if (&ptr && SLIP)
begin
	ptr <= 'h0;
	dval <= 'h0;
end
else if (SLIP)
begin
	ptr <= ptr + 1;
end
else
	dval <= pma_din_preval;


/* pipeline stage to clock in 2 blocks
*/
always @(posedge CLK)
if (RST)
begin
	pma_din_s0 <= 'h0;
	pma_din_s1 <= 'h0;
	dval_s0 <= 1'b0;
	dval_s1 <= 1'b0;
end
else
begin
	pma_din_s0 <= pma_din_swap;
	pma_din_s1 <= pma_din_s0;
	dval_s0 <= dval;
	dval_s1 <= dval_s0;
end

/* output mux stage
	 * ptr => SLIP_DOUT : 3 lvl 314mhz
*/
always @(
	ptr 
	or pma_din_s1 
	or pma_din_s0)
	case (ptr)
	6'd0 : slip_dout   =  pma_din_s1;
6'd1 : slip_dout  =  {pma_din_s0[0:0], pma_din_s1[63:1]};
6'd2 : slip_dout  =  {pma_din_s0[1:0], pma_din_s1[63:2]};
6'd3 : slip_dout  =  {pma_din_s0[2:0], pma_din_s1[63:3]};
6'd4 : slip_dout  =  {pma_din_s0[3:0], pma_din_s1[63:4]};
6'd5 : slip_dout  =  {pma_din_s0[4:0], pma_din_s1[63:5]};
6'd6 : slip_dout  =  {pma_din_s0[5:0], pma_din_s1[63:6]};
6'd7 : slip_dout  =  {pma_din_s0[6:0], pma_din_s1[63:7]};
6'd8 : slip_dout  =  {pma_din_s0[7:0], pma_din_s1[63:8]};
6'd9 : slip_dout  =  {pma_din_s0[8:0], pma_din_s1[63:9]};
6'd10 : slip_dout  =  {pma_din_s0[9:0], pma_din_s1[63:10]};
6'd11 : slip_dout  =  {pma_din_s0[10:0], pma_din_s1[63:11]};
6'd12 : slip_dout  =  {pma_din_s0[11:0], pma_din_s1[63:12]};
6'd13 : slip_dout  =  {pma_din_s0[12:0], pma_din_s1[63:13]};
6'd14 : slip_dout  =  {pma_din_s0[13:0], pma_din_s1[63:14]};
6'd15 : slip_dout  =  {pma_din_s0[14:0], pma_din_s1[63:15]};
6'd16 : slip_dout  =  {pma_din_s0[15:0], pma_din_s1[63:16]};
6'd17 : slip_dout  =  {pma_din_s0[16:0], pma_din_s1[63:17]};
6'd18 : slip_dout  =  {pma_din_s0[17:0], pma_din_s1[63:18]};
6'd19 : slip_dout  =  {pma_din_s0[18:0], pma_din_s1[63:19]};
6'd20 : slip_dout  =  {pma_din_s0[19:0], pma_din_s1[63:20]};
6'd21 : slip_dout  =  {pma_din_s0[20:0], pma_din_s1[63:21]};
6'd22 : slip_dout  =  {pma_din_s0[21:0], pma_din_s1[63:22]};
6'd23 : slip_dout  =  {pma_din_s0[22:0], pma_din_s1[63:23]};
6'd24 : slip_dout  =  {pma_din_s0[23:0], pma_din_s1[63:24]};
6'd25 : slip_dout  =  {pma_din_s0[24:0], pma_din_s1[63:25]};
6'd26 : slip_dout  =  {pma_din_s0[25:0], pma_din_s1[63:26]};
6'd27 : slip_dout  =  {pma_din_s0[26:0], pma_din_s1[63:27]};
6'd28 : slip_dout  =  {pma_din_s0[27:0], pma_din_s1[63:28]};
6'd29 : slip_dout  =  {pma_din_s0[28:0], pma_din_s1[63:29]};
6'd30 : slip_dout  =  {pma_din_s0[29:0], pma_din_s1[63:30]};
6'd31 : slip_dout  =  {pma_din_s0[30:0], pma_din_s1[63:31]};
6'd32 : slip_dout  =  {pma_din_s0[31:0], pma_din_s1[63:32]};
6'd33 : slip_dout  =  {pma_din_s0[32:0], pma_din_s1[63:33]};
6'd34 : slip_dout  =  {pma_din_s0[33:0], pma_din_s1[63:34]};
6'd35 : slip_dout  =  {pma_din_s0[34:0], pma_din_s1[63:35]};
6'd36 : slip_dout  =  {pma_din_s0[35:0], pma_din_s1[63:36]};
6'd37 : slip_dout  =  {pma_din_s0[36:0], pma_din_s1[63:37]};
6'd38 : slip_dout  =  {pma_din_s0[37:0], pma_din_s1[63:38]};
6'd39 : slip_dout  =  {pma_din_s0[38:0], pma_din_s1[63:39]};
6'd40 : slip_dout  =  {pma_din_s0[39:0], pma_din_s1[63:40]};
6'd41 : slip_dout  =  {pma_din_s0[40:0], pma_din_s1[63:41]};
6'd42 : slip_dout  =  {pma_din_s0[41:0], pma_din_s1[63:42]};
6'd43 : slip_dout  =  {pma_din_s0[42:0], pma_din_s1[63:43]};
6'd44 : slip_dout  =  {pma_din_s0[43:0], pma_din_s1[63:44]};
6'd45 : slip_dout  =  {pma_din_s0[44:0], pma_din_s1[63:45]};
6'd46 : slip_dout  =  {pma_din_s0[45:0], pma_din_s1[63:46]};
6'd47 : slip_dout  =  {pma_din_s0[46:0], pma_din_s1[63:47]};
6'd48 : slip_dout  =  {pma_din_s0[47:0], pma_din_s1[63:48]};
6'd49 : slip_dout  =  {pma_din_s0[48:0], pma_din_s1[63:49]};
6'd50 : slip_dout  =  {pma_din_s0[49:0], pma_din_s1[63:50]};
6'd51 : slip_dout  =  {pma_din_s0[50:0], pma_din_s1[63:51]};
6'd52 : slip_dout  =  {pma_din_s0[51:0], pma_din_s1[63:52]};
6'd53 : slip_dout  =  {pma_din_s0[52:0], pma_din_s1[63:53]};
6'd54 : slip_dout  =  {pma_din_s0[53:0], pma_din_s1[63:54]};
6'd55 : slip_dout  =  {pma_din_s0[54:0], pma_din_s1[63:55]};
6'd56 : slip_dout  =  {pma_din_s0[55:0], pma_din_s1[63:56]};
6'd57 : slip_dout  =  {pma_din_s0[56:0], pma_din_s1[63:57]};
6'd58 : slip_dout  =  {pma_din_s0[57:0], pma_din_s1[63:58]};
6'd59 : slip_dout  =  {pma_din_s0[58:0], pma_din_s1[63:59]};
6'd60 : slip_dout  =  {pma_din_s0[59:0], pma_din_s1[63:60]};
6'd61 : slip_dout  =  {pma_din_s0[60:0], pma_din_s1[63:61]};
6'd62 : slip_dout  =  {pma_din_s0[61:0], pma_din_s1[63:62]};
6'd63 : slip_dout  =  {pma_din_s0[62:0], pma_din_s1[63:63]};
default : slip_dout    =  'h0;
endcase

/* flops
*/
always @(posedge CLK)
if (RST)
begin
	SLIP_DOUT <= 'h0;
	SLIP_DOUT_VAL <= 'h0;
	SLIP_PN_START <= 1'b0;
	slip_dout_r <= 'h0;
	slip_dout_val_r <= 'h0;
	slip_pn_start_r <= 'h0;
end
else
begin
	SLIP_DOUT <= slip_dout_r;
	SLIP_DOUT_VAL <= dval_s1;
	SLIP_PN_START <= dval_s0;
	slip_dout_r <= slip_dout;
	slip_dout_val_r <= dval_s1;
	slip_pn_start_r <= dval_s0;
end

endmodule

