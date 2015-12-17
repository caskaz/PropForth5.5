fl

{
PropForth5.5(DevKernel)

RealTimeClock (PFC85263)
Using i2c_utility_0.4.f   
2015/04/17 19:58:43

         PCF85263    Propeller
          Vcc   ----  3.3V
          SCL   ----  SCL
          SDA   ----  SDA
                      ___________
          OSCI  ---- | 32.768kHz |
          OSCO  ---- | Xtal      |
                      -----------
          INTA  ----
          VBAT  ----  
          Vss   ----  GND
          INT    
}

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
\ Slave addres h51 for PCF85263 
hA2 wconstant PCF85263

\ register name 
\                                  RTC mode                           StopWatch mode 
\                             ---- RTC time ----                 ---- StopWatch time ----
0 wconstant 100th_sec         \    100th_seconds[0 - 99]              100th_seconds[0 - 99]
1 wconstant sec               \    Seconds[0 - 59]                    Seconds[0 - 59]
2 wconstant minute               \    Minutes[0 - 59]                    Minutes[0 - 59]
3 wconstant hour              \    AMPM Hours[1 - 12]                 HR XX_XX_00[0 - 99]
                              \    Hours[1 - 23]                 
4 wconstant day               \    days[1 - 31]                       HR XX_00_XX[0 - 99]
5 wconstant weekday           \    Weekdays[0 - 6]]                   HR 00_XX_XX[0 - 99]
6 wconstant month             \    Months[1 - 12]                     Not used
7 wconstant year              \    Years[0 - 99]                      Not used
\                             ---- RTC alarm1 ----               ---- StopWatch alarm1 ----
8 wconstant alm1_sec          \    Second alarm1[0 - 59]              Second alarm1[0 - 59]
9 wconstant alm1_min          \    Minutes alarm1[0 - 59]             Minutes alarm1[0 - 59]
h0A wconstant alm1_hour       \    AMPM Hour_alarm1[1 - 12]           HR XX_XX_00 alarm1[0 - 99]
                              \    HOURD[1 - 23]
h0B wconstant alm1_day        \    Day alarm1[1 - 31]                 HR XX_00_XX alarm1[0 - 99]
h0C wconstant alm1_month      \    Month alarm1[1 - 12]               HR 00_XX_XX alarm1[0 - 99]
\                             ---- RTC alarm2 ----               ---- StopWatch alarm2 ----
h0D wconstant alm2_min        \    Minutes[0 - 59]                    Minutes alarm2[0 - 59]
h0E wconstant alm2_hour       \    AMPM Hours[1 - 12]                 HR XX_00 alarm2[0 - 99]
                              \    Hours[1 - 23]
h0F wconstant alm2_weekday    \    Weekday[0 - 6]                     HR 00_XX alarm2[0 - 99]
\                             ---- RTC alarm enables ----        ---- StopWatch enables ----
h10 wconstant ALM_enable      \    Alarm enables                      Alarm enables 
\                             ---- RTC timestamp1(TSR1) ---      ---- StopWatch timestamp1(TSR1) --- 
h11 wconstant TSR1_sec        \    TSR1 seconds[0 - 59]               TSR1 seconds[0 - 59]
h12 wconstant TSR1_min       \    TSR1 minutes[0 - 59]               TSR1 minutes[0 - 59]
h13 wconstant TSR1_hour       \    TSR1 AMPM Hours[1 - 12]            TSR1 HR XX_XX_00[0 - 99]
                              \    TSR1 Hours[1 - 23]
h14 wconstant TSR1_day        \    TSR1 days[1 - 31]                  TSR1 HR XX_00_XX[0 - 99]
h15 wconstant TSR1_month      \    TSR1 months[1 - 12]                TSR1 HR XX_00_XX[0 - 99]
h16 wconstant TSR1_year       \    TSR1 years[0 - 99]                 TSR1 HR 00_XX_XX[0 - 99]
\                             ---- RTC timestamp2 ----           ---- StopWatch timestamp1(TSR2) ---
h17 wconstant TSR2_sec        \    TSR2 seconds[0 - 59]               TSR2 seconds[0 - 59]
h18 wconstant TSR2_min        \    TSR2 minutes[0 - 59]               TSR2 minutes[0 - 59]
h19 wconstant TSR2_hourR       \    TSR2 AMPM Hours[1 - 12]            TSR2 HR XX_00_XX[0 - 99]
                              \    TSR2 Hours[1 - 23]
h1A wconstant TSR2_day        \    TSR2 days[1 - 31]                  TSR2 HR XX_00_XX[0 - 99]
h1B wconstant TSR2_month      \    TSR2 months[1 - 12]                TSR2 HR 00_XX_XX[0 - 99]
h1C wconstant TSR2_year       \    TSR2 years[0 - 99]                 Not used
\                             ---- RTC timestamp3 ----           ---- StopWatch timestamp1(TSR3) ---
h1D wconstant TSR3_sec        \    TSR3 seconds[0 - 59]               TSR3 seconds[0 - 59]
h1E wconstant TSR3_min        \    TSR3 minutes[0 - 59]               TSR3 minutes[0 - 59]
h1F wconstant TSR3_hour       \    TSR3 AMPM Hours[1 - 12]            TSR2 HR XX_00_XX[0 - 99]
                              \    TSR3 Hours[1 - 23]            
h20 wconstant TSR3_day        \    TSR3 days[1 - 31]                  TSR2 HR 00_XX_XX[0 - 99]
h21 wconstant TSR3_month      \    TSR3 months[1 - 12]                TSR2 HR XX_00_XX[0 - 99]
h22 wconstant TSR3_year       \    TSR3 years[0 - 99]                 Not used
\                             ---- RTC timestamp mode control --  --- StopWatch mode control ---
h23 wconstant TSR_mode        \    TSR mode                           TSR mode

h24 wconstant offset          \ Offset
h25 wconstant osc             \ Oscillator
h26 wconstant battery         \ Battery switch
h27 wconstant pin_IO          \ Pin I/O
h28 wconstant function        \ Function
h29 wconstant INTA            \ INTA enable
h2A wconstant INTB            \ INTB enable
h2B wconstant flag            \ Flags
h2C wconstant RAM             \ RAM byte
h2D wconstant dog             \ WatchDog
h2E wconstant stop            \ Stop enable
h2F wconstant reset           \ Reset

\ =========================================================================== 
\ Variables 
\ =========================================================================== 


\ =========================================================================== 
\ Main 
\ =========================================================================== 
\ ------ Convert week-number to string ------
\ rtc_week ( n1 -- )  n1:0 to 6
: rtc_weekday
7 and 
c" MONTUEWEDTHUFRISATSUN" 1+ swap 3 u* +
3 0 do dup C@ emit 1+ loop drop 
;

\ Convert month-number to string
\ rtc_moth ( n1 -- )  n1:1 to 12
: rtc_month 
c" JANFEBMARAPRMAYJUNJULAUGSEPOCTNOVDEC" 1+ swap hC min 1 max 1- 3 u* +
3 0 do dup C@ emit 1+ loop drop 
;

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

\ ------ BCD Conversion ------
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

\ Soft reset
\ ( -- )
: SoftReset h2C reset PCF85263 i2c_wr err? ;

\ Set 100th second
\ ( n1 -- ) n1:0(Default:100th second disabled)  1(100th second enabled)
: Set100th
function PCF85263 i2c_rd err?
swap if h80 or else h7F and then
function PCF85263 i2c_wr err?
;

{
\ Set 24Hr or 12Hr mode
\ ( n1 -- )  n1:0(Default:24Hr mode)  1(12Hr mode)
: Set24Hr
osc PCF85263 i2c_rd err?
swap 
if 
     \ Change each register to 24Hour format
     \ RTC time Hour register     
     \ RTC alarm1 Hour register
     \ RTC alarm2 Hour register
     \ RTC TSR1 Hour register
     \ RTC TSR2 Hour register
     \ RTC TSR3 Hour register
     h20 or 
else 
     \ Change each register to 12Hour format
     \ RTC time Hour register     
     \ RTC alarm1 Hour register
     \ RTC alarm2 Hour register
     \ RTC TSR1 Hour register
     \ RTC TSR2 Hour register
     \ RTC TSR3 Hour register
     hDF and then
then
osc PCF85263 i2c_wr err?
;
}

\ Set RTC or StopWatch mode
\ ( n1 -- )  n1:0(Default:RTC mode)  1(StopWatch mode)
: SetRTC 
function PCF85263 i2c_rd err?
swap if h10 or  else hEF and then
function PCF85263 i2c_wr err?
;

\ Get current time 
\ Read/Convert current time from PCF85263
\ ( -- n1 n2 n3 n4 n5 n6 n7 )
\ n1 - 100th second (00 - 99)
\ n2 - second		(00 - 59)
\ n3 - minute		(00 - 59)
\ n4 - hour		24Hr:(00 - 23) 
\ n6 - date		(01 - 31)
\ n5 - weekday 	(Mon:0 Tue:1 Wed:2 Thur:3 Fri:4 Sat:5 San:6)
\ n7 - month		(01 - 12)
\ n8 - yesr		(2000 - 2099)   
: rd_current 
8 100th_sec PCF85263 i2c_rd_multi err? 
cr   ." CurrentTime" cr
." Year: " bcd> d2000 + . cr                 \ Year
." Date: " bcd> rtc_month space >r bcd> .    \ Month Date
space r> rtc_weekday cr                      \ Weekday
bcd> 2digit h3A emit                         \ Hour
bcd> 2digit h3A emit                         \ Minute
bcd> 2digit                                  \ Second
drop                                         \ Drop 100th second
cr
;

\ Set current-time to PCF85263   (24Hour mode)
\ Set second and 100th second to 0
\ ( n1 n2 n3 n4 n5 n6 -- ) 
\ n1 - yesr		(00 - 99)   
\ n2 - month		(01 - 12)
\ n3 - weekday      (Mon:0 Tue:1 Wed:2 Thur:3 Fri:4 Sat:5 San:6)
\ n4 - date		(01 - 31)
\ n5   hour		(00 - 23)
\ n6 - minute		(00 - 59)
: set_current                                                    
h80 sec PCF85263 i2c_wr err?  \ Clear OS bit
>bcd >r                       \ minute
>bcd >r                       \ hour
>bcd >r                       \ day
>r                            \ weekday
>bcd >r                       \ month
d2000 - >bcd                  \ year
r> r> r> r> r> 0 0
\ Write values to each register                           
8 100th_sec PCF85263 i2c_wr_multi err?
; 


: test
begin
rd_current   cr
d1000 delms
fkey? swap drop
until
;

