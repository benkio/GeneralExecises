module TwentyTwentyThree.TwentyFirstDecember where

import Data.Map (Map)
import qualified Data.Map as M (filter, findMax, fromList, lookup, mapKeys, toList, union)
import Data.Set (Set)
import qualified Data.Set as S (fromList, map, size, toList)

data FieldBlock = GardenPlot | Rock | StartingPosition deriving (Show, Eq)
data Step = N | S | E | W deriving (Show, Enum)
type Field = Map (Int, Int) FieldBlock

setConcatMap :: (Ord b) => (a -> [b]) -> Set a -> Set b
setConcatMap f = S.fromList . concatMap f . S.toList

input :: IO Field
input = parseInput <$> readFile "input/2023/21December.txt"

isGardenPlot :: Field -> (Int, Int) -> Bool
isGardenPlot f x = maybe False (== GardenPlot) $ M.lookup x f
isStartingPosition :: Field -> (Int, Int) -> Bool
isStartingPosition f x = maybe False (== StartingPosition) $ M.lookup x f

takeStep :: (Int, Int) -> Step -> (Int, Int)
takeStep (x, y) N = (x, y - 1)
takeStep (x, y) S = (x, y + 1)
takeStep (x, y) E = (x - 1, y)
takeStep (x, y) W = (x + 1, y)

takeOneStep :: Field -> Set (Int, Int) -> Set (Int, Int)
takeOneStep f s = setConcatMap (\c -> filter (\x -> isGardenPlot f x || isStartingPosition f x) (takeStep c <$> (enumFrom N))) s

walk :: Field -> Set (Int, Int) -> Int -> Set (Int, Int)
walk _ s 0 = s
walk f s c = walk f (takeOneStep f s) (c - 1)

solution1 f = S.size $ walk f startingPoint 64
  where
    startingPoint :: Set (Int, Int)
    startingPoint = S.fromList . map fst . M.toList $ M.filter (== StartingPosition) f

twentyfirstDecemberSolution1 :: IO Int
twentyfirstDecemberSolution1 = solution1 <$> input

expandField :: Field -> (Int, Int) -> Field -> Step -> Field
expandField f c f' s = expandField' f (amendCoord c s) f' s
  where
    (mx, my) = fst $ M.findMax f'
    amendCoord (x, y) N = (x - (x `mod` mx), y)
    amendCoord (x, y) S = (x - (x `mod` mx), y)
    amendCoord (x, y) E = (x, y - (y `mod` my))
    amendCoord (x, y) W = (x, y - (y `mod` my))

expandField' :: Field -> (Int, Int) -> Field -> Step -> Field
expandField' f (sx, sy) f' N = f `M.union` M.mapKeys (\(x, y) -> (sx + x, sy + y - ((snd . fst . M.findMax) f) - 1)) f'
expandField' f (sx, sy) f' S = f `M.union` M.mapKeys (\(x, y) -> (sx + x, sy + y + 1)) f'
expandField' f (sx, sy) f' W = f `M.union` M.mapKeys (\(x, y) -> (sx + x + 1, sy + y)) f'
expandField' f (sx, sy) f' E = f `M.union` M.mapKeys (\(x, y) -> (sx + x - ((fst . fst . M.findMax) f) - 1, sy + y)) f'

solution2 = undefined

twentyfirstDecemberSolution2 :: IO Int
twentyfirstDecemberSolution2 = undefined

parseInput :: String -> Field
parseInput = M.fromList . concat . zipWith (\y ls -> zipWith (\x c -> ((x, y), fromChar c)) [0 ..] ls) [0 ..] . lines
  where
    fromChar :: Char -> FieldBlock
    fromChar '.' = GardenPlot
    fromChar '#' = Rock
    fromChar 'S' = StartingPosition

testInput :: Field
testInput =
    parseInput
        "...........\n\
        \.....###.#.\n\
        \.###.##..#.\n\
        \..#.#...#..\n\
        \....#.#....\n\
        \.##..S####.\n\
        \.##..#...#.\n\
        \.......##..\n\
        \.##.#.####.\n\
        \.##..##.##.\n\
        \..........."
