{-# LANGUAGE CPP #-}
{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}
module Bead.Domain.Relationships where

import Data.Aeson (toJSON, toEncoding)
import Data.Aeson.Encoding (text)
import qualified Data.Aeson as Aeson
import Data.Ord (Down(..))
import Data.Data
import Data.Hashable (Hashable)
import Data.HashMap.Strict (HashMap)
import qualified Data.HashMap.Strict as HashMap
import Data.List as List hiding (group)
import Data.Map (Map)
import Data.Text (Text)
import qualified Data.Text as T
import Data.Time (UTCTime(..))
import Data.Tuple.Utils (fst3, snd3, thd3)
import GHC.Generics (Generic)

import Bead.Domain.Entities
import Bead.Domain.Evaluation
import qualified Bead.Domain.Entity.Assignment as Assignment

#ifdef TEST
import Test.Tasty.Arbitrary
import Test.Tasty.TestSet
#endif

-- * Relations

-- The submission limitation for an assignment
data SubmissionLimitF a
  = Unlimited a -- Unlimited submissions are allowed
  | Remaining Int a -- Positive number of the remaning submission
  | Reached a -- The submission limit is already reached
  deriving (Eq, Functor, Show, Ord)

type SubmissionLimit = SubmissionLimitF ()

unlimited   = Unlimited ()
remaining x = Remaining x ()
reached     = Reached ()

submissionLimit
  unlimited
  remaining
  reached
  sl = case sl of
    Unlimited x   -> unlimited x
    Remaining n x -> remaining n x
    Reached x     -> reached x

-- Calc the Submission Limit for the assignment and the given number of submissions
calcSubLimit :: Assignment -> Int -> SubmissionLimit
calcSubLimit assignment noOfSubmissions = noOfTries unlimited limited $ aspects assignment
  where
    limited limit =
      let rest = limit - noOfSubmissions
      in if rest > 0 then (remaining rest) else reached

#ifdef TEST
calcSubLimitTests = group "calcSubLimit" $ do
  assertProperty
      "No no of tries given"
      (==unlimited)
      (do asg <- fmap clear arbitrary
          sbm <- choose (-100, 100)
          return $ calcSubLimit asg sbm)
      "No of tries is recognized"
  assertProperty
      "No of tries is given and exceeds the limit"
      (==reached)
      (do lmt <- choose (1,100)
          asg <- fmap (set lmt) arbitrary
          sbm <- choose (lmt,lmt + 100)
          return $ calcSubLimit asg sbm)
      "Limit is not reached"
  assertProperty
      "Submissions are not reached the limit"
      (\(lmt,sbm,sbl) -> remaining (lmt - sbm) == sbl)
      (do lmt <- choose (1,100)
          asg <- fmap (set lmt) arbitrary
          sbm <- choose (0,lmt-1)
          return $ (lmt,sbm,calcSubLimit asg sbm))
      "Remaining is not calculated properly"
  where
    clear a = a {aspects = clearNoOfTries (aspects a)}
    set n a = a {aspects = setNoOfTries n (aspects a)}
#endif

data SubmissionDesc = SubmissionDesc {
    eCourse   :: Course
  , eGroup    :: Maybe Group
  , eStudent  :: User
  , eSolution :: Submission
  , eSubmissionInfo :: SubmissionInfo
  , eAssignmentKey   :: AssignmentKey
  , eAssignment      :: Assignment
  , eAssignmentDate  :: UTCTime
  , eComments :: Map CommentKey Comment
  , eFeedbacks :: [Feedback]
  }

-- | Returns a pair of filename and extension from a `SubmissionDesc`.
submissionFilename :: User -> Submission -> (String, String)
submissionFilename u s = (basename, ext)
    where
      basename = concat [u_name u, " (", uid id . u_uid $ u, ")"]
      ext = submissionValue (const "txt") (const "zip") (solution s)

submissionDescPermissions = ObjectPermissions [
    (P_Open, P_Group), (P_Open, P_Course)
  , (P_Open, P_Submission), (P_Open, P_Assignment)
  , (P_Open, P_Comment)
  ]

-- Sets of the submission which are not evaluated yet.
data OpenedSubmissionsS a = OpenedSubmissions {
    osAdminedCourse :: [(SubmissionKey, a)]
    -- ^ Submissions by the users which are in the set of the users which attends on a course
    -- which is related to the user's registered group, and attends one of the user's group
  , osAdminedGroup  :: [(SubmissionKey, a)]
    -- ^ Submissions by the users which are in the set of the users which attends on the user's groups
  , osRelatedCourse :: [(SubmissionKey, a)]
    -- ^ Submissions by the users which are in the set of the users which attends on a course
    -- which is related to the user's registered group, and does not attend one of the user's group
  }

type OpenedSubmissions = OpenedSubmissionsS SubmissionDesc

openedSubmissionsCata f (OpenedSubmissions admincourse admingroup relatedcourse)
  = f admincourse admingroup relatedcourse

-- Sorts the given submission list description into descending order, by
-- the times of the given submissions
sortSbmDescendingByTime :: [SubmissionInfo] -> [SubmissionInfo]
sortSbmDescendingByTime = List.sortOn (Down . thd3)

data SubmissionDetailsDesc = SubmissionDetailsDesc {
    sdCourse :: Course
  , sdGroup :: Maybe Group
  , sdAssignment :: Assignment
  , sdStatus :: Maybe Text
  , sdSubmission :: Text
  , sdComments :: Map CommentKey Comment
  , sdFeedbacks :: [Feedback]
  }

submissionDetailsDescPermissions = ObjectPermissions [
    (P_Open, P_Group), (P_Open, P_Course)
  , (P_Open, P_Assignment), (P_Open, P_Submission)
  , (P_Open, P_Comment)
  ]

-- |A 'SubmissionInfo' consists of a key, a state and a post time.
type SubmissionInfo = (SubmissionKey, SubmissionState, UTCTime)

submKeyAndState :: SubmissionInfo -> (SubmissionKey, SubmissionState)
submKeyAndState (key, state, _time) = (key, state)

submKey :: SubmissionInfo -> SubmissionKey
submKey = fst3

submState :: SubmissionInfo -> SubmissionState
submState = snd3

submTime :: SubmissionInfo -> UTCTime
submTime = thd3

-- | Information about a submission for a given assignment
data SubmissionState
  = Submission_Unevaluated
    -- ^ Submission is not evaluated yet.
  | Submission_QueuedForTest
    -- ^ Submission is waiting to be tested.
  | Submission_Tested Bool
    -- ^ Submission is tested by the automated testing framework.
    -- The parameter is True if the submission has passed the tests, and False if has failed
    -- the tests.
  | Submission_Result EvaluationKey EvResult
    -- ^ Submission is evaluated.
  deriving (Eq, Show)

instance Aeson.ToJSON SubmissionState where
  toJSON Submission_Unevaluated = Aeson.String "Unevaluated"
  toJSON Submission_QueuedForTest = Aeson.String "QueuedForTest"
  toJSON (Submission_Tested passed) = Aeson.String (if passed then "TestsPassed" else "TestsFailed")
  toJSON (Submission_Result _ result) = toJSON result

  toEncoding Submission_Unevaluated = text "Unevaluated"
  toEncoding Submission_QueuedForTest = text "QueuedForTest"
  toEncoding (Submission_Tested passed) = text (if passed then "TestsPassed" else "TestsFailed")
  toEncoding (Submission_Result _ result) = toEncoding result

submissionStateCata :: a -> a -> (Bool -> a) -> (EvaluationKey -> EvResult -> a) -> SubmissionState -> a
submissionStateCata
  unevaluated
  queued
  tested
  result
  s = case s of
    Submission_Unevaluated -> unevaluated
    Submission_QueuedForTest -> queued
    Submission_Tested r    -> tested r
    Submission_Result k r  -> result k r

withSubmissionState :: SubmissionState -> a -> a -> (Bool -> a) -> (EvaluationKey -> EvResult -> a) -> a
withSubmissionState s unevaluated queuedForTest tested result
  = submissionStateCata unevaluated queuedForTest tested result s

siEvaluationKey :: SubmissionState -> Maybe EvaluationKey
siEvaluationKey = submissionStateCata
  Nothing -- unevaluated
  Nothing -- queued for test
  (const Nothing) -- tested
  (\key _result -> Just key) -- result

-- Information to display on the UI
data TestScriptInfo = TestScriptInfo {
    tsiName :: Text
  , tsiDescription :: Text
  , tsiType :: TestScriptType
  }

data SubmissionTableInfo
  = CourseSubmissionTableInfo {
      stiUsers       :: [Username]      -- Alphabetically ordered list of usernames
    , stiAssignments :: [(AssignmentKey, Assignment, HasTestCase)] -- Cronologically ordered list of assignments
    , stiUserLines   :: [(UserDesc, [Maybe (SubmissionKey, SubmissionState)])]
    , stiGroups :: Map Username (Group, [User])
    , stiCourseKey :: CourseKey
    }
  | GroupSubmissionTableInfo {
      stiUsers      :: [Username] -- Alphabetically ordered list of usernames
    , stiCGAssignments :: [CGInfo (AssignmentKey, Assignment, HasTestCase)] -- Cronologically ordered list of course and group assignments
    , stiUserLines :: [(UserDesc, [Maybe (SubmissionKey, SubmissionState)])]
    , stiCourseKey :: CourseKey
    , stiGroupKey :: GroupKey
    }

submissionTableInfoCata
  course
  group
  ti = case ti of
    CourseSubmissionTableInfo users asgs lines groups key ->
                       course users asgs lines groups key
    GroupSubmissionTableInfo  users asgs lines ckey gkey ->
                       group  users asgs lines ckey gkey

submissionTableInfoToCourseGroupKey :: SubmissionTableInfo -> Either CourseKey GroupKey
submissionTableInfoToCourseGroupKey t@(CourseSubmissionTableInfo {}) = Left $ stiCourseKey t
submissionTableInfoToCourseGroupKey t@(GroupSubmissionTableInfo {}) = Right $ stiGroupKey t

submissionTableInfoPermissions = ObjectPermissions [
    (P_Open, P_Course), (P_Open, P_Assignment)
  ]

data TCCreation
  = NoCreation
  | FileCreation TestScriptKey (UsersFile FilePath)
  | TextCreation TestScriptKey Text
  deriving (Eq)

tcCreationCata
  noCreation
  fileCreation
  textCreation
  t = case t of
    NoCreation -> noCreation
    FileCreation tsk uf -> fileCreation tsk uf
    TextCreation tsk t  -> textCreation tsk t

data TCModification
  = NoModification
  | FileOverwrite TestScriptKey (UsersFile FilePath)
  | TextOverwrite TestScriptKey Text
  | TCDelete
  deriving (Eq)

tcModificationCata
  noModification
  fileOverwrite
  textOverwrite
  delete
  t = case t of
    NoModification -> noModification
    FileOverwrite tsk uf -> fileOverwrite tsk uf
    TextOverwrite tsk t  -> textOverwrite tsk t
    TCDelete -> delete

-- * Entity keys

newtype AssignmentKey = AssignmentKey String
  deriving (Eq, Ord, Show, Read, Data, Typeable, Generic)

instance Hashable AssignmentKey

assignmentKeyMap :: (String -> a) -> AssignmentKey -> a
assignmentKeyMap f (AssignmentKey x) = f x

newtype UserRegKey = UserRegKey String
  deriving (Eq, Ord, Show)

userRegKeyFold :: (String -> a) -> UserRegKey -> a
userRegKeyFold f (UserRegKey x) = f x

newtype CommentKey = CommentKey String
  deriving (Eq, Ord, Show, Read, Data, Typeable)

newtype SubmissionKey = SubmissionKey String
  deriving (Eq, Ord, Show, Read, Data, Typeable, Generic)

instance Hashable SubmissionKey

submissionKeyMap :: (String -> a) -> SubmissionKey -> a
submissionKeyMap f (SubmissionKey s) = f s

withSubmissionKey s f = submissionKeyMap f s

newtype MossScriptInvocationKey = MossScriptInvocationKey String
  deriving (Eq, Show)

mossScriptInvocationKey :: (String -> a) -> MossScriptInvocationKey -> a
mossScriptInvocationKey f (MossScriptInvocationKey k) = f k

-- Key for a given Test Script in the persistence layer
newtype TestScriptKey = TestScriptKey String
  deriving (Data, Eq, Ord, Show, Read, Typeable)

-- Template function for the TestScriptKey value
testScriptKeyCata f (TestScriptKey x) = f x

-- Key for a given Test Case in the persistence layer
newtype TestCaseKey = TestCaseKey String
  deriving (Eq, Ord, Show)

-- Template function for the TestCaseKey value
testCaseKeyCata f (TestCaseKey x) = f x

newtype CourseKey = CourseKey String
  deriving (Generic, Data, Eq, Ord, Show, Typeable)

instance Hashable CourseKey

courseKeyMap :: (String -> a) -> CourseKey -> a
courseKeyMap f (CourseKey g) = f g

newtype GroupKey = GroupKey String
  deriving (Generic, Data, Eq, Ord, Show, Typeable)

instance Hashable GroupKey

groupKeyMap :: (String -> a) -> GroupKey -> a
groupKeyMap f (GroupKey g) = f g

newtype EvaluationKey = EvaluationKey String
  deriving (Eq, Ord, Show, Read, Data, Typeable)

evaluationKeyMap :: (String -> a) -> EvaluationKey -> a
evaluationKeyMap f (EvaluationKey e) = f e

newtype FeedbackKey = FeedbackKey String
  deriving (Eq, Ord, Show)

feedbackKey f (FeedbackKey x) = f x

newtype ScoreKey = ScoreKey String
  deriving (Eq, Ord, Show, Read, Data, Typeable)

scoreKey f (ScoreKey x) = f x

newtype AssessmentKey = AssessmentKey String
  deriving (Eq, Ord, Show, Read, Data, Typeable)

assessmentKey f (AssessmentKey x) = f x

newtype NotificationKey = NotificationKey String
  deriving (Eq, Ord, Show)

notificationKey f (NotificationKey x) = f x

-- | Information about a score for a given assessment
newtype ScoreInfo = ScoreInfo (ScoreKey, EvaluationKey, EvResult)
  deriving (Eq)

scoreInfoCata :: (ScoreKey -> EvaluationKey -> EvResult -> a) -> ScoreInfo -> a
scoreInfoCata f (ScoreInfo (sKey, evKey, result)) = f sKey evKey result

scoreKeyOfInfo :: ScoreInfo -> ScoreKey
scoreKeyOfInfo = scoreInfoCata (\sk _ _ -> sk)

evaluationKeyOfInfo :: ScoreInfo -> EvaluationKey
evaluationKeyOfInfo = scoreInfoCata (\_ ek _ -> ek)

evaluationOfInfo :: ScoreInfo -> EvResult
evaluationOfInfo = scoreInfoCata (\_ _ e -> e)

-- | The scoreboard summarizes the information for a course or group related
-- assessments and the evaluation for the assessment.
data ScoreBoard =
    CourseScoreBoard {
        sbAssessments :: [(AssessmentKey, Assessment)]
      , sbUserLines :: [(UserDesc, [Maybe ScoreInfo])]
      }
  | GroupScoreBoard {
        sbAssessments :: [(AssessmentKey, Assessment)]
      , sbUserLines :: [(UserDesc, [Maybe ScoreInfo])]
      }
  deriving Eq

scoreBoardCata course group scoreBoard =
  case scoreBoard of
    CourseScoreBoard assessments userLines ->
      course assessments userLines
    GroupScoreBoard assessments userLines ->
      group assessments userLines

scoreBoardPermissions = ObjectPermissions
  [ (P_Open, P_Group), (P_Open, P_Assessment) ]

data AssessmentDesc = AssessmentDesc {
    adCourse        :: Text
  , adGroup         :: Maybe Text
  , adTeacher       :: [String]
  , adAssessmentKey :: AssessmentKey
  , adAssessment    :: Assessment
  }

data ScoreDesc = ScoreDesc {
      scdCourse     :: Course
    , scdGroup      :: Maybe Group
    , scdScore      :: ScoreKey
    , scdScoreInfo  :: Maybe (ScoreInfo)
    , scdAssessment :: Assessment
    }

scoreDescPermissions = ObjectPermissions [
    (P_Open, P_Group), (P_Open, P_Course)
  ]

-- * Default page to show for a logged-in user when URL path is "/"

data HomePageContents
  = Welcome
  | StudentView GroupKey
  | GroupOverview GroupKey
  | GroupOverviewAsStudent GroupKey
  | CourseManagement CourseKey
  | Administration
  deriving (Eq, Show, Data)

homePageContentsCata :: a -> (GroupKey -> a) -> (GroupKey -> a) -> (GroupKey -> a) -> (CourseKey -> a) -> a -> HomePageContents -> a
homePageContentsCata welcome studentView groupOverview groupOverviewAsStudent courseManagement administration homePage =
  case homePage of
    Welcome -> welcome
    StudentView gk -> studentView gk
    GroupOverview gk -> groupOverview gk
    GroupOverviewAsStudent gk -> groupOverviewAsStudent gk
    CourseManagement ck -> courseManagement ck
    Administration -> administration

-- Default page at log-in
defaultHomePage :: Role -> HomePageContents
defaultHomePage Admin = Administration
defaultHomePage _     = Welcome

#ifdef TEST
relationshipTests = group "Bead.Domain.Relationships" $ do
  calcSubLimitTests
#endif
