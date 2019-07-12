@ECHO OFF
for /r %%i in (*) do  if "%%~nxi" == "%%~ni" echo "Compiling %%~nxi from xml" & ^
python convert_ui.py -x %%~ni.xml %%~ni.compiled
echo "Done"
pause
