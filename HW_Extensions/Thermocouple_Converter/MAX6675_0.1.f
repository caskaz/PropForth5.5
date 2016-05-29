{                       
PropForth 5.5(DevKernel)

K-Thermocouple Converter Module(MAX6675)
 
2016/05/29 10:29:41

Franklin Lightning Sensor Module       Propeller
                   (AE-AS3935)
                         SCK     ------  P4
                         CS      ------  P5
                         SO      ------  P6
                         Vcc     ------ 3.3V
                         GND     ------ GND
                         T+      ------ Thermocouple sensor+
                  GND -- T-      ------ Thermocouple sensor-
}

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
4 wconstant sck
5 wconstant cs
6 wconstant so
so >m constant som
4 wconstant sensor_open

\ =========================================================================== 
\ Variables 
\ =========================================================================== 

\ =========================================================================== 
\ Main 
\ =========================================================================== 
\ Display temperature(Using Forth word)
\ ( -- )
: demo1
\ Initialize port
cs pinhi sck pinout cs pinout

begin
     cs pinlo
     0
     d16 0 do
          1 lshift
          sck pinhi 
          ina COG@ som and
          sck pinlo
          if 1 or then       
     loop                          
     dup sensor_open and
     if
          ." sensor open error" cr
          drop
     else
          3 rshift
          d25 * d100 u/mod . h2E emit .
          ." degreeC" cr
     then
     cs pinhi
     d220 delms
     fkey? swap drop
until
;

\ Get teperature data[16bit]
\ ( n1 -- n2 )  n1:top pin  n2:received data[16bit]
lockdict create a_getTemp forthentry
$C_a_lxasm w, h12F  h113  1- tuck - h9 lshift or here W@ alignl h10 lshift or l,
z2Wy\W1 l, zfi\ZB l, z20yPO1 l, z2Wy\b1 l, zfi\eB l, z20yPO1 l, z2Wy\j1 l, zfi\mB l,
z2WyPO0 l, z2WyPWG l, z1[ix[g l, 0 l, 0 l, z1bix[f l, 0 l, zfyPO1 l,
z1YF\ql l, z1boPO1 l, z1[ix[f l, 0 l, z3[yP[W l, z1bix[g l, 0 l, 0 l,
z1SV01X l, 0 l, 0 l, 0 l,
freedict

\ Display temperature(Using Assembler word)
\ ( -- )
: demo2
\ Initialize port
cs pinhi sck pinout cs pinout

begin
     sck a_getTemp              
     dup sensor_open and
     if
          ." sensor open error" cr
          drop
     else
          3 rshift
          d25 * d100 u/mod . h2E emit .
          ." degreeC" cr
     then
     d220 delms
     fkey? swap drop
until
;

{
\ Get teperature data[16bit]
\ ( n1 -- n2 )  n1:top pin  n2:received data[16bit]
\ $C_treg1 -- loop counter
fl
build_BootOpt :rasm
          \ Get sck mask
          mov       __sck , # 1
          shl       __sck , $C_stTOS
          add       $C_stTOS , # 1
          \ Get cs mask
          mov       __cs , # 1
          shl       __cs , $C_stTOS
          add       $C_stTOS , # 1
          \ Get so mask
          mov       __so , # 1
          shl       __so , $C_stTOS
          mov       $C_stTOS , # 0
          
          mov       $C_treg1 , # d16
          \ Set cs to Lo
          andn      outa , __cs
          nop
          nop
          
          \ Get 16bit
__1  
          \ Output sck
          or        outa , __sck
          nop
          \ Get 1bit
          shl       $C_stTOS , # 1
          test      __so , ina	wz
if_nz     or        $C_stTOS , # 1
          andn      outa , __sck
          nop
          djnz      $C_treg1 , # __1        
     
          \ Set cs to Hi
          or        outa , __cs
          nop
          nop
          jexit
          
__sck
     0
__cs  
     0
__so
     0
        
;asm a_getTemp

}
