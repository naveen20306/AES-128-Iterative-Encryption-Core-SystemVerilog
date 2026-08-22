`timescale 1ns / 1ps

module mix_columns (
    input  logic [7:0] state_in  [0:15],
    output logic [7:0] state_out [0:15]
);

    // ------------------------------------------------
    // Column 0
    // ------------------------------------------------
    logic [7:0] c0_mul2_a;
    logic [7:0] c0_mul3_a;
    logic [7:0] c0_mul2_b;
    logic [7:0] c0_mul3_b;
    logic [7:0] c0_mul2_c;
    logic [7:0] c0_mul3_c;
    logic [7:0] c0_mul2_d;
    logic [7:0] c0_mul3_d;

    // ------------------------------------------------
    // Column 1
    // ------------------------------------------------
    logic [7:0] c1_mul2_a;
    logic [7:0] c1_mul3_a;
    logic [7:0] c1_mul2_b;
    logic [7:0] c1_mul3_b;
    logic [7:0] c1_mul2_c;
    logic [7:0] c1_mul3_c;
    logic [7:0] c1_mul2_d;
    logic [7:0] c1_mul3_d;

    // ------------------------------------------------
    // Column 2
    // ------------------------------------------------
    logic [7:0] c2_mul2_a;
    logic [7:0] c2_mul3_a;
    logic [7:0] c2_mul2_b;
    logic [7:0] c2_mul3_b;
    logic [7:0] c2_mul2_c;
    logic [7:0] c2_mul3_c;
    logic [7:0] c2_mul2_d;
    logic [7:0] c2_mul3_d;

    // ------------------------------------------------
    // Column 3
    // ------------------------------------------------
    logic [7:0] c3_mul2_a;
    logic [7:0] c3_mul3_a;
    logic [7:0] c3_mul2_b;
    logic [7:0] c3_mul3_b;
    logic [7:0] c3_mul2_c;
    logic [7:0] c3_mul3_c;
    logic [7:0] c3_mul2_d;
    logic [7:0] c3_mul3_d;


    // =================================================
    // GF multipliers - Column 0
    // =================================================

    gf_mul gf_c0_a (
        .a    (state_in[0]),
        .mul2 (c0_mul2_a),
        .mul3 (c0_mul3_a)
    );

    gf_mul gf_c0_b (
        .a    (state_in[1]),
        .mul2 (c0_mul2_b),
        .mul3 (c0_mul3_b)
    );

    gf_mul gf_c0_c (
        .a    (state_in[2]),
        .mul2 (c0_mul2_c),
        .mul3 (c0_mul3_c)
    );

    gf_mul gf_c0_d (
        .a    (state_in[3]),
        .mul2 (c0_mul2_d),
        .mul3 (c0_mul3_d)
    );


    // =================================================
    // GF multipliers - Column 1
    // =================================================

    gf_mul gf_c1_a (
        .a    (state_in[4]),
        .mul2 (c1_mul2_a),
        .mul3 (c1_mul3_a)
    );

    gf_mul gf_c1_b (
        .a    (state_in[5]),
        .mul2 (c1_mul2_b),
        .mul3 (c1_mul3_b)
    );

    gf_mul gf_c1_c (
        .a    (state_in[6]),
        .mul2 (c1_mul2_c),
        .mul3 (c1_mul3_c)
    );

    gf_mul gf_c1_d (
        .a    (state_in[7]),
        .mul2 (c1_mul2_d),
        .mul3 (c1_mul3_d)
    );


    // =================================================
    // GF multipliers - Column 2
    // =================================================

    gf_mul gf_c2_a (
        .a    (state_in[8]),
        .mul2 (c2_mul2_a),
        .mul3 (c2_mul3_a)
    );

    gf_mul gf_c2_b (
        .a    (state_in[9]),
        .mul2 (c2_mul2_b),
        .mul3 (c2_mul3_b)
    );

    gf_mul gf_c2_c (
        .a    (state_in[10]),
        .mul2 (c2_mul2_c),
        .mul3 (c2_mul3_c)
    );

    gf_mul gf_c2_d (
        .a    (state_in[11]),
        .mul2 (c2_mul2_d),
        .mul3 (c2_mul3_d)
    );


    // =================================================
    // GF multipliers - Column 3
    // =================================================

    gf_mul gf_c3_a (
        .a    (state_in[12]),
        .mul2 (c3_mul2_a),
        .mul3 (c3_mul3_a)
    );

    gf_mul gf_c3_b (
        .a    (state_in[13]),
        .mul2 (c3_mul2_b),
        .mul3 (c3_mul3_b)
    );

    gf_mul gf_c3_c (
        .a    (state_in[14]),
        .mul2 (c3_mul2_c),
        .mul3 (c3_mul3_c)
    );

    gf_mul gf_c3_d (
        .a    (state_in[15]),
        .mul2 (c3_mul2_d),
        .mul3 (c3_mul3_d)
    );


    // =================================================
    // MixColumns
    // =================================================

    always_comb begin

        // Column 0: a=state[0] b=state[1] c=state[2] d=state[3]
        state_out[0] = c0_mul2_a ^ c0_mul3_b ^ state_in[2] ^ state_in[3];
        state_out[1] = state_in[0] ^ c0_mul2_b ^ c0_mul3_c ^ state_in[3];
        state_out[2] = state_in[0] ^ state_in[1] ^ c0_mul2_c ^ c0_mul3_d;
        state_out[3] = c0_mul3_a ^ state_in[1] ^ state_in[2] ^ c0_mul2_d;

        // Column 1
        state_out[4] = c1_mul2_a ^ c1_mul3_b ^ state_in[6] ^ state_in[7];
        state_out[5] = state_in[4] ^ c1_mul2_b ^ c1_mul3_c ^ state_in[7];
        state_out[6] = state_in[4] ^ state_in[5] ^ c1_mul2_c ^ c1_mul3_d;
        state_out[7] = c1_mul3_a ^ state_in[5] ^ state_in[6] ^ c1_mul2_d;

        // Column 2
        state_out[8]  = c2_mul2_a ^ c2_mul3_b ^ state_in[10] ^ state_in[11];
        state_out[9]  = state_in[8] ^ c2_mul2_b ^ c2_mul3_c ^ state_in[11];
        state_out[10] = state_in[8] ^ state_in[9] ^ c2_mul2_c ^ c2_mul3_d;
        state_out[11] = c2_mul3_a ^ state_in[9] ^ state_in[10] ^ c2_mul2_d;

        // Column 3
        state_out[12] = c3_mul2_a ^ c3_mul3_b ^ state_in[14] ^ state_in[15];
        state_out[13] = state_in[12] ^ c3_mul2_b ^ c3_mul3_c ^ state_in[15];
        state_out[14] = state_in[12] ^ state_in[13] ^ c3_mul2_c ^ c3_mul3_d;
        state_out[15] = c3_mul3_a ^ state_in[13] ^ state_in[14] ^ c3_mul2_d;

    end

endmodule
