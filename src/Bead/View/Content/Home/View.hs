{-# LANGUAGE OverloadedStrings, CPP #-}
module Bead.View.Content.Home.View where

import           Control.Arrow ((***))
import           Control.Monad.Identity
import           Data.Function (on)
import           Data.List (find, intersperse, sortBy)
import qualified Data.Map as Map
import           Data.Maybe (isJust)
import           Data.String (fromString)
import qualified Data.Text as T

import           Text.Blaze.Html5 hiding (map, id)
import qualified Text.Blaze.Html5 as H
import           Text.Blaze.Html5.Attributes as A hiding (id)

import qualified Bead.Controller.Pages as Pages
import           Bead.Domain.Entities as E (Role(..))
import           Bead.Domain.Evaluation
import           Bead.View.Markdown (markdownToHtml)
import           Bead.View.Content as Content hiding (userState, table, assessments)
import           Bead.View.Content.SubmissionState as SState
import           Bead.View.Content.SubmissionTable as ST
import           Bead.View.Content.ScoreInfo (scoreInfoToIconLink,scoreInfoToIcon)
import           Bead.View.Content.VisualConstants

import qualified Bead.View.Content.Bootstrap as Bootstrap
import           Bead.View.Content.Home.Data

homeContent :: HomePageData -> IHtml
homeContent d = do
  let s = userState d
      r = Content.role s
      hasCourse = hasCourses d
      hasGroup  = hasGroups d
      testScripts = courseTestScripts d
  msg <- getI18N
  return $ do
            when (isAdmin s) $ do
              Bootstrap.row $ Bootstrap.colMd12 $ do
                h3 . fromString . msg $ msg_Home_AdminTasks "Administrator Menu"
                i18n msg $ navigation [administration]

            -- Course Administration Menu
            when (courseAdminUser r) $ do
              Bootstrap.row $ Bootstrap.colMd12 $ do
                h3 . fromString . msg $ msg_Home_CourseAdminTasks "Course Administrator Menu"
                when (not hasCourse) $ do
                  H.p $ fromString . msg $ msg_Home_NoCoursesYet
                    "There are no courses.  Contact the administrator to have courses assigned."

            -- Submission tables for course or group assignments
            when ((courseAdminUser r) || (groupAdminUser r)) $ do
              when hasGroup $ do
                when (not . null $ concatMap submissionTableInfoAssignments $ sTables d) $ do
                  Bootstrap.row $ Bootstrap.colMd12 $ p $ fromString . msg $ msg_Home_SubmissionTable_Info $ concat
                    [ "Assignments may be modified by clicking on their identifiers if you have rights for the modification (their names are shown in the tooltip).  "
                    , "Students may be unregistered from the courses or the groups by checking the boxes in the Remove column "
                    , "then clicking on the button."
                    ]
                i18n msg $ htmlSubmissionTables d

              -- HR
              Bootstrap.row $ Bootstrap.colMd12 $ hr

              -- Course Administration links
              when hasCourse $ do
                Bootstrap.row $ Bootstrap.colMd12 $ h3 $ fromString . msg $ msg_Home_CourseAdministration "Course Administration"
                Bootstrap.row $ Bootstrap.colMd12 $ p $ fromString . msg $ msg_Home_CourseSubmissionTableList_Info $ concat
                  [ "Submission table for courses can be found on separate pages, please click on the "
                  , "name of a course."
                  ]
                Bootstrap.row $ Bootstrap.colMd12 $ ul ! class_ "list-group" $ do
                  let courseList = sortBy (compareHun `on` (courseName . snd)) $ Map.toList $ administratedCourseMap d
                  forM_ courseList $ \(ck, c) ->
                    li ! class_ "list-group-item"
                       $ a ! href (fromString $ routeOf (courseOverview ck))
                       $ (fromString (courseName c))

            -- Course Administration Button Group
            when (courseAdminUser r && hasCourse) $ do
              Bootstrap.row $ Bootstrap.colMd12 $ p $ fromString . msg $ msg_Home_CourseAdministration_Info $ concat
                [ "New groups for courses may be created in the Course Settings menu.  Teachers may be also assigned to "
                , "each of the groups there as well."
                ]
              i18n msg $ navigation $ courseAdminButtons
            -- Group Administration Button Group
            when (groupAdminUser r && hasGroup) $ do
              i18n msg $ navigation groupAdminButtons

            -- HR
            when (or [groupAdminUser r && hasGroup, courseAdminUser r && hasCourse]) $ do
              Bootstrap.row $ Bootstrap.colMd12 $ hr

            -- Student Menu
            when (not $ isAdmin r) $ do
              Bootstrap.row $ Bootstrap.colMd12 $ h3 $ fromString $ msg $ msg_Home_StudentTasks "Student Menu"
              i18n msg $ navigation [groupRegistration]
              i18n msg $ availableAssignmentsAssessments d (timeConverter d) (assignmentsAssessments d)
  where
      administration    = Pages.administration ()
      courseAdmin       = Pages.courseAdmin ()
      courseOverview ck = Pages.courseOverview ck ()
      evaluationTable   = Pages.evaluationTable ()
      groupRegistration = Pages.groupRegistration ()
      newTestScript     = Pages.newTestScript ()
#ifndef SSO
      setUserPassword   = Pages.setUserPassword ()
#endif
      uploadFile     = Pages.uploadFile ()

      courseAdminUser = (==E.CourseAdmin)
      groupAdminUser  = (==E.GroupAdmin)

      -- With single sign-on, passwords cannot be set.
#ifdef SSO
      courseAdminButtons = [ courseAdmin, newTestScript, evaluationTable, uploadFile ]
      groupAdminButtons = [ evaluationTable, uploadFile ]
#else
      courseAdminButtons = [courseAdmin, newTestScript, evaluationTable, setUserPassword, uploadFile ]
      groupAdminButtons = [evaluationTable, setUserPassword, uploadFile ]
#endif

-- * Helpers

submissionTableInfoAssignments = submissionTableInfoCata course group where
  course _n _us as _uls _grps _ck = as
  group _n _us cgas _uls _ck _gk = map (cgInfoCata id id) cgas

htmlSubmissionTables :: HomePageData -> IHtml
htmlSubmissionTables pd = do
  sbmTables <- mapM (htmlSubmissionTable pd) $ zip [1..] (sTables pd)
  asmtTables <- mapM (assessmentTable pd) (sTables pd)
  return $ forM_ (zip sbmTables asmtTables) $ \(s,a) -> s >> a
  where
    assessmentTable pd s = do
      case Map.lookup (submissionTableInfoToCourseGroupKey s) (assessmentTables pd) of
        Nothing -> return $ return ()
        Just sb -> htmlAssessmentTable sb

    htmlSubmissionTable pd (i,s) = do
      submissionTable (concat ["st", show i]) (now pd) (submissionTableCtx pd) s

-- assessment table for teachers
htmlAssessmentTable :: ScoreBoard -> IHtml
htmlAssessmentTable board
  | (null . sbAssessments $ board) = return mempty
  | otherwise = do
      msg <- getI18N
      return $ do
        Bootstrap.rowColMd12 . H.p . fromString . msg $ msg_Home_AssessmentTable_Assessments "Assessments"
        Bootstrap.rowColMd12 . Bootstrap.table $ do
          H.tr $ do
            H.th . fromString . msg $ msg_Home_AssessmentTable_StudentName "Name"
            H.th . fromString . msg $ msg_Home_AssessmentTable_Username "Username"
            forM_ (zip sortedAssessments [1..]) (assessmentViewButton msg)
          forM_ (sortBy (compareHun `on` ud_fullname) (sbUsers board)) (userLine msg)
      where
        assessmentViewButton :: I18N -> ((AssessmentKey,Assessment),Int) -> Html
        assessmentViewButton msg ((ak,as),n) = H.td $ Bootstrap.customButtonLink style modifyLink assessmentName (show n)
            where
              style = [fst ST.groupButtonStyle]
              modifyLink = routeOf $ Pages.modifyAssessment ak ()
              assessmentName = assessment (\title _desc _creation _cfg _visible -> title) as

        userLine :: I18N -> UserDesc -> Html
        userLine msg userDesc = H.tr $ do
          H.td . string . ud_fullname $ userDesc
          H.td . string . uid id . ud_uid $ userDesc
          forM_ sortedAssessments (scoreIcon msg . ud_username $ userDesc)

        scoreIcon :: I18N -> Username -> (AssessmentKey,Assessment) -> Html
        scoreIcon msg username (ak,_as) = H.td $ scoreInfoToIconLink msg (newScoreLink ak username) modifyLink scoreInfo
              where (scoreInfo,modifyLink) = case Map.lookup (ak,username) (sbScores board) of
                                               Just scoreKey -> (maybe Score_Not_Found id (Map.lookup scoreKey (sbScoreInfos board)), modifyScoreLink scoreKey)
                                               Nothing       -> (Score_Not_Found,"")

        newScoreLink ak u = routeOf $ Pages.newUserScore ak u ()
        modifyScoreLink sk = routeOf $ Pages.modifyUserScore sk ()

        sortByCreationTime :: [(AssessmentKey,Assessment)] -> [(AssessmentKey,Assessment)]
        sortByCreationTime = sortBy (compare `on` (created . snd))

        sortedAssessments = sortByCreationTime (sbAssessments board)

navigation :: [Pages.Page a b c d e f] -> IHtml
navigation links = do
  msg <- getI18N
  return
    $ Bootstrap.row
    $ Bootstrap.colMd12
    $ H.div ! class_ "btn-group"
    $ mapM_ (i18n msg . linkButtonToPageBS) links

availableAssignmentsAssessments :: HomePageData -> UserTimeConverter -> [(Group, Course, [ActiveAssignment], [ActiveAssessment])] -> IHtml
availableAssignmentsAssessments pd timeconverter groups
  | null groups = do
      msg <- getI18N
      return
        $ Bootstrap.row
        $ Bootstrap.colMd12
        $ p
        $ fromString
        $ msg $ msg_Home_HasNoRegisteredCourses "There are no registered courses, register to some."
  | otherwise = do
      msg <- getI18N
      return $ do
        when (any hasAssignments groups) $ do
          Bootstrap.rowColMd12
            $ p
            $ fromString . msg $ msg_Home_Assignments_Info $ concat
              [ "Submissions and their evaluations may be accessed by clicking on each assignment's link. "
              , "The table shows only the last evaluation per assignment."
              ]

          Bootstrap.rowColMd12 $
            Bootstrap.alert Bootstrap.Info $
            markdownToHtml . msg $ msg_Home_EvaluationLink_Hint $
            "**Hint**: You can go straight to your submission by clicking on a link in the Evaluation column."

        forM_ groups $ \g@(grp, course, assignments, assessments) -> do
          h4 $ fromString $ fullGroupName course grp
          if (not (hasAssignments g || hasAssessments g))
            then Bootstrap.row
                   $ Bootstrap.colMd12
                   $ p
                   $ fromString
                   $ msg $ msg_Home_HasNoAssignments "There are no available assignments yet."
            else do
              when (hasAssignments g) $ do
                Bootstrap.rowColMd12 $ do
                  let areIsolateds = areOpenAndIsolatedAssignments assignments
                  let visibleAsgs = if areIsolateds then (isolatedAssignments assignments) else assignments
                  let isLimited = isLimitedAssignments visibleAsgs
                  when areIsolateds $
                    Bootstrap.alert Bootstrap.Warning $
                      markdownToHtml . msg $ msg_Home_ThereIsIsolatedAssignment $ concat
                        [ "**Isolated mode**: There is at least one assignment which hides the normal assignments for "
                        , "this course."
                        ]
                  Bootstrap.table $ do
                    thead $ headerLine msg isLimited
                    -- Sort assignments by their end date time in reverse
                    tbody $ mapM_ (assignmentLine msg isLimited)
                      $ reverse $ sortBy (compare `on` (aEndDate . activeAsgDesc))
                      $ visibleAsgs
              -- Assessment table
              availableAssessments msg g
  where
    isLimitedAssignments = isJust . find limited

    limited = submissionLimit (const False) (\_ _ -> True) (const True) . (\(_a,ad,_si) -> aLimit ad)

    isOpenAndIsolated a = and [aIsolated a, aActive a]

    areOpenAndIsolatedAssignments = isJust . find (isOpenAndIsolated . activeAsgDesc)

    isolatedAssignments = filter (isOpenAndIsolated . activeAsgDesc)

    groupRegistration = Pages.groupRegistration ()

    headerLine :: I18N -> Bool -> H.Html
    headerLine msg isLimited = tr $ do
      th ""
      th (fromString $ msg $ msg_Home_Assignment "Assignment")
      when isLimited $ th (fromString $ msg $ msg_Home_Limit "Limit")
      th (fromString $ msg $ msg_Home_Deadline "Deadline")
      th (fromString $ msg $ msg_Home_Evaluation "Evaluation")

    assignmentLine :: I18N -> Bool -> ActiveAssignment -> H.Html
    assignmentLine msg isLimited (a, aDesc, subm) = H.tr $ do
      case and [aActive aDesc, noLimitIsReached aDesc] of
        True ->
          td $ H.span
                 ! A.class_ "glyphicon glyphicon-lock"
                 ! A.style "visibility: hidden"
                 $ mempty
        False ->
          td $ H.span
                 ! A.class_ "glyphicon glyphicon-lock"
                 $ mempty
      td $ Bootstrap.link (routeOf (Pages.submission a ())) (aTitle aDesc)
      when isLimited $ td (fromString . limit $ aLimit aDesc)
      td (fromString . showDate . timeconverter $ aEndDate aDesc)
      H.td submissionStateLabel
      where
        noLimitIsReached = submissionLimit (const True) (\n _ -> n > 0) (const False) . aLimit
        limit = fromString . submissionLimit
          (const "") (\n _ -> unwords [msg $ msg_Home_Remains "Remains:", show n]) (const $ msg $ msg_Home_Reached "Reached")

        submissionDetails :: SubmissionKey -> Pages.Page () () () () () ()
        submissionDetails key = Pages.submissionDetails a key ()

        submissionStateLabel :: Html
        submissionStateLabel = 
          maybe
          (Bootstrap.grayLabel $ T.pack $ msg $ msg_Home_SubmissionCell_NoSubmission "No submission")
          (\(key, state) ->
             Bootstrap.link (routeOf (submissionDetails key)) (SState.formatSubmissionState SState.toLabel msg state))
          subm

-- assessment table for students
availableAssessments :: I18N -> (Group, Course, [ActiveAssignment], [ActiveAssessment]) -> Html
availableAssessments msg (_, _, _, assessments) | null assessments = mempty
                                                | otherwise = do
  Bootstrap.rowColMd12 . H.p . fromString . msg $ msg_Home_AssessmentTable_Assessments "Assessments"
  Bootstrap.rowColMd12 . Bootstrap.table $ do
    H.tr (header sortedAssessments)
    H.tr $ mapM_ evaluationViewButton (zip [(sk,si) | (_,_,sk,si) <- sortedAssessments] [1..])
  where
      header assessments = mapM_ (H.td . assessmentLabel) (zip [assessment | (_ak,assessment,_sk,_si) <- assessments] [1..])
          where
            assessmentLabel :: (Assessment, Int) -> Html
            assessmentLabel (as,n) = Bootstrap.grayLabel (T.pack $ show n) ! tooltip
                where aTitle = assessment (\title _desc _creation _cfg _visible -> title) as
                      tooltip = A.title . fromString $ aTitle

      evaluationViewButton :: ((Maybe ScoreKey, ScoreInfo),Int) -> Html
      evaluationViewButton ((Just sk,info),n) = H.td $ scoreInfoToIconLink msg "" viewScoreLink info
          where viewScoreLink = routeOf $ Pages.viewUserScore sk ()
      evaluationViewButton ((Nothing,info),n) = H.td $ scoreInfoToIcon msg info

      sortedAssessments = sortByCreationTime assessments
      sortByCreationTime = sortBy (compare `on` (\(_ak,as,_sk,_si) -> created as))
