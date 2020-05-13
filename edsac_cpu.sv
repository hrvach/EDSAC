`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2020, Hrvoje Cavrak.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
// * Redistributions of source code must retain the above copyright
//   notice, this list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright
//   notice, this list of conditions and the following disclaimer in the
//   documentation and/or other materials provided with the distribution.
// * The names of contributors may not be used to endorse or promote products
//   derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL Thomas Skibo OR CONTRIBUTORS BE LIABLE FOR
// ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
// LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
// OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
// SUCH DAMAGE.
//
//////////////////////////////////////////////////////////////////////////////

`define SWORD 18
`define LWORD 36
`define ACCU_LEN 71


module edsac_cpu
(
   input                    clock,
   input                    enable,
   input  [`LWORD-2:0]      memory_in,
   input                    resume,
   input                    reset,
   input                    cpu_halt,
   
   input  [4:0]             rotary_dial_in,
   input  [4:0]             tape_data_in,
   
   output reg [8:0]         cpu_addr_out,
   output reg [`LWORD-2:0]  cpu_data_out,
   output reg               memory_wren,
   output reg               character_strobe,
   output reg [4:0]         character,
   output reg               tape_read_strobe,
   output                   cpu_running,
   
   output [70:0] o_abc,
   output [34:0] o_rs,
   output [9:0] o_scr,
   output [16:0] o_ir,
   output [10:0] o_phase

);

`include "util.sv"

//////////////////////////////////////////////////////////////
// Registers
//////////////////////////////////////////////////////////////

reg [16:0] IR;                   /* Instruction Register */

reg signed [70:0] ABC = 0;       /* Accumulator */
`define AB ABC[70:36]
`define A ABC[70:54]

reg signed [34:0] RS = 35'd0;    /* Multiplier Register */
`define R RS[34:18]

reg [9:0]  SCR = 0;              /* Sequence Control Register a.k.a. Program Counter */
reg [16:0] OT;                   /* Order Tank a.k.a. Instruction Register */

reg  HALT = 1'b1;                /* Start halted */
reg  NOP;

assign cpu_running = ~HALT;

  /* The order format is:

     0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16
   +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
   |      op      |xx|              address        |SL|
   +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

   op = instruction,
   address = 10 bit address in memory,
   S/L = length code

  */

function integer shift_count;
    input [16:0] value;

    for (shift_count=1; |value && ~value[0]; shift_count=shift_count+1)
        value = value>>1;

endfunction


function signed [70:0] mult;
    input signed [34:0] a;
    input signed [34:0] b;

    mult = (a * b) << 2;                                                                              /* Multiplication needs to be shifted 2 places left to preserve decimal point */

endfunction


function [34:0] short_write;
    input [16:0] word;
    short_write = IR[1] ? {word, memory_in[17:0]} : {memory_in[34:17], word};
endfunction



task exec_instruction;
    input [16:0] instruction;
    input signed [`LWORD-2:0]  memory_in;
    input signed [16:0] short;
begin
    
    `define OPCODE instruction[16:12]
    `define ADDRESS instruction[10:1]
    `define MODE instruction[0]
   
   case (`OPCODE) 
      i_A:   ABC <= ABC + (`MODE ? {memory_in, 36'b0} : {short, 54'b0});
      i_S:   ABC <= ABC - (`MODE ? {memory_in, 36'b0} : {short, 54'b0});
      
      i_H:   RS <= `MODE ? memory_in : {short, 18'b0};                                                // Short RS write destroys lower half as well!

      i_V:   ABC <= ABC + (`MODE ? (memory_in * RS) << 2 : mult({short, 18'b0}, RS));                 // Short mode does not mean whole RS isn't used as well
      i_N:   ABC <= ABC - (`MODE ? (memory_in * RS) << 2 : mult({short, 18'b0}, RS));                 // Short mode does not mean whole RS isn't used as well

      i_C:   ABC <= ABC + (`MODE ? {memory_in & RS, 36'b0} : {short & `R, 54'b0});

      i_T:   begin cpu_data_out <= (`MODE ? `AB : short_write(`A)); ABC <= 71'b0; end
      i_U:   cpu_data_out <= (`MODE ? `AB : short_write(`A)); 

      i_F:   cpu_data_out <= (`MODE ? {character, 30'b0} : short_write({character, 12'b0})); 
      i_I:   cpu_data_out <= (`MODE ? {12'b0, tape_data_in, 18'b0} : short_write({12'b0, tape_data_in})); 

      i_R:   ABC <= ABC >>> shift_count(instruction);
      i_L:   ABC <= ABC << shift_count(instruction);
        
      i_E:   if(~ABC[70]) {SCR, jump} <= {`ADDRESS, 1'b1};                                            /* If A >= 0 (MSB == 0), PC <= address. */
      i_G:   if(ABC[70])  {SCR, jump} <= {`ADDRESS, 1'b1};                                            /* If A < 0  (MSB == 1), PC <= address. */
      
      i_Y:   ABC <= ABC + {35'b0, 1'b1, 35'b0};
   
      i_O:   begin character_strobe <= 1'b1; character <= short[16:12]; end               
      
      i_Z:   HALT <= 1'b1;
      i_X:   NOP <= 1'b1;
      default: HALT <= 1'b1;                                                                          /* Unknown instruction causes HALT */
   endcase
    
end

endtask


/* In order to match the original speed, we have many cycles to waste. 
   Stuff happens only when phase counter is one of these: 
*/
`define PREFETCH 11'b00000000000
`define FETCH    11'b01000000000
`define RD_MEM   11'b01010000000
`define EXECUTE  11'b10000000000
`define WR_MEM   11'b10100000000
`define CLEANUP  11'b11000000000
`define PC_STEP  11'b11010000000

/* These instructions write to RAM */
wire ram_write = (IR[16:12] == i_T || IR[16:12] == i_U || IR[16:12] == i_I || IR[16:12] == i_F);

reg [10:0] phase = 0;
reg jump = 0;
reg old_resume = 0;

always @(posedge clock) begin

    old_resume <= resume;

    if(enable) begin
      phase <= HALT ? 11'b0 : phase + 1'b1;
    
      case(phase)
         `PREFETCH: cpu_addr_out <= SCR[9:1];
         `FETCH:    IR <= SCR[0] ? memory_in [34:18] : memory_in[16:0];
         `RD_MEM:   cpu_addr_out <= IR[10:2];       
         `EXECUTE:  exec_instruction(IR, memory_in[34:0], IR[1] ? memory_in[34:18] : memory_in[16:0]);
         `WR_MEM:   memory_wren <= ram_write ? 1'b1 : 1'b0;
         `CLEANUP:  memory_wren <= 1'b0;  
         `PC_STEP:  {SCR, jump, character_strobe} <= {SCR + !jump, 2'b0};
      endcase
    
      tape_read_strobe <= (IR[16:12] == i_I);      
    end

     
    if (!old_resume && resume) begin
      HALT <= 1'b0;
      `A <= `A + rotary_dial_in;
      SCR <= SCR + 1'b1;
    end
    
    if(reset) begin
         ABC <= 0;
         SCR <= 0;
         RS <= 0;
         HALT <= 1'b0;     
    end
    
    if(cpu_halt)
      HALT <= 1;
 
end


// These are used for panel and scope display

assign o_abc = ABC;
assign o_rs = RS;
assign o_scr = SCR;
assign o_ir = IR;
assign o_phase = phase;

endmodule

