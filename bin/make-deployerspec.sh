#!/bin/sh -eu

cd deployerspec/

deployer package "$FRIENDLY_REV_ID" ../rel/deployerspec.zip
