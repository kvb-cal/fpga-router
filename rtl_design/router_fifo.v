`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.02.2024 15:26:10
// Design Name: 
// Module Name: router_fifo
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


module router_fifo(clock,resetn,data_in,read_enb,write_enb,data_out,full,empty,lfd_state,soft_reset);
                          
parameter width=9,depth=16;
// Module Inputs
input lfd_state; // LFD State Input
input [width-2:0] data_in; // Data Input
input clock,resetn,read_enb,write_enb,soft_reset; // Clock and Control Inputs
reg [4:0]rd_pointer,wr_pointer;
output reg [width-2:0] data_out;
reg [6:0]count;

// Module Outputs
output full,empty; // Data Output
integer i; // Full and Empty Flags

// Internal Signals
reg [width-1:0] mem[depth-1:0]; // Memory Array
reg temp;

// Full and Empty Assignments
assign full=((wr_pointer[4] != rd_pointer[4]) && (wr_pointer[3:0]==rd_pointer[3:0]));
assign empty= wr_pointer==rd_pointer;

// LFD State Assignment
always@(posedge clock)
begin
  if(~resetn)
    temp=0;
  else 
    temp=lfd_state;
end

//write
always@(posedge clock)
begin 
  if(~resetn)
    begin 
      for(i=0;i<=15;i=i+1)
         mem[i]<=0;
    end
  else if(soft_reset)
    begin
       for(i=0;i<=15;i=i+1)
        mem[i]<=0;
    end
  else if(write_enb && !full)
    begin
      if(lfd_state)
        {mem[wr_pointer[3:0]][8],mem[wr_pointer[3:0]][7:0]}<={temp,data_in};
    else
        {mem[wr_pointer[3:0]][8],mem[wr_pointer[3:0]][7:0]}<={temp,data_in};
     end
end

//read
always@(posedge clock)
begin 
     if(~resetn)
       begin 
         data_out <= 0;
       end
else if(soft_reset)
      begin
	      data_out <= 'bz;
      end
else if(read_enb && !empty)
      begin
         data_out <= mem[rd_pointer[3:0]][7:0];
      end
      else if(count==0 && data_out != 0)
      data_out <= 8'bzzzzzzzz;
end
         
//counter
always@(posedge clock)
begin
 if(read_enb && !empty)
     begin
      if(mem[rd_pointer[3:0]][8])
         begin
          count <= mem[rd_pointer[3:0]][7:2] +1;
          end
     else
       if(count!=0)
         begin
         count <= count-1;
         end
    end  
end

// Pointer Update Process     
always@(posedge clock)
begin
  if(~resetn || soft_reset)
	begin
      rd_pointer <= 0;
      wr_pointer <= 0;
	end
	else
	begin
      if(write_enb && !full)
          wr_pointer <= wr_pointer+1;
      if(read_enb && !empty)
          rd_pointer <= rd_pointer+1;
	end
end

endmodule
