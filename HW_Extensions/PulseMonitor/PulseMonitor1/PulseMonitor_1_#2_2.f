fl

{
PropForth 5.5(DevKernel)
PulseMonitor

2017/10/16 17:19:50

}

\ ==================================================================
\ Main
\ ================================================================== 

\ ----- ADC -----
\ : cs_l cs pinlo ;
: cs_h cs pinhi ;

\ A/D conversion by MCP3204 single-mode CH0
\ ( n1 -- n2 )  n1:mcs  n2: ADC value
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

\ Shift LCD-dots to left dot by dot[1dot=10msec]
\ ( n1 n2 -- )  n1:buffer address  n2:mSDA
\ Using [here W@] as buffer
lockdict create a_dotShift forthentry
$C_a_lxasm w, h159  h113  1- tuck - h9 lshift or here W@ alignl h10 lshift or l,
z2WidJB l, zfyPO1 l, z2WidRB l, zbyPO2 l, z2WidZB l, z1SyLI[ l, z2WideB l, z1SyLI[ l,
z2WyPY1 l, z2Wydky l, ziPgL l, z1SycCs l, z2WiPoN l, z1SydDA l, z20ydb1 l, ziPgL l,
z24ydb1 l, zFPgL l, z1SycCs l, z2WiPoO l, z1SydDA l, z20ydb1 l, z24yPW1 l, z3[ydnT l,
z2WyPW2 l, ziPgL l, z1SycCs l, z2WiPoN l, z1SydDA l, z1SV01X l, z2WyQ08 l, zfyPrO l,
zoyPr1 l, z1jix\I l, z1bix\J l, z1[ix\J l, z3[yQ4m l, z1SV000 l, z1[ix\K l, z2WyPrd l,
z1Sya4k l, z1bix\K l, z2WyPr0 l, z1Sya4k l, z2WiPuC l, z1Sya4k l, z1[ix\K l, z2WyPre l,
z1Sya4k l, z1bix\K l, z2WyPr0 l, z1Sya4k l, z2WiPuD l, z1Sya4k l, z1SV000 l, z1[ix\K l,
z2WyPrf l, z1Sya4k l, z1bix\K l, z2WiPuE l, z1Sya4k l, z1Sya4k l, z1SV000 l, 0 l,
0 l, 0 l, 0 l, 0 l, 0 l, z3y l,
freedict

\ Updating pulse
\ ( n1 n2 -- )   n1:pulseValue address n2:varNum address
lockdict create a_dispDigits forthentry
$C_a_lxasm w, h1AC  h113  1- tuck - h9 lshift or here W@ alignl h10 lshift or l,
z4iPZB l, z26VPZ8 l, z1SL05O l, z2WiPZB l, z20yPO4 l, z8iPeB l, z2WinJD l, zfyPb1 l,
z2WinRD l, zfyPb1 l, z2WinZD l, zbyPb3 l, z2WineD l, z2WimRC l, z20yPW2 l, z2WimZC l,
z20yPW6 l, z4immC l, z20yPW2 l, z2WimuC l, z20yPW2 l, z2Win3C l, z20yPW2 l, z2WinBC l,
z1SyLI[ l, z2WimeB l, z6iPhS l, z1SL052 l, z4iP]T l, z2WyPb0 l, z25VPX[ l, z20mPb1 l,
z24mPX[ l, z1SJ04k l, z1YVPey l, z2WtPbA l, z4FPhV l, z2WyPb0 l, z25VPWA l, z20mPb1 l,
z24mPWA l, z1SJ04s l, z4FPhW l, z4FP]X l, z2WyPW3 l, z4FP]S l, z1SV05R l, z26VPb3 l,
z1SL05A l, z4iP]V l, z2WyoPl l, z1SyioT l, z2WyPW2 l, z4FP]S l, z1SV05R l, z26VPb2 l,
z1SL05I l, z4iP]W l, z2WyoPY l, z1SyioT l, z2WyPW1 l, z4FP]S l, z1SV05R l, z4iP]X l,
z2WyoPI l, z1SyioT l, z2WyPW0 l, z8FP]R l, z1SV05R l, z20yPW1 l, z4FPZB l, z1SyLI[ l,
z1SyLI[ l, z1SV01X l, z22yPW0 l, z1SQ05X l, z20ymjf l, z3[yP\V l, z1[ix][ l, z2WyPWd l,
z1SykU7 l, z2WyPb0 l, z2WiPpe l, z1Syl6C l, z2WyPb0 l, z20yPjF l, z1Syl6C l, z2WyPWe l,
z1SykU7 l, z2WyPb0 l, z2WyPl6 l, z1Syl6C l, z2WyPb0 l, z2WyPlR l, z1Syl6C l, z2WyPWf l,
z1SykU7 l, z2WynjM l, z2WynrG l, z4io6U l, zkyo01 l, z1SmlhH l, z1SvmMM l, z3[ynwq l,
z20ymj2 l, z3[ynoo l, z1bix][ l, z1SV000 l, z2WyQ08 l, zfyPrO l, zoyPr1 l, z1jix]Y l,
z1bix]Z l, z1[ix]Z l, z3[yQ61 l, z1SV000 l, z1[ix]\ l, z2WiPuC l, z1Syjoy l, z1bix]\ l,
z1SV000 l, z2WiPuD l, z1Syjoy l, z2WiPuE l, z1Syjoy l, z1SV000 l, z2WyPr0 l, z1Syjoy l,
z2WyPr0 l, z1Syjoy l, z1SV000 l, z2WiPxc l, z1Syjoy l, z2WiPxd l, z1Syjoy l, z1SV000 l,
0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l,
0 l, 0 l, 0 l, 0 l, 0 l, 0 l, z7 l, z3W l,
0 l,
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
csx_l
h2C wrCom
d160 0 do
     d128 0 do dup pixel loop
loop
drop
csx_h
;

\ initialize LCD(T18000T01  Controller:ST7735R)    Default:18bit-Color
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
0 fullScrn                    \ black
;

\ Set dot to [x,y]  x:2-129 y:1-160
\ ( n1 n2 -- )  n1:x n2:y
: plot
csx_l
h2B wrCom dup 0 wrByte wrByte 0 wrByte wrByte     \ x:row
h2A wrCom dup 0 wrByte wrByte 0 wrByte wrByte     \ y:colum
h2C wrCom
hFFFF pixel
csx_h
;

\ Display analog-signal to LCD from roght to left
\( -- )
: lcd
init_ST7735R                                      \ Initialize LCD
0 varNum L!
0 buffer d64 0 do 2dup W! 2+ loop 2drop           \ Clear buffer
10msec cnt COG@ +
begin
     stopPrinter W@
     if
          signal W@ 5 rshift 1+ dup bufferEnd C!
          2 swap plot                    
          csx_l buffer mSDA a_dotShift csx_h           \ Shift dots
          pulseValue varNum a_dispDigits               \ update pulse
     then
     10msec waitcnt
\     fkey? swap drop
0 until
\ drop
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

\ Set font size  ( n -- ) n:font size  7<n<24
: font_size GS_! prtcmd ;

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
\ ( -- n1 ) n1:true[sw:off] false[sw:on]
: rdSw ina COG@ swMask and ;

\ Initialize sw and led
\ ( -- )
: initSW
\ Set initial values
swMask swState W!
0 debounce W!
\ Set led to output   
\ ledMask dira COG@ or dira COG!                    
;
 
 
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

\ Get pulse-number
\ ( -- )
: GetPulse
\ c" lcd" 5 cogx
initPulse
2msec cnt COG@ +
begin                                              
     mcs a_ADC signal W!                          \ Get snsor-output

     3 IBI W@ * 5 u/ calcIBI W!                   \ Get (3/5)+IBI
     2 currentBeat W+!                            \ Add 2msec
     currentBeat W@ lastBeat W@ - N W!            \ Get N(difference from currentBeat to lastBeat)

     \ Check condition when signal less than thresh
     signal W@ thresh W@ < N W@ calcIBI W@ > and  
     if
          signal W@ T W@ < if signal W@ T W! then \ Update T
     then

     \ Check condition when signal is more than threshold
     signal W@ thresh W@ > signal W@ P W@ > and   
     if signal W@ P W! then                       \ Update P

     \ Calculate pulse when N>250(ie;pulse is less than 240/min)
     N W@ d250 >
     if
          signal W@ thresh W@ > Pulse W@ 0= N W@ calcIBI W@ > and and
          if
               1 Pulse W!
               currentBeat W@ lastBeat W@ -  IBI W!
               currentBeat W@ lastBeat W!   
               1stBeat W@
               if
                    0 1stBeat W! 
                    0 pulseValue W!              
               else  
                    2ndBeat W@
                    if
                         0 2ndBeat W!                            
                         IBI W@ rate 9 0 do 2dup W! 2+ loop 2drop     
                    else
                         \ Shift data inside rate-array         
                         rate 9 0 do i 1+ 2* over + W@ over i 2* + W! loop drop
                    then
                    IBI W@ rate d18 + W!
                    0 rate d10 0 do dup i 2* + W@ rot + swap loop drop
                    d10 / d60000 swap / pulseValue W!
               then
          then
     then
     \ Check condition during signal is rising down
     signal W@ thresh W@ < Pulse W@ 1 = and
     if                                               
          0 Pulse W!       
          P W@ T W@ - dup amp W!
          2/ T W@ + dup dup thresh W!
          P W! T W!
     then
     
     \ Check condition if signal go out for 2.5sec
     N W@ d2500 >
     if                                               
          \ Initialize thresh,P,T,lastBeat
          d2048 thresh W! d2048 P W! d2048 T W! 
          currentBeat W@ lastBeat W!
          1 1stBeat W!
     then
     
     2msec waitcnt                    
0 until
\ fkey? swap drop
\ until
;

\ Clear prnBuffer
\ ( -- )
: clr_prnBuffer 0 prnBuffer d24 0 do 2dup W! 2+ loop 2drop ;

\ Make dot-pattern (3dots) in prnBuffer array[48byte:384bit]
\ ( n1 -- )  n1:time axis on LCD[0-127]
: makeDots
d128 0 do
     dup
     i buffer + C@                 \ Get ADC value[0-127]  
     =
     if   
          \ Store bit-pattern in prnBuffer
          3 i *                    \ horizontal drection on printer[0-383] 
          8 u/mod                  \ ( n1 reminder quotient )
          dup 
          if
               \ plotted dots is inside [8-383]dots
               prnBuffer +         \ ( n1 reminder prnBuffer )
               hE000 rot           \ ( n1 prnBuffer hE000 reminder )
               rshift              \ ( n1 prnBuffer rshifted[E000] )
          else
               \ plotted dots is inside [0-7]dots
               2drop prnBuffer     \ ( n1 prnBuffer )
               hE000 i rshift      \ ( n1 prnBuffer rshifted[E000] )
          then
          2dup
          8 rshift                 \ ( n1 prnBuffer rshifted[E000] prnBuffer Hi_byte ) 
          over C@ or swap C!       \ ( n1 prnBuffer rshifted[E000] )
          hFF and dup              \ ( n1 prnBuffer Lo_byte Lo_byte )
          if
               swap 1+ C!    
          else
               2drop
          then
     then
loop
drop
;

\ print pulse on TeraTerm
: test
buffer
128 0 do dup i + C@ spaces h2E emit cr loop drop
;
\ print value inside prnBuffer[48byte]
: print prnBuffer d48 0 do dup C@ .byte 1+ loop drop ;  

\ print week
\ ( n1 -- )  (Mon:0 Tue:1 Wed:2 Thur:3 Fri:4 Sat:5 San:6)
: printWeek 
c" MONTUEWEDTHUFRISATSUN" 1+ swap 6 min 0 max 3 u* + 
3 0 do dup C@ Transmit 1+ loop drop
;

\ Print number to printer
\ ( n1 -- )
: printNum
0 result W! d1000000000 tmp L!
d10 0 do 
     dup tmp L@ >=                                     \ Check if n is bigger than tmp
     if 
          tmp L@ u/mod h30 +  Transmit 1 result W!     \ Print number-char
     else 
          result W@ tmp L@ 1 = or 
          if h30 Transmit then                        \ Print "0"
     then
     tmp L@ d10 u/ tmp L!                              \ Divide tmp by d10 
loop
drop
;
 
\ Print time to get from rtc
\ ( -- )
: printTime
8 font_size
d10 3 do i PCF2129_rd loop         \ Get time(year.month,weekday,date,hour,minute)
bcd> d2000 + printNum c" /" prt_str 
bcd> printNum c" /" prt_str
>r
bcd> printNum  c"    " prt_str
bcd> printNum  c" :" prt_str bcd> printNum 
c"    " prt_str r> printWeek 
linefeed d1000 delms
;
   
\ Print pulse-wave from upper to lower
\ ( -- )
: printPulse
\ Print pulse value
d16 font_size
c" Pulse " prt_str 
pulseValue W@
d100 u/mod 0= if h20 else h30 + then Transmit
d10 u/mod h30 + Transmit
h30 + Transmit
linefeed d1000 delms
\ Print pulse-wave
hFF DC2_# prtcmd                        \ Change density
d128 0 do
     clr_prnBuffer
     d127 i - makeDots
     d48 3 DC2_* prtcmd 
     3 0 do 
          prnBuffer d48 0 do dup C@ Transmit 1+ loop drop
     loop
loop
;

\ Detect sw status               
\ ( -- n1 ) n1:pushed-sw sensed if true
: swDetect
     \ Check if during debounce
     debounce W@                        
     if
          \ Check if exceeding 10msec
          cnt COG@ DebounceTime L@ - 10msec >
          if               
               rdSw dup swState W@ <> 
               if 
                    swState W!               \ Update swState if sw-status change
               else 
                    drop                     
               then  
               0 debounce W!                 \ Clear debounce
          then
     else
          rdSw swState W@ <>               
          if
               1 debounce W!                 \ Set debounce
               cnt COG@ DebounceTime L!      \ Set DebounceTime    
          then
     then
     swState W@                    
;

\ Start PulseMonitor(ADC,LCD,pulse,printer)
\ ( -- )
: PulseMonitor
initSW                                                                                                       
initSerial
init_prt
setup                                   \ Printer
1 stopPrinter W!
c" lcd" 5 cogx
c" GetPulse" 3 cogx
d100 delms

begin
     swDetect 0=
     if 
          0 stopPrinter W!               \ Stop updating lcd 
          printTime
          printPulse  
      \    d5000 delms
          1 stopPrinter W!               \ Restart updating lcd
          begin swDetect until
     then     
     fkey? swap drop
until 
3 cogreset   
5 cogreset  
stopSerial
;
