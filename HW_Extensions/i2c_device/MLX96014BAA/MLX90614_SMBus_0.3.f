fl

{
PropForth 5.5(DevKernel)
IR Temperature sensor(MLX90614ESF-BAA)
      
This use to copy a parts from i2c_utility_0.4.1.f   
2016/03/12 13:05:04

      MLX90614 module    QuickStart
                 Vdd  -- 3.3V
                 SCL  -- SCL
                 SDA  -- SDA
                 Vss  -- GND
}


\ =========================================================================== 
\ Constants 
\ =========================================================================== 
\ Slave addres h5A for MLX90614 
hB4 wconstant MLX90614

\ eeprom register acccess command [h20 + eeprom_register]
h20 wconstant TOmax
h21 wconstant TOmin                         
h22 wconstant PWMctrl
h23 wconstant Ta_Range
h24 wconstant Ke
h25 wconstant ConfigR1
h2E wconstant SMBus_Addr
h3C wconstant ID_1
h3D wconstant ID_2
h3E wconstant ID_3
h3F wconstant ID_4

\ RAM register acccess command
3 wconstant Ambient
4 wconstant IR1
5 wconstant IR2
6 wconstant Ta
7 wconstant Tobj1
8 wconstant Tobj2

\ =========================================================================== 
\ Main 
\ =========================================================================== 

\ Read data from RAM or eeprom in MLX90614
\ ( n1 -- n2 n3 )  n1:command   n2:data[16bit] n3:PEC  
: MLX90614_rd
3 swap MLX90614 std_i2c_rd_multi  \ ( LowByte HiByte n3 )
rot                                \ ( n3 LowByte HiByte )
rot 8 lshift or swap               \ ( n2 n3 )
;

\ Write data to RAM or eeprom in MLX90614
\ ( n1 n2 n3 -- t/f )  n1:PEC n2:data[16bit] n3:command  t/f:true if there was an error
: MLX90614_wr
>r                                 \ ( n1 n2 )
dup 8 rshift swap 3                \ ( n1 HiByte LowByte 3 )
r> MLX90614                        \ ( n1 HiByte LowByte 3 n3 SlaveAddress )
std_i2c_wr_multi                   \ ( -- )
;

\ TAB
\ ( -- )
: tab 9 emit ;
: 2tab tab tab ;

\ Display value in RAM or eeprom register
\ ( n1 -- n2 )
: disp_reg1 MLX90614_rd drop ;
: disp_reg2 disp_reg1 . cr ;
: disp_reg3 disp_reg1 hFF and . ;

\ Message "Melexis reserved"
\ ( n1 -- )  n1:register
: mlx_msg1 dup .byte tab ." Melexis reserved:" disp_reg2 ;
: mlx_msg2 ." no        Melexis reserved" cr ;

\ Display RAM register
\ ( -- )
: disp_RAM
." Address" tab ." Contents" cr
hex
4 0 do i mlx_msg1 loop
4 .byte tab ." Raw data IR ch 1:" 4 disp_reg2
5 .byte tab ." Raw data IR ch 2:" 5 disp_reg2
6 .byte tab ." Tambient (16bit format, $27AD=10_157=-70degreeC to $7FFF=32_767=382degreeC):" 6 disp_reg2
7 .byte tab ." Tobject1 (16bit format, $27AD=10_157=-70degreeC to $7FFF=32_767=382degreeC):" 7 disp_reg2
8 .byte tab ." Tobject2 (16bit format, $27AD=10_157=-70degreeC to $7FFF=32_767=382degreeC):" 8 disp_reg2
9 .byte tab ." Melexis reserved:" 9 disp_reg2
hA .byte tab ." Melexis reserved, Ta1_PKI:" hA disp_reg2
hB .byte tab ." Melexis reserved, Ta2_PKI:" hB disp_reg2
h13 hC do i mlx_msg1 loop
h13 .byte tab ." Melexis reserved, Scale_Alpha_Ratio:" h13 disp_reg2
h14 .byte tab ." Melexis reserved, Scale_Alpha_Slope:" h14 disp_reg2
h15 .byte tab ." Melexis reserved, IIR_Filter:" h15 disp_reg2
h16 .byte tab ." Melexis reserved, Ta1_PKI_Fraction:" h16 disp_reg2
h17 .byte tab ." Melexis reserved, Ta2_PKI_Fraction:" h17 disp_reg2
h1B h18 do i mlx_msg1 loop
h1B .byte tab ." Melexis reserved, FIR_Filter:" h1B disp_reg2
h20 h1C do i mlx_msg1 loop
decimal
;

\ Display eeprom register
\ ( -- )
: disp_eeprom
hex
." Address" tab ." Contents" tab ." Writable" cr
0 .byte tab h20 disp_reg1 . 2tab ." yes       To_max" cr
1 .byte tab h21 disp_reg1 . 2tab ." yes       To_min" cr
2 .byte tab h22 disp_reg1 . 2tab ." yes       PWMCTRL" cr
3 .byte tab h23 disp_reg1 . 2tab ." yes       Ta range" cr
4 .byte tab h24 disp_reg1 . 2tab ." yes       emissivity correction coefficient" cr
5 .byte tab h25 disp_reg1 . 2tab ." yes       config register1" cr
h2E h26 do i h20 - .byte tab i disp_reg1 . 2tab mlx_msg2 loop
hE .byte tab h2E MLX90614_rd drop hFF and . 2tab ." yes       SMbus address (LSB only)" cr
hF .byte tab h2F disp_reg1 . 2tab ." yes       Melexis reserved" cr
h39 h30 do i h20 - .byte tab i disp_reg1 . 2tab mlx_msg2 loop
h19 .byte tab h39 disp_reg1 . 2tab ." yes       Melexis reserved" cr
h3C h3A do i h20 - .byte tab i disp_reg1 . 2tab mlx_msg2 loop
h1C .byte tab h3C disp_reg3 2tab ." no        ID number" cr
h1D .byte tab h3D disp_reg3 2tab ." no        ID number" cr
h1E .byte tab h3E disp_reg3 2tab ." no        ID number" cr
h1F .byte tab h3F disp_reg3 2tab ." no        ID number" cr
decimal
;

\ PEC uses CRC-8 to calculate PacketErrorCode(PEC).
\ ( n1 n2 -- n3 )  n1:crc n2:data  n3:crc
: crc8
xor                      \ ( result )  xor new byte and old crc to get remainder + byte
\ check all 8 bit
8 0 do
     1 lshift            \ ( result' result')  shift it out
     dup h100 and 0 <>   \ ( result' t/f )
     if
          7 xor          \ ( result'' )  xor with the polynomial
     then   
loop  
hFF and                  \ remove the bit shifted out
;     

\ Writ data in eeprom
\ ( n1 n2 -- ) n1:value[16bit] n2:eeprom address
: wr_eeprom
over dup 8 rshift swap hFF and 2 ST@              \ ( n1 n2 Hi-byte Lo-byte n2 ) 
\ MLX90614 0 -> crc8 -> 5 n2 -> crc8 -> hD1 Lo-byte -> crc8 -> ## Hi-byte -> crc8 -> **
MLX90614 0 crc8 crc8 crc8 crc8                    \ ( n1 n2 PEC )
rot2
MLX90614_wr                                       \ ( PEC n1 n2 )
5 delms
;  

\ Set data in eeprom
\ ( n1 n2 -- ) n1:value[16bit] n2:eeprom address
: set_eeprom
dup 0 swap wr_eeprom     \ Erase value
wr_eeprom                \ Write value
;

\ Change SA(Slave Address) h0 - h7F
\ ( n1 -- )  n1:SlaveAddress
: set_SA
dup 0 <>
if 
     0 SMBus_Addr wr_eeprom   \ Erase SA
     SMBus_Addr wr_eeprom     \ Write new SA
     ." Success to set SA" 
else
     ." Cannot SA:0"
then
cr
;

\ SoftReset
\ ( -- )
: reset
\ Start I2C 
_eestart
\ GeneralCalladdress
0 std_eewrite 6 std_eewrite or
\ Stop I2C
_eestop 
;

\ Enter sleep mode ( This is NOT available for 5V supply version)
\ ( -- )
: sleep
\ Calculate PEC
MLX90614 0 crc8 hFF crc8
hFF MLX90614 std_i2c_wr
_scll _sclo              \ Set scl to lo
;

\ Wake up
\ ( -- )
: wakeup
_scli                         \ Set scl to Hi          
_sdal _sdao d40 delms _sdai   \ Keep sda to Lo during min 33msec
;

\ Read flag
\ Data[b15:b8]=0 Data[b7]=EEBUSY Data[b6]=unused Data[b5]=EE_DEAD Data[b4]=INIT Data[b3]=Not impelemented Data[b2:b0]=0
\ ( -- ) 
: flag 
\ Start I2C 
_eestart
\ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi) 
MLX90614 std_eewrite          \ ( t/f )
\ Write command
hF0 std_eewrite or            \ ( t/f )
>r
\ Read Lo bytes
0 std_eeread                  \ ( Lo )
\ Read Hi bytes
0 std_eeread                  \ ( Lo-byte Hi-byte )
\ Read PEC ,then set sda to Hi(NACK:master->slave)
-1 std_eeread                 \ ( Lo-byte Hi-byte PEC )
\ Stop I2C
_eestop
drop r>                       \ ( Lo-byte Hi-byte t/f )
err?
8 lshift or .         
;

\ Display temperature
\ ( n1 -- )  n1:value
: disp_degree
d100 over >
if
     h30 emit h2E emit
     d10 u/mod h30 + emit h30 + emit
else
     d1000 over >
     if
          d100 u/mod h30 + emit h2E emit
          d10 u/mod h30 + emit h30 + emit
     else
          d10000 over >
          if
               d1000 u/mod h30 + emit 
               d100 u/mod h30 + emit h2E emit
               d10 u/mod h30 + emit h30 + emit
          else
               d10000 u/mod h30 + emit
               d1000 u/mod h30 + emit 
               d100 u/mod h30 + emit h2E emit
               d10 u/mod h30 + emit h30 + emit
          then
     then                    
then
;

\ Display temperature[degree]
\ ( n1 -- ) n1:data[16bit]
: calc_degree
dup h8000 and
if
     ." Error "
else
     d100 u* d50 u/ d27315 - 
     dup 0 >=
     if
          disp_degree
     else
          h2D emit
          invert 1+
          disp_degree
     then
     ." degreeC" 
then
;
     

\ Repeat displaying temperature
\ ( -- )
: demo
tab ." Raw" 2tab ." degreeC" cr
clkfreq cnt COG@ +
begin
     ." Tamb=" tab Ta MLX90614_rd drop dup . 2tab calc_degree cr
     ." Tobj1=" tab Tobj1 MLX90614_rd drop dup . 2tab calc_degree cr
     ." Tobj2=" tab Tobj2 MLX90614_rd drop dup . 2tab calc_degree cr
     cr
     clkfreq waitcnt
     fkey? swap drop
until
drop
;
