fl
{                       
PropForth 5.5(DevKernel)

WiFi-Module(ESP-WROOM-02) 
2017/02/13 14:10:04

ESP-WROOM-02
      3V3  ---- 3V3 Power(more than 70mA)
      GND  ---- GND
      EN   --- 10kohm -- 3V3
      IO0  --- 10kohm -- 3V3
      IO2  --- 10kohm -- 3V3                  Propeller
      IO15 ---- GND
      TxD  ------------------------------------ P27(Rx)
      RxD  ------------------------------------ P26(Tx)
                GND --------------------------- GND
                                                P3 -- 220ohm --LED--- GND

}

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
d26 wconstant Tx
d27 wconstant Rx
d28800 constant baud/4         \ 115200/4
3 wconstant LED

\ Defining word store string
\ ( -- )
: s, parsenw dup C@ 1+ bounds dup rot2 do C@++ c, loop drop ;
\ command
wvariable AT -2 allot s, AT 
wvariable GMR -2 allot s, AT+GMR
wvariable CWMODE -2 allot s, AT+CWMODE_CUR=1
wvariable CIFSR -2 allot s, AT+CIFSR
wvariable CWJAP -2 allot s, AT+CWJAP_CUR="elecom2g-d495d6","3762406455331"
wvariable CIPMUX -2 allot s, AT+CIPMUX=1
wvariable CIPSTART -2 allot s, AT+CIPSTART=4,"UDP","192.168.1.3",123,1112,0
wvariable CIPSEND -2 allot s, AT+CIPSEND=4,48
wvariable CIPSTATUS -2 allot s, AT+CIPSTATUS
wvariable CIPCLOSE -2 allot s, AT+CIPCLOSE=4
wvariable CIPSERVER -2 allot s, AT+CIPSERVER=1,23
wvariable PING -2 allot s, AT+PING="192.168.1.3"
wvariable RST -2 allot s, AT+RST

wvariable debug 1 debug W!

\ =========================================================================== 
\ Variables 
\ =========================================================================== 
wvariable inchar h100 inchar W!
\ ntp packet
variable ntp -4 allot
h00000023 l,           \ control_word
0 l,           \ root_delay
0 l,           \ root_dispersion
0 l,           \ reference_identifier
0 l, 0 l,      \ reference_timestamp
0 l, 0 l,      \ originate_timestamp
0 l, 0 l,      \ receive_timestamp
0 l, 0 l,      \ transmit_timestamp_seconds

wvariable flag
wvariable inchar
wvariable retry
variable timeout

\ =========================================================================== 
\ Main 
\ =========================================================================== 

\ Start up ESP-WROOM-02
\ ( -- )
: initWiFi
c" Tx Rx baud/4 serial" 5 cogx     \ Start serial on cog5
d100 delms
inchar 5 cogio 2+ W!               \ Set output of cog5 to inchar
h100 inchar W!                     \ Clear inchar
1 5 sersetflags                    \ CR is transmitted as CR
1 flag W!
;

\ Stop ESP-WROOM-02
\ ( -- )
: stopWiFi 0 5 cogio 2+ W! 5 cogreset ;

\ Transmit command and data
\ ( c1 -- ) n1:character code
: WiFi_Tx
begin 5 cogio W@ h100 and until         \ Wait until input for serial-cog is under ready-state
5 cogio W!                              \ Write data to cog5's input
;

\ Send CR
\ ( -- )
: CRLF d13 WiFi_Tx d10 WiFi_Tx ;

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

\ Dump free area
\ ( -- )
: DEBUG
dup here W@ - dup . ." characters" cr
here W@ swap dump
;

\ Send AT-command to WiFi-module
\ ( n1 -- n2 ) n1:string's address   n2:last address of free area
: sendCom
flag W@ 0= if initWiFi then
\ Transmitt
C@++ bounds do i C@ WiFi_Tx loop CRLF
\ Receivement                                                                      
begin USB_available until               \ Wait until receiveing start
here W@
begin 
     WiFi_Rx                            \ Receive 1byte 
     1 delms                            \ delay
     dup here W@ - 2 >=
     if
          dup dup 1-
          C@ d75 = swap                 \ Check "K"
          2 - C@ d79 = and              \ Ckeck "O"
          if 1 else 0 then
     else
          0
     then 
until 
[ifdef debug DEBUG ]
;

\ Send AT-command to WiFi-module
\ ( n1 -- ) n1:last address of free area
: WiFicstr
sendCom d10 delms        
\ Print received string    
here W@ do i C@ emit loop cr
;

\ Flush Rx buffer
\ ( -- )
: flush 
here W@ begin WiFi_Rx USB_available 0= until 
dup here W@ - 0=
if
     ." receive buffer is empty"
else
\     here W@ - here W@ swap dump 
     [ifdef debug DEBUG ]
     drop
     ." Flush finished!" 
then
cr
;

\ Data from telnet-client saved in free area
\ ( -- n1 ) n1:last address of received data
: receive
here W@
begin 
     WiFi_Rx                            \ Receive 1byte 
     1 delms                            \ delay
     USB_available 0=                    
until                                           
\ Print received data when there are data    
dup here W@ <>
if
     \ debug
     [ifdef debug DEBUG ]
\     dup here W@ - dup . ." characters" cr
\     dup here W@ swap dump
     dup here W@ do i C@ emit loop
then
;

\ Test telnet-server
\ LED on if received character is "1"
\ LED off if received character is "0"
\ ( -- )
: testTelnet
AT WiFicstr 
GMR WiFicstr 
CWMODE WiFicstr 
CWJAP WiFicstr 
CIFSR WiFicstr 
CIPMUX WiFicstr 
CIPSERVER WiFicstr
LED pinout

begin
     \ Receive data from TeraTerm
     receive
     \ Check if there are data
     dup here W@ <>                          
     if
          \ Search character ":"
          1- dup                              
          begin
               C@ d58 =                 \ ":"
               if
                    1+ 
                    C@ dup h31 =        \ LED on 
                    if 
                         drop LED pinhi 
                    else
                         h30 =
                         if
                              LED pinlo \ LED off
                         then
                    then
                    1
               else
                    \ Check address is less than [here W@]
                    1- dup here W@ < 
                    if drop 1 else dup 0 then
               then
          until
     else
          drop     
     then                  
     fkey? swap drop
until
;
