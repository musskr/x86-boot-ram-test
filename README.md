# x86-boot-ram-test

16-bit boot sector written in nasm.

enters unreal mode to access memory above 1mb, writes a marker (0xdeadbeef) at 0x100000, and forces a triple fault to trigger a system reset. on the second boot, it checks if the marker survived.

## build & run
```bash
nasm -f bin boot.asm -o boot.bin
qemu-system-i386 -drive format=raw,file=boot.bin