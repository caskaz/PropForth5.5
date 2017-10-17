fl

{
PropForth 5.5(DevKernel)
PulseMonitor

2017/10/16 17:18:48

                                                                 Vcc
                                                                 |
Sensor            A=100          A=100                      -----------
(NJL5501R)        ------         ------         MCP3204    |           |
 --------      - |      |out  - |      |out  CH0 -----     | Propeller |
|        |-------| INV- |-------| INV- |--------| ADC |----|           |
|        |     + |  AMP |     + |  AMP |         -----     |           |
 --------     ---|      |    ---|      |                   |           |
             |   |      |   |   |      |        ST7735R    |           |
             |    ------    |    ------        --------    |           |
            Vcc/2          Vcc/2              |  LCD   |---|           |
                                              |        |   |           |
                                               --------    |           |
                                                           |           |
                                              ----------   |           |
                                             | Rotary   |--|           |
                                             |  Encoder |Å@|           |
                                             |  with SW |  |           |
                                              ----------   |           |
                                                           |           |
                                              ----------   |           |
                                             |  RTC     |--|           |
                                              ----------   |           |
                                                            -----------
                                                                 |
                                                                GND
A/D Converter(MCP3204)
MCP3204      Propeller
CS     <---  _cs(P5)
Din    <---  _do(P6)    
Dout   --->  _di(P7)    
CLK    <---  _clk(P8)
CH0   ---------------------- Analog signal

Using single mode on CH0 
   
Store current A/D value to buffer[128] 
Shift dot from buffer [n+1] to buffer[n]  

LCD:T18003T01(ST7735R)
     LCD         Propeller
     RES  -----  P0
     RS   -----  P1
     SDA  -----  P2
     SCL  -----  P3
     CS   -----  P4

   [x,y]=[129,160]              [x,y]=[2,160]
     -------------------------- YE=160  
    |[]                      []|        ^    
    |                          |        |
    |                          |        |
    |                          |        |
    |                          |        | Pulse level
    |                          |        |
    |         LCD              |   row  |  
    |                          |        |
    |                          |        |
    |                          |        |
    |                          |        |
    |                          |        |
    |[]                      []| YS=1    
     --------------------------  [x,y]=[2,1] 
    XE=129                  XS=2 
   [x,y]=[129,1]    column
  buffer[0]                  buffer[127]
    ---------------------------> Time

ThermalPrinter(CSN-A2-T)
                             CSM-A2-T     PowerSupply
                              1 GND ------ GND
                              2 NC
 Propeller                    3 VH  ------ 5V4A
  Gnd ----------------------- 4 Gnd           
                          
 P9(Rx)  -------------------- 5 Tx (3V3 when idle)
 P10(Tx) -------------------- 6 Rx (3V3 when idle)
               
    
RS232  19200bps  Noparity Stopbit1
time ------------------------------------------------------------>>
-------       ---------                               ------------
       |     |         |                             |
       |     |         |                             | 
        -----           -----------------------------
 idle   start bit0 bit1 bit2 bit3 bit4 bit5 bit6 bit7 stop  stop   idle
         bit                                           bit
       (always "0")                                  (always "1")
                                          
switch
                       
                3V3
                 |
                10kohm
                 |
       P11 ------|
                 |
                sw
                 |
                GND
                
rtc(PCF2129AT)

Propeller       PCF2129AT
               ------------
SCL  ---------|SCL      Vcc|---3V3
SDA  ---------|SDA     VBAT|---battery---- GND
       GND ---|SDI      BBS|---
              |            |   |
       GND ---|Vss      IFS|---
               ------------
                     

}

\ ==================================================================
\ Constants
\ ================================================================== 
\ ----- ADC ----- 
5 wconstant cs         
6 wconstant _do               \ connect to MCP3204's Din         
7 wconstant di                \ connect to MCP3204's Dout
8 wconstant clk          
cs >m constant mcs

\ ----- LCD -----
0 wconstant RES
1 wconstant D/CX
2 wconstant SDA
\ 3 wconstant SCL
4 wconstant CSX
SDA >m constant mSDA

wvariable initData -2 allot
hB4 c, 1 c, 7 c,                             \ colum inversion
hC0 c, 3 c, hA2 c, h02 c, h84 c,             \ power control 1
hC1 c, 1 c, hC5 c,                           \ power control 2
hC2 c, 2 c, h0A c, h00 c,                    \ power control 3
hC3 c, 2 c, h8A c, h2A c,                    \ power control 4
hC4 c, 2 c, h8A c, hEE c,                    \ power control 5
hC5 c, 1 c, h0E c,                           \ VCOM
h36 c, 1 c, hC8 c,                           \ Mwmory data access control [] MX, MY, BGR-Mode ]
\ Gammma Sequence
hE0 c, d16 c, h02 c, h1C c, h07 c, h12 c, h37 c, h32 c, h29 c, h2D c, h29 c, h25 c, 
h2B c, h39 c, h00 c, h01 c, h03 c, h10 c,    \ VCOM
hE1 c, d16 c, h03 c, h1D c, h07 c, h06 c, h2E c, h2C c, h29 c, h2D c, h2E c, h2E c,
h37 c, h3F c, h00 c, h00 c, h02 c, h10 c,         
h2A c, 4 c, h00 c, h02 c, h00 c, h81 c,      \ set column address    
h2B c, 4 c, h00 c, h01 c, h00 c, hA0 c,      \ set row address
\ Interface pixel format
h3A c, 1 c, h05 c,                           \ 16bits/pixel RGB 5-6-5bit   

d800000 constant 10msec
wvariable buffer d126 allot   \ Buffer for ADC
buffer d127 + constant bufferEnd

\ character font
wvariable font -2 allot
\ char"0"
h03E0 w, h0FF8 w, h1FFC w, h1F1C w, h3B0E w, h3B8E w, h3B8E w, h398E w, h398E w, h398E w, h39CE w, h39CE w, h38CE w, h38CE w, h38CE w, h38EE w, h38EE w, h386E w, h1C7C w, h1FFC w, h0FF8 w, h03E0 w,
\ char"1"
h3FFE w, h3FFE w, h3FFE w, h01C0 w, h01C0 w, h01C0 w, h01C0 w, h01C0 w, h01C0 w, h01C0 w, h01C0 w, h01C0 w, h01C0 w, h01C0 w, h01C0 w, h39C0 w, h3DC0 w, h1FC0 w, h0FC0 w, h07C0 w, h03C0 w, h01C0 w,
\ char"2"
h3FFE w, h3FFE w, h3FFE w, h3800 w, h3800 w, h3C00 w, h1C00 w, h1E00 w, h0F80 w, h07C0 w, h01F0 w, h00F8 w, h003C w, h001C w, h000E w, h000E w, h380E w, h380E w, h1C1C w, h1FFC w, h0FF8 w, h03E0 w,
\ char"3"
h03E0 w, h0FF8 w, h1FFC w, h1C1C w, h380E w, h380E w, h000E w, h000E w, h000E w, h001C w, h03FC w, h03F8 w, h03FC w, h001C w, h000E w, h000E w, h380E w, h380E w, h1C1C w, h1FFC w, h0FF8 w, h03E0 w,
\ char"4"
h0070 w, h0070 w, h0070 w, h0070 w, h0070 w, h3FFE w, h3FFE w, h3FFE w, h1C70 w, h1C70 w, h1C70 w, h0E70 w, h0E70 w, h0E00 w, h0700 w, h0700 w, h0700 w, h0380 w, h0380 w, h0380 w, h01C0 w, h01C0 w,
\ char"5"
h03E0 w, h0FF8 w, h1FFC w, h1C1C w, h380E w, h380E w, h000E w, h000E w, h000E w, h000E w, h381C w, h3FFC w, h3FF8 w, h3BE0 w, h3800 w, h3800 w, h3800 w, h3800 w, h3800 w, h3FFC w, h3FFC w, h3FFC w,
\ char"6"
h03E0 w, h0FF8 w, h1FFC w, h1C1C w, h380E w, h380E w, h380E w, h380E w, h380E w, h380E w, h3C1C w, h3FFC w, h3FF8 w, h3BE0 w, h3800 w, h3800 w, h380E w, h380E w, h1C1C w, h1FFC w, h0FF8 w, h03E0 w,
\ char"7"
h0380 w, h0380 w, h0380 w, h01C0 w, h01C0 w, h01C0 w, h00E0 w, h00E0 w, h00E0 w, h0070 w, h0070 w, h0070 w, h0038 w, h0038 w, h0038 w, h001C w, h001C w, h001C w, h000E w, h3FFE w, h3FFE w, h3FFE w,
\ char"8"
h03E0 w, h0FF8 w, h1FFC w, h1C1C w, h380E w, h380E w, h380E w, h380E w, h380E w, h1C1C w, h1FFC w, h0FF8 w, h1FFC w, h1C1C w, h380E w, h380E w, h380E w, h380E w, h1C1C w, h1FFC w, h0FF8 w, h03E0 w,
\ char"9"
h03E0 w, h0FF8 w, h1FFC w, h1C1C w, h380E w, h380E w, h000E w, h000E w, h03EE w, h0FFE w, h1FFE w, h1C1E w, h380E w, h380E w, h380E w, h380E w, h380E w, h380E w, h1C1C w, h1FFC w, h0FF8 w, h03E0 w,
\ char" " 
h0000 w, h0000 w, h0000 w, h0000 w, h0000 w, h0000 w, h0000 w, h0000 w, h0000 w, h0000 w, h0000 w, h0000 w, h0000 w, h0000 w, h0000 w, h0000 w, h0000 w, h0000 w, h0000 w, h0000 w, h0000 w, h0000 w,

\ ----- pulseMonitor -----
d160000 constant 2msec

\ ----- Printer -----
\ Priner command
\ command-name( n1 n2 n3-nn) n1:command byte number n2:data byte number n3:command byte(1byte /2byte/nbyte) 
wvariable LF -2 allot 1 c, 0 c, h0A c,
wvariable GS_! -2 allot 2 c, 1 c, h1D c, h21 c,          
wvariable DC2_* -2 allot 2 c, 2 c, h12 c, h2A c,
wvariable ESC_7 -2 allot 2 c, 3 c, h1B c, h37 c,
wvariable DC2_# -2 allot 2 c, 1 c, h12 c, h23 c,
\ Init command
wvariable ESC_@ -2 allot 2 c, 0 c, h1B c, h40 c,
wvariable result
variable tmp
\ serial for PropForth<-->ThermalPrinter
9 wconstant Rx
d10 wconstant Tx
d4800 constant baud/4    \ 19200/4

\ ----- switch ------
d11 wconstant swpin
d800000 constant 10msec
swpin >m constant swMask
\ ledpin >m constant ledMask

\ ----- rtc -----
\ Slave addres h51 for PCF2129 
hA2 wconstant rtc
 
\ ==================================================================
\ Variables
\ ================================================================== 
\ ----- LCD -----
wvariable ADC
wvariable stopPrinter

\ ----- pulseMonitor -----
wvariable pulseVar d46 allot
pulseVar constant signal
pulseVar 2+ constant thresh
pulseVar 4+ constant Pulse
pulseVar 6 + constant N
pulseVar 8 + constant calcIBI
pulseVar d10 + constant IBI
pulseVar d12 + constant currentBeat
pulseVar d14 + constant lastBeat
pulseVar d16 + constant P
pulseVar d18 + constant T
pulseVar d20 + constant amp
pulseVar d22 + constant rate
pulseVar d42 + constant pulseValue
pulseVar d44 + constant 1stBeat
pulseVar d46 + constant 2ndBeat
{
n         update timer[0-500]      2byte
m         index for Digit^display  2byte
mSDA      mask of sda:             4byte
font      address for font         2byte
Digit3    char-cod for Digit3      2byte
Digit2    char-cod for Digit2      2byte
Digit1    char-cod for Digit1      2byte
}
variable varNum -4 allot
0 l, mSDA l, font w, 0 w, 0 w, 0 w,

\ ----- ThermalPrinter ------
wvariable inchar
wvariable prnBuffer d46 allot \ Buffer for Thermalprinter[384bit=384dots]

\ ----- switch ------
variable DebounceTime
wvariable swState
wvariable debounce

