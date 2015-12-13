BOARD           := arduino
VARIANT         := standard
ARDUINO_HOME    := /opt/arduino
ARDUINO_LIBRARY := lib$(BOARD).a

AR  := "$(ARDUINO_HOME)/hardware/tools/avr/bin/avr-ar"
CC  := "$(ARDUINO_HOME)/hardware/tools/avr/bin/avr-gcc"
CXX := "$(ARDUINO_HOME)/hardware/tools/avr/bin/avr-g++"

MCU       := -mmcu=atmega328p
CPU_SPEED := -DF_CPU=16000000L
DEFINES   := -DARDUINO=10606 -DARDUINO_AVR_UNO -DARDUINO_ARCH_AVR
SFLAGS    := -g -x assembler-with-cpp $(MCU) $(CPU_SPEED) $(DEFINES)
CFLAGS    := -g -Os -Wall -Wextra -std=gnu11 -ffunction-sections -fdata-sections -MMD $(MCU) $(CPU_SPEED) $(DEFINES)
CXXFLAGS  := -g -Os -Wall -Wextra -std=gnu++11 -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics -MMD $(MCU) $(CPU_SPEED) $(DEFINES)

ARDUINO_ROOT        := $(ARDUINO_HOME)/hardware/$(BOARD)/avr
ARDUINO_INCLUDE     := include/cores/arduino include/variants/$(VARIANT)
ARDUINO_S_OBJECTS   := $(patsubst %,%.o,$(shell find src/cores/$(BOARD) -name *.S))
ARDUINO_C_OBJECTS   := $(patsubst %,%.o,$(shell find src/cores/$(BOARD) -name *.c))
ARDUINO_CXX_OBJECTS := $(patsubst %,%.o,$(shell find src/cores/$(BOARD) -name *.cpp))

default: import compile
	mkdir -p lib
	$(AR) rcs lib/$(ARDUINO_LIBRARY) $(ARDUINO_S_OBJECTS)
	$(AR) rcs lib/$(ARDUINO_LIBRARY) $(ARDUINO_C_OBJECTS)
	$(AR) rcs lib/$(ARDUINO_LIBRARY) $(ARDUINO_CXX_OBJECTS)

import: clean
	mkdir -p src include
	rsync -av --include='*.S' --include='*.c' --include='*.cpp' --include='*/' --exclude='*' "$(ARDUINO_ROOT)/" ./src
	rsync -av --include='*.h' --include='*.hpp' --include='*/' --exclude='*' "$(ARDUINO_ROOT)/" ./include

compile: $(ARDUINO_S_OBJECTS) $(ARDUINO_C_OBJECTS) $(ARDUINO_CXX_OBJECTS)

%.S.o : %.S
	$(CC) -c $(SFLAGS) $(foreach var,$(ARDUINO_INCLUDE),-I$(var)) $< -o $@

%.c.o : %.c
	$(CC) -c $(CFLAGS) $(foreach var,$(ARDUINO_INCLUDE),-I$(var)) $< -o $@

%.cpp.o : %.cpp
	$(CXX) -c $(CXXFLAGS) $(foreach var,$(ARDUINO_INCLUDE),-I$(var)) $< -o $@

clean:
	rm -rf lib src include
