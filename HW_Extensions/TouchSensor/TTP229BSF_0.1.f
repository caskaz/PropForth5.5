fl

{                       
PropForth 5.5(DevKernel)

TouchSensor(TTP229BSF)
2017/03/02 20:20:23

Setting jumper for TTP229BSF board
     TP0=1(open)
     TP1=0(short) 2wire serial I/F:active-Hi
     TP2=0(short) 16inputkeys mode
     TP3=1(open)
     TP4=1(open)
     TP5=1(open)
     TP6=1(open)
     TP7=1(open)

Propeller            TTP229BSF board
     P0  ------------ SDA
     P1  ------------ SCL
                    7SEG-LED(LNM324KS01A)
     P2  ---220ohm--- digit1-a(11)
     P3  ---220ohm--- digit1-b(10)
     P4  ---220ohm--- digit1-c(6)
     P5  ---220ohm--- digit1-d(7)
     P6  ---220ohm--- digit1-e(5)
     P7  ---220ohm--- digit1-f(9)
     P8  ---220ohm--- digit1-g(8)
                      digit1-COM(12) --- GND
     P9  ---220ohm--- digit2-b(15)
     P10 ---220ohm--- digit2-c(3)
                      digit2-COM(13) --- GND     
}

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
0 wconstant sda
1 sda lshift constant msda
1 wconstant scl
2 wconstant 7SEG
h3FF 7SEG lshift constant m7SEG
d40000000 constant 500msec

\ =========================================================================== 
\ Variables 
\ =========================================================================== 
wvariable key
wvariable oldkey 
\ 7SegLED data
variable 7SEG-digit -4 allot
h3F w, 6 w, h5B w, h4F w, h66 w, h6D w, h7D w, 7 w, h7F w,  h6F w,
h1BF w, h186 w, h1DB w, h1CF w, h1E6 w, h1ED w, h1FD w, 

\ =========================================================================== 
\ Main 
\ =========================================================================== 

\ Sense touch-pad
\ ( -- )
: senseKey
d17 1 do
     scl pinhi
     scl pinlo
     ina COG@ msda and  
     if i key W! then
loop
d100 delms
;

\ Clear key
\ ( -- )
: clrKey hFF key W! ;
\ Clear oldkey
\ ( -- )
: clr_oldKey hFF oldkey W! ;

\ Update cnt
\ ( n1 -- n2 )  : n1:old cnt  n2:new cnt
: updateCNT drop cnt COG@ ;

\ Display totch-pad's key on TeraTerm
\ ( -- )
: demo1
\ Initialization
scl pinout  
clr_oldKey             
clrKey

cnt COG@
begin          
     senseKey
     key W@ hFF <>                                \ Check if key sensed
     if
          \ Sensed key          
          key W@ oldkey W@ <>
          if
               key W@ dup . oldkey W! 
          then
          clrKey                                  \ Clear key
          updateCNT
     else
          \ Not sensed key   
          oldkey W@ hFF <>           
          if
               \ Check if it pass 500msec
               cnt COG@ over - 500msec >          
               if
                    clr_oldKey                    \ Clear oldkey 
                    updateCNT
               then
          then
     then
     fkey? swap drop
until
drop
;

\ Display number on 7SEG-LED
\ ( n1 -- ) n1:number
: 7SEG_out 2* 7SEG-digit + W@ 7SEG lshift outa COG! ;

\ Display totch-pad's key on 7SEG-LED
\ ( -- )
: demo2
\ Initialization
m7SEG dira COG!                                   \ 7SEG-LED
scl pinout                                        \ SCL
clr_oldKey             
clrKey
0 outa COG!                                       \ 7SEG-LED off

cnt COG@
begin          
     senseKey
     key W@ hFF <>                                \ Check if key sensed
     if
          \ Sensed key          
          key W@ oldkey W@ <>
          if
               key W@ dup 7SEG_out  oldkey W! 
          then
          clrKey                                  \ Clear key
          updateCNT
     else
          \ Not sensed key
          oldkey W@ hFF <>           
          if
               \ Check if it pass 500msec
               cnt COG@ over - 500msec >          
               if
                    clr_oldKey                    \ Clear oldkey 
                    updateCNT
               then
          then
     then
     fkey? swap drop
until
drop
;
