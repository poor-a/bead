{-# LANGUAGE CPP, TypeFamilies, FlexibleContexts #-}
module Bead.Persistence.SQL.Group where

import           Control.Applicative
import           Control.Arrow ((&&&))
import           Control.Monad (when)
import           Database.Esqueleto (select, from, on, where_, InnerJoin(InnerJoin), val, (^.), Value(unValue))
import qualified Database.Esqueleto as Esq
import           Data.Maybe
import qualified Data.Text as Text
import           Data.Tuple.Utils (thd3)

import           Database.Persist.Sql

import qualified Bead.Domain.Entities as Domain
import qualified Bead.Domain.Relationships as Domain
import           Bead.Persistence.SQL.Entities
import           Bead.Persistence.SQL.Class

#ifdef TEST
import qualified Data.Set as Set

import           Bead.Persistence.SQL.Course
import           Bead.Persistence.SQL.User
import           Bead.Persistence.SQL.MySQLTestRunner
import           Bead.Persistence.SQL.TestData

import           Test.Tasty.TestSet (ioTest, equals)
#endif

-- * Group Persistence

-- Save the group under the given course
saveGroup :: Domain.CourseKey -> Domain.Group -> Persist Domain.GroupKey
saveGroup key group = do
  let courseKey = fromDomainKey key
  groupKey <- insert (fromDomainValue group)
  insertUnique (GroupsOfCourse courseKey groupKey)
  return $! toDomainKey groupKey

-- Load the group from the database
loadGroup :: Domain.GroupKey -> Persist Domain.Group
loadGroup groupKey = do
  mGroup <- get (fromDomainKey groupKey)
  return $! case mGroup of
    Nothing    -> persistError "loadGroup" $ "no group is found:" ++ show groupKey
    Just group -> toDomainValue group

loadGroupAndCourse :: Domain.GroupKey -> Persist (Domain.CourseKey, Domain.Course, Domain.GroupKey, Domain.Group)
loadGroupAndCourse key = do
  groups <- select $ from $ \(g `InnerJoin` gc `InnerJoin` c) -> do
    on (g ^. GroupId Esq.==. gc ^. GroupsOfCourseGroup Esq.&&.
        gc ^. GroupsOfCourseCourse Esq.==. c ^. CourseId
       )
    where_ (g ^. GroupId Esq.==. val (fromDomainKey key))
    return (c, g)
  case groups of
    [] -> persistError "loadGroupAndCourse" $ "no group is found: " ++ show key
    [(c, g)] ->  return (toDomainKey . entityKey $ c, toDomainValue . entityVal $ c, toDomainKey . entityKey $ g, toDomainValue . entityVal $ g)
    _ -> persistError "loadGroupAndCourse" $ "more than one groups are found: " ++ show key

-- Returns the course of the given group
courseOfGroup :: Domain.GroupKey -> Persist Domain.CourseKey
courseOfGroup key = do
  mCourseGroup <- getBy . UniqueGroupCourseGroup $ fromDomainKey key
  return $! case mCourseGroup of
    Nothing  -> persistError "courseOfGroup" $ "no group is found:" ++ show key
    Just ent -> toDomainKey . groupsOfCourseCourse $ entityVal ent

-- Lists all groups from the database
groups :: Persist [(Domain.Course, Domain.GroupKey, Domain.Group)]
groups = do
  grps <- select $ from $ \(c `InnerJoin` cg `InnerJoin` g) -> do
    on (c ^. CourseId Esq.==. cg ^. GroupsOfCourseCourse Esq.&&.
        cg ^. GroupsOfCourseGroup Esq.==. g ^. GroupId)
    return (c, g ^. GroupId, g)
  return $ map (\(c, gk, g) -> (toDomainValue (entityVal c), toDomainKey (unValue gk), toDomainValue (entityVal g))) grps

-- Lists all the groups from the database that satisfies the given predicate
filterGroups :: (Domain.GroupKey -> Domain.Group -> Bool) -> Persist [(Domain.GroupKey, Domain.Group)]
filterGroups pred = (filter (uncurry pred) . map toDomainGroupPair) <$> selectList [] ([] :: [SelectOpt Group])
  where
    toDomainGroupPair e = (toDomainKey $ entityKey e, toDomainValue $ entityVal e)

-- Returns True if the user is registered in the group, otherwise False
isUserInGroup :: Domain.Username -> Domain.GroupKey -> Persist Bool
isUserInGroup username groupKey = withUser username (return False) $ \userEnt ->
  isJust <$> getBy (UniqueUsersOfGroupPair (toEntityKey groupKey) (entityKey userEnt))

userGroupKeys :: Domain.Username -> Persist [Domain.GroupKey]
userGroupKeys username = do
  groups <- select $ from $ \(u `InnerJoin` ug) -> do
    on (u ^. UserId Esq.==. ug ^. UsersOfGroupUser)
    where_ (u ^. UserUsername Esq.==. val (Domain.usernameCata Text.pack username))
    return (ug ^. UsersOfGroupGroup)
  return $ map (toDomainKey . unValue) groups

-- Lists all the groups that the user is attended in
userGroups :: Domain.Username -> Persist [(Domain.CourseKey, Domain.Course, Domain.GroupKey, Domain.Group)]
userGroups username = do
  groups <- select $ from $ \(u `InnerJoin` ug `InnerJoin` g `InnerJoin` gc `InnerJoin` c) -> do
    on (u ^. UserId Esq.==. ug ^. UsersOfGroupUser Esq.&&.
        ug ^. UsersOfGroupGroup Esq.==. g ^. GroupId Esq.&&.
        g ^. GroupId Esq.==. gc ^. GroupsOfCourseGroup Esq.&&.
        gc ^. GroupsOfCourseCourse Esq.==. c ^. CourseId
       )
    where_ (u ^. UserUsername Esq.==. val (Domain.usernameCata Text.pack username))
    return (c, g)
  return $ map (\(c, g) -> (toDomainKey . entityKey $ c, toDomainValue . entityVal $ c, toDomainKey . entityKey $ g, toDomainValue . entityVal $ g)) groups

-- Subscribe the user for the given course and group
subscribe :: Domain.Username -> Domain.GroupKey -> Persist ()
subscribe username groupKey = withUser username (return ()) $ \userEnt -> void $ do
  courseKey <- courseOfGroup groupKey
  let userKey = entityKey userEnt
  insertUnique (UsersOfGroup  (toEntityKey groupKey)  userKey)
  insertUnique (UsersOfCourse (toEntityKey courseKey) userKey)

-- Unsubscribe the user from the given course and group,
-- if the user is not subscribed nothing happens
unsubscribe :: Domain.Username -> Domain.GroupKey -> Persist ()
unsubscribe username groupDomKey = withUser username (return ()) $ \userEnt -> void $ do
  courseDomKey <- courseOfGroup groupDomKey
  let groupKey = toEntityKey groupDomKey
      courseKey = toEntityKey courseDomKey
      userKey = entityKey userEnt
      groupFilter = [UsersOfGroupUser ==. userKey, UsersOfGroupGroup ==. groupKey]
      courseFilter = [UsersOfCourseUser ==. userKey, UsersOfCourseCourse ==. courseKey]
  groups <- selectList groupFilter []
  courses <- selectList courseFilter []
  when (or [not $ null groups, not $ null courses]) . void $ do
    deleteWhere groupFilter
    deleteWhere courseFilter
    insertUnique (UnsubscribedUsersFromGroup  groupKey  userKey)
    insertUnique (UnsubscribedUsersFromCourse courseKey userKey)

#ifdef TEST

groupTests = do
  ioTest "Create and load group" $ runSql $ do
    c <- saveCourse course
    g <- saveGroup  c group
    group' <- loadGroup g
    equals group group' "Group was saved and load incorrectly"

  ioTest "Course key of group was saved correctly" $ runSql $ do
    c <- saveCourse course
    g <- saveGroup  c group
    c' <- courseOfGroup g
    equals c c' "Course key was not loaded correctly"

  ioTest "Check group subscription" $ runSql $ do
    saveUser user1
    c <- saveCourse course
    g <- saveGroup  c group

    ingr <- isUserInGroup user1name g
    equals False ingr "User was in the group"

    subscribe user1name g
    ingr <- isUserInGroup user1name g
    equals True ingr "User was not in the subscribed group"

  ioTest "Check creating group admins" $ runSql $ do
    saveUser user1
    saveUser user2
    c <- saveCourse course
    g <- saveGroup c group
    ags <- administratedGroups user1name
    equals [] (concatMap (map fst . thd3) ags) "There was group administrated with the user"
    admins <- groupAdminKeys g
    equals [] admins "There were group admins, without creation"
    createGroupAdmin user1name g
    admins <- groupAdminKeys g
    equals [user1name] admins "The first admin was not assigned to the group"
    ags <- administratedGroups user1name
    equals [g] (concatMap (map fst . thd3) ags) "There was no group administrated with the user"
    createGroupAdmin user2name g
    admins <- groupAdminKeys g
    equals
      (Set.fromList [user1name, user2name])
      (Set.fromList admins)
      "The admins were different to the group"

  ioTest "Check the user subscription and unsubscription from the course" $ runSql $ do
    saveUser user1
    saveUser user2
    c <- saveCourse course
    g <- saveGroup c group
    subscribe user1name g
    unsubscribe user1name g
    us <- unsubscribedFromGroup g
    equals [user1name] us "User was not unsubscribed from the group"

#endif

-- Calculates the domain username from the user entity
usernameFromEntity = Domain.Username . Text.unpack . userUsername

groupAdminKeys :: Domain.GroupKey -> Persist [Domain.Username]
groupAdminKeys groupKey = do
  groupAdmins <- select $ from $ \(ag `InnerJoin` u) -> do
    on (ag ^. AdminsOfGroupAdmin Esq.==. u ^. UserId)
    where_ (ag ^. AdminsOfGroupGroup Esq.==. val (fromDomainKey groupKey))
    return (u ^. UserUsername)
  return $ map (Domain.Username . Text.unpack . unValue) groupAdmins

-- Lists all the group admins for the given group
groupAdmins :: Domain.GroupKey -> Persist [Domain.User]
groupAdmins groupKey = do
  groupAdmins <- select $ from $ \(ag `InnerJoin` u) -> do
    on (ag ^. AdminsOfGroupAdmin Esq.==. u ^. UserId)
    where_ (ag ^. AdminsOfGroupGroup Esq.==. val (fromDomainKey groupKey))
    return u
  return $ map (toDomainValue . entityVal) groupAdmins

-- Set the given user for the given group
createGroupAdmin :: Domain.Username -> Domain.GroupKey -> Persist ()
createGroupAdmin username groupKey = withUser username (return ()) $ \userEnt -> void $ do
  insertUnique (AdminsOfGroup (toEntityKey groupKey) (entityKey userEnt))

-- Lists all the users that are subscribed to the given group
subscribedToGroup :: Domain.GroupKey -> Persist [Domain.Username]
subscribedToGroup groupKey = do
  userIds <- selectList [UsersOfGroupGroup ==. (toEntityKey groupKey)] []
  (map usernameFromEntity . catMaybes) <$> mapM (get . usersOfGroupUser . entityVal) userIds

-- Lists all the users that are unsubscribed from the given group at least once
unsubscribedFromGroup :: Domain.GroupKey -> Persist [Domain.Username]
unsubscribedFromGroup groupKey = do
  userIds <- selectList [UnsubscribedUsersFromGroupGroup ==. (toEntityKey groupKey)] []
  (map usernameFromEntity . catMaybes) <$> mapM (get . unsubscribedUsersFromGroupUser . entityVal) userIds
