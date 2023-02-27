`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IITGn
// Engineer: Glint
// 
// Create Date: 12/08/2022 10:44:19 AM
// Design Name: 
// Module Name: Receiver
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



module Receiver (

    clk,  //input clock
    reset,  //input reset 
    RxD,  //input receving data line
    RxData,  // output for 8 bits data
    isNewData  //changes value 
);

  parameter W5Frequency = 100_000_000;
  parameter baudRate = 9600;
  parameter samplingInterval = W5Frequency / baudRate;
  parameter halfSamplingInterval = samplingInterval / 2;


  input clk;
  input reset;
  input RxD;
  output reg [7:0] RxData;

  reg [31:0] state;
  reg [31:0] sequenceCounter;

  reg [ 7:0] data;
  output reg isNewData;

  always @(posedge clk) begin
    if (reset) begin
      state = 0;
      data = 0;
      sequenceCounter = 0;
      isNewData = 0;
      RxData=0;

    end else begin


      case (state)
        0: begin
          if (RxD == 0) begin
            state = 1;
          end
        end
        1: begin
          //start bit
          sequenceCounter = sequenceCounter + 1;
          if (sequenceCounter > halfSamplingInterval) begin
            sequenceCounter = 0;
            state = 2;
          end else begin
            //do nothing
          end
        end
        2: begin
          //first bit
          sequenceCounter = sequenceCounter + 1;
          if (sequenceCounter > samplingInterval) begin
            sequenceCounter = 0;
            state = 3;
            data[0] = RxD;
          end else begin
            //do nothing
          end
        end
        3: begin
          //second bit
          sequenceCounter = sequenceCounter + 1;
          if (sequenceCounter > samplingInterval) begin
            sequenceCounter = 0;
            state = 4;
            data[1] = RxD;
          end else begin
            //do nothing
          end
        end
        4: begin
          //thrid bit
          sequenceCounter = sequenceCounter + 1;
          if (sequenceCounter > samplingInterval) begin
            sequenceCounter = 0;
            state = 5;
            data[2] = RxD;
          end else begin
            //do nothing
          end
        end
        5: begin
          //fourth bit
          sequenceCounter = sequenceCounter + 1;
          if (sequenceCounter > samplingInterval) begin
            sequenceCounter = 0;
            state = 6;
            data[3] = RxD;
          end else begin
            //do nothing
          end
        end
        6: begin
          //fifth bit
          sequenceCounter = sequenceCounter + 1;
          if (sequenceCounter > samplingInterval) begin
            sequenceCounter = 0;
            state = 7;
            data[4] = RxD;
          end else begin
            //do nothing
          end
        end
        7: begin
          //sixth bit
          sequenceCounter = sequenceCounter + 1;
          if (sequenceCounter > samplingInterval) begin
            sequenceCounter = 0;
            state = 8;
            data[5] = RxD;
          end else begin
            //do nothing
          end
        end
        8: begin
          //seventh bit
          sequenceCounter = sequenceCounter + 1;
          if (sequenceCounter > samplingInterval) begin
            sequenceCounter = 0;
            state = 9;
            data[6] = RxD;
          end else begin
            //do nothing
          end
        end
        9: begin
          //eight bit
          sequenceCounter = sequenceCounter + 1;
          if (sequenceCounter > samplingInterval) begin
            sequenceCounter = 0;
            state = 10;
            data[7] = RxD;
            RxData = data;
            isNewData = isNewData + 1;
          end else begin
            //do nothing
          end
        end
        10: begin
          //reset
          sequenceCounter = sequenceCounter + 1;
          if (sequenceCounter > samplingInterval) begin
            sequenceCounter = 0;
            state = 0;
          end else begin
            //do nothing
          end
        end
        default: begin
          //
        end
      endcase


    end

  end




endmodule
