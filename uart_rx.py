import serial           # import the module
import struct
import time

ComPort = serial.Serial('COM12') # open COM24
ComPort.baudrate = 9600 # set Baud rate to 9600
ComPort.bytesize = 8    # Number of data bits = 8
ComPort.parity   = 'N'  # No parity
ComPort.stopbits = 1    # Number of Stop bits = 1

print("Enter 1 eight bit numbers.\nThe sum will be printed")
print("Press 'q' to exit infinite loop at any time")

while True:
    x=int(input("Enter number 1: "))
    if x>127:
        x = x - 256
    if x == 'q':
        break
    ot= ComPort.write(struct.pack('b', x))    #for sending data to FPGA
    # y=input("Enter number 2: ")
    # ot= ComPort.write(struct.pack('h', int(y)))    #for sending data to FPGA

    it=(ComPort.read())                #for receiving data from FPGA
    print(it)
    print(f"{x} = {int.from_bytes(it, byteorder='big')}")

ComPort.close()         # Close the Com port