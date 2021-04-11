# SaiOS

## Building instructions 

Windows change `pwd` to `%cd%`

### Docker building
```bash
docker build -t linux-build-env .
docker run -it --rm -v `pwd`:/root/env linux-build-env
make 
```

### Emulation

There are multiple options for emulators including, but not limited to:
* QEMU (Which I picked)
* Bochs
* Oracle VMBox
* VMWare

```bash
qemu-system-x86_64 -fda ./build/img/disk.img
```

### Debugging 

For debugging, I tried using gdb-multiarch, but radare2 dealt with it the best

```bash
# 0x9000 is kmain (Look at ./build/img/os.map for updated values)
qemu-system-x86_64 -fda ./build/img/disk.img -gdb tcp::9001 -S & \
    r2 -m 0x9000 -b 64 -d gdb://localhost:9001
```

#### Inside radare2
```bash
e dbg.bpinmaps=0 # Might not have to do this, it caused issues for me though
db 0x9000
dc
V!

# Step into
s
# Step over 
S 

# Seek to PC / RIP
.
# Commands 
:
# Help
?
```
