{-# LANGUAGE OverloadedStrings  #-}
{-# LANGUAGE CPP #-}
module Bead.View.Snap.Login (
    login
  , loginSubmit
  ) where

-- Bead imports

import Bead.Controller.ServiceContext hiding (serviceContext)
import Bead.Controller.Logging as L
import qualified Bead.Controller.Pages as P
import qualified Bead.Controller.UserStories as S
import Bead.View.Snap.Application
import Bead.View.Snap.Dictionary (Language(..))
import Bead.View.Snap.Session
import Bead.View.Snap.HandlerUtils
import Bead.View.Snap.Pagelets

import Bead.View.Snap.Content hiding (BlazeTemplate, template)
import Bead.View.Snap.Content.All

-- Haskell imports

import Data.String
import Data.ByteString.Char8 hiding (index)
import qualified Data.Text as T
import Control.Monad (join)

-- Snap and Blaze imports

import Snap hiding (get)
import Snap.Blaze (blaze)
import Snap.Snaplet.Auth as A
import Snap.Snaplet.Session

-- import Control.Monad (mapM_)

import Text.Blaze (textTag)
import Text.Blaze.Html5 (Html, (!))
import qualified Text.Blaze.Html5 as H
import Text.Blaze.Html5.Attributes hiding (title, rows, accept)
import qualified Text.Blaze.Html5.Attributes as A

-- * Login and Logout handlers

login :: Maybe AuthFailure -> Handler App (AuthManager App) ()
login authError = blaze $ loginPage authError

-- TODO: Handle multiple login attempts correctly
-- One user should just log in at once.
loginSubmit :: Handler App b ()
loginSubmit = do
  withTop auth $ loginUser
    (fieldName loginUsername)
    (fieldName loginPassword)
    Nothing (login . visibleFailure) $ do
      um <- currentUser
      case um of
        Nothing -> do
          logMessage ERROR $ "User is not logged during login submittion process"
          withTop sessionManager $ commitSession
        Just authUser -> do
          context <- withTop serviceContext getServiceContext
          token   <- sessionToken
          let unameFromAuth = usernameFromAuthUser authUser
              mpasswFromAuth = passwordFromAuthUser authUser
          case mpasswFromAuth of
            Nothing -> do logMessage ERROR "No password was given"
                          A.logout
            Just passwFromAuth -> do
              result <- liftIO $ S.runUserStory context UserNotLoggedIn (S.login unameFromAuth passwFromAuth token)
              case result of
                Left err -> do
                  logMessage ERROR $ "Error happened processing user story: " ++ show err
                  -- Service context authentication
                  liftIO $ (userContainer context) `userLogsOut` (userToken (unameFromAuth, token))
                  A.logout
                  withTop sessionManager $ commitSession
                Right (val,userState) -> do
                  initSessionValues (page userState) unameFromAuth
                  withTop sessionManager $ commitSession
                  redirect "/"

  where
    err = Just . T.pack $ "Unknown user or password"

    initSessionValues :: P.Page -> Username -> Handler App b ()
    initSessionValues page username = do
      withTop sessionManager $ do
        setSessionVersion
        setLanguageInSession (Language "en")
        setUsernameInSession username
        setActPageInSession  page

      withTop serviceContext $ do
        logMessage DEBUG $ "Username is set in session to: " ++ show username
        logMessage DEBUG $ "User's actual page is set in session to: " ++ show page

-- * Blaze --

userForm :: String -> Html
userForm act = do
  postForm act $ do
    table (formId loginForm) (formId loginForm) $ do
      tableLine "Login:" (textInput (fieldName loginUsername) 20 Nothing ! A.required "")
      tableLine "Password:" (passwordInput (fieldName loginPassword) 20 Nothing ! A.required "")
    submitButton (fieldName loginSubmitBtn) "Login"

loginPage :: Maybe AuthFailure -> Html
loginPage err = withTitleAndHead "Login" content
  where
    content = do
      userForm "/login"
      maybe (return ())
            ((H.p ! A.style "font-size: smaller") . fromString . show)
            err
      H.p $ do
        "Don't have a login yet? "
#ifdef EMAIL_REGISTRATION
        H.a ! A.href "/reg_request" $ "Create new user"
#else
        H.a ! A.href "/new_user" $ "Create new user"
#endif

-- Keeps only the authentication failures which are
-- visible for the user
visibleFailure :: AuthFailure -> Maybe AuthFailure
visibleFailure (AuthError e)     = Just (AuthError e)
visibleFailure IncorrectPassword = Just IncorrectPassword
visibleFailure UserNotFound      = Just UserNotFound
visibleFailure _ = Nothing
