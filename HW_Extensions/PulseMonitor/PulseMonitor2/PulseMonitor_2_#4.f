fl

{
PropForth 5.5(DevKernel)
PulseMonitor

Calcullation of pulse/Printer/Swutch
2018/04/17 20:21:40

}

\ ==================================================================
\ Main
\ ================================================================== 
\ Get pulse-number
\ ( -- )
: GetPulse
initPulse
2msec cnt COG@ +
begin                                              
     mcs a_ADC signal W!                          \ Get sensor-output[0-4095]

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
     stopPulse W@ if pulseValue W@ currentValue W! 0 stopPulse W! then     \ Save pulse when pulse-scan stop
     2msec waitcnt                    
0 until
;

\ Clear prnBuffer
\ ( -- )
: clr_prnBuffer 0 prnBuffer d24 0 do 2dup W! 2+ loop 2drop ;

\ Make dot-pattern (3dots) in prnBuffer array[48byte:384bit]
\ ( n1 -- )  n1:time axis on LCD[0-127]
: makeDots
d128 0 do
     dup
     i 4* bufTop + L@      \ Get ADC value[0-4095] 
     d32 /                         \ [0-127]
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

{
\ print pulse on TeraTerm
: test
buffer
128 0 do dup i + C@ spaces h2E emit cr loop drop
;
\ print value inside prnBuffer[48byte]
: print prnBuffer d48 0 do dup C@ .byte 1+ loop drop ;  
}

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

\ Print a,b,c,d,e
\ ( n1 -- )
: printCoef dup 0< if abs c" -" prt_str then printNum c"  " prt_str ;
 
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
drop
linefeed d1000 delms
;

{
\ Print number
\ ( n1 -- )  n1:number
: printNum
d100 u/mod 0= if h20 else h30 + then Transmit
d10 u/mod h30 + Transmit
h30 + Transmit
linefeed d1000 delms
;
}
\ Print pulse value
\ ( -- )
{
: printPulse
\ Print pulse value
d16 font_size
c" Pulse " prt_str 
currentValue W@ printNum                             
;
}
: printPulse
\ Print pulse value
d16 font_size
c" Pulse " prt_str 
currentValue W@ 
d100 u/mod 0= if h20 else h30 + then Transmit
d10 u/mod h30 + Transmit
h30 + Transmit
linefeed d1000 delms
;
   
\ Print pulse-wave 
\ ( -- )
: printWave
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
\ ( -- n1 ) n1:1[sw2 pushed], 2[sw1 pushed], 3[both are not pushed]
: swDetect
debounce W@
if
     cnt COG@ DebounceTime L@ - 10msec >
     if
          rdSW dup senseSW W@ =
          if
               dup 0= if drop else swState W! then
          else
               drop
          then
          0 debounce W!
     then
else
     rdSW dup swState W@ <>
     if
          senseSW W! 1 debounce W! cnt COG@ DebounceTime L!
     else
          drop
     then
then
swState W@
;
\ : test initSW begin swDetect dup 3 < if . else drop then fkey? swap drop until ;

\ Wait until both sw are off
\ ( -- )
: noSensedSW begin swDetect 3 = until ;

\ Check mode switch
\ ( -- n1 )  n1:true if mode-sw is pushed
: mode? swDetect 2 = ;

\ Check print switch
\ ( -- n1 )  n1:true if print-sw is pushed
: prtSW? swDetect 1 = ;  
