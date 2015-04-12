
import QtQuick 1.0
import Qt3D 1.0
import Qt3D.Shapes 1.0
import Qt.labs.shaders 1.0
import QtMobility.sensors 1.1
import Qt.labs.particles 1.0

Viewport {

      signal dataRequired;

    Timer {
           interval: 1; running: true; repeat: true
           onTriggered: {
               //skala=testOb.gimmeText()*30

               //console.log(skala)

           }
       }

    width: 854; height: 480
  //  picking: true

property real ay: 0
property real skala: 1

 light: Light {
     ambientColor: "#FFFFFF"
     specularColor: "#FF0000"
  position: Qt.vector3d(0, 500, -2000)
 }
 Skybox {
         source: "space"
     }

 camera: Camera {
     id:kamera
        eye: Qt.vector3d(0, 0, -800)
    }


Item3D{
    id:ksiezyc
    scale:0.1
    mesh: Mesh { source: "Sphere.obj" }
   position: Qt.vector3d(0, 0, -600)

   effect:
       ShaderProgram {
       id: program_ksiezyc
  texture: "ksiezyc.png"

  vertexShader: "
attribute highp vec4 qt_Vertex;
attribute highp vec4 qt_MultiTexCoord0;
attribute highp vec4 color;
attribute highp vec3 normal;

uniform highp vec4 lightPosition;
uniform highp mat4 modelview;
uniform highp mat4 qt_ModelViewProjectionMatrix;
uniform highp mat3 normalMatrix;

varying highp vec4 texCoord;
varying highp vec3 lightDir;
varying highp vec4 vertColor;
varying highp vec3 ecNormal;
void main(void)
{
gl_Position = qt_ModelViewProjectionMatrix * qt_Vertex;
vec3 ecVertex = vec3(modelview * qt_Vertex);
  ecNormal = normalize(normalMatrix * normal);

lightDir = normalize(lightPosition.xyz - ecVertex);
 vertColor = color;
texCoord = qt_MultiTexCoord0;
}
  "
  fragmentShader: "
varying highp vec4 texCoord;
varying highp vec4 vertColor;
varying highp vec3 lightDir;
varying highp vec3 ecNormal;
uniform sampler2D qt_Texture0;
void main(void)
{
mediump vec3 direction = normalize(lightDir);
mediump vec3 normal = normalize(ecNormal);

highp float intensity = max(0.0, dot(direction, normal));

highp vec4 textureColor = texture2D(qt_Texture0, texCoord.st);
highp vec4 tintColor = vec4(intensity, intensity, intensity, 1) * vertColor;

gl_FragColor = textureColor;
}
  "


   }
}
 Item3D {
     id: ziemia
     scale:1
      mesh: Mesh { source: "Sphere.obj" }

      transform: [
      Rotation3D {
           id:rotate0
          angle: 0
          axis:Qt.vector3d(0, 1, 0)
      }]

      SequentialAnimation {
      running: true
      NumberAnimation {
                      target: rotate0
                      property: "angle"
                      easing.type: Easing.Linear
                      from:0
                      to: 360
                       duration: 360*8
                       loops: Animation.Infinite;
                      //easing.type:"OutQuad"
                  }

      }

      effect:
          ShaderProgram {
          id: program
          property real textureOffsetX : 1.0
                  NumberAnimation on textureOffsetX
                  {
                      running: true; loops: Animation.Infinite
                      from: 0.0; to: 1.0;
                      duration: 1000
                  }
                 texture: "ziemia.png"

                 vertexShader: "
        attribute highp vec4 qt_Vertex;
         uniform highp mat4 qt_ModelViewProjectionMatrix;

         attribute highp vec4 qt_MultiTexCoord0;
         varying highp vec4 texCoord;

         void main(void)
         {
             texCoord = qt_MultiTexCoord0;
             gl_Position = qt_ModelViewProjectionMatrix * qt_Vertex;
         }
                 "
                 fragmentShader: "
       varying highp vec4 texCoord;
         uniform sampler2D qt_Texture0;

         void main(void)
         {
             mediump vec4 textureColor = texture2D(qt_Texture0, texCoord.st);
             gl_FragColor = textureColor;
         }
                 "
      }

 }



    OrientationSensor {
           id: orientation
           active: true

           onReadingChanged: {
               if (reading.orientation == OrientationReading.TopUp)
                   console.log("TopUp");
               else if (reading.orientation == OrientationReading.TopDown)
                   console.log("TopDown");
               else if (reading.orientation == OrientationReading.LeftUp)
                   console.log("LeftUp");
               else if (reading.orientation == OrientationReading.RightUp)
                   console.log("RightUp");
               else if (reading.orientation == OrientationReading.FaceUp)
                   console.log("FaceUp");
               else if (reading.orientation == OrientationReading.FaceDown)
                   console.log("FaceDown");
               else
                   console.log("");
           }
       }





 }


//! [1]
