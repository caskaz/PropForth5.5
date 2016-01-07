fl

{
PropForth5.5

Search automatically free-cog amd set command
2013/09/29 22:55:15
}

\ **************************
\    variables
\ **************************
variable cogID
variable maskA -4 allot h00FF_FFF0 l, h00FF_FF00 l, h00FF_F000 l, h00FF_0000 l, h00F0_0000 l, h0000_0000 l, 
variable maskB -4 allot h0000_0000 l, h0000_000F l, h0000_00FF l, h0000_0FFF l, h0000_FFFF l, h000F_FFFF l,

: testA 4 state andnC! c" RUNNING TEST-A" cds W! begin 0 until ;
: testB 4 state andnC! c" RUNNING TEST-B" cds W! begin 0 until ;
: testC 4 state andnC! c" RUNNING TEST-C" cds W! begin 0 until ;
: testD 4 state andnC! c" RUNNING TEST-D" cds W! begin 0 until ;
: testE 4 state andnC! c" RUNNING TEST-E" cds W! begin 0 until ;
: testF 4 state andnC! c" RUNNING TEST-F" cds W! begin 0 until ;

\ Search free cog
\ ( -- n1 n2)     n1:available cogID  -1= no available cog  
: free_cog
cogID L@ d28 rshift 
(nfcog) 0=
if
     dup ." available cogID:" . cr
     dup cogID L@ 4 lshift or cogID L!   
     swap 1+ d28 lshift cogID L@ or cogID L!
else
     nip
     ." No free Cog"  cr
then                                
;

: auto_set_demo
free_cog dup -1 <>
if
     c" testA" swap cogx
else
     drop     
then

d10 delms
free_cog dup -1 <>
if
     c" testB" swap cogx
else
     drop     
then

d10 delms
free_cog dup -1 <>
if
     c" testC" swap cogx
else
     drop     
then

d10 delms
free_cog dup -1 <>
if
     c" testD" swap cogx
else
     drop     
then

d10 delms
free_cog dup -1 <>
if
     c" testE" swap cogx
else
     drop     
then

d10 delms
free_cog dup -1 <>
if
     c" testF" swap cogx
else
     drop     
then
d10 delms
free_cog dup -1 <>
if
     c" testA" swap cogx
else
     drop     
then
cr cr
cog?
." cogID:0x" cogID L@ hex . decimal cr 
;

\ Reset cogID under operating
\ ( n1 -- ) n1:cog_number(0 or 1 or 2 or 3 or 4 or 5 ) 
: cog_reset
dup 6 <                                      \ Skip when cog6 or cog7
if
     cogID L@ dup d28 rshift                 \ Get cogs under operating
     0 do
          2dup                               \ ( cog_number cogID cog_number cogID )
          hF and =                           \ Check if cog_number=cogID[b3-b0]
          if
               dup hF and cogreset           \ Reset cog_number
               d10 delms
               cogID L@ dup d28 rshift 1-    \ subtract 1 from cogs ( cog_number cogID [cogID L@] cogs-1 )
               swap dup                      \ ( cog_number cogID cogs-1 [cogID L@] [cogID L@] )
               i 4 u* maskA + L@ and         \ ( cog_number cogID cogs-1 [cogID L@] [cogID L@]_and_maskA )
               4 rshift swap                 \ ( cog_number cogID cogs-1 [cogID L@]_and_maskA [cogID L@] )
               i 4 u* maskB + L@ and or      \ ( cog_number cogID cogs-1 new_cogID )
               swap d28 lshift or            \ ( cog_number cogID new_cogID )
               cogID L!                                       
               leave                   
          else
               4 rshift
               lasti? 
               if ." No cogID" over . ."  under operating" then   \ Operating cog_number don't exist
          then
     loop
     2drop                
else
     drop
     ." Cannot reset Cog6 and Cog7" cr
then
d10 delms
cr
cog?
." cogID:0x" cogID L@ hex . decimal cr
;

\ Reset all cog under operating
\ ( -- )
: all_cog_reset
cogID L@ dup d28 rshift
0 do
     dup hF and cogreset      \ Reset from first cog to last cog
     4 rshift
loop
drop
d10 delms
cr
0 cogID L!
." cogID:0x" cogID L@ hex . decimal cr
cog?
;

\ Print out the display string for cog
\ ( n1 -- )  n1:cog nymber
: cog_string cogcds W@ .cstr cr ;
