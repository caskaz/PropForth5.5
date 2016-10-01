fl

{
Single UART (SC16IS750IPW)
      
PropForth 5.5
2016/10/01 13:40:31   

2016/09/30 15:07:34

Propeller           SC16IS750IPW       
SDA       ------    SDA      
SCL       ------    SCL      
          
                    Tx    ------| Connect Tx and Rx when executing word"test"
                    Rx    ------|
   
RST      ------     RESET 
            
                    Xtal1　--------|----------     max Xtal=80MHz on 3.3V
                                   |         |     When using external clock, max24MHz should spply on Xtal1(Xtal2:open)
                              　　20MHz    22pF
                                   |         |
                                   |        GND
                    Xtal2　--------|
                                   |
                                  22pF
                                   |
                                  GND  
                       
                    A0   -------- 3.3V
                    A1   -------- GND

}

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
\ Slave addres h4C for SC16IS750IPW 
h98 wconstant SC16IS750IPW
0 wconstant RST

\ register  [b6 b5 b4 b3 0 0 0]<---[b3 b2 b1 b0] shift 3bit to left
\ General register set
0 wconstant RHR/THR
1 wconstant IER
2 wconstant IIR/FCR
3 wconstant LCR
4 wconstant MCR
5 wconstant LSR
6 wconstant MSR/TCR
7 wconstant SPR/TLR
8 wconstant TXLVL
9 wconstant RXLVL
hA wconstant IODir
hB wconstant IOState
hC wconstant IOIntEna
hE wconstant IOControl 
hF wconstant EFCR
\ special register set
0 wconstant DLL
1 wconstant DLH
\ Enhanced register set
2 wconstant EFR
3 wconstant XON1
4 wconstant XON2
5 wconstant XOFF1
6 wconstant XOFF2

\ =========================================================================== 
\ Main 
\ =========================================================================== 
\ allocate string
\ ( -- )
: s, parsenw dup C@ 1+ bounds dup rot2 do C@++ c, loop drop ;

wvariable string1 -2 allot 
s, RHR/THR s, IER s, IIR/FCR s, LCR s, MCR s, LSR s, MSR/TCR s, SPR/TLR
s, TXLVL s, RXLVL s, IODir s, IOState s, IOIntEna s, IOControl s, EFCR
wvariable string2 -2 allot 
s, DLL s, DLH
wvariable string3 -2 allot 
s, EFR s, XON1 s, XON2 s, XOFF1 s, XOFF2

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

\ Shift register number to left 3bit
\ ( n1 -- n2 ) n1:register number  n2:shift 3bit to left
: left3bit 3 lshift ;

\ Read register 1byte
\ ( n1 -- n2 ) n1:register number  n2:value
: byte_rd SC16IS750IPW i2c_rd ;

\ Display reg-name and value
\ ( n1 n2 -- ) n1:string index n2:string's top address
: dispValue dispStr ." :" ." h" ;

\ Display all registers 
\ ( -- )
: rd_allreg
cr hex
\ General register
RHR/THR
d15 0 do
     dup i + left3bit byte_rd                \ Read register value
     i string1 dispValue . cr                \ Print register-name and value
loop
drop

LCR left3bit SC16IS750IPW i2c_rd dup   
\ Accessible [Dll - XOFF2] only when LCR[7]=1   
h80 and
if
     \ Accessible [EFR - XOFF2] only when LCR=hBF
     hBF =
     if
          \ Enhanced rejister 
          EFR 
          5 0 do 
               dup i + left3bit byte_rd      \ Read register value 
               i string3 dispValue . cr      \ Print register-name and value
          loop 
          drop 
     else
          \ Special register
          DLL                                          
          2 0 do 
               dup i + left3bit byte_rd      \ Read register value     
               i string2 dispValue . cr      \ Print register-name and value
          loop 
          drop 
     then
else 
     drop
then    

decimal
cr
;

\ Soft Reset
\ ( -- )
: SoftReset
\ Start I2C 
_eestart
\ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi) 
SC16IS750IPW _eewrite         \ ( t/f )
\ Write register"IOControl"
h70 _eewrite or               \ ( t/f )
\ Write data (SC16IS750IPW return NACK)  
8 _eewrite invert or          \ ( t/f )   
\ Stop I2C
_eestop
err? 
;

\ Hardware Reset (using P0)
\ ( -- )
: HWReset RST pinout RST pinhi RST pinlo RST pinhi ;



\ Set GPIO 
\ GPIO[7]=GPIO7/RI GPIO[6]=GPIO6/CD GPIO[5]=GPIO5/DTR GPIO[4]=GPIO4/DSR 
\ GPIO[3]=GPIO3 GPIO[2]=GPIO2 GPIO[1]=GPIO1 GPIO[0]=GPIO0
\ Set 8-GPIO to input or output
\ ( n1 -- ) n1:IO-bitpattern output[1] inpur[0]
: GPIO
\ Set GPIO[7:4] to IO-pin
0 IOControl left3bit SC16IS750IPW i2c_wr 
\ Set GPIO-direction
IODir left3bit SC16IS750IPW i2c_wr 
\ Read status of IODir
IODir left3bit SC16IS750IPW i2c_rd             
." bit7    bit6    bit5    bit4    bit3    bit2    bit1    bit0" cr
h80 8 0 do 2dup and if ." OUT" else ." IN" then tab 1 rshift loop 2drop
cr
;

\ Read GPIO status
\ ( -- n1 ) n1:value
: rdGPIO IOState left3bit SC16IS750IPW i2c_rd ;

\ Write values to GPIO 
\ ( n1 -- ) n1:value 
: wrGPIO IOState left3bit SC16IS750IPW i2c_wr ;

\ Transmit/Receive characters
\ Connect Tx-pin and Rx-pin
\ Although checking errors, error-type doesn't check.
\ ( n1 -- )  n1:cstr
: test
cr
\ Set format(8bit 1Stopbit Noparity) and select spacial register set
h83 LCR left3bit SC16IS750IPW i2c_wr 
\ Set divisor-latch for baud rate generator(9600baud Xtal:20MHz)
d130 DLL left3bit SC16IS750IPW i2c_wr 
0 DLH left3bit SC16IS750IPW i2c_wr           
\ Cancel spacial register set 
3 LCR left3bit SC16IS750IPW i2c_wr
\ Enable Tx/Rx FIFO and reset them
7 IIR/FCR left3bit SC16IS750IPW i2c_wr  
 
\ Transmit
dup                                               \ ( cstr cstr ) 
C@ 0 do
     1+ dup C@
     RHR/THR left3bit SC16IS750IPW i2c_wr        \ Transmit 1 charcter
loop
drop     
                      
\ Receive
begin
     LSR left3bit SC16IS750IPW i2c_rd            \ Check if there is no data
     dup h8F and 
     if
          h8F and 1 >
          if
               \ There is error( FIFO-error or framing-error or parity-error or overrun^error)
               ." There is error"
               1
          else
               \ There is data
               RHR/THR left3bit SC16IS750IPW i2c_rd   \ Receive 1 charcter
               emit
               0
          then
     else
          \ There is no data
          drop
          1
     then
until         
cr cr
;
