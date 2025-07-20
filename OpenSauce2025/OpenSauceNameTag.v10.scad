// open sauce robot name tag
use <OsmanRobotHead.v7.scad>;
$fn=32;

// ["all", "name", "logo", "rim"]
render_part="all";

name="Greg";
xShift=9;
size=14;

tagSize=[74, 40];

echo(name=name, render=render_part);


tagThickness=0.8;
faceEmboss=tagThickness+1.2;
tagRimThickness=1;
nameThickness=faceEmboss;

xyScale=0.18;
rivetScale=0.5;



ExclusivePrint(render_part == "name")
Name(name=name, xShift=xShift, size=size);

NameTagOuter();


ExclusivePrint(render_part == "logo")
rotate([0, 0, -16])
translate([-22, -14, 0])
{
    color("blue")
    scale([xyScale, xyScale, 1])
    rotate([0, 0, 180])
    linear_extrude(faceEmboss, convexity=10)
    {
        FaceShape2d();
        
        projection()
        rotate([-90, 0, 0])
        EarPlacement();
    }

    color("silver")
    translate([0, 0, faceEmboss])
    scale([1, 1, rivetScale])
    scale([xyScale, xyScale, xyScale])
    rotate([90, 0, 0])
    Rivets(yPos=0);
}




module Name(name, xShift=0, size=14)
{
    font="Liberation Sans:style=Regular";
    
    color("red")
    translate([xShift, size*.8, 0])
    rotate([0, 0, 180])
    linear_extrude(nameThickness, convexity=10)
    text(name, size=size, halign="center", font=font);
}


radius=3;
radius2=1;
module NameTagOuter()
{
    module OuterShape()
    {
        difference()
        {
            offset(r=radius)
            square(tagSize, center=true);
        }
    }
    
    linear_extrude(tagThickness, convexity=10)
    OuterShape();
    
    
    ExclusivePrint(render_part == "rim")
    translate([0, 0, tagThickness])
    difference()
    {
        roof(convexity=10)
        difference()
        {
            OuterShape();
            
            offset(r=radius2)
            offset(r=-radius-radius2)
            OuterShape();
        }
        
        // crop rim z
        big=100;
        translate([0, 0, tagRimThickness+big/2])
        cube([big, big, big], center=true);
    }
}

module ExclusivePrint(bool)
{
    if (bool)
    {
        !children();
    }
    children();
}