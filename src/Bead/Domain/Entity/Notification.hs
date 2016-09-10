{-# LANGUAGE DeriveDataTypeable #-}
module Bead.Domain.Entity.Notification where

import Data.Data
import Data.Text
import Data.Time (UTCTime)
import Data.Typeable

import Bead.Domain.Relationships

-- The notifications can come from different sources
data NotificationType
  = Comment    CommentKey
  | Evaluation EvaluationKey
  | Assignment AssignmentKey
  | Assessment AssessmentKey
  | System
  deriving (Eq, Show, Read, Data, Typeable)

notificationType
  comment
  evaluation
  assignment
  assessment
  system
  n = case n of
    Comment    ck -> comment ck
    Evaluation ek -> evaluation ek
    Assignment ak -> assignment ak
    Assessment ak -> assessment ak
    System        -> system

data NotificationState = New | Seen
  deriving (Eq, Show)

data NotificationProcessed = Unprocessed | Processed
  deriving (Eq, Show)

data NotificationReference
  = NRefComment AssignmentKey SubmissionKey CommentKey
  | NRefSubmissionEvaluation AssignmentKey SubmissionKey EvaluationKey
  | NRefScoreEvaluation ScoreKey EvaluationKey
  | NRefAssignment AssignmentKey
  | NRefAssessment AssessmentKey
  | NRefSystem
  deriving (Eq, Show)

notificationReference
  comment
  submission
  score
  assignment
  assessment
  system
  r = case r of
    NRefComment ak sk ck -> comment ak sk ck
    NRefSubmissionEvaluation ak sk ek -> submission ak sk ek
    NRefScoreEvaluation sk ek -> score sk ek
    NRefAssignment ak -> assignment ak
    NRefAssessment ak -> assessment ak
    NRefSystem -> system

-- The notification is rendered for the user on some informational
-- page or send via email.
data Notification = Notification {
    notifMessage :: Text
  , notifDate    :: UTCTime
  , notifType    :: NotificationType
  } deriving (Eq, Show)

notification f (Notification msg date typ) = f msg date typ
