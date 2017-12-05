@if (%_echo%)==() ( 
    echo off
    set G_ECHO_ON=TRUE 
)

REM # Diosco, 2016
REM #
set   ScrName=oraenv
set   Version=1.0.0
REM #
REM # Description :
set DL0= set the oracle environment variable for a specific database.
set DL1= 
set DL2= 
REM # 
REM # Version History
REM # 1.0.0	5-12-2017  RSK  initial
REM ###############################


goto :MAIN

REM ############# script parameters ###############

REM # STANDALONE parameter uses when no retrieve parameters from a database is requered

set STANDALONE=FALSE
SET EXIT_CODE=0
SET ORACLE_DB=TRUE

REM ############# set parameters ###############


REM ############# Oracle Databases ###############

#####
#
#####

:SetEnvFor_ORADB10G

set ORACLE_SID=
set CONNECT_STRING=

REM # Oracle Software Paramaters
set ORACLE_BASE=<=====ORACLE_BASE====>
set ORACLE_HOME=%ORACLE_BASE%\oradb10g
set TNS_ADMIN=%ORACLE_HOME%\network\admin
set PATH=%ORACLE_HOME%;%ORACLE_HOME%\bin;%ORACLE_HOME%\OPatch;%PATH%

goto :EOF

#####
#
#####

:SetEnvFor_LSNR

set ORACLE_SID=
set CONNECT_STRING=

REM # Oracle Software Paramaters
set ORACLE_BASE=<=====ORACLE_BASE====>
set ORACLE_HOME=%ORACLE_BASE%\oradb10g
set TNS_ADMIN=%ORACLE_HOME%\network\admin
set PATH=%ORACLE_HOME%;%ORACLE_HOME%\bin;%ORACLE_HOME%\OPatch;%PATH%

goto :EOF



#####
#
#####

:SetEnvFor_<====DATABASE====>

REM # Database Settings
set ORACLE_SID=<====SID====>
set CONNECT_STRING=
set ORACLE_UNQNAME=%ORACLE_SID%
REM # Database Settings if these not filled the script will attemt to retrieve these variabelen from the database using the CONNECT_STRING.
set NLS_LANG=
set BDUMP=
set UDUMP=
REM # Oracle Software Paramaters
set ORACLE_BASE=<=====ORACLE_BASE====>
set ORACLE_HOME=%ORACLE_BASE%\Product\oradb11R2
set TNS_ADMIN=%ORACLE_HOME%\network\admin
set PATH=%ORACLE_HOME%;%ORACLE_HOME%\bin;%ORACLE_HOME%\OPatch;%PATH%
REM # If using RMAN fill in these values else leave empty
set BACKUP_DIR=
set RMAN_TARGET_CONNECT=
set RMAN_REP_CONNECT=

goto :EOF



REM ################ Program #####################

REM ######
REM # set NLS_LANG
REM ######

:SET_NLS_LANG

set NLS_LANG=
set NLS_LANG_ERR=FALSE

set SQL_OUTPUT1=EMPTY
for /F "tokens=1,2,3 " %%a in ('"echo select 'ou' ^^^|^^^| 'tp: ' ^^^|^^^| value from NLS_DATABASE_PARAMETERS where PARAMETER = 'NLS_LANGUAGE'; | sqlplus -s %CONNECT_STRING% | findstr outp:"') do ( set SQL_OUTPUT1=%%b)

REM # Check Returned Parameter
if "d-%SQL_OUTPUT1%" EQU "d-EMPTY" set NLS_LANG_ERR=TRUE

set SQL_OUTPUT2=EMPTY
for /F "tokens=1,2,3 " %%a in ('"echo select 'ou' ^^^|^^^| 'tp: ' ^^^|^^^| value from NLS_DATABASE_PARAMETERS where PARAMETER = 'NLS_TERRITORY'; | sqlplus -s %CONNECT_STRING% | findstr outp:"') do ( 
  if "d-%%c" EQU "d-" (
    set SQL_OUTPUT2=%%b
  ) else (
    set SQL_OUTPUT2=%%b %%c
  )
)

REM # Check Returned Parameter
if "d-%SQL_OUTPUT2%" EQU "d-EMPTY" set NLS_LANG_ERR=TRUE

set SQL_OUTPUT3=EMPTY
for /F "tokens=1,2,3 " %%a in ('"echo select 'ou' ^^^|^^^| 'tp: ' ^^^|^^^| value from NLS_DATABASE_PARAMETERS where PARAMETER = 'NLS_CHARACTERSET'; | sqlplus -s %CONNECT_STRING% | findstr outp:"') do ( set SQL_OUTPUT3=%%b)

REM # Check Returned Parameter
if "d-%SQL_OUTPUT3%" EQU "d-EMPTY" set NLS_LANG_ERR=TRUE

set NLS_LANG=%SQL_OUTPUT1%_%SQL_OUTPUT2%.%SQL_OUTPUT3%

if "%NLS_LANG_ERR%" NEQ "FALSE" set NLS_LANG=

goto :EOF


REM ######
REM # set BDUMP
REM ######

:SET_BDUMP

for /F "tokens=1,* delims=: " %%a in ('"echo select 'ou' ^^^|^^^| 'tp: ' ^^^|^^^| value hd from v^$parameter where upper(name) like '^%%BACKGROUND_DUMP_DEST^%%'; | sqlplus -s %CONNECT_STRING% | findstr outp:"') do ( set BDUMP=%%b)

goto :EOF

REM ######
REM # set UDUMP
REM ######

:SET_UDUMP

for /F "tokens=1,* delims=: " %%a in ('"echo select 'ou' ^^^|^^^| 'tp: ' ^^^|^^^| value hd from v^$parameter where upper(name) like '^%%USER_DUMP_DEST^%%'; | sqlplus -s %CONNECT_STRING% | findstr outp:"') do ( set udump=%%b)

goto :EOF

REM ######
REM # set RESET_ORACLE_PARAMETERS
REM ######

:RESET_PARAMETERS
     set ORACLE_HOME=
	 set ORACLE_UNQNAME=
     set NLS_LANG=
     set CONNECT_STRING=
     set BDUMP=
     set UDUMP=
     set CDUMP=
     set BACKUP_DIR=
     set RMAN_TARGET_CONNECT=
     set RMAN_REP_CONNECT=
	 set ORACLE_INSTANCE=
goto :EOF


REM ######
REM # AUTO_SET_ORACLE_DB
REM ######

:AUTO_SET_ORACLE_DB

REM # Try to retrieve parameter for a oracle database when they are not set.    
if "d-%ORACLE_SID%" NEQ "d-" (

    if "d-%CONNECT_STRING%" EQU "d-" ( set CONNECT_STRING="/ as sysdba")

    if "d-%NLS_LANG%" EQU "d-" ( call :SET_NLS_LANG )
    if "d-%BDUMP%" EQU "d-" ( call :SET_BDUMP )
    if "d-%UDUMP%" EQU "d-" ( call :SET_UDUMP )

    doskey sqlpp=sqlplus %CONNECT_STRING%
    doskey svrmgrl=sqlplus %CONNECT_STRING%
    doskey ls=dir

    if "D-%RMAN_REP_CONNECT%" NEQ "D-" (
       doskey RMANN=rman catalog %RMAN_REP_CONNECT% target %RMAN_TARGET_CONNECT%
    )
    
    if exist %BDUMP%\alert_%ORACLE_SID%.log (doskey tallert=tail -f %BDUMP%\alert_%ORACLE_SID%.log) 

)

goto :EOF


:DISPLAY_SETTINGS

ECHO:
ECHO:
ECHO ## Te following parameters are set 
ECHO:
echo ORACLE_SID   = %ORACLE_SID%
echo ORACLE_HOME  = %ORACLE_HOME%
echo TNS_ADMIN    = %TNS_ADMIN%
ECHO NLS_LANG     = %NLS_LANG%
ECHO BDUMP        = %BDUMP%
ECHO UDUMP        = %UDUMP%
ECHO:
ECHO:

goto :EOF


REM ######
REM # MAIN
REM # ~1 [inp,opt] Database SID for wich to set the enviornment
REM ######


:MAIN

REM # check for input parameter 
if "d-%~1"  NEQ "d-" (
  set ORACLE_ENV=%~1
) ELSE (
  REM # if Input is not defined given ask to enter one.
  if "d-%ORAENV_ASK%" NEQ "d-N" ( 
           echo:
		   echo Options:
		   echo:
		   for /F "tokens=1,* delims=_" %%a in ('"type %~df0 | findstr /B :SetEnvFor"') do ( echo:  - %%b)
		   echo:
		   set /P ORACLE_ENV="set ORACLE Enviornment for = " 
		   )
)

REM # set the oracle environment variables
if "d-%ORACLE_ENV%" NEQ "d-" (
     call :RESET_PARAMETERS 
     call :SetEnvFor_%ORACLE_ENV% 
) 

if "d-%ORACLE_SID%" NEQ "d-" ( call :AUTO_SET_ORACLE_DB )

call :DISPLAY_SETTINGS

REM # change Dos window title when you ar in a dos box
if "d-%ORACLE_ENV%" NEQ "d-" (
  if "d-%ORAENV_ASK%" NEQ "d-N" (  
     title %ORACLE_ENV%@%COMPUTERNAME%
  )   
)

:EOF

@if "d-%G_ECHO_ON%" EQU "d-TRUE" ( echo on )

REM #############################################
