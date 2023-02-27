`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/08/2022 10:46:50 AM
// Design Name: 
// Module Name: Main
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


module Main (
    clk,  //input clock
    reset,  //input reset 
    RxD,  //input receving data line
    TxD,
    isNewData,
    seg,
    segActivate,
    lState,
    reach
    
);

  input clk;
  input reset;
  input RxD;
  output TxD;
  output [6:0] seg;
  output segActivate;
  output wire isNewData;
  output wire [3:0] lState;
  output reach;
  
  wire doTransmit;
  wire isBusy;
  wire [7:0] TxData;
  wire [7:0] RxData;
  wire [31:0] localState;
  
//  assign TxD=1;
//  assign isBusy=1;
  assign lState = localState[3:0];
  
  Display7 display7 (

      .bcd(RxData[3:0]),
      .seg(seg),
      .segActivate(segActivate)
  );


  Receiver receiver (

      .clk(clk),  //input clock
      .reset(reset),  //input reset 
      .RxD(RxD),  //input receving data line
      .RxData(RxData),  // output for 8 bits data
      .isNewData(isNewData)  //changes value 
  );

  DNNProcessingElement_Simba dNNProcessingElement (

      //**********inputs***************
      //clock signal
      .reset(reset),
      .clock(clk),
      //data from uart receiver to dnn accelerator
      .dataIn(RxData),
      //to see a valid data is present at dataIn from UART receiver
      .isNewData(isNewData),

      .isBusy(isBusy),

      //*************outputs********************
      // data from DNN accelerator to UART transmitter    
      .dataOut(TxData),
      // to see valid data is present at dataOut
      .doTransmit(doTransmit),
      .localState(localState),
      .reach(reach)

  );



  Sender sender (
      .clk(clk),
      .reset(reset),
      .TxD(TxD),
      .doTransmit(doTransmit),
      .TxData(TxData),
      .isBusy(isBusy)
  );



endmodule
