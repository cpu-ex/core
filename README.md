# core

## 1st完動までのtodo
+ 目標としてはシングルサイクルで正常に動くコアを作る。(core 10Mhz, uart 100Mhz)
+ マルチサイクルまたはパイプラインにする可能性があります。
+ DRAMのメモリと合流
+ FPUと合流
+ 完動?

## 2ndの予定
+ パイプラインにする。
+ ??

## 仕様
### Memory
+ Big endian

Data Memory(2^26 byte)
+ 0x0000000からstatic data,heap,stack,MMIOが割り当てられる。

MMIO
+ 0x3FFFFF0: uart_in
+ 0x3FFFFF4: uart_in_valid
+ 0x3FFFFF8: uart_out_valid
+ 0x3FFFFFC: uart_out

Instruction Memory
+ Data Memoryとは別のメモリ空間
+ サイズはまだ決まってない。

### Instruction
RISC-VのRV32IFの一部と命令メモリに書き込むための命令swi(store word instruction)
 
### bootloader
0x00000000からbootloaderが置かれていて、プログラムを0x00000100にloadする。
loadし終わると、0x00000100にjumpして実行を開始

bootloader
```python
  .globl main
  .text
main:
  addi t0, zero, 256
loop: # wait fifo reset
  addi t0, t0, -1
  blt zero, t0, loop
out99:
  lw t0, 8(zero) # uart_out_valid
  beq t0, zero, out99
  addi t0, zero, 0x99
  sw t0, 12(zero) # uart_tx
# receive program size  
load1:
  lw t0, 4(zero) # uart_in_valid
  beq t0, zero, load1
  lw t1, 0(zero) # uart_rx
  slli t1, t1, 8
load2:
  lw t0, 4(zero) # uart_in_valid
  beq t0, zero, load2
  lw t0, 0(zero) # uart_rx
  or t1, t1, t0
  slli t1, t1, 8
load3:
  lw t0, 4(zero) # uart_in_valid
  beq t0, zero, load3
  lw t0, 0(zero) # uart_rx
  or t1, t1, t0
  slli t1, t1, 8
load4:
  lw t0, 4(zero) # uart_in_valid
  beq t0, zero, load4
  lw t0, 0(zero) # uart_rx
  or t1, t1, t0

# receive program   
  li a2, 0x100 # program start point
pload1:
  lw a0, 4(zero) # uart_in_valid
  beq a0, zero, pload1
  lw a1, 0(zero) # uart_rx
  slli a1, a1, 8
pload2:
  lw a0, 4(zero) # uart_in_valid
  beq a0, zero, pload2
  lw a0, 0(zero) # uart_rx
  or a1, a1, a0
  slli a1, a1, 8
pload3:
  lw a0, 4(zero) # uart_in_valid
  beq a0, zero, pload3
  lw a0, 0(zero) # uart_rx
  or a1, a1, a0
  slli a1, a1, 8
pload4:
  lw a0, 4(zero) # uart_in_valid
  beq a0, zero, pload4
  lw a0, 0(zero) # uart_rx
  or a1, a1, a0

  swi a1, 0(a2)
  addi a2, a2, 4
  addi t1, t1, -4
  blt zero, t1, pload1

outaa:
  lw t0, 8(zero) # uart_out_valid
  beq t0, zero, outaa
  addi t0, zero, 0xaa
  sw t0, 12(zero) # uart_tx

  # jump progarm
  jalr zero, 0x100(zero)
```