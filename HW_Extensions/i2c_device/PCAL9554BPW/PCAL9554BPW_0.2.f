fl

{                       
PropForth 5.5(DevKernel)

8bit I/O Expander(PCAL9554BPW)
Using i2c_utility_0.4.1.f 
2016/03/20 22:25:48

    PCAL9554BPW       Propeller
          SDA   ------  SDA
          SCL   ------  SCL
          
          A0   -------- GND
          A1   -------- GND
          A2   -------- GND
}

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
\ Slave addres h20 for PCAL9554BPW      
h40 wconstant PCAL9554BPW

\ register  
0 wconstant InPort
1 wconstant OutPort
2 wconstant Porality
3 wconstant Config
h40 wconstant Output_st0
h41 wconstant Output_st1
h42 wconstant InLatch
h43 wconstant Pull_u/d_enb
h44 wconstant Pull_u/d_sel
h45 wconstant Interrupt_mask
h46 wconstant Interrupt_status
h4F wconstant OutputConfig

variable reg_num -4 allot 
h00 c, h01 c, h02 c, h03 c, h40 c, h41 c, h42 c, h43 c, h44 c, h45 c, h46 c, h4F c,

\ =========================================================================== 
\ Main 
\ =========================================================================== 

\ allocate string
\ ( -- )
: s, parsenw dup C@ 1+ bounds dup rot2 do C@++ c, loop drop ;

wvariable string -2 allot 
s, InputPort s, OutputPort 
s, PoralityInversion s, Configuration s, OutputDriveStrength0 s, OutputDriveStrength1 
s, InputLatch s, Pull_up/down_enable
s, Pull_up/down_selection 
s, InteruptMask s, InterruptStatus s, OutputPortConfiguration

\ Display allocated string above
\ ( n1 n2 -- )  n1:string index  n2:string's top address
: dispStr 
swap dup 0 <> 
if  
     0 do
          dup C@ + 1+
     loop     
else
     drop     
then 
.cstr 
;

\ TAB
\ ( -- )
: tab 9 emit ;
: 2tab tab tab ;

\ Display all registers from mode1 to ALLCALLADR
\ ( -- )
: rd_allreg
cr
hex
d12 0 do     
     \ Print register name
     i string dispStr ." :" 
     i 2 < if 2tab else i 3 u/mod drop 0= if 2tab else i d11 < if tab thens
     \ Print value                                
     ." h" reg_num i + C@ PCAL9554BPW i2c_rd . 
     cr   
loop
decimal
cr
;

\ Invert logic of each bit
\ ( n1 -- ) n1:1=inverting  0= normal
\ [b7 b6 b5 b4 b3 b2 b1 b0]=[P7 P6 P5 P4 P3 P2 P1 P0]
\ b7-b0 is databit     P7-P0 is port on device
: porality_inv Porality PCAL9554BPW i2c_wr ;

\ Set each bit to input or output
\ ( n1 -- )  n1:1=input 0=output
: config Config PCAL9554BPW i2c_wr ;

\ Set drive-capability for each pin
\ Output_st0 [port3 port2 port1 port0]=[b7-6 b5-4 b3-2 b1-0]
\ Output_st1 [port7 port6 port5 port4]=[b7-6 b5-4 b3-2 b1-0]
\ 00=x0.25 01=x0.5  10=x0.75  11=x1.0
\ ( n1 n2 -- )  n1:OutputDriveStrength0 n2:OutputDriveStrength1
: setDrive
Output_st1 PCAL9554BPW i2c_wr 
Output_st0 PCAL9554BPW i2c_wr 
;

\ Enable/Disable pull-up/pull-down resistor on each bit
\ ( n1 -- )  n1:1=enable  0=disable
: pull_up/dn_enable Pull_u/d_enb PCAL9554BPW i2c_wr ;

\ Selection port to pull-up or pull-down resistor
\ ( n1 -- ) n1:1=pull-up resistor 0=pull-down resistor
: pull_up/dn_sel Pull_u/d_sel PCAL9554BPW i2c_wr ;

\ Configurate output type to pushpull or open-drain
\ ( n1 -- )  n1:1=open-drain 0=pushpull
: output_config OutputConfig PCAL9554BPW i2c_wr ;

\ Print bit
\ ( n1 -- ) n1:data
: bitprint
h80
8 0 do
     2dup and
     if 1 . else 0 . then       
     1 rshift 
     space
loop
2drop
;


{
 GPIO terminal connection
P7 ----- P3
P6 ----- P2
P5 ----- P1
P4 ----- P0
}
\ ( -- )
\ ( -- )
: I/O-test
." [P7 P6 P5 P4] --> [P3 P2 P1 P0]" cr
."  b7 b6 b3 b4 b3 b2 b1 b0" cr             
\ [P7 P6 P5 P4]=output  [P3 P2 P1 P0]=input
hF config
4 0 do
     1 i 4 + lshift OutPort PCAL9554BPW i2c_wr          
     OutPort PCAL9554BPW i2c_rd 
     InPort PCAL9554BPW i2c_rd hF and  or
     bitprint
     cr
loop
cr
." [P7 P6 P5 P4] <- [P3 P2 P1 P0]" cr
."  b7 b6 b3 b4 b3 b2 b1 b0" cr             
\ [P7 P6 P5 P4]=input  [P3 P2 P1 P0]=output
hF0 config
4 0 do
     1 3 i - lshift OutPort PCAL9554BPW i2c_wr          
     OutPort PCAL9554BPW i2c_rd 
     InPort PCAL9554BPW i2c_rd hF0 and  or
     bitprint
     cr
loop
;

