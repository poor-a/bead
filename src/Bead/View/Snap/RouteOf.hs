{-# LANGUAGE OverloadedStrings #-}
module Bead.View.Snap.RouteOf (
    ReqParam(..)
  , RequestParam(..)
  , routeOf
  , routeWithParams

  , invariants
  , unitTests
  ) where

import Data.String
import Data.List (intersperse, nub)
import Control.Monad (join)
import Bead.Controller.Pages hiding (invariants, unitTests)

import Bead.Invariants (Invariants(..), UnitTests(..))

newtype ReqParam = ReqParam (String,String)

queryStringParam :: ReqParam -> String
queryStringParam (ReqParam (k,v)) = join [k, "=", v]

class RequestParam r where
  requestParam :: r -> ReqParam

routeOf :: (IsString s) => Page -> s
routeOf = r where
  r Login      = fromString "/login"
  r Logout     = fromString "/logout"
  r Home       = fromString "/home"
  r Error      = fromString "/error"
  r Profile    = fromString "/profile"
  r CourseAdmin = fromString "/course-admin"
  r EvaulationTable = fromString "/evaulation-table"
  r Evaulation      = fromString "/evaulation"
  r Submission      = fromString "/submission"
  r Administration   = fromString "/administration"
  r CourseRegistration = fromString "/course-registration"
  r CreateCourse = fromString "/create-course"
  r UserDetails = fromString "/user-details"
  r AssignCourseAdmin = fromString "/assign-course-admin"
  r CreateGroup = fromString "/create-group"
  r AssignProfessor = fromString "/assign-professor"
  r NewGroupAssignment  = fromString "/new-group-assignment"
  r NewCourseAssignment  = fromString "/new-course-assignment"

routeWithParams :: (IsString s) => Page -> [ReqParam] -> s
routeWithParams p rs = fromString . join $
  [routeOf p, "?"] ++ (intersperse "&" (map queryStringParam rs))

-- * Invariants

unitTests = UnitTests [
    ("Routes must be differents", let rs = map routeOf allPages in (length rs == length (nub rs)) )
  ]

invariants = Invariants [
    ("RouteOf strings must not be empty", \p -> length (routeOf' p) > 0)
  ] where
    routeOf' :: Page -> String
    routeOf' = routeOf
