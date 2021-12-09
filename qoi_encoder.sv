// Top level QOI encoder

module QoiEncoder
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
	 output reg ostream_valid);

         wire [7:0] qoiOpIndexData;
         wire [7:0] qoiOpRgbaData;
         logic qoiOpIndexValid;
         logic qoiOpRgbaValid;

         QoiOpIndexEncoder qoiOpIndexEncoder(rst_n, clk, pixel, pixel_valid, qoiOpIndexData, qoiOpIndexValid);
         FullPixelEncoder qoiOpRgbaEncodcer(rst_n, clk, pixel, pixel_valid, qoiOpRgbaData, qoiOpRgbaValid);

         always @(posedge clk) begin
                 if (qoiOpIndexValid == 1'b1) begin
                         ostream_valid = 1'b1;
                         ostream = qoiOpIndexData;
                 end
                 else if (qoiOpRgbaValid) begin
                         ostream_valid = 1'b1;
                         ostream = qoiOpRgbaValid;
                 end
                 else begin
                         ostream_valid = 1'b0;
                         ostream = 8'bX;
                 end
         end

endmodule