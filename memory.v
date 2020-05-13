// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on

/* Charset contains EDSAC charset, applied from a font like the one on a IBM Model B typewriter */
module teletype_charset (
   address,
   clock,
   q);

   input [10:0]  address;
   input   clock;
   output   [15:0]  q;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
   tri1    clock;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

   wire [15:0] sub_wire0;
   wire [15:0] q = sub_wire0[15:0];

   altsyncram  altsyncram_component (
            .address_a (address),
            .clock0 (clock),
            .q_a (sub_wire0),
            .aclr0 (1'b0),
            .aclr1 (1'b0),
            .address_b (1'b1),
            .addressstall_a (1'b0),
            .addressstall_b (1'b0),
            .byteena_a (1'b1),
            .byteena_b (1'b1),
            .clock1 (1'b1),
            .clocken0 (1'b1),
            .clocken1 (1'b1),
            .clocken2 (1'b1),
            .clocken3 (1'b1),
            .data_a ({16{1'b1}}),
            .data_b (1'b1),
            .eccstatus (),
            .q_b (),
            .rden_a (1'b1),
            .rden_b (1'b1),
            .wren_a (1'b0),
            .wren_b (1'b0));
   defparam
      altsyncram_component.address_aclr_a = "NONE",
      altsyncram_component.clock_enable_input_a = "BYPASS",
      altsyncram_component.clock_enable_output_a = "BYPASS",
      altsyncram_component.init_file = "./roms/edsac_charset.mif",
      altsyncram_component.intended_device_family = "Cyclone V",
      altsyncram_component.lpm_hint = "ENABLE_RUNTIME_MOD=NO",
      altsyncram_component.lpm_type = "altsyncram",
      altsyncram_component.numwords_a = 2048,
      altsyncram_component.operation_mode = "ROM",
      altsyncram_component.outdata_aclr_a = "NONE",
      altsyncram_component.outdata_reg_a = "CLOCK0",
      altsyncram_component.ram_block_type = "M10K",
      altsyncram_component.widthad_a = 11,
      altsyncram_component.width_a = 16,
      altsyncram_component.width_byteena_a = 1;

endmodule


/* Terminal frame buffer, contains 64 x 32 characters which correspond to letters on teletype emulator screen */
module teletype_fb (
   clock,
   data,
   rdaddress,
   wraddress,
   wren,
   q);
   
   input   clock;
   input [5:0]  data;
   input [10:0]  rdaddress;
   input [10:0]  wraddress;
   input   wren;
   output   [5:0]  q;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
   tri1    clock;
   tri0    wren;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

   wire [5:0] sub_wire0;
   wire [5:0] q = sub_wire0[5:0];

   altsyncram  altsyncram_component (
            .address_a (wraddress),
            .address_b (rdaddress),
            .clock0 (clock),
            .data_a (data),
            .wren_a (wren),
            .q_b (sub_wire0),
            .aclr0 (1'b0),
            .aclr1 (1'b0),
            .addressstall_a (1'b0),
            .addressstall_b (1'b0),
            .byteena_a (1'b1),
            .byteena_b (1'b1),
            .clock1 (1'b1),
            .clocken0 (1'b1),
            .clocken1 (1'b1),
            .clocken2 (1'b1),
            .clocken3 (1'b1),
            .data_b ({6{1'b1}}),
            .eccstatus (),
            .q_a (),
            .rden_a (1'b1),
            .rden_b (1'b1),
            .wren_b (1'b0));
   defparam
      altsyncram_component.address_aclr_b = "NONE",
      altsyncram_component.address_reg_b = "CLOCK0",
      altsyncram_component.clock_enable_input_a = "BYPASS",
      altsyncram_component.clock_enable_input_b = "BYPASS",
      altsyncram_component.clock_enable_output_b = "BYPASS",
      altsyncram_component.intended_device_family = "Cyclone V",
      altsyncram_component.lpm_type = "altsyncram",
      altsyncram_component.numwords_a = 2048,
      altsyncram_component.numwords_b = 2048,
      altsyncram_component.init_file = "./roms/blank_textbuffer.mif",
      altsyncram_component.operation_mode = "DUAL_PORT",
      altsyncram_component.outdata_aclr_b = "NONE",
      altsyncram_component.outdata_reg_b = "CLOCK0",
      altsyncram_component.power_up_uninitialized = "FALSE",
      altsyncram_component.read_during_write_mode_mixed_ports = "DONT_CARE",
      altsyncram_component.widthad_a = 11,
      altsyncram_component.widthad_b = 11,
      altsyncram_component.width_a = 6,
      altsyncram_component.width_b = 6,
      altsyncram_component.width_byteena_a = 1;

endmodule



/* Sounds buffer, contains ADPCM encoded sound effects */
module sound_lib (
   clock,
   data,
   rdaddress,
   wraddress,
   wren,
   q);
   
   input         clock;
   input [3:0]   data;
   input [15:0]  rdaddress;
   input [15:0]  wraddress;
   input         wren;
   output [3:0]  q;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
   tri1    clock;
   tri0    wren;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

   wire [3:0] sub_wire0;
   wire [3:0] q = sub_wire0[3:0];

   altsyncram  altsyncram_component (
            .address_a (wraddress),
            .address_b (rdaddress),
            .clock0 (clock),
            .data_a (data),
            .wren_a (wren),
            .q_b (sub_wire0),
            .aclr0 (1'b0),
            .aclr1 (1'b0),
            .addressstall_a (1'b0),
            .addressstall_b (1'b0),
            .byteena_a (1'b1),
            .byteena_b (1'b1),
            .clock1 (1'b1),
            .clocken0 (1'b1),
            .clocken1 (1'b1),
            .clocken2 (1'b1),
            .clocken3 (1'b1),
            .data_b ({4{1'b1}}),
            .eccstatus (),
            .q_a (),
            .rden_a (1'b1),
            .rden_b (1'b1),
            .wren_b (1'b0));
   defparam
      altsyncram_component.address_aclr_b = "NONE",
      altsyncram_component.address_reg_b = "CLOCK0",
      altsyncram_component.clock_enable_input_a = "BYPASS",
      altsyncram_component.clock_enable_input_b = "BYPASS",
      altsyncram_component.clock_enable_output_b = "BYPASS",
      altsyncram_component.intended_device_family = "Cyclone V",
      altsyncram_component.lpm_type = "altsyncram",
      altsyncram_component.numwords_a = 65535,
      altsyncram_component.numwords_b = 65535,
      altsyncram_component.init_file = "./roms/sound_library.mif",
      altsyncram_component.operation_mode = "DUAL_PORT",
      altsyncram_component.outdata_aclr_b = "NONE",
      altsyncram_component.outdata_reg_b = "CLOCK0",
      altsyncram_component.power_up_uninitialized = "FALSE",
      altsyncram_component.read_during_write_mode_mixed_ports = "DONT_CARE",
      altsyncram_component.widthad_a = 16,
      altsyncram_component.widthad_b = 16,
      altsyncram_component.width_a = 4,
      altsyncram_component.width_b = 4,
      altsyncram_component.width_byteena_a = 1;

endmodule


/* Temporary storage to hold tape images uploaded from the SD card until EDSAC processes them */
module edsac_tape_ram (
   address_a,
   address_b,
   clock_a,
   clock_b,
   data_a,
   data_b,
   wren_a,
   wren_b,
   q_a,
   q_b);

   input [11:0]  address_a;
   input [11:0]  address_b;
   input   clock_a;
   input   clock_b;
   input [7:0]  data_a;
   input [7:0]  data_b;
   input   wren_a;
   input   wren_b;
   output   [7:0]  q_a;
   output   [7:0]  q_b;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
   tri1    clock_a;
   tri0    wren_a;
   tri0    wren_b;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

   wire [7:0] sub_wire0;
   wire [7:0] sub_wire1;
   // wire [7:0] q_a = sub_wire0[7:0];
   wire [7:0] q_a = sub_wire0[7:0];
   wire [7:0] q_b = sub_wire1[7:0]  ^ 5'b10000;

   altsyncram  altsyncram_component (
            .address_a (address_a),
            .address_b (address_b),
            .clock0 (clock_a),
            .clock1 (clock_b),
            .data_a (data_a),
            .data_b (data_b),
            .wren_a (wren_a),
            .wren_b (wren_b),
            .q_a (sub_wire0),
            .q_b (sub_wire1),
            .aclr0 (1'b0),
            .aclr1 (1'b0),
            .addressstall_a (1'b0),
            .addressstall_b (1'b0),
            .byteena_a (1'b1),
            .byteena_b (1'b1),
            .clocken0 (1'b1),
            .clocken1 (1'b1),
            .clocken2 (1'b1),
            .clocken3 (1'b1),
            .eccstatus (),
            .rden_a (1'b1),
            .rden_b (1'b1));
   defparam
      altsyncram_component.address_reg_b = "CLOCK1",
      altsyncram_component.clock_enable_input_a = "BYPASS",
      altsyncram_component.clock_enable_input_b = "BYPASS",
      altsyncram_component.clock_enable_output_a = "BYPASS",
      altsyncram_component.clock_enable_output_b = "BYPASS",
      altsyncram_component.indata_reg_b = "CLOCK1",
      altsyncram_component.intended_device_family = "Cyclone V",
      altsyncram_component.lpm_type = "altsyncram",
      altsyncram_component.init_file = "./roms/blank_tape_ram.mif",
      altsyncram_component.numwords_a = 4096,
      altsyncram_component.numwords_b = 4096,
      altsyncram_component.operation_mode = "BIDIR_DUAL_PORT",
      altsyncram_component.outdata_aclr_a = "NONE",
      altsyncram_component.outdata_aclr_b = "NONE",
      altsyncram_component.outdata_reg_a = "CLOCK0",
      altsyncram_component.outdata_reg_b = "CLOCK1",
      altsyncram_component.power_up_uninitialized = "FALSE",
      altsyncram_component.read_during_write_mode_port_a = "NEW_DATA_NO_NBE_READ",
      altsyncram_component.read_during_write_mode_port_b = "NEW_DATA_NO_NBE_READ",
      altsyncram_component.widthad_a = 12,
      altsyncram_component.widthad_b = 12,
      altsyncram_component.width_a = 8,
      altsyncram_component.width_b = 8,
      altsyncram_component.width_byteena_a = 1,
      altsyncram_component.width_byteena_b = 1,
      altsyncram_component.wrcontrol_wraddress_reg_b = "CLOCK1";


endmodule

/* Stores compressed background images for scope and panel. 
   Supports writing from userspace as well to prevent recompile when tweaking the images */
module image_library (
   clock,
   data,
   rdaddress,
   wraddress,
   wren,
   q);

   input   clock;
   input [7:0]  data;
   input [16:0]  rdaddress;
   input [16:0]  wraddress;
   input   wren;
   output   [7:0]  q;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
   tri1    clock;
   tri0    wren;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

   wire [7:0] sub_wire0;
   wire [7:0] q = sub_wire0[7:0];

   altsyncram  altsyncram_component (
            .address_a (wraddress),
            .address_b (rdaddress),
            .clock0 (clock),
            .data_a (data),
            .wren_a (wren),
            .q_b (sub_wire0),
            .aclr0 (1'b0),
            .aclr1 (1'b0),
            .addressstall_a (1'b0),
            .addressstall_b (1'b0),
            .byteena_a (1'b1),
            .byteena_b (1'b1),
            .clock1 (1'b1),
            .clocken0 (1'b1),
            .clocken1 (1'b1),
            .clocken2 (1'b1),
            .clocken3 (1'b1),
            .data_b ({8{1'b1}}),
            .eccstatus (),
            .q_a (),
            .rden_a (1'b1),
            .rden_b (1'b1),
            .wren_b (1'b0));
   defparam
      altsyncram_component.address_aclr_b = "NONE",
      altsyncram_component.address_reg_b = "CLOCK0",
      altsyncram_component.clock_enable_input_a = "BYPASS",
      altsyncram_component.clock_enable_input_b = "BYPASS",
      altsyncram_component.clock_enable_output_b = "BYPASS",
      altsyncram_component.init_file = "./roms/rle_combined.mif",
      altsyncram_component.intended_device_family = "Cyclone V",
      altsyncram_component.lpm_type = "altsyncram",
      altsyncram_component.numwords_a = 131072,
      altsyncram_component.numwords_b = 131072,
      altsyncram_component.operation_mode = "DUAL_PORT",
      altsyncram_component.outdata_aclr_b = "NONE",
      altsyncram_component.outdata_reg_b = "CLOCK0",
      altsyncram_component.power_up_uninitialized = "FALSE",
      altsyncram_component.read_during_write_mode_mixed_ports = "DONT_CARE",
      altsyncram_component.widthad_a = 17,
      altsyncram_component.widthad_b = 17,
      altsyncram_component.width_a = 8,
      altsyncram_component.width_b = 8,
      altsyncram_component.width_byteena_a = 1;


endmodule


/* Main EDSAC memory */
module edsac_memory (
   address_a,
   address_b,
   byteena_a,
   byteena_b,
   clock_a,
   clock_b,
   data_a,
   data_b,
   wren_a,
   wren_b,
   q_a,
   q_b);

   input [8:0]  address_a;
   input [8:0]  address_b;
   input [3:0]  byteena_a;
   input [3:0]  byteena_b;
   input   clock_a;
   input   clock_b;
   input [35:0]  data_a;
   input [35:0]  data_b;
   input   wren_a;
   input   wren_b;
   output   [35:0]  q_a;
   output   [35:0]  q_b;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
   tri1  [3:0]  byteena_a;
   tri1  [3:0]  byteena_b;
   tri1    clock_a;
   tri0    wren_a;
   tri0    wren_b;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

   wire [35:0] sub_wire0;
   wire [35:0] sub_wire1;
   wire [35:0] q_a = sub_wire0[35:0];
   wire [35:0] q_b = sub_wire1[35:0];

   altsyncram  altsyncram_component (
            .address_a (address_a),
            .address_b (address_b),
            .byteena_a (byteena_a),
            .byteena_b (byteena_b),
            .clock0 (clock_a),
            .clock1 (clock_b),
            .data_a (data_a),
            .data_b (data_b),
            .wren_a (wren_a),
            .wren_b (wren_b),
            .q_a (sub_wire0),
            .q_b (sub_wire1),
            .aclr0 (1'b0),
            .aclr1 (1'b0),
            .addressstall_a (1'b0),
            .addressstall_b (1'b0),
            .clocken0 (1'b1),
            .clocken1 (1'b1),
            .clocken2 (1'b1),
            .clocken3 (1'b1),
            .eccstatus (),
            .rden_a (1'b1),
            .rden_b (1'b1));
   defparam
      altsyncram_component.address_reg_b = "CLOCK1",
      altsyncram_component.byteena_reg_b = "CLOCK1",
      altsyncram_component.byte_size = 9,
      altsyncram_component.clock_enable_input_a = "BYPASS",
      altsyncram_component.clock_enable_input_b = "BYPASS",
      altsyncram_component.clock_enable_output_a = "BYPASS",
      altsyncram_component.clock_enable_output_b = "BYPASS",
      altsyncram_component.indata_reg_b = "CLOCK1",
      altsyncram_component.init_file = "./roms/initial_v2.mif",
      altsyncram_component.intended_device_family = "Cyclone V",
      altsyncram_component.lpm_type = "altsyncram",
      altsyncram_component.numwords_a = 512,
      altsyncram_component.numwords_b = 512,
      altsyncram_component.operation_mode = "BIDIR_DUAL_PORT",
      altsyncram_component.outdata_aclr_a = "NONE",
      altsyncram_component.outdata_aclr_b = "NONE",
      altsyncram_component.outdata_reg_a = "CLOCK0",
      altsyncram_component.outdata_reg_b = "CLOCK1",
      altsyncram_component.power_up_uninitialized = "FALSE",
      altsyncram_component.read_during_write_mode_port_a = "NEW_DATA_NO_NBE_READ",
      altsyncram_component.read_during_write_mode_port_b = "NEW_DATA_NO_NBE_READ",
      altsyncram_component.widthad_a = 9,
      altsyncram_component.widthad_b = 9,
      altsyncram_component.width_a = 36,
      altsyncram_component.width_b = 36,
      altsyncram_component.width_byteena_a = 4,
      altsyncram_component.width_byteena_b = 4,
      altsyncram_component.wrcontrol_wraddress_reg_b = "CLOCK1";


endmodule
