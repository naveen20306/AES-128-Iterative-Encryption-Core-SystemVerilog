`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: aes128_top
// Description: Top-level iterative AES-128 encryption core.
//////////////////////////////////////////////////////////////////////////////////
module aes128_top (
    input  logic         clk,
    input  logic         rst,
    input  logic         start,

    input  logic [127:0] plaintext,
    input  logic [127:0] key,

    output logic [127:0] ciphertext,
    output logic         busy,
    output logic         done
);

    // ------------------------------------------------
    // Internal state (16 bytes), byte 0 = MSB of the block
    // ------------------------------------------------
    logic [7:0] state_reg        [0:15];
    wire  [7:0] next_state_bytes [0:15];

    wire  [127:0] round_keys [0:10];
    logic [3:0]   round_counter;
    logic         final_round;
    logic         ld_key;
    logic         do_round;

    logic [7:0] plaintext_bytes [0:15];
    logic [7:0] round_key_bytes [0:15];

    // ------------------------------------------------
    // Split 128-bit vectors into byte arrays (byte 0 = bits [127:120])
    // ------------------------------------------------
    genvar gi;
    generate
        for (gi = 0; gi < 16; gi = gi + 1) begin : byte_split
            assign plaintext_bytes[gi] = plaintext[127 - gi*8 -: 8];
            assign round_key_bytes[gi] = round_keys[round_counter][127 - gi*8 -: 8];
        end
    endgenerate

    // ------------------------------------------------
    // Key expansion (combinational: all 11 round keys)
    // ------------------------------------------------
    key_expansion u_key_expansion (
        .key        (key),
        .round_keys (round_keys)
    );

    // ------------------------------------------------
    // AES datapath: one round of hardware, reused every cycle
    // ------------------------------------------------
    aes_round u_aes_round (
        .state_in    (state_reg),
        .round_key   (round_key_bytes),
        .final_round (final_round),
        .state_out   (next_state_bytes)
    );

    // ------------------------------------------------
    // Control FSM
    // ------------------------------------------------
    aes128_fsm u_fsm (
        .clk           (clk),
        .rst           (rst),
        .start         (start),
        .round_counter (round_counter),
        .final_round   (final_round),
        .ld_key        (ld_key),
        .do_round      (do_round),
        .busy          (busy),
        .done          (done)
    );

    // ------------------------------------------------
    // State register update
    // ------------------------------------------------
    integer i;
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 16; i = i + 1)
                state_reg[i] <= 8'h00;
        end else if (ld_key) begin
            // Initial AddRoundKey: state = plaintext XOR round_key[0]
            for (i = 0; i < 16; i = i + 1)
                state_reg[i] <= plaintext_bytes[i] ^ round_key_bytes[i];
        end else if (do_round) begin
            // Capture the result of the round just computed
            for (i = 0; i < 16; i = i + 1)
                state_reg[i] <= next_state_bytes[i];
        end
    end

    // ------------------------------------------------
    // Pack state back into the 128-bit ciphertext output
    // ------------------------------------------------
    generate
        for (gi = 0; gi < 16; gi = gi + 1) begin : cipher_pack
            assign ciphertext[127 - gi*8 -: 8] = state_reg[gi];
        end
    endgenerate

endmodule
