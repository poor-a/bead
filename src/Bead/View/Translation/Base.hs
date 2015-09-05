{-# LANGUAGE TemplateHaskell #-}
module Bead.View.Translation.Base where

import Language.Haskell.TH

-- Translation is an enumeration all the possbile messages that could be rendered
-- on every page with the associated value.
newtype Translation a = T { unT :: (Int, a) }
  deriving (Show,Read,Ord,Eq)

trans :: Translation a -> a
trans (T (_,x)) = x

t :: Int -> a -> Translation a
t = curry T

tid :: Translation a -> Int
tid (T (x,_)) = x

tlabel :: Translation a -> String
tlabel t = labels !! (tid t)

generateTranslationEntries :: [String] -> Q [Dec]
generateTranslationEntries labels =
  sequence [ entry tid l | (tid, l) <- [0..] `zip` labels ]
  where
    entry :: Int -> String -> Q Dec
    entry x n = do
      body <- [| \s -> t x s |]
      return $ FunD (mkName n) [Clause [] (NormalB body) []]

generateTranslationEnumList :: [String] -> Q Exp
generateTranslationEnumList labels = return $
  ListE [ AppE (VarE $ mkName n) (TupE []) | n <- labels ]

labels =
 [ "msg_Index_Header"
 , "msg_Index_Body"
 , "msg_Index_Proceed"

 , "msg_Login_PageTitle"
 , "msg_Login_Username"
 , "msg_Login_Password"
 , "msg_Login_Submit"
 , "msg_Login_Title"
 , "msg_Login_Registration"
 , "msg_Login_Forgotten_Password"
 , "msg_Login_InternalError"
 , "msg_Login_SelectLanguage"
 , "msg_Login_InvalidPasswordOrUser"
 , "msg_Login_On_SSO"
 , "msg_Login_Error"
 , "msg_Login_TryAgain"
 , "msg_Login_Error_NoUser"
 , "msg_Login_Error_NoSnapCache"
 , "msg_Login_Error_NoSnapUpdate"
 , "msg_Login_Error_NoLDAPAttributes"

 , "msg_Routing_InvalidRoute"
 , "msg_Routing_SessionTimedOut"

 , "msg_ErrorPage_Title"
 , "msg_ErrorPage_GoBackToLogin"
 , "msg_ErrorPage_Header"

 , "msg_Input_Group_Name"
 , "msg_Input_Group_Description"
 , "msg_Input_Group_Evaluation"
 , "msg_Input_Course_Name"
 , "msg_Input_Course_Description"
 , "msg_Input_Course_Evaluation"
 , "msg_Input_Course_TestScript"
 , "msg_Input_User_Role"
 , "msg_Input_User_Email"
 , "msg_Input_User_FullName"
 , "msg_Input_User_TimeZone"
 , "msg_Input_User_Language"
 , "msg_Input_TestScriptSimple"
 , "msg_Input_TestScriptZipped"

 , "msg_CourseAdmin_CreateCourse"
 , "msg_CourseAdmin_AssignAdmin"
 , "msg_CourseAdmin_AssignAdmin_Button"
 , "msg_CourseAdmin_CreateGroup"
 , "msg_CourseAdmin_NoCourses"
 , "msg_CourseAdmin_Course"
 , "msg_CourseAdmin_PctHelpMessage"
 , "msg_CourseAdmin_NoGroups"
 , "msg_CourseAdmin_NoGroupAdmins"
 , "msg_CourseAdmin_Group"
 , "msg_CourseAdmin_Admin"
 , "msg_CourseAdmin_GroupAdmins_Info"
 , "msg_CourseAdmin_GroupAdmins_Group"
 , "msg_CourseAdmin_GroupAdmins_Admins"

 , "msg_Administration_NewCourse"
 , "msg_Administration_PctHelpMessage"
 , "msg_Administration_CreatedCourses"
 , "msg_Administration_CreateCourse"
 , "msg_Administration_AssignCourseAdminTitle"
 , "msg_Administration_NoCourses"
 , "msg_Administration_NoCourseAdmins"
 , "msg_Administration_AssignCourseAdminButton"
 , "msg_Administration_ChangeUserProfile"
 , "msg_Administration_SelectUser"
 , "msg_Administration_HowToAddMoreAdmins"
 , "msg_Administration_CourseAdmins_Info"
 , "msg_Administration_CourseAdmins_Course"
 , "msg_Administration_CourseAdmins_Admins"

 , "msg_NewAssignment_Title"
 , "msg_NewAssignment_Title_Default"
 , "msg_NewAssignment_SubmissionDeadline"
 , "msg_NewAssignment_StartDate"
 , "msg_NewAssignment_EndDate"
 , "msg_NewAssignment_Description"
 , "msg_NewAssignment_Description_Default"
 , "msg_NewAssignment_Markdown"
 , "msg_NewAssignment_CanBeUsed"
 , "msg_NewAssignment_Properties"
 , "msg_NewAssignment_Course"
 , "msg_NewAssignment_Group"
 , "msg_NewAssignment_SaveButton"
 , "msg_NewAssignment_PreviewButton"
 , "msg_NewAssignment_Title_Normal"
 , "msg_NewAssignment_Title_BallotBox"
 , "msg_NewAssignment_Title_Password"
 , "msg_NewAssignment_Info_Normal"
 , "msg_NewAssignment_Info_BallotBox"
 , "msg_NewAssignment_Info_Password"
 , "msg_NewAssignment_TestCase"
 , "msg_NewAssignment_TestScripts"
 , "msg_NewAssignment_DoNotOverwrite"
 , "msg_NewAssignment_NoTesting"
 , "msg_NewAssignment_TestFile"
 , "msg_NewAssignment_TestFile_Info"
 , "msg_NewAssignment_AssignmentPreview"
 , "msg_NewAssignment_BallotBox"
 , "msg_NewAssignment_PasswordProtected"
 , "msg_NewAssignment_Password"
 , "msg_NewAssignment_EvaluationType"
 , "msg_NewAssignment_BinaryEvaluation"
 , "msg_NewAssignment_PercentageEvaluation"
 , "msg_NewAssignment_SubmissionType"
 , "msg_NewAssignment_TextSubmission"
 , "msg_NewAssignment_ZipSubmission"
 , "msg_NewAssignment_EvalTypeWarn"
 , "msg_NewAssignment_Isolated"
 , "msg_NewAssignment_Info_Isolated"
 , "msg_NewAssignment_Info_NoOfTries"
 , "msg_NewAssignment_NoOfTries"

 , "msg_GroupRegistration_RegisteredCourses"
 , "msg_GroupRegistration_SelectGroup"
 , "msg_GroupRegistration_NoRegisteredCourses"
 , "msg_GroupRegistration_Courses"
 , "msg_GroupRegistration_Admins"
 , "msg_GroupRegistration_NoAvailableCourses"
 , "msg_GroupRegistration_Register"
 , "msg_GroupRegistration_Unsubscribe"
 , "msg_GroupRegistration_NoUnsubscriptionAvailable"
 , "msg_GroupRegistration_Warning"

 , "msg_UserDetails_SaveButton"
 , "msg_UserDetails_NonExistingUser"

 , "msg_Submission_Course"
 , "msg_Submission_Admin"
 , "msg_Submission_Assignment"
 , "msg_Submission_Deadline"
 , "msg_Submission_Description"
 , "msg_Submission_Solution"
 , "msg_Submission_Submit"
 , "msg_Submission_TimeLeft"
 , "msg_Submission_Days"
 , "msg_Submission_DeadlineReached"
 , "msg_Submission_InvalidPassword"
 , "msg_Submission_NonUsersAssignment"
 , "msg_Submission_Password"
 , "msg_Submission_Info_Password"
 , "msg_Submission_Info_File"
 , "msg_Submission_File_NoFileReceived"
 , "msg_Submission_File_PolicyFailure"
 , "msg_Submission_File_InvalidFile"
 , "msg_Submission_File_InternalError"
 , "msg_Submission_Remaining"
 , "msg_Submission_NoTriesLeft"
 , "msg_Submission_Large_Submission"
 , "msg_Submission_Collapse_Submission"

 , "msg_Comments_Title"
 , "msg_Comments_SubmitButton"
 , "msg_Comments_AuthorTestScript_Public"
 , "msg_Comments_AuthorTestScript_Private"
 , "msg_Comments_TestPassed"
 , "msg_Comments_TestFailed"
 , "msg_Comments_BinaryResultPassed"
 , "msg_Comments_BinaryResultFailed"
 , "msg_Comments_PercentageResult"

 , "msg_Evaluation_Title"
 , "msg_Evaluation_Course"
 , "msg_Evaluation_Group"
 , "msg_Evaluation_Student"
 , "msg_Evaluation_SaveButton"
 , "msg_Evaluation_Submitted_Solution"
 , "msg_Evaluation_Submitted_Solution_Text_Info"
 , "msg_Evaluation_Submitted_Solution_Text_Link"
 , "msg_Evaluation_Submitted_Solution_Zip_Info"
 , "msg_Evaluation_Submitted_Solution_Zip_Link"
 , "msg_Evaluation_Accepted"
 , "msg_Evaluation_Rejected"
 , "msg_Evaluation_New_Comment"
 , "msg_Evaluation_Info"
 , "msg_Evaluation_Username"
 , "msg_Evaluation_SubmissionDate"

 , "msg_SubmissionDetails_Course"
 , "msg_SubmissionDetails_Admins"
 , "msg_SubmissionDetails_Assignment"
 , "msg_SubmissionDetails_Deadline"
 , "msg_SubmissionDetails_Description"
 , "msg_SubmissionDetails_Solution"
 , "msg_SubmissionDetails_Solution_Text_Info"
 , "msg_SubmissionDetails_Solution_Text_Link"
 , "msg_SubmissionDetails_Solution_Zip_Info"
 , "msg_SubmissionDetails_Solution_Zip_Link"
 , "msg_SubmissionDetails_Evaluation"
 , "msg_SubmissionDetails_NewComment"
 , "msg_SubmissionDetails_SubmitComment"
 , "msg_SubmissionDetails_InvalidSubmission"

 , "msg_Registration_Title"
 , "msg_Registration_Username"
 , "msg_Registration_Email"
 , "msg_Registration_FullName"
 , "msg_Registration_SubmitButton"
 , "msg_Registration_GoBackToLogin"
 , "msg_Registration_InvalidUsername"
 , "msg_Registration_HasNoUserAccess"
 , "msg_Registration_UserAlreadyExists"
 , "msg_Registration_RegistrationNotSaved"
 , "msg_Registration_EmailSubject"
 , "msg_Registration_EmailBody"
 , "msg_Registration_RequestParameterIsMissing"

 , "msg_RegistrationFinalize_NoRegistrationParametersAreFound"
 , "msg_RegistrationFinalize_SomeError"
 , "msg_RegistrationFinalize_InvalidToken"
 , "msg_RegistrationFinalize_UserAlreadyExist"
 , "msg_RegistrationFinalize_Password"
 , "msg_RegistrationFinalize_PwdAgain"
 , "msg_RegistrationFinalize_Timezone"
 , "msg_RegistrationFinalize_SubmitButton"
 , "msg_RegistrationFinalize_GoBackToLogin"

 , "msg_RegistrationCreateStudent_NoParameters"
 , "msg_RegistrationCreateStudent_InternalError"
 , "msg_RegistrationCreateStudent_InvalidToken"

 , "msg_RegistrationTokenSend_Title"
 , "msg_RegistrationTokenSend_StoryFailed"
 , "msg_RegistrationTokenSend_GoBackToLogin"

 , "msg_EvaluationTable_EmptyUnevaluatedSolutions"
 , "msg_EvaluationTable_Course"
 , "msg_EvaluationTable_Group"
 , "msg_EvaluationTable_Student"
 , "msg_EvaluationTable_Assignment"
 , "msg_EvaluationTable_Link"
 , "msg_EvaluationTable_Solution"
 , "msg_EvaluationTable_Info"
 , "msg_EvaluationTable_CourseAssignment"
 , "msg_EvaluationTable_GroupAssignment"
 , "msg_EvaluationTable_MiscCourseAssignment"
 , "msg_EvaluationTable_CourseAssignmentInfo"
 , "msg_EvaluationTable_GroupAssignmentInfo"
 , "msg_EvaluationTable_MiscCourseAssignmentInfo"
 , "msg_EvaluationTable_Username"
 , "msg_EvaluationTable_DateOfSubmission"

 , "msg_UserSubmissions_NonAccessibleSubmissions"
 , "msg_UserSubmissions_Course"
 , "msg_UserSubmissions_Assignment"
 , "msg_UserSubmissions_Student"
 , "msg_UserSubmissions_SubmittedSolutions"
 , "msg_UserSubmissions_SubmissionDate"
 , "msg_UserSubmissions_Evaluation"

 , "msg_UserSubmissions_Accepted"
 , "msg_UserSubmissions_Rejected"
 , "msg_UserSubmissions_NotFound"
 , "msg_UserSubmissions_NonEvaluated"
 , "msg_UserSubmissions_Tests_Passed"
 , "msg_UserSubmissions_Tests_Failed"

 , "msg_SubmissionList_CourseOrGroup"
 , "msg_SubmissionList_Admin"
 , "msg_SubmissionList_Assignment"
 , "msg_SubmissionList_Deadline"
 , "msg_SubmissionList_Description"
 , "msg_SubmissionList_SubmittedSolutions"
 , "msg_SubmissionList_NotEvaluatedYet"
 , "msg_SubmissionList_NoSubmittedSolutions"
 , "msg_SubmissionList_NonAssociatedAssignment"
 , "msg_SubmissionList_NonReachableAssignment"
 , "msg_SubmissionList_Info"
 , "msg_SubmissionList_NotFound"
 , "msg_SubmissionList_TestsPassed"
 , "msg_SubmissionList_TestsFailed"
 , "msg_SubmissionList_Passed"
 , "msg_SubmissionList_Failed"

 , "msg_ResetPassword_UserDoesNotExist"
 , "msg_ResetPassword_PasswordIsSet"
 , "msg_ResetPassword_GoBackToLogin"
 , "msg_ResetPassword_Username"
 , "msg_ResetPassword_Email"
 , "msg_ResetPassword_NewPwdButton"
 , "msg_ResetPassword_EmailSent"
 , "msg_ResetPassword_ForgottenPassword"
 , "msg_ResetPassword_EmailSubject"
 , "msg_ResetPassword_EmailBody"
 , "msg_ResetPassword_GenericError"
 , "msg_ResetPassword_InvalidPassword"

 , "msg_Profile_User"
 , "msg_Profile_Email"
 , "msg_Profile_FullName"
 , "msg_Profile_Timezone"
 , "msg_Profile_SaveButton"
 , "msg_Profile_OldPassword"
 , "msg_Profile_NewPassword"
 , "msg_Profile_NewPasswordAgain"
 , "msg_Profile_ChangePwdButton"
 , "msg_Profile_Language"
 , "msg_Profile_PasswordHasBeenChanged"

 , "msg_SetUserPassword_NonRegisteredUser"
 , "msg_SetUserPassword_User"
 , "msg_SetUserPassword_NewPassword"
 , "msg_SetUserPassword_NewPasswordAgain"
 , "msg_SetUserPassword_SetButton"

 , "msg_InputHandlers_BinEval"
 , "msg_InputHandlers_PctEval"
 , "msg_InputHandlers_Role_Student"
 , "msg_InputHandlers_Role_GroupAdmin"
 , "msg_InputHandlers_Role_CourseAdmin"
 , "msg_InputHandlers_Role_Admin"

 , "msg_Home_NewSolution"
 , "msg_Home_AdminTasks"
 , "msg_Home_CourseAdminTasks"
 , "msg_Home_CourseAdministration_Info"
 , "msg_Home_NoCoursesYet"
 , "msg_Home_GroupAdminTasks"
 , "msg_Home_NoGroupsYet"
 , "msg_Home_SubmissionTable_Info"
 , "msg_Home_CourseAdministration"
 , "msg_Home_CourseSubmissionTableList_Info"
 , "msg_Home_StudentTasks"
 , "msg_Home_HasNoRegisteredCourses"
 , "msg_Home_HasNoAssignments"
 , "msg_Home_Assignments_Info"
 , "msg_Home_Course"
 , "msg_Home_Limit"
 , "msg_Home_CourseAdmin"
 , "msg_Home_Assignment"
 , "msg_Home_Deadline"
 , "msg_Home_Evaluation"
 , "msg_Home_ClosedSubmission"
 , "msg_Home_SubmissionCell_NoSubmission"
 , "msg_Home_SubmissionCell_NonEvaluated"
 , "msg_Home_SubmissionCell_Accepted"
 , "msg_Home_SubmissionCell_Rejected"
 , "msg_Home_SubmissionCell_Tests_Failed"
 , "msg_Home_SubmissionCell_Tests_Passed"
 , "msg_Home_SubmissionTable_NoCoursesOrStudents"
 , "msg_Home_Remains"
 , "msg_Home_Reached"

 , "msg_Home_SubmissionTable_StudentName"
 , "msg_Home_SubmissionTable_Username"
 , "msg_Home_SubmissionTable_Summary"

 , "msg_Home_SubmissionTable_Accepted"
 , "msg_Home_SubmissionTable_Rejected"
 , "msg_Home_NonBinaryEvaluation"
 , "msg_Home_HasNoSummary"
 , "msg_Home_NonPercentageEvaluation"
 , "msg_Home_DeleteUsersFromCourse"
 , "msg_Home_DeleteUsersFromGroup"
 , "msg_Home_NotAdministratedTestScripts"
 , "msg_Home_NoTestScriptsWereDefined"
 , "msg_Home_ModifyTestScriptTable"
 , "msg_Home_CourseAssignmentIDPreffix"
 , "msg_Home_GroupAssignmentIDPreffix"
 , "msg_Home_ThereIsIsolatedAssignment"

 , "msg_NewTestScript_Name"
 , "msg_NewTestScript_Type"
 , "msg_NewTestScript_Description"
 , "msg_NewTestScript_Notes"
 , "msg_NewTestScript_Script"
 , "msg_NewTestScript_Save"
 , "msg_NewTestScript_Course"
 , "msg_NewTestScript_HasNoCourses"
 , "msg_NewTestScript_ScriptTypeHelp"

 , "msg_UploadFile_FileSelection"
 , "msg_UploadFile_Directory"
 , "msg_UploadFile_Info"
 , "msg_UploadFile_UploadButton"
 , "msg_UploadFile_FileName"
 , "msg_UploadFile_FileSize"
 , "msg_UploadFile_FileDate"
 , "msg_UploadFile_Successful"
 , "msg_UploadFile_NoFileReceived"
 , "msg_UploadFile_PolicyFailure"
 , "msg_UploadFile_UnnamedFile"
 , "msg_UploadFile_InternalError"
 , "msg_UploadFile_ErrorInManyUploads"

 , "msg_UserStory_SetTimeZone"
 , "msg_UserStory_ChangedUserDetails"
 , "msg_UserStory_CreateCourse"
 , "msg_UserStory_SetCourseAdmin"
 , "msg_UserStory_SetGroupAdmin"
 , "msg_UserStory_CreateGroup"
 , "msg_UserStory_SubscribedToGroup"
 , "msg_UserStory_SubscribedToGroup_ChangeNotAllowed"
 , "msg_UserStory_NewGroupAssignment"
 , "msg_UserStory_NewCourseAssignment"
 , "msg_UserStory_UsersAreDeletedFromCourse"
 , "msg_UserStory_UsersAreDeletedFromGroup"
 , "msg_UserStory_SuccessfulCourseUnsubscription"
 , "msg_UserStory_NewTestScriptIsCreated"
 , "msg_UserStory_ModifyTestScriptIsDone"
 , "msg_UserStory_AlreadyEvaluated"
 , "msg_UserStory_EvalTypeWarning"

 , "msg_UserStoryError_UnknownError"
 , "msg_UserStoryError_Message"
 , "msg_UserStoryError_SameUserIsLoggedIn"
 , "msg_UserStoryError_InvalidUsernameOrPassword"
 , "msg_UserStoryError_NoCourseAdminOfCourse"
 , "msg_UserStoryError_NoAssociatedTestScript"
 , "msg_UserStoryError_NoGroupAdmin"
 , "msg_UserStoryError_NoGroupAdminOfGroup"
 , "msg_UserStoryError_AlreadyHasSubmission"
 , "msg_UserStoryError_UserIsNotLoggedIn"
 , "msg_UserStoryError_RegistrationProcessError"
 , "msg_UserStoryError_AuthenticationNeeded"
 , "msg_UserStoryError_SubmissionDeadlineIsReached"
 , "msg_UserStoryError_XID"
 , "msg_UserStoryError_TestAgentError"
 , "msg_UserStoryError_EmptyAssignmentTitle"
 , "msg_UserStoryError_EmptyAssignmentDescription"
 , "msg_UserStoryError_NonAdministratedCourse"
 , "msg_UserStoryError_NonAdministratedGroup"
 , "msg_UserStoryError_NonAdministratedAssignment"
 , "msg_UserStoryError_NonRelatedAssignment"
 , "msg_UserStoryError_NonAdministratedSubmission"
 , "msg_UserStoryError_NonAdministratedTestScript"
 , "msg_UserStoryError_NonCommentableSubmission"
 , "msg_UserStoryError_NonAccessibleSubmission"
 , "msg_UserStoryError_BlockedSubmission"

 , "msg_UserActions_ChangedUserDetails"

 , "msg_LinkText_Login"
 , "msg_LinkText_Logout"
 , "msg_LinkText_Home"
 , "msg_LinkText_Profile"
 , "msg_LinkText_Error"
 , "msg_LinkText_CourseAdministration"
 , "msg_LinkText_CourseOverview"
 , "msg_LinkText_Submission"
 , "msg_LinkText_SubmissionList"
 , "msg_LinkText_UserSubmissions"
 , "msg_LinkText_NewTestScript"
 , "msg_LinkText_ModifyTestScript"
 , "msg_LinkText_UploadFile"
 , "msg_LinkText_ModifyEvaluation"
 , "msg_LinkText_ViewAssignment"
 , "msg_LinkText_SubmissionDetails"
 , "msg_LinkText_Administration"
 , "msg_LinkText_Evaluation"
 , "msg_LinkText_EvaluationTable"
 , "msg_LinkText_GroupRegistration"
 , "msg_LinkText_CreateCourse"
 , "msg_LinkText_UserDetails"
 , "msg_LinkText_AssignCourseAdmin"
 , "msg_LinkText_CreateGroup"
 , "msg_LinkText_AssignGroupAdmin"
 , "msg_LinkText_NewGroupAssignment"
 , "msg_LinkText_NewCourseAssignment"
 , "msg_LinkText_ModifyAssignment"
 , "msg_LinkText_NewGroupAssignmentPreview"
 , "msg_LinkText_NewCourseAssignmentPreview"
 , "msg_LinkText_ModifyAssignmentPreview"
 , "msg_LinkText_ChangePassword"
 , "msg_LinkText_SetUserPassword"
 , "msg_LinkText_DeleteUsersFromCourse"
 , "msg_LinkText_DeleteUsersFromGroup"
 , "msg_LinkText_UnsubscribeFromCourse"
 , "msg_LinkText_GetSubmission"

 , "msg_TestScriptTypeSimple"
 , "msg_TestScriptTypeZipped"

 , "msg_Domain_EvalPassed"
 , "msg_Domain_EvalFailed"
 , "msg_Domain_EvalNoResultError"
 , "msg_Domain_EvalPercentage"

 , "msg_SeeMore_SeeMore"
 , "msg_SeeMore_SeeLess"

 , "msg_Markdown_NotFound"
 ]
