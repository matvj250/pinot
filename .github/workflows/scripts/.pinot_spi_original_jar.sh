#!/bin/bash -x

cd pinot/pinot-spi || exit
mvn clean package -DskipTests
mkdir resources
cp target/pinot-spi-1.4.0-SNAPSHOT.jar resources/pinot-spi-japicmp-baseline.jar
