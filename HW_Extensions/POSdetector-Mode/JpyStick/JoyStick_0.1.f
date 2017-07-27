fl

{
PropForth5.5(DevKernel)
2017/07/27 13:07:24

JoyStick
                    P1(Y) VRx
                    ^
                    |   JoyStick board
          ---------------------
         |                     |
         |          |          |             
         |          |          |             
         |          |          |             
         | ---------|--------- |---> P0(X) VRy            
         |          |          |             
         |          |          |             
         |          |          |             
         |   GND   VRx VRy     |
          ---------------------
              |  |  |  |  |
             GND    P1 P0

P0 -----------------------
        |    open        |
        |     |          |
         ---->VRy(10k) Capacitance(0.01uF)
              |          |
             GND        GND
             
P1 -----------------------
        |    open        |
        |     |          |
         ---->VRx(10k)  Capacitance(0.01uF)
              |          |
             GND        GND
               
                
}

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
1 wconstant VRx
1 VRx lshift constant mVRx
d71000 constant Xmax
0 wconstant VRy
1 VRy lshift constant mVRy
d67100 constant Ymax

h1F8 wconstant ctra
h1F9 wconstant ctrb
h1FA wconstant frqa
h1FB wconstant frqb
h1FC wconstant phsa
h1FD wconstant phsb

\ =========================================================================== 
\ Variables 
\ =========================================================================== 
variable Xcenter
variable Ycenter
wvariable Xdiv
wvariable Ydiv

\ =========================================================================== 
\ Main 
\ =========================================================================== 
: tab 9 emit ;

\ Count PHSA after charging capacitance
\ Ignore phsa-counting until pin is set to input
\ ( -- n1 ) n1:phsa value
: Xcount
dira COG@ mVRy or dira COG!             \ Set pin to output
1 drop                                  \ Wait charging
0 phsa COG!                             \ Clear phsa
mVRy invert dira COG@ and dira COG!     \ Set pin to input
1 delms
phsa COG@
;

\ Count PHSB after charging capacitance
\ Ignore phsb-counting until pin is set to input
\ ( -- n1 ) n1:phsb value
: Ycount
dira COG@ mVRx or dira COG!             \ Set pin to output
1 drop                                  \ Wait charging
0 phsb COG!                             \ Clear phsa
mVRx invert dira COG@ and dira COG!     \ Set pin to input
1 delms
phsb COG@
;

\ Print X,Y(raw value)
\ ( -- )
: test
\ Initialize counter mode
h20000000 VRy or ctra COG!              \ POS detector mode
1 frqa COG!
h20000000 VRx or ctrb COG!              \ POS detector mode
1 frqb COG!
outa COG@ mVRy or mVRx or outa COG!     \ Set -pin-outport to 1
begin
     Xcount . tab
     Ycount . cr
     d100 delms
     fkey? swap drop
until
;


\ Print X,Y
\ ( -- )
: demo
\ Initialize counter mode
h20000000 VRy or ctra COG!              \ POS detector mode
1 frqa COG!
h20000000 VRx or ctrb COG!              \ POS detector mode
1 frqb COG!
outa COG@ mVRy or mVRx or outa COG!     \ Set -pin-outport to 1
\ Measure center value
d100 delms
Xcount Xcenter L! 
Xmax Xcenter L@ - d100 / Xdiv W!
Ycount Ycenter L!
Ymax Ycenter L@ - d100 / Ydiv W!
                                 st?
begin
     Xcount Xcenter L@ - Xdiv W@ / . tab
     Ycount Ycenter L@ - Ydiv W@ / . cr
     d100 delms
     fkey? swap drop
until
;

