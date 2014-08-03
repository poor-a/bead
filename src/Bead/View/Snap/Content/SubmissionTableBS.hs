{-# LANGUAGE OverloadedStrings #-}
module Bead.View.Snap.Content.SubmissionTableBS (
    AdministratedCourses
  , AdministratedGroups
  , CourseTestScriptInfos
  , SubmissionTableContext(..)
  , submissionTable
  , submissionTableContext
  , sortUserLines
  , resultCell
  ) where

import           Data.Char (isAlphaNum)
import           Data.Function
import           Data.List
import           Data.Map (Map)
import qualified Data.Map as Map
import           Data.Maybe
import           Data.Monoid
import           Data.String
import           Data.Time
import           Numeric

import qualified Bead.Domain.Entities as E
import qualified Bead.Domain.Entity.Assignment as Assignment
import           Bead.Domain.Evaluation
import           Bead.Domain.Relationships
import qualified Bead.Controller.Pages as Pages
import           Bead.Controller.UserStories (UserStory)
import qualified Bead.Controller.UserStories as S
import           Bead.View.Snap.Content
import qualified Bead.View.Snap.DataBridge as Param

import           Text.Blaze.Html5 ((!))
import qualified Text.Blaze.Html5 as H
import qualified Text.Blaze.Html5.Attributes as A


type AdministratedCourses = Map CourseKey E.Course

type AdministratedGroups  = Map GroupKey  (E.Group, String)

type CourseTestScriptInfos = Map CourseKey [(TestScriptKey, TestScriptInfo)]

data SubmissionTableContext = SubmissionTableContext {
    stcAdminCourses :: AdministratedCourses
  , stcAdminGroups  :: AdministratedGroups
  , stcCourseTestScriptInfos :: CourseTestScriptInfos
  }

submissionTableContextCata f (SubmissionTableContext courses groups testscripts)
  = f courses groups testscripts

submissionTableContext :: UserStory SubmissionTableContext
submissionTableContext = do
  ac <- S.administratedCourses
  ag <- S.administratedGroups
  ts <- Map.fromList <$> mapM (testScriptForCourse . fst) ac
  return $! SubmissionTableContext {
      stcAdminCourses = adminCourseMap ac
    , stcAdminGroups  = adminGroupMap ag
    , stcCourseTestScriptInfos = ts
    }
  where
    testScriptForCourse ck = do
      infos <- S.testScriptInfos ck
      return (ck, infos)

    adminCourseMap = Map.fromList

    adminGroupMap = Map.fromList . map (\(k,g,c) -> (k,(g,c)))

submissionTable :: String -> UTCTime -> SubmissionTableContext -> SubmissionTableInfo -> IHtml
submissionTable tableId now stb table = submissionTableContextCata html stb where
  html courses groups testscripts = do
    msg <- getI18N
    return $ do
      H.h4 . H.b $ fromString $ stiCourse table
      i18n msg $ assignmentCreationMenu courses groups table
      i18n msg $ submissionTablePart tableId now stb table
      i18n msg $ courseTestScriptTable testscripts table

table' m
  = H.div ! A.class_ "row"
  $ H.div ! A.class_ "col-md-12" ! A.draggable "true"
  $ H.table ! A.class_ "table table-bordered table-condensed table-striped table-hover" $ m

-- Produces the HTML table from the submission table information,
-- if there is no users registered and submission posted to the
-- group or course students, an informational text is shown.
-- Supposing that the given tableid is unique name on the page.
submissionTablePart :: String -> UTCTime -> SubmissionTableContext -> SubmissionTableInfo -> IHtml

-- Empty table
submissionTablePart tableId _now _ctx s
  | and [null $ submissionTableInfoAssignments s, null $ stiUsers s] = do
    msg <- getI18N
    return $ do
      table' $ do
        H.td (fromString $ msg $ Msg_Home_SubmissionTable_NoCoursesOrStudents "There are no assignments or students yet.")


-- Non empty table
submissionTablePart tableId now ctx s = do
  msg <- getI18N
  return $ do
    courseForm $ do
      table' $ do
        checkedUserScript
        assignmentLine msg
        mapM_ (userLine s) (stiUserLines s)
  where
    -- JavaScript
    tableIdJSName = filter isAlphaNum tableId
    noOfUsers = tableIdJSName ++ "NoOfUsers"
    onCheck = tableIdJSName ++ "OnCheck"
    onUncheck = tableIdJSName ++ "OnUncheck"
    removeButton = tableIdJSName ++ "Button"
    onClick = tableIdJSName ++ "OnClick"
    checkedUserScript = H.script $ fromString $ unlines
      [ concat ["var ", noOfUsers, " = 0;"]
      , concat ["function ", onCheck, "(){"]
      ,   noOfUsers ++ "++;"
      ,   concat ["if(", noOfUsers, " > 0) {"]
      ,     concat ["document.getElementById(\"",removeButton,"\").disabled = false;"]
      ,   "}"
      , "}"
      , concat ["function ", onUncheck, "(){"]
      ,   noOfUsers ++ "--;"
      ,   concat ["if(", noOfUsers, " < 1) {"]
      ,     concat ["document.getElementById(\"",removeButton,"\").disabled = true;"]
      ,     noOfUsers ++ " = 0;"
      ,   "}"
      , "}"
      , concat ["function ", onClick, "(checkbox){"]
      ,   "if(checkbox.checked) {"
      ,      onCheck ++ "();"
      ,   "} else {"
      ,      onUncheck ++ "();"
      ,   "}"
      , "}"
      ]

    -- HTML
    courseForm = submissionTableInfoCata course group s where
      course _n _us _as _uls _ns ck      = postForm (routeOf $ Pages.deleteUsersFromCourse ck ())
      group _n _us _cgas _uls _ns _ck gk = postForm (routeOf $ Pages.deleteUsersFromGroup gk ())

    headerCell = H.th

    assignmentLine msg = H.tr $ do
      headerCell $ fromString $ msg $ Msg_Home_SubmissionTable_StudentName "Name"
      headerCell $ fromString $ msg $ Msg_Home_SubmissionTable_Username "Username"
      assignmentLinks
      deleteHeaderCell msg
      where
        openedHeaderCell o c (_i,ak) =
          if isActiveAssignment ak
            then H.th # o
            else H.th # c

        assignmentLinks = submissionTableInfoCata course group s

        course _name _users as _ulines _anames _key =
          mapM_ (\x -> openedHeaderCell openCourseAssignmentStyle closedCourseAssignmentStyle x
                         $ modifyAssignmentLink "" x)
              $ zip [1..] as

        group  _name _users cgas _ulines _anames ckey _gkey = do
          let as = reverse . snd $ foldl numbering ((1,1),[]) cgas
          mapM_ header as
          where
            numbering ((c,g),as) = cgInfoCata
              (\ak -> ((c+1,g),(CourseInfo (c,ak):as)))
              (\ak -> ((c,g+1),(GroupInfo  (g,ak):as)))

            header = cgInfoCata
              (\x -> openedHeaderCell openCourseAssignmentStyle closedCourseAssignmentStyle x $
                       viewAssignmentLink ckey (msg $ Msg_Home_CourseAssignmentIDPreffix "C") x)
              (\x -> openedHeaderCell openGroupAssignmentStyle closedGroupAssignmentStyle x $
                       modifyAssignmentLink (msg $ Msg_Home_GroupAssignmentIDPreffix "G") x)

    assignmentName ak = maybe "" Assignment.name . Map.lookup ak $ stiAssignmentInfos s

    isActiveAssignment ak =
      maybe False (flip Assignment.isActive now) . Map.lookup ak $ stiAssignmentInfos s

    modifyAssignmentLink pfx (i,ak) =
      linkWithTitle
        (routeOf $ Pages.modifyAssignment ak ())
        (assignmentName ak)
        (concat [pfx, show i])


    viewAssignmentLink ck pfx (i,ak) =
      linkWithTitle
        (viewOrModifyAssignmentLink ck ak)
        (assignmentName ak)
        (concat [pfx, show i])
      where
        viewOrModifyAssignmentLink ck ak =
          case Map.lookup ck (stcAdminCourses ctx) of
            Nothing -> routeOf $ Pages.viewAssignment ak ()
            Just _  -> routeOf $ Pages.modifyAssignment ak ()

    userLine s (u,_p,submissionInfoMap) = do
      H.tr $ do
        let username = ud_username u
        H.td . fromString $ ud_fullname u
        H.td . fromString $ usernameCata id username
        submissionCells username s
        deleteUserCheckbox u
      where
        submissionInfos = submissionTableInfoCata course group where
          course _n _users as _ulines _anames _key =
            catMaybes $ map (\ak -> Map.lookup ak submissionInfoMap) as

          group _n _users as _ulines _anames _ckey _gkey =
            catMaybes $ map lookup as
            where
              lookup = cgInfoCata (const Nothing) (flip Map.lookup submissionInfoMap)


        submissionCells username = submissionTableInfoCata course group where
          course _n _users as _ulines _anames _key = mapM_ (submissionInfoCell username) as

          group _n _users as _ulines _anames _ck _gk =
            mapM_ (cgInfoCata (submissionInfoCell username) (submissionInfoCell username)) as

        submissionInfoCell u ak = case Map.lookup ak submissionInfoMap of
          Nothing -> H.td $ mempty -- dataCell noStyle $ fromString "░░░"
          Just si -> submissionCell u (ak,si)

    submissionCell u (ak,si) =
      resultCell
        (linkWithHtml (routeWithParams (Pages.userSubmissions ()) [requestParam u, requestParam ak]))
        mempty -- (H.i ! A.class_ "glyphicon glyphicon-th"    ! A.style "color:#0000FF; font-size: xx-large" $ mempty) -- not found
        (H.i ! A.class_ "glyphicon glyphicon-stop"  ! A.style "color:#AAAAAA; font-size: xx-large" $ mempty) -- non-evaluated
        (H.i ! A.class_ "glyphicon glyphicon-cloud" ! A.style "color:#FFFF00; font-size: xx-large" $ mempty) -- tested
        (H.i ! A.class_ "glyphicon glyphicon-thumbs-up" ! A.style "color:#00FF00; font-size: xx-large" $ mempty) -- accepted
        (H.i ! A.class_ "glyphicon glyphicon-thumbs-down" ! A.style "color:#F00; font-size: xx-large" $ mempty) -- rejected
        si    -- of percent

    deleteHeaderCell msg = submissionTableInfoCata deleteForCourseButton deleteForGroupButton s where
        deleteForCourseButton _n _us _as _uls _ans _ck =
          headerCell $ submitButtonDanger
            removeButton
            (msg $ Msg_Home_DeleteUsersFromCourse "Remove") ! A.disabled ""

        deleteForGroupButton _n _us _as _uls _ans _ck _gk =
          headerCell $ submitButtonDanger
            removeButton
            (msg $ Msg_Home_DeleteUsersFromGroup "Remove") ! A.disabled ""

    deleteUserCheckbox u = submissionTableInfoCata deleteCourseCheckbox deleteGroupCheckbox s where
        deleteCourseCheckbox _n _us _as _uls _ans _ck =
          H.td $ checkBox
            (Param.name delUserFromCoursePrm)
            (encode delUserFromCoursePrm $ ud_username u)
            False ! A.onclick (fromString (onClick ++ "(this)"))

        deleteGroupCheckbox _n _us _as _uls _ans _ck _gk =
          H.td $ checkBox
            (Param.name delUserFromGroupPrm)
            (encode delUserFromGroupPrm $ ud_username u)
            False ! A.onclick (fromString (onClick ++ "(this)"))


resultCell contentWrapper notFound unevaluated tested passed failed s =
  H.td $ contentWrapper (sc s)
  where
    sc = submissionInfoCata
           notFound
           unevaluated
           tested
           (\_key result -> val result) -- evaluated

    val (EvResult (BinEval (Binary Passed))) = passed
    val (EvResult (BinEval (Binary Failed))) = failed
    val (EvResult (PctEval (Percentage (Scores [p])))) = fromString $ percent p
    val (EvResult (PctEval (Percentage _))) = error "SubmissionTable.coloredSubmissionCell percentage is not defined"

    percent x = join [show . round $ (100 * x), "%"]

courseTestScriptTable :: CourseTestScriptInfos -> SubmissionTableInfo -> IHtml
courseTestScriptTable cti = submissionTableInfoCata course group where
  course _n _us _as _uls _ans ck = testScriptTable cti ck
  group _n _us _as _uls _ans _ck _gk = (return (return ()))

-- Renders a course test script modification table if the information is found in the
-- for the course, otherwise an error message. If the course is found, and there is no
-- test script found for the course a message indicating that will be rendered, otherwise
-- the modification table is rendered
testScriptTable :: CourseTestScriptInfos -> CourseKey -> IHtml
testScriptTable cti ck = maybe (return "") courseFound $ Map.lookup ck cti where
  courseFound ts = do
    msg <- getI18N
    return $ do
      table' $ do
        headLine . msg $ Msg_Home_ModifyTestScriptTable "Testers"
        case ts of
          []  -> dataCell noStyle $ fromString . msg $
                   Msg_Home_NoTestScriptsWereDefined "There are no testers for the course."
          ts' -> mapM_ testScriptLine ts'
    where
      headLine = H.tr . (H.th # textAlign "left" ! A.colspan "4") . fromString
      tableId = join ["tst-", courseKeyMap id ck]
      dataCell r = H.td -- # (informationalCell <> r)

      testScriptLine (tsk,tsi) = do
        dataCell noStyle $ linkWithText
          (routeOf (Pages.modifyTestScript tsk ()))
          (tsiName tsi)

-- Renders a menu for the creation of the course or group assignment if the
-- user administrates the given group or course
assignmentCreationMenu
  :: AdministratedCourses
  -> AdministratedGroups
  -> SubmissionTableInfo
  -> IHtml
assignmentCreationMenu courses groups = submissionTableInfoCata courseMenu groupMenu
  where
    groupMenu _n _us _as _uls _ans ck gk = maybe
      (return (return ()))
      (const $ do
        msg <- getI18N
        return . navigationWithRoute msg $
          case Map.lookup ck courses of
            Nothing -> [Pages.newGroupAssignment gk ()]
            Just _  -> [Pages.newGroupAssignment gk (), Pages.newCourseAssignment ck ()] )
      (Map.lookup gk groups)

    courseMenu _n _us _as _uls _ans ck = maybe
      (return (return ()))
      (const $ do
        msg <- getI18N
        return (navigationWithRoute msg [Pages.newCourseAssignment ck ()]))
      (Map.lookup ck courses)

    navigationWithRoute msg links =
      H.div ! A.class_ "row" $ H.div ! A.class_ "col-md-6" $ H.div ! A.class_ "btn-group" $ mapM_ elem links
      where
        elem page = H.a ! A.href (routeOf page) ! A.class_ "btn btn-default" $ (fromString . msg $ linkText page)

-- * CSS Section

openCourseAssignmentStyle = backgroundColor "#52B017"
openGroupAssignmentStyle  = backgroundColor "#00FF00"
closedCourseAssignmentStyle = backgroundColor "#736F6E"
closedGroupAssignmentStyle = backgroundColor "#A3AFAE"

-- * Colors

newtype RGB = RGB (Int, Int, Int)

pctCellColor :: Double -> RGB
pctCellColor x = RGB (round ((1 - x) * 255), round (x * 255), 0)

colorStyle :: RGB -> String
colorStyle (RGB (r,g,b)) = join ["background-color:#", hex r, hex g, hex b]
  where
    twoDigits [d] = ['0',d]
    twoDigits ds  = ds

    hex x = twoDigits (showHex x "")

-- * Tools

sortUserLines = submissionTableInfoCata course group where
  course name users assignments userlines names key =
      CourseSubmissionTableInfo name users assignments (sort userlines) names key

  group name users assignments userlines names ckey gkey =
      GroupSubmissionTableInfo name users assignments (sort userlines) names ckey gkey

  sort = sortBy (compareHun `on` fst3)

  fst3 :: (a,b,c) -> a
  fst3 (x,_,_) = x

submissionTableInfoAssignments = submissionTableInfoCata course group where
  course _n _us as _uls _ans _ck = as
  group _n _us cgas _uls _ans _ck _gk = map (cgInfoCata id id) cgas

headLine = H.tr . H.th . fromString