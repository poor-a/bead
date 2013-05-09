{-# LANGUAGE OverloadedStrings #-}
module Bead.View.Snap.Content.UserSubmissions (
    userSubmissions
  ) where

import Bead.View.Snap.Content
import Bead.Domain.Types (Str(..))
import Bead.Domain.Entities (Email(..), roles)
import qualified Bead.Controller.UserStories as U (userSubmissions)
import Bead.Controller.Pages as P (Page(ModifyEvaulation, Evaulation))

import Text.Blaze.Html5 ((!))
import qualified Text.Blaze.Html5 as H
import qualified Text.Blaze.Html5.Attributes as A
import Data.String (fromString)
import Data.Time (UTCTime)

userSubmissions :: Content
userSubmissions = getContentHandler userSubmissionPage

userSubmissionPage :: GETContentHandler
userSubmissionPage = withUserStateE $ \s -> do
  username <- getParamE (fieldName usernameField)      Username "Username is not found"
  aKey     <- getParamE (fieldName assignmentKeyField) AssignmentKey "Assignment key was not found"
  mDesc <- runStoryE $ U.userSubmissions username aKey
  case mDesc of
    Nothing -> renderPagelet $ withUserFrame s unauthorized
    Just  d -> renderPagelet $ withUserFrame s (userSubmissionHtml d)

unauthorized :: Pagelet
unauthorized = onlyHtml $ mkI18NHtml $ const $
  "You have tried to reach a submission that not belongs to your groups"

userSubmissionHtml :: UserSubmissionDesc -> Pagelet
userSubmissionHtml u = onlyHtml $ mkI18NHtml $ \i18n -> do
  H.p $ do
    fromString . i18n $ "Course: "
    fromString . usCourse $ u
  H.p $ do
    fromString . i18n $ "Assignment: "
    fromString . usAssignmentName $ u
  H.p $ do
    fromString . i18n $ "Student: "
    fromString . usStudent $ u
  H.p $ do
    fromString . i18n $ "Submitted Solutions: "
    submissionTable i18n . usSubmissions $ u

submissionTable :: I18N -> [(SubmissionKey, UTCTime, SubmissionInfo, EvaulatedWith)] -> Html
submissionTable i18n s = do
  table "submission-table" (className userSubmissionClassTable) $ do
    headerLine
    mapM_ submissionLine s

  where
    headerLine = H.tr $ do
      H.th . fromString . i18n $ "Date of submission"
      H.th . fromString . i18n $ "Evaulated By"
      H.th . fromString . i18n $ ""

    submissionLine (sk,t,si,ev) = H.tr $ do
      H.td $ sbmLink si sk t
      H.td $ fromString $ i18n $ submissionInfo si
      H.td $ fromString $ i18n $ evaulatedWith  ev

    submissionInfo :: SubmissionInfo -> String
    submissionInfo Submission_Not_Found   = "Not Found"
    submissionInfo (Submission_Passed _)  = "Passed"
    submissionInfo (Submission_Failed _)  = "Failed"
    submissionInfo Submission_Unevaulated = "Unevaulated"

    evaulatedWith EvHand = "By Hand"

    sbmLink si sk t = case siEvaulationKey si of
      Nothing -> link
        (routeWithParams P.Evaulation [requestParam sk])
        (fromString . show $ t)
      Just ek -> link
        (routeWithParams P.ModifyEvaulation [requestParam sk,requestParam ek] )
        (show t)
