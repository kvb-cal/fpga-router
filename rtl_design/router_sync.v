`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.02.2024 15:39:43
// Design Name: 
// Module Name: router_sync
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module router_sync(clock,resetn,data_in,detect_add,full_0,full_1,full_2,empty_0,empty_1,empty_2,write_enb_reg,read_enb_0,read_enb_1,read_enb_2,vld_out_0,vld_out_1,vld_out_2,fifo_full,soft_reset_0,soft_reset_1,soft_reset_2,write_enb);

input clock,resetn,detect_add,full_0,full_1,full_2,empty_0,empty_1,empty_2,write_enb_reg,read_enb_0,read_enb_1,read_enb_2;

output vld_out_0,vld_out_1,vld_out_2,soft_reset_0,soft_reset_1,soft_reset_2;
output reg[2:0] write_enb;
output reg fifo_full;

// Internal registers
reg [1:0]temp;
reg [5:0]count0,count1,count2;
input [1:0]data_in;
reg soft_reset_0;
reg soft_reset_1;
reg soft_reset_2;

// Combinational block to determine overall FIFO full status
always@(temp or full_0 or full_1 or full_2)
begin
  case(temp)
    2'b00: fifo_full=full_0;
    2'b01: fifo_full=full_1;
    2'b10: fifo_full=full_2;
    default: fifo_full=0;
  endcase
end

// Register for storing current address data
always@(posedge clock)
begin
  if(!resetn)
   temp<=0;// Reset address on reset
  else if(detect_add)
    temp<=data_in;// Store address data when detected
  else 
    temp<=temp;// Hold current address
end

// Combinational block to generate write enable signals based on address
always@(temp or write_enb or write_enb_reg)
begin
  if(write_enb_reg)
    begin
      case(temp)
        2'b00: write_enb=3'b001;
        2'b01: write_enb=3'b010;
        2'b10: write_enb=3'b100;
      default: write_enb=3'b000;
      endcase
    end
	 else write_enb=0;
end

// Assign valid output signals based on FIFO empty status
assign vld_out_0=~empty_0;
assign vld_out_1=~empty_1;
assign vld_out_2=~empty_2;

 // Logic for generating soft reset signals for FIFOs
always@(posedge clock)
begin
  if(!resetn)
    begin
      count0<=0;
      soft_reset_0<=0;
    end
  else if(!read_enb_0 && vld_out_0)
    begin
      if(count0<29)
         count0<=count0+1;
      if(count0>=29)
         soft_reset_0<=1'b1;
      if(read_enb_0)
         count0<=0;
    end
end 


always@(posedge clock)
begin
  if(!resetn)
    begin
      count1<=0;
      soft_reset_1<=0;
     end
  else if(!read_enb_1 && vld_out_1)
    begin
      if(count1<29)
         count1<=count1+1;
      if(count1>=29)
         soft_reset_1<=1'b1;
      if(read_enb_1)
         count1<=0;
    end
end 

always@(posedge clock)
begin
  if(!resetn)
    begin
      count2<=0;
      soft_reset_2<=0;
     end
  else if(!read_enb_2 && vld_out_2)
    begin
      if(count2<29)
         count2<=count2+1;
      if(count2>=29)
         soft_reset_2<=1'b1;
      if(read_enb_2)
         count2<=0;
    end
end 

 

 



endmodule 

 