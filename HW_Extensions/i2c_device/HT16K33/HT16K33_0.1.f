fl

{
Ram Mapping  16X8 LED Controller Driver with keyscan(HT16K33-24)
Using i2c_utility_0.4_1.f
      
PropForth 5.5(DevKernel)

2016/02/09 10:26:07
}

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
\ Slave addres h70 for HT16K33-24 
hE0 wconstant HT16K33

\ command
0 wconstant addrPtr
h20 wconstant sysSetup
h80 wconstant Blink
hE0 wconstant Brightness

\ bit data
1 wconstant oscOn
1 wconstant dispOn
0 wconstant dispOff
2 wconstant 2Hz
4 wconstant 1Hz
6 wconstant 0.5Hz

\ =========================================================================== 
\ 8X8 Font Characters 
\ =========================================================================== 
wvariable Font -2 allot
h00 c, h00 c, h00 c, h00 c, h00 c, h00 c, h00 c, h00 c, 
h00 c, h06 c, h5F c, h5F c, h06 c, h00 c, h00 c, h00 c,
h00 c, h03 c, h07 c, h00 c, h07 c, h03 c, h00 c, h00 c,
h14 c, h7F c, h7F c, h14 c, h7F c, h7F c, h14 c, h00 c,
h24 c, h2E c, h2A c, h6B c, h6B c, h3A c, h12 c, h00 c,
h46 c, h66 c, h30 c, h18 c, h0C c, h66 c, h62 c, h00 c,
h30 c, h7A c, h4F c, h5D c, h37 c, h7A c, h48 c, h00 c,
h00 c, h04 c, h07 c, h03 c, h00 c, h00 c, h00 c, h00 c,
h00 c, h1C c, h3E c, h63 c, h41 c, h00 c, h00 c, h00 c,
h00 c, h41 c, h63 c, h3E c, h1C c, h00 c, h00 c, h00 c,
h08 c, h2A c, h3E c, h1C c, h1C c, h3E c, h2A c, h08 c,
h08 c, h08 c, h3E c, h3E c, h08 c, h08 c, h00 c, h00 c,
h00 c, h80 c, hE0 c, h60 c, h00 c, h00 c, h00 c, h00 c,
h08 c, h08 c, h08 c, h08 c, h08 c, h08 c, h00 c, h00 c,
h00 c, h00 c, h60 c, h60 c, h00 c, h00 c, h00 c, h00 c,
h60 c, h30 c, h18 c, h0C c, h06 c, h03 c, h01 c, h00 c,
h3E c, h7F c, h41 c, h49 c, h41 c, h7F c, h3E c, h00 c,
h40 c, h42 c, h7F c, h7F c, h40 c, h40 c, h00 c, h00 c,
h62 c, h73 c, h59 c, h49 c, h6F c, h66 c, h00 c, h00 c,
h22 c, h63 c, h49 c, h49 c, h7F c, h36 c, h00 c, h00 c,
h18 c, h1C c, h16 c, h53 c, h7F c, h7F c, h50 c, h00 c,
h27 c, h67 c, h45 c, h45 c, h7D c, h39 c, h00 c, h00 c,
h3C c, h7E c, h4B c, h49 c, h79 c, h30 c, h00 c, h00 c,
h03 c, h03 c, h71 c, h79 c, h0F c, h07 c, h00 c, h00 c,
h36 c, h7F c, h49 c, h49 c, h7F c, h36 c, h00 c, h00 c,
h06 c, h4F c, h49 c, h69 c, h3F c, h1E c, h00 c, h00 c,
h00 c, h00 c, h66 c, h66 c, h00 c, h00 c, h00 c, h00 c,
h00 c, h80 c, hE6 c, h66 c, h00 c, h00 c, h00 c, h00 c,
h08 c, h1C c, h36 c, h63 c, h41 c, h00 c, h00 c, h00 c,
h24 c, h24 c, h24 c, h24 c, h24 c, h24 c, h00 c, h00 c,
h00 c, h41 c, h63 c, h36 c, h1C c, h08 c, h00 c, h00 c,
h02 c, h03 c, h51 c, h59 c, h0F c, h06 c, h00 c, h00 c,
h3E c, h7F c, h41 c, h5D c, h5D c, h1F c, h0E c, h00 c,
h7C c, h7E c, h13 c, h13 c, h7E c, h7C c, h00 c, h00 c,
h41 c, h7F c, h7F c, h49 c, h49 c, h7F c, h36 c, h00 c,
h1C c, h3E c, h63 c, h41 c, h41 c, h63 c, h22 c, h00 c,
h41 c, h7F c, h7F c, h41 c, h63 c, h3E c, h1C c, h00 c,
h41 c, h7F c, h7F c, h49 c, h5D c, h41 c, h63 c, h00 c,
h41 c, h7F c, h7F c, h49 c, h1D c, h01 c, h03 c, h00 c,
h1C c, h3E c, h63 c, h41 c, h51 c, h73 c, h72 c, h00 c,
h7F c, h7F c, h08 c, h08 c, h7F c, h7F c, h00 c, h00 c,
h00 c, h41 c, h7F c, h7F c, h41 c, h00 c, h00 c, h00 c,
h30 c, h70 c, h40 c, h41 c, h7F c, h3F c, h01 c, h00 c,
h41 c, h7F c, h7F c, h08 c, h1C c, h77 c, h63 c, h00 c,
h41 c, h7F c, h7F c, h41 c, h40 c, h60 c, h70 c, h00 c,
h7F c, h7F c, h0E c, h1C c, h0E c, h7F c, h7F c, h00 c,
h7F c, h7F c, h06 c, h0C c, h18 c, h7F c, h7F c, h00 c,
h1C c, h3E c, h63 c, h41 c, h63 c, h3E c, h1C c, h00 c,
h41 c, h7F c, h7F c, h49 c, h09 c, h0F c, h06 c, h00 c,
h1E c, h3F c, h21 c, h71 c, h7F c, h5E c, h00 c, h00 c,
h41 c, h7F c, h7F c, h09 c, h19 c, h7F c, h66 c, h00 c,
h26 c, h6F c, h49 c, h49 c, h7B c, h32 c, h00 c, h00 c,
h03 c, h41 c, h7F c, h7F c, h41 c, h03 c, h00 c, h00 c,
h7F c, h7F c, h40 c, h40 c, h7F c, h7F c, h00 c, h00 c,
h1F c, h3F c, h60 c, h60 c, h3F c, h1F c, h00 c, h00 c,
h7F c, h7F c, h30 c, h18 c, h30 c, h7F c, h7F c, h00 c,
h61 c, h73 c, h1E c, h0C c, h1E c, h73 c, h61 c, h00 c,
h07 c, h4F c, h78 c, h78 c, h4F c, h07 c, h00 c, h00 c,
h47 c, h63 c, h71 c, h59 c, h4D c, h67 c, h73 c, h00 c,
h00 c, h7F c, h7F c, h41 c, h41 c, h00 c, h00 c, h00 c,
h01 c, h03 c, h06 c, h0C c, h18 c, h30 c, h60 c, h00 c,
h00 c, h41 c, h41 c, h7F c, h7F c, h00 c, h00 c, h00 c,
h08 c, h0C c, h06 c, h03 c, h06 c, h0C c, h08 c, h00 c,
h80 c, h80 c, h80 c, h80 c, h80 c, h80 c, h80 c, h80 c,
h00 c, h00 c, h01 c, h03 c, h06 c, h04 c, h00 c, h00 c,
h20 c, h74 c, h54 c, h54 c, h3C c, h78 c, h40 c, h00 c,
h41 c, h7F c, h3F c, h48 c, h48 c, h78 c, h30 c, h00 c,
h38 c, h7C c, h44 c, h44 c, h6C c, h28 c, h00 c, h00 c,
h30 c, h78 c, h48 c, h49 c, h3F c, h7F c, h40 c, h00 c,
h38 c, h7C c, h54 c, h54 c, h5C c, h18 c, h00 c, h00 c,
h48 c, h7E c, h7F c, h49 c, h03 c, h02 c, h00 c, h00 c,
h98 c, hBC c, hA4 c, hA4 c, hF8 c, h7C c, h04 c, h00 c,
h41 c, h7F c, h7F c, h08 c, h04 c, h7C c, h78 c, h00 c,
h00 c, h44 c, h7D c, h7D c, h40 c, h00 c, h00 c, h00 c,
h60 c, hE0 c, h80 c, h80 c, hFD c, h7D c, h00 c, h00 c,
h41 c, h7F c, h7F c, h10 c, h38 c, h6C c, h44 c, h00 c,
h00 c, h41 c, h7F c, h7F c, h40 c, h00 c, h00 c, h00 c,
h7C c, h7C c, h08 c, h38 c, h0C c, h7C c, h78 c, h00 c,
h7C c, h7C c, h04 c, h04 c, h7C c, h78 c, h00 c, h00 c,
h38 c, h7C c, h44 c, h44 c, h7C c, h38 c, h00 c, h00 c,
h84 c, hFC c, hF8 c, hA4 c, h24 c, h3C c, h18 c, h00 c,
h18 c, h3C c, h24 c, hA4 c, hF8 c, hFC c, h84 c, h00 c,
h44 c, h7C c, h78 c, h4C c, h04 c, h1C c, h18 c, h00 c,
h48 c, h5C c, h54 c, h54 c, h74 c, h24 c, h00 c, h00 c,
h00 c, h04 c, h3E c, h7F c, h44 c, h24 c, h00 c, h00 c,
h3C c, h7C c, h40 c, h40 c, h3C c, h7C c, h40 c, h00 c,
h1C c, h3C c, h60 c, h60 c, h3C c, h1C c, h00 c, h00 c,
h3C c, h7C c, h60 c, h38 c, h60 c, h7C c, h3C c, h00 c,
h44 c, h6C c, h38 c, h10 c, h38 c, h6C c, h44 c, h00 c,
h9C c, hBC c, hA0 c, hA0 c, hFC c, h7C c, h00 c, h00 c,
h4C c, h64 c, h74 c, h5C c, h4C c, h64 c, h00 c, h00 c,
h08 c, h08 c, h3E c, h77 c, h41 c, h41 c, h00 c, h00 c,
h00 c, h00 c, h7F c, h7F c, h00 c, h00 c, h00 c, h00 c,
h41 c, h41 c, h77 c, h3E c, h08 c, h08 c, h00 c, h00 c,
h02 c, h03 c, h01 c, h03 c, h02 c, h03 c, h01 c, h00 c,
h4C c, h5E c, h73 c, h01 c, h73 c, h5E c, h4C c, h00 c,

\ =========================================================================== 
\ Variables 
\ =========================================================================== 
\ Buffer for 8x8Matrix
variable 8x8Matrix 4 allot

\ =========================================================================== 
\ Main 
\ =========================================================================== 
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

\ Page write operation
\ ( n1..nn n2 n3 n4 -- )  n1..nn:data n2:number n3:command n4:slave_address  
: pageWr
\ Start I2C 
_eestart
\ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi) 
_eewrite                      \ ( n1,,nn n2 n3 t/f )
\ Write command
swap _eewrite or              \ ( n1,,nn n2 t/f )
\ Write data
st?
swap                          \ ( n1,,nn t/f n2 )
0 do                                
     swap _eewrite or         \ ( t/f ) 
loop
\ Stop I2C
_eestop                       
err?                          \ ( -- )
;

\ 

\ Initialize HT16K33
\ ( -- )
: init_HT16K33
sysSetup oscOn or HT16K33 wrCom1   \ Set systemOscillator to on
Blink HT16K33 wrCom1               \ Set Blink to off
Brightness 1 or HT16K33 wrCom1     \ Set Brightness to 1
;

\ Display on
\ ( -- )
: dispON h81 HT16K33 wrCom1 ;

\ Display off
\ ( -- )
: dispOFF h80 HT16K33 wrCom1 ;

\ Set Blink
\ ( n1 -- )
: setBlink Blink or dispOn or HT16K33 wrCom1 ;


\ HOLTEK test
\ ( -- )
: testmode
hD9 HT16K33 wrCom1                 \ Testmode command                      
dispON
;

\ Display Matrix-buffer to 8x8Matrix
\ ( -- )
: scanMatrix
init_HT16K33
dispON 
begin 
     8 0 do 8x8Matrix i + C@ addrPtr i 2* + HT16K33 wrCom2 loop 
0 until 
;

\ Clear 8x8Matrix buffer
\ ( -- )
: clrMatrix 0 8x8Matrix L! 0 8x8Matrix 4+ L! ;

\ Display 1character-font from right to left inside 8x8Matrix
\ ( n1 -- )  n1:character code
: 1charMatrix
h20 - 8 * Font +              \ Top address of character
8 0 do
     \ Shift data
     8x8Matrix 1+ 
     7 0 do
          dup dup
          C@ swap 1- C!
          1+
     loop
     drop
     d100 delms
     dup
     C@ 8x8Matrix 7 + C!      \ Save data to 8x8Matrix
     1+
loop
drop
; 

\ Display string
\ ( cstr -- )
: strMatrix
C@++                                    \ ( c-addr+1 c1 )  c-addr+1: string's first char addr  c1:string length
dup 
if 
     bounds do i C@ 1charMatrix loop    \ Print string 
else 
     2drop 
then 
;

\ Display all characters
\ ( -- )
: demo1
clrMatrix
c" scanMatrix" 0 cogx
h20
d96 0 do
     dup 
     1charMatrix
     1+
loop
drop
d500 delms
0 cogreset
;

\ Characters and Brightness
\ ( -- )
: demo2
clrMatrix
c" scanMatrix" 0 cogx
h30
d10 0 do
     dup 
     1charMatrix
     1+
loop
drop
clrMatrix
d500 delms
c" May the Forth be with you" strMatrix
d500 delms
0 cogreset

\ Brightness
h10 0 do Brightness i or HT16K33 wrCom1 d500 delms loop
Brightness 1 or HT16K33 wrCom1
\ Blink
Blink 2Hz or dispOn or HT16K33 wrCom1 d5000 delms
Blink 1Hz or dispOn or HT16K33 wrCom1 d5000 delms
Blink 0.5Hz or dispOn or HT16K33 wrCom1 d5000 delms
Blink dispOn or HT16K33 wrCom1
;

