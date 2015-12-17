fl

{
PropForth 5.5(DevKernel)

RTC DS1337 driver  
Using i2c_utility_0.4.f   
2015/10/06 15:19:37
 
   RTC DS1337     Propeller
      scl    ----  P28   
      sda    ----  P29 
      INTA   ----  Pull-up resister --- 3V3
   SQW/INTB  ----  Pull-up resister --- 3V3
}

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
\ Slave addres[h68] for DS1337
hD0 wconstant DS1337

\ register name
0 wconstant current
7 wconstant alarm1
9 wconstant alm1_Hour
hA wconstant alm1_DY/DT
hB wconstant alarm2
hC wconstant alm2_Hour
hD wconstant alm2_DY/DT
hE wconstant control
hF wconstant status

\ register value
h40 wconstant 12Hour
h20 wconstant AM/PM
h40 wconstant DY/DT

\ SQW_rate
0 wconstant 1Hz     \ 1Hz
1 wconstant 4kHz    \ 4.096kHz
2 wconstant 8kHz    \ 8.192kHz
3 wconstant 32kHz   \ 32.68kHz

\ =========================================================================== 
\ String 
\ =========================================================================== 
\ Convert week-number to string
\ rtc_week ( n1 -- )  n1:1 to 7
: rtc_week
7 and 
c" MONTUEWEDTHUFRISATSUN" 1+ swap 1 max 1- 3 u* +
3 0 do dup C@ emit 1+ loop drop 
;

\ Convert month-number to string
\ rtc_mon ( n1 -- )  n1:1 to 12
: rtc_mon 
c" JANFEBMARAPRMAYJUNJULAUGSEPOCTNOVDEC" 1+ swap hC min 1 max 1- 3 u* +
3 0 do dup C@ emit 1+ loop drop 
;

\ =========================================================================== 
\ BCD Conversion
\ =========================================================================== 
\ bcd> ( n1 -- n2 ) convert bcd byte n1 to hex byte n2
[ifndef bcd>
: bcd>
	dup hF and
	swap hF0 and
	1 rshift dup
	2 rshift + +
;
]

\
\ >bcd ( n1 -- n2 ) convert hex byte n1 to bcd byte n2
[ifndef >bcd
: >bcd
	d10 u/mod 4 lshift +
;
]

\ _rtcflip7 ( n7 n6 n5 n4 n3 n2 n1 -- n1 n2 n3 n4 n5 n6 n7 ) flip the top 7 items on the stack
: _rtcflip7 
	rot >r rot >r rot >r rot >r rot >r
	swap
	r> r> r> r> r>
	rot >r rot >r rot >r
	swap
	r> r> r>
	swap rot
;

\ =========================================================================== 
\ Reading register value
\ =========================================================================== 
\ Display all register's value 
: disp_reg
." Address(hex)  " ." value(hex)" cr
hex
h10 0 do
     9 emit
     i .byte                  \ Display register address
     9 emit
     i DS1337 i2c_rd          \ Read value
     .byte                    \ Display register value
     cr
loop
decimal
;

\ =========================================================================== 
\ Interrupt control for alarm1/alarm2
\ =========================================================================== 

\ Set/Clear INTCN bit
\ ( n1 -- )  n1:0/1  0=clear 1=set    
: set_INTCN 
control        \ register 
DS1337         \ slave address
i2c_rd         \ ( n1 data )
swap           \ ( n1 data )
hFB and swap if 4 or then     \ ( data )
control                       \ register
DS1337                        \ slave address
i2c_wr                        \ ( -- )
;

\ Print message[Enabled/Disabled] by control register value  
\ ( n1 n2 -- )  n1:control register value n2:alarm[1/2]
: INT_msg and if ." Enabled" else ." Disabled" then cr ;

\ Display alarm1/alarm2 Interupt status
\ ( -- )
: chk_IE 
control        \ register
DS1337         \ slave address
i2c_rd         \ ( data )
dup 
." Alarm1 Interupt:" 1 INT_msg 
." Alarm2 Interupt:" 2 INT_msg 
;

\ Enable/Disable interupt for alarm1/alarm2
\ ( n1 n2 -- t/f )  n1:enable[1] disable[0]  n2:alarm1 or alarm2  t/f:true if there was an error
: set_IE
control        \ register
DS1337         \ slave address
i2c_rd         \ ( n1 n2 data )
rot2           \ ( data n1 n2 )
alarm1 =
if 
     \ alarm1
     if 1 or else hFE and then     \ Set or Clear bit0[A1IE]  
else
     \ alarm2
     if 2 or else hFD and then     \ Set or Clear bit1[A2IE]
then           \ ( data )
control        \ register
DS1337         \ slave address
i2c_wr
chk_IE
;

\ Print status 
\ ( n1 -- )
: status_msg and if ." 1" else ." 0" then cr ;

\ Display alarm flag
\ ( -- )
: chk_INT
status         \ register
DS1337         \ slave address
i2c_rd         \ ( data )
dup
." Alarm1 Flag:" 1 status_msg
." Alarm2 Flag:" 2 status_msg cr
;

\ Clear INT-flag for alarm1/alarm2, then clear A1M4 and A2M3 (Alarm when hour.minutes match) 
\ ( n1 -- )  n1:alarm1 or alarm2   
: clr_INT
status         \ register
DS1337         \ slave address
i2c_rd         \ ( n1 data )
swap           \ ( data n1 )
alarm1 = 
if 
     \ Clear bit0
     hFE and                            \ ( data*hFE )       
     \ Clear A1M4
     alm1_DY/DT dup DS1337 i2c_rd       \ ( n1*hFE register data )
     h7F and swap DS1337 i2c_wr         \ ( n1*hFE )   
else 
     \ clear bit1
     hFD and                            \ ( data*hFD )                
     \ Clear A2M4
     alm2_DY/DT dup DS1337 i2c_rd       \ ( n1*hFDE register data )
     h7F and swap DS1337 i2c_wr         \ ( n1*hFE t/f ) 
     status DS1337 i2c_wr 
then
chk_INT
;
                
\ =========================================================================== 
\ Manipulate digits
\ =========================================================================== 
\ Print 1digit
\ ( n1 -- ) n1:digit (0-9)
: 1digit tochar emit ;

\ Alignment/Print time-digit to 2digits
\ ( n1 -- ) n1:time-digit (0-24,0-59)
: 2digit
dup d10 <
if
     \ If n1 < d10
     0 tochar emit tochar emit
else
     \ If n1 > 9
     d10 u/mod tochar emit tochar emit
then
;

\ =========================================================================== 
\ Manipulate 12/24-mode
\ =========================================================================== 
\ Set 12/24-mode to current/alarm1/alarm2
\ ( n1 n2 -- )  n1:1=12Hour or 0=24Hour  n2:register[current or alarm1 or alarm2]
: set_12/24
dup alarm2 = if 1+ else 2+ then              \ Get Hour regiter address
                                             \ ( n1 n2 )
2dup                                         \ ( n1 n2 n1 n2 )
DS1337 i2c_rd                                \ Read Hour register  ( n1 n2 n1 data )
12Hour and 6 rshift <>                       \ ( n1 n2 t/f )
if
                                             \ ( n1 n2 )
     dup DS1337 i2c_rd                       \ ( n1 n2 data )
     dup 12Hour and 0 =                                             
     if
          \ Change 24Hour to 12Hour
          bcd> dup d12 > 
          if d12 - 1 else 0 then             \ If hour > 12, subtract d12, then set [AM/PM]
          5 lshift swap >bcd or 12Hour or    \ Add bit6(12Hour) +bit5(PM/AM) + Hour(bit4-bit0)
     else
          \ Change 12Hour to 24Hour 
          dup AM/PM and 0= if 0 else 1 then  \ Check if AM/PM
          swap h1F and bcd> swap             
          if d12 + then                      \ Add d12 if PM
          >bcd
     then                                    \ ( n1 n2 data )
     over DS1337 i2c_wr                      \ ( n1 n2 )
then
2drop
;

\ =========================================================================== 
\ Common word on current, alarm1, alarm2
\ =========================================================================== 
\ Display AM or PM checking AM/PM on 12Hour mode
\ ( n1 -- n2 )  n1:Hour register(bcd)  n2:Hore(binary)
: disp_AM/PM
dup AM/PM and swap            \ Check AM/PM 
h1F and bcd> swap             \ Convert Hour to hex byte
if ." PM" else ." AM" then    \ Print AM or PM
space
;

\ Display AM/PM and calculate Hour-time if 12Hour mode
\ ( n1 -- n2 )  n1:Hour register(binary)  n2:Hore(binary)
: chk_12H_mode
." Time: "
>bcd dup 12Hour and 0<>
if 
     disp_AM/PM          \ Display AM/PM on 12Hour mode
else 
     bcd>                \ Convert data to binary on 24Hour mode 
then
;

\ Display or Not display Day/date 
\ ( n1 n2 -- )   n1:Hour  n2:DAY/DT register  
: disp_DY/DT
DS1337 i2c_rd                                          \ Get Day/Date for alarm1 or alarm2
                                                       \ ( n1 data )
dup h80 and 0=                                         \ Check A1M4/A2M4 whether display  DY/DT or not
if
     DY/DT and                                         \ Day or Date?
     if ." Week: " rtc_week else ." Date: " . then cr  \ Display Week or Date   
else
     2drop     
then                                                   \ ( n1 )
chk_12H_mode                                           \ Display AM/PM if 12Hour mode   
;

\ Convert input-value to bcd
\ ( n1 n2 -- n3 )  n1:data n2:Hour register    n3:Hour 
: conv_hour
DS1337 i2c_rd                           \ ( n1 hour )
dup 12Hour and                          
\ Check if 12Hour-mode 
if 
                                        \ ( n1 hour )
     \ 12Hour mode
     swap dup d12 > 
     if 
          \ > d12
          d12 - >bcd AM/PM or           \ Add bit5[AM/PM]
     else
          \ d13 >
          >bcd                         
     then
     12Hour or swap                     \ Add bit6[12/24]
else
     \ 24Hour mode
     swap >bcd swap
then
h80 and                                 \ mask bit7[A1m4 or A2M4]
or                                      \ bit7[1 or 0] + Hour  
;

\ =========================================================================== 
\ Current time
\ =========================================================================== 
\ Get current time 
\ Read/Convert current time from DS1337
\ ( -- n1 n2 n3 n4 n5 n6 n7 )
\ n1 - second		(00 - 59)
\ n2 - minute		(00 - 59)
\ n3 - hour		(00 - 23)
\ n4 - day of week 	(Mon:1 Tue:2 Wed:3 Thur:4 Fri:5 Sat:6 San:7)
\ n5 - date		(01 - 31)
\ n6 - month		(01 - 12)
\ n7 - yesr		(2000 - 2099)   
: rd_current
7 0 do current i + DS1337 i2c_rd bcd> loop                 
cr   ." CurrentTime" cr
." Year: " d2000 + . cr
." Date: " rtc_mon space . rtc_week cr
chk_12H_mode
2digit h3A emit 2digit h3A emit 2digit  
cr cr    
;

\ Set current-time to DS1337   (24Hour mode)
\ Set second to 0
\ ( n1 n2 n3 n4 n5 n6 -- ) 
\ n1 - yesr		(00 - 99)   
\ n2 - month		(01 - 12)
\ n3 - date		(01 - 31)
\ n4 - day-of-week  (Mon:1 Tue:2 Wed:3 Thur:4 Fri:5 Sat:6 San:7)
\ n4 - hour		(00 - 23)
\ n5 - minute		(00 - 59)
: set_current 
0 status DS1337 i2c_wr        \ Clear OSF
>bcd >r                       \ minute
>bcd >r                       \ hour
>r                            \ day-of-week
>bcd >r                       \ day
>bcd >r                       \ month
d2000 - >bcd                  \ year
r> r> r> r> r> 0     
7 current DS1337 i2c_wr_multi
rd_current 
0 alarm1 set_12/24 0 alarm2 set_12/24        \ Set alarm1/alarm2 to 24Hour mode
;

\ =========================================================================== 
\ Alarm1 time
\ =========================================================================== 
\ Get alarm1 time from DS1337
\ ( -- n1 n2 n3 n4 )
\ n1 - second		(00 - 59)
\ n2 - minute		(00 - 59)
\ n3 - hour		(00 - 23)
\ n4 - day of week 	(Mon:1 Tue:2 Wed:3 Thur:4 Fri:5 Sat:6 San:7)
\      date  (1-31)
: rd_alm1
4 0 do alarm1 i + DS1337 i2c_rd bcd> loop
cr  ." Alarm1 setting" cr                                     
\ Check if Day or Date or Ignore, then 12Hour-mode                     
alm1_DY/DT disp_DY/DT
2digit h3A emit 2digit h3A emit 2digit  cr cr     
;

\ Set alarm1-time to DS1337   (24Hour mode)
\ Set second to 0
\ ( n1 n2 n3 -- ) 
\ n1 - date		(01 - 31)       bit[DY/DT]=0
\ n1 - day-of-week  (Mon:1 Tue:2 Wed:3 Thur:4 Fri:5 Sat:6 San:7)    bit[DY/DT]=1
\ n2 - hour		(00 - 23)
\ n3 - minute		(00 - 59)
: set_alm1 
>bcd >r                       \ minute
>r                            \ hour
>bcd >r                       \ day / day-of-week
r> r> r> 0
2 alarm1 DS1337 i2c_wr_multi                 \ Save second and minute to register                                           
\ Hour   
alm1_Hour conv_hour
alm1_Hour DS1337 i2c_wr                      \ Save Hour to register          
alm1_DY/DT DS1337 i2c_rd  
DY/DT h80 or and or 
alm1_DY/DT DS1337 i2c_wr                     \ Save bit[A1M4] + bit[Day or Date] + InputValue to register
rd_alm1                                      \ Display alarm1 setting
\ Interrupt Enable
1 alarm1 set_IE
;

\ =========================================================================== 
\ Alarm2 time
\ =========================================================================== 
\ Get alarm2 time from DS1337
\ ( -- n1 n2 n3 )
\ n1 - minute		(00 - 59)
\ n2 - hour		(00 - 23)
\ n3 - day of week 	(Mon:1 Tue:2 Wed:3 Thur:4 Fri:5 Sat:6 San:7)
\      date
: rd_alm2
3 0 do alarm2 i + DS1337 i2c_rd bcd> loop
cr  ." Alarm2 setting" cr
\ Check if Day or Date or Ignore, then 12Hour-mode                     
alm2_DY/DT disp_DY/DT
2digit h3A emit 2digit cr cr     
;

\ Set alarm2-time to DS1337   (24Hour mode)
\ ( n1 n2 n3 -- ) 
\ n1 - date		(01 - 31)         bit[DY/DT]=0
\ n1 - day-of-week  (Mon:1 Tue:2 Wed:3 Thur:4 Fri:5 Sat:6 San:7)   bit[DY/DT]=1
\ n2 - hour		(00 - 23)
\ n3 - minute		(00 - 59)
: set_alm2 
>bcd >r                       \ minute
>r                            \ hour
>bcd >r                       \ day / day-of-week
r> r> r>      
alarm2 DS1337 i2c_wr          \ Save minute to register
\ Hour
alm2_Hour conv_hour
alm2_Hour DS1337 i2c_wr       \ Save Hour to register          
 
alm2_DY/DT DS1337 i2c_rd  
DY/DT h80 or and or 
alm2_DY/DT DS1337 i2c_wr      \ Save bit[A2M4] + bit[Day or Date] + InputValue to register
rd_alm2                       \ Display alarm1 setting

\ Interrupt Enable
1 alarm2 set_IE
;
                                                                       
\ =========================================================================== 
\ Manipulating special-purpose registers except for interrupt
\ =========================================================================== 
\ Set SQW
\ ( n1 --)  n1:1Hz or 4kHz(4.096kHz) or 8kHz(8.192kHz) or 32kHz(32.768kHz) (default:32.768kHz)
: set_SQW 
control DS1337 i2c_rd 
hE7 and swap 3 lshift or 
control DS1337 i2c_wr 
;

\ Start/Stop OSC
\ (n1 -- )  n1:0(stop)/1(start)
: osc_on/off
dup                                          \ ( n1 n1 )
status DS1337 i2c_rd                         \ ( n1 n1 data )
h80 and                                      \ Check bit7[OSF]  Logic 1 indicate oscillator stop
7 rshift =                                   \ ( n1 t/f )
if                                           \ ( n1 )
     if
          \ Start OSC
          ." OSC started."
          control DS1337 i2c_rd              \ ( data )
          h7F and                            \ Clear bit7[EOSC] 
          control DS1337 i2c_wr or           \ ( -- )
          \ Clear OSF-bit
          d500 delms                         \ wait 
          status DS1337 i2c_rd               \ ( data )
          h7F and                            \ Clear bit7[OSF]
          status DS1337 i2c_wr               \ ( -- )
     else
          \ Stop OSC
          ." OSC stopped."
          control DS1337 i2c_rd              \ ( data )
          h80 or                             \ Set bit7[EOSC]
          control DS1337 i2c_wr              \ ( -- )
     then
else
     if
          ." OSC already is starting."
     else
          ." OSC stop."
     then
then
cr
;

\ =========================================================================== 
\ Utility
\ =========================================================================== 
\ Display current, alarm1, alarm2
\ ( -- )
: all rd_current rd_alm1 rd_alm2 ;

\ Set Time(current,alarm1,alarm2) to 12Hour or 24Hour
\ ( n1 -- )  n1:1[12Hour] or 0[24Hour]
: set_12H
dup dup current set_12/24 alarm1 set_12/24 alarm2 set_12/24
rd_current rd_alm1 rd_alm2
;

\ Disable/Enable No Day/Date on alarm1(hour,minute,0second)
\                                       on alarm2(hour,minute)
\ ( n1 n2 -- )  n1:0(disable)/1(enable)  n2:alarm1 or alarm2
: no_DY/DT
alarm1 =
if
     \ alarm1
     if
          \ ignore DY/DT (Set bit[A1M4])
          alm1_DY/DT DS1337 i2c_rd           \ ( data )
          h80 or                             \ ( t/f data )
     else
          \ valid DY/DT (Clear bit[A1M4])    
          alm1_DY/DT DS1337 i2c_rd           \ ( data )
          h7F and                            \ ( t/f data )
     then
     alm1_DY/DT                              \ ( t/f data register )
else
     \ alarm2
     if
          \ ignore DY/DT (Set bit[A2M4]) 
          alm2_DY/DT DS1337 i2c_rd           \ ( data )
          h80 or                             \ ( data )
     else
          \ valid DY/DT (Clear bit[A2M4]) 
          alm2_DY/DT DS1337 i2c_rd           \ ( data )
          h7F and                            \ ( data )
     then
     alm2_DY/DT                              \ ( data register )
then
DS1337 i2c_wr                                \ ( -- )
;

\ Set DY/DT-mode on alarm1 and alarm2
\ If changed DY/DT-mode, value for Day/Date-mode must be reinitialized
\ ( n1 n2 -- ) n1:1=Day  0=Date   n1:alarm1 or alarm2
: alm_Day
alarm1 = if alm1_DY/DT else alm2_DY/DT then       \ ( n1 register ) 
tuck                                              \ ( register n1 register )
DS1337 i2c_rd                                     \ ( register n1 data )
swap                                              \ ( register data n1 )
if 
     DY/DT or            \ Set bit[DY/DT] 
else 
     DY/DT invert and    \ Clear bit[DY/DT] 
then                                              \ ( register data )
swap                                              \ ( data register )
DS1337 i2c_wr                                     \ ( -- )
;

