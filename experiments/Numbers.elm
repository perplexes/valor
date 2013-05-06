{-
Error while compiling experiments/Numbers.elm:
Type error ():
Number is not a {Float,Int,Time}
In context: thing

Why is Number not an ADT?
-}
module Numbers where
thing : Number
thing = 5

thing2 : Int -> Number
thing a = a

main = thing 5
