fl

{
PropForth 5.5(DevKernel)

eeprom(AT24C512) 64kbyte
Using i2c_utility_0.4.1.f 
2016/05/15 12:18:43

AT24C512  QuickStart
(Atmel)
Vcc -------- 3V3
SCL -------- SCL
SDA -------- SDA
A0  -------- 3V3
A1  -------- GND
WP  -------- GND
GND -------- GND

SlaveAddress   [A1 A0] 
h50            [0 0] Inhibit using this address 
h51            [0 1] addr[h0-hFFFF]
h52            [1 0] addr[h0-hFFFF]
h53            [1 1] addr[h0-hFFFF]

AT24C512C/24LC512    QuickStart
(Atmel)  (Microchip)
Vcc ---------------- 3V3
SCL ---------------- SCL
SDA ---------------- SDA
A0  ---------------- 3V3
A1  ---------------- GND
A2  ---------------- GND
WP  ---------------- GND
GND ---------------- GND

SlaveAddress   [A2 A1 A0] 
h50            [0 0 0] Inhibit using this address 
h51            [0 0 1] addr[h0-hFFFF]
h52            [0 1 0] addr[h0-hFFFF]
h53            [0 1 1] addr[h0-hFFFF]
h54            [1 0 0] addr[h0-hFFFF]
h55            [1 0 1] addr[h0-hFFFF]
h56            [1 1 0] addr[h0-hFFFF]
h57            [1 1 1] addr[h0-hFFFF]

}

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
\ Slave addres h51 for 24C512 
\ h50-h57:AT24C512C     
\ h50-h53:AT24C512
hA2 wconstant 24C512

\ =========================================================================== 
\ Variables 
\ =========================================================================== 
\ 128byte buffer
variable buffer d124 allot

\ =========================================================================== 
\ Main 
\ =========================================================================== 
\ Set dummy values in buffer
\ ( n1 -- ) n1:value[0..d255]
: setDummy
buffer
d128 0 do
     2dup C!
     swap 1+ swap 1+
loop
2drop
;     

\ Wite eeprom address
\ ( n1 n2 -- ) n1:eeprom address n2:t/f  n3:Lo-address n4:Hi-address
: addrWr
swap                          \ ( t/f n1 )
dup 8 rshift                  \ ( t/f Lo-address Hi-address )
\ Write address
_eewrite swap _eewrite or or  \ ( t/f )
;

\ Byte Write
\ ( n1 n2 n3 -- )   n1:byte data n2:eeprom Address n3:SlaveAddress
: byteWr
\ Start I2C 
_eestart
\ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi) 
_eewrite                      \ ( n1 n2 t/f )
\ Write eeprom address
addrWr
\ Write data
swap _eewrite or              \ ( t/f )
\ Stop I2C
_eestop                       
err?                          \ ( -- )
;

\ Page Write(Write buffer-data to eeprom)
\ ( n1 n2 n3 n4 -- )  n1:buffer address n2:data number n3:eeprom Address n4:SlaveAddress
: pageWr
\ Write slave address[wr], Check if eeprom is ready
begin _eestart dup _eewrite if 0 else drop 1 then until 
\ Acknowledge-bit(ACK:Lo)  
0                             \ ( n1 n2 n3 f )
\ Write eeprom address
addrWr
rot2                          \ ( t/f n1 n2 )
\ Write data
d128 min                      \ max 128byte 
bounds do
     i C@ _eewrite or         \ ( t/f )            
loop
\ Stop I2C
_eestop                       
err?                          \ ( -- )
;

\ Byte Read
\ ( n1 n2 -- n3 ) n1:eeprom address n2:SlaveAddress  n3:byte data
: byteRd
dup t0 W!                     \ Save SlaveAddress
\ Start I2C 
_eestart
\ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi) 
_eewrite                      \ ( n1 t/f )
\ Write eeprom address
addrWr
\ Start read_process
Sr
t0 W@                         \ Copy SlaveAddress  ( t/f n2 ) 
1 or _eewrite or              \ ( t/f )
\ Read 1byte ,then set sda to Hi(NACK:master->slave)
-1 _eeread             
\ Stop I2C
_eestop                                         
swap                          \ ( n3 t/f )
err?                          \ ( n3 )
;

\ Page Read (Read fromm eeprom to buffer)
\ ( n1 n2 n3 n4 --  )  n1:buffer Address n2:data number[must be more than 1] n3:eeprom Address n4:SlaveAddress
: pageRd
2 ST@ 1 >
if
     dup t0 W!                     \ Save SlaveAddress
     \ Start I2C 
     _eestart
     \ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi) 
     _eewrite                      \ ( n1 n2 n3 t/f )
     \ Write eeprom address
     addrWr
     \ Start read_process
     Sr
     t0 W@                         \ Copy SlaveAddress  ( n1 n2 t/f n4 )
     1 or _eewrite or              \ ( n1 n2 t/f )
     rot2                          \ ( t/f n1 n2 )
     \ read data
     d128 min                      \ max 128byte 
     \ Read n1 byte
     bounds do
          lasti? _eeread           \ ( t/f data )
          i C!                     \ Save data to buffer
     loop
     \ Stop I2C
     _eestop      
     err?                          \ ( -- )         
else
     3drop drop                    \ ( -- )
then
;

\ Display contents inside eeprom(1page=128byte)
\ ( n1 n2 n3 -- )  n1:SlaveAddress n2:start page number n3:end page number  (page number= 0 - 511)
: rdEEPROM
2dup <=                                 \ Check if n1 <= n2
if
     1+ d128 * swap d128 *              \ ( n1 [n3+1]+128 n2*128 -- )
     do
          \ Read 1 page from eeprom 
          buffer d128 i 3 ST@ pageRd
          \ Display 128 data inside buffer
          i                             \ ( n1 eeprom_address )    
          buffer d128 bounds
          do
               dup .word _ecs           \ ( n1 eeprom_address )  Print out eeprom_address
               \ Print out 16 data
               i d16 bounds
               do
               	i C@ .byte space
               loop
               \ Print out 16 characters
               2 spaces i d16 bounds
               do
                    i C@ dup bl h7E between invert
                    \ Print out "." if characters are except for h2E-h7E 
                    if drop h2E then emit              
               loop
               cr
               d16 +                    \ ( n1 eeprom_address+16 )
          d16 +loop
          drop
     d128 +loop                         \ ( n1 )
else
     2drop
then
drop 
;

\ Weiting test and Reading test
\ eeprom address [h0-h57F]
\ ( -- )
: demo
hex
d11 0 do
     \ Make dummy data
     i 4 + setDummy
     \ Write data from buffer to eeprom
     buffer d128 d128 i * 24C512 pageWr
loop
\ Check if eeprom is ready
begin _eestart 24C512 _eewrite 0= until
\ Display data reded data from eeprom
24C512 0 d10 rdEEPROM
decimal
;

