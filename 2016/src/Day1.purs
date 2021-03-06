module Day1 where

import Prelude
import Data.Tuple (Tuple(..))
import Data.Generic
import Data.List (List(..), head, last, (..), group, concat, zipWith, drop, filter, length)
import Data.Ord (abs)
import Data.Set as Set
import Data.Maybe
import Data.Either (either)
import Data.Bifunctor (bimap)
import Data.Traversable (scanl)
import Control.Alternative ((<|>))
import Control.Monad.Eff (Eff)
import Control.MonadZero (guard)
import Control.Monad.Eff.Console (CONSOLE, log)
import Text.Parsing.Simple (Parser, parse, sepBy, string, char, int)

data Direction = N | E | S | W
data State = State (Tuple Int Int) Direction

derive instance genericDirection :: Generic Direction
instance showState :: Show State where
  show (State (Tuple x y) dir) = show x <> "," <> show y <> "|" <> gShow dir

right N = E
right E = S
right S = W
right W = N

left  E = N
left  S = E
left  W = S
left  N = W

dirV N = Tuple 0 1
dirV E = Tuple 1 0
dirV S = Tuple 0 (-1)
dirV W = Tuple (-1) 0

coords (State t _) = t

dist (Tuple x1 y1) (Tuple x2 y2) =
  abs (x1 - x2) + abs (y1 - y2)

cmdParser :: Parser String (State -> State)
cmdParser = do
  rotate <- (char 'L' *> pure left) <|> (char 'R' *> pure right)
  steps <- int
  pure $ \ (State pos dir) ->
    let newDir = rotate dir in
    State (add pos (bimap (_*steps) (_*steps) (dirV newDir))) newDir

run :: String -> State -> Maybe (List State)
run str start =
  either
    (const Nothing)
    (transform start >>> Just)
    (parse (cmdParser `sepBy` (string ", ")) str)
  where
    transform = scanl (flip ($))

interpolate :: Tuple Int Int -> Tuple Int Int -> List (Tuple Int Int)
interpolate (Tuple x1 y1) (Tuple x2 y2) = do
  x <- x1 .. x2
  y <- y1 .. y2
  guard $ x /= x2 || y /= y2
  pure $ Tuple x y

firstDup :: forall a . Ord a => List a -> Maybe a
firstDup list =
  aux Set.empty list
  where
    aux s Nil = Nothing
    aux s (Cons x xs) =
      if x `Set.member` s then Just x else aux (Set.insert x s) xs

main :: Eff (console :: CONSOLE) Unit
main = do
  log $ show do
    visited <- map (map coords) (run input start)
    last <- last visited
    let solution1 = dist (coords start) last
    -- Part 2: expand visited locations to all coordinates between each two steps, then find first coordinate that occurs twice
    visitedTwice <- firstDup <<< concat $ zipWith interpolate (Cons (coords start) visited) visited
    let solution2 = dist (coords start) visitedTwice
    pure $ Tuple solution1 solution2
    where
      start = State (Tuple 0 0) N
      input = "R4, R5, L5, L5, L3, R2, R1, R1, L5, R5, R2, L1, L3, L4, R3, L1, L1, R2, R3, R3, R1, L3, L5, R3, R1, L1, R1, R2, L1, L4, L5, R4, R2, L192, R5, L2, R53, R1, L5, R73, R5, L5, R186, L3, L2, R1, R3, L3, L3, R1, L4, L2, R3, L5, R4, R3, R1, L1, R5, R2, R1, R1, R1, R3, R2, L1, R5, R1, L5, R2, L2, L4, R3, L1, R4, L5, R4, R3, L5, L3, R4, R2, L5, L5, R2, R3, R5, R4, R2, R1, L1, L5, L2, L3, L4, L5, L4, L5, L1, R3, R4, R5, R3, L5, L4, L3, L1, L4, R2, R5, R5, R4, L2, L4, R3, R1, L2, R5, L5, R1, R1, L1, L5, L5, L2, L1, R5, R2, L4, L1, R4, R3, L3, R1, R5, L1, L4, R2, L3, R5, R3, R1, L3"
