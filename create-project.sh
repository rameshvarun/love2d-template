#!/usr/bin/env bash

cd vendor
wget -nc https://raw.githubusercontent.com/mirven/underscore.lua/master/lib/underscore.lua # underscore.lua

wget -nc https://raw.githubusercontent.com/kikito/middleclass/master/middleclass.lua # middleclass
wget -nc https://raw.githubusercontent.com/kikito/stateful.lua/master/stateful.lua # stateful.lua

wget -nc https://raw.githubusercontent.com/rxi/lume/master/lume.lua # lume
wget -nc https://raw.githubusercontent.com/rxi/lurker/master/lurker.lua # lurker

# HUMP Utilities
wget -nc https://raw.githubusercontent.com/vrld/hump/master/timer.lua # hump.timer
wget -nc https://raw.githubusercontent.com/vrld/hump/master/signal.lua # hump.signal
wget -nc https://raw.githubusercontent.com/vrld/hump/master/vector.lua # hump.vector

wget -nc https://raw.githubusercontent.com/rameshvarun/hump.timer.actions/master/actions.lua # hump.timer.actions

# HardonCollider
wget -nc https://github.com/vrld/HC/archive/master.zip -O hc.zip
unzip hc.zip
mv HC-master/ hc/
rm hc.zip
