# ESP8266_FloodLight

This repository holds the code for a interenet connected RGB light. The hardware is based on very cheap LED floodlights available from chinese suppliers such as banggood.com:
- [10W version](http://www.banggood.com/Wholesale-10W-RGB-900LM-Color-Changing-Outdoor-Remote-LED-Flood-Wash-Light-85-265V-p-30587.html)
- [20W version](http://www.banggood.com/20W-RGB-Color-Changing-Outdoor-Remote-Control-LED-Flood-Light-85-265V-p-932666.html)

Replacing the internal logic of the floodlight and using an Espressif ESP8266 ESP-03 board to generate the necessary PWM signals, enables this floodlight to be remotely controlled from anywhere in the world.

--------------

The source scripts are meant for use with the nodeMCU lua interpreting firmware. Get the latest firmware from their repository (https://github.com/nodemcu/nodemcu-firmware).
This code builds on top of revision 0.9.5 of the firmware and does not use floating point operations.