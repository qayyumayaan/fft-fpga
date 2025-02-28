module fft_16_elements (
    input  logic signed [15:0] x_real [0:15], // Input real parts (Q1.15 format)
    input  logic signed [15:0] x_imag [0:15], // Input imaginary parts (Q1.15 format)
    output logic signed [15:0] fft_real [0:15], // Output real parts (Q1.15 format)
    output logic signed [15:0] fft_imag [0:15]  // Output imaginary parts (Q1.15 format)
);

    // Define a complex number as a struct with real and imaginary parts
    typedef struct packed {
        logic signed [15:0] re;
        logic signed [15:0] im;
    } complex_t;

    // Input and output arrays of complex numbers
    complex_t x     [0:15];
    complex_t fft   [0:15];

    // Intermediate arrays
    complex_t even  [0:7];
    complex_t odd   [0:7];
    complex_t fft_even [0:7];
    complex_t fft_odd  [0:7];
    complex_t T     [0:7];

    // Twiddle factors W_N^k in fixed-point representation (Q1.15 format)
    localparam logic signed [15:0] W_N_re [0:7] = '{
        16'sd32768,   // cos(0)
        16'sd30274,   // cos(pi/8)
        16'sd23170,   // cos(pi/4)
        16'sd12540,   // cos(3*pi/8)
        16'sd0,       // cos(pi/2)
        -16'sd12540,  // cos(5*pi/8)
        -16'sd23170,  // cos(3*pi/4)
        -16'sd30274   // cos(7*pi/8)
    };

    localparam logic signed [15:0] W_N_im [0:7] = '{
        16'sd0,       // -sin(0)
        -16'sd12540,  // -sin(pi/8)
        -16'sd23170,  // -sin(pi/4)
        -16'sd30274,  // -sin(3*pi/8)
        -16'sd32768,  // -sin(pi/2)
        -16'sd30274,  // -sin(5*pi/8)
        -16'sd23170,  // -sin(3*pi/4)
        -16'sd12540   // -sin(7*pi/8)
    };

    // Function for complex multiplication in Q1.15 format with saturation
    function automatic complex_t complex_mult (complex_t a, complex_t b);
        logic signed [31:0] re_part;
        logic signed [31:0] im_part;
        complex_t result;
        begin
            re_part = (a.re * b.re - a.im * b.im);
            im_part = (a.re * b.im + a.im * b.re);
            // Scale back to Q1.15 format by shifting right by 15 bits with saturation
            result.re = (re_part >>> 15 > 32767) ? 32767 : 
                        (re_part >>> 15 < -32768) ? -32768 : re_part >>> 15;
            result.im = (im_part >>> 15 > 32767) ? 32767 : 
                        (im_part >>> 15 < -32768) ? -32768 : im_part >>> 15;
            complex_mult = result;
        end
    endfunction

    // Function for complex addition
    function automatic complex_t complex_add (complex_t a, complex_t b);
        complex_t result;
        begin
            result.re = a.re + b.re;
            result.im = a.im + b.im;
            complex_add = result;
        end
    endfunction

    // Function for complex subtraction
    function automatic complex_t complex_sub (complex_t a, complex_t b);
        complex_t result;
        begin
            result.re = a.re - b.re;
            result.im = a.im - b.im;
            complex_sub = result;
        end
    endfunction

    // Initialize complex input array
    always_comb begin
        for (int i = 0; i < 16; i++) begin
            x[i].re = x_real[i];
            x[i].im = x_imag[i];
        end
    end

    // Step 2: Split input into even and odd elements
    always_comb begin
        for (int i = 0; i < 8; i++) begin
            even[i] = x[2*i];
            odd[i]  = x[2*i + 1];
        end
    end

    // FFT computations for even and odd elements
    logic signed [15:0] even_real [0:7];
    logic signed [15:0] even_imag [0:7];
    logic signed [15:0] fft_even_real [0:7];
    logic signed [15:0] fft_even_imag [0:7];
    logic signed [15:0] odd_real [0:7];
    logic signed [15:0] odd_imag [0:7];
    logic signed [15:0] fft_odd_real [0:7];
    logic signed [15:0] fft_odd_imag [0:7];

    always_comb begin
        for (int i = 0; i < 8; i++) begin
            even_real[i] = even[i].re;
            even_imag[i] = even[i].im;
            odd_real[i]  = odd[i].re;
            odd_imag[i]  = odd[i].im;
        end
    end

    fft_8_elements fft_even_inst (
        .x_real(even_real),
        .x_imag(even_imag),
        .fft_real(fft_even_real),
        .fft_imag(fft_even_imag)
    );

    fft_8_elements fft_odd_inst (
        .x_real(odd_real),
        .x_imag(odd_imag),
        .fft_real(fft_odd_real),
        .fft_imag(fft_odd_imag)
    );

    always_comb begin
        for (int i = 0; i < 8; i++) begin
            fft_even[i].re = fft_even_real[i];
            fft_even[i].im = fft_even_imag[i];
            fft_odd[i].re  = fft_odd_real[i];
            fft_odd[i].im  = fft_odd_imag[i];
        end
    end

    // Step 5: Compute T_k = W_N^k * fft_odd[k]
    always_comb begin
        for (int k = 0; k < 8; k++) begin
            complex_t W_N_k;
            W_N_k.re = W_N_re[k];
            W_N_k.im = W_N_im[k];
            T[k] = complex_mult(W_N_k, fft_odd[k]);
        end
    end

    // Step 6: Combine the results
    always_comb begin
        for (int k = 0; k < 8; k++) begin
            fft[k]     = complex_add(fft_even[k], T[k]);
            fft[k+8]   = complex_sub(fft_even[k], T[k]);
        end
    end

    // Assign outputs
    always_comb begin
        for (int i = 0; i < 16; i++) begin
            fft_real[i] = fft[i].re;
            fft_imag[i] = fft[i].im;
        end
    end

endmodule
