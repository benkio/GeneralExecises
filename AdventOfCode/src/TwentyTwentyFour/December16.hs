module TwentyTwentyFour.December16 where

import Control.Arrow
import Data.Bifunctor (bimap)
import Data.List (find, groupBy, minimumBy, nubBy, sortBy)
import Data.Map (Map)
import Data.Map as Map (fromList, lookup, toList)
import Data.Maybe (fromJust)
import Data.Ord (comparing)
import qualified Data.Set as S (fromList, size)
import Data.Tree (Tree, drawTree, foldTree)
import Data.Void
import Debug.Trace
import Lib.Coord (Coord, coordDistance, findCardinalNeighboors)
import Lib.CoordMap (findBranches)
import Lib.Direction (Direction (..))
import Lib.Parse (parseGridWithElemSelection)
import Lib.Pathfinding (Node (..), mapToPaths)

data Terrain = S | E | T deriving (Show, Eq)
type ReindeerMap = Map Coord Terrain

input :: IO ReindeerMap
input = parseInput <$> readFile "input/2024/December16.txt"

parseInput :: String -> ReindeerMap
parseInput = fromList . fst . parseGridWithElemSelection parseReindeerMap
  where
    parseReindeerMap :: Int -> Int -> Char -> Maybe (Either (Coord, Terrain) Void)
    parseReindeerMap y x '#' = Nothing
    parseReindeerMap y x '.' = Just $ Left ((x, y), T)
    parseReindeerMap y x 'S' = Just $ Left ((x, y), S)
    parseReindeerMap y x 'E' = Just $ Left ((x, y), E)

buildPaths :: (Coord, Terrain) -> Coord -> ReindeerMap -> [[(Node (Terrain), Int)]]
buildPaths startingPoint target = mapToPaths startingPoint East (\_ v -> v == E) calculateScore

findPoint :: Terrain -> ReindeerMap -> (Coord, Terrain)
findPoint t = fromJust . find ((== t) . snd) . toList

-- foldTree :: (a -> [b] -> b) -> Tree a -> b
findBestPathScore :: Tree ((Node Terrain, Int)) -> (Int, [Coord])
findBestPathScore = foldTree foldNCalculateScore

foldNCalculateScore :: (Node Terrain, Int) -> [(Int, [Coord])] -> (Int, [Coord])
foldNCalculateScore (n, v) xs
    | val n == E = trace ("calculate on End " ++ show v) (v, [nc n])
    | null candidates = trace ("discard node " ++ show (nc n)) (-1, [])
    | otherwise = trace ("calculate on node " ++ show (nc n)) $ minimumBy (comparing fst) candidates
  where
    candidates = filter ((>= 0) . fst) xs

calculateScore :: Node Terrain -> Int
calculateScore (N{distanceFromParent = dist, turnL = tl, turnR = tr}) = dist + (1000 * (tl + tr))

-- test' = putStrLn . drawTree . fmap (\n -> show (calculateScore n) ++ show n) $ buildPaths sp testInput
--   where
--     sp = findPoint testInput
-- test c dir = findBranches c dir (\_ v -> v == E) testInput

findMinimumScore = minimum . fmap getPathScore . findEndPaths
getPathScore = snd . last
findEndPaths = filter ((== E) . val . fst . last)

solution1 :: ReindeerMap -> Int
solution1 ms =
    findMinimumScore $ paths
  where
    sp = findPoint S ms
    target = fst $ findPoint E ms
    paths = buildPaths sp target ms

december16Solution1 :: IO Int
december16Solution1 = solution1 <$> input

-- solution2 :: ReindeerMap -> Int
solution2 ms =
     -- sum $ fmap (\(n,_) -> distanceFromParent n)
     -- .nubBy (\(n,_) (n',_) -> nc n == nc n')
     fmap (fmap (distanceFromParent . fst))
--        . concat
        . filter ((== minimumScore) . getPathScore)
        $ endPaths
  where
    sp = findPoint S ms
    target = fst $ findPoint E ms
    paths = buildPaths sp target ms
    minimumScore = findMinimumScore paths
    endPaths = findEndPaths paths

-- december16Solution2 :: IO Int
december16Solution2 = solution2 <$> input

testInput :: ReindeerMap
testInput =
    parseInput
        "###############\n\
        \#.......#....E#\n\
        \#.#.###.#.###.#\n\
        \#.....#.#...#.#\n\
        \#.###.#####.#.#\n\
        \#.#.#.......#.#\n\
        \#.#.#####.###.#\n\
        \#...........#.#\n\
        \###.#.#####.#.#\n\
        \#...#.....#.#.#\n\
        \#.#.#.###.#.#.#\n\
        \#.....#...#.#.#\n\
        \#.###.#.#.#.#.#\n\
        \#S..#.....#...#\n\
        \###############\n"

testInput' :: ReindeerMap
testInput' =
    parseInput
        "#################\n\
        \#...#...#...#..E#\n\
        \#.#.#.#.#.#.#.#.#\n\
        \#.#.#.#...#...#.#\n\
        \#.#.#.#.###.#.#.#\n\
        \#...#.#.#.....#.#\n\
        \#.#.#.#.#.#####.#\n\
        \#.#...#.#.#.....#\n\
        \#.#.#####.#.###.#\n\
        \#.#.#.......#...#\n\
        \#.#.###.#####.###\n\
        \#.#.#...#.....#.#\n\
        \#.#.#.#####.###.#\n\
        \#.#.#.........#.#\n\
        \#.#.#.#########.#\n\
        \#S#.............#\n\
        \#################\n"
