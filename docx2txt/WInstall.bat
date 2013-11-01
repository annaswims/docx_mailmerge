@echo off

:: docx2txt, a command-line utility to convert Docx documents to text format.
:: Copyright (C) 2008-now Sandeep Kumar
::
:: This program is free software; you can redistribute it and/or modify
:: it under the terms of the GNU General Public License as published by
:: the Free Software Foundation; either version 3 of the License, or
:: (at your option) any later version.
::
:: This program is distributed in the hope that it will be useful,
:: but WITHOUT ANY WARRANTY; without even the implied warranty of
:: MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
:: GNU General Public License for more details.
::
:: You should have received a copy of the GNU General Public License
:: along with this program; if not, write to the Free Software
:: Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

::
:: A simple commandline installer for docx2txt on Windows.
::
:: Author : Sandeep Kumar (shimple0 -AT- Yahoo .DOT. COM)
::
:: ChangeLog :
::
::    02/10/2009 - Initial version of command line installation script for
::                 Windows users. Script will prompt user for perl, unzip and
::                 cakecmd paths and will update these paths in the installed
::                 files using perl, if perl path is valid. Else it will simply
::                 copy the concerned files to the installation folder.
::


::
:: Ensure that required command extensions are enabled.
::

setlocal enableextensions
setlocal enabledelayedexpansion


echo.
echo Welcome to command line installer for docx2txt.
echo.


::
:: Check if this install script is invoked correctly.
::

if not "%~2" == "" (
    echo.
    echo Usage : "%~0" [WhereToInstall]
    echo.
    echo 	WhereToInstall specifies a folder to install into.
    echo.
    echo 	If destination folder is not specified on command line,
    echo 	then it will be asked for during the installation.
    echo.
    goto END
)


::
:: Check if destination folder was specified on command line, else ask for it.
::

if "%~1" == "" (
    echo.
    echo Where should the docx2txt tool be installed? Specify the location
    echo without surrounding quotes.
    echo.
    set /P destdir=Installation Folder :
    echo.
) else (
    set destdir=%~1
)

if not exist "%destdir%" (
    echo.
    echo ** Folder "%destdir%" does not exist. It will be created now.
    echo.
    mkdir "%destdir%"
)


::
:: Check if user specified destdir is a valid folder or a not.
::

pushd "%destdir%" 2>nul
if ERRORLEVEL 1 (
    echo.
    echo ** "%destdir%" does not specify a valid folder name.
    echo ** Exiting installer.
    echo.
    goto END
) else if ERRORLEVEL 0 (
    popd
)


echo.
echo Please specify fully qualified paths to utilities when requested.
echo Perl.exe is required for docx2txt tool as well as for this installation.
echo.

set /A attempts=0

:GET_PERL_PATH

set /P PERL=Path to Perl.exe : 
call :CHECK_FILE_EXISTENCE "%PERL%" "perl"
if ERRORLEVEL 7 (
    set /A attempts=attempts+1
    if !attempts! == 3 (
        echo.
        echo Continuing with simple installation ....
        echo.
        goto SIMPLE_INSTALL
    ) else (
        goto GET_PERL_PATH
    )
)


echo.
echo.
echo If you do not have CakeCmd.exe installed, simply press Enter/Return key.
echo.
 
set /P CAKECMD=Path to CakeCmd.exe : 


echo.
echo.
echo In case you are using Cygwin Perl.exe, you need to specify Unzip.exe path
echo using forward slashes i.e. like C:/path/to/unzip.exe .
echo If you do not have Unzip.exe installed, simply press Enter/Return key.
echo.
 
set /P UNZIP=Path to Unzip.exe : 

echo.
echo.
echo Here is the information you have provided.
echo.
echo Installation folder = %destdir%
echo Perl = %PERL%
echo CakeCmd = %CAKECMD%
echo Unzip = %UNZIP%
echo.

pause

echo.
echo Installing script files to "%destdir%" ....

copy docx2txt.pl "%destdir%" > nul

if not "%UNZIP%" == "" (
    %PERL% -e "undef $/; $_ = <>; s/(unzip\s*=>)[^,]*,/$1 '$ARGV[0]',/; print;" docx2txt.config "%UNZIP%" > "%destdir%\docx2txt.config"
)

if "%CAKECMD%" == "" (
    %PERL% -e "undef $/; $_ = <>; s/(set PERL=).*?(\r?\n)/$1$ARGV[0]$2/; print;" docx2txt.bat "%PERL%" > "%destdir%\docx2txt.bat"
) else (
    %PERL% -e "undef $/; $_ = <>; s/(set PERL=).*?(\r?\n)/$1$ARGV[0]$2/; s/:: (set CAKECMD=).*?(\r?\n)/$1$ARGV[1]$2/; print;" docx2txt.bat "%PERL%" "%CAKECMD%" > "%destdir%\docx2txt.bat"
)

goto END


:SIMPLE_INSTALL

echo Copying script files to "%destdir%" ....

copy docx2txt.bat "%destdir%" > nul
copy docx2txt.pl "%destdir%" > nul
copy docx2txt.config "%destdir%" > nul

echo.
echo Please adjust perl, unzip and cakecmd paths (as needed) in
echo "%destdir%\docx2txt.bat" and "%destdir%\docx2txt.config"
echo.

goto END

::
:: Check whether the argument executable exists?
::

:CHECK_FILE_EXISTENCE

if not exist "%~1" (
    echo.
    echo ** Can not find executable "%~1".
    echo.
) else if /I "%~nx1" NEQ "%~2.exe" (
    echo.
    echo ** "%~1" does not seem to be an executable file.
    echo.
) else exit /B 0

exit /B 7


:END

endlocal
endlocal

set PERL=
set CAKECMD=
set UNZIP=
set FILES=
set attempts=
