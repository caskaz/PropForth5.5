fl

{
PropForth 5.5(DevKernel)
HDSP-2121

2018/01/18 11:32:36

         HDSP-2121
          --------
P14 ---- |RST   D7| ---- P7
P15 ---- |FL    D6| ---- P6
P8  ---- |A0    D5| ---- P5
P9  ---- |A1    D4| ---- P4
P10 ---- |A2    D3| ---- P3
P11 ---- |A3    D2| ---- P2
         |      D1| ---- P1
P12 ---- |A4    D0| ---- P0
5V  ---- |CLS   RD| ---- P17
         |      CE| ---- P16
P13 ---- |WR   GND| ---- GND
5V  ---- |Vdd  GND| ---- GND
          --------

}


\ ==================================================================
\ Constants
\ ================================================================== 
0 wconstant D0
hFF D0 lshift invert constant datam
8 wconstant A0
h1F A0 lshift invert constant addrm
d13 wconstant WR
d14 wconstant RST
d15 wconstant FL
d16 wconstant CE
d17 wconstant RD

\ UDC
variable udc -4 allot 
h00 c, h00 c, h00 c, h00 c, h00 c, h00 c, h00 c,
h00 c, h00 c, h00 c, h00 c, h00 c, h00 c, h1F c,
h00 c, h00 c, h00 c, h00 c, h00 c, h1F c, h1F c,
h00 c, h00 c, h00 c, h00 c, h1F c, h1F c, h1F c,
h00 c, h00 c, h00 c, h1F c, h1F c, h1F c, h1F c,
h00 c, h00 c, h1F c, h1F c, h1F c, h1F c, h1F c,
h00 c, h1F c, h1F c, h1F c, h1F c, h1F c, h1F c,
h1F c, h1F c, h1F c, h1F c, h1F c, h1F c, h1F c,

\ ==================================================================
\ Variables
\ ================================================================== 
\ 1st-byte:char-number  2nd-27th:string character
variable buffer d31 allot

\ ==================================================================
\ Main
\ ================================================================== 

\ Initialize ports
\ ( -- )
: init
D0 d17 0 do dup pinout 1+ loop drop
CE pinhi              
WR pinhi 
FL pinhi
RST pinhi RST pinlo 1 delms RST pinhi
;

{
: test
init
outa COG@ addrm and h18 A0 lshift or outa COG!
CE pinlo WR pinlo WR pinhi CE pinhi
outa COG@ datam and h10 D0 lshift or outa COG!
CE pinlo WR pinlo WR pinhi CE pinhi
; 
}

\ Write operation
\ ( -- )
: wr CE pinlo WR pinlo WR pinhi CE pinhi ;

\ Set address
\ ( n1 n2 -- ) Character/UDC n1:7SEG-position[0..7] n2:h18
\ Control word  n1:h10 n2:0
: setAddr or A0 lshift outa COG@ addrm and or outa COG! ;

\ Set character-address
\ ( n1 -- )  n1:7SEG-position[0..7]
: setRAMaddr h18 setAddr ;

\ Set character data
\ ( n1 -- ) n1:ACII code
: setCharData D0 lshift outa COG@ datam and or outa COG! wr ;

\ Get data
\ ( -- n1 ) n1:data
: getData CE pinlo RD pinlo ina COG@ RD pinhi CE pinhi D0 rshift hFF and ;

\ Convert char-code to HDSP-2121
\ ( n1 -- n2 )  n1:char-code(Only ASCII code)  n2:converted code
: convCode 
h20 over h40 < 
if 
     - 
else 
     over h3F > if + else drop then
then 
;

\ Print ASCII character
\ ( n1 n2 -- ) n1:character-code n1:7SEG-position[0..7]
: prtASCII setRAMaddr convCode setCharData ;

\ Print katakana
\ ( n1 n2 -- ) n1:character-code n1:7SEG-position[0..7]
: prtKatakana setRAMaddr setCharData ;

\ test
\ ( -- )
: test
h48 0 prtASCII
h44 1 prtASCII
h53 2 prtASCII
h50 3 prtASCII
h32 4 prtASCII
h31 5 prtASCII
h32 6 prtASCII
h31 7 prtASCII
;
\ Clear all 7SEG-LEDs
\ ( -- )
: allClr 8 0 do i setRAMaddr 0 setCharData loop ;

\ Clear buffer
\ ( -- )
: clrbufASCII buffer d36 0 do h20 buffer i + C! loop drop ;
 
\ Print all characters
\ ( -- )
: prtALL d128 0 do i i 8 u/mod drop setRAMaddr setCharData d100 delms loop ;

\ Copy strings for ASCII-code(max 26characters) in buffer  c" MAY THE FORTH BE WITH YOU." copyASCII
\ ( n1 -- )  n1:cstr
: copyASCII
clrbufASCII
dup C@ dup d26 >                   \ ( addr[cstr] [str_length] 1/0 )
if drop d26 then
buffer C! 1+                       \ ( addr[cstr+1] ) 
buffer 1+ buffer C@ bounds do 
     dup C@ i C! 1+ 
loop 
drop
;

\ Print string inside buffer on 7SEG-LED
\ ( -- )
: prtbufASCII
buffer C@ 8 >
if
     \ more than 9 characters
     buffer dup C@ 1+ swap 1+ swap bounds  \ ( addr[cstr+1+str_length] addr[cstr+1] ) 
     do
          i 
          8 0 do 
               dup C@ i setRAMaddr convCode setCharData d20 delms 1+
          loop drop
          d80 delms
     loop     
else
     \ less than 8 characters
     allClr     
     buffer dup C@ 0 do
          dup 1+ C@ i setRAMaddr convCode setCharData d20 delms 1+ 
     loop
     drop
then
;

\ Define UDC from h80 to h87
\ ( -- )  
: defineUDC
d14 0 do
     0 0 setAddr                             \ Set UDC address register address
     i setCharData                           \ Set UDC address(7SEG LED position)
     \ Set data for each row in each UDC
     i 8 <
     if
          7 0 do
               i 8 or 0 setAddr                   \ Set each row
               udc j 7 * + i + C@ setCharData     \ Set data for row
          loop 
     else
          7 0 do
               i 8 or 0 setAddr                   \ Set each row
               udc j j 7 - 2* - 7 * +           \ udc+(j-(j-7)*2)*7
               i + C@ setCharData                 \ Set data for row
          loop 
     then                                                 
loop

;

\ wave
\ ( -- )
: wave
defineUDC
h80                                               \ initial UDC code
d130 0 do
     dup
     \ Print wave-character for 7SEG LEDs
     8 0 do
          i setRAMaddr dup setCharData            \ Print character
          1+ dup h8E = if drop h80 then
          d10 delms
     loop
     drop
  
     \ Set next character on start position(left)
     1+ dup h8E = if drop h80 then
loop
drop
;


\ ( -- )
: demo
init
prtALL
test d500 delms
c" TEST" copyASCII
prtbufASCII d500 delms
c" MAY THE FORTH BE WITH YOU." copyASCII
prtbufASCII

defineUDC                                        
{
0 setRAMaddr h80 setCharData
0 setRAMaddr h81 setCharData
0 setRAMaddr h82 setCharData
0 setRAMaddr h83 setCharData
0 setRAMaddr h84 setCharData
0 setRAMaddr h85 setCharData
0 setRAMaddr h86 setCharData
0 setRAMaddr h87 setCharData

0 setRAMaddr h88 setCharData
0 setRAMaddr h89 setCharData
0 setRAMaddr h8A setCharData
0 setRAMaddr h8B setCharData
0 setRAMaddr h8C setCharData
0 setRAMaddr h8D setCharData
}
wave
\ Brightness
test
8 0 do 
     h10 0 setAddr i setCharData 
     d500 delms
loop
h10 0 setAddr 0 setCharData 
d500 delms    
\ Blinking
c" BLINK" copyASCII
prtbufASCII
h10 0 setAddr h10 setCharData d2000 delms    \ Set ENABLE-BLINK bit
h10 0 setAddr 0 setCharData

\ Flash
test
d500 delms
h10 0 setAddr 8 setCharData   \ Set ENABLE-FLASH bit 
8 0 do
     FL pinlo i 0 setAddr  1 setCharData FL pinhi     
     d500 delms
loop
d500 delms
h10 0 setAddr 0 setCharData        \ Reset ENABLE-FLASH bit
;


{
: selftest
c" SELFTEST" copyASCII
prtbufASCII  d500 delms
h10 0 setAddr h40 setCharData  
;




}
