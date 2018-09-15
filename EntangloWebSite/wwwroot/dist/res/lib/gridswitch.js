/* DATABASE DESIGN INTERFACE */

  // var stats = new Stats();
  // stats.showPanel(0);
  // document.body.appendChild( stats.dom );

  var camera, scene, renderer;
  var geometry, material, mesh, lines, cube;
  var raycaster, mouse;
  var currDragObj;
  var addedObj = [];

  var grid = [];
  var savedTables = [];
  var removedTables = [];
  var cell = {
        place: 0,
        type: "",
        posx: 0, posy: 0, posz: 0,
        rotx: 0, roty: 0, rotz: 0,
        scax: 0, scay: 0, scaz: 0
      }

  var data;
  var keys;
  var childKeys;

  //var listStartX = (window.innerWidth / 2) - 10;
  var listStartX = (window.innerWidth / 5) * 2;
  var listStartY = (window.innerHeight / 2);
  var listSpacing = 100;

  var oldX = 0, oldY = 0;

  var rotationV = 0;
  var halfWindowWidth = window.innerWidth / 2;
  var halfWindowHeight = window.innerHeight / 2;
  var quarterObjectWidth = 0;
  var halfObjectWidth = 0;
  var objectWidth = 0;
  var savedTableSpace = 0;

  var savedObjWidth = 0;
  var savedStartX = 0;
  var savedStartY = 0;
  var tableSaved = false;
  var savedTableCount = 0;

  var removedStartX = 0;
  var removedStartY = 0;
  var tableRemoved = false;
  var removedTableCount = 0;

  var right = false, left = false, up = false, down = false;
  var xDirection = '';
  var yDirection = '';

  var bodyElement = document.querySelector("body");
  bodyElement.addEventListener("mousemove", getMouseDirection, false);
  bodyElement.addEventListener('touchmove', getTouchDirection, false);

  var intersectsObj;
  var intersectsText;
  var isDragging = false;
  var isTableDragging = false;
  var resetTable = false;

  var tableRetrieve = false;

  //var newColumns = false;

  var objects = [];
  var tableObj;
  var tempSavedObjects = [];

  var gravity = 0;
  var impact = false;
  var tableScale = 0.0;

  var labelList;
  var labelIndex;

  var originalColors = [];
  //var tableColors = [ 0x003333, 0x004d4d, 0x006666, 0x008080, 0x009999, 0x00B3B3, 0X00CCCC, 0X00E6E6, 0X00FFFF, 0X1AFFFF ];
  var tableColors = [ 0x003333, 0x004D4D, 0x4D0000, 0x660000 ];

  //var table;

  init();
  animate();

  function init() {

      container = document.createElement( 'div' );
      document.body.appendChild( container );
      camera = new THREE.PerspectiveCamera( 70, window.innerWidth / window.innerHeight, 1, 10000 );
      camera.position.z = 1000;
      controls = new THREE.TrackballControls( camera );
      controls.rotateSpeed = 1.0;
      controls.zoomSpeed = 1.2;
      controls.panSpeed = 0.8;
      controls.noZoom = false;
      controls.noPan = false;
      controls.staticMoving = true;
      controls.dynamicDampingFactor = 0.3;
      scene = new THREE.Scene();
      scene.background = new THREE.Color( 0x000000 );
      scene.add( new THREE.AmbientLight( 0x505050 ) );
      var light = new THREE.SpotLight( 0xffffff, 1.5 );
      light.position.set( 0, 500, 2000 );
      light.castShadow = true;
      light.shadow = new THREE.LightShadow( new THREE.PerspectiveCamera( 50, 1, 200, 10000 ) );
      light.shadow.bias = - 0.00022;
      light.shadow.mapSize.width = 2048;
      light.shadow.mapSize.height = 2048;
      scene.add( light );

      // PARAMETERS: radiusAtTop, radiusAtBottom, height, segmentsAroundRadius, segmentsAlongHeight
      // geometry = new THREE.CylinderGeometry(100,100,30,6,4);

      raycaster = new THREE.Raycaster();
      mouse = new THREE.Vector2();

      // BUILD TEST DATA OBJECT
      buildDataBlock();
      keys = Object.keys(data);


      // textMaterial = new THREE.MeshPhongMaterial( { color: 0xFFFFFF, flatShading: true } );

      buildDataObjects(10);

      // CUBES
      renderer = new THREE.WebGLRenderer( { antialias: true } );
      renderer.setPixelRatio( window.devicePixelRatio );
      renderer.setSize( window.innerWidth, window.innerHeight );

      //renderer.shadowMap.enabled = true;
      //renderer.shadowMap.type = THREE.PCFShadowMap;
      container.appendChild( renderer.domElement );

      var dragControls = new THREE.DragControls( objects, camera, renderer.domElement );
      //dragControls = new THREE.DragControls( tableObj, camera, renderer.domElement );
      //dragControls.addEventListener( 'dragstart', function ( event ) { controls.enabled = false; } );
      //dragControls.addEventListener( 'dragend', function ( event ) { controls.enabled = true; } );

      window.addEventListener( 'resize', onWindowResize, false );

      document.addEventListener( 'mousedown', onDocumentMouseDown, false );
      document.addEventListener( 'touchstart', onDocumentTouchStart, false );
      document.addEventListener( 'touchmove', onDocumentTouchMove, false );
      document.addEventListener( 'mousemove', onDocumentMouseMove, false );
      document.addEventListener( 'touchend', onDocumentTouchEnd, false );
      document.addEventListener( 'mouseup', onDocumentMouseUp, false );

      // change
      halfObjectWidth = 100;//geometry.parameters.radiusTop;
      quarterObjectWidth = halfObjectWidth / 2;
      objectWidth = halfObjectWidth * 2;
      rotationV = (halfWindowWidth / objectWidth) / 100;

      savedObjWidth = objectWidth;
      // savedStartX = -(window.innerWidth / 2) - savedObjWidth;
      savedStartX = -(window.innerWidth / 5) * 3;
      savedStartY = (window.innerHeight / 2) + halfObjectWidth;
      savedTableSpace = halfObjectWidth / 4;

      removedStartX = savedStartX;
      removedStartY = -(window.innerHeight / 2) - halfObjectWidth;

      // BUILD DATA GRID FOR POSITIONING DATA BLOCKS
      buildDataGrid();

      // BUILD SAVED TABLE GRID FOR POSITIONING UPPER TABLE BLOCKS
      buildSavedGrid();

      // BUILD REMOVED TABLE GRID FOR POSITIONING LOWER TABLE BLOCKS
      buildRemovedGrid();


  }

  function buildDataObjects(quantity) {

      var fontLoader = new THREE.FontLoader();

      fontLoader.load( 'dist/res/lib/fonts/helvetiker_regular.typeface.json', function ( font ) {

          for ( var i = 0; i < quantity; i ++ ) {

              var geometry = new THREE.CylinderGeometry(100,100,30,6,4);

              var object = new THREE.Mesh( geometry, new THREE.MeshLambertMaterial( { color: 0xFFFFFF } ) );

              object.material.linewidth = 2;

              // Add extra x, y, z cordinates attributes for saving objects original location
              object.position.x = object.xcord = listStartX;
              object.position.y = object.ycord = listStartY - (listSpacing * i);
              object.position.z = object.zcord = 0;

              object.castShadow = true;
              object.receiveShadow = true;

              object.num = (i + 1).toString(); // Add incrementing number to each object
              object.type = '';
              object.place = 0;
              object.name = keys[i];
              object.gravity = 0;

              originalColors.push(0xFFFFFF);

              var textMaterial = new THREE.MeshPhongMaterial( { color: 0xFFFFFF, flatShading: true } );

              // MAIN DATA TITLE
              var dataText = new THREE.TextGeometry(keys[i], {
                  font: font,
                  size: 15,
                  height: 10,
                  curveSegments: 4,
                  bevelThickness: 1,
                  bevelSize: 0.5,
                  bevelEnabled: true,
                  bevelSegments: 5
              });
              //
              // let dataText = new THREE.TextSprite({
              //     textSize: 10,
              //     texture: {
              //         text: keys[i],
              //         fontFamily: 'Arial, Helvetica, sans-serif',
              //     },
              //     material: {color: 0xffbbff},
              // });
              // scene.add(dataText);

              // ABBREVIATED DATA TITLE
              var abbr = new THREE.TextGeometry( abbreviate(keys[i].toString(), 8), {
                  font: font,
                  size: 15,
                  height: 10,
                  curveSegments: 4,
                  bevelThickness: 1,
                  bevelSize: 0.5,
                  bevelEnabled: true,
                  bevelSegments: 5
              });
              // let abbr = new THREE.TextSprite({
              //     textSize: 10,
              //     texture: {
              //         text: abbreviate(keys[i].toString()),
              //         fontFamily: 'Arial, Helvetica, sans-serif',
              //     },
              //     material: {color: 0xffbbff},
              // });
              // scene.add(abbr);

              // TITLE
              var textMesh = new THREE.Mesh( dataText, textMaterial );
              // ABBREVIATED
              var abbrMesh = new THREE.Mesh( abbr, textMaterial );

              textMesh.position.x = object.xcord + halfObjectWidth * 1.5;
              textMesh.position.y = object.ycord;
              textMesh.position.z = object.zcord;
              textMesh.rotation.y = -0.5;
              textMesh.name = object.name;  // Assign table name to each column title/abbr for easy referencing
              textMesh.num = i.toString();

              scene.add( textMesh );

              abbrMesh.scale.set( 2, 2, 2 );
              abbrMesh.visible = false;
              abbrMesh.name = object.name;
              abbrMesh.num = i.toString();

              scene.add( abbrMesh );

              object.title = textMesh;
              object.abbr = abbrMesh;

              // object.title = dataText;
              // object.abbr = abbr;

              scene.add( object );

              objects.push( object );
          }
      });
  }

  function disposeObjectsFromScene(objects) {

      objects.forEach(function(object) {

          scene.remove( object.abbr );
          scene.remove( object.title );
          scene.remove( object );
          //object.abbr.dispose();
          object.abbr.geometry.dispose();
          object.abbr.material.dispose();
          object.abbr.remove();
          //object.title.dispose();
          object.title.geometry.dispose();
          object.title.material.dispose();
          object.title.remove();

          object.geometry.dispose();
          object.material.dispose();
          object.remove();
      });
  }

  function addObjectsToScene(objects) {

      objects.forEach(function(object) {

          scene.add( object.abbr );
          scene.add( object.title );
          scene.add( object );

      });
  }

  function cloneObjectArray(objects) {

      cloneObjects = [];
      for (var i = 0; i < objects.length; i++) {

          cloneObjects.push(objects[i].clone())
          cloneObjects[i].title = objects[i].title.clone();
          cloneObjects[i].abbr = objects[i].abbr.clone();

          cloneObjects[i].gravity = objects[i].gravity;
          cloneObjects[i].num = objects[i].num;
          cloneObjects[i].place = objects[i].place;
          cloneObjects[i].type = objects[i].type;
          cloneObjects[i].xcord = objects[i].xcord;
          cloneObjects[i].ycord = objects[i].ycord;
          cloneObjects[i].zcord = objects[i].zcord;

      }

      return cloneObjects;
  }

  function cloneObject(object) {

      newObject = object.clone();

      newObject.title = object.title.clone();
      newObject.abbr = object.abbr.clone();

      newObject.gravity = object.gravity;
      newObject.num = object.num;
      newObject.place = object.place;
      newObject.type = object.type;
      newObject.xcord = object.xcord;
      newObject.ycord = object.ycord;
      newObject.zcord = object.zcord;

      return newObject;
  }

  function removeObjectsFromScene(objects) {

      objects.forEach(function(object) {

          scene.remove( object.abbr );

          scene.remove( object.title );

          scene.remove( object );

      });

      objects.length = 0;
  }

  function saveTableToDatabase(savedTableObj) {

      setTableToRow(savedTableObj, true);

  }

  function removeTableFromDatabase(removedTableObj) {

      setTableToRow(removedTableObj, false);

  }

  function setTableToRow(tableObj, saved) {

      for (var k = 0; k < objects.length; k++) {

          if (tableObj.objects[k].place == 0) {

              tableObj.objects[k].scale.set(1, 1, 1);
              tableObj.objects[k].abbr.scale.set(2.5, 2.5, 2.5);

              tableObj.objects[k].position.x = tableObj.posx;
              tableObj.objects[k].position.y = tableObj.posy;

              tableObj.objects[k].abbr.rotation.y = 0;
              tableObj.objects[k].abbr.visible = true;

              setTableStatus(tableObj.objects[k], saved);

              centerObjects(tableObj.objects[k], tableObj.objects[k].abbr);

              scene.add(tableObj.objects[k]);
              scene.add(tableObj.objects[k].abbr);

              break;
          }
      }

  }

  function setTableStatus(object, saved) {

      if (saved) {
          if (object.hasOwnProperty("removed")) {
              delete object.removed;
          }
          object.saved = true;
      } else {
          if (object.hasOwnProperty("saved")) {
              delete object.saved;
          }
          object.removed = true;
      }
  }

  function getIndexOfTable(tables) {

      var index = 0;

      for (var i = 0; i < tables.length; i++) {

          if (tables[i].tableUuid == currDragObj.uuid) {
              index = i;
              break;
          }
      }
      return index;
  }

  function repositionTables(tables) {
      //console.log("repositioning tables");
      for (var i = 1; i < tables.length; i++) {
          if (tables[i + 1].objects.length > 0) {
              if (!tables[i].placed) {
                  tables[i].objects = tables[i + 1].objects;
                  tables[i].placed = true;
                  tables[i].tableUuid = tables[i + 1].tableUuid;
                  tables[i + 1].objects = [];
                  tables[i + 1].placed = false;
                  tables[i + 1].tableUuid = "";
                  tables[i].objects[0].position.x = tables[i].posx;
                  tables[i].objects[0].position.y = tables[i].posy;
                  shadowTitle(tables[i].objects[0], 'left');
              }
          }

          // Break from loop if all objects have been repositioned
          if (!tables[i + 1].placed && !tables[i + 2].placed) {
              break;
          }
      }
  }

  function abbreviate(chars, n){
      // return (chars.length > n) ? chars.substr(0, n-3) + '...' : chars;
      return (chars.length > n) ? chars.substr(0, n-1) : chars;
  };

  function convertObjectsToJson(table) {

      // Add main table object array attributes
      var jsonTable = '{ "main" : {' +
                              ' "place" : "' + table.place + '",' +
                              ' "posx" : "' + table.posx + '",' +
                              ' "posy" : "' + table.posy + '",' +
                              ' "tableUuid" : "' + table.tableUuid + '" },';

      var colCount = 0;       // Column counter

      // Add attributes to each object
      table.objects.forEach(function(object) {
          // Add table specific attributes
          if (object.type == 'table') {
              // Table specific attributes
              jsonTable += '"table" : {' +
                                      ' "name" : "' + object.name + '",' +
                                      ' "place" : "' + object.place + '",' +
                                      ' "positionx" : "' + object.position.x + '",' +
                                      ' "positiony" : "' + object.position.y + '",' +
                                      ' "xcord" : "' + object.xcord + '",' +
                                      ' "ycord" : "' + object.ycord + '",' +
                                      ' "abbr" : "' + object.abbr.name + '" },';

              // Columns header
              jsonTable += '"columns" : { ';  // Added here as this block is entered only once
          }
          else {
              // Add each column specific attributes
              jsonTable += '"column' + colCount + '" : {' +
                                      ' "name" : "' + object.name + '",' +
                                      ' "place" : "' + object.place + '",' +
                                      ' "positionx" : "' + object.position.x + '",' +
                                      ' "positiony" : "' + object.position.y + '",' +
                                      ' "xcord" : "' + object.xcord + '",' +
                                      ' "ycord" : "' + object.ycord + '",' +
                                      ' "abbr" : "' + object.abbr.name + '" },';
          }

          ++colCount;   // Increment column counter
      });

      // Add closing json tag
      jsonTable = jsonTable.substring(0, jsonTable.length - 1); // Remove last comma
      jsonTable += ' } }';

      console.log("Table Created");

      return jsonTable;
  }

  function saveTableToServer(table) {
      // Table sent to server status
      var tableSaved = false;
      // Table Payload POST settings
      var settings = {
              "async": true,
              "crossDomain": true,
              //"url": "https://entanglowebservice20180111094252.azurewebsites.net/Entanglo/Create/Table",
              "url": "https://localhost:44333/Entanglo/Create/Table",
              "method": "POST",
              "headers": {
                  "Content-Type": "application/json"
          },
              "processData": false,
              "data": "{\n\t\"DatabaseName\": \"entanglo.dev\",\n\t\"TableName\": \"tblName4\",\n\t\"TableColumns\": [\n\t\t{ \n\t\t\t\"DatabaseName\": \"entanglo.dev\",\n\t\t\t\"TableName\": \"tblName3\",\n\t\t\t\"ColumnName\": \"colName1\",\n\t\t\t\"ColumnDataType\": \"text\",\n\t\t\t\"ColumnSize\": \"50\",\n\t\t\t\"ColumnConstraint\": \"\",\n\t\t\t\"ColumnDefaultValue\": \"null\"\n\t\t},\n\t\t{\n\t\t\t\"DatabaseName\": \"entanglo.dev\",\n\t\t\t\"TableName\": \"tblName3\",\n\t\t\t\"ColumnName\": \"colName2\",\n\t\t\t\"ColumnDataType\": \"text\",\n\t\t\t\"ColumnSize\": \"50\",\n\t\t\t\"ColumnConstraint\": \"\",\n\t\t\t\"ColumnDefaultValue\": \"null\"\n\t\t}]\n}"
      }
      // Send table payload to server
      $.ajax(settings).done(function (response) {
          console.log(response);
          // Check response message from server
          if (response == 200) {
              tableSaved = true;  // If successful set table saved status
          }
      });

      // $.ajax({
      //     type: "POST",
      //     //url: "https://entanglowebservice20180111094252.azurewebsites.net/Entanglo/Create/Table",
      //     url: "https://localhost:44333/Entanglo/Create/Table",
      //     data: JSON.stringify({ Table: table }),
      //     contentType: "application/json; charset=utf-8",
      //     dataType: "json",
      //     success: function(data){ tablesSaved = true; alert(data); },
      //     failure: function(errMsg) {
      //         alert(errMsg);
      //     }
      // });

      return tableSaved;
  }

  function onWindowResize(){
      camera.aspect = window.innerWidth / window.innerHeight;
      camera.updateProjectionMatrix();
      renderer.setSize( window.innerWidth, window.innerHeight );
  }

  function onDocumentTouchStart( event ) {
      //event.preventDefault();
      //console.log('TOUCH START');

      event.clientX = event.touches[0].clientX;
      event.clientY = event.touches[0].clientY;

      onDocumentMouseDown( event );
  }

  function onDocumentTouchEnd( event ) {
      //event.preventDefault();
      //console.log('TOUCH END');

      onDocumentMouseUp( event );
  }

  function onDocumentMouseDown( event ) {
      //event.preventDefault();
      //console.log('MOUSE DOWN');

      // Get current mouse/touch coordinates
      mouse.x = ( event.clientX / renderer.domElement.clientWidth ) * 2 - 1;
      mouse.y = - ( event.clientY / renderer.domElement.clientHeight ) * 2 + 1;
      // Create a vector from the camera through to the mouse/touch position
      //var raycaster;
      raycaster.setFromCamera( mouse, camera );

      // Save the object and associated text/label that is selected
      intersectsObj = raycaster.intersectObjects( objects );
      // Check if a list object was selected
      if (intersectsObj.length < 1) {
          // If not
          if (tableObj != null) {
              intersectsObj = raycaster.intersectObject( tableObj );
          }
          else {  // change

              for (var i = 1; i < savedTables.length; i++) {
                  if (savedTables[i].objects.length > 0) {
                      //intersectsObj = [];

                      intersectsObj = raycaster.intersectObjects( savedTables[i].objects );

                      if (intersectsObj.length > 0) {

                          removeObjectsFromScene(objects);
                          objects = savedTables[i].objects;

                          objects.forEach(function(object) {
                              object.position.x = objects[0].position.x;
                              object.position.y = objects[0].position.y;
                          });

                          disposeObjectsFromScene(savedTables[i].objects);

                          tableSaved = true;

                          break;
                      }
                  }

                  if (removedTables[i].objects.length > 0) {
                      intersectsObj = raycaster.intersectObjects( removedTables[i].objects );

                      if (intersectsObj.length > 0) {

                          removeObjectsFromScene(objects);
                          objects = removedTables[i].objects;

                          objects.forEach(function(object) {
                              object.position.x = objects[0].position.x;
                              object.position.y = objects[0].position.y;
                          });

                          disposeObjectsFromScene(removedTables[i].objects);

                          tableRemoved = true;

                          break;
                      }
                  }
              }


              if (intersectsObj.length == 1) {
                  console.log(intersectsObj[0].object.name);
              }
              else if (intersectsObj.length > 1) {
                  console.log("-----------")
                  console.log(intersectsObj[0].object.name);
                  console.log(intersectsObj[1].object.name);
                  console.log("-----------")
              }

              // if (intersectsObj.length > 0) {
              //     currDragObj = intersectsObj[0].object;
              //     var index = getIndexOfTable(savedTables);
              //     addObjectsToScene(savedTables[index].objects);
              // }
              addObjectsToScene(objects);

              if (intersectsObj.length > 0) {
                  objects.forEach(function(object) {
                      if ((object.num == '0') || (object.place != 0)) {
                          addedObj.push(object.num);
                          grid[object.num].placed = true;
                      }
                      else {
                          object.position.x = object.xcord;
                          object.position.y = object.ycord;
                      }
                  });

                  if (objects[0].type == 'table') {
                      objects[0].scale.set(1.5, 1.5, 1.5);
                  }

                  isTableDragging = true;
              }
          }
      }


      // Check that an object is still selected
      if ( intersectsObj.length > 0 ) {
          currDragObj = intersectsObj[0].object;

          // currDragObj = cloneObject(intersectsObj[0].object);
          // intersectsObj = [];
          isDragging = true;
          // getLabelIndex();
          // Check if any other objects are added
          if (addedObj.length > 0) {
              // Loop through each added object
              for (var i = 0; i < addedObj.length; i++) {
                  // Check if the current selected object is already added
                  var found = $.inArray(currDragObj.num, addedObj);
                  if (found == -1) {  // Set colour of newly added (first time selected) object and text/label

                      addedObj.push(currDragObj.num); // Add selected object to list
                      //getLabelIndex(currDragObj);                // Get the objects title/abbr index for color coding

                      if (currDragObj.material.color.getHex() == 0xffffff) {
                          currDragObj.material.color.setHex( Math.random() * 0xffffff );
                          // Save objects original colour
                          originalColors[currDragObj.num] = currDragObj.material.color.getHex();
                          currDragObj.title.material.color.setHex( currDragObj.material.color.getHex() );
                      }

                      break;
                  }
              }
              // Check if the selected object is the table object (center)
              if (currDragObj.type == 'table') {
                  // Set table object colour
                  currDragObj.material.color.setHex(tableColors[0]);
                  // Set all other column objects colour
                  addedObj.forEach(function(obj){
                      if (objects[obj].type == 'column') {
                          // objects[obj].material.color.setHex(tableColors[obj]);
                          objects[obj].material.color.setHex(tableColors[1]);
                      }
                  });

                  // Remove all column text/labels
                  objects.forEach(function(obj){
                      obj.abbr.visible = false;
                  });

                  currDragObj.abbr.visible = true;
                  // Only turn table dragging on if at lease 1 column exists
                  if ( addedObj.length >= 1) { isTableDragging = true; }

              }
          }
          else {  // Set colour of first added object and text/label
              if (currDragObj.material.color.getHex() == 0xffffff) {
                  currDragObj.material.color.setHex( Math.random() * 0xffffff );
                  // Save objects original colour
                  originalColors[currDragObj.num] = currDragObj.material.color.getHex();
                  currDragObj.title.material.color.setHex( currDragObj.material.color.getHex() );
              }
              addedObj.push(currDragObj.num); // Add selected object to list
          }
      }
  }

  function onDocumentMouseUp( event ) {
      //event.preventDefault();
      //console.log('MOUSE UP');

      // Check if entire table is being dragged
      if (typeof currDragObj != "undefined") {

          if (isTableDragging) {
              clearGridPositions();
              repositionColumns();
              currDragObj = objects[0];
              // Loop through all objects in table
              addedObj.forEach(function(place){
                  // Set objects color back to original color
                  objects[place].material.color.setHex(originalColors[place]);
                  objects[place].abbr.visible = true;  // Make abbreviated title/label visible
                  // Set objects location back to original grid placement locations
                  objects[place].rotation.x = grid[objects[place].place].rotx;
                  objects[place].position.x = grid[objects[place].place].posx;
                  objects[place].position.y = grid[objects[place].place].posy;
                  objects[place].gravity = objects[place].place / 3; // Reset objects gravity increment
                  //objects[place].scale.set(1, 1, 1);
                  //objects[place].abbr.scale.set(2, 2, 2);
              });

              currDragObj.abbr.scale.set(2, 2, 2);  // Down scale title/label back to original size
              currDragObj.scale.set(1, 1, 1);       // Down scale table object back to original size
              shadowTitle(currDragObj, 'left');                  // Set all abbreviated titles/labels back to grid home positions

              //disposeObjectsFromScene()

              isTableDragging = false;              // Turn off table dragging
              impact = false;                       // Remove gravity impact
              tableScale = 0.0;
          }
          else if (resetTable) {
              // Reset grid placements
              // grid.forEach(function(place) {
              //     place.placed = false;
              // });
              clearGridPositions();
              // Remove all objects from added table list
              addedObj.length = 0;

              keys = Object.keys(data);

              if (currDragObj.type == 'table' && tableSaved) {
                  for (var i = 0; i < savedTables.length; i++) {
                      if (savedTables[i].tableUuid == currDragObj.uuid) {
                          removeObjectsFromScene(savedTables[i].objects);
                          savedTables[i].objects = [];
                          savedTables[i].placed = false;
                          savedTables[i].tableUuid = "";
                          break;
                      }
                  }
              }
              else if (currDragObj.type == 'table' && tableRemoved) {
                  for (var i = 0; i < removedTables.length; i++) {
                      if (removedTables[i].tableUuid == currDragObj.uuid) {
                          removeObjectsFromScene(removedTables[i].objects);
                          removedTables[i].objects = [];
                          removedTables[i].placed = false;
                          removedTables[i].tableUuid = "";
                          break;
                      }
                  }
              }
              else {
                  removeObjectsFromScene(objects);
              }

              //if (cloneObjects.length > 0) { removeObjectsFromScene(cloneObjects); cloneObjects = []; }

              buildDataObjects(keys.length);

              // Deactivate reset table flag
              resetTable = false;
              tableSaved = false;
              tableRemoved = false;
              currDragObj = null;
              tableObj = null;
          }
          else {  // Set object back to original color
              currDragObj.material.color.setHex(originalColors[currDragObj.num]);

              //change
              if ((currDragObj.type == 'table') && (addedObj.length == 1) && (tableObj == undefined)) {

                  keys = Object.values(data[currDragObj.name]);

                  objects.forEach(function(obj) {

                      if (obj.type == 'table') {

                          tableObj = obj.clone();
                          tableObj.material = obj.material.clone();
                          tableObj.title = obj.title.clone();
                          tableObj.title.material = obj.title.material.clone();
                          tableObj.abbr = obj.abbr.clone();
                          tableObj.abbr.material = obj.abbr.material.clone();

                          tableObj.gravity = obj.gravity;
                          tableObj.num = '0';//obj.num;
                          tableObj.place = obj.place;
                          tableObj.type = obj.type;

                          //tableObj.saved = false;

                          tableObj.xcord = obj.xcord;
                          tableObj.ycord = obj.ycord;
                          tableObj.zcord = obj.zcord;

                          scene.add(tableObj.title);
                          scene.add(tableObj.abbr);
                          scene.add(tableObj);

                      }

                      scene.remove(obj.title);
                      scene.remove(obj.abbr);
                      scene.remove(obj);
                  });

                  removeObjectsFromScene(objects);

                  buildDataObjects(keys.length);

                  objects.push(tableObj);

                  addedObj.length = 0;

                  addedObj.push(tableObj.num);
              }
          }
      }

      isDragging = false; // Turn off dragging
      oldX = 0; oldY = 0; // Reset previous dragged object position
      // Check if object is back in list after dragging stopped to remove from added list
      if ((currDragObj != "undefined") && (currDragObj != null)) {
          // change
          //Check if object has been dragged to grid
          if (currDragObj.position.x < halfObjectWidth) {
              // Check if it is a table object

          }
          //if ((currDragObj.position.x > halfWindowWidth - 11) && ) {// || (currDragObj.position.x < halfWindowWidth)) {
          if (((currDragObj.position.x > halfObjectWidth) &&
                  (currDragObj.position.x < halfWindowWidth - objectWidth)) ||
                      (currDragObj.position.x > listStartX - quarterObjectWidth)) { //halfWindowWidth - quarterObjectWidth)) {
              grid[currDragObj.place].placed = false;   // Open up grid place
              currDragObj.place = 0;                    // Set objects placement to 0
              currDragObj.type = "";                    // Reset object type
              removeObject(addedObj, currDragObj.num);  // Remove object from list
              currDragObj.abbr.visible = false;   // Hide abbrviated title/label

              // Reposition all objects after removal if at least 1 exists in grid
              if (addedObj.length > 0) {
                  // Reposition objects in grid
                  repositionColumns();
              }
          }
      }
  }

  function onDocumentTouchMove( event ) {
      //event.preventDefault();
      //console.log('TOUCH MOVE');

      event.clientX = event.touches[0].clientX;
      event.clientY = event.touches[0].clientY;

      onDocumentMouseMove( event );
  }

  function onDocumentMouseMove( event ) {
      //event.preventDefault();
      // Rotate current touched/dragged object
      if (typeof intersectsObj != "undefined") {
          if(typeof intersectsObj[0] != "undefined") {
              currDragObj = intersectsObj[0].object;

              // Direction 'left', 'right', 'up', 'down' comes from getTouchDirection/getMouseDirection event functions
              /*###############################################################################
                #                             TABLE DRAG                                      #
                ###############################################################################*/
              // Check if current dragged object is table object and at least 1 column exists
              if (currDragObj.type == 'table' && addedObj.length >= 1 && isTableDragging) {

                  // Loop through all objects added to grid
                  for (var i = 0; i < addedObj.length; i++) { // Set to
                      // Get the objects difference in position from main table object
                      var diffx = grid[objects[addedObj[i]].place].posx - grid[0].posx;
                      var diffy = grid[objects[addedObj[i]].place].posy - grid[0].posy;
                      // Set objects location relative to dragged table object
                      objects[addedObj[i]].position.x = currDragObj.position.x + diffx;
                      objects[addedObj[i]].position.y = currDragObj.position.y + diffy;
                  }

                  shadowTitle(currDragObj, 'up');

                  /*##################### TABLE DRAG RIGHT TO LIST #####################*/
                  // Check if table is dragged over to list location
                  if (currDragObj.position.x > halfWindowWidth - objectWidth) {
                      //isDragging = false;
                      isTableDragging = false;
                      resetTable = true;

                      objects.forEach(function(obj) {
                          obj.rotation.x = 0;
                          obj.rotation.y += 0.005;
                          obj.position.x = obj.xcord;
                          obj.position.y = obj.ycord;
                      });

                      currDragObj.scale.set(1, 1, 1);
                  }
                  // Check if table is dragged up to 'Save' table location (top)
                  /*##################### TABLE DRAG UP TO SAVE TABLE ROW #####################*/
                  else if (currDragObj.position.y > (halfWindowHeight + halfObjectWidth)) {

                      //setTableStatus(currDragObj, true);
                      var tableIndex = getIndexOfTable(removedTables);
                      removedTables[tableIndex].placed = false;

                      if (getIndexOfTable(savedTables) == 0) {
                          if (currDragObj.hasOwnProperty("saved")) { delete currDragObj.saved; }
                      }

                      for (var h = 1; h < objects.length; h++) {
                          if ((currDragObj.saved != undefined) && (currDragObj.saved)) {
                              if (savedTables[h].objects[0].uuid == currDragObj.uuid) {
                                  // cloneObjects = cloneObjectArray(objects);
                                  // disposeObjectsFromScene(savedTables[h].objects);
                                  // disposeObjectsFromScene(objects);
                                  // savedTables[h].objects.length = 0;
                                  // savedTables[h].placed = false;
                                  // objects = cloneObjectArray(cloneObjects);
                                  // disposeObjectsFromScene(cloneObjects);
                                  break;
                              }
                          }
                          else {
                              if (savedTables[h].placed == false ) {
                                  break;
                              }
                          }
                      }

                      currDragObj.scale.set(1, 1, 1);

                      savedTables[h].objects = cloneObjectArray(objects);

                      if (savedTables[h].placed == false) {
                          savedTables[h].placed = true;
                      }

                      savedTables[h].tableUuid = savedTables[h].objects[0].uuid;

                      saveTableToDatabase(savedTables[h]);

                      // Convert saved table to JSON
                      var jsonTable = convertObjectsToJson(savedTables[h]);
                      // Attempt to send table to server for saving
                      if (jsonTable != undefined) {
                          // Save table to server
                          var sentToServer = saveTableToServer(jsonTable);
                          // Check if table saved successfully to server
                          if (sentToServer) {
                              console.log("TABLE SENT TO SERVER SUCCESSFULLY!");
                          } else {
                              console.log("ERROR SENDING TABLE TO SERVER!");
                          }
                      }   // Table was not built into JSON successfully
                      else {
                          console.log("ERROR BUILDING TABLE INTO JSON!");
                      }

                      // tableSaved = true;

                      dragControls = new THREE.DragControls( savedTables[h].objects, camera, renderer.domElement );

                      isTableDragging = false;
                      resetTable = true;

                      removeObjectsFromScene(objects);

                      //clearGridPositions();
                      repositionTables(removedTables);
                  }
                  /*##################### TABLE DRAG UP TO SAVE #####################*/
                  // else if ((currDragObj.position.y > (halfWindowHeight / 3)) && (!tableRetrieve)) {
                  else if (currDragObj.position.y > (halfWindowHeight / 3)) {
                      for (var i = 0; i < addedObj.length; i++) {

                          if (objects[addedObj[i]].type == 'column') {

                              if (!impact) {

                                  applyGravity(currDragObj, addedObj[i]);
                                  //console.log('gravity applied');
                              }
                              else {
                                  objects[addedObj[i]].position.x = currDragObj.position.x;
                                  objects[addedObj[i]].position.y = currDragObj.position.y;
                                  // Place the abbreviated title/label based drag up or drag down
                                  if (currDragObj.position.y > 0) { // Drag up to SAVE table
                                      currDragObj.abbr.position.y = currDragObj.position.y - objectWidth;
                                  } else {                          // Drag down to REMOVE table
                                      currDragObj.abbr.position.y = currDragObj.position.y + halfObjectWidth;
                                  }
                                  // After gravity threshold, scale table object to larger size for save/remove placeholder
                                  tableScale += (0.2 / addedObj.length);
                                  if (tableScale < 0.5) {
                                      currDragObj.scale.set(1 + tableScale, 1 + tableScale, 1 + tableScale);
                                  }
                              }
                          }
                      }
                  }
                  // Check if table is dragged down to 'Remove' table location (bottom)
                  /*##################### TABLE DRAG DOWN TO REMOVE #####################*/
                  else if (currDragObj.position.y < -(halfWindowHeight + halfObjectWidth)) {

                      //if (!tableRemoved) {

                      //setTableStatus(currDragObj, false);
                      var tableIndex = getIndexOfTable(savedTables);
                      savedTables[tableIndex].placed = false;

                      if (getIndexOfTable(removedTables) == 0) {
                          if (currDragObj.hasOwnProperty("saved")) { delete currDragObj.saved; }
                      }

                      for (var h = 1; h < objects.length; h++) {
                          if ((currDragObj.saved != undefined) && (currDragObj.saved)) {
                              if (removedTables[h].objects[0].uuid == currDragObj.uuid) {
                                  // cloneObjects = cloneObjectArray(objects);
                                  // disposeObjectsFromScene(removedTables[h].objects);
                                  // disposeObjectsFromScene(objects);
                                  // removedTables[h].objects.length = 0;
                                  // removedTables[h].placed = false;
                                  // objects = cloneObjects;
                                  break;
                              }
                          }
                          else {
                              if (removedTables[h].placed == false ) {
                                  break;
                              }
                          }
                      }

                      currDragObj.scale.set(1, 1, 1);

                      removedTables[h].objects = cloneObjectArray(objects);

                      if (removedTables[h].placed == false) {
                          removedTables[h].placed = true;
                      }

                      removedTables[h].tableUuid = removedTables[h].objects[0].uuid;

                      removeTableFromDatabase(removedTables[h]);

                      //tableRemoved = true;

                      dragControls = new THREE.DragControls( removedTables[h].objects, camera, renderer.domElement );

                      isTableDragging = false;
                      resetTable = true;

                      removeObjectsFromScene(objects);

                      repositionTables(savedTables);
                  }
                  /*##################### TABLE DRAG DOWN TO REMOVE #####################*/
                  else if (currDragObj.position.y < -(halfWindowHeight / 3)) {

                      for (var i = 0; i < addedObj.length; i++) {

                          if (objects[addedObj[i]].type == 'table') {
                              objects[addedObj[i]].material.color.setHex(tableColors[2]);
                          }
                          else {
                          //if (objects[addedObj[i]].type == 'column') {
                              objects[addedObj[i]].material.color.setHex(tableColors[3]);

                              if (!impact) {

                                  applyGravity(currDragObj, addedObj[i]);
                              }
                              else {
                                  objects[addedObj[i]].position.x = currDragObj.position.x;
                                  objects[addedObj[i]].position.y = currDragObj.position.y;
                                  // Place the abbreviated title/label based drag up or drag down
                                  if (currDragObj.position.y > 0) { // Drag up to SAVE table
                                      currDragObj.abbr.position.y = currDragObj.position.y - objectWidth;
                                  } else {                          // Drag down to REMOVE table
                                      currDragObj.abbr.position.y = currDragObj.position.y + halfObjectWidth;
                                  }
                                  // After gravity threshold, scale table object to larger size for save/remove placeholder
                                  tableScale += (0.2 / addedObj.length);
                                  if (tableScale < 0.5) {
                                      currDragObj.scale.set(1 + tableScale, 1 + tableScale, 1 + tableScale);
                                  }
                              }
                          }
                      }
                  }
                  /*##################### TABLE DRAG DOWN TO GRID #####################*/
                  // Reset gravity if table dragged back down to initial grid placement
                  else if ((currDragObj.position.y < (halfWindowHeight / 2)) && (impact)) {
                      //gravity = 0.00;
                      //console.log('reset gravity (grid)');
                      // Loop through all objects in table
                      addedObj.forEach(function(place){
                          // Set objects gravity back to original gravity value
                          objects[place].gravity = objects[place].place / 3; // Reset objects gravity increment
                          // Set objects colour back to table SAVE colour
                          if (objects[place].type == 'table') {
                              objects[place].material.color.setHex(tableColors[0]);
                          } else {
                              objects[place].material.color.setHex(tableColors[1]);
                          }
                      });

                      // var tables = 0;
                      // savedTables.forEach(function(table) {
                      //     if (table.placed) { ++tables; }
                      // });
                      //
                      // if (tables > 1) {
                      //     for (var i = 1; i < tables + 1; i++) {
                      //         if (savedTables[i].placed && savedTables[i].tableUuid == currDragObj.uuid) {
                      //             var tempTable = savedTables[i].objects;
                      //             savedTables[i].objects = savedTables[i + 1].objects;
                      //             savedTables[i + 1].objects = tempTable;
                      //         }
                      //     }
                      // }

                      currDragObj.scale.set(1, 1, 1);
                      impact = false;
                      tableScale = 0.0;
                  }
              }
              /*##################### DRAG LEFT TO GRID #####################*/
              else if (left) {
                  if (currDragObj.rotation.x < 1.5) {
                      currDragObj.rotation.x += rotationV;
                  }

                  if (currDragObj.position.x < halfWindowWidth - objectWidth) {

                      if ((currDragObj.place == 0) && (currDragObj.type == '')) {
                          for (var i = 0; i < grid.length; i++) {
                              if (grid[i].placed == false) {
                                  repositionObject(currDragObj, i);
                                  currDragObj.type = grid[i].type;
                                  currDragObj.place = grid[i].place;
                                  grid[i].placed = true;
                                  currDragObj.gravity = 1.0; //currDragObj.place / 3;
                                  shadowTitle(currDragObj, 'left');
                                  break;
                              }
                          }

                          shadowTitle(currDragObj, 'left');
                          isDragging = false;
                      }
                      else {
                          if (currDragObj != undefined) {

                              repositionObject(currDragObj, currDragObj.place);
                              shadowTitle(currDragObj, 'left');
                          }
                      }
                  }
                  shadowTitle(currDragObj, 'left');
              }
              /*##################### DRAG RIGHT TO GRID #####################*/
              else if (right){

                  if (currDragObj.rotation.x >= 0.000) {
                    currDragObj.rotation.x -= rotationV;
                  }

                  if (currDragObj.position.x > halfObjectWidth) {
                      currDragObj.rotation.x = 0;
                      currDragObj.rotation.y += 0.005;
                      currDragObj.position.x = currDragObj.xcord;
                      currDragObj.position.y = currDragObj.ycord;
                      currDragObj.gravity = 0;
                  }

                  shadowTitle(currDragObj, 'right');
              }
          }
      }
      // console.log('isTableDragging: ' + isTableDragging +
      //             ' tableRetrieve: ' + tableRetrieve + ' impact: ' + impact);
  }

  function applyGravity(currentObj, gridObject) {

      // Get the objects difference in position from main table object
      var diffx = grid[objects[gridObject].place].posx - grid[1].posx;
      var diffy = grid[objects[gridObject].place].posy - grid[1].posy;
      // Set objects location relative to dragged table object
      var dynamicX = currentObj.position.x + diffx;
      var dynamicY = currentObj.position.y + diffy;

      objects[gridObject].gravity += (objects[gridObject].gravity / 2);


      if (objects[gridObject].position.x < currentObj.position.x) {

          objects[gridObject].position.x = dynamicX + objects[gridObject].gravity;
      }
      else if (objects[gridObject].position.x > currentObj.position.x) {

          objects[gridObject].position.x = dynamicX - objects[gridObject].gravity;
      }

      if ((objects[gridObject].position.x < currentObj.position.x + 10) &&
          (objects[gridObject].position.x > currentObj.position.x - 10)) {

          objects[gridObject].position.x = currentObj.position.x;
          impact = true;
      }

      if(objects[gridObject].position.y < currentObj.position.y) {

          objects[gridObject].position.y = dynamicY + objects[gridObject].gravity;
      }
      else if(objects[gridObject].position.y > currentObj.position.y) {

          objects[gridObject].position.y = dynamicY - objects[gridObject].gravity;
      }
  }

  function applyAntiGravity(currentObj, gridObject) {

      // Get the objects difference in position from main table object
      var diffx = grid[objects[gridObject].place].posx - grid[1].posx;
      var diffy = grid[objects[gridObject].place].posy - grid[1].posy;
      // Set objects location relative to dragged table object
      var dynamicX = currentObj.position.x + diffx;
      var dynamicY = currentObj.position.y + diffy;

      objects[gridObject].gravity -= (objects[gridObject].gravity / 2);


      if (objects[gridObject].position.x < currentObj.position.x) {

          objects[gridObject].position.x = dynamicX - objects[gridObject].gravity;
      }
      else if (objects[gridObject].position.x > currentObj.position.x) {

          objects[gridObject].position.x = dynamicX + objects[gridObject].gravity;
      }

      if ((objects[gridObject].position.x < currentObj.position.x + 10) &&
          (objects[gridObject].position.x > currentObj.position.x - 10)) {

          objects[gridObject].position.x = currentObj.position.x + diffx;
          impact = true;
      }

      if(objects[gridObject].position.y < currentObj.position.y) {

          objects[gridObject].position.y = dynamicY - objects[gridObject].gravity;
      }
      else if(objects[gridObject].position.y > currentObj.position.y) {

          objects[gridObject].position.y = dynamicY + objects[gridObject].gravity;
      }
  }

  function repositionObject(object, gridPosition) {

      object.rotation.x = grid[gridPosition].rotx;
      object.position.x = grid[gridPosition].posx;
      object.position.y = grid[gridPosition].posy;
      grid[gridPosition].placed = true;
      object.place = grid[gridPosition].place;
  }

  function repositionColumns() {
      //console.log('repositioning columns');
      // Clear all spots before repositioning objects
      grid.forEach(function(spot) {
          //if (spot.place > 0) {
              spot.placed = false;
          //}
      });

      for (var i = 0; i < addedObj.length; i++) {

          objects[addedObj[i]].place = grid[i].place;
          grid[i].placed = true;
          objects[addedObj[i]].rotation.x = grid[i].rotx;
          objects[addedObj[i]].position.x = grid[i].posx;
          objects[addedObj[i]].position.y = grid[i].posy;
          objects[addedObj[i]].type = grid[i].type;
          objects[addedObj[i]].gravity = 1.0;

          currDragObj = objects[addedObj[i]];
          shadowTitle(currDragObj, 'left');
      }
  }

  function clearGridPositions() {

      grid.forEach(function(position) {
          position.placed = false;
      });

  }

  function shadowTitle(object, direction) {

      //getLabelIndex(currDragObj);

      if (direction == 'right') {

          centerObjects(object, object.abbr);
          object.abbr.position.z = 10.0;
          object.abbr.rotation.y = 0.0;

          object.title.visible = true;
          object.title.position.x = object.position.x + (halfObjectWidth * 1.5);
          object.title.position.y = object.position.y;
          object.title.position.z = 1.0;
          object.title.rotation.y = -0.5;
      }
      else if (direction == 'left') {

          object.title.visible = false;
          object.abbr.visible = true;

          centerObjects(object, object.abbr);

          object.abbr.position.z = 10.0;
          object.abbr.rotation.y = 0.0;
      }
      else if (direction == 'up') {
          object.title.visible = false;
          object.abbr.visible = true;

          centerObjects(object, object.abbr);
          object.abbr.position.y += objectWidth + halfObjectWidth;
          object.abbr.position.z = 10.0;
          object.abbr.rotation.y = 0.0;
          object.abbr.scale.set(5, 5, 5);
      }
  }

  /**
   * Compute the "middlePoint" aka the point at the middle of the boundingBox
   *
   * @params {THREE.Geometry} the geometry to compute on
   * @returns {THREE.Vector3} the middlepoint of the geometry
  */
  function centerObjects(object1, object2) {
      // Create vector for finding center of object 1
      var obj1center = new THREE.Vector3;
      // Create bounding box of object 2 to find dimensions
      var obj2boundBox = new THREE.Box3().setFromObject(object2);
      // Set start of object 2 to the center of object 1 using a vector
      obj1center.lerpVectors(object1.position, object2.position, 0.0);
      // Offset object 2 to match center with center of object 1
      object2.position.set(
        obj1center.x - ((obj2boundBox.max.x - obj2boundBox.min.x) / 2),
        obj1center.y - ((obj2boundBox.max.y - obj2boundBox.min.y) / 2),
        10.0);
  }

  function getTouchDirection(e) {
      e.pageX = event.touches[0].clientX;
      e.pageY = event.touches[0].clientY;

      getMouseDirection(e);
  }

  function getMouseDirection(e) {

      // Find horizontal direction
      if (oldX < e.pageX) {
          right = true;
          left = false;
          xDirection = 'right';
      } else {
          left = true;
          right = false;
          xDirection = 'left';
      }

      // Find vertical direction
      if (oldY < e.pageY) {
          down = true;
          up = false;
          yDirection = 'down';
      } else {
          up = true;
          down = false;
          yDirection = 'up';
      }

      oldX = e.pageX;
      oldY = e.pageY;
  }

  function removeObject(array, object) {
      const index = array.indexOf(object);

      if (index != -1) {
          array.splice(index, 1);
      }
  }

  function animate() {

      //stats.begin();

      // Check if an object has been selected and stop it's rotation if so
      objects.forEach(function(element) {
          if (addedObj.length > 0){
              // Loop through currently touched/dragged objects
              for (var i = 0; i < addedObj.length; i++) {
                  // If already found (touched/dragged) stop horizontal rotation
                  var found = $.inArray(element.num, addedObj);
                  if (found != -1) {
                      element.rotation.y = 0.000;
                  } // If not found (touched/dragged) then continue rotating horizontally
                  else {
                      element.rotation.y += 0.005;
                      objects[0].rotation.y = 0.000;
                  }
              }
          }
          else { // If no touched/dragged objects exist then rotate horizontally
              if (grid[element.num].type == 'table') {
                  element.rotation.y = 0.000;
              } else {
                  element.rotation.y += 0.005;
              }
          }
      });

      //stats.end();

      requestAnimationFrame(animate);

      render();
  }

  function render() {
      controls.update();
      controls.enabled = false;
      renderer.render( scene, camera );
  }

  function buildDataGrid() {

      var cell = {
            place: 0,
            placed: false,
            type: "table",
            posx: -objectWidth,
            posy: 0,
            posz: 0,
            rotx: 1.5, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0
          }
      grid.push(cell);

      var cell = {
            place: 1,
            placed: false,
            type: "column",
            posx: -objectWidth + halfObjectWidth -10,
            posy: halfObjectWidth * 1.5 + 5,
            posz: 0,
            rotx: 1.5, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0
          }
      grid.push(cell);

      var cell = {
            place: 2,
            placed: false,
            type: "column",
            posx: -objectWidth + halfObjectWidth -10,
            posy: -halfObjectWidth * 1.5 - 5,
            posz: 0,
            rotx: 1.5, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0
          }
      grid.push(cell);

      var cell = {
            place: 3,
            placed: false,
            type: "column",
            posx: -objectWidth * 2 + 20,
            posy: 0,
            posz: 0,
            rotx: 1.5, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0
          }
      grid.push(cell);

      var cell = {
            place: 4,
            placed: false,
            type: "column",
            posx: -20,
            posy: 0,
            posz: 0,
            rotx: 1.5, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0
          }
      grid.push(cell);

      var cell = {
            place: 5,
            placed: false,
            type: "column",
            posx: -objectWidth - halfObjectWidth + 10,
            posy: halfObjectWidth * 1.5 + 5,
            posz: 0,
            rotx: 1.5, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0
          }
      grid.push(cell);

      var cell = {
            place: 6,
            placed: false,
            type: "column",
            posx: -objectWidth - halfObjectWidth + 10,
            posy: -halfObjectWidth * 1.5 - 5,
            posz: 0,
            rotx: 1.5, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0
          }
      grid.push(cell);

      var cell = {
            place: 7,
            placed: false,
            type: "column",
            posx: halfObjectWidth / 2 + 20,
            posy: halfObjectWidth * 1.5 + 5,
            posz: 0,
            rotx: 1.5, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0
          }
      grid.push(cell);

      var cell = {
            place: 8,
            placed: false,
            type: "column",
            posx: (-objectWidth * 2) - halfObjectWidth + 30,
            posy: halfObjectWidth * 1.5 + 5,
            posz: 0,
            rotx: 1.5, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0
          }
      grid.push(cell);

      var cell = {
            place: 9,
            placed: false,
            type: "column",
            posx: -objectWidth,
            posy: objectWidth * 2 - halfObjectWidth + 10,
            posz: 0,
            rotx: 1.5, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0
          }
      grid.push(cell);

      var cell = {
            place: 10,
            placed: false,
            type: "",
            posx: listStartX,
            posy: listStartY,
            posz: 0,
            rotx: 1.5, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0
          }
      grid.push(cell);

  }

  function buildDataBlock() {

    data = {
          "Movies": [
           "Title", "Released", "Origin", "Location", "Company", "Budget", "Director", "Producer", "Actors",  "Gross"
          ]
      ,
          "Identification": [
             "Type", "FirstName", "LastName", "Picture", "BirthDate", "Height", "Weight", "CardNumber", "ExpiryDate", "Note"
          ]
      ,
          "Hydro": [
              "BillingDate", "DueDate", "Address", "Rate", "CostPerUnit", "BillTotal", "StartDate", "EndDate", "Chart", "Company"
          ]
      ,
          "Abcdefghijklmnopqrst": [
              "DataType1", "DataType2", "DataType3", "DataType4", "DataType5", "DataType6", "DataType7", "DataType8", "DataType9", "DataType10"
          ]
      ,
          "Template5": [
              "DataType1", "DataType2", "DataType3", "DataType4", "DataType5", "DataType6", "DataType7", "DataType8", "DataType9", "DataType10"
          ]
      ,
          "Template6": [
              "DataType1", "DataType2", "DataType3", "DataType4", "DataType5", "DataType6", "DataType7", "DataType8", "DataType9", "DataType10"
          ]
      ,
          "Template7": [
              "DataType1", "DataType2", "DataType3", "DataType4", "DataType5", "DataType6", "DataType7", "DataType8", "DataType9", "DataType10"
          ]
      ,
          "Template8": [
              "DataType1", "DataType2", "DataType3", "DataType4", "DataType5", "DataType6", "DataType7", "DataType8", "DataType9", "DataType10"
          ]
      ,
          "Template9": [
              "DataType1", "DataType2", "DataType3", "DataType4", "DataType5", "DataType6", "DataType7", "DataType8", "DataType9", "DataType10"
          ]
      ,
          "Template10": [
              "DataType1", "DataType2", "DataType3", "DataType4", "DataType5", "DataType6", "DataType7", "DataType8", "DataType9", "DataType10"
          ]
    }
  }


  function buildSavedGrid() {

      var cell = {
            place: 0,
            placed: false,
            type: "",
            posx: 0,
            posy: 0,
            posz: 0,
            rotx: 0, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0,
            objects: [],
            table: "",
            tableUuid: ""
          }
      savedTables.push(cell);

      var cell = {
            place: 1,
            placed: false,
            type: "table",
            posx: savedStartX,//var listStartX = (window.innerWidth / 2) - 10;,
            posy: savedStartY,
            posz: 0,
            rotx: 0, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0,
            objects: [],
            table: "",
            tableUuid: ""
          }
      savedTables.push(cell);

      var cell = {
            place: 2,
            placed: false,
            type: "table",
            posx: savedStartX + savedObjWidth + savedTableSpace,
            posy: savedStartY,
            posz: 0,
            rotx: 0, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0,
            objects: [],
            table: "",
            tableUuid: ""
          }
      savedTables.push(cell);

      var cell = {
            place: 3,
            placed: false,
            type: "table",
            posx: savedStartX + (savedObjWidth + savedTableSpace) * 2,
            posy: savedStartY,
            posz: 0,
            rotx: 0, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0,
            objects: [],
            table: "",
            tableUuid: ""
          }
      savedTables.push(cell);

      var cell = {
            place: 4,
            placed: false,
            type: "table",
            posx: savedStartX + (savedObjWidth + savedTableSpace) * 3,
            posy: savedStartY,
            posz: 0,
            rotx: 0, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0,
            objects: [],
            table: "",
            tableUuid: ""
          }
      savedTables.push(cell);

      var cell = {
            place: 5,
            placed: false,
            type: "table",
            posx: savedStartX + (savedObjWidth + savedTableSpace) * 4,
            posy: savedStartY,
            posz: 0,
            rotx: 0, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0,
            objects: [],
            table: "",
            tableUuid: ""
          }
      savedTables.push(cell);

      var cell = {
            place: 6,
            placed: false,
            type: "table",
            posx: savedStartX + (savedObjWidth + savedTableSpace) * 5,
            posy: savedStartY,
            posz: 0,
            rotx: 0, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0,
            objects: [],
            table: "",
            tableUuid: ""
          }
      savedTables.push(cell);

      var cell = {
            place: 7,
            placed: false,
            type: "table",
            posx: savedStartX + (savedObjWidth + savedTableSpace) * 6,
            posy: savedStartY,
            posz: 0,
            rotx: 0, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0,
            objects: [],
            table: "",
            tableUuid: ""
          }
      savedTables.push(cell);

      var cell = {
            place: 8,
            placed: false,
            type: "table",
            posx: savedStartX + (savedObjWidth + savedTableSpace) * 7,
            posy: savedStartY,
            posz: 0,
            rotx: 0, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0,
            objects: [],
            table: "",
            tableUuid: ""
          }
      savedTables.push(cell);

      var cell = {
            place: 9,
            placed: false,
            type: "table",
            posx: savedStartX + (savedObjWidth + savedTableSpace) * 8,
            posy: savedStartY,
            posz: 0,
            rotx: 0, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0,
            objects: [],
            table: "",
            tableUuid: ""
          }
      savedTables.push(cell);

      var cell = {
            place: 10,
            placed: false,
            type: "table",
            posx: savedStartX + (savedObjWidth + savedTableSpace) * 9,
            posy: savedStartY,
            posz: 0,
            rotx: 0, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0,
            objects: [],
            table: "",
            tableUuid: ""
          }
      savedTables.push(cell);

  }


  function buildRemovedGrid() {

      var cell = {
            place: 0,
            placed: false,
            type: "",
            posx: 0,
            posy: 0,
            posz: 0,
            rotx: 0, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0,
            objects: [],
            table: ""
          }
      removedTables.push(cell);

      var cell = {
            place: 1,
            placed: false,
            type: "table",
            posx: removedStartX,
            posy: removedStartY,
            posz: 0,
            rotx: 0, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0,
            objects: [],
            table: ""
          }
      removedTables.push(cell);

      var cell = {
            place: 2,
            placed: false,
            type: "table",
            posx: removedStartX + savedObjWidth + savedTableSpace,
            posy: removedStartY,
            posz: 0,
            rotx: 0, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0,
            objects: [],
            table: ""
          }
      removedTables.push(cell);

      var cell = {
            place: 3,
            placed: false,
            type: "table",
            posx: removedStartX + (savedObjWidth + savedTableSpace) * 2,
            posy: removedStartY,
            posz: 0,
            rotx: 0, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0,
            objects: [],
            table: ""
          }
      removedTables.push(cell);

      var cell = {
            place: 4,
            placed: false,
            type: "table",
            posx: removedStartX + (savedObjWidth + savedTableSpace) * 3,
            posy: removedStartY,
            posz: 0,
            rotx: 0, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0,
            objects: [],
            table: ""
          }
      removedTables.push(cell);

      var cell = {
            place: 5,
            placed: false,
            type: "table",
            posx: removedStartX + (savedObjWidth + savedTableSpace) * 4,
            posy: removedStartY,
            posz: 0,
            rotx: 0, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0,
            objects: [],
            table: ""
          }
      removedTables.push(cell);

      var cell = {
            place: 6,
            placed: false,
            type: "table",
            posx: removedStartX + (savedObjWidth + savedTableSpace) * 5,
            posy: removedStartY,
            posz: 0,
            rotx: 0, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0,
            objects: [],
            table: ""
          }
      removedTables.push(cell);

      var cell = {
            place: 7,
            placed: false,
            type: "table",
            posx: removedStartX + (savedObjWidth + savedTableSpace) * 6,
            posy: removedStartY,
            posz: 0,
            rotx: 0, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0,
            objects: [],
            table: ""
          }
      removedTables.push(cell);

      var cell = {
            place: 8,
            placed: false,
            type: "table",
            posx: removedStartX + (savedObjWidth + savedTableSpace) * 7,
            posy: removedStartY,
            posz: 0,
            rotx: 0, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0,
            objects: [],
            table: ""
          }
      removedTables.push(cell);

      var cell = {
            place: 9,
            placed: false,
            type: "table",
            posx: removedStartX + (savedObjWidth + savedTableSpace) * 8,
            posy: removedStartY,
            posz: 0,
            rotx: 0, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0,
            objects: [],
            table: ""
          }
      removedTables.push(cell);

      var cell = {
            place: 10,
            placed: false,
            type: "table",
            posx: removedStartX + (savedObjWidth + savedTableSpace) * 9,
            posy: removedStartY,
            posz: 0,
            rotx: 0, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0,
            objects: [],
            table: ""
          }
      removedTables.push(cell);

  }

  // End
