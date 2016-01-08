fl

{
   Thermal printer ID597(ver 2.68)
    PropForth 5.5       
    2014/12/14 22:09:02
    
               ID597       PowerSupply
               1 GND ------ GND
               2 NC
  Propeller    3 VH  ------ 5V4A
    Gnd ------ 4 Gnd           
    P1  ------ 5 Rx
    P0  ------ 6 Tx
    
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

0 wconstant Rx
1 wconstant Tx
d19200 constant baud


\ =========================================================================== 
\ Main 
\ =========================================================================== 
{
half duplex serial structure
00 - 03 -- bitticks
04 - 07 -- rx pin mask
08 - 0B -- tx pin mask
}
\ hdserialStruct X ( baud rxpin txpin -- )   X is structure's name
: hdserialStruct
	lockdict variable 8 allot lastnfa nfa>pfa 2+ alignl freedict
	tuck swap >m swap 8 + L!
	tuck swap >m swap 4 + L!
	swap clkfreq swap u/ swap L!
;

\ Assembler word Half Duplex serial Transmit
\ ( n1 n2 -- )  n1:sending data n2:hdserialStruct's name 
lockdict create a_hdserialTx forthentry
$C_a_lxasm w, h127  h113  1- tuck - h9 lshift or here W@ alignl h10 lshift or l,
z8i[ZB l, z20yPO8 l, z8i[eB l, z1SyLI[ l, z1biPS] l, zfyPO1 l, z2WyPbB l, z2WiPn[ l,
z20iPqk l, z1YVPO1 l, z1rixn\ l, z3riPn[ l, zbyPO1 l, z3[yPfS l, z1SyLI[ l, z1[ixn\ l,
z1SV01X l, 0 l, 0 l, zC0 l,
freedict

\ Assembler word Half Duplex serial Receive
\ ( n1 -- n2 )  n1:hdserialStruct's name n2:receving data
lockdict create a_hdserialRx forthentry
$C_a_lxasm w, h126  h113  1- tuck - h9 lshift or here W@ alignl h10 lshift or l,
z8i[ZB l, z20yPO4 l, z8i[eB l, z2WyPW8 l, z2WyPO0 l, z2WiPf[ l, zbyPb2 l, z20iPf[ l,
z3jF[f\ l, z3nF[f\ l, z20iPik l, z3riPf[ l, z1YF[il l, zbyPO1 l, z1vyPQ0 l, z3[yP[U l,
z1SV01X l, 0 l, 0 l,
freedict

\ Build serial-structure
baud Rx Tx hdserialStruct serial


\ Send command to ThermalPrinter
\ ( nn-nm n1 -- )   nn-nm:data if needed  n1:command 
: prtcmd
dup                     
C@ over 2+ swap
0 do dup C@ serial a_hdserialTx 1+ loop drop                \ Serial out command
1+ C@ dup 0<>
if
     0 do serial a_hdserialTx loop                          \ Serial out data
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
     bounds do i C@ serial a_hdserialTx loop      \ Print string 
else 
     2drop 
then 
;

\ Get printer status
\ ( -- )
: GetStatus
ESC_v prtcmd linefeed  
serial a_hdserialRx 
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
     dup
     serial a_hdserialTx
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
     dup
     serial a_hdserialTx
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
     serial a_hdserialTx
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

\ bit image
: test
d10 2 DC2_* prtcmd 
hEE serial a_hdserialTx
hEE serial a_hdserialTx
hEE serial a_hdserialTx
hEE serial a_hdserialTx
hEE serial a_hdserialTx
hEE serial a_hdserialTx
hEE serial a_hdserialTx
hEE serial a_hdserialTx
hEE serial a_hdserialTx
hEE serial a_hdserialTx
hEE serial a_hdserialTx
hEE serial a_hdserialTx
hEE serial a_hdserialTx
hEE serial a_hdserialTx
hEE serial a_hdserialTx
hEE serial a_hdserialTx
hEE serial a_hdserialTx
hEE serial a_hdserialTx
hEE serial a_hdserialTx
hEE serial a_hdserialTx
linefeed 
;






{
( n1 n2 -- )
entry  n1:sending data n2:hdserialStruct's name 

Using register inside
       $C_treg2:loop counter
       $C_treg3:ticks(1bit)
       
exit   none

fl
build_BootOpt :rasm
          rdlong    __bitticks , $C_stTOS
          add       $C_stTOS , # 8
          rdlong    __txmask , $C_stTOS
          spop
          
          or        $C_stTOS , __stopbit
          shl       $C_stTOS , # 1
          
          mov       $C_treg2 , # d11
          mov       $C_treg3 , __bitticks
          add       $C_treg3 , cnt
          
__txloop
          test      $C_stTOS , # 1 wz
          muxz      dira , __txmask
          waitcnt   $C_treg3 , __bitticks
          shr       $C_stTOS , # 1
          djnz      $C_treg2 , # __txloop
          spop
          
          andn      dira , __txmask
          jexit
          
__bitticks
     0
__txmask
     0
__stopbit
     h300
     
;asm a_hdserialTx 

}
{
( n1 -- n2 )
entry  n1:hdserialStruct's name 

Using register inside
       $C_treg1:loop counter
       $C_treg2:next bit count(1st:1.25bit, 2nd-8th:1bit)
       
exit   n2:receive data

fl
build_BootOpt :rasm
          rdlong    __bitticks , $C_stTOS
          add       $C_stTOS , # 4
          rdlong    __rxmask , $C_stTOS
          
          mov       $C_treg1 , # 8
          mov       $C_stTOS , # 0
          mov       $C_treg2 , __bitticks
          shr       $C_treg2 , # 2
          add       $C_treg2 , __bitticks

          \ Wait from hi to lo transition
          waitpeq   __rxmask , __rxmask 
          waitpne   __rxmask , __rxmask
          
          \ first loop tick count (1.25bit+cnt)
          add       $C_treg2 , cnt
__rxloop
          \ 1bit+cnt
          waitcnt   $C_treg2 , __bitticks
          test      __rxmask , ina wz
          shr       $C_stTOS , # 1
          muxnz     $C_stTOS , # h80
          djnz      $C_treg1 , # __rxloop
          
          jexit
          
__bitticks
     0
__rxmask
     0
     
;asm a_hdserialRx 

}
{
\ --------------------------
\ serial communication test
\ --------------------------
\
\      3.3V
\       |
\     10kohm
\       |
\  P0 ------ P1
\
\
: transmit
\ 0 outa COG! 0 dira COG!
0 begin dup serial a_hdserialTx 1+ d100 delms 0 until
;
: test
c" transmit" 0 cogx
d100 delms
begin serial a_hdserialRx . fkey? swap drop until
0 cogreset
;

Result below;
Prop0 Cog6 ok
test
1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 Prop0 Cog6 ok
}

