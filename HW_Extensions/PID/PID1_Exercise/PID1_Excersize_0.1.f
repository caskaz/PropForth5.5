fl

{
PID Excersize (Using 12VDC-FAN 2500rpm and 12-KeyPad and characterLCD)

    PropForth 5.5(DevKernel) 

2016/02/04 13:03:04
}
\ Re-defined Word"seral" because it has bugs.
: serial
	4*
	clkfreq swap u/ dup 2/ 2/
\
\ serial structure
\
\
\ init 1st 4 members to hFF
\
	hFF h1C2 
	2dup COG!
	1+ 2dup COG!
	1+ 2dup COG!
	1+ tuck COG!
\
\ next 2 members to h100
\
	1+ h100 swap 2dup COG!
	1+ tuck COG!
\
\ bittick/4, bitticks
\
	1+ tuck COG!
	1+ tuck COG!
\
\ rxmask txmask
\
	1+ swap >m over COG!
	1+ swap >m over COG!
\ rest of structure to 0
	1+ h1F0 swap
	do
		0 i COG!
	loop
\
	c" SERIAL" numpad ccopy numpad cds W!
	4 state andnC!
\	0 io hC4 + L!    <-- always 0 cogn sersetbreak
\	0 io hC8 + L!    <-- always 0 cogn sersetflags
	_serial
;

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
\ Top pin for KeyPad(7 continued pins)
\ from P8 to 14     [Raws from P8 to P10]  [Columns from P11 to P14]
8 wconstant KeyPad
d4000000 constant 50msec
d900 wconstant scale
d2500 wconstant max_setPoint
d4096 wconstant maxK

wvariable key_table -2 allot 
d10 c, 0 c, d12 c, 1 c, 2 c, 3 c, 4 c, 5 c, 6 c, 7 c, 8 c, 9 c, 

\ Special register
h1F8	wconstant ctra
h1FA	wconstant frqa 
h1FC	wconstant phsa 

0 wconstant _pwm
1 wconstant _sense
1 _sense lshift constant _sensem
d4000000 constant pwmMax
\ Time during 1-rotation of DC12V-FAN
variable T
d900 wconstant scale 

\ =========================================================================== 
\ Variables 
\ =========================================================================== 
variable lastDebounceTime
wvariable swState
wvariable lastswState
wvariable debounce
wvariable char     
variable buffer 
  
\ Buffer to store key-entered value
{
index
  0       setpoint
  2       Kp
  4       Ki
  6       Kd
}
variable PID_par 4 allot
wvariable itemNum

wvariable inchar h100 inchar W!
wvariable Kp
wvariable Ki
wvariable Kd
wvariable Auto 
variable error
variable output 
variable pwmValue
variable setPoint
variable input
variable lastInput
variable dInput
variable ITerm

\ =========================================================================== 
\ Main 
\ =========================================================================== 
\ - Communication between PropForth and Processing2.2.1 -
\ Pretreatment for communication
\ ( -- )
: pre
\ Initialize serial
\    if this bit is 0, CR is transmitted as CR LF
\    if this bit is 1, CR is transmitted as CR
1 5 sersetflags
\ pin 26 tx, pin 27 rx  d9600/4 = d2400
 c" 26 27 d2400 serial" 5 cogx
d10 delms
5 cogio 2+ W@                           \ Put output ptr of cog5 on stack
inchar 5 cogio 2+ W!                    \ Set output ptr of cog5 to inchar
io 2+ W@                                \ Put output ptr of current cog on stack
5 cogio io 2+ W!                        \ Set output ptr of current cog to input ptr of cog 5
;

\ Post-processing for communication
\ ( -- )
: post
\ Restore output ptr for current cog 
io 2+ W!
\ Restore output ptr for cog 5
5 cogio 2+ W!   
\ Read out until read-buffer is empty
begin 
     inchar W@ h100 =
     if
          1
     else
          h100 inchar W! 0
     then
until     
5 cogreset
;

\ -------- 12-KeyPad --------------------------------------------------------
\ Initialize KeyPad
\ ( -- )
: init_sw
\ Set initial values
0 swState W!             
0 lastDebounceTime L!
0 lastswState W!         \ Switch state when no pushing switch
0 debounce W!
;

\ Read current sw-state for 1column
\ ( -- n1 ) n1:3bit data
: rd_sw 
7 KeyPad lshift
ina COG@ and KeyPad rshift              
;

\ Read Row1/Row2/Row3 to drive each column
\ ( -- ) 
: swScan
init_sw
begin
     \ Read current sw and check if pushed or released
     rd_sw dup lastswState W@ <>                      
     if
          \ If sw is under debouncong
          debounce W@ 0=
          if
               cnt COG@ lastDebounceTime L!           
               1 debounce W!
          then
     else
          0 debounce W!
     then
     
     debounce W@
     if
          cnt COG@ lastDebounceTime L@ - 50msec >    
          if
               \ Update current swState and lastswState
               dup
               swState W! lastswState W!
               \ Break loop 
               1   
          else
               drop
               \ Continue loop
               0
          then
     else
          drop
          \ Break loop
          1
     then
until
;

\ Get 1 character
\ ( -- )
: get1char
\ Set mask for column port to output
hF KeyPad 3 + lshift dira COG!

begin
     \ Scan 3columns 
     KeyPad 3 +
     4 0 do
          dup i + pinhi            \ Activate column port
          \ Read Row-data 
          swScan           
          swState W@ dup            
          if                    
               1 rshift i 3 * + key_table + C@ char W!
               begin swScan swState W@ 0= until
          else
               drop                          
          then 
          dup i + pinlo           \ Deactivate column port
     loop 
     drop              
\     fkey? swap drop
0 until
;

\ -------- characterLCD --------------------------------------------------------

\ case statement
\ ( n1 n2 -- n1 n3 ) if n1 is equal to n2, n3 is 1
: case over = ;

\ Display item on charLCD
\ ( n1 -- ) n1:index(0,1,2,3,4,5,6)
: dispItem
lcd_clr
dup 5 <                            \ ( n1 1/0 )
if
     \ Display Setpoint/Kp/Ki/Kd
     0 case                        \ ( n1 1/0 )
     if
          c" Setpoint:" lcd_str
          PID_par W@ lcd_dec          
     else
          1 case                   \ ( n1 1/0 )
          if
               c" Kp:" lcd_str
               PID_par 2+ W@ lcd_dec
          else
               2 case              \ ( n1 1/0 )
               if
                    c" Ki:" lcd_str
                    PID_par 4+ W@ lcd_dec
               else
                    3 case
                    if
                         c" Kd:" lcd_str
                         PID_par 6 + W@ lcd_dec
                    else
                         c" Output[%]:" lcd_str
                         pwmValue L@ d100 * pwmMax / lcd_dec
                    then
               then
          then
     then
else
     5 case                        \ ( n1 1/0 )                      
     if
          \ Start
          c" Start" lcd_str
     else
          \ Switch Auto/Manual
          Auto W@
          if
               \ Auto
               c" Manual" lcd_str
          else
               \ Manual
               c" Auto" lcd_str
          then
     then
then
drop
1 2 lcd_pos                        \ Lower line
c" Acutual:" lcd_str
input L@ scale / lcd_dec
;

\ ------- Measurement for FAN's RPM ---------------------

\ Get state of _sense
\ ( -- n1 )  n1:t/f
: senseState 1 _sense lshift ina COG@ and ;

\ Measure rotation time by PhotoInterrupt sensor
\ T is 0 when signal don't change during 400msec(32000000ticks) because T remain old value when Fan stopped
\ ( -- )  
: 1rotT
_sensem _sensem waitpeq                 \ Wait until pulse goes to Hi
begin
     cnt COG@
     \ Wait until pulse goes to Lo with Timeout 
     begin dup cnt COG@ swap - 32000000 > if 0 T L! then senseState ina COG@ and 0= until
     \ Wait until pulse goes to Hi with Timeout
     begin dup cnt COG@ swap - 32000000 > if 0 T L! then senseState ina COG@ and until
     cnt COG@ swap - T L!
0 until
;

\ -------- Menu display --------------------------------------------------------
\ Clear charcter buffer
\ ( -- )
: charClr d255 char W! ;

\ Check if input-key is "Enter"key
\ ( -- n1 ) n1:1="Enter"key
: EnterKey? char W@ d12 = ; 

\ Check if input-key is "Cancel"key
\ ( -- n1 ) n1:1="Cancel"key
: CancelKey? char W@ d10 = ; 

\ Get digits from 12-KeyPad
\ ( -- n1 )  n1:input value
: getDigit
begin
     1 2 lcd_pos d16 lcd_bl             \ Clear characters on Lower line
     0 0                                \ ( flag sum )
     4 0 do
          d10 * 
          d13 i + 2 lcd_pos             \ Right side on charLCD
          \ Check num-key and Enter-key
          begin char W@ dup d10 < swap d12 = or until    
          EnterKey?
          if          
               swap drop 1 swap         \ Set falag for Enter-key
               4 seti                   \ Break do-loop
               d10 /
          else
               char W@
               dup h30 + lcd_char       \ Display input-key on charLCD
               +                        \ ( 1/0 n1 )                            
          then
          charClr                          
     loop
     swap                               \ ( n1 1/0 )
     if 
          1                             \ break begin-loop
     else 
          begin char W@ d255 <> until   \ Wait until key is pushed
          EnterKey?
          if
               1                        \ break begin-loop
          else
               drop 0                   \ Again begin-loop because other key
          then 
     then
     charClr           
until     
;

\ Select item
\ ( -- )
: selectItem
itemNum W@ 6 =
if 
     0 itemNum W!             \ Back to top item
else
     1 itemNum W+!            \ Increment itemNum
then
;

\ Compare value and maximum and Store values to PID_par if no problem
\ ( -- )
: set_PID_par
getDigit                      \ Get value
\ Compare value and maxmum
itemNum W@ 0=
if
     \ Check setpoint
     dup max_setPoint <
     if 1 else 0 then
else
     \ Check Kp/Ki/Kd
     dup maxK <
     if 1 else 0 then
then
\ Store value to PID_par
if
     PID_par itemNum W@ 2* + W!    \ Store new value to PID_parameters 
else
     drop
then                  
;

\ Set value[0%-100%] to pwm
\ ( -- )
: setOutput
getDigit                      \ Get value
\ Check if input-value is valid
dup 0 d100 between            \ If 100 >= value >= 0, ok
if
     pwmMax d100 / *
     pwmValue L!              \ Drive pwm
then     
;

\ Check PID_parameters and update setPoint/Kp/Ki/Kd
\ ( -- )
: startMode
\ Update PID-parameters
\ setpoint.Kp,Ki,Kd
\ Save to setPoint/Kp/Ki/Kd
PID_par W@ scale * setPoint L!
PID_par 2+ W@ Kp W! 
PID_par 4+ W@ Ki W! 
PID_par 6 + W@ Kd W!              
;

\ Display Setpoint/Kp/Ki/Kd/input and set new value
\ 0:Setpoint 1:Kp 2:Ki 3:Kd 4:Output 5:Start 6:Manual/Auto
\ ( -- )
: changeItem
charClr                                 \ Clear char buffer
\ c" get1char" 1 cogx
lcd_init

0 dispItem                              \ Initial 
begin
     CancelKey?
     if
          selectItem
          itemNum W@ dispItem           \ Display item on charLCD
          charClr 
     else
          \ Update item contents
          EnterKey?
          if   
               charClr
               itemNum W@ 4 <                \ setPoint/Kp/Ki/Kd?
               if
                    set_PID_par
                    itemNum W@ dispItem      \ Display new value
               else
                    itemNum W@ 4 =           \ Output?
                    if
                         Auto W@ 0=          \ Manual?
                         if
                              \ Manual
                              setOutput
                              itemNum W@ dispItem \ Display new value
                         then
                    else
                         itemNum W@ 5 =      \ Start?
                         if
                              startMode
                         else
                              \ Auto/Manual switch mode
                              Auto W@ if 0 else 1 then
                              Auto W!
                              itemNum W@ dispItem      \ Display new value
                         then
                    then
               then
          then
     then
     \ Update input
     9 2 lcd_pos 4 lcd_bl 9 2 lcd_pos input L@ scale / lcd_dec 
     d100 delms                                   
0 until
;

\ Set initial values
\ ( -- )
: setInitialValue
\ Set initial PID values
d10 Kd W!
d50 Ki W!
d300 Kp W!
d1400 scale * setPoint L!
0 input L!
0 ITerm L!    
0 lastInput L!
1 Auto W!
0 itemNum W!
\ Copy PID values to PID_par
setPoint L@ scale / PID_par W!
Kp W@ PID_par 2+ W!
Ki W@ PID_par 4+ W!
Kd W@ PID_par 6 + W!
\ Set initial rotation
0 T L!
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

\ Start Cog*
\ ( -- )
: startCog
\ Start Fan sense for Cog0                   
c" 1rotT" 0 cogx                             
d10 delms
\ Start 12-keyPad for Cog1
c" get1char" 1 cogx                          
d10 delms
\ Start KeyPad and charLCD for Cog2
c" changeItem" 2 cogx                         
d10 delms
;

\ Send data to Processing
\ ( -- )
: sendData
setPoint L@ scale / dup emit 8 rshift emit
Kp W@ dup emit 8 rshift emit
Ki W@ dup emit 8 rshift emit
Kd W@ dup emit 8 rshift emit          
input L@ scale / dup emit 8 rshift emit
pwmValue L@ dup emit
8 rshift dup emit
8 rshift dup emit
8 rshift emit
Auto W@ emit
;

\  Communication PropForth and Processing
\ ( -- t/f )  t:Finish PID1_Excercise
: ProcessingData
inchar W@ d66 =          \ Finish?
if 
     1        
else                                        
     sendData            \ Send 15byte
     h100 inchar W!
     0
then
;

\
\ ( -- )
: PID1_Exercise
setInitialValue
setPMW
startCog      

\ Prepare connection between PropForth and Precessing
pre
h100 inchar W!            
\ Wait until receiving 'd65' (mouse click)
begin inchar W@ d65 = until
h100 inchar W!
                                                                         
cnt COG@ 50msec +                                 \ cnt + 50msec  
begin
     \ Read 1rotation time of Fan
     T L@ dup                                \ Get ticks for 1rotation
     if 
          \ Get rpm
          d30 clkfreq u* swap u/ 2 u*        \ (30sec_ticks/1rotation_ticks) * 2 
     then                                     

     Auto W@
     if
          \ Auto(PID_ON)
          scale * input L!                        \ Get scales current rotation     
          \ PID calculation
          setPoint L@ input L@ - dup error L!     \ error
          Ki W@ * ITerm L@ + ITerm L!
    
          input L@ lastInput L@ - dInput L!
          Kp W@ error L@ * 
          ITerm L@ 
          Kd W@ dInput L@ * + +
          \ Check if calculated value is positive
          dup 0>
          if
               \ Positive
               scale W@ u/                        \ Get output                                                            
               \ Convert output to pwm
               d80 *                              \ 1usec
               dup pwmMax >                       \ Check if value exceed pwmMax
               if
                    drop pwmMax
               then
          else
               \ Negative
               drop 0
          then                       
          dup
          \ Set negative value to phsa      
          negate phsa COG!
          pwmValue L!     
          input L@ lastInput L!                   \ Update lastInput   
       
          \ Check character from processing (hitting any key)
          ProcessingData                          \ ( cnt 1/0 )
     else
          \ Manual(PID_OFF)
          scale * input L!                        \ Get scales current rotation
          \ Set negative value to phsa      
          pwmValue L@ negate phsa COG!
          ProcessingData
     then
     swap                                     
     50msec waitcnt                               \ cnt + 50msec
     0 phsa COG! 
     swap 
until 
drop       
\ Back to original cog
post
0 cogreset
0 ctra COG!
1 cogreset
2 cogreset
;
