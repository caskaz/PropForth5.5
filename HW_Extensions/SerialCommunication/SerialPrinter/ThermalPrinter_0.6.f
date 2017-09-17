fl

{
   Thermal printer CSM-A2-T(ver 2.68)
    PropForth 5.5(DevKernel)       
    2017/09/17 19:26:40
    
                             CSM-A2-T     PowerSupply
                              1 GND ------ GND
                              2 NC
 Propeller                    3 VH  ------ 5V4A
  Gnd ----------------------- 4 Gnd           
                          
 P9(Rx)  -------------------- 5 Tx (3V3 when idle)
 P10(Tx) -------------------- 6 Rx (3V3 when idle)
               
    
RS232  19200bps  Noparity Stopbit1
time ------------------------------------------------------------>>
-------       ---------                               ------------
       |     |         |                             |
       |     |         |                             | 
        -----           -----------------------------
 idle   start bit0 bit1 bit2 bit3 bit4 bit5 bit6 bit7 stop  stop   idle
         bit                                           bit
       (always "0")                                  (always "1")
    
}
\ =========================================================================== 
\ Constants 
\ =========================================================================== 
\ Priner command
\ command-name( n1 n2 n3-nn) n1:command byte number n2:data byte number n3:command byte(1byte /2byte/nbyte) 
wvariable LF -2 allot 1 c, 0 c, h0A c,
\ wvariable HT -2 allot 1 c, 0 c, h09 c,                 \ No operation
\ wvariable FF -2 allot 1 c, 0 c, h0C c,                 \ Same as LF
wvariable ESC_J -2 allot 2 c, 1 c, h1B c, h4A c,
wvariable ESC_FF -2 allot 2 c, 0 c, h1B c, h0C c,
wvariable ESC_d -2 allot 2 c, 1 c, h1B c, h64 c,
wvariable ESC_= -2 allot 2 c, 1 c, h1B c, h3D c,
\ Line spacing setting command
wvariable ESC_2 -2 allot 2 c, 0 c, h1B c, h32 c,
wvariable ESC_3 -2 allot 2 c, 1 c, h1B c, h33 c,
wvariable ESC_a -2 allot 2 c, 1 c, h1B c, h61 c, 
wvariable GS_L -2 allot 2 c, 2 c, h1D c, h4C c,
wvariable ESC_$ -2 allot 2 c, 2 c, h1B c, h24 c,
wvariable ESC_B -2 allot 2 c, 1 c, h1B c, h42 c,
\ Character command
wvariable ESC_! -2 allot 2 c, 1 c, h1B c, h21 c,
wvariable GS_! -2 allot 2 c, 1 c, h1D c, h21 c,          
\ wvariable ESC_E -2 allot 2 c, 1 c, h1B c, h45 c,          \ No operation
wvariable ESC_SP -2 allot 2 c, 1 c, h1B c, h20 c,
wvariable ESC_S0 -2 allot 2 c, 0 c, h1B c, h0E c,
wvariable ESC_DC4 -2 allot 2 c, 0 c, h1B c, h14 c,
wvariable ESC_{ -2 allot 2 c, 1 c, h1B c, h7B c,
wvariable GS_B -2 allot 2 c, 1 c, h1D c, h42 c,
\ wvariable ESC_- -2 allot 2 c, 1 c, h1B c, h2D             \ No operation
wvariable ESC_% -2 allot 3 c, 0 c, h1B c, h25 c, 1 c,
wvariable ESC_& -2 allot 2 c, 4 c, h1B c, h26 c,
wvariable ESC_? -2 allot 3 c, 0 c, h1B c, h25 c, 0 c,
wvariable ESC_R -2 allot 2 c, 1 c, h1B c, h52 c,
wvariable ESC_t -2 allot 2 c, 1 c, h1B c, h74 c,
\ Bit Image command
wvariable ESC_* -2 allot 2 c, 3 c, h1B c, h2A c,
wvariable GS_/ -2 allot 2 c, 1 c, h1D c, h2F c,
wvariable GS_* -2 allot 2 c, 2 c, h1D c, h2A c,
wvariable GS_v -2 allot 3 c, 5 c, h1D c, h76 c, 0 c,
wvariable DC2_* -2 allot 2 c, 2 c, h12 c, h2A c,
wvariable DC2_V -2 allot 2 c, 2 c, h12 c, h56 c,
wvariable DC2_v -2 allot 2 c, 2 c, h12 c, h76 c,
\  Key control command
wvariable ESC_c -2 allot 3 c, 1 c, h1B c, h63 c, h35 c,
\ Init command
wvariable ESC_@ -2 allot 2 c, 0 c, h1B c, h40 c,
\ Status command
wvariable ESC_v -2 allot 2 c, 0 c, h1B c, h76 c,
wvariable GS_a -2 allot 2 c, 0 c, h1D c, h61 c,
wvariable ESC_u -2 allot 2 c, 0 c, h1B c, h75 c,
\ Bar code command
wvariable GS_H -2 allot 2 c, 1 c, h1D c, h48 c,
wvariable GS_h -2 allot 2 c, 1 c, h1D c, h68 c,
wvariable GS_x -2 allot 2 c, 1 c, h1D c, h78 c,
wvariable GS_w -2 allot 2 c, 1 c, h1D c, h77 c,
wvariable GS_k_1 -2 allot 2 c, 1 c,
wvariable GS_k_2 -2 allot 2 c, 2 c,
\ Control parameter command
wvariable ESC_7 -2 allot 2 c, 3 c, h1B c, h37 c,
wvariable ESC_8 -2 allot 2 c, 1 c, h1B c, h38 c,
wvariable DC2_# -2 allot 2 c, 1 c, h12 c, h23 c,
wvariable DC2_T -2 allot 2 c, 0 c, h12 c, h54 c,

\ serial for PropForth<-->ThermalPrinter
9 wconstant Rx
d10 wconstant Tx
d4800 constant baud/4    \ 19200/4

\ =========================================================================== 
\ Variables 
\ =========================================================================== 
wvariable inchar

\ =========================================================================== 
\ Main 
\ =========================================================================== 

\ Start up serial-communication
\ This need to execute when staring serial-communication at first
\ ( -- )
: initSerial
c" Tx Rx baud/4 serial" 5 cogx     \ Start serial on cog5
d100 delms
inchar 5 cogio 2+ W!               \ Set output of cog5 to inchar
h100 inchar W!                     \ Clear inchar
1 4 sersetflags
;

\ Stop Serial communication
\ This need to execute when finishing serial-communication at last
\ ( -- )
: stopSerial 0 5 cogio 2+ W! 5 cogreset ;

\ Transmit data[1byte]
\ ( n1 -- )  n1:transmitting byte
: Transmit
begin 5 cogio W@ h100 and until    \ Wait until input for serial-cog is under ready-state
5 cogio W!                         \ Write data to cog5's input
;

\ Receive data and save them in free area
\ ( n1 -- n2 ) n1:repeat number  n2:last addres+1 of free area 
: Receive
here W@ swap
0 do
     begin inchar W@ h100 and 0= until       \ Wait until output for serial-cog is under ready-state
     inchar W@ over C!                       \ Save output-data of cog5 to free area
     h100 inchar W!                          \ Clear inchar
     1+                                      \ Increment free space address
loop
;

\ Send command to ThermalPrinter
\ ( nn-nm n1 -- )   nn-nm:data if needed  n1:command 
: prtcmd
dup                     
C@ over 2+ swap
0 do dup C@ Transmit 1+ loop drop            \ Serial out command
1+ C@ dup 0<>
if
     0 do Transmit loop                       \ Serial out data
else
     drop
then
;

\ -----------------------------------------------
\ Word for Thermal Printer
\ -----------------------------------------------
\ Initialize printer ( -- )
: init_prt ESC_@ prtcmd ;
\ Carrige return ( -- )
: linefeed LF prtcmd ;
\ code437 ( -- )
: code437 0 ESC_t prtcmd ;
\ code850 ( -- )
: code850 1 ESC_t prtcmd ;
\ Set bold font ( -- )
: bold_on 1 ESC_SP prtcmd ;
\ Cansel bold font ( -- )
: bold_off 0 ESC_SP prtcmd ;
\ Set double-width ( -- )
: double_width_on ESC_S0 prtcmd ;
\ Cansel double-width ( -- )
: double_width_off ESC_DC4 prtcmd ;
\ Set character updown ( -- )
: updown_on 1 ESC_{ prtcmd ;
\ Cansel character updown ( -- )
: updown_off 0 ESC_{ prtcmd ;
\ Set reverse mode  ( -- )
: reverse_prt_on 1 GS_B prtcmd ;
\ Cansel reverse mode ( -- )
: reverse_prt_off 0 GS_B prtcmd ;
\ Set font size  ( n -- ) n:font size  7<n<24
: font_size GS_! prtcmd ;
\ Set start-position to left
: left 0 ESC_a prtcmd ;
\ Set start-position to center
: center 1 ESC_a prtcmd ;
\ Set start-position to right
: right 2 ESC_a prtcmd ;
\ TAB (6 blank char)
: prt_tab 5 ESC_B prtcmd ;

\ --- ESC ! ---
\ Set small character
: small_char 1 ESC_! prtcmd ;
\ Set emphasized mode
: emphasize_char 8 ESC_! prtcmd ;
\ Set Double height mode
: heightX2_on h10 ESC_! prtcmd ;
\ Set Double width mode
: widthX2_on h20 ESC_! prtcmd ;
\ Set underline
: underline_on h80 ESC_! prtcmd ;
\ Cancel ESC !
: ESC_!_off 0 ESC_! prtcmd ;
\ --------------
     
\ Test print
: TEST DC2_T prtcmd ;
\ -----------------------------------------------

\ Set up controll parameter
\ ( -- )
: setup
2 d80 7 ESC_7 prtcmd          \ heating dots,heating time,heating interval        
hF8 DC2_# prtcmd              \ printing density
;               

\ Send string toprinter
\ ( n1 -- ) n1:cstr
: prt_str
C@++                               \ ( c-addr+1 c1 )  c-addr+1: string's first char addr  c1:string length
dup 
if 
     bounds do i C@ Transmit loop  \ Print string 
else 
     2drop 
then 
;

\ Get printer status
\ ( -- )
: GetStatus
ESC_v prtcmd                       \ Get paper sensor status 
linefeed  
1 Receive                          \ Receive 
here W@ C@                         \ Get data from free-area
cr
dup ." Printer Temperature:"
h40 and if ." Over 60 degree" else ." Normal" then cr
dup ." Power:"
8 and if ." > 9.5V" else ." Normal" then cr
." Paper:"
4 and if ." Empty" else ." ok" then cr
cr
;

: demo1
initSerial                                   \ This need when staring serial-communication at first
init_prt
setup
code437

\ Change density
hFF DC2_# prtcmd 
c" demo1" prt_str linefeed       
\ Back to original density
hF8 DC2_# prtcmd

c" Character code 437" prt_str linefeed

\ Print characters
h20                                                       
d224 0 do
     dup 
     Transmit                                  \ Transmitt
     1+
     i 1+ d32 u/mod drop 0=
     if linefeed then
loop
drop
linefeed
c" Test" prt_str prt_tab c" Test" prt_str linefeed
\ stopSerial
;

: demo2
init_prt
setup
code850

\ Change density
hFF DC2_# prtcmd 
c" demo2" prt_str linefeed
\ Back to original density
hF8 DC2_# prtcmd
                                                c" normal"  prt_str linefeed
c" Character code 850" prt_str linefeed

\ Print characters
h20
d224 0 do
     dup
     Transmit
     1+
     i 1+ d32 u/mod drop 0=
     if linefeed then
loop
drop
;

: demo3
init_prt
setup
                    
\ Change density
hFF DC2_# prtcmd 
c" demo3" prt_str linefeed
\ Back to original density
hF8 DC2_# prtcmd

small_char
c" small character" prt_str linefeed

\ Print characters
h20
d224 0 do
     dup
     Transmit
     1+
     i 1+ d42 u/mod drop 0=
     if linefeed then
loop
      linefeed
drop
\ Print different size font
d10 font_size
c" size 10" prt_str linefeed
d20 font_size
c" size 20" prt_str linefeed
d23 font_size
c" size 23" prt_str linefeed

init_prt
setup
left
c" Left" prt_str linefeed
center
c" Center" prt_str linefeed
right
c" Right" prt_str linefeed
;

: demo4
init_prt
setup
                    
\ Change density
\ hFF DC2_# prtcmd 
c" demo4" prt_str linefeed
\ Back to original density
\ hF8 DC2_# prtcmd

\ normal
c" normal"  prt_str linefeed
\ small_character
small_char
c" small character"  prt_str linefeed
ESC_!_off
\ enphasized mode
emphasize_char
c" emphasized mode"  prt_str linefeed
ESC_!_off
\ bold  
bold_on
c" bold font"  prt_str linefeed  
bold_off
\ Double height mode
heightX2_on
c" Double height mode"  prt_str linefeed
ESC_!_off   
\ Double width mode
widthX2_on
c" Double width mode"  prt_str linefeed  
ESC_!_off
\ updown
updown_on
c" updown mode"  prt_str linefeed  
updown_off
\ underline
underline_on
c" underline"  prt_str linefeed  
ESC_!_off
\ reverse  printing mode
reverse_prt_on
c" reverse printing mode"  prt_str linefeed  
reverse_prt_off
;
