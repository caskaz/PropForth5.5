fl

{
PropForth 5.5(DevKernel)

I2C characterLCD AQM1602XA-RN-GBW(controller:ST7032i)      
Using i2c_utility_0.4.f   
2015/10/08 13:01:40

characterLCD(ST7032i)  Propeller board
               Vdd  -- 3V3
               SCL  -- P28
               SDA  -- P29
               RST  -- 3V3
               Vss  -- GND
           SlaveAddress  0111_110[R/W]
           ControlByte   [C0][R/S]00_0000
           DataByte      0000_0000    
}


\ =========================================================================== 
\ Constants 
\ =========================================================================== 
\ Slave addres h3E for ST7032i
h7C wconstant ST7032i

h80 wconstant Co    \ Co is added when not last command id sent
h40 wconstant RS    \ RS is added when data is sent

\ =========================================================================== 
\ Variables 
\ =========================================================================== 

wvariable char           \ character number for using LCD [1,2,.. 16]          
wvariable line           \ line number for using LCD  [1,2]
wvariable cur_line       \ current line number  [1,2]

\ Used on word'lcd_dec'
variable tmp
wvariable result     

\ =========================================================================== 
\ Main
\ =========================================================================== 
\ Send command to ST7032i  
\ ( n1 -- n2 )  n:command  n2:t/f  If there is error,true
: lcd_com 
\ Start I2C 
_eestart
\ Slave address
ST7032i _eewrite
\ ControlByte 
0 _eewrite or 
\ DataByte
swap _eewrite or 
\ Stop i2c  
_eestop 
err?          
;

\ Initialize ST7032i
\ ( -- )
: lcd_init
d50 delms
\ Function set   DL:8bit mode N:2-line DH:not double height font IS:normal instruction
h38 lcd_com        
1 delms
\ Function set   DL:8bit mode N:2-line DH:not double height font IS:extent instruction
h39 lcd_com    
1 delms
\ Bias selection/internal OSC frequency adjust  BS:bias=1/5 OSC:183Hz(3V)   
h14 lcd_com    
1 delms
\ Contrast set
h73 lcd_com   
1 delms
\ Power/ICON control ICON:display off Bon:booster on  Contrast HiByte:2
h56 lcd_com
1 delms
\ Follow control Fon:internal foler curcuit on 
h6C lcd_com
d200 delms
\ Function set   DL:8bit mode N:2-line DH:not double height font IS:normal instruction
h38 lcd_com
1 delms
\ Clear display
1 lcd_com
1 delms
\ Display on/off   D:display on C:cursol off B:blinl off
hC lcd_com
1 delms
;

\ Display character  
\ ( c -- )   c:character code     
: lcd_char 
\ Start I2C 
_eestart
\ Slave address
ST7032i _eewrite 
\ ControlByte 
RS _eewrite or 
\ DataByte
swap _eewrite or 
\ Stop i2c  
_eestop 
err? 
;

\ Display string  
\ ( cstr -- )   cstr:string addr
: lcd_str 
C@++                               \ ( c-addr+1 c1 )  c-addr+1: string's first char addr  c1:string length
dup 
if 
     bounds do i C@ lcd_char loop  \ Print string 
else 
     2drop 
then 
;
                                                                           
\ Clear LCD-screen
\ ( -- )
: lcd_clr 
1 lcd_com 
d10 delms                              \ If no wait, next displayment is strange 
;

\ Display Off (not erase display-data)
\ ( -- )
: lcd_off 8 lcd_com ;
                                                              
\ Display On
\ ( -- )
: lcd_on hC lcd_com ;                

\ Adjust contrast
\ ( n1 -- )  n1 contrast[0 to 64]
: contrast
\ Separate highByte and lowByte
dup hFF and swap 4 rshift
\ Function set
h39 lcd_com    
1 delms
\ Set contrast highByte
h54 or lcd_com
1 delms
\ Set contrast lowByte
h70 or lcd_com
1 delms
\ Function set   
h38 lcd_com        
1 delms
;

\ Setup of display construction  
\ ( x y -- )
: lcd_setup line W! char W! ;

\ Display decimal-number from Left
\ d987654321 lcd_dec --> [987654321]
\ d4321 lcd_dec -------> [4321]
\ ( n1 -- )  n1:number
: lcd_dec
0 result W! d1000000000 tmp L!
dup h80000000 and if negate h2D lcd_char then          \ Check if minus and print "-"  
d10 0 do 
     dup tmp L@ >=                                     \ Check if n is bigger than tmp
     if 
          tmp L@ u/mod h30 + lcd_char 1 result W!      \ Print number-char
     else 
          result W@ tmp L@ 1 = or 
          if h30 lcd_char then                         \ Print "0"
     then
     tmp L@ d10 u/ tmp L!                              \ Divide tmp by d10 
loop
drop
;

\ Set position to (x,y)
\ x -- horizontal pos  : 1 to 16Characters
\ y -- line number     : 1 to 2Lines)
\ DDRAM addres of 16X2 CHaracter-LCD
\ 1Line [h00 ------ h0F]
\ 2Line [h40 ------ h4F]
\ ( x y -- )
: lcd_pos
2 / 1 =                  
if h40 + then            \ 2-line 
1-                       \ x-1
h80 or    lcd_com        \ Set DDRAM Addr command 
;

\ Print spaces  
\ ( n -- ) n:space's number printing on LCD 
: lcd_bl dup if 0 do bl lcd_char loop else drop then ;

\ Display binary number 
\ (n1 n2 -- ) n1:decimal number  n2:digits(1 to d16) 
: lcd_bin
dup rot2 h20 swap - lshift swap  
0 do 
     dup h80000000 and 
     if h31 else h30 then      
     lcd_char                 \ Print "1" or "0"
     1 lshift 
loop 
drop
;

\ Print cr
\ ( -- )
: lcd_cr 
cur_line W@ 1+ dup line W@ >            \ Check if current_line+1 is bigger than using LCD-line 
if 
     drop 1 1 lcd_pos 1 cur_line W!     \ Move to lcd's up-left
else 
     dup 1 swap lcd_pos cur_line W!     \ Move to lower line
then 
;

\ Display hex-number from Left
\ d255 4 lcd_hex   --> [00FF]
\ d65535 8 lcd_hex --> [0000FFFF]
\ -1 8 lcd_hex     --> [FFFFFFFF]
\ ( n1 n2 -- )  n1:decimal number  n2:digit[1 to 8]
: lcd_hex
dup rot2 8 swap - 2 lshift lshift swap
0 do 
     dup hF0000000 and d28 rshift dup d10 < 
     if 
          h30 +                              \ 0,1,2,3,4,5,6,7,8,9 
     else 
          h37 +                              \ A,B,C,D,E,F
     then 
     lcd_char 
     4 lshift 
loop
drop
;

\ Set bar_graph_font(horizontal) to CG-RAM
\ ( -- )
: set_bar_graph
h20 h40
6 0 do                                  \ set 6 charcters
     8 0 do                             \ set 8 lines for 1 character
          dup lcd_com                   \ command for character to CG-RAM
          swap dup lcd_char swap        \ write data
          1+    
     loop
     hF8 and   
     swap dup 1 rshift or swap
loop
2drop
;

\ ( -- )
: demo
lcd_init    
\ 16characters 2line
d16 2 lcd_setup                         
1 cur_line W!

\ display char-code [0x0 - 0xFF] 
d16 0 do
     d16 0 do
          i 1+ cur_line W@ lcd_pos    \ Set position
          j d16 * i + lcd_char     \ Write char-code
          d100 delms
     loop
     cur_line W@ 1+ dup line W@ > if drop 1 then cur_line W!       
loop

lcd_clr
1 cur_line W! 
\ display binary, hex, decimal
c" 0x1+0x6 = b" lcd_str 1 6 + 4 lcd_bin

1 2 lcd_pos       
c" 0xACE+0xF=0x" lcd_str hACE hF + 4 lcd_hex

lcd_cr
c" 0x0-0x12=" lcd_str
0 h12 - lcd_dec c" (D) " lcd_str
d3000 delms 

lcd_clr 
d-987654321 lcd_dec
d3000 delms 

\ Contrast
lcd_clr
c" PropForth5.5" lcd_str
d64 d20 do i contrast d300 delms loop
d32 contrast

lcd_clr
\ Function set
h3D lcd_com    
1 delms
c" PropForth5.5" lcd_str
d3000 delms
\ Function set
h38 lcd_com    
1 delms

\ Bar graph
set_bar_graph
lcd_clr  1 cur_line W!                                            
c" Bar Graph" lcd_str 
1    \ x-position 
char W@ 0
do 
     0 
     6 0 do 
          dup lcd_char                  \ Print bar_graph character
           1+ d100 delms  
           swap dup 2 lcd_pos swap      \ Set same x-position                 
     loop 
     drop
     1+ dup 2 lcd_pos                   \ Increment x-position 
loop
drop


char W@ 2 lcd_pos
char W@
char W@ 0
do
     5
     6 0 do 
          dup lcd_char                  \ Print bar_graph character 
          1- d100 delms  
          swap dup 2 lcd_pos swap       \ Set same x-positionap 
     loop 
     drop
     1- dup 2 lcd_pos                   \ Decrement x-position
loop
drop

lcd_clr                                                        
c" Demo Finished" lcd_str
;
