@ECHO OFF

REM ; This script is used in the jenkins part of our pipeline to verify our
REM ; package is working correctly after install.

REM ; chef version ensures our bin ends up on path and the basic ruby env is
REM ; working.
call chef version
