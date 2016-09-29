fl

{
PropForth 5.5(DevKernel)

Temperature Sensor(PCT2075)
Using i2c_utility_0.4.2.f   
2016/09/28 21:53:32

                 PCT2075      Propeller
                    Vcc   ----  3.3V
                    SCL   ----  SCL
                    SDA   ----  SDA
3V3--LED--220ohm---- OS
                     A0   ----  GND
                     A1   ----  GND
                     A2   ----  GND           
                    GND   ----  GND
             
}

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
\ Slave addres h48 for PCT2075 (A0=A1=A2=0) 
h90 wconstant PCT2075

\ register
0 wconstant Temp
1 wconstant Conf
2 wconstant Thyst
3 wconstant Tos
4 wconstant Tidle

\ register value
\ - Conf
0 wconstant OS_f1
8 wconstant OS_f2
h10 wconstant OS_f3
h18 wconstant OS_f4

d8000000 constant 100msec

\ =========================================================================== 
\ Main 
\ =========================================================================== 
\ Read Temperature
\ ( -- n1 n2 )   n1:Temperature[11bit]]  n2:positive[0]/negative[1]  
: GetTemp 
2 Temp PCT2075 i2c_rd_multi 
swap 8 lshift or
5 rshift
dup abs swap
h400 and 
if 1 else 0 then
;

\ Get Configuration register
\ ( -- n1 )  n1:Configuration[8bit]
: GetConf Conf PCT2075 i2c_rd ;

\ Set Configuration register
\ ( n1 -- )  n1:Configuration[8bit]
: setConf Conf PCT2075 i2c_wr ;

\ Set OS fault queue
\ ( n1 -- ) n1:OS_f1(default),OS_f2,OS_f3,OS_f4
: setOS_queue GetConf 7 and or setConf ;

\ Set OverShutdown polarity
\ ( n1 -- ) n1:0=active Low(default)  1=active Hi
: setOS_pol GetConf swap if 4 or else hFB and then setConf ;

\ Set OverShutdown polarity
\ ( n1 -- ) n1:0=active Low(default)  1=active Hi
: setOS_pol GetConf swap if 4 or else hFB and then setConf ;

\ Set OverShutdown operation mode
\ ( n1 -- ) n1:0=comparator(default)  1=interupt 
: setOS_mode GetConf swap if 2 or else hFD and then setConf ;

\ Set device mode
\ ( n1 -- ) n1:0=normal(default)  1=shutdown 
: setMode GetConf swap if 1 or else hFE and then setConf ;

\ Get HysterisisTemperature/OverTemperature register
\ ( n1 -- n2 n3 )  
\ n1:Thyst or Tos  n2:HysterisisTemperature[degree] n3:positive[0]/negative[1] 
: getThyst/Tos
2 swap PCT2075 i2c_rd_multi 
swap 8 lshift or
7 rshift                     
dup abs swap
h100 and 
if 1 else 0 then
;

\ Create separate byte for i2c write
\ ( n1 n2 -- n3 n4 ) n1:HysterisisTemperature[degree] n2:positive[0]/negative[1]
\ n3:LSByte  n4:MSByte
: buildByte
if invert 1+ then
8 lshift dup             \ Shift tbit n1*2 to left
hFF and                  \ LSByte 
swap 8 rshift            \ MSByte
;

\ Set HysterisisTemperature register
\ ( n1 n2 -- )  n1:HysterisisTemperature[degree]only integer n2:positive[0]/negative[1] 
: SetThyst
buildByte
2 Thyst PCT2075 i2c_wr_multi
;

\ OverTemperature register
\ ( n1 -- )  n1:OverTemperature[degree]only integer  n2:positive[0]/negative[1]
: SetTos
buildByte
2 Tos PCT2075 i2c_wr_multi
;

\ Get TemperatureIdle register
\ ( -- n1 )   n1:TemperatureIdle[msec]
: getTidle Tidle PCT2075 i2c_rd ;

\ Set TemperatureIdle register
\ ( n1 -- n1 )   n1:TemperatureIdle[x 100msec] 0,1=100msec 200[msec] .. 3100[msec]
: setTidle h1F and Tidle PCT2075 i2c_wr  ;


\ Convert Temp[11bit] to degree
\ ( n1 n2 -- n3 )  n1:Temperature[11bit]]  n2:positive[0]/negative[1]  n3:Temperature[degree]
: degree
if h2D emit abs then          \ print "-"
d125 *
d1000 u/mod .                 \ print integer part
h2E emit                      \ print "."
.                             \ print frac part
." degree"
;

\ Convert Tos/Thyst[9bit] to degree
\ ( n1 n2 -- n3 )  n1:Temperature[11bit]]  n2:positive[0]/negative[1]  n3:Temperature[degree]
: Tos/Thyst
if h2D emit abs then          \ print "-"
d50 *
d100 u/mod .                 \ print integer part
h2E emit                      \ print "."
.                             \ print frac part
." degree"
cr
;

\ Display Temperature[degree]
\ ( -- )
: demo1 
getTidle 100msec * cnt COG@ +
begin 
     GetTemp degree cr 
     getTidle 100msec * waitcnt 
     fkey? swap drop
until 
drop
;


