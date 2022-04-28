`timescale 1ns/1ps

//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    15:15:11 08/18/2013
// Design Name:
// Module Name:    alu
// Project Name:
// Target Devices:
// Tool versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
module alu(
           clk,           // system clock              (input)
           rst_n,         // negative reset            (input)
           src1,          // 32 bits source 1          (input)
           src2,          // 32 bits source 2          (input)
           ALU_control,   // 4 bits ALU control input  (input)
           result,        // 32 bits result            (output)
           zero,          // 1 bit when the output is 0, zero must be set (output)
           cout,          // 1 bit carry out           (output)
           overflow       // 1 bit overflow            (output)
           );

    input           clk;
    input           rst_n;
    input  [32-1:0] src1;
    input  [32-1:0] src2;
    input   [4-1:0] ALU_control;
    

    output [32-1:0] result;
    output          zero;
    output          cout;
    output          overflow;

    wire   [32-1:0] carry;
    reg     [2-1:0] operation;
    reg             less;
    reg             A_invert;
    reg             B_invert;
    reg             first;
    wire            tmp1;
    wire            tmp2;

    always@(*) begin
        case(ALU_control)
            4'b0000: begin A_invert = 0; B_invert = 0; first = 0; operation = 0; end
            4'b0001: begin A_invert = 0; B_invert = 0; first = 0; operation = 1; end
            4'b0010: begin A_invert = 0; B_invert = 0; first = 0; operation = 2; end
            4'b0110: begin A_invert = 0; B_invert = 1; first = 1; operation = 2; end
            4'b1100: begin A_invert = 1; B_invert = 1; first = 0; operation = 0; end
            4'b1101: begin A_invert = 1; B_invert = 1; first = 0; operation = 1; end
            4'b0111: begin A_invert = 0; B_invert = 1; first = 1; operation = 3; end
                
            
        endcase
    end

    always@(*) begin
        if(ALU_control == 4'b0111) begin
            case(src1[31]^src2[32])
                1'b0: begin less=carry[31];end
                1'b1:begin less=src1[31];end
            endcase
        end
    end

    //assign zero =(ALU_control==4'b0111) ? 0 : ~(|result);//
    assign zero = ~(|result);
    assign cout = (ALU_control==4'b0111) ? 0 :carry[31];

    assign tmp1 = A_invert ? ~src1[31] : src1[31];
    assign tmp2 = B_invert ? ~src2[31] : src2[31];

    assign overflow = (ALU_control==4'b0111) ? 0 : ~(tmp1 ^ tmp2) & (tmp1 ^ result[31]);

    genvar i;
    generate
        for(i = 0; i < 32; i = i + 1) begin
            alu_top sub_alu(
                .src1(src1[i]),
                .src2(src2[i]),
                .less( (i == 0) ? less : 1'b0),//alu less,a<b,i=0//
                .A_invert(A_invert),
                .B_invert(B_invert),
                .cin(i == 0 ? first : carry[i-1]),//carry out connect to next cin//
                .operation(operation),
                .result(result[i]),
                .cout(carry[i])
            );
        end
    endgenerate

endmodule
