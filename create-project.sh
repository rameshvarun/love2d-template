#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Set the output directory.
OUT_DIR="out/"

if [ -d "$OUT_DIR" ]; then
  echo "$OUT_DIR already exists. Delete it and try again."
  exit 1
fi

cp -r template $OUT_DIR

echo -n "Enter an identifier for the game: "
read GAME_ID
echo -n "Enter a name for the game: "
read GAME_NAME

(
  cd $OUT_DIR
  cat conf.lua | sed -e "s:\${game_id}:$GAME_ID:g" | sed -e "s:\${game_name}:$GAME_NAME:g" > conf.lua.tmp
  mv conf.lua.tmp conf.lua
)

(
  cd $OUT_DIR
  cd vendor

  wget -nc https://raw.githubusercontent.com/mirven/underscore.lua/master/lib/underscore.lua # underscore.lua
  wget -nc https://raw.githubusercontent.com/Mechazawa/Love-Debug-Graph/master/debugGraph.lua # debugGraph.lua

  wget -nc https://raw.githubusercontent.com/kikito/middleclass/master/middleclass.lua # middleclass
  wget -nc https://raw.githubusercontent.com/kikito/stateful.lua/master/stateful.lua # stateful.lua

  wget -nc https://raw.githubusercontent.com/rxi/lume/master/lume.lua # lume
  wget -nc https://raw.githubusercontent.com/rxi/lurker/master/lurker.lua # lurker
  wget -nc https://raw.githubusercontent.com/rxi/lovebird/master/lovebird.lua # lovebird

  # HUMP Utilities
  wget -nc https://raw.githubusercontent.com/vrld/hump/master/timer.lua # hump.timer
  wget -nc https://raw.githubusercontent.com/vrld/hump/master/signal.lua # hump.signal
  wget -nc https://raw.githubusercontent.com/vrld/hump/master/vector.lua # hump.vector
  wget -nc https://raw.githubusercontent.com/vrld/hump/master/camera.lua # hump.camera

  wget -nc https://raw.githubusercontent.com/rameshvarun/hump.timer.actions/master/actions.lua # hump.timer.actions

  wget -nc  https://raw.githubusercontent.com/bjornbytes/cargo/master/cargo.lua # cargo

  # HardonCollider
  wget -nc https://github.com/vrld/HC/archive/master.zip -O hc.zip
  unzip hc.zip
  mv HC-master/ hc/
  rm hc.zip
)
