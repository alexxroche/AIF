#!/usr/bin/env runhaskell

-- README.lhs - this file
-- Makefile   - make ; it happen
-- hello.hs   - Haskel "Hello World" Source file 
-- hello.hi   - Haskel Intermediate (pre-compiled)
-- hello.o    - object code
-- hello_you  - binary


> sites = ["http://tryhaskell.org", "http://yannesposito.com/Scratch/en/blog/Haskell-the-Hard-Way/", "http://learnyouahaskell.com", "http://book.realworldhaskell.org" ]
> main = do
>       print "So you want to lean Haskell? Read this file"
>       print ""
>       print "There are a few sites that you should work through, (probably in this order:)"
>       print ""
>       print "http://tryhaskell.org"
>       print "http://yannesposito.com/Scratch/en/blog/Haskell-the-Hard-Way/"
>       print "http://learnyouahaskell.com"
>       print "http://book.realworldhaskell.org"

-->       map print sites

http://www.haskell.org/haskellwiki/Haskell_in_5_steps

If you want to write a script, (because your imperative language of choice is perl,python,$_anthing_else_like_C_that_you_don't_compile) 
then just make sure it ends with .lhs and use

$ runhaskell example.lhs


-- -- example.lhs (remote the "-- " REM comment marks
-- 
-- > f x y = x*x + y*y
-- > main = print (f 2 3)

The same function as a Haskell program is written as example.hs

f x y = x*x + y*y
main = print (f 2 3)

you also have the ghci but the format is:

let f x y = x*x + y*y
print (f 2 3)


