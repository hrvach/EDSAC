## Generated SDC file "/media/hrvoje/fpga/EDSAC_MiSTer/sys/sys_top.sdc"

## Copyright (C) 2018  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 18.1.0 Build 625 09/12/2018 SJ Lite Edition"

## DATE    "Fri Apr 17 02:33:48 2020"

##
## DEVICE  "5CSEBA6U23I7"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {FPGA_CLK1_50} -period 20.000 -waveform { 0.000 10.000 } [get_ports {FPGA_CLK1_50}]
create_clock -name {FPGA_CLK2_50} -period 20.000 -waveform { 0.000 10.000 } [get_ports {FPGA_CLK2_50}]
create_clock -name {FPGA_CLK3_50} -period 20.000 -waveform { 0.000 10.000 } [get_ports {FPGA_CLK3_50}]
create_clock -name {sysmem|fpga_interfaces|clocks_resets|h2f_user0_clk} -period 10.000 -waveform { 0.000 5.000 } [get_pins -compatibility_mode {*|h2f_user0_clk}]
create_clock -name {spi_sck} -period 10.000 -waveform { 0.000 5.000 } [get_pins -compatibility_mode {spi|sclk_out}]
create_clock -name {emu:emu|snd_wait[0]} -period 20.000 -waveform { 0.000 10.000 } [get_registers { emu:emu|snd_wait[0] }]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk} -source [get_pins {pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|vco0ph[0]}] -duty_cycle 50/1 -multiply_by 1 -divide_by 3 -master_clock {pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|fpll_0|fpll|vcoph[0]} [get_pins {pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk}] 
create_generated_clock -name {pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|fpll_0|fpll|vcoph[0]} -source [get_pins {pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|fpll_0|fpll|refclkin}] -duty_cycle 50/1 -multiply_by 4563 -divide_by 512 -master_clock {FPGA_CLK1_50} [get_pins {pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|fpll_0|fpll|vcoph[0]}] 
create_generated_clock -name {HDMI_CLK} -source [get_pins -compatibility_mode {pll_hdmi|pll_hdmi_inst|altera_pll_i|*[0].*|divclk}] -master_clock {pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk} [get_ports {HDMI_TX_CLK}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk}] -rise_to [get_clocks {HDMI_CLK}] -setup 0.300  
set_clock_uncertainty -rise_from [get_clocks {pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk}] -rise_to [get_clocks {HDMI_CLK}] -hold 0.210  
set_clock_uncertainty -rise_from [get_clocks {pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk}] -fall_to [get_clocks {HDMI_CLK}] -setup 0.300  
set_clock_uncertainty -rise_from [get_clocks {pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk}] -fall_to [get_clocks {HDMI_CLK}] -hold 0.210  
set_clock_uncertainty -rise_from [get_clocks {pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk}] -rise_to [get_clocks {pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk}] -setup 0.200  
set_clock_uncertainty -rise_from [get_clocks {pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk}] -rise_to [get_clocks {pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk}] -fall_to [get_clocks {pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk}] -setup 0.200  
set_clock_uncertainty -rise_from [get_clocks {pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk}] -fall_to [get_clocks {pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk}] -rise_to [get_clocks {HDMI_CLK}] -setup 0.300  
set_clock_uncertainty -fall_from [get_clocks {pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk}] -rise_to [get_clocks {HDMI_CLK}] -hold 0.210  
set_clock_uncertainty -fall_from [get_clocks {pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk}] -fall_to [get_clocks {HDMI_CLK}] -setup 0.300  
set_clock_uncertainty -fall_from [get_clocks {pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk}] -fall_to [get_clocks {HDMI_CLK}] -hold 0.210  
set_clock_uncertainty -fall_from [get_clocks {pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk}] -rise_to [get_clocks {pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk}] -setup 0.200  
set_clock_uncertainty -fall_from [get_clocks {pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk}] -rise_to [get_clocks {pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk}] -fall_to [get_clocks {pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk}] -setup 0.200  
set_clock_uncertainty -fall_from [get_clocks {pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk}] -fall_to [get_clocks {pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {spi_sck}] -rise_to [get_clocks {spi_sck}]  0.060  
set_clock_uncertainty -rise_from [get_clocks {spi_sck}] -fall_to [get_clocks {spi_sck}]  0.060  
set_clock_uncertainty -rise_from [get_clocks {spi_sck}] -rise_to [get_clocks {FPGA_CLK3_50}]  0.110  
set_clock_uncertainty -rise_from [get_clocks {spi_sck}] -fall_to [get_clocks {FPGA_CLK3_50}]  0.110  
set_clock_uncertainty -fall_from [get_clocks {spi_sck}] -rise_to [get_clocks {spi_sck}]  0.060  
set_clock_uncertainty -fall_from [get_clocks {spi_sck}] -fall_to [get_clocks {spi_sck}]  0.060  
set_clock_uncertainty -fall_from [get_clocks {spi_sck}] -rise_to [get_clocks {FPGA_CLK3_50}]  0.110  
set_clock_uncertainty -fall_from [get_clocks {spi_sck}] -fall_to [get_clocks {FPGA_CLK3_50}]  0.110  
set_clock_uncertainty -rise_from [get_clocks {sysmem|fpga_interfaces|clocks_resets|h2f_user0_clk}] -rise_to [get_clocks {sysmem|fpga_interfaces|clocks_resets|h2f_user0_clk}]  0.060  
set_clock_uncertainty -rise_from [get_clocks {sysmem|fpga_interfaces|clocks_resets|h2f_user0_clk}] -fall_to [get_clocks {sysmem|fpga_interfaces|clocks_resets|h2f_user0_clk}]  0.060  
set_clock_uncertainty -fall_from [get_clocks {sysmem|fpga_interfaces|clocks_resets|h2f_user0_clk}] -rise_to [get_clocks {sysmem|fpga_interfaces|clocks_resets|h2f_user0_clk}]  0.060  
set_clock_uncertainty -fall_from [get_clocks {sysmem|fpga_interfaces|clocks_resets|h2f_user0_clk}] -fall_to [get_clocks {sysmem|fpga_interfaces|clocks_resets|h2f_user0_clk}]  0.060  
set_clock_uncertainty -rise_from [get_clocks {FPGA_CLK3_50}] -rise_to [get_clocks {FPGA_CLK3_50}] -setup 0.170  
set_clock_uncertainty -rise_from [get_clocks {FPGA_CLK3_50}] -rise_to [get_clocks {FPGA_CLK3_50}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {FPGA_CLK3_50}] -fall_to [get_clocks {FPGA_CLK3_50}] -setup 0.170  
set_clock_uncertainty -rise_from [get_clocks {FPGA_CLK3_50}] -fall_to [get_clocks {FPGA_CLK3_50}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {FPGA_CLK3_50}] -rise_to [get_clocks {FPGA_CLK3_50}] -setup 0.170  
set_clock_uncertainty -fall_from [get_clocks {FPGA_CLK3_50}] -rise_to [get_clocks {FPGA_CLK3_50}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {FPGA_CLK3_50}] -fall_to [get_clocks {FPGA_CLK3_50}] -setup 0.170  
set_clock_uncertainty -fall_from [get_clocks {FPGA_CLK3_50}] -fall_to [get_clocks {FPGA_CLK3_50}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {FPGA_CLK2_50}] -rise_to [get_clocks {HDMI_CLK}]  0.380  
set_clock_uncertainty -rise_from [get_clocks {FPGA_CLK2_50}] -fall_to [get_clocks {HDMI_CLK}]  0.380  
set_clock_uncertainty -rise_from [get_clocks {FPGA_CLK2_50}] -rise_to [get_clocks {FPGA_CLK2_50}] -setup 0.310  
set_clock_uncertainty -rise_from [get_clocks {FPGA_CLK2_50}] -rise_to [get_clocks {FPGA_CLK2_50}] -hold 0.270  
set_clock_uncertainty -rise_from [get_clocks {FPGA_CLK2_50}] -fall_to [get_clocks {FPGA_CLK2_50}] -setup 0.310  
set_clock_uncertainty -rise_from [get_clocks {FPGA_CLK2_50}] -fall_to [get_clocks {FPGA_CLK2_50}] -hold 0.270  
set_clock_uncertainty -fall_from [get_clocks {FPGA_CLK2_50}] -rise_to [get_clocks {HDMI_CLK}]  0.380  
set_clock_uncertainty -fall_from [get_clocks {FPGA_CLK2_50}] -fall_to [get_clocks {HDMI_CLK}]  0.380  
set_clock_uncertainty -fall_from [get_clocks {FPGA_CLK2_50}] -rise_to [get_clocks {FPGA_CLK2_50}] -setup 0.310  
set_clock_uncertainty -fall_from [get_clocks {FPGA_CLK2_50}] -rise_to [get_clocks {FPGA_CLK2_50}] -hold 0.270  
set_clock_uncertainty -fall_from [get_clocks {FPGA_CLK2_50}] -fall_to [get_clocks {FPGA_CLK2_50}] -setup 0.310  
set_clock_uncertainty -fall_from [get_clocks {FPGA_CLK2_50}] -fall_to [get_clocks {FPGA_CLK2_50}] -hold 0.270  
set_clock_uncertainty -rise_from [get_clocks {FPGA_CLK1_50}] -rise_to [get_clocks {FPGA_CLK1_50}] -setup 0.170  
set_clock_uncertainty -rise_from [get_clocks {FPGA_CLK1_50}] -rise_to [get_clocks {FPGA_CLK1_50}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {FPGA_CLK1_50}] -fall_to [get_clocks {FPGA_CLK1_50}] -setup 0.170  
set_clock_uncertainty -rise_from [get_clocks {FPGA_CLK1_50}] -fall_to [get_clocks {FPGA_CLK1_50}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {FPGA_CLK1_50}] -rise_to [get_clocks {FPGA_CLK1_50}] -setup 0.170  
set_clock_uncertainty -fall_from [get_clocks {FPGA_CLK1_50}] -rise_to [get_clocks {FPGA_CLK1_50}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {FPGA_CLK1_50}] -fall_to [get_clocks {FPGA_CLK1_50}] -setup 0.170  
set_clock_uncertainty -fall_from [get_clocks {FPGA_CLK1_50}] -fall_to [get_clocks {FPGA_CLK1_50}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {emu:emu|snd_wait[0]}] -rise_to [get_clocks {emu:emu|snd_wait[0]}]  0.270  
set_clock_uncertainty -rise_from [get_clocks {emu:emu|snd_wait[0]}] -fall_to [get_clocks {emu:emu|snd_wait[0]}]  0.270  
set_clock_uncertainty -rise_from [get_clocks {emu:emu|snd_wait[0]}] -rise_to [get_clocks {FPGA_CLK2_50}]  0.290  
set_clock_uncertainty -rise_from [get_clocks {emu:emu|snd_wait[0]}] -fall_to [get_clocks {FPGA_CLK2_50}]  0.290  
set_clock_uncertainty -fall_from [get_clocks {emu:emu|snd_wait[0]}] -rise_to [get_clocks {emu:emu|snd_wait[0]}]  0.270  
set_clock_uncertainty -fall_from [get_clocks {emu:emu|snd_wait[0]}] -fall_to [get_clocks {emu:emu|snd_wait[0]}]  0.270  
set_clock_uncertainty -fall_from [get_clocks {emu:emu|snd_wait[0]}] -rise_to [get_clocks {FPGA_CLK2_50}]  0.290  
set_clock_uncertainty -fall_from [get_clocks {emu:emu|snd_wait[0]}] -fall_to [get_clocks {FPGA_CLK2_50}]  0.290  
set_clock_uncertainty -rise_from [get_clocks {FPGA_CLK2_50}] -rise_to [get_clocks {emu:emu|snd_wait[0]}]  0.290  
set_clock_uncertainty -rise_from [get_clocks {FPGA_CLK2_50}] -fall_to [get_clocks {emu:emu|snd_wait[0]}]  0.290  
set_clock_uncertainty -fall_from [get_clocks {FPGA_CLK2_50}] -rise_to [get_clocks {emu:emu|snd_wait[0]}]  0.290  
set_clock_uncertainty -fall_from [get_clocks {FPGA_CLK2_50}] -fall_to [get_clocks {emu:emu|snd_wait[0]}]  0.290  


#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -add_delay -max -clock [get_clocks {HDMI_CLK}]  4.000 [get_ports {HDMI_TX_DE}]
set_output_delay -add_delay -min -clock [get_clocks {HDMI_CLK}]  3.000 [get_ports {HDMI_TX_DE}]
set_output_delay -add_delay -max -clock [get_clocks {HDMI_CLK}]  4.000 [get_ports {HDMI_TX_D[0]}]
set_output_delay -add_delay -min -clock [get_clocks {HDMI_CLK}]  3.000 [get_ports {HDMI_TX_D[0]}]
set_output_delay -add_delay -max -clock [get_clocks {HDMI_CLK}]  4.000 [get_ports {HDMI_TX_D[1]}]
set_output_delay -add_delay -min -clock [get_clocks {HDMI_CLK}]  3.000 [get_ports {HDMI_TX_D[1]}]
set_output_delay -add_delay -max -clock [get_clocks {HDMI_CLK}]  4.000 [get_ports {HDMI_TX_D[2]}]
set_output_delay -add_delay -min -clock [get_clocks {HDMI_CLK}]  3.000 [get_ports {HDMI_TX_D[2]}]
set_output_delay -add_delay -max -clock [get_clocks {HDMI_CLK}]  4.000 [get_ports {HDMI_TX_D[3]}]
set_output_delay -add_delay -min -clock [get_clocks {HDMI_CLK}]  3.000 [get_ports {HDMI_TX_D[3]}]
set_output_delay -add_delay -max -clock [get_clocks {HDMI_CLK}]  4.000 [get_ports {HDMI_TX_D[4]}]
set_output_delay -add_delay -min -clock [get_clocks {HDMI_CLK}]  3.000 [get_ports {HDMI_TX_D[4]}]
set_output_delay -add_delay -max -clock [get_clocks {HDMI_CLK}]  4.000 [get_ports {HDMI_TX_D[5]}]
set_output_delay -add_delay -min -clock [get_clocks {HDMI_CLK}]  3.000 [get_ports {HDMI_TX_D[5]}]
set_output_delay -add_delay -max -clock [get_clocks {HDMI_CLK}]  4.000 [get_ports {HDMI_TX_D[6]}]
set_output_delay -add_delay -min -clock [get_clocks {HDMI_CLK}]  3.000 [get_ports {HDMI_TX_D[6]}]
set_output_delay -add_delay -max -clock [get_clocks {HDMI_CLK}]  4.000 [get_ports {HDMI_TX_D[7]}]
set_output_delay -add_delay -min -clock [get_clocks {HDMI_CLK}]  3.000 [get_ports {HDMI_TX_D[7]}]
set_output_delay -add_delay -max -clock [get_clocks {HDMI_CLK}]  4.000 [get_ports {HDMI_TX_D[8]}]
set_output_delay -add_delay -min -clock [get_clocks {HDMI_CLK}]  3.000 [get_ports {HDMI_TX_D[8]}]
set_output_delay -add_delay -max -clock [get_clocks {HDMI_CLK}]  4.000 [get_ports {HDMI_TX_D[9]}]
set_output_delay -add_delay -min -clock [get_clocks {HDMI_CLK}]  3.000 [get_ports {HDMI_TX_D[9]}]
set_output_delay -add_delay -max -clock [get_clocks {HDMI_CLK}]  4.000 [get_ports {HDMI_TX_D[10]}]
set_output_delay -add_delay -min -clock [get_clocks {HDMI_CLK}]  3.000 [get_ports {HDMI_TX_D[10]}]
set_output_delay -add_delay -max -clock [get_clocks {HDMI_CLK}]  4.000 [get_ports {HDMI_TX_D[11]}]
set_output_delay -add_delay -min -clock [get_clocks {HDMI_CLK}]  3.000 [get_ports {HDMI_TX_D[11]}]
set_output_delay -add_delay -max -clock [get_clocks {HDMI_CLK}]  4.000 [get_ports {HDMI_TX_D[12]}]
set_output_delay -add_delay -min -clock [get_clocks {HDMI_CLK}]  3.000 [get_ports {HDMI_TX_D[12]}]
set_output_delay -add_delay -max -clock [get_clocks {HDMI_CLK}]  4.000 [get_ports {HDMI_TX_D[13]}]
set_output_delay -add_delay -min -clock [get_clocks {HDMI_CLK}]  3.000 [get_ports {HDMI_TX_D[13]}]
set_output_delay -add_delay -max -clock [get_clocks {HDMI_CLK}]  4.000 [get_ports {HDMI_TX_D[14]}]
set_output_delay -add_delay -min -clock [get_clocks {HDMI_CLK}]  3.000 [get_ports {HDMI_TX_D[14]}]
set_output_delay -add_delay -max -clock [get_clocks {HDMI_CLK}]  4.000 [get_ports {HDMI_TX_D[15]}]
set_output_delay -add_delay -min -clock [get_clocks {HDMI_CLK}]  3.000 [get_ports {HDMI_TX_D[15]}]
set_output_delay -add_delay -max -clock [get_clocks {HDMI_CLK}]  4.000 [get_ports {HDMI_TX_D[16]}]
set_output_delay -add_delay -min -clock [get_clocks {HDMI_CLK}]  3.000 [get_ports {HDMI_TX_D[16]}]
set_output_delay -add_delay -max -clock [get_clocks {HDMI_CLK}]  4.000 [get_ports {HDMI_TX_D[17]}]
set_output_delay -add_delay -min -clock [get_clocks {HDMI_CLK}]  3.000 [get_ports {HDMI_TX_D[17]}]
set_output_delay -add_delay -max -clock [get_clocks {HDMI_CLK}]  4.000 [get_ports {HDMI_TX_D[18]}]
set_output_delay -add_delay -min -clock [get_clocks {HDMI_CLK}]  3.000 [get_ports {HDMI_TX_D[18]}]
set_output_delay -add_delay -max -clock [get_clocks {HDMI_CLK}]  4.000 [get_ports {HDMI_TX_D[19]}]
set_output_delay -add_delay -min -clock [get_clocks {HDMI_CLK}]  3.000 [get_ports {HDMI_TX_D[19]}]
set_output_delay -add_delay -max -clock [get_clocks {HDMI_CLK}]  4.000 [get_ports {HDMI_TX_D[20]}]
set_output_delay -add_delay -min -clock [get_clocks {HDMI_CLK}]  3.000 [get_ports {HDMI_TX_D[20]}]
set_output_delay -add_delay -max -clock [get_clocks {HDMI_CLK}]  4.000 [get_ports {HDMI_TX_D[21]}]
set_output_delay -add_delay -min -clock [get_clocks {HDMI_CLK}]  3.000 [get_ports {HDMI_TX_D[21]}]
set_output_delay -add_delay -max -clock [get_clocks {HDMI_CLK}]  4.000 [get_ports {HDMI_TX_D[22]}]
set_output_delay -add_delay -min -clock [get_clocks {HDMI_CLK}]  3.000 [get_ports {HDMI_TX_D[22]}]
set_output_delay -add_delay -max -clock [get_clocks {HDMI_CLK}]  4.000 [get_ports {HDMI_TX_D[23]}]
set_output_delay -add_delay -min -clock [get_clocks {HDMI_CLK}]  3.000 [get_ports {HDMI_TX_D[23]}]
set_output_delay -add_delay -max -clock [get_clocks {HDMI_CLK}]  4.000 [get_ports {HDMI_TX_HS}]
set_output_delay -add_delay -min -clock [get_clocks {HDMI_CLK}]  3.000 [get_ports {HDMI_TX_HS}]
set_output_delay -add_delay -max -clock [get_clocks {HDMI_CLK}]  4.000 [get_ports {HDMI_TX_VS}]
set_output_delay -add_delay -min -clock [get_clocks {HDMI_CLK}]  3.000 [get_ports {HDMI_TX_VS}]


#**************************************************************
# Set Clock Groups
#**************************************************************

set_clock_groups -exclusive -group [get_clocks { *|pll|pll_inst|altera_pll_i|*[*].*|divclk}] -group [get_clocks { pll_hdmi|pll_hdmi_inst|altera_pll_i|*[0].*|divclk}] -group [get_clocks { *|h2f_user0_clk}] -group [get_clocks { FPGA_CLK1_50 }] -group [get_clocks { FPGA_CLK2_50 }] -group [get_clocks { FPGA_CLK3_50 }] 


#**************************************************************
# Set False Path
#**************************************************************

set_false_path -to [get_keepers {*altera_std_synchronizer:*|din_s1}]
set_false_path -from [get_ports {KEY*}] 
set_false_path -from [get_ports {BTN_*}] 
set_false_path -to [get_ports {LED_*}]
set_false_path -to [get_ports {VGA_*}]
set_false_path -to [get_ports {AUDIO_SPDIF}]
set_false_path -to [get_ports {AUDIO_L}]
set_false_path -to [get_ports {AUDIO_R}]
set_false_path -to [get_keepers {cfg[*]}]
set_false_path -from [get_keepers {cfg[*]}] 
set_false_path -to [get_keepers {wcalc[*] hcalc[*]}]


#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

