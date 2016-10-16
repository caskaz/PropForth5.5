fl

{                       
PropForth 5.5(DevKernel)

Adafruit 16X32 Matrix
2016/10/13 14:40:51


   Adafruit 16X32 Matrix    [ C B A ]
 -------------------------
| b31   ......         b0 | [ 0 0 0 ]      
| upper matrix(8x32)      |    ...        upper matrix(8x32) color[ B1 G1 R1 ]
|                         | [ 1 1 1 ]
|-------------------------|
| b31   ......         b0 | [ 0 0 0 ]     
| lower matrix(8x32)      |    ...        lower matrix(8x32) color[ B2 G2 R2 ]
|                         | [ 1 1 1 ]
 -------------------------
 ^                      ^
output signal side      Input signal side
(LED Matrux side)       (LED Matrux side)



Dot buffer   32Long X 8 = 1024bytes 1dot=4bytes(32bit)
Using free area( here W@) as matrix buffer
     -------------------------
0   | b31    ......        b0 | <-- 128bytes     
..  | upper matrix(8x32)      |   
7   |                         | 
    |-------------------------|
8   | b31   ......         b0 |     
..  | lower matrix(8x32)      | 
15  |                         | 
     -------------------------
     (LED Matrux side)
     
Pulled down[10kohm] from P0 to P5[R1 G1 B1 R2 G2 B2] because of preventing LED-on when 5V power-on     
}


\ Display characters(8x8) [only upper plane]
\ ( -- )
: demo1
prepMatrix
c" scanMatrix" 0 cogx
1 color0 W!
Font 
begin
     8 0 do
          \ upper section
          dup                           \ ( addr addr )
          C@                            \ ( addr value )
          1                             \ ( addr value 1 )
          8 0 do               
               \ Save b0 value of each line
               2dup and                 \ ( addr value 1 1/0 )
               if color0 W@ else 0 then    \ ( addr value 1 color0/0 )
               here W@
               i d128 u* +
               array31 +
               dup                      \ ( addr value 1 color0/0 [address of b0] [address of b0] )
               L@ upper_m and rot       \ ( addr value 1 [address of b0] [masked value of b0] color0/0 )
               R1 lshift or swap        \ ( addr value 1 [value of b0] [address of b0] )
               L!                       \ ( addr value 1 )                 
               1 lshift
               4 delms
          loop                          \ ( addr value h100 )
          here W@ shift_bit             \ Shift b30-b0 of upper section to 1bit left    
          2drop                         \ ( addr )
          1+ dup
          Font_end = if drop Font then
     loop
     color0 W@ 1+ dup 8 = if drop 1 then color0 W! 
     fkey? swap drop
until
drop
clrMatrix
0 cogreset
;

\ Display characters(8x8) [upper and lower plane]
\ ( -- )
: demo2
prepMatrix
c" scanMatrix" 0 cogx
1 color0 W!
Font 
begin
     8 0 do                             \ 8x8 font
          \ upper section
          dup                           \ ( addr addr )
          C@                            \ ( addr value )
          1                             \ ( addr value 1 )
          8 0 do                        \ 1st line to 8th line
               \ Save bit[0-7] value of each line
               2dup and                 \ ( addr value 1 1/0 )
               if color0 W@ else 0 then    \ ( addr value 1 color0/0 )   Selection color
               here W@
               i d128 u* +
               array31 +                \ ( addr value 1 color0/0 [address of b0] )
               swap dup R2 lshift     
               swap R1 lshift or        \ ( addr value 1 [address of b0] [colors for upper and lower] )
               over L@ plane_m and or   \ ( addr value 1 [address of b0] [content of b0] )
               swap L!                  \ ( addr value 1 )
               1 lshift
               4 delms
          loop                          \ ( addr value h100 )
          here W@ shift_bit             \ Shift b30-b0 of upper section to 1bit left    
          2drop                         \ ( addr )
          1+ dup
          Font_end = if drop Font then                                                                             
     loop
     color0 W@ 1+ dup 8 = if drop 1 then color0 W!      \ next color 
     fkey? swap drop
until
drop
clrMatrix
0 cogreset
;

\ Display characters(8x8) [upper and lower plane]
\ Moving to left 1char by 1char on upper and lower plane
\ ( -- )
: demo3
prepMatrix
c" scanMatrix" 0 cogx
1 color0 W! 1 color1 W!
Font Font                               \ ( lower-Font upper-Font )
begin
     \ upper side
     8 0 do                             \ 8x8 font
          \ upper section
          dup                           \ ( lower-Font upper-Font addr )
          C@                            \ ( lower-Font upper-Font value )
          1                             \ ( lower-Font upper-Font value 1 )
          8 0 do                        \ 1st line to 8th line
               \ Save bit[0-7] value of each line
               2dup and                 \ ( lower-Font upper-Font value 1 1/0 )
               if color0 W@ else 0 then    \ ( lower-Font upper-Font value 1 color0/0 )   Selection color
               here W@
               i d128 u* +
               array31 +                \ ( lower-Font upper-Font value 1 color0/0 [address of b0] )
               swap over                \ ( lower-Font upper-Font value 1 [address of b0] color0/0 [address of b0] )
               L@ upper_m and or        \ ( lower-Font upper-Font value 1 [address of b0] [content of b0] )
               swap L!                  \ ( lower-Font upper-Font value 1 )
               1 lshift
          loop                          \ ( lower-Font upper-Font value h100 )
          here W@ shift_bit             \ Shift b30-b0 of upper section to 1bit left    
          2drop                         \ ( lower-Font upper-Font )
          1+ dup
          Font_end = if drop Font then                                                                             
     loop
     color0 W@ 1+ dup 8 = if drop 1 then color0 W!      \ next color 
                                                                \    d1000 delms
     \ lower side
     swap                               \ ( upper-Font lower-Font )
     8 0 do                             \ 8x8 font
          \ lower section
          dup                           \ ( upper-Font lower-Font addr )
          C@                            \ ( upper-Font lower-Font value )
          1                             \ ( upper-Font lower-Font value 1 )
          8 0 do                        \ 1st line to 8th line
               \ Save bit[0-7] value of each line
               2dup and                 \ ( upper-Font lower-Font value 1 1/0 )
               if color1 W@ else 0 then    \ ( addr value 1 color1/0 )   Selection color
               here W@ d1024 +
               i d128 u* +
               array31 +                \ ( upper-Font lower-Font value 1 color1/0 [address of b0] )
               swap over L@ lower_m and
               swap R2 lshift
               or                       \ ( upper-Font lower-Font value 1 [address of b0] [content of b0] )
               swap L!                  \ ( upper-Font lower-Font value 1 )
               1 lshift
          loop                          \ ( upper-Font lower-Font value h100 )
          here W@ d1024 + shift_bit     \ Shift b30-b0 of upper section to 1bit left    
          2drop                         \ ( upper-Font lower-Font )
          1+ dup                                                                   
          Font_end = if drop Font then                                                                             
     loop
     color1 W@ 1+ dup 8 = if drop 1 then color1 W!      \ next color 
     swap                               \ ( lower-Font upper-Font )
     fkey? swap drop                     
until                                     
2drop
clrMatrix
0 cogreset                         
;
