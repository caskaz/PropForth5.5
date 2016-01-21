fl

{
3-axis-jyro/3-axis-accelerometer (MPU6050)
      
PropForth 5.5(DevKernel)
This use to copy a parts from i2c_utility_0.4_1.f   

2016/01/20 22:24:54

  MPU6050 module     Propeller
          Vcc   ----  3.3V
          SCL   ----  SCL
          SDA   ----  SDA
          AD0   ----  GND
          GND   ----  GND
          INT    

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
\ Slave addres h68 for MPU6050 (AD0:GND) 
hD0 wconstant MPU6050

\ register
d26 wconstant CONFIG          
d59 wconstant ACCEL_XOUT
d61 wconstant ACCEL_YOUT
d63 wconstant ACCEL_ZOUT
d107 wconstant PWR_MGMT_1

\ =========================================================================== 
\ Variables 
\ =========================================================================== 
wvariable inchar h100 inchar W!

\ =========================================================================== 
\ Main 
\ =========================================================================== 

\ Initilize MPU6050
\ ( -- )
: init_MPU6050
1 PWR_MGMT_1 MPU6050 i2c_wr             \ Eneble Temperature-sensor
1 CONFIG MPU6050 i2c_wr 
;

\ reset_MPU6050
\ ( -- )
: reset_MPU h80 PWR_MGMT_1 MPU6050 i2c_wr ;

\ TAB
\ ( -- )
: tab 9 emit ;

\ Convert 2byte to 1word 
\ ( n1 n2 -- n3 )   n1:H-byte n2:L-byte  n3:32bit with sign
: conv
dup h8000 and 
if hFFFF0000 or then 
;

\ Pretreatment for communication
\ ( -- )
: pre
\ Initialize serial
\    if this bit is 0, CR is transmitted as CR LF
\    if this bit is 1, CR is transmitted as CR
1 5 sersetflags
\ pin 26 tx, pin 27 rx  d9600/4 = d2400
c" 26 27 d2400 serial" 5 cogx
d10 delms
5 cogio 2+ W@                           \ Put output ptr of cog5 on stack
inchar 5 cogio 2+ W!                    \ Set output ptr of cog5 to inchar
io 2+ W@                                \ Put output ptr of current cog on stack
5 cogio io 2+ W!                        \ Set output ptr of current cog to input ptr of cog 5
;

\ Post-processing for communication
\ ( -- )
: post
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
5 cogreset
;

\ Display Acceleration[x,y,z]to TeraTerm screen
\ ( -- )
: Disp_accel
init_MPU6050

." Acc-Z" tab ." ACC-Y" tab ." Acc-X" cr
d800000 cnt COG@ +                             
begin
     6 ACCEL_XOUT MPU6050 i2c_rd_multi 
     swap 8 lshift or conv . tab             \ Z
     swap 8 lshift or conv . tab             \ Y
     swap 8 lshift or conv .                 \ X
     d800000 waitcnt
     cr
     fkey? swap drop
until
drop
;


\ Send data for acceleration[x,y,z](raw data) to Processing 
\ ( -- )
: Graph_accel
init_MPU6050

pre

\ Wait until receiving 'd65'
\ begin inchar W@ d65 = until

h100 inchar W!
begin
     \ Check char from processing
     inchar W@ d66 =
     if 
          1
     else
          inchar W@ d65 =
          if          
               \ Raw data below
               6 ACCEL_XOUT MPU6050 i2c_rd_multi 
               \ Send 4byte z
               swap 8 lshift or conv dup emit 8 rshift dup emit 8 rshift dup emit 8 rshift emit
               \ Send 4byte y
               swap 8 lshift or conv dup emit 8 rshift dup emit 8 rshift dup emit 8 rshift emit
               \ Send 4byte x
               swap 8 lshift or conv dup emit 8 rshift dup emit 8 rshift dup emit 8 rshift emit
               h100 inchar W!
               0
          else
               0
     thens
until

post
;
