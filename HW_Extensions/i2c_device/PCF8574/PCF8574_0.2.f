fl

{
PropForth 5.5(DevKernel)

8bit I/O Expander(PCF8574)
Using i2c_utility_0.4.1.f 
2016/03/15 11:16:56

    PCF8574 module      Propeller
           Vcc    ----  3.3V
           GND    ----  GND
           SDA    ----  P29(SDA)   
           SCL    ----  P28(SCL) 
           P0     ----  P0
           P1     ----  P1     
           P2     ----  P2      
           P3     ----  P3       
           P4     ----  P4       
           P5     ----  P5       
           P6     ----  P6      
           P7     ----  P7    
     A2=A1=A0=GND


}

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
\ Slave addres h20 for PCF8574
h40 wconstant PCF8574
\ A2=A1=A0=0
0 wconstant addr

\ =========================================================================== 
\ Main 
\ =========================================================================== 
\ Read ports of PCF8574
\ ( n1 -- n2 nn )    n1:repeat number  n2-nn:data
: rd_PCF8574
\ Start I2C 
_eestart
\ Write slave address[rd], then receive Acknowledge-bit(ACK:Lo  NACK:Hi) 
PCF8574 addr 1 lshift or 1 or _eewrite      \ ( n1 t/f ) 
>r                                                \ ( n1 )
dup 1 >
if
     \ Read (n1-1)bytes
     1- 0 do
          0 _eeread                               \ ( n2..nn-1 )
     loop
else
     drop
then
\ Read 1byte ,then set sda to Hi(NACK:master->slave)
-1 _eeread                                        \ ( n2..nn )
r>                                                \ ( n2..nn t/f )
\ Stop I2C
_eestop
err?                                         
;
 
          
\ Output to ports of PF8574
\ ( n1 nn n2 -- )  n1-nn:data  n2:repeat number
: wr_PCF8574
\ Start I2C 
_eestart
\ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi) 
PCF8574 addr 1 lshift or _eewrite      \ ( n1 nn n2 t/f ) 
swap                                         \ ( n1 nn t/f n2 ) 
0 do                                         \ ( n1 nn t/f )
     swap                                    \ ( n1 t/f nn )
     _eewrite or                             \ ( n1 t/f )
loop
_eestop
err?                                         
;


\ Input test
\ PCF8574 module <--- Propeller
\ ( -- )
: demo1
\ Set ports(P0-P7) to output
8 0 do i pinout loop

d256 0 do
     i outa COG!
     1 rd_PCF8574 .
     i d16 u/mod drop d15 = if cr then
loop
cr
;

\ Output test
\ PCF8574 module ---> Propeller
\ ( -- )
: demo2
\ Set ports(P0-P7) to input
8 0 do i pinin loop

d256 0 do
     i 1 wr_PCF8574
     ina COG@ hFF and .
     i d16 u/mod drop d15 = if cr then
loop
cr
;

