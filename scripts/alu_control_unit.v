`timescale 1ns/1ps

module alu_control_unit (
    input  wire       clk,
    input  wire       rst,
    input  wire       start,
    input  wire       target_reached,
    output wire [1:0] cu_signal,
    output wire       we_a,
    output wire       we_q,
    output wire       we_m,
    output wire       end_flag,
    output wire       counter_load,
    output wire       counter_en,
    output wire       s0,
    output wire       s1,
    output wire       not_s0,
    output wire       not_s1
);

    wire [1:0] state;
    wire [1:0] next_state;

    assign s0 = state[0];
    assign s1 = state[1];
    assign not_s0 = ~s0;
    assign not_s1 = ~s1;

    assign next_state[1] = s0;
    assign next_state[0] = (not_s1 & not_s0 & start) |
                           (not_s1 & s0) |
                           (s1 & s0 & ~target_reached);

    register_param #(
        .WIDTH(2),
        .RESET_VALUE(2'b00)
    ) fsm_state_reg (
        .clk(clk),
        .rst(rst),
        .we(1'b1),
        .d(next_state),
        .q(state)
    );

    assign cu_signal = state;
    assign we_a = s0;
    assign we_q = s0;
    assign we_m = s0 & not_s1;
    assign end_flag = s1 & not_s0;

    assign counter_load = not_s1 & s0;
    assign counter_en = s1 & s0;

endmodule
