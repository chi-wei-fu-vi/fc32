/********************************CONFIDENTIAL****************************
* Copyright (c) 2011 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: $
* $Author: $
* $Date: 2012-07-13 14:28:26 -0700 (Fri, 13 Jul 2012) $
* $Revision: 71 $
* Description:
*
* This file contains defines, structs and functions useful for
* implementing PCIe application.
*
* Revision History Notes:
* 2012/07/26 Tim - initial release
* 2012/08/28 Tim - Added is_unsupported_request and pipe_if_type
*
***************************************************************************/
module is_unsupported_request(input [1:0] fmt, input [4:0] frm_type, output logic out);
  
  always_comb
  begin
    priority casex ({fmt, frm_type})
  
      7'b0000000 : out = 0;   // MRd; Supported
      7'b0100000 : out = 1;   // MRd-64-bit (4DW);Not Supported
      7'b0x00001 : out = 1;   // MRdLk;
      7'b1000000 : out = 0;   // MWr; Support
      7'b1100000 : out = 1;   // MWr-64-bit (4DW); Not Supported
      7'bx000010 : out = 1;   // IORd/IOWr;
      7'bx00010x : out = 1;   // CfgRd0/CfgWr0/CfgRd1/CfgWr1;
      7'bx011011 : out = 1;   // TCfgRd/TCfgWr; (depracated TLP type)
      7'bx110xxx : out = 1;   // Msg;
      7'b1110xxx : out = 1;   // MsgD;
      7'bx00101x : out = 0;   // Cpl/CplD/CplLk/CplDLk;
      default    : out = 1;   // others unsupported
    endcase
  end
endmodule
module is_non_posted(input [1:0] fmt, input [4:0] frm_type, output logic out);
  always_comb
  begin
    priority casex ({fmt, frm_type})
      7'b0x00000 : out = 1;   // MRd;
      7'b0x00001 : out = 1;   // MRdLk;
      7'b1x00000 : out = 0;   // MWr;
      7'b0000010 : out = 1;   // IORd;
      7'b1000010 : out = 0;   // IOWr;
      7'b000010x : out = 1;   // CfgRd0/CfgRd1;
      7'b100010x : out = 1;   // CfgWr0/CfgWr1;
      7'b0011011 : out = 1;   // TCfgRd; (depracated TLP type)
      7'b1011011 : out = 1;   // TCfgWr; (depracated TLP type)
  //  7'bx110xxx : out = 1;   // Msg;
  //  7'b1110xxx : out = 1;   // MsgD;
      7'bx00101x : out = 0;   // Cpl/CplD/CplLk/CplDLk;
      default    : out = 0;   // others
    endcase
  end
endmodule