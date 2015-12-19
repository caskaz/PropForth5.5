fl
                                                                        
{
128x64 LCD with SPI(controller:ST7567)
   
2015/02/09 20:59:00
           
     LCD(128x64) Propeller
      CS   -----  P0
      SDA  -----  P1
      SCLK -----  P2
      A0   -----  P3 
      RST  -----  P5
      3.3V -----  3.3V 
      0V   -----  0V
      
      The read functions is not available in serial interface mode.
}

\ 128x64dots buffer[128x64/8bytes]
\ Execute before loading this file
{
reboot
...
...
Prop0 Cog6 ok
variable buffer d508 allot
Prop0 Cog6 ok
buffer .
17608 Prop0 Cog6 ok
d17608 d1024 + here W!
Prop0 Cog6 ok
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
1 wconstant _sda
2 wconstant _sclk
3 wconstant _a0
4 wconstant _rst

\ --- command ---
hAF wconstant DispOn          \ Display ON
hAE wconstant DispOff         \ Display OFF
h40 wconstant Set_Line        \ Set start Line
hB0 wconstant Set_Page        \ Set Page Address
h10 wconstant Set_Col_MSB     \ Set Column Address(MSB)
h00 wconstant Set_Col_LSB     \ Set Column Address(LSB)
hA0 wconstant SEG_dir         \ SEG Direction
hA6 wconstant Normal          \ Normal Display
hA7 wconstant Inverse         \ Inverse Display
hA4 wconstant Pixel_off       \ Normal Display
hA5 wconstant Pixel_on        \ All Pixel On
hA2 wconstant Bias            \ Bias Select
hE0 wconstant R_M_W           \ Read-modify-Write
hEE wconstant END             \ End "Read-modify-Write"
hE2 wconstant soft_RST        \ Reset
hC0 wconstant COM_dir         \ COM Direction
h2F wconstant PWR_ctl         \ Power Control(VB=VR=VF=1)
h20 wconstant reguration      \ Reguration Ratio
h81 wconstant Set_EV          \ Set EV
hF8 wconstant Set_boost
hE3 wconstant NOP

0 wconstant data
1 wconstant command

\ -------------------------------------------------------
\ Variables
\ -------------------------------------------------------
wvariable page
wvariable row_in_page
wvariable column
wvariable char_x
wvariable char_y
variable odd
variable row_line
wvariable font_kind

\ -------------------------------------------------------
\ Main
\ -------------------------------------------------------

\ Execute before power-off
\ Power off
\ ( -- )
: poweroff
_rst pinlo 100 delms _rst pinhi
d250 delms
;

\ Write data/command to ST7567
\ ( n1 n2 -- )  n1:value  n2:data/command 
: wr_st7567
\ Set cs to lo
_cs pinlo
\ Set A0 to lo if command
if 
     _a0 pinlo                \ command
else
     _a0 pinhi                \ data
then
h80
8 0 do
     _sclk pinlo              \ Set sclk to lo
     2dup and 
     if
          _sda pinhi          \ Set sda to hi
     else   
          _sda pinlo          \ Set sda to lo
     then
     _sclk pinhi              \ Set sclk to hi
     1 rshift                 \ next bit
loop
2drop
_cs pinhi 
;

\ Adjustment for contrast
\ Write value to Set_EV
\ ( n1 -- )  n1:value   
: contrast
Set_EV command wr_st7567
command wr_st7567
;

\ Normal display
\ When writing "1", dot is black.[Background:white]
\ ( -- )
: Normal_disp
Pixel_off command wr_st7567
Inverse command wr_st7567
;

\ Reverse display
\ When writing "1", dot is white.[Background:black]
: Reverse_disp
Pixel_off command wr_st7567
Normal command wr_st7567
;

\ Initialize LCD(128x64)
\ ( -- )
: init_ST7567 
soft_RST command wr_st7567
Bias 1 or command wr_st7567
SEG_dir command wr_st7567
COM_dir 8 or command wr_st7567
reguration 4 or command wr_st7567
d25 contrast
PWR_ctl command wr_st7567
Set_Line command wr_st7567
Set_Page command wr_st7567
Set_Col_MSB command wr_st7567
Set_Col_LSB command wr_st7567
Normal_disp
\ Reverse_disp
;

\ Write 1-character[8x8] to buffer
\ 8x8-FONT on (0,0)-(15,7)[char_x,char_y]
\ ( n1 n2 n3 -- )  n1:character  n2:x-position[0 - 15] n3:y-position[0 - 7]
: lcd_char_8x8
d128 u*                            \ y * 128
swap 8 u*                          \ x * 8
+ buffer +                         \ Get buffer's address
swap                               \ ( buffer-address character )
                                    
\  Get 8x8-character                            
h20 - 8 u* Font +                  \ Get Font address
\ Copy character to buffer         \ ( buffer-address Font-address )
8 0 do
     2dup                          \ ( buffer-address Font-address buffer-address Font-address )
     C@ swap C!                    \ Copy font-data to buffer
     1+ swap 1+ swap               \ ( buffer-address+1 Font-address+1 )
loop
2drop 
;

\ Get prop-character 
{
                Even-character is even-bits. (bit30,28,26,24,....4,2,0)
address          column ----->          
row  n          b31 b30 b29 . . . b1  b0
 |   n+4         0   0   0        0   0
 |   .
 |   .
\|/  n+d124      0   0   0        0   0
 
}
\ row_line n      --> character's top
\ row_line n+d124 --> character's bottom
\ ( n1 n2 -- )  n1:buffer-address  n2:character code
: prop_char
dup 1 and if 2 else 1 then odd L!       \ Check even/odd
hFE and
d64 u* h8000 +                          \ Get ROM Font address
                                        \ character for ROM font occupy 64bytes(character include even/odd-characters)
\ column=16bits
d16 0 do
     dup                                               \ ( buffer-address font-address font-address )
    
     d32 0 do
          row_line L@ 1 rshift row_line L!             \ Shift row_line to right
          dup L@ odd L@                                \ ( buffer-address font-address font-address data odd )
          and                                          \ ( buffer-address font-address font-address t/f )          
          if 
               row_line L@ h80000000 or row_line L!    \ Update bit-data of row_line 
          then                                         \ ( buffer-address font-address font-address )
          \ Add 4 to font-address   ( to next row )       
          4 +                                          \ ( buffer-address font-address font-address+4 )
     loop     
     drop
     
     \ --- Copy 32bit-data to buffer ---
     swap                                              \ ( font-address buffer-address )
     dup                                               \ ( font-address buffer-address buffer-address )
     4 0 do
          dup                                          \ ( font-address buffer-address buffer-address buffer-address )
          i row_line + C@ 
          swap C!                                      \ Save data to vram
          d128 +                                       \ ( font-address buffer-address buffer-address+128 )
     loop
     drop 1+                                           \  ( font-address buffer-address+1)
     swap                                              \ ( buffer-address font-address )
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
2drop
;

\ Write 1-character[ROM-FONT] to buffer
\ ROM-FONT on (0,0)-(7,3) [char_x,char_y]
\ ( n1 n2 n3 -- )  n1:character  n2:x-position[0 - 7] n3:y-position[0 - 3]
: lcd_char_prop
d512 u*                            \ y * 528(32lines)
swap d16 u*                        \ x * 16
+ buffer +                         \ Get buffer's address
swap                               \ ( buffer-address character )
prop_char
;


\ Print 1-character and update only char_x
\ ( n1 -- )  n1:character code
: print
char_x W@ char_y W@ 
font_kind W@
if
     lcd_char_8x8
else
     lcd_char_prop
then             
\ update char_x
char_x W@ 1+ char_x W!
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

\ Clear buffer and DDRAM
\ ( -- )
: clr_scrn
\ Clear buffer
d256 0 do
     0 i 4 u* buffer + L!
loop
\ Clear DDRAM
8 0 do
     i Set_Page or command wr_st7567
     Set_Col_MSB command wr_st7567
     Set_Col_LSB command wr_st7567
     d128 0 do
          0 data wr_st7567
     loop
loop    
;

\ Copy buffer to LCD's DDRAM
\ ( -- )
: disp_LCD
buffer
8 0 do
     i Set_Page or command wr_st7567
     Set_Col_MSB command wr_st7567
     Set_Col_LSB command wr_st7567
     d128 0 do
          dup                           \ ( buffer buffer )
          C@ data wr_st7567             \ ( buffer )
          1+                            \ ( buffer+1 )
     loop
loop 
drop   
;

\ initial setting
\ ( -- )
: init_LCD
_cs 5 0 do dup dup pinhi pinout 1+ loop drop      \ Set pin to output and to hi
_rst pinlo _rst pinhi                             \ Reset chip
init_ST7567                                       \ Initialize ST7567
clr_scrn                                          \ Clear buffer and DDRAM
DispOn command wr_st7567                          \ Display on
;

\ Display 8x8font 
\ ( -- )
: demo1
init_LCD
1 font_kind W!           \ 8x8font      
0 char_x W!         \ 0 <= x <= 15
0 char_y W!         \ 0 <= y <= 7
h20 
begin
     dup
     char_x W@ char_y W@ lcd_char_8x8
     \ Update char_x
     char_x W@ 1+ dup d16 = 
     if 
          drop 0 
          \ Update char_y 
          char_y W@ 1+ dup 8 = 
          if drop 0 then
          char_y W!
     then
     char_x W!
     1+
     dup d128 =
     if drop h20 then
     \ Copy buffer to DDRAM
     disp_LCD
     fkey? swap drop
until
drop
poweroff
;

\ Display propfont 
\ ( -- )
: demo2
init_LCD
0 font_kind W!           \ propfont      
0 char_x W!         \ 0 <= x <= 7
0 char_y W!         \ 0 <= y <= 1
0 
begin
     dup
     char_x W@ char_y W@ lcd_char_prop
     \ Update char_x
     char_x W@ 1+ dup 8 = 
     if 
          drop 0 
          \ Update char_y 
          char_y W@ 1+ dup 2 = 
          if drop 0 then
          char_y W!
     then
     char_x W!
     1+
     dup d256 =
     if drop 0 then
     \ Copy buffer to DDRAM
     disp_LCD
     fkey? swap drop
until
drop
poweroff
;

\ Display string and move it down
\ ( -- )
: demo3
init_LCD
0 font_kind W!           \ propfont      
0 char_x W!
0 char_y W!
c" PF5.5" lcd_string
disp_LCD
d1000 delms
Reverse_disp
d1000 delms
Normal_disp
d63
begin
     1- dup Set_Line or command wr_st7567
     dup 0= if drop d63 then
     d100 delms
     fkey? swap drop
until
drop
poweroff     
;
