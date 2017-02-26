fl
{                       
PropForth 5.5(DevKernel)

WiFi-Module(ESP-WROOM-02) 
2017/02/25 21:28:15

ESP-WROOM-02
      3V3  ---- 3V3 Power(more than 70mA)
      GND  ---- GND
      EN   --- 10kohm -- 3V3
      IO0  --- 10kohm -- 3V3
      IO2  --- 10kohm -- 3V3                  Propeller Board
      IO5  ---- GND
      TxD  ------------------------------------ P27(Rx)
      RxD  ------------------------------------ P26(Tx)
                GND --------------------------- GND

}
1 wconstant debug

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
d26 wconstant Tx
d27 wconstant Rx
d28800 constant baud/4         \ 115200/4

\ Defining word store string
\ ( -- )
: s, parsenw dup C@ 1+ bounds dup rot2 do C@++ c, loop drop ;
\ Replace "|"(h7C) inside just before string to space(h20)
\ ( -- )
: replace lastnfa nfa>pfa 2+ C@++ bounds do i C@ h7C = if h20 i C! then loop ;

\ command
wvariable AT -2 allot s, AT 
wvariable GMR -2 allot s, AT+GMR
wvariable CWMODE -2 allot s, AT+CWMODE_CUR=1
wvariable CIFSR -2 allot s, AT+CIFSR
wvariable CWJAP -2 allot s, AT+CWJAP_CUR="SSID","password"
wvariable CIPMUX -2 allot s, AT+CIPMUX=1
wvariable CIPSTATUS -2 allot s, AT+CIPSTATUS
wvariable CIPCLOSE -2 allot s, AT+CIPCLOSE=0
wvariable CIPSERVER -2 allot s, AT+CIPSERVER=1,80
wvariable CIPSEND -2 allot s, AT+CIPSEND=0,50
wvariable RST -2 allot s, AT+RST
wvariable html -2 allot  s, <html><h1>Hello!!|This|is|PropForth5.5</h1></html> replace
\ string
wvariable IP -2 allot s, +CIFSR:STAIP
wvariable connect -2 allot s, CONNECT
wvariable prompt -2 allot s, >
wvariable ok -2 allot s, SEND|OK replace
wvariable GET -2 allot s, :GET

\ =========================================================================== 
\ Variables 
\ =========================================================================== 
wvariable inchar h100 inchar W!
wvariable init
wvariable flag
wvariable IPaddr d13 allot
wvariable conID
wvariable endAddr

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
1 init W!
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

\ Check if WiFi operated
\ ( -- )
: WiFi? init W@ 0= if initWiFi then ;

\ Send AT-command to WiFi-module and receive data until last CR/LF reach
\ ( n1 -- n2 ) n1:string's address   n2:last address of free area
: sendCom
\ Transmitt
C@++ bounds do i C@ WiFi_Tx loop CRLF
\ Receivement                                                                      
begin USB_available until               \ Wait until receiveing start
here W@
begin 
     WiFi_Rx                            \ Receive 1byte 
     dup 1- C@ d75 =                    \ Check "K"
     if
          dup 2- C@ d79 =               \ Ckeck "O"
          if 1 else 0 then
     else
          0
     then     
until 
\ Receive last CR and LF
begin WiFi_Rx 1 delms USB_available 0= until                                           
;

\ Dump free area and print cstr
\ ( -- ) 
: DEBUG
endAddr W@ dup 
here W@ - dup . ." characters" cr
here W@ swap dump
here W@ do i C@ emit loop cr
;

\ Send AT-command to WiFi-module
\ ( n1 -- ) n1:address of command string 
: WiFicstr
sendCom d10 delms             
\ Print debug message
endAddr W!    
debug if DEBUG then
;

\ Flush Rx buffer
\ ( -- )
: flush 
here W@ begin WiFi_Rx USB_available 0= until 
dup here W@ - 0=
if
     ." receive buffer is empty"
else
     here W@ - here W@ swap dump 
     ." Flush finished!" 
then
cr
;

\ Data from client saved in free area
\ ( -- n1 ) n1:1/0
: receive
here W@
begin 
     WiFi_Rx                            \ Receive 1byte 
     1 delms                            \ delay
     USB_available 0=                    
until                                           
\ Print received data when there are data    
dup endAddr W! 
here W@ <>
;

\( n1 n2 - n3 ) n1:compared string n2:end address of free area  n3:address of free area when both are same
: searchStr
over C@ -                               \ ( n1 [n2-string_length] )
here W@ do                              \ ( n1 )
     \ Compare string
     1 over i swap                    \ ( n1 1 i n1 )
     \ i = address of free area j = string address
     C@++ bounds do                     \ ( n1 1 i )
          dup C@ i C@ = rot and          \ ( n1 i 1/0 )           
          if 
               1+                       \ Increment free area addr if character is same
               1 swap                   \ ( n1 1 i+1 )
          else 
               0 swap leave             \ ( n1 0 i )
          then       
     loop                      
     over    
     if 
          2drop i leave                 \ Break loop if both are same 
     else 
          2drop 
     then                    
     lasti? if 0 then                   \ Place 0 if loop finish
loop
nip
;     

\ Search IPaddress
\ ( n1 -- )  n1:top address of string"IPaddress"
: getIP
d14 + IPaddr 1+                         \ ( address IPaddr+1 )
begin
     2dup over C@ dup d34 <>            \ ( address IPaddr+1 address IPaddr+1 [address] 1/0 )
     if
          swap C! drop                  \ Save character to variable[IPaddr]
          1+ swap 1+ swap               \ Increment both address
          0                             \ Continue begin-loop
     else
          drop IPaddr - 1- IPaddr C!    \ Save number of character to top of variable[IPaddr]
          3drop 1                       \ Break brgin-loop
     then
until
;

\ Search CONNECT
\ ( n1 -- )  n1:top address of string"CONNECT"
: getCONNECT 2- C@ conID W! ;


\ Start WebServer (Send only text to client's browser)
\ ( -- )
: WebServer1
WiFi?
flag W@ 0=
if
     CWMODE WiFicstr 
     CWJAP WiFicstr 
     CIFSR WiFicstr 
     IP endAddr W@ searchStr dup 0<> if getIP else drop then    
     CIPMUX WiFicstr
     1 flag W!
then 
CIPSERVER WiFicstr                       
." IP address:" IPaddr .cstr cr
begin
     \ Receive data from TeraTerm
     \ ==== Check inside Rx Buffer ====                          
     receive                               
     \ true if there are data
     if
          debug if DEBUG then
          \ Search "CONNECT"
          connect endAddr W@ searchStr dup 0<>           \ ( [searched address]/0 1/0 )
          if                                           
               getCONNECT 
               ." connectionID:" conID W@ emit cr
               
               \ Search ":GET"
               GET endAddr W@ searchStr 0<> 
               if
                    \ Return back HTTP to client
                    CIPSEND WiFicstr 
                    prompt endAddr W@ searchStr 0<>
                    if
                         html dup C@ swap 1+ swap bounds do i C@ dup emit WiFi_Tx loop cr
                    else
                         ." -data ready-error"
                    then  
                    \ Search ""SEND OK"                   
                    begin 
                         receive                            \ Check Rx buffer 
                         if 
                              ok endAddr W@ searchStr       
                         else
                              0
                         then
                    until                     
                    debug if DEBUG then
                    CIPCLOSE WiFicstr   
               then                         
          else
               drop
          then             
     then                              
     fkey? swap drop    
until
;
