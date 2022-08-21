{-# OPTIONS_GHC -fno-warn-monomorphism-restriction #-}

import           Control.Concurrent (threadDelay)
import           Control.Monad      (unless, when)
import           Foreign.C.String   (withCString)
import           Foreign.Ptr        (nullPtr)
import qualified SDL
import qualified SDL.Raw.Mixer      as Mix
import           System.Environment (getArgs)
import           System.Exit        (exitFailure)

main :: IO ()
main = do
  -- read arguments
  (fn1, fn2) <- do
    args <- getArgs
    case args of
      (arg : arg2 : _) -> return (arg, arg2)
      _ -> do
        putStrLn "Usage: cabal run sdl2-mixer-raw-2 <sound filename> <sound filename>"
        exitFailure

  -- initialize libraries
  SDL.initialize [SDL.InitAudio]
  _ <- Mix.init Mix.INIT_MP3

  let rate = 22050
      format = Mix.AUDIO_S16SYS
      channels = 2
      bufsize = 256

  -- open device
  result <- Mix.openAudio rate format channels bufsize
  assert $ result == 0

  -- open file
  sound <- withCString fn1 $ \cstr -> Mix.loadWAV cstr
  sound2 <- withCString fn2 $ \cstr -> Mix.loadWAV cstr

  assert $ sound /= nullPtr
  assert $ sound2 /= nullPtr

  -- play file
  channel1 <- Mix.playChannel 0 sound 0

  threadDelay 100000

  channel2 <- Mix.playChannel 1 sound2 0

  assert $ channel1 /= -1

  -- wait until finished
  whileTrueM $ (/= 0) <$> Mix.playing channel1
  whileTrueM $ (/= 0) <$> Mix.playing channel2

  -- free resources
  Mix.freeChunk sound

  -- close device
  Mix.closeAudio

  -- quit
  Mix.quit
  SDL.quit

assert :: Bool -> IO ()
assert = flip unless $ error "Assertion failed"

whileTrueM :: Monad m => m Bool -> m ()
whileTrueM cond = do
  loop <- cond
  when loop $ whileTrueM cond
