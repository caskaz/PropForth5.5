fl

{
PID Excersize (Position control by using encorder)

    PropForth 5.5(DevKernel)
    
            Motor Drive  Curcuit
           ---------------------      ----
    P2 -- |PWM           MPower+| -- |9VPS|
    P3 -- |CW            MPower-| -- |0V  |
    P4 -- |CCW                  |     ----
          |                  5V | -- |5VPS|
    P5 -- |Encoder-A        GND | -- |0V  |
    P6 -- |Encoder-B            |     ----
          |                     |     -----
          |                  M+ | -- |Motor|
          |                  M- | -- |     |
          |                     |     -------
          |            Encoder-A| -- |       |       
          |            Encoder-B| -- |Encoder|              
           ---------------------      -------           

2016/02/20 21:57:15
}

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
\ Special register
h1F8	wconstant ctra
h1FA	wconstant frqa 
h1FC	wconstant phsa 

\ Encorder
5 wconstant phaseA
3 phaseA lshift constant encoderm
variable encoder_tbl -4 allot 
0 l, 1 l, -1 l, 0 l, 
-1 l, 0 l, 0 l, 1 l, 
1 l, 0 l, 0 l, -1 l, 
0 l, -1 l, 1 l, 0 l, 

\ pwm
2 wconstant _pwm
3 wconstant dir_L
1 dir_L lshift constant cwm
2 dir_L lshift constant ccwm 
3 dir_L lshift invert constant dirm
d800000 constant pwmMax 
d100000 constant pwmMin    
d800000 constant 10msec

\ =========================================================================== 
\ Variables 
\ =========================================================================== 
\ Encorder
variable pos
variable prev
variable position 8 allot

\ pwm
wvariable Kp
wvariable Ki
wvariable Kd
wvariable setpoint
variable pwmValue

wvariable n

\ =========================================================================== 
\ Main 
\ =========================================================================== 
\ Count up/down encorder's position
\ ( -- )
: encorder
0 pos L!
0 prev L!
begin                                                      
     ina COG@ encoderm and phaseA rshift        \ Shift right to get current
     dup                                                         
     prev L@ or 4* encoder_tbl + L@               \ Get value 
     pos L@ + pos L!                              \ Update pos
     2 lshift prev L!                             \ Save prev to shift 2bit left 
0 until
;

\ Set pwm for driving Fan
\ ( -- )
: setPMW
_pwm pinout
1 frqa COG!
0 phsa COG!
\ Set PWM/NCO mode on servo pin       
_pwm h10000000 or ctra COG!
0 pwmValue L!
;

: tab 9 emit ;

\ Position control by PID
\ ( n1 n2 n3 n4 -- ) n1:Kd n2:Ki n3:Kp n4:setpoint
: PID2
\ Initial setup
setpoint W!
Kp W!
Ki W!
Kd W!
d10 n W!
                                                          
10msec cnt COG@ +                                 \ PMW frequency 100Hz
begin     
     setpoint W@ pos L@ - dup position L!         \ Difference between target and current position
     Kp W@ *                                      \ Kp item
                                                                 dup . tab
     position L@ position 4+ L@ - Ki W@ *         \ Ki item
                                                                 dup . tab
     position L@ position 4+ L@ - 
     position 4+ L@ position 8 + L@ - - Kd W@ *   \ Kd item
                                                                 dup . tab
     + +                                          \ ( PID-value )
     
     \ CW or CCW?
     outa COG@ dirm and                           \ ( PID_value outa )
     over 0>                                      \ ( PID_value outa 1/0 )
     \ Set direction
     if cwm else ccwm then or outa COG!           \ ( PID_value )
     dup 0< if -1 * then                          \ If PID_value is negative, set positive
     \ Calculate pwm
     d80 *                                        \ 1usec
     dup pwmMax >                                 \ Check if value exceed pwmMax
     if
          drop pwmMax
     else
          setpoint W@ pos L@ <>                   \ Check setpoint?
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
                                   pwmValue L@ .  tab pos L@ .  cr
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
dir_L pinout dir_L 1+ pinout
setPMW

c" encorder" 0 cogx
5 delms                                           \ Delay because operating 'encorder' takes a little time.
\ Clear position buffer
0 position L! 0 position 4+ L! 0 position 8 + L!

100 200 300 1000 PID2
300 300 300 600 PID2
50 200 700 2100 PID2

0 cogreset
outa COG@ dirm and outa COG!
0 ctra COG!
;

