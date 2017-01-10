#!/usr/bin/env stack
-- stack --install-ghc runghc --package turtle --package text
 
                                    -- #!/bin/bash
{-# LANGUAGE OverloadedStrings #-}  --
                                    --
import Turtle                       --
import Data.List
import Data.Text hiding (intercalate)
import qualified Data.Text as T
import qualified Data.Text.IO as T

main = do
    mapM_ (T.putStrLn . interp 3)
        [

                "/images/italy/day3/IMG_1402.jpg"
                ,"/images/italy/day3/IMG_1404.jpg"
                ,"/images/italy/day3/IMG_1406.jpg"
                ,"/images/italy/day3/IMG_1413.jpg"
                ,"/images/italy/day3/IMG_1414.jpg"
        ]

interp :: Int -> Text -> Text
interp day img = mconcat 
    [ "<a data-lightbox=\"day-" <> day' <>  "\" href=\"" <> img <> "\""
    , " data-title=\"\">"
    , "<img "
    , "src=\"" <> img <> "\""
    , " style=\"height:200px; border-radius:4px;margin:5px\"/>"
    , "</a>"
    ]
        where day' = T.pack $ show day

