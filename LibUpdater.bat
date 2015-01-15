@echo off
REM The title of the CMD window
title Bot of legends LibUpdater v1.3 by Herkules101 (Updated by Bing)
REM the color of the text
color e
echo LibUpdater : The automatic library updater
echo.
echo This tool will automatically download and install BoL libraries with ease.
echo ______________________________________________________________________________
echo.
echo -- Libraries available for installation --
echo.
REM The current libraries the program will download
echo [AllClass.lua]              [AoE_SkillShot_Position.lua]
echo [AQLib.lua]                 [BestCollision.lua]
echo [ChampionLib.lua]           [Collision.lua]
echo [ComboClass.lua]            [ComboLib.lua]
echo [CustomPermaShow.lua]       [DataManager.lua]
echo [DRAW_POS_MANAGER.lua]      [DrawDamageLib.lua]
echo [Edited_AllClass.lua]       [ezCollision.lua]
echo [ezLibrary.lua]             [FastCollision.lua]
echo [FTER_SOW.lua]              [iLibraryENC.lua]
echo [ImBeastyLib.lua]           [imLib.lua]
echo [iSAC.lua]                  [ITEM_MANAGER.lua]
echo [ItemRecipes.lua]           [LEVEL.lua]
echo [LineSkillShotPosition.lua] [MapPosition.lua]
echo [PPrediction.lua]           [Prodiction.lua]
echo [RivenORB]                  [SALib.lua]
echo [Selector.lua]              [ShadowVayneLib.lua]
echo [SourceLib.lua]             [SOW.lua]
echo [spellDmg.lua]              [spellList.lua]
echo [SxOrbWalk.lua]             [TotallyLib]
echo [VPrediction.lua]           [YooLib.lua]
echo [Yolib.lua]

echo.
echo.
pause
cls
:install
REM Ask user whether they would like to Download libraries Y = goto download N = goto exit
Set /P _install= Download/update the current libraries available? (Y/N) :
If /I "%_install%"=="Y" goto download
If /I "%_install%"=="N" goto exit
) Else (
REM If the user doesn't enter Y or N (Case insensitive) this message will be displayed and the user asked to answer again.
echo Invalid argument - this program is case insensitive.
ping 123.45.67.89 -n 1 -w 1800 > nul
cls
goto install

:exit
REM Exit the program
cls
echo Exiting . . .
ping 123.45.67.89 -n 1 -w 2000 > nul
exit

:download
REM Start the download process
cls
cd Tools
REM Make temporary directory to store libraries in
mkdir temp
copy wget.exe temp
cls
echo Downloading and installing libraries . . . please stand by
cd temp
REM GitHub/BitBucket URL's // Will always download the latest version that the developer uploads.
@echo on
wget --no-check-certificate -q https://raw.githubusercontent.com/SurfaceS/BoL_Studio/master/Scripts/Common/AllClass.lua
wget --no-check-certificate -q https://raw.githubusercontent.com/Dienofail/BoL/master/common/AoESkillShotPosition.lua
ren "AoESkillShotPosition.lua" "AoE_SkillShot_Position.lua"
wget --no-check-certificate -q https://raw.githubusercontent.com/bolqqq/BoLScripts/master/common/AQLib.lua
wget --no-check-certificate -q https://raw.githubusercontent.com/Dienofail/BoL/master/common/BestCollision.lua
wget --no-check-certificate -q https://raw.githubusercontent.com/wquantum1/BoL/master/ChampionLib.lua
wget --no-check-certificate -q https://bitbucket.org/Klokje/public-klokjes-bol-scripts/raw/b891699e739f77f77fd428e74dec00b2a692fdef/Common/Collision.lua
wget --no-check-certificate -q https://raw.githubusercontent.com/SurfaceS/BoL_Studio/master/Scripts/Common/ComboClass.lua
wget --no-check-certificate -q https://raw.githubusercontent.com/LlamaBoL/BoL/master/Common/comboLib.lua
wget --no-check-certificate -q https://raw.githubusercontent.com/Superx321/BoL/master/common/CustomPermaShow.lua
wget --no-check-certificate -q https://raw.githubusercontent.com/BoL-Apple/BoL/master/Common/DataManager.lua
wget --no-check-certificate -q https://raw.githubusercontent.com/fter44/ilikeman/master/common/DRAW_POS_MANAGER.lua
wget --no-check-certificate -q https://raw.githubusercontent.com/fter44/ilikeman/master/common/Edited_AllClass.lua 
wget --no-check-certificate -q https://raw.githubusercontent.com/soulcaliber/BoL/master/Common/ezCollision.lua
wget --no-check-certificate -q https://raw.githubusercontent.com/soulcaliber/BoL/master/Common/ezLibrary.lua
wget --no-check-certificate -q https://bitbucket.org/boboben1/bol-scripts/raw/7dae5a6294b9db14b5430b72d9b5c2c6eb8758a1/Misc/FastCollision.lua
wget --no-check-certificate -q https://raw.githubusercontent.com/fter44/ilikeman/master/common/FTER_SOW.lua
wget --no-check-certificate -q http://iuser99.com/libraries/iLibraryENC.lua
wget --no-check-certificate -q http://scripts.imbeasty.com/ImBeastyLib.lua
wget --no-check-certificate -q https://bitbucket.org/Klokje/public-klokjes-bol-scripts/raw/master/Common/ImLib.lua
wget --no-check-certificate -q https://raw.githubusercontent.com/BoL-Apple/BoL/master/Common/iSAC.lua
wget --no-check-certificate -q https://raw.githubusercontent.com/fter44/ilikeman/master/common/ITEM_MANAGER.lua
wget --no-check-certificate -q https://raw.githubusercontent.com/fter44/ilikeman/master/common/LEVEL.lua
wget --no-check-certificate -q https://raw.githubusercontent.com/Dienofail/BoL/master/common/LineSkillShotPosition.lua
wget --no-check-certificate -q https://raw.githubusercontent.com/c3iL/BoL-1/master/MapPosition.lua
wget --no-check-certificate -q https://raw.githubusercontent.com/Dienofail/BoL/master/common/PPrediction.lua
wget --no-check-certificate -q https://bitbucket.org/Klokje/public-klokjes-bol-scripts/raw/master/Test/Prodiction/Prodiction.lua
wget --no-check-certificate -q https://raw.githubusercontent.com/kokosik1221/bol/master/RivenORB.lua
wget --no-check-certificate -q https://raw.githubusercontent.com/UglyOldGuy/NintendoBoL/master/BH%20Bundle/Common/SALib.lua
wget --no-check-certificate -q http://iuser99.com/scripts/Selector.lua
wget --no-check-certificate -q https://raw.githubusercontent.com/Superx321/BoL/master/common/ShadowVayneLib.lua
wget --no-check-certificate -q https://raw.githubusercontent.com/gbilbao/Bilbao/master/BoL1/Common/SourceLib.lua
wget --no-check-certificate -q https://raw.githubusercontent.com/gbilbao/Bilbao/master/BoL1/Common/SOW.lua
wget --no-check-certificate -q https://raw.githubusercontent.com/SurfaceS/BoL_Studio/master/Scripts/Common/spellList.lua
wget --no-check-certificate -q https://raw.githubusercontent.com/Superx321/BoL/master/common/SxOrbWalk.lua
wget --no-check-certificate -q https://raw.githubusercontent.com/Nickieboy/BoL/master/lib/TotallyLib.lua
wget --no-check-certificate -q https://raw.githubusercontent.com/Ralphlol/BoLGit/master/VPrediction.lua
wget --no-check-certificate -q https://raw.githubusercontent.com/Yoooooo/YoLuaProject/master/YooLib.lua
wget --no-check-certificate -q https://raw.githubusercontent.com/Yoooooo/YoLuaProjects/master/Yolib.lua
@echo off
REM Pastebin Links // Will only download the pastebin links as I add them, user may not always recieve the latest version of the library untill added.
@echo on
wget --no-check-certificate -q http://pastebin.com/raw.php?i=hTM4bVC6
ren "raw.php?i=hTM4bVC6" "ItemRecipes.lua"
wget --no-check-certificate -q http://pastebin.com/raw.php?i=7EDjNzuq
ren "raw.php?i=7EDjNzuq" "spellDmg.lua"
wget --no-check-certificate -q http://pastebin.com/raw.php?i=UfZ0Efax
ren "raw.php?i=UfZ0Efax" "DrawDamageLib.lua"
@echo off
REM Move all of the downloaded libraries into the Scripts\Common\ folder.
xcopy "*.lua" "../../Scripts/Common" /e /y /s /i
cd..
REM Remove the temporary directory which holds the libraries.
rmdir temp /q /s
cd..
cls

REM If VPrediction.lua in Scripts\Common doesn't exist goto error
if not exist Scripts\Common\VPrediction.lua goto error
REM If VPrediction.lua exists in Scripts\Common goto success
if exist Scripts\Common\VPrediction.lua goto success

:success
REM The script successfully found VPrediction.lua leading to this message being displayed.
echo Libraries have succesfully been installed. 
echo.
echo. ~ Exiting in 5 ~
ping 123.45.67.89 -n 1 -w 5000 > nul
exit

:error
REM The script couldn't find VPrediction.lua leading to this message being displayed.
echo An error has occured during the download and installation process.
echo.
echo Please ensure that the "Tools" folder is present within your BoL installation
echo If errors persist try and disable any anti-virus that may be installed.
echo The program will now exit . . .
ping 123.45.67.89 -n 1 -w 10000 > nul