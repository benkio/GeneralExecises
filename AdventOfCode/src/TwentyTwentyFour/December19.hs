module TwentyTwentyFour.December19 where

input :: IO a
input = parseInput <$> readFile "input/2024/December19.txt"

parseInput :: String -> a
parseInput = undefined

testInput :: a
testInput =
    parseInput
        ""

solution1 :: a -> Int
solution1 = undefined

december19Solution1 :: IO Int
december19Solution1 = solution1 <$> input

solution2 :: a -> Int
solution2 = undefined

december19Solution2 :: IO Int
december19Solution2 = solution2 <$> input

