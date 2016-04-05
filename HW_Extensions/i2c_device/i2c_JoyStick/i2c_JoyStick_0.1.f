fl

{                       
PropForth 5.5(DevKernel)

i2c_JoyStick by PCF8591
Using i2c_utility_0.4.1.f 
PCF8591_0.3.f
2016/04/05 9:41:37

        PCF8591                           Propeller
          AN0   ------- JoyStick Y-axis
          AN1   ------- JoyStick X-axis
          AN2   
          AN3   
          A0    ------- GND
          A1    ------- GND
          A2    ------- GND
          SDA   ------------------------  SDA
          SCL   ------------------------  SCL
          OSC   
          EXT   ------- GND (Selected internal OSC)
          AGND  ------- GND
          VREF  ------- 3.3V
          AOUT  
          VDD   ------- 3.3V
}

\ =========================================================================== 
\ Main 
\ =========================================================================== 

: JoyStick_demo 
." X" 9 emit ." Y" cr
begin
     0 h44 PCF8591 std_i2c_wr      \ Write contril byte
     3 PCF8591_rd                  \ Get A/D-value 
     . 9 emit . cr drop            \ drop previous A/D-value
     d200 delms
     fkey? swap drop
until
;
