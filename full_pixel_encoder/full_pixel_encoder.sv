// A module which encodes a full pixel into the data stream.

module FullPixelEncoder
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

	reg [8*COMPONENTS-1:0] pixbuf;
	reg [6-1:0] state;
	localparam 
	  READPIX = 0,
	  WRITEHDR = 1,
	  WRITE4 = 2,
	  WRITE3 = 3,
	  WRITE2 = 4,
	  WRITE1 = 5,
	  WRITEEND = 6;

	always @(posedge clk) begin
		if (rst_n == 0) begin
			state = READPIX;
		end
		else begin
			case(state)
				READPIX:
				begin
					if (pixel_valid == 1) begin
						pixbuf <= pixel;
						state = WRITEHDR;
					end
				end
				WRITEHDR:
				begin
					ostream[7:4] = 4'b1111;
					ostream[3:0] = 4'b1110;
					if (COMPONENTS == 4) begin
						ostream[0] = 1'b1;
					end
					wr_en = 1;
					if (COMPONENTS == 4) begin
						state = WRITE4;
					end
					else if (COMPONENTS == 3) begin
						state = WRITE3;
					end
				end
				WRITE4:
				begin
					ostream[7:0] = pixel[31:24];
					state = WRITE3;
				end
				WRITE3:
				begin
					ostream[7:0] = pixel[23:16];
					state = WRITE2;
				end
				WRITE2:
				begin
					ostream[7:0] = pixel[15:8];
					state = WRITE1;
				end
				WRITE1:
				begin
					ostream[7:0] = pixel[7:0];
					state = WRITEEND;
				end
				WRITEEND:
				begin
					wr_en = 0;
					state = WRITEHDR;
				end
			endcase
		end
	end

	`ifdef COCOTB_SIM
	initial begin
		$dumpfile ("full_pixel_encoder.vcd");
		$dumpvars (0, FullPixelEncoder);
		#1;
	end
	`endif
endmodule