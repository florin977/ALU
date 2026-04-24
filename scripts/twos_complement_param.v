`timescale 1ns/1ps

module twos_complement_param #(
    parameter WIDTH = 8
) (
    input  wire [WIDTH-1:0] in,
    output wire [WIDTH-1:0] out
);

    wire adder_cout;

    parallel_adder_param #(
        .WIDTH(WIDTH)
    ) negator_adder (
        .a(~in),
        .b({{(WIDTH-1){1'b0}}, 1'b1}),
        .cin(1'b0),
        .sum(out),
        .cout(adder_cout)
    );

endmodule
