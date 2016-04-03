fl

{
PropForth 5.5(DevKernel)

Temperature Sensor(LM75BD)
Using i2c_utility_0.4.1.f 
2016/04/03 17:15:54

                   LM75        Propeller
                   Vcc   ----  3.3V
                   SCL   ----  SCL
                   SDA   ----  SDA
                    A0   ----  GND
                    A1   ----  GND
                    A2   ----  GND
3V3--220ohm--LED--- OS           
            [P N]  GND   ----  GND
             
}

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
\ Slave addres h48 for LM75 (A0=A1=A2=0) 
h90 wconstant LM75

\ register
0 wconstant Temp
1 wconstant Conf
2 wconstant Thyst
3 wconstant Tos

\ register value
\ - Conf
0 wconstant OS_f1
8 wconstant OS_f2
h10 wconstant OS_f3
h18 wconstant OS_f4
0 wconstant OS_act_l
4 wconstant OS_act_h
0 wconstant OS_comp
2 wconstant OS_int
0 wconstant normal
1 wconstant shutdn

\ =========================================================================== 
\ Main 
\ =========================================================================== 
\ TAB
\ ( -- )
: tab 9 emit ;

\ Set Configuration
\ ( n1 -- )
: setConf Conf LM75 i2c_wr ;

\ Get Configuration register
\ ( -- n1 )  n1:Configuration[8bit]
: GetConf Conf LM75 i2c_rd ;

\ Read Temperature
\ ( -- n1 )   n1:Temperature 
: GetTemp 
2 Temp LM75 i2c_rd_multi 
swap 8 lshift or
;

\ Display Temperature
\ ( n1 -- ) n1:Temp data
: dispTemp
5 rshift
dup h400 and
if
     h2D emit invert 1+ h7FF and
then          
d125 * d1000 u/mod . h2E emit . 
." degreeC" cr
;

\ Display Tos and Thys on degreeC
\ ( n1 -- ) n1:data
: dispThysTos
dup
1 rshift . h2E emit
1 and if h35 else h30 then emit
." degreeC" cr
;

\ Get HysterisisTemperature register(Default:h4B00)
\ ( -- n1 )  n1:HysterisisTemperature[degree]
: GetThyst
2 Thyst LM75 i2c_rd_multi 
swap 8 lshift or
;

\ Get OverTemperature register(Default:h5000)
\ ( -- n1 )  n1:OverTemperature
: GetTos
2 Tos LM75 i2c_rd_multi 
swap 8 lshift or 
;

\ Read register 
\ ( -- )
: dispReg
hex
." Temp:" tab GetTemp ." h" dup . tab decimal dispTemp hex  
." Conf:" tab Conf LM75 i2c_rd ." h" . cr
." Thyst:" tab GetThyst ." h" dup . tab decimal 7 rshift dispThysTos hex
." Tos:" tab GetTos hex ." h" dup . tab decimal 7 rshift dispThysTos
;

\ Calculate 2byte data for Thyst andTos
\ ( n1 -- n2 n3 ) n1:Temp(no fraction:20,21,..30)  n2LSByte n3:MSByte
: calc2byte
8 lshift dup             \ Shift tbit n1*2 to left
hFF and                  \ LSByte 
swap 8 rshift            \ MSByte
;

\ Set HysterisisTemperature register
\ ( n1 -- )  n1:HysterisisTemperature[degree]
: SetThyst
calc2byte
2 Thyst LM75 i2c_wr_multi 
;

\ OverTemperature register
\ ( n1 -- )  n1:OverTemperature[degree]
: SetTos
calc2byte
2 Tos LM75 i2c_wr_multi 
;

\ Display Temperature[degree]
\ ( -- )
: demo1
begin 
     GetTemp dispTemp
     d100 delms 
     fkey? swap drop 
until
;


