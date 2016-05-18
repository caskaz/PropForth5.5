fl

{
BRACCIO
PropForth5.5

2016/05/18 21:10:53

QuickStart             BRACCIO shield board
            ---------
     3V3---|VCCA VCCB|----5V          
     P8----|A0     B0|----M1
     P9----|A1     B1|----M2
     P10---|A2     B2|----M3
     P11---|A3     B3|----M4
     P12---|A4     B4|----M5
     P13---|A5     B5|----M6
     GND---|GND    OE|----GND
            ---------
             FXMA108
}

\ -------------------------------------------------------
\ Constants
\ -------------------------------------------------------
\ Special register
h1F8	wconstant ctra
h1FA	wconstant frqa 
h1FC	wconstant phsa 
\ Time for servo
d80 wconstant 1usec
\ Max-limit and Min-limit for each servo
wvariable servo_limit -2 allot
d500 w, d2500 w,         \ base
d900 w, d2300 w,         \ shoulder
d600 w, d2500 w,         \ elbow
d500 w, d2500 w,         \ vertical wrist
d500 w, d2500 w,         \ rotary wrist
d1350 w, d2200 w,        \ gripper

\ top pin number of contiguous servo group
8 wconstant servo
\ each servo ch
0 wconstant base
1 wconstant shoulder
2 wconstant elbow
3 wconstant vert_wrist
4 wconstant rot_wrist
5 wconstant gripper

\ channel[max:8]
6 wconstant ch


\ -------------------------------------------------------
\ Variables
\ -------------------------------------------------------
\ target[ch],delta[ch],usec[ch]: each channel has 2byte(total 12byte)
variable target 8 allot 
variable delta 8 allot
variable usec 8 allot

\ -------------------------------------------------------
\ Main
\ -------------------------------------------------------

\ Get address of target for each ch
\ ( n1 -- n2 )  n1:servo ch n2:target_position's variable address for each ch
: tgtPos 2 u* target + ;

\ Get address of delta for each ch
\ ( n1 -- n2 )  n1:servo ch n2:delta's variable address for each ch
: deltaVal 2 u* delta + ;

\ Get address of usec for each ch
\ ( n1 -- n2 )  n1:servo ch n2:current_position's variable address for each ch
: curPos 2 u* usec + ;

\ Set servo-motor's pin to output
\ ( n1 -- )   n1:top pin number of contiguous servo group
: setup ch 0 do dup pinout 1+ loop drop ;

\ Check if position is inside region
\ ( n1 n2 -- n3 )  
\ n1:servo ch  
\ n2:servo position(microsecond)
\ n3:Checked servo position(microsecond)
: posCheck 
over 4 * servo_limit + W@ max \ Check Min-limit 
over                          \ ( n1 [n2 or min-limit] n1 )
4 * 2+ servo_limit + W@ min   \ Check Max-limit
;

\ Set selected servo(ch) to new position 
\ ( n1 n2 -- )  
\ n1:servo ch 
\ n2:newpos specified in microseconds
: setpos
posCheck                      \ ( n1 n2 )
over                          \ ( n1 n2 n1 ) 
\ delta[ch] = 0
deltaVal 0 swap W!            \ ( n1 n2 )  Save delta=0 to specified ch                    
swap 2dup                     \ ( n2 n1 n2 n1 )
tgtPos W!                     \ ( n2 n1 )  Save target_position to sprcified ch
\ usec[ch] = newpos
curPos W!                     \ ( -- )  Save new_position to specified ch
;

\ Move selected servo from current position to newpos in n1 frames
\ ( n1 n2 n3 -- )  
\ n1:frame [1frame is 15msec(servo frame timing)]
\ n2:servo ch
\ n3:newpos
: movpos
posCheck                      \ ( n1 n2 n3 )
rot                           \ ( n2 n3 n1 )
dup 1 =
if
     \ Moving rapidly
     drop                     \ ( n2 n3 )
     setpos
else
     \ Moving slowly through frames
     over                     \ ( n2 n3 n1 n3 )
     >r                       \ ( n2 n3 n1 ) Push newpos
     >r                       \ ( n2 n3 )   Push frame
     over                     \ ( n2 n3 n2 )
     curPos W@ -              \ Calculate (difference from newpos and usec)
     abs d10 u*               \ ( n2 n3 calc_value )
     r>                       \ Pop frame
     u/                       \ ( n2 n3 calc_value )  Calculate 0.1usec/frame
     5 + d10 u/ 1 max         \ ( n2 compared_result )  round up to 1usec/frame
     over                     \ ( n2 compared_resulte n2 )
     deltaVal W!              \ ( n2 )  Update delta to specified ch
     r>                       \ ( n2 n3 ) Pop newpos
     swap                     \ ( n3 n2 )
     tgtPos W!                \ ( -- ) Update new_position to specified ch
then
;

\ Returns position (current output command to servo) of channel
\ ( n1 -- n2 )  
\ n1:servo ch  n2:ch's position(microseconds)
: position curPos W@ ;

\ Returns True when servo ch is at desired target
\ ( n1 -- n2 )  
\ n1:servo ch  n2:t/f
: at_target dup curPos W@ swap tgtPos W@ = ;

\ Wait until servo channel reaches at target position
\ ( n1 -- )  n1:ch
: wait_tgt begin dup at_target until drop ;

\ Runs 6 servos
\ ( n1 -- )  n1:top pin number of contiguous servo group
: deltaServo
dup 
setup
1 frqa COG!
0 phsa COG!
cnt COG@ d200000 +                 \ cnt + 2.5msec  
swap
\ run 6 slot(15msec)
begin
     ch 0 do   
          \ Set PWM/NCO mode on servo pin       
          dup i + h10000000 or ctra COG!
          \ Set negative value to phsa      
          i curPos W@ 1usec u* negate phsa COG!
               
          i curPos W@ i tgtPos W@ <
          if
               i curPos W@ i deltaVal W@ +
               i tgtPos W@ min
               i curPos W!
          else
               i curPos W@ i tgtPos W@ >
               if
                    i curPos W@ i deltaVal W@ -
                    i tgtPos W@ max
                    i curPos W!
               then
          then
          swap                                                    
          d200000 waitcnt                    \ cnt + 2.5msec
          swap
          0 ctra COG! 
     loop
0 until
\ fkey? swap drop until drop
;

\ Start servo cog
\ ( -- )   
: servo_init
base d1500 setpos                       
shoulder d1800 setpos              
elbow d1000 setpos
vert_wrist d2500 setpos
rot_wrist d1500 setpos
gripper d1500 setpos

c" servo deltaServo" 0 cogx
;

: disp_pos
ch 0 do 
     ." ch:" i .
     ." target:" i tgtPos W@ .
     ." delta:" i deltaVal W@ .
     ." usec:" i curPos W@ .
     cr
loop
cr
;

: demo1
d100 base d1500 movpos
d100 shoulder d1600 movpos
d100 elbow d1600 movpos
d100 vert_wrist d1500 movpos
d100 rot_wrist d1500 movpos
d100 gripper d1500 movpos
;

: demo2
d100 base d1500 movpos
d100 shoulder d1800 movpos
d100 elbow d1000 movpos
d100 vert_wrist d2500 movpos
d100 rot_wrist d1500 movpos
d100 gripper d1500 movpos
;
: demo3
d100 base d2000 movpos
d50 rot_wrist 500 movpos
d50 gripper d1350 movpos
begin rot_wrist at_target until    \ Wait until reached at desired position    
d50 rot_wrist 2500 movpos
begin gripper at_target until      \ Wait until reached at desired position
d50 gripper d2200 movpos
;


: wait
begin base at_target until
begin shoulder at_target until
begin elbow at_target until
begin vert_wrist at_target until
begin rot_wrist at_target until
begin gripper at_target until
;

\ https://youtu.be/JL5h1zzt0RA
: test
servo_init 
demo1 wait demo2 wait demo3 wait demo2 
;
