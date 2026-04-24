`timescale 1ns/1ps

module shifter_param #(
    parameter WIDTH = 8,
    parameter AMOUNT_WIDTH = 4
) (
    input  wire [WIDTH-1:0]        data_in,
    input  wire [AMOUNT_WIDTH-1:0] shift_amount,
    input  wire [1:0]              op,
    output wire [WIDTH-1:0]        data_out
);

    localparam OP_HOLD  = 2'b00;
    localparam OP_LSL   = 2'b01;
    localparam OP_LSR   = 2'b10;
    localparam OP_ASR   = 2'b11;

    wire [WIDTH-1:0] asr_fill;
    wire [WIDTH-1:0] asr_result;

    assign asr_fill = {WIDTH{data_in[WIDTH-1]}} << (WIDTH - shift_amount);
    assign asr_result = (shift_amount == {AMOUNT_WIDTH{1'b0}}) ?
                        data_in :
                        ((data_in >> shift_amount) | asr_fill);
    assign data_out = (op == OP_LSL) ? (data_in << shift_amount) :
                      (op == OP_LSR) ? (data_in >> shift_amount) :
                      (op == OP_ASR) ? asr_result :
                                       data_in;

endmodule
