fl

{                       
PropForth 5.5(DevKernel)

TouchSensor(RH6010)
Using i2c_utility_0.4.1.f 
2016/04/09 11:29:52

touch sensor-module   Propeller
       VDD    ----  3.3V
       GND    ----  GND
       INT      
       SCL    ----  P28   
       SDA    ----  P29   

https://youtu.be/4VvR8k8k8Z0


Only R9 is shorted in my trial.
But it might be good that all resistor[R3..R10] are shorted.

--- CAUTION -------------------------------------------------------------------------------
When connecting to TeraTerm, PF5.5Kernel don't reply prompt under connecting RH6010's scl.
After PF5.5Kernel replying, RH6010's scl need to connect.
When rebooting under connecting RH6010's scl, PF5.5Kernel don't reply reboot-messages.
It need to push reset-sw after removing RH6010's scl.
TeraTerm also reboot.
I have no idea. 
-------------------------------------------------------------------------------------------

}

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
\ Slave addres h78 for RH6010
hF0 wconstant RH6010

\ register name
0 wconstant Config1      \ Sensivity:[b4..b0]
1 wconstant Config2
2 wconstant Key
\ register          Key7 Key6 Key5 Key4 Key3 Key2 Key1 Key0
\ Chip Terminal      TP7  TP6  TP5  TP4  TP3  TP2  TP1  TP0

\ 7SegLED data
variable 7SEG -4 allot
0 c, 6 c, h5B c, h4F c, h66 c, h6D c, h7C c, 7 c, h7F c,

\ =========================================================================== 
\ Main 
\ =========================================================================== 
\ Setup RH6010
\ ( -- )
: initRH6010
h66 Config1 RH6010 std_i2c_wr 
d100 delms
hF5 Config2 RH6010 std_i2c_wr 
d100 delms
;

\ Display register2
\ ( -- )
: demo1
initRH6010
hex 
begin
     Key RH6010 std_i2c_rd 
     . cr
     d100 delms
     fkey? swap drop
until
decimal
;

\ case statement
\ ( n1 n2 -- n1 t/f )  n1:number n2:number t/f:true if n1=n2
: case over = ;

\ Add 7Seg-LED data
\ ( -- )
: 7Seg_out 7SEG + C@ outa COG@ or outa COG! ;
 
{
Display touched sensor-pad to 7Segment-LED(GL-8R04:Cathode common)
Prop     GL-8R04
P0-------a[1]
P1-------b[13]
P2-------c[10]
P3-------d[8]
P4-------e[7]
P5-------f[2]
P6-------g12]
GND------COM

Touchpad on Board surface
 ----------------------
|K2  | K1  | K8  | K7  |
|bit2| bit3| bit4| bit5|
 ----------------------
|K3  | K4  | K5  | K6  |
|bit1| bit0| bit7| bit6|
 ----------------------
}
\ ( -- )
: demo2
initRH6010
h7F dira COG!

begin
     Key RH6010 std_i2c_rd 
     1 case
     if
          7 7Seg_out
     else
     2 case
     if
          8 7Seg_out
     else
     4 case
     if
          4 7Seg_out
     else
     8 case
     if
          3 7Seg_out
     else
     h10 case
     if
          2 7Seg_out
     else
     h20 case
     if
          1 7Seg_out
     else
     h40 case
     if
          5 7Seg_out
     else
     h80 case
     if
          6 7Seg_out
     else
          outa COG@ hFFFFFF80 and outa COG!
     thens
     drop              
     d100 delms
     fkey? swap drop
until
;
