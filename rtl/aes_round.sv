`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: aes_round
// Description: One AES round: SubBytes -> ShiftRows -> (MixColumns) -> AddRoundKey.
//              MixColumns is skipped when final_round = 1 (round 10).
//////////////////////////////////////////////////////////////////////////////////
module aes_round (
    input  wire  [7:0] state_in   [0:15],
    input  wire  [7:0] round_key  [0:15],
    input  logic       final_round,
    output wire  [7:0] state_out  [0:15]
);

    wire  [7:0] sub_out   [0:15];
    wire  [7:0] shift_out [0:15];
    wire  [7:0] mix_out   [0:15];
    wire  [7:0] pre_key   [0:15];

    sub_bytes u_sub_bytes (
        .state_in  (state_in),
        .state_out (sub_out)
    );

    shift_rows u_shift_rows (
        .state_in  (sub_out),
        .state_out (shift_out)
    );

    mix_columns u_mix_columns (
        .state_in  (shift_out),
        .state_out (mix_out)
    );

    // Final round skips MixColumns
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : final_mux
            assign pre_key[i] = final_round ? shift_out[i] : mix_out[i];
        end
    endgenerate

    add_round_key u_add_round_key (
        .state_in  (pre_key),
        .round_key (round_key),
        .state_out (state_out)
    );

endmodule
