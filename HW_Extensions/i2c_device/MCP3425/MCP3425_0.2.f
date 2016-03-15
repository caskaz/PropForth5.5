fl

{
PropForth 5.5(DevKernel)

16bit Analog to Digital Converter(MCP3425)
Using i2c_utility_0.4.1.f 
2016/03/15 12:46:56
                        
                Positive input          
                              3.3V
  Propeller     MCP3425        |
                 1 Vin+ ------VR(10k)    
     GND   ----  2 Vss         |
     SCL   ----  3 SCL        GND
     SDA   ----  4 SDA 
     3.3V  ----  5 Vdd 
                 6 Vin- ------GND

                Negative input          
                              
  Propeller     MCP3425        
                 1 Vin+ ------GND    
     GND   ----  2 Vss         
     SCL   ----  3 SCL        
     SDA   ----  4 SDA        3.3V
     3.3V  ----  5 Vdd         |
                 6 Vin- ------VR(10k)
                               |
                              GND
}

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
\ Slave addres h68 for MCP3425(A0=A1=A2=0) 
hD0 wconstant MCP3425

\ Write configuration
h10 wconstant cont
0 wconstant 1shot
0 wconstant 12bits
4 wconstant 14bits
8 wconstant 16bits

h80 wconstant ready

\ =========================================================================== 
\ Variables 
\ =========================================================================== 
wvariable config

\ =========================================================================== 
\ Main 
\ =========================================================================== 

\ Reset MCP3425 by using General Call
\ ( -- )
: GenCall_reset _eestart 0 _eewrite 6 _eewrite _eestop or err? ;

\ Set 1-shot-conversion by using General Call
\ ( -- )
: GenCall_1shot _eestart 0 _eewrite 8 _eewrite _eestop or err? ; 

\  Write data to congig-register for MCP3425
\ ( n -- t/f ) n:byte data  t/f:true if there was an error
: i2c_wr_MCP3425
dup                      \ ( n n )
\ Start I2C 
_eestart
\ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi)
MCP3425 _eewrite         \ ( n n t/f )
\ Write config
swap _eewrite or         \  ( n t/f )
\ Stop I2C
_eestop
swap config W!           \ Save data to config  
;

\ Write config
\ Set 1-shot conversion or continuous conversion
\ ( n1 n2 n3 -- t/f )  n1:1shot or cont  n2:SampleRate(12bits,14bits,16bits)  n3:PGA Gain(1,2,4,8)   t/f:true if there was an error
: wr_config
\ Convert Gain to 0 or 1 or 2 or 3
1 rshift dup 4 = if drop 3 then 3 and     
or or
i2c_wr_MCP3425
;

\ Read data from device
\ ( -- n1 n2 n3 t/f )  n1:Upper data Byte n2:Lower Data Byte n3:Configuration Byte  t/f:true if there was an error
: rd_data
\ Start I2C 
_eestart
\ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi)
MCP3425 1+ _eewrite      \ ( t/f )
>r                       
\ Read 3 bytes
2 0 do 0 _eeread loop    \ ( n1 n2 )
\ Read 1byte ,then set sda to Hi(NACK:master->slave)
-1 _eeread               \ ( n1 n2 n3 )
r>                       \ ( n1 n2 n3 t/f )

\ Stop I2C
_eestop  
;

\ Display config-register[hex]
\ ( -- )
: rd_config rd_data err? ." h" hex . 2drop decimal ;

\ Get data on continuous mode
\ ( -- n )   n:data
: get_cont
rd_data err?                            \ ( n1 n2 n3 )
ready and 0=                            \ ( n1 n2 t/f )
if
     \ Updated latest conversion data
     swap 8 lshift or                   \ ( n )
     config W@                          \ ( n config )
     dup 12bits and
     if 
          \ 12bit data
          drop dup h800 and 
          if hFFFFF000 or then          \ negative       
     else 
          16bits and
          if 
               \ 14bit data
               dup h2000 and
               if hFFFFC000 or then     \ negative
          else 
               \ 16bit data
               dup h8000 and
               if hFFFF0000 or then     \ negative
          then     
     then
          
           
     . cr
else
     \ Not updated
     2drop
then
;

\ Get data on One-Shot mode
\ ( -- n )   n:data
: get_1shot
\ Initiate new conversion
config W@ h80 or i2c_wr_MCP3425 err?
begin
     rd_data err?                  \ ( n1 n2 n3 )
     ready and 0=                  \ ( n1 n2 t/f )
     \ Repeat until new data is ready
     if 1 else 2drop 0 then
until
                       
\ Updated latest conversion data
swap 8 lshift or                   \ ( n )
config W@                          \ ( n config )
dup 12bits and
if 
     \ 12bit data
     drop dup h800 and 
     if hFFFFF000 or then          \ negative       
else 
     16bits and
     if 
          \ 14bit data
          dup h2000 and
          if hFFFFC000 or then     \ negative
     else 
          \ 16bit data
          dup h8000 and
          if hFFFF0000 or then     \ negative
     then     
then
. cr               
;

\ Read conversion-result (default after POR)
\ ( -- )
: get_A/D
rd_data err?
config W! 2drop
config W@ dup

cont and if 1 ." Continuous " else 0 ." One-Shot " then
." Convesion Mode "
swap
dup
hC0 and 12bits over =
if
     ." 12bits"
else
     14bits over =
     if
          ." 14bits"
     else
          ." 16bits"
thens
drop

."  PGA-Gain="
3 and 0 over =
if
     ." 1"
else
     1 over =
     if
          ." 2"
     else
          2 over =
          if
               ." 4"
          else
               ." 8"
thens
drop cr cr
\ ( n )  n:continuour[1] 1-shot[0]  
         
begin
     if
          \ Continuous mode
          get_cont
          1
     else
          \ 1shot mode
          get_1shot
          0
     then
     
     fkey? swap drop
until
drop
;


   \   1shot 12bits 1 wr_config err? get_A/D
   \   1shot 12bits 2 wr_config err? get_A/D
   \   1shot 12bits 4 wr_config err? get_A/D
   \   1shot 12bits 8 wr_config err? get_A/D
   \   cont 12bits 1 wr_config err? get_A/D
   \   cont 12bits 2 wr_config err? get_A/D
   \   cont 12bits 4 wr_config err? get_A/D
   \   cont 12bits 8 wr_config err? get_A/D


