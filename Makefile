AS=nasm
LD=ld
ASFLAGS=-f elf32
LDFLAGS=
OBJ=$(patsubst %.asm,%.o, $(wildcard *.asm))
TARGET=asmfuck
.PHONY: all main
all: $(TARGET)
$(TARGET): $(OBJ)
	$(LD) $(OBJ) $(LDFLAGS) -o $(TARGET)
%.o: %.asm
	$(AS) $(ASFLAGS) $< -o $@
clean:
	rm -f $(OBJ) $(TARGET)
