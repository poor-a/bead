module Bead.Persistence.Guards
  ( doesBlockAssignmentView
  , doesBlockSubmissionView
  , isAccessibleBallotBoxSubmission
  , isAccessibleSubmission
  , isAdministratedAssessment
  , isAdministratedAssignment
  , isAdministratedCourse
  , isAdministratedCourseOfGroup
  , isAdministratedEvaluation
  , isAdminOfGroupOrCourse
  , isAdministratedSubmission
  , isAdministratedTestScript
  , isCourseOrGroupAdmin
  , isInBallotBox
  , isStudentOf
  , isUserOfSubmission
  , isUsersAssignment
  ) where

{-
This module implements guards for persistence layer,
that check if the user is created or have access to the given objects
-}

import           Control.Applicative ((<$>))
import           Control.Monad ((>=>), foldM)
import           Control.Monad.IO.Class (liftIO)
import           Data.List (find, nub)
import           Data.Maybe (isNothing)
import qualified Data.Set as Set
import           Data.Time (getCurrentTime)
import           Data.Tuple.Utils (fst3,thd3)

import           Bead.Domain.Entities
import           Bead.Domain.Relationships
import           Bead.Persistence.Persist
import           Bead.Persistence.Relations

-- * Guards against invalid data modification

-- Returns True if the given user administrates the course of the given
-- group, otherwise False.
isAdministratedCourseOfGroup :: Username -> GroupKey -> Persist Bool
isAdministratedCourseOfGroup u gk = do
  ck <- courseOfGroup gk
  ac <- adminCourse u
  return (ac ck)

-- Returns True if the user administrates the course or one of the
-- groups in the course.
isCourseOrGroupAdmin :: Username -> CourseKey -> Persist Bool
isCourseOrGroupAdmin u ck = do
  adminAGroup <- adminCourseOfGroup u
  cAdmin <- isAdministratedCourse u ck
  return (adminAGroup ck || cAdmin)

-- Returns True if the given user administrates the given group or
-- administrates the course of the group, otherwise False.
isAdminOfGroupOrCourse :: Username -> GroupKey -> Persist Bool
isAdminOfGroupOrCourse u gk = do
  ag <- adminGroup u
  adminedCourse <- isAdministratedCourseOfGroup u gk
  return (ag gk || adminedCourse)

-- Returns True if the given user administrates the given course, otherwise False
isAdministratedCourse :: Username -> CourseKey -> Persist Bool
isAdministratedCourse u ck = do
  ac <- adminCourse u
  return (ac ck)

-- Returns True if the given user administrates the given test script, otherwise False
isAdministratedTestScript :: Username -> TestScriptKey -> Persist Bool
isAdministratedTestScript u tk = do
  tck <- courseOfTestScript tk
  ac  <- adminCourse u
  return (ac tck)

-- Returns True if the given user administrates the given assignment, otherwise False
isAdministratedAssignment :: Username -> AssignmentKey -> Persist Bool
isAdministratedAssignment u ak = do
  key <- courseOrGroupOfAssignment ak
  either course group key
  where
    group gk = do
      ag <- adminGroup u
      ck <- courseOfGroup gk
      as <- adminCourse u
      return (or [ag gk, as ck])

    course ck = do
      ac <- adminCourse u
      ac' <- adminCourseOfGroup u
      return (or [ac ck, ac' ck])

-- Returns True if the given user administrates the given assessment, otherwise False
isAdministratedAssessment :: Username -> AssessmentKey -> Persist Bool
isAdministratedAssessment u ak = do
  key <- courseOrGroupOfAssessment ak
  either course group key
  where
    group gk = do
      ag <- adminGroup u
      ck <- courseOfGroup gk
      as <- adminCourse u
      return (or [ag gk, as ck])

    course ck = do
      ac <- adminCourse u
      ac' <- adminCourseOfGroup u
      return (or [ac ck, ac' ck])

-- Returns True if the given user is a student in a course or group that the given
-- assignment belongs to, otherwise False
isUsersAssignment :: Username -> AssignmentKey -> Persist Bool
isUsersAssignment u ak = do
  key <- courseOrGroupOfAssignment ak
  either (isUserInCourse u) (isUserInGroup u) key

-- Returns True if the given user administrates a course or a group that the given
-- submission belongs to the assignment which belongs to the course or a group, otherwise False
isAdministratedSubmission :: Username -> SubmissionKey -> Persist Bool
isAdministratedSubmission u sk = do
  ak <- assignmentOfSubmission sk
  isAdministratedAssignment u ak

-- Returns True if the given user administrates a course or a group that the given evaluation is belongs to
-- through the submission, assignment path, otherwise False
isAdministratedEvaluation :: Username -> EvaluationKey -> Persist Bool
isAdministratedEvaluation u ek = do
  sk <- submissionOfEvaluation ek
  falseOr (isAdministratedSubmission u) sk
  where
    falseOr k = maybe (return False) k

-- Returns True if the given user submitted the given submission, otherwise false
isUserOfSubmission :: Username -> SubmissionKey -> Persist Bool
isUserOfSubmission u sk = do
  user <- usernameOfSubmission sk
  return (user == u)

-- Returns true if the assignment of submission is in ballot box mode at the
-- moment of the query, otherwise false.
isInBallotBox :: SubmissionKey -> Persist Bool
isInBallotBox sk = do
  ak  <- assignmentOfSubmission sk
  asg <- loadAssignment ak
  now <- liftIO getCurrentTime
  return $ (isBallotBox $ aspects asg) && (start asg <= now && now <= end asg)

-- Returns True if the given user submitted the given submission or
-- administrates a course or group that the submission is submitted
isAccessibleSubmission :: Username -> SubmissionKey -> Persist Bool
isAccessibleSubmission u sk = do
  owns <- isUserOfSubmission u sk
  admined <- isAdministratedSubmission u sk
  return $ or [owns, admined]

-- This action is similar to `isAccessibleSubmission` but it also
-- considers if the assignment of the submission is in ballot box
-- mode at the moment of the query.
isAccessibleBallotBoxSubmission :: Username -> SubmissionKey -> Persist Bool
isAccessibleBallotBoxSubmission u sk = do
  owns    <- isUserOfSubmission u sk
  admined <- isAdministratedSubmission u sk
  boxed   <- isInBallotBox sk
  return $ (owns && not boxed) || admined

-- * Helpers

-- Returns a function that returns True if the user administrates
-- the given course key otherwise False
adminCourse :: Username -> Persist (CourseKey -> Bool)
adminCourse u = do
  cks <- map fst <$> administratedCourses u
  return (\ck -> elem ck cks)

-- Returns a function that returns True if the user administrates
-- the given group key otherwise False
adminGroup :: Username -> Persist (GroupKey -> Bool)
adminGroup u = do
  gks <- concatMap (map fst . thd3) <$> administratedGroups u
  return (\gk -> elem gk gks)

-- Returns a function that returns True if the user administrates a
-- group of a course, otherwise False.
adminCourseOfGroup :: Username -> Persist (CourseKey -> Bool)
adminCourseOfGroup u = do
  gs <- administratedGroups u
  return (\ck -> elem ck (map fst3 gs))

-- Returns True if the given student is in the
-- administrated groups or courses of the user
isStudentOf :: Username -> Username -> Persist Bool
isStudentOf student admin = do
  scourses  <- userCourses student
  sgroups   <- userGroupKeys student
  sgcourses <- mapM courseOfGroup sgroups

  acourses <- map fst <$> administratedCourses admin
  agroups  <- concatMap (map fst . thd3) <$> administratedGroups admin
  return $ or [ hasIntersection (Set.fromList (scourses ++ sgcourses)) (Set.fromList acourses)
              , hasIntersection (Set.fromList sgroups) (Set.fromList agroups)
              ]
  where
    hasIntersection s1 s2 = not . Set.null $ Set.intersection s1 s2

-- Return False if the submissions can not be seen for the student,
-- because there is an other isolated related assignment for the course or group
doesBlockSubmissionView :: Username -> SubmissionKey -> Persist Bool
doesBlockSubmissionView u = assignmentOfSubmission >=> doesBlockAssignmentView u

-- Return False if the submissions for the assignment is hidden for the student,
-- because there is an other isolated related assignment for the course or group
doesBlockAssignmentView :: Username -> AssignmentKey -> Persist Bool
doesBlockAssignmentView u ak = do
  now <- liftIO getCurrentTime
  asg <- loadAssignment ak
  if isActive asg now && isIsolated (aspects asg)
    then return True
    else  do
      key <- courseOrGroupOfAssignment ak
      others <- filter (/= ak) <$> case key of
        Left  ck -> do
          aks <- courseAssignments ck
          gks <- groupsOfUsersCourse u ck
          foldM (\acc gk -> (++ acc) <$> groupAssignments gk) aks gks
        Right gk -> do
          aks  <- courseAssignmentsOfGroup gk
          aks' <- groupAssignments gk
          return (aks ++ aks')
      not <$> foldM (\found ak ->
                        if found
                        then return found
                        else do
                          a <- loadAssignment ak
                          return $ isActive a now && isIsolated (aspects a)
                    )
                    False
                    others

