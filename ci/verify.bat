
@ECHO OFF

REM ; This script is used in the jenkins part of our pipeline to verify our
REM ; package is working correctly after install.

REM ; Accept the EULA for testing purposes
SET CHEF_LICENSE=accept-no-persist

REM ; chef-run version ensures our bin ends up on path and the basic ruby env is
REM ; working.
call chef-run --version
IF %ERRORLEVEL% NEQ 0 goto :error

REM ; Ensure our ChefDK works
call chef env
IF %ERRORLEVEL% NEQ 0 goto :error
