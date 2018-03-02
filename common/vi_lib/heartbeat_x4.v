//--------------------------------------------------------------------------//
// Title:       heartbeat_x4.v                                              //
// Rev:         Rev 1                                                       //
// Author		Altera High Speed Design Group - San Diego                  //
//--------------------------------------------------------------------------//
// Description: // Drives LEDs with a "heartbeat" pattern (board is alive)  // 
//----------------------------------------------------------------------------
//Copyright © 2006 Altera Corporation. All rights reserved.  Altera products
//are protected under numerous U.S. and foreign patents, maskwork rights,
//copyrights and other intellectual property laws.
//                                                                                                     
//This reference design file, and your use thereof, is subject to and
//governed by the terms and conditions of the applicable Altera Reference
//Design License Agreement.  By using this reference design file, you
//indicate your acceptance of such terms and conditions between you and
//Altera Corporation.  In the event that you do not agree with such terms and
//conditions, you may not use the reference design file. Please promptly                         
//destroy any copies you have made.
//
//This reference design file being provided on an "as-is" basis and as an
//accommodation and therefore all warranties, representations or guarantees
//of any kind (whether express, implied or statutory) including, without
//limitation, warranties of merchantability, non-infringement, or fitness for
//a particular purpose, are specifically disclaimed.  By making this
//reference design file available, Altera expressly does not recommend,
//suggest or require that this reference design file be used in combination 
//with any other product not provided by Altera
// Set parameter "heartbeat_mode" for different LED patterns
module heartbeat_x4 (
						reset_n,
						clk,
						led_pattern
					);									
	parameter						heartbeat_mode	=	1;	// Set to 0 or 1, controls LED Pattern
	parameter						led_width		=	4;
	parameter						lfsr_seed		=	1;
	input          					reset_n;         
	input			   				clk;
	output	reg	[led_width-1:0]		led_pattern;

	// Internal data structures:					
	reg		[31:0]				heartbeat;
	reg		[7:0]				lfsr_data;
	integer						state_ctr;	


	always	@(posedge clk or negedge reset_n)
	begin
		if	(!reset_n)
		begin
			heartbeat	<=	0;
			led_pattern	<=	0;
			state_ctr	<=	0;
			lfsr_data	<=	lfsr_seed;
		end else begin
			heartbeat	<=	heartbeat + 1;
			if	(	((heartbeat[23]==1) 	&& (heartbeat_mode == 0))	||
					((heartbeat[22:0]==0)	&& (heartbeat_mode == 1))
				)
			begin
				change_led;
			end
		end
	end			
	
	task	change_led;
		begin			
			case	(state_ctr)
				0:			led_pattern		<=	4'b1111;
				1:			led_pattern		<=	4'b1110;
				2:			led_pattern		<=	4'b1100;
				3:			led_pattern		<=	4'b1001;
				4:			led_pattern		<=	4'b0011;
				5:			led_pattern		<=	4'b0111;
				6:			led_pattern		<=	4'b1111;
				7:			led_pattern		<=	4'b0111;
				8:			led_pattern		<=	4'b0011;
				9:			led_pattern		<=	4'b1001;
				10:			led_pattern		<=	4'b1100;
				11:			led_pattern		<=	4'b1110;
				default:	led_pattern		<=	4'b1111;
			endcase
			if	((state_ctr == 5) || (state_ctr==11))
			begin
				random_data;
				if	(lfsr_data[0] == 0)
				begin
					state_ctr	<=	0;
				end else begin
					state_ctr	<=	6;
				end
			end else begin
				state_ctr	<=	state_ctr + 1;
			end
		end
	endtask
	
	// simple lfsr generator:
	task	random_data;
		begin
			lfsr_data[0] <= lfsr_data[7] ;
			lfsr_data[1] <= lfsr_data[0] ;
			lfsr_data[2] <= lfsr_data[1] ^ lfsr_data[7] ;
			lfsr_data[3] <= lfsr_data[2] ^ lfsr_data[7] ;
			lfsr_data[4] <= lfsr_data[3] ^ lfsr_data[7] ;
			lfsr_data[5] <= lfsr_data[4] ;
			lfsr_data[6] <= lfsr_data[5] ;
			lfsr_data[7] <= lfsr_data[6] ;
		end
	endtask

				
endmodule