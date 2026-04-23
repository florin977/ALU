`timescale 1ns/1ps

module parallel_adder_9bit (
    input  wire [8:0] a,
    input  wire [8:0] b,
    input  wire       cin,
    output wire [8:0] sum,
    output wire       cout
);

    assign {cout, sum} = a + b + cin;

endmodule
