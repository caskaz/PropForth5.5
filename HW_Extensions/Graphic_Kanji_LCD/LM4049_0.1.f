fl

{                       
PropForth 5.5(DevKernel)

Module LM4049
Graphic & kanji LCD Display(Controller:HD66732)
2016/12/07 14:27:19

          LM4049
            Vss  --- GND     GND
            Vdd  --- 3.3V     |
Propeller   Vo   ------------VR(50kohm)
   P0 ----- RS                |
   P1 ----- RW                |
   P2 ----- E                 |
   P3 ----- DB0               |
   P4 ----- DB1               |
   P5 ----- DB2               |
   P6 ----- DB3               |
   P7 ----- DB4               |
   P8 ----- DB5               |
   P9 ----- DB6               |
   P10 ---- DB7               |
            NC                |
   P11 ---- RESET             |
            VEE  --------------          
            LED+ --- 3.3V
            LED- --- GND

Using free area(here W@) as graphic buffer

Module LM4049 use 68-syastem parallel bus as I/F.
This module cannot use contrast register

}

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
\ Pin
0 wconstant RS
1 wconstant RW
2 wconstant E
3 wconstant DB0
d11 wconstant RST
hFF DB0 lshift invert constant DBm  
\ character property 
0 wconstant normal
1 wconstant reverse
2 wconstant blink
3 wconstant reverse_blink
 
\ =========================================================================== 
\ Variables 
\ =========================================================================== 
wvariable FCpropaty
wvariable HCpropaty
\ buffer for DDRAM
variable charRAM d76 allot

\ Graphic Line
\ variable RAMbuf d836 allot
d120 wconstant pixel_X
d52 wconstant pixel_Y
wvariable x0
wvariable x1
wvariable y0
wvariable y1
wvariable dx
wvariable dy
variable D
wvariable y
wvariable x

\ =========================================================================== 
\ Main 
\ =========================================================================== 
\ case statemenr
\ ( n1 n2 -- n1 t/f )  return true if n1=n2
: case over = ;

\ Write mode
\ ( -- )
: wrMode RW pinlo ;

\ Read mode
\ ( -- )
: rdMode RW pinhi ;

\ Set register/data/command to DataBus
\ ( n1 -- ) n1:register/data/command
: setDB E pinhi DB0 lshift outa COG@ DBm and or outa COG! E pinlo ;
\  : setDB DB0 lshift E pinhi outa COG@ DBm and or outa COG! E pinlo ;

\ Set register
\ ( n1 -- ) n1:register
: setReg RS pinlo setDB ;

\ Set command or data
\ ( n1 -- ) n1:command or data
: setCom RS pinhi setDB ;

\ Write command
\ ( n1 n2 -- ) n1:command n2:register
: wrCom setReg setCom ;

\ Read RAM
\ ( -- n1 ) n1:data[1byte]
: rdRAM RS pinhi E pinhi E pinlo ina COG@ DB0 rshift hFF and ;

\ Clear character RAM(DDRAM) AdressCounter=0 I/D=1
\ ( -- )
: clrScr 1 0 wrCom ;

\ Set auto-increment on character RAM
\ ( -- )
: autoInc 9 7 wrCom ;

\ Stop auto-increment on character RAM
\ ( -- )
: stopInc hB 7 wrCom ;

\ Set address on character RAM (DDRAM adress[0-h13,h20-h33,h40-h53,h60-h73])
\ ( n1 n2 -- ) n1:x[1-20] n2:y[1-4]
: charPos
0 hD wrCom                                   \ Write DDRAM upper address 
1 case
if
     0                   \ 1st line
else
     2 case
     if
          h20            \ 2nd line
     else
          3 case
          if
               h40       \ 3rd line
          else
               h60       \ 4th line
thens
nip + 1-
hE wrCom                                     \ Write DDRAM lower address
;
     
\ Set address for CGRAM(graphic RAM)
\ ( n1 -- ) n1: address index[0-6] [0-h77,h100-h177,h]
: CGRAMaddr 
h100 * dup
8 rshift h80 or hD wrCom                     \ Write CGRAM upper address 
hFF and hE wrCom                             \ Write CGRAM lower address
;

\ Initialize LM40449 LCD
\ ( -- )
: init
RS d12 0 do dup pinout 1+ loop drop          \ Set port to output
RST pinhi RST pinlo d10 delms RST pinhi      \ Reset LCD( OSC start, DDRAM clear[all hA0] )
1 1 wrCom                                    \ Start OSC
d20 delms
wrMode                                     \ Set write-mode                                          
h42 2 wrCom                                  \ 4charcter line, 1/52 duty, scan-direction
0 3 wrCom                                    \ Selection for LCD drive-wave
h1F 4 wrCom                                  \ 1/8bias, max contrast

 hB0 5 wrCom                                  \ Voltage follower curcuit on, triple boost

\ Clear CGRAM
5 7 wrCom                                    \ Graphic mode
7 0 do
     i CGRAMaddr                             \ Set CGRAM address
     d120 0 do 0 hF wrCom loop               \ Clear CGRAM
loop     
9 7 wrCom                                    \ entry mode[super impose, character mode, auto increment]
1 2 charPos                                  \ Set DDRAM address
8 8 wrCom                                    \ cursol off, address-counter reset
h22 9 wrCom                                  \ Display on, 10digits
;

\ Get HD66732 character code from JIS code(2byte)
\ ( n1 n2 -- n3 ) n1:JIS upper byte code[7bits] n2:JIS lower byte code[7bits]  n3:char_code[13bits]
: KanjiCode
over dup 4 rshift            
2 case                                  
if
     drop
     \ Non Kanji
     7 and 7 lshift swap                     \ Convert JIS upper byte code
     dup h1F and swap h60 and 5 lshift or    \ Convert JIS lower byte code
     or
else
     3 case                                
     if
          drop
          \ JIS Level1 Kanji 1st
          dup 6 rshift 4 lshift swap hF and or 7 lshift     \ Convert JIS upper byte code
          or              
     else
          4 case                                            
          if                                                    
               drop                                                  
               \ JIS Level1 Kanji 2nd
               dup 6 rshift 4 lshift swap hF and or 7 lshift     \ Convert JIS upper byte code
               or              
          else
               5 case
               if
                    drop
                    \ JIS Level2 Kanji 1st
                    dup 5 rshift 4 lshift swap hF and or 7 lshift     \ Convert JIS upper byte code
                    or
               else
                    6 case
                    if
                         drop
                         \ JIS Level1 Kanji 2nd
                         dup 5 rshift 4 lshift swap hF and or    \ Convert JIS upper byte code
                         or
                    else
                         drop
                         \ JIS Level1 Kanji 3rd
                         7 and 7 lshift swap                     \ Convert JIS upper byte code
                         dup h1F and swap h60 and 5 lshift or    \ Convert JIS lower byte code
                         or
thens               
nip
;

\ Print Full size character on DDRAM
\ ( n1 n2 -- ) n1:JIS upper byte code[7bits] n2:JIS lower byte code[7bits]
: FCGROM
KanjiCode
dup 
hFF and hF wrCom              \ Write lower byte
8 rshift                      \ Full size char: msb=0
FCpropaty W@ 5 lshift or      \ Add property
hF wrCom                      \ Write upper byte
;

\ Select Half size ROM on each line
\ ( n1 --) n1:bit3-bit0[line4-line1]   ROM0:0 ROM1:1
: selectHalfSizeROM hB swap wrCom ;

\ Set property to Half character line[0,1,2,3]
\ ( n1 n2 n3 n4 -- ) n1:4th line n2:3rd line n3:2nd line n4:1st line
: setProperty swap 2 lshift or swap 4 lshift or swap 6 lshift or hC wrCom ;

\ Print half size character on DDRAM
\ ( n1 -- ) n1:character code[7bits]
: HCGROM h80 or hF wrCom ; \   outa COG@ DBm and outa COG! ;    \                

\ Print 7bit character to DDRAM
\ ( n1 -- ) n1:7bit character code
: HC_str C@++ bounds do i C@ HCGROM loop ;

\ Clear DDRAM buffer
\ ( -- )
: clrRAM charRAM d20 0 do hA0A0A0A0 over L! 4+ loop drop ;

\ Shift charRAM to 1-char(Kanji:2byte) left
\ ( -- )
: shiftKanji
charRAM
4 0 do 
     dup i d20 * +       \ Get top address of each line  ( n1 n1*(i*20) )
     9 0 do
          dup            \ ( n1 n1*(i*20) n1*(i*20) )
          2+ W@ over W!  \ address)<--(address+2)<--(address+4)<--..<--(address+18)
          2+             \ ( n1 n1*(i*20)+2 )          
     loop
     drop                \ ( n1 ) 
loop
drop
; 

\ Scan charRAM only 1 time
\ ( -- )
: scanRAM
charRAM     
5 1 do                        \ scanning y
     1 i charPos              \ Set position(x=1 y=line)          
     d20 0 do                 \ scanning x
          dup C@ hF wrCom
          1+    
     loop
loop
drop 
;

\ にゃ～ん文字列
wvariable string -2 allot 
hE13 w, h881 w, hE03 w, hA0B w, 
hA0A0 w, hE13 w, h881 w, hE03 w, 
hA0B w, hA0A0 w, hE13 w, h881 w, 
hE03 w, hA0B w, hA0A0 w, hE13 w, 
h881 w, hE03 w, hA0B w, hA0A0 w, 

\ Update LCD screen
\ ( -- )
: updateLCD scanRAM d500 delms shiftKanji scanRAM ;

\ Save character to each line's left edge on LCD screen
\ ( -- )
: 1LineLeft charRAM d18 + W! ;
: 2LineLeft charRAM d38 + W! ;
: 3LineLeft charRAM d58 + W! ;
: 4LineLeft charRAM d78 + W! ;

\ Display JIS-code(kanji,katakana,hiragana) and 7bit-character
\ ( -- )                                            
: demo1
init
d500 delms
1 1 charPos
h25 h47 FCGROM      \ デ
h25 h38 FCGROM      \ ジ
h25 h43 FCGROM      \ ッ
h25 h48 FCGROM      \ ト
\ Full-size & Half-size chaeacter on 1 line
1 2 charPos
h23 h48 FCGROM      \ H
h48 HCGROM          \ D
h23 h36 FCGROM      \ 6
h36 HCGROM          \ 6
h23 h37 FCGROM      \ 7
h33 HCGROM          \ 3
h23 h32 FCGROM      \ 2
d1000 delms
\ Half-size character string
1 2 charPos d14 0 do h20 HCGROM loop
1 2 charPos c" HD66732" HC_str
d1000 delms

1 3 charPos
h25 h30 FCGROM      \ グ
h25 h69 FCGROM      \ ラ
h25 h55 FCGROM      \ フ
h25 h23 FCGROM      \ ィ
h25 h43 FCGROM      \ ッ
h25 h2F FCGROM      \ ク
h21 h75 FCGROM      \ ＆
h34 h41 FCGROM      \ 漢
h3B h7A FCGROM      \ 字
1 4 charPos
h23 h50 FCGROM      \ P
h23 h72 FCGROM      \ r
h23 h6F FCGROM      \ o
h23 h70 FCGROM      \ p
h23 h46 FCGROM      \ F
h23 h6F FCGROM      \ o
h23 h72 FCGROM      \ r
h23 h74 FCGROM      \ t
h23 h68 FCGROM      \ h
d2000 delms
\ Changing attribute
1 FCpropaty W! 1 1 charPos h25 h47 FCGROM d1000 delms
0 FCpropaty W! 1 1 charPos h25 h47 FCGROM
2 FCpropaty W! 3 1 charPos h25 h38 FCGROM d1000 delms
0 FCpropaty W! 3 1 charPos h25 h38 FCGROM
3 FCpropaty W! 5 1 charPos h25 h43 FCGROM d1000 delms
0 FCpropaty W! 5 1 charPos h25 h43 FCGROM
\ Chenging attribute
1 FCpropaty W!
1 1 charPos
h25 h47 FCGROM      \ デ
h25 h38 FCGROM      \ ジ
h25 h43 FCGROM      \ ッ
h25 h48 FCGROM      \ ト
d2000 delms
1 1 charPos
h25 h47 FCGROM      \ デ
h25 h38 FCGROM      \ ジ
h25 h43 FCGROM      \ ッ
h25 h48 FCGROM      \ ト

\ Vertical scroll
2 0 do
     4 0 do
          d13 0 do j d16 * i + hA wrCom d200 delms loop
     loop
loop
0 FCpropaty W!
1 1 charPos
h25 h47 FCGROM      \ デ
h25 h38 FCGROM      \ ジ
h25 h43 FCGROM      \ ッ
h25 h48 FCGROM      \ ト

clrScr  d20 delms
h60A charRAM W!
hA03 charRAM 2+ W!
hA11 charRAM 4+ W!
h604 charRAM 6 + W!
d2000 delms
clrRAM
     
hA0B 1LineLeft
updateLCD
hE03 1LineLeft
hA0B 2LineLeft
updateLCD
h881 1LineLeft
hE03 2LineLeft
hA0B 3LineLeft
updateLCD 

d10 0 do
     string 
     5 0 do        
          dup         
          W@ 1LineLeft
          dup 2+ W@ 2LineLeft
          dup 4+ W@ 3LineLeft
          dup 6 + W@ 4LineLeft
          updateLCD
          8 +     
     loop
     drop
loop
;

\ Display 20 Full-size character code and continue when hitting space-key 
\ Break this when hitting except for space-key
\ ( n1 -- )  n1:character code
: dispFC
hex
begin
     clrScr d20 delms
     \ Print character code
     ." Starting Character code:h" dup . cr
     dup dup                            \ ( n1 n1 n1 )
     d40 + swap do 
          i dup 
          hFF and hF wrCom              \ Write lower byte
          8 rshift                      \ Full size char: msb=0
          FCpropaty W@ 5 lshift or      \ Add property
          hF wrCom                      \ Write upper byte
     loop                               \ ( n1 )
     \ Wait until hitting any key
     begin fkey? 0= if drop 0 else 1 then until
     \ Check space-key
     h20 = 
     if 
          d40 +                         \ nect code
          dup h2000 and                 \ Check if exceed h1FFF 
          if drop 1 else 0 then
     else 
          drop 1 
     then     
until
decimal
;

\ Display Full-size character[h2F0-h1FFF]
\ ( -- )
: demo2 init h2F0 dispFC ;

\ Display Half-size character[h0-h7F]
\ ( -- )
: demo3
init
hex
0
2 0 do                                  \ ( n1 )
     clrScr d20 delms                          
     \ Print character code
     ." Starting Character code:h" dup . cr
     5 1 do
          1 i charPos
          dup dup                       \ ( n1 n1 n1 )
          d16 + swap do 
               i HCGROM                 \ ( n1 )
          loop
          d16 +                         \ next code
     loop
     \ Wait until hitting any key
     begin fkey? 0= if 0 else 1 then nip until
     d16 +                              \ next code
loop

drop
decimal
;

\ Clear RAMbuf
\ ( -- )
: clrRAMbuf here W@ d210 0 do dup 0 swap L! 4+ loop drop ;

\    here W@   ----------------------------------------
\       0     |(0,0)                     (pixel_X-1, 0)|
\       |     |                                        | total bytes = pixel_X x pixel_Y/8 
\     y |     |               (x,y)                    |     
\       |     |                                        |
\       |     |(0,pixel_Y-1)     (pixel_X-1, pixel_Y-1)|
\   pixel_Y-1  ----------------------------------------
\
\       y    0 ---------------------------------- pixel_X - 1
\                         x
\ Calculate GraphicMemory address from (x,y)
\ ( n1 n2 -- n3 )  n1:x n2:y  n3:address
: GetAddr
8 u/ pixel_X u*          \ vertical direction
swap 
+ here W@ +              \ Get address
;

\ Set/Clear dot at (x,y)
\ ( n1 n2 n3 -- )  n1:1=putPixel 0=clearPixel  n2:x  n3:y
: setPixel
dup >r                        \ Push y  ( n1 n2 n3 )
GetAddr dup                   \ Get address  ( n1 address address )
C@                            \ Get byte  ( n1 address byte )
r> 8 u/mod drop 1 swap lshift   \ Get bit data  ( n1 address byte bit-data )
3 ST@                   
if or else hFF xor and then   \ Set or clear bit ( n1 address byte )
swap C!
drop
;

\ Plot line
\ ( n1 n2 -- )  n1:x1 n2:x0
: plotLine
1+                            \ Pop x0 and x1   ( n1 n4 n5+1 )
do                            \ Loop from x0+1 to x1  ( n1 )
     D L@ 0>
     if
          dup i y W@ 1+ dup y W! setPixel
          D L@ 
          dy W@ 2* dx W@ 2* - 
          + D L!                   \ D=D+(2*dy-2*dx)
     else
          dup i y W@ setPixel
          D L@ dy W@ 2* + D L!     \ D=D+(2*dy)
     then
loop
drop
;

\ Bresenham's line algorithm
\ Draw straight line from (x0,y0) to (x1,y1)  [x0 < x1, y0 < y1]
\ ( n1 n2 n3 n4 n5 -- )    n1:1=putPixel 0=clearPixel n2:y1  n3:y0  n4:x1  n5:x0
: DrawLine
2 ST@ y W!                    \ y <- y0 
dup x W!                      \ x <- x0  
4 ST@  1 ST@ 4 ST@ setPixel   \ Put/clear (x0,y0)  
2dup >r >r                    \ Push x0 and x1  
2 ST@ >r 3 ST@ >r             \ Push y0 and y1 
- dx W!                       \ Get differense for x
- dy W!                       \ Get differense for y
dx W@ dy W@ >                    
if 
     r> r> 2drop r> r>
     dy W@ 2* dx W@ - D L! 
     1+                                 \ Pop x0 and x1   ( n1 n4 n5+1 )
          do                            \ Loop from x0+1 to x1  ( n1 )
               D L@ 0>
               if
                    dup i y W@ 1+ dup y W! setPixel
                    D L@ 
                    dy W@ 2* dx W@ 2* - 
                    + D L!              \ D=D+(2*dy-2*dx)
               else
               dup i y W@ setPixel
               D L@ dy W@ 2* + D L!     \ D=D+(2*dy)
               then
          loop
else
     r> r> r> r> 2drop
     dx W@ dy W@ dx W! dy W!
     1+                                 \ Pop x0 and x1   ( n1 n4 n5+1 )
          do                            \ Loop from x0+1 to x1  ( n1 )
               D L@ 0>
               if
                    dup i y W@ 1+ dup y W! swap setPixel
                    D L@ 
                    dy W@ 2* dx W@ 2* - 
                    + D L!              \ D=D+(2*dy-2*dx)
               else
               dup i y W@ swap setPixel
               D L@ dy W@ 2* + D L!     \ D=D+(2*dy)
               then
          loop
then                      
drop
;

\ Copy RAMbuf to CGRAM
\ ( -- )
: copyRAM
\ RAMbuf
here W@
7 0 do
     i CGRAMaddr              \ Set CGRAM address
     d120 0 do
          dup C@ hF wrCom     \ Write daita to CGRAM
          1+                  \ Increment RAMbuf addres 
     loop
loop
drop
;

\ Display plotting line and character
\ ( -- )           
: demo4
init
clrRAMbuf           
5 7 wrCom                          \ entry mode[graphic mode, auto increment]
1 0 0 119 0 DrawLine 
1 8 0 d119 0 DrawLine
1 d16 0 d119 0 DrawLine
1 d24 0 d119 0 DrawLine
1 d32 0 d119 0 DrawLine
1 d40 0 d119 0 DrawLine
1 d48 0 d119 0 DrawLine
1 d51 0 d119 0 DrawLine
1 d51 0 d20 0 DrawLine
1 d51 0 d40 0 DrawLine
1 d51 0 d60 0 DrawLine
1 d51 0 d80 0 DrawLine
1 d51 0 d110 0 DrawLine
1 d51 0 d119 0 DrawLine
1 d51 0 0 0 DrawLine
copyRAM
1 4 charPos c" PropForth5.5" HC_str
d1000 delms                        \ Needing time-wait when switching mode
9 7 wrCom                          \ entry mode[super impose, character mode, auto increment]
d4000 delms                        \ Needing time-wait when switching mode
1 7 wrCom                          \ entry mode[character mode, auto increment]
;

