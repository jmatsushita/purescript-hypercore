module Hypercore where

import Prelude
import Control.Promise
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)
import Effect.Uncurried (EffectFn2, EffectFn3, runEffectFn2, runEffectFn3)
import Effect.Class (liftEffect)
import Effect.Console (log, logShow)
import Node.Buffer (Buffer, toString)
import Node.Encoding (Encoding(..)) as N
import Option as Option


foreign import hypercore_ :: forall a. EffectFn2 Storage Options (Promise (Feed a))
foreign import hypercoreWithKey_ :: forall a. EffectFn3 Storage PublicKey Options (Promise (Feed a))
foreign import append_ :: forall a. EffectFn2 a (Feed a) (Promise Seq)
foreign import get_ :: forall a. EffectFn2 Index (Feed a) (Promise Buffer)

type FilePath = String
data Storage = RAM | RAF FilePath
data Feed a
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
  sparse :: Boolean, -- do not mark the entire feed to be downloaded
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
defaultOptions = Option.fromRecord {
  createIfMissing : true, -- create a new hypercore key pair if none was present in storage
  overwrite: false, -- overwrite any old hypercore that might already exist
  valueEncoding: BINARY, -- defaults to binary
  sparse: false, -- do not mark the entire feed to be downloaded
  eagerUpdate: true, -- always fetch the latest update that is advertised. default false in sparse mode.
  -- secretKey: buffer, -- optionally pass the corresponding secret key yourself
  storeSecretKey: true, -- if false, will not save the secret key
  storageCacheSize: Cachesize 65536, -- the # of entries to keep in the storage system's LRU cache (false or 0 to disable)
  -- onwrite: (index, data, peer, cb) -- optional hook called before data is written after being verified
  --                                  -- (remember to call cb() at the end of your handler)
  stats: false -- collect network-related statistics,
  -- Optionally use custom cryptography for signatures
  -- crypto: {
  --   sign (data, secretKey, cb(err, signature)),
  --   verify (signature, data, key, cb(err, valid))
  -- }
  -- noiseKeyPair: { publicKey, secretKey } -- set a static key pair to use for Noise authentication when replicating
}

hypercore :: forall a. Storage -> Options -> Aff (Feed a)
hypercore s o = toAffE $ runEffectFn2 hypercore_ s o

hypercoreWithKey :: forall a. Storage -> PublicKey -> Options -> Aff (Feed a)
hypercoreWithKey s p o = toAffE $ runEffectFn3 hypercoreWithKey_ s p o

append :: forall a. a -> Feed a -> Aff Seq
append a f = toAffE $ runEffectFn2 append_ a f

get :: forall a. Index -> Feed a -> Aff Buffer
get i f = toAffE $ runEffectFn2 get_ i f

main :: Effect Unit
main = launchAff_ do
  -- f <- liftEffect $ hypercore RAM defaultOptions
  feed <- hypercore (RAF "./test-data") defaultOptions
  s <- append "a" feed
  liftEffect $ logShow s
  (b :: Buffer) <- get 0 feed
  a <- liftEffect $ toString N.UTF8 b
  -- a <- get 0 feed
  liftEffect $ logShow a
  liftEffect $ log "🍝"
