module Test.Model.UserStory where

import           Control.Monad (when)
import           Control.Monad.Trans (lift)
import           Control.Monad.Trans.Reader
import qualified Data.Text as T
import qualified Data.UUID as UUID
import           Prelude hiding (log)

import           Bead.Controller.Logging
import qualified Bead.Controller.Pages as P
import           Bead.Controller.ServiceContext
import           Bead.Controller.UserStories as U
import           Bead.Domain.Entities as E hiding (name, uid)
import qualified Bead.Domain.Relationships as R
import           Bead.Domain.TimeZone (utcZoneInfo)
import qualified Bead.Persistence.Initialization as PersistInit
import           Bead.Persistence.Persist
import           Bead.View.Translation (trans)

import           Test.HUnit hiding (Test(..), test)


context :: IO ServiceContext
context = do
  interp <- createPersistInterpreter defaultConfig
  return $ serviceContext errorLogger interp
  where
    errorLogger = Logger {
        log = \e msg -> case e of
          ERROR -> error (T.unpack msg)
          _     -> return ()
      }

adminUserState :: UserState
adminUserState = UserLoggedIn {
    user = Username "admin"
  , uid = Uid "admin"
  , name = "Admin"
  , _language = lang
  , role = E.Admin
  , uuid = UUID.nil
  , _timeZone = utcZoneInfo
  , _status = Nothing
  , _homePage = R.Administration
  }

student :: User
student = User {
    u_role = E.Student
  , u_username = (Username "student")
  , u_email = Email "student@university.com"
  , u_name = "Stu Dent"
  , u_timezone = utcZoneInfo
  , u_language = Language "hu"
  , u_uid = Uid "student"
  }

student2 :: User
student2 = User {
    u_role = E.Student
  , u_username = (Username "student2")
  , u_email = Email "student@university.com"
  , u_name = "Stu Dent"
  , u_timezone = utcZoneInfo
  , u_language = Language "hu"
  , u_uid = Uid "student"
  }


adminUser :: User
adminUser = User {
    u_role = E.Admin
  , u_username = (Username "admin")
  , u_email = Email "admin@university.com"
  , u_name = "Admin"
  , u_timezone = utcZoneInfo
  , u_language = Language "hu"
  , u_uid = Uid "admin"
  }

groupAdminUser :: User
groupAdminUser = User {
    u_role = E.GroupAdmin
  , u_username = Username "groupadmin"
  , u_email = Email "groupadmin@university.com"
  , u_name = "Group Admin"
  , u_timezone = utcZoneInfo
  , u_language = Language "hu"
  , u_uid = Uid "groupadmin"
  }

courseAdminUser :: User
courseAdminUser = User {
    u_role = E.CourseAdmin
  , u_username = Username "courseadmin"
  , u_email = Email "courseadmin@university.com"
  , u_name = "Course Admin"
  , u_timezone = utcZoneInfo
  , u_language = Language "hu"
  , u_uid = Uid "courseadmin"
  }

-- * Test Tools

runStory c u s = do
  e <- runUserStory c trans u s
  case e of
    Left ue -> error $ show ue
    Right a -> return a

userStoryTestContext steps = do
  context >>= runReaderT steps

lang :: Language
lang = Language "en"

-- Runs a UserStory computation in the given context with a user bracketed
-- with login/logout
userStory username story = do
  c <- ask
  (_,state1) <- lift $ runStory c (UserNotLoggedIn lang) $ login username
  (value,state2) <- lift $ runStory c state1 story
  (_, _) <- lift $ runStory c state2 (logout lang)
  return value

runStoryWithState state story = do
  c <- ask
  (value, _) <- lift $ runStory c state story
  return value

-- Runs a UserStory computation in the given context with admin user
adminStory = runStoryWithState adminUserState

-- Runs a UserStory computation in the given context with TestAgent user
testAgentStory = runStoryWithState TestAgent

-- Runs a UserStory computation in the given context with Registration user
registrationStory = runStoryWithState Registration

assertUserState :: UserState -> User -> IO ()
assertUserState (UserNotLoggedIn _) _ = error "User is not logged in"
assertUserState state usr = do
  assertBool "Invalid user is logged in" $ (user state) == (u_username usr)
  assertBool "Invalid person name: "     $ (name state) == (u_name usr)
  assertBool "Invalid role was loaded"   $ (role state) == (u_role usr)

initPersistent :: IO ()
initPersistent = do
  init <- createPersistInit defaultConfig
  setUp <- PersistInit.isSetUp init
  when setUp $ PersistInit.tearDown init
  PersistInit.initPersist init
  setUp <- PersistInit.isSetUp init
  assertBool "Setting up persistence was failed" setUp

cleanUpPersistent :: IO ()
cleanUpPersistent = do
  init <- createPersistInit defaultConfig
  PersistInit.tearDown init


