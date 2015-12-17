fl

{
PropForth5.5(DevKernel)

RealTimeClock (PFC2129)
Using i2c_utility_0.4.f   
2015/10/08 12:53:55

         PCF2129    Propeller
          Vdd   ----  3.3V
          SCL   ----  SCL
          SDA   ----  SDA
          IFS   --|
                  |
          BBS   --|        
          SDI   ----  GND
          VBAT  ----  GND
          Vss   ----  GND
              
}

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
\ Slave addres h51 for PCF2129 
hA2 wconstant PCF2129

\ register name 
0 wconstant control1
1 wconstant control2
2 wconstant control3
3 wconstant sec
4 wconstant minute
5 wconstant hour
6 wconstant day
7 wconstant weekday
8 wconstant month
9 wconstant year
hA wconstant alm_sec
hB wconstant alm_min
hC wconstant alm_hour
hD wconstant alm_day
hE wconstant alm_weekday
hF wconstant clockout_ctl
h10 wconstant WD_tim_ctl
h11 wconstant WD_tim_val
h12 wconstant Timest_ctl
h13 wconstant Timest_sec
h14 wconstant Timest_min
h15 wconstant Timest_hour
h16 wconstant Timest_day
h17 wconstant Timest_mon
h18 wconstant Timest_year
h19 wconstant Aging_offset

\ =========================================================================== 
\ Main 
\ =========================================================================== 
\ allocate string
\ ( -- )
: s, parsenw dup C@ 1+ bounds dup rot2 do C@++ c, loop drop ;

wvariable string -2 allot 
s, Control_1 s, Control_2 s, Control_3 
s, Seconds s, Minutes s, Hourd s, Days s, Weekdays s, Months s, Years 
s, Second_alarm s, Minute_alarm s, Hour_alarm s, Day_alarm s, Weekday_alarm
s, CLKOUT_ctl 
s, Watchdog_tim_ctl s, Watchdog_tim_val 
s, Timestp_ctl s, Sec_timestp s, Min_timestp s, Hour_timestp s, Day_timestp s, Mon_timestp s, Year_timestp
s, Aging_offset

\ Display allocated string above
\ ( n1 n2 -- )  n1:string index  n2:string's top address
: dispStr 
swap dup 0 <> 
if  
     0 do
          dup C@ + 1+
     loop     
else
     drop     
then 
.cstr 
;

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

\ Read register
\ ( n1 n2 -- n3..nn t/f )  n1:number  n2:register  n3..nn:series data  t/f:true if there was an error
: PCF2129_rd_multi
\ Start I2C 
_eestart
\ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi)  
PCF2129 _eewrite              \ ( n1 n2 t/f )
\ Write register
swap _eewrite or              \ ( n1 t/f )

_eestop _eestart
\ Write slave address[rd], then receive Acknowledge-bit(ACK:Lo  NACK:Hi)
PCF2129 1 or 
_eewrite or                   \ ( n1 t/f )
\ Read (n1-1)bytes
>r                            \ Push flag  ( n1 )
dup 1 > 
if 
     1 - 0 do 
          0 _eeread           \ ( n3..nn-1 )
     loop
else
     drop
then
\ Read 1byte ,then set sda to Hi(NACK:master->slave)
-1 _eeread                    \ ( n3..nn )
r>                            \ Pop flag   ( n3..nn t/f )
\ Stop I2C
_eestop 
;

\ Display all registers 
\ ( -- )
: rd_allreg
cr hex   ." register:value[hex]" cr
d26 0 do
     i string dispStr                    \ Print register-name 
     ." :"
     1 i PCF2129_rd_multi . cr
loop
decimal
;


\ Get current time 
\ Read/Convert current time from PCF2129
\ ( -- n1 n2 n3 n4 n5 n6 n7 )
\ n1 - second		(00 - 59)
\ n2 - minute		(00 - 59)
\ n3 - hour		24Hr:(00 - 23) 
\ n4 - date		(01 - 31)
\ n5 - weekday 	(Mon:0 Tue:1 Wed:2 Thur:3 Fri:4 Sat:5 San:6)
\ n6 - month		(01 - 12)
\ n7 - yesr		(2000 - 2099)   
: rd_time 
7 sec PCF2129_rd_multi 
cr   ." CurrentTime" cr                               
." Year: " bcd> d2000 + . cr                 \ Year
." Date: " bcd> rtc_month space >r bcd> .    \ Month Date
space r> rtc_weekday cr                      \ Weekday
bcd> 2digit h3A emit                         \ Hour
bcd> 2digit h3A emit                         \ Minute
bcd> 2digit                                  \ Second
cr
;

\ Set current-time to PCF2129   (24Hour mode)
\ Set second to 0
\ ( n1 n2 n3 n4 n5 n6 -- ) 
\ n1 - yesr		(00 - 99)   
\ n2 - month		(01 - 12)
\ n3 - weekday      (Mon:0 Tue:1 Wed:2 Thur:3 Fri:4 Sat:5 San:6)
\ n4 - day 		(01 - 31)
\ n5   hour		(00 - 23)
\ n6 - minute		(00 - 59)
: set_time                                                   
>bcd >r                       \ minute
>bcd >r                       \ hour
>bcd >r                       \ day
>r                            \ weekday
>bcd >r                       \ month
d2000 - >bcd                  \ year
r> r> r> r> r> 0
\ Write values to each register                           
7 sec PCF2129 i2c_wr_multi 
; 

\ Print time
\ ( -- )
: test begin rd_time d1000 delms fkey? swap drop until ;
