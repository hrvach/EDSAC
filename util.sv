parameter i_P = 5'b0;

parameter
    i_E   = 5'b00011,  /* Conditional branch */
    i_R   = 5'b00100,  /* Shift */
    i_T   = 5'b00101,  /* Store */
    i_Y   = 5'b00110,  /* Round */
    i_U   = 5'b00111,  /* Store */
    i_I   = 5'b01000,  /* Read */
    i_O   = 5'b01001,  /* Output/Print */
    i_S   = 5'b01100,  /* Subtract */
    i_Z   = 5'b01101,  /* Stop and ring */
    i_F   = 5'b10001,  /* Reread */
    i_H   = 5'b10101,  /* Copy */
    i_N   = 5'b10110,  /* Multiply */
    i_L   = 5'b11001,  /* Shift */
    i_X   = 5'b11010,  /* NOP */
    i_G   = 5'b11011,  /* Conditional Branch */
    i_A   = 5'b11100,  /* Add */
    i_C   = 5'b11110,  /* Collate (And) */
    i_V   = 5'b11111;  /* Multiply */
    

parameter
    SHORT = 1'b0,     /* Short (17 bit) addressing mode */
    LONG  = 1'b1;     /* Long (35 bit) addressing mode */

    
function [0:0] is_circle_8;                                    /* Lookup table to decide if a (x, y) coordinate is within a circle of radius 8. */
   input [3:0] coord_x;                                        /* Contains only data for the first quadrant, and transforms other quadrants accordingly */
   input [3:0] coord_y;
begin
   /* Translate everything into the first quadrant */
   if (coord_x < 4'd7) coord_x = ~coord_x;
   if (coord_y > 4'd7) coord_y = ~coord_y;

   case (coord_y)
      4'd4:  is_circle_8 = coord_x < 4'd15;
      4'd3:  is_circle_8 = coord_x < 4'd15;
      4'd2:  is_circle_8 = coord_x < 4'd14;
      4'd1:   is_circle_8 = coord_x < 4'd13;
      4'd0:   is_circle_8 = coord_x < 4'd11;
      default: is_circle_8 = 1'b1;
   endcase
end

endfunction

function [0:0] is_circle_12;                                    /* Lookup table to decide if a (x, y) coordinate is within a circle. */
   input [4:0] coord_x;                                        /* Contains only data for the first quadrant, and transforms other quadrants accordingly */
   input [4:0] coord_y;
begin
   /* Translate everything into the first quadrant */
   if (coord_x < 5'd16) coord_x = ~coord_x;
   if (coord_y > 5'd16) coord_y = ~coord_y;

   case (coord_y)
      5'd16:  is_circle_12 = coord_x < 5'd23;
      5'd15:  is_circle_12 = coord_x < 5'd23;
      5'd14:  is_circle_12 = coord_x < 5'd23;
      5'd13:  is_circle_12 = coord_x < 5'd23;
      5'd12:  is_circle_12 = coord_x < 5'd23;
      5'd11:  is_circle_12 = coord_x < 5'd22;
      5'd10:  is_circle_12 = coord_x < 5'd22;
      5'd9:   is_circle_12 = coord_x < 5'd21;
      5'd8:   is_circle_12 = coord_x < 5'd19;
      default: is_circle_12 = 1'b0;
   endcase           
end

endfunction


function [0:0] is_circle_16;                                   /* Lookup table to decide if a (x, y) coordinate is within a circle of radius 16. */
   input [4:0] coord_x;                                        /* Contains only data for the first quadrant, and transforms other quadrants accordingly */
   input [4:0] coord_y;
begin
   /* Translate everything into the first quadrant */
   if (coord_x < 5'd16) coord_x = ~coord_x;
   if (coord_y >= 5'd16) coord_y = ~coord_y;
    
   case(coord_y)
      9,10,11: is_circle_16 = coord_x < 5'd31;
      8: is_circle_16 = coord_x < 5'd30;
      2,3,4,5,6,7: is_circle_16 = coord_x < 5'd23 + coord_y;
      1: is_circle_16 = coord_x < 5'd23;
      0: is_circle_16 = coord_x < 5'd20;
      default: is_circle_16 = 1'b1;
   endcase


end
endfunction


function [7:0] calc_pix;                                       /* Lookup table for scope pixel luma, fading away as distance from center increases */
   input [2:0] x;
   input [2:0] y;
begin
   if (~x[2]) x = ~x;
   if (~y[2]) y = ~y;

   case({x[1:0], y[1:0]})
      4'b0000:                   calc_pix = 8'd192;
      4'b0001, 4'b0100:          calc_pix = 8'd160;
      4'b0101:                   calc_pix = 8'd100;
      4'b1000, 4'b0010:          calc_pix = 8'd80;
      4'b1001, 4'b0110:          calc_pix = 8'd50;
      4'b1100, 4'b0011, 4'b1010: calc_pix = 8'd30;
      4'b0111, 4'b1101:          calc_pix = 8'd20;
      4'b1110, 4'b1011:          calc_pix = 8'd10;
      4'b1111:                   calc_pix = 8'd00;
   endcase

end
endfunction


function [7:0] px_add;                                         /* Pixel brightness addition with cap for max brightness to prevent overflow */
   input [7:0] px1;
   input [7:0] px2;
begin
   reg [8:0] sum = px1 + px2;
   return sum[8] ? 8'd255 : px1 + px2;
end
endfunction



function [23:0] get_color;                                     /* Only a few colors are used on the panel, so this simple palette is enough. */
   input [7:0] luma;                                           /* If luma matches one of these values, a color gets assigned. Otherwise, it stays B/W. */
begin
   case(luma)
      8'h62: get_color = 24'hAA4400;
      8'hE8: get_color = 24'hE5FF80;
      8'hEA: get_color = 24'hA7A776;
      
      default: get_color = {3{luma}};
   endcase        
end

endfunction


