fl
                                                                        
{
128x64 LCD with 8bit-parallel(controller:ST7565)
   
2015/02/19 12:58:19
           
     LCD(128x64) Propeller
      CS   -----  P0
      RES  -----  P1
      A0   -----  P2
      R/W  -----  P3 
      E    -----  P4
      D0   -----  P5
      D1   -----  P6
      D2   -----  P7
      D3   -----  P8
      D4   -----  P9
      D5   -----  P10
      D6   -----  P11
      D7   -----  P12
      VDD  -----  3.3V 
      VSS  -----  0V
      
}


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

\ -------------------------------------------------------
\ Constants
\ -------------------------------------------------------
0 wconstant _cs
1 wconstant _res
2 wconstant _a0
3 wconstant _r/w
4 wconstant _e
5 wconstant _data0
hFF _data0 lshift invert constant mask

\ --- command ---
hAF wconstant DispOn          \ Display ON
hAE wconstant DispOff         \ Display OFF
h40 wconstant Start_Line      \ Set start Line
hB0 wconstant Set_Page        \ Set Page Address
h10 wconstant Set_Col_MSB     \ Set Column Address(MSB) 
h00 wconstant Set_Col_LSB     \ Set Column Address(LSB)
hA0 wconstant ADC_sel         \ SEG Direction

hA6 wconstant Normal          \ Normal Display
hA7 wconstant Reverse         \ Inverse Display
hA4 wconstant Pixel_off       \ Normal Display
hA5 wconstant Pixel_on        \ All Pixel On
hA2 wconstant Bias            \ Bias Select
hE0 wconstant R_M_W           \ Read-modify-Write
hEE wconstant END             \ End "Read-modify-Write"
hE2 wconstant soft_RST        \ Reset
hC0 wconstant COM_normal      \ COM Direction(normal)
hC8 wconstant COM_reverse     \ COM Direction(reverse)
h2F wconstant PWR_ctl         \ Power Control(VB=VR=VF=1)
h20 wconstant reguration      \ Reguration internal rasistor Ratio
h81 wconstant Set_EV          \ Set Electronic Volume[DoubleByteCommand]
hAC wconstant static_On       \ Static Indicator ON[DoubleByteCommand]                                   
hAD wconstant static_Off      \ Static Indicator OFF[DoubleByteCommand]  
hF8 wconstant Boost_ratio     \ Booster Ratio[DoubleByteCommand]
hE3 wconstant NOP

0 wconstant data
1 wconstant command

\ -------------------------------------------------------
\ Variables
\ -------------------------------------------------------
\ 8x8Font character formation
wvariable x
wvariable y
\ ROM Font
wvariable xdot      \ X dot-position 
wvariable yy
variable odd
variable row_line
\ 1:8x8Font  0;ROM Font
wvariable font_type

\ -------------------------------------------------------
\ Main
\ -------------------------------------------------------

\ Write data/command to ST7565
\ ( n1 n2 -- )  n1:value  n2:data/command 
: wr_st7565
_cs pinlo                     \ Set CS to lo
_r/w pinlo                    \ set R/W to lo
\ Set A0 to lo if command
if 
     _a0 pinlo                \ command
else
     _a0 pinhi                \ data
then
\ Set data
_data0 lshift
outa COG@ mask and or
outa COG!

_e pinhi _e pinlo             \ Add E pulse
_cs pinhi                     \ Set cs to hi
;

\ Read data/status from ST7565
\ ( n1 -- n2 )  n1:data/status  n2:data 
: rd_st7565
_cs pinlo                     \ Set CS to lo
_r/w pinhi                    \ set R/W to hi
\ Set A0 to lo if status
if 
     _a0 pinlo                \ status
else
     _a0 pinhi                \ data
then
\ Read data
ina COG@ _data0 rshift hFF and
_cs pinhi                     \ Set cs to hi
;

\ Execute before power-off
\ Power off
\ ( -- )
: poweroff
static_Off command wr_st7565
DispOff command wr_st7565
Pixel_on command wr_st7565
_res pinlo 100 delms 

;

\ Adjustment for contrast
\ Write value to Set_EV
\ ( n1 -- )  n1:value   
: contrast
Set_EV command wr_st7565
command wr_st7565
;

\ Normal display
\ When writing "1", dot is black.[Background:white]
\ ( -- )
: Normal_disp
Normal command wr_st7565
;

\ Reverse display
\ When writing "1", dot is white.[Background:black]
: Reverse_disp
Reverse command wr_st7565
;

\ Initialize LCD(128x64)
\ ( -- )
: init_ST7565
\ LCD driving 
Bias command wr_st7565
ADC_sel command wr_st7565
COM_reverse command wr_st7565
reguration 6 or command wr_st7565
d20 contrast
PWR_ctl command wr_st7565
\ Display setting
Start_Line command wr_st7565
Pixel_off command wr_st7565
Normal_disp
\ Reverse_disp 
Set_Page command wr_st7565
Set_Col_MSB command wr_st7565
Set_Col_LSB command wr_st7565
;

\ Position in DDRAM
\ ( n1 n2 -- )  n1:x[0-15] n2:y[0-7]
: pos
\ y-position
Set_Page or command wr_st7565
\ x-position
8 u* 4+ dup
4 rshift Set_Col_MSB or command wr_st7565
hF and Set_Col_LSB or command wr_st7565
;

\ Write 1-character[8x8] to DDRAM
{
 FONT on (0,0)-(15,7)[x,y]
   
     x --------------------->
        0 1     ..        15
   y    ---------------------
   | 0 |(0,0) ..       (15,0)|
   | 1 |(0,1) ..       (15,1)|
   | 2 |(0,2) ..       (15,2)|
   | 3 |(0,3) ..DDRAM  (15,3)|
   | 4 |(0,4) ..       (15,4)|
   | 5 |(0,5) ..       (15,5)|
   | 6 |(0,6) ..       (15,6)|
   | 7 |(0,7) ..       (15,7)|
  \|/   ---------------------
}
\ ( n1 n2 n3 -- )  n1:character  n2:x-position[0 - 15] n3:y-position[0 - 7]
: lcd_char_8x8
\ Set position
pos                                                                    
\  Get 8x8-character                            
h20 - 8 u* Font +                  \ Get Font address
\ Copy character to DDRAM          
8 0 do
     dup                           \ ( Font_adr Font_adr )                           
     C@ data wr_st7565
     1+                            \ ( Font_adr+1 )
loop
drop 
;

{
 Get prop-character 
Even-character is even-bits. (bit30,28,26,24,....4,2,0)
address          column ----->          
row  n          b31 b30 b29 . . . b1  b0
 |   n+4         0   0   0        0   0
 |   .
 |   .
\|/  n+d124      0   0   0        0   0
 
 row_line n      --> character's top
 row_line n+d124 --> character's bottom
}
\ ( n1 -- )  n1:character code
: prop_char
dup 1 and if 2 else 1 then odd L!       \ Check even/odd
hFE and
d64 u* h8000 +                          \ Get ROM Font address
                                        \ character for ROM font occupy 64bytes(character include even/odd-characters)
\ column=16bits
d16 0 do
     dup                                               \ ( font-address font-address )
    
     d32 0 do
          row_line L@ 1 rshift row_line L!             \ Shift row_line to right
          dup L@ odd L@                                \ ( font-address font-address data odd )
          and                                          \ ( font-address font-address t/f )          
          if 
               row_line L@ h80000000 or row_line L!    \ Update bit-data of row_line 
          then                                         \ ( font-address font-address )
          \ Add 4 to font-address   ( to next row )       
          4 +                                          \ ( font-address font-address+4 )
     loop     
     drop                                              \ ( font-address )
     
     \ --- Copy 32bit-data to DDRAM ---     
     4 0 do
          \ Next (xdot,y)
          xdot W@ 4+ dup
          4 rshift Set_Col_MSB or command wr_st7565
          hF and Set_Col_LSB or command wr_st7565
          yy W@ i + Set_Page or command wr_st7565                
          i row_line + C@ data wr_st7565                              
     loop
     xdot W@ 1+ xdot W!                                \ Update (xdot,y) 
{     
     \ --- Print character to TeraTerm window ----
           row_line L@ h80000000
           d32 0 do 2dup and if h41 else h20 then emit 1 rshift loop
           2drop cr
     \ -------------------------------------------
}     
     \ next colummn bit
     odd L@ 2 lshift odd L!                       
loop
drop
;

\ Write 1-character[ROM-FONT:16dotx32dot] to DDRAM
{
 ROM-FONT on (0,0)-(7,1) [x,y]
   
     x --------------------->
        0 1               7
   y    --------------------
   | 0 |(0,0) ..       (7,0)|<--4lines [1line=128bytes]
   | 1 |(0,1) .. DDRAM (7,1)|<--4lines
  \|/   --------------------
}
\ ( n1 n2 n3 -- )  n1:character  n2:x-position[0 - 7] n3:y-position[0 - 1]
: lcd_char_prop
\ Set position
if 4 else 0 then
dup yy W!                          \ Save y
swap
2 u* dup 8 u* xdot W!              \ Save xdot
swap
pos                                 

prop_char
;


\ Print 1-character and update only x
\ Display is only 1-line 
\ ( n1 -- )  n1:character code
: print
x W@ y W@ 
font_type W@
if
     lcd_char_8x8
else
     lcd_char_prop
then             
\ update char_x
x W@ 1+ x W!
;

\ Display string to LCD(128x64dots)
\ Always display only 1-line
\ ( cstr -- )
: lcd_string
C@++ dup
if
     bounds do
          i C@ 
          print
     loop
else
     2drop
then
;

\ Clear DDRAM
\ ( -- )
: clr_scrn
8 0 do
     i Set_Page or command wr_st7565
     Set_Col_MSB command wr_st7565
     Set_Col_LSB 4+ command wr_st7565
     d128 0 do
          0 data wr_st7565
     loop
loop    
;

\ initial setting
\ ( -- )
: init_LCD
_cs pinhi _cs pinout                              \ Set cs to output abd to hi
_res pinhi
_res d12 0 do dup pinout 1+ loop drop             \ Set pins to output
_res pinlo _res pinhi                             \ Reset chip
init_ST7565                                       \ Initialize ST7565
clr_scrn                                          \ Clear buffer and DDRAM
DispOn command wr_st7565                          \ Display on
;

\ Display 8x8font 
\ ( -- )
: demo1
init_LCD
1 font_type W!           \ 8x8font      
0 x W!                   \ 0 <= x <= 15
0 y W!                   \ 0 <= y <= 7
h20 
begin
     dup                             
     x W@ y W@ lcd_char_8x8           
     \ Update char_x
     x W@ 1+ dup d16 = 
     if 
          drop 0 
          \ Update char_y 
          y W@ 1+ dup 8 = 
          if drop 0 then
          y W!
     then
     x W!                  
     1+                    
     dup d128 =                 
     if drop h20 then
     d100 delms
     fkey? swap drop
until
drop
poweroff
;

\ Display propfont 
\ ( -- )
: demo2
init_LCD
0 font_type W!           \ propfont      
0 x W!                   \ 0 <= x <= 7
0 y W!                   \ 0 <= y <= 1
0 
begin
     dup                          
     x W@ y W@ lcd_char_prop      
     \ Update char_x
     x W@ 1+ dup 8 = 
     if 
          drop 0 
          \ Update char_y 
          y W@ 1+ dup 2 = 
          if drop 0 then
          y W!
     then
     x W!
     1+
     dup d256 =
     if drop 0 then              
     fkey? swap drop
until
drop
poweroff
;

\ Display string and move it down
\ ( -- )
: demo3
init_LCD
0 font_type W!           \ propfont      
0 x W!
0 y W!
c" PF5.5" lcd_string
d1000 delms
Reverse_disp
d1000 delms
Normal_disp
d64
begin
     1- dup Start_Line or command wr_st7565
     dup 0= if drop d64 then
     d100 delms
     fkey? swap drop
until
drop
poweroff     
;
