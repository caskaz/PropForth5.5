fl

{
PropForth 5.5(DevKernel)

12bit Digital to Analog Converter(MCP4725)
Using i2c_utility_0.4.1.f 
2016/03/16 12:51:41

    MCP4725 module      Propeller
           Vcc    ----  3.3V
           GND    ----  GND
           SDA    ----  P29   
           SCL    ----  P28 
           ANALOG ----  
           GND    ----  GND
           A0-GND

}

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
\ Slave addres h60 for MCP4725  
\ [A2:A1:A0]  A2=A1=0:Factory setting, A0=0:User defined
hC0 wconstant MCP4725

\ Power down bits
0 wconstant normal
1 wconstant 1k
2 wconstant 100k
3 wconstant 500k

\ Command type  [C2 C1 C0]
0 wconstant Fast
h40 wconstant wr_DAC
h60 wconstant wr_DAC&EEPROM

\ =========================================================================== 
\ Main 
\ =========================================================================== 

\ Reset MCP4725 (using General Call Reset)
\ ( -- )
: reset
\ Start I2C 
_eestart
\ Issue General Call Reset
0 _eewrite 6 _eewrite or
\ Stop I2C
_eestop                                                        
err?
;

\ Wake Up MCP4725 (using General Call Wake Up)
\ ( -- )
: WakeUp
\ Start I2C 
_eestart
\ Issue General Call Wake Up
0 _eewrite 9 _eewrite or
\ Stop I2C
_eestop                                                        
err?
;

\ Change DAC Code In Fast Mode:(C2 C1)=(0 0)
\ ( n1 n2 -- )    n1:DAC data(12bit)   n2:power-down bits
: DAC_out
\ Start I2C          
_eestart
\ Write slave address[wr], AddressBits then receive Acknowledge-bit(ACK:Lo  NACK:Hi)   1st byte
MCP4725 _eewrite                   \ ( n1 n2 t/f )
>r                                 \ ( n1 n2 )
\ Making 2nd-byte and 3rd-byte                                           
\ Fast mode command, power-down bits and upper6bits of DAC data   2nd byte
4 lshift                           \ power-down bits
Fast                               \ Command Type
or swap                            \ ( 2nd-byte n1 )
dup hF00 and 8 rshift              \ ( 2nd-byte n1 n1_upper4bits )
rot                                \ ( n1 upper6bits 2nd-byte )
or                                 \ ( n1 2nd-byte )
r>                                 \ ( 3rd-byte 2nd-byte t/f )
2 0 do swap _eewrite or loop                                               
\ Stop I2C
_eestop 
err?
;

\ Using except for Fast mode
\ ( n1 n2 n3 -- )  n1:DAC data(12bit) n2:wr_DAC or wr_DAC&EEPROM n3:power-down bits
: DAC&EEPROM
\ Start I2C 
_eestart
\ Write slave address[wr], AddressBits then receive Acknowledge-bit(ACK:Lo  NACK:Hi)   1st byte
MCP4725 _eewrite                   \ ( n1 wr_DAC n2 t/f )
>r                                 \ ( n1 wr_DAC n2 )
\ Making 2nd-byte, 3rd-byte and 4th-byte                                           
\ Write DAC register command, power-down bits and upper6bits of DAC data   2nd byte
1 lshift                           \ power-down bits
or swap                            \ ( 2nd-byte n1 )
dup 4 rshift                       \ ( 2nd-byte n1 3rd-byte )
swap 4 lshift                      \ ( 2nd-byte 3rd-byte 4th-byte )
swap                               \ ( 2nd-byte 4th-byte 3rd-byte )
rot                                \ ( 4th-byte 3rd-byte 2nd-byte )
r>                                 \ ( 4th-byte 3rd-byte 2nd-byte t/f )
3 0 do swap _eewrite or loop       \ ( t/f )
\ Stop I2C
_eestop 
err?
;

\ Write DAC register
\ command type (C2,C1,C0)=(0,1,0) 
\ ( n1 n2 -- )    n1:DAC data(12bit) n2:power-down bits 
: DAC_out_slow
wr_DAC swap                        \ ( n1 wr_DAC n2 )
DAC&EEPROM
;

\ Write DAC register and EEPROM
\ command type (C2,C1,C0)=(0,1,1) 
\ ( n1 n2 -- )    n1:DAC data(12bit) n2:power-down bits 
: wr_EEPROM
wr_DAC&EEPROM swap                 \ ( n1 wr_DAC&EEPROM n2 )
DAC&EEPROM
;

\ Read DAC register and eeprom
\ ( -- n1 n2 n3 n4 n5 )    n1:RDY=h80 BSY=0 n2:POR n3:DAC register n4:Power down bits n5:EEPROM
: rd_DAC&EEPROM
\ Start I2C 
_eestart
\ Write slave address[rd], AddressBits then receive Acknowledge-bit(ACK:Lo  NACK:Hi)   1st byte
MCP4725 1 or _eewrite              \ ( t/f )
>r                                                                              
\ Read from 2nd-byte to 5th-byte
4 0 do 0 _eeread loop
\ Read last byte
-1 _eeread                                                       
\ Stop I2C
_eestop                                                        
r> err?
\ 5th-byte & 6th-byte
over hF and 8 lshift or >r         \ EEPROM data
           
5 rshift 3 and >r                  \ EEPROM Power down bits
\ 3rd-byte & 4th-byte
4 rshift swap 4 lshift or >r       \ DAC register value(12bits)
\ 2nd-byte
dup 1 rshift 3 and >r              \ DAC register Power down bits
dup h40 and >r                     \ POR
h80 and                            \ RDY/BSY
r> r> r> r> r>                     \ ( RDY/BSY POR DAC-PD DAC EEPROM-PD EEPROM )     
;

\ Print TAB
\ ( -- )
: TAB 9 emit ;
\ Message for PowerDown Bits
\ ( -- )
: PD
0 over =
if TAB ." normal"
else 1 over =
if TAB ." 1k"
else 2 over =
if TAB ." 100k"
else TAB ." 500k"
thens 
drop cr
;

\ Display EEPROM, Power down bits, DAC-register and RDY/BSY
\ ( -- )
: disp_status
rd_DAC&EEPROM cr
." --- EEPROM ---" cr
." Value:" TAB TAB . cr
." PowerDownBits:"
PD cr
." --- DAC register ---" cr
." Value:" TAB TAB . cr
." PowerDownBits:" 
PD 
." Power On Reset:" TAB d64 = if h31 else h30 then emit cr
cr
." EEPROM Write Status:" h80 = if ." Ready" else ." Busy" then cr
cr
;


\ Output from 0V to 3.3V
\ Using [Fast] mode as Write command type
\ ( -- )    
: demo1
begin
     d4096 0 do
          i normal DAC_out
     loop
     d4096 0 do
          d4095 i - normal DAC_out
     loop
     fkey? swap drop
until
;

\ Output from 0V to 3.3V
\ Using [WriteDAC reg] as Write command type
\ ( -- )    
: demo2
begin
     d4096 0 do
          i normal DAC_out_slow
     loop
     d4096 0 do
          d4095 i - normal DAC_out_slow
     loop
     fkey? swap drop
until
;
