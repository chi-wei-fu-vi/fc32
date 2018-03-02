module txmux
#(
        parameter LINKS    =  12
)
(
        
        input   [1:0][71:0] txbist_data,
        input   [1:0]       txbist_data_val,
        
        output  [LINKS*2-1:0][63:0]  tx_blk,
        output  [LINKS*2-1:0][1:0]   tx_sh,
        output  [LINKS*2-1:0]        tx_val
);

genvar ii;
generate
for (ii=  0; ii<LINKS; ii      =  ii+1) begin : xbar
        
        /* Loopback/bist data mux.
 * Channels are divided into even/odd.  Even channels are connected to txbist engine 0.
 * Odd channels are connected to txbist engine 1.  Each individual channel has
 * far_end loopback control.
 */
        
                assign tx_blk[2*ii]   =   txbist_data[0][63:0];
                assign tx_sh[2*ii]    =   txbist_data[0][65:64];
                assign tx_val[2*ii]   =   txbist_data_val[0];
                assign tx_blk[2*ii+1] =   txbist_data[1][63:0];
                assign tx_sh[2*ii+1]  =   txbist_data[1][65:64];
                assign tx_val[2*ii+1] =   txbist_data_val[1];
        
end : xbar
endgenerate

endmodule
