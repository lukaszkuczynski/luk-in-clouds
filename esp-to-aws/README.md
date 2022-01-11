# ESP to AWS
The goal of this project is to show how easy it is to move data from your own hand-made device to the AWS cloud.

## Sensor to MCU

## MCU to local MQTT

## local MQTT to AWS
In this step we want to move data from local MQTT to AWS cloud. To make it happen we use MQTT functionality called bridging - I can connect 2 MQTT brokers together so they exchange data in topics between each other. 

AWS is very extensive platform that gives you hosted MQTT broker, too. So the most important step here I used is to bridge my local with cloud MQTT broker. I followed the instructions [from AWS blogpost](https://aws.amazon.com/blogs/iot/how-to-bridge-mosquitto-mqtt-broker-to-aws-iot/). Go to section *Check How to Configure the Bridge to AWS IoT Core*, I did not need to use EC2 in this regard. In general it is enough to get some certificates from AWS and update bridge.conf entries - if you will encounter issues let me know, I can help.
When we bridged our MQTT networks we should test it. And if you will test it and it works we are ready to go, to use it in the cloud.
