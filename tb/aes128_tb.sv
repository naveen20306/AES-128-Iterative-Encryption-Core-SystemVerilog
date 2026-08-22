`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: aes128_tb
// Description: Main testbench for aes128_top. Applies the NIST FIPS-197
//              AES-128 example vector and checks the resulting ciphertext,
//              then runs a couple of extra vectors back-to-back.
//////////////////////////////////////////////////////////////////////////////////
module aes128_tb;

    logic         clk;
    logic         rst;
    logic         start;
    logic [127:0] plaintext;
    logic [127:0] key;
    logic [127:0] ciphertext;
    logic         busy;
    logic         done;

    int errors = 0;
    int tests   = 0;

    // ------------------------------------------------
    // DUT
    // ------------------------------------------------
    aes128_top dut (
        .clk        (clk),
        .rst        (rst),
        .start      (start),
        .plaintext  (plaintext),
        .key        (key),
        .ciphertext (ciphertext),
        .busy       (busy),
        .done       (done)
    );

    // ------------------------------------------------
    // Clock generation: 10 ns period
    // ------------------------------------------------
    initial clk = 0;
    always #5 clk = ~clk;

    // ------------------------------------------------
    // Task: run one encryption and check the result
    // ------------------------------------------------
    task automatic run_test(
        input [127:0] pt,
        input [127:0] k,
        input [127:0] expected_ct,
        input string  name
    );
        tests++;

        plaintext = pt;
        key       = k;
        start     = 1'b1;
        @(posedge clk);
        start     = 1'b0;

        // Wait for the FSM to signal completion
        wait (done == 1'b1);
        @(negedge clk);

        if (ciphertext === expected_ct) begin
            $display("[PASS] %-24s ciphertext = %032h", name, ciphertext);
        end else begin
            $display("[FAIL] %-24s got = %032h  expected = %032h",
                      name, ciphertext, expected_ct);
            errors++;
        end

        // Return to IDLE before the next test
        @(posedge clk);
    endtask

    // ------------------------------------------------
    // Stimulus
    // ------------------------------------------------
    initial begin
        rst   = 1'b1;
        start = 1'b0;
        plaintext = '0;
        key       = '0;

        repeat (3) @(posedge clk);
        rst = 1'b0;
        @(posedge clk);

        // -------------------------------------------------
        // Test 1: FIPS-197 Appendix B example vector
        //   Plaintext : 00112233445566778899AABBCCDDEEFF
        //   Key       : 000102030405060708090A0B0C0D0E0F
        //   Ciphertext: 69C4E0D86A7B0430D8CDB78070B4C55A
        // -------------------------------------------------
        run_test(
            128'h00112233445566778899AABBCCDDEEFF,
            128'h000102030405060708090A0B0C0D0E0F,
            128'h69C4E0D86A7B0430D8CDB78070B4C55A,
            "FIPS-197 vector"
        );

        // -------------------------------------------------
        // Test 2: all-zero plaintext and key
        //   (well-known reference result for AES-128)
        // -------------------------------------------------
        run_test(
            128'h00000000000000000000000000000000,
            128'h00000000000000000000000000000000,
            128'h66E94BD4EF8A2C3B884CFA59CA342B2E,
            "All-zero vector"
        );

        // -------------------------------------------------
        // Test 3: all-zero plaintext, all-one key
        // -------------------------------------------------
        run_test(
            128'h00000000000000000000000000000000,
            128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,
            128'hA1F6258C877D5FCD8964484538BFC92C,
            "Zero PT / all-1 key"
        );

        $display("--------------------------------------------------");
        if (errors == 0)
            $display("ALL %0d TESTS PASSED", tests);
        else
            $display("%0d OF %0d TESTS FAILED", errors, tests);
        $display("--------------------------------------------------");

        $finish;
    end

    // Safety timeout in case done never asserts
    initial begin
        #100000;
        $display("[TIMEOUT] Simulation did not finish in time.");
        $finish;
    end

endmodule