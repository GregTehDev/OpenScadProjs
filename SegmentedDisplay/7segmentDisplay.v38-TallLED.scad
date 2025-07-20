// 9-segment display
$fn=48;
fnDiode=24;


letterAngle=-10;
segmentWidth=5.5;
angledSegmentWidth=32.4;
totalWidth=47.8;
totalHeight=69.7;
//totalSegmentHeight=56.8; // edge-to-edge
segmentCenterHeight=25.75;
decimalPointPosition=17.35;
decimalPointDiameter=5.5;

segmentGapSize=segmentWidth/4;

centerSegmentWidth=angledSegmentWidth-decimalPointDiameter-segmentGapSize;

mainMirror=[0, 0, 0];

DECIMAL_POINTS=false;


/*NOTES
- on actual ones each corner type is different (or rotated)

v26:
 - skipped from v23 to leave some room
 - this is switching the segments to being 3d instead of 2d, via linear extrudes
 
v30:
 - Fixed letter angle to be negative for this print rotation. Build plate surface is display surface

v35:
 - Got a new set of leds, taller ones
 - PRINT SETTINGS: Have been using zero infil, zero top layer. Only wall and bottom, which works pretty nice
 
*/

a=[cos(letterAngle), sin(letterAngle)];




//TESTS();

//scaleXY=0.5;
scaleXY=.75;
scaleOverZ=.55;
thickness=10+4;




spacing1=4;
spacing2=6;
s=1.5;
layoutGroups_fullDate=[
    [3, spacing2, -1.5-s],
    [2, spacing1, 0],
    [4, spacing1, 2+s],
    [2, spacing1, 4+s*2],
    [2, spacing1, 6+s*2.25]
];

layoutGroups=[
    [2, spacing1, 0]
];

// clock hh:mm
layoutGroups22=[
    [2, spacing1, 0],
    [2, spacing1, s*1.5],
];




difference()
{
    scale([scaleXY, scaleXY, 1])
    //linear_extrude(10, convexity=10)
    {
        //ExtrudeShape();
        *DisplayRow(4, widthAdjust=4);
        
        
        
        for (group = layoutGroups)
        {
            digits=group[0];
            spacing=group[1];
            xMove=group[2];
            
            newWidth=totalWidth-spacing;
            
            translate([xMove*newWidth, 0, 0])
            DisplayRow(digits, widthAdjust=spacing);
        }
        
    }

    scale([scaleXY, scaleXY, 1])
    mirror(mainMirror)
    translate([0, 0, thickness/2])
    mirror([0, 0, 1])
    RenderLayoutGroups_DiodeHoles(layoutGroups);
}



module DisplayRow(count, widthAdjust)
{
    DisplayRow_subproc(count, widthAdjust)
    {
        ExtrudeShape(widthAdjust);
    }
}
module DisplayRow_subproc(count, widthAdjust)
{
    wR=totalWidth-widthAdjust;
    wT=totalWidth-TWEAK-widthAdjust;
    
    c=(count-1)/2;
    
    maxX=(count-1)/2 * wT;
    
    pos=[for(a = [0:count-1]) a*wT - maxX];
    echo(pos=pos);
    
    for (i = [1 : count])
    {
        translate([pos[i-1], 0, 0])
        children();
    }
}
module RenderLayoutGroups_DiodeHoles(layout)
{
    for (group = layout)
    {
        digits=group[0];
        spacing=group[1];
        xMove=group[2];
        
        newWidth=totalWidth-spacing;
        
        translate([xMove*newWidth, 0, -TWEAK])
        DisplayRow_subproc(digits, widthAdjust=spacing)
        //DiodeHole();
        DiodeHole_5050();
    }
}
// This is for 5050 (5.0mm x 5.0mm) chips on a pcb that is just under 10mm. Have a strip of 50 of those, so I could handle 7 digits
module DiodeHole_5050($fn=fnDiode)
{
    d=9.5 + .2;
    hole=[5.2, 5.5];
    
    lightPathHoleDia=4.0;
    lightPathH=5;
    
    domeH=1.5;
    h=3.0-domeH;
    
    domeHScale=1/1.5;
    
    zBase=1.4;
    zBaseDia=d+.5;
    
    SegmentCenterPositions(rotateWithAngle=-1)
    {
        scale([1/scaleXY, 1/scaleXY, 1])
        {
            cylinder(h=zBase+TWEAK, d=zBaseDia);
            
            translate([0, 0, zBase])
            //cylinder(h=h, d=d);
            linear_extrude(h)
            square(hole, center=true);
            
            translate([0, 0, zBase])
            translate([0, 0, h-TWEAK])
            cylinder(h=lightPathH+TWEAK, d=lightPathHoleDia);
            
            *translate([0, 0, zBase])
            translate([0, 0, h])
            scale([1, 1, 1/scaleXY * domeHScale])
            sphere(d=lightPathHoleDia);
        }
    }
}
module DiodeHole_5mmRound($fn=fnDiode)
{
    d=5;
    
    domeH=1.5;
    h=7.0-domeH;
    
    domeHScale=1/1.5;
    
    zBase=1.4;
    zBaseDia=5.6+.2;
    
    SegmentCenterPositions()
    {
        scale([1/scaleXY, 1/scaleXY, 1])
        {
            cylinder(h=zBase, d=zBaseDia);
            
            translate([0, 0, zBase])
            cylinder(h=h, d=d);
            
            translate([0, 0, zBase])
            translate([0, 0, h])
            scale([1, 1, 1/scaleXY * domeHScale])
            sphere(d=d);
        }
    }
}

module ExtrudeShape(widthAdjust)
{
    mirror(mainMirror)
    difference()
    {
        color("blue", .4)
        linear_extrude(thickness, center=true, convexity=10)
        square([totalWidth-widthAdjust, totalHeight], center=true);
        
        _NegativeExtrudes();
    }
}
module _NegativeExtrudes()
{
        2dTo3dExtrude()
        CenterSegment();
        if (DECIMAL_POINTS) DecimalPoint();
        HorizontalSegments_Pointed();
        VerticalSegments_Pointed();
}




module SegmentCenterPositions(rotateWithAngle=0)
{
    // center
    children();
    
    // top/bottom
    for (d = [1, -1])
    {
        translate([segmentCenterHeight*a.y*d, segmentCenterHeight*d])
        children();
    }
    
    // verticles
    xDiff=segmentCenterHeight/2 * a.y;
    
    posY=segmentCenterHeight/2;
    posX=centerSegmentWidth/2 + segmentGapSize/2 + xDiff;
    posXNeg=centerSegmentWidth/2 + segmentGapSize/2 - xDiff;
    positive=[posX, posY];
    negative=[posXNeg, posY];
    
    positions=[
        [1, 1],
        [1, -1],
        [-1, 1],
        [-1, -1]
    ];
    
    for (d = positions)
    {
        parity=d.x*d.y;
        move=(parity > 0 ? positive : negative);
        translate([move.x*d.x, posY*d.y])
        {
            rotate([0, 0, rotateWithAngle*letterAngle])
            children();
        }
    }
}


//testDistance=30;
//echo([testDistance*a.x, testDistance*a.y]);
//
//translate([testDistance*a.x, testDistance*a.y])
//circle(d=1);
//
//translate([-centerSegmentWidth/2, 0, 0])
//rotate([0, 0, 90-letterAngle])
//translate([segmentCenterHeight, 0, 0])
//circle(d=1);


cornerType="rounded";



function anglePointX(p) = [p.x + (a.y*p.y), p.y];

// NOT NEEDED?
function getX(p) = angleDir(p) > 0 ? (2-a.x) : a.x;
function angleDir(p) = sign(sign(p.x) * sign(p.y));

//module TESTS()
//{
//    test1=[10.0125, -2.75];
//    echo("Test", test1,
//        anglePointX(test1),
//        getX(test1));
//    test2=[-10.0125, -2.75];
//    echo("Test", test2,
//        anglePointX(test2),
//        getX(test2));
//}

module 2dTo3dExtrude()
{
    //linear_extrude(thickness, scale=scaleOverZ, center=true, convexity=10)
    
    translate([0, 0, -thickness/4])
    linear_extrude(thickness/2+TWEAK, center=true, convexity=10)
    children();
    
    translate([0, 0, thickness/4])
    linear_extrude(thickness/2+TWEAK, scale=scaleOverZ, center=true, convexity=10)
    children();
}



module HorizontalSegments_Pointed()
{
    for (d = [1, -1])
    {
        translate([segmentCenterHeight*a.y*d, segmentCenterHeight*d])
        2dTo3dExtrude()
        CenterSegment();
    }
}
module VerticalSegments_Pointed()
{
    xDiff=segmentCenterHeight/2 * a.y;
    
    posY=segmentCenterHeight/2;
    posX=centerSegmentWidth/2 + segmentGapSize/2 + xDiff;
    posXNeg=centerSegmentWidth/2 + segmentGapSize/2 - xDiff;
    positive=[posX, posY];
    negative=[posXNeg, posY];
    //echo(posX=posX, posXNeg=posXNeg);
    
    positions=[
        [1, 1],
        [1, -1],
        [-1, 1],
        [-1, -1]
    ];
    
    for (d = positions)
    {
        parity=d.x*d.y;
        move=(parity > 0 ? positive : negative);
        translate([move.x*d.x, posY*d.y])
        {
            2dTo3dExtrude()
            VerticalSegment_Centered();
        }
    }
}

module VerticalSegment_Centered()
{
    cornerX=segmentWidth/2*(2-a.x);
    h=segmentCenterHeight/2 - segmentGapSize/2;
    cornerY=h-segmentWidth/2;
    
    points=[
        [h*a.y, h],
        anglePointX([cornerX, cornerY]),
        anglePointX([cornerX, -cornerY]),
    
        [-h*a.y, -h],
        anglePointX([-cornerX, -cornerY]),
        anglePointX([-cornerX, cornerY]),
    ];
    //echo(points);
    
    polygon(points);
}
module CenterSegment()
{
    cornerY=segmentWidth/2;
    cornerX=centerSegmentWidth/2-segmentWidth/2;
    
    points=[
        anglePointX([cornerX, cornerY]),
        [centerSegmentWidth/2, 0],
        anglePointX([cornerX, -cornerY]),
    
        anglePointX([-cornerX, -cornerY]),
        [-centerSegmentWidth/2, 0],
        anglePointX([-cornerX, cornerY]),
    ];
    //echo(points);
    
    polygon(points);
}
module DecimalPoint()
{
    translate([decimalPointPosition, -segmentCenterHeight])
    circle(d=decimalPointDiameter);
}


TWEAK=0.001;