import { Mat4 } from './math.js';
import { Parser } from './parser.js';
import { Scene } from './scene.js';
import { Renderer } from './renderer.js';
import { TriangleMesh } from './trianglemesh.js';
// DO NOT CHANGE ANYTHING ABOVE HERE

////////////////////////////////////////////////////////////////////////////////
// TODO: Implement createCube, createSphere, computeTransformation, and shaders
////////////////////////////////////////////////////////////////////////////////

// Example two triangle quad
const quad = {
  positions: [-1, -1, -1, 1, -1, -1, 1, 1, -1, -1, -1, -1, 1,  1, -1, -1,  1, -1],
  normals: [0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1],
  uvCoords: [0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1]
}

TriangleMesh.prototype.createCube = function() {
  // TODO: populate unit cube vertex positions, normals, and uv coordinates
  this.positions =
    [-1, -1, -1, //back
    1, -1, -1,
    1, 1, -1,
    -1, -1, -1,
    1,  1, -1,
    -1,  1, -1,

    -1, 1, -1, //top
    1, 1, 1,
    1, 1, -1,
    -1, 1, -1,
    -1, 1, 1,
    1, 1, 1,

    1, -1, 1, //front
    -1, 1, 1,
    1, 1, 1,
    1, -1, 1,
    -1, -1, 1,
    -1, 1, 1,

    1, 1, 1, //right
    1, -1, -1,
    1, 1, -1,
    1, 1, 1,
    1, -1, -1,
    1, -1, 1,

    -1, 1, 1, //left
    -1, 1, -1,
    -1, -1, -1,
    -1, 1, 1,
    -1, -1, -1,
    -1, -1, 1,

    -1, -1, -1, //bottom
    1, -1, 1,
    -1, -1, 1,
    -1, -1, -1,
    1, -1, -1,
    1, -1, 1];

  this.normals =
    [0, 0, -1, //back
    0, 0, -1,
    0, 0, -1,
    0, 0, -1,
    0, 0, -1,
    0, 0, -1,

    0, 1, 0, //top
    0, 1, 0,
    0, 1, 0,
    0, 1, 0,
    0, 1, 0,
    0, 1, 0,

    0, 0, 1, //front
    0, 0, 1,
    0, 0, 1,
    0, 0, 1,
    0, 0, 1,
    0, 0, 1,

    1, 0, 0, //right
    1, 0, 0,
    1, 0, 0,
    1, 0, 0,
    1, 0, 0,
    1, 0, 0,

    -1, 0, 0, //left
    -1, 0, 0,
    -1, 0, 0,
    -1, 0, 0,
    -1, 0, 0,
    -1, 0, 0,

    0, -1, 0, //bottom
    0, -1, 0,
    0, -1, 0,
    0, -1, 0,
    0, -1, 0,
    0, -1, 0];

  this.uvCoords = [
    0.5, 0, //back
    1, 0,
    1, 1/3,

    0.5, 0,
    1, 1/3,
    0.5, 1/3,

    0, 1/3, //top
    0.5, 0,
    0.5, 1/3,

    0, 1/3,
    0, 0,
    0.5, 0,

    0.5, 2/3, //front
    0, 1,
    0.5, 1,

    0.5, 2/3,
    0, 2/3,
    0, 1,

    0, 2/3,//right
    0.5, 1/3,
    0.5, 2/3,

    0, 2/3,
    0.5, 1/3,
    0, 1/3,

    1, 2/3,//left
    0.5, 2/3,
    0.5, 1/3,

    1, 2/3,
    0.5, 1/3,
    1, 1/3,

    0.5, 1, //bottom
    1, 2/3,
    1, 1,

    0.5, 1,
    0.5, 2/3,
    1, 2/3];
}


//The code for my sphere references the sphere example linked in the assignment
TriangleMesh.prototype.createSphere = function(stackCount, sectorCount) {
  const radius = 1;
  var stackAngle = 0;//phi
  var sectorAngle = 0;//theta
  var x, y, z, nx, ny, nz
  var s, t;
  var k1, k2;
  var lengthInv = 1/radius;

  for (var i = 0; i <= stackCount; i++) {

    stackAngle = Math.PI / 2 - i * (Math.PI / stackCount);
    
    for (var j = 0; j <= sectorCount; j++) {
      sectorAngle = 2 * Math.PI * j / sectorCount;

      x = Math.cos(stackAngle) * Math.cos(sectorAngle);
      y = Math.cos(stackAngle) * Math.sin(sectorAngle);
      z = Math.sin(stackAngle);
      this.positions.push(x * radius, y * radius, z * radius);

      nx = x * lengthInv;
      ny = y * lengthInv;
      nz = z * lengthInv;
      this.normals.push(nx, ny, nz);

      s = 1 - j / sectorCount;
      t = i / stackCount;
      this.uvCoords.push(s, t);
    }
  }

  for (var i = 0; i < stackCount; i++) {
    k1 = i * (sectorCount + 1);
    k2 = k1 + sectorCount + 1;
    for (var j = 0; j < sectorCount; j++, k1++, k2++) {

      if (i != 0) {
        this.indices.push(k1, k2, k1+1);
      }
      if (i != (stackCount - 1)) {
        this.indices.push(k1 + 1, k2, k2 + 1);
      }
    }
  }
}

Scene.prototype.computeTransformation = function(transformSequence) {
  // TODO: go through transform sequence and compose into overallTransform
  let overallTransform = Mat4.create(); 
  let mat = [];
  //Start with the last transformation
  for (var i = transformSequence.length - 1; i >= 0; i--) {
    mat[i] = Mat4.create(); //identity matrix
    //Change the identity matrices to the corresponding transformation matrices based on lecture slides
    //Since the matrices go by column, multiply the column index you want to change by 3, 
    //and add the row index
    if (transformSequence[i][0] == 'T') {
      mat[i][4*3 + 0] = transformSequence[i][1];
      mat[i][4*3 + 1] = transformSequence[i][2];
      mat[i][4*3 + 2] = transformSequence[i][3];
    } else if (transformSequence[i][0] == 'S') {
      mat[i][4*0 + 0] = transformSequence[i][1];
      mat[i][4*1 + 1] = transformSequence[i][2];
      mat[i][4*2 + 2] = transformSequence[i][3];
    } else {
      var sectorAngle = transformSequence[i][1] * Math.PI/180;
      if (transformSequence[i][0] == 'Rx') {
        mat[i][4*1 + 1] = Math.cos(sectorAngle);
        mat[i][4*2 + 1] = -Math.sin(sectorAngle);
        mat[i][4*1 + 2] = Math.sin(sectorAngle);
        mat[i][4*2 + 2] = Math.cos(sectorAngle);
      } else if (transformSequence[i][0] == 'Ry') {
        mat[i][4*0 + 0] = Math.cos(sectorAngle);
        mat[i][4*2 + 0] = Math.sin(sectorAngle);
        mat[i][4*0 + 2] = -Math.sin(sectorAngle);
        mat[i][4*2 + 2] = Math.cos(sectorAngle);
      } else if (transformSequence[i][0] == 'Rz') {
        mat[i][4*0 + 0] = Math.cos(sectorAngle);
        mat[i][4*1 + 0] = -Math.sin(sectorAngle);
        mat[i][4*0 + 1] = Math.sin(sectorAngle);
        mat[i][4*1 + 1] = Math.cos(sectorAngle);
      }
    }
    var CurrentMatrix = overallTransform;
    overallTransform = Mat4.multiply(overallTransform, CurrentMatrix, mat[i]);
  }
  return overallTransform;
}

//The code for my shaders references a mix of the professor's code from the second half of the lecture on March 23rd, and the Wikipedia example of Blinn-Phong : https://en.wikipedia.org/wiki/Blinn%E2%80%93Phong_reflection_model
Renderer.prototype.VERTEX_SHADER = `
precision mediump float;
attribute vec3 position, normal;
attribute vec2 uvCoord;
uniform vec3 lightPosition;
uniform mat4 projectionMatrix, viewMatrix, modelMatrix;
uniform mat3 normalMatrix;
varying vec2 vTexCoord;

// TODO: implement vertex shader logic below

varying vec4 vectDistance;
varying vec3 fNormal;
varying vec4 pos;

void main() {
  fNormal = normalize(normalMatrix * normal); 
  pos = viewMatrix * modelMatrix * vec4(position, 1.0);

  vec4 lightDir = viewMatrix * vec4(lightPosition, 1.0);
  
  vectDistance = lightDir - pos;

  vTexCoord = uvCoord;
  gl_Position = projectionMatrix * viewMatrix * modelMatrix * vec4(position, 1.0);
}
`;

Renderer.prototype.FRAGMENT_SHADER = `
precision mediump float;
uniform vec3 ka, kd, ks, lightIntensity;
uniform float shininess;
uniform sampler2D uTexture;
uniform bool hasTexture;
varying vec2 vTexCoord;

// TODO: implement fragment shader logic below

varying vec4 vectDistance;
varying vec3 fNormal;
varying vec4 pos;

void main() {
  float distance = length(vectDistance.xyz);
  distance = distance * distance;

  //Ambient
  vec3 col_ambient = ka * lightIntensity;

  //Lambertian diffuse
  float n_dot_l = dot(fNormal, normalize(vectDistance.xyz));
  float clamp_n_dot_l = max(0.0, n_dot_l);
  vec3 col_diffuse = kd * clamp_n_dot_l * lightIntensity/(distance);

  //Blinn-Phong
  vec3 h = (normalize(vectDistance.xyz) - normalize(pos.xyz));
  float n_dot_h = dot(fNormal, normalize(h));
  float clamp_n_dot_h = max(0.0, n_dot_h);
  vec3 col_specular = ks * lightIntensity * pow(clamp_n_dot_h, shininess)/(distance);

  vec3 col = col_ambient + col_diffuse + col_specular;

  if (hasTexture) {
    gl_FragColor = vec4(col, 1.0)* texture2D(uTexture, vTexCoord);
  } else {
    gl_FragColor = vec4(col, 1.0);
  }
}
`;


////////////////////////////////////////////////////////////////////////////////
// EXTRA CREDIT: change DEF_INPUT to create something interesting!
////////////////////////////////////////////////////////////////////////////////
const DEF_INPUT = [
  "c,myCamera,perspective,0,0,8,0,0,0,0,1,0;",
  "l,myLight,point,0,5,0,1,1,1;",
  "p,head,cube;",
  "m,steve,1,1,1,0,0.7,0,1,1,1,15,minecraftHead.jpg;",
  "o,sh,head,steve;",
  "X,sh,Ry,0;",
  "X,sh,Rx,0;",
  "X,sh,Rz,0;",
  "X,sh,S,0.5,0.5,0.5;",
  "X,sh,T,0,1,0;",
  "p,shirt,cube;",
  "m,shirtM,0.019686,0.68235,0.68235,0,0.7,0,1,1,1,15;",
  "o,shirtO,shirt,shirtM;",
  "X,shirtO,S,0.5,0.5,0.5;",
  "X,shirtO,Ry,0;",
  "X,shirtO,Rx,0;",
  "X,shirtO,Rz,0;",
  "X,shirtO,T,0,0,0;",
  "p,lSleeve,cube;",
  "m,sleeveM,0.68235,0.4784,0.4039,0,0.7,0,1,1,1,15;",
  "o,lSleeveO,lSleeve,sleeveM;",
  "X,lSleeveO,S,0.125,0.5,0.25;",
  "X,lSleeveO,Ry,0;",
  "X,lSleeveO,Rx,10;",
  "X,lSleeveO,Rz,0;",
  "X,lSleeveO,T,0.63,0,0;",
  "p,rSleeve,cube;",
  "o,rSleeveO,rSleeve,sleeveM;",
  "X,rSleeveO,S,0.125,0.5,0.25;",
  "X,rSleeveO,Ry,0;",
  "X,rSleeveO,Rx,-10;",
  "X,rSleeveO,Rz,0;",
  "X,rSleeveO,T,-0.63,0,0;",

  "p,pants,cube;",
  "m,pantsM,0.1578,0.0725,0.6098,0,0.7,0,1,1,1,15;",
  "o,lPantsO,pants,pantsM;",
  "X,lPantsO,S,0.25,0.7,0.25;",
  "X,lPantsO,Ry,0;",
  "X,lPantsO,Rx,2;",
  "X,lPantsO,Rz,0;",
  "X,lPantsO,T,-0.25,-1,0;",
  
  "o,rPantsO,pants,pantsM;",
  "X,rPantsO,S,0.25,0.7,0.25;",
  "X,rPantsO,Ry,0;",
  "X,rPantsO,Rx,-20;",
  "X,rPantsO,Rz,0;",
  "X,rPantsO,T,0.25,-1,0;",
  
  "p,grass,cube;",
  "m,grassM,1,1,1,0,0.7,0,1,1,1,15,grassBrick.jpg;",
  "o,grassO,grass,grassM;",
  "X,grassO,S,0.8,0.8,0.8;",
  "X,grassO,Ry,0;",
  "X,grassO,Rx,0;",
  "X,grassO,Rz,0;",
  "X,grassO,T,0,-2.6,0;",
].join("\n");

// DO NOT CHANGE ANYTHING BELOW HERE
export { Parser, Scene, Renderer, DEF_INPUT };
