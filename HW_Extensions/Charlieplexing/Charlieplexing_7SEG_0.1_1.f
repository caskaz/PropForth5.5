fl                                                               fl

{
Drived on 9-lines for 7Segment LED(8pcs) by Charlieplexing
2014/11/09 19:24:59

              
  Propeller
       P0 - 100ohm  -- d0
       P1 - 100ohm  -- d1
       P2 - 100ohm  -- d2
       P3 - 100ohm  -- d3
       P4 - 100ohm  -- d4
       P5 - 100ohm  -- d5
       P6 - 100ohm  -- d6
       P7 - 100ohm  -- d7
       P8 - 100ohm  -- d8


             7SEG-LED(Anode common)
              digit1(Lower)   outa=1
       d0  -- COM
       d1  -- a
       d2  -- b
       d3  -- c
       d4  -- d
       d5  -- e
       d6  -- f
       d7  -- g
       d8  -- dp

              digit2  outa=h80
       d7  -- COM
       d0  -- a
       d1  -- b
       d2  -- c
       d3  -- d
       d4  -- e
       d5  -- f
       d6  -- g
       d8  -- dp

              digit3  outa=h40
       d6  -- COM
       d7  -- a
       d0  -- b
       d1  -- c
       d2  -- d
       d3  -- e
       d4  -- f
       d5  -- g
       d8  -- dp

              digit4  outa=h20
       d5  -- COM
       d6  -- a
       d7  -- b
       d0  -- c
       d1  -- d
       d2  -- e
       d3  -- f
       d4  -- g
       d8  -- dp

              digit5 outa=h10
       d4  -- COM
       d5  -- a
       d6  -- b
       d7  -- c
       d0  -- d
       d1  -- e
       d2  -- f
       d3  -- g
       d8  -- dp

              digit6  outa=8
       d3  -- COM
       d4  -- a
       d5  -- b
       d6  -- c
       d7  -- d
       d0  -- e
       d1  -- f
       d2  -- g
       d8  -- dp

              digit7  outa=4
       d2  -- COM
       d3  -- a
       d4  -- b
       d5  -- c
       d6  -- d
       d7  -- e
       d0  -- f
       d1  -- g
       d8  -- dp

              digit8(Upper)  outa=2
       d1  -- COM
       d2  -- a
       d3  -- b
       d4  -- c
       d5  -- d
       d6  -- e
       d7  -- f
       d0  -- g
       d8  -- dp


}

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
\ Writing data to dira
wvariable digit -2 allot
h7F c, h0D c, hB7 c, h9F c, hCD c, hDB c, hFB c, h0F c, hFF c, hDF c, 
\ 7SEG-fint for digit2
hBF c, h86 c, hDB c, hCF c, hE6 c, hED c, hFD c, h87 c, hFF c, hEF c, 
\ 7SEG-fint for digit3
hDF c, h43 c, hED c, hE7 c, h73 c, hF6 c, hFE c, hC3 c, hFF c, hF7 c, 
\ 7SEG-fint for digit4
hEF c, hA1 c, hF6 c, hF3 c, hB9 c, h7B c, h7F c, hE1 c, hFF c, hFB c, 
\ 7SEG-fint for digit5
hF7 c, hD0 c, h7B c, hF9 c, hDC c, hBD c, hBF c, hF0 c, hFF c, hFD c, 
\ 7SEG-fint for digit6
hFB c, h68 c, hBD c, hFC c, h6E c, hDE c, hDF c, h78 c, hFF c, hFE c, 
\ 7SEG-fint for digit7
hFD c, h34 c, hDE c, h7E c, h37 c, h6F c, hEF c, h3C c, hFF c, h7F c, 
\ 7SEG-fint for digit8
hFE c, h1A c, h6F c, h3F c, h9B c, hB7 c, hF7 c, h1E c, hFF c, hBF c, 

\ =========================================================================== 
\ Variables 
\ =========================================================================== 
\ Buffer for 8-digits 7SEG-LEDs
variable 7SEG 4 allot 

\ =========================================================================== 
\ Main 
\ =========================================================================== 

\ Driver for 8-digits 7SEG-LEDs by Charlieplexing
\ ( -- )
: drive_7SEG
0 dira COG!
begin
     7SEG 1
     8 0 do
          2dup                \ ( 7SEG 1 7SEG 1 )
          0 dira COG!         \ Clear dira
          outa COG!           \ ( 7SEG 1 7SEG )
          C@ digit i d10 u* + + 
          C@                  \ Get 7SEG-font
          dira COG!           \ ( 7SEG 1 )
          i 0=
          if
               drop h80       \ Place h80 when digit1
          else
               1 rshift
          then
          swap 1+ swap
     loop     
     2drop
     fkey? swap drop
until
;

\ Test each 7SEG-LED
\ ( -- )
: check_7SEG
0 7SEG L!
0 7SEG 4+ L!
c" drive_7SEG" 0 cogx 
8 0 do
     d10 0 do i 7SEG j + C! d500 delms loop 
loop
0 cogreset
;
