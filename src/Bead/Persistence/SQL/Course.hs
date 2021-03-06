{-# LANGUAGE CPP #-}
module Bead.Persistence.SQL.Course where

import           Control.Applicative
import           Data.Maybe
import qualified Data.Text as Text

import           Database.Esqueleto (select, from, on, where_, InnerJoin(InnerJoin), val, (^.), Value(unValue))
import qualified Database.Esqueleto as Esq
import           Database.Persist.Sql

import qualified Bead.Domain.Entities as Domain
import qualified Bead.Domain.Relationships as Domain
import           Bead.Persistence.SQL.Class
import           Bead.Persistence.SQL.Entities
import           Bead.Persistence.SQL.User

#ifdef TEST
import           Control.Monad.IO.Class (liftIO)

import           Bead.Persistence.SQL.MySQLTestRunner
import           Bead.Persistence.SQL.TestData

import           Test.Tasty.TestSet (ioTest, equals, satisfies)
#endif


-- * Course Persistence

-- Saves a Course into the database
saveCourse :: Domain.Course -> Persist Domain.CourseKey
saveCourse course = do
  key <- insert (fromDomainValue course)
  return $! toDomainKey key

-- Lists all the course keys saved in the database
courseKeys :: Persist [Domain.CourseKey]
courseKeys = do
  courses <- selectCourses
  return $! map (toDomainKey . entityKey) courses
  where
    selectCourses :: Persist [Entity Course]
    selectCourses = selectList [] []

-- Selects all the courses with satisfies the given property
filterCourses :: (Domain.CourseKey -> Domain.Course -> Bool) -> Persist [(Domain.CourseKey, Domain.Course)]
filterCourses pred = do
  courses <- selectCourses
  return $! filter (uncurry pred) $ map fromEntity courses
  where
    selectCourses :: Persist [Entity Course]
    selectCourses = selectList [] []

    fromEntity :: Entity Course -> (Domain.CourseKey, Domain.Course)
    fromEntity e = (toDomainKey $ entityKey e, toDomainValue $ entityVal e)

-- Load the course from the database
loadCourse :: Domain.CourseKey -> Persist Domain.Course
loadCourse courseKey = do
  mCourse <- get (fromDomainKey courseKey)
  return $! case mCourse of
    Nothing     -> persistError "loadCourse" $ "no course is found:" ++ show courseKey
    Just course -> toDomainValue course

-- Lists all the groups keys for the given course, the listed groups
-- are the groups under the given course
groupKeysOfCourse :: Domain.CourseKey -> Persist [Domain.GroupKey]
groupKeysOfCourse key = do
  let courseKey = fromDomainKey key
  groups <- selectList [GroupsOfCourseCourse ==. courseKey] []
  return $! map (toDomainKey . groupsOfCourseGroup . entityVal) groups

-- Checks if the user attends the given course
isUserInCourse :: Domain.Username -> Domain.CourseKey -> Persist Bool
isUserInCourse username courseKey = do
  let courseId = fromDomainKey courseKey
  withUser
    username
    (return False)
    (fmap isJust . getBy . UniqueUsersOfCoursePair courseId . entityKey)

-- Lists all the courses which the user attends
userCourses :: Domain.Username -> Persist [Domain.CourseKey]
userCourses username = withUser username (return []) $ \user ->
  map (toDomainKey . usersOfCourseCourse . entityVal)
    <$> selectList [UsersOfCourseUser ==. entityKey user] []

-- Set the given user as an administrator for the course
createCourseAdmin :: Domain.Username -> Domain.CourseKey -> Persist ()
createCourseAdmin username courseKey = withUser username (return ()) $ \userEnt -> void $ do
  insertUnique (AdminsOfCourse (toEntityKey courseKey) (entityKey userEnt))

courseAdminKeys :: Domain.CourseKey -> Persist [Domain.Username]
courseAdminKeys courseKey = do
  courseAdmins <- select $ from $ \(ac `InnerJoin` u) -> do
    on (ac ^. AdminsOfCourseAdmin Esq.==. u ^. UserId)
    where_ (ac ^. AdminsOfCourseCourse Esq.==. val (fromDomainKey courseKey))
    return (u ^. UserUsername)
  return $ map (Domain.Username . Text.unpack . unValue) courseAdmins

-- Lists all the users which are administrators of the given course
courseAdmins :: Domain.CourseKey -> Persist [Domain.User]
courseAdmins courseKey = do
  courseAdmins <- select $ from $ \(ac `InnerJoin` u) -> do
    on (ac ^. AdminsOfCourseAdmin Esq.==. u ^. UserId)
    where_ (ac ^. AdminsOfCourseCourse Esq.==. val (fromDomainKey courseKey))
    return u
  return $ map (toDomainValue . entityVal) courseAdmins

#ifdef TEST
administratedCourseTest = ioTest "Administrated course test" $ runSql $ do
    saveUser user1
    c <- saveCourse course
    acs <- administratedCourses user1name
    equals [] (map fst acs) "There were courses that the user should not administrate."
    let u1 = Domain.u_username user1
    createCourseAdmin u1 c
    us <- courseAdminKeys c
    equals [u1] us "Admins of course were different."
    acs <- administratedCourses user1name
    equals [c] (map fst acs) "The administrated course list was wrong."
#endif

-- Lists all the users that are attends as a student on the given course
subscribedToCourse :: Domain.CourseKey -> Persist [Domain.Username]
subscribedToCourse key = do
  let courseKey = fromDomainKey key
  userIds <- map (usersOfCourseUser . entityVal) <$> selectList [UsersOfCourseCourse ==. courseKey] []
  usernames userIds

-- Lists all the users that are unsubscribed once from the given course
unsubscribedFromCourse :: Domain.CourseKey -> Persist [Domain.Username]
unsubscribedFromCourse key = do
  let courseKey = fromDomainKey key
  userIds <- map (unsubscribedUsersFromCourseUser . entityVal)
               <$> selectList [UnsubscribedUsersFromCourseCourse ==. courseKey] []
  usernames userIds

-- Lists all the test scripts that are connected with the course
testScriptsOfCourse :: Domain.CourseKey -> Persist [Domain.TestScriptKey]
testScriptsOfCourse key = do
  let courseKey = fromDomainKey key
  map (toDomainKey . testScriptsOfCourseTestScript . entityVal)
    <$> selectList [TestScriptsOfCourseCourse ==. courseKey] []
