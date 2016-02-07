fl

{
Pressure Sensor (BMP180)
Using i2c_utility_0.4_1.f
      
PropForth 5.5(DevKernel)

2016/02/07 12:47:43

    BMP180 module    Propeller
          Vcc   ----  3.3V
          SCL   ----  SCL
          SDA   ----  SDA
          GND   ----  GND 
}

\ =========================================================================== 
\ Constants 
\ =========================================================================== 
\ Slave addres h77 for BMP180 
hEE wconstant BMP180

\ register
hAA wconstant AC1        \ Top for Calibration registers(eeprom)

hF4 wconstant Control
hF6 wconstant outMsb
hF7 wconstant outLsb
hF8 wconstant outXlsb
hE0 wconstant Reset
hD0 wconstant id

\ bit
h20 wconstant sco
\ oss
0 wconstant oss0
1 wconstant oss1
2 wconstant oss2
3 wconstant oss3
wvariable oss_wait -2 allot 5 c, 8 c, d14 c, d26 c,

: s, parsenw dup C@ 1+ bounds dup rot2 do C@++ c, loop drop ;
wvariable string -2 allot
s, AC1: s, AC2: s, AC3: s, AC4: s, AC5: s, AC6: s, B1: s, B2: s, MB: s, MC: s, MD:

\ =========================================================================== 
\ Variables 
\ =========================================================================== 
\ buffer for coefficients
variable coefficient d40 allot
\ Temperature and Pressure
wvariable UT
wvariable UP
wvariable oss
variable UT
variable UP
variable T
variable X1
variable X2
variable X3
variable B3
variable B4
variable B5
variable B6
variable B7
variable p

\ =========================================================================== 
\ Main 
\ =========================================================================== 
\ Print out string
\ ( n1 n2 -- ) n1:index(0,1,2,..,n) n2:stringarray's address
: dispStr
swap dup 0 <>                 \ Not searching if 0
if
     0 do dup C@ + 1+ loop    \ Search string's top
else
     drop
then
.cstr
;

\ Read chipID
\ ( -- )
: chipID id BMP180 i2c_rd h68 emit hex . decimal cr ;

\ Soft Reset
\ ( -- )
: softReset hB6 Reset BMP180 i2c_wr ;

\ Save coefficients to buffer
\ ( -- )
: saveCoeff
AC1
d11 0 do
     dup
     2 swap BMP180 i2c_rd_multi swap 8 lshift or      
     i 3 5 between 0=
     if
          dup h8000 and            \ Check if negative 
          if hFFFF0000 or then  
     then                   
     coefficient i 4 * + L! 
     2+     
loop
drop
;

: rdCoeff
saveCoeff
coefficient
d11 0 do
     i string dispStr              \ Print coefficient name
     dup i 4 * + L@ . cr           \ Print value
loop
drop
;

\ wait until conversion finish
\ ( -- ) 
: scoCheck begin sco Control BMP180 i2c_rd and 0= until ;

\ Neasure Temperature and Pressure
\ ( n1 -- )  n1:oss
: measure
saveCoeff
oss W!
begin     
     \ Read uncompressed Temperature
     h2E Control BMP180 i2c_wr     \ Start Temp-measurement     
     5 delms                       \ wait
     scoCheck
     2 outMsb BMP180 i2c_rd_multi  \ Get Temperature
     swap 8 lshift or 
     UT W!     
                    UT W@ . 
     \ Read uncompressed Pressure
     oss W@ 6 lshift               \ ( n1<<6 )
     h34 or Control BMP180 i2c_wr  \ Start Pressure-measurement   
     oss_wait oss W@ + C@ delms    \ Wait 
     scoCheck 
     3 outMsb BMP180 i2c_rd_multi  \ Get Pressure ( MSB LSB XLSB )
     swap 8 lshift or swap d16 lshift or     \ ( 24bit )
     8 oss W@ - rshift   
     UP W!                 
                     UP W@ .   9 emit                     
     \ Calculate true Temperature
     \ X1=(UT-AC6)*AC5/32768
     UT W@ coefficient d20 + L@ - coefficient d16 + L@ * d32768 / X1 L!
     \ X2=MC*2048/(X1+MD) 
     coefficient d36 + L@ d2048 * X1 L@ coefficient d40 + L@ + / X2 L!
     \ B5=X1+X2
     X1 L@ X2 L@ + B5 L!
     \ T=(B5+8)/16
     B5 L@ 8 + d16 / T L!
                    T L@ d10 u/mod . h2E emit . ." degree"  9 emit                                
     \ Calculate true Pressure
     \ B6=B5-4000
     B5 L@ d4000 - B6 L!
     \ X1=(B2*(B6*B6/4096))/2048
     coefficient d28 + L@ B6 L@ dup * d4096 / * d2048 / X1 L!
     \ X2=AC2*B6/2048
     coefficient 4+ L@ B6 L@ * d2048 / X2 L!
     \ X3=X1+X2
     X1 L@ X2 L@ + X3 L!
     \ B3=(((AC1*4+X3)<<oss)+2)/4
     coefficient L@ 4 * X3 L@ + oss W@ lshift 2+ 4 / B3 L!
     \ X1=AC3*B6/8192
     coefficient 8 + L@ B6 L@ * d8192 / X1 L!
     \ X2=(B1*(B6*B6/4096))/65536)
     coefficient d24 + L@ B6 L@ dup * d4096 / * d65536 / X2 L!
     \ X3=((X1+X2)+2)/4)
     X1 L@ X2 L@ + 2+ 4 / X3 L!
     \ B4=AC4*(unsigned long)(X3+32768)/32768
     X3 L@ d32768 + dup h80000000 and if -1 * then                           
     coefficient d12 + L@ * d32768 / B4 L!
     \ B7=((unsigned long)UP-B3)*(50000>>oss)
     UP L@ B3 L@ - dup h80000000 and if -1 * then
     d50000 oss W@ rshift * B7 L!
     \ if (B7<80000000){p=(B7*2)/B4}
     \ else {p=(B7/B4)*2}
     B7 L@ h80000000 < 
     if
          B7 L@ 2* B4 L@ / 
     else
          B7 L@ B4 L@ / 2* 
     then
     p L!
     \ X1=(p/256)*(p/256)
     p L@ d256 / dup * X1 L!
     \ X1=(X1*3038)/65536
     X1 L@ d3038 * d65536 / X1 L!
     \ X2=(-7357*p)/65536
     p L@ d-7357 * d65536 / X2 L!
     \ p=p+(X1+X2+3791)/16
     p L@ X1 L@ X2 L@ + d3791 + d16 / + p L!
                    p L@ . ." Pa"
     cr                                           
     fkey? swap drop
until
;



{
\ Calculation for values of BMP180.pdf
\ ( n1 -- ) n1:oss*
: test
\ saveCoeff

d408 coefficient L!
d-72 coefficient 4+ L!
d-14383 coefficient 8 + L!
d32741 coefficient d12 + L!
d32757 coefficient d16 + L!
d23153 coefficient d20 + L!
d6190 coefficient d24 + L!
4 coefficient d28 + L!
d-32768 coefficient d32 + L!
d-8711 coefficient d36 + L!
d2868 coefficient d40 + L!

\ begin
     oss W!
     \ Read uncompressed Temperature
     h2E Control BMP180 i2c_wr     \ Start Temp-measurement     
     5 delms                       \ wait
     2 outMsb BMP180 i2c_rd_multi  \ Get Temperature
     swap 8 lshift or 
     UT W!        d27898 UT W!   UT W@ . 
     \ Read uncompressed Pressure
     oss W@ 6 lshift               \ ( n1<<6 )
     h34 or Control BMP180 i2c_wr  \ Start Pressure-measurement   
     oss_wait oss W@ + C@ delms    \ Wait  
     3 outMsb BMP180 i2c_rd_multi  \ Get Pressure ( MSB LSB XLSB )
     swap 8 lshift or swap d16 lshift or     \ ( 24bit )
     8 oss W@ - rshift   
     UP W!      d23843 UP W!  UP W@ .   cr              
                                           
     \ Calculate true Temperature
     \ X1=(UT-AC6)*AC5/32768
     UT W@ coefficient d20 + L@ - coefficient d16 + L@ * d32768 / dup . cr  X1 L!
     \ X2=MC*2048/(X1+MD) 
     coefficient d36 + L@ d2048 * X1 L@ coefficient d40 + L@ + / dup . cr X2 L!
     \ B5=X1+X2
     X1 L@ X2 L@ + dup . cr B5 L!
     \ T=(B5+8)/16
     B5 L@ 8 + d16 / dup . cr T L!    
                                           
     \ Calculate true Pressure
     \ B6=B5-4000
     B5 L@ d4000 - dup . cr B6 L!
     \ X1=(B2*(B6*B6/4096))/2048
     coefficient d28 + L@ B6 L@ dup * d4096 / * d2048 / dup . cr X1 L!
     \ X2=AC2*B6/2048
     coefficient 4+ L@ B6 L@ * d2048 / dup . cr X2 L!
     \ X3=X1+X2
     X1 L@ X2 L@ + dup . cr X3 L!
     \ B3=(((AC1*4+X3)<<oss)+2)/4
     coefficient L@ 4 * X3 L@ + oss W@ lshift 2+ 4 / dup . cr B3 L!
     \ X1=AC3*B6/8192
     coefficient 8 + L@ B6 L@ * d8192 / dup . cr X1 L!
     \ X2=(B1*(B6*B6/4096))/65536)
     coefficient d24 + L@ B6 L@ dup * d4096 / * d65536 / dup . cr X2 L!
     \ X3=((X1+X2)+2)/4)
     X1 L@ X2 L@ + 2+ 4 / dup . cr X3 L!
     \ B4=AC4*(unsigned long)(X3+32768)/32768
     X3 L@ d32768 + dup h80000000 and if -1 * then                           
     coefficient d12 + L@ * d32768 / dup . cr B4 L!
     \ B7=((unsigned long)UP-B3)*(50000>>oss)
     UP L@ B3 L@ - dup h80000000 and if -1 * then
     d50000 oss W@ rshift * dup . cr B7 L!
     \ if (B7<80000000)(p=(B7*2)/B4)
     \ else (p=(B7/B4)*2)
     B7 L@ h80000000 < 
     if
          B7 L@ 2* B4 L@ / 
     else
          B7 L@ B4 L@ / 2* 
     then
     dup . cr p L!
     \ X1=(p/256)*(p/256)
     p L@ d256 / dup * dup . cr X1 L!
     \ X1=(X1*3038)/65536
     X1 L@ d3038 * d65536 / dup . cr X1 L!
     \ X2=(-7357*p)/65536
     p L@ d-7357 * d65536 / dup . cr X2 L!
     \ p=p+(X1+X2+3791)/16
     p L@ X1 L@ X2 L@ + d3791 + d16 / + dup . cr p L!
     cr                                           
\     fkey? swap drop
\ until     
;
}

