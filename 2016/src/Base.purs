module Base (module Prelude, (|>), module Control.Monad.Eff, module Control.Monad.Eff.Console, module Data.Maybe, inputLines, eitherToMaybe, Main) where

import Prelude
import Data.Function (applyFlipped)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Control.Monad.Eff.Exception (EXCEPTION)
import Data.Maybe
import Data.Either (Either, either)
import Data.String (split, Pattern(..))
import Node.Encoding (Encoding(UTF8))
import Node.FS (FS())
import Node.FS.Sync (readTextFile)

infixl 1 applyFlipped as |>

eitherToMaybe :: forall a b .Either a b -> Maybe b
eitherToMaybe = either (const Nothing) Just

type Main a = forall eff . Eff (fs :: FS, err :: EXCEPTION, console :: CONSOLE | eff) a

inputLines :: forall eff . String -> Eff (fs :: FS, err :: EXCEPTION | eff) (Array String)
inputLines path =
  split (Pattern "\n") <$> readTextFile UTF8 path