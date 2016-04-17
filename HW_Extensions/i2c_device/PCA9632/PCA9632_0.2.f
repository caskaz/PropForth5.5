fl

{
PropForth 5.5(DevKernel)

LED driver (PCA9632)
Using i2c_utility_0.4.1.f 
2016/04/17 22:07:18

PCA9632DP1(8pin)     Propeller
     Vdd  ------------ 3.3V
     SDA  ------------ SDA
     SCL  ------------ SCL
     GND  ------------ GND
     
     LED0 -- -LED+ -- 220ohm -- 3.3V
     LED1 -- -LED+ -- 220ohm -- 3.3V
     LED2 -- -LED+ -- 220ohm -- 3.3V
     LED3 -- -LED+ -- 220ohm -- 3.3V
}

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
\ Slave addres h62 for PCA9632 
hC4 wconstant PCA9632
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
6 wconstant GRPPWM
7 wconstant GRPFREQ
8 wconstant LEDOUT0
9 wconstant SUBADR1
hA wconstant SUBADR2
hB wconstant SUBADR3
hC wconstant ALLCALLADR

\ Auto Increment Code
0 wconstant no_inc             \ No Auto Incremenr
h80 wconstant all_inc          \ (register:0 - hC)
hA0 wconstant bright_inc       \ (register:2 - 5)
hC0 wconstant group_inc        \ (register:6 - 7)
hE0 wconstant brt_grp_inc      \ (register:2 - 7)
 
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
s, PWM0 s, PWM1 s, PWM2 s, PWM3 
s, GRPPWM s, GRPFREQ
s, LEDOUT0 
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
d13 0 do
     \ Set No-Auto-Increment to control-register
     mode1 no_inc or i + PCA9632 i2c_rd 
     i string dispStr ." :" 
     i 7 < if 2tab else tab then
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
d13 mode1 all_inc or PCA9632 i2c_rd_multi 
d13 0 do
     d12 i - string dispStr ." :" 
     i 6 < if tab else 2tab then
     ." h" . cr   
loop
decimal
cr
;

\ Drive 4 LED elemets from pwm 0% to pwm 99.6%
\ ( -- )
: demo1
\ Set No Auto Incremenr and Normal operation[b4] and ALLCALL[b0]
1 mode1 PCA9632 i2c_wr 
\ Set LED3,2,1,0:Full-ON[LDRx=01] and LED7,6,5,4:PWM[LDRx=10]
hA5 LEDOUT0 all_inc or PCA9632 i2c_wr  
5 0 do
     d256 0 do
          i i i i 
          \ Set Auto-Increment for individual brightness to control-register 
          4 PWM0 bright_inc or PCA9632 i2c_wr_multi
          d10 delms
     loop                    
loop
\ Set LED3,2,1,0:PWM[LDRx=10] and LED7,6,5,4:Full-ON[LDRx=01]
h5A LEDOUT0 all_inc or PCA9632 i2c_wr  
5 0 do
     d256 0 do
          i i i i 
          \ Set Auto-Increment for individual brightness to control-register 
          4 PWM0 bright_inc or PCA9632 i2c_wr_multi
          d10 delms
     loop                    
loop
             
SoftReset                        
;

\ Drive 4 LED elemets by GRPPWM & GRPFREQ
\ ( -- )
: demo2
\ Set No Auto Incremenr and Normal operation[b4] and ALLCALL[b0]
1 mode1 PCA9632 i2c_wr
\ Set DMBLINK 
h20 mode2 PCA9632 i2c_wr
\ Set LED3,2,1,0:PWM&GRPPWM        
hFF LEDOUT0 all_inc or PCA9632 i2c_wr
\ Set GRPPWM to 128  
d128 GRPPWM PCA9632 i2c_wr

\ Set Auto-Increment for individual brightness to control-register 
d255 d255 d255 d255 
4 PWM0 bright_inc or PCA9632 i2c_wr_multi
d5000 delms
\ Set blink to 0.21sec
4 GRPFREQ PCA9632 i2c_wr
d5000 delms
\ Set blink to 2sec
d47 GRPFREQ PCA9632 i2c_wr
d1000 delms
\ Set GRPFREQ to 5
d119 GRPFREQ PCA9632 i2c_wr
\ Set blink to 10sec
d239 GRPFREQ PCA9632 i2c_wr
d50000 delms

SoftReset                        
;
