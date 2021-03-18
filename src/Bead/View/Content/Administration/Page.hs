{-# LANGUAGE OverloadedStrings #-}
module Bead.View.Content.Administration.Page (
    administration
  , assignCourseAdmin
  , createCourse
  ) where

import           Prelude

import           Control.Arrow ((***), (&&&))
import           Control.Monad
import           Data.Function (on)
import           Data.List
import           Data.String (fromString)

import qualified Bead.Controller.Pages as Pages
import qualified Bead.Controller.UserStories as Story
import           Bead.View.Content
import qualified Bead.View.Content.Bootstrap as Bootstrap
import qualified Bead.View.UserActions as UA (UserAction(..))

import           Text.Blaze.Html5 as H hiding (map)
import           Text.Blaze.Html5.Attributes as A hiding (id)
import qualified Text.Blaze.Html5.Attributes as A

administration = ViewHandler administrationPage

data PageInfo = PageInfo {
    courses      :: [(CourseKey, Course)]
  , admins       :: [User]
  , courseAdmins :: [User]
  , assignedCourseAdmins :: [(Course, [User])]
  }

administrationPage :: GETContentHandler
administrationPage = do
  (cs,ausers,assigned) <- userStory $ do
    cs <- Story.selectCourses each
    ausers <- Story.selectUsers adminOrCourseAdmin
    assigned <- Story.allCourseAdministrators
    return (cs,ausers,assigned)
  let info = PageInfo {
      courses = cs
    , admins = filter admin ausers
    , courseAdmins = filter courseAdmin ausers
    , assignedCourseAdmins = assigned
    }
  setPageContents $ htmlPage (msg_LinkText_Administration "Administration") $ administrationContent info
  where
    each _ _ = True

    adminOrCourseAdmin u =
      case u_role u of
        Admin -> True
        CourseAdmin -> True
        _ -> False

    admin = (Admin ==) . u_role
    courseAdmin = (CourseAdmin ==) . u_role

administrationContent :: PageInfo -> IHtml
administrationContent info = do
  msg <- getI18N
  return $ do
    Bootstrap.row $ Bootstrap.colMd12 $ do
      H.h3 $ (fromString . msg $ msg_Administration_NewCourse "New course")
      postForm (routeOf createCourse) $ do
        -- i18n msg $ inputPagelet emptyCourse
        Bootstrap.textInput (fieldName courseNameField) (msg $ msg_Input_Course_Name "Title") ""
        Bootstrap.textInput (fieldName courseDescField) (msg $ msg_Input_Course_Description "Description") ""
        Bootstrap.selectionWithLabel
          (fieldName testScriptTypeField)
          (msg $ msg_Input_Course_TestScript "Type of test script")
          (const False)
          (testScriptTypes msg)

        -- Help message for the percentage
        H.span ! A.id (fieldName pctHelpMessage) ! A.hidden "" $
          (fromString . msg $ msg_Administration_PctHelpMessage "Minimum of percent to achieve by students")
        Bootstrap.submitButton (fieldName createCourseBtn) (fromString . msg $ msg_Administration_CreateCourse "Create")
    Bootstrap.row $ Bootstrap.colMd12 $ do
      H.h3 $ (fromString . msg $ msg_Administration_AssignCourseAdminTitle "Assign teacher to course")
      let coursesInfo = courses info
      nonEmpty coursesInfo (fromString . msg $ msg_Administration_NoCourses "There are no courses.") $ do
        nonEmpty (courseAdmins info) (noCourseAdminInfo msg coursesInfo) $ do
          H.p (fromString . msg $
            msg_Administration_HowToAddMoreAdmins
              "Further teachers can be added by modifying roles of users, then assign them to courses.")
          postForm (routeOf assignCourseAdmin) $ do
            Bootstrap.selection (fieldName selectedCourse) (const False) courses'
            Bootstrap.selection (fieldName selectedCourseAdmin) (const False) courseAdmins'
            Bootstrap.submitButton (fieldName assignBtn) (fromString . msg $ msg_Administration_AssignCourseAdminButton "Assign")
      courseAdministratorsTable msg (assignedCourseAdmins info)
    Bootstrap.row $ Bootstrap.colMd12 $ do
      H.h3 $ (fromString . msg $ msg_Administration_ChangeUserProfile "Modify users")
      getForm (routeOf userDetails) $ do
        -- i18n msg $ inputPagelet emptyUsername
        Bootstrap.textInput (fieldName usernameField) "" ""
        Bootstrap.submitButton (fieldName selectBtn) (fromString . msg $ msg_Administration_SelectUser "Select")
  where
    noCourseAdminInfo msg coursesInfo = do
      fromString . msg $ msg_Administration_NoCourseAdmins "There are no teachers. Teachers can be created by modifying roles of users."
      Bootstrap.table $ do
        H.thead $ H.tr $ H.th $ fromString . msg $ msg_Administration_CreatedCourses "Courses"
        H.tbody $ forM_ coursesInfo (\(_ckey,c) -> H.tr $ H.td $ fromString $ courseName c)

    userLongname :: User -> String
    userLongname u = concat [ u_name u, " - ", usernameCata id $ u_username u ]

    courses' :: [(CourseKey, String)]
    courses' = sortBy (compareHun `on` snd) $ map (id *** courseName) $ courses info

    courseAdmins' :: [(Username, String)]
    courseAdmins' = sortBy (compareHun `on` snd) $ map (u_username &&& userLongname) $ courseAdmins info

    createCourse      = Pages.createCourse ()
    assignCourseAdmin = Pages.assignCourseAdmin ()
    userDetails       = Pages.userDetails ()

    testScriptTypes msg = [
        (TestScriptSimple, msg $ msg_Input_TestScriptSimple "Simple")
      , (TestScriptZipped, msg $ msg_Input_TestScriptZipped "Zipped")
      ]

courseAdministratorsTable :: I18N -> [(Course,[User])] -> H.Html
courseAdministratorsTable _ [] = return ()
courseAdministratorsTable i18n courses = Bootstrap.row $ Bootstrap.colMd12 $ do
  H.p . fromString . i18n . msg_Administration_CourseAdmins_Info $ unlines
    [ "Each line of the following table contains a course and the username of the administrators,"
    , " that are assigned to the course."
    ]
  let courses' = sortBy (compare `on` (courseName . fst)) courses
  Bootstrap.table $ do
    H.thead $ do
      H.th (fromString . i18n $ msg_Administration_CourseAdmins_Course "Course")
      H.th (fromString . i18n $ msg_Administration_CourseAdmins_Admins "Administrators")
    H.tbody $ forM_ courses' $ \(course, admins) -> do
      H.tr $ do
        H.td . fromString $ courseName course
        let admins' = sort $ map u_name admins
        H.td . fromString . concat $ intersperse ", " admins'

-- Add Course Admin

assignCourseAdmin :: ModifyHandler
assignCourseAdmin = ModifyHandler $ do
  admin <- getParameter (jsonUsernamePrm  (fieldName selectedCourseAdmin))
  course <- getParameter (jsonCourseKeyPrm (fieldName selectedCourse))
  return $ Action $ do
    Story.createCourseAdmin admin course
    return $ redirection $ Pages.administration ()

-- Create Course

createCourse :: ModifyHandler
createCourse = ModifyHandler $ do
  c <- getCourse
  return $ Action $ do
    Story.createCourse c
    return $ redirection $ Pages.administration ()

getCourse :: ContentHandler Course
getCourse = Course
  <$> getParameter (stringParameter (fieldName courseNameField) "Course name")
  <*> getParameter (stringParameter (fieldName courseDescField) "Course description")
  <*> getParameter (jsonParameter (fieldName testScriptTypeField) "Script type")
