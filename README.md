# core
なんか頭の中がごちゃごちゃになってきたので整理のために1st完動までのtodoを整理します。

## 1st完動までのtodo

+ 目標としてはシングルサイクルで正常に動くコアを作る。(core 20Mhz, uart 100Mhzでその間はasync fifoでつなぐ。)
+ 命令はすべて実装した。
+ uartの入出力はいまはin,out命令で行っているがなんか気に入らないのでMMIOにしたい、それに合わせてレジスタから命令メモリに書き込む命令SWI(store word instruction)を付け足す。(done)
+ bootloaderをそれに合わせて書き直す。(done)
+ シュミレーションでテストする。このテストはフィボナッチのプログラムでやる。(done)
+ 全命令のテスト
+ pyserialでPCからのシリアル通信を実装して、実機でもテストする。これもフィボナッチ
+ DRAMのメモリと合流
+ FPUと合流
+ 完動?

## 2ndの予定
+ パイプラインにする。
+ ??

## MMIO
とりあえず今のところの実装では
+ 0x00000000: uart_in
+ 0x00000004: uart_in_valid
+ 0x00000008: uart_out_valid
+ 0x0000000c: uart_out
になってます。(1st/src/cpu.sv l79~l89参照)
 
## bootloaderの実装
0x00000000からbootloaderが置かれていて、loadし終わると
0x00000100にjumpして実行を開始します。
(dataとinstrを同じメモリ空間に置くならuartかbootloaderの置く位置を変える。)

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