fl

{
PropForth 5.5(DevKernel)

Encoder with eliminating chattering
2017/10/13 17:38:52

         3V3
          |
        10kohm
          |     A -----------
P12 -------------| Rotary    |
         GND ----|  Encorder |
P13 -------------|           |
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
d12 wconstant phaseA
3 phaseA lshift constant m_encorder
variable encoder_tbl -4 allot 
0 l, 1 l, -1 l, 0 l, 
-1 l, 0 l, 0 l, 1 l, 
1 l, 0 l, 0 l, -1 l, 
0 l, -1 l, 1 l, 0 l, 
d400000 constant 5msec        \ This need to change accordong to used rotary-encoder

\ =========================================================================== 
\ Variables 
\ =========================================================================== 
variable pos
wvariable prev
variable encDebounceTime
wvariable encDebounce
wvariable curState

\ =========================================================================== 
\ Main 
\ =========================================================================== 

\ Get current encoder status(b1:b0)
\ ( -- n1 ) n1:encoder status
: status ina COG@ phaseA rshift 3 and ;

\ Check encoder-change
\ ( -- n1 n2 ) n1:encoder value(0,1,2,3) n2:1[changed] 0[no changed]
: chkEnc status dup prev W@ phaseA rshift <> ;

\ Get encorder's position
\ ( -- )
: count
\ 0 encDebounceTime W!                         \ Clear debounce
0 pos L!                                     \ Clear position
0 curState W!                                \ Clear current state  
status 2 lshift prev W!                      \ initial prev
begin
     encDebounce W@                          \ Check if during debounce
     if                                
          \ Check if exceeding 5msec
          cnt COG@ encDebounceTime L@ - 10msec >
          if
               chkEnc
               if
                    curState W!              \ Save current state
               else
                    drop
               then
               0 encDebounce W!              \ Clear debounce
          then
     else                         
          chkEnc
          if
               1 encDebounce W!              \ Set debounce
               cnt COG@ encDebounceTime L!   \ Set DebounceTime
          then
          drop
     then
     \ Update encoder position                                       
     prev W@ curState W@ or 4* encoder_tbl + L@ 
     pos L@ + pos L!
     curState W@ 2 lshift prev W!            \ Update prev
\  pos L@ . space                       
\     fkey? swap drop
\ until
0 until
;
: test
c" count" 0 cogx            \ Run count on anothrt cog
100 delms
begin pos L@ . space  fkey? swap drop until
0 cogreset
;
