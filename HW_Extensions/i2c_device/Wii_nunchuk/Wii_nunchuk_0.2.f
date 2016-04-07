fl

{
PropForth 5.5(DevKernel)

Wii nunchuk driver 
2016/04/06 23:17:00

     Wii nunchuk   Propeller
     clk            P28   0x1c
     dat            P29   0x1d
Diagram below is showing the pinout looking into the connector (which plugs into the Wii Remote)
 _______ 
| 1 2 3 |
|       |
| 6 5 4 |
|_-----_|          Peopeller

1 - SDA  --------- P29
2 - 
3 - VCC  --------- 3.3V
4 - SCL  --------- P28
5 - 
6 - GND  --------- GND

Cutted connecter.   2012/8/8
VCC(Red)    --------- 3.3V
GND (White) --------- GND
SDA(Green)  --------- P29
SCL(Yellow) --------- P28

==== CAUTION ===========================================================================
This doesn't use i2c_utility_0.4.1.f, because _eestart inside it cause I2C-error.
Device inside Wii-nunchuk cannot operate _eestart(assembler-word).
So, it is Forth-word on this code.    
========================================================================================
}

\ =========================================================================== 
\ I2C 
\ =========================================================================== 
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
_scli     \ Release scl 
_sdai     \ Release sda
;

\ std_eewrite ( c1 -- t/f ) write c1 to the eeprom, true if there was an error
\ Received acknowledge from i2c-device during scl is high
\ scl/sda use pull-up resistor at hi
\ clock:100kHz
lockdict create std_eewrite forthentry
$C_a_lxasm w, h12C  h113  1- tuck - h9 lshift or here W@ alignl h10 lshift or l,
z2WyPW8 l, z1YVPQ0 l, z1rixnd l, z1Sy\C] l, z1[ixne l, z1Sy\C] l, z1bixne l, zfyPO1 l,
z3[yP[K l, z1[ixnd l, z1Sy\C] l, z1[ixne l, z1Sy\C] l, z1YF\Nl l, z1viPR6 l, z1bixne l,
z1Sy\C] l, z1bixnd l, z1SV01X l, z2WyPh3 l, z20iPik l, z3ryPb0 l, z1SV000 l, zW0000 l,
zG0000 l,
freedict

\ std_eeread ( t/f -- c1 ) flag should be true is this is the last read
\ scl/sda use pull-up resistor at hi
\ clock:100kHz
lockdict create std_eeread forthentry
$C_a_lxasm w, h12D  h113  1- tuck - h9 lshift or here W@ alignl h10 lshift or l,
z2WiPZB l, z2WyPO0 l, z1[ixne l, z2WyPj8 l, z1Sy\Ka l, z1[ixnf l, z1Sy\Ka l, z1XF\Vl l,
znyPO1 l, z1bixnf l, z3[yPnN l, z26VPW0 l, z1rixne l, z1Sy\Ka l, z1[ixnf l, z1Sy\Ka l,
z1bixnf l, z1bixne l, z1Sy\Ka l, z1SV01X l, z2WyPh3 l, z20iPik l, z3ryPb0 l, z1SV000 l,
zW0000 l, zG0000 l,
freedict

\ Display connected i2c-device's slave-address
\ This also can use SMBus device.
\ ( -- )
: std_i2c_detect
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
          dup i + 1 lshift std_eewrite 0=                      
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

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
\ Slave addres h52 for Wii-nunchaku
hA4 wconstant nunchuk

d127 wconstant cal_joy_x
d135 wconstant cal_joy_y
d200 wconstant cal_z

d40000000 constant 500msec

\ =========================================================================== 
\ Variables 
\ =========================================================================== 
variable sx
variable sy
wvariable ax
wvariable ay
variable az
wvariable cb
wvariable z

\ =========================================================================== 
\ Main 
\ =========================================================================== 
\ Write data to Wii-nunchuk
\ ( n1 n2 n3 -- t/f )   n1:data n2:register n3:slave address   t/f: true if there are error
: wr_nunchuk
_eestart 
std_eewrite swap std_eewrite or         \ ( n1 t/f )
swap std_eewrite or                     \ ( t/f )
_eestop
;

\ Initialize Wii-nunchuku
\ ( -- t/f )     t/f: true if there are error
: init_nunchuk 
h55 hF0 nunchuk wr_nunchuk 
0 hFB nunchuk wr_nunchuk or 
;

\ Read data for Wii-nunchuk 
\ ( -- n1-n6 t/f )    n1-n6:data(6bytes) t/f: true if there are error
: readNunchuk 
_eestart nunchuk std_eewrite 0 std_eewrite _eestop or       \ ( t/f )      
1 delms                                                     \ Wait
_eestart nunchuk 1 or std_eewrite or                        \ ( t/f )
>r                                                          \ Push
\ Read 6bytes 
5 0 do 0 std_eeread loop -1 std_eeread _eestop              \ Read 6bytes      
r>                                                          \ Pop
; 

\ Calculate data[joy_x,joy_y,ax,ay,az,c-button,z-button]
\ ( n1..n6 -- )  n1..n6:6bytes
: get_value
dup 1 and z W!                \ z-button
dup 2 and cb W!               \ c-button
2 rshift dup 3 and ax W!
2 rshift dup 3 and ay W!
2 rshift 3 and az L!
2 lshift az L@ + cal_z - az L!
2 lshift ay W+!
2 lshift ax W+!

cal_joy_y - sy L!
cal_joy_x - sx L!
;

\ Display [joy_x,joy_y,ax,ay,az,c-button,z-button]
\ ( -- )
: test_Nunchuk 
init_nunchuk err?               
cnt COG@ 500msec +
begin     
     readNunchuk err?          
     get_value
     ." SX:" sx L@ . ." SY:" sy L@ .  ." AX:" ax W@ . ." AY:" ay W@ . ." AZ:" az L@ . ." c:" cb W@ . ." z:" z W@ . cr                     
     500msec waitcnt        
fkey? swap drop until     
drop
;

: x_wave
init_nunchuk err?               
cnt COG@ 500msec +
begin     
     readNunchuk err?          
     get_value
     ax W@ d10 u/ 1- spaces h2A emit cr 
     500msec waitcnt        
fkey? swap drop until     
drop
;

: y_wave
init_nunchuk err?               
cnt COG@ 500msec +
begin     
     readNunchuk err?          
     get_value
     ay W@ d10 u/ 1- spaces h2A emit cr 
     500msec waitcnt        
fkey? swap drop until     
drop
;

: z_wave
init_nunchuk err?               
cnt COG@ 500msec +
begin     
     readNunchuk err?          
     get_value
     az W@ d10 u/ 1- spaces h2A emit cr 
     500msec waitcnt        
fkey? swap drop until     
drop
;

