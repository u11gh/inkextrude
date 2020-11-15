# inkextrude

inkextrude is a simple `XSLT` script which generates an OpenSCAD script containing extrusions of each layer of an input Inkscape `SVG`. The title of the layers is used to define the range of the extrusion. This allows inkscape users to create (very) simple OpenSCAD 3D models without having to write OpenSCAD code.

## Requirements

  * SAXON 9 HE `XSLT` processor. Any other `XSLT` 2.0 processor might work but this has not been verified.

## Usage

### Inkscape

The layer name defined in inkscape is passed to the generated openscad function to change parameters. Therefore it has to be a valid openscad function argument definition.

Example:
  
    z=45, height=3 /*Text*/

In this example the extrusion is extruded by 45 milimeters and the extrusion is 3 milimeters high. 
In line comments are supported.

Available parameters:

  * `x`: passed to `translate` as x coordinate, default value is `0`
  * `y`: passed to `translate` as y coordinate, default value is `0`
  * `z`: passed to `translate` as z coordinate, default value is `0`
  * `height`: passed to `linear_extrude` as height, default value is `0`
  * `center`: passed to `import`, default value is `false`
  * `linex_scale`: passed to `linear_extrude` as scale, default value is `1`
  

![](inkscape.png)

### Transformation

Execute following command within the `demo` directory:

    saxon-xslt demo.svg ../src/inkextrude.xslt > demo.scad

![](openscad.png)

## Trouble Shooting

* OpenSCAD can only extrude `SVG` objects which are paths. Embedded images or text has to be converted to paths.

### Known and unknown issues

* Please don't use exotic input names, no blanks, to fancy characters.
* It hasn't been tested on windows yet.
* Execute the `XSLT` script creates a directory with the name `svg_gen`
  in the executing directory. The generated `SCAD` file has to be in the same parent directory as the `svg_gen` directory, otherwise OpenSCAD will not be able to import the `SVG` files.