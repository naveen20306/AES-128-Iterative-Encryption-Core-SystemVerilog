`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: sub_bytes
// Description: Applies the AES S-box independently to all 16 state bytes.
//////////////////////////////////////////////////////////////////////////////////
module sub_bytes (
    input  wire  [7:0] state_in  [0:15],
    output wire  [7:0] state_out [0:15]
);

    genvar i;
    generate
        for (i = 0; i <= 15; i = i + 1) begin : sub_bytes_gen
            sbox sbox_inst (
                .in  (state_in[i]),
                .out (state_out[i])
            );
        end
    endgenerate

endmodule
