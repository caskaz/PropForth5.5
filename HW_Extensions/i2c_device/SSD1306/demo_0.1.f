fl

{
PropForth 5.5(DevKernel)

128x32dots OLED LCD Controller SSD1306
Using i2c_utility_0.4.2.f   
2016/08/11 9:05:22

OLED display(128X32)   Propeller
           VDD    ----  3.3V
           GND    ----  GND
           RES    ----  P4      
           SCL    ----  P28   
           SDA    ----  P29   
}



\ Display 8x8Fonts without vram
\ ( -- )
: demo1
init_oled
clr_mem
hrz set_mode        \ Horizontal mode
_eestart
\ Write slave address[wr], then receive Acknowledge-bit(ACK:Lo  NACK:Hi) 
OLED _eewrite                                         
1 controlbyte or
Font
\ 96 characters
d96 0 do
     \ 1 character
     8 0 do
          dup
          C@ _eewrite rot or swap
          1+
     loop
     d100 delms
loop
drop
\ Stop I2C
_eestop 
err?
;

\ Display 8x8Fonts
\ ( -- )
: demo2
init_oled
hrz set_mode        \ Horizontal mode
clr_vram            \ Clear vram
disp_OLED_LCD       \ Copy vram to GDDRAM

0 vidX W! 0 vidY W!
d15 max_vidX W!
\ 96 characters
h20
d96 0 do
     dup     
     print               \ Print character
     1+                  \ Increment character code
     disp_OLED_LCD
loop
drop
c" PropForth5.5    " lcd_string
disp_OLED_LCD
disp_reverse
d3000 delms
disp_OLED_LCD
d3000 delms
disp_normal
d3000 delms
disp_OLED_LCD
;

\ Display PropROM Fonts
\ ( -- )
: demo3
init_oled
vrt set_mode        \ Horizontal mode
clr_vram            \ Clear vram
disp_OLED_LCD       \ Copy vram to GDDRAM

7 max_vidX W!
0 vidX W! 
\ 512 characters
0
d256 0 do
     dup     
     print               \ Print character
     1+                  \ Increment character code
     disp_OLED_LCD
loop
drop
clr_vram 0 vidX W! 
c" Forth" lcd_string
disp_OLED_LCD
disp_reverse
d2000 delms
disp_OLED_LCD
d2000 delms
disp_normal
d2000 delms
disp_OLED_LCD
;

: demo4
demo2
scroll_H 
demo3
scroll_VH 
0 Blink
d5000 delms
dis_Fade/Blink
1 FadeOut
d5000 delms
dis_Fade/Blink
;
