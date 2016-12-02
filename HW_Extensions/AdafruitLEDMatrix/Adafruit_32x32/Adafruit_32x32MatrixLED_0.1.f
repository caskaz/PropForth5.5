fl

{                       
PropForth 5.5(DevKernel)

Adafruit 32X32 Matrix
2016/12/02 14:21:49


   Adafruit 16X32 Matrix           Adafruit 16X32 Matrix    [ C B A ]
 -------------------------       -------------------------
| b63   ......         b32|     | b31   ......         b0 | [ 0 0 0 ]      
| upper matrix(8x32)      |     | upper matrix(8x32)      |    ...        upper matrix(8x32) color[ B1 G1 R1 ]
|                         |     |                         | [ 1 1 1 ]
|-------------------------|=====|-------------------------| 
| b63   ......         b32|cable| b31   ......         b0 | [ 0 0 0 ]     
| lower matrix(8x32)      |     |    lower matrix(8x32)   |               lower matrix(8x32) color[ B2 G2 R2 ]
|                         |     |                         | [ 1 1 1 ]
 -------------------------       -------------------------
 ^                      ^         ^                     ^
 |                      |       output signal side    Input signal side
 |                      |
output signal side    Input signal side


Dot buffer   64Long X 16 = 4096bytes 1dot=4bytes(32bit)
Using free area( here W@) as matrix buffer

      -------------------------
0    | b31   ......         b0 |  <-- 128bytes(4byte X 32)    
..   | upper matrix(8x32)      |   
7    |                         | 
     |-------------------------|
8    | b31   ......         b0 |    
..   |    lower matrix(8x32)   |              
15   |                         | 
      -------------------------
0    | b63   ......         b32|  <-- 128bytes(4byte X 32)    
..   | upper matrix(8x32)      |   
7    |                         |                         
     |-------------------------|
8    | b63   ......         b32|    
..   | lower matrix(8x32)      |              
15   |                         |  
      --------------------------

Address for Matrix
   b63                            b32           b31                             b0    [ C B A ]
 --------------------------------------       --------------------------------------
|here W@ + 0      Y=16    here W@ + 127|     |here W@ + 128    Y=0     here W@ + 255| [ 0 0 0 ]
|      .                       .       |     |      .                          .    |    ...
|      .                       .       |     |      .                          .    |    ...
|here W@ + 1792   Y=23   here W@ + 1919|     |here W@ + 1920   Y=7    here W@ + 2047| [ 1 1 1 ]
|--------------------------------------|=====|--------------------------------------|
|here W@ + 2048   Y=24   here W@ + 2175|cable|here W@ + 2176   Y=8    here W@ + 2303| [ 0 0 0 ]
|     .                        .       |     |      .                       .       |    ...
|     .                        .       |     |      .                       .       |    ...
|here W@ + 3840   Y=31   here W@ + 3967|     |here W@ + 3968   Y=15   here W@ + 4095| [ 1 1 1 ]
 --------------------------------------      ---------------------------------------

     
Pulled down[10kohm] from P0 to P5[R1 G1 B1 R2 G2 B2] because of preventing LED-on when 5V power-on     
}

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
\ Pin
0 wconstant R1
\ 1 wconstant G1
\ 2 wconstant B1
3 wconstant R2
\ 4 wconstant G2
\ 5 wconstant B2
6 wconstant LnA
\ 7 wconstant LnB
\ 8 wconstant LnC
9 wconstant CLK
d10 wconstant LE
d11 wconstant EN

7 R1 lshift invert constant upper_m               \ mask bit for upper-matrix RGB
7 R2 lshift invert constant lower_m               \ mask bit for lower-matrix RGB
7 LnA  lshift invert constant line_m              \ mask bit for line
1 EN lshift constant en_m                         \ mask bit for EN 
1 CLK lshift constant clk_m                       \ mask bit for CLK   
 
\ =========================================================================== 
\ Variables 
\ =========================================================================== 
wvariable color1
variable odd
variable row_line

\ =========================================================================== 
\ Main 
\ =========================================================================== 
\ Set matrix buffer's value(1Long) into outa-register 
\ ( n1 n2 - n3 )  n1:address of matrix buffer  n2:clk_m  n3:n1+4
lockdict create a_matrix_16x32 forthentry
$C_a_lxasm w, h119  h113  1- tuck - h9 lshift or here W@ alignl h10 lshift or l,
z2WiPZB l, z1SyLI[ l, z8ixZB l, z1bixZC l, z20yPO4 l, z1SV01X l,
freedict

\ Set [C B A] to matrix buffer
\ ( -- )
: prepMatrix
here W@
2 0 do
     8 0 do                             \ from 1st line to 8th line
          d64 0 do                      \ from bit0 to bit31
               j LnA lshift             \ Get line number
               en_m or                  \ Add EN 
               over L!                  \ Save line number to each dot
               4+                       \ next address
          loop
     loop
loop
drop
;

\ Set port to output
\ ( -- )
: setPort R1 d12 0 do dup pinout 1+ loop drop ;

\ Display matrix buffer's value to LED-Matrix
\ ( -- )
: scanMatrix
setPort
here W@                            \ Address for matrix buffer
begin
     dup
     d16 0 do
          d64 0 do
               clk_m a_matrix_16x32
          loop
          LE pinhi LE pinlo     
          EN pinlo
     loop
     drop
\     fkey? swap drop     
\ until
0 until
\ drop
;

\ Clear color-bit in matrix_buffer
\ ( -- )
: clrMatrix
setPort
h3F R1 lshift invert here W@       \ ( color_mask matrix_buffer_address )
d1024 0 do
     2dup
     dup L@ rot and swap L!        \ Clear color
     4+
loop
2drop
;
     
\ Shift 31bit to 1bit left
\ ( n1 -- ) n1:matrix address
: shift16x32     
d16 0 do                                \ 16 line
     dup                                \ ( addr addr )
     d31 0 do
          dup dup 4+                    \ ( addr addr addr addr+4 )  
          L@ swap L!                    \ ( addr addr )
          4+                            \ ( addr addr+4 )
     loop
     drop                               \ ( addr )
     d256 +                             \ next line
loop
;

\ Shift upper(16x32) and lower(16x32) board of matrix_array(32x32) to left(1dot)
\ ( -- )
: shift_bit32x32
\ bit63-bit32
here W@ d128 + shift16x32 
drop                               
\ bit31-bit0
here W@ shift16x32  
drop
;


\ Get 1-row(32bit) from character                                                    
\ ( n1 -- ) n1:font-address
: Get_rowline
d32 0 do
     row_line L@ 1 rshift row_line L!             \ Shift row_line to right
     dup L@ odd L@                                \ ( font-address data odd )
     and                                          \ ( font-address t/f )          
     if 
          row_line L@ h80000000 or row_line L!    \ Uodate bit-data of row_line 
     then                                         \ ( font-address )
     \ Add 4 to font-address   ( to next row )       
     4 +                                          \ ( font-address+4 )
loop
drop  
;

\ Select color
\ ( n1 -- n2 ) n1:1/0  n2:color1/0
: selColor
2dup and
if color1 W@ else 0 then           \ Check if bit is true
;

\ Select R1 or R2
\ ( n1 -- n2 ) n1:1/0  n2:R1/R2
: selR1/R2 if R2 lshift else R1 lshift then ;

\ Get address of bit63
\ ( n1 -- n2 ) n1:row[15-0]  n2:address of bit63
: addrBit63 d256 u* here W@ + ;

\ Update color to check if upper or lower
\ ( n1 n2 n3 -- n4 ) n1:color1/0 n2:value n3:1/0  n4:value
: updateColor
if lower_m else upper_m then
and or 
;

\ Print prop character(32x16) on adafruit matrix LED
{
Even-character is even-bits. (bit30,28,26,24,....4,2,0)
    address     column ----->          
row  n          b31 b30 b29 . . . b1  b0
 |   n+4         0   0   0        0   0
 |   .
 |   .
\|/  n+d124      0   0   0        0   0
 
row_line n      --> character's top
row_line n+d124 --> character's bottom
}
\ ( n1 -- ) n1:character cide
: PropChar
dup 1 and if 2 else 1 then odd L!       \ Check even/odd
hFE and
d64 u* h8000 +                          \ Get ROM Font address
                                                                     
\ Print row-lines(1 row-line=32dots)
d16 0 do
     dup                                \ ( font-address font-address )
     \ Get 1-row(32bit) from character                                                    
     Get_rowline                        \ ( font-address ) 
{     
     \ --- Print character to TeraTerm window ----
     \ row_line:bit31 is bottom of character
           row_line L@ h80000000
           d32 0 do 2dup and if h41 else h20 then emit 1 rshift loop
           2drop cr
     \ -------------------------------------------
}     
     \ Display 1 row-line to Adafruit Matrix LED
     row_line L@ h80000000     
     \ lower16x32 board
     d16 0 do                           \ ( font-address [row_line] h80000000 )
          selColor
          i 8 <                         \ Check if section is lower (lower section when i < 8)
          selR1/R2                      \ ( font-address [row_line] h80000000 color1/0 )          
          d15 i - addrBit63 d124 +      \ Get bit32 address of Matrix LED
          swap over                     \ ( font-address [row_line] h80000000 address color1/0 address )
          L@ 
          i 8 <                         \ Check if section is lower (lower section when i < 8)
          updateColor
          swap L!                       \ ( font-address [row_line] h80000000 )
          1 rshift
     loop                                         
     \ upper16x32 board
     d16 0 do                           \ ( font-address [row_line] h8000 1 )
          selColor
          i 8 <                         \ Check if section is lower (lower section when i < 8)
          selR1/R2                              \ ( font-address [row_line] h8000 color1/0 )
          d15 i - addrBit63 d252 +      \ Get bit0 address of Matrix LED 
          swap over                     \ ( font-address [row_line] h8000 address color1/0 address )
          L@ 
          i 8 <                         \ Check if section is lower (lower section when i < 8)
          updateColor
          swap L!                       \ ( font-address [row_line] h8000 )
          1 rshift
     loop                                   
     2drop                                              
     \ next colummn bit
     odd L@ 2 lshift odd L! 
     shift_bit32x32                     \ Shift character to 1bit left                          
loop     
drop    
;

\ Prop-character string
\ ( n1 -- ) n1:cstr
: PropStr
C@++                          \ ( c-addr+1 c1 )
bounds do i C@ PropChar loop
;

\ Didplay Prop-character
\ ( -- )
: demo1
prepMatrix
c" scanMatrix" 0 cogx
1 color1 W!

0
begin
     dup PropChar
     1+
     color1 W@ 1+ dup 8 = if drop 1 then color1 W!      \ next color 
     fkey? swap drop
until
drop
clrMatrix
0 cogreset
;
 
\ Display string
\ ( -- )    
: demo2
prepMatrix
c" scanMatrix" 0 cogx
6 color1 W!
c" PropForth5.5" PropStr
clrMatrix
d10 delms
0 cogreset
;

{
fl                                                                                                       
\ ( n1 n2 -- n3 )  n1:address of buffer n2:clk_m  n3:n1+4
build_BootOpt :rasm
          mov       $C_treg1 , $C_stTOS
          spop   
          rdlong    outa , $C_stTOS
          or        outa , $C_treg1
          add       $C_stTOS , # 4
          jexit
          
;asm a_matrix_16x32
}
