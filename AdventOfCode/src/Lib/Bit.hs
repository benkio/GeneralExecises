module Lib.Bit (
    toBaseBit,
    fromBaseBit,
    fillBitToN,
    bitWiseXor3bits,
) where

import Data.List.Split (chunksOf)
import Debug.Trace

toBaseBit :: Int -> Int -> [Int]
toBaseBit b x
    | rest == 0 = [bit]
    | otherwise = toBaseBit b rest ++ [bit]
  where
    (rest, bit) = x `divMod` b

fromBaseBit :: Int -> [Int] -> Int
fromBaseBit b xs = go (reverse xs) 0
  where
    go [] _ = 0
    go (x : xs) p = x * b ^ p + go xs (p + 1)

fillBitToN :: Int -> [Int] -> [Int]
fillBitToN n xs = replicate (n - length xs) 0 ++ xs

bitWiseXor3bits :: Int -> Int -> Int -> Int
bitWiseXor3bits b x y =
    fromBaseBit b
        . fmap (fromBaseBit 2)
        . chunksOf 3
        $ zipWith xOr xOrMaskX xOrMaskY
  where
    binX = concat $ fillBitToN 3 . toBaseBit 2 <$> toBaseBit b x
    binY = concat $ fillBitToN 3 . toBaseBit 2 <$> toBaseBit b y
    xOrMaskY = replicate (length binX - length binY) 0 ++ binY
    xOrMaskX = replicate (length binY - length binX) 0 ++ binX
    xOr a b = if a == b then 0 else 1
