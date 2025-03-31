# Bare minimum x86-64 bootloader/OS
Attempt to write x86_64 NASM code for a small bootloader

Originally wrote this code before finding out UEFI is very very different.

If you're finding this while you try to develop an OS, heres some notes:

BIOS was originally very vendor specific and resulted in thousands of different "functions" available.

UEFI was made to solve this issue and has stricter rules.

Things like this project can still run in class 0, 1, and 2, but never 3 (Explanation further down.)

You'll have to either use a VM/QEMU or enable "CSM" in your systems UEFI setup.

The different classes are:

- 0: Legacy BIOS only
- 1: Runs exclusively in CSM mode, may not even show that it has UEFI support
- 2: Supports UEFI and Legacy BIOS in CSM
- 3: UEFI only

CSM = Compatibility Support Mode

I learned these things from the following article, I suggest reading it if you haven't!

https://wiki.osdev.org/UEFI

I will now be moving on from this repository to write an UEFI bootloader instead!

## How this BIOS "bootloader" works

Although only printing some text, the code may seem very complicated at first.
If you've wrote assembly beforehand, you probably know how interupts and kernel calls work.
During BIOS theres BIOS interupt for doing various things, but I mention above that there are thousands
and thousands of them available, some if not most not even working unless you're on a very specific machine

If you'd like to try this out, I included a zsh script to try it in QEMU. (Note I only really tested this on Arch)

You'll need: 

- nasm
- dd
- mkdir
- cp
- rm
- trap
- genisoimage
- qemu-system-i386

```zsh
./runner.zsh --run
```