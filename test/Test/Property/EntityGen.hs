module Test.Property.EntityGen where

import           Bead.Controller.ServiceContext (UserState(UserNotLoggedIn, UserLoggedIn))
import qualified Bead.View.AuthToken as Auth
import           Bead.View.Translation (Translation(T))
import           Bead.Domain.Entities
import qualified Bead.Domain.Entity.Notification as Notification
import           Bead.Domain.Relationships (CourseKey, GroupKey, HomePageContents)
import qualified Bead.Domain.Relationships as R
import           Bead.Domain.TimeZone (utcZoneInfo, cetZoneInfo)
import           Bead.Domain.Shared.Evaluation

import           Test.Tasty.Arbitrary

import           Control.Monad (join, liftM)
import           Control.Applicative ((<$>),(<*>),pure)
import           Data.String (IsString, fromString)
import           Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.Encoding as TE
import           Data.UUID (UUID)
import qualified Data.UUID as UUID

import qualified Data.ByteString.Char8 as BS (pack)

import System.Exit (ExitCode(ExitFailure))

word :: IsString s => Gen s
word = fromString <$> (listOf1 $ elements ['a' .. 'z' ])
numbers = listOf1 $ elements ['0' .. '9']

manyWords :: IsString s => Gen s
manyWords = do
  w <- word
  ws <- manyWords'
  return $ fromString $ unwords [w, ws]

  where
    manyWords' = listOf1 $ elements ['a' .. 'z']

manyLines :: Gen String
manyLines = unlines <$> listOf1 manyWords

usernames :: Gen Username
usernames = liftM Username (vectorOf 6 $ oneof [capital, digits])
  where
    capital = elements ['A' .. 'Z']

digits :: Gen Char
digits = elements ['0' .. '9']

urls :: Gen String
urls = do
  protocol <- elements ["http", "https"]
  address <- listOf1 $ elements ("/_&=%" ++ ['0'..'9'] ++ ['a'..'z'] ++ ['A'..'Z'])
  return $ concat [protocol, "://", address]

uids = fmap (usernameCata Uid) usernames

roleGen = elements [Student, GroupAdmin, CourseAdmin, Admin]
teacherRoleGen = elements [GroupAdmin, CourseAdmin]
nonTeacherRoleGen = elements [Student, Admin]

emails = do
  user <- word
  domain <- word
  return $ Email $ join [user, "@", domain, ".com"]

familyNames = do
  first <- word
  last <- word
  return $ join [first, " ", last]

languages = Language <$> word

users' :: Role -> Gen User
users' r = User
  <$> (return r)
  <*> usernames
  <*> emails
  <*> familyNames
  <*> (return utcZoneInfo)
  <*> languages
  <*> uids

users :: Gen User
users = roleGen >>= users'

userAndEPwds = do
  user <- users
  code <- numbers
  return (user, code)

fullNames :: Gen String
fullNames = manyWords

userStates :: Gen UserState
userStates = oneof [
    UserLoggedIn
      <$> usernames
      <*> uids
      <*> fullNames
      <*> languages
      <*> roleGen
      <*> (return UUID.nil)
      <*> timeZones
      <*> statusMessages
      <*> homePages
  , UserNotLoggedIn
      <$> languages
  ]

cookies :: Gen Auth.Cookie
cookies = oneof [
    Auth.LoggedInCookie
      <$> usernames
      <*> uids
      <*> fullNames
      <*> languages
      <*> roleGen
      <*> (return UUID.nil)
      <*> timeZones
      <*> statusMessages
      <*> homePages
  , Auth.NotLoggedInCookie
      <$> languages
  ]

homePages :: Gen HomePageContents
homePages = oneof [ return $ R.Welcome
                  , R.StudentView <$> groupKeys
                  , R.GroupOverview <$> groupKeys
                  , R.GroupOverviewAsStudent <$> groupKeys
                  , R.CourseManagement <$> courseKeys
                  , return R.Administration
                  ]

statusMessages :: Gen (Maybe (StatusMessage Translation))
statusMessages = do
  severity <- elements [SmNormal, SmError]
  message <- translations
  elements [Nothing, Just (severity message)]
    where
      translations :: Gen Translation
      translations = do
        n <- elements [1..20]
        s <- manyWords
        return $ T (n, T.pack s)

courseKeys :: Gen CourseKey
courseKeys = R.CourseKey <$> vectorOf 4 digits

courseNames = word

courseDescs = manyWords

evalConfigs = oneof [
    return binaryConfig
  , percentageConfig <$> percentage
  ]

percentage = do
  (_,f) <- properFraction <$> arbitrary
  return $ case f < 0 of
             True  -> (-1.0) * f
             False -> f

courses =
  courseAppAna
    courseNames
    courseDescs
    (elements [TestScriptSimple, TestScriptZipped])

groupKeys :: Gen GroupKey
groupKeys = R.GroupKey <$> vectorOf 4 digits

groupCodes :: Gen String
groupCodes = word

groupNames :: Gen Text
groupNames = manyWords

groupDescs :: Gen Text
groupDescs = manyWords

groupUsers' = liftM (map Username) (listOf1 word)

groups = Group
  <$> groupNames
  <*> groupDescs

timeZones = elements [utcZoneInfo, cetZoneInfo]

exitCodesFailure :: Gen ExitCode
exitCodesFailure = ExitFailure <$> suchThat arbitrary (/= 0)

mossScriptInvocations = oneof [successful, unsuccessful, notInterpretable]
  where
    successful = do
      output <- manyLines
      url <- urls
      return $ MossScriptInvocationSuccess (T.pack output) (T.pack url)

    unsuccessful = do
      output <- manyLines
      exitCode <- exitCodesFailure
      return $ MossScriptInvocationFailure (T.pack output) exitCode

    notInterpretable = do
      output <- manyLines
      return $ MossScriptInvocationNotInterpretableOutput (T.pack output)

assignments start end = assignmentAna
  assignmentNames
  assignmentDescs
  assignmentTypeGen
  (return start)
  (return end)
  evaluationConfigs

assignmentNames :: Gen Text
assignmentNames = manyWords

assignmentDescs :: Gen Text
assignmentDescs = manyWords

assignmentTCss :: IsString s => Gen s
assignmentTCss = manyWords

assignmentTypeGen = oneof [
    (return emptyAspects)
  , (return $ aspectsFromList [BallotBox])
  , (do pwd <- word; return $ aspectsFromList [Password pwd])
  , (do pwd <- word; return $ aspectsFromList [Password pwd, BallotBox])
  ]

evaluationConfigs = oneof [
    (return binaryConfig)
  , percentageConfig <$> percentage
  ]

passwords :: IsString s => Gen s
passwords = word

solutionValues = oneof [
    TextSubmission <$> solutionTexts
  , ZippedSubmission . TE.encodeUtf8 <$> solutionTexts
  ]

submissions date = Submission
  <$> solutionValues
  <*> (return date)

commentTypes = elements [CT_Student, CT_GroupAdmin, CT_CourseAdmin, CT_Admin]

comments date = Comment
  <$> commentTexts
  <*> commentAuthors
  <*> (return date)
  <*> commentTypes

solutionTexts :: Gen Text
solutionTexts = manyWords

commentTexts = manyWords

commentAuthors = manyWords

evaluations :: EvConfig -> Gen Evaluation
evaluations cfg = Evaluation
  <$> evaluationResults cfg
  <*> writtenEvaluations

writtenEvaluations = manyWords

evaluationResults =
  evConfigCata
    (binaryResult <$> elements [Passed, Failed])
    (const (percentageResult <$> percentage))
    arbitrary

testScripts = testScriptAppAna
  word      -- words
  manyWords -- desc
  manyWords -- notes
  manyWords -- script
  enumGen   -- type

testCases = oneof [
    TestCase <$> word <*> manyWords <*> (SimpleTestCase <$> manyWords) <*> manyWords
  , TestCase <$> word <*> manyWords <*> (ZippedTestCase . BS.pack <$> manyWords) <*> manyWords
  ]

-- Ensure list of feedbacks contains a TestResult.
testFeedbackInfo :: Gen [FeedbackInfo]
testFeedbackInfo = do
  result <- TestResult <$> arbitrary
  msgForStudent <- MessageForStudent <$> manyWords
  msgForAdmin <- MessageForAdmin <$> manyWords
  (result :) <$> sublistOf [msgForStudent, msgForAdmin]

feedbacks date = Feedback <$> (testFeedbackInfo >>= elements) <*> (return date)

scores :: Gen Score
scores = arbitrary

date = read "2016-01-22 14:41:26 UTC"

assessments = Assessment <$> manyWords <*> manyWords <*> pure date <*> evalConfigs <*> arbitrary

notifEvents = oneof
  [ Notification.NE_CourseAdminCreated <$> manyWords
  , Notification.NE_CourseAdminAssigned <$> manyWords <*> manyWords
  , Notification.NE_TestScriptCreated <$> manyWords <*> manyWords
  , Notification.NE_TestScriptUpdated <$> manyWords <*> manyWords <*> manyWords
  , Notification.NE_RemovedFromGroup <$> manyWords <*> manyWords
  , Notification.NE_GroupAdminCreated <$> manyWords <*> manyWords <*> manyWords
  , Notification.NE_GroupAssigned <$> manyWords <*> manyWords <*> manyWords <*> manyWords
  , Notification.NE_GroupCreated <$> manyWords <*> manyWords <*> manyWords
  , Notification.NE_GroupAssignmentCreated <$> manyWords <*> manyWords <*> manyWords <*> manyWords
  , Notification.NE_CourseAssignmentCreated <$> manyWords <*> manyWords <*> manyWords
  , Notification.NE_GroupAssessmentCreated <$> manyWords <*> manyWords <*> manyWords <*> manyWords
  , Notification.NE_CourseAssessmentCreated <$> manyWords <*> manyWords <*> manyWords
  , Notification.NE_AssessmentUpdated <$> manyWords <*> manyWords
  , Notification.NE_AssignmentUpdated <$> manyWords <*> manyWords
  , Notification.NE_EvaluationCreated <$> manyWords <*> manyWords
  , Notification.NE_AssessmentEvaluationUpdated <$> manyWords <*> manyWords
  , Notification.NE_AssignmentEvaluationUpdated <$> manyWords <*> manyWords
  , Notification.NE_CommentCreated <$> manyWords <*> manyWords <*> manyWords
  ]

notifications =
  Notification.Notification <$> notifEvents <*> pure date <*> pure Notification.System

