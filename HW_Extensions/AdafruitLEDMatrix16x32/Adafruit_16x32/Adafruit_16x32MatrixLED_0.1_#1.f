fl

{                       
PropForth 5.5(DevKernel)

Adafruit 16X32 Matrix
2016/10/13 14:40:35


   Adafruit 16X32 Matrix    [ C B A ]
 -------------------------
| b31   ......         b0 | [ 0 0 0 ]      
| upper matrix(8x32)      |    ...        upper matrix(8x32) color[ B1 G1 R1 ]
|                         | [ 1 1 1 ]
|-------------------------|
| b31   ......         b0 | [ 0 0 0 ]     
| lower matrix(8x32)      |    ...        lower matrix(8x32) color[ B2 G2 R2 ]
|                         | [ 1 1 1 ]
 -------------------------
 ^                      ^
output signal side      Input signal side
(LED Matrux side)       (LED Matrux side)



Dot buffer   32Long X 16 = 2048bytes 1dot=4bytes(32bit)
Using free area( here W@) as matrix buffer
     -------------------------
0   | b31    ......        b0 | <-- 128bytes     
..  | upper matrix(8x32)      |   
7   |                         | 
    |-------------------------|
8   | b31   ......         b0 |     
..  | lower matrix(8x32)      | 
15  |                         | 
     -------------------------
     (LED Matrux side)
     
Pulled down[10kohm] from P0 to P5[R1 G1 B1 R2 G2 B2] because of preventing LED-on when 5V power-on     
}

\ =========================================================================== 
\ Variables 
\ =========================================================================== 
wvariable n
d124 constant array31
wvariable color0
wvariable color1
{
adafruitStrStruct        char num on upper-plane
adafruitStrStruct+2      string on upper-plane
adafruitStrStruct+28     char num on lower-plane
adafruitStrStruct+30     string on lower-plane
}
wvariable adafruitStrStruct d54 allot

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
1 EN lshift constant en_m                         \ EN 
upper_m lower_m and constant plane_m

\ =========================================================================== 
\ 8X8 Font Characters for OLED
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
Font d768 + wconstant Font_end

\ =========================================================================== 
\ Main 
\ =========================================================================== 
\ Set matrix buffer's value(1Long) into outa-register 
\ ( n1 -- n2 )  n1:address of matrix buffer  n2:n1+4
lockdict create a_matrix_16x32 forthentry
$C_a_lxasm w, h118  h113  1- tuck - h9 lshift or here W@ alignl h10 lshift or l,
z8ixZB l, z1bix[N l, z20yPO4 l, z1SV01X l, z80 l,
freedict

\ Set [C B A] to matrix buffer
\ ( -- )
: prepMatrix
here W@
2 0 do
     8 0 do                             \ from 1st line to 8th line
          d32 0 do                      \ from bit0 to bit31
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
          d32 0 do
               a_matrix_16x32
          loop
          LE pinhi LE pinlo 
          EN pinlo
     loop
     drop
\     fkey? swap drop     
0 until
\ drop
;

\ Clear color-bit in matrix_buffer
\ ( -- )
: clrMatrix
setPort
h3F R1 lshift invert here W@       \ ( color_mask matrix_buffer_address )
d512 0 do
     2dup
     dup L@ rot and swap L!        \ Clear color
     4+
loop
2drop
;
     
     
\ Shift upper section(8x32) of matrix_array(16x32) to left(1Long)
\ ( n1 -- ) n1:matrix buffer address
: shift_bit
8 0 do                                  \ 8 line
     dup dup                            \ ( addr addr addr )
     d31 0 do
          dup 4+                        \ ( addr addr addr addr+4 )
          L@ swap L!                    \ ( addr addr )
          4+ dup                        \ ( addr addr+4 addr+4 )
     loop
     2drop                              \ ( addr )
     d128 +                             \ next line
loop
drop
;

\ Set cstr in upper adafruitStrStruct
\ ( n1 -- ) n1:cstr
: setUpperStr 
C@++ dup                           \ ( c-addr+1 c1 c1 )
adafruitStrStruct W!               \ Save string length
bounds adafruitStrStruct 2+ rot2
do dup i C@ swap C! 1+ loop
drop 
;

\ Set cstr in lower adafruitStrStruct
\ ( n1 -- ) n1:cstr
: setLowerStr
C@++ dup                           \ ( c-addr+1 c1 c1 )
adafruitStrStruct d28 + W!         \ Save string length
bounds adafruitStrStruct d30 + rot2
do dup i C@ swap C! 1+ loop
drop 
;

\ Print 1character on upper plane
\ ( n1 -- ) n1:character's top-addr 
: upperChar
8 0 do
     dup                                     \ ( addr addr )
     C@ 1                                    \ ( addr value 1 )
     8 0 do                                  \ from 1st line to 8th line(each bit row)
          \ Save bit[0-7] value of each line
          2dup and                           \ ( addr value 1 1/0 )
          if color0 W@ else 0 then           \ ( addr value 1 color0/0 ) Selection color
          here W@
          i d128 u* + array31 +              \ ( addr value 1 color0/0 [address of bit*] )
          swap over L@ upper_m and
          swap R1 lshift
          or                                 \ ( addr value 1 [address of bit*] [content of bit*])
          swap L!                            \ ( addr value 1 )
          1 lshift                           \ next bit
     loop                                    \ ( addr value h100 )
     here W@ shift_bit                       \ Shift b30-b0 of upper section to 1bit left    
     2drop                                   \ ( addr )
     1+                                      \ ( addr+1 )
loop     
drop                                         \ ( -- )               
;

\ Print 1character on lower plane
\ ( n1 -- ) n1:character's top-addr 
: lowerChar
8 0 do
     dup                                     \ ( addr addr )
     C@ 1                                    \ ( addr value 1 )
     8 0 do                                  \ from 1st line to 8th line(each bit row)
          \ Save bit[0-7] value of each line
          2dup and                           \ ( addr value 1 1/0 )
          if color1 W@ else 0 then           \ ( addr value 1 color1/0 ) Selection color
          here W@ d1024 + 
          i d128 u* + array31 +              \ ( addr value 1 color1/0 [address of bit*] )
          swap over L@ lower_m and
          swap R2 lshift
          or                                 \ ( addr value 1 [address of bit*] [content of bit*])
          swap L!                            \ ( addr value 1 )
          1 lshift                           \ next bit
     loop                                    \ ( addr value h100 )
     here W@ d1024 + shift_bit               \ Shift b30-b0 of upper section to 1bit left    
     2drop                                   \ ( addr )
     1+                                      \ ( addr+1 )
loop     
drop                                         \ ( -- )               
;

\ Display string on adafruit matrix32x16
\ character move from right to left
\ ( -- )         
: adafruitStr
prepMatrix
c" scanMatrix" 0 cogx
adafruitStrStruct d30 + adafruitStrStruct 2+
begin
     \ upper plane
     dup C@                                  \ Get character-code in string 
     h20 - 8 u* Font +                       \ Get Font's top address 
                                             \ ( lower-str-addr upper-str-addr Font-addr )
                                         \                   st?
     \ Print 1character
     upperChar                               \ ( lower-str-addr upper-str-addr )
     \ Check if upper string is end
     1+ dup adafruitStrStruct dup W@ + 1+ > 
     if drop adafruitStrStruct 2+ then       \ ( lower-str-addr upper-str-addr )                                                                              

     \ lower plane
     swap                                    \ ( upper-str-addr lower-str-addr )
     dup C@                                  \ Get character-code in string 
     h20 - 8 u* Font +                       \ Get Font's top address 
                                             \ ( lower-str-addr upper-str-addr Font-addr )
     \ Print 1character
     lowerChar                               \ ( upper-str-addr lower-str-addr )
     \ Check if upper string is end
     1+ dup adafruitStrStruct d28 + dup W@ + 1+ > 
     if drop adafruitStrStruct d30 + then                                                                                     
     swap                                    \ ( lower-str-addr upper-str-addr )
     fkey? swap drop                     
until                                     
2drop
clrMatrix
0 cogreset                         
;
{
c" PropForth5.5 " setUpperStr 
c" May the Forth be with you." setLowerStr 
2 color0 W!
1 color1 W!
}
{
fl                                                                                                       
\ ( n1 -- n2 )  n1:address of buffer
build_BootOpt :rasm          
          rdlong    outa , $C_stTOS
          or        outa , __clk
          add       $C_stTOS , # 4
          jexit
__clk
     h200
          
;asm a_matrix_16x32
}
