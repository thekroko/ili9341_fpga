create_clock -period 20.833 -name clk [get_ports clk]
derive_clocks -period 20.833
derive_pll_clocks
derive_clock_uncertainty