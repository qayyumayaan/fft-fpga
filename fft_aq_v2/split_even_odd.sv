module split_even_odd #(parameter N = 16)(
    input  logic [31:0] x    [0:N-1],
    output logic [31:0] even [0:((N+1)/2)-1],
    output logic [31:0] odd  [0:(N/2)-1]
);

    always_comb begin
        // Extract even-indexed elements
        for (int i = 0; i < N; i += 2) begin
            even[i/2] = x[i];
        end

        // Extract odd-indexed elements
        for (int i = 1; i < N; i += 2) begin
            odd[i/2] = x[i];
        end
    end

endmodule
