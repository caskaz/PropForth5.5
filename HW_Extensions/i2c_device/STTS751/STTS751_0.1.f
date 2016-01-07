fl

{
TEmperature Sensor(STTS751-0WB3F)
Using i2c_utility_0.4_1.f

PropForth5.5

 
             ---------
 Propeller  | STTS751 |
    SDA ----|SDA   Vdd|---- 3V3
    SCL ----|SCL      |
            |         |
            |Addr  GND|
             ---------
               |    |
              GND  GND

2016/01/07 11:23:34

}

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
\ Slave addres[h39] for STTS751[Addr=0)
h72 wconstant STTS751

\ Configuration register
0 wconstant enableEVENT
h80 wconstant disableEVENT
0 wconstant RUN
h40 wconstant STOP
8 wconstant 9bit
0 wconstant 10bit
4 wconstant 11bit
hC wconstant 12bit

\ Conversion Rate
0 constant 0.06125c/s
1 constant 0.125c/s
2 constant 0.25c/s
3 constant 0.5c/s
4 constant 1c/s
5 constant 2c/s
6 constant 4c/s
7 constant 8c/s
8 constant 16c/s
9 constant 32c/s

\ Conversion Rate s string
: s, parsenw dup C@ 1+ bounds dup rot2 do C@++ c, loop drop ;
wvariable convRateStr -2 allot s, 0.0625 s, 0.125 s, 0.25 s, 0.5 s, 1 s, 2 s, 4 s, 8 s, 16 s, 32

\ Time for conversion rate
wvariable rate -2 allot 
d1280000000 l, d640000000 l, d320_000_000 l, d160_000_000 l, d80_000_000 l, 
d40_000_000 l, d20_000_000 l, d10_000_000 l, d5_000_000 l, d2_500_000 l,

\ =========================================================================== 
\ Variables 
\ =========================================================================== 
variable dT
wvariable bit

\ =========================================================================== 
\ Main 
\ =========================================================================== 

\ Read ProductID and ManufactureID and RevisionNumber
\ ( -- )
: chipID
." Product ID:" hFD STTS751 i2c_rd . cr
." ManufactureID:h" hFE STTS751 i2c_rd hex . cr decimal
." Revision ID:" hFF STTS751 i2c_rd . cr cr
;
 
\ Read status
\ ( -- )
: rdStatus
1 STTS751 i2c_rd dup 0 >
if
     dup h80 and if ." busy " then
     dup h40 and if ." High limit On " then
     dup h20 and if ."  Low limit On" then
     1 and if ." THERM On" then
else
     ." None"
then
cr
;

\ Set Configuration
\ ( n1 n2 n3 -- )  n1:EVENT n2:RUN/STOP n3:Temperature resolution [Default 10bits]
: setConfig or or 3 STTS751 i2c_wr ;

\ Read Configuration
\ ( -- ) 
: rdConfig 
3 STTS751 i2c_rd                                                     
dup h80 and ." EVENT is " if ." enabled" else ." disabled" then cr
dup h40 and if ." Standby " else ." Conversion " then ." mode" cr
2 rshift 3 and               
0 over =
if 
     ." 10bits"
else 
     1 over =
     if 
          ." 11bits"
     else 
          2 over =
          if 
               ." 9bits"
          else
               ." 12bits"
thens
drop
cr
;

\ Set conversion rate
\ ( n1 -- ) n1:Conversion Rate ( Default:1c/s)
: setConvRate 4 STTS751 i2c_wr ;

\ Print out string
\ ( n1 n2 ) n1:index(0,1,2,..,n) n2:stringarray's address
: dispStr
swap dup 0 <>
if
     0 do
          dup C@ + 1+
     loop
else
     drop
then
.cstr
;

\ Read conversion rate
\ ( -- )  
: rdConvRate 4 STTS751 i2c_rd convRateStr dispStr ." /sec" cr ;

\ Display fractional part
\ ( n1 n2 -- ) n1:number n2:bit
: fraction
d1000 swap 
0 do
     2dup
     u/mod h30 + emit
     rot drop
     swap d10 /
loop
2drop
               
;

\ Display Temperature (Not operating for 1shot)
\ ( -- )
: Temp
\ Read conversiob rate
4 STTS751 i2c_rd 4* rate + L@ dT L!
\ Read configuration
3 STTS751 i2c_rd 2 rshift 3 and 
2 over =
if 1
else 0 over =
if 2
else 1 over =
if 3
else 4
thens
nip                          \ Conversion rate 1:9bits 2:10bits 3:11bits 4:12bits                       
                         
bit W!
                        
dT L@ cnt COG@ +                           
begin
     \ Read Hi-byte
     0 STTS751 i2c_rd dup h80 and
     if
          h2D emit            \ "-" 
          1- invert h7F and   \ absolute value
     then     
     . h2E emit               \ Print integer and "."
     
     \ Read Lo-byte
     2 STTS751 i2c_rd                    
     0
     over h80 and if d5000 + then
     over h40 and if d2500 + then
     over h20 and if d1250 + then
     swap h10 and if d675 + then
     bit W@                               
     fraction            
     
     dT L@ waitcnt    
     fkey? swap drop
     ." degree" cr
until
drop
;
