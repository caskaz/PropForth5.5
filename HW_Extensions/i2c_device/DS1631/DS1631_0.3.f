fl

{
PropForth 5.5(DevKernel)

DS1631(Thermometer and Thermostat) driver 
Using i2c_utility_0.4.1.f 
2016/05/24 16:04:47

DS1631      Propeller
1 SDA    ----  SDA(P29) 
2 SCL    ----  SCL(P28) 
3 Tout   ----  Thermostat Output pin
4 GND    ----  GND
5 A0     ----  GND
6 A1     ----  GND
7 A2     ----  GND
8 VDD    ----  3.3V
       
}

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
\ Slave addres h48 for DS1631 A0=A1=A2=GND
h90 wconstant DS1631

\ command name
h51 wconstant Start
h22 wconstant Stop
hAA wconstant Temp
hA1 wconstant TH
hA2 wconstant TL
hAC wconstant Config
h54 wconstant POR
\ Resolution Configuration 
0 wconstant 9bit
4 wconstant 10bit
8 wconstant 11bit
hC wconstant 12bit

\ =========================================================================== 
\ Variables 
\ =========================================================================== 
wvariable tmp

\ =========================================================================== 
\  Word for I2C_device
\ =========================================================================== 

\ Write control-byte to DS1631
\ ( n1 -- t/f )  n1:command  t/f:true if there was an error
: DS1631_com
\ Start I2C 
_eestart
\ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi) 
DS1631 _eewrite               \ ( n1 t/f )
\ Write command
swap _eewrite or              \ ( t/f )
\ Stop I2C
 _eestop
 err? 
;

\ =========================================================================== 
\ Main
\ =========================================================================== 

\ Issue "Start Convert"
\ ( -- )
: startConv Start DS1631_com ;

\ Issue "Stop Convert"
\ ( -- )
: stopConv Stop DS1631_com ; 

\ Write data to Configuration register
\ ( n1 -- )  n1:data
: wrConfig Config DS1631 i2c_wr ;

\ Read from Configuration register
\ ( -- n1 )   n1:configuration byte
: rdConfig Config DS1631 i2c_rd ;

\ Initiate a software power-on-reset(POR)
\ ( -- )
: reset POR DS1631_com ;

\ Combine Hi-byte and Lo-byte
\ ( n1 n2 -- n3 ) n1:Hi-byte n2:Lo-byte  n3:16bit data
: combByte swap 8 lshift or ;
 
\ Read Temp
\ ( -- n1 )  n1:Temperature[16bit]
: rdTemp 2 Temp DS1631 i2c_rd_multi combByte ;

\ Read TempThreshold_Hi
\ ( -- n1 )  n1:Temp_Hi-Threshold[16bit]
: rd_TH 2 TH DS1631 i2c_rd_multi combByte ;

\ Read TempThreshold_Lo
\ ( -- n1 )  n1:Temp_Lo-Threshold[16bit]
: rd_TL 2 TL DS1631 i2c_rd_multi combByte ;

\ Read TempThreshold
\ ( n1 -- n2 )  n1:TL or TH  n2:TempThresholdc[16bit]
: rdThreshold 2 swap DS1631 i2c_rd_multi combByte ;

\ Separate 16bit data to Hi and Lo byte 
\ ( n1 -- n2 n3 ) n1:16bit data  n2:Lo-byte n3:Hi-byte
: separateByte dup 8 rshift ;

\ Write TempThreshold_Hi
\ ( n1 -- )  n1:Temp_Hi-Threshold[16bit] 
: wr_TH separateByte 2 TH DS1631 i2c_wr_multi ;

\ Write TempThreshold_Lo
\ ( n1 -- )  n1:Temp_Lo-Threshold[16bit] 
: wr_TL 2 separateByte 2 TL DS1631 i2c_wr_multi ;

\ Write TempThreshold
\ ( n1 n2 -- )  n1:TL or TH n2:Temp-Threshold[16bit]   
: wrThreshold
separateByte                       \ ( n1 Threshold-Lobyte Threshold-Hibyte )
rot                                \ ( Threshold-Lobyte Threshold-Hibyte n1 ) 
2 swap                             \ ( Threshold-Lobyte Threshold-Hibyte 2 n1 )
DS1631 i2c_wr_multi 
;

\ Set resolution (Default:12bit)
\ ( n1 -- ) n1:9bit, 10bit, 11bit, 12bit
: setResolution 
rdConfig           \ Get configuration
hF3 and or
wrConfig           \ Write configuration
;

\ Read resolution
\ ( -- n1 )  n1:0=9bit, 1=10bit, 2=11bit, 3=12bit
: rdResolution
rdConfig           \ Get configuration
2 rshift 3 and
;

\ Print integer/fraction for Temperature/TH/TL
\ ( n1 -- )  n1:data[16bit]     Resolution:12bit[1bit=0.0625degree]
: printDegree
decimal
0 tmp W!
separateByte                            \ ( fraction integer )
\ Integer
. h2E emit
\ Calculate fraction
4 rshift d625 swap                      \ ( d625 fraction )
4 0 do
     2dup                               \ ( d625 fraction d625 fraction )
     1 i lshift and 
     if tmp W@ + tmp W! else drop then  \ ( d625 fraction )
     swap 1 lshift swap
loop
2drop                                   \ ( -- )
\ Print fraction part
tmp W@ 
d1000 u/mod
h30 + emit
d100 u/mod
h30 + emit
d10 u/mod
h30 + emit
h30 + emit
." degree" 
;

\ Print out Temperature/TH/TL by degree [Only 12bits]
\ ( n1 -- )  n1:data[16bit]
: degree
0 tmp W!
dup h8000 and 0=                   \ Check if minus
if
     \ positive
     printDegree
else
     \ negative
     h2D emit
     \ Back to positive
     invert 1+ hFFFF and
     printDegree
then
;

\ TAB
\ ( -- )
: tab 9 emit ;

\ Display register
\ ( -- )
: disp_reg
hex ." Temperature:" tab rdTemp dup .word tab degree cr
hex ." Temp-High:" tab rd_TH dup .word tab degree cr
hex ." Temp-Low:" tab rd_TL dup .word tab degree cr
hex ." Configuration:" tab rdConfig .byte cr
decimal
;

\ Display Temperature[Resolution:12bit]
\ ( -- )
: measure
rdConfig h9F and wrConfig          \ Clear TempFlag
startConv
0
begin
     1+ dup d20 =
     if
          cr ." Temp:" 9 emit 9 emit ." TH" 9 emit 9 emit ." TL" 9 emit 9 emit ." TempFlag" cr
          drop 0
     then 
     rdTemp degree 9 emit rd_TH degree 9 emit rd_TL degree 9 emit rdConfig 5 rshift . cr
     d750 delms
     fkey? swap drop
until
stopConv
drop
;
