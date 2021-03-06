{-# LANGUAGE OverloadedStrings, ExistentialQuantification #-}
{-# LANGUAGE CPP #-}
module Bead.View.TemplateAndComponentNames where

-- This module contains information about templates and
-- fields in the type safe manner.

import           Data.Text (Text)
import qualified Data.Text as T

import           Bead.View.Fay.HookIds
import qualified Bead.Controller.Pages as P

#ifdef TEST
import qualified Data.Set as Set
import           Test.Tasty.TestSet
#endif

-- * Type safe declarations

class SnapFieldName f where
  fieldName :: f -> Text

newtype SubmitButton = SubmitButton { sbFieldName :: Text }

instance SnapFieldName SubmitButton where
  fieldName = sbFieldName

newtype FieldName = FieldName Text

instance SnapFieldName FieldName where
  fieldName (FieldName f) = f

-- * Component names

instance SnapFieldName LoginField where
  fieldName = T.pack . lcFieldName

loginSubmitBtn = SubmitButton "login-submit"
regSubmitBtn   = SubmitButton "reg-submit"
pwdSubmitBtn   = SubmitButton "pwd-submit"
regGroupSubmitBtn = SubmitButton "reg-group-submit"
createGroupBtn    = SubmitButton "crt-group-submit"
createCourseBtn = SubmitButton "crt-course-submit"
assignBtn = SubmitButton "asg-assign-submit"
selectBtn = SubmitButton "select-submit"
saveEvalBtn = SubmitButton "save-eval-submit"
saveSubmitBtn = SubmitButton "save-submit-button"
submitSolutionBtn = SubmitButton "submit-solution-btn"
commentBtn = SubmitButton "comment-submit-btn"
saveChangesBtn = SubmitButton "save-changes-btn"
assignGroupAdminBtn = SubmitButton "asg-group-admin-submit"
changeProfileBtn = SubmitButton "change-profile"
changePasswordBtn = SubmitButton "change-password"
unsubscribeFromCourseSubmitBtn = SubmitButton "unsubscribe-from-course"

instance SnapFieldName RegistrationComp where
  fieldName = T.pack . rFieldName

data ExerciseForm
  = ExerciseForm     { eFieldName :: String }
  | ExerciseKeyField { eFieldName :: String }

instance SnapFieldName ExerciseForm where
  fieldName = T.pack . eFieldName

exerciseForm = ExerciseForm "exercise"
exerciseKey  = ExerciseKeyField "exercise-key"

data CourseFormInfo
  = CourseKeyInfo   { cFieldName :: String }
  | CourseFormInfo  { cFieldName :: String }
  | CourseNameField { cFieldName :: String }
  | CourseCodeField { cFieldName :: String }
  | CourseDescField { cFieldName :: String }

instance SnapFieldName CourseFormInfo where
  fieldName = T.pack . cFieldName

courseKeyInfo  = CourseKeyInfo  "course-key"
courseFormInfo = CourseFormInfo "course"
courseCodeField = CourseCodeField "course-code"
courseNameField = CourseNameField "course-name"
courseDescField = CourseDescField "course-desc"

newtype GroupKeyName
  = GroupKeyName { gkFieldName :: String }

instance SnapFieldName GroupKeyName where
  fieldName = T.pack . gkFieldName

groupKeyName = GroupKeyName "group-key"

data GroupField
  = GroupCodeField { gFieldName :: String }
  | GroupDescField { gFieldName :: String }
  | GroupNameField { gFieldName :: String }
  | GroupEvalField { gFieldName :: String }

instance SnapFieldName GroupField where
  fieldName = T.pack . gFieldName

groupCodeField = GroupCodeField "group-code"
groupNameField = GroupNameField "group-name"
groupDescField = GroupDescField "group-desc"
groupEvalField = GroupEvalField "group-eval"

newtype UserField = UserField  { uFieldName :: String }

instance SnapFieldName UserField where
  fieldName = T.pack . uFieldName

usernameField  = UserField "username"
userEmailField = UserField "useremail"
userRoleField  = UserField "userrole"
userFamilyNameField = UserField "userfamilyname"
userTimeZoneField = UserField "usertimezone"
userUidField = UserField "useruid"

instance SnapFieldName ChangePwdField where
  fieldName = T.pack . cpf

menuId :: P.Page a b c d e f -> String
menuId = P.pageCata
  (c "link-index")
  (c "link-login")
  (c "link-logout")
  (c "link-home")
  (c "link-profile")
  (c "link-admin")
  (c2 "link-student-view")
  (c2 "link-group-overview")
  (c2 "link-group-overview-as-student")
  (c3 "link-course-overview")
  (c "link-evaluation-table")
  (c2 "link-evaluation")
  (c3 "link-modify-evaluation")
  (c2 "link-new-group-assignment")
  (c2 "link-new-course-assignment")
  (c2 "link-modify-assignment")
  (c2 "link-view-assignment")
  (c2 "link-new-group-assignment-preview")
  (c2 "link-new-course-assignment-preview")
  (c2 "link-modify-assignment-preview")
  (c2 "link-submission")
  (c3 "link-submission-details")
  (c2 "link-view-user-score")
  (c3 "link-new-user-score")
  (c2 "link-modify-user-score")
  (c "link-group-registration")
  (c "link-user-details")
  (c "link-upload-files")
  (c "link-create-course")
  (c2 "link-create-group")
  (c "link-assign-course-admin")
  (c2 "link-assign-group-admin")
  (c2 "link-create-test-script")
  (c3 "link-modify-test-script")
  (c "link-change-password")
#ifndef SSO
  (c "link-set-user-password")
#endif
  (c2 "link-delete-users-from-course")
  (c2 "link-delete-users-from-group")
  (c2 "link-queue-submission-for-test")
  (c2 "link-queue-all-submissions-for-test")
  (c2 "link-unsubscribe-from-course")
  (c2 "link-export-evaluations-admined-groups")
  (c2 "link-export-evaluations-all-groups")
  (c2 "link-export-submissions")
  (c3 "link-export-submissions-of-groups")
  (c3 "link-export-submissions-of-one-group")
  (c2 "link-get-submission")
  (c3 "link-get-submissions-of-user-in-group")
  (c3 "link-get-submissions-of-assignment-in-group")
  (c2 "link-get-course-csv")
  (c2 "link-get-group-csv")
  (c2 "link-new-group-assessment")
  (c2 "link-new-course-assessment")
  (c2 "link-fill-group-assessment-preview")
  (c2 "link-fill-course-assessment-preview")
  (c2 "link-modify-assessment")
  (c2 "link-modify-assessment-preview")
  (c2 "link-view-asssessment")
  (c "link-notifications")
  (c2 "link-view-moss-script-output")
  (c2 "link-similarity-check-moss")
  (c2 "link-rest-submission-table")
  (c2 "link-rest-users-in-group")
    where
      c = const
      c2 = c . const
      c3 = c2 . const

instance SnapFieldName (P.Page a b c d e f) where
  fieldName = T.pack . menuId

newtype AssignmentField = AssignmentField { aFieldName :: String }

assignmentNameField  = AssignmentField  "asg-name"
assignmentDescField  = AssignmentField  "asg-desc"
assignmentTCsField   = AssignmentField   "asg-tcs"
assignmentAspectField = AssignmentField  "asg-asp"
assignmentPwdField   = AssignmentField   "asg-pwd"
assignmentKeyField   = AssignmentField   "asg-key"
assignmentEvField    = AssignmentField    "asg-ev"
assignmentTestCaseField = AssignmentField "asg-testcase"
assignmentTestScriptField = AssignmentField "asg-testscript"
assignmentUsersFileField = AssignmentField "asg-usersfield"
assignmentSubmissionTypeField = AssignmentField "asg-subt"
assignmentNoOfTriesField = AssignmentField "asg-no-of-tries"

instance SnapFieldName AssignmentField where
  fieldName = T.pack . aFieldName

newtype AssessmentField = AssessmentField { assessFieldName :: String }

assessmentKeyField = AssessmentField "assess-key"

newtype ScoreField = ScoreField { scoreFieldName :: String }

instance SnapFieldName ScoreField where
    fieldName = T.pack . scoreFieldName

scoreKeyField = ScoreField "score-key"

instance SnapFieldName AssessmentField where
  fieldName = T.pack . assessFieldName

data AssignCourseAdminField
  = SelectedCourse { acFieldName :: String }
  | SelectedCourseAdmin { acFieldName :: String }

selectedCourse = SelectedCourse "selected-course"
selectedCourseAdmin = SelectedCourseAdmin "selected-course-admin"

instance SnapFieldName AssignCourseAdminField where
  fieldName = T.pack . acFieldName

data AssignCourseGroupAdminField
  = SelectedGroupAdmin { cpFieldName :: String }
  | SelectedGroup      { cpFieldName :: String }

selectedGroup = SelectedGroup "selected-group"
selectedGroupAdmin = SelectedGroupAdmin "selected-group-admin"

instance SnapFieldName AssignCourseGroupAdminField where
  fieldName = T.pack . cpFieldName

data GroupRegistrationField
  = GroupRegistrationField { grFieldName :: String }

groupRegistrationField = GroupRegistrationField "group-registration"

instance SnapFieldName GroupRegistrationField where
  fieldName = T.pack . grFieldName

instance SnapFieldName SubmissionField where
  fieldName = T.pack . sfFieldName

newtype EvaluationField = EvaluationField { evFieldName :: String }

evaluationValueField = EvaluationField "evaluation"
evaluationKeyField   = EvaluationField "evaluation-key"
evaluationConfigField = EvaluationField "evaluation-config"
evaluationPercentageField = EvaluationField "evaluation-percentage"
evaluationCommentOnlyField = EvaluationField "evaluation-comment-only"
evaluationFreeFormField = EvaluationField "evaluation-freeformat-text"

instance SnapFieldName EvaluationField where
  fieldName = T.pack . evFieldName

data CommentField
  = CommentKeyField   { ckFieldName :: String }
  | CommentValueField { ckFieldName :: String }

commentKeyField = CommentKeyField "comment-key"
commentValueField = CommentValueField "comment-value"

instance SnapFieldName CommentField where
  fieldName = T.pack . ckFieldName

newtype ChangeLanguageField = ChangeLanguageField { clgFieldName :: String }

changeLanguageField = ChangeLanguageField "change-language"
userLanguageField = ChangeLanguageField "user-change-language"

instance SnapFieldName ChangeLanguageField where
  fieldName = T.pack . clgFieldName

data TableName = TableName {
    tName :: String
  }

instance SnapFieldName TableName where
  fieldName = T.pack . tName

availableAssignmentsTable = TableName "available-assignments"
submissionTableName = TableName "submission-table"
registrationTable = TableName "reg-form-table"
resetPasswordTable = TableName "rst-pwd-table"
profileTable = TableName "profile-table"
changePasswordTable = TableName "change-password-table"
courseAdministratorsTableName = TableName "course-administrators-table"
groupAdministratorsTableName = TableName "group-administrators-table"

newtype HomeField = HomeField { hfFieldName :: String }

instance SnapFieldName HomeField where
  fieldName = T.pack . hfFieldName

delUserFromCourseField = HomeField "del-user-form-course"
delUserFromGroupField  = HomeField "del-user-from-group"

newtype UploadFileField = UploadFileField { ufFieldName :: String }

newtype UploadFileClass = UploadFileClass { ufClassName :: String }

instance SnapFieldName UploadFileField where
  fieldName = T.pack . ufFieldName

fileUploadField = UploadFileField "upload-file"
fileUploadSubmit = UploadFileField "upload-file-submit"
usersFileTableName = UploadFileField "upload-file-table"
usersFileTableClass = UploadFileClass "upload-file-table-class"

newtype CourseKeyField = CourseKeyField { ckfFieldName :: String }

instance SnapFieldName CourseKeyField where
  fieldName = T.pack . ckfFieldName

courseKeyField = CourseKeyField "course-key-field"

newtype GroupKeyField = GroupKeyField { gkfFieldName :: String }

instance SnapFieldName GroupKeyField where
  fieldName = T.pack . gkfFieldName

groupKeyField = GroupKeyField "group-key-field"

newtype TestScriptField = TestScriptField { tscFieldName :: String }

instance SnapFieldName TestScriptField where
  fieldName = T.pack . tscFieldName

testScriptNameField = TestScriptField "test-script-name"
testScriptTypeField = TestScriptField "test-script-type"
testScriptDescField = TestScriptField "test-script-desc"
testScriptNotesField = TestScriptField "test-script-note"
testScriptScriptField = TestScriptField "test-script-script"
testScriptSaveButton = TestScriptField "test-script-save-button"
testScriptKeyField = TestScriptField "test-script-key"

-- * Template names

newtype LoginTemp = LoginTemp String
  deriving (Eq)

loginTemp = LoginTemp "login"

-- * Class names

data TableClassName = TableClassName {
    tcName :: String
  }


evaluationClassTable = TableClassName "evaluation-table"
submissionListTable = TableClassName "submission-list-table"
groupSubmissionTable = TableClassName "group-submission-table"
assignmentTable = TableClassName "assignment-table"

data DivClassName = DivClassName {
    divClass :: String
  }

submissionListDiv = DivClassName "submission-list-div"

instance SnapFieldName HookId where
  fieldName = T.pack . hookId

#ifdef TEST

-- * Unit tests

data SFN = forall n . SnapFieldName n => SFN n

instance SnapFieldName SFN where
  fieldName (SFN n) = fieldName n

fieldList :: [Text]
fieldList = map fieldName $ concat [
  [ SFN loginUsername,  SFN loginPassword,   SFN regFullName, SFN regEmailAddress, SFN regTimeZoneField
  , SFN exerciseForm,   SFN exerciseKey
  , SFN courseFormInfo, SFN courseCodeField, SFN courseNameField,        SFN courseDescField
  , SFN groupKeyName,   SFN groupCodeField,  SFN groupNameField,         SFN groupDescField
  , SFN usernameField,  SFN courseKeyInfo,   SFN userEmailField,         SFN userFamilyNameField, SFN userUidField
  , SFN userRoleField,  SFN loginSubmitBtn,  SFN assignmentDescField,    SFN assignmentTCsField
  , SFN selectedCourse, SFN selectedCourseAdmin,       SFN groupRegistrationField
  , SFN assignmentAspectField, SFN assignmentStartField, SFN assignmentEndField,     SFN evaluationResultField
  , SFN assignmentKeyField, SFN assignmentEvField,     SFN submissionKeyField
  , SFN commentKeyField,SFN commentValueField, SFN regSubmitBtn, SFN regGroupSubmitBtn, SFN createGroupBtn
  , SFN assignGroupAdminBtn, SFN createCourseBtn, SFN assignBtn, SFN selectBtn, SFN saveEvalBtn
  , SFN saveSubmitBtn, SFN submitSolutionBtn, SFN commentBtn, SFN saveChangesBtn
  , SFN availableAssignmentsTable, SFN submissionTableName, SFN groupEvalField, SFN profileTable
  , SFN changePasswordTable, SFN oldPasswordField, SFN newPasswordField, SFN newPasswordAgainField
  , SFN assignmentStartDateField, SFN assignmentEndDateField
  , SFN assignmentStartHourField, SFN assignmentStartMinField
  , SFN assignmentEndHourField, SFN assignmentEndMinField, SFN assignmentTestCaseField
  , SFN assignmentStartDefaultDate, SFN assignmentStartDefaultHour, SFN assignmentStartDefaultMin
  , SFN assignmentEndDefaultDate, SFN assignmentEndDefaultHour, SFN assignmentEndDefaultMin
  , SFN studentNewPwdField, SFN studentNewPwdAgainField, SFN pctHelpMessage, SFN changeLanguageField
  , SFN userLanguageField, SFN courseKeyField, SFN groupKeyField
  , SFN delUserFromCourseField, SFN delUserFromGroupField, SFN unsubscribeFromCourseSubmitBtn
  , SFN fileUploadField, SFN fileUploadSubmit, SFN usersFileTableName
  , SFN assignmentTestScriptField, SFN assignmentUsersFileField, SFN assignmentPwdField
  , SFN assignmentSubmissionTypeField, SFN assignmentNoOfTriesField
  , SFN assessmentKeyField

  , SFN evaluationValueField, SFN evaluationKeyField, SFN evaluationConfigField
  , SFN evaluationPercentageField, SFN evaluationCommentOnlyField, SFN evaluationFreeFormField

  , SFN testScriptNameField, SFN testScriptTypeField, SFN testScriptDescField
  , SFN testScriptNotesField, SFN testScriptScriptField, SFN testScriptSaveButton
  , SFN testScriptKeyField

  , SFN createCourseForm, SFN evaluationTypeSelection, SFN evaluationTypeValue, SFN startDateDivId
  , SFN evalTypeSelectionDiv, SFN registrationTable, SFN createGroupForm, SFN endDateDivId
  , SFN evaluationPercentageDiv, SFN regUserRegKey, SFN regToken, SFN regLanguage, SFN pwdSubmitBtn
  , SFN resetPasswordTable, SFN regPasswordAgain, SFN changeProfileBtn, SFN changePasswordBtn
  , SFN userTimeZoneField, SFN assignmentForm, SFN courseAdministratorsTableName
  , SFN groupAdministratorsTableName, SFN evCommentOnlyText
  ]
  ]

names = fieldList

fieldNameTest =
  assertEquals
    "Field names"
    (Set.size . Set.fromList $ names)
    (length names)
    "Field names must be unique"

#endif
