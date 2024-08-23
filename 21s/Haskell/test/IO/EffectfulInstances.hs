{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}

module IO.EffectfulInstances where

import Control.Exception
import Control.Monad.Except
import qualified Control.Monad.Except as E
import Control.Monad.Random
import Control.Monad.State.Class
import Control.Monad.State.Lazy
import qualified Control.Monad.State.Lazy as S
import Control.Monad.Trans.Random.Lazy
import Data.Functor.Identity
import IO.Algebras
import Pure.Domain

type TestStack a = StateT [String] (E.ExceptT SomeException (Rand ())) a

instance MonadError IOException Identity where
    throwError = throw
    catchError m _ = m

instance (Monad m) => MonadConsole (StateT [String] m) where
    putStrLn s = S.modify $ \st -> s : st

instance RandomGen () where
    next x = (1, ())
    split _ = ((), ())
