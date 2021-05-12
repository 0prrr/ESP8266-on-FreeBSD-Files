ifndef SKETCH
    $(error No SKETCH file defined...)
endif

CUR_DIR:=$(shell pwd)
BUILD_DATE=$(shell date '+%Y%m%d-%H%M%S')
BUILD_DIR?=/tmp/arduino_build_$(BUILD_DATE)
BUILD_CACHE_DIR=/tmp/arduino_cache_$(BUILD_DATE)

BOARD_TAG?=nodemcuv2
CHIP?=esp8266
FQBN=espressif:$(CHIP):$(BOARD_TAG):xtal=80

USER_ARDUINO_ROOT?=$(HOME)/Arduino
ARDUINO_SYS_DIR?=/usr/local/arduino

ARDUINO_BUILDER?=/usr/local/bin/arduino-builder
ARDUINO_HARDWARE_DIR?=$(ARDUINO_SYS_DIR)/hardware
ARDUINO_TOOLS_BUILDER?=$(ARDUINO_SYS_DIR)/tools-builder
ARDUINO_SYS_LIBS?=$(ARDUINO_SYS_DIR)/libraries
ARDUINO_USER_LIBS?=$(USER_ARDUINO_ROOT)/libraries
BAUD_RATE?=115200
IDE_VERSION=10805

ESP_DIR?=$(ARDUINO_HARDWARE_DIR)/espressif/esp8266
ESP_TOOLS_DIR?=$(ESP_DIR)/tools
PY3_BIN?=$(ESP_TOOLS_DIR)/python3/python3
CORE_VER_SCRIPT?=$(ESP_TOOLS_DIR)/makecorever.py
SIZES_SCRIPT?=$(ESP_TOOLS_DIR)/sizes.py
UPLOAD_SCRIPT?=$(ESP_TOOLS_DIR)/upload.py
ESP_LIB_VER?=unix-2.7.4

show:
	$(foreach V,$(sort $(.VARIABLES)),$(if $(filter-out environment% default automatic,$(origin $V)),$(warning $V=$($V) ($(value $V)))))

upload:
	mkdir -p $(BUILD_DIR)
	mkdir -p $(BUILD_CACHE_DIR)
	$(ARDUINO_BUILDER) -compile -logger=machine -hardware $(ARDUINO_HARDWARE_DIR) -tools $(ARDUINO_TOOLS_BUILDER) -built-in-libraries $(ARDUINO_SYS_LIBS) -libraries $(ARDUINO_USER_LIBS) -fqbn=$(FQBN),vt=flash,exception=legacy,ssl=all,eesz=4M2M,led=2,ip=lm2f,dbg=Disabled,lvl=None____,wipe=none,baud=$(BAUD_RATE) -ide-version=$(IDE_VERSION) -build-path $(BUILD_DIR) -warnings=none -build-cache $(BUILD_CACHE_DIR) -prefs=build.warn_data_percentage=75 -verbose $(CUR_DIR)/$(SKETCH)
	$(PY3_BIN) $(CORE_VER_SCRIPT) --build_path $(BUILD_DIR) --platform_path $(ESP_DIR) --version "$(ESP_LIB_VER)"
	$(PY3_BIN) $(SIZES_SCRIPT) --elf $(BUILD_DIR)/*.elf --path $(ESP_TOOLS_DIR)/xtensa-lx106-elf/bin
	$(PY3_BIN) $(UPLOAD_SCRIPT) --chip $(CHIP) --port $(UPLOAD_PORT) --baud $(BAUD_RATE) --before default_reset --after hard_reset write_flash 0x0 $(BUILD_DIR)/*.bin

clean:
	rm -rf /tmp/arduino*
