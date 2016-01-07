fl

{
PropForth5.5

Display ROM-fonts
2013/09/29 23:00:32
}

: font1
h8000                                   \ start-address of font
begin
     dup hC000 = if drop h8000 then     \ If end-char, back to start-address
     dup ." $" hex . cr
     d32 0 do                           \ Repeat 32-column
          dup L@ 1                      \ Get 1-Long for 1-column
          d32 0 do                      \ Print dots inside 1-column
               2dup and 
               if 
                    1 
               else 
                    0 
               then 
               . 
               1 lshift                 \ Shift bit-position to left 
          loop 
          2drop cr   
          4 +                           \ Increment HUB-ram address
     loop
     cr cr
fkey? swap drop until
drop
;

: font2
h8000                                        \ start-address of font
begin
     dup hC000 = if drop h8000 then          \ If end-char, back to start-address
     dup ." $" hex . cr
     d32 0 do                                \ Repeat 32-column
          dup L@ 1                           \ Get 1-Long for 1-column
          d32 0 do                           \ Print dots inside 1-column
               2dup and                      \ Check if bit is "1" or "0"
               if 
                    i 2 u/mod drop           \ Check even-char or odd-char
                    if 
                         h23                 \ If odd-char, print "#"
                    else
                         h21                 \ If even-char, print "!"
                    then
               else 
                    bl                       \ If "0", print blank
               then 
               emit 
               1 lshift                      \ Shift bit-position to left
          loop 
          2drop cr
          4 +                                \ Increment HUB-ram address
     loop
     cr cr
fkey? swap drop until
drop
;

\ ************************
\  variables
\ ************************
wvariable odd

\ ************************
\  main
\ ************************

: font3
h8000                                        \ start-address of font
begin
     dup hC000 = if drop h8000 then          \ If end-char, back to start-address
     dup ." $" hex . cr 
     dup                 
     2 0 do                                  \ Repeat even-char and odd-char 
          i 1+ odd W!                        \ Set value(1 or 2) to odd
          d32 0 do                           \ Repeat 32-column
               dup L@ odd W@
               d16 0 do                      \ print 1-row (16bits)
                    2dup and
                    if
                         h2A                 \ Print "*"
                    else
                         bl                  \ blank
                    then     
                    emit
                    2 lshift                 \ Shift bit-position to left 2bits
               loop
               2drop
               cr
               4 +                           \ Increment HUB-ram address
          loop           
          cr cr
          d128 -                             \ Back address to first (4 * d32 = d128)
     loop
     drop
     d128 +                                  \ next character
fkey? swap drop until
drop
;

