// Osman robot head copy
$fn=32*2;

// poorly measured ratios: 54, 46, 18
_tot=54+46+18;
echo(total=_tot, scaledSize=18/_tot);
echo(b=18/48, c=7/48, d=42/52, e=35/42);

faceDepth=8;

box=[100, 100, 100];
browSize=[16, 16, box.y*.56];

eyeDiameter=32;
eyeSpacing=box.x/3.666;
eyeZPosition=browSize.z-eyeDiameter/2;

featureWidth=4;

//eyeCenterDia=eyeDiameter*.85*.85;
eyeCenterDia=eyeDiameter-featureWidth*2;
eyePupleDia=9;
echo(eyeCenterDia=eyeCenterDia, eyePupleDia=eyePupleDia);

mouthHeight=eyeDiameter*.8;
mouthZPostion=mouthHeight/2+mouthHeight/2.75;
mouthTotalWidth=box.x*.8;


color("yellow")
cube(box, center=true);


translate([0, box.y/2+faceDepth-TWEAK, 0])
rotate([90, 0, 0])
linear_extrude(faceDepth)
FaceShape2d();

Rivets();

EarPlacement();



module EarPlacement()
{
    for (xm = [0, 1])
    {
        echo(GetEarRoation(), $t);
        
        mirror([xm, 0, 0])
        rotate([GetEarRoation()*sign(xm-.5), 0, 0])
        translate([(box.x/2-TWEAK), 0, 8])
        Ear();
    }
}



module FaceShape2d()
{
    // top justified
    translate([0, box.z/2, 0])
    {
        translate([0, -browSize.y/2, 0])
        square([box.x, browSize.y], center=true);
        
        translate([0, -browSize.z/2, 0])
        square([browSize.x, browSize.z], center=true);
        
        for (xi = [1, -1])
        {
            translate([xi*eyeSpacing, -eyeZPosition, 0])
            {
                difference()
                {
                    circle(d=eyeDiameter);
                    
                    circle(d=eyeCenterDia);
                }
                
                translate([0, -eyePupleDia*.666, 0])
                //rotation center
                translate([0, 3, 0])
                rotate([0, 0, GetEyeRotation()]) translate([0, 3, 0])
                circle(d=eyePupleDia);
            }
        }
    }
    
    Mouth2d();
}
module Mouth2d()
{
    // bottom justified
    translate([0, -box.z/2, 0])
    difference()
    {
        mouthCenters=mouthTotalWidth-mouthHeight;
        
        hull()
        for (xi = [1, -1])
        translate([xi*mouthCenters/2, mouthZPostion, 0])
        circle(d=mouthHeight);
        
        // cut mouth opening
        offset(r=-featureWidth)
        hull()
        for (xi = [1, -1])
        translate([xi*mouthCenters/2, mouthZPostion, 0])
        circle(d=mouthHeight);
    }
    
    // teeth dividers
    toothH=mouthHeight*.9;
    toothSpacing=13.33;
    toothLineCount=4;
    translate([-toothSpacing*toothLineCount/2, 0, 0])
    for (i = [0 : toothLineCount])
    {
        widthAdj=ToothWidthAdj(i);
        echo(tooth=widthAdj, $t);
        
        translate([0, -box.z/2+toothH, 0])
        translate([i*toothSpacing, 0, 0])
        square([featureWidth+widthAdj, toothH], center=true);
    }
    
}
module Ear()
{
    stickout=16;
    radius=28;
    
    cropStickout=15;
    
    rotate([0, 90, 0])
    intersection()
    {
        translate([0, 0, stickout-radius])
        sphere(r=radius);
        
        cylinder(h=cropStickout, d=radius*1.5);
    }
    
    // antenna
    antennaH=box.z*.666;
    translate([6, 0, 0])
    rotate([0, 10, 0])
    {
        cylinder(h=antennaH, d=4);
        
        translate([0, 0, box.z*.666])
        sphere(d=13);
    }
}

module Rivets(yPos=box.y/2+faceDepth)
{
    rivetXCount=7;
    rivetZCount=4;
    rivetDia=7.5;
    rivetPadding=6.66;
    
    rivetSpacing=box.x/rivetXCount;
    rivetZSpacing=(browSize.z)/rivetZCount;
    
    // face top justified
    translate([0, yPos, box.z/2])
    {
        translate([-(rivetXCount-1)/2*rivetSpacing, 0, 0])
        for (i = [0 : rivetXCount-1])
        {
            ii = abs(i-rivetXCount/2);
            iScale=1+Headache()*(ii/rivetXCount);
            echo(iScale=iScale, Headache());
            
            translate([i*rivetSpacing, 0, -rivetPadding])
            scale([iScale, 1, iScale])
            rivet();
        }
        
        
        translate([0, 0, -rivetPadding])
        for (i = [0 : rivetZCount-1])
        {
            iScale=1+Headache()*(i/rivetZCount);
            //echo(iScale=iScale, Headache());
            
            translate([0, 0, -i*rivetZSpacing])
            scale([iScale, 1, iScale])
            rivet();
        }
    }
    
    module rivet()
    {
            rotate([90, 0, 0])
            sphere(d=rivetDia);
    }
}



earRange=15;
function GetEarRoation() = lookup($t, [
    [0, -earRange],
    [0.25, 0],
    [0.5, earRange],
    [.75, 0],
    [0, -earRange],
    [1, -earRange],
]);
function GetEyeRotation() = 360*$t;
function ToothWidthAdj(i) = lookup($t, [
    [0,    [0, 0, 0, 1, 0][i]],
    [0.25, [0, 3, 0, 4, 0][i]],
    [0.5,  [0, 0, 4, 0, 0][i]],
    [.75,  [0, 0, 0, 3, 0][i]],
    [1, 0, [0, 3, -2, 1, 0][i]],
]);

function Headache() = lookup($t, [
    [0,    0],
    [0.5,  0.5],
    [1, 0],
]);


TWEAK=0.01;
