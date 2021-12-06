// A  module implementing a circular buffer with CAM search capability.

module CircularCAM
        // parameters
        // BITS: the number of bits in the index. sets the memory depth as well
        // INP_WIDTH: the width in bits of the input
        #(parameter INP_BITS=24)
        // port declarations
        // rst_n: asynchronous reset
        // clk: the clock
        // inp: the input search data
        // rd_en: input search data is valid and a search will occur
        // wr_en: input data will be stored in the next available slot
        // index: the index of the input search data
        // index_valid: high if index is valid
        (input rst_n,
         input clk,
         input [INP_BITS-1:0] inp,
         input rd_en,
         input wr_en,
         output logic [5:0] index,
         output logic index_valid);
        
        reg [INP_BITS-1:0] buffer[64];
        reg [5:0] next;

        initial begin
                $display("Circular CAM");
                $display("  INP_BITS=%d", INP_BITS);
                next <= 0;
                index_valid <= 0;
                index <= 0;
                for (int i=0; i < 64; i=i+1) begin
                        buffer[i] <= 0;
                end
        end

        always_comb begin
                index_valid = 0;
                for (int i=0; i < 64; i=i+1) begin
                        if (rd_en) begin
                                if (inp == buffer[i]) begin
                                        index = i;
                                        index_valid = 1'b1;
                                end
                        end
                end
        end

        always @(posedge clk) begin
                if (rst_n == 1'b0) begin
                        next <= 0;
                        index <= 0;
                end else begin
                        if (wr_en == 1'b1) begin
                                buffer[next] = inp;
                                next = next + 1;
                        end
                end
        end

        `ifdef COCOTB_SIM
	initial begin
		$dumpfile ("circular_cam.vcd");
		$dumpvars (0, CircularCAM);
		#1;
	end
	`endif
endmodule