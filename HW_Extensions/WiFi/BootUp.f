fl
{                       
PropForth 5.5(DevKernel)

WiFi-Module(ESP-WROOM-02) 
2017/02/17 14:16:58

ESP-WROOM-02
      3V3  ---- 3V3 Power(more than 70mA)
      GND  ---- GND
      EN   --- 10kohm -- 3V3
      IO0  --- 10kohm -- 3V3
      IO2  --- 10kohm -- 3V3                  QuickStart Board
      IO5  ---- GND
      TxD  ------------------------------------ P27(Rx)
      RxD  ------------------------------------ P26(Tx)
                GND --------------------------- GND

}

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
d26 wconstant Tx
d27 wconstant Rx
d18720 constant baud/4         \ 76800/4

\ =========================================================================== 
\ Variables 
\ =========================================================================== 
wvariable inchar h100 inchar W!

\ =========================================================================== 
\ Main 
\ =========================================================================== 
\ Check if USB is available
\ ( -- n1 ) n1:not 0 if there is data from ESP-WROOM-02
: USB_available inchar W@ hFF and ;

\ Receive data and save them in free area
\ ( n1 -- n2 ) n1:address saving received data   n2:n1+1 when there are data
: WiFi_Rx
USB_available
if
     inchar W@ over C!                  \ Save output-data of cog5 to free area
     h100 inchar W!                     \ Clear inchar
     1+                                 \ Increment free space address
then     
;

\ Receive Boot-up initial message from ESP-WROOM-02
\ ( -- )
: initialMsg
c" Tx Rx baud/4 serial" 5 cogx     \ Start serial on cog5
d100 delms
inchar 5 cogio 2+ W!               \ Set output of cog5 to inchar
h100 inchar W!                     \ Clear inchar
\ Wait until character reveive
begin USB_available until
d500 delms                         \ Delay time might need to adjst
\ Receive Boot up message
here W@
begin 
     WiFi_Rx                            \ Receive 1byte 
     1 delms                            \ delay
     USB_available 0=
until                                           

dup here W@ - dup . ." characters" cr
here W@ swap dump
\ Print received string    
here W@ do i C@ emit loop
\ Reset serial
0 5 cogio 2+ W! 5 cogreset 
;
