fl

{
PropForth 5.5(DevKernel)
PulseMonitor

2018/04/17 18:29:15

}                                                

\ ==================================================================
\ Main
\ ================================================================== 
{
\ PPG(photoplethysmogram)
\ SDPPG(second derivative of photoplethysmogram)
\ Save ADC-value(PPG) in buffer at every 10msec
\ buffer size is 160longs[1long/1ADC(12bit)]
\ PPG1:oldest ADC-value  PPG2:newest ADC-value

                     6000/pulse
 |               |-----------------------|
 |              * *                      **
 |            *     ***                *    *
 |           *          *           **        *
 |          *              *      *             *
 | * *  *  *                * * *                * * ****
 |      |-----------------------|
 |      n1                      n2
 |         range for calculating SDPPG
 ------------------------------------------------------------- 
bufTop                                                bufTop + 636
buffer[0]                                             buffer[159]  sample rate=10msec[160points] 
0msec                                                   1600msec   1long/sample
}
\ Search range for calculating SDPPG in buffer[sample time:10msec]
\ ( -- n1 n2 n3 )  n1:address n2:n1+(6000/pulse) n3:true if {n1...n2} is out of {buffer[0]...buffer[159]}
: detectRange
d6000 currentValue W@ / 4*                    \ Get region inside buffer  ( range )
\ Search maximum value in side buffer(1st scan)
0 bufTop d636 bounds do
     i L@ 2dup <
     if nip else drop then
loop                                         \ ( range max )
\ Search 1st position(2nd scan)
dup d10 / -                                  \ Get max-(max*0.1) ( range [0.9*max] )
bufTop                                            
begin 2dup L@ < if nip 1 else 4+ 0 then until     \ ( range address 1 ) or ( range [0.9*max] address 0 )  
d80 -                                        \ ( range n1 )
swap over +                                  \ ( n1 n2 )
\ Check if region is out of order
over bufTop <                        \ ( n1 n2 1/0 )
over bufTop d636 + > or              \ ( n1 n2 1/0 )   
;

\ Convert integer from n1 to n2 to float 
\ ( n1 n2 -- n1 n2 )
: convA/D 
over bufTop swap bufTop - 0 fill  \ Clear data  [here W@]..[n1-1]
2dup 4+ swap do i L@ i>f i L! 4 +loop             \ [n1]..[n2+3] 
dup 4+ dup bufTop 640 + swap - 0 fill             \ Clear data  [n2]..[here W@ +639]
;                                                     

\ Get difference [n1+4]-[n1] and  inside region[n1..n2-4]
\ ( n1 n2 -- n1 n2 )  n1:startSDPPG  n2:end SDPPG
: differential 2dup swap do i 4+ L@ i L@ f- i L! 4 +loop ;

\ ExponentialMovingAvrage     f(n)=0.95*[n] + 0.05*[n+4]
\ ( n1 n2 -- n1 n2 )  n1:startSDPPG  n2:end SDPPG
: EMA
2dup
4+ swap do   
     i 4- L@ h3F733333 f*                    \ 0.95*[n1-4] 
     i 4+ L@ h3D4CCCCC f*                    \ 0.05*[n1]
     f+                                      \ 0.95*[n1-4] + 0.05*[n1]
     i L!            
4 +loop
;

\ Subtract 4 from n2 and clear [n2]
\ ( n1 n2  -- n1 n2-4 )
: update_n2 dup 0 swap L! 4- ;

\ Get derivative and do ExponentialMovingAvrage
\ ( n1 n2 -- n1 n2-4 )
: Derivative differential update_n2 EMA update_n2 ;

\ Seach Max and min on second derivative graph
\ ( n1 n2 -- n1 n2 )  n1:start SDPPG  n2:end SDPPG
: searchMaxMin
2dup 0 rot2                                       \ ( n1 n2 0 n1 n2 )
4+ swap do i L@ over f> if drop i L@ then 4 +loop \ ( n1 n2 max )
>r                                                \ ( n1 n2 )
2dup 0 rot2                                       \ ( n1 n2 0 n1 n2 )
4+ swap do dup i L@ f> if drop i L@ then 4 +loop  \ ( n1 n2 min )
r> over f- diff L! MIN L!                         \ ( n1 n2 )
;

\ Convert float to integer[127-0]
\ ( n1 n2 -- ) n1:start SDPPG  n2:end SDPPG
: convF>I 
4+ swap do                                        \ ( -- )
     i L@ MIN L@ f- h457FF000 f*                  \ ([i L@]-[MIN])*4095
     diff L@ f/ f>i i L!                          \ ([i L@]-[MIN])*4095/(max-min)
4 +loop
;

\ Value to compare [n] and[n-4]
\ ( n1 -- n1 n2 n3 )  n1:address  n2:[address] n3:[address-4]
: loopBreakVal 4+ dup L@ over 4- L@ ;

\ Save value
\ ( n1 -- ) n1:address
: saveVal L@ TMP W! ;
 
\ Search trandition-point from up to down
\ ( n1 n2 -- n2 nn )  n1:SDPPG end-address n2:start-address for searching 
: searchTop
begin loopBreakVal < until                \ Break loop when [n]>[n+4]
dup 4- saveVal                                      \ ( n2 nn )
4 +                                               \ next address
\ Check 5points and replace value if [nn] >= [TMP]
5 0 do
     dup L@ TMP W@ >
     if dup saveVal then
     4+                                           \ next address
loop
;

\ Search trandition-point from down to up
\ ( n2 n1 -- n2 nn )  n2:SDPPG end-address n1:start-address for searching   
: searchBottom
begin loopBreakVal > until                \ Break loop when [n]<[n+4]
dup 4- saveVal                                      \ ( n2 nn )
4 +                                               \ next address
\ Check 5points and replace value if [nn] <= [TMP]
5 0 do
     dup L@ TMP W@ <
     if dup saveVal then
     4+                                           \ next address
loop
;

\ Compare address
\ ( n1 n2 -- n1 n2 n3 ) n1:end-address n2:address n3:1/0
: compAddr? 4+ 2dup = ;

\ Clear overAddr
\ ( -- )
: clr_overAddr 0 overAddr W! ;

\ Search last trandition-point from up to dwn 
\ This might not exist
\ ( n2 n1 -- n2 nn )
: lastSearchTop
begin
     compAddr?                                    \ ( n2 n1 1/0 )
     if
          clr_overAddr 1                         \ Exceeding SDPPG-endAddress
     else
          dup L@ over 4- L@ < 
     then
until                                             \ Break loop when [n]>[n+4] 
overAddr W@                                   
if
     dup 4- saveVal                               \ ( n2 nn )
     compAddr?
     if
          clr_overAddr                            \ Exceeding SDPPG-endAddress
     else
          \ Check 5points and replace value if [nn] >= [TMP]
          5 0 do
               dup L@ TMP W@ >
               if dup saveVal then
               compAddr?
               if 
                    clr_overAddr  
                    5 seti
               then
          loop
     then               
then    
;

\ Calculate zero-point from start to 5point
\ ( n1 n2 -- n1 n2 ) n1:start SDPPG n2:end SDPPG
: calc_zeroP over 0 swap 5 0 do dup L@ rot + swap 4+ loop drop 5 / zeroP W! ;

\ Calculate Age
\ ( n1 n2 -- n3 )   n1:start SDPPG n2:end SDPPG  n3:normal when less than 120 
: calcAge
calc_zeroP
swap d32 + searchTop TMP W@ zeroP W@ - a L!  
searchBottom TMP W@ zeroP W@ - b L!    
searchTop TMP W@ zeroP W@ - c L!    
searchBottom  TMP W@ zeroP W@ - d L!  cr 
1 overAddr W!  0 e L!
lastSearchTop overAddr W@ 0= if TMP W@ zeroP W@ - e L!  then 
2drop
b L@ c L@ - d L@ - e L@ - i>f a L@ i>f f/   \ SDPGAI=(b-c-d-e)/a
dup h422DE147 f* h4283B851 f+ f>i manAge W!  \ Calculate man age
h4226AE14 f* h42770000 f+ f>i womanAge W!    \ Calculate woman age
manAge W@ d120 <
;
