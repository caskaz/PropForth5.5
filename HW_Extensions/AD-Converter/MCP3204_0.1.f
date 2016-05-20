fl

{
PropForth 5.5(DevKernel)

A/D Converter(MCP3204)
2016/05/20 16:01:10

MCD3204      Propeller
CS     <---  _cs(P8)
Din    <---  _do(P9)    
Dout   --->  _di(P10)    
CLK    <---  _clk(P11)
         
}

\ ==================================================================
\ Constants
\ ================================================================== 
8 wconstant _cs         
9 wconstant _do               \ connect to MCP3204's Din         
d10 wconstant _di             \ connect to MCP3204's Dout
d11 wconstant _clk          
1 wconstant single
0 wconstant diff

\ ==================================================================
\ Variables
\ ================================================================== 
wvariable volt

\ ==================================================================
\ Main
\ ================================================================== 

1 _di lshift constant _dim
: _cs_l _cs pinlo ;
: _cs_h _cs pinhi ;
: _do_l _do pinlo ;
: _do_h _do pinhi ;
: _clk_l _clk pinlo ;
: _clk_h _clk pinhi ;
: clk_out _clk_l _clk_h ;

\ Get data from MCP3204( MCP3408 also usable)
\ Convert analog[0-3.3V] to digital[0-4095] 
\ ( n1 n2 -- n3 )   n1:channel [0 - 3] n2:single/diff   n3:A/D Conversion result
{
n2:0
differencial input for MCP3204
0: CH0=IN+ CH1= IN-
1: CH0=IN- CH1= IN+
2: CH2=IN+ CH3= IN-
3: CH2=IN- CH3= IN+

n2:1
single_end input for MCP3204
0: CH0
1: CH1
2: CH2
3: CH3

}
: MCP3204
_cs_l  
if h18 or then
\ Send start and control bit[5bit]
h10                      \ ( 5bit h10 )
5 0 do
     2dup and            \ ( 5bit h10 t/f )
     if _do_h then
     clk_out
     1 rshift            \ Shift 1bit to right
     _do_l
loop
2drop
\ dummy clock
clk_out
\ Receive data
0
d13 0 do
     1 lshift
     clk_out
     ina COG@ _dim and if 1+ then
loop
_cs_h
;

\ Assembler word
\ Get data from MCP3204( MCP3408 also usable)
\ Convert analog[0-3.3V] to digital[0-4095] 
\ ( n1 n2 n3 -- n4 )  n1:channel [0 - 3] n2:single/diff n3:top pin cpnnected to MCP3204  n6:result
lockdict create a_MCP3204 forthentry
$C_a_lxasm w, h13F  h113  1- tuck - h9 lshift or here W@ alignl h10 lshift or l,
z2WyaO1 l, zfiaRB l, z2Wia[u l, zfyaW1 l, z2Wiafv l, zfyab1 l, z2Wianw l, zfyaj1 l,
z1SyLI[ l, z2WiPZB l, z1SyLI[ l, z1YyPW1 l, z20oPO8 l, z20yPOG l, zfyPOR l, z2WyPb5 l,
z1[ix[u l, zgyPO1 l, z1bfx[v l, z1SyaKn l, z1[ix[v l, z3[yPf[ l, z1SyaKn l, z2WyPO0 l,
z2WyPbD l, zfyPO1 l, z1SyaKn l, z1YFail l, z20oPO1 l, z3[yPff l, z1[ix[x l, z1bix[u l,
z1SV01X l, z1[ix[x l, z2WyPWB l, z20iPak l, z3ryPW0 l, z1bix[x l, 0 l, z1SV000 l,
0 l, 0 l, 0 l, 0 l,
freedict

\ Print A/D data
\ ( -- )
: demo1
\ Set output ports
_cs pinout _cs_h _do pinout _clk pinout
begin 
     0 single MCP3204 . cr
     fkey? swap drop
until
;


\ Print A/D data by assembler word
\ ( -- )
: demo2
\ Set output ports
_cs pinout _cs_h _do pinout _clk pinout
begin 
     0 single _cs a_MCP3204 . cr
     fkey? swap drop
until
;

: tab 9 emit ;

\ Compare D/A output and MCP3204 ADC
\ Needing i2c_utility_0.4.1.f and MCP4725_0.2.f
\ ( -- )
: test
_cs pinout _do pinout _clk pinout
d4096 0 do
     i d30 u/mod drop 0=
     if 
     ." D/A output" tab  ." A/D-Converter(MCP3204)" tab ." A/D-Converter(MCP3204)asm" cr 
     then
     tab
     i dup . normal DAC_out
     d100 delms
     tab tab
     0 single MCP3204  . 
     tab tab tab 
     0 single _cs a_MCP3204 . cr 
                  
loop
;


{

( n1 n2 n3 -- n4 )  n1:channel [0 - 3] n2:single/diff n3:top pin cpnnected to MCP3204  n4:result
$C_treg1:working
$C_treg2:loop counter

fl
build_BootOpt :rasm
               \ get cs mask
          mov       __cs , # 1
          shl       __cs , $C_stTOS
               \ get do mask
          mov       __do , __cs
          shl       __do , # 1
               \ get di mask
          mov       __di , __do
          shl       __di , # 1
               \ get clk mask
          mov       __clk , __di
          shl       __clk , # 1
          spop
          
               \ check single/differential
          mov       $C_treg1 , $C_stTOS          
               \ [caution] Z-flag change after spop
          spop
               
               \ add single/diff bit to channel
          and       $C_treg1 , # 1 wz
if_nz     add       $C_stTOS , # 8
               \ add start bit 
          add       $C_stTOS , # h10
          
               \ send start and control bit[5bit] to MCP3204
          shl       $C_stTOS , # d27     
          mov       $C_treg2 , # 5
               \ set cs to Lo
          andn      outa ,  __cs
__1
          shl       $C_stTOS , # 1 wc
               \ set do to Hi
if_c      or        outa , __do
               \ out clk-pulse              
          jmpret    __clkout_ret , # __clkout
               \ set do to Lo
          andn      outa , __do
          djnz      $C_treg2 , # __1
          
               \ dummy clock
         jmpret    __clkout_ret , # __clkout      
          
               \ receive data
          mov       $C_stTOS , # 0
          mov       $C_treg2 , # d13
__2
          shl       $C_stTOS , # 1
               \ clock out
          jmpret    __clkout_ret , # __clkout
          test      __di , ina wz
if_nz     add       $C_stTOS , # 1
          djnz      $C_treg2 , # __2
                         
               \ set clk to Lo
          andn      outa , __clk 
               \ set cs to Hi
          or        outa , __cs
          jexit          
          
__clkout
          andn      outa , __clk 
          \ 24ticks from [mov $C_treg1 , # d11] to [waitcnt $C_treg1 , # 0]
          mov       $C_treg1 , # d11
          add       $C_treg1 , cnt
          waitcnt   $C_treg1 , # 0          
          or        outa , __clk
          nop
__clkout_ret
ret          

__cs
     0
__do
     0
__di
     0
__clk
     0
                         
;asm a_MCP3204
}
