`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: add_round_key
// Description: XORs the state with the round key, byte by byte.
//////////////////////////////////////////////////////////////////////////////////
module add_round_key (
    input  logic [7:0] state_in  [0:15],
    input  logic [7:0] round_key [0:15],
    output logic [7:0] state_out [0:15]
);

    integer i;
    always_comb begin
        for (i = 0; i < 16; i = i + 1) begin
            state_out[i] = state_in[i] ^ round_key[i];
        end
    end

endmodule
