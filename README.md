# core
vivadoのimplementation strategyはPerformance_NetDelay_high

## 1st
+ 5段パイプラインコア、キャッシュあり(core 100Mhz, uart 100Mhz) 
+ 実行時間 16x16 2.8s 128x128 47s
+ GShare predictor
+ vlw

## 仕様
### Memory
+ Big endian

Data Memory(2^27 byte)
+ 0x0000000からstatic data,heap,stack,MMIOが割り当てられる。

MMIO
+ 0x3FFFFFC: uart_addr

uart_in_valid, uart_out_validは用意せず、一つのuart_addrのみ使う。
uart_addrにlwしたら、送信、uart_addrにswしたら受信。
送信や受信ができない場合はstallする。

Instruction Memory
+ Data Memoryとは別のメモリ空間
+ サイズは2 ^ 17 byte

### Instruction
RISC-VのRV32IFの一部と命令メモリに書き込むための命令swi(store word instruction)と独自拡張

### 実行時間予測用パラメータ
+ lwの直後に依存のある命令 +1
+ fadd, fsub +3 
+ fmul +2
+ fsqrt +7
+ fdiv +11
+ fcvtsw +2
+ fcvtws +1
+ jalr +2
+ branchの予測はPHTのサイズが256bitのGShare predictor, 予測が失敗すると+2
+ lw hit時 +1
+ sw hit時 +1
+ baudrate 2304000
 
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
  li t2, 0x3FFFFFC # uart addr

  addi t0, zero, 0x99
  sw t0, 0(t2) # uart_tx
# receive program size  
  lw t1, 0(t2) # uart_rx
  slli t1, t1, 8

  lw t0, 0(t2) # uart_rx
  or t1, t1, t0
  slli t1, t1, 8

  lw t0, 0(t2) # uart_rx
  or t1, t1, t0
  slli t1, t1, 8

  lw t0, 0(t2) # uart_rx
  or t1, t1, t0

# receive program   
  li a2, 0x100 # program start point
pload:

  lw a1, 0(t2) # uart_rx
  slli a1, a1, 8

  lw a0, 0(t2) # uart_rx
  or a1, a1, a0
  slli a1, a1, 8

  lw a0, 0(t2) # uart_rx
  or a1, a1, a0
  slli a1, a1, 8

  lw a0, 0(t2) # uart_rx
  or a1, a1, a0

  swi a1, 0(a2)
  addi a2, a2, 4
  addi t1, t1, -4
  blt zero, t1, pload

  addi t0, zero, 0xaa
  sw t0, 0(t2) # uart_tx

  # jump progarm
  jalr zero, 0x100(zero)
```