SKETCH=$(wildcard *.ino)
ESP_DIR=/path/to/your/esp8266/repo
UPLOAD_PORT=/dev/cuaU0
CHIP=esp8266
BOARD_TAG=nodemcuv2
BAUD_RATE=115200
ESP_LIB_VER=unix-2.7.4
VERBOSE=1

include /path/to/your/esp8266-build.mk
