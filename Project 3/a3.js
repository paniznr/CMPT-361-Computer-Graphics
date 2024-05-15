import { Framebuffer } from './framebuffer.js';
import { Rasterizer } from './rasterizer.js';
// DO NOT CHANGE ANYTHING ABOVE HERE

////////////////////////////////////////////////////////////////////////////////
// TODO: Implement functions drawLine(v1, v2) and drawTriangle(v1, v2, v3) below.
////////////////////////////////////////////////////////////////////////////////

// take two vertices defining line and rasterize to framebuffer
Rasterizer.prototype.drawLine = function(v1, v2) {
  const [x1, y1, [r1, g1, b1]] = v1;
  const [x2, y2, [r2, g2, b2]] = v2;
  let line = [];
  //Edge case: v1 == v2
  if (x1 == x2 && y1 == y2) {
    this.setPixel(x1, y1, [r1, g1, b1]);
    return;
  }
  //Edge case: dividing by inf for vertical lines
  if (x1 == x2) {
    let head = v1;
    let tail = v2;
    if (y1 > y2) {
      head = v2;
      tail = v1;
    }
    let min = Math.min(y1, y2);
    let max = Math.max(y1, y2);
    for (let i = min; i<= max; i++) {
      let t =  (i - head[1]) / Math.sqrt(Math.pow(tail[0] - head[0], 2) + Math.pow(tail[1] - head[1], 2));
      let startClr = head;
      let endClr = tail;

      let cpR = (1-t)*startClr[2][0] + t*endClr[2][0];
      let cpG = (1-t)*startClr[2][1] + t*endClr[2][1];
      let cpB = (1-t)*startClr[2][2] + t*endClr[2][2];  
      this.setPixel(x1, i, [cpR, cpG, cpB]);
      line[i - min] = [x1, i];
    }
    return line;
  }
  let m = (y2 - y1)/(x2 - x1);
  let head = Math.min(x1, x2);
  let tail = Math.max(x1, x2);
  let oppHead = y1;
  let oppTail = y2;
  let switched = false;
  if (x1 > x2) {
    oppHead = y2;
    oppTail = y1;
    switched = true;
  }
  let steepSlope = false; //Identifier for whether we have to switch logic for the for loop

  //Steeper slopes: invert x and y
  if (m > 1 || m < -1) {
    head = Math.min(y1, y2);
    tail = Math.max(y1, y2);
    oppHead = x1;
    oppTail = x2;
    switched = false;
    if (y1 > y2) {
      oppHead = x2;
      oppTail = x1;
      switched = true;
    }
    m = (x2 - x1)/(y2 - y1);
    steepSlope = true;
  }

  let startClr = v1;
  let endClr = v2;
  if (switched) {
    startClr = v2;
    endClr = v1;
  }
  let moving = oppHead;
  for (let i = head;  i <= tail; i++) {
    let t =  Math.sqrt(Math.pow(i - head, 2) + Math.pow(moving - oppHead, 2)) / Math.sqrt(Math.pow(tail - head, 2) + Math.pow(oppTail - oppHead, 2));
    let cpR = (1-t)*startClr[2][0] + t*endClr[2][0];
    let cpG = (1-t)*startClr[2][1] + t*endClr[2][1];
    let cpB = (1-t)*startClr[2][2] + t*endClr[2][2];
   
    if (!steepSlope) {
      this.setPixel(i, Math.round(moving), [cpR, cpG, cpB]);      
      line[i- head] = [i, Math.round(moving)];
    } else {
      this.setPixel(Math.round(moving), i, [cpR, cpG, cpB]);
      line[i - head] = [Math.round(moving), i];
    }
    moving += m;
  }
  return line;
}

// take 3 vertices defining a solid triangle and rasterize to framebuffer
Rasterizer.prototype.drawTriangle = function(v1, v2, v3) {
  const [x1, y1, [r1, g1, b1]] = v1;
  const [x2, y2, [r2, g2, b2]] = v2;
  const [x3, y3, [r3, g3, b3]] = v3;

  //-------------------ESTABLISH POTENTIAL TOP EDGE AND LEFT EDGES FOR EDGE CASE
  let orderY = order(v1, v2, v3, 1); //1 -> y coordinates
  const ccwOrder = [];
  //Start CCW ordering from the highest coordinate
  ccwOrder[0] = orderY[0];
  let topEdgeExists = false;
  let topEdge = [];
  let leftEdge = [];
  if (orderY[0][1] == orderY[1][1]) { //horizontal line
    topEdgeExists = true;
    topEdge = [orderY[0], orderY[1]];

    //for Left edge: now order from left to right
    if (orderY[1][0] < orderY[2][0]) { //orderY[1] is on the left
      ccwOrder[1] = orderY[1];
      ccwOrder[2] = orderY[2];
    } else {
      ccwOrder[1] = orderY[2];
      ccwOrder[2] = orderY[1];
    }
  } else { //there isn't a horizontal line
    if (orderY[1][0] < orderY[2][0]) {
      ccwOrder[1] = orderY[1];
      ccwOrder[2] = orderY[2];
    } else {
      ccwOrder[1] = orderY[2];
      ccwOrder[2] = orderY[1];
    }
  }
  //now that edges are in CCW order, for each line check if end point is strictly lower than starting point
  for (let j = 0; j < 3; j++) { //loop through all 3 lines in order
    leftEdge[j] = false;
    if (ccwOrder[j%3][1] < ccwOrder[(j + 1)%3][1]) { 
      leftEdge[j] = true;
    }
  }
  //------------------------------------------------------------------
  //Draw triangle edges using drawLine
  //Ordering lines to be in CCW 
  const line1 = this.drawLine(ccwOrder[0], ccwOrder[1]);
  const line2 = this.drawLine(ccwOrder[1], ccwOrder[2]);
  const line3 = this.drawLine(ccwOrder[2], ccwOrder[0]);
  const lines = [line1, line2, line3];

  //Create a rectangle around the triangle to look for points that could be inside
  let xMin = Math.min(ccwOrder[0][0], ccwOrder[1][0], ccwOrder[2][0]);
  let xMax = Math.max(ccwOrder[0][0], ccwOrder[1][0], ccwOrder[2][0]);
  let yMin = Math.min(ccwOrder[0][1], ccwOrder[1][1], ccwOrder[2][1]);
  let yMax = Math.max(ccwOrder[0][1], ccwOrder[1][1], ccwOrder[2][1]);

  let pointInsideCheck = false;
  for (let i = xMin; i < xMax; i++) {
    for (let j = yMin; j < yMax; j++) {
      //Fill triangle in using pointIsInsideTriangle
      let p = [i, j];
      pointInsideCheck = pointIsInsideTriangle(v1, v2, v3, p, lines, ccwOrder, topEdgeExists, topEdge, leftEdge);
      if (pointInsideCheck) {
        let c = this.barycentricCoord(p, v1, v2, v3);
        this.setPixel(i, j, [c[0], c[1], c[2]]);
      }
      
    }
  }  
}

function pointIsInsideTriangle(v1, v2, v3, p, lines, ccwOrder, topEdgeExists, topEdge, leftEdge) {
  //for each of the 3 lines, check if point is inside

  let check = 0; //Counts if a point passed half-plane test for all 3 planes
  for (let i = 0; i<3; i++) {
    let x0 = ccwOrder[i%3][0];
    let x1 = ccwOrder[(i + 1)%3][0];
    let y0 = ccwOrder[i%3][1];
    let y1 = ccwOrder[(i + 1)%3][1];

    //set coefficients
    let a = y1 - y0;
    let b = x0 - x1;
    let c = x1*y0 - x0*y1;
    let f = a*p[0] + b*p[1] + c;

    if (f > 0) {
      check++;
    } else if (f == 0) { //Edge case: on the edge lines
      if (topEdgeExists) {
        if ((p[1] == topEdge[0][1]) && (p[0] <= Math.max(topEdge[0][0], topEdge[1][0])) && (p[1] >= Math.min(topEdge[0][0], topEdge[1][0]))) {
          return true; 
        }
      } 
      
      //check if the line is a left edge
      if (leftEdge[i]) {
        for (let j = 0; j < lines[i].length; j++) {
          if ((p[0] == lines[i][j][0]) && (p[1] == lines[i][j][1])) {
            return true;
          } 
        }
      }
     return true;
    }
  }
  if (check == 3) {
    return true;
  } else {
    return false;
  }
}
//Ordering vertices from largest to smallest based on either x or y coordinates
function order(a, b, c, coord) {
  let array = [a, b, c];
  if (array[0][coord] > array[1][coord]) {
    array = swap(array, 0, 1);
  } 
  if (array[0][coord] > array[2][coord]) {
    array = swap(array, 0,2);
  }
  if (array[1][coord] > array[2][coord]) {
    array = swap(array, 1,2);
  }
  return array;
}

function swap(array, a, b) {
  let temp = array[a];
  array[a] = array[b];
  array[b] = temp;
  return array;
}


Rasterizer.prototype.barycentricCoord = function(p, v1, v2, v3) {
  let colour = [];
  const [x1, y1, [r1, g1, b1]] = v1;
  const [x2, y2, [r2, g2, b2]] = v2;
  const [x3, y3, [r3, g3, b3]] = v3;
  const vArray = [v1, v2, v3];
  //area of triangle = 0.5 area of parallelogram
  let a = [];

  a[0] = Math.abs((v2[0] - p[0])*(v3[1] - p[1]) - (v2[1] - p[1])*(v3[0] - p[0]));
  a[1] = Math.abs((v3[0] - p[0])*(v1[1] - p[1]) - (v3[1] - p[1])*(v1[0] - p[0]));
  a[2] = Math.abs((v1[0] - p[0])*(v2[1] - p[1]) - (v1[1] - p[1])*(v2[0] - p[0]));

  let A = a[0] + a[1] + a[2];
  let u = a[0]/A;
  let v = a[1]/A;
  let w = a[2]/A;
  //u + v + w = 1;
  colour[0] = u*v1[2][0] + v*v2[2][0] + w*v3[2][0];
  colour[1] = u*v1[2][1] + v*v2[2][1] + w*v3[2][1];
  colour[2] = u*v1[2][2] + v*v2[2][2] + w*v3[2][2];

  return colour;
}


////////////////////////////////////////////////////////////////////////////////
// EXTRA CREDIT: change DEF_INPUT to create something interesting!
////////////////////////////////////////////////////////////////////////////////
const DEF_INPUT = [ //picture of skyline and mountains
  "v,0,0,0.5,0.7,0.99;",
"v,63,0,0.5,0.7,0.99;",
"v,0,50,0.988,0.4,0.753;",
"v,63,50,0.988,0.4,0.753;",

"t,0,1,2;",
"t,1,2,3;",

"v,10,26,0.1,0.1,0.2;",
"v,0,45,0.0,0.1,0.0;",
"v,30,45,0.0,0.1,0.0;",
"t,4,5,6;",

"v,50,24,0.5,0.5,0.7;",
"v,30,45,0.0,0.1,0.0;",
"v,63,45,0.0,0.1,0.0;",
"t,7,8,9;",

"v,20,28,0.2,0.2,0.3;",
"v,4,45,0.1,0.1,0.2;",
"v,37,45,0.1,0.1,0.2;",
"t,10,11,12;",

"v,36,34,0.3,0.3,0.3;",
"v,14,45,0.1,0.1,0.2;",
"v,63,45,0.1,0.1,0.2;",
"t,13,14,15;",

"v,63,33,0.3,0.3,0.3;",
"v,55,45,0.1,0.1,0.2;",
"v,63,45,0.1,0.1,0.2;",
"t,16,17,18;",

"v,0,37,0.3,0.3,0.3;",
"v,0,45,0.1,0.1,0.2;",
"v,15,45,0.1,0.1,0.2;",
"t,19,20,21;",

"v,0,45,0.1,0.1,0.2;",
"v,63,45,0.1,0.1,0.2;",
"v,0,63,0.0,0.0,0.0;",
"v,63,63,0.0,0.0,0.0;",
"t,22,23,24;",
"t,23,24,25;",

"v,10,35,0.1,0.5,0.6;",
"v,14,35,0.1,0.5,0.6;",
"v,10,63,0.2,0.2,0.7;",
"v,14,63,0.2,0.2,0.7;",
"t,26,27,28;",
"t,27,28,29;",

"v,45,40,0.1,0.5,0.6;",
"v,55,40,0.1,0.5,0.6;",
"v,45,63,0.2,0.2,0.7;",
"v,55,63,0.2,0.2,0.7;",
"t,30,31,32;",
"t,31,32,33;",

"v,50,47,0.1,0.5,0.6;",
"v,63,47,0.1,0.5,0.6;",
"v,50,63,0.2,0.2,0.7;",
"v,63,63,0.2,0.2,0.7;",
"t,34,35,36;",
"t,35,36,37;",


"v,0,42,0.1,0.5,0.6;",
"v,10,42,0.1,0.5,0.6;",
"v,0,63,0.2,0.2,0.7;",
"v,10,63,0.2,0.2,0.7;",
"t,38,39,40;",
"t,39,40,41;",

"v,30,28,0.1,0.5,0.6;",
"v,34,30,0.1,0.5,0.6;",
"v,30,63,0.2,0.2,0.7;",
"v,34,63,0.2,0.2,0.7;",
"t,42,43,44;",
"t,43,44,45;",

"v,60,42,0.1,0.5,0.6;",
"v,60,47,0.1,0.5,0.6;",
"l,46,47;",

"v,18,50,0.1,0.5,0.6;",
"v,50,50,0.1,0.5,0.6;",
"v,18,63,0.2,0.2,0.7;",
"v,50,63,0.2,0.2,0.7;",
"t,48,49,50;",
"t,49,50,51;",

"v,50,34,0.1,0.4,0.5;",
"t,30,31,52;",

"v,20,45,0.1,0.5,0.6;",
"v,27,45,0.1,0.5,0.6;",
"v,20,63,0.2,0.2,0.7;",
"v,27,63,0.2,0.2,0.7;",
"t,53,54,55;",
"t,54,55,56;"
  /*"v,10,10,1.0,0.0,0.0;",
  "v,52,52,0.0,1.0,0.0;",
  "v,52,10,0.0,0.0,1.0;",
  "v,10,52,1.0,1.0,1.0;",
  "t,0,1,3;",
  "t,0,1,2;",
  "t,0,3,1;",
  "v,10,10,1.0,1.0,1.0;",
  "v,10,52,0.0,0.0,0.0;",
  "v,52,52,1.0,1.0,1.0;",
  "v,52,10,0.0,0.0,0.0;",
  "l,4,5;",
  "l,5,6;",
  "l,6,7;",
  "l,7,4;"*/
].join("\n");


// DO NOT CHANGE ANYTHING BELOW HERE
export { Rasterizer, Framebuffer, DEF_INPUT };
