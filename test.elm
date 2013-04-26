--main = asText <| show (filled black (rect 1 1) |> move 100 100)
adder : (Int,Int,Float,Float) -> Float
adder (w,x,y,z) =
  w * x + y / z
main = asText <| [adder (1,1024,343.3,100.0), 1+1]
