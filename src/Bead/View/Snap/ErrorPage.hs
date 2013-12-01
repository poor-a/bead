{-# LANGUAGE OverloadedStrings #-}
module Bead.View.Snap.ErrorPage (
    errorPage
  , msgErrorPage
  , errorPageWithTitle
  ) where

import Data.String

import Snap
import Snap.Blaze (blaze)
import Text.Blaze.Html5 (Html, (!))
import qualified Text.Blaze.Html5 as H
import qualified Text.Blaze.Html5.Attributes as A

import Bead.Controller.Pages (Page(Login))
import Bead.View.Snap.Application (App)
import Bead.View.Snap.HandlerUtils
import Bead.View.Snap.Pagelets (
    link, withTitleAndHead
  )

-- | Produces an error page showing the reason of an error, and redirects to
--   login page after a while
errorPage :: ContentHandlerError -> Handler App b ()
errorPage = contentHandlerErrorMap (blaze . (page "Error"))

msgErrorPage :: String -> Handler App b ()
msgErrorPage = blaze . (page "Error") . Just

-- Produces a handler that renders the error page, with the
-- given title and message for the user
errorPageWithTitle :: String -> String -> Handler App b ()
errorPageWithTitle title = blaze . (page title) . Just

page :: String -> (Maybe String) -> Html
page t e = withTitleAndHead t $ do
  H.div $ do
    H.h2 $ "Some error happened"
    H.p $
      maybe (return ()) fromString e
    H.br
  H.div $
    link "/" "Go back to login page"

