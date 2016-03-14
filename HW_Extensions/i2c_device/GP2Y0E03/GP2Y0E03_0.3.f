fl                                                              

{
PropForth 5.5(DevKernel)

Distance Measuring Sensor(GP2Y0E03)
Using i2c_utility_0.4.1.f 
2016/03/14 17:49:16


QuickStart       GP2Y0E03
Board            ----------
3V3 ----------- |1 Vdd     |
                |2 Vout    |
GND ----------- |3 GND     |                
3V3 ----------- |4 VIO     |
3V3 ----------- |5 GPIO    |
SCL ----------- |6 SCL     |
SDA ----------- |7 SDA     |
                 --------
 
                 Prop plug
                -------------
P26(Tx) -------|RX           |
P27(Rx) -------|TX           |-----------------------PC COM5 (Processing)
               |RES          | USB
GND -----------|Vss          |
                -------------
}
\ Re-defined Word"seral" because it has bugs.
: serial
	4*
	clkfreq swap u/ dup 2/ 2/
\
\ serial structure
\
\
\ init 1st 4 members to hFF
\
	hFF h1C2 
	2dup COG!
	1+ 2dup COG!
	1+ 2dup COG!
	1+ tuck COG!
\
\ next 2 members to h100
\
	1+ h100 swap 2dup COG!
	1+ tuck COG!
\
\ bittick/4, bitticks
\
	1+ tuck COG!
	1+ tuck COG!
\
\ rxmask txmask
\
	1+ swap >m over COG!
	1+ swap >m over COG!
\ rest of structure to 0
	1+ h1F0 swap
	do
		0 i COG!
	loop
\
	c" SERIAL" numpad ccopy numpad cds W!
	4 state andnC!
\	0 io hC4 + L!    <-- always 0 cogn sersetbreak
\	0 io hC8 + L!    <-- always 0 cogn sersetflags
	_serial
;

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
\ Slave addres h40 for GP2Y0E03
h80 wconstant GP2Y0E03

1 wconstant GPIO1

\ =========================================================================== 
\ Variables 
\ =========================================================================== 
\ ImageSensorData 220byte X 3
variable ImageSens_L 
0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l,
0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l,
0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 
variable ImageSens_M 
0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l,
0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l,
0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 
variable ImageSens_H 
0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l,
0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l,
0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 

wvariable sig_accum_t
wvariable distance

\ =========================================================================== 
\ Main 
\ =========================================================================== 
\ Read out ImageSenorData(220pcs) and store them to each area
\ ( n1 -- )  n1:address
: ImageSenorData
d220 0 GP2Y0E03                         \ ( n1 d220 0 GP2Y0E03 )
\ Start I2C 
_eestart
\ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi)  
tuck _eewrite                           \ ( n1 d220 GP2Y0E03 0 t/f )
\ Write register
swap _eewrite or                        \ ( n1 d220 GP2Y0E03 t/f )
swap                                    \ ( n1 d220 t/f GP2Y0E03 )
\ Repeated Start read_process
Sr
\ Write slave address[rd], then receive Acknowledge-bit(ACK:Lo  NACK:Hi)
1 or 
_eewrite or                             \ ( n1 d220 t/f )
\ Read (n1-1)bytes
>r                                      \ Push flag  ( n1 d220 )
1 - 0 do 
     0 _eeread                          \ ( n1 data )
     over i + C!                        \ ( n1 )
loop
\ Read 1byte ,then set sda to Hi(NACK:master->slave)
-1 _eeread                              \ ( n1 data )
swap d219 + C!
r>                                      \ Pop flag   ( t/f )
\ Stop I2C
_eestop
err?                                         
;

\ TAB
\ ( -- )
: tab 9 emit ;

\ Standby GP2Y0E03
\ ( -- )
: standby 1 hE8 GP2Y0E03 i2c_wr ;

\ Activate GP2Y0E03 (Default state)
\ ( -- )
: active 0 hE8 GP2Y0E03 i2c_wr ;

\ Software reset
\ ( -- )
: soft_reset
0 hEF GP2Y0E03 i2c_wr    \ Select Bank 0                         
hFF hEC GP2Y0E03 i2c_wr  \ Set clock to manual
6 hEE GP2Y0E03 i2c_wr    \ software reset
h7F hEC GP2Y0E03 i2c_wr  \ Set clock to auto
;

\ Display all register
\ ( -- )
: disp_reg
hex
3 GP2Y0E03 i2c_rd
." Hold bit" tab tab tab .byte cr
h13 GP2Y0E03 i2c_rd
." Maximum Emitting Pulse Width" tab .byte cr
h1C GP2Y0E03 i2c_rd
." Spot Symmetry Thresgold" tab tab .byte cr
h2F GP2Y0E03 i2c_rd
." Signal Intensity Threshold" tab .byte cr
h33 GP2Y0E03 i2c_rd
." Maximum Spot Size Threshold" tab .byte cr
h34 GP2Y0E03 i2c_rd
." Minimum Spot Size Threshold" tab .byte cr
h35 GP2Y0E03 i2c_rd
." Shift Bit" tab tab tab .byte cr
h3F GP2Y0E03 i2c_rd
." Median Filter" tab tab tab .byte cr
h4C GP2Y0E03 i2c_rd
." SRAM Access" tab tab tab .byte cr
h5E GP2Y0E03 i2c_rd
." Distance[11:4]" tab tab tab .byte cr
h5F GP2Y0E03 i2c_rd
." Distance[3:0]" tab tab tab .byte cr
h64 GP2Y0E03 i2c_rd
." AE[15:8]" tab tab tab .byte cr
h65 GP2Y0E03 i2c_rd
." AE[7:0]" tab tab tab tab .byte cr
h67 GP2Y0E03 i2c_rd
." AG[7:0]" tab tab tab tab .byte cr
h8D GP2Y0E03 i2c_rd
." Cover Compensation[5:0]" tab tab .byte cr
h8E GP2Y0E03 i2c_rd
." Cover Compensation[10:6]" tab .byte cr
h8F GP2Y0E03 i2c_rd
." Cover Compensation Enable Bit" tab .byte cr
h90 GP2Y0E03 i2c_rd
." Read out ImageSensor data" tab .byte cr
hA8 GP2Y0E03 i2c_rd
." Signal Accumlation Number" tab .byte cr
hBC GP2Y0E03 i2c_rd 
." Enable Bit(Signal Intensity)" tab .byte cr
hBD GP2Y0E03 i2c_rd
." Enable Bit(Miniumum spot size)" tab .byte cr
hBE GP2Y0E03 i2c_rd
." Enable Bit(Maximum spot size)" tab .byte cr
hBF GP2Y0E03 i2c_rd
." Enable Bit(Spot symmetry)" tab .byte cr
hC8 GP2Y0E03 i2c_rd
." E-Fuse Target Address" tab tab .byte cr
hC9 GP2Y0E03 i2c_rd
." E-Fuse Bit Number" tab tab .byte cr
hCA GP2Y0E03 i2c_rd
." E-Fuse Program Enable Bit" tab .byte cr
hCD GP2Y0E03 i2c_rd
." E-Fuse Program Data" tab tab .byte cr
hE8 GP2Y0E03 i2c_rd
." Active/StandBy State Control" tab .byte cr
hEC GP2Y0E03 i2c_rd
." Clock Select" tab tab tab .byte cr
hEE GP2Y0E03 i2c_rd
." Software Reset" tab tab tab .byte cr
hEF GP2Y0E03 i2c_rd
." Bank Select" tab tab tab .byte cr
hF8 GP2Y0E03 i2c_rd
." Right Edge Coordinate(C)" tab .byte cr
hF9 GP2Y0E03 i2c_rd
." Left Edge Coordinate(A)" tab tab .byte cr
hFA GP2Y0E03 i2c_rd
." Peak Coordinate(B)" tab tab .byte cr
decimal
;

\ Display distance
\ ( -- n1 )    n1:distance[mm]
: Get_distance
2 h5E GP2Y0E03 i2c_rd_multi
hF and                                  \ distance[3:0]
swap d16 u*                             \ distance[11:4]x16
+                                       \ ( distance[11:4]x16+distance[3:0] )
d10 u*                                  \ unit[mm]
d16 u/                                  \ ( {distance[11:4]x16+distance[3:0]}/16 )
h35 GP2Y0E03 i2c_rd                     \ Shift_bit
1 = if 2 else 4 then                    \ ( {distance[11:4]x16+distance[3:0]}/16 2/4 )
u/                                      \ distance value
;

\ Get values of detector[1:220]
\ ( -- )
: get_ImageSensor
0 hEF GP2Y0E03 i2c_wr                   \ Select Bank0
hFF hEC GP2Y0E03 i2c_wr                 \ Set manual-clock
hA8 GP2Y0E03 i2c_rd                     \ Get SignalAccumlationNumber
\ case 0
0 over = if 1 
else 
\ case 1
1 over = if 5 
else 
\ case 2
2 over = if d30 
else 
d10 
thens
nip
sig_accum_t W!
                                                                        
sig_accum_t W@ d10 + 4 u* delms         \ Wait 4x(N+10)
0 3 GP2Y0E03 i2c_wr                     \ Hold
sig_accum_t W@ d10 + 2 u* delms         \ Wait 2x(N+10)
h10 h4C GP2Y0E03 i2c_wr                 \ Access SRAM
sig_accum_t W@ d10 + 2 u* delms         \ Wait 2x(N+10)
                                                                        
\ Read out setting of Low Level Data (Burst Read)
h10 h90 GP2Y0E03 i2c_wr                 \ Set h10 for reading out low-level data of ImageSensor
\ Read out from address[0] to address[d219]                                        
ImageSens_L ImageSenorData
                                                                         
\ Read out setting of Middle Level Data (Burst Read)
h11 h90 GP2Y0E03 i2c_wr                 \ Set h11 for reading out low-level data of ImageSensor
\ Read out from address[0] to address[d219]                                        
ImageSens_M ImageSenorData

\ Read out setting of High Level Data (Burst Read)
h12 h90 GP2Y0E03 i2c_wr                 \ Set h12 for reading out low-level data of ImageSensor
\ Read out from address[0] to address[d219]                                        
ImageSens_H ImageSenorData

{
\ Calculation and printing to TeraTerm
d220 0 do
     ImageSens_L i + C@ ImageSens_M i + C@ d256 u* + ImageSens_H i + C@ d65536 u* + . cr
loop
}

\ Set measure mode
0 h90 GP2Y0E03 i2c_wr                   \ Disable reading out of ImageSensor
1 3 GP2Y0E03 i2c_wr                     \ Device enable
h7F hEC GP2Y0E03 i2c_wr                 \ Set auto-clock
;

\ Display distance[mm]
\ ( -- )
: measure
d25 delms                                 \ Wait until stable
\ Display distance[mm]
begin
     Get_distance . cr      100 delms
     fkey? swap drop
until 
;

wvariable inchar h100 inchar W!
\ Draw graph for ImageSensor detector by using Processing
\ ( -- )
: draw_ImageSensor
5 cogreset d10 delms
     \ if this bit is 0, CR is transmitted as CR LF
     \ if this bit is 1, CR is transmitted as CR
1 5 sersetflags
\ pin 26 tx, pin 27 rx  9600baud  d9600/4 = d2400
c" 26 27 d2400 serial" 5 cogx
d10 delms
5 cogio 2+ W@                           \ Put output ptr of cog5 on stack
inchar 5 cogio 2+ W!                    \ Set output ptr of cog5 to inchar
io 2+ W@                                \ Put output ptr of current cog on stack
5 cogio io 2+ W!                        \ Set output ptr of current cog to input ptr of cog 5

begin
     get_ImageSensor
     Get_distance distance W!
     
     \ Check char from processing
     begin 
          inchar W@ d65 =                    \ ( 1/0 )
          if 
               \ Repeat sending ImageSensor-data                                                          
               1 1                           \ ( 1 1 )
               h100 inchar W!                \ Set inchar ready to receive next char
          else 
               inchar W@ d66 = 
               if                                                           
                    \ Finish begin-loop because of hitting anykey on Processing-window[ImageSensor_2_4_1]                   
                    0 1                      \ ( 0 1 )
                    h100 inchar W!           \ Set inchar ready to receive next char
               else
                    0                        \ ( 0 )
               then
          then      
     until
     \ Send values to Processing
     if
          \ Send 660 bytes
          d220 0 do
               ImageSens_L i + C@ emit 
               ImageSens_M i + C@ emit 
               ImageSens_H i + C@ emit 
          loop
          \ Send distance's value
          distance W@ dup
          hFF and emit                       \ Send Lo byte 
          8 rshift emit                      \ Send Hi byte 
          0
     else
          \ Finish begin-until loop
          1
     then 
until                                              
                                               
\ Restore output ptr for current cog 
io 2+ W!
\ Restore output ptr for cog 5
5 cogio 2+ W!   

\ Read out until read-buffer is empty
begin 
     inchar W@ h100 =
     if
          1
     else
          h100 inchar W! 0
     then
until     
;
