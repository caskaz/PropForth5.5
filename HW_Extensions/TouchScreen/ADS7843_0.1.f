fl

{
TouchScreen Controller(ADS7843)
PropForth5.5

2015/12/28 18:55:35

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
P9 <----- |PENIRQ     GND  |            
           ----------------
                       |
                      GND
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
1 wconstant Ydata
5 wconstant Xdata
2 wconstant Aux1
6 wconstant Aux2
\ Resolution
0 wconstant 12bitData
1 wconstant 8bitData
\ Single/Differential
0 wconstant diff
1 wconstant single
\ PowerDown selection
0 wconstant enablePD
1 wconstant disablePD

\ -------------------------------------------------------
\ Variables
\ -------------------------------------------------------


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

\ Convert analog to digital
\ ( n1 n2 n3 n4 -- n5 ) n1:PD n2:single/diff(select single when Aux1/Aux2) n3:mode n4:address   n5:conversion data
: ADS7843
\ Set output port
cs pinhi cs pinout clk pinout din pinout

cs pinlo
1                   \ Start bit
3 lshift or         \ Add address
over >r             \ Push mode
1 lshift or         \ Add mode
1 lshift or         \ Add single/diff
2 lshift or         \ Add PD
\ Send control data
h80
8 0 do
     2dup and
     if din_h else din_l then
     clk_pulse
     1 rshift
loop
2drop
clk_pulse 
\ Read data
0                             
r>                  \ Pop mode
dup >r              \ Push mode
if 8 else d12 then
0 do
     1 lshift
     clk pinhi 
     ina COG@ doutm and   
                              \      dup if ." 1" else ." 0" then  
     if 1 or then
     clk pinlo
loop
                               \       cr   st?
r>                                      
if
     clk_pulse clk_pulse clk_pulse
else
     7 0 do clk_pulse loop
then          
cs pinhi
;

: test
begin
enablePD diff 12bitData Ydata ADS7843 .
fkey? swap drop
until
;

\ Display 12bit(x,y) on TouchScreen
\ ( -- )
: demo
begin
enablePD diff 12bitData Ydata ADS7843 d2047 - .
enablePD diff 12bitData Xdata ADS7843 d2047 - . cr 
d100 delms
fkey? swap drop
until
;

\ Display 8bit(x,y) on TouchScreen
\ ( -- )
: demo1
begin
enablePD diff 8bitData Ydata ADS7843 d127 - .
enablePD diff 8bitData Xdata ADS7843 d127 - . cr 
d100 delms
fkey? swap drop
until
;


: AD
\ Set output port
cs pinhi cs pinout clk pinout din pinout

cs pinlo
1                   \ Start bit
3 lshift or         \ Add address
over >r             \ Push mode
1 lshift or         \ Add mode
1 lshift or         \ Add single/diff
2 lshift or         \ Add PD
\ Send control data
h80
8 0 do
     2dup and
     if din_h else din_l then
     clk_pulse
     1 rshift
loop
2drop
clk_pulse 
\ Read data
0                             
r>                  \ Pop mode
\ dup >r              \ Push mode
if 8 else d12 then
0 do
     1 lshift
     clk pinhi 
     ina COG@ doutm and   
                              \      dup if ." 1" else ." 0" then  
     if 1 or then
     clk pinlo
loop
                               \       cr   st?
{
r>                                      
if
   \  clk_pulse clk_pulse clk_pulse
else
  \   7 0 do clk_pulse loop
then
}          
cs pinhi
;
: demo2
begin
enablePD diff 12bitData Ydata AD  .
enablePD diff 12bitData Xdata AD  . cr 
d100 delms
fkey? swap drop
until
;
: demo3
begin
enablePD diff 8bitData Ydata AD  .
enablePD diff 8bitData Xdata AD  . cr 
d100 delms
fkey? swap drop
until
;

: test
begin                             
begin ina COG@ penirqm and 0= st? until
enablePD diff 8bitData Ydata AD  .
enablePD diff 8bitData Xdata AD  . cr 
d100 delms
fkey? swap drop
until
;
: test1 begin ina COG@ penirqm st? and 0= until ;
