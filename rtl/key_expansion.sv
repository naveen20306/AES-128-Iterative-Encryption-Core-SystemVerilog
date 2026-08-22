`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: key_expansion
// Description: AES-128 key schedule. Expands a 128-bit cipher key into 11
//              128-bit round keys (round_keys[0] .. round_keys[10]).
//              Combinational: round_keys settle shortly after `key` changes.
//////////////////////////////////////////////////////////////////////////////////
module key_expansion (
    input  logic [127:0] key,
    output logic [127:0] round_keys [0:10]
);

    // 44 x 32-bit words: w[0..3] = original key, w[4..43] = expanded
    logic [31:0] w [0:43];

    // Rcon values for AES-128 (rounds 1..10)
    logic [7:0] rcon [1:10];
    assign rcon[1]  = 8'h01;
    assign rcon[2]  = 8'h02;
    assign rcon[3]  = 8'h04;
    assign rcon[4]  = 8'h08;
    assign rcon[5]  = 8'h10;
    assign rcon[6]  = 8'h20;
    assign rcon[7]  = 8'h40;
    assign rcon[8]  = 8'h80;
    assign rcon[9]  = 8'h1B;
    assign rcon[10] = 8'h36;

    // Initial words come straight from the key
    assign w[0] = key[127:96];
    assign w[1] = key[95:64];
    assign w[2] = key[63:32];
    assign w[3] = key[31:0];

    genvar r;
    generate
        for (r = 1; r <= 10; r = r + 1) begin : key_sched

            logic [31:0] rot_word;
            logic [31:0] sub_word;
            logic [31:0] temp;

            logic [7:0] sub_byte0, sub_byte1, sub_byte2, sub_byte3;

            // RotWord: rotate the previous word left by one byte
            assign rot_word = { w[4*r-1][23:0], w[4*r-1][31:24] };

            // SubWord: apply the AES S-box to every byte of the rotated word
            sbox sb0 (.in(rot_word[31:24]), .out(sub_byte0));
            sbox sb1 (.in(rot_word[23:16]), .out(sub_byte1));
            sbox sb2 (.in(rot_word[15:8]),  .out(sub_byte2));
            sbox sb3 (.in(rot_word[7:0]),   .out(sub_byte3));

            assign sub_word = { sub_byte0, sub_byte1, sub_byte2, sub_byte3 };

            // XOR with Rcon (only the top byte is non-zero)
            assign temp = sub_word ^ { rcon[r], 24'h000000 };

            // Word expansion for this round
            assign w[4*r]   = w[4*r-4] ^ temp;
            assign w[4*r+1] = w[4*r-3] ^ w[4*r];
            assign w[4*r+2] = w[4*r-2] ^ w[4*r+1];
            assign w[4*r+3] = w[4*r-1] ^ w[4*r+2];

        end
    endgenerate

    // Pack every 4 words into a 128-bit round key
    genvar k;
    generate
        for (k = 0; k <= 10; k = k + 1) begin : round_key_gen
            assign round_keys[k] = { w[4*k], w[4*k+1], w[4*k+2], w[4*k+3] };
        end
    endgenerate

endmodule
