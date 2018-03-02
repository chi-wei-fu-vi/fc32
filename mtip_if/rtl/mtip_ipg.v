/***************************************************************************
* Copyright (c) 2013 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: mtip_ipg.v$
* $Author: honda.yang $
* $Date: 2013-02-26 16:36:25 -0800 (Tue, 26 Feb 2013) $
* $Revision: 1601 $
* Description: This module was copied from Nuvation FC8 design (fe_buffer)
*              This module smooths the traffic from the MTIP core RX output. It ensures 
*              that there are at least 2 clock cyles of interpacket gap between frames
*
***************************************************************************/

 module mtip_ipg
  (
  input								iRESET_n,		 // Synchronous reset
  input								iCLK,				 // 212.5 MHz clock
  //	MTIP Receive FIFO Interface
	input   wire[ 31:0] iMTIP_DATA,  // Receive Data
	input   wire				iMTIP_DVAL,	 // Receive Data Valid            
	input   wire				iMTIP_SOP, 	 // Receive Start of Packet           
	input   wire				iMTIP_EOP, 	 // Receive End of Packet. 	
	input   wire				iMTIP_ERR,	 // Receive Frame Error
	// Outputs
	output	wire				oSOP,				 // SOP 1 clock cycle before oSOP_P0
	output	wire				oEOP,				 // EOP 1 clock cycle before oEOP_P0
  output	wire				oERR,				 // ERR 1 clock cycle before oERR_P0
  output	wire				oDVAL,		   // DVAL 1 clock cycle before oDVAL_P0
  output	wire [31:0]	oDATA_P0,		 // Output data to the Frame Extractor
	output	wire				oSOP_P0,		 // SOP  start of Packet 
	output	wire				oEOP_P0,		 // EOP  End of Packet
	output	wire				oERR_P0,	   // ERR  The last Frame had an error
  output	wire				oDVAL_P0,		 // DVAL SOP, EOP, ERR and DATA Valid
  output  wire        oFIFO_FULL   // The FE BUFFER is FULL  
  );
 
   // Signal Declarations
  reg	[2:0]	ps, ns; 

  reg [35:0] feBuff_r1;
  reg  [3:0] ipgCntr;
  reg        loadIpgCntr;
  reg        decIpgCntr; 
  reg        readEn;     
  
  wire [35:0] feBuffDataIn;
  wire [35:0] feBuffDataOut;
  wire        feBuffEmpty;
  wire        feBuffFull;
  wire        newFrame;
  wire        endFrame;
  wire        feBuffValid;
  wire        ipgEnd;
  
  // Parameters
    localparam  IPG_CNT = 4'h2;  // The number of clock cycles of interpacket gap between frames. 
                                 // This must be at least 2
                                 
  	localparam 	IDLE_ST		= 3'h1; 
    localparam 	READ_ST		= 3'h2; 
  	localparam  IPG_ST 		= 3'h4;
 
 
  assign newFrame = feBuffDataOut[32] && !feBuffEmpty;  // The first 32-bit word of a new frame
  assign endFrame = feBuffDataOut[33] && !feBuffEmpty;  // The last 32-bit word of the current frame
   
   assign feBuffDataIn =  {1'b0, iMTIP_ERR, iMTIP_EOP, iMTIP_SOP, iMTIP_DATA};

   assign oFIFO_FULL = feBuffFull;
   
	// Frame Extractor Fifo - 36 bits wide, 256 words deep. Show ahead with registered output
	fifo_36bx256w	feBuff 
  (
         .almost_full(),    // output wire almost_full
         .overflow(),          // output wire overflow
         .almost_empty(),  // output wire almost_empty
         .underflow(),        // output wire underflow
  .       wr_rst_busy(),    // output wire wr_rst_busy
         .rd_rst_busy(),   // output wire rd_rst_busy
	 .rst 	( !iRESET_n ),
	 .clk ( iCLK ),
	 .din 	( feBuffDataIn ),
	 .rd_en ( readEn ),
	 .wr_en ( iMTIP_DVAL ), // All valid data from the MTIP core is written into this fifo
	 .empty ( feBuffEmpty ),
	 .full 	( feBuffFull ),
	 .dout 		( feBuffDataOut ),
	 .data_count (  )
	 );


// INST_TAG_END ------ End INSTANTIATION Template ---------

// You must compile the wrapper file fifo_36bx256w.v when simulating
// the core, fifo_36bx256w. When compiling the wrapper file, be sure to
// reference the Verilog simulation library.

    // The FIFO output is not valid if it is empty, or the next state is not the read state. 
    // This prevents the same output data from being valid for more than 1 clock cycle. 
   assign feBuffValid = (!feBuffEmpty && ((ns == READ_ST) || (ps == READ_ST)) ) ;

   assign oSOP  =  feBuffDataOut[32] && feBuffValid;
   assign oEOP  =  feBuffDataOut[33] && feBuffValid;
   assign oERR  =  feBuffDataOut[34] && feBuffValid;
   assign oDVAL =  feBuffValid;


 // This register allows the 1 clock cycle early indication for the MTIP
 // signals from registered feBuff output
   always @(posedge iCLK or negedge iRESET_n)		
     if(!iRESET_n)
       feBuff_r1 <= {36{1'b0}};
     else
       feBuff_r1 <= {feBuffValid, feBuffDataOut[34:0]}; 
   
// The output signals delayed by 1 clock cycle   
   assign oDATA_P0 =  oDVAL_P0 ? feBuff_r1[31:0] : {32{1'b0}};
   assign oSOP_P0  =  feBuff_r1[32] && oDVAL_P0;
   assign oEOP_P0  =  feBuff_r1[33] && oDVAL_P0;
   assign oERR_P0  =  feBuff_r1[34] && oDVAL_P0;
   assign oDVAL_P0 =  feBuff_r1[35]; 
   
   //**************************************************************************
   // This is the state machine that reads the contents of the feBuff Fifo. It 
   // always readsthe contents of the feBuff except it puts in an ipg gap after 
   // every frame.
   //**************************************************************************
   // FSM Sequential logic
 always @(posedge iCLK or negedge iRESET_n)		
  if(!iRESET_n)
   	ps <= IDLE_ST;
  else
   	ps <= ns;
 
 // FSM next state and output Logic
 always @*
   begin
    loadIpgCntr = 1'b0;
    decIpgCntr  = 1'b0;
    readEn      = 1'b0;
    
 		case(ps)
 			IDLE_ST:	if(newFrame)  // Start of a new Packet
                  begin
 									  ns = READ_ST;
                    loadIpgCntr = 1'b1;
                    readEn = 1'b1;
                  end
 								else
 									begin
                    ns = IDLE_ST;
                    readEn = 1'b1;
                  end                                       
                  
      READ_ST:  if(endFrame)
                  begin
                    ns = IPG_ST;
                    readEn = 1'b1;
                    decIpgCntr = 1'b1;
                  end                                             
                else
                  begin
                    ns = READ_ST;
                    readEn = 1'b1;
                  end                         
                  
        IPG_ST: if(ipgEnd)
                  begin
                    ns = IDLE_ST;
                  end
                else
                  begin
                    ns = IPG_ST;
                    decIpgCntr = 1'b1;
                  end
                  
        default:  begin
                    readEn = 1'b1;
                    ns = IDLE_ST;
                  end
     endcase
   end
 //**************************************************************************
 //*************  End of FSM ************************************************
 //**************************************************************************
 //
  // Inter Packet Gap Counter 
  always @(posedge iCLK or negedge iRESET_n)		
    if(!iRESET_n)
      ipgCntr <= 4'b0;
    else
      if(loadIpgCntr)
        ipgCntr <= IPG_CNT;
      else
        if(ipgCntr > 4'h0)
          ipgCntr <= ipgCntr - decIpgCntr;
        else
          ipgCntr <= ipgCntr;
                
      assign ipgEnd = (ipgCntr == 4'h0 ); // IPG_ST will account for 1 ipg already
 
endmodule	
