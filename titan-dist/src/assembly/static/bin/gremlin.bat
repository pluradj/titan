:: Licensed to the Apache Software Foundation (ASF) under one
:: or more contributor license agreements.  See the NOTICE file
:: distributed with this work for additional information
:: regarding copyright ownership.  The ASF licenses this file
:: to you under the Apache License, Version 2.0 (the
:: "License"); you may not use this file except in compliance
:: with the License.  You may obtain a copy of the License at
::
::   http://www.apache.org/licenses/LICENSE-2.0
::
:: Unless required by applicable law or agreed to in writing,
:: software distributed under the License is distributed on an
:: "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
:: KIND, either express or implied.  See the License for the
:: specific language governing permissions and limitations
:: under the License.

:: Windows launcher script for Gremlin Console

@echo off
SETLOCAL EnableDelayedExpansion
set work=%CD%

if [%work:~-3%]==[bin] cd ..

set LIBDIR=lib
set EXT=ext
set EXTDIR=%EXT%/*

cd ext

FOR /D /r %%i in (*) do (
    set EXTDIR=!EXTDIR!;%%i/*
)

cd ..

:: put slf4j-log4j12 first because of conflict with logback
set CP=%LIBDIR%/slf4j-log4j12-1.7.5.jar;%LIBDIR%/*;%EXTDIR%;%CLASSPATH%
set GREMLIN_LOG_LEVEL=WARN

:: workaround for https://issues.apache.org/jira/browse/GROOVY-6453
set JAVA_OPTIONS=-Xms32m -Xmx512m -Djline.terminal=none -Dtinkerpop.ext=%EXT% -Dlog4j.configuration=conf/log4j-console.properties -Dgremlin.log4j.level=%GREMLIN_LOG_LEVEL% -javaagent:%LIBDIR%/jamm-0.3.0.jar

:: Launch the application

if "%1" == "" goto console
if "%1" == "-e" goto script
if "%1" == "-v" goto version

:console

java %JAVA_OPTIONS% %JAVA_ARGS% -cp %CP% org.apache.tinkerpop.gremlin.console.Console %*

goto :eof

:script

set strg=

FOR %%X IN (%*) DO (
CALL :concat %%X %1 %2
)

java %JAVA_OPTIONS% %JAVA_ARGS% -cp %CP% org.apache.tinkerpop.gremlin.groovy.jsr223.ScriptExecutor %strg%

goto :eof

:version
java %JAVA_OPTIONS% %JAVA_ARGS% -cp %CP% org.apache.tinkerpop.gremlin.util.Gremlin

goto :eof

:concat

if %1 == %2 goto skip

SET strg=%strg% %1

:concatsep

if "%CP%" == "" (
set CP=%LIBDIR%\%1
)else (
set CP=%CP%;%LIBDIR%\%1
)

:skip
