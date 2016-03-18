fl

{
PropForth 5.5(DevKernel)

Settg date and time to RTC
2015/10/07 22:13:00

Prepare;
Loading i2c_utility_0.4.f
Loading DS1337_1.6.f
Loading i2c_charLCD(ST7032)_0.1.f

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

                3V3
                 |
                10kohm
                 |
      P2  -------|
                 |
                sw
                 |
                GND
                
              |\|
      P3  ----| | ----220ohm---GND  
              |/| 
              LED           
           
}

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
0 wconstant phaseA
2 wconstant swpin
3 wconstant ledpin
3 phaseA lshift constant m_encoder
d4000000 constant 50msec
swpin >m constant swMask
ledpin >m constant ledMask
variable encoder_tbl -4 allot 
0 l, 1 l, -1 l, 0 l, 
-1 l, 0 l, 0 l, 1 l, 
1 l, 0 l, 0 l, -1 l, 
0 l, -1 l, 1 l, 0 l, 

wvariable leap_day -2 allot 
31 w, 29 w, 31 w, 30 w, 31 w, 30 w, 31 w, 31 w, 31 w, 31 w, 30 w, 31 w, 
wvariable common_day -2 allot 
31 w, 28 w, 31 w, 30 w, 31 w, 30 w, 31 w, 31 w, 31 w, 31 w, 30 w, 31 w, 

\ =========================================================================== 
\ Variables 
\ =========================================================================== 
\ --- sw ---
variable lastDebounceTime
variable lastswState
variable push
wvariable swState
wvariable debounce
\ --- encoder ---
variable pos
wvariable prev

wvariable year
wvariable month
wvariable day
wvariable weekday
wvariable hour
wvariable minute
wvariable sec

\ =========================================================================== 
\ swich 
\ =========================================================================== 
\ read current sw-state
\ ( -- n1 ) n1:1[sw:off] 0[sw:on]
: rd_sw ina COG@ swMask and if 1 else 0 then ;

\ Read current sw and check if pushed or released
\ ( -- )
: sw_input
\ Check if curren switch and lastswState is different
rd_sw dup lastswState W@ <>                                                  
if     
     debounce W@ 0=                                    \ Check if sw is under debouncing
     if          
          cnt COG@ lastDebounceTime L!                 \ Start debounce-time
          1 debounce W!
          0 push L!                                    \ Clear push
     then
else     
     0 debounce W!                                     \ Clear debounce state
then

\ Check debounce-time if sw is under debouncing     
debounce W@
if
     cnt COG@ lastDebounceTime L@ - 50msec >           \ Debounce-time exceed 50msec?    
     if
          \ Update current swState and lastswState
          dup
          swState W! lastswState W! 
          cnt COG@ push L!                             \ Save cnt because of check time to continue pushing sw
     else
          drop                                         \ Debounce-time is less than 50msec                                    
     then
else
     drop                                              \ Not under debouncing
then
;

\ Initial sw
\ ( -- )
: init_sw
1 swState W!                                                 
0 lastDebounceTime L!
1 lastswState W!
0 debounce W!    
;

\ Wait until switch is released 
\ ( -- )
: waitRelease begin rd_sw until init_sw ;

\ Check if sw is pushed
\ ( -- t/f )  t:sw pushed f:sw released
: finish? sw_input swState W@ 0 = ;

\ =========================================================================== 
\ Encoder 
\ =========================================================================== 
: encoder
0 pos L!
0 prev W!
begin                                                          
     ina COG@ m_encoder and phaseA rshift         \ Shift right to get current
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

\ =========================================================================== 
\ Main
\ =========================================================================== 
\ Alignment/Print time-digit to 2digits
\ ( n1 -- ) n1:time-digit (0-24,0-59)
: 2digitLCD
dup d10 <
if
     h30 lcd_char h30 + lcd_char   \ n1<10
else
     d10 u/mod h30 + lcd_char h30 + lcd_char \ n1>9
then
;

\ Check leap
\ ( n1 -- n2 )  n1:year  n2:1[leap] 0[normal]
: leap? 4 u/mod drop 0= if 1 else 0 then ;

\ Get end of day
\ ( -- n1 ) n1:end day of Month
: getDayEnd
year W@ leap?
if
     leap_day month W@ 1- 2* + W@
else
     common_day month W@ 1- 2* + W@
then
;

\ Convert week-number to string
\ rtc_week ( n1 -- )  n1:1 to 7
: rtc_week_LCD
7 and 
c" MONTUEWEDTHUFRISATSUN" 1+ swap 1 max 1- 3 u* +
3 0 do dup C@ lcd_char 1+ loop drop 
;

\ Prepare each item selection
\ ( n1 -- n2 )  n1:initial pos for encoder n2:loop counter
: prepare
pos L!                        \ Set n1(x4 because encorder[96counts] with 24click)
init_sw
0                             \ loop counter
;

\ Check loop counter
\ ( n1 -- n2 ) n1:loop counter  n2:n1+1, 0 if n1>50
: chkCounter 1+ dup d50 > if drop 0 then ;

\ Set year [2015 to 2099]
\ ( -- )
: setYear
d60 prepare                   \ 15x4
begin
     pos/4 dup d15 < 
     if 
          drop d99 d396 pos L! 
     else 
          dup d99 > 
          if 
               drop d15 d60 pos L! 
     thens
     dup year W! 
     1 1 lcd_pos
     \ Display value with flashing on charLCD
     over d24 > if d2000 + lcd_dec else drop c"     " lcd_str then
     d10 delms
     chkCounter                                        \ Reset counter if counter > 50 
     \ Year-selection finished?     
     finish?                                           \ Break begin-until if sw is pushed  
     if 
          d25 < 
          if 1 1 lcd_pos year W@ d2000 + lcd_dec then  \ Display year 
          1 
     else 
          0 
     then              
until                                
waitRelease                 
;

\ Set month [1 to 12]
\ ( -- )
: setMonth
4 prepare                     \ 1x4
begin
     pos/4 dup 1 < 
     if 
          drop d12 d48 pos L! 
     else 
          dup d12 > 
          if 
               drop 1 4 pos L! 
     thens
     dup month W!
     6 1 lcd_pos    
     \ Display value with flashing on charLCD
     over d24 > if 2digitLCD else drop c"   " lcd_str then 
     d10 delms
     chkCounter                                   \ Reset counter if counter > 50 
     \ Month-selection finished?     
     finish?                                      \ Break begin-until if sw is pushed
     if 
          d25 < 
          if 6 1 lcd_pos month W@ 2digitLCD then  \ Display month 
          1 
     else 
          0 
     then                                         
until        
waitRelease            
;

\ Set day [1 to 31]
\ ( -- )
: setDay
4 prepare                     \ 1x4
begin
     pos/4 dup 1 < 
     if 
          drop
          \ Check day-end
          getDayEnd dup 4* pos L! 
     else 
          dup 
          \ Check day-end
          getDayEnd >
          if 
               drop 1 4 pos L! 
     thens
     dup day W! 
     9 1 lcd_pos    
     \ Display value with flashing on charLCD
     over d24 > if 2digitLCD else drop c"   " lcd_str then 
     d10 delms                                                
     chkCounter                                   \ Reset counter if counter > 50 
     \ Day-selection finished?     
     finish?                                      \ Break begin-until if sw is pushed
     if 
          d25 < 
          if 9 1 lcd_pos day W@ 2digitLCD then    \ Display day 
          1 
     else 
          0 
     then                                         
until
waitRelease             
;

\ Set weekday [1 to 7]
\ ( -- )
: setWeekday
1 prepare                     \ 1x4
begin
     pos/4 dup 1 < 
     if 
          drop 7 d28 pos L! 
     else 
          dup 7 > 
          if 
               drop 1 4 pos L! 
     thens
     dup weekday W!
     d13 1 lcd_pos
     \ Display value with flashing on charLCD
     over d24 > if rtc_week_LCD else drop c"    " lcd_str then 
     d10 delms                                                
     chkCounter                                   \ Reset counter if counter > 50 
     \ weekDay-selection finished?     
     finish?                                      \ Break begin-until if sw is pushed
     if 
          d25 < 
          if d13 1 lcd_pos day W@ rtc_week_LCD then   \ Display weekday 
          1 
     else 
          0 
     then                                         
until
waitRelease             
;
     
\ Set hour [0 to 23]
\ ( -- )
: setHour
0 prepare                     \ 0x4
begin
     pos/4 dup 0 < 
     if 
          drop d23 d92 pos L! 
     else 
          dup d23 > 
          if 
               drop 0 0 pos L! 
     thens
     dup hour W!
     1 2 lcd_pos
     \ Display value with flashing on charLCD
     over d24 > if 2digitLCD else drop c"   " lcd_str then 
     d10 delms                                                
     chkCounter                                   \ Reset counter if counter > 50 
     \ Hour-selection finished?     
     finish?                                      \ Break begin-until if sw is pushed
     if 
          d25 < 
          if 1 2 lcd_pos hour W@ 2digitLCD then   \ Display hour 
          1 
     else 
          0 
     then                                         
until
waitRelease             
;

\ Set minute [0 to 59]
\ ( -- )
: setMinute
0 prepare                     \ 0x4
begin
     pos/4 dup 0 < 
     if 
          drop d59 d236 pos L! 
     else 
          dup d59 > 
          if 
               drop 0 0 pos L! 
     thens
     dup minute W!
     4 2 lcd_pos
     \ Display value with flashing on charLCD
     over d24 > if 2digitLCD else drop c"   " lcd_str then 
     d10 delms                                                
     chkCounter                                   \ Reset counter if counter > 50 
     \ Minute-selection finished?     
     finish?                                      \ Break begin-until if sw is pushed
     if 
          d25 < 
          if 4 2 lcd_pos hour W@ 2digitLCD then   \ Display minute 
          1 
     else 
          0 
     then                                         
until
waitRelease             
;
     
\ Set second [0 to 59]
\ ( -- )
: setSecond
0 prepare                     \ 0x4
begin
     pos/4 dup 0 < 
     if 
          drop d59 d236 pos L! 
     else 
          dup d59 > 
          if 
               drop 0 0 pos L! 
     thens
     dup sec W!
     7 2 lcd_pos
     \ Display value with flashing on charLCD
     over d24 > if 2digitLCD else drop c"   " lcd_str then 
     d10 delms                                                
     chkCounter                                   \ Reset counter if counter > 50 
     \ second-selection finished?     
     finish?                                      \ Break begin-until if sw is pushed
     if 
          d25 < 
          if 7 2 lcd_pos sec W@ 2digitLCD then    \ Display sec 
          1 
     else 
          0 
     then                                         
until
waitRelease             
;


\ Set initial tima and date
\ ( -- )
: initialSet
init_sw
ledpin pinout            \ Set led to uutput
c" encoder" 0 cogx                                          
lcd_init                                                      
;

\ Set date and time to rtc
\ ( --)
: setTime
initialSet
begin
     \ Read rtc
     7 current DS1337 i2c_rd_multi                                      
     \ Display year/month/date/weekday/hour/minute/sec
     1 1 lcd_pos
     bcd> d2000 + lcd_dec h2E lcd_char bcd> 2digitLCD h2E lcd_char bcd> 2digitLCD     
     1 lcd_bl h28 lcd_char rtc_week_LCD h29 lcd_char                                    
     1 2 lcd_pos
     bcd> 2digitLCD h3A lcd_char bcd> 2digitLCD h3A lcd_char bcd> 2digitLCD   
                                                                             
     \ Check sw
     sw_input                     
     \ Switch is pushed?
     swState W@ 0= push L@ and
     if
          cnt COG@ push L@ - clkfreq 2 * >        \ It exceed 2seconds?
          if
               \ --- TimeSet mode --- 
               ledpin pinhi                       \ LED on because of entering TimeSet mode
               waitRelease

               \ year
               setYear
               \ month
               setMonth
               \ day
               setDay
               \ weekday
               setWeekday
               \ hour
               setHour
               \ minute
               setMinute
               \ second
               setSecond
          
               ledpin pinlo
               \ Set date and time to rtc 
               year W@ >bcd month W@ >bcd day W@ >bcd weekday W@ >bcd 
               hour W@ >bcd minute W@ >bcd sec W@ >bcd 
               7 0 DS1337 i2c_wr_multi 
          then                 
     then                  
                                 
     fkey? swap drop      
until
0 cogreset
;
