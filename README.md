# core
+ vivado の implementation strategy は Flow_RunPostRoutePhysOpt
+ main は vlw, vsw ありのコア、without-vlw branch は vlw, vsw なしのコア
+ vlw ありは最終的に動かなかったため、記録は without-vlw のもの
+ vlw なしのメモリは cpu-ex/memory の 9c38c89bdffe67db975bf28afe93cfe74eabfb3a を使用。

## 1st
+ 5段パイプラインコア、キャッシュあり(core 100Mhz, uart 100Mhz)
+ GShare predictor
+ 実行時間 128x128 43.873s 512x512 494.393s
+ fliが64bit命令

## 仕様
### Memory
+ Big endian

Data Memory(2^27 byte)
+ 0x0000000からstatic data,heap,stack,MMIOが割り当てられる。

MMIO
+ 0x0: uart_addr

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
+ fdiv +10
+ fcvtsw +1
+ fcvtws +1
+ jalr +2
+ branchの予測はPHTのサイズが512bitのGShare predictor, 予測が失敗すると+2
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

  addi t0, zero, 0x99
  sw t0, 0(x0) # uart_tx
# receive program size  
  lw t1, 0(x0) # uart_rx
  slli t1, t1, 8

  lw t0, 0(x0) # uart_rx
  or t1, t1, t0
  slli t1, t1, 8

  lw t0, 0(x0) # uart_rx
  or t1, t1, t0
  slli t1, t1, 8

  lw t0, 0(x0) # uart_rx
  or t1, t1, t0

# receive program   
  li a2, 0x100 # program start point
pload:

  lw a1, 0(x0) # uart_rx
  slli a1, a1, 8

  lw a0, 0(x0) # uart_rx
  or a1, a1, a0
  slli a1, a1, 8

  lw a0, 0(x0) # uart_rx
  or a1, a1, a0
  slli a1, a1, 8

  lw a0, 0(x0) # uart_rx
  or a1, a1, a0

  swi a1, 0(a2)
  addi a2, a2, 4
  addi t1, t1, -4
  blt zero, t1, pload

  addi t0, zero, 0xaa
  sw t0, 0(x0) # uart_tx

  # jump progarm
  jalr zero, 0x100(zero)
```