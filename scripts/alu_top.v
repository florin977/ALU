`timescale 1ns/1ps

module alu_top (
    input  wire       clk,
    input  wire       rst,
    input  wire       start,
    input  wire [1:0] opcode,
    input  wire [7:0] a_in,
    input  wire [7:0] b_in,
    output wire [8:0] a,
    output wire [7:0] q,
    output wire [7:0] m,
    output wire       q_1,
    output wire [8:0] adder_result,
    output wire [8:0] a_shifted,
    output wire [7:0] q_shifted,
    output wire [1:0] cu_signal,
    output wire [1:0] select_m,
    output wire       sub,
    output wire       end_flag,
    output wire       target_reached,
    output wire       we_a,
    output wire       we_q,
    output wire       we_m
);

    wire       counter_load;
    wire       counter_en;
    wire [3:0] counter_value;
    wire [3:0] counter_target;
    wire       s0;
    wire       s1;
    wire       not_s0;
    wire       not_s1;
    wire       not_a8;

    mux4_param #(.WIDTH(4)) target_mux (
        .in0(4'd0),
        .in1(4'd0),
        .in2(4'd3),
        .in3(4'd7),
        .sel(opcode),
        .out(counter_target)
    );

    assign target_reached = (counter_value == counter_target);

    alu_control_unit control_unit (
        .clk(clk),
        .rst(rst),
        .start(start),
        .target_reached(target_reached),
        .cu_signal(cu_signal),
        .we_a(we_a),
        .we_q(we_q),
        .we_m(we_m),
        .end_flag(end_flag),
        .counter_load(counter_load),
        .counter_en(counter_en),
        .s0(s0),
        .s1(s1),
        .not_s0(not_s0),
        .not_s1(not_s1)
    );

    counter_4bit loop_counter (
        .clk(clk),
        .rst(rst | counter_load),
        .en(counter_en),
        .count(counter_value)
    );

    alu_datapath datapath (
        .clk(clk),
        .rst(rst),
        .opcode(opcode),
        .a_in(a_in),
        .b_in(b_in),
        .cu_signal(cu_signal),
        .we_a(we_a),
        .we_q(we_q),
        .we_m(we_m),
        .a(a),
        .q(q),
        .m(m),
        .q_1(q_1),
        .adder_result(adder_result),
        .a_shifted(a_shifted),
        .q_shifted(q_shifted),
        .select_m(select_m),
        .sub(sub),
        .not_a8(not_a8)
    );

endmodule
