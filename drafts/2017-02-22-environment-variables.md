---
title: Haskell Bits #4 - Environment Variables
author: Benjamin Kovach
tags: haskell, programming, haskell-bits
---

It's likely that you'll have to deal with environment variables at some point. What I'll describe here is a kicking-off point for
robust environment handling with a really low overhead. We'll basically build a tiny library that will make dealing
with environment variables and configuration a lot easier, then I'll show some example usage.

TODO: Why not base System.Environment?

You'll need the following libraries to get run the code in this post: `transformers`, `split` and `safe`.

```haskell
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

import System.Environment hiding (getEnv)
import Control.Monad.Trans.Maybe
import Control.Monad.IO.Class
import Control.Applicative
import Control.Monad
import Safe
import Data.List.Split

newtype Env a = Env{ unEnv :: MaybeT IO a }
    deriving
        ( Functor
        , Applicative
        , Monad
        , MonadIO
        , Alternative
        , MonadPlus
        )

liftMaybe :: Maybe a -> Env a
liftMaybe = Env . MaybeT . pure

runEnv :: Env a -> IO (Maybe a)
runEnv = runMaybeT . unEnv

getEnv :: String -> Env String
getEnv key =
    liftIO (lookupEnv key) >>= liftMaybe

env :: (String -> Maybe a) -> String -> Env a
env f key = liftMaybe . f =<< getEnv key

maybeEnv
    :: (String -> Maybe a)
    -> String
    -> Env (Maybe a)
maybeEnv f key =
    (f <$> getEnv key) <|> pure Nothing 

readEnv :: Read a => String -> Env a
readEnv = env readMay
```

This code was adapted from 
[a comment on reddit](https://www.reddit.com/r/haskell/comments/3bckm7/envy_an_environmentally_friendly_way_to_deal_with/csl3nqa/) (credit to u/Tekmo).

I honestly think this mini-library is "good enough" for a lot of applications. One major drawback is that it doesn't
report missing or improperly formatted environment variables.
That functionality can be added in a relatively straightforward way, however, with a `MonadThrow` constraint.
This is the simplest thing that does the job well,
which is exactly what the Haskell Bits are supposed to be about, so we'll continue on this path. 

For my example application, I want to be able to pull configuration information
from a set of environment variables.

We can use our mini-library of functions to do this:

```haskell
data Stage 
  = Testing
  | Development
  | Staging 
  | Production
    deriving (Show, Read)

data Version = Version Int Int Int
    deriving Show

data MyEnvironment = MyEnvironment
    { stage :: Stage
    , identifier :: Maybe String
    , version :: Version
    } deriving (Show)

-- Parse a semantic version string like v1.3.3
parseVersion :: String -> Maybe Version
parseVersion versionString =
    case splitOn "." semver of
         [major, minor, patch] ->
             Version
                <$> readMay major
                <*> readMay minor
                <*> readMay patch
         _ -> Nothing
    where semver = tail versionString

-- An environment reader for `MyEnvironment`
myEnv :: Env MyEnvironment
myEnv = MyEnvironment
    <$> (readEnv "APP_STAGE" <|> pure Production)
    <*> maybeEnv Just "APP_ID"
    <*> env parseVersion "APP_VERSION"

main :: IO ()
main = runEnv myEnv >>= print
```

Running this, we get (formatting mine):

```haskell
$ APP_STAGE=Testing APP_VERSION=v1.1.1 APP_ID=its_me_mario my_app

Just (
  MyEnvironment
    { stage = Testing
    , identifier = Just "its_me_mario"
    , version = Version 1 1 1
    }
  )
```

Or, with some missing/incomplete information:

```haskell
$ APP_STAGE=nonexistent APP_VERSION=v1.1.4 my_app

Just (
  MyEnvironment
    { stage = Production
    , identifier = Nothing
    , version = Version 1 1 4
    }
  )
```
