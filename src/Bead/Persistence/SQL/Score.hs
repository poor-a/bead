{-# LANGUAGE CPP #-}
{-# LANGUAGE OverloadedStrings #-}
module Bead.Persistence.SQL.Score where

import           Control.Applicative
import           Control.Monad.Trans
import           Control.Monad.Trans.Maybe
import           Data.Maybe
import qualified Data.Text as Text

import           Database.Persist.Sql
import           Database.Esqueleto (select, from, on, where_, limit, InnerJoin(InnerJoin), val, (^.), Value(unValue))
import qualified Database.Esqueleto as Esq

import qualified Bead.Domain.Entities          as Domain
import qualified Bead.Domain.Relationships     as Domain
import qualified Bead.Domain.Shared.Evaluation as Domain
import           Bead.Persistence.SQL.Class
import           Bead.Persistence.SQL.Entities

#ifdef TEST
import           Bead.Persistence.SQL.Assessment
import           Bead.Persistence.SQL.Course
import           Bead.Persistence.SQL.Evaluation
import           Bead.Persistence.SQL.MySQLTestRunner
import           Bead.Persistence.SQL.User

import           Bead.Persistence.SQL.TestData

import           Test.Tasty.TestSet (ioTest, shrink, equals)
#endif

-- * Score

saveScore :: Domain.Username -> Domain.AssessmentKey -> Domain.Score -> Persist Domain.ScoreKey
saveScore user assessment score = do
  key <- insert (fromDomainValue score)
  userId <- getUserId user
  insertUnique (ScoresOfUsernameAssessment key userId (toEntityKey assessment))
  return $! toDomainKey key

loadScore :: Domain.ScoreKey -> Persist Domain.Score
loadScore key = do
  score <- get (toEntityKey key)
  return $!
    maybe (persistError "loadScore" $ "There is no score for the key: " ++ show key)
          toDomainValue
          score

getUserId = fmap (entity key) . getByUsername
  where key k _v = k

assessmentOfScore :: Domain.ScoreKey -> Persist Domain.AssessmentKey
assessmentOfScore key = do
  assessments <- selectList [ScoresOfUsernameAssessmentScore ==. toEntityKey key] []
  return $!
    maybe
      (persistError "assessmentOfScore" $ "Score does not have an assessment: " ++ show key)
      (toDomainKey . scoresOfUsernameAssessmentAssessment . entityVal)
      (listToMaybe assessments)

usernameOfScore :: Domain.ScoreKey -> Persist Domain.Username
usernameOfScore key = do
  users <- selectList [ScoresOfUsernameAssessmentScore ==. toEntityKey key] []
  user <- runMaybeT $ do
    userId <- extract $ (scoresOfUsernameAssessmentUser . entityVal) <$> (listToMaybe users)
    user   <- extract =<< lift (get userId)
    return (userUsername user)
  return $!
    maybe
      (persistError "usernameOfScore" $ "Score does not have a username: " ++ show key)
      (Domain.Username . Text.unpack)
      user
  where
    extract = maybe (fail "Nothing") return

scoreOfAssessmentAndUser :: Domain.Username -> Domain.AssessmentKey -> Persist [Domain.ScoreKey]
scoreOfAssessmentAndUser u ak = do
  userId <- getUserId u
  scores <- selectList [ScoresOfUsernameAssessmentUser ==. userId, ScoresOfUsernameAssessmentAssessment ==. toEntityKey ak] []
  return $ map (toDomainKey . scoresOfUsernameAssessmentScore . entityVal) scores

evaluationOfScore :: Domain.ScoreKey -> Persist (Maybe (Domain.EvaluationKey, Domain.Evaluation))
evaluationOfScore key = do
  evaluations <- select $ from $ \(scoreEvaluation `InnerJoin` evaluation) -> do
    on (scoreEvaluation ^. ScoreOfEvaluationEvaluation Esq.==. evaluation ^. EvaluationId)
    where_ (scoreEvaluation ^. ScoreOfEvaluationScore Esq.==. val (fromDomainKey key))
    limit 1
    return evaluation
  case evaluations of
    [] -> return Nothing
    e : _ -> return $! Just (toDomainKey . entityKey $ e, toDomainValue . entityVal $ e)

scoresOfUser :: Domain.Username -> Persist [Domain.ScoreKey]
scoresOfUser user = do
  userId <- getUserId user
  scores <- selectList [ScoresOfUsernameAssessmentUser ==. userId] []
  return $!
    map (toDomainKey . scoresOfUsernameAssessmentScore . entityVal) scores

#ifdef TEST
scoreTests = do
  ioTest "Score end-to-end test" $ runSql $ do
    -- Given
    saveUser user1
    c  <- saveCourse course
    ca <- saveCourseAssessment c ast
    scs <- scoresOfUser user1name
    equals [] scs "There were scores registered for unscored user."

    -- When
    s  <- saveScore user1name ca scr

    -- Then
    sa <- assessmentOfScore s
    equals ca sa "The assessment of the score was different."

    -- Then
    us <- usernameOfScore s
    equals user1name us "The username of the score was different."

    -- Then
    es <- evaluationOfScore s
    equals Nothing es "A non evaluated score has some evaluation."

    -- Then
    scs <- scoresOfUser user1name
    equals [s] scs "There wasn't score for the scored user."

    -- When
    e  <- saveScoreEvaluation s ev
    es <- evaluationOfScore s

    -- Then
    equals (Just (e, ev)) es "An evaluated score does not have some evaluation."
#endif
