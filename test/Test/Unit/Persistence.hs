{-# LANGUAGE CPP #-}
{-# LANGUAGE OverloadedStrings #-}
module Test.Unit.Persistence (
    tests
  ) where

-- Test imports

import Test.HUnit hiding (test)
import Test.Tasty (TestTree)
import Test.Tasty.HUnit (testCase)
import Test.Tasty.TestSet
import Test.QuickCheck.Gen (generate, sample')

-- Bead imports
import Bead.Domain.Entities
import qualified Test.Property.EntityGen as EGen
import Bead.Domain.TimeZone (utcZoneInfo)
import Bead.Domain.Shared.Evaluation
import Bead.Domain.Relationships
import Bead.Persistence.Initialization
import Bead.Persistence.Persist
import Bead.Persistence.SQL.FileSystem (initFS, removeFS, testOutgoing)
import qualified Bead.Persistence.SQL.TestData as TestData
import qualified Bead.Persistence.Guards as G
import Bead.Persistence.Relations

-- Utils

import Control.Concurrent (threadDelay)
import Control.Monad (join, when)
import Control.Monad.IO.Class (liftIO)
import Data.Maybe
import Data.List ((\\), isSuffixOf)
import Data.Text (Text)
import qualified Data.Text.IO as TIO
import Data.Time.Clock
import Data.Tuple.Utils (thd3)
import System.Directory
import System.FilePath

tests = group "Persistence tests" $ do
  test test_initialize_persistence
  test test_create_load_exercise
  test test_create_user
  test test_create_group_user
#ifndef SSO
  test testUserRegSaveAndLoad
#endif
  test testOpenSubmissions
  test test_feedbacks
  test testStateOfSubmission
  test testIsolatedAssignmentBlocksView
  test testIsGroupAdmin
  test clean_up

-- Normal assignment is represented as empty aspects set
normal = emptyAspects

ballot = aspectsFromList [BallotBox]

test_initialize_persistence :: TestTree
test_initialize_persistence = testCase "Initialize persistence layer" $ do
  init <- createPersistInit defaultConfig
  setUp <- isSetUp init
  assertBool "Persistence was set up" (not setUp)
  initPersist init
  setUp <- isSetUp init
  assertBool "Setting up persistence was failed" setUp

test_feedbacks :: TestTree
test_feedbacks = testCase "Create and delete test feedbacks" $ do
  removeFS
  initFS
  interp <- createPersistInterpreter defaultConfig
  let skey = "s2013"
      skey' = SubmissionKey skey
      publicMsg = "Public Message"
      privateMsg = "Private Message"
      result = "True"

      skey2 = "s2019"
      skey2' = SubmissionKey skey2

      skey3 = "s2020"
  
  dumpFeedback "1" skey (Just privateMsg) (Just publicMsg) (Just result)
  dumpFeedback "2" skey2 Nothing (Just publicMsg) (Just result)
  dumpFeedback "3" skey2 (Just privateMsg) Nothing (Just result)
  dumpFeedback "4" skey3 (Just privateMsg) (Just publicMsg) Nothing

  rs <- fmap (map (\(sk, fs) -> (sk, map info fs))) $ liftE interp $ testFeedbacks
  equals rs
    [ (skey', [ TestResult True
              , MessageForAdmin privateMsg
              , MessageForStudent publicMsg
              ]
      )
    , (skey2', [ TestResult True
               , MessageForStudent publicMsg
               ]
      )
    , (skey2', [ TestResult True
               , MessageForAdmin privateMsg
               ]
      )
    ]
    "Wrong values"

  dumpFeedback "5" skey3 (Just privateMsg) (Just publicMsg) (Just "invalid")
  dumpFeedback "6" skey Nothing Nothing (Just "False")
  rs <- fmap (map (\(sk, fs) -> (sk, map info fs))) $ liftE interp $ testFeedbacks
  equals [(skey', [TestResult False])] rs "Couldn't handle invalid test results."

  haveAllInvalids <- and <$> mapM doesDirectoryExist [testIncoming </> "4.invalid", testIncoming </> "5.invalid"]
  assertBool "A .invalid directory is missing." haveAllInvalids

  entries <- liftIO $ listDirectory testOutgoing
  equals [] (filter (\p -> not $ ".invalid" `isSuffixOf` p) entries) "Test jobs are not removed."

  -- Test order of feedbacks of the same submission
  dumpFeedback "8" skey Nothing Nothing (Just "True")
  dumpFeedback "7" skey Nothing Nothing (Just "False")
  rs <- fmap (map (\(sk, fs) -> (sk, map info fs))) $ liftE interp $ testFeedbacks

  equals rs
    [ (skey', [ TestResult True ])
    , (skey', [ TestResult False ])
    ]
    "Wrong order of feedbacks"

  where
    -- This is needed because Travis handles file IO too fast, which
    -- makes output of testFeedbacks nondeterministic.
    waitALittle :: IO ()
    waitALittle = threadDelay (1 * 10^5) -- 0.1s
    
    dumpFeedback :: String -> String -> Maybe Text -> Maybe Text -> Maybe String -> IO ()
    dumpFeedback d sk private public result = do
      let sdir = testIncoming </> d
      createDirectory sdir
      writeFile (sdir </> "id") sk
      maybe (return ()) (TIO.writeFile (sdir </> "private")) private
      maybe (return ()) (TIO.writeFile (sdir </> "public")) public
      maybe (return ()) (writeFile (sdir </> "result")) result
      waitALittle

testStateOfSubmission :: TestTree
testStateOfSubmission = testCase "stateOfSubmission tests" $ do
  interp <- createPersistInterpreter defaultConfig
  reinitpersistence
  liftE interp $ do
    c <- saveCourse TestData.course
    g <- saveGroup c TestData.group
    saveUser TestData.user1
    subscribe TestData.user1name g
    a <- saveGroupAssignment g TestData.asg
    s <- saveSubmission a TestData.user1name TestData.sbm
    st <- stateOfSubmission s
    equals Submission_Unevaluated st "Submission state is not unevaluated initially."
    saveFeedbacks s [TestData.fbMsgStudent]
    st <- stateOfSubmission s
    equals Submission_Unevaluated st "Submission state is not unevaluated after message for a student."
    saveFeedbacks s [TestData.fbMsgForAdmin]
    st <- stateOfSubmission s
    equals Submission_Unevaluated st "Submission state is not unevaluated after message for an admin."
    saveComment s TestData.cmt
    st <- stateOfSubmission s
    equals Submission_Unevaluated st "Submission state is not unevaluated after a comment."

    let (time:time1:time2:time3:time4:time5:time6:time7: _) = TestData.times

    saveFeedbacks s [Feedback QueuedForTest time]
    st <- stateOfSubmission s
    equals Submission_QueuedForTest st "Submission state is not queued for test after scheduling event."

    saveFeedbacks s [Feedback (TestResult False) time1]
    st <- stateOfSubmission s
    equals (Submission_Tested False) st "Submission state is not tested after test result False."

    saveFeedbacks s [Feedback (TestResult True) time2]
    st <- stateOfSubmission s
    equals (Submission_Tested True) st "Submission state didn't change after a new test result."

    saveFeedbacks s [TestData.fbMsgStudent]
    st <- stateOfSubmission s
    equals (Submission_Tested True) st "Submission state changed after a message for a student."

    saveFeedbacks s [Feedback (TestResult False) time3]
    st <- stateOfSubmission s
    equals (Submission_Tested False) st "Submission state didn't change after second test result False."

    saveComment s TestData.cmt
    st <- stateOfSubmission s
    equals (Submission_Tested False) st "Submission state changed after a comment."

    saveSubmission a TestData.user1name TestData.sbm2
    st <- stateOfSubmission s
    equals (Submission_Tested False) st "Submission state changed after a new submission."

    saveFeedbacks s [Feedback QueuedForTest time4]
    st <- stateOfSubmission s
    equals (Submission_QueuedForTest) st "Submission state is not queued again for test after scheduling event."

    e <- saveSubmissionEvaluation s TestData.acceptEvaluation
    st <- stateOfSubmission s
    equals (Submission_Result e (evaluationResult TestData.acceptEvaluation)) st "Submission state is not evaluated after evaluation."

    let rejected = Submission_Result e (evaluationResult TestData.rejectEvaluation)
    modifyEvaluation e TestData.rejectEvaluation
    st <- stateOfSubmission s
    equals rejected st "Submission state didn't change after new evaluation."

    saveFeedbacks s [Feedback (TestResult True) time5]
    st <- stateOfSubmission s
    equals rejected st "Evaluated state of submission changed after second test result True."

    saveFeedbacks s [TestData.fbMsgStudent]
    st <- stateOfSubmission s
    equals rejected st "Evaluated state of submission changed after a message for a student."

    saveComment s TestData.cmt
    st <- stateOfSubmission s
    equals rejected st "Evaluated state of submission changed after a comment."

    saveSubmission a TestData.user1name TestData.sbm2
    st <- stateOfSubmission s
    equals rejected st "Evaluated state of submission changed after a new submission."
    s <- saveSubmission a TestData.user1name TestData.sbm2
    st <- stateOfSubmission s
    equals Submission_Unevaluated st "Submission 2 state is not unevaluated initially."
    e <- saveSubmissionEvaluation s TestData.rejectEvaluation
    st <- stateOfSubmission s
    equals (Submission_Result e (evaluationResult TestData.rejectEvaluation)) st "Submission 2 state didn't change after new evaluation."

    s <- saveSubmission a TestData.user1name TestData.sbm2
    st <- stateOfSubmission s
    equals Submission_Unevaluated st "Submission 3 state is not unevaluated initially"

    saveFeedbacks s [Feedback QueuedForTest time6]
    st <- stateOfSubmission s
    equals (Submission_QueuedForTest) st "Submission 3 state is not queued again for test after scheduling event."

    e <- saveSubmissionEvaluation s TestData.acceptEvaluation
    let accepted = Submission_Result e (evaluationResult TestData.acceptEvaluation)
    st <- stateOfSubmission s
    equals accepted st "Submission 3 state didn't change after new evaluation."

    saveFeedbacks s [Feedback (TestResult False) time7]
    st <- stateOfSubmission s
    equals accepted st "Submission 3 state changed from evaluated after result False."

test_create_load_exercise = testCase "Create and load exercise" $ do
  interp <- createPersistInterpreter defaultConfig
  let str = utcTimeConstant
  let end = utcTimeConstant
  let a = Assignment "Title" "This is an exercise" normal str end binaryConfig
  k <- liftE interp $ saveAssignment a
  a' <- liftE interp $ loadAssignment k
  assertBool (concat ["The saved assignment differs from the read one. ", show a, show a']) (a' == a)

test_create_user = testCase "Create user" $ do
  interp <- createPersistInterpreter defaultConfig
  let uname = Username "ursula"
  let user = User {
        u_role     = Student
      , u_username = uname
      , u_email    = Email "ursula@gmail.com"
      , u_name     = "Ursula"
      , u_timezone = utcZoneInfo
      , u_language = Language "hu"
      , u_uid = usernameCata Uid uname
      }
  liftE interp $ saveUser user
  us <- liftE interp $ filterUsers (const True)
  assertBool "The filter did not find the user" (length us > 0)
  user1 <- liftE interp $ loadUser uname
  assertBool "Loading the registered user has failed" (user1 == user)
  let user2 = user { u_role = CourseAdmin }
  liftE interp $ updateUser user2
  user3 <- liftE interp $ loadUser uname
  assertBool "Updating and loading user has failed" (user3 == user2)

#ifndef SSO
testUserRegSaveAndLoad = testCase "Save and Load User registration" $ do
  interp <- createPersistInterpreter defaultConfig
  let now = utcTimeConstant
  let u = UserRegistration "username" "e@e.com" "Family name" "token" now
  key <- liftE interp $ saveUserReg u
  u'  <- liftE interp $ loadUserReg key
  assertBool (concat ["Loaded user registration info differs from saved ", show u, " ", show u']) (u == u')
#endif

testOpenSubmissions = testCase "Users separated correctly in open submission tables" $ do
  interp <- createPersistInterpreter defaultConfig
  let str = utcTimeConstant
  let end = utcTimeConstant
  reinitpersistence
  let myStudent = Username "mystudent"
      myStudentUser = User {
          u_role = Student
        , u_username = myStudent
        , u_email = Email "admin@gmail.com"
        , u_name = "mystudent"
        , u_timezone = utcZoneInfo
        , u_language = Language "hu"
        , u_uid = usernameCata Uid myStudent
        }
      otherStudent = Username "otherstudent"
      otherStudentUser = User {
          u_role = Student
        , u_username = otherStudent
        , u_email = Email "admin@gmail.com"
        , u_name = "otherstudent"
        , u_timezone = utcZoneInfo
        , u_language = Language "hu"
        , u_uid = usernameCata Uid otherStudent
        }
      admin = Username "admin2"
      adminUser = User {
          u_role = Admin
        , u_username = admin
        , u_email = Email "admin@gmail.com"
        , u_name = "admin"
        , u_timezone = utcZoneInfo
        , u_language = Language "hu"
        , u_uid = usernameCata Uid admin
        }
      password = "password"
      cAssignment = Assignment "CourseAssignment" "Assignment" ballot str end binaryConfig
      gAssignment1 = Assignment "GroupAssignment" "Assignment" normal str end binaryConfig
      gAssignment2 = Assignment "GroupAssignment" "Assignment" normal str end binaryConfig
      sbsm = Submission (TextSubmission "submission") str
  join $ liftE interp $ do
    ck  <- saveCourse (Course "name" "desc" TestScriptSimple)
    gk1 <- saveGroup ck (Group "gname1" "gdesc1")
    gk2 <- saveGroup ck (Group "gname2" "gdesc2")
    saveUser adminUser
    saveUser myStudentUser
    saveUser otherStudentUser
    subscribe myStudent gk1
    subscribe otherStudent gk2
    createCourseAdmin admin ck
    createGroupAdmin admin gk1
    cak <- saveCourseAssignment ck cAssignment
    gak1 <- saveGroupAssignment gk1 gAssignment1
    _ <- saveGroupAssignment gk2 gAssignment2
    sk1 <- saveSubmission cak myStudent sbsm
    sk2 <- saveSubmission gak1 myStudent sbsm
    sk3 <- saveSubmission cak otherStudent sbsm
    os <- openedSubmissionInfo admin
    return $ do
      let adminedCourse = map fst $ osAdminedCourse os
          adminedGroup  = map fst $ osAdminedGroup os
          relatedCourse = map fst $ osRelatedCourse os
      assertBool
        (join ["Course level assignment for administrated group were incorrent:", show adminedCourse])
        ([sk1] == adminedCourse)
      assertBool
        (join ["Group level assignment for administrated group were incorrent:", show adminedGroup])
        ([sk2] == adminedGroup)
      assertBool
        (join ["Course level assignment for non-administrated group were incorrent:", show relatedCourse])
        ([sk3] == relatedCourse)


test_create_group_user = testCase "Create Course and Group with a user" $ do
  interp <- createPersistInterpreter defaultConfig
  let username = Username "ursula"
      admin = Username "admin"
      adminUser = User {
          u_role = Admin
        , u_username = admin
        , u_email = Email "admin@gmail.com"
        , u_name = "admin"
        , u_timezone = utcZoneInfo
        , u_language = Language "hu"
        , u_uid = usernameCata Uid admin
        }
      password = "password"
  ck <- liftE interp $ saveCourse (Course "name" "desc" TestScriptSimple)
  gk <- liftE interp $ saveGroup ck (Group "gname" "gdesc")
  gks <- liftE interp $ groupKeysOfCourse ck
  assertBool "Registered group was not found in the group list" (elem gk gks)
  liftE interp $ subscribe username gk
  rCks <- liftE interp $ userCourses username
  assertBool "Course does not found in user's courses" (rCks == [ck])
  rGks <- liftE interp $ userGroupKeys username
  assertBool "Group does not found in user's groups" (rGks == [gk])
  isInGroup <- liftE interp $ isUserInGroup username gk
  assertBool "Registered user is not found" isInGroup
  isInCourse <- liftE interp $ isUserInCourse username ck
  assertBool "Registered user is not found" isInCourse
  liftE interp $ saveUser adminUser
  liftE interp $ createCourseAdmin admin ck
  cs <- liftE interp $ administratedCourses admin
  assertBool "Course is not found in administrated courses" (elem ck (map fst cs))
  liftE interp $ createGroupAdmin admin gk
  gs <- liftE interp $ administratedGroups admin
  assertBool "Group is not found in administrated groups" (elem gk (concatMap (map fst . thd3) gs))
  let str = utcTimeConstant
  let end = utcTimeConstant
  let gAssignment = Assignment "GroupAssignment" "Assignment" normal str end binaryConfig
      cAssignment = Assignment "CourseAssignment" "Assignment" ballot str end (percentageConfig 0.1)
  cak <- liftE interp $ saveCourseAssignment ck cAssignment
  cas <- liftE interp $ courseAssignments ck
  assertBool "Course does not have the assignment" (elem cak cas)
  gak <- liftE interp $ saveGroupAssignment gk gAssignment
  gas <- liftE interp $ groupAssignments gk
  assertBool "Group does not have the assignment" (elem gak gas)
  us <- liftE interp $ groupAdminKeys gk
  assertBool "Admin is not in the group" ([admin] == us)
  gs <- liftE interp $ filterGroups (\_ _ -> True)
  assertBool "Group list was different" ([gk] == map fst gs)

  testHasNoLastSubmission gak username

  -- Submission
  let sbsm = Submission (TextSubmission "submission") str
  sk <- liftE interp $ saveSubmission gak username sbsm
  sk_user <- liftE interp $ usernameOfSubmission sk
  assertBool
    (join ["Username of the submission differs from the registered: (", show username, " ", show sk_user, ")"])
    (username == sk_user)
  sk_ak <- liftE interp $ assignmentOfSubmission sk
  assertBool "Assignment differs from registered" (gak == sk_ak)
  osk <- liftE interp $ openedSubmissions
  assertBool "Submission is not in the opened submissions" (elem sk osk)

  testHasLastSubmission gak username sk

  -- Test Submissions
  submissions <- liftE interp $ submissionsForAssignment gak
  assertBool "Submissions for assignment was different" (submissions == [sk])

  uss <- liftE interp $ userSubmissions username gak
  assertBool "Submission is not in the users' submission" (elem sk uss)

  let ev = Evaluation (binaryResult Passed) "Good"
  evKey <- liftE interp $ saveSubmissionEvaluation sk ev
  ev1 <- liftE interp $ loadEvaluation evKey
  assertBool "Evaluation was not loaded correctly" (ev == ev1)
  ev_sk <- liftE interp $ submissionOfEvaluation evKey
  assertBool "Submission key was different for the evaluation" (Just sk == ev_sk)
  liftE interp $ removeFromOpened gak username sk

  testComment sk

  return ()

testComment :: SubmissionKey -> IO ()
testComment sk = do
  interp <- createPersistInterpreter defaultConfig
  let now = utcTimeConstant
  let comment = Comment "comment" "author" now CT_Student
  key <- liftE interp $ saveComment sk comment
  c2  <- liftE interp $ loadComment key
  assertBool (concat ["Loaded comment was different ", show comment, " ", show c2]) (comment == c2)
  sk2 <- liftE interp $ submissionOfComment key
  assertBool "Submission key was different" (sk == sk2)

testHasNoLastSubmission :: AssignmentKey -> Username -> IO ()
testHasNoLastSubmission ak u = do
  interp <- createPersistInterpreter defaultConfig
  mKey <- liftE interp $ lastSubmission ak u
  assertBool "Found submission" (isNothing mKey)

testHasLastSubmission :: AssignmentKey -> Username -> SubmissionKey -> IO ()
testHasLastSubmission ak u sk = do
  interp <- createPersistInterpreter defaultConfig
  mKey <- liftE interp $ lastSubmission ak u
  assertBool "Submission was not found" (isJust mKey)
  assertBool "Submission was different" (sk == fromJust mKey)

testIsGroupAdmin :: TestTree
testIsGroupAdmin = testCase "Check group administratorship" $ do
  interp <- createPersistInterpreter defaultConfig
  c <- liftE interp $ saveCourse TestData.course
  groups <- take 5 <$> liftIO (sample' EGen.groups)
  gks@[g1, g2, g3, g4, g5] <- liftE interp (mapM (saveGroup c) groups)
  student_ <- liftIO (generate $ EGen.users' Student)
  gAdmin_ <- liftIO (generate $ EGen.users' GroupAdmin)
  gAdmin2_ <- liftIO (generate $ EGen.users' GroupAdmin)
  cAdmin_ <- liftIO (generate $ EGen.users' CourseAdmin)
  let [student, gAdmin, gAdmin2, cAdmin] = map u_username [student_, gAdmin_, gAdmin2_, cAdmin_]
  liftE interp $ do
    saveUser student_
    saveUser gAdmin_
    saveUser gAdmin2_
    saveUser cAdmin_
    createGroupAdmin gAdmin g2
    createGroupAdmin gAdmin g3
    createGroupAdmin gAdmin2 g3
    createGroupAdmin gAdmin2 g4
    createCourseAdmin cAdmin c
    createGroupAdmin cAdmin g4
    createGroupAdmin cAdmin g5
  isAdmin <- or <$> liftE interp (mapM (isAdminOfGroup student) gks)
  assertBool "A user administrated a group but nobody has assigned a group to her." (not isAdmin)
  isAdmin <- liftE interp $ isAdminOfGroup gAdmin g1
  assertBool "Group admin administrates a group that nobody has assigned to her." (not isAdmin)
  isAdmin <- liftE interp $ isAdminOfGroup gAdmin g2
  assertBool "Group admin should administrate an assigned group." isAdmin
  isAdmin <- liftE interp $ isAdminOfGroup gAdmin g3
  assertBool "Group admin should administrate a shared assigned group." isAdmin
  isAdmin <- liftE interp $ isAdminOfGroup gAdmin g5
  assertBool "Group admin should not administrate a group of other admin." (not isAdmin)
  isAdmin <- liftE interp $isAdminOfGroup cAdmin g3
  assertBool "Course admin should not administrate a group of other admin." (not isAdmin)
  isAdmin <- liftE interp $ isAdminOfGroup cAdmin g4
  assertBool "Course admin should administrate a shared group of her." isAdmin
  isAdmin <- liftE interp $ isAdminOfGroup cAdmin g5
  assertBool "Course admin should administrate her only group." isAdmin

-- Guard tests

testIsolatedAssignmentBlocksView :: TestTree
testIsolatedAssignmentBlocksView = testCase "Isolated assignment blocks viewing other assignments" $ do
  reinitpersistence
  interp <- createPersistInterpreter defaultConfig
  now <- getCurrentTime
  let std1 = Username "student1"
      student1 = User {
          u_role = Student
        , u_username = std1
        , u_email = Email "student@gmail.com"
        , u_name = "Student"
        , u_timezone = utcZoneInfo
        , u_language = Language "hu"
        , u_uid = usernameCata Uid std1
        }
      isolated = aspectsFromList [Isolated]
      start = now
      end = addUTCTime 600 start -- 10 minutes
      startInactive = addUTCTime (-600) now
      endInactive = startInactive
      asgC1 = Assignment "CourseAssignment1" "Assignment" normal start end binaryConfig
      asgC2 = Assignment "CourseAssignment2" "Assignment" normal start end binaryConfig
      asgC3 = Assignment "CourseAssignment3" "Assignment" normal startInactive endInactive binaryConfig
      asgG1 = Assignment "GroupAssignment1" "Assignment" normal start end binaryConfig
      asgG2 = Assignment "GroupAssignment2" "Assignment" normal start end binaryConfig
      asgG3 = Assignment "GroupAssignment3" "Assignment" normal startInactive endInactive binaryConfig
      isolate a = a { aspects = isolated }
      locally ak asg m = do
        modifyAssignment ak (isolate asg)
        m
        modifyAssignment ak asg
  liftE interp $ do
    ck  <- saveCourse (Course "name" "desc" TestScriptSimple)
    gk <- saveGroup ck (Group "gname1" "gdesc1")
    _ <- saveUser student1
    subscribe std1 gk
    [aC1, aC2, aC3] <- mapM (saveCourseAssignment ck) [asgC1, asgC2, asgC3]
    [aG1, aG2, aG3] <- mapM (saveGroupAssignment gk) [asgG1, asgG2, asgG3]
    let aks = [aC1, aC2, aC3, aG1, aG2, aG3]
    allAccessible <- and <$> mapM (G.doesBlockAssignmentView std1) aks
    liftIO $ assertBool "User cannot access one of the assignments initially." allAccessible
    locally aC1 asgC1 $ do
      isAccessible <- G.doesBlockAssignmentView std1 aC1
      liftIO $ assertBool "User cannot access the isolated course assignment" isAccessible
      othersAccessible <- or <$> mapM (G.doesBlockAssignmentView std1) (aks \\ [aC1])
      liftIO $ assertBool "User can access one of the assignments when a course assignment is isolated." (not othersAccessible)
      locally aC3 asgC3 $ do
        isInactiveAccessible <- G.doesBlockAssignmentView std1 aC3
        liftIO $ assertBool "User can access an inactive isolated course assignment when a course assignment is isolated." (not isInactiveAccessible)
      locally aG3 asgG3 $ do
        isInactiveAccessible <- G.doesBlockAssignmentView std1 aG3
        liftIO $ assertBool "User can access an inactive isolated group assignment when a course assignment is isolated." (not isInactiveAccessible)
    locally aG1 asgG1 $ do
      isAccessible <- G.doesBlockAssignmentView std1 aG1
      liftIO $ assertBool "User cannot access the isolated group assignment" isAccessible
      othersAccessible <- or <$> mapM (G.doesBlockAssignmentView std1) (aks \\ [aG1])
      liftIO $ assertBool "User can access one of the assignments when a group assignment is isolated." (not othersAccessible)
      locally aC3 asgC3 $ do
        isInactiveAccessible <- G.doesBlockAssignmentView std1 aC3
        liftIO $ assertBool "User can access an inactive isolated course assignment when a group assignment is isolated." (not isInactiveAccessible)
      locally aG3 asgG3 $ do
        isInactiveAccessible <- G.doesBlockAssignmentView std1 aG3
        liftIO $ assertBool "User can access an inactive isolated group assignment when a group assignment is isolated." (not isInactiveAccessible)
    locally aC3 asgC3 $ do
      isAccessible <- G.doesBlockAssignmentView std1 aC3
      liftIO $ assertBool "User cannot access the isolated inactive course assignment" isAccessible
      othersAccessible <- and <$> mapM (G.doesBlockAssignmentView std1) (aks \\ [aC3])
      liftIO $ assertBool "User cannot access one of the assignments when an inactive course assignment is isolated." othersAccessible
    locally aG3 asgG3 $ do
      isAccessible <- G.doesBlockAssignmentView std1 aG3
      liftIO $ assertBool "User cannot access the isolated inactive group assignment" isAccessible
      othersAccessible <- and <$> mapM (G.doesBlockAssignmentView std1) (aks \\ [aG3])
      liftIO $ assertBool "User cannot access one of the assignments when an inactive group assignment is isolated." othersAccessible

reinitpersistence = do
  init <- createPersistInit defaultConfig
  setUp <- isSetUp init
  when setUp $ do
    tearDown init
    initPersist init

clean_up = testCase "Cleaning up" $ do
  init <- createPersistInit defaultConfig
  tearDown init

-- * Tools

liftE :: Interpreter -> Persist a -> IO a
liftE interp m = do
  x <- runPersist interp m
  case x of
    Left e -> error e
    Right y -> return y

utcTimeConstant :: UTCTime
utcTimeConstant = read "2015-08-27 17:08:58 UTC"
