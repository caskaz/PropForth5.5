fl

{
PropForth 5.5(DevKernel)
PulseMonitor

ADC/LCD/Printer BasicCommand
2018/04/17 19:54:00
                       
}

\ ==================================================================
\ Main
\ ================================================================== 
: bufTop here W@ alignl ;
\ ----- ADC -----
\ : cs_l cs pinlo ;
: cs_h cs pinhi ;

\ A/D conversion by MCP3204 single-mode CH0
\ ( n1 -- n2 )  n1:mcs  n2: ADC value[0-4095]
lockdict create a_ADC forthentry
$C_a_lxasm w, h138  h113  1- tuck - h9 lshift or here W@ alignl h10 lshift or l,
z2Wi]RB l, zfyPO1 l, z2Wi]ZB l, zfyPO1 l, z2Wi]eB l, zfyPO1 l, z2Wi]mB l, z2WiPSq l,
z2WyPb5 l, z1[ix[m l, zgyPO1 l, z1jix[n l, z1Sy]Kf l, z3[yPfT l, z1[ix[n l, z1Sy]Kf l,
z2WyPbD l, zfyPO1 l, z1Sy]Kf l, z1YF]il l, z20oPO1 l, z3[yPf[ l, z1[ix[p l, z1bix[m l,
z1SV01X l, z1[ix[p l, z2WyPWB l, z20iPak l, z3ryPW0 l, z1bix[p l, 0 l, z1SV000 l,
0 l, 0 l, 0 l, 0 l, z300000 l,
freedict

\ ----- LCD -----
\ Serial-out 1byte to LCD(ST7735R)
\ ( n1 n2 -- )  n:1byte data   n2:lcdpin
lockdict create a_byteWr forthentry
$C_a_lxasm w, h123  h113  1- tuck - h9 lshift or here W@ alignl h10 lshift or l,
z2Wi[BB l, zfyPO1 l, z2Wi[JB l, z1SyLI[ l, z2WyPW8 l, zfyPOO l, zoyPO1 l, z1jix[X l,
z1bix[Y l, z1[ix[Y l, z3[yP[P l, z1[ix[X l, z1SyLI[ l, z1SV01X l, 0 l, 0 l,
freedict

\ Shift LCD-dots to left 
\ ( n1 n2 n3 -- )   n1:signal address n2:buffer address n3:mSDA
lockdict create a_dotShift forthentry
$C_a_lxasm w, h167  h113  1- tuck - h9 lshift or here W@ alignl h10 lshift or l,
z2WifJB l, zfyPO1 l, z2WifRB l, zbyPO2 l, z2WifZB l, z1SyLI[ l, z2WifeB l, z1SyLI[ l,
z2WyPW1 l, z2WyflV l, z8iPg\ l, zbyPb5 l, z20yPb2 l, z1SyeD9 l, z2WyPj0 l, z1SyfDQ l,
z20yfb4 l, z8iPg\ l, z2WiQBD l, z24yfb4 l, z8FQD\ l, zbyPb5 l, z20yPb2 l, z1SyeD9 l,
z2WyPmy l, z1SyfDQ l, z20yfb4 l, z20yPW1 l, z3[yfnT l, z2WyPYW l, z8iPg\ l, zbyPb5 l,
z20yPb2 l, z1SyeD9 l, z2WyPj0 l, z1SyfDQ l, z4iPeB l, z1SyLI[ l, z8FPg\ l, zbyPb5 l,
z20yPb2 l, z2WyPYW l, z1SyeD9 l, z2WyPmy l, z1SyfDQ l, z1SV01X l, z2WyQ08 l, zfyPrO l,
zoyPr1 l, z1jix\Y l, z1bix\Z l, z1[ix\Z l, z3[yQ53 l, z1SV000 l, z1[ix\[ l, z2WyPrd l,
z1Syc51 l, z1bix\[ l, z2WyPr0 l, z1Syc51 l, z2WiPuD l, z1Syc51 l, z1[ix\[ l, z2WyPre l,
z1Syc51 l, z1bix\[ l, z2WyPr0 l, z1Syc51 l, z2WiPuC l, z1Syc51 l, z1SV000 l, z1[ix\[ l,
z2WyPrf l, z1Syc51 l, z1bix\[ l, z2WiPuE l, z1Syc51 l, z1Syc51 l, z1SV000 l, 0 l,
0 l, 0 l, 0 l, 0 l,
freedict

\ Updating pulse
\ ( n1 n2 -- )   n1:pulseValue address n2:varNum address
lockdict create a_dispDigits forthentry
$C_a_lxasm w, h19B  h113  1- tuck - h9 lshift or here W@ alignl h10 lshift or l,
z8iPZB l, z2WilJC l, zfyPW1 l, z2WilRC l, zbyPW2 l, z2WilZC l, z20yPO4 l, z2WikZB l,
z20yPO2 l, z4ikmB l, z20yPO2 l, z2WikuB l, z20yPO2 l, z2Wil3B l, z20yPO2 l, z2WilBB l,
z1SyLI[ l, z4ikeB l, z1SyLI[ l, z6iPhC l, z1SL04t l, z2WyPb0 l, z25Vkc[ l, z20mPb1 l,
z24mkc[ l, z1SJ04c l, z1YVPey l, z2WtPbA l, z4FPhF l, z2WyPb0 l, z25VkbA l, z20mPb1 l,
z24mkbA l, z1SJ04k l, z4FPhG l, z4FkhH l, z2WyPW3 l, z4FP]C l, z1SV05F l, z26VPb3 l,
z1SL052 l, z4iP]F l, z2WymHk l, z1SygwG l, z2WyPW2 l, z4FP]C l, z1SV05F l, z26VPb2 l,
z1SL05A l, z4iP]G l, z2WymI1 l, z1SygwG l, z2WyPW1 l, z4FP]C l, z1SV05F l, z4iP]H l,
z2WymIH l, z1SygwG l, z2WyPW0 l, z4FP]C l, z1SV01X l, z22yPW0 l, z1SQ05K l, z20ykk0 l,
z3[yP\I l, z2WyPWd l, z1Syi\r l, z2WyPb0 l, z2WyPkY l, z1SyjDw l, z2WyPb0 l, z2WyPl1 l,
z1SyjDw l, z2WyPWe l, z1Syi\r l, z2WyPb0 l, z2WiPpQ l, z1SyjDw l, z2WyPb0 l, z20yPjF l,
z1SyjDw l, z2WyPWf l, z1Syi\r l, z2WylbG l, z2WyljW l, z8ilxE l, zkylr1 l, z1Smjp2 l,
z1SvkU7 l, z3[yloc l, z20ykj4 l, z3[ylga l, z1SV000 l, z2WyQ08 l, zfyPrO l, zoyPr1 l,
z1jix]I l, z1bix]J l, z1[ix]J l, z3[yQ5l l, z1SV000 l, z1[ix]K l, z2WiPuC l, z1Syhwj l,
z1bix]K l, z1SV000 l, z2WiPuD l, z1Syhwj l, z2WiPuE l, z1Syhwj l, z1SV000 l, z2WyPr0 l,
z1Syhwj l, z2WyPr0 l, z1Syhwj l, z1SV000 l, z2WiPxO l, z1Syhwj l, z2WiPxP l, z1Syhwj l,
z1SV000 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l,
0 l, 0 l, 0 l, 0 l, 0 l, z7 l, z3W l, 0 l,
freedict

\ Fill screen(128X160dots) by single color 
\ ( n1 n2 -- )   n1:color(16bit) n3:mSDA
lockdict create a_fullScrn forthentry
$C_a_lxasm w, h14E  h113  1- tuck - h9 lshift or here W@ alignl h10 lshift or l,
z2WicBB l, zfyPO1 l, z2WicJB l, zbyPO2 l, z2WicRB l, z1SyLI[ l, z2WiPZB l, z1SyLI[ l,
z2WiceC l, zbyPW8 l, z2WicZC l, z2WyPWd l, z2WyPb2 l, z2WyPl1 l, z1Syc4v l, z2WyPWe l,
z2WyPb1 l, z2WyPlW l, z1Syc4v l, z1[ix\B l, z2WyPrf l, z1SyaSm l, z1bix\B l, z2WyPYW l,
z2WyPd0 l, z2WiPwC l, z1SyaSm l, z2WiPwD l, z1SyaSm l, z3[yPff l, z3[yP[e l, z1SV01X l,
z2WyQ08 l, zfyPrO l, zoyPr1 l, z1jix\9 l, z1bix\A l, 0 l, z1[ix\A l, z3[yQ4o l,
z1SV000 l, z1[ix\B l, z2WiPuC l, z1SyaSm l, z1bix\B l, z2WyPr0 l, z1SyaSm l, z2WiPuD l,
z1SyaSm l, z2WyPr0 l, z1SyaSm l, z2WiPuE l, z1SyaSm l, z1SV000 l, 0 l, 0 l,
0 l, 0 l, 0 l,
freedict

: res_l RES pinlo ;
: res_h RES pinhi ;
: d/cx_l D/CX pinlo ;
: d/cx_h D/CX pinhi ;
: csx_l CSX pinlo ;
: csx_h CSX pinhi ;

\ Write byte-data to ST7735R
\ ( n  -- )  n:1byte
: wrByte mSDA a_byteWr ;

\ Write command to ST7735R
\ ( n1 -- ) n1:command  
: wrCom d/cx_l wrByte d/cx_h ;

\ Write 16bit-color-data to RAM
\ ( n1 -- )  n1:16bit (RGB 5-6-5bit)
: pixel dup 8 rshift wrByte wrByte ;

\  Set initial data
\ ( n1 -- n2 )   :n1:address  n2:next address
: setInitData 
dup C@ wrCom
1+ dup C@ 0 do 1+ dup C@ wrByte loop
1+
;

\ Paint screen(128X160dots) by 16bit-color
\ ( n1 -- )  n1:16bit color
: fullScrn
h2B wrCom 0 wrByte 1 wrByte 0 wrByte d160 wrByte       \ y:row
h2A wrCom 0 wrByte 2 wrByte 0 wrByte d129 wrByte       \ x:column
h2C wrCom
d160 0 do
     d128 0 do dup pixel loop
loop
drop
;

\ initialize LCD(T18000T01  Controller:ST7735R)    Default:18bit-Color
\ ( -- )
: init_ST7735R
\ Set all port to output
RES 5 0 do dup pinout 1+ loop drop               
csx_h d/cx_h
\ Issue reset-pulse
res_h res_l res_h
csx_l
\ sleep out
h11 wrCom
d120 delms
initData d13 0 do setInitData loop
drop
\ Display on
h29 wrCom
csx_h
0 csx_l fullScrn csx_h                   \ Fill LCD-screnn by black
;

\ Display second-derivative graph
\ Set dots to [x,y]  x:[2..129] y:[1..160] 
\ ( -- )
: dispDeriv
d160 0 do
     h2B wrCom 0 wrByte i 1+ dup wrByte 0 wrByte wrByte                         \ y:row
     h2A wrCom 0 wrByte bufTop i 4* + L@ d32 / dup 2+ wrByte 0 wrByte wrByte    \ x:column
     h2C wrCom
     hFFFF pixel
loop
;

{
\ Set dot to [x,y]  x:1-160 y:2-129
\ ( n1 n2 -- )  n1:y n2:x
: plot
csx_l
h2B wrCom dup 0 wrByte wrByte 0 wrByte wrByte     \ y:row
h2A wrCom dup 0 wrByte wrByte 0 wrByte wrByte     \ x:column
h2C wrCom
hFF pixel
csx_h
;
}

\ Display analog-signal to LCD from roght to left
\ ( -- )
: lcd
init_ST7735R                                      \ Initialize LCD
bufTop d640 0 fill                                \ Clear buffer area
0 varNum 4+ W!
csx_l
cnt COG@                                          \ ( cnt )
begin
     lcdActive W@ 
     if
          signal bufTop mSDA a_dotShift                \ Shift dots to left in every 10msec
          pulseValue varNum a_dispDigits               \ Update pulse-value in every 40msec
     else
          secondDeriva W@
          if
               0 mSDA a_fullScrn                       \ Clear all screen
               dispDeriv                               \ Display 2nd derivarive graph
               4 0 do manAge varNum a_dispDigits loop  \ Display age of man
               4 0 do manAge varNum a_dispDigits loop  \ Display age of man
               begin secondDeriva W@ 0= until          \ Wait until inhibited displaying graph and age
               0 mSDA a_fullScrn                       \ Clear all screen
          then
     then
     begin cnt COG@ over - 10msec > until         \ ( cnt )
     drop cnt COG@                                \ ( cnt )
0 until
;

\ ----- TermalPrinter -----
\ Start up serial-communication
\ This need to execute when staring serial-communication at first
\ ( -- )
: initSerial
c" Tx Rx baud/4 serial" 4 cogx     \ Start serial on cog5
d100 delms
inchar 4 cogio 2+ W!               \ Set output of cog5 to inchar
h100 inchar W!                     \ Clear inchar
1 4 sersetflags
;

\ Stop Serial communication
\ This need to execute when finishing serial-communication at last
\ ( -- )
: stopSerial 0 4 cogio 2+ W! 4 cogreset ;

\ Transmit data[1byte]
\ ( n1 -- )  n1:transmitting byte
: Transmit
begin 4 cogio W@ h100 and until    \ Wait until input for serial-cog is under ready-state
4 cogio W!                         \ Write data to cog5's input
;

{
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
}

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

\ Set font size  ( n -- ) n:font size  7<n<24
: font_size GS_! prtcmd ;

\ Set small character
\ ( -- )
: small_char 1 ESC_! prtcmd ;

\ Initialize printer ( -- )
: init_prt ESC_@ prtcmd ;

\ Carrige return ( -- )
: linefeed LF prtcmd ;

\ Set up controll parameter
\ ( -- )
: setup
d20 d160 7 ESC_7 prtcmd       \ heating dots,heating time,heating interval 
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

\ ----- switch -----
\ read current sw-state
\ ( -- n1 ) n1:1[sw2 pushed], 2[sw1 pushed], 3[both are not pushed]
: rdSW ina COG@ swMask and sw1 rshift ;

\ Initialize sw 
\ ( -- )
: initSW 3 swState W! 0 debounce W! ; 
 
\ ----- pulseMonitor -----
{
\ Tab
: tab 9 emit ;
\ Display each value of pulseVar
\ ( -- )
: disp
pulseVar
cr 
." signal" tab tab dup W@ . cr
." thresh" tab tab 2+ dup W@ . cr
." Pulse" tab tab 2+ dup W@ . cr
." N" tab tab 2+ dup W@ . cr
." calcIBI" tab tab 2+ dup W@ . cr
." IBI" tab tab 2+ dup W@ . cr
." currentBeat" tab 2+ dup W@ . cr
." lastBeat" tab 2+ dup W@ . cr
." P" tab tab 2+ dup W@ . cr
." T" tab tab 2+ dup W@ . cr
." amp" tab tab 2+ dup W@ . cr
." pulse array" cr
2+ dup 
d10 0 do dup W@ . space 2+ loop drop cr
." pulseValue" tab d20 + dup W@ . cr
." 1stBeat" tab tab 2+ W@ . cr
;
}
\ Initial setting
\ ( -- )
: initPulse
0 currentBeat W!
0 lastBeat W!
d2048 thresh W!
d2048 P W!
d2048 T W!
d600 IBI W!
0 Pulse W!
0 amp W!
1 1stBeat W!
1 2ndBeat W!
0 N W!
0 pulseValue W!
0 rate d10 0 do 2dup W! 2+ loop 2drop
\ Set output ports
cs pinout cs_h _do pinout clk pinout
;

