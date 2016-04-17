fl

{
PropForth 5.5(DevKernel)

LED driver (PCA9624)
Using i2c_utility_0.4.1.f 
2016/04/17 15:27:57

  PCA9624     Propeller
     A0  ---  GND
     A1  ---  GND
     A2  ---  GND
     A3  ---  GND
     A4  ---  3.3V
     A5  ---  GND
     A6  ---  GND
     OE  ---  GND
     
     LED0 -- -LED+ -- 220ohm -- 3.3V
     LED1 -- -LED+ -- 220ohm -- 3.3V
     LED2 -- -LED+ -- 220ohm -- 3.3V
     LED3 -- -LED+ -- 220ohm -- 3.3V
     LED4 -- -LED+ -- 220ohm -- 3.3V
     LED5 -- -LED+ -- 220ohm -- 3.3V
     LED6 -- -LED+ -- 220ohm -- 3.3V
     LED7 -- -LED+ -- 220ohm -- 3.3V
}

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
\ Slave addres h10 for PCA9624 
h20 wconstant PCA9624
\ All LED Call Address h70
hE0 wconstant PCA9624_call
\ Software Reset call
6 wconstant SWRST

\ register
0 wconstant mode1
1 wconstant mode2
2 wconstant PWM0
3 wconstant PWM1
4 wconstant PWM2
5 wconstant PWM3
6 wconstant PWM4
7 wconstant PWM5
8 wconstant PWM6
9 wconstant PWM7
hA wconstant GRPPWM
hB wconstant GRPFREQ
hC wconstant LEDOUT0
hD wconstant LEDOUT1
hE wconstant SUBADR1
hF wconstant SUBADR2
h10 wconstant SUBADR3
h11 wconstant ALLCALLADR

\ Auto Increment Code inside Control register [control-register= Increment Code + register number]
0 wconstant no_inc             \ No Auto Incremenr
h80 wconstant all_inc          \ (register:0 - h11)
hA0 wconstant bright_inc       \ (register:2 - h11)
hC0 wconstant group_inc        \ (register:hA - hB)
hE0 wconstant brt_grp_inc      \ (register:2 - hB)
 
\ =========================================================================== 
\ Main 
\ =========================================================================== 

\ Software Reset
\ After send hA5 and h5A following SWRST, PCA9624 is resetting.
\ ( -- )
: SoftReset
\ Start I2C 
_eestart
\ Write SWRST, then receive Acknowledge-bit(ACK:Lo  NACK:Hi) 
SWRST _eewrite                      
hA5 _eewrite or
h5A _eewrite or
\ Stop I2C
_eestop
err? 
;

\ allocate string
\ ( -- )
: s, parsenw dup C@ 1+ bounds dup rot2 do C@++ c, loop drop ;

wvariable string -2 allot 
s, MODE1 s, MODE2 
s, PWM0 s, PWM1 s, PWM2 s, PWM3 s, PWM4 s, PWM5 s, PWM6 s, PWM7 
s, GRPPWM s, GRPFREQ
s, LEDOUT0 s, LEDOUT1
s, SUBADR1 s, SUBADR2 s, SUBADR3
s, ALLCALLADR

\ Display allocated string above
\ ( n1 n2 -- )  n1:string index  n2:string's top address
: dispStr 
swap dup 0 <> 
if  
     0 do
          dup C@ + 1+
     loop     
else
     drop     
then 
.cstr 
;

\ TAB
\ ( -- )
: tab 9 emit ;
: 2tab tab tab ;

\ Display all registers from mode1 to ALLCALLADR
\ ( -- )
: rd_allreg
hex
d18 0 do
     \ Set No-Auto-Increment to control-register
     mode1 no_inc or i + PCA9624 i2c_rd 
     i string dispStr ." :" 
     i d11 < if 2tab else tab then
     ." h" . cr   
loop
decimal
cr
;

\ Display all registers from ALLCALLADR to mode1
\ ( -- )
: rd_allreg_rev
hex
\ Set Auto-Increment to control-register
d18 mode1 all_inc or PCA9624 i2c_rd_multi 
d18 0 do
     d17 i - string dispStr ." :" 
     i 7 < if tab else 2tab then
     ." h" . cr   
loop
decimal
cr
;

\ Drive 8 LED elemets from pwm 0% to pwm 99.6%
\ ( -- )
: demo1
\ Set No Auto Incremenr and Normal operation[b4] and ALLCALL[b0]
1 mode1 PCA9624 i2c_wr 
\ Set LED3,2,1,0:Full-ON[LDRx=01] and LED7,6,5,4:PWM[LDRx=10]
hAA h55 2 LEDOUT0 all_inc or PCA9624 i2c_wr_multi  
5 0 do
     d256 0 do
          i i i i i i i i
          \ Set Auto-Increment for individual brightness to control-register 
          8 PWM0 bright_inc or PCA9624 i2c_wr_multi
          d10 delms
     loop                    
loop
\ Set LED3,2,1,0:PWM[LDRx=10] and LED7,6,5,4:Full-ON[LDRx=01]
h55 hAA 2 LEDOUT0 all_inc or PCA9624 i2c_wr_multi  
5 0 do
     d256 0 do
          i i i i i i i i
          \ Set Auto-Increment for individual brightness to control-register 
          8 PWM0 bright_inc or PCA9624 i2c_wr_multi
          d10 delms
     loop                    
loop
             
SoftReset                        
;

\ Drive 8 LED elemets by GRPPWM & GRPFREQ
\ ( -- )
: demo2
\ Set No Auto Incremenr and Normal operation[b4] and ALLCALL[b0]
1 mode1 PCA9624 i2c_wr
\ Set DMBLINK 
h20 mode2 PCA9624 i2c_wr
\ Set LED7,6,5,4,3,2,1,0:PWM&GRPPWM        
hFF hFF 2 LEDOUT0 all_inc or PCA9624 i2c_wr_multi
\ Set GRPPWM to 128  
d128 GRPPWM PCA9624 i2c_wr

\ Set Auto-Increment for individual brightness to control-register 
d255 d255 d255 d255 d255 d255 d255 d255
8 PWM0 bright_inc or PCA9624 i2c_wr_multi
d5000 delms
\ Set blink to 2sec
d47 GRPFREQ PCA9624 i2c_wr
d10000 delms
\ Set blink to 5sec
d119 GRPFREQ PCA9624 i2c_wr
d15000 delms
\ Set blink to 10sec
d239 GRPFREQ PCA9624 i2c_wr
d50000 delms

SoftReset                        
;
