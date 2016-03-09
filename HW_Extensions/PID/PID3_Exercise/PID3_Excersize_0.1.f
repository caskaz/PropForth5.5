fl

{
PropForth 5.5(DevKernel)




         3V3
          |
        10kohm
          |       -------------------
P0 --------------|5 PhaseA  Servo    |
P1 --------------|6 Phaseb  Encoder  |
          |       -------------------
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


          L298N
P2 -------IN1
P3 -------IN2          ----------------
                      |1 5V            |
          L298N       |2 GND     Servo |
          OUT1------- |3 Motor+        |
          OUT2------- |4 Motor-        |
                       ----------------


2016/03/09 16:28:17
         
}

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
\ Special register
h1F8	wconstant ctra
h1FA	wconstant frqa 
h1FC	wconstant phsa 

\ Encorder
0 wconstant phaseA
1 phaseA lshift constant m_phaseA 
3 phaseA lshift constant m_encorder
variable encoder_tbl -4 allot 
0 l, 1 l, -1 l, 0 l, 
-1 l, 0 l, 0 l, 1 l, 
1 l, 0 l, 0 l, -1 l, 
0 l, -1 l, 1 l, 0 l, 

\ pwm
2 wconstant cw
3 wconstant ccw
1 cw lshift constant cwm
1 ccw lshift constant ccwm 

\ =========================================================================== 
\ Variables 
\ =========================================================================== 
\ Encorder
variable pos
wvariable prev
variable T
variable position 8 allot

\ pwm
wvariable Kp
wvariable Ki
wvariable Kd
variable p_setpoint
variable pwmValue
wvariable n
d800000 constant pwmMax 
d50000 constant pwmMin    
d800000 constant 10msec

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

\ Time for encoder to count-up(-down) 
\ ( -- )
: Time
begin
     m_phaseA m_phaseA waitpeq    \ Wait until phaseA goes to Hi
     cnt COG@  
     m_phaseA m_phaseA waitpne    \ Wait until phaseA goes to Low
     m_phaseA m_phaseA waitpeq
     cnt COG@ swap - T L!
     m_phaseA m_phaseA waitpne    \ Wait until phaseA goes to Low
0 until
;


\ Set pwm for driving Fan
\ ( n1 -- )  n1:cw/ccw
: setPMW
1 frqa COG!
0 phsa COG!
\ Set PWM/NCO mode on servo pin       
h10000000 or ctra COG!
;

: tab 9 emit ;

\ Position control by PID
\ ( n1 n2 n3 n4 -- ) n1:Kd n2:Ki n3:Kp n4:p_setpoint
: PID3
\ Initial setup
p_setpoint W!
Kp W!
Ki W!
Kd W!
d10 n W!
                                                          
10msec cnt COG@ +                                 \ PMW frequency 100Hz
begin     
     p_setpoint W@ pos L@ - dup position L!       \ Difference between target and current position
     Kp W@ *                                      \ Kp item
                                                              \   dup . tab
     position L@ position 4+ L@ - Ki W@ *         \ Ki item
                                                              \   dup . tab
     position L@ position 4+ L@ - 
     position 4+ L@ position 8 + L@ - - Kd W@ *   \ Kd item
                                                              \   dup . tab
     + +                                          \ ( PID-value )
                   dup .
     \ CW or CCW?
     dup 0> dup                                   \ ( PID_value 1/0 1/0 )
     \ Set direction     
     if cw ccw pinlo else ccw cw pinlo then h10000000 or ctra COG!    \ ( PID_value )
     if ccw pinlo else cw pinlo then
     dup 0< if -1 * then                          \ If PID_value is negative, set positive
     \ Calculate pwm
     d80 *                                        \ 1usec
     dup pwmMax >                                 \ Check if value exceed pwmMax
     if
          drop pwmMax
     else
          p_setpoint W@ pos L@ <>                 \ Check setpoint?
          if
               d10 n W!
               dup pwmMin <                       \ Check if value is less than pwmMin 
               if
                    drop pwmMin
               then
          else
               n W@ 1- n W!
               drop 0                             \ If position reach ro setpoint, set pwm to 0
          then
     then
     dup
    
     \ Set negative value to phsa      
     negate phsa COG!
     pwmValue L!     
                                   pwmValue L@ .  tab pos L@ . tab d8000000 T L@ / . cr
     \ update differene
     position 4+ L@ position 8 + L!
     position L@ position 4+ L! 

     10msec waitcnt
     n W@ 0= if 1 else 0 then
until
drop
;


: demo
\ Set direction-port to output
cw pinout ccw pinout
0 pwmValue L!
cw setPMW
c" encorder" 0 cogx
5 delms                                           \ Delay because operating 'encorder' takes a little time.
c" Time" 1 cogx
5 delms
\ Clear position buffer
0 position L! 0 position 4+ L! 0 position 8 + L!

10 200 300 3000 PID3
2000 delms
10 300 300 600 PID3
2000 delms
10 200 300 10000 PID3
2000 delms

0 cogreset
1 cogreset
0 ctra COG!
;

