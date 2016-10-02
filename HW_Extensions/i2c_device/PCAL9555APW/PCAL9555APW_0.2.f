fl

{                       
PropForth 5.5(DevKernel)

16bit I/O Expanda(PCAL9554BPW)
2016/10/02 15:12:48

    PCAL9555APW       Propeller
          SDA   ------  SDA
          SCL   ------  SCL
          
          A0   -------- 3.3V
          A1   -------- GND
          A2   -------- GND
}

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
\ Slave addres h21 for PCAL9555APW [A2=A1=0 A0=1]
h42 wconstant PCAL9555APW

\ register  
0 wconstant InPort0
1 wconstant InPort1
2 wconstant OutPort0
3 wconstant OutPort1
4 wconstant Porality0
5 wconstant Porality1
6 wconstant Config0
7 wconstant Config1
h40 wconstant Output_st0_L    \ CC0.3-CC0.0
h41 wconstant Output_st0_H    \ CC0.7-CC0.4
h42 wconstant Output_st1_L    \ CC1.3-CC1.0
h43 wconstant Output_st1_H    \ CC1.7-CC1.4
h44 wconstant InLatch0
h45 wconstant InLatch1
h46 wconstant Pull_u/d_ena0
h47 wconstant Pull_u/d_ena1
h48 wconstant Pull_u/d_sel0
h49 wconstant Pull_u/d_sel1
h4A wconstant Interrupt_mask0
h4B wconstant Interrupt_mask1
h4C wconstant Interrupt_status0
h4D wconstant Interrupt_status1
h4F wconstant OutputConfig

variable reg_num -4 allot 
h00 c, h01 c, h02 c, h03 c, h04 c, h05 c, h06 c, h07 c, 
h40 c, h41 c, h42 c, h43 c, h44 c, h45 c, h46 c, h47 c,
h48 c, h49 c, h4A c, h4B c, h4C c, h4D c, h4F c,


\ =========================================================================== 
\ Main 
\ =========================================================================== 

\ allocate string
\ ( -- )
: s, parsenw dup C@ 1+ bounds dup rot2 do C@++ c, loop drop ;

wvariable string -2 allot 
s, InputPort0 s, InputPort1 s, OutputPort0 s, OutputPort1
s, PoralityInversion0 s, PoralityInversion1 s, Configuration0 s, Configuration1 
s, OutputDriveStrength0 s, OutputDriveStrength0 s, OutputDriveStrength1 s, OutputDriveStrength1
s, InputLatch0 s, InputLatch1 s, Pull_up/down_enable0 s, Pull_up/down_enable1
s, Pull_up/down_selection0 s, Pull_up/down_selection1
s, InteruptMask0 s, InteruptMask1 s, InterruptStatus0 s, InterruptStatus1 
s, OutputPortConfiguration

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
d23 0 do
     reg_num i +
     C@ PCAL9555APW i2c_rd
     i string dispStr ." :" space
     ." h" . cr   
loop
decimal
cr
;

\ Seperate lower8bit and upper8bit
\( -- )
: lower hFF and ;
: upper 8 rshift ;

\ Set logic-porality of input port
\ ( n1 -- )  n1:16bit Upper8bit[P1_7 - P1_0] Lower8bit[P0_7 - P0_0] 1=inverting  0= normal
: porality_inv 
dup
lower Porality0 PCAL9555APW i2c_wr
upper Porality1 PCAL9555APW i2c_wr
;

\ Set port to input or output
\ ( n1 -- )  n1:16bit Upper8bit[P1_7 - P1_0] Lower8bit[P0_7 - P0_0] 1=input 0=output
: config
dup 
lower Config0 PCAL9555APW i2c_wr
upper Config1 PCAL9555APW i2c_wr
;

\ Set drive-capability for OutputDriveStrength0
\ OutputDriveStrength0 [CC0.7 CC0.6 CC0.5 CC0.4 CC0.3 CC0.2 CC0.1 CC0.0 ]
\ 00=x0.25 01=x0.5  10=x0.75  11=x1.0
\ ( n1 -- )  n1:16bit[CC0.7-CC0.0] 
: setDrive_st0
dup
lower Output_st0_L PCAL9555APW i2c_wr
upper Output_st0_H PCAL9555APW i2c_wr
;

\ Set drive-capability for OutputDriveStrength1
\ OutputDriveStrength0 [CC1.7 CC1.6 CC1.5 CC1.4 CC1.3 CC1.2 CC1.1 CC1.0 ]
\ 00=x0.25 01=x0.5  10=x0.75  11=x1.0
\ ( n1 -- )  n1:16bit[CC1.7-CC1.0] 
: setDrive_st1
dup
lower Output_st1_L PCAL9555APW i2c_wr 
upper Output_st1_H PCAL9555APW i2c_wr
;

\ Enable/Disable pull-up/pull-down resistor
\ ( n1 -- )  n1:16bit Upper8bit[P1_7 - P1_0] Lower8bit[P0_7 - P0_0]  1=enable  0=disable
: pull_up/dn_ena 
dup
lower Pull_u/d_ena0 PCAL9555APW i2c_wr
upper Pull_u/d_ena1 PCAL9555APW i2c_wr
;

\ Selection port to pull-up or pull-down resistor
\ ( n1 -- ) n1:16bit Upper8bit[P1_7 - P1_0] Lower8bit[P0_7 - P0_0]  1=pull-up resistor 0=pull-down resistor
: pull_up/dn_sel 
dup
lower Pull_u/d_sel0 PCAL9555APW i2c_wr 
upper Pull_u/d_sel1 PCAL9555APW i2c_wr
;

\ Select output type to pushpull or open-drain
\ ( n1 -- )  n1:bit1=config for P0_*  bit0=config for P1_*  1=open-drain 0=pushpull
: output_sel OutputConfig PCAL9555APW i2c_wr ;


\ Test for input and output
\ ( -- )
: demo
cr
." [Input port test]" cr
\ Set all port to input (porality is normal)
hFFFF config
0 porality_inv
\ Set all port to enable
hFFFF pull_up/dn_ena
\ Set all port to pull-down resistor
0 pull_up/dn_sel
."  P1_7 P1_6 P1_5 P1_4 P1_3 P1_2 P1_1 P1_0 P0_7 P0_6 P0_5 P0_4 P0_3 P0_2 P0_1 P0_0" cr
d16 0 do
     1 i lshift pull_up/dn_sel          \ Set only 1bit to pull-up
     InPort0 PCAL9555APW i2c_rd         \ Read Inport0[P0_*]
     InPort1 PCAL9555APW i2c_rd         \ Read Inport1[P1_*]
     8 lshift or
     \ Display bit
     h8000 d16 0 do 2dup and if ."     1" else ."     0" then 1 rshift loop 2drop
     cr
loop
cr

."  [Reverse input porality]" cr
hFFFF porality_inv
."  P1_7 P1_6 P1_5 P1_4 P1_3 P1_2 P1_1 P1_0 P0_7 P0_6 P0_5 P0_4 P0_3 P0_2 P0_1 P0_0" cr
d16 0 do
     1 i lshift pull_up/dn_sel          \ Set only 1bit to pull-up
     InPort0 PCAL9555APW i2c_rd         \ Read Inport0[P0_*]
     InPort1 PCAL9555APW i2c_rd         \ Read Inport1[P1_*]
     8 lshift or
     \ Display bit
     h8000 d16 0 do 2dup and if ."     1" else ."     0" then 1 rshift loop 2drop
     cr
loop
cr
                                  
." [Output port test]" cr
\ Set output to open-drain (Default:push-pull)
3 output_sel
\ Set all port to output 
0 config
."  P1_7 P1_6 P1_5 P1_4 P1_3 P1_2 P1_1 P1_0 P0_7 P0_6 P0_5 P0_4 P0_3 P0_2 P0_1 P0_0" cr
d16 0 do
     \ Set only 1bit to 1
     1 i lshift dup 
     OutPort0 PCAL9555APW i2c_wr                  \ Po_*
     8 rshift OutPort1 PCAL9555APW i2c_wr         \ P1_*
     \ Read Outport
     OutPort0 PCAL9555APW i2c_rd                  \ Po_*
     OutPort1 PCAL9555APW i2c_rd                  \ P1_*
     8 lshift or
     \ Display bit
     h8000 d16 0 do 2dup and if ."     1" else ."     0" then 1 rshift loop 2drop
     cr
loop
; 

