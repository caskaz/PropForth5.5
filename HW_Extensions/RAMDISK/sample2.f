flRAM

{
Sample code
Loading this code by using RAMDISK
2016/08/27 16:36:24
}
{
PropForth5.5(DevKernel)

i2c_utility
2016/05/24 14:37:08

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
\ Read n1 byte
>r                            \ Push flag ( n1 )
0 do
     lasti? _eeread           \ ( t/f n4..nn )
loop
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
\ Read n1 byte
>r                            \ Push flag  ( n1 )
0 do
     lasti? std_eeread        \ ( t/f n4..nn )
loop
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


{
PropForth 5.5(DevKernel)

128x32dots OLED LCD Controller SSD1306
Using i2c_utility_0.4.2.f   
2016/08/11 8:58:24

OLED display(128X32)   Propeller
           VDD    ----  3.3V
           GND    ----  GND
           RES    ----  P4      
           SCL    ----  P28   
           SDA    ----  P29   
}

\ =========================================================================== 
\ 8X8 Font Characters for OLED
\ =========================================================================== 
wvariable Font -2 allot
h00 c, h00 c, h00 c, h00 c, h00 c, h00 c, h00 c, h00 c,
h00 c, h06 c, h5F c, h5F c, h06 c, h00 c, h00 c, h00 c,
h00 c, h03 c, h07 c, h00 c, h07 c, h03 c, h00 c, h00 c,
h14 c, h7F c, h7F c, h14 c, h7F c, h7F c, h14 c, h00 c,
h24 c, h2E c, h2A c, h6B c, h6B c, h3A c, h12 c, h00 c,
h46 c, h66 c, h30 c, h18 c, h0C c, h66 c, h62 c, h00 c,
h30 c, h7A c, h4F c, h5D c, h37 c, h7A c, h48 c, h00 c,
h00 c, h04 c, h07 c, h03 c, h00 c, h00 c, h00 c, h00 c,
h00 c, h1C c, h3E c, h63 c, h41 c, h00 c, h00 c, h00 c,
h00 c, h41 c, h63 c, h3E c, h1C c, h00 c, h00 c, h00 c,
h08 c, h2A c, h3E c, h1C c, h1C c, h3E c, h2A c, h08 c,
h08 c, h08 c, h3E c, h3E c, h08 c, h08 c, h00 c, h00 c,
h00 c, h80 c, hE0 c, h60 c, h00 c, h00 c, h00 c, h00 c,
h08 c, h08 c, h08 c, h08 c, h08 c, h08 c, h00 c, h00 c,
h00 c, h00 c, h60 c, h60 c, h00 c, h00 c, h00 c, h00 c,
h60 c, h30 c, h18 c, h0C c, h06 c, h03 c, h01 c, h00 c,
h3E c, h7F c, h41 c, h49 c, h41 c, h7F c, h3E c, h00 c,
h40 c, h42 c, h7F c, h7F c, h40 c, h40 c, h00 c, h00 c,
h62 c, h73 c, h59 c, h49 c, h6F c, h66 c, h00 c, h00 c,
h22 c, h63 c, h49 c, h49 c, h7F c, h36 c, h00 c, h00 c,
h18 c, h1C c, h16 c, h53 c, h7F c, h7F c, h50 c, h00 c,
h27 c, h67 c, h45 c, h45 c, h7D c, h39 c, h00 c, h00 c,
h3C c, h7E c, h4B c, h49 c, h79 c, h30 c, h00 c, h00 c,
h03 c, h03 c, h71 c, h79 c, h0F c, h07 c, h00 c, h00 c,
h36 c, h7F c, h49 c, h49 c, h7F c, h36 c, h00 c, h00 c,
h06 c, h4F c, h49 c, h69 c, h3F c, h1E c, h00 c, h00 c,
h00 c, h00 c, h66 c, h66 c, h00 c, h00 c, h00 c, h00 c,
h00 c, h80 c, hE6 c, h66 c, h00 c, h00 c, h00 c, h00 c,
h08 c, h1C c, h36 c, h63 c, h41 c, h00 c, h00 c, h00 c,
h24 c, h24 c, h24 c, h24 c, h24 c, h24 c, h00 c, h00 c,
h00 c, h41 c, h63 c, h36 c, h1C c, h08 c, h00 c, h00 c,
h02 c, h03 c, h51 c, h59 c, h0F c, h06 c, h00 c, h00 c,
h3E c, h7F c, h41 c, h5D c, h5D c, h1F c, h0E c, h00 c,
h7C c, h7E c, h13 c, h13 c, h7E c, h7C c, h00 c, h00 c,
h41 c, h7F c, h7F c, h49 c, h49 c, h7F c, h36 c, h00 c,
h1C c, h3E c, h63 c, h41 c, h41 c, h63 c, h22 c, h00 c,
h41 c, h7F c, h7F c, h41 c, h63 c, h3E c, h1C c, h00 c,
h41 c, h7F c, h7F c, h49 c, h5D c, h41 c, h63 c, h00 c,
h41 c, h7F c, h7F c, h49 c, h1D c, h01 c, h03 c, h00 c,
h1C c, h3E c, h63 c, h41 c, h51 c, h73 c, h72 c, h00 c,
h7F c, h7F c, h08 c, h08 c, h7F c, h7F c, h00 c, h00 c,
h00 c, h41 c, h7F c, h7F c, h41 c, h00 c, h00 c, h00 c,
h30 c, h70 c, h40 c, h41 c, h7F c, h3F c, h01 c, h00 c,
h41 c, h7F c, h7F c, h08 c, h1C c, h77 c, h63 c, h00 c,
h41 c, h7F c, h7F c, h41 c, h40 c, h60 c, h70 c, h00 c,
h7F c, h7F c, h0E c, h1C c, h0E c, h7F c, h7F c, h00 c,
h7F c, h7F c, h06 c, h0C c, h18 c, h7F c, h7F c, h00 c,
h1C c, h3E c, h63 c, h41 c, h63 c, h3E c, h1C c, h00 c,
h41 c, h7F c, h7F c, h49 c, h09 c, h0F c, h06 c, h00 c,
h1E c, h3F c, h21 c, h71 c, h7F c, h5E c, h00 c, h00 c,
h41 c, h7F c, h7F c, h09 c, h19 c, h7F c, h66 c, h00 c,
h26 c, h6F c, h49 c, h49 c, h7B c, h32 c, h00 c, h00 c,
h03 c, h41 c, h7F c, h7F c, h41 c, h03 c, h00 c, h00 c,
h7F c, h7F c, h40 c, h40 c, h7F c, h7F c, h00 c, h00 c,
h1F c, h3F c, h60 c, h60 c, h3F c, h1F c, h00 c, h00 c,
h7F c, h7F c, h30 c, h18 c, h30 c, h7F c, h7F c, h00 c,
h61 c, h73 c, h1E c, h0C c, h1E c, h73 c, h61 c, h00 c,
h07 c, h4F c, h78 c, h78 c, h4F c, h07 c, h00 c, h00 c,
h47 c, h63 c, h71 c, h59 c, h4D c, h67 c, h73 c, h00 c,
h00 c, h7F c, h7F c, h41 c, h41 c, h00 c, h00 c, h00 c,
h01 c, h03 c, h06 c, h0C c, h18 c, h30 c, h60 c, h00 c,
h00 c, h41 c, h41 c, h7F c, h7F c, h00 c, h00 c, h00 c,
h08 c, h0C c, h06 c, h03 c, h06 c, h0C c, h08 c, h00 c,
h80 c, h80 c, h80 c, h80 c, h80 c, h80 c, h80 c, h80 c,
h00 c, h00 c, h01 c, h03 c, h06 c, h04 c, h00 c, h00 c,
h20 c, h74 c, h54 c, h54 c, h3C c, h78 c, h40 c, h00 c,
h41 c, h7F c, h3F c, h48 c, h48 c, h78 c, h30 c, h00 c,
h38 c, h7C c, h44 c, h44 c, h6C c, h28 c, h00 c, h00 c,
h30 c, h78 c, h48 c, h49 c, h3F c, h7F c, h40 c, h00 c,
h38 c, h7C c, h54 c, h54 c, h5C c, h18 c, h00 c, h00 c,
h48 c, h7E c, h7F c, h49 c, h03 c, h02 c, h00 c, h00 c,
h98 c, hBC c, hA4 c, hA4 c, hF8 c, h7C c, h04 c, h00 c,
h41 c, h7F c, h7F c, h08 c, h04 c, h7C c, h78 c, h00 c,
h00 c, h44 c, h7D c, h7D c, h40 c, h00 c, h00 c, h00 c,
h60 c, hE0 c, h80 c, h80 c, hFD c, h7D c, h00 c, h00 c,
h41 c, h7F c, h7F c, h10 c, h38 c, h6C c, h44 c, h00 c,
h00 c, h41 c, h7F c, h7F c, h40 c, h00 c, h00 c, h00 c,
h7C c, h7C c, h08 c, h38 c, h0C c, h7C c, h78 c, h00 c,
h7C c, h7C c, h04 c, h04 c, h7C c, h78 c, h00 c, h00 c,
h38 c, h7C c, h44 c, h44 c, h7C c, h38 c, h00 c, h00 c,
h84 c, hFC c, hF8 c, hA4 c, h24 c, h3C c, h18 c, h00 c,
h18 c, h3C c, h24 c, hA4 c, hF8 c, hFC c, h84 c, h00 c,
h44 c, h7C c, h78 c, h4C c, h04 c, h1C c, h18 c, h00 c,
h48 c, h5C c, h54 c, h54 c, h74 c, h24 c, h00 c, h00 c,
h00 c, h04 c, h3E c, h7F c, h44 c, h24 c, h00 c, h00 c,
h3C c, h7C c, h40 c, h40 c, h3C c, h7C c, h40 c, h00 c,
h1C c, h3C c, h60 c, h60 c, h3C c, h1C c, h00 c, h00 c,
h3C c, h7C c, h60 c, h38 c, h60 c, h7C c, h3C c, h00 c,
h44 c, h6C c, h38 c, h10 c, h38 c, h6C c, h44 c, h00 c,
h9C c, hBC c, hA0 c, hA0 c, hFC c, h7C c, h00 c, h00 c,
h4C c, h64 c, h74 c, h5C c, h4C c, h64 c, h00 c, h00 c,
h08 c, h08 c, h3E c, h77 c, h41 c, h41 c, h00 c, h00 c,
h00 c, h00 c, h7F c, h7F c, h00 c, h00 c, h00 c, h00 c,
h41 c, h41 c, h77 c, h3E c, h08 c, h08 c, h00 c, h00 c,
h02 c, h03 c, h01 c, h03 c, h02 c, h03 c, h01 c, h00 c,
h4C c, h5E c, h73 c, h01 c, h73 c, h5E c, h4C c, h00 c,

\ =========================================================================== 
\ Constants for OLED
\ =========================================================================== 
\ OLED LCD
\ Slave addres h3C for OLED display(128X32)  sa0=0
h78 wconstant OLED

\ Addressing mode
1 wconstant hrz     \ Horizontal Addressing
2 wconstant vrt     \ Vertical Addressing

\ Initialize by values for SSD1306-registers
\ Default values are comment.
\ Set Vertical Addressing Mode
wvariable init_tbl -2 allot
\ hAE            \ Display Off sleep-mode (Default)

\ hD5          \ DisplayClock, Ratio/Oscillatpr
\ h80          \    (Default valuue)

hA8 c,         \ Multiplex Ratio
h1F c,         \    1/32 duty

\ hD3          \ Display Offset
\ h00          \    (Default valuue)

h40 c,         \ Display RAM display start line (Default valuue)

h8D c,         \ Charge Pump Setting
h14 c,         \    Ensble Charge Pump

h20 c,         \ Memory Addressing Mode 
h01 c,         \    Vertical Addressing Mode
h21 c,         \ Column Address 
h00 c,         \    Column Start Address (Default)
h7F c,         \    Column End Address   (Default)
h22 c,         \ Page Address 
h00 c,         \    Page Start Address
h03 c,         \    Page End Address


\ hA4          \ Entire Display ON (Default)

\ hA0          \ Segment Re-map (Default)

\ hC0          \ COM output, Scan direction normal mode (Default)

hDA c,         \ COM Pins
h02 c,         \      Sequential COM pin(Default), Disable COM left/right remap

\ h81          \ Contrast control
\ h7F          \    (Default valuue)

\ hD9          \ Ptr-charge Period
\ h22          \    (Default valuue)

hDB c,         \ Vcomh Deselect Level
h30 c,         \ 0.83Vcc

\ hA6          \ Normal Display (Default)

hAF c,         \ Display On

\ =========================================================================== 
\ Variables
\ =========================================================================== 
\ video ram[addong 1-line] for 128x32dots (128x40/8)
variable vram d508 allot

\ Character position on OLED_LCD
\ Vertical mode (0,0)-(7,0)
\ Horizontal mode (0,0)-(15,3)
wvariable vidX
wvariable vidY
wvariable max_vidX

\ Displat-status for OLED-LCD(hrz or vrt)
wvariable disp_mode

\ Variables for prop_font
variable row_line
variable odd

\ =========================================================================== 
\ Main
\ =========================================================================== 

\ Write controlbyte
\ ( n1 -- t/f )   n1:0=command, 1=data  t/f:true if there was an error
: controlbyte if h40 else h80 then _eewrite ;

\ Send command to SSD1306
\ ( n1 n2 -- n3 )  n1:t/f(previous result) command data   n3:t/f
: command
0 controlbyte            \ ( n1 n2 t/f ) 
swap                     \ ( n1 t/f n2 )
_eewrite or              \ ( n1 t/f )
or                       \ ( t/f )
;

\ Adjust contrast [default:h7F]
\ ( n1 -- ) n1:contrast value[1-255]
: contrast 
\ Start I2C 
_eestart
\ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi) 
OLED _eewrite            \ ( n1 t/f )
h81 command              \ ( n1 t/f )
swap command             \ ( t/f )
\ Stop I2C
_eestop 
err?
;

\ Initialize SSD1306 on vertical addressing mode
\ ( -- )
: init_oled
\ Start I2C 
_eestart
\ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi) 
OLED _eewrite                                         
\ Write values to setting registers 
d18 0 do
     \ Write command
     i init_tbl + C@ command 
loop
\ Stop I2C
_eestop 
err?
;

\ Set addressing mode (Not using Page addressing mode)
\ ( n1 -- )  n1:hrz=1, vrt=2 
: set_mode
dup disp_mode W!
\ Start I2C 
_eestart
\ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi) 
OLED _eewrite            \ ( n1 t/f )
h20 command              \ Memory Addressing Mode
swap                     \ ( t/f n1 )
1 =               
if                       \ ( t/f )
     \ Horizontal
     h00 command         \    Horizontal Addressing Mode
                         \ ( t/f )
else      
     \ Vertical
     h01 command         \    Vertical Addressing Mode
                         \ ( t/f )
then
h21 command         \ Column Address 
h00 command         \    Column Start Address (Default)
h7F command         \    Column End Address   (Default)
h22 command         \ Page Address 
h00 command         \    Page Start Address
h03 command         \    Page End Address
\ Stop I2C
_eestop 
err?
;

{
128x32dots
 0  1  2  .  . 126 127 _
D0 D0 D0 D0 D0  D0  D0 |
.  .  .  .  .   .   .  | PAGE0
.  .  .  .  .   .   .  |
D7 D7 D7 D7 D7  D7  D7 _
D0 D0 D0 D0 D0  D0  D0 |
.  .  .  .  .   .   .  | PAGE1 
.  .  .  .  .   .   .  |
D7 D7 D7 D7 D7  D7  D7  _
D0 D0 D0 D0 D0  D0  D0 |
.  .  .  .  .   .   .  | PAGE2  
.  .  .  .  .   .   .  |
D7 D7 D7 D7 D7  D7  D7 _
D0 D0 D0 D0 D0  D0  D0 |
.  .  .  .  .   .   .  | PAGE3  
.  .  .  .  .   .   .  |
D7 D7 D7 D7 D7  D7  D7 _
}                                                                              
\ Clear GDDRAM on Horizontal/Vertical Addressing Mode
\ ( -- )
: clr_mem
\ Start I2C 
4 0 do
     _eestart
     \ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi) 
     OLED _eewrite                                         
     1 controlbyte or
     \ Write o to GDDRAM(128byte X 4)
     d512 0 do 0 _eewrite or loop         
     \ Stop I2C
     _eestop 
     err?
loop
;

\ Clear vram
\ ( -- )
: clr_vram vram d128 0 do dup 0 swap L! 4+ loop drop ;

\ Copy vram to OLED-LCD's GDDRAM
\ ( -- )
: disp_OLED_LCD
\ Start I2C 
_eestart
\ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi) 
OLED _eewrite           
1 controlbyte or

\ Copy vram to GDDRAM
d512 0 do 
     vram i + C@ 
     _eewrite or 
loop         
\ Stop I2C
_eestop 
err?
;

\ Write 1-character[8x8] to vram
\ 8x8-FONT on (0,0)-(3,15)
\ ( n1 n2 n3 -- )  n1:character  n2:x-position[0 - 15] n3:y-position[0 - 3]
: lcd_char_8x8
d16 u* + 8 u* vram +               \ Get vram's address
swap                               \ ( vram-address character )
                                    
\  Get 8x8-character                            
h20 - 8 u* Font +                  \ Get Font address
\ Copy character to vram           \ ( vram_address Font-address )
8 0 do
     2dup                          \ ( vram_address Font-address vram_address Font-address )
     C@ swap C!                    \ Copy font-data to vram
     1+ swap 1+ swap               \ ( vram_address+1 Font-address+1 )
loop
2drop 
;

\ Get prop-character 
{
                Even-character is even-bits. (bit30,28,26,24,....4,2,0)
address          column ----->          
row  n          b31 b30 b29 . . . b1  b0
 |   n+4         0   0   0        0   0
 |   .
 |   .
\|/  n+d124      0   0   0        0   0
 
}
\ row_line n      --> character's top
\ row_line n+d124 --> character's bottom
\                                                  variable row_line
\                                                variable odd
\ ( n1 n2 -- )  n1:vram-address  n2:character code
: prop_char
dup 1 and if 2 else 1 then odd L!       \ Check even/odd
hFE and
d64 u* h8000 +                          \ Get ROM Font address

\ column=d16
d16 0 do
     dup                                               \ ( vram-address font-address font-address )
    
     d32 0 do
          row_line L@ 1 rshift row_line L!             \ Shift row_line to right
          dup L@ odd L@                                \ ( vram-address font-address font-address data odd )
          and                                          \ ( vram-address font-address font-address t/f )          
          if 
               row_line L@ h80000000 or row_line L!    \ Uodate bit-data of row_line 
          then                                         \ ( vram-address font-address font-address )
          \ Add 4 to font-address   ( to next row )       
          4 +                                          \ ( vram-address font-address font-address+4 )
     loop     
     drop
     
     \ --- Copy 32bit-data to vram ---
     swap                                              \ ( font-address vram-address )
     4 0 do
          dup                                          \ ( font-address vram-address vram-address )
          i row_line + C@ 
          swap C!                                      \ Save data to vram
          1+                                           \ ( font-address vram-address+1 )
     loop
     swap                                              \ ( vram-address font-address )
{     
     \ --- Print character to TeraTerm window ----
           row_line L@ h80000000
           d32 0 do 2dup and if h41 else h20 then emit 1 rshift loop
           2drop cr
     \ -------------------------------------------
}     
     \ next colummn bit
     odd L@ 2 lshift odd L!                       

loop
2drop
;

\ Write 1-character[ROM-FONT] to vram
\ ROM-FONT on (0,0)-(7,0)
\ ( n1 n2 -- )  n1:character  n2:x-position[0 - 7] 
: lcd_char_prop
d64 u* vram +            \ Get vram address (1-charcter occcupy 64bytes) 
swap                     \ ( vram-address character )
prop_char
;

\ Update posX and posY
\ ( -- )
: updateXY
vidX W@ 1+ dup max_vidX W@ >
if 
     drop 0 vidX W! vidY W@ 1+ dup 3 >
     if
          drop 0 vidY W!
     else
          vidY W!
     then
else
     vidX W!
then
;

\ Print 1-character and update vidX/vidY
\ ( n1 -- )  n1:character code
: print
vidX W@ vidY W@
disp_mode W@ hrz =
if
     lcd_char_8x8             \ 8x8 font 
else
     drop
     lcd_char_prop            \ ROM font 
then

updateXY
;

\ Display string to OLED-LCD(128x32dots)
\ ( cstr -- )
: lcd_string
C@++ dup
if
     bounds do
          i C@ 
          print
     loop
else
     2drop
then
;


\ Power off OLED_LCD
\ Shutdown OLED_LCD
\ ( -- )
: power_off
\ Start I2C 
_eestart
\ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi) 
OLED _eewrite
hAE command                                  \ Display Off (sleep-mode)
h8D command                                  \ Charge Pump Setting
h10 command                                  \    Disble Charge Pump
d150 delms
\ Stop I2C
_eestop 
err?
;

\ Reverse LCD-up/dn direction on vertical mode
\ ( -- )
: disp_reverse
\ Start I2C 
_eestart
\ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi) 
OLED _eewrite
hA1 command                                  \ Segment remap
hC8 command                                  \ Scan derection remap
\ Stop I2C
_eestop 
err?
;

\ Normal LCD-up/dn direction on vertical mode
\ ( -- )
: disp_normal
\ Start I2C 
_eestart
\ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi) 
OLED _eewrite
hA0 command                                  \ Segment remap
hC0 command                                  \ Scan derection remap
\ Stop I2C
_eestop 
err?
;

\ Horizontal Scrolling 
\ ( -- )
: scroll_H                              
\ Start I2C 
_eestart
\ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi) 
OLED _eewrite            \ ( n1 t/f )
  
h26 command              \ Scroll to right
0 command
0 command
0 command
3 command
0 command
hFF command
h2F command              \ Activate scroll
d4000 delms

h2E command              \ Deactivate scroll
h27 command              \ Scroll to left
0 command
0 command
0 command
3 command
0 command
hFF command
h2F command              \ Activate scroll           
d4000 delms
h2E command              \ Deactivate scroll 
\ Stop I2C
_eestop 
err?
;

\ Vertical and Horizontal Scrolling
\ ( -- ) 
: scroll_VH                              
\ Start I2C 
_eestart
\ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi) 
OLED _eewrite            \ ( n1 t/f )

hA3 command              \ Set Vertical Scroll Area
0 command                
d32 command 

h29 command              \ Vertical and Right Horizontal scroll
0 command
0 command                \ Page0
1 command
3 command                \ Page3
1 command                \ Vertical Scrolling offset
h2F command              \ Activate scroll
d5000 delms
h2E command              \ Deactivate scroll

h2A command              \ Vertical and Right Horizontal scroll
0 command
0 command                \ Page0
0 command                \ Vertical Scrolling offset
3 command                \ Page3
1 command
h2F command              \ Activate scroll
d5400 delms
h2E command              \ Deactivate scroll

\ Stop I2C
_eestop 
err?
;

\ FadeOut
\ ( n1 -- )  n1:interval time[0-15]
: FadeOut
\ Start I2C 
_eestart
\ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi) 
OLED _eewrite            \ ( n1 t/f )

h23 command              \ ( n1 t/f )
swap h20 or command      \ ( t/f )
\ Stop I2C
_eestop 
err?
;

\ Blinking
\ ( n1 -- )  n1:interval time[0-15]
: Blink
\ Start I2C 
_eestart
\ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi) 
OLED _eewrite            \ ( n1 t/f )

h23 command              \ ( n1 t/f )
swap h30 or command      \ ( t/f )
\ Stop I2C
_eestop 
err?
;

\ Disable FadeOut/Blinking
\ ( -- )
: dis_Fade/Blink
\ Start I2C 
_eestart
\ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi) 
OLED _eewrite            \ ( t/f )
h23 command              \ ( t/f )
0 command                \ ( t/f )
\ Stop I2C
_eestop 
err?
;

\ Display 8x8Fonts without vram
\ ( -- )
: demo1
init_oled
clr_mem
hrz set_mode        \ Horizontal mode
_eestart
\ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi) 
OLED _eewrite                                         
1 controlbyte or
Font
\ 96 characters
d96 0 do
     \ 1 character
     8 0 do
          dup
          C@ _eewrite rot or swap
          1+
     loop
     d100 delms
loop
drop
\ Stop I2C
_eestop 
err?
;

\ Display 8x8Fonts
\ ( -- )
: demo2
init_oled
hrz set_mode        \ Horizontal mode
clr_vram            \ Clear vram
disp_OLED_LCD       \ Copy vram to GDDRAM

0 vidX W! 0 vidY W!
d15 max_vidX W!
\ 96 characters
h20
d96 0 do
     dup     
     print               \ Print character
     1+                  \ Increment character code
     disp_OLED_LCD
loop
drop
c" PropForth5.5    " lcd_string
disp_OLED_LCD
disp_reverse
d3000 delms
disp_OLED_LCD
d3000 delms
disp_normal
d3000 delms
disp_OLED_LCD
;

\ Display PropROM Fonts
\ ( -- )
: demo3
init_oled
vrt set_mode        \ Horizontal mode
clr_vram            \ Clear vram
disp_OLED_LCD       \ Copy vram to GDDRAM

7 max_vidX W!
0 vidX W! 
\ 512 characters
0
d256 0 do
     dup     
     print               \ Print character
     1+                  \ Increment character code
     disp_OLED_LCD
loop
drop
clr_vram 0 vidX W! 
c" Forth" lcd_string
disp_OLED_LCD
disp_reverse
d2000 delms
disp_OLED_LCD
d2000 delms
disp_normal
d2000 delms
disp_OLED_LCD
;

: demo4
demo2
scroll_H 
demo3
scroll_VH 
0 Blink
d5000 delms
dis_Fade/Blink
1 FadeOut
d5000 delms
dis_Fade/Blink
;
