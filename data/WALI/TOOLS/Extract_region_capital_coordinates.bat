@echo off
setlocal enabledelayedexpansion
set line=
set lineNum=1950000
set xLine=
set yLine=
set /a count=0
del region_capital_coordinates.txt /q

for /f "skip=1950000 tokens=*" %%f in (esf.xml) do (	

	set /a lineNum=!lineNum!+1
	echo !lineNum!
	
	set 6LineBack=!5LineBack!
	set 5LineBack=!4LineBack!
	set 4LineBack=!3LineBack!
	set 3LineBack=!2LineBack!
	set 2LineBack=!prevLine!
	set prevLine=!line!
	set line=%%f
	
	echo "%%f"|findstr "<s>" >nul
	
	if not errorlevel 1 (

		set "regionLine=!line:<s>=!"
		set "regionLine=!regionLine:</s>=!"

		echo "!6LineBack!"|findstr "<flt>" >nul
		if not errorlevel 1 (
			echo "!5LineBack!"|findstr "<flt>" >nul
			if not errorlevel 1 (
				for /f "tokens=*" %%a in (regions.txt) do ( 
					set region=%%a

					if "!region!"=="!regionLine!" (
					rem echo "%%a"|findstr "!regionLine!" >nul
					rem if not errorlevel 1 (
						set "PosX=!6LineBack!"
						set "PosX=!PosX:<flt>=!"
						set "PosX=!PosX:</flt>=!"

						set "PosY=!5LineBack!"
						set "PosY=!PosY:<flt>=!"
						set "PosY=!PosY:</flt>=!"

						echo ["!region!"] = {!PosX!, !PosY!},>>region_capital_coordinates.txt
					)
				)
			)
		)
		

	)






	
	
)
echo !count!
echo !count2!
pause