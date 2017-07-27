fl

{
PropForth5.5(DevKernel)
2017/07/27 10:12:31

Light sensor

P0 ---220ohm ----------
                |      |
                |      |
               0/01uF  C PhotTransistor
                |      E  
                |      |
               GND    GND
                
}

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
0 wconstant LS
1 LS lshift constant mLS
d80 wconstant 1us
h1F8 wconstant ctra
h1FA wconstant frqa
h1FC wconstant phsa

\ =========================================================================== 
\ Main 
\ =========================================================================== 
\ Counting phsa
\ ( -- n1 )  n1:phsa value
: count
dira COG@ mLS or dira COG!         \ Set pin to output
1 drop                             \ Wait charging
0 phsa COG!                        \ Clear phsa
mLS invert dira COG@ and dira COG! \ Set pin to input
d100 delms                         \ Wait discharging
phsa COG@
;

\ Test phsa value
\ ( -- )
: test
h20000000 LS or ctra COG!          \ POS detector mode
1 frqa COG!
outa COG@ mLS or outa COG!         \ Set pin-outport to 1
begin
     count . cr
     fkey? swap drop
until
;

\ Print light-sensor graph
\ ( -- )     
: demo
h20000000 LS or ctra COG!          \ POS detector mode
1 frqa COG!
outa COG@ mLS or outa COG!         \ Set pin-outport to 1
begin
     count
     d40000 / spaces h2A emit cr
     fkey? swap drop
until
;
