ifeq ($(strip $(V)),)
	E = @echo
	Q = @
else
	E = @\#
	Q =
endif
export E Q

CROSS_PREFIX=aarch64-none-elf-
CFLAGS += -I include

all: workload.bin

main.o: main.c
	$(E) "  CC      " $@
	$(Q) $(CROSS_PREFIX)gcc $(CFLAGS) -c $< -o $@

uart.o: modules/uart/pl011.c
	$(E) "  CC      " $@
	$(Q) $(CROSS_PREFIX)gcc $(CFLAGS) -c $< -o $@

head.o: aarch64/head.s
	$(E) "  AS      " $@
	$(Q) $(CROSS_PREFIX)as -c $< -o $@

workload.elf: main.o head.o uart.o
	$(E) "  LINK    " $@
	$(Q) $(CROSS_PREFIX)ld -Tscripts/baremetal.ld $^ -o $@

workload.bin: workload.elf
	$(E) "  OBJCOPY " $@
	$(Q) $(CROSS_PREFIX)objcopy -O binary $< $@

run:
	$(E) "[TinyBox Emulator]"
	$(Q) @make
	$(Q) @clear
	$(Q) qemu-system-aarch64 -M virt -cpu cortex-a57 -nographic -kernel workload.bin

clean:
	$(E) "  CLEAN   "
	$(Q) rm -f  workload.* *.o
