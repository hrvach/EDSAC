/* 
   Implementation is done according to specifications that can be found at https://multimedia.cx/mirror/dialogic-adpcm.pdf
   
   Most important segments, quote:
   
   The decoder computes the difference between the previous linear output estimate and the anticipated one.
   This difference is added to the previous estimate to produce the linear output estimate. The input ADPCM
   sample is also presented to the step size calculator to compute the step size estimate
   
   The decoder accepts ADPCM code values, L(n), and step size values. It calculates a reproduced differential 
   value, and accumulates an estimated waveform value, X. Here is a pseudocode algorithm:

   d(n) = (ss(n)*B2)+(ss(n)/2*B1)+(ss(n)/4*BO)+(ss(n)/8)
   if (B3 = 1)
      then d(n) = d(n) * (-1)
   X(n) = X(n-1) + d(n)
   
   ss(n+1) = ss(n) * 1.1M(L(n))
      -> Calculated from a lookup table
      
   Initial conditions: When the ADPCM algorithm is reset, the step size ss(n) is set to the minimum value (16) and the
   estimated waveform value X is set to zero (half scale)
*/

module adpcm_decoder (
   input                         reset,
   input                         clock,  
   input [3:0]                   in_pcm,   
   output reg signed [11:0]      sample
);

reg signed [11:0] differential_value;
reg signed [6:0]  index, delta;
reg [10:0] step, pr_step;
reg [15:0] pcm;
   
wire signed [11:0] estimation = pcm[15] ? sample + differential_value : sample - differential_value;                    

always @(posedge clock) 
begin
   if(reset) begin
      delta <= 7'd0; sample <= 12'd0; differential_value <= 12'd0;
      index <= 7'd0; step <= 11'd0; pr_step <= 11'd0; pcm <= 16'd0; 
   end
   
   else begin
   
   pcm <= {pcm[11:0], in_pcm[3:0]};
   pr_step <= step;

   case (in_pcm[2:0]) 
      3'b000:  delta <= -7'd1;     3'b001:  delta <= -7'd1;     3'b010:  delta <= -7'd1;     3'b011:  delta <= -7'd1;
      3'b100:  delta <=  7'd2;     3'b101:  delta <=  7'd4;     3'b110:  delta <=  7'd6;     3'b111:  delta <=  7'd8;
   endcase 
  
   if (index + delta < 0)       index <= 0;
   else if (index + delta > 48) index <= 48;
   else                         index <= index + delta; 

   case (index)
      7'd00: step <= 11'd16;    7'd01: step <= 11'd17;    7'd02: step <= 11'd19;    7'd03: step <= 11'd21;
      7'd04: step <= 11'd23;    7'd05: step <= 11'd25;    7'd06: step <= 11'd28;    7'd07: step <= 11'd31;
      7'd08: step <= 11'd34;    7'd09: step <= 11'd37;    7'd10: step <= 11'd41;    7'd11: step <= 11'd45;
      7'd12: step <= 11'd50;    7'd13: step <= 11'd55;    7'd14: step <= 11'd60;    7'd15: step <= 11'd66;
      7'd16: step <= 11'd73;    7'd17: step <= 11'd80;    7'd18: step <= 11'd88;    7'd19: step <= 11'd97;
      7'd20: step <= 11'd107;   7'd21: step <= 11'd118;   7'd22: step <= 11'd130;   7'd23: step <= 11'd143;
      7'd24: step <= 11'd157;   7'd25: step <= 11'd173;   7'd26: step <= 11'd190;   7'd27: step <= 11'd209;
      7'd28: step <= 11'd230;   7'd29: step <= 11'd253;   7'd30: step <= 11'd279;   7'd31: step <= 11'd307;   
      7'd32: step <= 11'd337;   7'd33: step <= 11'd371;   7'd34: step <= 11'd408;   7'd35: step <= 11'd449;
      7'd36: step <= 11'd494;   7'd37: step <= 11'd544;   7'd38: step <= 11'd598;   7'd39: step <= 11'd658;
      7'd40: step <= 11'd724;   7'd41: step <= 11'd796;   7'd42: step <= 11'd876;   7'd43: step <= 11'd963;   
      7'd44: step <= 11'd1060;  7'd45: step <= 11'd1166;  7'd46: step <= 11'd1282;  7'd47: step <= 11'd1411;
      7'd48: step <= 11'd1552;
      default: step <= 11'd1552;
   endcase 
   
   differential_value <= {pcm[10] ? pr_step : 12'd0} + {pcm[9] ? (pr_step>>1) : 12'd0} + {pcm[8] ? (pr_step>>2) : 12'd0} + (pr_step>>3);

   if (estimation >  2047)       sample <= 12'd2047;
   else if (estimation < -2048)  sample <= -12'd2048;
   else                          sample <= estimation;  
   
   end
end 
endmodule
