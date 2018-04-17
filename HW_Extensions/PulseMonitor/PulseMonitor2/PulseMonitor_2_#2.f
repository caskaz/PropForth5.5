fl

{
PropForth 5.5(DevKernel)
PulseMonitor

RTC(PCF2129AT)
2018/03/16 19:56:40

}

\ =========================================================================== 
\ I2C 
\ =========================================================================== 
\ Slave addres h51 for PCF2129 
hA2 wconstant PCF2129

\ Modified _eewrite ( c1 -- t/f ) write c1 to the eeprom, true if there was an error
\ Received acknowledge from i2c-device during scl is high
\ scl/sda use pull-up resistor at hi
\ clock:400kHz
lockdict create _eewrite forthentry
$C_a_lxasm w, h12C  h113  1- tuck - h9 lshift or here W@ alignl h10 lshift or l,
z2WyPW8 l, z1YVPQ0 l, z1rixnd l, z1Sy\C] l, z1[ixne l, z1Sy\C] l, z1bixne l, zfyPO1 l,
z3[yP[K l, z1[ixnd l, z1Sy\C] l, z1[ixne l, z1Sy\C] l, z1YF\Nl l, z1viPR6 l, z1bixne l,
z1Sy\C] l, z1bixnd l, z1SV01X l, z2WyPc7 l, z20iPik l, z3ryPb0 l, z1SV000 l, zW0000 l,
zG0000 l,
freedict

\ _eeread ( t/f -- c1 ) flag should be true is this is the last read
\ scl/sda use pull-up resistor at hi
\ clock:400kHz
lockdict create _eeread forthentry
$C_a_lxasm w, h12D  h113  1- tuck - h9 lshift or here W@ alignl h10 lshift or l,
z2WiPZB l, z2WyPO0 l, z1[ixne l, z2WyPj8 l, z1Sy\Ka l, z1[ixnf l, z1Sy\Ka l, z1XF\Vl l,
znyPO1 l, z1bixnf l, z3[yPnN l, z26VPW0 l, z1rixne l, z1Sy\Ka l, z1[ixnf l, z1Sy\Ka l,
z1bixnf l, z1bixne l, z1Sy\Ka l, z1SV01X l, z2WyPc9 l, z20iPik l, z3ryPb0 l, z1SV000 l,
zW0000 l, zG0000 l,
freedict

: err_msg ." I2C error" ;
\ If error, print message
\ ( n1 -- )   n1:t/f
: err? if err_msg cr then ;

\ Start i2c-commnication 
\ ( -- )
: _eestart
_sdal _sdao              \ Set sda to lo 
_scll _sclo              \ Set scl to lo
;

\ Stop i2c-commnication 
\ ( -- )
: _eestop
_scli                    \ Release scl 
_sdai                    \ Release sda
;

\ Write data to register in i2c_device
\ ( n1 n2 n3 -- t/f )  n1:data  n2:register  n3:slave_address  t/f:true if there was an error
: i2c_wr
\ Start I2C 
_eestart
\ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi) 
_eewrite                      \ ( n1 n2 t/f )
\ Write register
swap _eewrite or              \ ( n1 t/f )
\ Write data   
swap _eewrite or              \ ( t/f )   
\ Stop I2C
_eestop 
;

: PCF2129_rd_multi
\ Start I2C 
_eestart
\ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi)  
PCF2129 _eewrite              \ ( n1 n2 t/f )
\ Write register
swap _eewrite or              \ ( n1 t/f )

_eestop _eestart
\ Write slave address[rd], then receive Acknowledge-bit(ACK:Lo  NACK:Hi)
PCF2129 1 or 
_eewrite or                   \ ( n1 t/f )
\ Read (n1-1)bytes
>r                            \ Push flag  ( n1 )
dup 1 > 
if 
     1 - 0 do 
          0 _eeread           \ ( n3..nn-1 )
     loop
else
     drop
then
\ Read 1byte ,then set sda to Hi(NACK:master->slave)
-1 _eeread                    \ ( n3..nn )
r>                            \ Pop flag   ( n3..nn t/f )
\ Stop I2C
_eestop 
err?                                        
;

\ Read data from register in i2c_device
\ ( n1 -- n2 )  n1:register  n2:data  
: PCF2129_rd
\ Start I2C 
_eestart
\ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi)  
PCF2129 _eewrite              \ ( n1 t/f )
\ Write register
swap _eewrite or              \ ( t/f )

_eestop _eestart
\ Write slave address[rd], then receive Acknowledge-bit(ACK:Lo  NACK:Hi)
PCF2129 1 or 
_eewrite or                   \ ( t/f )
\ Read 1byte ,then set sda to Hi(NACK:master->slave)
-1 _eeread                    \ ( t/f n3 )
\ Stop I2C
_eestop 
swap err?                                        
;

\ Display connected i2c-device's slave-address
\ ( -- )
: i2c_detect
hex
\ Print lower
."      0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F" cr
\ ( n1 n2 ) n1:reserve address 's count n2:i2c_device's count n3:i2c_address
0 0 0 
8 0 do
     \ Print 1-line
     dup .byte h3A emit space           
     d16 0 do
          \ Start I2C 
          _eestart
          \ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi)   
          dup i + 1 lshift _eewrite 0=                      
          if                                 \ there is ACK 
               dup i + dup .byte             \ Get slave-addres
               dup 7 > swap h78 < and        \ 0 to 7 and h78 to h7F
               if 
                    swap 1+ swap             \ Count up device (eliminate reserve number)
               else 
                    rot 1+ rot2
               then     
          else 
               ." --" 
          then 
          space 
          \ Stop I2C
          _eestop                                       
     loop
     cr
     \ next line
     d16 +                                                      
loop
drop
decimal
." i2c_device:" . cr  
0> if ." [0 - 7] and [h78 - h7F] are reserve-address" then cr
cr
;

\ =============================
\ rtc(PCF2129AT)
\ =============================
\ -----------------
\ BCD Conversion
\ -----------------
\ Convert bcd byte n1 to hex byte n2
\ bcd> ( n1 -- n2 ) n1:bcd  n2:hex
: bcd>
dup hF and
swap hF0 and
1 rshift dup
2 rshift + +
;

\ Convert hex byte n1 to bcd byte n2
\ >bcd ( n1 -- n2 ) n1:hex  n2:bcd
[ifndef >bcd
: >bcd
d10 u/mod 4 lshift +
;

\ Get current time 
\ Read/Convert current time from PCF2129
\ ( -- n1 n2 n3 n4 n5 n6 n7 )
\ n1 - second		(00 - 59)
\ n2 - minute		(00 - 59)
\ n3 - hour		24Hr:(00 - 23) 
\ n4 - date		(01 - 31)
\ n5 - weekday 	(Mon:0 Tue:1 Wed:2 Thur:3 Fri:4 Sat:5 San:6)
\ n6 - month		(01 - 12)
\ n7 - yesr		(2000 - 2099)   
: rd_time
d10 3 do i PCF2129_rd loop        
." Year: " bcd> . cr                
." Month:" bcd> . cr
." Weekday:" bcd> . cr
." Date:" bcd> . cr
bcd> . ." :" bcd> . ." :" h7F and . cr
;

\ Set current-time to PCF2129   (24Hour mode)
\ Set second to 0
\ ( n1 n2 n3 n4 n5 n6 -- ) 
\ n1 - yesr		(00 - 99)                                                               
\ n2 - month		(01 - 12)
\ n3 - weekday      (Mon:0 Tue:1 Wed:2 Thur:3 Fri:4 Sat:5 San:6)
\ n4 - day 		(01 - 31)
\ n5   hour		(00 - 23)
\ n6 - minute		(00 - 59)
\ Example d2015 6 3 4 12 0 set_time  2015/6/4 12:00:00 Tursday
: set_time
>bcd >r                       \ minute
>bcd >r                       \ hour
>bcd >r                       \ day
>r                            \ weekday
>bcd >r                       \ month
 >bcd                         \ year
r> r> r> r> r> 0
\ Write values to each register                           
d10 3 do i PCF2129 i2c_wr err? loop
;
