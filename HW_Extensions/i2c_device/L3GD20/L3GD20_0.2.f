fl

{
3-axis Gyroscope L3GD20 module driver 
     
 
PropForth 5.5
2014/01/06 10:35:39

L3GD20 module      Propeller
       1 VDD    ----  3.3V
       2 SCL    ----  P28   
       3 SDA    ----  P29 
       4 SA0    ----  3.3V
       5 CS     ----  3.3V
       8 GND    ----  GND

}

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
\ Slave addres h6B for L3GD20 SA0=1
hD6 wconstant L3GD20

\ register name
hF wconstant WHO_AM_I
h20 wconstant ctrl1
h21 wconstant ctrl2
h22 wconstant ctrl3
h23 wconstant ctrl4
h24 wconstant ctrl5
h25 wconstant reference
h26 wconstant temp
h27 wconstant status
h28 wconstant out_x
h2A wconstant out_y
h2C wconstant out_z
h2E wconstant fifo_ctrl
h2F wconstant fifo_src
h30 wconstant int_cfg
h31 wconstant int_src
h32 wconstant int1_tsh_x
h34 wconstant int1_tsh_y
h35 wconstant int1_tsh_z
h38 wconstant int1_duration

\ =========================================================================== 
\ Variables 
\ =========================================================================== 
variable cx
variable cy
variable cz

\ =========================================================================== 
\ Main
\ =========================================================================== 

\ Check communiation
\ If reply is "D4", i2c-communication is ok.
\ ( -- )
: test 1 WHO_AM_I L3GD20 i2c_rd_multi err? hex . decimal cr ;

\ Display all register's value 
\ ( -- )
: disp_reg
hex
." Address(hex)  " ." value(hex)" cr
h39 h20 do
     4 spaces
     i .byte                       \ Display register address
     9 emit 9 emit
     1 i L3GD20 i2c_rd_multi err?  \ Read value
     .byte                         \ Display register value
     cr
loop
decimal
;

\ Set FIFO mode (Default:Bypass mode)
\ ( n1 -- )   n1:0(Bypass), 1(FIFO), 2(Stream) ,3(StreamToFIFO), 4(BypassToStream)
: FIFO_mode
5 lshift
1 fifo_ctrl L3GD20 i2c_rd_multi err?    \ Read FIFO_CTRL register 
h1F and or                    
1 fifo_ctrl L3GD20 i2c_wr_multi err?    \ Write data to FIFO_CTRL register 
;
                
\ Set FullScale[250dps, 500dps, 2000dps] 
\ Default:250dps
\ ( n1 -- )  n1:0[250dps], 1[500dps], 2[2000dps]
: dps
4 lshift
1 ctrl4 L3GD20 i2c_rd_multi err?        \ Read CTRL_REG4 register 
hCF and or
1 ctrl4 L3GD20 i2c_wr_multi err?        \ Write data to CTRL_REG4 register 
;

\ Convert 2's complement form(16bit) to 32bit
\ None if positive
\ ( n1 -- n2 ) n1:2's complement form(16bit)  n2:32bit
: conv_32 dup h8000 and if hFFFF0000 or then ;

\ Wait until data is ready
\ ( -- )          
: dataReady?
begin
     1 status L3GD20 i2c_rd_multi err?  \ Read status register 
     8 and 0=                           \ Check bit3
     if 0 else 1 then
until
;

\ Get x,y,z
\ ( -- x y z )
: get_xyz
\ Get 6byte  
6 out_x h80 or                               \ In case of multi_read, register set bit7 to 1
L3GD20 i2c_rd_multi err?                     \ Get x,y,z     
8 lshift or conv_32 >r                       \ z
8 lshift or conv_32 >r                       \ y
8 lshift or conv_32                          \ x
r> r>
;

\ add n1 to the long contents of address
\ ( n1 addr -- )
: L+! dup L@ rot + swap L! ;

\ Caribration x,y,z
\ ( -- )
: caribrate
0 cx L! 0 cy L! 0 cz L!
d10 0 do
     dataReady?
     get_xyz                    
     cz L+! cy L+! cx L+!
loop
cx L@ d10 / cx L!
cy L@ d10 / cy L!
cz L@ d10 / cz L!
;

\ Show x,y,z on degree (Default:250dps)
\ ( -- )     
: show_xyz
\ init L3GD20
8 1 ctrl3 L3GD20 i2c_wr_multi err?            
h80 1 ctrl4 L3GD20 i2c_wr_multi err?
h1F 1 ctrl1 L3GD20 i2c_wr_multi err? 
d500 delms                                   \ Wait until stable
caribrate

." Temp:" 9 emit ." Z:" 9 emit ." Y:" 9 emit  ." X:"  cr
0
begin
     1 temp L3GD20 i2c_rd_multi err? .                    \ Display Temperature
     dataReady?
     get_xyz
{     
     \ Raw data below
     9 emit cz L@ - . 9 emit cy L@ - . 9 emit cx L@ - . 
}
     \ 1unit is 0.00875degrees at 250dps setting(default)
     \ 114.28unit = 1degree
     9 emit cz L@ - d114 / . 9 emit cy L@ - d114 / . 9 emit cx L@ - d114 / . 
     cr
     1+ dup d20 =
     if
          cr ." Temp:" 9 emit ." Z:" 9 emit ." Y:" 9 emit  ." X:"  cr
          drop 0
     then          
     fkey? swap drop
     d100 delms 
until
drop
;


