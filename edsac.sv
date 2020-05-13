/* ================================================================
 * EDSAC
 *
 * Copyright (C) 2020 Hrvoje Cavrak
 *
 * Permission is hereby granted, free of charge, to any person 
 * obtaining a copy of this software and associated documentation 
 * files (the "Software"), to deal in the Software without 
 * restriction, including without limitation the rights to use, 
 * copy, modify, merge, publish, distribute, sublicense, and/or 
 * sell copies of the Software, and to permit persons to whom 
 * the Software is furnished to do so, subject to the following 
 * conditions:
 * 
 * The above copyright notice and this permission notice shall be 
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES 
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR 
 * OTHER DEALINGS IN THE SOFTWARE.
 * ================================================================
 */

module emu
(
   //Master input clock
   input         CLK_50M,

   //Async reset from top-level module.
   //Can be used as initial reset.
   input         RESET,

   //Must be passed to hps_io module
   inout  [45:0] HPS_BUS,

   //Base video clock. Usually equals to CLK_SYS.
   output        CLK_VIDEO,

   //Multiple resolutions are supported using different CE_PIXEL rates.
   //Must be based on CLK_VIDEO
   output        CE_PIXEL,

   //Video aspect ratio for HDMI. Most retro systems have ratio 4:3.
   output  [7:0] VIDEO_ARX,
   output  [7:0] VIDEO_ARY,

   output  [7:0] VGA_R,
   output  [7:0] VGA_G,
   output  [7:0] VGA_B,
   output        VGA_HS,
   output        VGA_VS,
   output        VGA_DE,    // = ~(VBlank | HBlank)
   output        VGA_F1,
   output  [1:0] VGA_SL,

   output        LED_USER,  // 1 - ON, 0 - OFF.
   output  [1:0] LED_POWER,
   output  [1:0] LED_DISK,

   output  [1:0] BUTTONS,

   output [15:0] AUDIO_L,
   output [15:0] AUDIO_R,
   output        AUDIO_S,   // 1 - signed audio samples, 0 - unsigned
   output  [1:0] AUDIO_MIX, // 0 - no mix, 1 - 25%, 2 - 50%, 3 - 100% (mono)

   //ADC
   inout   [3:0] ADC_BUS,

   //SD-SPI
   output        SD_SCK,
   output        SD_MOSI,
   input         SD_MISO,
   output        SD_CS,
   input         SD_CD,

   //High latency DDR3 RAM interface
   //Use for non-critical time purposes
   output        DDRAM_CLK,
   input         DDRAM_BUSY,
   output  [7:0] DDRAM_BURSTCNT,
   output [28:0] DDRAM_ADDR,
   input  [63:0] DDRAM_DOUT,
   input         DDRAM_DOUT_READY,
   output        DDRAM_RD,
   output [63:0] DDRAM_DIN,
   output  [7:0] DDRAM_BE,
   output        DDRAM_WE,

   //SDRAM interface with lower latency
   output        SDRAM_CLK,
   output        SDRAM_CKE,
   output [12:0] SDRAM_A,
   output  [1:0] SDRAM_BA,
   inout  [15:0] SDRAM_DQ,
   output        SDRAM_DQML,
   output        SDRAM_DQMH,
   output        SDRAM_nCS,
   output        SDRAM_nCAS,
   output        SDRAM_nRAS,
   output        SDRAM_nWE,

   input         UART_CTS,
   output        UART_RTS,
   input         UART_RXD,
   output        UART_TXD,
   output        UART_DTR,
   input         UART_DSR,

   // Open-drain User port.
   // 0 - D+/RX
   // 1 - D-/TX
   // 2..6 - USR2..USR6
   // Set USER_OUT to 1 to read from USER_IN.
   input   [6:0] USER_IN,
   output  [6:0] USER_OUT,

   input         OSD_STATUS
);

assign {SD_SCK, SD_MOSI, SD_CS} = 'Z;
assign {SDRAM_CLK, SDRAM_CKE, SDRAM_A, SDRAM_BA, SDRAM_DQ, SDRAM_DQML, SDRAM_DQMH, SDRAM_nCS, SDRAM_nCAS, SDRAM_nRAS, SDRAM_nWE} = 'Z;
assign {DDRAM_CLK, DDRAM_BURSTCNT, DDRAM_ADDR, DDRAM_DIN, DDRAM_RD, DDRAM_BE, DDRAM_WE} = 'Z;

assign {UART_RTS, UART_TXD, UART_DTR} = 'Z;
assign {BUTTONS, VGA_SL} = 'Z;

assign LED_USER  = ioctl_download;
assign LED_DISK  = 0;
assign LED_POWER = 0;

assign USER_OUT  = '1;
assign VGA_F1    = 0;

assign VIDEO_ARX = status[1] ? 8'd4 : 8'd16;
assign VIDEO_ARY = status[1] ? 8'd3 : 8'd9;

`include "build_id.v"
`include "util.sv"
localparam CONF_STR = 
{
   "EDSAC;;",
   "-;",
   "F1,TAP,Load tape;",
   "-;",
   "OG,Tape Reader Speed,Normal,Fast;",
   "OF,Initial Orders ver,2,1;",
   "OE,Tank group,One,Two;",
   "O36,Memory Tank,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15;",
   "O1,Aspect Ratio,16:9,4:3;",
   "V,v0.3.",`BUILD_DATE
};

/* 00 = CRT, 01 = Teletype, 10 = Panel, 11 = N/A */
reg [1:0] active_mode;                                         

////////////////////   CLOCKS   ///////////////////

wire clk_vid, clk_sys;

video_pll pll (
        .refclk(CLK_50M),
        .rst(0),
        .outclk_0(clk_vid)        
);

assign clk_sys = CLK_50M;

///////////////////////////////////////////////////
// Connection to the HPS
///////////////////////////////////////////////////

wire [31:0] status;
wire  [1:0] buttons;

// Tape upload signals from the HPS side
wire        ioctl_download;
wire  [7:0] ioctl_index;
wire        ioctl_wr;
wire [26:0] ioctl_addr;
wire  [7:0] ioctl_dout;
wire [31:0] ioctl_file_ext;

wire [10:0] ps2_key;

hps_io #(.STRLEN($size(CONF_STR)>>3)) hps_io
(
   .clk_sys(clk_sys),
   .HPS_BUS(HPS_BUS),

   .conf_str(CONF_STR),

   .buttons(buttons),
   .status(status),

   .ps2_key(ps2_key),

   .ioctl_download(ioctl_download),
   .ioctl_index(ioctl_index),
   .ioctl_wr(ioctl_wr),
   .ioctl_addr(ioctl_addr),
   .ioctl_dout(ioctl_dout)
);

///////////////////////////////////////////////////
// CPU
///////////////////////////////////////////////////

/* Internal signals exported for the panel display */

wire [70:0] o_abc;
wire [34:0] o_rs;
wire [9:0] o_scr;
wire [16:0] o_ir;
wire [10:0] o_phase;

/* With abundance of time, run CPU only during blanking periods so nothing on the screen 
   will tear and nothing needs to be latched. Also, delay tape reader/printer character 
   reading/writing to ~6 CPS, to make it more realistic 
*/
wire cpu_enable = (vc > 730 && tape_read_wait == 0 && char_read_wait == 0);

reg cpu_resume = 1'b0;
wire cpu_running;
reg old_cpu_running;

edsac_cpu cpu(
   .clock(clk_sys),
   .cpu_addr_out(cpu_addr_out),
   .memory_wren(memory_wren),
   .cpu_data_out(cpu_data_out[34:0]),
   .memory_in(memory_in[34:0]),
   .enable(cpu_enable),
   .resume(cpu_resume),
   .reset(cpu_reset),
   .cpu_halt(cpu_halt),
   .cpu_running(cpu_running),
   .rotary_dial_in(rotary_dial),
    
   .tape_read_strobe(tape_read_strobe),
   .tape_data_in(tape_ram_data[4:0]),
   
   .character_strobe(character_strobe),
   .character(character),

   // Output internals for displaying on panel/scope
   .o_abc(o_abc),
   .o_rs(o_rs),
   .o_scr(o_scr),
   .o_ir(o_ir),
   .o_phase(o_phase)
    
);


///////////////////////////////////////////////////
// Memory
///////////////////////////////////////////////////

wire [35:0] memory_in;
wire [35:0] cpu_data_out;
wire [8:0]  cpu_addr_out;
wire memory_wren;

edsac_memory ram(
   .address_a(cpu_addr_out),
   .address_b(video_addr),
   .byteena_a(4'b1111),
   .byteena_b(4'b1111),
   .clock_a(clk_sys),
   .clock_b(clk_vid),
   .data_a(cpu_data_out),
   .data_b({1'b0, bstrap_data}),
   .wren_a(memory_wren),
   .wren_b(write_bootloader),
   .q_a(memory_in),
   .q_b(ram_video_data)
);


////////////////////////////////////////////////////////////////////
// Tape reader                                                    //
////////////////////////////////////////////////////////////////////

wire tape_read_strobe;

reg [11:0] tape_ram_addr;
wire [7:0] tape_ram_data;

reg [11:0] tape_video_ram_addr;
wire [7:0] tape_video_ram_data;

reg [23:0] tape_read_wait, 
           char_read_wait;

/* Temporary buffer where TAP image gets written when received from HPS */
edsac_tape_ram tape_ram (
   .clock_a(clk_sys),
   .data_a(ioctl_dout),
   .address_a(ioctl_download ? ioctl_addr[11:0] : tape_ram_addr),
   .wren_a(ioctl_wr & ioctl_download),
   .q_a(tape_ram_data),
   
   .clock_b(clk_vid),
   .wren_b(1'b0),
   .address_b(tape_video_ram_addr),
   .q_b(tape_video_ram_data)
);


////////////////////////////////////////////////////////////////////
// Audio                                                          //
////////////////////////////////////////////////////////////////////

assign AUDIO_S = 1'b1;
assign AUDIO_MIX = 2'b0;

reg [12:0] snd_wait = 0;
reg [15:0] soundlib_addr;

wire [3:0] sound_adpcm;
wire [12:0] adpcm_out;

/* Memory that holds compressed samples */
sound_lib soundlib (
   .clock(clk_sys),
   .rdaddress(soundlib_addr),
   .wren(1'b0),
   .q(sound_adpcm)
);
   
/* ADPCM that decodes 4 bit chunks into 12 bit raw audio */
adpcm_decoder adpcm (
   .reset(sound_duration == 0),
   .clock(snd_wait == 0),
   .in_pcm(sound_adpcm),
   .sample(adpcm_out)
);

assign AUDIO_L = { adpcm_out, 4'b0 };
assign AUDIO_R = { adpcm_out, 4'b0 };

reg [15:0] sound_duration;
reg sound_loop;

always @(posedge clk_sys)
begin

   old_tape_read_strobe <= tape_read_strobe;
   old_character_strobe <= character_strobe;
   old_cpu_running <= cpu_running;
   
   char_read_wait <= char_read_wait > 0 ? char_read_wait - 1'b1 : 24'b0;
   
   /* For smoother sound looping, if sound runs out, clear tape_read_wait so new instruction will kick off another cycle */
   tape_read_wait <= tape_read_wait > 0 && sound_duration > 0 ? tape_read_wait - 1'b1 : 24'b0;     

   /* Sounds: Keypress  (0000 - 4160,   = 4160  bytes)
              Bell      (4160 - 24014,  = 19854 bytes)
              Tape read (24014 - 65462, = 41448 bytes) */
   
	/* If sample is still playing, increment the address counter (output another chunk) every 4167 clocks, that is @ 12 kHz */
   if (sound_duration > 0)
   begin
      snd_wait <= snd_wait < 13'd4166 ? snd_wait + 1'b1 : 13'd0;                                // 12 kHz OKI ADPCM, 4167 @ 50MHz
      
      if (snd_wait == 0) begin
         soundlib_addr <= soundlib_addr + 1'b1;
         sound_duration <= sound_duration - 1'b1;
      end
   end
   
   /* Allow starting a new clip only if no existing one is currently playing */
   else begin
      snd_wait <= 0;

      if((active_mode == 2'b10) & ~old_tape_read_strobe && tape_read_strobe)                    // Tape reader
            begin
               soundlib_addr <= 16'd24014;
               sound_duration <= 16'd41448;
            end
      
      else if((active_mode == 2'b01) & ~old_character_strobe & character_strobe)                // Teleprinter key
            begin
               if(character != 5'b10100) begin                                                  // Don't sound on space, but keep the delay
                  soundlib_addr <= 16'd0600;
                  sound_duration <= 16'd1800;
               end
               
               char_read_wait <= 24'd9000000;
            end      
   end         
      
   if(cpu_reset || ioctl_download) begin
      tape_ram_addr <= {13{1'b1}};                                                              // On next (first) read strobe the address will overflow to 0
   end
	
   else if(~old_tape_read_strobe && tape_read_strobe) begin
      tape_ram_addr <= tape_ram_addr + 1'b1; 
      tape_read_wait <= ~status[16] ? 24'd4000000 : 24'd0;                                      // If fast read is enabled, don't wait at all
   end      

   /* This is allowed to interrupt the sound already playing */
   else if(old_cpu_running & ~cpu_running)                                                      // Bell
      begin
         soundlib_addr <= 16'd4160;
         sound_duration <= 16'd19854;
      end         
   
end


////////////////////////////////////////////////////////////////////
// Video                                                          //
////////////////////////////////////////////////////////////////////

reg [7:0] pix, pix_r, pix_g, pix_b;

wire HSync, VSync;

assign VGA_HS = HSync;
assign VGA_VS = VSync;

assign CLK_VIDEO = clk_vid;
assign CE_PIXEL  = 1'b1;

reg  [10:0] hc;
reg  [10:0] vc;

wire [35:0] ram_video_data;
reg  [10:0] screen_x, screen_y, scr_x, scr_y;
reg  [8:0] video_addr;

wire [7:0] fb_pixel;

wire rle_wren = (ioctl_download & ioctl_wr & (ioctl_index[5:0] == 6'd2));

assign VGA_G = (active_mode == 1) ? tty_g : pix_g;
assign VGA_R = (active_mode == 1) ? tty_r : pix_r;
assign VGA_B = (active_mode == 1) ? tty_b : pix_b;
assign VGA_DE = ((hc < 11'd1280) && (vc < 11'd720));       

rle_framebuffer fb(
   .clock(clk_vid),
   .enable(fb_en | (ioctl_download && ioctl_index[5:0] == 2)),
   .sync(fb_sync),
   .pixel(fb_pixel),
   .active_mode(active_mode),
   
   .data(ioctl_dout),
   .wraddress(ioctl_addr),
   .wren(rle_wren),
   
   .status(status)
);

reg [10:0] symbol_addr;
wire [15:0] symbol_out;

teletype_charset symbol (
   .address(symbol_addr),
   .clock(clk_vid),
   .q(symbol_out)
);

/* Simple function that returns true if current horizontal/vertical counters lie within 
   a box bound by the coordinates passed as arguments */
function [7:0] within_box;                                    
   input [10:0] x1;
   input [10:0] y1;
   input [10:0] x2;
   input [10:0] y2;
begin   
   return (hc > x1 && vc > y1 && hc < x2 && vc < y2);
end
endfunction


reg fb_sync, fb_en;

/* Three bulbs on the main panel */
wire [8:0] signal_bulbs = {1'b0, |{tape_read_wait, char_read_wait}, 2'b0, ~cpu_running, 2'b0, o_abc[70], 1'b0};
wire [30:0] random_data;

random lfsr(
   .clock(clk_vid),
   .lfsr(random_data)
);


/* The ugly part of video / panel / scope generation. Target resolution is 720p60. */

always @(posedge clk_vid) begin
   hc <= hc + 1'd1;
   
   if(hc == 11'd1623) begin                                               // End of horizontal line, both visible and blanking
      hc <= 11'd0;
      vc <= (vc == 11'd764) ? 0 : vc + 1'd1;                              // End of vertical frame, both visible and blanking
   end

   if(hc == 11'd1390) HSync <= 1'b1;                                      // Horizontal sync impulse
   if(hc == 11'd1420) HSync <= 1'b0;
   if(vc == 11'd725) VSync <= 1'b1;                                       // Vertical sync impulse
   if(vc == 11'd730) VSync <= 1'b0;
   
   screen_x <= hc > 11'd503  && hc < 11'd785 ? hc - 11'd504 : 11'h0;      // Offset to center, used for scope
   screen_y <= vc > 11'd175  && vc < 11'd305 ? vc - 11'd176 : 11'h0;      // Offset to center
 
   scr_x <= hc > 11'd511  && hc < 11'd1050 ? hc - 11'd511 : 11'h0;        // Offset to center, used for panel
   scr_y <= vc > 11'd435  && vc < 11'd705 ? vc - 11'd435 : 11'h0;         // Offset to center

   fb_en <= (hc < 11'd1275 || hc > 11'd1618);                             // RLE framebuffer enable signal, triggers 5T early.
   fb_sync <= (hc == 11'd1619 && vc == 11'd764);                          // This sync signal pulses when complete frame is drawn
   
   pix <= (hc > 11'd15 && hc < 11'd1265) ? fb_pixel : 8'b0; 				  // Trim the left and right borders

	
   // If we need to write the bootloader, use B side of dual-port RAM because it's used only for reading.
   // However, we need something to count the addresses and we'll use horizontal counter used for video generation
   // and we'll do that in last line of video that's outside of visible area 
   
   if (active_mode == 2'b00)  	/* ------------- CRT ------------- */
   begin
      video_addr <= write_bootloader ? hc[8:0] : {status[14], status[6:3], ~screen_y[6:3]};     
      {pix_r, pix_g, pix_b} <= {3{pix}};     
      
      /* Center scope display of selected memory tank */
      if (within_box(503, 175, 785, 304)) begin
         pix_g <= ram_video_data[34-screen_x[8:3]] ? px_add(fb_pixel, calc_pix(hc[2:0], vc[2:0])) : fb_pixel;
      end
      
      /* Sequence control register */
      else if (within_box(1011, 207, 1095, 260)) begin      
         pix_g <= o_scr[8'd135-hc[10:3]] && hc[2:0] == 0 ? px_add(fb_pixel, 8'hfe) : fb_pixel;
      end
            
      /* Phase */
      else if (within_box(159, 207, 301, 260)) begin
         pix_g <= o_phase[21-hc[8:3]] && hc[2:0] == 0 ? px_add(fb_pixel, 8'hfe) : fb_pixel;
      end
      
      
      /* Phase (left scope) random noise */
      if (within_box(110, 257 + random_data[2:0], 350, 265 - random_data[2:0])) begin
         pix_g <= random_data[3:0] != 0 ? px_add(random_data[8:1], fb_pixel) : fb_pixel;
      end
      
      /* Right scope random noise */
      if (within_box(940, 257 + random_data[4:2], 1184, 265 - random_data[4:2])) begin      
         pix_g <= random_data[3:0] != 0 ? px_add(random_data[8:1], fb_pixel) : fb_pixel;
      end

      
   end
   
   else if(active_mode == 2'b10) 	/* ------------- PANEL ------------- */
   begin
      video_addr <= write_bootloader ? hc[8:0] : {scr_x[8:7], scr_y[7:1]};
      symbol_addr <= {tape_ram_data[4:0] < 11, tape_ram_data[4:0], vc[5:1]};     
      {pix_r, pix_g, pix_b} <= get_color(pix);     

      /* Symbol */
      if (within_box(353, 520, 388, 581))
            pix <= symbol_out[4'd0 - hc[4:1]] ? 8'b1 : fb_pixel;                          
      
      /* TAPE */
      else if (within_box(107, 101, 190, 704) && hc[3]==0 && vc[3]==0) begin
         if (tape_video_ram_data[4'd11 - hc[7:4]] && vc[9:4] != 24)         
            pix <= is_circle_16({hc[2:0], 2'b01}, {vc[2:0], 2'b01}) ? 8'h1 : fb_pixel;                   
      end
   
      /* Memory */
      else if (within_box(513, 435, 999, 691)) begin
         pix <= ~write_bootloader & ram_video_data[scr_x[6:1] - 2] ? 8'b1 : fb_pixel;
      end   

      /* Main signal bulbs */
      else if (within_box(959, 223, 1231, 257) && is_circle_16(hc[4:0], vc[4:0]))
            pix <= signal_bulbs[hc[10:5] - 30] ? 8'hfe : fb_pixel;
      
      /* Main registers */
      else if (is_circle_8(hc[3:0], vc[3:0])) begin

         /* Acc HI */
         if (within_box(319, 207, 881, 224))        
            pix <= o_abc[7'd89 - hc[10:4]] ? 8'hfe : 8'h22;                               
      
         /* Acc LO */
         if (within_box(319, 239, 881, 256))
            pix <= o_abc[7'd54 - hc[10:4]] ? 8'hfe : 8'h22;                               
         
         /* RS register */
         if (within_box(319, 335, 881, 352))
            pix <= o_rs[7'd54 - hc[10:4]] ? 8'hfe : 8'h22;           

         /* Order Tank (Instruction Register) */
         if (within_box(959, 335, 1231, 352))
            pix <= o_ir[76 - hc[10:4]] ? 8'hfe : 8'h22;                                  
            
      end
                  
   end
        
   tape_video_ram_addr <= vc[10:4] - 12'd25 + tape_ram_addr;                             
                                                                                         
end

////////////////////////////////////////////////////////////////////
// Teletype                                                       //
////////////////////////////////////////////////////////////////////

wire [4:0] character;
wire character_strobe;
reg tty_erase = 0;
wire [7:0] tty_g, tty_r, tty_b;

teletype tty (
   .clk(clk_vid),
   .horizontal_counter(hc),
   .vertical_counter(vc),
   .erase(tty_erase),
   .red_out(tty_r),
   .green_out(tty_g),
   .blue_out(tty_b),
   .char_in(character),
   .character_strobe(character_strobe)
);


////////////////////////////////////////////////////////////////////
// Keyboard / Rotary Dial                                         //
////////////////////////////////////////////////////////////////////

reg [4:0] rotary_dial = 0;
wire pressed    = ps2_key[9];
wire [8:0] code = ps2_key[8:0];

reg old_tape_read_strobe;
reg old_character_strobe;

reg cpu_reset = 0;
reg cpu_halt = 0;
reg old_state;

always @(posedge clk_sys) begin
   old_state <= ps2_key[10];
   
   if(old_state != ps2_key[10]) begin              
      case(code[7:0])       
         8'h45: rotary_dial <= 5'd20;        // 0 Adds 2 * 10 instead of 0, to differentiate between 0 dialed and nothing dialed
         8'h16: rotary_dial <= 5'd2;         // 1 adds 2
         8'h1E: rotary_dial <= 5'd4;         // 2 adds 4
         8'h26: rotary_dial <= 5'd6;         // ... etc, n adds n * 2
         8'h25: rotary_dial <= 5'd8;
         8'h2E: rotary_dial <= 5'd10;
         8'h36: rotary_dial <= 5'd12;
         8'h3D: rotary_dial <= 5'd14;
         8'h3E: rotary_dial <= 5'd16;
         8'h46: rotary_dial <= 5'd18;
                        
         8'h05: active_mode <= 2'b00;        // F1 = CRT 
         8'h06: active_mode <= 2'b01;        // F2 = Teletype
         8'h04: active_mode <= 2'b10;        // F3 = Panel

         8'h43: write_bootloader <= 1'b1;    // I = Initial Orders Write
         8'h24: tty_erase <= pressed;        // E = Erase Teleprinter Screen        
         8'h2D: begin
                   cpu_reset <= pressed;     // R = Reset
                   rotary_dial <= 5'd0;
                end
         8'h33: cpu_halt <= pressed;         // H = Halt
         8'h21: cpu_resume <= pressed;       // C = Continue Execution (resume)        
      endcase
   end
   
   if(fb_sync)
      write_bootloader <= 1'b0;              // Disable bootloader write logic at a known state.
                  
end


////////////////////////////////////////////////////////////////////
// Initial Orders / Bootstrap                                     //
////////////////////////////////////////////////////////////////////

reg [34:0] bstrap_data = 35'd0;
wire bootloader_version = status[15];
reg write_bootloader;

wire bootstrap_clk = write_bootloader & clk_vid;

    
/* After powering on, there need to be some instructions to execute. There are 2 versions of the 
   EDSAC bootloader - the very basic one from May 1949 and a more advanced one from September. Most
   programs use V2, but a few original ones still load with V1. 
   
   Writing is done by (ab)using the 2nd RAM port used to display memory contents. When upload mode
   is on, instead of just reading, memory is written when its address corresponds to bootloader 
   instruction location.
*/  
    
always @(posedge bootstrap_clk) begin
         
   if(~bootloader_version)

   /* Initial orders version 2 (September 1949) */
   case (video_addr)
      // Addresses off by 1 in pipeline to match correct address with data
      9'd511: bstrap_data <= {i_E, 11'b_0_0000010100, SHORT, 1'b0, i_T, 11'b_0_0000000000, SHORT};       // (TS) m[0] = A; ABC = 0,      (E20S) if A >= 0 goto 20 
      9'd000: bstrap_data <= {i_U, 11'b_0_0000000010, SHORT, 1'b0, i_P, 11'b_0_0000000001, SHORT};       // (P1S) ,      (U2S) m[2] = A 
      9'd001: bstrap_data <= {i_R, 11'b_0_0000000100, SHORT, 1'b0, i_A, 11'b_0_0000100111, SHORT};       // (A39S) A += m[39],      (R4S) ABC >>= 4 
      9'd002: bstrap_data <= {i_L, 11'b_0_0000001000, SHORT, 1'b0, i_V, 11'b_0_0000000000, SHORT};       // (VS) AB += m[0] * R,      (L8S) ABC <<= 5 
      9'd003: bstrap_data <= {i_I, 11'b_0_0000000001, SHORT, 1'b0, i_T, 11'b_0_0000000000, SHORT};       // (TS) m[0] = A; ABC = 0,      (I1S) m[1] = read() 
      9'd004: bstrap_data <= {i_S, 11'b_0_0000100111, SHORT, 1'b0, i_A, 11'b_0_0000000001, SHORT};       // (A1S) A += m[1],      (S39S) A -= m[39] 
      9'd005: bstrap_data <= {i_L, 11'b_0_0000000000, LONG , 1'b0, i_G, 11'b_0_0000000100, SHORT};       // (G4S) if A < 0 goto 4,      (LL) ABC <<= 1 
      9'd006: bstrap_data <= {i_E, 11'b_0_0000010001, SHORT, 1'b0, i_S, 11'b_0_0000100111, SHORT};       // (S39S) A -= m[39],      (E17S) if A >= 0 goto 17 
      9'd007: bstrap_data <= {i_A, 11'b_0_0000100011, SHORT, 1'b0, i_S, 11'b_0_0000000111, SHORT};       // (S7S) A -= m[7],      (A35S) A += m[35] 
      9'd008: bstrap_data <= {i_A, 11'b_0_0000000000, SHORT, 1'b0, i_T, 11'b_0_0000010100, SHORT};       // (T20S) m[20] = A; ABC = 0,      (AS) A += m[0] 
      9'd009: bstrap_data <= {i_A, 11'b_0_0000101000, SHORT, 1'b0, i_H, 11'b_0_0000001000, SHORT};       // (H8S) R = m[8],      (A40S) A += m[40] 
      9'd010: bstrap_data <= {i_A, 11'b_0_0000010110, SHORT, 1'b0, i_T, 11'b_0_0000101011, SHORT};       // (T43S) m[43] = A; ABC = 0,      (A22S) A += m[22] 
      9'd011: bstrap_data <= {i_T, 11'b_0_0000010110, SHORT, 1'b0, i_A, 11'b_0_0000000010, SHORT};       // (A2S) A += m[2],      (T22S) m[22] = A; ABC = 0 
      9'd012: bstrap_data <= {i_A, 11'b_0_0000101011, SHORT, 1'b0, i_E, 11'b_0_0000100010, SHORT};       // (E34S) if A >= 0 goto 34,      (A43S) A += m[43] 
      9'd013: bstrap_data <= {i_A, 11'b_0_0000101010, SHORT, 1'b0, i_E, 11'b_0_0000001000, SHORT};       // (E8S) if A >= 0 goto 8,      (A42S) A += m[42] 
      9'd014: bstrap_data <= {i_E, 11'b_0_0000011001, SHORT, 1'b0, i_A, 11'b_0_0000101000, SHORT};       // (A40S) A += m[40],      (E25S) if A >= 0 goto 25 
      9'd015: bstrap_data <= {i_T, 11'b_0_0000101010, SHORT, 1'b0, i_A, 11'b_0_0000010110, SHORT};       // (A22S) A += m[22],      (T42S) m[42] = A; ABC = 0 
      9'd016: bstrap_data <= {i_A, 11'b_0_0000101000, LONG , 1'b0, i_I, 11'b_0_0000101000, LONG };       // (I40L) w[40] = read(),      (A40L) AB += w[40] 
      9'd017: bstrap_data <= {i_T, 11'b_0_0000101000, LONG , 1'b0, i_R, 11'b_0_0000010000, SHORT};       // (R16S) ABC >>= 6,      (T40L) w[40] = AB; ABC = 0 
      9'd018: bstrap_data <= {i_P, 11'b_0_0000000101, LONG , 1'b0, i_E, 11'b_0_0000001000, SHORT};       // (E8S) if A >= 0 goto 8,      (P5L)  
      9'd019: bstrap_data <= {i_P, 11'b_0_0000000000, SHORT, 1'b0, i_P, 11'b_0_0000000000, LONG };       // (PL) ,      (PS)
      
      default:
         bstrap_data <= 35'b0;
         
   endcase
   
   /* Initial orders version 1 (May 1949, D. Wheeler) */
   else case (video_addr)
      9'd511: bstrap_data <= {i_H, 11'b_0_0000000010, SHORT, 1'b0, i_T, 11'b_0_0000000000, SHORT};       // (TS) m[0] = A; ABC = 0,      (H2S) R = m[2] 
      9'd000: bstrap_data <= {i_E, 11'b_0_0000000110, SHORT, 1'b0, i_T, 11'b_0_0000000000, SHORT};       // (TS) m[0] = A; ABC = 0,      (E6S) if A >= 0 goto 6 
      9'd001: bstrap_data <= {i_P, 11'b_0_0000000101, SHORT, 1'b0, i_P, 11'b_0_0000000001, SHORT};       // (P1S) ,      (P5S)  
      9'd002: bstrap_data <= {i_I, 11'b_0_0000000000, SHORT, 1'b0, i_T, 11'b_0_0000000000, SHORT};       // (TS) m[0] = A; ABC = 0,      (IS) m[0] = read() 
      9'd003: bstrap_data <= {i_R, 11'b_0_0000010000, SHORT, 1'b0, i_A, 11'b_0_0000000000, SHORT};       // (AS) A += m[0],      (R16S) ABC >>= 6 
      9'd004: bstrap_data <= {i_I, 11'b_0_0000000010, SHORT, 1'b0, i_T, 11'b_0_0000000000, LONG };       // (TL) w[0] = AB; ABC = 0,      (I2S) m[2] = read() 
      9'd005: bstrap_data <= {i_S, 11'b_0_0000000101, SHORT, 1'b0, i_A, 11'b_0_0000000010, SHORT};       // (A2S) A += m[2],      (S5S) A -= m[5] 
      9'd006: bstrap_data <= {i_T, 11'b_0_0000000011, SHORT, 1'b0, i_E, 11'b_0_0000010101, SHORT};       // (E21S) if A >= 0 goto 21,      (T3S) m[3] = A; ABC = 0 
      9'd007: bstrap_data <= {i_L, 11'b_0_0000001000, SHORT, 1'b0, i_V, 11'b_0_0000000001, SHORT};       // (V1S) AB += m[1] * R,      (L8S) ABC <<= 5 
      9'd008: bstrap_data <= {i_T, 11'b_0_0000000001, SHORT, 1'b0, i_A, 11'b_0_0000000010, SHORT};       // (A2S) A += m[2],      (T1S) m[1] = A; ABC = 0 
      9'd009: bstrap_data <= {i_R, 11'b_0_0000000100, SHORT, 1'b0, i_E, 11'b_0_0000001011, SHORT};       // (E11S) if A >= 0 goto 11,      (R4S) ABC >>= 4  
      9'd010: bstrap_data <= {i_L, 11'b_0_0000000000, LONG , 1'b0, i_A, 11'b_0_0000000001, SHORT};       // (A1S) A += m[1],      (LL) ABC <<= 1  
      9'd011: bstrap_data <= {i_T, 11'b_0_0000011111, SHORT, 1'b0, i_A, 11'b_0_0000000000, SHORT};       // (AS) A += m[0],      (T31S) m[31] = A; ABC = 0  
      9'd012: bstrap_data <= {i_A, 11'b_0_0000000100, SHORT, 1'b0, i_A, 11'b_0_0000011001, SHORT};       // (A25S) A += m[25],      (A4S) A += m[4]  
      9'd013: bstrap_data <= {i_S, 11'b_0_0000011111, SHORT, 1'b0, i_U, 11'b_0_0000011001, SHORT};       // (U25S) m[25] = A,      (S31S) A -= m[31]  
      9'd014: bstrap_data <= {i_P, 11'b_0_0000000000, SHORT, 1'b0, i_G, 11'b_0_0000000110, SHORT};       // (G6S) if A < 0 goto 6,      (PS)   
   default:
      bstrap_data <= 35'b0;
   endcase

   
end

endmodule
