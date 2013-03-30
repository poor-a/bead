{-# LANGUAGE OverloadedStrings #-}
module Bead.View.Snap.Content.Profile (
    profile
  ) where

import Control.Monad (liftM)

import Bead.Controller.ServiceContext (UserState(..))
import Bead.View.Snap.Pagelets
import Bead.View.Snap.Content

import Text.Blaze.Html5 (Html)
import qualified Text.Blaze.Html5 as H

profile :: Content
profile = getContentHandler profilePage

profilePage :: GETContentHandler
profilePage = withUserStateE $ \s -> do
  blaze $ withUserFrame s (profileContent) Nothing

profileContent :: Html
profileContent = do
  H.p $ "Full name"
  H.p $ "Password section"
