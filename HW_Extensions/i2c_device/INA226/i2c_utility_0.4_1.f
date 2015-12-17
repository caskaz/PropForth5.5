fl

{
PropForth5.5(DevKernel)

i2c_utility
2015/10/24 13:55:02

Modified to be able to use i2c-device(Fast-mode,Standard mode) and SMBus device
}


: err_msg ." I2C error" ;
\ If error, print message
\ ( n1 -- )   n1:t/f
: err? if err_msg cr then ;

\ Start i2c-commnication 
\ This also can use SMBus device.
\ ( -- )
lockdict create _eestart forthentry
$C_a_lxasm w, h122  h113  1- tuck - h9 lshift or here W@ alignl h10 lshift or l,
z1[ixnW l, z1[ixnX l, z2WyP[U l, z20iPak l, z3ryPW0 l, z1bixnW l, z2WyP[V l, z20iPak l,
z3ryPW0 l, z1bixnX l, z1SV01X l, zl0 l, zCW l, zW0000 l, zG0000 l,
freedict

\ Re-defined RepeatedStart
\ ( -- )
: Sr _eestart ;

\ Stop i2c-commnication 
\ ( -- )
: _eestop
_scli     \ Release scl 
_sdai     \ Release sda
;

\ When SDA-line is stuck LOW, master should send nine clock-pulse.
\ ( -- )
: bus_clr d10 0 do _scll _sclo _scli loop ;

\ =========================================================================== 
\ Fast-mode(400kHz) i2c     
\ =========================================================================== 

\ _eewrite ( c1 -- t/f ) write c1 to the eeprom, true if there was an error
\ Received acknowledge from i2c-device during scl is high
\ scl/sda use pull-up resistor at hi
\ clock:400kHz
lockdict create _eewrite forthentry
$C_a_lxasm w, h12C  h113  1- tuck - h9 lshift or here W@ alignl h10 lshift or l,
z2WyPW8 l, z1YVPQ0 l, z1rixnd l, z1Sy\C] l, z1[ixne l, z1Sy\C] l, z1bixne l, zfyPO1 l,
z3[yP[K l, z1[ixnd l, z1Sy\C] l, z1[ixne l, z1Sy\C] l, z1YF\Nl l, z1viPR6 l, z1bixne l,
z1Sy\C] l, z1bixnd l, z1SV01X l, z2WyPc7 l, z20iPik l, z3ryPb0 l, z1SV000 l, zW0000 l,
zG0000 l,
freedict

\ _eeread ( t/f -- c1 ) flag should be true is this is the last read
\ scl/sda use pull-up resistor at hi
\ clock:400kHz
lockdict create _eeread forthentry
$C_a_lxasm w, h12D  h113  1- tuck - h9 lshift or here W@ alignl h10 lshift or l,
z2WiPZB l, z2WyPO0 l, z1[ixne l, z2WyPj8 l, z1Sy\Ka l, z1[ixnf l, z1Sy\Ka l, z1XF\Vl l,
znyPO1 l, z1bixnf l, z3[yPnN l, z26VPW0 l, z1rixne l, z1Sy\Ka l, z1[ixnf l, z1Sy\Ka l,
z1bixnf l, z1bixne l, z1Sy\Ka l, z1SV01X l, z2WyPc9 l, z20iPik l, z3ryPb0 l, z1SV000 l,
zW0000 l, zG0000 l,
freedict

\ Write data to register in i2c_device
\ ( n1 n2 n3 -- )  n1:data  n2:register  n3:slave_address  
: i2c_wr
\ Start I2C 
_eestart
\ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi) 
_eewrite                      \ ( n1 n2 t/f )
\ Write register
swap _eewrite or              \ ( n1 t/f )
\ Write data   
swap _eewrite or              \ ( t/f )   
\ Stop I2C
_eestop                       
err?                          \ ( -- )
;

\ Write series data to register in i2c_device
\ ( n1..nn n2 n3 n4 -- )   n1..nn:data  n2:number  n3:register  n4:slave_address  
: i2c_wr_multi
\ Start I2C 
_eestart
\ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi) 
_eewrite                                \ ( n1..nn n2 n3 t/f )
\ Write register                   
swap _eewrite or                        \ ( n1..nn n2 t/f )
swap                                    \ ( n1..nn t/f n2 )
\ Read n2 byte
dup 1 >
if                                      \ ( n1..nn t/f n2 )                 
     0 do                               \ ( n1..nn t/f )
          swap _eewrite or              \ ( n1.. nn t/f ) 
     loop
else                                    \ ( n1 t/f n2 )     
     drop swap _eewrite or              \ ( t/f )
then               
\ Stop I2C
_eestop 
err?                                    \ ( -- )
;

\ Read data from register in i2c_device
\ ( n1 n2 -- n3 )  n1:register  n2:slave_address  n3:data 
: i2c_rd
\ Start I2C 
_eestart
\ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi)   
tuck _eewrite                 \ ( n2 n1 t/f )
\ Write register
swap _eewrite or              \ ( n2 t/f )
swap                          \ ( t/f n2 )
\ Start read_process
Sr
\ Write slave address[rd], then receive Acknowledge-bit(ACK:Lo  NACK:Hi)
1 or _eewrite or              \ ( t/f )
\ Read 1byte ,then set sda to Hi(NACK:master->slave)
-1 _eeread             
\ Stop I2C
_eestop                                         
swap                         \ (n3 t/f )
err?                         \ ( n3 )
;

\ Read sereis data from series register in i2c_device
\ ( n1 n2 n3 -- n4 . . nn )  n1:number  n2:register  n3:slave_address  n4..nn:series data  
: i2c_rd_multi
\ Start I2C 
_eestart
\ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi)  
tuck _eewrite                 \ ( n1 n3 n2 t/f )
\ Write register
swap _eewrite or              \ ( n1 n3 t/f )
swap                          \ ( n1 t/f n3 )
\ Repeated Start read_process
Sr
\ Write slave address[rd], then receive Acknowledge-bit(ACK:Lo  NACK:Hi)
1 or 
_eewrite or                   \ ( n1 t/f )
\ Read (n1-1)bytes
>r                            \ Push flag  ( n1 )
dup 1 > 
if 
     1 - 0 do 
          0 _eeread           \ ( n4..nn-1 )
     loop
else
     drop
then
\ Read 1byte ,then set sda to Hi(NACK:master->slave)
-1 _eeread                    \ ( n4..nn )
r>                            \ Pop flag   ( n4..nn t/f )
\ Stop I2C
_eestop      
err?                          \ ( n4..nn )         
;

\ Display connected i2c-device's slave-address
\ This also can use SMBus device.
\ ( -- )
: i2c_detect
hex
\ Print lower
."      0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F" cr
\ ( n1 n2 ) n1:reserve address 's count n2:i2c_device's count n3:i2c_address
0 0 0 
8 0 do
     \ Print 1-line
     dup .byte h3A emit space           
     d16 0 do
          \ Start I2C 
          _eestart
          \ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi)   
          dup i + 1 lshift _eewrite 0=                      
          if                                 \ there is ACK 
               dup i + dup .byte             \ Get slave-addres
               dup 7 > swap h78 < and        \ 0 to 7 and h78 to h7F
               if 
                    swap 1+ swap             \ Count up device (eliminate reserve number)
               else 
                    rot 1+ rot2
               then     
          else 
               ." --" 
          then 
          space 
          \ Stop I2C
          _eestop                                       
     loop
     cr
     \ next line
     d16 +                                                      
loop
drop
decimal
." i2c_device:" . cr  
0> if ." [0 - 7] and [h78 - h7F] are reserve-address" then cr
cr
;

\ =========================================================================== 
\ standard mode(100kHz) i2c    Also SMBus
\ =========================================================================== 

\ std_eewrite ( c1 -- t/f ) write c1 to the eeprom, true if there was an error
\ Received acknowledge from i2c-device during scl is high
\ scl/sda use pull-up resistor at hi
\ clock:100kHz
lockdict create std_eewrite forthentry
$C_a_lxasm w, h12C  h113  1- tuck - h9 lshift or here W@ alignl h10 lshift or l,
z2WyPW8 l, z1YVPQ0 l, z1rixnd l, z1Sy\C] l, z1[ixne l, z1Sy\C] l, z1bixne l, zfyPO1 l,
z3[yP[K l, z1[ixnd l, z1Sy\C] l, z1[ixne l, z1Sy\C] l, z1YF\Nl l, z1viPR6 l, z1bixne l,
z1Sy\C] l, z1bixnd l, z1SV01X l, z2WyPh3 l, z20iPik l, z3ryPb0 l, z1SV000 l, zW0000 l,
zG0000 l,
freedict

\ std_eeread ( t/f -- c1 ) flag should be true is this is the last read
\ scl/sda use pull-up resistor at hi
\ clock:100kHz
lockdict create std_eeread forthentry
$C_a_lxasm w, h12D  h113  1- tuck - h9 lshift or here W@ alignl h10 lshift or l,
z2WiPZB l, z2WyPO0 l, z1[ixne l, z2WyPj8 l, z1Sy\Ka l, z1[ixnf l, z1Sy\Ka l, z1XF\Vl l,
znyPO1 l, z1bixnf l, z3[yPnN l, z26VPW0 l, z1rixne l, z1Sy\Ka l, z1[ixnf l, z1Sy\Ka l,
z1bixnf l, z1bixne l, z1Sy\Ka l, z1SV01X l, z2WyPh3 l, z20iPik l, z3ryPb0 l, z1SV000 l,
zW0000 l, zG0000 l,
freedict

\ Write data to register in i2c_device
\ ( n1 n2 n3 -- )  n1:data  n2:register  n3:slave_address 
: std_i2c_wr
\ Start I2C 
_eestart
\ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi) 
std_eewrite                   \ ( n1 n2 t/f )
\ Write register
swap std_eewrite or           \ ( n1 t/f )
\ Write data   
swap std_eewrite or           \ ( t/f )   
\ Stop I2C
_eestop 
err?                          \ ( -- )
;

\ Write series data to register in i2c_device
\ ( n1..nn n2 n3 n4 -- )   n1..nn:data  n2:number  n3:register  n4:slave_address  
: std_i2c_wr_multi
\ Start I2C 
_eestart
\ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi) 
std_eewrite                        \ ( n1..nn n2 n3 t/f )
\ Write register                   
swap std_eewrite or                \ ( n1..nn n2 t/f )
swap                               \ ( n1..nn t/f n2 )
\ Read n2 byte
dup 1 >
if                                 \ ( n1..nn t/f n2 )                 
     0 do                          \ ( n1..nn t/f )
          swap std_eewrite or      \ ( n1.. nn t/f ) 
     loop
else                               \ ( n1 t/f n2 )     
     drop swap std_eewrite or      \ ( t/f )
then               
\ Stop I2C
_eestop 
err?                               \ ( -- )
;

\ Read data from register in i2c_device
\ ( n1 n2 -- n3 )  n1:register  n2:slave_address  n3:data  
: std_i2c_rd
\ Start I2C 
_eestart
\ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi)   
tuck std_eewrite              \ ( n2 n1 t/f )
\ Write register
swap std_eewrite or           \ ( n2 t/f )
swap                          \ ( t/f n2 )
\ Start read_process
Sr
\ Write slave address[rd], then receive Acknowledge-bit(ACK:Lo  NACK:Hi)
1 or std_eewrite or           \ ( t/f )
\ Read 1byte ,then set sda to Hi(NACK:master->slave)
-1 std_eeread             
\ Stop I2C
_eestop                                         
swap                          \ ( n3 t/f )
err?                          \ ( n3 )
;

\ Read sereis data from series register in i2c_device
\ ( n1 n2 n3 -- n4 . . nn )  n1:number  n2:register  n3:slave_address  n4..nn:series data  
: std_i2c_rd_multi
\ Start I2C 
_eestart
\ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi)  
tuck std_eewrite              \ ( n1 n3 n2 t/f )
\ Write register
swap std_eewrite or           \ ( n1 n3 t/f )
swap                          \ ( n1 t/f n3 )
\ Repeated Start read_process
Sr
\ Write slave address[rd], then receive Acknowledge-bit(ACK:Lo  NACK:Hi)
1 or 
std_eewrite or                \ ( n1 t/f )
\ Read (n1-1)bytes
>r                            \ Push flag  ( n1 )
dup 1 > 
if 
     1 - 0 do 
          0 std_eeread        \ ( n4..nn-1 )
     loop
else
     drop
then
\ Read 1byte ,then set sda to Hi(NACK:master->slave)
-1 std_eeread                 \ ( n4..nn )
r>                            \ Pop flag   ( n4..nn t/f )
\ Stop I2C
_eestop                                         
err?                          \ ( n4..nn )
;

\ Display connected i2c-device's slave-address
\ This also can use SMBus device.
\ ( -- )
: std_i2c_detect
hex
\ Print lower
."      0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F" cr
\ ( n1 n2 ) n1:reserve address 's count n2:i2c_device's count n3:i2c_address
0 0 0 
8 0 do
     \ Print 1-line
     dup .byte h3A emit space           
     d16 0 do
          \ Start I2C 
          _eestart
          \ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi)   
          dup i + 1 lshift std_eewrite 0=                      
          if                                 \ there is ACK 
               dup i + dup .byte             \ Get slave-addres
               dup 7 > swap h78 < and        \ 0 to 7 and h78 to h7F
               if 
                    swap 1+ swap             \ Count up device (eliminate reserve number)
               else 
                    rot 1+ rot2
               then     
          else 
               ." --" 
          then 
          space 
          \ Stop I2C
          _eestop                                       
     loop
     cr
     \ next line
     d16 +                                                      
loop
drop
decimal
." i2c_device:" . cr  
0> if ." [0 - 7] and [h78 - h7F] are reserve-address" then cr
cr
;
