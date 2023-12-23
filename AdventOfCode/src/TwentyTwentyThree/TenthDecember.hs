{-# LANGUAGE TupleSections #-}

module TwentyTwentyThree.TenthDecember where

import Data.Functor ((<&>))
import Data.List (nubBy)
import Data.Map (Map, fromList, mapWithKey, toList)
import qualified Data.Map as M (filter, lookup)
import Data.Maybe (fromJust, mapMaybe)
import Data.Set (Set)
import Debug.Trace

type Coordinate = (Int, Int)
data PipeOrientation = NS | EW | NE | NW | SW | SE deriving (Show, Eq, Ord)
data Field = P PipeOrientation | D | A deriving (Eq, Ord)
data AnimalMove = N | S | E | W deriving (Show, Enum, Eq)
type FieldMap = Map Coordinate Field

instance Show Field where
    show (P o) = show o
    show D = "."
    show A = "S"

input :: IO FieldMap
input = parseInput <$> readFile "input/2023/10December.txt"

startingPoint :: FieldMap -> Coordinate
startingPoint = fst . head . toList . M.filter (== A)

search :: FieldMap -> [(Coordinate, AnimalMove)]
search fm = head $ nubBy sameLoop $ animalPath fm st
  where
    st = (\d -> [(startingPoint fm, d)]) <$> enumFrom N
    sameLoop :: [(Coordinate, AnimalMove)] -> [(Coordinate, AnimalMove)] -> Bool
    sameLoop p p' = all ((`elem` fmap fst p') . fst) p

isLoop :: FieldMap -> [(Coordinate, AnimalMove)] -> Bool
isLoop fm = ((`elem` fmap (stepCoordinate (startingPoint fm)) (enumFrom N)) . fst) . last

animalPath :: FieldMap -> [[(Coordinate, AnimalMove)]] -> [[(Coordinate, AnimalMove)]]
animalPath fm [] = []
animalPath fm (p : ps)
    | null nextP && isLoop fm p = p : animalPath fm ps
    | null nextP && not (isLoop fm p) = animalPath fm ps
    | otherwise = animalPath fm (fmap (\n -> p ++ [n]) nextP) ++ animalPath fm ps
  where
    nextP = animalMove (concat (p : ps)) fm (last p)

animalMove :: [(Coordinate, AnimalMove)] -> FieldMap -> (Coordinate, AnimalMove) -> [(Coordinate, AnimalMove)]
animalMove path fm (c, am) = filter ((`notElem` fmap fst path) . fst) . mapMaybe (\x -> animalStep fm (stepCoordinate c x) x) . filter (/= oppositeDirection am) $ enumFrom N

animalStep :: FieldMap -> Coordinate -> AnimalMove -> Maybe (Coordinate, AnimalMove)
animalStep fm nc am = M.lookup nc fm >>= pipeAccess am <&> (nc,)

stepCoordinate :: Coordinate -> AnimalMove -> Coordinate
stepCoordinate (x, y) N = (x, y - 1)
stepCoordinate (x, y) S = (x, y + 1)
stepCoordinate (x, y) E = (x + 1, y)
stepCoordinate (x, y) W = (x - 1, y)

pipeAccess :: AnimalMove -> Field -> Maybe AnimalMove
pipeAccess _ D = Nothing
pipeAccess _ A = Nothing
pipeAccess N (P po) = M.lookup po $ fromList [(NS, N), (SE, E), (SW, W)]
pipeAccess S (P po) = M.lookup po $ fromList [(NS, S), (NE, E), (NW, W)]
pipeAccess W (P po) = M.lookup po $ fromList [(EW, W), (SE, S), (NE, N)]
pipeAccess E (P po) = M.lookup po $ fromList [(EW, E), (SW, S), (NW, N)]

solution1 = (`div` 2) . (+ 1) . length . search

tenthDecemberSolution1 :: IO Int
tenthDecemberSolution1 = solution1 <$> input

cleanNonLoopPipes :: FieldMap -> [(Coordinate, AnimalMove)] -> FieldMap
cleanNonLoopPipes fm l = mapWithKey (\c f -> if c `elem` fmap fst l then f else D) fm

-- walk the path, fix a convention for what's in and out:
-- going est in EW, then North in In, south is out etc
-- foreach pipe select the rows/cols of in and out and add them to the sets
selectInOut :: FieldMap -> [(Coordinate, AnimalMove)] -> (Set Coordinate, Set Coordinate) -> (Set Coordinate, Set Coordinate)
selectInOut _ [] (sin, sout) = (sin, sout)
selectInOut fm (l : ls) (sin, sout) = undefined

-- Populate the 2 sets including what's in and out by convention
selectInOutSingle :: FieldMap -> (Coordinate, AnimalMove) -> (Set Coordinate, Set Coordinate) -> (Set Coordinate, Set Coordinate)
selectInOutSingle fm (c, am) (sin, sout) = undefined
  where
    (inDirections, outDirections) = inOutConvention ((fromJust . M.lookup c) fm) am
    -- select all the elements not in loop and not out of the map in the directions from the coordinate c
    (inCoordinates, outCoordinates) = undefined

inOutConvention :: Field -> AnimalMove -> ([AnimalMove], [AnimalMove])
inOutConvention (P NS) N = ([E], [W])
inOutConvention (P NS) S = ([W], [E])
inOutConvention (P EW) E = ([S], [N])
inOutConvention (P EW) W = ([N], [S])
inOutConvention (P NE) N = ([], [S, W])
inOutConvention (P NE) E = ([S, W], [])
inOutConvention (P NW) N = ([E, S], [])
inOutConvention (P NW) W = ([], [E, S])
inOutConvention (P SW) S = ([], [N, E])
inOutConvention (P SW) W = ([N, E], [])
inOutConvention (P SE) S = ([N, W], [])
inOutConvention (P SE) E = ([], [N, W])
inOutConvention x y = error $ "expected a pipe, got: " ++ (show (x, y))

solution2 = undefined

tenthDecemberSolution2 :: IO Int
tenthDecemberSolution2 = undefined

parseInput :: String -> FieldMap
parseInput = fromList . concatMap (\(y, c) -> (fmap (parseField y) . zip [0 ..]) c) . zip [0 ..] . lines
  where
    parseField :: Int -> (Int, Char) -> (Coordinate, Field)
    parseField y (x, '|') = ((x, y), P NS)
    parseField y (x, '-') = ((x, y), P EW)
    parseField y (x, 'L') = ((x, y), P NE)
    parseField y (x, 'J') = ((x, y), P NW)
    parseField y (x, '7') = ((x, y), P SW)
    parseField y (x, 'F') = ((x, y), P SE)
    parseField y (x, '.') = ((x, y), D)
    parseField y (x, 'S') = ((x, y), A)

testInput :: FieldMap
testInput =
    parseInput
        ".....\n\
        \.S-7.\n\
        \.|.|.\n\
        \.L-J.\n\
        \....."

testInput' :: FieldMap
testInput' =
    parseInput
        "..F7.\n\
        \.FJ|.\n\
        \SJ.L7\n\
        \|F--J\n\
        \LJ..."

oppositeDirection :: AnimalMove -> AnimalMove
oppositeDirection N = S
oppositeDirection S = N
oppositeDirection E = W
oppositeDirection W = E
