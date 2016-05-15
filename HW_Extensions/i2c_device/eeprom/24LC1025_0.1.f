fl

{
PropForth 5.5(DevKernel)

eeprom(24LC1025) 128kbyte
Using i2c_utility_0.4.1.f 
2016/05/15 14:00:49

24LC1025   QuickStart
Vcc -------- 3V3
SCL -------- SCL
SDA -------- SDA
A0  -------- GND
A1  -------- 3V3
A2  -------- 3V3
WP  -------- GND
GND -------- GND

SlaveAddress   [B0 A1 A0] MemoryAddress
h50            [0 0 0] Inhibit using this address
h54            [1 0 0] Inhibit using this address
h51            [0 0 1] addr[h0-hFFFF]
h55            [1 0 1] addr[h10000-h1FFFF]
h52            [0 1 0] addr[h0-hFFFF]
h56            [1 1 0] addr[h10000-h1FFFF]
h53            [0 1 1] addr[h0-hFFFF]
h57            [1 1 1] addr[h10000-h1FFFF]

}

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
\ Slave addres h51(A0=0 A1=1) for 24LC1025 
hA4 wconstant 24LC1025
8 wconstant B0

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

\ Check if eeprom addres is more than h10000
\ ( n1 n2 -- )   n1:eeprom Address n2:SlaveAddress
: addrCheck
\ Check eeprom address 
over h10000 and
if
     B0 or                    \ Add B0 to SlaveAddress
     swap hFFFF and swap      \ Modify eeprom address
then
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

\ Byte Write for 24LC1025
\ ( n1 n2 n3 -- )   n1:byte data n2:eeprom Address n3:SlaveAddress
: byteWr_1025 addrCheck byteWr ;
 
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

\ Page Write(Write buffer-data to eeprom) for 24LC1025
\ ( n1 n2 n3 n4 -- )  n1:buffer address n2:data number n3:eeprom Address n4:SlaveAddress
: pageWr_1025 addrCheck pageWr ;


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

\ Byte Read for 24LC1025
\ ( n1 n2 -- n3 ) n1:eeprom address n2:SlaveAddress  n3:byte data
: byteRd_1025 addrCheck byteRd ;

\ Page Read (Read fromm eeprom to buffer) 
\ ( n1 n2 n3 n4 --  )  n1:buffer Address n2:data number[must be more than 1] n3:eeprom Address n4:SlaveAddress
: pageRd
addrCheck 
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

\ Page Read (Read fromm eeprom to buffer) for 24LC1025
\ ( n1 n2 n3 n4 --  )  n1:buffer Address n2:data number[must be more than 1] n3:eeprom Address n4:SlaveAddress
: pageRd_1025 addrCheck pageRd ;

\ Display contents inside eeprom(1page=128byte) for 24LC1025
\ ( 0 n2 n3 n4 -- )  n1:SlaveAddress n2:start page number n3:end page number   (page number= 0 - 511 or 512 - 1023)
: rdEEPROM_1025
2dup <=                                 \ Check if n1 <= n2
if
     1 ST@ d511 >
     if
          rot                           \ ( 0 n2 n3 n1 )
          B0 or                         \ Add B0 to SlaveAddress
          rot d512 -                    \ ( 0 n3 n1 n2 )
          rot d512 -                    \ ( 0 n1 n2 n3 )
          1 3 ST!                       \ ( t n1 n2 n3 ))
     then                                                  
     1+ d128 * swap d128 *              \ ( t/f n1 [n3+1]+128 n2*128 -- )
     do
          \ Read 1 page from eeprom 
          buffer d128 i 3 ST@ pageRd
          \ Display 128 data inside buffer
          i                             \ ( t/f n1 eeprom_address )    
          buffer d128 bounds
          do
               2 ST@ if h31 emit then
               dup .word _ecs           \ ( t/f n1 eeprom_address )  Print out eeprom_address
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
               d16 +                    \ ( t/f n1 eeprom_address+16 )
          d16 +loop
          drop
     d128 +loop                         \ ( t/f n1 )
else
     2drop 
then
2drop 
;

\ Weiting test and Reading test
\ eeprom address [h0-h57F]
\ ( -- )
: demo1
hex
d11 0 do
     \ Make dummy data
     i 5 + setDummy
     \ Write data from buffer to eeprom
     buffer d128 d128 i * 24LC1025 pageWr_1025
loop
\ Check if eeprom is ready
begin _eestart 24LC1025 _eewrite 0= until
\ Display data reded data from eeprom
0 24LC1025 0 d10 rdEEPROM_1025
decimal
;

\ Weiting test and Reading test
\ eeprom address [h10000-h1057F]
\ ( -- )
: demo2
hex
d11 0 do
     \ Make dummy data
     i 3 + setDummy
     \ Write data from buffer to eeprom
     buffer d128 d128 i * d65536 + 24LC1025 pageWr_1025
loop
\ Check if eeprom is ready
begin _eestart 24LC1025 _eewrite 0= until
\ Display data reded data from eeprom
0 24LC1025 d512 d522 rdEEPROM_1025
decimal
;

