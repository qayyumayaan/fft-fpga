library verilog;
use verilog.vl_types.all;
entity fft_8_elements is
    port(
        x_real          : in     vl_logic;
        x_imag          : in     vl_logic;
        fft_real        : out    vl_logic;
        fft_imag        : out    vl_logic
    );
end fft_8_elements;
