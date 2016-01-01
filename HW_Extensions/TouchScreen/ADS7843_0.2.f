fl

{
TouchScreen Controller(ADS7843)
PropForth5.5

2016/01/01 11:21:30

           ----------------             
    3V3-- |Vref         Vcc| -- 3V3     -----------
P5 -----> |cs            X+| --------- |           |
P6 -----> |clk           X-| --------- |TouchScreen|
P7 -----> |din  ADS7843  Y+| --------- |           |
P8 <----- |dout          Y-| --------- |           |
     3V3  |                |            -----------
      |   |                |
     10k  |                |
      |   |                |
P9 <----- |PENIRQ          |  
          |           GND  |
           ----------------
                       |
                      GND
TouchPosition(X,Y) is averaged by sampled 8 times.
                      
}


\ -------------------------------------------------------
\ Constants
\ -------------------------------------------------------
5 wconstant cs
6 wconstant clk
7 wconstant din
8 wconstant dout
1 dout lshift constant doutm
9 wconstant penirq
1 penirq lshift constant penirqm
\ A/D selection
9 wconstant Ydata
hD wconstant Xdata
hA wconstant Aux1
hE wconstant Aux2
\ Mode
0 wconstant 12bit
1 wconstant 8bit
\ Single/Differential
0 wconstant diff
1 wconstant single
\ PowerDown selection
0 wconstant enablePD
1 wconstant disablePD
8 wconstant average

\ -------------------------------------------------------
\ Variables
\ -------------------------------------------------------
wvariable cont_X
wvariable cont_Y
wvariable contAux1
wvariable contAux2

\ -------------------------------------------------------
\ Main
\ -------------------------------------------------------

\ Set clk to Hi
\ ( -- )
: clk_h clk pinhi ;

\ Set clk to Lo
\ ( -- )
: clk_l clk pinlo ;

\ Set din to Hi
\ ( -- )
: din_h din pinhi ;

\ Set din to Lo
\ ( -- )
: din_l din pinlo ;

\ Set control byte(X and Y) for TouchScreen 
\ ( n1 n2 n3 -- ) n1:mode n2:single/differential n3:PowerDown
: setTSC
swap 2 lshift or
swap 3 lshift or
dup
Ydata 4 lshift or cont_Y W!
Xdata 4 lshift or cont_X W!
;

\ Set control byte(Aux1 and Aux2) for Aux 
\ ( n1 n2 n3 -- ) n1:mode n2:single/differential n3:PowerDown
: setAux
swap 2 lshift or
swap 3 lshift or
dup
Aux1 4 lshift or contAux1 W!
Aux2 4 lshift or contAux2 W!
;

\ SPI communication
\ ( n1 -- n2 ) n1;control byte  n2:data
: 24bitSPI
cs pinlo
0 swap                                  \ ( 0 n1 )
d16 lshift h800000                      \ ( 0 n1 h800000 )
d24 0 do
     \ transmitt
     2dup                               \ ( 0 n1 h800000 n1 h800000 )
     and
     if din_h else din_l then
     clk_h                              \ Send 1bit to din
     \ receive
     rot                                \ ( n1 h800000 0 )
     ina COG@ doutm and
     if 1 or then 1 lshift rot2         \ Receive 1bit from dout
     clk_l
     1 rshift                              
loop
2drop
1 rshift
cs pinhi
;

\ Get A/D 1data
\ ( n1 -- n2 )  n1;control byte  n2:data
: rdA/D
dup 24bitSPI                            \ ( n1 [received data] )
swap 8 and                              \ ( [received data] 1/0 )
if
     \ 8bit mode
     7 rshift hFF and
else
     \ 12bit mode
     3 rshift hFFF and
then                                    \ ( n2 )
;     
     
\ Get Touch position
\ ( -- n1 n2 ) n1:average value for Y-position  n2:average value for X-position
: rdTouch
0                                       \ initial sum for Y
average 0 do
     cont_Y W@ rdA/D               
     +
loop                                
average u/   
0                                       \ initial sum for X
average 0 do
     cont_X W@ rdA/D               
     +
loop                                
average u/   
;

\ Display (X,Y)
\ ( -- )
: demo
\ Set data for TouchScreenController 
12bit diff enablePD setTSC
\ Set output port
cs pinhi cs pinout clk pinout din pinout

begin
     penirqm penirqm waitpne                 \ Check touch
     rdTouch ." X:" . ." Y:". cr
     fkey? swap drop
until

\ Set data for TouchScreenController 
8bit diff enablePD setTSC
begin
     penirqm penirqm waitpne                 \ Check touch
     rdTouch ." X:" . ." Y:". cr
     fkey? swap drop
until
;






\ Time to get X-position
\ ( -- )         
: test2 cnt COG@ cont_X W@ rdA/D cnt COG@ nip swap - dup . ." ticks  "  d80 u/ . ." usec" ;

