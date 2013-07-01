module QuadTree where
--import Mouse
--import Window
--import Touch
import open Automaton

{-

    Ported from Haskell's Gloss library, which can be found here:
        http://hackage.haskell.org/packages/archive/gloss

    This code was specifically taken mostly from:
        http://hackage.haskell.org/packages/archive/gloss/1.1.0.0/doc/html/src/Graphics-Gloss-Data-QuadTree.html
    with some relatively minor changes

    Found at: http://deadfoxygrandpa.pw/quadtree.elm
-}

-- Empty is an empty node, Leaf contains a value, Node has quadrants
data QuadTree a = Empty | Leaf a | Node (QuadTree a) (QuadTree a)
                                        (QuadTree a) (QuadTree a)

-- Quadrant names
data Quadrant = NW | NE | SW | SE

-- A rectangular area of the 2D plane
data Extent = Extent { north : Float
                     , south : Float
                     , east  : Float
                     , west  : Float
                     }

-- A point on the 2D plane
type Coord = (Float, Float)

-- Maybe monad to make some things easier
(>>=) : Maybe a -> (a -> Maybe b) -> Maybe b
a >>= f = case a of
            (Just x) -> f x
            Nothing  -> Nothing

return : a -> Maybe a
return x = Just x

listToMaybe : [a] -> Maybe a
listToMaybe list = if (length list == 0) then Nothing else Just (head list)

foldM : (a -> b -> Maybe a) -> a -> [b] -> Maybe a
foldM f a bs =
    if (length bs == 0) then return a else
        f a (head bs) >>= (\fax -> foldM f fax (tail bs))

-- Extent functions
makeExtent : Float -> Float -> Float -> Float -> Extent
makeExtent n s e w = Extent { north = n
                            , south = s
                            , east  = e
                            , west  = w
                            }

takeExtent : Extent -> (Float, Float, Float, Float)
takeExtent (Extent {north, south, east, west}) = (north, south, east, west)

pathToCoord : Extent -> Coord -> Maybe [Quadrant]
pathToCoord extent coord =
    if isUnitExtent extent then Just []
        else quadrantOfCoord extent coord >>= (\quad ->
                pathToCoord (cutQuadrantOfExtent quad extent) coord >>= (\rest ->
                    return (quad :: rest)))


-- Check if an extent is a 1 by 1 square
isUnitExtent : Extent -> Bool
isUnitExtent extent =
    let (x, y) = sizeOfExtent extent in
    x <= 10 && y <= 10

sizeOfExtent : Extent -> (Float, Float)
sizeOfExtent (Extent {north, south, east, west}) = (east - west, north - south)

centerOfExtent : Extent -> (Float, Float)
centerOfExtent (Extent {north, south, east, west}) = ((east + west) / 2, (north + south) / 2)

cutQuadrantOfExtent : Quadrant -> Extent -> Extent
cutQuadrantOfExtent quad (Extent {north, south, east, west}) =
    let hheight = (north - south) / 2
        hwidth  = (east - west) / 2 in
    case quad of
        NW -> makeExtent (north - hheight) south (east - hwidth) west
        NE -> makeExtent (north - hheight) south east (west + hwidth)
        SW -> makeExtent north (south + hheight) (east - hwidth) west
        SE -> makeExtent north (south + hheight) east (west + hwidth)

quadrantOfCoord : Extent -> Coord -> Maybe Quadrant
quadrantOfCoord extent coord =
    listToMaybe <|
    filter (\q -> coordInExtent (cutQuadrantOfExtent q extent) coord) <|
    [NW, NE, SW, SE]

coordInExtent : Extent -> Coord -> Bool
coordInExtent (Extent {north, south, east, west}) (x, y) =
    x >= west && x < east &&
    y >= south && y < north

-- QuadTree functions
emptyTree : QuadTree a
emptyTree = Empty

emptyNode : QuadTree a
emptyNode = Node Empty Empty Empty Empty

getQuadrant : Quadrant -> QuadTree a -> Maybe (QuadTree a)
getQuadrant quad tree =
    case tree of
        Empty     -> Nothing
        Leaf a    -> Nothing
        Node nw ne sw se
            ->  case quad of
                    NW -> Just nw
                    NE -> Just ne
                    SW -> Just sw
                    SE -> Just se

-- Apply a function to a quadrant
liftQ : Quadrant -> (QuadTree a -> QuadTree a) -> QuadTree a -> QuadTree a
liftQ quad f tree =
    case tree of
        Empty     -> tree
        Leaf a    -> tree
        Node nw ne sw se
            ->  case quad of
                    NW -> Node (f nw) ne sw se
                    NE -> Node nw (f ne) sw se
                    SW -> Node nw ne (f sw) se
                    SE -> Node nw ne sw (f se)

-- Insert a value into the QuadTree at a location specified by a list of Quadrants
insertByPath : [Quadrant] -> a -> QuadTree a -> QuadTree a
insertByPath quadrants x tree =
    if (length quadrants == 0) then Leaf x
        else let (q::qs) = quadrants in
             case tree of
                Empty        -> liftQ q (insertByPath qs x) emptyNode
                Leaf a       -> tree
                Node _ _ _ _ -> liftQ q (insertByPath qs x) tree

insertByCoord : Extent -> Coord -> a -> QuadTree a -> Maybe (QuadTree a)
insertByCoord extent coord x tree =
    pathToCoord extent coord >>= (\path ->
        return <| insertByPath path x tree)

insert2ByCoord : Extent -> (Coord, Coord) -> a -> QuadTree a -> Maybe (QuadTree a)
insert2ByCoord extent (c1, c2) x tree =
    insertByCoord extent c1 x tree >>= (\tree2 ->
        insertByCoord extent c2 x tree2)

lookupNodeByPath : [Quadrant] -> QuadTree a -> Maybe (QuadTree a)
lookupNodeByPath quadrants tree =
    if   (length quadrants == 0) then Just tree
    else let (q::qs) = quadrants in
         case tree of
            Empty        -> Nothing
            Leaf x       -> Nothing
            Node _ _ _ _ -> let Just quad = getQuadrant q tree in
                            lookupNodeByPath qs quad

lookupByPath : [Quadrant] -> QuadTree a -> Maybe a
lookupByPath path tree =
    case lookupNodeByPath path tree of
        Just (Leaf x) -> Just x
        _             -> Nothing

lookupByCoord : Extent -> Coord -> QuadTree a -> Maybe a
lookupByCoord extent coord tree =
    pathToCoord extent coord >>= (\path ->
        lookupByPath path tree)

flattenQuadTree : Extent -> QuadTree a -> [(Coord, a)]
flattenQuadTree extentInit treeInit =
    let flatten' extent tree = case tree of
                                 Empty  -> []
                                 Leaf x -> let x' = x -- XXX: Elm bug!!
                                               (n, s, e, w) = takeExtent extent
                                            in [((w, s), x')]
                                 Node _ _ _ _ -> concatMap (flattenQuad extent tree) [NW, NE, SW, SE]
        flattenQuad extent tree quad = let extent' = cutQuadrantOfExtent quad extent
                                           Just tree' = getQuadrant quad tree in
                                       flatten' extent' tree' in
    flatten' extentInit treeInit

flattenQuadTreeWithExtents : Extent -> QuadTree a -> [(Extent, a)]
flattenQuadTreeWithExtents extentInit treeInit =
    let flatten' extent tree = case tree of
                                 Empty  -> []
                                 Leaf x -> [(extent ,x)]
                                 Node _ _ _ _ -> concatMap (flattenQuad extent tree) [NW, NE, SW, SE]
        flattenQuad extent tree quad = let extent' = cutQuadrantOfExtent quad extent
                                           Just tree' = getQuadrant quad tree in
                                       flatten' extent' tree' in
    flatten' extentInit treeInit

getExtents : Extent -> QuadTree a -> [Extent]
getExtents extentInit treeInit =
    let flatten' extent tree = case tree of
                                 Empty  -> [extent]
                                 Leaf _ -> [extent]
                                 Node _ _ _ _ -> concatMap (flattenQuad extent tree) [NW, NE, SW, SE]
        flattenQuad extent tree quad = let extent' = cutQuadrantOfExtent quad extent
                                           Just tree' = getQuadrant quad tree in
                                       flatten' extent' tree' in
    flatten' extentInit treeInit

-- Drawing functions for pretty output

--extentForm : Extent -> Form
--extentForm extent =
--    let (w, h) = sizeOfExtent extent in
--    outlined defaultLine <| rect w h

--drawTree : Extent -> QuadTree a -> Element
--drawTree extent tree =
--    let extents = getExtents extent tree
--        centers = map centerOfExtent extents
--        (w, h)  = sizeOfExtent extent in
--    collage w h <| map (\((x, y), e) -> move (x-(w `div` 2), 0-(y-(h `div` 2))) <| extentForm e) <| zip centers extents

--display (w, h) pos =
--    let extent = (makeExtent h 0 w 0)
--        tree   = insertByCoord extent pos True emptyTree
--        txt    = (plainText "Tree data structure: " `beside` (asText <| maybe emptyTree id tree))
--                 `above`
--                 (plainText "Quadrant path to cursor: " `beside` (asText <| pathToCoord extent pos))
--                 `above`
--                 (plainText "Cursor position: " `beside` (asText <| pos))
--                 `above`
--                 (plainText "NW quadrant subtree: " `beside` (asText <| lookupNodeByPath [NW] (maybe emptyTree id tree)))
--                 `above`
--                 (plainText "List of all values in tree with positions: " `beside` (asText <| flattenQuadTree extent (maybe emptyTree id tree))) in
--    layers [txt, drawTree extent (maybe emptyTree id tree)]

--main = display <~ Window.dimensions ~ Mouse.position
