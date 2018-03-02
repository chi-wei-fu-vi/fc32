/***************************************************************************
* Copyright (c) 2013, 2014 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: $
* $Author: $
* $Date: $
* $Revision: $
***************************************************************************/

module  vi_stratixv_crcblock
  (

   input 	       clk_fr,               // hook-up to 100Mhz free running clock
   input 	       clk,                  // hook-up to core clock
   input 	       rst_fr_n,             // hook-up to 100Mhz free running clock reset
   input 	       rst_n,                // hook-up to core clock async reset

   output logic        crc_error_event,      // for connection as enable to counter.  synchronized
                                             // into the core clock domain

   output logic [67:0] crc_error_emr,        // CRC error message register.  Specifies the type and
                                             // details of error.  

   output logic        io_crc_error          // crc_error - connect to bi-dir I/O.  flopped and 
                                             // synchronous with clk_fr
   );
   

   logic 	       crc_error_d;
   logic [31:0]        crcblock_regout;
   logic 	       crcblock_shiftnld;
  
   // -------------
   // User Logic
   // -------------
   // Interfaces and controls Altera CRC block.  This code has not been completed.  

   // CRC error to I/O must be flopped per Altera guidelines
   always_ff @(posedge clk_fr or negedge rst_fr_n)
     io_crc_error <= ~rst_fr_n ? 1'b0 : crc_error_d;

   // FIXME - state machine to sequence out EMR is not completed
   assign crcblock_shiftnld = 1'b0;

   assign crc_error_event = (crc_error_d & ~io_crc_error);

   assign crc_error_emr[67:0] = 68'hC001C0DE;
   
   // -------------
   // CRC_Error 
   // -------------
   // WYSIWYG atom instantiation to create interface into crc error detection block.
   //
   // Comments are embedded from Altera AN539 app note

   stratixv_crcblock crc_wysiwyg_atom
     (
      
      // Designates the clock input of this cell. All operations of this cell
      // are with respect to the falling edge of the clock. Whether loading
      // data into the cell or out of the cell, this always occurs on the
      // falling edge. This is a required port.
      .clk       (clk_fr),

      // An input into the error detection block.  If shiftnld=1, the user
      // shift register shifts the data to the regout port at each rising edge
      // of the clk port.  If shiftnld=0, the user shift register parallel
      // loads the contents of the user update register. This is a required
      // port.  This input triggers clock enable for the user update register
      // to de-assert after two EDCLK cycles. After driving the ED_SHIFTNLD
      // signal low, wait at least two EDCLK cycles before clocking the ED_CLK
      // signal.
      .shiftnld  (crcblock_shiftnld),

      // Output of the cell that is synchronized to the internal oscillator of
      // the device (100-MHz or 80-MHz internal oscillator) and not to the clk
      // port. This output asserts automatically high if the error block
      // detects that a SRAM bit has flipped and the internal CRC computation
      // has shown a difference with respect to the pre-computed value.
      // Connect this signal to an output pin or a bidirectional pin. If you
      // connect this output signal to an output pin, you can only monitor the
      // CRC_ERROR pin (the core logic cannot access this output). If the core
      // logic uses the CRC_ERROR signal to read the error detection logic,
      // connect this signal to a BIDIR pin. The signal is fed to the core
      // indirectly by feeding a BIDIR pin that has its output enable port (oe)
      // connected to VCC.  The signal that is routed to the CRC_ERROR pin is
      // also routed to the core.
      .crcerror  (crc_error_d),

      // Output of the user shift register synchronized to the clk port, to
      // be read by the core logic. This shifts one bit at each cycle.
      .regout    (crcblock_regout[31:0])

      );

   // divisor is 2^n.  n=1-8.  Set to zero for fastest scrubbing rate.
   defparam crc_wysiwyg_atom.oscillator_divider = 1;

endmodule // vi_arriav_crcblock

