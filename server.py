import time
import serial

import serial.tools.list_ports

ports = serial.tools.list_ports.comports()


def printPortInfo():
    for port, desc, hwid in sorted(ports):
        print("{}: {} [{}]".format(port, desc, hwid))


def openPort(port="COM6", baudRate=9600):
    return serial.Serial(port, baudRate)


def closePort(serialPort):
    serialPort.close()


def sendLayerType(ser, layerType):
    packet = bytearray()
    packet.append(layerType)
    ser.write(packet)


def sendShape(ser, M, C, P, Q, R, S, xStride, yStride, reuse):
    packet = bytearray()
    packet.append(M)
    packet.append(C)
    packet.append(P)
    packet.append(Q)
    packet.append(R)
    packet.append(S)
    packet.append(xStride)
    packet.append(yStride)
    packet.append(reuse)
    ser.write(packet)


def sendShape_MAX_POOL(ser, C, P, Q, R, S, xStride, yStride, reuse):
    packet = bytearray()
    packet.append(C)
    packet.append(P)
    packet.append(Q)
    packet.append(R)
    packet.append(S)
    packet.append(xStride)
    packet.append(yStride)
    packet.append(reuse)
    ser.write(packet)


def sendShape_RELU(ser, P, Q, C, reuse):
    packet = bytearray()
    packet.append(P)
    packet.append(Q)
    packet.append(C)
    packet.append(reuse)
    ser.write(packet)


def sendInput(ser, input_list):
    packet = bytearray()
    for val in input_list:
        packet.append(val)

    ser.write(packet)


def sendWeight(ser, weight_list):
    # values = range(16)
    packet = bytearray()
    for val in weight_list:
        packet.append(val)

    ser.write(packet)


def readOutput(ser, M, C, P, Q, R, S, xStride, yStride, reuse):
    size = M * P * Q
    values = range(size)
    packet = bytearray()

    for i in values:
        x = ser.read()
        valx = int.from_bytes(x, "big")
        print(valx)
        packet.append(valx)

    print("Printing from DS")
    for i in values:
        print(packet[i])


# some testing example
# def sendShapeTest(M,C,P,Q,R,S,xStride,yStride):
#     ser = serial.Serial(port,baudRate)
#     packet = bytearray()
#     packet.append(M)
#     ser.write(packet)
#     packet = bytearray()
#     time.sleep(1)

#     packet.append(C)
#     ser.write(packet)
#     packet = bytearray()
#     time.sleep(1)

#     packet.append(P)
#     ser.write(packet)
#     packet = bytearray()
#     time.sleep(1)

#     packet.append(Q)
#     ser.write(packet)
#     packet = bytearray()
#     time.sleep(1)

#     packet.append(R)
#     ser.write(packet)
#     packet = bytearray()
#     time.sleep(1)

#     packet.append(S)
#     ser.write(packet)
#     packet = bytearray()
#     time.sleep(1)

#     packet.append(xStride)
#     ser.write(packet)
#     packet = bytearray()
#     time.sleep(1)

#     packet.append(yStride)
#     ser.write(packet)
#     packet = bytearray()
#     time.sleep(1)

#     ser.close()


# # print(list(serial.tools.list_ports.comports()))

# sendShape(2,2,3,3,2,2,1,1)


def main():
    printPortInfo()
    myPort = openPort()
    input_list = []
    weight_list = []
    for i in range(128):
        input_list.append(i - 10)

    for i in range(256):
        weight_list.append(i - 7)

    # CNN LAYER
    print("Processing First Layer")
    sendLayerType(myPort, 1)
    sendShape(myPort, 8, 8, 3, 3, 2, 2, 1, 1, 0)
    sendInput(myPort, input_list)
    sendWeight(myPort, weight_list)
    readOutput(myPort, 8, 8, 3, 3, 2, 2, 1, 1, 0)

    # # MAX_POOL_LAYER
    # print("Processing Second Layer")
    # sendLayerType(myPort, 2)
    # sendShape_MAX_POOL(myPort, 8, 2, 2, 2, 2, 1, 1, 1)
    # # sendInput(myPort, 1)
    # # sendWeight(myPort, 2)
    # readOutput(myPort, 8, 8, 2, 2, 2, 2, 1, 1, 1)

    # #RELU LAYER
    # print("Processing Third Layer")
    # sendLayerType(myPort, 3)
    # sendShape_RELU(myPort, 2, 2, 8, 1)
    # # sendInput(myPort, 1)
    # # sendWeight(myPort, 2)
    # readOutput(myPort, 2, 2, 8, 1)

    closePort(myPort)


if __name__ == "_main_":
    main()