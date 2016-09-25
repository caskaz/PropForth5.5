fl

{
      
PropForth 5.5(DevKernel)
2016/09/24 20:10:01

P0  ----- 150ohm -- SinglePhaseSteppMotor Coil -- P1

         3.3V
          |
        10kohm
          |     A ----------------
P3 --------------| Rotary         |
         GND ----|  Encorder      | 
P4 --------------| without detent |
          |     B ----------------
        10kohm
          |
         3.3V
}


\ =========================================================================== 
\ Constants 
\ =========================================================================== 
\ Clock
\ output pin for SinglePhaseSteppMotor Coil(continuous pin)
0 wconstant out1
1 wconstant out2
clkfreq constant 1second
d1760000 constant cw_pulse         \ cw pulse width[22msec]
d484000 constant ccw_pulse1        \ 6.5msec 
d1120000 constant ccw_pulse2       \ 14msec
d800000 constant 10msec
d2800000 constant cwMIN            \ minimum cw cycle time(35msec)
d12000000 constant ccwMIN          \ minumum ccw cycle time(120msec)
clkfreq 2 * constant 2sec

\ Encorder
3 wconstant phaseA
3 phaseA lshift constant m_encorder
variable encoder_tbl -4 allot 
0 l, 1 l, -1 l, 0 l, 
-1 l, 0 l, 0 l, 1 l, 
1 l, 0 l, 0 l, -1 l, 
0 l, -1 l, 1 l, 0 l, 

\ =========================================================================== 
\ Variables 
\ =========================================================================== 
\ Clock
variable flag
variable dir
\ Encorder
variable pos
wvariable prev

\ =========================================================================== 
\ Main 
\ =========================================================================== 
\ ----- Clock -----
: test
cnt COG@
dup clkfreq + 0 waitcnt 
cnt COG@ 
nip swap - . 
;



\ Initial setting
\ ( -- )
: init
out1 pinout out2 pinout
-1 flag L!
;

\ Check flag
\ ( -- n1 )  n1:-1 or 0
: check flag L@ dup invert flag L! ;

\ Output cw-pulse
\ ( n1 -- ) n1:0 or 1
: cwPulse
out1 + dup pinhi 
cw_pulse cnt COG@ + 0 waitcnt drop 
pinlo 
;
                
\ Rotate to cw
\ ( -- ) 
: cw check if 0 else 1 then cwPulse ;

\ Output ccw-pulse
\ ( n1 -- ) n1:0 or 1
: ccwPulse
if 1 0 else 0 1 then                          
out1 + dup pinhi                             
ccw_pulse1 cnt COG@ + 0 waitcnt drop       
pinlo                                         
out1 + dup pinhi                          
ccw_pulse2 cnt COG@ + 0 waitcnt drop
pinlo                                     
;

\ Rotate to ccw
\ ( -- ) 
: ccw check if 0 else 1 then ccwPulse ;

\ ----- Encrder -----
\ Read encorder status
\ ( -- )
: rdStatus ina COG@ m_encorder and phaseA rshift ;

\ Count up/down encorder's position
\ ( -- )
: encorder
0 pos L!
rdStatus 4* prev W!
begin                                                          
     rdStatus        
     dup                                                         
     prev W@ + 4* encoder_tbl + L@                \ Get value 
     pos L@ + pos L!                              \ Update pos
     4* prev W!                                   \ Save prev 
0 until
;

\ ----------------------------------------------------------------------

\ Calculate ticks from encorder value[only cw]
\ ( -- n1 ) n1:ticks
: calcTicks1
clkfreq
pos L@ dup 0=
if drop 0 else 10msec * then 
- dup cwMIN < if drop cwMIN then
;

\ Moving only cw
\ ( -- )
: demo1
init
c" encorder" 5 cogx
5 delms                                           \ Delay because operating 'encorder' takes a little time.
cnt COG@     
begin
     cw
     calcTicks1 + 0 waitcnt
     fkey? swap drop          
until
drop
5 cogreset
; 


\ Calculate ticks from encorder value[both cw and ccw]
\ ( -- n1 ) n1:ticks
: calcTicks2
clkfreq
pos L@ dup 0=
if drop 0 else 10msec * then 
- dup 
2sec <
if
     \ cw direction
     dup cwMIN < if drop cwMIN then
     1 dir L!
else
     \ ccw direction
     2sec - ccwMIN +       
     0 dir L!
then
;

\ Moving cw and ccw
\ ( -- )
: demo2
init
1 dir L!
c" encorder" 5 cogx
5 delms                            \ Delay because operating 'encorder' takes a little time.
cnt COG@     
begin
     dir L@ if cw else ccw then    \ direction check
     calcTicks2 + 0 waitcnt         
     fkey? swap drop          
until
drop
5 cogreset
; 

