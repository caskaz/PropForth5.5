fl

{                       
PropForth5.5(DevKernel)

4channel Bus Switch(PCA9546)
Using i2c_utility_0.4.f   
2015/10/08 12:52:22

Propeller      PCA9546       
     SDA   ---  SDA
     SCL   ---  SCL
          
                A0   ---- 3.3V
                A1   ---- GND
                A2   ---- GND
                
                
                
}

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
\ Slave addres h71 for PCA9546 
hE2 wconstant PCA9546

0 wconstant channel0
2 wconstant channel1
4 wconstant channel2
8 wconstant channel3

\ =========================================================================== 
\ Main
\ =========================================================================== 

\ Switch i2c-Bus to channel*
\ ( n1 -- ) n1:[b3 b2 b1 b0]
: switch 
\ Start I2C 
_eestart
\ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi) 
PCA9546 _eewrite              \ ( n1 t/f )
\ Write control byte
swap _eewrite or              \ ( t/f )
\ Stop I2C
_eestop
;

\ Read current channnel
\ ( -- n1 )  n1:channel number
: sw_rd
\ Start I2C 
_eestart
\ Write slave address[rd], then receive Acknowledge-bit(ACK:Lo  NACK:Hi)
PCA9546 1 or _eewrite              \ ( t/f )
\ Read 1byte ,then set sda to Hi(NACK:master->slave)
-1 _eeread             
\ Stop I2C
_eestop                                         
nip
;

\ Write and read channnel
\ ( -- )
: test
d16 0 do
     i switch sw_rd .
loop
;
