`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: gf_mul
// Description: GF(2^8) multiplication by 02 (xtime) and by 03, used by MixColumns.
//////////////////////////////////////////////////////////////////////////////////
module gf_mul (
    input  logic [7:0] a,
    output logic [7:0] mul2,
    output logic [7:0] mul3
);

    // Multiply by 02: shift left, XOR with 0x1B if MSB was 1
    function automatic logic [7:0] xtime(input logic [7:0] in);
        xtime = in[7] ? ((in << 1) ^ 8'h1B) : (in << 1);
    endfunction

    assign mul2 = xtime(a);
    assign mul3 = xtime(a) ^ a;

endmodule
