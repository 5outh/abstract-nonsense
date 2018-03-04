{-# LANGUAGE OverloadedStrings #-}

import           Data.Monoid
import           Hakyll

main :: IO ()
main = hakyll $ do
    match "images/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "images/**/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "pdfs/*" $ do
        route idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "js/**/*" $ do
        route idRoute
        compile copyFileCompiler

    match (fromList ["about.rst", "contact.markdown"]) $ do
        route   $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls

    match "art/*" $ do
        route $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/art.html"    postCtx
            >>= saveSnapshot "content"
            >>= loadAndApplyTemplate "templates/default.html" postCtx
            >>= relativizeUrls

    match "posts/*" $ do
        route $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/post.html"    postCtx
            >>= saveSnapshot "content"
            >>= loadAndApplyTemplate "templates/default.html" postCtx
            >>= relativizeUrls

    create ["archive.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let
              archiveCtx =
                listField "posts" postCtx (return posts) `mappend`
                constField "title" "Archives"            `mappend`
                defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls

    match "index.html" $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let
              indexCtx =
                listField "posts" postCtx (return posts) `mappend`
                defaultContext

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    match "templates/*" $ compile templateBodyCompiler

    createAtomFeed
    createRssFeed

postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y" `mappend`
    defaultContext

createAtomFeed :: Rules ()
createAtomFeed = create [ "atom.xml" ] $ do
    route idRoute
    compile $ do
        let feedCtx = postCtx <> bodyField "description"
        posts <- fmap (take 10)  . recentFirst =<<
            loadAllSnapshots "posts/*" "content"
        renderAtom feedConfiguration feedCtx posts

createRssFeed :: Rules ()
createRssFeed = create [ "rss.xml" ] $ do
    route idRoute
    compile $ do
       let feedCtx = postCtx <> bodyField "description"
       posts <- fmap (take 10)  . recentFirst =<<
           loadAllSnapshots "posts/*" "content"
       renderRss feedConfiguration feedCtx posts

feedConfiguration :: FeedConfiguration
feedConfiguration = FeedConfiguration
    { feedTitle = "Abstract Nonsense"
    , feedDescription = "Ramblings by Benjamin Kovach"
    , feedAuthorName = "Benjamin Kovach"
    , feedAuthorEmail = "bkovach13@gmail.com"
    , feedRoot = "http://kovach.me"
    }
