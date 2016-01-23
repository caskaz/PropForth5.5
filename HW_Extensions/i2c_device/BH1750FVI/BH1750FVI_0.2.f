fl

{
Ambient Light Sensor (BH1750FVI)
Using i2c_utility_0.4_1.f
      
PropForth 5.5(DevKernel)
2016/01/23 13:37:42

 BH1750FVI module    Propeller
          Vcc   ----  3.3V
          SCL   ----  SCL
          SDA   ----  SDA
          ADDR  ----  GND
          GND   ----  GND 
}

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
\ Slave addres h23 for BH1750FVI (ADDR:GND) 
h46 wconstant BH1750FVI

\ Command
0 wconstant PD           \ Power Down
1 wconstant PO           \ Power On
7 wconstant Reset        \ Reset
h10 wconstant cont_HR    \ Continuous Hi-Resolution Mode
h11 wconstant cont_HR2   \ Continuous Hi-Resolution Mode2 
h13 wconstant cont_LR    \ Continuous Lo-Resolution Mode
h20 wconstant single_HR  \ Single Hi-Resolution Mode
h21 wconstant single_HR2 \ Single Hi-Resolution Mode2
h23 wconstant single_LR  \ Single Lo-Resolution Mode

d9600000 constant 120msec
d1280000 constant 16msec

\ =========================================================================== 
\ Variables 
\ =========================================================================== 
variable time

\ =========================================================================== 
\ Main 
\ =========================================================================== 

\ Write Format for BH1750FVI
\ ( n1 -- t/f )  n1:Command t/f:true if there was an error  
: wr_BH1750FVI
\ Start I2C 
_eestart
\ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi) 
BH1750FVI _eewrite                 \ ( n1 t/f )
\ Write command                   
swap _eewrite or                   \ ( t/f )
\ Stop I2C
_eestop
;

\ Read Format for BH1750FVI
\ ( -- n1 t/f )     n1:16bits  t/f:true if there was an error
: rd_BH1750FVI
\ Start I2C 
_eestart
\ Write slave address[rd], then receive Acknowledge-bit(ACK:Lo  NACK:Hi) 
BH1750FVI 1 or _eewrite            \ ( t/f )
0 _eeread                          \ ( t/f Hi-byte )
-1 _eeread                         \ ( t/f Hi-byte Lo-byte )
\ Stop I2C
_eestop
swap 8 lshift or swap              \ ( 16bits t/f ) 
;

\ Power Down
\ ( -- )
: PowerDown PD wr_BH1750FVI err? ;

\ Power On
\ ( -- )
: PowerOn PO wr_BH1750FVI err? ;

\ RESET
\ ( -- )
: RESET Reset wr_BH1750FVI err? ;


\ Measure on continuous-mode [cont_HR, cont_HR2, cont_LR]
\ ( n -- )  n:continuous-mode command
: cont_mode
PowerOn
dup
\ Set 24msec(Lo-Res) or 180msec(Hi-Res) to time
2 and 0=        
if 120msec else 16msec then time L!
wr_BH1750FVI                  \ Issue command
err?  
time L@ cnt COG@ +                                                  
begin
     rd_BH1750FVI
     err?
     . cr
     time L@ waitcnt          \ Wait until data updating
     fkey? swap drop
until
drop
;

\  Measure on single-mode [single_HR, single_HR2, single_LR]
\ ( n1 -- )   n1:single-mode command
: single_mode
dup                           \ ( n1 n1 )
PowerOn
wr_BH1750FVI                  \ Issue command   ( n1 t/f )
err?                          \ ( n1 )
2 and 0=        
if d120 else d16 then delms
rd_BH1750FVI 
err?
. cr
;

