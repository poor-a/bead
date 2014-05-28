module Bead.Persistence.Persist (
    Persist
  , runPersist

  , saveUser
  , personalInfo
  , filterUsers
  , loadUser
  , updateUser
  , doesUserExist
  , userDescription
  , userSubmissions
  , administratedCourses
  , administratedGroups

  -- Users file upload
  , copyFile  -- Copies the given file with the given filename to the users data directory
  , listFiles -- List all the user's files
  , getFile   -- Get the current path for the user's file

  -- Registration
  , saveUserReg
  , loadUserReg

  -- Course Persistence
  , saveCourse
  , courseKeys
  , filterCourses
  , loadCourse
  , groupKeysOfCourse
  , isUserInCourse
  , userCourses
  , createCourseAdmin
  , courseAdmins
  , subscribedToCourse
  , unsubscribedFromCourse
  , testScriptsOfCourse

  -- Group Persistence
  , saveGroup
  , loadGroup
  , courseOfGroup
  , filterGroups
  , isUserInGroup
  , userGroups
  , subscribe
  , unsubscribe
  , groupAdmins
  , createGroupAdmin
  , subscribedToGroup
  , unsubscribedFromGroup

  -- Test Scripts
  , saveTestScript
  , loadTestScript
  , courseOfTestScript
  , modifyTestScript

  -- Test Cases
  , saveTestCase
  , loadTestCase
  , assignmentOfTestCase
  , testScriptOfTestCase
  , modifyTestCase
  , removeTestCaseAssignment
  , copyTestCaseFile
  , modifyTestScriptOfTestCase

  -- Test Jobs
  , saveTestJob -- Saves the test job for the test daemon

  -- Test Comments
  , testComments
  , deleteTestComment -- Deletes the test daemon's comment from the test-incomming

  -- Assignment Persistence
  , assignmentKeys
  , saveAssignment
  , loadAssignment
  , modifyAssignment
  , courseAssignments
  , groupAssignments
  , saveCourseAssignment
  , saveGroupAssignment
  , courseOfAssignment
  , groupOfAssignment
  , submissionsForAssignment
  , assignmentCreatedTime
  , testCaseOfAssignment

  -- Submission
  , saveSubmission
  , loadSubmission
  , assignmentOfSubmission
  , usernameOfSubmission
  , submissionKeys
  , evaluationOfSubmission
  , commentsOfSubmission
  , lastSubmission

  , removeFromOpened
  , openedSubmissions
  , usersOpenedSubmissions

  -- Evaluation
  , saveEvaluation
  , loadEvaluation
  , modifyEvaluation
  , submissionOfEvaluation

  -- Comment
  , saveComment
  , loadComment
  , submissionOfComment

  -- Persistence initialization
  , isPersistenceSetUp
  , initPersistence
  ) where

import           Data.Time (UTCTime)

import           Bead.Domain.Types (Erroneous)
import           Bead.Domain.Entities
import           Bead.Domain.Relationships

import qualified Bead.Persistence.NoSQLDir as PersistImpl

type Persist a = PersistImpl.Persist a

-- Save the current user
saveUser :: User -> Persist ()
saveUser = PersistImpl.saveUser

-- Calculates the personal information about the user
personalInfo :: Username -> Persist PersonalInfo
personalInfo = PersistImpl.personalInfo

-- Select users who satiesfies the given predicate
filterUsers :: (User -> Bool) -> Persist [User]
filterUsers = PersistImpl.filterUsers

-- Loads the user information for the given username
loadUser :: Username -> Persist User
loadUser = PersistImpl.loadUser

-- Updates the user information
updateUser :: User -> Persist ()
updateUser = PersistImpl.updateUser

-- Checks if the user is already in the database
doesUserExist :: Username -> Persist Bool
doesUserExist = PersistImpl.doesUserExist

-- Creates a description for the given username
userDescription :: Username -> Persist UserDesc
userDescription = PersistImpl.userDescription

-- Lists all the submission keys for the submissions that submitted by the user
-- for the given assignment
userSubmissions :: Username -> AssignmentKey -> Persist [SubmissionKey]
userSubmissions = PersistImpl.userSubmissions

-- Lists all the courses that are administrated by the user
administratedCourses :: Username -> Persist [(CourseKey, Course)]
administratedCourses = PersistImpl.administratedCourses

-- Lists all the groups that are administrated by the user
administratedGroups :: Username -> Persist [(GroupKey, Group)]
administratedGroups = PersistImpl.administratedGroups

-- * Users file upload

copyFile :: Username -> FilePath -> UsersFile -> Persist () -- Copies the given file with the given filename to the users data directory
copyFile = PersistImpl.copyFile

listFiles :: Username -> Persist [(UsersFile, FileInfo)] -- List all the user's files
listFiles = PersistImpl.listFiles

getFile :: Username -> UsersFile -> Persist FilePath -- Get the current path for the user's file
getFile = PersistImpl.getFile

-- * Registration

-- Save the user registration information which is created at the time, when the
-- user starts a new registration
saveUserReg :: UserRegistration -> Persist UserRegKey
saveUserReg = PersistImpl.saveUserReg

-- Loads the user registration
loadUserReg :: UserRegKey -> Persist UserRegistration
loadUserReg = PersistImpl.loadUserReg

-- * Course Persistence

-- Saves a Course into the database
saveCourse :: Course -> Persist CourseKey
saveCourse = PersistImpl.saveCourse

-- Lists all the course keys saved in the database
courseKeys :: Persist [CourseKey]
courseKeys = PersistImpl.courseKeys

-- Selects all the courses with satisfies the given property
filterCourses :: (CourseKey -> Course -> Bool) -> Persist [(CourseKey, Course)]
filterCourses = PersistImpl.filterCourses

-- Load the course from the database
loadCourse :: CourseKey -> Persist Course
loadCourse = PersistImpl.loadCourse

-- Lists all the groups keys for the given course, the listed groups
-- are the groups under the given course
groupKeysOfCourse :: CourseKey -> Persist [GroupKey]
groupKeysOfCourse = PersistImpl.groupKeysOfCourse

-- Checks if the user attends the given course
isUserInCourse :: Username -> CourseKey -> Persist Bool
isUserInCourse = PersistImpl.isUserInCourse

-- Lists all the courses which the user attends
userCourses :: Username -> Persist [CourseKey]
userCourses = PersistImpl.userCourses

-- Set the given user as an administrator for the course
createCourseAdmin :: Username -> CourseKey -> Persist ()
createCourseAdmin = PersistImpl.createCourseAdmin

-- Lists all the users which are administrators of the given course
courseAdmins :: CourseKey -> Persist [Username]
courseAdmins = PersistImpl.courseAdmins

-- Lists all the users that are attends as a student on the given course
subscribedToCourse :: CourseKey -> Persist [Username]
subscribedToCourse = PersistImpl.subscribedToCourse

-- Lists all the users that are unsubscribed once from the given course
unsubscribedFromCourse :: CourseKey -> Persist [Username]
unsubscribedFromCourse = PersistImpl.unsubscribedFromCourse

-- Lists all the test scripts that are connected with the course
testScriptsOfCourse :: CourseKey -> Persist [TestScriptKey]
testScriptsOfCourse = PersistImpl.testScriptsOfCourse

-- * Group Persistence

-- Save the group under the given course
saveGroup :: CourseKey -> Group -> Persist GroupKey
saveGroup = PersistImpl.saveGroup

-- Load the group from the database
loadGroup :: GroupKey -> Persist Group
loadGroup = PersistImpl.loadGroup

-- Returns the course of the given group
courseOfGroup :: GroupKey -> Persist CourseKey
courseOfGroup = PersistImpl.courseOfGroup

-- Lists all the groups from the database that satisfies the given predicate
filterGroups :: (GroupKey -> Group -> Bool) -> Persist [(GroupKey, Group)]
filterGroups = PersistImpl.filterGroups

-- Returns True if the user is registered in the group, otherwise False
isUserInGroup :: Username -> GroupKey -> Persist Bool
isUserInGroup = PersistImpl.isUserInGroup

-- Lists all the groups that the user is attended in
userGroups :: Username -> Persist [GroupKey]
userGroups = PersistImpl.userGroups

-- Subscribe the user for the given course and group
subscribe :: Username -> CourseKey -> GroupKey -> Persist ()
subscribe = PersistImpl.subscribe

-- Unsubscribe the user from the given course and group,
-- if the user is not subscribed nothing happens
unsubscribe :: Username -> CourseKey -> GroupKey -> Persist ()
unsubscribe = PersistImpl.unsubscribe

-- Lists all the group admins for the given course
groupAdmins :: GroupKey -> Persist [Username]
groupAdmins = PersistImpl.groupAdmins

-- Set the given user for the given group
createGroupAdmin :: Username -> GroupKey -> Persist ()
createGroupAdmin = PersistImpl.createGroupAdmin

-- Lists all the users that are subscribed to the given group
subscribedToGroup :: GroupKey -> Persist [Username]
subscribedToGroup = PersistImpl.subscribedToGroup

-- Lists all the users that are unsubscribed from the given group at least once
unsubscribedFromGroup :: GroupKey -> Persist [Username]
unsubscribedFromGroup = PersistImpl.unsubscribedFromGroup

-- * Test Scripts

-- Saves the test script for the given course
saveTestScript :: CourseKey -> TestScript -> Persist TestScriptKey
saveTestScript = PersistImpl.saveTestScript

-- Load the test script from the database
loadTestScript :: TestScriptKey -> Persist TestScript
loadTestScript = PersistImpl.loadTestScript

-- Returns the course of the test script
courseOfTestScript :: TestScriptKey -> Persist CourseKey
courseOfTestScript = PersistImpl.courseOfTestScript

-- Updates the test script for the given test script key
modifyTestScript :: TestScriptKey -> TestScript -> Persist ()
modifyTestScript = PersistImpl.modifyTestScript

-- *  Test Cases

-- Saves the test case for the given assignment and given test script
saveTestCase :: TestScriptKey -> AssignmentKey -> TestCase -> Persist TestCaseKey
saveTestCase = PersistImpl.saveTestCase

-- Loads the test case from the database
loadTestCase :: TestCaseKey -> Persist TestCase
loadTestCase = PersistImpl.loadTestCase

-- Returns the assignment of the given test case
assignmentOfTestCase :: TestCaseKey -> Persist AssignmentKey
assignmentOfTestCase = PersistImpl.assignmentOfTestCase

-- Returns the test script of the given test case
testScriptOfTestCase :: TestCaseKey -> Persist TestScriptKey
testScriptOfTestCase = PersistImpl.testScriptOfTestCase

-- Updates the test case for the given test case key
modifyTestCase :: TestCaseKey -> TestCase -> Persist ()
modifyTestCase = PersistImpl.modifyTestCase

-- Deletes the link from the test case connected to an assignment
-- TODO: This could introduce a bug
removeTestCaseAssignment :: TestCaseKey -> AssignmentKey -> Persist ()
removeTestCaseAssignment = PersistImpl.removeTestCaseAssignment

copyTestCaseFile :: TestCaseKey -> Username -> UsersFile -> Persist ()
copyTestCaseFile = PersistImpl.copyTestCaseFile

modifyTestScriptOfTestCase :: TestCaseKey -> TestScriptKey -> Persist ()
modifyTestScriptOfTestCase = PersistImpl.modifyTestScriptOfTestCase

-- * Test Jobs

saveTestJob :: SubmissionKey -> Persist () -- Saves the test job for the test daemon
saveTestJob = PersistImpl.saveTestJob

-- * Test Comments

-- | List the comments that the test daemon left in the test-incomming, comment for the
-- groups admin, and comments for the student
testComments :: Persist [(SubmissionKey, Comment)]
testComments = PersistImpl.testComments

-- Deletes the test daemon's comment from the test-incomming
deleteTestComment :: SubmissionKey -> Persist ()
deleteTestComment = PersistImpl.deleteTestComment

-- * Assignment Persistence

-- Lists all the assignments in the database
assignmentKeys :: Persist [AssignmentKey]
assignmentKeys = PersistImpl.assignmentKeys

-- Save the assignment into the database
saveAssignment :: Assignment -> Persist AssignmentKey
saveAssignment = PersistImpl.saveAssignment

-- Load the assignment from the database
loadAssignment :: AssignmentKey -> Persist Assignment
loadAssignment = PersistImpl.loadAssignment

-- Modify the assignment in the database for the given key
modifyAssignment :: AssignmentKey -> Assignment -> Persist ()
modifyAssignment = PersistImpl.modifyAssignment

-- Lists all the assignment that are created for the given course
courseAssignments :: CourseKey -> Persist [AssignmentKey]
courseAssignments = PersistImpl.courseAssignments

-- Lists all the assignment that are created for the given group
groupAssignments :: GroupKey -> Persist [AssignmentKey]
groupAssignments = PersistImpl.groupAssignments

-- Save the assignment for the given course
saveCourseAssignment :: CourseKey -> Assignment -> Persist AssignmentKey
saveCourseAssignment = PersistImpl.saveCourseAssignment

-- Save the assignment for the given group
saveGroupAssignment :: GroupKey  -> Assignment -> Persist AssignmentKey
saveGroupAssignment = PersistImpl.saveGroupAssignment

-- Returns (Just courseKey) the course key of the assignment if the assignment
-- is a course assignment otherwise Nothing
courseOfAssignment :: AssignmentKey -> Persist (Maybe CourseKey)
courseOfAssignment = PersistImpl.courseOfAssignment

-- Returns (Just groupKey) the group key of the assignment if the assignment
-- is a group assignment otherwise Nothing
groupOfAssignment :: AssignmentKey -> Persist (Maybe GroupKey)
groupOfAssignment = PersistImpl.groupOfAssignment

-- Returns all the submissions for the given assignment
submissionsForAssignment :: AssignmentKey -> Persist [SubmissionKey]
submissionsForAssignment = PersistImpl.submissionsForAssignment

-- Returns when the assignment was saved first, the modification of an assignment
-- does not change the time stamp
assignmentCreatedTime :: AssignmentKey -> Persist UTCTime
assignmentCreatedTime = PersistImpl.assignmentCreatedTime

-- Returns the test case of the assignment is if there is any attached.
-- returns (Just key) if there is, otherwise Nothing
testCaseOfAssignment :: AssignmentKey -> Persist (Maybe TestCaseKey)
testCaseOfAssignment = PersistImpl.testCaseOfAssignment

-- * Submission

-- Saves the submission for a given assignment, submitted by the given user
saveSubmission :: AssignmentKey -> Username -> Submission -> Persist SubmissionKey
saveSubmission = PersistImpl.saveSubmission

-- Loads the given submission from the database
loadSubmission :: SubmissionKey -> Persist Submission
loadSubmission = PersistImpl.loadSubmission

-- Returns the assignment for the submission
assignmentOfSubmission :: SubmissionKey -> Persist AssignmentKey
assignmentOfSubmission = PersistImpl.assignmentOfSubmission

-- Returns the username for the submission
usernameOfSubmission :: SubmissionKey -> Persist Username
usernameOfSubmission = PersistImpl.usernameOfSubmission

-- Lists all the submissions stored in the database
submissionKeys :: Persist [SubmissionKey]
submissionKeys = fmap (map fst) $ PersistImpl.filterSubmissions (\_ _ -> True)

-- Returns the evaluation for the submission if the evalution exist, otherwise Nothing
evaluationOfSubmission :: SubmissionKey -> Persist (Maybe EvaluationKey)
evaluationOfSubmission = PersistImpl.evaluationOfSubmission

-- Returns all the comments for the given submission
commentsOfSubmission :: SubmissionKey -> Persist [CommentKey]
commentsOfSubmission = PersistImpl.commentsOfSubmission

-- Returns the last submission of an assignment submitted by the given user if the
-- user is submitted something otherwise Nothing
lastSubmission :: AssignmentKey -> Username -> Persist (Maybe SubmissionKey)
lastSubmission = PersistImpl.lastSubmission

-- Remove the submission from the opened (which need to be evaluated) queue
removeFromOpened :: AssignmentKey -> Username -> SubmissionKey -> Persist ()
removeFromOpened = PersistImpl.removeFromOpened

-- Returns all the opened submissions
openedSubmissions :: Persist [SubmissionKey]
openedSubmissions = PersistImpl.openedSubmissions

-- Calculates all the opened submisison for a given user and a given assignment
usersOpenedSubmissions :: AssignmentKey -> Username -> Persist [SubmissionKey]
usersOpenedSubmissions = PersistImpl.usersOpenedSubmissions

-- * Evaluation

-- Save the evaluation for the given submission
saveEvaluation :: SubmissionKey -> Evaluation -> Persist EvaluationKey
saveEvaluation = PersistImpl.saveEvaluation

-- Load the evaluatuon from the database
loadEvaluation :: EvaluationKey -> Persist Evaluation
loadEvaluation = PersistImpl.loadEvaluation

-- Modify the evalution for the given key in the database
modifyEvaluation :: EvaluationKey -> Evaluation -> Persist ()
modifyEvaluation = PersistImpl.modifyEvaluation

-- Returns the submission of the given evaluation
submissionOfEvaluation :: EvaluationKey -> Persist SubmissionKey
submissionOfEvaluation = PersistImpl.submissionOfEvaluation

-- * Comment

-- Saves the comment for the given submission
saveComment :: SubmissionKey -> Comment -> Persist CommentKey
saveComment = PersistImpl.saveComment

-- Loads the comment from the database
loadComment :: CommentKey -> Persist Comment
loadComment = PersistImpl.loadComment

-- Returns the submission of the comment
submissionOfComment :: CommentKey -> Persist SubmissionKey
submissionOfComment = PersistImpl.submissionOfComment

-- * Persistence initialization

-- Checks if the persistent layes is setted up correctly
isPersistenceSetUp :: IO Bool
isPersistenceSetUp = PersistImpl.isPersistenceSetUp

-- Inits the persistent layer
initPersistence :: IO ()
initPersistence = PersistImpl.initPersistence

-- Run a persistent command which can fail
runPersist :: Persist a -> IO (Erroneous a)
runPersist = PersistImpl.runPersist
