`timescale 1ns/1ps

module alu_datapath (
    input  wire       clk,
    input  wire       rst,
    input  wire [1:0] opcode,
    input  wire [7:0] a_in,
    input  wire [7:0] b_in,
    input  wire [1:0] cu_signal,
    input  wire       we_a,
    input  wire       we_q,
    input  wire       we_m,
    output wire [8:0] a,
    output wire [7:0] q,
    output wire [7:0] m,
    output wire       q_1,
    output wire [8:0] adder_result,
    output wire [8:0] a_shifted,
    output wire [7:0] q_shifted,
    output wire [1:0] select_m,
    output wire       sub,
    output wire       not_a8
);

    wire [8:0] a_next;
    wire [7:0] q_next;
    wire [7:0] m_next;
    wire       q_1_next;

    wire [1:0] booth_select_m;
    wire       booth_sub;

    wire [8:0] m_ext;
    wire [8:0] two_m;
    wire [8:0] selected_m;
    wire [8:0] selected_m_xor_sub;
    wire       adder_cout;

    wire [8:0] alu_in_a;
    wire [8:0] q_ext;
    wire [8:0] srt2_pre_shift_a;
    wire [8:0] booth_a;
    wire [7:0] booth_q;
    wire [7:0] srt2_q;

    assign not_a8 = ~a[8];

    register_param #(
        .WIDTH(9),
        .RESET_VALUE(9'b0)
    ) a_reg (
        .clk(clk),
        .rst(rst),
        .we(we_a),
        .d(a_next),
        .q(a)
    );

    register_param #(
        .WIDTH(8),
        .RESET_VALUE(8'b0)
    ) q_reg (
        .clk(clk),
        .rst(rst),
        .we(we_q),
        .d(q_next),
        .q(q)
    );

    register_param #(
        .WIDTH(8),
        .RESET_VALUE(8'b0)
    ) m_reg (
        .clk(clk),
        .rst(rst),
        .we(we_m),
        .d(m_next),
        .q(m)
    );

    register_param #(
        .WIDTH(1),
        .RESET_VALUE(1'b0)
    ) q_1_reg (
        .clk(clk),
        .rst(rst),
        .we(we_q),
        .d(q_1_next),
        .q(q_1)
    );

    mux4_param #(.WIDTH(9)) a_input_mux (
        .in0(a),
        .in1(9'b0),
        .in2(a),
        .in3(a_shifted),
        .sel(cu_signal),
        .out(a_next)
    );

    mux4_param #(.WIDTH(8)) q_input_mux (
        .in0(q),
        .in1(a_in),
        .in2(q),
        .in3(q_shifted),
        .sel(cu_signal),
        .out(q_next)
    );

    mux4_param #(.WIDTH(8)) m_input_mux (
        .in0(m),
        .in1(b_in),
        .in2(m),
        .in3(m),
        .sel(cu_signal),
        .out(m_next)
    );

    mux4_param #(.WIDTH(1)) q_1_input_mux (
        .in0(q_1),
        .in1(1'b0),
        .in2(q_1),
        .in3(q[1]),
        .sel(cu_signal),
        .out(q_1_next)
    );

    booth_radix4_control booth_control (
        .q1(q[1]),
        .q0(q[0]),
        .q_1(q_1),
        .select_m(booth_select_m),
        .sub(booth_sub)
    );

    mux4_param #(.WIDTH(2)) select_m_mux (
        .in0(2'b01),
        .in1(2'b01),
        .in2(booth_select_m),
        .in3(2'b01),
        .sel(opcode),
        .out(select_m)
    );

    mux4_param #(.WIDTH(1)) sub_mux (
        .in0(1'b0),
        .in1(1'b1),
        .in2(booth_sub),
        .in3(not_a8),
        .sel(opcode),
        .out(sub)
    );

    assign m_ext = {m[7], m};

    shifter_param #(
        .WIDTH(9),
        .AMOUNT_WIDTH(4)
    ) two_m_shifter (
        .data_in(m_ext),
        .shift_amount(4'd1),
        .op(2'b01),
        .data_out(two_m)
    );

    mux4_param #(.WIDTH(9)) selected_m_mux (
        .in0(9'b0),
        .in1(m_ext),
        .in2(two_m),
        .in3(9'b0),
        .sel(select_m),
        .out(selected_m)
    );

    assign selected_m_xor_sub = selected_m ^ {9{sub}};

    assign q_ext = {1'b0, q};
    assign srt2_pre_shift_a = {a[7:0], q[7]};

    mux4_param #(.WIDTH(9)) alu_in_a_mux (
        .in0(q_ext),
        .in1(q_ext),
        .in2(a),
        .in3(srt2_pre_shift_a),
        .sel(opcode),
        .out(alu_in_a)
    );

    parallel_adder_9bit adder (
        .a(alu_in_a),
        .b(selected_m_xor_sub),
        .cin(sub),
        .sum(adder_result),
        .cout(adder_cout)
    );

    shifter_param #(
        .WIDTH(9),
        .AMOUNT_WIDTH(4)
    ) booth_a_shifter (
        .data_in(adder_result),
        .shift_amount(4'd2),
        .op(2'b11),
        .data_out(booth_a)
    );

    assign booth_q = {adder_result[1:0], q[7:2]};
    assign srt2_q = {q[6:0], ~adder_result[8]};

    mux4_param #(.WIDTH(9)) a_shifted_mux (
        .in0(adder_result),
        .in1(adder_result),
        .in2(booth_a),
        .in3(adder_result),
        .sel(opcode),
        .out(a_shifted)
    );

    mux4_param #(.WIDTH(8)) q_shifted_mux (
        .in0(q),
        .in1(q),
        .in2(booth_q),
        .in3(srt2_q),
        .sel(opcode),
        .out(q_shifted)
    );

endmodule
