`timescale 1ns/1ps

module register_param #(
    parameter WIDTH = 8,
    parameter [WIDTH-1:0] RESET_VALUE = {WIDTH{1'b0}}
) (
    input  wire             clk,
    input  wire             rst,
    input  wire             we,
    input  wire [WIDTH-1:0] d,
    output reg  [WIDTH-1:0] q
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            q <= RESET_VALUE;
        end else if (we) begin
            q <= d;
        end
    end

endmodule
