{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE TypeFamilies #-}
module Bead.Persistence.SQL.Class where

import qualified Data.Text as Text
import           Database.Persist.Class
import           Database.Persist.Sql hiding (update, updateField)
import           Text.JSON.Generic (encodeJSON,decodeJSON)

import qualified Bead.Domain.Entities as Domain
import qualified Bead.Domain.Entity.Notification as Domain hiding (NotificationType(..))
import           Bead.Domain.Types (readMaybe)
import qualified Bead.Domain.Relationships as Domain
import           Bead.Persistence.SQL.Entities
import           Bead.Persistence.SQL.JSON

-- * DomainKey and DomainValue definitions

-- | Represents conversational functions between a domain
-- key and an entity key
class DomainKey k where
  type EntityForKey k :: *
  toDomainKey   :: (EntityForKey k ~ record, PersistEntity record) => Key record -> k
  fromDomainKey :: (EntityForKey k ~ record, PersistEntity record) => k -> Key record

-- | Creates a key value from the entity key supposing that the entity key
-- is an integer
entityToDomainKey :: (DomainKey k, PersistEntity record, record ~ EntityForKey k)
                  => (String -> k) -> String -> Key record -> k
entityToDomainKey domainKey name key = persistInt $ keyToValues key where
  persistInt [(PersistInt64 k)] = domainKey $ show k
  persistInt k = persistError name $ concat ["invalid entity key ", show k]

domainKeyToEntityKey :: (Show k, DomainKey k, PersistEntity record, record ~ EntityForKey k)
                     => (k -> String) -> k -> Key record
domainKeyToEntityKey fromDomain key = check . keyFromValues . list . PersistInt64 . readError $ fromDomain key
  where
    readError = maybe (error $ "domainKeyToEntityKey: " ++ show key ++ " ") id . readMaybe
    check = either (persistError "Invalid key" . show) id
    list x = [x]

-- | Converts a domain key to an entity key
toEntityKey :: (PersistEntity record, DomainKey k, record ~ EntityForKey k) => k -> Key record
toEntityKey = fromDomainKey

-- | Converts an entity key to a domain key
fromEntityKey :: (PersistEntity record, DomainKey k, record ~ EntityForKey k) => Key record -> k
fromEntityKey = toDomainKey

-- | Rerpesnts conversional functions between a domain
-- value and persistent value
class DomainValue v where
  type EntityValue v :: *
  toDomainValue      :: (EntityValue v) -> v
  fromDomainValue    :: v -> (EntityValue v)

-- | Converts an entity value to a domain value
fromEntityValue :: (DomainValue v, record ~ EntityValue v) => EntityValue v -> v
fromEntityValue = toDomainValue

-- | Converts a domain value to an entity value
toEntityValue :: (DomainValue v, record ~ EntityValue v) => v -> EntityValue v
toEntityValue = fromDomainValue

-- * Instances

instance DomainValue Domain.User where
  type EntityValue Domain.User = User

  toDomainValue ent = Domain.User
    (decodeRole $ userRole ent)
    (Domain.Username . Text.unpack $ userUsername ent)
    (Domain.Email . Text.unpack $ userEmail ent)
    (Text.unpack $ userName ent)
    (decodeTimeZone $ userTimeZone ent)
    (Domain.Language . Text.unpack $ userLanguage ent)
    (Domain.Uid . Text.unpack $ userUid ent)

  fromDomainValue = Domain.userCata $ \role username email name timezone language uid -> User
    (encodeRole role)
    (Domain.usernameCata Text.pack username)
    (Domain.emailCata Text.pack email)
    (Text.pack name)
    (encodeTimeZone timezone)
    (Domain.languageCata Text.pack language)
    (Domain.uid Text.pack uid)
    ""


instance DomainKey Domain.UserRegKey where
  type EntityForKey Domain.UserRegKey = UserRegistration
  fromDomainKey = domainKeyToEntityKey $ \(Domain.UserRegKey k) -> k
  toDomainKey   = entityToDomainKey Domain.UserRegKey "entityKeyToUserRegKey"

instance DomainValue Domain.UserRegistration where
  type EntityValue Domain.UserRegistration = UserRegistration

  fromDomainValue = Domain.userRegistration $ \username email name token timeout -> UserRegistration
    (Text.pack username)
    (Text.pack email)
    (Text.pack name)
    (Text.pack token)
    timeout

  toDomainValue ent = Domain.UserRegistration
    (Text.unpack $ userRegistrationUsername ent)
    (Text.unpack $ userRegistrationEmail ent)
    (Text.unpack $ userRegistrationName ent)
    (Text.unpack $ userRegistrationToken ent)
    (userRegistrationTimeout ent)


instance DomainKey Domain.CourseKey where
  type EntityForKey Domain.CourseKey = Course
  fromDomainKey = domainKeyToEntityKey $ \(Domain.CourseKey k) -> k
  toDomainKey   = entityToDomainKey Domain.CourseKey "entityKeyToCourseKey"

instance DomainValue Domain.Course where
  type EntityValue Domain.Course = Course

  toDomainValue ent = Domain.Course
    (courseName ent)
    (courseDescription ent)
    (decodeTestScriptType $ courseTestScriptType ent)

  fromDomainValue = Domain.courseCata encodeTestScriptType
    $ \name description testScriptType ->
         Course name
                description
                testScriptType

instance DomainKey Domain.GroupKey where
  type EntityForKey Domain.GroupKey = Group
  fromDomainKey = domainKeyToEntityKey $ \(Domain.GroupKey k) -> k
  toDomainKey   = entityToDomainKey Domain.GroupKey "entityKeyToGroupKey"

instance DomainValue Domain.Group where
  type EntityValue Domain.Group = Group

  toDomainValue ent = Domain.Group
    (groupName ent)
    (groupDescription ent)

  fromDomainValue = Domain.groupCata
        $ \name description ->
            Group name
                  description

instance DomainKey Domain.TestScriptKey where
  type EntityForKey Domain.TestScriptKey = TestScript
  fromDomainKey = domainKeyToEntityKey $ \(Domain.TestScriptKey k) -> k
  toDomainKey   = entityToDomainKey Domain.TestScriptKey "entityKeyToTestScriptKey"

instance DomainValue Domain.TestScript where
  type EntityValue Domain.TestScript = TestScript

  toDomainValue ent = Domain.TestScript
    (testScriptName ent)
    (testScriptDescription ent)
    (testScriptNotes ent)
    (testScriptScript ent)
    (decodeTestScriptType $ testScriptTestScriptType ent)

  fromDomainValue = Domain.testScriptCata encodeTestScriptType
    $ \name desc notes script type_ ->
        TestScript name
                   desc
                   notes
                   script
                   (type_)


instance DomainKey Domain.TestCaseKey where
  type EntityForKey Domain.TestCaseKey = TestCase
  fromDomainKey = domainKeyToEntityKey $ \(Domain.TestCaseKey k) -> k
  toDomainKey   = entityToDomainKey Domain.TestCaseKey "entityKeyToTestCaseKey"

instance DomainValue Domain.TestCase where
  type EntityValue Domain.TestCase = TestCase

  toDomainValue ent = Domain.TestCase
    (testCaseName ent)
    (testCaseDescription ent)
    (case (testCaseSimpleValue ent, testCaseZippedValue ent) of
       (Just simple, Nothing) -> Domain.SimpleTestCase simple
       (Nothing, Just zipped) -> Domain.ZippedTestCase zipped
       (Just _, Just _)   -> error "toDomainTestCase: simple and zipped value were given"
       (Nothing, Nothing) -> error "toDomainTestCase: simple or zipped value were given")
    (testCaseInfo ent)

  fromDomainValue = Domain.testCaseCata id -- encodeTestCaseType
    $ \name desc value {-type_-} info ->
        let (simple, zipped) = Domain.withTestCaseValue
                                 value
                                 (\simple -> (Just simple, Nothing))
                                 (\zipped -> (Nothing, Just zipped))
        in TestCase name
                    desc
                    simple
                    zipped
                    info

instance DomainKey Domain.AssignmentKey where
  type EntityForKey Domain.AssignmentKey = Assignment
  fromDomainKey = domainKeyToEntityKey $ \(Domain.AssignmentKey k) -> k
  toDomainKey   = entityToDomainKey Domain.AssignmentKey "entityKeyToAssignmentKey"

instance DomainKey Domain.SubmissionKey where
  type EntityForKey Domain.SubmissionKey = Submission
  fromDomainKey = domainKeyToEntityKey $ \(Domain.SubmissionKey k) -> k
  toDomainKey   = entityToDomainKey Domain.SubmissionKey "entityKeyToSubmissionKey"

instance DomainValue Domain.Submission where
  type EntityValue Domain.Submission = Submission

  fromDomainValue = Domain.submissionCata $ \submission postDate ->
    let (simple, zipped) = Domain.submissionValue
                             (\simple -> (Just simple, Nothing))
                             (\zipped -> (Nothing, Just zipped))
                             submission
    in Submission simple
                  zipped
                  postDate

  toDomainValue ent =
    Domain.Submission
      (case (submissionSimple ent, submissionZipped ent) of
         (Just simple, Nothing) -> Domain.TextSubmission simple
         (Nothing, Just zipped) -> Domain.ZippedSubmission zipped
         (Nothing, Nothing) -> error "toDomainSubmission: no simple or zipped solution was given."
         (Just _, Just _)   -> error "toDomainSubmission: simple and zipped solution were given.")
      (submissionPostDate ent)

instance DomainKey Domain.EvaluationKey where
  type EntityForKey Domain.EvaluationKey = Evaluation
  fromDomainKey = domainKeyToEntityKey $ \(Domain.EvaluationKey k) -> k
  toDomainKey   = entityToDomainKey Domain.EvaluationKey "entityKeyToEvaluationKey"

instance DomainValue Domain.Evaluation where
  type EntityValue Domain.Evaluation = Evaluation

  fromDomainValue = Domain.evaluationCata $ \result written ->
    Evaluation (encodeEvaluationResult result)
               written

  toDomainValue ent =
    Domain.Evaluation
      (decodeEvaluationResult $ evaluationResult ent)
      (evaluationWritten ent)

instance DomainKey Domain.CommentKey where
  type EntityForKey Domain.CommentKey = Comment
  fromDomainKey = domainKeyToEntityKey $ \(Domain.CommentKey k) -> k
  toDomainKey   = entityToDomainKey Domain.CommentKey "entityKeyToCommentKey"

instance DomainValue Domain.Comment where
  type EntityValue Domain.Comment = Comment

  fromDomainValue = Domain.commentCata $ \cmt author date type_ ->
    Comment cmt
            author
            date
            (encodeCommentType type_)

  toDomainValue ent =
    Domain.Comment
      (commentText ent)
      (commentAuthor ent)
      (commentDate ent)
      (decodeCommentType $ commentType ent)

instance DomainKey Domain.FeedbackKey where
  type EntityForKey Domain.FeedbackKey = Feedback
  fromDomainKey = domainKeyToEntityKey $ \(Domain.FeedbackKey k) -> k
  toDomainKey   = entityToDomainKey Domain.FeedbackKey "entityToFeedbackKey"

instance DomainValue Domain.Feedback where
  type EntityValue Domain.Feedback = Feedback

  fromDomainValue = Domain.feedback encodeFeedbackInfo Feedback

  toDomainValue ent =
    Domain.Feedback
      (decodeFeedbackInfo $ feedbackInfo ent)
      (feedbackDate ent)

instance DomainKey Domain.MossScriptInvocationKey where
  type EntityForKey Domain.MossScriptInvocationKey = MossScriptInvocation
  fromDomainKey = domainKeyToEntityKey $ \(Domain.MossScriptInvocationKey k) -> k
  toDomainKey   = entityToDomainKey Domain.MossScriptInvocationKey "entityToMossReportKey"

instance DomainKey Domain.AssessmentKey where
  type EntityForKey Domain.AssessmentKey = Assessment
  fromDomainKey = domainKeyToEntityKey $ \(Domain.AssessmentKey k) -> k
  toDomainKey   = entityToDomainKey Domain.AssessmentKey "entityToAssessmentKey"

instance DomainValue Domain.Assessment where
  type EntityValue Domain.Assessment = Assessment

  fromDomainValue = Domain.assessment $
    \title desc createdTime cfg visible -> Assessment
      title
      desc
      createdTime
      (encodeEvalConfig cfg)
      visible

  toDomainValue ent = Domain.Assessment title description createdTime evalConfig visible
      where
        title = assessmentTitle ent
        description = assessmentDescription ent
        createdTime = assessmentCreated ent
        evalConfig = decodeEvalConfig $ assessmentEvalConfig ent
        visible = assessmentVisible ent

instance DomainKey Domain.ScoreKey where
  type EntityForKey Domain.ScoreKey = Score
  fromDomainKey = domainKeyToEntityKey $ \(Domain.ScoreKey k) -> k
  toDomainKey   = entityToDomainKey Domain.ScoreKey "entityToScoreKey"

instance DomainValue Domain.Score where
  type EntityValue Domain.Score = Score
  fromDomainValue _s = Score "score"
  toDomainValue _ent = Domain.Score ()

instance DomainKey Domain.NotificationKey where
  type EntityForKey Domain.NotificationKey = Notification
  fromDomainKey = domainKeyToEntityKey $ \(Domain.NotificationKey k) -> k
  toDomainKey   = entityToDomainKey Domain.NotificationKey "entityToNotificationKey"

instance DomainValue Domain.Notification where
  type EntityValue Domain.Notification = Notification
  fromDomainValue = Domain.notification $ \event date typ -> Notification (encodeJSON event) date (encodeJSON typ)
  toDomainValue ent = Domain.Notification (decodeJSON $ notificationEvent ent) (notificationDate ent) (decodeJSON $ notificationType ent)
