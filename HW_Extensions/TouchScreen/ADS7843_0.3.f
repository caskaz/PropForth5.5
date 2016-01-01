fl

{
TouchScreen Controller(ADS7843)
PropForth5.5

2016/01/01 12:28:21

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
P10 <---- |busy            |
          |           GND  |
           ----------------
                       |
                      GND
}


\ -------------------------------------------------------
\ Constants
\ -------------------------------------------------------
5 wconstant cs
1 cs lshift constant csm
6 wconstant clk
1 clk lshift constant clkm
7 wconstant din
8 wconstant dout
1 dout lshift constant doutm
9 wconstant penirq
1 penirq lshift constant penirqm
d10 wconstant busy
1 busy lshift constant busym
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
3 wconstant disablePD
8 wconstant average

\ -------------------------------------------------------
\ Variables
\ -------------------------------------------------------
wvariable cont_X
wvariable cont_Y
wvariable posX
wvariable posY
wvariable aveVal

\ -------------------------------------------------------
\ Main
\ -------------------------------------------------------
\ Output clk-pulse
\ ( -- )
: clk_pulse clk pinhi clk pinlo ;

\ Set din to Hi
\ ( -- )
: din_h din pinhi ;

\ Set din to Lo
\ ( -- )
: din_l din pinlo ;

\ Set control byte(X and Y) for ADS7843 
\ ( n1 n2 n3 -- ) n1:mode n2:single/differential n3:PowerDown
: setTSC
swap 2 lshift or
swap 3 lshift or
dup
Ydata 4 lshift or cont_Y W!
Xdata 4 lshift or cont_X W!
;
            
\ Wait until busy fall down
\ ( -- )
: waitBusy
begin ina COG@ busym and until
begin ina COG@ busym and 0= until
;
: waitBusy
busym busym waitpeq           \ Wait until busy goes to Hi
busym busym waitpne           \ Wait until busy goes to Lo
;

\ Read A/D conversion data
\ ( n1 -- n2 )  n1:8 or 12  n2:A/D conversion value
: rdA/D
0                             \ Initial value
swap 0 do
     1 lshift
     clkm clkm waitpeq        \ Wait until clk go to Hi
     ina COG@ doutm and   
     if 1 or then
     clkm clkm waitpne        \ Wait until clk go to Lo
loop
;

\ Get average value
\ ( -- n1 ) n1:average value
: rdTS
begin
     begin ina COG@ csm and 0= until    \ Wait until cs goes to Lo
     0                                  \ Initial average value
     average 0 do
          waitBusy                      \ Wait until busy fall down
          cont_X W@ 8 and               \ Check mode
          if 8 else d12 then
          rdA/D                         \ Get A/D value
          +
     loop
     8 u/ aveVal W!
     begin ina COG@ csm and until       \ Wait until cs goes to Hi
0 until
;

\ Send controlByte(8bit) and only clock-pulse
\ ( n1 -- )  n1:control byte
: sendData
h80
8 0 do
     2dup and
     if din_h else din_l then
     clk_pulse
     1 rshift
loop
2drop
\ Send clock
cont_X W@ 8 and               \ Check mode
if 4 else 8 then
0 do 
     clk_pulse 
     1 1 * drop               \ Dummy delay 
loop                
;

\ Send extra clock
\ ( -- )
: extraCLK  
cont_X W@ 8 and               \ Check mode(8bit or 12bit)
if d12 else d16 then
0 do 
     clk_pulse 
     1 1 * drop               \ Dummy delay 
loop                
;

\ Display (X.Y)
\ Cog6 send control-byte and extra clock and Cog0 read A/D conversion data
\ ( -- )
: demo
\ Set data for TouchScrenn 
12bit diff enablePD setTSC

cs pinhi cs pinout clk pinout din pinout
c" rdTS" 0 cogx

begin
     penirqm penirqm waitpne                 \ Check touch

\ --- X ---          
     cs pinlo                 \ Activate cs
     \ X
     average 0 do
          \ Send control-byte
          cont_X W@ sendData
     loop
     extraCLK
     aveVal W@ posX W!
     cs pinhi                 \ Deactivate cs
     
\ --- Y ---          
     cs pinlo                 \ Activate cs   
     \ Y
     average 0 do
          \ Send control-byte
          cont_Y W@ sendData
     loop
     extraCLK
     aveVal W@ posY W!
     cs pinhi                 \ Deactivate cs
     
    ." X:" posX W@ . ." Y:" posY W@ . cr
     
fkey? swap drop
until
0 cogreset
;

\ Display time for X-position(sample:8 data) and (X.Y)
\ ( -- )
: demo1
\ Set data for TouchScrenn 
12bit diff enablePD setTSC

cs pinhi cs pinout clk pinout din pinout
c" rdTS" 0 cogx

begin
     penirqm penirqm waitpne                 \ Check touch

\ --- X ---  
cnt COG@        
     cs pinlo                 \ Activate cs
     \ X
     average 0 do
          \ Send control-byte
          cont_X W@ sendData
     loop
     extraCLK
     aveVal W@ posX W!
     cs pinhi                 \ Deactivate cs
cnt COG@ swap - .     
\ --- Y ---          
     cs pinlo                 \ Activate cs   
     \ Y
     average 0 do
          \ Send control-byte
          cont_Y W@ sendData
     loop
     extraCLK
     aveVal W@ posY W!
     cs pinhi                 \ Deactivate cs
     
    ." X:" posX W@ . ." Y:" posY W@ . cr
     
fkey? swap drop
until
0 cogreset
;


