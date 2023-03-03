`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/08/2022 10:46:21 AM
// Design Name: 
// Module Name: DNNProcessingElement
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


module DNNProcessingElement_Simba (

    //***inputs******
    //clock signal
    reset,
    clock,
    //data from uart receiver to dnn accelerator
    dataIn,
    //to see a valid data is present at dataIn from UART receiver
    isNewData,

    isBusy,

    //****outputs*******
    // data from DNN accelerator to UART transmitter    
    dataOut,
    // to see valid data is present at dataOut
    doTransmit,
    localState,  //debug tool to see the local state
    reach  //to see if a piece of code is getting reached.

);

  //parameters
  parameter BITWIDTH = 8;
  parameter INPUT_ARRAY_SIZE = 484;
  parameter OUTPUT_ARRAY_SIZE = 484;
  parameter WEIGHT_ARRAY_SIZE = 400;

  parameter CNN_LAYER = 1;
  parameter MAX_POOL_LAYER = 2;
  parameter RELU_LAYER = 3;
  parameter FULLY_CONNECTED_LAYER = 4;
  input reset;
  input clock;

  input [BITWIDTH-1:0] dataIn;
  input isNewData;

  output reg [BITWIDTH-1:0] dataOut;

  output reg doTransmit;

  input isBusy;

  output reg reach;
  //state variables
  reg [31:0] globalState;
  output reg [31:0] localState;
  reg [31:0] sequenceCounter;
  reg [31:0] skipCounter;
  reg previousDataState;
  reg [31:0] inputSize;
  reg [31:0] weightSize;
  reg [31:0] outputSize;



  //layerSizes
  // reg [31:0] N;
  reg [31:0] M;
  reg [31:0] C;
  reg [31:0] P;
  reg [31:0] Q;
  reg [31:0] R;
  reg [31:0] S;
  reg [31:0] W;
  reg [31:0] H;
  reg reuse;

  reg [31:0] xStride;
  reg [31:0] yStride;

  //iterators
  // reg [31:0] n;
  reg [31:0] m;
  reg [31:0] c;
  reg [31:0] p;
  reg [31:0] q;
  reg [31:0] r;
  reg [31:0] s;
  reg [31:0] i;
  reg [31:0] j;
  reg [31:0] k;
  reg [31:0] l;
  reg [31:0] n;

  reg [31:0] indexOutput;
  reg [31:0] indexInput;
  reg [31:0] indexWeight;

  reg [31:0] indexOutput_CNN[0:3]; // [0:Mac_units-1]
  reg [31:0] indexInput_CNN[0:3]; // [0:Multipliers-1]
  reg [31:0] indexWeight_CNN[0:15]; // [0:Mac_units*Multipliers - 1]


  //local buffer
  reg signed [BITWIDTH-1:0] inputs[0:INPUT_ARRAY_SIZE];
  reg signed [BITWIDTH-1:0] weights[0:WEIGHT_ARRAY_SIZE];
  reg signed [BITWIDTH-1:0] outputs[0:OUTPUT_ARRAY_SIZE];

  reg signed [BITWIDTH-1:0] temp;




  always @(posedge clock) begin

    if (reset) begin

      //state variables
      globalState = 0;
      localState = 0;
      sequenceCounter = 0;
      skipCounter = 0;
      inputSize = 0;
      weightSize = 0;
      outputSize = 0;
      dataOut = 0;
      doTransmit = 0;
      previousDataState = 0;
      reach = 0;
      temp = -(2 ** (BITWIDTH - 1));

      //layerSizes
      // N = 0;
      M = 0;
      C = 0;
      P = 0;
      Q = 0;
      R = 0;
      S = 0;
      W = 0;
      H = 0;
      reuse = 0;

      //iterators
      // n = 0;
      m = 0;
      c = 0;
      p = 0;
      q = 0;
      r = 0;
      s = 0;
      i = 0;
      j = 0;
      k = 0;
      l = 0;
      n = 0;


      indexOutput = 0;

      indexInput = 0;

      indexWeight = 0;


    end else begin

      if (globalState == 0) begin


        if (previousDataState != isNewData) begin

          previousDataState = isNewData;
          case (dataIn)
            CNN_LAYER: begin
              globalState = CNN_LAYER;
            end
            MAX_POOL_LAYER: begin
              globalState = MAX_POOL_LAYER;
            end
            RELU_LAYER: begin
              globalState = RELU_LAYER;
            end
            FULLY_CONNECTED_LAYER: begin
              globalState = FULLY_CONNECTED_LAYER;
            end
            default: begin
              globalState = 0;
            end
          endcase

        end else begin
          //do not
        end


      end else if (globalState == CNN_LAYER) begin
        //CNN layer

        case (localState)
          0: begin
            //loading data into layerSizes
            if (previousDataState != isNewData) begin
              previousDataState = isNewData;
              case (sequenceCounter)
                0: begin
                  M = dataIn;
                  sequenceCounter = sequenceCounter + 1;
                end
                1: begin
                  C = dataIn;
                  sequenceCounter = sequenceCounter + 1;
                end
                2: begin
                  P = dataIn;
                  sequenceCounter = sequenceCounter + 1;
                end
                3: begin
                  Q = dataIn;
                  sequenceCounter = sequenceCounter + 1;
                end
                4: begin
                  R = dataIn;
                  sequenceCounter = sequenceCounter + 1;
                end
                5: begin
                  S = dataIn;
                  sequenceCounter = sequenceCounter + 1;
                end
                6: begin
                  xStride = dataIn;
                  sequenceCounter = sequenceCounter + 1;
                end
                7: begin
                  yStride = dataIn;
                  sequenceCounter = sequenceCounter + 1;
                end
                8: begin
                  reuse = dataIn;
                  sequenceCounter = sequenceCounter + 1;
                  W = (P - 1) * xStride + R;
                  H = (Q - 1) * yStride + S;
                  inputSize = H * W * C;
                  weightSize = S * R * C * M;
                  outputSize = Q * P * M;
                  sequenceCounter = 0;
                  localState = localState + 1;
                end
                default: begin
                  //do nothing
                end
              endcase
            end else begin
              //skip the cycle
            end

          end
          1: begin
            //loading data into inputs
            if (reuse == 0) begin
              if (previousDataState != isNewData) begin
                previousDataState = isNewData;
                if (sequenceCounter < inputSize) begin
                  inputs[sequenceCounter] = dataIn;
                  sequenceCounter = sequenceCounter + 1;
                  if (sequenceCounter == inputSize) begin
                    sequenceCounter = 0;
                    localState = localState + 1;
                  end else begin
                    //do nothing
                  end
                  
                end else begin
                  // do nothing
                  //this shouldn't happen
                end
                
              end else begin
                //skip cycle
              end
              
            end else begin
              if(sequenceCounter < inputSize) begin
                inputs[sequenceCounter] = outputs[sequenceCounter];
                sequenceCounter = sequenceCounter + 1;
                if(sequenceCounter == inputSize) begin
                  sequenceCounter = 0;
                  localState = localState + 1;
                  end
                  end
                  end
            end
              
              // for (sequenceCounter=0; sequenceCounter<inputSize; sequenceCounter=sequenceCounter+1) begin
              //   inputs[sequenceCounter] = outputs[sequenceCounter];
              // end
              
              // sequenceCounter = 0;
              // localState = localState + 1;
          
              
          2: begin

            //loading weights
            if (previousDataState != isNewData) begin
              previousDataState = isNewData;
              if (sequenceCounter < weightSize) begin
                weights[sequenceCounter] = dataIn;
                sequenceCounter = sequenceCounter + 1;
                if (sequenceCounter == weightSize) begin
                  sequenceCounter = 0;
                  localState = localState + 1;
                end else begin
                  //do nothing
                end

              end else begin

                // do nothing
                //this shouldn't happen

              end
            end else begin
              //skip cycle
            end
          end
          // 

          3: begin

            //later set this up such that partial products can be loaded from python by seeting dataIn
            // if (validIn) begin
            if (sequenceCounter < outputSize) begin
              outputs[sequenceCounter] = 0;
              sequenceCounter = sequenceCounter + 1;
              if (sequenceCounter == outputSize) begin
                sequenceCounter = 0;
                localState = localState + 1;
              end else begin
                //do nothing

              end

            end else begin

              // do nothing
              //this shouldn't happen

            end
            // end
            // else begin

            //   //skip cycle if expecting partial data 
            // end
          end






          4: begin
            //compute
            indexInput_CNN[0] = (q * xStride + s) + (((p * yStride) + r) * H) + ((c) * H * W);
            indexWeight_CNN[0] = s + (r * S) + ((c) * R * S) + ((m) * C * R * S);
            indexOutput_CNN[0] = q + p * Q + (m) * Q * P;

              for (i=1; i<4; i=i+1)  // i < Multipliers
              begin
                indexInput_CNN[i] = indexInput_CNN[0] + i * H * W;
              end
            
              for (j=0; j<4; j=j+1)   // j < MAC_units 
              begin
                  for (n = 0; n<4; n = n+1) // n < Multipliers
                begin
                    indexWeight_CNN[(4*j)+n] = indexWeight_CNN[0] + n * R * S + j * C * R * S;  // The 4 in the ((4*j) + n) is the no. of multipliers

                // indexWeight_CNN[(8*j)+0] = s + (r * S) + ((c+0) * R * S) + ((m+j) * C * R * S);
                // indexWeight_CNN[(8*j)+1] = s + (r * S) + ((c+1) * R * S) + ((m+j) * C * R * S);                
                // indexWeight_CNN[(8*j)+2] = s + (r * S) + ((c+2) * R * S) + ((m+j) * C * R * S);                
                // indexWeight_CNN[(8*j)+3] = s + (r * S) + ((c+3) * R * S) + ((m+j) * C * R * S);
                // indexWeight_CNN[(8*j)+4] = s + (r * S) + ((c+4) * R * S) + ((m+j) * C * R * S);
                // indexWeight_CNN[(8*j)+5] = s + (r * S) + ((c+5) * R * S) + ((m+j) * C * R * S);                
                // indexWeight_CNN[(8*j)+6] = s + (r * S) + ((c+6) * R * S) + ((m+j) * C * R * S);                
                // indexWeight_CNN[(8*j)+7] = s + (r * S) + ((c+7) * R * S) + ((m+j) * C * R * S);                
              end
              end
            
              for (k=1; k<4; k=k+1) // k < MAC_units
              begin
                indexOutput_CNN[k] = indexOutput_CNN[0] + k * Q * P;
              end

              for (l = 0; l<4; l=l+1) // l < MAC_units
              begin
                  // indexInput_CNN must be indexed from 0 to Multipliers - 1
                  // indexWeight_CNN must be indexed from (Multipliers*l + 0) to (Multipliers*l + (Multipliers - 1)) 
                outputs[indexOutput_CNN[l]] = outputs[indexOutput_CNN[l]] + (inputs[indexInput_CNN[0]]*weights[indexWeight_CNN[4*l+0]] + inputs[indexInput_CNN[1]]*weights[indexWeight_CNN[4*l+1]] + inputs[indexInput_CNN[2]]*weights[indexWeight_CNN[4*l+2]] + inputs[indexInput_CNN[3]]*weights[indexWeight_CNN[4*l+3]]);
              end

            //schedule
            // s,r, q, p, c, m 
            if (q < Q - 1) begin
              q = q + 1;
            end else begin
              q = 0;
              if (p < P - 1) begin
                p = p + 1;
              end else begin
                p = 0;
                if (s < S - 1) begin
                  s = s + 1;
                end else begin
                  s = 0;
                  if (r < R - 1) begin
                    r = r + 1;
                  end else begin
                    r = 0;
                      if (c < (C>>2) - 1) begin // (C >> log(Multipliers) base 2)
                      c = c + 1;
                    end else begin
                      c = 0;
                        if (m < (M>>2) - 1) begin // (M >> log(MAC_units) base 2)
                        m = m + 1;
                      end else begin
                        m = 0;
                        localState = localState + 1;
                      end
                    end
                  end
                end
              end
            end



          end

          5: begin
            // wait for the uart in the server to come active.
            //            if (sequenceCounter > 100000) begin
            //              localState = 6;
            //              sequenceCounter = 0;
            //            end else begin
            //              sequenceCounter = sequenceCounter + 1;

            //            end

            // or you can do some post processing stuff here
            localState = localState + 1;
          end
          6: begin

            if (isBusy == 0) begin
              if (skipCounter > 10) begin
                skipCounter = 0;

                if (sequenceCounter >= outputSize) begin
                  sequenceCounter = 0;
                  localState = 0;
                  globalState = 0;

                end else begin
                  dataOut = outputs[sequenceCounter];
                  sequenceCounter = sequenceCounter + 1;
                  doTransmit = 1;
                end





              end else begin
                skipCounter = skipCounter + 1;
                doTransmit  = 0;
              end
            end else begin
              doTransmit = 0;
            end


          end

        endcase

      end else if (globalState == MAX_POOL_LAYER) begin
        //MAX_POOL_LAYER

        case (localState)
          0: begin
            //loading data into layerSizes
            if (previousDataState != isNewData) begin
              previousDataState = isNewData;
              case (sequenceCounter)
//                 0: begin
//                   M = dataIn;
//                   sequenceCounter = sequenceCounter + 1;
//                 end
                0: begin
                  C = dataIn;
                  sequenceCounter = sequenceCounter + 1;
                end
                1: begin
                  P = dataIn;
                  sequenceCounter = sequenceCounter + 1;
                end
                2: begin
                  Q = dataIn;
                  sequenceCounter = sequenceCounter + 1;
                end
                3: begin
                  R = dataIn;
                  sequenceCounter = sequenceCounter + 1;
                end
                4: begin
                  S = dataIn;
                  sequenceCounter = sequenceCounter + 1;
                end
                5: begin
                  xStride = dataIn;
                  sequenceCounter = sequenceCounter + 1;
                end
                6: begin
                  yStride = dataIn;
                  sequenceCounter = sequenceCounter + 1;
                end
                7: begin
                  reuse = dataIn;
                  sequenceCounter = sequenceCounter + 1;
                  W = (P - 1) * xStride + R;
                  H = (Q - 1) * yStride + S;
                  inputSize = H * W * C;
                  weightSize = S * R;
                  outputSize = Q * P * C;
                  sequenceCounter = 0;
                  localState = localState + 1;
                end
                default: begin
                  //do nothing
                end
              endcase
            end else begin
              //skip the cycle
            end

          end
          1: begin
            //loading data into inputs
            if (reuse == 0) begin
              if (previousDataState != isNewData) begin
                previousDataState = isNewData;
                if (sequenceCounter < inputSize) begin
                  inputs[sequenceCounter] = dataIn;
                  sequenceCounter = sequenceCounter + 1;
                  if (sequenceCounter == inputSize) begin
                    sequenceCounter = 0;
                    localState = localState + 1;
                  end else begin
                    //do nothing
                  end
                  
                end else begin
                  // do nothing
                  //this shouldn't happen
                end
                
              end else begin
                //skip cycle
              end
              
            end else begin
//              for (sequenceCounter=0; sequenceCounter<inputSize; sequenceCounter=sequenceCounter+1) begin
//                inputs[sequenceCounter] = outputs[sequenceCounter];
//              end
              
//              sequenceCounter = 0;
//              localState = localState + 1;
                if(sequenceCounter < inputSize) begin
                  inputs[sequenceCounter] = outputs[sequenceCounter];
                  sequenceCounter = sequenceCounter + 1;
                  if(sequenceCounter == inputSize) begin
                  sequenceCounter = 0;
                  localState = localState + 1;
                  end
                  
                 end
            end
            
          end
          
          
          
          2: begin
            // Since there is no need for the weights to be inputted, skip the localState
            localState = localState + 1;
          end


          3: begin
            localState = localState + 1;
          end


          4: begin
            //compute
            indexInput = (q * xStride + s) + (((p * yStride) + r) * H) + (c * H * W);

            if (temp < inputs[indexInput]) begin
              temp = inputs[indexInput];
            end else begin
              temp = temp;
            end



            //schedule
            // s,r, q, p, c, m 
            if (s < S - 1) begin
              s = s + 1;
            end else begin
              s = 0;
              if (r < R - 1) begin
                r = r + 1;
              end else begin


                //setting the max value to the curresponding output word
                indexOutput = q + p * Q + c * Q * P;
                outputs[indexOutput] = temp;
                //and then resetting the temp variable
                temp = -(2 ** (BITWIDTH - 1));

                //onward with the origianl schedule
                r = 0;
                if (q < Q - 1) begin
                  q = q + 1;
                end else begin
                  q = 0;
                  if (p < P - 1) begin
                    p = p + 1;
                  end else begin
                    p = 0;
                    if (c < C - 1) begin
                      c = c + 1;
                    end else begin
                      c = 0;
                      localState = localState + 1;
//                       if (m < M - 1) begin
//                         m = m + 1;
//                       end else begin
//                         m = 0;
//                         localState = localState + 1;
//                       end
                     end
                  end
                end
              end
            end
          end

          5: begin

            localState = localState + 1;

          end
          6: begin

            if (isBusy == 0) begin
              if (skipCounter > 10) begin
                skipCounter = 0;

                if (sequenceCounter >= outputSize) begin
                  sequenceCounter = 0;
                  localState = 0;
                  globalState = 0;

                end else begin
                  dataOut = outputs[sequenceCounter];
                  sequenceCounter = sequenceCounter + 1;
                  doTransmit = 1;
                end





              end else begin
                skipCounter = skipCounter + 1;
                doTransmit  = 0;
              end
            end else begin
              doTransmit = 0;
            end


          end

        endcase


      end else if (globalState == RELU_LAYER) begin
        //RELU_LAYER

        case (localState)
          0: begin
            //loading data into layerSizes
            if (previousDataState != isNewData) begin
              previousDataState = isNewData;
              case (sequenceCounter)
                0: begin
                  P = dataIn;
                  sequenceCounter = sequenceCounter + 1;
                end
                1: begin
                  Q = dataIn;
                  sequenceCounter = sequenceCounter + 1;
                end
                2: begin
                  C = dataIn;
                  sequenceCounter = sequenceCounter + 1;
                end
                3: begin
                  reuse = dataIn;
                  sequenceCounter = sequenceCounter + 1;
                  W = P;
                  H = Q;
                  M = C;
                  inputSize = H * W * C;
                  outputSize = Q * P * M;
                  sequenceCounter = 0;
                  localState = localState + 1;
                end
                default: begin
                  //do nothing
                end
              endcase
            end else begin
              //skip the cycle
            end

          end
          1: begin
            //loading data into inputs
            if (reuse == 0) begin
              if (previousDataState != isNewData) begin
                previousDataState = isNewData;
                if (sequenceCounter < inputSize) begin
                  inputs[sequenceCounter] = dataIn;
                  sequenceCounter = sequenceCounter + 1;
                  if (sequenceCounter == inputSize) begin
                    sequenceCounter = 0;
                    localState = localState + 1;
                  end else begin
                    //do nothing
                  end
                  
                end else begin
                  // do nothing
                  //this shouldn't happen
                end
                
              end else begin
                //skip cycle
              end

            end else begin
              if(sequenceCounter < inputSize) begin
                inputs[sequenceCounter] = outputs[sequenceCounter];
                sequenceCounter = sequenceCounter + 1;
                if(sequenceCounter == inputSize) begin
                  sequenceCounter = 0;
                  localState = localState + 1;
                  end
                  end
                  end
            end
                 
          //   end else begin
          //     for (sequenceCounter=0; sequenceCounter<inputSize; sequenceCounter=sequenceCounter+1) begin
          //       inputs[sequenceCounter] = outputs[sequenceCounter];
          //     end
              
          //     sequenceCounter = 0;
          //     localState = localState + 1;
          //   end
            
          // end
          
              
          2: begin
            // Since there is no need for the weights to be inputted, skip the localState
            localState = localState + 1;

          end


          3: begin
            // No need for setting the ouputs to zero. Therefore skipping this localState.
            localState = localState + 1;

          end

          4: begin
            //compute
            indexInput  = sequenceCounter;
            indexOutput = sequenceCounter;

            if (inputs[indexInput][BITWIDTH-1] == 1) begin
              outputs[indexOutput] = 0;
            end else begin
              outputs[indexOutput] = inputs[indexInput];
            end


            //schedule
            if (sequenceCounter < inputSize - 1) begin
              sequenceCounter = sequenceCounter + 1;
            end else begin
              sequenceCounter = 0;
              localState = localState + 1;
            end

          end

          5: begin

            localState = localState + 1;

          end
          6: begin

            if (isBusy == 0) begin
              if (skipCounter > 10) begin
                skipCounter = 0;

                if (sequenceCounter >= outputSize) begin
                  sequenceCounter = 0;
                  localState = 0;
                  globalState = 0;

                end else begin
                  dataOut = outputs[sequenceCounter];
                  sequenceCounter = sequenceCounter + 1;
                  doTransmit = 1;
                end





              end else begin
                skipCounter = skipCounter + 1;
                doTransmit  = 0;
              end
            end else begin
              doTransmit = 0;
            end


          end

        endcase

      end else begin
        //do nothing
        globalState = 0;
        //
      end

    end

  end


endmodule
