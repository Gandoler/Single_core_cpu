module adder32(
    input logic [31:0] a_i,
    input logic [31:0] b_i,
    input logic carry_i,
    output logic [31:0] sum_o,
    output logic carry_o
);
    logic carry_0, carry_1, carry_2, carry_3, carry_4, carry_5, carry_6;

    adder4 sum0 (
        .a_i(a_i[3:0]),
        .b_i(b_i[3:0]),
        .carry_i(carry_i),
        .sum_o(sum_o[3:0]),
        .carry_o(carry_0)
    );

    adder4 sum1 (
        .a_i(a_i[7:4]),
        .b_i(b_i[7:4]),
        .carry_i(carry_0),
        .sum_o(sum_o[7:4]),
        .carry_o(carry_1)
    );

    adder4 sum2 (
        .a_i(a_i[11:8]),
        .b_i(b_i[11:8]),
        .carry_i(carry_1),
        .sum_o(sum_o[11:8]),
        .carry_o(carry_2)
    );

    adder4 sum3 (
        .a_i(a_i[15:12]),
        .b_i(b_i[15:12]),
        .carry_i(carry_2),
        .sum_o(sum_o[15:12]),
        .carry_o(carry_3)
    );

    adder4 sum4 (
        .a_i(a_i[19:16]),
        .b_i(b_i[19:16]),
        .carry_i(carry_3),
        .sum_o(sum_o[19:16]),
        .carry_o(carry_4)
    );

    adder4 sum5 (
        .a_i(a_i[23:20]),
        .b_i(b_i[23:20]),
        .carry_i(carry_4),
        .sum_o(sum_o[23:20]),
        .carry_o(carry_5)
    );

    adder4 sum6 (
        .a_i(a_i[27:24]),
        .b_i(b_i[27:24]),
        .carry_i(carry_5),
        .sum_o(sum_o[27:24]),
        .carry_o(carry_6)
    );

    adder4 sum7 (
        .a_i(a_i[31:28]),
        .b_i(b_i[31:28]),
        .carry_i(carry_6),
        .sum_o(sum_o[31:28]),
        .carry_o(carry_o)
    );

endmodule
