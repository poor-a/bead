{-# LANGUAGE OverloadedStrings #-}
module Bead.View.Snap.Content.Assignment.Page (
    newGroupAssignment
  , newCourseAssignment
  , modifyAssignment
  , viewAssignment
  , newGroupAssignmentPreview
  , newCourseAssignmentPreview
  , modifyAssignmentPreview
  ) where

import           Control.Monad.Error
import qualified Data.Map as Map
import           Data.Time (getCurrentTime)

import qualified Bead.Controller.UserStories as S
import           Bead.View.Snap.Content
import           Bead.View.Snap.RequestParams

import           Bead.View.Snap.Content.Assignment.Data
import           Bead.View.Snap.Content.Assignment.View

-- * Content Handlers

newCourseAssignment = ViewModifyHandler newCourseAssignmentPage postCourseAssignment
newGroupAssignment  = ViewModifyHandler newGroupAssignmentPage postGroupAssignment
modifyAssignment    = ViewModifyHandler modifyAssignmentPage postModifyAssignment
viewAssignment      = ViewHandler viewAssignmentPage
newCourseAssignmentPreview = UserViewHandler newCourseAssignmentPreviewPage
newGroupAssignmentPreview  = UserViewHandler newGroupAssignmentPreviewPage
modifyAssignmentPreview    = UserViewHandler modifyAssignmentPreviewPage

-- * Course Assignment

newCourseAssignmentPage :: GETContentHandler
newCourseAssignmentPage = withUserState $ \s -> do
  ck <- getParameter (customCourseKeyPrm courseKeyParamName)
  (c, tss, ufs) <- userStory $ do
    S.isAdministratedCourse ck
    (course, _groupKeys) <- S.loadCourse ck
    tss' <- S.testScriptInfosOfCourse ck
    ufs  <- map fst <$> S.listUsersFiles
    return ((ck, course), nonEmptyList tss', ufs)
  now <- liftIO $ getCurrentTime
  tz <- userTimeZoneToLocalTimeConverter
  renderBootstrapPage . bootStrapUserFrame s . newAssignmentContent $ PD_Course tz now c tss ufs

postCourseAssignment :: POSTContentHandler
postCourseAssignment = do
  CreateCourseAssignment
    <$> getParameter (customCourseKeyPrm (fieldName selectedCourse))
    <*> getValue -- assignment
    <*> readTCCreation

newCourseAssignmentPreviewPage :: ViewPOSTContentHandler
newCourseAssignmentPreviewPage = withUserState $ \s -> do
  ck <- getParameter (customCourseKeyPrm courseKeyParamName)
  assignment <- getValue
  tc <- readTCCreationParameters
  (c, tss, ufs) <- userStory $ do
    S.isAdministratedCourse ck
    (course, _groupKeys) <- S.loadCourse ck
    tss' <- S.testScriptInfosOfCourse ck
    ufs  <- map fst <$> S.listUsersFiles
    return ((ck, course), nonEmptyList tss', ufs)
  now <- liftIO $ getCurrentTime
  tz <- userTimeZoneToLocalTimeConverter
  renderBootstrapPage . bootStrapUserFrame s . newAssignmentContent $
    PD_Course_Preview tz now c tss ufs assignment tc

-- Tries to create a TCCreation descriptive value. If the test script, usersfile and testcase
-- parameters are included returns Just tccreation otherwise Nothing
readTCCreation :: HandlerError App b TCCreation
readTCCreation = do
  (mTestScript, mZippedTestCaseName, mPlainTestCase) <- readTCCreationParameters
  case tcCreation mTestScript mZippedTestCaseName mPlainTestCase of
    Left  e  -> throwError . strMsg $ "Some error in test case parameters " ++ e
    Right tc -> return tc

readTCCreationParameters :: HandlerError App b TCCreationParameters
readTCCreationParameters = do
  mTestScript         <- getOptionalParameter (jsonParameter (fieldName assignmentTestScriptField) "Test Script")
  mZippedTestCaseName <- getOptionalParameter (jsonParameter (fieldName assignmentUsersFileField) "Test Script File")
  mPlainTestCase      <- getOptionalParameter (stringParameter (fieldName assignmentTestCaseField) "Test Script")
  return (mTestScript, mZippedTestCaseName, mPlainTestCase)

tcCreation :: Maybe (Maybe TestScriptKey) -> Maybe UsersFile -> Maybe String -> Either String TCCreation
tcCreation Nothing        _ _ = Right NoCreation
tcCreation (Just Nothing) _ _ = Right NoCreation
tcCreation (Just (Just tsk)) (Just uf) _ = Right $ FileCreation tsk uf
tcCreation (Just (Just tsk)) _ (Just t)  = Right $ TextCreation tsk t
tcCreation (Just (Just _tsk)) Nothing Nothing = Left "#1"

readTCModificationParameters :: HandlerError App b TCModificationParameters
readTCModificationParameters = do
  mTestScript         <- getOptionalParameter (jsonParameter (fieldName assignmentTestScriptField) "Test Script")
  mZippedTestCaseName <- getOptionalParameter (jsonParameter (fieldName assignmentUsersFileField) "Test Script File")
  mPlainTestCase      <- getOptionalParameter (stringParameter (fieldName assignmentTestCaseField) "Test Script")
  return (mTestScript,mZippedTestCaseName,mPlainTestCase)

readTCModification :: HandlerError App b TCModification
readTCModification = do
  (mTestScript,mZippedTestCaseName,mPlainTestCase) <- readTCModificationParameters
  case tcModification mTestScript mZippedTestCaseName mPlainTestCase of
    Nothing -> throwError $ strMsg "Some error in test case parameters"
    Just tm -> return tm

tcModification :: Maybe (Maybe TestScriptKey) -> Maybe (Either () UsersFile) -> Maybe String -> Maybe TCModification
tcModification Nothing        _ _                    = Just NoModification
tcModification (Just Nothing) _ _                    = Just TCDelete
tcModification (Just (Just _tsk)) (Just (Left ())) _  = Just NoModification
tcModification (Just (Just tsk)) (Just (Right uf)) _ = Just $ FileOverwrite tsk uf
tcModification (Just (Just tsk)) _ (Just t)          = Just $ TextOverwrite tsk t
tcModification _ _ _                                 = Nothing

-- * Group Assignment

newGroupAssignmentPage :: GETContentHandler
newGroupAssignmentPage = withUserState $ \s -> do
  now <- liftIO $ getCurrentTime
  gk <- getParameter (customGroupKeyPrm groupKeyParamName)
  (g,tss,ufs) <- userStory $ do
    S.isAdministratedGroup gk
    group <- S.loadGroup gk
    tss' <- S.testScriptInfosOfGroup gk
    ufs  <- map fst <$> S.listUsersFiles
    return ((gk, group), nonEmptyList tss', ufs)
  tz <- userTimeZoneToLocalTimeConverter
  renderBootstrapPage . bootStrapUserFrame s . newAssignmentContent $ PD_Group tz now g tss ufs

postGroupAssignment :: POSTContentHandler
postGroupAssignment = do
  CreateGroupAssignment
  <$> getParameter (customGroupKeyPrm (fieldName selectedGroup))
  <*> getValue -- assignment
  <*> readTCCreation

newGroupAssignmentPreviewPage :: ViewPOSTContentHandler
newGroupAssignmentPreviewPage = withUserState $ \s -> do
  gk <- getParameter (customGroupKeyPrm groupKeyParamName)
  assignment <- getValue
  tc <- readTCCreationParameters
  (g,tss,ufs) <- userStory $ do
    S.isAdministratedGroup gk
    group <- S.loadGroup gk
    tss' <- S.testScriptInfosOfGroup gk
    ufs  <- map fst <$> S.listUsersFiles
    return ((gk, group), nonEmptyList tss', ufs)
  tz <- userTimeZoneToLocalTimeConverter
  now <- liftIO $ getCurrentTime
  renderBootstrapPage . bootStrapUserFrame s . newAssignmentContent $
    PD_Group_Preview tz now g tss ufs assignment tc

-- * Modify Assignment

modifyAssignmentPage :: GETContentHandler
modifyAssignmentPage = withUserState $ \s -> do
  ak <- getValue
  (as,tss,ufs,tc) <- userStory $ do
    S.isAdministratedAssignment ak
    as <- S.loadAssignment ak
    tss' <- S.testScriptInfosOfAssignment ak
    ufs  <- map fst <$> S.listUsersFiles
    tc   <- S.testCaseOfAssignment ak
    return (as, nonEmptyList tss', ufs, tc)
  tz <- userTimeZoneToLocalTimeConverter
  renderBootstrapPage . bootStrapUserFrame s . newAssignmentContent $
    PD_Assignment tz ak as tss ufs tc

postModifyAssignment :: POSTContentHandler
postModifyAssignment = do
  ModifyAssignment <$> getValue <*> getValue <*> readTCModification

modifyAssignmentPreviewPage :: ViewPOSTContentHandler
modifyAssignmentPreviewPage = withUserState $ \s -> do
  ak <- getValue
  as <- getValue
  tm <- readTCModificationParameters
  (tss,ufs,tc) <- userStory $ do
    S.isAdministratedAssignment ak
    tss' <- S.testScriptInfosOfAssignment ak
    ufs  <- map fst <$> S.listUsersFiles
    tc   <- S.testCaseOfAssignment ak
    return (nonEmptyList tss', ufs, tc)
  tz <- userTimeZoneToLocalTimeConverter
  renderBootstrapPage . bootStrapUserFrame s . newAssignmentContent $
    PD_Assignment_Preview tz ak as tss ufs tc tm

viewAssignmentPage :: GETContentHandler
viewAssignmentPage = withUserState $ \s -> do
  ak <- getValue
  (as,tss,tc) <- userStory $ do
    S.isAdministratedAssignment ak
    as <- S.loadAssignment ak
    tss' <- S.testScriptInfosOfAssignment ak
    ts   <- S.testCaseOfAssignment ak
    return (as, tss', ts)
  tz <- userTimeZoneToLocalTimeConverter
  let ti = do (_tck, _tc, tsk) <- tc
              Map.lookup tsk $ Map.fromList tss
  renderBootstrapPage . bootStrapUserFrame s .
    newAssignmentContent $ PD_ViewAssignment tz ak as ti tc

-- * Helpers

-- | Returns Nothing if the given list was empty, otherwise Just list
nonEmptyList [] = Nothing
nonEmptyList xs = Just xs
