@ECHO OFF
for /r %%i in (*) do  if "%%~nxi" == "%%~ni" echo "Decompiling %%~nxi to xml" & ^
python convert_ui.py -u %%~ni %%~ni.xml
echo "Done"
pause
