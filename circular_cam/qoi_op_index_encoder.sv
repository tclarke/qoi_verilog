// A module implementing QOI_OP_INDEX encoding.

module QoiOpIndexEncoder
	// COMPONENTS sets the number of image components,
	// typically 3 for RGB and 4 for RGBA.
	#(parameter COMPONENTS=4)
	// port declations
	// rst_n: active low reset
	// clk: the clock
	// pixel: the input pixel
	// pixel_valid: active high when pixel is valid
	// ostream: the output stream
	// wr_en: active high when ostream is valid
	(input rst_n,
	 input clk,
	 input [8*COMPONENTS-1:0] pixel,
	 input pixel_valid,
	 output reg [7:0] ostream,
	 output reg wr_en);

   wire [5:0] cam_output;

   assign cam_output = ostream[5:0];


   CircularCam cam (
      .rst_n (rst_n),
      .clk (clk),
      .inp (pixel),
      .rd_en (pixel_valid),
      .wr_en (1'b1),
      .index (cam_output),
      .index_valid (wr_en));

endmodule