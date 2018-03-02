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
* This file should contain reusable functions that are portable across blocks
* or applications
*
* Revision History Notes:
* 2012/07/26 Tim - initial release
*
*
***************************************************************************/
package bali_lib_pkg;
  
  function [4:0] encoder_32_5;
    input [31:0] one_hot;
  begin
    encoder_32_5 = 4'b0;
    unique case ( 1'b1 )
      one_hot[ 0]: encoder_32_5 = 5'd0;
      one_hot[ 1]: encoder_32_5 = 5'd1;
      one_hot[ 2]: encoder_32_5 = 5'd2;
      one_hot[ 3]: encoder_32_5 = 5'd3;
      one_hot[ 4]: encoder_32_5 = 5'd4;
      one_hot[ 5]: encoder_32_5 = 5'd5;
      one_hot[ 6]: encoder_32_5 = 5'd6;
      one_hot[ 7]: encoder_32_5 = 5'd7;
      one_hot[ 8]: encoder_32_5 = 5'd8;
      one_hot[ 9]: encoder_32_5 = 5'd9;
      one_hot[10]: encoder_32_5 = 5'd10;
      one_hot[11]: encoder_32_5 = 5'd11;
      one_hot[12]: encoder_32_5 = 5'd12;
      one_hot[13]: encoder_32_5 = 5'd13;
      one_hot[14]: encoder_32_5 = 5'd14;
      one_hot[15]: encoder_32_5 = 5'd15;
      one_hot[16]: encoder_32_5 = 5'd16;
      one_hot[17]: encoder_32_5 = 5'd17;
      one_hot[18]: encoder_32_5 = 5'd18;
      one_hot[19]: encoder_32_5 = 5'd19;
      one_hot[20]: encoder_32_5 = 5'd20;
      one_hot[21]: encoder_32_5 = 5'd21;
      one_hot[22]: encoder_32_5 = 5'd22;
      one_hot[23]: encoder_32_5 = 5'd23;
      one_hot[24]: encoder_32_5 = 5'd24;
      one_hot[25]: encoder_32_5 = 5'd25;
      one_hot[26]: encoder_32_5 = 5'd26;
      one_hot[27]: encoder_32_5 = 5'd27;
      one_hot[28]: encoder_32_5 = 5'd28;
      one_hot[29]: encoder_32_5 = 5'd29;
      one_hot[30]: encoder_32_5 = 5'd30;
      one_hot[31]: encoder_32_5 = 5'd31;
      default:     encoder_32_5 = 5'd0;
    endcase
  end
  endfunction
  
  
  function [3:0] encoder_16_4;
    input [15:0] one_hot;
  begin
    encoder_16_4 = 4'b0;
    unique case ( 1'b1 )
      one_hot[ 0]: encoder_16_4 = 4'd0;
      one_hot[ 1]: encoder_16_4 = 4'd1;
      one_hot[ 2]: encoder_16_4 = 4'd2;
      one_hot[ 3]: encoder_16_4 = 4'd3;
      one_hot[ 4]: encoder_16_4 = 4'd4;
      one_hot[ 5]: encoder_16_4 = 4'd5;
      one_hot[ 6]: encoder_16_4 = 4'd6;
      one_hot[ 7]: encoder_16_4 = 4'd7;
      one_hot[ 8]: encoder_16_4 = 4'd8;
      one_hot[ 9]: encoder_16_4 = 4'd9;
      one_hot[10]: encoder_16_4 = 4'd10;
      one_hot[11]: encoder_16_4 = 4'd11;
      one_hot[12]: encoder_16_4 = 4'd12;
      one_hot[13]: encoder_16_4 = 4'd13;
      one_hot[14]: encoder_16_4 = 4'd14;
      one_hot[15]: encoder_16_4 = 4'd15;
      default:     encoder_16_4 = 4'd0;
    endcase
  end
  endfunction
  
  function [2:0] encoder_8_3
  (
    input [7:0] one_hot
  );
  begin
    encoder_8_3 = {one_hot[4]|one_hot[5]|one_hot[6]|one_hot[7],
                   one_hot[2]|one_hot[3]|one_hot[6]|one_hot[7],
                   one_hot[1]|one_hot[3]|one_hot[5]|one_hot[7]};
  end
  endfunction
  
  function [1:0] encoder_4_2
  (
    input [3:0] one_hot
  );
  begin
    encoder_4_2 = {one_hot[2] | one_hot[3],
                   one_hot[1] | one_hot[3]};
  end
  endfunction
  
endpackage
