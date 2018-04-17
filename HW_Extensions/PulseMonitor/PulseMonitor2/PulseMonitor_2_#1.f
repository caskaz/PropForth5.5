fl

{
PropForth 5.5(DevKernel)
PulseMonitor

Variables/Constants

2018/04/17 19:52:28

                                                                 Vcc
                                   max20                              |
Sensor            A=100          A=min10                      -----------
  (RPR220)        ------         ------         MCP3204    |           |
 --------      - |      |out  - |      |out  CH0 -----     | Propeller |
|        |-------| INV- |-------| INV- |--------| ADC |----|P5-P8      |
|        |     + |  AMP |     + |  AMP |         -----     |           |
 --------     ---|      |    ---|      |                   |           |
             |   |      |   |   |      |        ST7735R    |           |
             |    ------    |    ------        --------    |           |
            Vcc/2          Vcc/2              |  LCD   |---|P0-P4      |
                                              |        |   |           |
                                               --------    |           |                                                           |           |
                                              ----------   |           |
                                             |  RTC     |--|P28,P29    |
                                              ----------   |           |
                                              ----------   |           |
                                             |  Printer |--|P9,P10     |
                                              ----------   |           |                                              
                                              ----------   |           |
                                             |  sw1     |--|P11        |
                                              ----------   |           |
                                              ----------   |           |
                                             |  sw2     |--|P12        |
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
     
    
   [x,y]=[129,1]              [x,y]=[129,160]
     ---------------------------------- XS=129  
    |[]                              []|        ^    
    |                                  |        |
    |                                  |        |
    |                                  |        | Pulse magnitude
    |                                  |        |
    |                LCD               |x:column|  
    |                                  |        |
    |                                  |        |
    |[]                              []| XE=2    
     ----------------------------------  [x,y]=[2,160] 
    YS=1                             YE=160 
   [x,y]=[2,1]    y:row
  here W@                           here W@ + 636
  buffer[0]                         buffer[159]
    -----------------------------------> Time
     
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
                       
                3V3                 3V3
                 |                   |
                10kohm              10kohm
                 |                   |
       P11 ------|         P12 ------|
                 |                   |
               sw1(NO)              sw2(NO)
                 |                   |
                GND                 GND
             Function switch      Print switch
             
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

: PULSE ;

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

\ character font
variable fontTable -4 allot
\ char"0"
h0000_0000 l, h0000_0000 l, h007F_FE00 l, h01FF_FF80 l, h03FF_FFC0 l, h0380_01C0 l, h0700_0FE0 l, h0701_FFE0 l,
h073F_FCE0 l, h07FF_80E0 l, h07F0_00E0 l, h0380_01C0 l, h03FF_FFC0 l, h01FF_FF80 l, h007F_FE00 l, h0000_0000 l,
\ char"1"
h0000_0000 l, h0000_0000 l, h0030_00E0 l, h0070_00E0 l, h00F0_00E0 l, h01E0_00E0 l, h03C0_00E0 l, h07FF_FFE0 l,
h07FF_FFE0 l, h07FF_FFE0 l, h0000_00E0 l, h0000_00E0 l, h0000_00E0 l, h0000_00E0 l, h0000_00E0 l, h0000_0000 l,
\ char"2"
h0000_0000 l, h0000_0000 l, h0060_07E0 l, h01E0_1FE0 l, h03E0_3FE0 l, h0380_7CE0 l, h0700_70E0 l, h0700_E0E0 l,
h0701_E0E0 l, h0701_C0E0 l, h0703_80E0 l, h0387_80E0 l, h03FF_00E0 l, h01FE_00E0 l, h0078_00E0 l, h0000_0000 l,
\ char"3"
h0000_0000 l, h0000_0000 l, h0060_0600 l, h01E0_0780 l, h03E0_07C0 l, h0380_01C0 l, h0703_80E0 l, h0703_80E0 l,
h0703_80E0 l, h0703_80E0 l, h0703_80E0 l, h0387_C1C0 l, h03FF_FFC0 l, h01FE_FF80 l, h0078_3E00 l, h0000_0000 l,
\ char"4"
h0000_0000 l, h0000_0000 l, h0000_1C00 l, h0000_FC00 l, h0007_FC00 l, h003F_FC00 l, h01FF_1C00 l, h07F8_1C00 l,
h07C0_1C00 l, h0603_FFE0 l, h0003_FFE0 l, h0003_FFE0 l, h0000_1C00 l, h0000_1C00 l, h0000_1C00 l, h0000_0000 l,
\ char"5"
h0000_0000 l, h0000_0000 l, h07FF_8600 l, h07FF_8780 l, h07FF_87C0 l, h0703_01C0 l, h0707_00E0 l, h0707_00E0 l,
h0707_00E0 l, h0707_00E0 l, h0707_00E0 l, h0703_81C0 l, h0703_FFC0 l, h0701_FF80 l, h0000_7E00 l, h0000_0000 l,
\ char"6"
h0000_0000 l, h0000_0000 l, h007F_FE00 l, h01FF_FF80 l, h03FF_FFC0 l, h0383_81C0 l, h0707_00E0 l, h0707_00E0 l,
h0707_00E0 l, h0707_00E0 l, h0707_00E0 l, h0383_81C0 l, h03E3_FFC0 l, h01E1_FF80 l, h0060_7E00 l, h0000_0000 l,
\ char"7"
h0000_0000 l, h0000_0000 l, h0700_0000 l, h0700_0000 l, h0700_0000 l, h0700_0000 l, h0700_00E0 l, h0700_07E0 l,
h0700_3FE0 l, h0701_FF00 l, h070F_F800 l, h077F_C000 l, h07FE_0000 l, h07F0_0000 l, h0780_0000 l, h0000_0000 l,
\ char"8"
h0000_0000 l, h0000_0000 l, h0078_3E00 l, h01FE_FF80 l, h03FF_FFC0 l, h0387_C1C0 l, h0703_80E0 l, h0703_80E0 l,
h0703_80E0 l, h0703_80E0 l, h0703_80E0 l, h0387_C1C0 l, h03FF_FFC0 l, h01FE_FF80 l, h0078_3E00 l, h0000_0000 l,
\ char"9"
h0000_0000 l, h0000_0000 l, h007E_0600 l, h01FF_8780 l, h03FF_C7C0 l, h0381_C1C0 l, h0700_E0E0 l, h0700_E0E0 l,
h0700_E0E0 l, h0700_E0E0 l, h0700_E0E0 l, h0381_C1C0 l, h03FF_FFC0 l, h01FF_FF80 l, h007F_FE00 l, h0000_0000 l,
\ char" " 
h0000_0000 l, h0000_0000 l, h0000_0000 l, h0000_0000 l, h0000_0000 l, h0000_0000 l, h0000_0000 l, h0000_0000 l,
h0000_0000 l, h0000_0000 l, h0000_0000 l, h0000_0000 l, h0000_0000 l, h0000_0000 l, h0000_0000 l, h0000_0000 l,

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
wvariable ESC_! -2 allot 2 c, 1 c, h1B c, h21 c,
\ Init command
wvariable ESC_@ -2 allot 2 c, 0 c, h1B c, h40 c,
wvariable result
variable tmp
\ serial for PropForth<-->ThermalPrinter
9 wconstant Rx
d10 wconstant Tx
d4800 constant baud/4    \ 19200/4

\ ----- switch ------
d11 wconstant sw1
d12 wconstant sw2
d800000 constant 10msec
sw1 >m sw2 >m or constant swMask

\ ----- rtc -----
\ Slave addres h51 for PCF2129 
hA2 wconstant rtc

\ ==================================================================
\ Variables
\ ================================================================== 
\ ----- LCD -----
wvariable ADC
wvariable lcdActive

\ ----- pulseMonitor -----
wvariable stopPulse
wvariable currentValue

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
mSDA      mask of sda:             4byte
m         index for Digit-display  2byte
font      address for font         2byte
Digit3    char-cod for Digit3      2byte
Digit2    char-cod for Digit2      2byte
Digit1    char-cod for Digit1      2byte
}
variable varNum -4 allot
mSDA l, 0 w, fontTable w, 0 w, 0 w, 0 w,

\ ----- ThermalPrinter ------
wvariable inchar
wvariable prnBuffer d46 allot \ Buffer for Thermalprinter[384bit=384dots]

\ ----- switch ------
variable DebounceTime
wvariable swState
wvariable debounce
wvariable senseSW

\ ---- Blood Circulation -----
variable diff
variable MIN

\ ---- Calculation of SDPGAI
wvariable TMP
wvariable overAddr
wvariable zeroP
variable a
variable b
variable c
variable d
variable e
wvariable manAge
wvariable womanAge
wvariable secondDeriva
