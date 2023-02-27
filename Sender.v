`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IITGn
// Engineer: Glint
// 
// Create Date: 12/08/2022 10:44:40 AM
// Design Name: 
// Module Name: Sender
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


module Sender (
    clk, 
    reset,
    TxD,
    doTransmit,
    TxData,
    isBusy
);

  input clk;
  input reset;
  output reg TxD;
  input doTransmit;
  input [7:0] TxData;
  output reg isBusy;

  reg [31:0] state;
  reg [31:0] sequenceCounter;
  reg [ 7:0] data;


  parameter W5Frequency = 100_000_000;
  parameter baudRate = 9600;
  parameter samplingInterval = W5Frequency / baudRate;
  parameter halfSamplingInterval = samplingInterval / 2;


  always @(posedge clk) begin
    if (reset) begin
      state = 0;
      data = 0;
      sequenceCounter = 0;
      TxD = 1;
      isBusy=0;

   end else begin


      case (state)
        0: begin
          if (doTransmit == 1) begin
            state = 2;
            data = TxData;
            isBusy = 1;
            sequenceCounter=0;
            TxD = 0;// this is start bit
          end
        end
        2: begin
          //first bit
          sequenceCounter = sequenceCounter + 1;
          if (sequenceCounter > samplingInterval) begin
            sequenceCounter = 0;
            state = 3;
            TxD = data[0];
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
            TxD = data[1];
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
            TxD = data[2];
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
            TxD = data[3];
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
            TxD = data[4];
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
            TxD = data[5];
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
            TxD = data[6];
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
            TxD = data[7];
          end else begin
            //do nothing
          end
        end
        10: begin
          //end bit
          sequenceCounter = sequenceCounter + 1;
          if (sequenceCounter > samplingInterval) begin
            sequenceCounter = 0;
            state = 11;
            TxD = 1; // this is end bit
          end else begin
            //do nothing
          end
        end
        11: begin
          //reset
          sequenceCounter = sequenceCounter + 1;
          if (sequenceCounter > samplingInterval) begin
            sequenceCounter = 0;
            state = 0;
            isBusy = 0;
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
