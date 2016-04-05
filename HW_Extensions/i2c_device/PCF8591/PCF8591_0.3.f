fl

{                       
PropForth 5.5(DevKernel)

A/D D/A Converter(PCF8591)
Using i2c_utility_0.4.1.f 
2016/04/04 20:41:41

        PCF8591                         Propeller
          AN0   ------- Analog In0
          AN1   ------- Analog In1
          AN2   ------- Analog In2
          AN3   ------- Analog In3
          A0    ------- GND
          A1    ------- GND
          A2    ------- GND
          SDA   ------------------------  SDA
          SCL   ------------------------  SCL
          OSC   
          EXT   ------- GND (Selected internal OSC)
          AGND  ------- GND
          VREF  ------- 3.3V
          AOUT  ------- Analog Out
          VDD   ------- 3.3V
}

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
\ Slave addres h48 for PCF8591 
h90 wconstant PCF8591

\ --- control byte ---
\ channel
0 wconstant ch0          \ Default
1 wconstant ch1
2 wconstant ch2
3 wconstant ch3
\ Auto increment flag
0 wconstant auto_inact   \ Default
4 wconstant auto_act
\ Analog input programming
0 wconstant 4ch_single   \ Default
h10 wconstant 3ch_diff
h20 wconstant mix
h30 wconstant 2ch_diff 
\ Analog out enable flag
0 wconstant D/A_disab    \ Default
h40 wconstant D/A_enab

\ =========================================================================== 
\ Variables 
\ =========================================================================== 
wvariable contByte 

\ =========================================================================== 
\ Main 
\ =========================================================================== 
\ Read data (SCK:100kHz)
\ ( n1 -- n2..nn t/f )   n1:number  n2..nn:data  t/f:true if there was an error
: PCF8591_rd
\ Start I2C 
_eestart
\ Write slave address[rd], then receive Acknowledge-bit(ACK:Lo  NACK:Hi)
PCF8591 1 or std_eewrite      \ ( n1 t/f ) 
\ Read (n1-1)bytes
>r                            \ Push flag  ( n1 )
dup 1 > 
if 
     1 - 0 do 
          0 std_eeread        \ ( n2..nn-1 )
     loop
else
     drop
then
\ Read 1byte ,then set sda to Hi(NACK:master->slave)
-1 std_eeread                 \ ( n4..nn )
r>                            \ Pop flag   ( n2..nn t/f )
\ Stop I2C
_eestop                       \ ( n2..nn t/f ) 
err?                          \ ( n2..nn )                        
;

\ Write data (SCK:100kHz)
\ ( n1 n2 n3 n4 -- ) n1:D/A enable/disable n2:Analog input programming n3:Auto increment n4:channel
: PCF8591_wr 
or or or dup contByte W!      \ Save control byte
PCF8591 std_i2c_wr 
;


{
A/D test
Voltage[0-3v3] in ch0 convert to digital[0-255]
     3V3
      |                   PCF8591
      VR(10kohm)center--- AN0
      |
     GND 
} 
\ ( -- )
: A/D_test 
0 D/A_disab 4ch_single auto_inact ch0 PCF8591_wr 
begin 
     5 PCF8591_rd        \ Get 5pcs A/D-value 
     + + + + 5 / . cr    \ Print average
     fkey? swap drop
until
;

{
D/A out input to A/D channel ANIN0  
ANIN1=ANIN2=ANIN3=0V 
       PCF8591
       AIN0----AOUT
       AIN1----------GND
       AIN2----------GND
       AIN3----------GND
}            
\ ( -- )
: demo1
d256 0 do
     \ Output D/A to analog-output
     i D/A_enab 4ch_single auto_act ch0 PCF8591_wr      
     ." Setting[D/A]:" i . 2 spaces 
     d10 delms
     5 PCF8591_rd 
     ." ch3:" . ." ch2:" . ." ch1:" . ." ch0:" . ." previous-ch0:" .
     cr
loop
;

\ A/D conversion on 2 Differential mode
\ ( -- )
: demo2
0 D/A_enab 2ch_diff auto_inact ch0 PCF8591_wr

begin
     2 PCF8591_rd nip 
     contByte W@ h30 and     
     if
          \ 2 Differential mode
          dup h80 and    
          if
               h2D emit  \ Print "-"
               invert 1+ hFF and
          then
     then
     . cr
     d100 delms
     fkey? swap drop
until
;
