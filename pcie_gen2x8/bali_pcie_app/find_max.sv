module find_max (
  input clk,
  input rst_n,
  input start,
  input stop,
  input rst_count,
  output reg [31:0] max_count
);
  localparam SM_WIDTH = 1;
  localparam SM_WAITSTART = 0;
  localparam SM_WAITSTOP = 1; 


  reg [31:0] curr_count;
  reg [31:0] local_max;


  /* count clocks between start and stop */
  always @(posedge clk)
    if (!rst_n || rst_count || stop)
      curr_count <= 'h0;
    else 
      curr_count <= curr_count + (start & ~stop);

  /* track max start-stop count between latch events */
  always @(posedge clk)
    if (!rst_n || rst_count)
      local_max <= 'h0;
    else if (stop && (curr_count > local_max))
      local_max <= curr_count; 

  /* latch running max at latch event */
  always @(posedge clk)
    if (!rst_n)
      max_count <= 'h0;
    else if (rst_count)
      max_count <= local_max;

endmodule
