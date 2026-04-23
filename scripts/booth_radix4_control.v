`timescale 1ns/1ps

module booth_radix4_control (
    input  wire q1,
    input  wire q0,
    input  wire q_1,
    output wire [1:0] select_m,
    output wire sub
);

    wire q1_xor_q0;
    wire q0_xor_q_1;

    assign q1_xor_q0 = q1 ^ q0;
    assign q0_xor_q_1 = q0 ^ q_1;

    assign select_m[0] = q0_xor_q_1;
    assign select_m[1] = q1_xor_q0 & ~q0_xor_q_1;
    assign sub = q1;

endmodule
