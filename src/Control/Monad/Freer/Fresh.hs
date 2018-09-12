-- |
-- Module:       Control.Monad.Freer.Fresh
-- Description:  Generation of fresh integers as an effect.
-- Copyright:    (c) 2016 Allele Dev; 2017 Ixperta Solutions s.r.o.; 2017 Alexis King
-- License:      BSD3
-- Maintainer:   Alexis King <lexi.lambda@gmail.com>
-- Stability:    experimental
-- Portability:  GHC specific language extensions.
--
-- Composable handler for 'Fresh' effects. This is likely to be of use when
-- implementing De Bruijn naming/scopes.
--
-- Using <http://okmij.org/ftp/Haskell/extensible/Eff1.hs> as a starting point.

module Control.Monad.Freer.Fresh
  ( Fresh(..)
  , fresh
  , runFresh
  , evalFresh
  ) where

import Control.Monad.Freer.Internal (Eff, Member, HasLen, handleRelayS, send)

-- | Fresh effect model.
data Fresh r where
  Fresh :: Fresh Int

-- | Request a fresh effect.
fresh :: Member Fresh effs => Eff effs Int
fresh = send Fresh

-- | Handler for 'Fresh' effects, with an 'Int' for a starting value. The
-- return value includes the next fresh value.
runFresh :: HasLen effs => Int -> Eff (Fresh ': effs) a -> Eff effs (a, Int)
runFresh s =
  handleRelayS s (\s' a -> pure (a, s')) (\s' Fresh k -> (k $! s' + 1) s')

-- | Handler for 'Fresh' effects, with an 'Int' for a starting value. Discards
-- the next fresh value.
evalFresh :: HasLen effs => Int -> Eff (Fresh ': effs) a -> Eff effs a
evalFresh s = fmap fst . runFresh s
