module Test.Browser where

import Effect.Aff
import Prelude

import Data.Traversable (sequence)
import Data.String.CodeUnits (charAt, fromCharArray, singleton, toCharArray, uncons)
import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Console (log, logShow)
import Hypercore (Storage(..), append, bytes, defaultOptions, dump, get, hypercore, truncate) as H
import Node.Buffer (Buffer, toString)
import Node.Encoding (Encoding(..))
import Prelude (Unit, bind, ($))
import Test.Spec (describe, it)
import Test.Spec.Assertions (shouldEqual)
import Test.Spec.Mocha (runMocha)
import Test.Spec.Reporter.Console (consoleReporter)
import Test.Spec.Runner (runSpec)

-- | Attach a `Char` to the front of a `String`
cons :: Char -> String -> String
cons = append <<< singleton

replicate :: Int -> Char -> String
replicate = replicate' ""
  where
    replicate' acc n c | n <= 0 = acc
                       | otherwise = replicate' (cons c acc) (n - 1) c

main :: Effect Unit
main = 
  runMocha do
    describe "Hypercore" do
      describe "RAM" do
        it "appends with a RAM storage" do
          f <- H.hypercore H.RAM H.defaultOptions
          _ <- H.append "a" f
          (b :: Buffer) <- H.get 0 f
          a <- liftEffect $ toString UTF8 b
          a `shouldEqual` "a"
        it "gets bytes length" do
          f <- H.hypercore H.RAM H.defaultOptions
          _ <- H.append "a" f
          b <- H.bytes f
          b `shouldEqual` 3
        it "gets bytes length for several appends" do
          f <- H.hypercore H.RAM H.defaultOptions
          _ <- H.append "a" f
          _ <- H.append "b" f
          b <- H.bytes f
          b `shouldEqual` 6
        it "dumps" do
          f <- H.hypercore H.RAM H.defaultOptions
          _ <- H.append "a" f
          _ <- H.append "b" f
          (d :: Array String) <- H.dump f
          _ <- sequence $ liftEffect <$> map (\s -> logShow $ "dump: " <> s) d
          pure unit
      describe "RAI" do
        it "creates a random access idb storage" do
          f <- H.hypercore H.RAI H.defaultOptions
          pure unit
        it "appends with a random access idb storage" do
          f <- H.hypercore H.RAI H.defaultOptions
          _ <- H.append "a" f
          (b :: Buffer) <- H.get 0 f
          a <- liftEffect $ toString UTF8 b
          a `shouldEqual` "a"
          b <- H.bytes f
          b `shouldEqual` 3
        it "has persisted the appended data" do
          f <- H.hypercore H.RAI H.defaultOptions
          (b :: Buffer) <- H.get 0 f
          a <- liftEffect $ toString UTF8 b
          b <- H.bytes f
          a `shouldEqual` "a"
          b `shouldEqual` 3
        it "dumps - bug in random-access-idb where length isn't maintained accross reopening" do
          f <- H.hypercore H.RAI H.defaultOptions
          _ <- H.append "a" f
          _ <- H.append "b" f
          (d :: Array String) <- H.dump f
          _ <- sequence $ liftEffect <$> map (\s -> logShow $ "dump: " <> s) d
          pure unit
        it "can truncate the core" do
          f <- H.hypercore H.RAI H.defaultOptions
          _ <- H.truncate 0 f
          b <- H.bytes f
          b `shouldEqual` 0
        it "dumps" do
          f <- H.hypercore H.RAI H.defaultOptions
          _ <- H.append "a" f
          _ <- H.append "b" f
          (d :: Array String) <- H.dump f
          _ <- sequence $ liftEffect <$> map (\s -> logShow $ "dump: " <> s) d
          pure unit
        it "can truncate the core" do
          f <- H.hypercore H.RAI H.defaultOptions
          _ <- H.truncate 0 f
          b <- H.bytes f
          b `shouldEqual` 0
        it "appends a large amount of data" do
          f <- H.hypercore H.RAI H.defaultOptions
          _ <- H.append (replicate 10000 '0') f
          (b :: Buffer) <- H.get 0 f
          a <- liftEffect $ toString UTF8 b
          a `shouldEqual` (replicate 10000 '0')
          b <- H.bytes f
          b `shouldEqual` 10002
        it "can truncate the core" do
          f <- H.hypercore H.RAI H.defaultOptions
          _ <- H.truncate 0 f
          b <- H.bytes f
          b `shouldEqual` 0
