fl

{
PropForth 5.5(DevKernel)

Encoder
2015/10/07 15:11:12

         3V3
          |
        10kohm
          |     A -----------
P0 --------------| Rotary    |
         GND ----|  Encorder |
P1 --------------|           |
          |     B -----------
        10kohm
          |
         3V3
         
     prev  current status
       0     0      stop           0
       0     1      CW             1
       0     2      CCW           -1
       0     3      invalid(=stop) 0
       4     0      CCW           -1
       4     1      stop           0
       4     2      invalid(=stop) 0
       4     3      CW             1
       8     0      CW             1
       8     1      invalid(=stop) 0
       8     2      stop           0
       8     3      CCW           -1
       C     0      invalid(=stop) 0
       C     1      CCW           -1
       C     2      CW             1
       C     3      stop           0
         
}

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
0 wconstant phaseA
3 phaseA lshift constant m_encorder
variable encoder_tbl -4 allot 
0 l, 1 l, -1 l, 0 l, 
-1 l, 0 l, 0 l, 1 l, 
1 l, 0 l, 0 l, -1 l, 
0 l, -1 l, 1 l, 0 l, 

\ =========================================================================== 
\ Variables 
\ =========================================================================== 
variable pos
wvariable prev

\ =========================================================================== 
\ Main 
\ =========================================================================== 
\ Count up/down encorder's position
\ ( -- )
: encorder
0 pos L!
0 prev W!
begin                                                          
     ina COG@ m_encorder and phaseA rshift        \ Shift right to get current
     dup                                                         
     prev W@ or 4* encoder_tbl + L@               \ Get value 
     pos L@ + pos L!                              \ Update pos
     2 lshift prev W!                             \ Save prev to shift 2bit left 
0 until
;

\ Incase of using 96count(24click)/1rotary
\ pos L@ when using Ncounts(no click)/1rotary
\ ( -- n1 ) n1:
: pos/4 pos L@ 4/ ;

\ Display position with RotaryEncoder without click 
\ ( -- )
: test1 
c" encorder" 5 cogx
5 delms                                           \ Delay because operating 'encorder' takes a little time.
begin pos L@ . d10 delms fkey? swap drop until
5 cogreset 
;

\ Display position with RotaryEncoder with 96count(24click)/1rotary  
\ ( -- )
: test2 
c" encorder" 5 cogx
5 delms                                           \ Delay because operating 'encorder' takes a little time.
begin pos/4 . d10 delms fkey? swap drop until
5 cogreset 
;
