fl

{
PropForth 5.5(DevKernel)

SingFace
Using MCP3204 and 8x8Matrix(HT16K33-24)
2016/04/30 10:42:48
         
}

\ ==================================================================
\ Constants
\ ================================================================== 
\ face pattern
wvariable Face -2 allot
h00 c, hF1 c, h90 c, h96 c, h90 c, h90 c, hF1 c, h06 c, 
h00 c, h01 c, hF0 c, h96 c, h90 c, hF0 c, h01 c, h06 c,
h00 c, h01 c, h00 c, h66 c, h60 c, h00 c, h01 c, h06 c,
h00 c, h01 c, h60 c, h66 c, h60 c, h60 c, h01 c, h06 c,
h00 c, h01 c, h20 c, h26 c, h20 c, h20 c, h01 c, h06 c,
\ audio level
wvariable level -2 allot
h80 c, hC0 c, hE0 c, hF0 c, hF8 c, hFC c, hFE c, hFF c,

\ --- HT16K33 ---
\ Slave addres h70 for HT16K33-24 
hE0 wconstant HT16K33
\ command
0 wconstant addrPtr
h20 wconstant sysSetup
h80 wconstant Blink
hE0 wconstant Brightness
\ bit data
1 wconstant oscOn

\ --- MCP3204 ---
d2021 wconstant noSound       \ A/D value when mic removed
noSound d300 + wconstant upperSound
noSound d300 - wconstant lowerSound
8 wconstant _cs         
9 wconstant _do               \ connect to MCP3204's Din         
d10 wconstant _di             \ connect to MCP3204's Dout
d11 wconstant _clk          
1 _di lshift constant _dim

\ ==================================================================
\ Variables
\ ================================================================== 
\ --- HT16K33 ---
\ Buffer for 8x8Matrix
variable 8x8Matrix 4 allot

\ ==================================================================
\ i2c-module(HT16K33)
\ ================================================================== 
: err_msg ." I2C error" ;
\ If error, print message
\ ( n1 -- )   n1:t/f
: err? if err_msg cr then ;

\ Start i2c-commnication 
\ This also can use SMBus device.
\ ( -- )
lockdict create _eestart forthentry
$C_a_lxasm w, h122  h113  1- tuck - h9 lshift or here W@ alignl h10 lshift or l,
z1[ixnW l, z1[ixnX l, z2WyP[U l, z20iPak l, z3ryPW0 l, z1bixnW l, z2WyP[V l, z20iPak l,
z3ryPW0 l, z1bixnX l, z1SV01X l, zl0 l, zCW l, zW0000 l, zG0000 l,
freedict

\ Re-defined RepeatedStart
\ ( -- )
: Sr _eestart ;

\ Stop i2c-commnication 
\ ( -- )
: _eestop
_scli     \ Release scl 
_sdai     \ Release sda
;

\ _eewrite ( c1 -- t/f ) write c1 to the eeprom, true if there was an error
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

\ Write command to HT16K33
\ ( n1 n2 -- )  n1:command n2:slave_address  
: wrCom1
\ Start I2C 
_eestart
\ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi) 
_eewrite                      \ ( n1 t/f )
\ Write command
swap _eewrite or              \ ( t/f )
\ Stop I2C
_eestop                       
err?                          \ ( -- )
;

\ Write command and data to HT16K33
\ ( n1 n2 n3 -- )  n1:data n2:command n3:slave_address  
: wrCom2
\ Start I2C 
_eestart
\ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi) 
_eewrite                      \ ( n1 n2 t/f )
\ Write command
swap _eewrite or              \ ( n1 t/f )
\ Write data
swap _eewrite or              \ ( t/f ) 
\ Stop I2C
_eestop                       
err?                          \ ( -- )
;

\ Initialize HT16K33
\ ( -- )
: init_HT16K33
sysSetup oscOn or HT16K33 wrCom1   \ Set systemOscillator to on
Blink HT16K33 wrCom1               \ Set Blink to off
Brightness 1 or HT16K33 wrCom1     \ Set Brightness to 1
;

\ Display Matrix-buffer to 8x8Matrix
\ ( -- )
: scanMatrix
init_HT16K33             \ Initialize HT16K33
h81 HT16K33 wrCom1       \ Display on
\ Send data inside 8x8Matrix to HT16K33
begin 
     8 0 do 
          8x8Matrix i + C@ addrPtr i 2* + HT16K33 wrCom2 
     loop 
0 until 
;

\ Clear 8x8Matrix buffer
\ ( -- )
: clrMatrix 0 8x8Matrix L! 0 8x8Matrix 4+ L! ;

\ ==================================================================
\ MCP3204
\ ================================================================== 
: _cs_l _cs pinlo ;
: _cs_h _cs pinhi ;
: _do_l _do pinlo ;
: _do_h _do pinhi ;
: _clk_l _clk pinlo ;
: _clk_h _clk pinhi ;

\ Convert analog[0-3.3V] to digital[0-4095] 
\ single-end input for MCP3204
\ ( n1 -- n2 )   n1:channel [0 - 3]  n2:data
: get_a/d    
_cs_l  
\ Output control-bits       
h18 or                        \ Add start-bit and single-bit
h10
5 0 do 
     2dup                     \ ( n1+h18 h10 n1+h18 h10 )      
     and 0> 
     if _do_h then
     _clk_h _clk_l 
     1 rshift 
     _do_l           
loop
2drop                                  
_clk_h _clk_l                 \ dummy clock

\ Read conversion-data   
0                             \ initial value
d13 0 do 
     1 lshift
     _clk_h  _clk_l
     ina COG@ _dim and 0> 
     if 1+ then       
loop     
1 rshift
_cs_h
;

\ Check audio level(To TeraTerm)
\ ---Adjust audio level by volume[500k]
\ ( -- )
: AudioCheck
_cs pinout _do pinout _clk pinout 
begin
     0 get_a/d  
     d100 * d4095 / dup
     0 do h2A emit loop 
     d100 swap - 0 do h2E emit loop cr
     fkey? swap drop
until
;

\ ==================================================================
\ Main
\ ================================================================== 
\ Check audio level( to 8x8Matrix) ---
\ ---Adjust audio level by volume[500k]
\ ( -- )
: AudioLevel
_cs pinout _do pinout _clk pinout 
clrMatrix
c" scanMatrix" 0 cogx
begin
     0 get_a/d noSound - dup
     \ Check if negative
     if abs then
     d256 /                   \ 0,1,2,3,4,5,6,7
     level + C@               \ Get level-data
     8x8Matrix C!
     d100 delms
     7 0 do
          8x8Matrix 6 i - +   \ Get address of level data 
          dup C@ swap 1+ C!   \ Move data from 8x8Matrix+[n] to 8x8Matrix+[n+1]
     loop
     fkey? swap drop
until
0 cogreset               
;

\ Display each face to 8x8Matrix
\ ( -- )
: face
clrMatrix
c" scanMatrix" 0 cogx
Face
5 0 do
     8 0 do
          dup
          i + C@ 8x8Matrix i + C!
     loop
     d2000 delms
8 +
loop
drop
0 cogreset
;

\ Display face to 8x8Matrix
\ ( -- )
: SingFace
_cs pinout _do pinout _clk pinout 
clrMatrix
c" scanMatrix" 0 cogx
begin
     0 get_a/d              
     dup
     upperSound >
     swap lowerSound <
     or
     if
          rnd 5 u/mod drop 8 * 
     else
          d16 
     then
     Face +
     8 0 do
          dup
          i + C@ 8x8Matrix i + C!
     loop
     drop
     d50 delms
     fkey? swap drop
until
0 cogreset               
;
