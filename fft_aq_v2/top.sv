module top (
    input  logic signed [15:0] inputs [0:15],     // 16 signed 16-bit inputs
    output logic signed [15:0] real_out [0:15]   // Real parts of FFT outputs
);

    // Wires for FFT outputs
    logic signed [15:0] fft_real [0:15];
    logic signed [15:0] fft_imag [0:15];

    // Define temporary packed array for imaginary inputs
    logic signed [15:0] zero_imag [0:15];

    // Initialize the imaginary part to zero
    initial begin
        for (int i = 0; i < 16; i++) begin
            zero_imag[i] = 16'sd0;
        end
    end

    // Instantiate FFT module
    fft_16_elements fft_inst (
        .x_real(inputs),
        .x_imag(zero_imag),   // Pass the temporary array
        .fft_real(fft_real),
        .fft_imag(fft_imag)
    );

    // Directly assign FFT real outputs
    always_comb begin
        for (int i = 0; i < 16; i++) begin
            real_out[i] = fft_real[i]; // Direct assignment (16-bit precision)
        end
    end

endmodule
