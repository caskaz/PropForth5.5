fl                                                               fl

{
PropForth 5.5(DevKernel)

16bit I/O Expander(MCP23017)
Using i2c_utility_0.4.1.f 
2016/03/19 23:16:33

     
Propeller     MCP23017     
SCL ---------  SCL
SDA ---------  SDA
3V3 ---------  3V3
GND ---------  GND
GND ---------  A0
GND ---------  A1
GND ---------  A2
         3V3
          |
        10kohm
          |
P0  ---------  RESET
               
}

\ Register string-data in dictionary
: s, parsenw dup C@ 1+ bounds dup rot2 do C@++ c, loop drop ;

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
\ Slave addres h20 for MCP23017
0 wconstant addr_input                  \ A2=A1=A0=0
h40 addr_input 1 lshift or wconstant MCP23017

\ reset pin[P0]
0 wconstant RST               

\ register
0 wconstant IODIR
2 wconstant IPOL
4 wconstant GPINTEN
6 wconstant DEFVAL
8 wconstant INTCON
hA wconstant IOCON
hC wconstant GPPU
hE wconstant INTF
h10 wconstant INTCAP
h12 wconstant GPIO
h14 wconstant OLAT

\ Define string data
wvariable reg_name -2 allot 
s, IODIRA s, IODIRB s, IPOLA s, IPOLB s, GPINTENA s, GPINTENB s, DEFVALA s, DEFVALB s, INTCONA 
s, INTCONB s, IOCON s, IOCON s, GPPUA s, GPPUB s, INTFA s, INTFB s, INTCAPA s, INTCAPB s, GPIOA 
s, GPIOB s, OLATA s, OLATB

\ =========================================================================== 
\ Main 
\ =========================================================================== 
\ Print out string inside string table
\ ( n1 n2 -- ) n1:index(0,1,2,..,n) n2:stringarray's address
: dispStr
swap dup 0 <>
if
     0 do dup C@ + 1+ loop
else
     drop
then
\ Print string
.cstr
;

\ Print tab
\ ( -- )
: tab 9 emit ;

\ ( n1 n2 -- )  n1:8bits n2:register 
: wr_MCP23017 MCP23017 i2c_wr ;      

\ Read registerA/B[2byte]
\ ( n1 -- n2 ) n1:register  n2:data
: rd_MCP23017 MCP23017 i2c_rd ;

{
Write each registers[****A/****B]
register
IODIR     I/O Direction regisrwe   IODIRA(lower8bits)/IODIRB(upper8bits)  1=input 0=output
IPOL      Input Porality Register  IPOLA(lower8bits)/IPOLB(upper8bits)  1=oppsitelogic state 0=same logic state
GPINTEN   Interrup-On-register     GPINTENA(lower8bits)/GPINTENB(upper8bits)  1=enable 0=disable
DEFVAL    Default Value Register   DEFVALA(lower8bits)/DEFVALB(upper8bits)  
INTCON    Interrupt-On-Change Control Register    INTCONA(lower8bits)/INTCONB(upper8bits)    
                                       1=compared for interupt-on-change 0=compared against previous value
IOCON     I/O Expander Configuration Register     IOCONA(lower8bits)/IOCONB(upper8bits)
GPPU      Pullup Resistor Register GPPUA(lower8bits)/GPPUB(upper8bits)  1=Pull-up enabled  0= Pull-up disabled
INTF      Interupt Flag Register          
GPIO      General Purpose I/O Port Register  GPIOA(lower8bits)/GPIOB(upper8bits)      1=logic-hi  0=logic-lo
OLAT      Output Latch Register   OLATA(lower8bits)/OLATB(upper8bits)      1=logic-hi  0=logic-lo
}
\ Display all registers(IOCON.BANK=0:Default)
\ ( -- )   
: disp_reg
hex
." Register name" tab ." data[hex]" cr
d22 0 do
     \ Print register name
     i reg_name dispStr tab
     i 4 5 between 0= if tab then 
     \ Print data
     i rd_MCP23017 . cr
loop
decimal
;

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
GPA7 ----- GPB7
GPA6 ----- GPB6
GPA5 ----- GPB5
GPA4 ----- GPB4
GPA3 ----- GPB3
GPA2 ----- GPB2
GPA1 ----- GPB1
GPA0 ----- GPB0
}
\ ( -- )
: I/O-test
\ GPIOA:Input  GPIOB:Output
." GPIOB                     GPIOA" cr
." b7 b6 b5 b4 b3 b2 b1 b0    b7 b6 b5 b4 b3 b2 b1 b0" cr 
hFF IODIR wr_MCP23017
0 IODIR 1+ wr_MCP23017

8 0 do
     1 i lshift dup bitprint GPIO 1+ wr_MCP23017
     ." --> "
     GPIO rd_MCP23017 bitprint 
     cr
loop
cr
\ GPIOA:Output  GPIOB:Intput
." GPIOA                      GPIOB" cr
." b7 b6 b5 b4 b3 b2 b1 b0    b7 b6 b5 b4 b3 b2 b1 b0" cr 
hFF IODIR 1+ wr_MCP23017
0 IODIR wr_MCP23017

8 0 do
     1 i lshift dup bitprint GPIO wr_MCP23017
     ." --> "
     GPIO 1+ rd_MCP23017 bitprint 
     cr
loop
cr
;     
