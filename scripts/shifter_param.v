`timescale 1ns/1ps

module shifter_param #(
    parameter WIDTH = 8,
    parameter AMOUNT_WIDTH = 4
) (
    input  wire [WIDTH-1:0]        data_in,
    input  wire [AMOUNT_WIDTH-1:0] shift_amount,
    input  wire [1:0]              op,
    output reg  [WIDTH-1:0]        data_out
);

    localparam OP_HOLD  = 2'b00;
    localparam OP_LSL   = 2'b01;
    localparam OP_LSR   = 2'b10;
    localparam OP_ASR   = 2'b11;

    always @(*) begin
        case (op)
            OP_HOLD: data_out = data_in;
            OP_LSL:  data_out = data_in << shift_amount;
            OP_LSR:  data_out = data_in >> shift_amount;
            OP_ASR:  data_out = $signed(data_in) >>> shift_amount;
            default: data_out = data_in;
        endcase
    end

endmodule
