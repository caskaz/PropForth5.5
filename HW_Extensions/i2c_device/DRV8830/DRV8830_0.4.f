fl

{
MotorDriver using DRV8830

PropForth5.5
Using i2c_utility_0.4_1.f 
2016/03/11 14:57:58


     DRV8830      Propeller
     scl    ----  P28   
     sda    ----  P29   
     ( Need pull-up resister[10ohm] to 3.3V at SCL/SDA on DRV8830)
     
     out1   ------ Motot+
     out2   ------ Motot-
     Vcc    ------ 5V(MotorPoer & Logic)
     GND    ------ GND
     ISENSE ------ resistor -- GND 
     A0     ------ GND
     A1     ------ GND
     FAULT  ------ LED -- resitor(220ohm) -- 5V
              

DRV8830 (Connectable max 9 devices on same I2C line.)
  Slave address
    A1   A0         addr[wr]     addr[rd]
     0    0          hC0          hC1
     0   open        hC2          hC3
     0    1          hC4          hC5
    open  0          hC6          hC7
    open open        hC8          hC9
    open  1          hCA          hCB
     1    0          hCC          hCD
     1   open        hCE          hCF
     1    1          hD0          hD1
     
  Register inside DRV8830
    register    name
     0          CONTROL
     1          FAULT
     
  CONTROL[Register 0]  
     b7-b2:VSET[5..0] : Set DAC output voltage
     b1               : In1
     b0               : In2
     IN1 IN2  Function
      0   0   Standby/coast
      0   1   Reverse
      1   0   Forward
      1   1   Brake
      
  FAULT[Register 1]  
     b7     b6      b5      b4      b3   b2    b1   b0
     clear  unused  unused  LIMITS  OTS  UVLO  OCP  FAULT    

}


\ =========================================================================== 
\ Constants 
\ =========================================================================== 

\ DRV8830's slave address[h60]  A0=A1=GND
hC0 wconstant 1st_DRV
\ Register
0 wconstant CONTROL
1 wconstant FAULT
\ Value inside CONTROL register
1 wconstant rev     \ IN2=0 IN1=1
2 wconstant fwd     \ IN2=1 IN1=0
\ Value inside FAULT register
0 wconstant fault

\ =========================================================================== 
\  main
\ =========================================================================== 

\ Get slave-addr for n1 (n=0,1,2,3,4,5,6,7 8)
\ ( n1 -- n2 )  n1:device's number[from 0 to 8]  n2:slave-address
: Get_slave 2 u* 1st_DRV + ;

\ Clear fault
\ ( -- )
: fault_clr 
h80            \ data 
FAULT          \ register
0 Get_slave    \ slave address
i2c_wr 
;

\ Motor <-- 1.29V       
\ ( --  )
: test
h42            \ data 
CONTROL        \ register
0 Get_slave    \ slave address
i2c_wr 
;

\ Set status to standby
\ ( -- )
: set_standby 
0              \ data 
CONTROL        \ register
0 Get_slave    \ slave address
i2c_wr 
;

\ Stop Motor            
\ ( --  )
: stop1 
0              \ data 
CONTROL        \ register
0 Get_slave    \ slave address
i2c_wr 
;

\ Braking Motor       
\ ( --  )
: stop2 
3              \ data
CONTROL        \ register
0 Get_slave    \ slave address
i2c_wr 
;

\ Display FAULT-status     
\ ( -- ) 
: FAULT? 
FAULT          \ register
0 Get_slave    \ slave address
i2c_rd
dup hex . decimal 
0 <> if fault_clr then   \ If there is fault, claear fault
cr
;

: case over = ;

\ Read CONTROL-setting  
\ ( --  ) 
: CONTROL? 
CONTROL        \ register 
0 Get_slave    \ slave address
i2c_rd
." VSET DAC H-Bridge" cr
dup 2 rshift ."   " hex . decimal ."     "
3 and
0 case 
if ." standby"
else 1 case
     if ." reverse"
     else 2 case 
          if ." forward"
          else ." brake"
thens      
drop
cr
;


\ Motor-voltage is under 3V because this motor is for 3V.
\ ( -- )
: Motor_test
hex
\ Rotate up step by step
." Foward" cr
h26 h6 do
     i 2 lshift fwd or CONTROL 0 Get_slave i2c_wr
     CONTROL? 
     d8000000 cnt COG@ +                          \ dT=100msec
     begin
          ." FAULT register:" FAULT? cr 
          d8000000 waitcnt
     until
loop
\ Blaking
3 CONTROL 0 Get_slave i2c_wr 

\ Wait 
d500 delms
cr cr

\ Rotate up step by step to reverse
." Reverse" cr
h26 h6 do
     i 2 lshift rev or CONTROL 0 Get_slave i2c_wr
     CONTROL? 
     d8000000 cnt COG@ +                          \ dT=100dmsec
     begin
          ." FAULT register:" FAULT? cr 
          d8000000 waitcnt
     until
loop
\ Stop
0 CONTROL 0 Get_slave i2c_wr 
;
