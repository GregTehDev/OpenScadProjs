set scadlocation="C:\Program Files\OpenSCAD (Nightly)\openscad.com"
set scadVersion=v8
set scadScript="OpenSauceNameTag.%scadVersion%.scad"

set name=Testing

%scadlocation% %scadScript% -D "name=""%name%""" --enable all -o NameTagMain.%scadVersion%-%name%.stl

%scadlocation% %scadScript% -D "render_part=""name""" -D "name=""%name%""" --enable all -o NameTagName.%scadVersion%-%name%.stl
%scadlocation% %scadScript% -D "render_part=""logo""" -D "name=""%name%""" --enable all -o NameTagLogo.%scadVersion%-%name%.stl
%scadlocation% %scadScript% -D "render_part=""rim""" -D "name=""%name%""" --enable all -o NameTagRim.%scadVersion%-%name%.stl
