fl

{
PropForth 5.5(DevKernel)
2016/09/23 16:41:40

         3.3V
          |
        10kohm
          |     A -----------
P3 --------------| Rotary    |
         GND ----|  Encorder |
P4 --------------|           |
          |     B -----------
        10kohm
          |
         3.3V
         
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
variable pos
wvariable prev

\ =========================================================================== 
\ Main 
\ =========================================================================== 
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

\ Display position (RotaryEncorder without detent)
: test1 
c" encorder" 5 cogx
5 delms                                           \ Delay because operating 'encorder' takes a little time.
begin pos L@ . d10 delms fkey? swap drop until
5 cogreset 
;

\ Display position (RotaryEncorder with detent)
: test2 
c" encorder" 5 cogx
5 delms                                           \ Delay because operating 'encorder' takes a little time.
begin pos L@ 4/ . d10 delms fkey? swap drop until
5 cogreset 
;
