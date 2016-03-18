fl

{
PropForth 5.5(DevKernel)

i2c_encoder by using 8bit I/O Expander(PCF8574)
Using i2c_utility_0.4.1.f 
2016/03/18 16:26:00

     

Propeller      PCF8574 module
3.3V     -------  Vcc        Vcc
GND      -------  GND         |
P29(SDA) -------  SDA      10kohm
P28(SCL) -------  SCL         |  A -----------
P0       -------  P0   -----------| Rotary    |
                          GND ----|  Encorder |
P1       -------  P1   -----------|           |
               A2=A1=A0=GND   |  B -----------
                           10kohm
                              |
                             Vcc
                             
     prev  current status
       0     0      stop           0
       0     1      CW             1
       0     2      CCW           -1
       0     3      invalid(=stop) 0
       4     0      CCW           -1
       4     1      stop           0
       4     2      invalid(=stop) 0
       4     3      CW             1
       8     0      CW             1
       8     1      invalid(=stop) 0
       8     2      stop           0
       8     3      CCW           -1
       C     0      invalid(=stop) 0
       C     1      CCW           -1
       C     2      CW             1
       C     3      stop           0
                             
}

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
\ Slave addres h20 for PCF8574
h40 wconstant PCF8574
\ A2=A1=A0=0
0 wconstant addr

variable encoder_tbl -4 allot 
0 l, 1 l, -1 l, 0 l, 
-1 l, 0 l, 0 l, 1 l, 
1 l, 0 l, 0 l, -1 l, 
0 l, -1 l, 1 l, 0 l, 

\ =========================================================================== 
\ Variables 
\ =========================================================================== 
variable pos
wvariable prev

\ =========================================================================== 
\ Main 
\ =========================================================================== 

\ Count up/down encorder's position
\ If i2c-error occur, count stop.
\ ( -- )
: i2c_encorder
0 pos L!
0 prev W!
begin                  
     \ Start I2C 
     _eestart
     \ Write slave address[rd], then receive Acknowledge-bit(ACK:Lo  NACK:Hi) 
     PCF8574 addr 1 lshift or 1 or _eewrite       \ ( t/f ) 
     -1 _eeread                                   \ ( t/f n1 )
     \ Stop I2C
     _eestop
     swap                                         \ ( n1 t/f )
     if    
          drop
     else
          3 and dup                                                         
          prev W@ or 4* encoder_tbl + L@          \ Get value 
          pos L@ + pos L!                         \ Update pos
          2 lshift prev W!                        \ Save prev to shift 2bit left
     then 
0 until
;

\ Display position with RotaryEncoder without click 
\ ( -- )
: test1 
c" i2c_encorder" 0 cogx
5 delms                                           \ Delay because operating 'encorder' takes a little time.
begin pos L@ . d10 delms fkey? swap drop until
0 cogreset 
;

{
Measuring time from P2-Lo to P2-Hi --> 330usec(3.03kHz) --> 3030count/sec
Using encoder 24P/R --> 96count/R 

rotation speed =3030/96=31R/sec
i2c_encoder can use until 31rotation/second

: i2c_encorder_Time
2 pinout
0 pos L!
0 prev W!
begin     
     2 pinhi 2 pinlo        
     \ Start I2C 
     _eestart
     \ Write slave address[rd], then receive Acknowledge-bit(ACK:Lo  NACK:Hi) 
     PCF8574 addr 1 lshift or 1 or _eewrite       \ ( t/f ) 
     -1 _eeread                                   \ ( t/f n1 )
     \ Stop I2C
     _eestop
     swap                                         \ ( n1 t/f )
     if    
          drop
     else
          3 and dup                                                         
          prev W@ or 4* encoder_tbl + L@          \ Get value 
          pos L@ + pos L!                         \ Update pos
          2 lshift prev W!                        \ Save prev to shift 2bit left
     then 
0 until
;
c" i2c_encorder_Time" 0 cogx

}
