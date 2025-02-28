library verilog;
use verilog.vl_types.all;
entity tb is
    generic(
        N               : integer := 16;
        Q               : integer := 15;
        DATA_WIDTH      : integer := 16
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of N : constant is 1;
    attribute mti_svvh_generic_type of Q : constant is 1;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
end tb;
