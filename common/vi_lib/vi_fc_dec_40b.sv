/***********************************************************************************************************
* Copyright (c) 2012,2013 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Author$
* $Date$
* $Revision$
* $HeadURL$
***********************************************************************************************************/

module vi_fc_dec_40b
  (
    input [39:0]    rx_data,            // data must be big-endian (byte 0 at [39:30], byte 1 at [29:20], etc...)
    output 	    sof,
    output 	    eof,
    output 	    idle,               // includes ARBFF
    output 	    nos,
    output 	    ols,
    output 	    lr,
    output 	    lrr
   );

   `include "vi_defines.vh"

   wire [9:0]       rx_word0;             
   wire [9:0]       rx_word1;             
   wire [9:0]       rx_word2;             
   wire [9:0]       rx_word3;             
   wire             comma_in_0;           
   wire             d21_5_in_1;
   wire             d21_1_in_1;
   wire             d23_0_in_23;          
   wire             d23_2_in_23;          
   wire             d23_1_in_23;          
   wire             d21_2_in_23;          
   wire             d21_2_in_3;          
   wire             d21_2_in_1;          
   wire             d21_1_in_23;          
   wire             d22_2_in_23;          
   wire             d22_1_in_23;          
   wire             d25_0_in_23;          
   wire             d25_1_in_23;          
   wire             d25_2_in_23;          
   wire             d24_2_in_23;          
   wire             d21_4_in_1;           
   wire             d10_4_in_1;           
   wire             d10_5_in_1;           
   wire             d21_3_in_23;          
   wire             d21_4_in_23;          
   wire             d21_7_in_23;          
   wire             d21_6_in_23;          
   wire             d25_4_in_23;          
   wire             d20_4_in_1;           
   wire             d21_5_in_23;          
   wire             d31_7_in_23;
   wire 	    d31_5_in_2;
   wire 	    d5_2_in_3;
   wire 	    d10_4_in_2;
   wire 	    d9_2_in_1;
   wire 	    d9_2_in_3;
   wire [39:0] 	    rx_data_be;
   
   // ----------
   // Endianess
   // -----------
   // This module was originally coded as little endian.  FC is big-endian.  Swizzle the data coming in
//
//   assign rx_data_be[39:0] = {rx_data[9:0], rx_data[19:10], rx_data[29:20], rx_data[39:30]};


   // ----------
   // Bit reverse
   // -----------
   // bit reverse symbols to match `define symbol encodings

   assign rx_word0[9:0] = { rx_data[0],  rx_data[1],  rx_data[2],  rx_data[3],  rx_data[4],
                            rx_data[5],  rx_data[6],  rx_data[7],  rx_data[8],  rx_data[9] };

   assign rx_word1[9:0] = { rx_data[10], rx_data[11], rx_data[12], rx_data[13], rx_data[14],
                            rx_data[15], rx_data[16], rx_data[17], rx_data[18], rx_data[19] };
   
   assign rx_word2[9:0] = { rx_data[20], rx_data[21], rx_data[22], rx_data[23], rx_data[24],
                            rx_data[25], rx_data[26], rx_data[27], rx_data[28], rx_data[29] };
                               
   assign rx_word3[9:0] =  { rx_data[30], rx_data[31], rx_data[32], rx_data[33], rx_data[34],
                             rx_data[35], rx_data[36], rx_data[37], rx_data[38], rx_data[39] };

//   assign rx_word0[9:0] = rx_data[9:0];
//   assign rx_word1[9:0] = rx_data[19:10];
//   assign rx_word2[9:0] = rx_data[29:20];
//   assign rx_word3[9:0] = rx_data[39:30];


   // ------
   // SOF
   // ------

   assign comma_in_0    = (rx_word0[9:0]==`K28_5_N) | (rx_word0[9:0]==`K28_5_P);
   assign d21_5_in_1    = (rx_word1[9:0]==`D21_5_N) | (rx_word1[9:0]==`D21_5_P);
   
   assign d23_0_in_23   = ((rx_word2[9:0]==`D23_0_N) | (rx_word2[9:0]==`D23_0_P)) & 
                          ((rx_word3[9:0]==`D23_0_N) | (rx_word3[9:0]==`D23_0_P));

   assign d23_2_in_23   = ((rx_word2[9:0]==`D23_2_N) | (rx_word2[9:0]==`D23_2_P)) & 
                          ((rx_word3[9:0]==`D23_2_N) | (rx_word3[9:0]==`D23_2_P));

   assign d23_1_in_23   = ((rx_word2[9:0]==`D23_1_N) | (rx_word2[9:0]==`D23_1_P)) & 
                          ((rx_word3[9:0]==`D23_1_N) | (rx_word3[9:0]==`D23_1_P));

   assign d21_2_in_23   = ((rx_word2[9:0]==`D21_2_N) | (rx_word2[9:0]==`D21_2_P)) & 
                          ((rx_word3[9:0]==`D21_2_N) | (rx_word3[9:0]==`D21_2_P));

   assign d21_1_in_23   = ((rx_word2[9:0]==`D21_1_N) | (rx_word2[9:0]==`D21_1_P)) & 
                          ((rx_word3[9:0]==`D21_1_N) | (rx_word3[9:0]==`D21_1_P));

   assign d22_2_in_23   = ((rx_word2[9:0]==`D22_2_N) | (rx_word2[9:0]==`D22_2_P)) & 
                          ((rx_word3[9:0]==`D22_2_N) | (rx_word3[9:0]==`D22_2_P));

   assign d22_1_in_23   = ((rx_word2[9:0]==`D22_1_N) | (rx_word2[9:0]==`D22_1_P)) & 
                          ((rx_word3[9:0]==`D22_1_N) | (rx_word3[9:0]==`D22_1_P));

   assign d25_0_in_23   = ((rx_word2[9:0]==`D25_0_N) | (rx_word2[9:0]==`D25_0_P)) & 
                          ((rx_word3[9:0]==`D25_0_N) | (rx_word3[9:0]==`D25_0_P));
   
   assign d25_1_in_23   = ((rx_word2[9:0]==`D25_1_N) | (rx_word2[9:0]==`D25_1_P)) & 
                          ((rx_word3[9:0]==`D25_1_N) | (rx_word3[9:0]==`D25_1_P));
   
   assign d25_2_in_23   = ((rx_word2[9:0]==`D25_2_N) | (rx_word2[9:0]==`D25_2_P)) & 
                          ((rx_word3[9:0]==`D25_2_N) | (rx_word3[9:0]==`D25_2_P));

   assign d24_2_in_23   = ((rx_word2[9:0]==`D24_2_N) | (rx_word2[9:0]==`D24_2_P)) & 
                          ((rx_word3[9:0]==`D24_2_N) | (rx_word3[9:0]==`D24_2_P));

   assign sof = comma_in_0 & d21_5_in_1 & (d23_0_in_23 |    // SOF connect  class
                                           d23_2_in_23 |    // SOF initiate class
                                           d23_1_in_23 |    // SOF normal   class
                                           d21_2_in_23 |    // SOF initiate class
                                           d21_1_in_23 |    // SOF normal   class
                                           d22_2_in_23 |    // SOF initiate class
                                           d22_1_in_23 |    // SOF normal   class
                                           d25_0_in_23 |    // SOF active   class
                                           d25_2_in_23 |    // SOF initiate class
                                           d25_1_in_23 |    // SOF normal   class
                                           d24_2_in_23 );   // SOF fabric        
                                                                        
   // ------
   // EOF
   // ------

   
   assign d21_4_in_1    = (rx_word1[9:0]==`D21_4_N) | (rx_word1[9:0]==`D21_4_P);
   assign d10_4_in_1    = (rx_word1[9:0]==`D10_4_N) | (rx_word1[9:0]==`D10_4_P);
   assign d10_5_in_1    = (rx_word1[9:0]==`D10_5_N) | (rx_word1[9:0]==`D10_5_P);

   assign d21_3_in_23   = ((rx_word2[9:0]==`D21_3_N) | (rx_word2[9:0]==`D21_3_P)) & 
                          ((rx_word3[9:0]==`D21_3_N) | (rx_word3[9:0]==`D21_3_P));

   assign d21_4_in_23   = ((rx_word2[9:0]==`D21_4_N) | (rx_word2[9:0]==`D21_4_P)) & 
                          ((rx_word3[9:0]==`D21_4_N) | (rx_word3[9:0]==`D21_4_P));

   assign d21_7_in_23   = ((rx_word2[9:0]==`D21_7_N) | (rx_word2[9:0]==`D21_7_P)) & 
                          ((rx_word3[9:0]==`D21_7_N) | (rx_word3[9:0]==`D21_7_P));

   assign d21_6_in_23   = ((rx_word2[9:0]==`D21_6_N) | (rx_word2[9:0]==`D21_6_P)) & 
                          ((rx_word3[9:0]==`D21_6_N) | (rx_word3[9:0]==`D21_6_P));

   assign d25_4_in_23   = ((rx_word2[9:0]==`D25_4_N) | (rx_word2[9:0]==`D25_4_P)) & 
                          ((rx_word3[9:0]==`D25_4_N) | (rx_word3[9:0]==`D25_4_P));

   assign eof = comma_in_0 & ( (d21_4_in_1 & d21_3_in_23) |     // EOF terminate                                           
                               (d21_5_in_1 & d21_3_in_23) |     // EOF terminate                                           
                               (d21_4_in_1 & d21_4_in_23) |     // EOF disconnect-terminate (class 1 or class 4)
                               (d21_5_in_1 & d21_4_in_23) |     // EOF disconnect-terminate (class 1 or class 4)
                               (d21_4_in_1 & d21_7_in_23) |     // EOF abort                                               
                               (d21_5_in_1 & d21_7_in_23) |     // EOF abort                                               
                               (d21_4_in_1 & d21_6_in_23) |     // EOF normal                                              
                               (d21_5_in_1 & d21_6_in_23) |     // EOF normal                                              
                               (d10_4_in_1 & d21_6_in_23) |     // EOF normal-invalid                                      
                               (d10_5_in_1 & d21_6_in_23) |     // EOF normal-invalid                                      
                               (d10_4_in_1 & d21_4_in_23) |     // EOF disconnect-terminate-invalid (class 1 or class 4)
                               (d10_5_in_1 & d21_4_in_23) |     // EOF disconnect-terminate-invalid (class 1 or class 4)
                               (d21_4_in_1 & d25_4_in_23) |     // EOF remove-terminate (class 4)
                               (d21_5_in_1 & d25_4_in_23) |     // EOF remove-terminate (class 4)
                               (d10_4_in_1 & d25_4_in_23) |     // EOF remove-terminate-invalid (class 4)                  
                               (d10_5_in_1 & d25_4_in_23) );    // EOF remove-terminate-invalid (class 4)                
                                        
   // ----------
   // IDLE/ARBFF
   // ----------

   assign d20_4_in_1    = (rx_word1[9:0]==`D20_4_N)  | (rx_word1[9:0]==`D20_4_P);

   assign d21_5_in_23   = ((rx_word2[9:0]==`D21_5_N) | (rx_word2[9:0]==`D21_5_P)) & 
                          ((rx_word3[9:0]==`D21_5_N) | (rx_word3[9:0]==`D21_5_P));

   assign d31_7_in_23   = ((rx_word2[9:0]==`D31_7_N) | (rx_word2[9:0]==`D31_7_P)) & 
                          ((rx_word3[9:0]==`D31_7_N) | (rx_word3[9:0]==`D31_7_P));

   assign idle = (comma_in_0 & ((d21_4_in_1 & d21_5_in_23) |
                                (d20_4_in_1 & d31_7_in_23)));



   // ------
   // NOS
   // ------

   assign d21_2_in_1    = (rx_word1[9:0]==`D21_2_N) | (rx_word1[9:0]==`D21_2_P);

   assign d31_5_in_2    = (rx_word2[9:0]==`D31_5_N) | (rx_word2[9:0]==`D31_5_P);

   assign d5_2_in_3     = (rx_word3[9:0]==`D5_2_N)  | (rx_word3[9:0]==`D5_2_P);

   assign nos           = (comma_in_0 & d21_2_in_1 & d31_5_in_2 & d5_2_in_3);

   
   // ------
   // OLS
   // ------

   assign d21_1_in_1    = (rx_word1[9:0]==`D21_1_N) | (rx_word1[9:0]==`D21_1_P);

   assign d10_4_in_2    = (rx_word2[9:0]==`D10_4_N) | (rx_word2[9:0]==`D10_4_P);

   assign d21_2_in_3    = (rx_word3[9:0]==`D21_2_N) | (rx_word3[9:0]==`D21_2_P);

   assign ols           = (comma_in_0 & d21_1_in_1 & d10_4_in_2 & d21_2_in_3);


   // ------
   // LR
   // ------

   assign d9_2_in_1    = (rx_word1[9:0]==`D9_2_N) | (rx_word1[9:0]==`D9_2_P);

   assign d9_2_in_3    = (rx_word3[9:0]==`D9_2_N) | (rx_word3[9:0]==`D9_2_P);

   assign lr           = (comma_in_0 & d9_2_in_1 & d31_5_in_2 & d9_2_in_3);

   
   // ------
   // LRR
   // ------

   assign lrr           = (comma_in_0 & d21_1_in_1 & d31_5_in_2 & d9_2_in_3);

   
   
endmodule // vi_fc_dec_40b


