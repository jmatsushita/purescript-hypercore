module Hypercore
  ( CacheSize(..)
  , Encoding(..)
  , Core(..)
  , FilePath
  , Index
  , Options
  , PublicKey(..)
  , SecretKey(..)
  , Seq
  , Storage(..)
  , append
  , defaultOptions
  , get
  , truncate
  , subscribe
  , cursor
  , dump
  , bytes
  , hypercore
  , hypercoreWithKey
  -- , main
  )
  where

import Prelude (class Show, Unit, ($))
import Control.Promise (Promise, toAffE)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Uncurried (EffectFn1, EffectFn2, EffectFn3, runEffectFn1, runEffectFn2, runEffectFn3)
import Node.Buffer (Buffer)
import Option as Option


foreign import hypercoreRAMImpl :: forall a. EffectFn1 Options (Promise (Core a))
foreign import hypercoreRAIImpl :: forall a. EffectFn1 Options (Promise (Core a))
foreign import hypercoreRAFImpl :: forall a. EffectFn2 FilePath Options (Promise (Core a))
foreign import hypercoreWithKey_ :: forall a. EffectFn3 Storage PublicKey Options (Promise (Core a))
foreign import append_ :: forall a. EffectFn2 a (Core a) (Promise Seq)
foreign import get_ :: forall a. EffectFn2 Index (Core a) (Promise Buffer)
foreign import truncate_ :: forall a. EffectFn2 Index (Core a) (Promise Buffer)
foreign import dump_ :: forall a. EffectFn1 (Core a) (Promise (Array a))

foreign import bytes_ :: forall a. EffectFn1 (Core a) (Promise Int)

foreign import subscribe_ :: forall a. EffectFn2 (a -> Effect Unit) (Core a) Unit
foreign import cursor_ :: forall a. EffectFn2 (Seq -> Effect Unit) (Core a) Unit

type FilePath = String
data Storage = RAM | RAF FilePath | RAI
data Core :: forall k. k -> Type
data Core a
type Seq = Int
type Index = Int

data SecretKey = SecretKey Buffer
data PublicKey = PublicKey Buffer

data Encoding = JSON | UTF8 | BINARY
instance showEncoding :: Show Encoding where
  show JSON = "json"
  show UTF8 = "utf8"
  show BINARY = "binary"

newtype CacheSize = Cachesize Int -- Not sure of bounds.

type Options = Option.Option (
  createIfMissing :: Boolean, -- create a new hypercore key pair if none was present in storage
  overwrite :: Boolean, -- overwrite any old hypercore that might already exist
  valueEncoding :: Encoding, -- defaults to binary
  sparse :: Boolean, -- do not mark the entire core to be downloaded
  eagerUpdate :: Boolean, -- always fetch the latest update that is advertised. default false in sparse mode.
  secretKey :: SecretKey, -- optionally pass the corresponding secret key yourself
  storeSecretKey :: Boolean, -- if false, will not save the secret key
  storageCacheSize :: CacheSize, -- the # of entries to keep in the storage system's LRU cache (false or 0 to disable)
  -- onwrite: (index, data, peer, cb) -- optional hook called before data is written after being verified
  --                                  -- (remember to call cb() at the end of your handler)
  stats :: Boolean, -- collect network-related statistics,
  -- Optionally use custom cryptography for signatures
  -- crypto: {
  --   sign (data, secretKey, cb(err, signature)),
  --   verify (signature, data, key, cb(err, valid))
  -- }
  noiseKeyPair :: { publicKey :: PublicKey, secretKey :: SecretKey } -- set a static key pair to use for Noise authentication when replicating
)

defaultOptions :: Options
defaultOptions = Option.fromRecord
  { createIfMissing : true -- create a new hypercore key pair if none was present in storage
  -- overwrite: false, -- overwrite any old hypercore that might already exist
  -- valueEncoding: BINARY, -- defaults to binary
  , sparse: true -- do not mark the entire core to be downloaded
  -- , eagerUpdate: true -- always fetch the latest update that is advertised. default false in sparse mode.
  -- secretKey: buffer, -- optionally pass the corresponding secret key yourself
  , storeSecretKey: true -- if false, will not save the secret key
  , storageCacheSize: Cachesize 65536 -- the # of entries to keep in the storage system's LRU cache (false or 0 to disable)
  -- onwrite: (index, data, peer, cb) -- optional hook called before data is written after being verified
  --                                  -- (remember to call cb() at the end of your handler)
  , stats: false -- collect network-related statistics,
  -- Optionally use custom cryptography for signatures
  -- crypto: {
  --   sign (data, secretKey, cb(err, signature)),
  --   verify (signature, data, key, cb(err, valid))
  -- }
  -- noiseKeyPair: { publicKey, secretKey } -- set a static key pair to use for Noise authentication when replicating
}

hypercore :: forall a. Storage -> Options -> Aff (Core a)
hypercore RAM o = toAffE $ runEffectFn1 hypercoreRAMImpl o
hypercore RAI o = toAffE $ runEffectFn1 hypercoreRAIImpl o
hypercore (RAF f) o = toAffE $ runEffectFn2 hypercoreRAFImpl f o

hypercoreWithKey :: forall a. Storage -> PublicKey -> Options -> Aff (Core a)
hypercoreWithKey s p o = toAffE $ runEffectFn3 hypercoreWithKey_ s p o

append :: forall a. a -> Core a -> Aff Seq
append a f = toAffE $ runEffectFn2 append_ a f

get :: forall a. Index -> Core a -> Aff Buffer
get i f = toAffE $ runEffectFn2 get_ i f

truncate :: forall a. Index -> Core a -> Aff Buffer
truncate i f = toAffE $ runEffectFn2 truncate_ i f

dump :: forall a. Core a -> Aff (Array a)
dump f = toAffE $ runEffectFn1 dump_ f

bytes :: forall a. Core a -> Aff Int
bytes f = toAffE $ runEffectFn1 bytes_ f

-- Looking at https://pursuit.purescript.org/packages/purescript-node-streams-aff/5.0.0/docs/Node.Stream.Aff
-- And to interface purescript-event (aka halogen-subscriptions) with Aff
-- https://purescript-halogen.github.io/purescript-halogen/guide/04-Lifecycles-Subscriptions.html#implementing-a-timer
subscribe :: forall a. (a -> Effect Unit) -> Core a -> Effect Unit
subscribe h f = runEffectFn2 subscribe_ h f

cursor :: forall a. (Seq -> Effect Unit) -> Core a -> Effect Unit
cursor h f = runEffectFn2 cursor_ h f


-- main :: Effect Unit
-- main = launchAff_ do
--   -- f <- liftEffect $ hypercore RAM defaultOptions
--   core <- hypercore (RAF "./test-data") defaultOptions
--   liftEffect $ flip subscribe core $ \x -> do
--     log $ "subscribe: " <> show x
--   s <- append "a" core
--   liftEffect $ log $ "after append" <> show s
--   (b :: Buffer) <- get 0 core
--   a <- liftEffect $ toString N.UTF8 b
--   -- a <- get 0 core
--   liftEffect $ logShow a
--   liftEffect $ log "🍝"
