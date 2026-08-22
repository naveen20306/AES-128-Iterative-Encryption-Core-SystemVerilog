`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: aes128_fsm
// Description: Control FSM for the iterative AES-128 datapath.
//
//              IDLE -> KEY_EXP -> ADD_KEY -> ROUND (x9) -> FINAL_ROUND -> DONE -> IDLE
//
// Outputs:
//   round_counter : index of the round key currently selected by the datapath
//                   (0 during ADD_KEY, 1..9 during ROUND, 10 during FINAL_ROUND)
//   final_round   : high while processing round 10 (skip MixColumns)
//   ld_key        : one-cycle pulse - capture plaintext ^ round_key[0] into state
//   do_round      : high while a round result should be captured into state
//   busy          : high whenever an encryption is in progress
//   done          : one-cycle pulse when ciphertext is valid
//////////////////////////////////////////////////////////////////////////////////
module aes128_fsm (
    input  logic       clk,
    input  logic       rst,
    input  logic       start,

    output logic [3:0] round_counter,
    output logic       final_round,
    output logic       ld_key,
    output logic       do_round,
    output logic       busy,
    output logic       done
);

    typedef enum logic [2:0] {
        IDLE,
        KEY_EXP,
        ADD_KEY,
        ROUND,
        FINAL_ROUND,
        DONE_ST
    } state_t;

    state_t state, next_state;
    logic [3:0] round_counter_reg;

    // ------------------------------------------------
    // State register
    // ------------------------------------------------
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    // ------------------------------------------------
    // Next-state logic
    // ------------------------------------------------
    always_comb begin
        next_state = state;
        case (state)
            IDLE: begin
                if (start) next_state = KEY_EXP;
                else       next_state = IDLE;
            end
            KEY_EXP:     next_state = ADD_KEY;
            ADD_KEY:     next_state = ROUND;
            ROUND: begin
                if (round_counter_reg == 4'd9) next_state = FINAL_ROUND;
                else                           next_state = ROUND;
            end
            FINAL_ROUND: next_state = DONE_ST;
            DONE_ST:     next_state = IDLE;
            default:     next_state = IDLE;
        endcase
    end

    // ------------------------------------------------
    // Round counter register
    // ------------------------------------------------
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            round_counter_reg <= 4'd0;
        else if (state == ADD_KEY)
            round_counter_reg <= 4'd1;          // next round will be round 1
        else if (state == ROUND)
            round_counter_reg <= round_counter_reg + 4'd1;
        else if (state == IDLE)
            round_counter_reg <= 4'd0;
    end

    // ------------------------------------------------
    // Output logic
    // ------------------------------------------------
    assign round_counter = (state == ADD_KEY) ? 4'd0 : round_counter_reg;
    assign final_round   = (state == FINAL_ROUND);
    assign ld_key         = (state == ADD_KEY);
    assign do_round       = (state == ROUND) || (state == FINAL_ROUND);
    assign busy           = (state != IDLE);
    assign done           = (state == DONE_ST);

endmodule
