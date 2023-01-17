module Test.Node where

import Effect.Aff
import Prelude

import Data.Enum (defaultPred)
import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Hypercore (Storage(..), append, defaultOptions, get, hypercore)
import Node.Buffer (Buffer, toString)
import Node.Encoding (Encoding(..))
import Prelude (Unit, bind, ($))
import Test.Spec (describe, it)
import Test.Spec.Assertions (shouldEqual)
import Test.Spec.Mocha (runMocha)
import Test.Spec.Reporter.Console (consoleReporter)
import Test.Spec.Runner (runSpec)

-- rmTestData :: Effect Unit
-- rmTestData = rmdir "./test-data"

main :: Effect Unit
main = do
  launchAff_ $ runSpec [consoleReporter] do
    describe "Hypercore" do
      describe "RAM" do
        it "appends with a RAM storage" do
          f <- hypercore RAM defaultOptions
          s <- append "a" f
          (b :: Buffer) <- get 0 f
          a <- liftEffect $ toString UTF8 b
          a `shouldEqual` "a"
      describe "RAF" do
        it "appends with a RAF storage" do
          f <- hypercore (RAF "./test/data") defaultOptions
          s <- append "a" f
          (b :: Buffer) <- get 0 f
          a <- liftEffect $ toString UTF8 b
          a `shouldEqual` "a"
