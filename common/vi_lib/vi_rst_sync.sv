module vi_rst_sync
(
  input        iRST_ASYNC_N,
  input        iCLK, 
  output       oRST_SYNC_N        // connect to aclr of Altera ALM
);

logic [5:0] reset_ctr;
   
///////////////////////////////////////////////////////////////////////////////
//
// Reset control asserted asynchronously and de-asserted synchronously.
//
///////////////////////////////////////////////////////////////////////////////
always @(posedge iCLK or negedge iRST_ASYNC_N)
begin
  reset_ctr <= (!iRST_ASYNC_N) ? '0 : 
               (!reset_ctr[5]) ? reset_ctr + 1'b1 : 
                 reset_ctr;
end

assign oRST_SYNC_N = reset_ctr[5];


endmodule
