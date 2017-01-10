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
    mapM_ (T.putStrLn . interp 9)
        [

            "/images/italy/day9/IMG_1670.jpg"
            ,"/images/italy/day9/IMG_1671.jpg"
            ,"/images/italy/day9/IMG_1673.jpg"
            ,"/images/italy/day9/IMG_1674.jpg"
            ,"/images/italy/day9/IMG_1675.jpg"
            ,"/images/italy/day9/IMG_1683.jpg"
            ,"/images/italy/day9/IMG_1684.jpg"
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

