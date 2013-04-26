
transform = scale 0.2 . rotate 0.03

p1 = path [(0.0,0-250.0), (0.0, 250.0)]
p2 = path [(0-250.0,0.0), (250.0, 0.0)]
main = collage 500 500 [
  traced (solid gray) p1,
  traced (solid gray) p2,
  sprite 170 166 (0,0) "ship2.png" |> scale 0.25
  ]
