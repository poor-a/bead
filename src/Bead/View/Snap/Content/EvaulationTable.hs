{-# LANGUAGE OverloadedStrings #-}
module Bead.View.Snap.Content.EvaulationTable (
    evaulationTable
  ) where

import Control.Monad (liftM)

import Bead.Controller.Pages as P (Page(Evaulation))
import Bead.Controller.ServiceContext (UserState(..))
import Bead.Controller.UserStories (openSubmissions)
import Bead.View.Snap.Pagelets
import Bead.View.Snap.Content

import Text.Blaze.Html5 (Html)
import qualified Text.Blaze.Html5 as H

evaulationTable :: Content
evaulationTable = getContentHandler evaulationTablePage

evaulationTablePage :: GETContentHandler
evaulationTablePage = withUserStateE $ \s -> do
  keys <- runStoryE (openSubmissions)
  blaze $ withUserFrame s (evaulationTableContent keys)

evaulationTableContent :: [SubmissionKey] -> Html
evaulationTableContent ks = do
  H.p $ table "evaulation-table" $ do
    H.td $ "Table of new unevaulated assignements"
    mapM_ (\s -> H.td $ link (routeWithParams P.Evaulation [requestParam s]) (show s)) ks