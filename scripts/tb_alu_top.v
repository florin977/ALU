`timescale 1ns/1ps

module tb_alu_top;

    localparam OP_ADD = 2'b00;
    localparam OP_SUB = 2'b01;
    localparam OP_MUL = 2'b10;
    localparam OP_DIV = 2'b11;

    reg        clk;
    reg        rst;
    reg        start;
    reg  [1:0] opcode;
    reg  [7:0] a_in;
    reg  [7:0] b_in;

    wire [15:0] out_put;
    wire [8:0] a;
    wire [7:0] q;
    wire [7:0] m;
    wire       q_1;
    wire [8:0] adder_result;
    wire [8:0] a_shifted;
    wire [7:0] q_shifted;
    wire [1:0] cu_signal;
    wire [1:0] select_m;
    wire       sub;
    wire       end_flag;
    wire       target_reached;
    wire       we_a;
    wire       we_q;
    wire       we_m;
    wire       we_out;
    wire [1:0] fsm_state;
    wire [8:0] final_a;
    wire [7:0] final_q;

    integer errors;

    alu_top dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .opcode(opcode),
        .a_in(a_in),
        .b_in(b_in),
        .out_put(out_put),
        .a(a),
        .q(q),
        .m(m),
        .q_1(q_1),
        .adder_result(adder_result),
        .a_shifted(a_shifted),
        .q_shifted(q_shifted),
        .cu_signal(cu_signal),
        .select_m(select_m),
        .sub(sub),
        .end_flag(end_flag),
        .target_reached(target_reached),
        .we_a(we_a),
        .we_q(we_q),
        .we_m(we_m),
        .we_out(we_out),
        .fsm_state(fsm_state),
        .final_a(final_a),
        .final_q(final_q)
    );

    initial begin
        $dumpfile("tb_alu_top.vcd");
        $dumpvars(0, tb_alu_top);
        $display("GTKWave VCD: tb_alu_top.vcd");
    end

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    task reset_dut;
        begin
            rst = 1'b1;
            start = 1'b0;
            opcode = OP_ADD;
            a_in = 8'd0;
            b_in = 8'd0;
            repeat (2) @(posedge clk);
            rst = 1'b0;
            @(posedge clk);
        end
    endtask

    task run_operation;
        input [1:0] op;
        input [7:0] lhs;
        input [7:0] rhs;
        integer guard;
        begin
            opcode = op;
            a_in = lhs;
            b_in = rhs;

            @(negedge clk);
            start = 1'b1;
            @(negedge clk);
            start = 1'b0;

            guard = 0;
            while (!end_flag && guard < 32) begin
                @(posedge clk);
                guard = guard + 1;
            end

            if (guard == 32) begin
                $display("ERROR: timeout op=%b lhs=%0d rhs=%0d", op, lhs, rhs);
                errors = errors + 1;
            end

            @(posedge clk);
        end
    endtask

    task expect_add;
        input [7:0] lhs;
        input [7:0] rhs;
        reg [8:0] expected;
        reg [15:0] expected_out;
        begin
            reset_dut();
            run_operation(OP_ADD, lhs, rhs);
            expected = {1'b0, lhs} + {1'b0, rhs};
            expected_out = {{7{expected[8]}}, expected};
            if (a !== expected) begin
                $display("ERROR ADD: %0d + %0d expected A=%0d got A=%0d", lhs, rhs, expected, a);
                errors = errors + 1;
            end else if (out_put !== expected_out) begin
                $display("ERROR ADD OUT: %0d + %0d expected OUT=%0d got OUT=%0d", lhs, rhs, expected_out, out_put);
                errors = errors + 1;
            end else begin
                $display("PASS ADD: %0d + %0d = %0d OUT=%0d", lhs, rhs, a, out_put);
            end
        end
    endtask

    task expect_sub;
        input [7:0] lhs;
        input [7:0] rhs;
        reg signed [8:0] expected;
        reg signed [15:0] expected_out;
        begin
            reset_dut();
            run_operation(OP_SUB, lhs, rhs);
            expected = $signed({1'b0, lhs}) - $signed({1'b0, rhs});
            expected_out = {{7{expected[8]}}, expected};
            if ($signed(a) !== expected) begin
                $display("ERROR SUB: %0d - %0d expected A=%0d got A=%0d", lhs, rhs, expected, $signed(a));
                errors = errors + 1;
            end else if ($signed(out_put) !== expected_out) begin
                $display("ERROR SUB OUT: %0d - %0d expected OUT=%0d got OUT=%0d", lhs, rhs, expected_out, $signed(out_put));
                errors = errors + 1;
            end else begin
                $display("PASS SUB: %0d - %0d = %0d OUT=%0d", lhs, rhs, $signed(a), $signed(out_put));
            end
        end
    endtask

    task expect_mul;
        input signed [7:0] lhs;
        input signed [7:0] rhs;
        reg signed [15:0] expected;
        reg signed [16:0] actual;
        begin
            reset_dut();
            run_operation(OP_MUL, lhs[7:0], rhs[7:0]);
            expected = lhs * rhs;
            actual = {a, q};
            if (actual[15:0] !== expected) begin
                $display("ERROR MUL: %0d * %0d expected AQ=%0d got AQ=%0d A=%b Q=%b", lhs, rhs, expected, actual[15:0], a, q);
                errors = errors + 1;
            end else if (out_put !== expected[15:0]) begin
                $display("ERROR MUL OUT: %0d * %0d expected OUT=%0d got OUT=%0d", lhs, rhs, expected, $signed(out_put));
                errors = errors + 1;
            end else begin
                $display("PASS MUL: %0d * %0d = %0d OUT=%0d", lhs, rhs, actual[15:0], $signed(out_put));
            end
        end
    endtask

    task expect_div;
        input [7:0] dividend;
        input [7:0] divisor;
        reg [7:0] expected_q;
        reg [7:0] expected_r;
        begin
            reset_dut();
            run_operation(OP_DIV, dividend, divisor);
            expected_q = dividend / divisor;
            expected_r = dividend % divisor;
            if (q !== expected_q) begin
                $display("ERROR DIV: %0d / %0d expected Q=%0d got Q=%0d A=%0d", dividend, divisor, expected_q, q, a);
                errors = errors + 1;
            end else if (out_put !== {expected_r, expected_q}) begin
                $display("ERROR DIV OUT: %0d / %0d expected OUT={R=%0d,Q=%0d} got OUT=%h", dividend, divisor, expected_r, expected_q, out_put);
                errors = errors + 1;
            end else begin
                $display("PASS DIV: %0d / %0d quotient=%0d remainder=%0d OUT=%h", dividend, divisor, q, final_a[7:0], out_put);
            end
        end
    endtask

    initial begin
        errors = 0;
        reset_dut();

        expect_add(8'd25, 8'd17);
        expect_add(8'd200, 8'd55);

        expect_sub(8'd90, 8'd12);
        expect_sub(8'd12, 8'd90);

        expect_mul(8'sd7, 8'sd6);
        expect_mul(-8'sd5, 8'sd9);

        expect_div(8'd84, 8'd7);
        expect_div(8'd100, 8'd10);

        if (errors == 0) begin
            $display("ALL TESTS PASSED");
        end else begin
            $display("TESTS FAILED: %0d error(s)", errors);
        end

        $finish;
    end

endmodule
