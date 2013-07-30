module Bits ((<<), (>>), and, or, zorder) where
import Native.Bits as N

-- Shift left
(<<) : Int -> Int -> Int
-- Shift right
(>>) : Int -> Int -> Int
-- And
and : Int -> Int -> Int
-- Or
or : Int -> Int -> Int

zorder : (Int,Int) -> Int
