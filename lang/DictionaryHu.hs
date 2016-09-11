module DictionaryHu (dict) where

import Bead.View.Dictionary
import Bead.View.Translation

dict = DictionaryFile {
  iconFile = "hu.ico",
  langCode = "hu",
  langName = "Magyar",
  entries =
    [ msg_Index_Header <| "Köszöntjük!"
    , msg_Index_Body <| "Az oldalt az intézményhez tartozó Active Directory címtárban regisztrált felhasználók tudják használni.\n\nAmennyiben rendelkezünk ilyen hozzáféréssel, a belépéshez kattintsunk a **Tovább** gombra!\n\n*Megjegyzés:* A biztonságos bejelentkezéshez javasolt az [IWA](https://en.wikipedia.org/wiki/Integrated_Windows_Authentication) használata azokban a böngészőkben, ahol ez elérhető."
    , msg_Index_Proceed <| "Tovább"
    , msg_Login_PageTitle <| "Bejelentkezés"
    , msg_Login_Username <| "Felhasználónév:"
    , msg_Login_Password <| "Jelszó:"
    , msg_Login_Submit <| "Bejelentkezés"
    , msg_Login_Title <| "Bejelentkezés"
    , msg_Login_Registration <| "Regisztráció"
    , msg_Login_Forgotten_Password <| "Elfelejtett jelszó"
    , msg_Login_InternalError <| "Belső hiba történt, jelezzük az üzemeltetőknek!"
    , msg_Login_SelectLanguage <| "Nyelvek"
    , msg_Login_InvalidPasswordOrUser <| "Ismeretlen felhasználó vagy jelszó!"
    , msg_Login_On_SSO <| "Ezt az oldalt single sign-on módban nem lenne szabad elérni.  Jelezzük az üzemeltetőknek!"
    , msg_Login_Error <| "Sajnos hiba történt a bejelentkezés során: "
    , msg_Login_TryAgain <| "Próbáljuk újra!"
    , msg_Login_Error_NoUser <| "Ismeretlen felhasználó"
    , msg_Login_Error_NoSnapCache <| "A Snap nem tudta elmenteni a felhasználó (%s) adatait"
    , msg_Login_Error_NoSnapUpdate <| "A Snap nem tudta frissíteni a felhasználó (%s) adatait"
    , msg_Login_Error_NoLDAPAttributes <| "A felhasználó (%s) adatai nem kérdezhetőek le az LDAP adatbázisból"
    , msg_Routing_InvalidRoute <| "Érvénytelen útvonal"
    , msg_Routing_SessionTimedOut <| "Lejárt a munkamenet"
    , msg_ErrorPage_Title <| "Error"
    , msg_ErrorPage_GoBackToLogin <| "Vissza a bejelentkezéshez"
    , msg_ErrorPage_Header <| "Valami hiba történt... :-)"
    , msg_Input_Group_Name <| "Név"
    , msg_Input_Group_Description <| "Leírás"
    , msg_Input_Group_Evaluation <| "Értékelés"
    , msg_Input_Course_Name <| "Név"
    , msg_Input_Course_Description <| "Leírás"
    , msg_Input_Course_Evaluation <| "Értékelés"
    , msg_Input_Course_TestScript <| "Tesztelés típusa"
    , msg_Input_User_Role <| "Szerepkör"
    , msg_Input_User_Email <| "Email cím"
    , msg_Input_User_FullName <| "Teljes név"
    , msg_Input_User_TimeZone <| "Időzóna"
    , msg_Input_User_Language <| "Nyelv"
    , msg_Input_TestScriptSimple <| "Szöveges"
    , msg_Input_TestScriptZipped <| "Tömörített"
    , msg_CourseAdmin_CreateCourse <| "Csoport létrehozása"
    , msg_CourseAdmin_AssignAdmin <| "Oktató hozzárendelése a csoporthoz"
    , msg_CourseAdmin_AssignAdmin_Button <| "Hozzárendelés"
    , msg_CourseAdmin_CreateGroup <| "Új csoport létrehozása a tárgyhoz"
    , msg_CourseAdmin_NoCourses <| "Nincsenek tárgyak!"
    , msg_CourseAdmin_Course <| "Tárgy"
    , msg_CourseAdmin_PctHelpMessage <| "A hallgató által minimálisan teljesítendő százalék"
    , msg_CourseAdmin_NoGroups <| "Nincsenek csoportok!"
    , msg_CourseAdmin_NoGroupAdmins <| "Nincsenek oktatók!"
    , msg_CourseAdmin_Group <| "Csoport"
    , msg_CourseAdmin_Admin <| "Oktató"
    , msg_CourseAdmin_GroupAdmins_Info <| "Az alábbi táblázat(ok) minden sora egy csoport nevét tartalmazza és a csoporthoz hozzárendelt oktatók neptun kódját."
    , msg_CourseAdmin_GroupAdmins_Group <| "Csoport"
    , msg_CourseAdmin_GroupAdmins_Admins <| "Oktatók"
    , msg_Administration_NewCourse <| "Új tárgy"
    , msg_Administration_PctHelpMessage <| "A hallgatók által minimálisan teljesítendő százalék"
    , msg_Administration_CreatedCourses <| "Tárgyak"
    , msg_Administration_CreateCourse <| "Létrehozás"
    , msg_Administration_AssignCourseAdminTitle <| "Oktató hozzárendelése a tárgyhoz"
    , msg_Administration_NoCourses <| "Nincsenek tárgyak!"
    , msg_Administration_NoCourseAdmins <| "Nincsenek oktatók!  Oktatókat a regisztrált felhasználók adatainek módosításával lehet létrehozni."
    , msg_Administration_AssignCourseAdminButton <| "Hozzárendelés"
    , msg_Administration_ChangeUserProfile <| "Felhasználó adatainak módosítása"
    , msg_Administration_SelectUser <| "Kiválasztás"
    , msg_Administration_HowToAddMoreAdmins <| "További oktatókat a felhasználói adatok módosításával lehet létrehozni, majd ezt követően tudjuk őket a tárgyakhoz rendelni."
    , msg_Administration_CourseAdmins_Info <| "A következő táblázat minden sora egy tárgyat és a tárgyhoz rendelt tárgyfelelősök felhasználói nevét tartalmazza."
    , msg_Administration_CourseAdmins_Course <| "Tárgy"
    , msg_Administration_CourseAdmins_Admins <| "Tárgyfelelősök"
    , msg_NewAssignment_Title <| "Cím"
    , msg_NewAssignment_Title_Default <| "Névtelen feladat"
    , msg_NewAssignment_SubmissionDeadline <| "Beadás ideje"
    , msg_NewAssignment_StartDate <| "Nyitás"
    , msg_NewAssignment_EndDate <| "Zárás"
    , msg_NewAssignment_Description <| "Szöveges leírás"
    , msg_NewAssignment_Description_Default <| "Ennek a szövegnek markdown formátumban kell lennie.  Íme erre néhány egyszerű példa:\n\n  - Ez egy lista egyik eleme, *dőlt betűvel*.\n  - Ez pedig egy másik elem, **félkövérrel**.  Ügyeljünk\n    arra, hogy a szöveg többi része igazítva maradjon.\n\nNéha egyszerűen csak formázatlan szöveget akarunk írni.  Lentebb látható egy példa, miként lehet ezt megcsinálni.  Habár a `formázatlan` szavakat bármikor írhatunk a backtick (`` ` ``) szimbólum segítségével.\n\n~~~~\nformázatlan szöveg\n~~~~~\n\nEmellett még linkek is [illeszthetőek](http://haskell.org/) a szövegbe.  És ha végképp semmi sem jut az eszünkbe, akkor akár <a>sima</a> <b>HTML kódot</b> <i>is be lehet ágyazni</i>."
    , msg_NewAssignment_Markdown <| "A markdown formázás"
    , msg_NewAssignment_CanBeUsed <| " tanulmányozása javasolt a további lehetőségek megismeréséhez."
    , msg_NewAssignment_Properties <| "Tulajdonságok"
    , msg_NewAssignment_Course <| "Tárgy"
    , msg_NewAssignment_Group <| "Csoport"
    , msg_NewAssignment_SaveButton <| "Mentés"
    , msg_NewAssignment_PreviewButton <| "Előnézet"
    , msg_NewAssignment_Title_BallotBox <| "Urna"
    , msg_NewAssignment_Title_Password <| "Jelszóvédett"
    , msg_NewAssignment_Info_Normal <| "A feladatot a kezdés idejétől a befejezés idejéig lehet beadni.  A feladat nem fog látszani a kezdés idejéig.  A feladatok mindig automatikusan nyílnak és záródnak."
    , msg_NewAssignment_Info_BallotBox <| "(Zárthelyihez javasolt) A beadott megoldások és a hozzájuk tartozó értékelés csak a befejezés után lesz elérhető a hallgatók számára."
    , msg_NewAssignment_Info_Password <| "(Zárthelyihez javasolt) Megoldás a feladatra csak jelszó megadásával adható be.  A jelszót az oktató tudja használni a zárthelyi során, ezáltal tudja hitelesíteni a hallgató által beküldeni kívánt megoldást."
    , msg_NewAssignment_TestCase <| "Tesztesetek"
    , msg_NewAssignment_TestScripts <| "Tesztelő"
    , msg_NewAssignment_DoNotOverwrite <| "Nem változik"
    , msg_NewAssignment_NoTesting <| "Tesztelés nélküli feladat"
    , msg_NewAssignment_TestFile <| "Tesztállomány"
    , msg_NewAssignment_TestFile_Info <| "Egy (tesztadatokat tartalmazó) állomány adható meg itt, amelyet a tesztelő megkap.  Állományok az \"%s\" oldalon keresztül tölthetőek fel."
    , msg_NewAssignment_AssignmentPreview <| "A feladat előnézete"
    , msg_NewAssignment_BallotBox <| "Urna"
    , msg_NewAssignment_PasswordProtected <| "Jelszóvédett"
    , msg_NewAssignment_Password <| "Jelszó:"
    , msg_NewAssignment_EvaluationType <| "Kiértékelés típusa"
    , msg_NewAssignment_BinEval <| "Kétértékű"
    , msg_NewAssignment_PctEval <| "Százalékos"
    , msg_NewAssignment_FftEval <| "Szabadformátumú szöveges"
    , msg_NewAssignment_BinaryEvaluation <| "Kétértékű"
    , msg_NewAssignment_PercentageEvaluation <| "Százalékos"
    , msg_NewAssignment_SubmissionType <| "Beküldés típusa"
    , msg_NewAssignment_TextSubmission <| "Szöveges"
    , msg_NewAssignment_ZipSubmission <| "Zip állomány"
    , msg_NewAssignment_EvalTypeWarn <| "A kiértékelés típusát nem lehet megváltoztatni, mert már érkezett megoldás a feladatra."
    , msg_NewAssignment_Isolated <| "Izolált"
    , msg_NewAssignment_Info_Isolated <| "(Zárthelyihez javasolt) A hallgató által más feladatokra beküldött megoldások nem láthatóak a hallgató számára, egy vagy több aktív izolált feladat jelenlétében. Megjegyzés: ha több mint egy izolált feladat van akkor mindegyikre a hallgató által beadott megoldás elérhető a hallgató számára."
    , msg_NewAssignment_Info_NoOfTries <| "A hallgató által a feladatra beadható megoldások számának maximuma."
    , msg_NewAssignment_NoOfTries <| "Próbálkozások száma"
    , msg_NewAssignment_FreeFormEvaluation <| "Szabadformátumú kiértékelés"
    , msg_NewAssessment_Title <| "Cím"
    , msg_NewAssessment_Description <| "Leírás"
    , msg_NewAssessment_StudentName <| "Név"
    , msg_NewAssessment_UserName <| "Neptun-kód"
    , msg_NewAssessment_Score <| "Eredmény"
    , msg_NewAssessment_EvaluationType <| "Értékelés típusa"
    , msg_NewAssessment_BinaryEvaluation <| "Kétértékű"
    , msg_NewAssessment_PercentageEvaluation <| "Százalékos"
    , msg_NewAssessment_FreeFormEvaluation <| "Szabadformátumú szöveges"
    , msg_NewAssessment_FillButton <| "Kitöltés"
    , msg_NewAssessment_SaveButton <| "Mentés"
    , msg_NewAssessment_PreviewButton <| "Előnézet"
    , msg_NewAssessment_GetCsvButton <| "CSV letöltése"
    , msg_NewAssessment_EvalTypeWarn <| "Az értékelés típusát nem lehet megváltoztatni, mert már van beírt eredmény."
    , msg_NewAssessment_Accepted <| "Elfogadott"
    , msg_NewAssessment_Rejected <| "Elutasított"
    , msg_GroupRegistration_RegisteredCourses <| "Felvett csoportok"
    , msg_GroupRegistration_SelectGroup <| "Tárgy és csoport kiválasztása"
    , msg_GroupRegistration_NoRegisteredCourses <| "Nincsenek felvett tárgyak.  Válasszunk egy  csoportot!"
    , msg_GroupRegistration_Courses <| "Csoportok"
    , msg_GroupRegistration_Admins <| "Oktatók"
    , msg_GroupRegistration_NoAvailableCourses <| "Még nincsenek elérhető csoportok!  Valószínűleg még félév eleje van :-)"
    , msg_GroupRegistration_Register <| "Felvesz"
    , msg_GroupRegistration_Unsubscribe <| "Leiratkozás"
    , msg_GroupRegistration_NoUnsubscriptionAvailable <| "Már nem lehet leiratkozni!"
    , msg_GroupRegistration_Warning <| "Amíg nincs beadott feladat, addig le lehet iratkozni az adott csoportról vagy egy másik csoport kiválasztásával át lehet menni abba a csoportba.  Ha már van beadott feladatunk, akkor a gyakorlatvezetőt kell megkérni, hogy töröljön a csoportból."
    , msg_GetCsv_StudentName <| "Név"
    , msg_GetCsv_Username <| "Neptun-kód"
    , msg_GetCsv_Score <| "Eredmény"
    , msg_GetCsv_Information <| unlines [ "# A „#”-tel kezdődő sorok figyelmen kívül maradnak."
                                        , "# Az alábbi eredmények érvényesek:"
                                        , "#  - Kétértékű értékelés esetén:"
                                        , "#      Elfogadott írható mint „+”, „1” vagy „Elfogadott”."
                                        , "#      Elutasított írható mint „-”, „0” vagy „Elutasított”."
                                        , "#      Kis- és nagybetű között nincs különbség."
                                        , "#  - Százalékos értékelés esetén: egész szám 0-tól 100-ig."
                                        , "#  - Szabadformátumú értékelés esetén: szöveg a sor végéig."
                                        ]
    , msg_UserDetails_SaveButton <| "Mentés"
    , msg_UserDetails_NonExistingUser <| "Nem létező felhasználó:"
    , msg_Submission_Course <| "Tárgy: "
    , msg_Submission_Admin <| "Oktató: "
    , msg_Submission_Assignment <| "Feladat: "
    , msg_Submission_Deadline <| "Határidő: "
    , msg_Submission_Description <| "Leírás"
    , msg_Submission_Solution <| "Megoldás"
    , msg_Submission_Submit <| "Beküld"
    , msg_Submission_TimeLeft <| "Hátralévő idő:"
    , msg_Submission_Days <| "nap"
    , msg_Submission_DeadlineReached <| "A határidő lejárt"
    , msg_Submission_InvalidPassword <| "Hibás jelszó, a megoldást nem rögzítette a rendszer!"
    , msg_Submission_NonUsersAssignment <| "A feladathoz nincs jogosultágod!"
    , msg_Submission_Password <| "A feladat jelszava:"
    , msg_Submission_Info_Password <| "Ezt a feladatot csak a jelszó megadásával lehet beküldeni."
    , msg_Submission_Info_File <| "Válasszuk ki a beadni kívánt, .zip kiterjesztésű állományt!  A maximális méret kilobyte-ban: "
    , msg_Submission_File_NoFileReceived <| "Nem érkezett állomány!"
    , msg_Submission_File_PolicyFailure <| "A feltöltendő állomány nem felel meg a korlátozásoknak!"
    , msg_Submission_File_InvalidFile <| "Az állomány kiterjesztése nem megfelelő!"
    , msg_Submission_File_InternalError <| "Valamilyen hiba történt feltöltés közben."
    , msg_Submission_Remaining <| "Hátralévő próbálkozások:"
    , msg_Submission_NoTriesLeft <| "Elfogytak."
    , msg_Comments_Title <| "Hozzászólások"
    , msg_Comments_SubmitButton <| "Beküld"
    , msg_Comments_AuthorTestScript_Private <| "Automata tesztelői komment (csak az oktató láthatja)"
    , msg_Comments_AuthorTestScript_Public <| "Automata tesztelői komment"
    , msg_Comments_TestPassed <| "A megoldás átment a teszteken"
    , msg_Comments_TestFailed <| "A megoldás megbukott a teszteken"
    , msg_Comments_BinaryResultPassed <| "Elfogadott megoldás."
    , msg_Comments_BinaryResultFailed <| "Elutasított megoldás."
    , msg_Comments_PercentageResult <| "Az eredmény: %s százalék."
    , msg_Evaluation_Title <| "Értékelés"
    , msg_Evaluation_Course <| "Tárgy: "
    , msg_Evaluation_Assignment <| "Feladat: "
    , msg_Evaluation_Group <| "Csoport: "
    , msg_Evaluation_Student <| "Hallgató: "
    , msg_Evaluation_SaveButton <| "Beküld"
    , msg_Evaluation_Submitted_Solution <| "Beadott megoldás"
    , msg_Evaluation_Submitted_Solution_Text_Info <| "A megoldás letölthető szöveges állományként a linkre kattintva."
    , msg_Evaluation_Submitted_Solution_Text_Link <| "Letöltés"
    , msg_Evaluation_Submitted_Solution_Zip_Info <| "A megoldás tömörített állományként lett feltöltve, ezért nem jeleníthető meg.  A linkre kattintva viszont letölthető."
    , msg_Evaluation_Submitted_Solution_Zip_Link <| "Letöltés"
    , msg_Evaluation_Accepted <| "Elfogadott"
    , msg_Evaluation_Rejected <| "Elutasított"
    , msg_Evaluation_New_Comment <| "Új hozzászólás"
    , msg_Evaluation_Percentage <| "Százalék: "
    , msg_Evaluation_Info <| "Nem kötelező egyből értékelni a hallgató munkáját, lehet csak hozzászólást is írni.  A hozzászólásokra a hallgató szintén hozzászólásokkal tud válaszolni.  A feladat többször is értékelhető."
    , msg_Evaluation_Username <| "Neptun-kód:"
    , msg_Evaluation_SubmissionDate <| "Beadás dátuma:"
    , msg_Evaluation_SubmissionInfo <| "Állapot:"
    , msg_Evaluation_FreeFormEvaluation <| "Értékelés"
    , msg_Evaluation_FreeFormComment <| "Hozzászólás"
    , msg_Evaluation_EmptyCommentAndFreeFormResult <| "Sem hozzászólás, sem értékelés nem volt megadva!"
    , msg_Evaluation_FreeForm_Information <| "Figyelmeztetés: a feladat értékelése a fent megadott szöveg lesz. Ezért ajánlott %d karakternél rövidebbnek lennie, különben helyettesítő szöveg jelenik meg."
    , msg_SubmissionDetails_Course <| "Tárgy, csoport:"
    , msg_SubmissionDetails_Admins <| "Oktató:"
    , msg_SubmissionDetails_Assignment <| "Feladat:"
    , msg_SubmissionDetails_Deadline <| "Határidő:"
    , msg_SubmissionDetails_Description <| "A feladat szövege"
    , msg_SubmissionDetails_Solution <| "A beadott megoldás"
    , msg_SubmissionDetails_Solution_Text_Info <| "A megoldás letölthető szöveges állományként a linkre kattintva."
    , msg_SubmissionDetails_Solution_Text_Link <| "Letöltés"
    , msg_SubmissionDetails_Solution_Zip_Info <| "A megoldás tömörített állományként lett feltöltve, ezért nem jeleníthető meg.  A linkre kattintva viszont letölthető."
    , msg_SubmissionDetails_Solution_Zip_Link <| "Letöltés"
    , msg_SubmissionDetails_Evaluation <| "Értékelés"
    , msg_SubmissionDetails_NewComment <| "Új hozzászólás"
    , msg_SubmissionDetails_SubmitComment <| "Beküld"
    , msg_SubmissionDetails_InvalidSubmission <| "Ez a megoldás nem érhető el ezzel a felhasználóval!"
    , msg_Submission_Large_Submission <| "A megoldás túl nagy, megtekinthető erre a linkre kattintva."
    , msg_Submission_Collapse_Submission <| "A beadott feladat elrejtése"
    , msg_Registration_Title <| "Regisztráció"
    , msg_Registration_Username <| "Neptun:"
    , msg_Registration_Email <| "Email cím:"
    , msg_Registration_FullName <| "Teljes név:"
    , msg_Registration_SubmitButton <| "Regisztráció"
    , msg_Registration_GoBackToLogin <| "Vissza a bejelentkezéshez"
    , msg_Registration_InvalidUsername <| "Hibás Neptun-kód! Adj meg valami hasonlót: %s"
    , msg_Registration_HasNoUserAccess <| "A felhasználó adatainak lekérdezése nem megengedett."
    , msg_Registration_UserAlreadyExists <| "A felhasználó már létezik!"
    , msg_Registration_RegistrationNotSaved <| "A regisztráció nem lett elmentve!"
    , msg_Registration_EmailSubject <| "BE-AD: Regisztráció"
    , msg_Registration_EmailBody <| "Kedves leendő felhasználó!\n\nEzt a levelet azért kapod, mert valaki ezzel az e-mail címmel szeretne a BE-AD\nrendszerbe regisztrálni, \"{{regUsername}}\" néven.  Kérjük, erősítsd meg ezt a\nszándékot azzal, hogy követed az alábbi linket.\n\n{{regUrl}}\n\nÜdvözlettel:\nAz Adminisztrátorok\n\nUI: Amennyiben ezt a levelet tévedésből kaptad volna meg, vagy már nem kívánsz\n    regisztrálni a rendszerbe, úgy nyugodtan hagyd csak figyelmen kívül.\n"
    , msg_Registration_RequestParameterIsMissing <| "Valamelyik request paraméter hiányzik!"
    , msg_RegistrationFinalize_NoRegistrationParametersAreFound <| "Nincsenek regisztrációs paraméterek!"
    , msg_RegistrationFinalize_SomeError <| "Ismeretlen hiba"
    , msg_RegistrationFinalize_InvalidToken <| "A regisztrációs token lejárt, újra kell regisztrálni!"
    , msg_RegistrationFinalize_UserAlreadyExist <| "Ez a felhasználó már létezik!"
    , msg_RegistrationFinalize_Password <| "Jelszó:"
    , msg_RegistrationFinalize_PwdAgain <| "Jelszó (ismét):"
    , msg_RegistrationFinalize_Timezone <| "Időzóna:"
    , msg_RegistrationFinalize_SubmitButton <| "Regisztráció"
    , msg_RegistrationFinalize_GoBackToLogin <| "Vissza a bejelentkezéshez"
    , msg_RegistrationCreateStudent_NoParameters <| "Nincsenek regisztrációs paraméterek!"
    , msg_RegistrationCreateStudent_InternalError <| "Valamilyen belső hiba történt!"
    , msg_RegistrationCreateStudent_InvalidToken <| "A regisztrációs token már lejárt, újra kell regisztrálni!"
    , msg_RegistrationTokenSend_Title <| "A regisztrációs tokent elküldtük levélben, hamarosan megérkezik!"
    , msg_RegistrationTokenSend_StoryFailed <| "Belső hiba történt"
    , msg_RegistrationTokenSend_GoBackToLogin <| "Vissza a bejelentkezéshez"
    , msg_EvaluationTable_EmptyUnevaluatedSolutions <| "Nincsenek nem értékelt megoldások!"
    , msg_EvaluationTable_Course <| "Tárgy"
    , msg_EvaluationTable_Group <| "Csoport"
    , msg_EvaluationTable_Student <| "Hallgató"
    , msg_EvaluationTable_Assignment <| "Feladat"
    , msg_EvaluationTable_Link <| "Link"
    , msg_EvaluationTable_Solution <| "Megoldás"
    , msg_EvaluationTable_Info <| "A táblázatban hallgatónként csak a legutolsó, nem értékelt beadott megoldás látszik.  A többi megoldást a főoldalon levő összefoglaló értékelő táblázaton keresztül érhetjük el."
    , msg_EvaluationTable_CourseAssignment <| "Tárgyszintű feladatok"
    , msg_EvaluationTable_GroupAssignment <| "Csoportszintű feladatok"
    , msg_EvaluationTable_MiscCourseAssignment <| "Egyéb csoportszintű feladatok"
    , msg_EvaluationTable_CourseAssignmentInfo <| "Tárgyszintű feladatokra beküldött megoldások olyan hallgatóktól, akik valamilyen általunk regisztrált csoportba járnak."
    , msg_EvaluationTable_GroupAssignmentInfo <| "Csoportszintű feladatokra beküldött megoldások olyan hallgatóktól, akik valamilyen általunk regisztrált csoportba járnak."
    , msg_EvaluationTable_MiscCourseAssignmentInfo <| "Tárgyszintű feladatokra beküldött megoldások a tárgy többi hallgatójától (más oktatók is láthatják)."
    , msg_EvaluationTable_Username <| "Neptun"
    , msg_EvaluationTable_DateOfSubmission <| "Beadás dátuma"
    , msg_EvaluationTable_SubmissionInfo <| "Állapot"
    , msg_UserSubmissions_NonAccessibleSubmissions <| "Ezzel a felhasználóval ezt a megoldást nem lehet elérni!"
    , msg_UserSubmissions_Course <| "Tárgy:"
    , msg_UserSubmissions_Assignment <| "Feladat:"
    , msg_UserSubmissions_Student <| "Hallgató:"
    , msg_UserSubmissions_SubmittedSolutions <| "Beadott megoldások"
    , msg_UserSubmissions_SubmissionDate <| "Beküldés dátuma"
    , msg_UserSubmissions_Evaluation <| "Értékelés"
    , msg_UserSubmissions_Accepted <| "Elfogadott"
    , msg_UserSubmissions_Tests_Failed <| "Megbukott a teszteken"
    , msg_UserSubmissions_Tests_Passed <| "Átment a teszteken"
    , msg_UserSubmissions_Rejected <| "Elutasított"
    , msg_UserSubmissions_NotFound <| "Nem található"
    , msg_UserSubmissions_NonEvaluated <| "Nem értékelt"
    , msg_UserSubmissions_FreeForm <| "Értékelt"
    , msg_SubmissionList_CourseOrGroup <| "Tárgy, csoport:"
    , msg_SubmissionList_Admin <| "Oktató:"
    , msg_SubmissionList_Assignment <| "Feladat:"
    , msg_SubmissionList_Deadline <| "Határidő:"
    , msg_SubmissionList_Description <| "Részletes leírás"
    , msg_SubmissionList_SubmittedSolutions <| "Beadott megoldások"
    , msg_SubmissionList_NoSubmittedSolutions <| "Nincsenek még beadott megoldások."
    , msg_SubmissionList_NonAssociatedAssignment <| "Ezzel a felhasználóval ezt a feladatot nem lehet elérni!"
    , msg_SubmissionList_NonReachableAssignment <| "Ez a feladat nem érhető el!"
    , msg_SubmissionList_Info <| "A beadott megoldásokhoz a beadás után még hozzászólások írhatóak."
    , msg_SubmissionList_NotFound <| "Megoldás nem található!"
    , msg_SubmissionList_TestsPassed <| "Átment a teszteken"
    , msg_SubmissionList_TestsFailed <| "Megbukott a teszteken"
    , msg_SubmissionList_Passed <| "Elfogadva"
    , msg_SubmissionList_Failed <| "Elutasítva"
    , msg_ResetPassword_UserDoesNotExist <| "A felhasználó nem létezik!"
    , msg_ResetPassword_PasswordIsSet <| "Beállítottuk a jelszót!"
    , msg_ResetPassword_GoBackToLogin <| "Vissza a főoldalra"
    , msg_ResetPassword_Username <| "Neptun:"
    , msg_ResetPassword_Email <| "Email:"
    , msg_ResetPassword_NewPwdButton <| "Új jelszó"
    , msg_ResetPassword_EmailSent <| "Az új jelszót levélben kiküldtük, hamarosan megérkezik!"
    , msg_ResetPassword_ForgottenPassword <| "Elfelejtett jelszó"
    , msg_ResetPassword_EmailSubject <| "BE-AD: Elfelejtett jelszó"
    , msg_ResetPassword_EmailBody <| "Kedves {{fpUsername}}!\n\nA jelszavad átállítását kérted, ezért most generáltunk (és beállítottunk) neked\negy új jelszót, amely a következő:\n\n    {{fpNewPassword}}\n\nKérjük, jelentkezz be ezen jelszó használatával és változtasd meg minél\nhamarabb!\n\nÜdvözlettel:\nAz Adminisztrátorok\n"
    , msg_ResetPassword_GenericError <| "Hibás Neptun azonosító vagy jelszó!"
    , msg_ResetPassword_InvalidPassword <| "Hibás jelszó!"
    , msg_Profile_User <| "Felhasználó: "
    , msg_Profile_Email <| "Email cím: "
    , msg_Profile_FullName <| "Teljes név: "
    , msg_Profile_Timezone <| "Időzóna: "
    , msg_Profile_SaveButton <| "Mentés"
    , msg_Profile_OldPassword <| "Régi jelszó: "
    , msg_Profile_NewPassword <| "Új jelszó: "
    , msg_Profile_NewPasswordAgain <| "Új jelszó (ismét): "
    , msg_Profile_ChangePwdButton <| "Csere"
    , msg_Profile_Language <| "Nyelv: "
    , msg_Profile_PasswordHasBeenChanged <| "A jelszó megváltozott!"
    , msg_SetUserPassword_NonRegisteredUser <| "Nincs regisztrálva egyik tárgyon vagy csoportban sem!"
    , msg_SetUserPassword_User <| "Neptun: "
    , msg_SetUserPassword_NewPassword <| "Új jelszó: "
    , msg_SetUserPassword_NewPasswordAgain <| "Új jelszó (ismét): "
    , msg_SetUserPassword_SetButton <| "Beállít"
    , msg_InputHandlers_Role_Student <| "Hallgató"
    , msg_InputHandlers_Role_GroupAdmin <| "Oktató"
    , msg_InputHandlers_Role_CourseAdmin <| "Tárgyfelelős"
    , msg_InputHandlers_Role_Admin <| "Rendszergazda"
    , msg_Home_NewSolution <| "Új megoldás"
    , msg_Home_AdminTasks <| "Rendszergazdai feladatok"
    , msg_Home_CourseAdminTasks <| "Tárgyfelelősi feladatok"
    , msg_Home_CourseAdministration <| "Tárgyi adminisztráció"
    , msg_Home_CourseAdministration_Info <| "A tárgyhoz új csoportokat a Tárgyi beállítások almenüben lehet létrehozni.  Ugyanitt lehet egyúttal az egyes csoportokhoz oktatókat rendelni."
    , msg_Home_NoCoursesYet <| "Még nincsenek tárgyak!  Meg kell kérni az adminisztrátort, hogy rendeljen hozzánk tárgyat!"
    , msg_Home_SubmissionTable_Info <| "A feladat sorszámára kattintva módosítható már kiírt feladat, ha van jogosultságunk a feladat módosításához (a nevét ld. tooltipben).  Hallgatók törölhetőek kurzusról vagy csoportból a Törlés oszlopban bejelölve, majd a gombra kattintva."
    , msg_Home_CourseSubmissionTableList_Info <| "A kurzusokhoz tartozó összesítő táblázatok külön oldalon találhatóak. Kattintsunk a kurzus nevére az alábbi listában."
    , msg_Home_GroupAdminTasks <| "Oktatói feladatok"
    , msg_Home_NoGroupsYet <| "Még nincsenek csoportok!"
    , msg_Home_StudentTasks <| "Hallgatói feladatok"
    , msg_Home_HasNoRegisteredCourses <| "Még nincsenek felvett tárgyak, vegyünk fel tárgyakat!"
    , msg_Home_HasNoAssignments <| "Még nincsenek kiírva feladatok!"
    , msg_Home_Assignments_Info <| "A feladat linkjére kattintva lehet elérni az eddig beadott megoldásokat és a hozzájuk tartozó értékeléseket.  A táblázatban mindig az utolsó értékelés eredménye látható."
    , msg_Home_Course <| "Tárgy"
    , msg_Home_Limit <| "Limit"
    , msg_Home_CourseAdmin <| "Oktató"
    , msg_Home_Assignment <| "Feladat"
    , msg_Home_Deadline <| "Határidő"
    , msg_Home_Evaluation <| "Értékelés"
    , msg_Home_ClosedSubmission <| "Lezárva"
    , msg_Home_SubmissionCell_NoSubmission <| "Nincs megoldás"
    , msg_Home_SubmissionCell_NonEvaluated <| "Nem értékelt"
    , msg_Home_SubmissionCell_Tests_Passed <| "Átment a teszteken"
    , msg_Home_SubmissionCell_Tests_Failed <| "Megbukott a teszteken"
    , msg_Home_SubmissionCell_Accepted <| "Elfogadott"
    , msg_Home_SubmissionCell_Rejected <| "Elutasított"
    , msg_Home_SubmissionCell_FreeFormEvaluated <| "Értékelt"
    , msg_Home_SubmissionTable_NoCoursesOrStudents <| "Nincsenek feladatok vagy hallgatók a csoporthoz!"
    , msg_SubmissionList_NotEvaluatedYet <| "Még nem értékelt"
    , msg_Home_SubmissionTable_StudentName <| "Név"
    , msg_Home_SubmissionTable_Username <| "Neptun"
    , msg_Home_SubmissionTable_Summary <| "Összesítés"
    , msg_Home_SubmissionTable_Accepted <| "Elfogadott"
    , msg_Home_SubmissionTable_Rejected <| "Elutasított"
    , msg_Home_AssessmentTable_Assessments <| "Értékelések"
    , msg_Home_AssessmentTable_StudentName <| "Név"
    , msg_Home_AssessmentTable_Username <| "Neptun"
    , msg_Home_GroupAssessmentIDPrefix <| "Cs"
    , msg_Home_NonBinaryEvaluation <| "Nem kétértékű értékelés"
    , msg_Home_HasNoSummary <| "Nincs"
    , msg_Home_NonPercentageEvaluation <| "Nem százalékos értékelés"
    , msg_Home_DeleteUsersFromCourse <| "Törlés"
    , msg_Home_DeleteUsersFromGroup <| "Törlés"
    , msg_Home_NotAdministratedTestScripts <| "A tesztelőt valaki más hozta létre, ezért nem módosítható!"
    , msg_Home_NoTestScriptsWereDefined <| "Nincsenek tesztelők a tárgyhoz!"
    , msg_Home_ModifyTestScriptTable <| "Tesztelők"
    , msg_Home_CourseAssignmentIDPreffix <| "T"
    , msg_Home_GroupAssignmentIDPreffix <| "Cs"
    , msg_Home_ThereIsIsolatedAssignment <| "IZOLÁLT MÓD: Egy vagy több izolált feladat aktív, ami elrejti a többi feladatot."
    , msg_Home_Remains <| "Hátralévő: "
    , msg_Home_Reached <| "Elérve"
    , msg_NewUserScore_Course <| "Tárgy:"
    , msg_NewUserScore_Assessment <| "Értékelés:"
    , msg_NewUserScore_Description <| "Leírás:"
    , msg_NewUserScore_Group <| "Csoport:"
    , msg_NewUserScore_Student <| "Hallgató:"
    , msg_NewUserScore_UserName <| "Neptun-kód:"
    , msg_NewUserScore_Submit <| "Mentés"
    , msg_ViewUserScore_Course <| "Tárgy:"
    , msg_ViewUserScore_Group <| "Csoport:"
    , msg_ViewUserScore_Teacher <| "Oktató:"
    , msg_ViewUserScore_Assessment <| "Értékelés:"
    , msg_ViewUserScore_Description <| "Leírás:"
    , msg_NewTestScript_Name <| "Név"
    , msg_NewTestScript_Description <| "Leírás"
    , msg_NewTestScript_Notes <| "Segítség tesztesetek írásához"
    , msg_NewTestScript_Script <| "Tesztelő"
    , msg_NewTestScript_Type <| "Típus"
    , msg_NewTestScript_Save <| "Mentés"
    , msg_NewTestScript_Course <| "Tárgy:"
    , msg_NewTestScript_HasNoCourses <| "Ez a felhasználó egyik tárgynak sem a felelőse!"
    , msg_NewTestScript_ScriptTypeHelp <| "A tesztesetek fajtái"
    , msg_UploadFile_FileSelection <| "Állomány kiválasztása"
    , msg_UploadFile_Directory <| "Feltöltött állományok"
    , msg_UploadFile_Info <| "Válasszuk ki a feltöltendő állományt!  Az állományok mérete kilobyte-ban maximálisan, egyenként: "
    , msg_UploadFile_UploadButton <| "Feltöltés"
    , msg_UploadFile_FileName <| "Név"
    , msg_UploadFile_FileSize <| "Méret (byte)"
    , msg_UploadFile_FileDate <| "Dátum"
    , msg_UploadFile_Successful <| "Sikeres feltöltés!"
    , msg_UploadFile_NoFileReceived <| "Nem érkezett állomány!"
    , msg_UploadFile_PolicyFailure <| "Nem megfelelő állomány, méret vagy típusbeli hiba!"
    , msg_UploadFile_UnnamedFile <| "Nem lett állomány kiválasztva!"
    , msg_UploadFile_InternalError <| "Belső hiba történt!"
    , msg_UploadFile_ErrorInManyUploads <| "Hiba történt egy vagy több állomány feldolgozásakor!"
    , msg_TestScriptTypeSimple <| "Szöveges"
    , msg_TestScriptTypeZipped <| "Bináris"
    , msg_UserStory_SetTimeZone <| "Megváltozott az időzóna!"
    , msg_UserStory_ChangedUserDetails <| "A beállítások megváltoztak!"
    , msg_UserStory_CreateCourse <| "Létrejött a tárgy!"
    , msg_UserStory_SetCourseAdmin <| "A felhasználó tárgyfelelős lett!"
    , msg_UserStory_SetGroupAdmin <| "A felhasználó oktató lett!"
    , msg_UserStory_CreateGroup <| "A csoport létrejött!"
    , msg_UserStory_SubscribedToGroup <| "A regisztráció sikeres volt!"
    , msg_UserStory_SubscribedToGroup_ChangeNotAllowed <| "Csoportváltás nem engedélyezett mert már van beadott megoldásod más csoportban"
    , msg_UserStory_NewGroupAssignment <| "Létrejött a csoportszintű feladat!"
    , msg_UserStory_NewCourseAssignment <| "Létrejött a tárgyszintű feladat!"
    , msg_UserStory_UsersAreDeletedFromCourse <| "A felhasználók törölve lettek a tárgyról!"
    , msg_UserStory_UsersAreDeletedFromGroup <| "A felhasználók törölve lettek a csoportból!"
    , msg_UserStory_SuccessfulCourseUnsubscription <| "A tárgyról sikerült leiratkozni!"
    , msg_UserStory_NewTestScriptIsCreated <| "A tesztelő létrejött!"
    , msg_UserStory_ModifyTestScriptIsDone <| "A tesztelő módosítva lett!"
    , msg_UserStory_AlreadyEvaluated <| "Ezt a megoldást egy másik admin éppont értekelte!"
    , msg_UserStory_EvalTypeWarning <| "A feladat kiértékelésének típusa nem változott meg."
    , msg_UserStory_AssessmentEvalTypeWarning <| "Az értékelés típusa nem változott meg."
    , msg_UserStoryError_XID <| "Belső hiba történt, XID: %s"
    , msg_UserStoryError_SubmissionDeadlineIsReached <| "A beküldési határidő lejárt!"
    , msg_UserStoryError_UserIsNotLoggedIn <| "A felhasználó nincs bejelentkezve"
    , msg_UserStoryError_RegistrationProcessError <| "A regisztrációs folyamat hibás működése miatt más folyamatokat akar elérni %s %s."
    , msg_UserStoryError_TestAgentError <| "A tesztelői folyamat hibás működése miatt más folyamatokat akar elérni %s %s."
    , msg_UserStoryError_AuthenticationNeeded <| "Azonosítás szükséges %s %s %s!"
    , msg_UserStoryError_UnknownError <| "Ismeretlen hiba történt!"
    , msg_UserStoryError_Message <| "Hiba történt: %s!"
    , msg_UserStoryError_SameUserIsLoggedIn <| "Ez a felhasználó máshonnan is be van jelentkezve!"
    , msg_UserStoryError_InvalidUsernameOrPassword <| "Rossz jelszó vagy felhasználónév!"
    , msg_UserStoryError_NoCourseAdminOfCourse <| "Nem oktatója a kurzusnak!"
    , msg_UserStoryError_NoAssociatedTestScript <| "Ez a teszelő nem ehhez a felhasználóhoz tartozik, ezért nem módosítható!"
    , msg_UserStoryError_NoGroupAdmin <| "%s nem oktató!"
    , msg_UserStoryError_NoGroupAdminOfGroup <| "Nem oktatója a csoportnak!"
    , msg_UserStoryError_AlreadyHasSubmission <| "Ennek a felhasználónak már van beadott megoldása a kurzushoz tartozó feladatokhoz!"
    , msg_UserStoryError_EmptyAssignmentTitle <| "Nincs a feladatnak címe!"
    , msg_UserStoryError_EmptyAssignmentDescription <| "Nincs a feladatnak szövege!"
    , msg_UserStoryError_NonAdministratedCourse <| "Nem vagy oktatója a kurzusnak!"
    , msg_UserStoryError_NonAdministratedGroup <| "Nem vagy oktatója a csoportnak!"
    , msg_UserStoryError_NonAdministratedAssignment <| "Nem vagy oktatója a feladat csoportjának vagy kurzusának!"
    , msg_UserStoryError_NonAdministratedAssessment <| "Nem vagy oktatója az értékelés csoportjának vagy kurzusának!"
    , msg_UserStoryError_NonRelatedAssignment <| "Nem hozzád tartozó feladat!"
    , msg_UserStoryError_NonAdministratedSubmission <| "Nem vagy oktatója a megoldás kurzusának vagy csoportjának!"
    , msg_UserStoryError_NonAdministratedTestScript <| "Nem vagy oktatója a teszt szkript kurzusának!"
    , msg_UserStoryError_NonCommentableSubmission <| "Nem kommentelhető feladat!"
    , msg_UserStoryError_BlockedSubmission <| "A megoldást egy izolált feladat blokkolja."
    , msg_UserActions_ChangedUserDetails <| "A felhasználói beállításai megváltoztak!"
    , msg_UserStoryError_NonAccessibleSubmission <| "A megoldás nem hozzád tartozik!"
    , msg_UserStoryError_NonAccessibleScore <| "Az eredmény nem hozzád tartozik!"
    , msg_LinkText_Login <| "Bejelentkezés"
    , msg_LinkText_Logout <| "Kijelentkezés"
    , msg_LinkText_Home <| "Főoldal"
    , msg_LinkText_Profile <| "Beállítások"
    , msg_LinkText_Error <| "Hiba"
    , msg_LinkText_CourseAdministration <| "Tárgyi beállítások"
    , msg_LinkText_CourseOverview <| "Tárgyi áttekintő"
    , msg_LinkText_Submission <| "Beküldés"
    , msg_LinkText_SubmissionList <| "Beadott megoldások"
    , msg_LinkText_UserSubmissions <| "Megoldások"
    , msg_LinkText_ViewUserScore <| "Eredmény"
    , msg_LinkText_NewUserScore <| "Új eredmény"
    , msg_LinkText_ModifyUserScore <| "Eredmény módosítása"
    , msg_LinkText_NewTestScript <| "Új tesztelő"
    , msg_LinkText_ModifyTestScript <| "Tesztelő módosítása"
    , msg_LinkText_UploadFile <| "Állományok feltöltése"
    , msg_LinkText_ModifyEvaluation <| "Értékelés"
    , msg_LinkText_SubmissionDetails <| "Megoldás"
    , msg_LinkText_Administration <| "Adminisztráció"
    , msg_LinkText_Evaluation <| "Értékelés"
    , msg_LinkText_EvaluationTable <| "Értékelések"
    , msg_LinkText_GroupRegistration <| "Tárgy vagy csoport felvétele, leadása"
    , msg_LinkText_CreateCourse <| "Tárgy létrehozása"
    , msg_LinkText_UserDetails <| "Beállítások"
    , msg_LinkText_AssignCourseAdmin <| "Tárgyfelelős felvétele"
    , msg_LinkText_CreateGroup <| "Csoport létrehozása"
    , msg_LinkText_AssignGroupAdmin <| "Oktató felvétele"
    , msg_LinkText_NewGroupAssignment <| "Új csoportszintű feladat"
    , msg_LinkText_NewCourseAssignment <| "Új tárgyszintű feladat"
    , msg_LinkText_ModifyAssignment <| "Feladat módosítása"
    , msg_LinkText_NewGroupAssignmentPreview <| "Új csoportszintű feladat"
    , msg_LinkText_NewCourseAssignmentPreview <| "Új tárgyszintű feladat"
    , msg_LinkText_ModifyAssignmentPreview <| "Feladat módosítása"
    , msg_LinkText_ViewAssignment <| "Feladat megtekintése"
    , msg_LinkText_ChangePassword <| "Jelszócsere"
    , msg_LinkText_SetUserPassword <| "Hallgató jelszavának beállítása"
    , msg_LinkText_DeleteUsersFromCourse <| "Hallgatók törlése"
    , msg_LinkText_DeleteUsersFromGroup <| "Hallgatók törlése"
    , msg_LinkText_UnsubscribeFromCourse <| "Leiratkozás"
    , msg_LinkText_GetSubmission <| "A megoldás letöltése"
    , msg_LinkText_NewGroupAssessment <| "Új csoportszintű értékelés"
    , msg_LinkText_NewCourseAssessment <| "Új tárgyszintű értékelés"
    , msg_LinkText_GroupAssessmentPreview <| "Új csoportszintű értékelés"
    , msg_LinkText_CourseAssessmentPreview <| "Új tárgyszintű értékelés"
    , msg_LinkText_ViewAssessment <| "Értékelés megtekintése"
    , msg_LinkText_ModifyAssessment <| "Értékelés módosítása"
    , msg_LinkText_ModifyAssessmentPreview <| "Értékelés módosítása"
    , msg_LinkText_Notifications <| "Értesítések"
    , msg_Domain_EvalPassed <| "Elfogadva"
    , msg_Domain_EvalFailed <| "Elutasítva"
    , msg_Domain_EvalNoResultError <| "Ismeretlen hiba folyamán nem található értékelés!"
    , msg_Domain_EvalPercentage <| "%s%%"
    , msg_Domain_FreeForm <| "Értékelés: %s"
    , msg_SeeMore_SeeMore <| "Kinyit"
    , msg_SeeMore_SeeLess <| "Becsuk"
    , msg_Markdown_NotFound <| "Sajnos a kért oldal nem található!"
    , msg_NE_CourseAdminCreated <| "A \"%s\" tárgy hozzárendelésre került."
    , msg_NE_CourseAdminAssigned <| "Egy új tárgyfelelőst rendeltek a \"%s\" tárgyhoz: %s"
    , msg_NE_TestScriptCreated <| "%s létrehozott egy új tesztelőt a \"%s\" tárgyhoz"
    , msg_NE_TestScriptUpdated <| "%s módosított a \"%s\" tesztelőt a \"%s\" tárgyhoz"
    , msg_NE_RemovedFromGroup <| "A \"%s\" csoportból törölt %s"
    , msg_NE_GroupAdminCreated <| "A \"%s\" tárgy egy csoportját %s hozzárendelte %s oktatóhoz"
    , msg_NE_GroupAssigned <| "A \"%s\" csoport a \"%s\" tárgyból %s oktatóhoz került %s által"
    , msg_NE_GroupCreated <| "Egy új csoport jött létre \"%s\" tárgyból %s által: %s"
    , msg_NE_GroupAssignmentCreated <| "%s létrehozott egy új feladatot a \"%s\" csoportnak (\"%s\"): %s"
    , msg_NE_CourseAssignmentCreated <| "%s létrehozott egy új feladatot a \"%s\" tárgyhoz: %s"
    , msg_NE_GroupAssessmentCreated <| "%s létrehozott egy új értékelést a \"%s\" csoportnak (\"%s\"): %s"
    , msg_NE_CourseAssessmentCreated <| "%s létrehozott egy új értékelést a \"%s\" tárgyhoz: %s"
    , msg_NE_AssessmentUpdated <| "%s módosította a következő értékelést: %s"
    , msg_NE_AssignmentUpdated <| "%s módosította a \"%s\" feladatot"
    , msg_NE_EvaluationCreated <| "%s értékelte a következő megoldást: %s"
    , msg_NE_AssessmentEvaluationUpdated <| "%s módosította a következő értékelést: %s"
    , msg_NE_AssignmentEvaluationUpdated <| "%s módosította a következő feladat értékelését: %s"
    , msg_NE_CommentCreated <| "%s a következő megjegyzést írta a %s megoldásra: \"%s\""
    ]
}
