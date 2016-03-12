fl

{
PropForth 5.5(DevKernel)

ColorSensor S11059-02DT
Using i2c_utility_0.4.1.f 
2016/03/12 20:36:41

 S11059-02DT      QuickStartBoard
     1 VDD   ----  3.3V
     5 GND   ----  GND
     6 SCL   ----  P28   
    10 SDA   ----  P29   
}

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
\ Slave addres h2A 
h54 wconstant ColorSensor

\ register name
0 wconstant control
1 wconstant timing

h80 wconstant adc_res
h40 wconstant standby
8 wconstant Hi_gain
4 wconstant manual
3 wconstant 179.2msec
2 wconstant 22.4msec
1 wconstant 1.4msec
0 wconstant 87.5usec

\ =========================================================================== 
\  i2c-Word for ColorSensor
\ =========================================================================== 

\ Get color data
\ ( n1 n2 n3 -- n4 n5 n6 n7 t/f )  n1:delay time(msec) n2;control data  n3:slave address
\                                  n4:Red n5:Green n6:Blue n7:infrared t/f:true if there was an error 
: rd_ColorSensor
2dup                          \ ( n1 n2 n3 n2 n3 )
\ Start I2C 
_eestart
\ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi)   
_eewrite >r                   \ ( n1 n2 n3 n2 )  Push flag
\ Write control register
0 _eewrite r> or >r           \ ( n1 n2 n3 n2 )  Push flag
\ Write data for control register
_eewrite r> or >r             \ ( n1 n2 n3 )     Push flag
2dup                          \ ( n1 n2 n3 n2 n3 )
\ Repeated Start 
Sr
\ Write slave address[rd], then receive Acknowledge-bit(ACK:Lo  NACK:Hi)
_eewrite r> or >r             \ ( n1 n2 n3 n2 )  Push flag
\ Write control register
0 _eewrite r> or >r           \ ( n1 n2 n3 n2 )  Push flag
\ Write data(release reset) for control register
h7F and _eewrite r> or >r     \ ( n1 n2 n3 )     Push flag
rot
delms                         \ Wait integration time  ( n2 n3 )
nip dup                       \ ( n3 n3 )
\ Repeated Start I2C 
Sr
\ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi)   
_eewrite r> or >r             \ ( n3 )           Push flag
\ Write data register
3 _eewrite r> or >r           \ ( n3 )           Push flag
                                                      
\ Repeated Start 
Sr
\ Write slave address[rd], then receive Acknowledge-bit(ACK:Lo  NACK:Hi)
1 or _eewrite r> or >r        \ Push flag 
7 0 do 0 _eeread loop                                                               
-1 _eeread                                                                       
\ Stop I2C
_eestop 
                                                
swap 8 lshift or >r         
swap 8 lshift or >r                                             
swap 8 lshift or >r
swap 8 lshift or              

r> r> r> r>                   \ ( n4 n5 n6 n7 t/f )                                        
;

\ =========================================================================== 
\  Main
\ =========================================================================== 

\ Display default setting
\ manual mode,Low gain,Tint=175usec,integration time= 546msec/ch
\ ( -- )
: test
hex
3 control ColorSensor i2c_rd_multi                \ Read 3byte       
rot
." control:" . cr
." manual timing:" swap 8 lshift or .word cr
decimal
;

\ Set N on manual timing register
\ ( n1 -- )   n1:N  
: Set_manual_timing
dup                                     \ ( n1 n1 )
hFF and swap 8 rshift 2                 \ ( n1's_lower8bit n1's_upper8bit 2 )
timing ColorSensor i2c_wr_multi 
;

\ Mode:manual Gain:Low Tint:00(175usec) IntegralTime:546msec
\ ( -- )
: sample1
begin
     d2200 h84 ColorSensor rd_ColorSensor    
     err?
     ." Infrared:" . ." Blue:" . ." Green:" . ." Red:" .  cr
     fkey? swap drop
     d500 delms
until
;

\ Mode:fixed Gain:High Tint:01(1.4msec) IntegralTime:1.4msec
\ ( -- )
: sample2
\ Set Mode:fixed Gain:High Tint:01(1.4msec) IntegralTime:1.4msec
6 h89 ColorSensor rd_ColorSensor    
err?
begin
     ." Infrared:" . ." Blue:" . ." Green:" . ." Red:" . cr
     6 delms
     \ Get 8 bytes
     8 3 ColorSensor i2c_rd_multi      
     swap 8 lshift or >r         
     swap 8 lshift or >r                                             
     swap 8 lshift or >r
     swap 8 lshift or              
     r> r> r>                                        
     fkey? swap drop
until
3drop drop
;


