fl

{
PropForth 5.5(DevKernel)

Temperature Sensor(ADT7410)     
Using i2c_utility_0.4.1.f 
2016/03/17 21:31:54

    ADT7410 module      Propeller
           VDD    ----  3.3V
           GND    ----  GND
           SCL    ----  P28   
           SDA    ----  P29   
           A0-GND
           A1-GBD
}

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
\ Slave addres h48 for ADT7410  A0=A1=0
h90 wconstant ADT7410

\ register name
0 wconstant TempHi
1 wconstant TempLo
2 wconstant status
3 wconstant config
4 wconstant TH_SP_Hi
5 wconstant TH_SP_Lo
6 wconstant TL_SP_Hi
7 wconstant TL_SP_Lo
8 wconstant TCRIT_SP_Hi
9 wconstant TCRIT_SP_Lo
d10 wconstant THYST_SP
d11 wconstant ID
d12 wconstant soft_reset
\ Resolution
1 wconstant 16bit
0 wconstant 13bit
\ Mode
0 wconstant cont
1 wconstant 1-shot
2 wconstant SPS
3 wconstant shutdown

\ =========================================================================== 
\  Variables
\ =========================================================================== 
wvariable tmp
wvariable mode
0 mode W!

\ =========================================================================== 
\ Main
\ =========================================================================== 

\ Reset ADT7410
\ ( -- )
: reset_ADT7410 
\ Start I2C 
_eestart
\ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi) 
ADT7410 _eewrite h2F _eewrite or   
\ Stop I2C
_eestop
err? 
;

\ Change resolution to 16bit or 13bit
\ ( n1 -- ) n1:16bit/13bit
: resolution
\ read register3    
config ADT7410 i2c_rd                        \ ( 16bit/13bit config )
swap                                         \ ( config 16bit/13bit )
if
     h80 or                                  \ ( config )
else
     h7F and                                 \ ( config )
then
config ADT7410 i2c_wr
;

\ Display all register's value
\ ( -- ) 
: disp_reg
hex
." Address  " ." value(hex)" cr
2 TempHi ADT7410 i2c_rd_multi  
." 0" 9 emit swap .byte  cr             \ register0
." 1" 9 emit .byte cr                   \ register1
status ADT7410 i2c_rd 
." 2" 9 emit .byte cr                   \ register2
config ADT7410 i2c_rd
." 3" 9 emit .byte cr                   \ register3
2 TH_SP_Hi ADT7410 i2c_rd_multi 
." 4" 9 emit swap .byte cr              \ register4
." 5" 9 emit .byte cr                   \ register5
2 TL_SP_Hi ADT7410 i2c_rd_multi 
." 6" 9 emit swap .byte  cr             \ register6
." 7" 9 emit .byte  cr                  \ register7
2 TCRIT_SP_Hi ADT7410 i2c_rd_multi   
." 8" 9 emit swap .byte cr              \ register8
." 9" 9 emit .byte  cr                  \ register9

THYST_SP ADT7410 i2c_rd 
." 10" 9 emit .byte cr                  \ register10
ID ADT7410 i2c_rd
." 11" 9 emit .byte cr                  \ register11
decimal
;

\ Set mode
\ ( n1 -- )  n1:cont, 1-shot, SPS, shutdown
: set_mode
dup mode W!                             \ Save value to mode
5 lshift                                \ ( n1 )
\ Read register3    
config ADT7410 i2c_rd                   \ ( n1 config )
h9F and or
\ Write register
config ADT7410 i2c_wr
;

\ TAB
\ ( --)
: TAB 9 emit ;

\ Check if negative
\ ( n1 -- n2 ) ni:number  n2:changing to positive if negative
: negative?
     dup h8000 and
     if
          h2D emit                           \ print "-" 
          invert h7FFF and 1+
     then
;

\ Print "."
\ ( -- )
: prt. h2E emit ;

\ Calculate fraction
\ ( n1 n2 n3  -- n4 ) n1:fraction unit n2:fraction bit n3:loop number  n4:fraction part
: fracSum
0 do
     2dup 
     1 i lshift and if tmp W@ + tmp W! else drop then
     swap 1 lshift swap
loop
2drop
;

\ Print fraction part
\ ( n1 -- ) n1:fraction
: prtFract
d1000 tmp W!
4 0 do 
     dup tmp W@ >                       \ Check if n is bigger than tmp
     if 
          tmp W@ u/mod h30 + emit       \ Print number-char
     else 
          h30 emit                      \ Print "0"
     then
     tmp W@ d10 u/ tmp W!               \ Divide tmp by d10 
loop
drop
;

\ Print Temperature (13bit/16bit)
\ ( -- ) 
: prtTemp
2 TempHi ADT7410 i2c_rd_multi                \ ( MS-byte LS-byte )
\ Check 13bit or 16bit
config ADT7410 i2c_rd h80 and                \ ( MS-byte LS-byte t/f )
if
     \ 16bit
     swap 8 lshift or                        \ ( 16bit-Temp )
     negative?
     dup 7 rshift .                          \ Integer part
     prt. 
     \ fraction part
     h7F and d78 u*
     \ Print fraction part
     prtFract
else
     \ 13bit
     \ Print each flag(Tcrit,Thigh,Tlow) 
     dup 4
     3 0 do 
          2dup and 
          if ." ON" else ." OFF" then 
          TAB 1 rshift 
     loop
     2drop
     swap 8 lshift or                        \ ( 13bit-Temp )                        
     negative?
     3 rshift                                \ 13bit Temperature
     dup 4 rshift .                          \ Integer part
     prt.
     \ fraction part
     hF and d625 u*                  
     \ Print fraction part
     prtFract
then
cr
;


: title ." T-CRIT" 9 emit ." T-HIGH." 9 emit ." T-LOW" 9 emit ." Temperature[degree] " ;

\ Measure temperature by each mode
\ ( n1 -- )  n1:cont, 1-shot, SPS
: Measure_Temp
3 over =
if 
     drop      \ Ignore shutdown mode
else
     0 over =
     if
          drop
          \ Continuous mode
          cont set_mode
          title ." [Continuous mode]" cr
          0
          begin
               prtTemp 
               1+ dup d20 =
               if
                    cr title ." [Continuous mode]" cr
                    drop 0
               then
               \ Check ready-flag                          
               begin status ADT7410 i2c_rd 0= until
               fkey? swap drop
          until                   
     else
          1 over =
          if
               drop
               \ 1-shot
               title ." [1-shot mode]" cr
               0
               begin
                    1-shot set_mode
                    d240 delms
                    prtTemp 
                    1+ dup d20 =
                    if
                         cr title ." [1-shot mode]" cr
                         drop 0
                    then                          
                    fkey? swap drop
               until
          else
               drop
               \ SPS mode
               SPS set_mode
               d60 delms                               \ Wait 60msec only first time
               title ." [SPS mode]" cr    
               0 
               begin
                    prtTemp 
                    1+ dup d20 =
                    if
                         cr title ." [SPS mode]" cr
                         drop 0
                    then
                    d1000 delms                        \ Wait 1sec                          
                    fkey? swap drop
               until
thens
drop
;
