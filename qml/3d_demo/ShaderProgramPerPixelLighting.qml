import QtQuick 1.0
import Qt3D 1.0

ShaderProgram {
    id:program
    vertexShader: "                    
    attribute highp vec4 qt_Vertex;
    attribute mediump vec3 qt_Normal;
    uniform mediump mat4 qt_ModelViewMatrix;
    uniform mediump mat4 qt_ModelViewProjectionMatrix;
    uniform mediump mat3 qt_NormalMatrix;
    
    struct qt_MaterialParameters {
        mediump vec4 emission;
        mediump vec4 ambient;
        mediump vec4 diffuse;
        mediump vec4 specular;
        mediump float shininess;
    };
    uniform qt_MaterialParameters qt_Material;
    
    struct qt_SingleLightParameters {
        mediump vec4 position;
        mediump vec3 spotDirection;
        mediump float spotExponent;
        mediump float spotCutoff;
        mediump float spotCosCutoff;
        mediump float constantAttenuation;
        mediump float linearAttenuation;
        mediump float quadraticAttenuation;
    };
    uniform qt_SingleLightParameters qt_Light;
    
    varying mediump vec4 qAmbient;
    varying mediump vec4 qDiffuse;
    varying mediump vec3 qNormal;
    varying mediump vec3 qLightDirection;
    varying mediump vec3 qHalfVector;
    varying mediump vec3 qVertexToLight;
    
    void qLightVertex(vec4 vertex, vec3 normal)
    {
        vec3 toEye;
        qNormal = normal;
        qAmbient = qt_Material.emission + qt_Material.ambient;
        qDiffuse = qt_Material.diffuse;
        qLightDirection = normalize(qt_Light.position.xyz);
        toEye = vec3(0, 0, 1);
        qHalfVector = normalize(qLightDirection + toEye);
        qVertexToLight = vertex.xyz - qt_Light.position.xyz;
    }
    
    void main(void)
    {
        gl_Position = qt_ModelViewProjectionMatrix * qt_Vertex;
        vec4 vertex = qt_ModelViewMatrix * qt_Vertex;
        vec3 normal = normalize(qt_NormalMatrix * qt_Normal);
        qLightVertex(vertex, normal);
    }

    "
    fragmentShader: "   
    struct qt_MaterialParameters {
        mediump vec4 emission;
        mediump vec4 ambient;
        mediump vec4 diffuse;
        mediump vec4 specular;
        mediump float shininess;
    };
    uniform qt_MaterialParameters qt_Material;
    
    struct qt_SingleLightParameters {
        mediump vec4 position;
        mediump vec3 spotDirection;
        mediump float spotExponent;
        mediump float spotCutoff;
        mediump float spotCosCutoff;
        mediump float constantAttenuation;
        mediump float linearAttenuation;
        mediump float quadraticAttenuation;
    };
    uniform qt_SingleLightParameters qt_Light;
    
    varying mediump vec3 qNormal;
    varying mediump vec3 qLightDirection;
    varying mediump vec3 qHalfVector;
    varying mediump vec3 qVertexToLight;
    varying mediump vec4 qAmbient;
    varying mediump vec4 qDiffuse;
    
    vec4 qLightPixel(vec4 ambient, vec4 diffuse)
    {
        float angle, spot;
        vec4 color;
        vec4 component;
        vec3 normal = normalize(qNormal);
    
        // Start with the ambient color.
        color = ambient;
    
        // Determine the cosine of the angle between the normal and the
        // vector from the vertex to the light.
        angle = max(dot(normal, qLightDirection), 0.0);
    
        // Calculate the diffuse light components.
        component = angle * diffuse;
    
        // Calculate the specular light components.
        if (angle != 0.0) {
            angle = max(dot(normal, qHalfVector), 0.0);
            component += pow(angle, qt_Material.shininess) * qt_Material.specular;
        }
    
        // Apply the spotlight angle and exponent.
        if (qt_Light.spotCutoff != 180.0) {
            spot = max(dot(normalize(qVertexToLight),
                           normalize(qt_Light.spotDirection)), 0.0);
            if (spot < qt_Light.spotCosCutoff)
                spot = 0.0;
            else
                spot = pow(spot, qt_Light.spotExponent);
            component *= spot;
        }
    
        return clamp(color + component, 0.0, 1.0);
    }
    
    void main(void)
    {
        gl_FragColor = qLightPixel(qAmbient, qDiffuse);
    }

    "
}
