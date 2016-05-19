fl

{
USB-Current-Monitor-II
PropForth5.5

OLED display(128X32)   Propeller
           VDD    ----  3.3V
           GND    ----  GND
           RES    ----  P4      
           SCL    ----  P28   
           SDA    ----  P29   
MCD3204
           Din    ----  P0    
           CS     ----  P1
           CLK    ----  P2
           Dout   ----  P3    
Switch
         mode sw  ----  P5
         reverse  ----  P6
         
2014/03/06 21:15:13
}

\ ==================================================================
\ ADC
\ ================================================================== 
\ MCP3204
: _cs_l _cs pinlo ;
: _cs_h _cs pinhi ;
: _do_l _do pinlo ;
: _do_h _do pinhi ;
: _clk_l _clk pinlo ;
: _clk_h _clk pinhi ;

\ Convert analog[0-3.3V] to digital[0-4095] 
\ single-end input for MCP3204
\ ( n1 -- n2 )   n1:channel [0 - 3]  n2:data
: get_a/d    
_cs_l  
\ Output control-bits       
h18 or                        \ Add start-bit and single-bit
h10
5 0 do 
     2dup                     \ ( n1+h18 h10 n1+h18 h10 )      
     and 0> 
     if _do_h then
     _clk_h _clk_l 
     1 rshift 
     _do_l           
loop
2drop                                  
_clk_h _clk_l                 \ dummy clock

\ Read conversion-data   
0                             \ initial value
d13 0 do 
     1 lshift
     _clk_h  _clk_l
     ina COG@ _dim and 0> 
     if 1+ then       
loop     
1 rshift
_cs_h
;
                              
\ Get volt
\ ( -- )
: get_volt
2 get_a/d                     \ Read volt on ch2 
d330 u* d4096 u/ 2 u* 
volt W!
;

\ Replace zero if n1 is minus
\ ( n1 -- n1/0 )     
: chk_minus dup 0< if drop 0 then ;

\ Get current
\ ( -- )
: ADC
4 state andnC! c" RUNNING ADC" cds W!
\ Set pins for ADC to output
_do pinout _cs pinout _clk pinout
\ Initialize data
0 volt W!
0 current W!
0 sum_buf L!
0 top_pos W!
1 LT_1A W!
0 connect W!        \ USB device not connected

get_volt

\ Measurement for current at every 50msec 
cnt COG@ 50msec +
0                                  \ Initial counter   ( cnt+50msec 0 )
begin
     \ Check flag(less than 1A)
     0 get_a/d ch0_offset +
     chk_minus                     \ If minus, replace to zero
     switch_amp <                  \ Compare threshold between 1A and 2A
     if 
          1                        \ Less than 1A 
     else 
          0                        \ More than 1A
     then 
     dup LT_1A W@ <> 
     if 
          LT_1A W! drop 0                              \ If flag is different from previos, counter is resetted.
          0 sum_buf L!
          0 top_pos W!
                                                       \ ( cnt+50msec 0 )
     else
          drop
     then         
                                                                
     LT_1A W@                                               
     if
          \ Less than 1A
          0 get_a/d dup 5 <          
          if
               drop 0
          else
               ch0_offset +
               chk_minus                                \ If minus, replace to zero
          then
     else
          \ More than 1A
          1 get_a/d ch1_offset +                       
          chk_minus                                    \ If minus, replace to zero
     then
                                                       \ ( cnt+50msec counter ADCdata )     
     over d80 <>
     if     
          over ADC_buf + W!                            \ ( cnt+50msec counter )
          dup ADC_buf + W@ sum_buf L@ + sum_buf L!
          2+                                           \ ( cnt+50msec counter+2 )
     else                                              
          sum_buf L@ top_pos W@ ADC_buf + W@ -         \ Subtract top_pos of ring-buffer from sum_buf
                                                       \ ( cnt+50msec counter ADCdata sum_buf-top_pos )
          over top_pos W@ ADC_buf + W!                 \ Replace new ADC-data to top_pos of ring-buffer
          + sum_buf L!                                 \ ( cnt+50msec counter )
          
          \ Update top_pos
          top_pos W@ 2+ dup d80 =
          if drop 0 then
          top_pos W!
     then
     sum_buf L@ over 2 / u/                            \ Get average
                                        
     LT_1A W@
     if
          \ less than 1A 
          d1000 u* d4096 u/                            \ Convert 0 to d1000 [Less than 1A]   Adjustme gain
     else
          \ More than 1A
          d2000 u* d3948 u/                            \ Convert 0 to d2000 [More than 1A]   Adjustme gain

     then
     dup 5 <                                           \ Check if less than 5mA
     if drop 0 else 1 connect W! then                  \ USB device connected
     current W!                                        \ Save average data to current, break loop   
     get_volt
     swap                                              \ ( counter cnt+50msec )
     50msec waitcnt                                    \ Wait 50msec
     swap                                              \ ( cnt+50msec counter )
     0
 until
              
\ ADC_buf d20 0 do dup W@ . 2+ loop drop
\ current W@ .     st?                
\ fkey? swap drop until
\ 2drop
;

\ ==================================================================
\ Total current
\ ================================================================== 
\ Calculate total current at every 1second
\ ( -- )
: sum_Ampare
4 state andnC! c" RUNNING total-current" cds W!
0 mAs_sum W!
0 mAh_sum W!
0 Ah_sum W!

cnt COG@ clkfreq +
begin
     clkfreq waitcnt
     current W@
     
     mAs_sum W@ + dup d3600 >
     if   
          d3600 - mAs_sum W!
          mAh_sum W@ 1+ dup d1000 >
          if
               drop 1 mAh_sum W!
               Ah_sum W@ 1+ Ah_sum W! 
          else
               mAh_sum W! 
          then
     else
          mAs_sum W!
     then   
              
 0 until

\ mAs_sum W@ .  mAh_sum W@ . Ah_sum W@ . cr                 
\ fkey? swap drop until
\ drop
;

\ ==================================================================
\ OLED_LCD mode
\ ================================================================== 
\ Reverse LCD-up/dn direction on vertical mode
\ ( -- )
: disp_reverse
\ Start I2C 
_eestart
\ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi) 
OLED _eewrite
hA1 command                                  \ Segment remap
hC8 command                                  \ Scan derection remap
\ Stop I2C
_eestop 
err?
;

\ Normal LCD-up/dn direction on vertical mode
\ ( -- )
: disp_normal
\ Start I2C 
_eestart
\ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi) 
OLED _eewrite
hA0 command                                  \ Segment remap
hC0 command                                  \ Scan derection remap
\ Stop I2C
_eestop 
err?
;

\ ==================================================================
\ Switch
\ ================================================================== 
\ Read sw
\ ( -- 0/1/2 )  0:mode sw  1:reverse sw  2:none
: read_sw
mode px? 0=
if
     begin mode px? until          \ Wait switch is  released
     d100 delms
     0                             \ Change mode
else
     reverse px? 0=
     if
          begin mode px? until     \ Wait switch is  released
          d100 delms
          1                        \ Reverse lcd-screen
     else
          2                        \ No sw
thens
;

\ Read sw, change mode or reverse lcd-direction
\ ( -- 1/0 )  1:to next mode  0:reverse lcd-direction
: chk_sw
read_sw
0 over =
if
     \ Next mode
     drop 1                   
else        
     1 =
     if
          up/dn W@
          if
               0 up/dn W!          \ Set LCD to reverse
               \ reverse
               disp_reverse
               disp_OLED_LCD       \ Update LCD
          else
               1 up/dn W!          \ Set LCD to normal
               \ normal
               disp_normal
               disp_OLED_LCD       \ Update LCD
          then
          0
     else
          0     
thens
;     

\ ==================================================================
\ Time
\ ================================================================== 
\ Set x-pos and y-pos at horizontal mode
\ ( n1 n2 -- )  n1:x-pos  n2:y-pos
: xy vidY W! vidX W! ;

\ Set time(Hr,Nin,Sec)
\ ( -- )
: disp_Time d10 u/mod h30 + print h30 + print ;

\ Update time Hr:Min:Sec
\ 00:00:00 - 99:59:59
\ ( -- )
: Time
4 state andnC! c" RUNNING Time" cds W!
0 Sec W! 0 Min W! 0 Hr W!
\ Wait until USB-devices is connected
begin current W@ 5 > until

cnt COG@ clkfreq +
begin
     Sec W@ 1+ dup d60 =
     if      
          \ Update Min
          drop
          0 Sec W!
          Min W@ 1+ dup d60 =
          if
               \ Update Hr
               drop
               0 Min W!
               Hr W@ 1+ dup d100 =
               if
                    drop
                    0 Hr W!
               else
                    Hr W!
               then
          else
               Min W!
          then
     else
          Sec W!
     then
     \ Wait 1second
     clkfreq waitcnt          
0 until
;     

\ Display Time  [Hr:Min:Sec]
\ ( -- )
: Time_line
\ Set pos(0, 0)
0 0 xy
\ Display Hr:Min:Sec                         
Hr W@ disp_Time h3A print          \ Hr: 
Min W@ disp_Time h3A print         \ Hr:Min:
Sec W@ disp_Time                   \ Hr:Min:Sec
;

\ ==================================================================
\ Process for LCD-off
\ ================================================================== 
\ Check if USB-device is disconnected
\ ( -- )
: disconnect?
\ Check if already connected
current W@ 5 < 
if
     connect W@         
     if
          \ Set vertical mode
          vrt set_mode
          0 vidX W!
          c" LCD-OFF " lcd_string
          disp_OLED_LCD
          d3000 delms
          \ Power off OLED_LCD
          power_off
          \ Clear GDDRAM
          clr_mem
          
          \ If mode-sw is pressed during 3seconds, reboot
          \ Only waiting mode-sw
          begin
               mode px? 0=
               if
                    d500 delms mode px? 0=
                    if 
                         reboot    \ Rebooting propforth 
               thens
          0 until
thens
;          

\ ==================================================================
\ main
\ ================================================================== 

\ Display current mode
\ ( -- )
: disp_current
begin
     1 vidX W!                     
     current W@                     
     lcd_decimal_5digit
     disp_OLED_LCD               
     disconnect?
     \ Read switch
     chk_sw                                  
until
;

\ Display voltage mode
\ ( -- )
: disp_volt
begin
     volt W@                    
     3 vidX W!
     d100 u/mod h30 + print
     h2E print                     \ Print out "."
     dup d10 <
     if
          h30 print 
     else
          d10 u/mod h30 + print 
     then
     h30 + print
     disp_OLED_LCD
     disconnect?
     \ Read switch
     chk_sw                                     
until
;


\ Measure USB-current
\ ( -- )
: USB_current
4 state andnC! c" RUNNING USB_Current_Monitor_II" cds W!
\ Initializw variables
0 vidX W!                     \ Set X=0 at vertical mode
0 up/dn W!                    \ LCD Up/Down direction (normal)
1 lcd_update W!               \ Set lcd_update to 1

\ Initialize OLED_LCD on Vertical Addressing Mode
init_oled

\ Write string to vram
c" ------mA" lcd_string
\ Copy vram to GDDRAM
disp_OLED_LCD                         
\ Start ADC
c" ADC" 0 cogx
\ Wait until ADC is ready
begin volt W@ 0 <> until              
\ Start sum_Ampare
c" sum_Ampare" 1 cogx
\ Start time
c" Time" 2 cogx

begin
     \ Set vertical mode
     vrt set_mode
     vrt disp_mode W! 
                                     
     \ --- Display current ---
     0 vidX W!                                      
     c"       mA" lcd_string           
     disp_OLED_LCD
     disp_current     
                                       
     \ --- Display USB voltage ---
     0 vidX W!
     c"        V" lcd_string
     disp_OLED_LCD
     disp_volt
     
     \ When current is 0, Not execute-total current and time-current
     current W@ 0 >
     if
          \ --- Display time and total current ---
               
          hrz set_mode                  \ Set horizontal mode
          hrz disp_mode W!
          clr_vram                      \ Clear vram 
          disp_OLED_LCD                 \ Clear GDDRAM
          
          begin
               \ Time
               Time_line
               \ current
               9 0 xy current W@ lcd_decimal_5digit
               c" mA" lcd_string
               \ mAs
               8 1 xy mAs_sum W@ lcd_decimal_5digit
               c" mAs" lcd_string
               \ mAh
               8 2 xy mAh_sum W@ lcd_decimal_5digit
               c" mAh" lcd_string
               \ Ah
               9 3 xy Ah_sum W@ lcd_decimal_5digit
               c" Ah" lcd_string

               disp_OLED_LCD     
               disconnect?
               \ Read switch
               chk_sw
          until
     then
                                   
 0 until

\ fkey? swap drop until
\ 0 cogreset
\ 1 cogreset
\ 2 cogreset
;

: list_title 
." Current[mA]" 9 emit ." Total Current[mAs]" 9 emit ." Total Current[mAh]" 9 emit ." Total Current[Ah]" cr 
;
\ Monitor current,Total Current[mAs],Total Current[mAh],Total Current[Ah]
\ ( -- )
: monitor
cnt COG@ clkfreq +
list_title
0
begin     
     current W@ . 9 emit 9 emit mAs_sum W@ . 9 emit 9 emit 9 emit  mAh_sum W@ . 9 emit 9 emit 9 emit Ah_sum W@ . cr
     1+ dup d20 = 
     if
          cr
          list_title
          drop 0
     then
     swap
     clkfreq waitcnt
     swap     
     fkey? swap drop
until
2drop
;

\ Display ADC_buf(ring buffer)
\ ( -- )
: disp_ADC_buf
cnt COG@ 50msec +
begin
     ADC_buf 
     d40 0 do
          dup W@ . 2+
     loop
     drop cr
     50msec waitcnt
     fkey? swap drop 
until
drop
;

\ Display i2c_devices
\ No updating lcd during searching i2c_devices
\ ( -- )
: i2c_search 0 lcd_update W! d100 delms i2c_detect 1 lcd_update W! ;

\ Automatic operating at power-on
: onreset3 onreset USB_current ;

