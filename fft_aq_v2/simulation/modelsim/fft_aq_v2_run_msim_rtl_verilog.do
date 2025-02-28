transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/amazi/Documents/GitHub/dsd-labs/fft_aq_v2 {C:/Users/amazi/Documents/GitHub/dsd-labs/fft_aq_v2/fft_8_elements.sv}
vlog -sv -work work +incdir+C:/Users/amazi/Documents/GitHub/dsd-labs/fft_aq_v2 {C:/Users/amazi/Documents/GitHub/dsd-labs/fft_aq_v2/fft_16_elements.sv}
vlog -sv -work work +incdir+C:/Users/amazi/Documents/GitHub/dsd-labs/fft_aq_v2 {C:/Users/amazi/Documents/GitHub/dsd-labs/fft_aq_v2/top.sv}

vlog -sv -work work +incdir+C:/Users/amazi/Documents/GitHub/dsd-labs/fft_aq_v2 {C:/Users/amazi/Documents/GitHub/dsd-labs/fft_aq_v2/tb.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  tb

add wave *
view structure
view signals
run 100 ns
