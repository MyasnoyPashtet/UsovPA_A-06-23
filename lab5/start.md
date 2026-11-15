
**Сборка `boot.bin` из `boot.asm`**

```powershell
& 'C:\Program Files\NASM\nasm.exe' -f bin boot.asm -o boot.bin
```

**Запуск в QEMU**

```powershell
& 'C:\Program Files\qemu\qemu-system-i386.exe' -drive 'file=boot.bin,format=raw,if=floppy,readonly=on' -boot 'order=a'
```
