fl

{
Pressure Sensor LPS25H
Using i2c_utility_0.4_1.f
      
PropForth 5.5(DevKernel)

LPS25H module   Propeller
     Vdd   ------ 3V3
     SCL   ------ SCL
     SDA   ------ SDA
     SDO   ------ GND
     CS    ------ 3V3(I2C mode)
     GND   ------ GND


2016/02/07 13:19:14

}

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
\ Slave addres h5C (SDO:GND) 
hB8 wconstant LPS25H

\ register name
8 wconstant REP_P_XL
9 wconstant REP_P_L
hA wconstant REP_P_H
hF wconstant WHO_AM_I
h10 wconstant RES_CONF
h20 wconstant CTRL_REG1
h21 wconstant CTRL_REG2
h22 wconstant CTRL_REG3
h23 wconstant CTRL_REG4
h24 wconstant INT_CFG
h25 wconstant INT_SOURCE
h27 wconstant STATUS_REG
h28 wconstant PRESS_POUT_XL
h29 wconstant PRESS_POUT_L
h2A wconstant PRESS_POUT_H
h2B wconstant TEMP_OUT_L
h2C wconstant TEMP_OUT_H
h2E wconstant FIFO_CTRL
h2F wconstant FIFO_STATUS
h30 wconstant THS_P_L
h31 wconstant THS_P_H
h39 wconstant RPDS_L
h3A wconstant RPDS_H

\ bit data
0 wconstant P8
1 wconstant P32
2 wconstant P128
3 wconstant P512
0 wconstant T8
4 wconstant T16
8 wconstant T32
hC wconstant T64
4 wconstant reset
h80 wconstant pwr_act
h40 wconstant FIFO_EN
0 wconstant 1shot
h10 wconstant 1Hz
h20 wconstant 7Hz
h30 wconstant 12.5Hz
h40 wconstant 25Hz
1 wconstant start_1shot
\ Mode
0 wconstant Bypass
hC0 wconstant FIFO_mean_Mode
\ WTM
1 wconstant Sample2
3 wconstant Sample4
7 wconstant Sample8
hF wconstant Sample16
h1F wconstant Sample32

\ Register string-data in dictionary
: s, parsenw dup C@ 1+ bounds dup rot2 do C@++ c, loop drop ;

\ Define string data
wvariable reg_name -2 allot 
s, REF_P_XL s, REF_P_L s, REF_P_H 
s, WHO_AM_I s, RES_CONF 
s, CTRL_REG1 s, CTRL_REG2 s, CTRL_REG3 s, CTRL_REG4 s, INT_CFG s, INT_SOURCE 
s, STATUS_REG s, PRESS_OUTXL s, PRESS_OUT_L s, PRESS_OUT_H s, TEMP_OUT_L s, TEMP_OUT_H 
s, FIFO_CTRL s, FIFO_STATUS s, THS_P_L s, THS_P_H 
s, RPDS_L s, RPDS_H

\ =========================================================================== 
\ Variables 
\ =========================================================================== 

\ =========================================================================== 
\ Main
\ =========================================================================== 
\ Print out string inside string table
\ ( n1 n2 -- ) n1:index(0,1,2,..,n) n2:stringarray's address
: dispStr
swap dup 0 <>
if
     0 do dup C@ + 1+ loop
else
     drop
then
\ Print string
.cstr
;

\ Read sereis data from series register in LPS25H
\ ( n1 n2 n3 -- n4 . . nn t/f )  n1:number  n2:register  n3:slave_address  n4..nn:series data  t/f:true if there was an error
: LPS25H_i2c_rd_multi
\ Start I2C 
_eestart
\ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi)  
tuck _eewrite                 \ ( n1 n3 n2 t/f )
\ Write register (Set bit7 to 1 to read series register)
swap h80 or _eewrite or       \ ( n1 n3 t/f )   
swap                          \ ( n1 t/f n3 )
\ Repeated Start read_process
Sr
\ Write slave address[rd], then receive Acknowledge-bit(ACK:Lo  NACK:Hi)
1 or 
_eewrite or                   \ ( n1 t/f )
\ Read (n1-1)bytes
>r                            \ Push flag  ( n1 )
dup 1 > 
if 
     1 - 0 do 
          0 _eeread           \ ( n4..nn-1 )
     loop
else
     drop
then
\ Read 1byte ,then set sda to Hi(NACK:master->slave)
-1 _eeread                    \ ( n4..nn )
r>                            \ Pop flag   ( n4..nn t/f )
\ Stop I2C
_eestop      
err?                          \ ( n4..nn )         
;

\ Check communiation
\ If reply is "BD", chip is normal.
\ ( -- )
: chkID 
WHO_AM_I LPS25H i2c_rd hBD =
if ." Correct  deviceID:hBD"
else ." Incorrect"
then
cr
;

\ TAB
\ ( -- )
: tab 9 emit ;
: 2tab tab tab ;

\ Read 1 byte
\ ( n1 -- n2 ) n1:register  n2:value
: rdByte LPS25H i2c_rd ;

\ Write 1 byte
\ ( n1 n2 -- )  n1:value n2:register
: wrByte LPS25H i2c_wr ;

\ Set 1bit
\ ( n1 n2 -- ) n1:bit data  n2:register
: setbit
2dup                     \ ( n1 n2 n1 n2 ) 
rdByte or                \ ( n1 n2 value )
swap                     \ ( n1 value n2 )
LPS25H i2c_wr            \ ( n1 )
drop
;

\ Clear 1bit
\ ( n1 n2 -- ) n1:bit data  n2:register
: clrbit
dup                      \ ( n1 n2 n2 ) 
rdByte                   \ ( n1 n2 value )
rot                      \ ( n2 value n1 )
invert and               \ ( n2 value )
swap LPS25H i2c_wr         
;

\ Software Reset
\ ( -- )
: softReset reset CTRL_REG2 setbit ;
 
\ Display byte
\ ( -- )
: dispByte rdByte . cr ;

\ Display all registers
\ ( -- )
: disp_reg
." Register:hex" 2tab ." Value[hex]" cr
hex 
REP_P_H 1+ REP_P_XL 
do i 8 - reg_name dispStr ." :" i . 2tab i dispByte loop
RES_CONF 1+ WHO_AM_I 
do i d12 - reg_name dispStr ." :" i . 2tab i dispByte loop
INT_SOURCE 1+ CTRL_REG1 
do i d27 - reg_name dispStr ." :" i . 2tab i dispByte loop
TEMP_OUT_H 1+ STATUS_REG 
do i d28 - reg_name dispStr ." :" i . 2tab i dispByte loop
THS_P_H 1+ FIFO_CTRL 
do i d29 - reg_name dispStr ." :" i . 2tab i dispByte loop
RPDS_H 1+ RPDS_L 
do i d36 - reg_name dispStr ." :" i . 2tab i dispByte loop
decimal cr
;

\ Turn on device
\ ( -- )
: active pwr_act CTRL_REG1 setbit ;

\ Set output rate
\ ( n1 -- )  n1:output rate for Pressure and Temperature 
: setRate
\ Read 1byte and clear bit[6-4]
CTRL_REG1 rdByte h8F and
\ Write new value 
or CTRL_REG1 wrByte
;

\ Set internal average for Pressure and Temperature
\ ( n1 n2 -- )  n1:pressure  n2:temperature
: setRes
or                            \ Or press and temp
RES_CONF rdByte hF0 and       \ Clear bit[3..0] 
or RES_CONF wrByte
;

\ Start oneshot measurement
\ ( -- )
: start_OS start_1shot CTRL_REG2 setbit ;

\ Set mode
\ ( n1 -- ) n1:mode
: setMode
FIFO_CTRL rdByte h1F and 
or FIFO_CTRL wrByte
;

\ Set WTM_POINT
\ ( n1 -- ) n1:WTM_POINT
: setWTM
FIFO_CTRL rdByte hE0 and 
or FIFO_CTRL wrByte
;

\ Display Temperature
\ ( n1 n2 -- )  n1:L-byte n1:H-byte
: dispTemp
     8 lshift or dup h8000 and      
     if
          hFFFF0000 or   \ minus value 
     then
     d48 / d425 +
     dup h80000000 and
     if 
          h2D emit       \ print "-"
          invert 1+
     then  
     d10 u/mod . h2E emit . ." degree"    
;

\ Display Pressure
\ ( n1 n2 n3 -- )
: dispPress
d16 lshift swap 8 lshift or or d100 * d4096 / 
d100 u/mod . h2E emit . ." hPa" 
;

\ OneShot Mode
\ Pressure internal average:512   
\ Temperatire internal average:64
\ ( -- )
: measure_1shot
T64 P512 setRes
1shot setRate
FIFO_EN CTRL_REG2 clrbit
active
clkfreq cnt COG@ +
begin
     \ Start one-shot measurement
     start_OS
     \ Wait until measurement finish
     begin CTRL_REG2 rdByte 1 and 0= until
     5 PRESS_POUT_XL LPS25H LPS25H_i2c_rd_multi
     \ Temperature              
     dispTemp tab 
     
     \ Pressure
     dispPress     
     cr
     clkfreq waitcnt
     fkey? swap drop
until   
drop  
;

\ FIFO mean Mode
\ Pressure internal average:32      
\ Temperatire internal average:16
\ ( -- )
: measure_FIFO
T16 P32 setRes
FIFO_mean_Mode setMode
Sample2 setWTM
FIFO_EN CTRL_REG2 setbit
1Hz setRate
active
clkfreq cnt COG@ +
begin
     \ Get Temperature (2byte)
     2 TEMP_OUT_L LPS25H LPS25H_i2c_rd_multi
     dispTemp tab 
     
     \ Get Pressure(3byte)
     3 PRESS_POUT_XL LPS25H LPS25H_i2c_rd_multi
     dispPress 
     cr
     clkfreq waitcnt
     fkey? swap drop
until     
;

