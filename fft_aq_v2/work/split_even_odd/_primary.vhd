library verilog;
use verilog.vl_types.all;
entity split_even_odd is
    generic(
        N               : integer := 16
    );
    port(
        x               : in     vl_logic;
        even            : out    vl_logic;
        odd             : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of N : constant is 1;
end split_even_odd;
