module Test.Main where

import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Aff
import Hypercore (Storage(..), append, defaultOptions, get, hypercore)
import Node.Buffer (Buffer, toString)
import Node.Encoding (Encoding(..))
import Node.FS.Sync (rmdir)
import Prelude (Unit, bind, ($))
import Test.Spec (describe, it)
import Test.Spec.Assertions (shouldEqual)
import Test.Spec.Mocha (runMocha)
import Test.Spec.Runner (runSpec)
import Test.Spec.Reporter.Console (consoleReporter)

rmTestData :: Effect Unit
rmTestData = rmdir "./test-data"

main :: Effect Unit
main = do
  launchAff_ $ runSpec [consoleReporter] do
    -- runMocha do
      describe "Hypercore" do
        describe "RAM" do
          it "appends with a RAM storage" do
            f <- hypercore RAM defaultOptions
            s <- append "a" f
            (b :: Buffer) <- get 0 f
            a <- liftEffect $ toString UTF8 b
            a `shouldEqual` "a"
        -- describe "RAF" do
        --   after_ (liftEffect rmTestData) do
        --       it "appends with a RAF storage" do
        --         f <- liftEffect $ hypercore $ RAF "./test-data"
        --         s <- append f "a"
        --         (b :: Buffer) <- get f 0
        --         a <- liftEffect $ toString UTF8 b
        --         a `shouldEqual` "a"
        -- it "fails" $
        --   (1 + 1) `shouldEqual` 3
