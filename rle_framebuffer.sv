module rle_framebuffer
(
   input             clock,
   input             enable,
   input             sync,
   input [1:0]       active_mode,
   input [31:0]      status,
   output reg [7:0]  pixel,
   
   // Option to upload/change the ROM image file //   
   input [7:0]       data,
   input [16:0]      wraddress,
   input             wren
);

/* 
   This works by decompressing the provided ROM bitmap using a relatively simple RLE variant:
   Load byte. If LSB bit is 0, display remaining 7 bits as luma and proceed to the next byte.
   If LSB bit is 1, then use remaining 7 bits as luma but they will be repeated. Now we need to
   load repeat count. Keep loading bytes and extracting 7 bits from each of them until we get 
   one with LSB set to 0, that is the end of SIZE data. Save that size data into a counter and
   decrement with every posedge clock, keeping the original 7 bits for pixel luma in the output
   register. After counter drops to zero, restart the entire process.
*/

wire [7:0] fp_rom_data;
wire rom_clock = clock & enable;

parameter
    FETCH     = 2'b00,
    GET_LEN   = 2'b01,
    COPY_CHAR = 2'b10;

image_library fp_rom(
   .rdaddress({active_mode[1], rom_addr}),
   .wraddress(wraddress),
   .data(data),
   .wren(wren),
   .clock(rom_clock),
   .q(fp_rom_data)
);

reg [21:0] repeat_count = 22'd0;
reg [15:0] rom_addr = 16'b0;
reg [1:0] phase = 2'd0;
reg [2:0] size_len = 3'd0;

reg old_sync;

always @(posedge clock)
begin
   
   if (sync) begin
      rom_addr <= 16'hfffe;
      phase <= FETCH;
   end
   
   else
   if (enable)
   begin
   
   rom_addr <= rom_addr + 1'b1;
   
   case (phase)
      FETCH:   // Get pixel value
         begin
            repeat_count <= 22'b0;
            pixel <= {fp_rom_data[7:1], 1'b0};
            size_len <= {2'b0, fp_rom_data[0]};
            
            if (fp_rom_data[0])     			// This pixel is encoded, let's get the repeat count
               phase <= GET_LEN;
         end
         
         
      GET_LEN: // Get up to 3 bytes of size
         begin                      
            
            // When we reach the end of size data, subtract the number of clocks spent fetching the size
            repeat_count <= {repeat_count[14:0], fp_rom_data[7:1]};
            size_len <= size_len + 1'b1;  	// Keep tabs on clock count
            
            // There is more size data to come                          
            if (~fp_rom_data[0]) 
            begin
               rom_addr <= rom_addr - {repeat_count[8:0], fp_rom_data[7:1]} + {14'b0, size_len} + 16'd2;             
               phase <= COPY_CHAR;
            end
         end
         
         
      COPY_CHAR:  // Churn out pixels
         begin
            // While repeat_count is not zero
            if(repeat_count > {19'b0, size_len} + 22'd1)
               repeat_count <= repeat_count - 1'b1;            
            else begin
               phase <= FETCH;
            end
         end      
         
      default:
         phase <= FETCH;
   endcase
   end
end

endmodule