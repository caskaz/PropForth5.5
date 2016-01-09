fl

{
   Thermal printer CSM-A2-T(ver 2.68)
    PropForth 5.5(DevKernel)       
    2016/01/09 20:53:17
    
                                  CSM-A2-T     PowerSupply
                                   1 GND ------ GND
                                   2 NC
 Propeller                         3 VH  ------ 5V4A
  Gnd ---------------------------- 4 Gnd           
                  Si Diode         
 P0(Tx/Rx)--------P N------------- 5 Tx (3V3 when idle)
           |        |
           |       10kohm
           |        |
           |        |
           |       Base
            -Emitter  Collector--- 6 Rx (3V3 when idle)
                NPN Transistor
    
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

1 wconstant 1pinTxRx
d19200 constant baud


\ =========================================================================== 
\ Main 
\ =========================================================================== 
{
half duplex serial structure
00 - 03 -- bitticks
04 - 07 -- 1pin mask
}
\ hdserialStruct X ( baud 1pin -- )   X is structure's name
: hdserialStruct
	lockdict variable 4 allot lastnfa nfa>pfa 2+ alignl freedict
	tuck swap >m swap 4 + L!
	swap clkfreq swap u/ swap L!
;

{
Assembler word Half Duplex serial Transmit
Transmitt  
( n1 n2 -- ) n1:h100 + 8bit  n2:hdserialStruct's name
Receive
entry ( n1 n2 -- n3 ) n1:h00  n2:hdserialStruct's name   n3:receive data
}
lockdict create a_hdserial_1pin forthentry
$C_a_lxasm w, h136  h113  1- tuck - h9 lshift or here W@ alignl h10 lshift or l,
z8i]RB l, z20yPO4 l, z8i]ZB l, z1SyLI[ l, z1YVPS0 l, z1SQ04] l, z1biPSo l, zfyPO1 l,
z2WyPbB l, z2WiPnm l, z20iPqk l, z1YVPO1 l, z1rixnn l, z3riPnm l, zbyPO1 l, z3[yPfU l,
z1[ixnn l, z1SyLI[ l, z1SV01X l, z2WyPW8 l, z2WiPfm l, zbyPb2 l, z20iPfm l, z3jF][n l,
z3nF][n l, z20iPik l, z3riPfm l, z1YF]al l, zbyPO1 l, z1vyPQ0 l, z3[yP[g l, z1SV01X l,
0 l, 0 l, zC0 l,
freedict

\ Assembler word Half Duplex serial Receive
\ ( n1 -- n2 )  n1:hdserialStruct's name n2:receving data

\ Build serial-structure
baud 1pinTxRx hdserialStruct hd_1pin_serial

\ Add h100 to Transmit data
\ ( n1 -- ) n1:transmitt data
: TxOR h100 or ;

\ Send command to ThermalPrinter
\ ( nn-nm n1 -- )   nn-nm:data if needed  n1:command 
: prtcmd
dup                     
C@ over 2+ swap
0 do dup C@ TxOR hd_1pin_serial a_hdserial_1pin 1+ loop drop                \ Serial out command
1+ C@ dup 0<>
if
     0 do TxOR hd_1pin_serial a_hdserial_1pin loop                          \ Serial out data
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


\ Set up initial data when 5V is supplied on ID597
\ ( -- )
: setup
\ Set controll parameter
2 d80 7 ESC_7 prtcmd        
hF8 DC2_# prtcmd              
;               

\ Save string on ThermalPrinter-buffer
\ String are stored in buffer. 
\ linefeed print string and feeds one line.
\ ( n1 -- ) n1:cstr
: prt_str
C@++                                             \ ( c-addr+1 c1 )  c-addr+1: string's first char addr  c1:string length
dup 
if 
     bounds do i C@ TxOR hd_1pin_serial a_hdserial_1pin loop     \ Print string 
else 
     2drop 
then 
;

\ Get printer status
\ ( -- )
: GetStatus
ESC_v prtcmd linefeed  
hd_1pin_serial a_hdserial_1pin                                   \ Receive 
cr
dup ." Printer Temperature:"
h40 and if ." Over" else ." Normal" then cr
dup ." Power:"
8 and if ." Error" else ." Normal" then cr
." Paper:"
4 and if ." Empty" else ." ok" then cr
cr
;

: demo1
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
     dup TxOR 
     hd_1pin_serial a_hdserial_1pin                                   \ Transmitt
     1+
     i 1+ d32 u/mod drop 0=
     if linefeed then
loop
drop
linefeed
c" TAB" prt_str prt_tab c" TAB" prt_str linefeed
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
     dup TxOR 
     hd_1pin_serial a_hdserial_1pin                         \ Transmitt
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
     dup TxOR 
     hd_1pin_serial a_hdserial_1pin                         \ Transmitt
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




{
Transmitt  
entry ( n1 n2 -- ) n1:h100 + 8bit  n2:hdserialStruct's name
Using register inside
       $C_treg2:loop counter
       $C_treg3:ticks(1bit)       
exit   none

Receive
entry ( n1 n2 -- n3 ) n1:h00  n2:hdserialStruct's name   n3:receive data
Using register inside
       $C_treg1:loop counter
       $C_treg2:next bit count(1st:1.25bit, 2nd-8th:1bit)       
exit   receive data


fl
build_BootOpt :rasm
          rdlong    __bitticks , $C_stTOS
          add       $C_stTOS , # 4
          rdlong    __tx/rxmask , $C_stTOS
          spop

          test      $C_stTOS , # h100 wz
if_z      jmp       # __receive
\ Transmitt
          or        $C_stTOS , __stopbit
          shl       $C_stTOS , # 1
          
          mov       $C_treg2 , # d11
          mov       $C_treg3 , __bitticks
          add       $C_treg3 , cnt
          
__txloop
          test      $C_stTOS , # 1 wz
          muxz      dira , __tx/rxmask
          waitcnt   $C_treg3 , __bitticks
          shr       $C_stTOS , # 1
          djnz      $C_treg2 , # __txloop
          
          andn      dira , __tx/rxmask
          spop
          jexit

\ Receive
__receive
          mov       $C_treg1 , # 8
          mov       $C_treg2 , __bitticks
          shr       $C_treg2 , # 2
          add       $C_treg2 , __bitticks

          \ Wait from hi to lo transition
          waitpeq   __tx/rxmask , __tx/rxmask 
          waitpne   __tx/rxmask , __tx/rxmask
          
          \ first loop tick count (1.25bit+cnt)
          add       $C_treg2 , cnt
__rxloop
          \ 1bit+cnt
          waitcnt   $C_treg2 , __bitticks
          test      __tx/rxmask , ina wz
          shr       $C_stTOS , # 1
          muxnz     $C_stTOS , # h80
          djnz      $C_treg1 , # __rxloop
          
          jexit
          
__bitticks
     0
__tx/rxmask
     0
__stopbit
     h300
     
;asm a_hdserial_1pin
}

