module gatekeeper (

input iRST_LINK_FC_CORE_N,
input iCLK_CORE,

input mtip_enable,

input    [63:0]                         MIF_EXTR_DATA,
input    [2:0]                          MIF_EXTR_EMPTY,
input    MIF_EXTR_SOP,
input    MIF_EXTR_EOP,
input    MIF_EXTR_ERR,
input    MIF_EXTR_VALID,

input  [63:0]                         fmac_st_data,
input  [2:0]                          fmac_st_empty,
input                                 fmac_st_eop,
input                                 fmac_st_err,
input                                 fmac_st_sop,
input                                 fmac_st_valid,

output logic  [63:0]                         mux_st_data,
output logic  [2:0]                          mux_st_empty,
output logic                                 mux_st_sop,
output logic                                 mux_st_eop,
output logic                                 mux_st_err,
output logic                                 mux_st_valid

);
logic nsop, neop, nerr, nvalid;

always @(posedge iCLK_CORE or negedge iRST_LINK_FC_CORE_N)
  if (!iRST_LINK_FC_CORE_N)
  begin
		mux_st_data <= 'h0;
		mux_st_empty <= 'h0;
		mux_st_sop <= 'h0;
		mux_st_eop <= 'h0;
		mux_st_err <= 'h0;
		mux_st_valid <= 'h0;
	end
	else
	begin
		mux_st_data <= mtip_enable ? MIF_EXTR_DATA : fmac_st_data;
		mux_st_empty <= mtip_enable ? MIF_EXTR_EMPTY : fmac_st_empty;
		mux_st_sop <= nsop;
		mux_st_eop <= neop;
		mux_st_err <= nerr;
		mux_st_valid <= nvalid;
  end

/* check for min frame length violation
 * check for sop eop share same cycle
 * check for mode change while in frame violation
 * implies that an SOP is already sent
 */
logic viol8g;
logic viol16g;
logic eop_bb16g;
logic eop_bb8g;


se_violation
  se_8g_violation_inst
(
. clk(iCLK_CORE),
. rst_n(iRST_LINK_FC_CORE_N),
. sop(MIF_EXTR_SOP),
. eop(MIF_EXTR_EOP),
. valid (MIF_EXTR_VALID),
. active (mtip_enable),
. violation(viol8g),
. eop_bb(eop_bb8g)
);

se_violation
  se_16g_violation_inst
(
. clk(iCLK_CORE),
. rst_n(iRST_LINK_FC_CORE_N),
. sop(fmac_st_sop),
. eop(fmac_st_eop),
. valid (fmac_st_valid),
. active (~mtip_enable),
. violation(viol16g),
. eop_bb(eop_bb16g)
);

enum logic [2:0] {
NORM16 = 3'h0,
ERR_DAT16 = 3'h1,
ERR_EOP16 = 3'h2,
WAIT_SOP16 = 3'h3,
NORM8 = 3'h4,
ERR_DAT8 = 3'h5,
ERR_EOP8 = 3'h6,
WAIT_SOP8 = 3'h7} state, nstate;

//localparam NORM16 = 0;
//localparam ERR_DAT16 = 1;
//localparam ERR_EOP16 = 2;
//localparam WAIT_SOP16 = 3;
//localparam NORM8 = 4;
//localparam ERR_DAT8 = 5;
//localparam ERR_EOP8 = 6;
//localparam WAIT_SOP8 = 7;

//logic [2:0] state, nstate;

always @(posedge iCLK_CORE or negedge iRST_LINK_FC_CORE_N)
  if (!iRST_LINK_FC_CORE_N)
		state <= WAIT_SOP16;
	else
		state <= nstate;

always @(*)
begin
  nstate = state;
	nsop = 1'b0;
	neop = 1'b0;
	nerr = 1'b0;
	nvalid = 1'b0;
  case (state)
	  NORM16 : 
		begin
		  nsop = fmac_st_sop;
			neop = fmac_st_eop;
			nerr = fmac_st_err;
			nvalid = fmac_st_valid;
			if (eop_bb16g)
			begin
		    nsop = 1'b0;
				nvalid = 1'b0;
				neop = 1'b0;  //suppress eop to prepare for err end
		    nstate = WAIT_SOP16;
			end
	    else if (viol16g) 
			begin
	      nstate = ERR_DAT16;
				nsop = 1'b0;  // suppress sop, since already in frame to get violation
				nerr = 1'b0;  // suppress error until padding is done
				neop = 1'b0;  //suppress eop to prepare for err end
			end
      else if (mtip_enable && ~(fmac_st_sop & fmac_st_valid))
        nstate = WAIT_SOP8;
	  end
  
	  ERR_DAT16 : 
		begin
		  nsop = 1'b0;
			neop = 1'b0;
			nerr = 1'b0;
			nvalid = 1'b1;
		  nstate = ERR_EOP16;
		end
  
	  ERR_EOP16 : 
		begin
		  nsop = 1'b0;
			neop = 1'b1;
			nerr = 1'b1;
			nvalid = 1'b1;
		  nstate = WAIT_SOP16;
		end
 
    WAIT_SOP16 :
		begin
	    nsop = 1'b0;
	    neop = 1'b0;
	    nerr = 1'b0;
	    nvalid = 1'b0;
			if (mtip_enable)
			begin
		    nstate = WAIT_SOP8;
				nsop = 1'b0;
				nvalid = 1'b0;
			end
			else if (fmac_st_sop & fmac_st_valid)
			begin
			  nstate = NORM16;
				nsop = 1'b1;
				nvalid = 1'b1;
			end
	  end

    NORM8 :
    begin
      nsop = MIF_EXTR_SOP;
      neop = MIF_EXTR_EOP;
      nerr = MIF_EXTR_ERR;
      nvalid = MIF_EXTR_VALID;
			if (eop_bb8g)
			begin
				neop = 1'b0;  //suppress eop to prepare for err end
				nsop = 1'b0;
        nvalid = 1'b0;
		    nstate = WAIT_SOP8;
			end
      else if (viol8g)
      begin
        nstate = ERR_DAT8;
				nsop = 1'b0;
				nerr = 1'b0;  // suppress error until padding is done
        neop = 1'b0;  //suppress eop to prepare for err end
      end
      else if (~mtip_enable & ~(MIF_EXTR_SOP & MIF_EXTR_VALID))
        nstate = WAIT_SOP16;
    end

    ERR_DAT8 : 
    begin
      nsop = 1'b0;
      neop = 1'b0;
      nerr = 1'b0;
      nvalid = 1'b1;
      nstate = ERR_EOP8;
    end

    ERR_EOP8 : 
    begin
      nsop = 1'b0;
      neop = 1'b1;
      nerr = 1'b1;
      nvalid = 1'b1; 
      nstate = WAIT_SOP8;
    end

    WAIT_SOP8 :
		begin
      nsop = 1'b0;
      neop = 1'b0;
      nerr = 1'b0;
      nvalid = 1'b0;
      if (~mtip_enable)
      begin
        nstate = WAIT_SOP16;
        nsop = 1'b0;
        nvalid = 1'b0;
      end
      else if (MIF_EXTR_SOP & MIF_EXTR_VALID)
      begin
        nstate = NORM8;
        nsop = 1'b1;
        nvalid = 1'b1;
      end
    end

	  default : nstate = WAIT_SOP16;
  endcase

end



endmodule
