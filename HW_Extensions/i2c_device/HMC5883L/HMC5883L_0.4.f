fl

{
PropForth 5.5(DevKernel)

3-axis digital compass HMC5883L-module driver 
Using i2c_utility_0.4_1.f   
2016/03/10 21:01:25

HMC5883L module      Propeller
       1 VDD    ----  3.3V
       2 VDDIO  ----  3.3V
       3 GND    ----  GND
       4 GND    ----  GND
       5 DRDY   ----  
       6 SDA    ----  P29   
       7 SCL    ----  P28   
       8 VDD    ----  3.3V

}

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
\ Slave addres[h1E] for HMC5883L
h3C wconstant HMC5883L

\ register name
0 wconstant ConfigA
1 wconstant ConfigB
2 wconstant Mode
3 wconstant Data
9 wconstant Status
d10 wconstant RegA

0 wconstant Cont
1 wconstant Single
2 wconstant Idle

\ =========================================================================== 
\ Main
\ =========================================================================== 

\ Communication test
\ Communication is ok when displayed "H43"
\ ( -- )
: Test 3 RegA HMC5883L i2c_rd_multi ." data(H43)=" rot emit swap emit emit cr ;

\ Display all register's value
\ ( -- ) 
: disp_reg
." Address  " ." value(hex)" cr
d13 0 do
     4 spaces
     i .                                \ Display register address
     9 emit 9 emit
     1 i HMC5883L i2c_rd_multi          \ Read value
     hex .byte decimal                  \ Display register value
     cr
loop
;


\ Convert 2's complement form(16bit) to 32bit
\ None if positive
\ ( n1 -- n2 ) n1:2's complement form(16bit)  n2:32bit
: conv_32 dup hF000 and if hFFFF0000 or then ;

\
\
: conv_data
\ Data Y
swap 8 lshift or         
conv_32                  \ Convert to 32bit if minus
>r                       \ Push Y
\ Data Z
swap 8 lshift or                    
conv_32                  \ Convert to 32bit if minus   
\ Data X
rot2 swap 8 lshift or                   
conv_32                  \ Convert to 32bit if minus   
r>                       \ Pop Y
swap                     \ ( Z Y X )

;
     
\ Start continuous meauremaent
\ ( -- )      
: contMeasure
Cont 1 Mode HMC5883L i2c_wr_multi       \ Set continuous mode
begin
     \ Wait until ready
     begin
          1 Status HMC5883L i2c_rd_multi 
          1 and 
     until
     \ Read out 6bytes
     6 Data HMC5883L i2c_rd_multi  
     conv_data    
     ." X=" . ." Y=" . ." Z=" .
     cr
     fkey? swap drop
until
;

