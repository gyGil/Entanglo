import { OnInit, Component, ElementRef, Input, ViewChild, HostListener } from '@angular/core';

import * as THREE from 'three';
//import "./EnableThreeJS";
//import "three/examples/js/controls/DragControls";
//import "three/examples/js/controls/TrackballControls";
import * as $ from 'jquery';
import { Router } from '@angular/router';

import { AiService } from '../../services/ai.service';


@Component({
    selector: 'design',
    templateUrl: './dataDesign.component.html',
    styleUrls: ['./dataDesign.component.css']
})

export class DesignDataComponent implements OnInit {
    //switchpage = true;
    /* Page Swipe */
    private swipeCoord?: [number, number];
    private swipeTime?: number;
    private swipeStart: boolean = false;

    private container: any;
    private listeners: any;

    private renderer;
    private camera;
    private scene;
    //public controls: THREE.TrackballControls;
    //public dragControls: any;

    //private geometry;

    private raycaster;
    private mouse;
    private currDragObj: any;
    private addedObj = [];

    private grid = [];
    private savedTables = [];
    private removedTables = [];

    private data: any;
    private keys = [];

    private listStartX: number;
    private listStartY: number;
    private listSpacing: number;

    private oldX: number;
    private oldY: number;

    private halfWindowWidth: number;
    private halfWindowHeight: number;
    private halfObjectWidth: number;
    private quarterObjectWidth: number;
    private objectWidth: number;
    private rotationV: number;

    private savedObjWidth: number;
    private savedStartX: number;
    private savedStartY: number;
    private savedTableSpace: number;
    private tableSaved: boolean;
    private savedTableCount: number;

    private removedStartX: number;
    private removedStartY: number;
    private tableRemoved: boolean;
    private removedTableCount: number;

    private right: boolean;
    private left: boolean;
    private up: boolean;
    private down: boolean;
    private xDirection: string;
    private yDirection: string;

    private intersectsObj = [];
    private isDragging: boolean;
    private isTableDragging: boolean;
    private resetTable: boolean;

    public fieldOfView: number;
    public nearClippingPane: number;
    public farClippingPane: number;

    private objects = [];
    private tableObj: any;
    private tempSavedObjects = [];

    private gravity: number;
    private impact: boolean;
    private tableScale: number;

    private originalColors = [];
    private tableColors = [];

    public animateCallback;

    @ViewChild('canvas')
    private canvasRef: ElementRef;

    constructor(private router: Router,
        private aiSerivce: AiService) {
        this.render = this.render.bind(this);
        //this.container.appendChild(this.renderer.domElement);
    }


    onStart() {

        //this.disposeObjectsFromScene(this.objects);
        //this.router.navigate(["/home"]);
        this.router.navigateByUrl("/home");
    }

    onNext() {

        //this.disposeObjectsFromScene(this.objects);
        //this.router.navigate(["/ocr"]);  
        this.router.navigateByUrl("/ocr");
    }

    ngOnInit() {

        this.initializeAttributes();

        this.createScene();

        this.createCamera();

        this.createLight();

        this.startRendering();

        //this.container.appendChild(this.renderer.domElement);

        //this.createEvents();

        //this.createControls();

        this.buildDataBlock();

        this.keys = Object.keys(this.data);

        this.buildDataObjects(10);

        this.buildDataGrid();

        this.buildSavedGrid();

        this.buildRemovedGrid();

        this.animateCallback = {
            callAnimate: (this.animate).bind(this)
        };

        this.animateCallback.callAnimate();

        //============== Test (Remove after development) ============================//
        var wordRecomArgs: wordRecomRequestBody = { TargetWord: "book" };
        this.aiSerivce.postWordRecom(wordRecomArgs)
            .subscribe(async res => {
                console.log("Ok, in component.");
            },
            err => {
                console.log("word recom request failed - ", err);
            });

        //============== End Test (Remove after development) ============================//
    }

    private get canvas(): HTMLCanvasElement {

        return this.canvasRef.nativeElement;
    }

    private initializeAttributes() {

        //this.container = document.createElement('div');
        //document.body.appendChild(this.container);



        this.renderer = new THREE.WebGLRenderer;
        this.camera = new THREE.PerspectiveCamera;
        this.scene = new THREE.Scene;

        //this.geometry = new THREE.BoxGeometry;

        this.raycaster = new THREE.Raycaster;
        this.mouse = new THREE.Vector2();
        //this.currDragObj;
        this.addedObj = [];

        this.grid = [];
        this.savedTables = [];
        this.removedTables = [];

        this.listStartX = (window.innerWidth / 5) * 2;
        this.listStartY = (window.innerHeight / 2);
        this.listSpacing = 100;

        this.oldX = 0;
        this.oldY = 0;

        this.halfWindowWidth = window.innerWidth / 2;
        this.halfWindowHeight = window.innerHeight / 2;

        this.halfObjectWidth = 100;
        this.quarterObjectWidth = this.halfObjectWidth / 2;
        this.objectWidth = this.halfObjectWidth * 2;
        this.rotationV = (this.halfWindowWidth / this.objectWidth) / 100;

        this.savedObjWidth = this.objectWidth;

        this.savedStartX = -(window.innerWidth / 5) * 3;
        this.savedStartY = (window.innerHeight / 2) + this.halfObjectWidth;
        this.savedTableSpace = this.halfObjectWidth / 4;

        this.removedStartX = this.savedStartX;
        this.removedStartY = -(window.innerHeight / 2) - this.halfObjectWidth;

        this.tableSaved = false;
        this.savedTableCount = 0;

        this.tableRemoved = false;
        this.removedTableCount = 0;

        this.right = false;
        this.left = false;
        this.up = false;
        this.down = false;
        this.xDirection = '';
        this.yDirection = '';

        this.intersectsObj;
        this.isDragging = false;
        this.isTableDragging = false;
        this.resetTable = false;

        this.fieldOfView = 70;
        this.nearClippingPane = 1;
        this.farClippingPane = 10000;

        this.objects = [];
        //this.tableObj;
        this.tempSavedObjects = [];

        this.gravity = 0;
        this.impact = false;
        this.tableScale = 0.0;

        this.originalColors = [];
        this.tableColors = [0x003333, 0x004D4D, 0x4D0000, 0x660000];
    }

    private createScene() {

        this.scene = new THREE.Scene();
        this.scene.background = new THREE.Color(0x000000);
        this.scene.add(new THREE.AmbientLight(0x505050));

        //var geometry = new THREE.BoxGeometry(30, 30, 30);

        /* cube creation loop */
        //for (var i = 0; i < 100; i++) {

        //    var obj = new THREE.Mesh(geometry, new THREE.MeshLambertMaterial({ color: 0xFFFFFF }));

        //    obj.position.x = Math.random() * 1000 - 500;
        //    obj.position.y = Math.random() * 600 - 300;
        //    obj.position.z = Math.random() * 800 - 400;

        //    obj.castShadow = true;
        //    obj.receiveShadow = true;
        //    this.scene.add(obj);
        //    this.objects.push(obj);

        //}

    }

    private createLight() {

        var light = new THREE.SpotLight(0xFFFFFF, 1.5);
        light.position.set(0, 500, 2000);
        light.castShadow = true;
        light.shadow = new THREE.SpotLightShadow(new THREE.PerspectiveCamera(50, 1, 200, 10000));
        light.shadow.bias = - 0.00022;
        light.shadow.mapSize.width = 2048;
        light.shadow.mapSize.height = 2048;
        this.scene.add(light);
    }

    private createCamera() {

        //let aspectRatio = this.getAspectRatio();
        this.camera = new THREE.PerspectiveCamera(
            this.fieldOfView,
            //aspectRatio,
            (window.innerWidth / window.innerHeight),
            this.nearClippingPane,
            this.farClippingPane
        );

        // Set position and look at
        this.camera.position.x = 0;
        this.camera.position.y = 0;
        this.camera.position.z = 1000;
    }

    //private getAspectRatio(): number {

    //    let height = this.canvas.clientHeight;
    //    if (height === 0) {
    //        return 0;
    //    }
    //    return this.canvas.clientWidth / this.canvas.clientHeight;
    //}

    private startRendering() {

        this.renderer = new THREE.WebGLRenderer({
            canvas: this.canvas,
            antialias: true
        });
        //this.renderer.setPixelRatio(devicePixelRatio);
        //this.renderer.setSize(this.canvas.clientWidth, this.canvas.clientHeight);
        //this.renderer = new THREE.WebGLRenderer({ antialias: true });
        this.renderer.setPixelRatio(window.devicePixelRatio);
        this.renderer.setSize(window.innerWidth, window.innerHeight, false);

    }

    private createControls() {

        //this.controls = new THREE.TrackballControls(this.camera);
        //this.controls.rotateSpeed = 1.0;
        //this.controls.zoomSpeed = 1.2;
        //this.controls.panSpeed = 0.8;
        //this.controls.noZoom = false;
        //this.controls.noPan = false;
        //this.controls.staticMoving = true;
        //this.controls.dynamicDampingFactor = 0.3;
        //this.controls.addEventListener('change', this.render);

        //this.dragControls = new THREE.DragControls(this.objects, this.camera, this.renderer.domElement);
        //this.dragControls.addEventListener('dragstart', (function (event) { this.controls.enabled = false; }).bind(this));
        //this.dragControls.addEventListener('dragend', (function (event) { this.controls.enabled = true; }).bind(this));

    }

    private createEvents() {


        //window.addEventListener('resize', this.onWindowResize.bind(this), false);
        //document.addEventListener('mousedown', this.onMouseDown.bind(this), false);
        //document.addEventListener('touchstart', this.onTouchStart.bind(this), false);
        //document.addEventListener('touchmove', this.getTouchDirection.bind(this), false);
        //document.addEventListener('mousemove', this.getMouseDirection.bind(this), false);
        //document.addEventListener('touchend', this.onTouchEnd.bind(this), false);
        //document.addEventListener('mouseup', this.onMouseUp.bind(this), false);

        //this.listeners = $._data(document, 'events');
    }

    /* FUNCTIONS */
    private buildDataObjects(quantity) {

        let fontLoader = new THREE.FontLoader();

        fontLoader.load('/dist/res/lib/fonts/helvetiker_regular.typeface.json', (font) => {

            for (let i = 0; i < quantity; i++) {

                let geometry = new THREE.CylinderGeometry(100, 100, 30, 6, 4);

                let object = new THREE.Mesh(geometry, new THREE.MeshLambertMaterial({ color: 0xFFFFFF }));

                //object.material.linewidth = 2;

                // Add extra x, y, z cordinates attributes for saving objects original location
                object.position.x = object.xcord = this.listStartX;
                object.position.y = object.ycord = this.listStartY - (this.listSpacing * i);
                object.position.z = object.zcord = 0;

                object.castShadow = true;
                object.receiveShadow = true;

                object.num = (i + 1).toString(); // Add incrementing number to each object
                object.type = '';
                object.place = 0;
                object.name = this.keys[i];
                object.gravity = 0;

                this.originalColors.push(0xFFFFFF);

                let textMaterial = new THREE.MeshPhongMaterial({ color: 0xFFFFFF, flatShading: true });

                // MAIN DATA TITLE
                var dataText = new THREE.TextGeometry(this.keys[i], {
                    font: font,
                    size: 15,
                    height: 10,
                    curveSegments: 4,
                    bevelThickness: 1,
                    bevelSize: 0.5,
                    bevelEnabled: true//,
                    //bevelSegments: 5
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
                let abbr = new THREE.TextGeometry(this.abbreviate(this.keys[i].toString(), 8), {
                    font: font,
                    size: 15,
                    height: 10,
                    curveSegments: 4,
                    bevelThickness: 1,
                    bevelSize: 0.5,
                    bevelEnabled: true//,
                    //bevelSegments: 5
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
                let textMesh = new THREE.Mesh(dataText, textMaterial);
                // ABBREVIATED
                let abbrMesh = new THREE.Mesh(abbr, textMaterial);

                textMesh.position.x = object.xcord + this.halfObjectWidth * 1.5;
                textMesh.position.y = object.ycord;
                textMesh.position.z = object.zcord;
                textMesh.rotation.y = -0.5;
                textMesh.name = object.name;  // Assign table name to each column title/abbr for easy referencing
                textMesh.num = i.toString();

                this.scene.add(textMesh);

                abbrMesh.scale.set(2, 2, 2);
                abbrMesh.visible = false;
                abbrMesh.name = object.name;
                abbrMesh.num = i.toString();

                this.scene.add(abbrMesh);

                object.title = textMesh;
                object.abbr = abbrMesh;

                // object.title = dataText;
                // object.abbr = abbr;

                this.scene.add(object);

                this.objects.push(object);

            }
            console.log("Objects Made");
        });

    }

    private abbreviate(chars, n) {

        return (chars.length > n) ? chars.substr(0, n - 1) : chars;
    };

    private disposeObjectsFromScene(objects) {

        objects.forEach((object) => {

            this.scene.remove(object.abbr);
            this.scene.remove(object.title);
            this.scene.remove(object);

            object.abbr.geometry.dispose(); object.abbr.geometry = null;
            object.abbr.material.dispose(); object.abbr.material = null;
            object.abbr.remove(); object.abbr = null;

            object.title.geometry.dispose(); object.title.geometry = null;
            object.title.material.dispose(); object.title.material = null;
            object.title.remove(); object.title = null;

            object.geometry.dispose(); object.geometry = null;
            object.material.dispose(); object.material = null;
            object.remove(); object = null;
        });

        //objects.remove();
        objects.length = 0;
        objects = null;

    }

    private addObjectsToScene(objects) {

        if (objects[0] != null) {
            objects.forEach((object) => {

                this.scene.add(object.abbr);
                this.scene.add(object.title);
                this.scene.add(object);

            });
        }
    }

    private cloneObjectArray(objects) {

        var cloneObjects = [];
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

    private cloneObject(object) {

        var newObject = object.clone();

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

    private removeObjectsFromScene(objects) {

        objects.forEach((object) => {

            this.scene.remove(object.abbr);

            this.scene.remove(object.title);

            this.scene.remove(object);

        });

        objects.length = 0;
    }

    private saveTable(savedTableObj) {

        this.setTableToRow(savedTableObj, true);

    }

    private removeTable(removedTableObj) {

        this.setTableToRow(removedTableObj, false);

    }

    private setTableToRow(tableObj, saved) {

        for (var k = 0; k < this.objects.length; k++) {

            if (tableObj.objects[k].place == 0) {

                tableObj.objects[k].scale.set(1, 1, 1);
                tableObj.objects[k].abbr.scale.set(2.5, 2.5, 2.5);

                tableObj.objects[k].position.x = tableObj.posx;
                tableObj.objects[k].position.y = tableObj.posy;

                tableObj.objects[k].abbr.rotation.y = 0;
                tableObj.objects[k].abbr.visible = true;

                this.setTableStatus(tableObj.objects[k], saved);

                this.centerObjects(tableObj.objects[k], tableObj.objects[k].abbr);

                tableObj.table = tableObj.objects[k].name;

                this.scene.add(tableObj.objects[k]);
                this.scene.add(tableObj.objects[k].abbr);

                break;
            }
        }

    }

    private setTableStatus(object, saved) {

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

    private getIndexOfTable(tables) {

        var index = 0;

        for (var i = 0; i < tables.length; i++) {

            if (tables[i].tableUuid == this.currDragObj.uuid) {
                index = i;
                break;
            }
        }
        return index;
    }

    private repositionTables(tables) {

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
                    this.shadowTitle(tables[i].objects[0], 'left');
                }
            }

            // Break from loop if all objects have been repositioned
            if (!tables[i + 1].placed && !tables[i + 2].placed) {
                break;
            }
        }
    }

    private applyGravity(currentObj, gridObject) {

        // Get the objects difference in position from main table object
        var diffx = this.grid[this.objects[gridObject].place].posx - this.grid[1].posx;
        var diffy = this.grid[this.objects[gridObject].place].posy - this.grid[1].posy;
        // Set objects location relative to dragged table object
        var dynamicX = currentObj.position.x + diffx;
        var dynamicY = currentObj.position.y + diffy;

        this.objects[gridObject].gravity += (this.objects[gridObject].gravity / 2);


        if (this.objects[gridObject].position.x < currentObj.position.x) {

            this.objects[gridObject].position.x = dynamicX + this.objects[gridObject].gravity;
        }
        else if (this.objects[gridObject].position.x > currentObj.position.x) {

            this.objects[gridObject].position.x = dynamicX - this.objects[gridObject].gravity;
        }

        if ((this.objects[gridObject].position.x < currentObj.position.x + 10) &&
            (this.objects[gridObject].position.x > currentObj.position.x - 10)) {

            this.objects[gridObject].position.x = currentObj.position.x;
            this.impact = true;
        }

        if (this.objects[gridObject].position.y < currentObj.position.y) {

            this.objects[gridObject].position.y = dynamicY + this.objects[gridObject].gravity;
        }
        else if (this.objects[gridObject].position.y > currentObj.position.y) {

            this.objects[gridObject].position.y = dynamicY - this.objects[gridObject].gravity;
        }
    }

    private repositionObject(object, gridPosition) {

        object.rotation.x = this.grid[gridPosition].rotx;
        object.position.x = this.grid[gridPosition].posx;
        object.position.y = this.grid[gridPosition].posy;
        this.grid[gridPosition].placed = true;
        object.place = this.grid[gridPosition].place;
    }

    private repositionColumns() {

        // Clear all spots before repositioning objects
        this.grid.forEach(function (spot) {

            spot.placed = false;
        });

        for (var i = 0; i < this.addedObj.length; i++) {

            this.objects[this.addedObj[i]].place = this.grid[i].place;
            this.grid[i].placed = true;
            this.objects[this.addedObj[i]].rotation.x = this.grid[i].rotx;
            this.objects[this.addedObj[i]].position.x = this.grid[i].posx;
            this.objects[this.addedObj[i]].position.y = this.grid[i].posy;
            this.objects[this.addedObj[i]].type = this.grid[i].type;
            this.objects[this.addedObj[i]].gravity = 1.0;

            this.currDragObj = this.objects[this.addedObj[i]];
            this.shadowTitle(this.currDragObj, 'left');
        }
    }

    private clearGridPositions() {

        this.grid.forEach(function (position) {
            position.placed = false;
        });

    }

    private shadowTitle(object, direction) {

        //getLabelIndex(currDragObj);

        if (direction == 'right') {

            this.centerObjects(object, object.abbr);
            object.abbr.position.z = 10.0;
            object.abbr.rotation.y = 0.0;

            object.title.visible = true;
            object.title.position.x = object.position.x + (this.halfObjectWidth * 1.5);
            object.title.position.y = object.position.y;
            object.title.position.z = 1.0;
            object.title.rotation.y = -0.5;
        }
        else if (direction == 'left') {

            object.title.visible = false;
            object.abbr.visible = true;

            this.centerObjects(object, object.abbr);

            object.abbr.position.z = 10.0;
            object.abbr.rotation.y = 0.0;
        }
        else if (direction == 'up') {
            object.title.visible = false;
            object.abbr.visible = true;

            this.centerObjects(object, object.abbr);
            object.abbr.position.y += this.objectWidth + this.halfObjectWidth;
            object.abbr.position.z = 10.0;
            object.abbr.rotation.y = 0.0;
            object.abbr.scale.set(5, 5, 5);
        }
    }

    /*
       * Compute the "middlePoint" aka the point at the middle of the boundingBox
       *
       * @params {THREE.Geometry} the geometry to compute on
       * @returns {THREE.Vector3} the middlepoint of the geometry
    */
    private centerObjects(object1, object2) {
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
        if (obj1center.x < 250) {
            console.log(obj1center.x.toString);
        }
    }

    private removeObject(array, object) {

        const index = array.indexOf(object);

        if (index != -1) {
            array.splice(index, 1);
        }
    }


    private convertObjectsToJson(table) {

        var mainJson;       // Main saved table object information
        var tableJson;      // Table object information
        var columnJson = [];// Column object information
        var jsonData = {};  // Combined table JSON object

        var columns = [];   // Column information for database

        // Add main table object array attributes
        mainJson = {
            "place": table.place,
            "posx": table.posx,
            "posy": table.posy,
            "tableUuid": table.tableUuid
        }

        var colCount = 0;       // Column counter

        // Add attributes to each object
        table.objects.forEach((object) => {
            // Add table specific attributes of the saved table
            if (object.type == 'table') {
                // Table specific attributes
                tableJson = {
                    "name": object.name,
                    "place": object.place,
                    "positionx": object.position.x,
                    "positiony": object.position.y,
                    "xcord": object.xcord,
                    "ycord": object.ycord,
                    "abbr": object.abbr.name
                }
            }
            else {
                // Add each column specific attributes of the saved table
                columnJson.push(this.buildColumn(object, colCount));
                // Add column specific attributes for database modelling
                columns.push(this.buildTableColumn(object));
            }

            ++colCount;   // Increment column counter
        });

        // Set saved table JSON object levels
        jsonData["main"] = mainJson;
        jsonData["table"] = tableJson;
        jsonData["columns"] = columnJson;

        // Build saved table information into JSON string
        var combinedJsonData = JSON.stringify(jsonData);

        // Build final table JSON object
        var jsonTable = {
            "Schema": "user",             // Schema is the users name which should be taken from the login info
            "TableName": table.table,
            "TableUuid": table.tableUuid,
            "JsonData": combinedJsonData,
            "TableColumns": columns
        }

        return jsonTable;
    }

    private buildColumn(object, colCount) {
        // Create incrementing column name
        var col = "column" + colCount.toString();

        object = {
            col: {
                "name": object.name,
                "place": object.place,
                "positionx": object.position.x,
                "positiony": object.position.y,
                "xcord": object.xcord,
                "ycord": object.ycord,
                "abbr": object.abbr.name
            }
        }
        return object;
    }

    private buildTableColumn(object) {

        object = {
            "ColumnName": object.name,
            "ColumnDataType": "TEXT",
            "ColumnSize": "50",
            "ColumnConstraint": "",
            "ColumnDefaultValue": "null"
        }

        return object;
    }

    private saveTableToServer(table) {
        // Table sent to server status
        var tableSaved = false;
        // Table Payload POST settings
        $.ajax({
            type: "POST",
            url: "https://localhost:44333/Entanglo/Create/Table",
            data: JSON.stringify(table),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (data) {
                alert(data);
                console.log("Table sent successfully!");
                tableSaved = true;
            },
            failure: function (errMsg) {
                alert(errMsg);
                console.log("Error sending table! Error Message: " + errMsg);
            }
        });

        return tableSaved;
    }




    /* EVENTS */
    public onTouchStart(event) {

        event.stopImmediatePropagation();

        event.clientX = event.touches[0].clientX;
        event.clientY = event.touches[0].clientY;

        //var route: string = event.currentTarget.URL.includes("home")
        //if ((!event.currentTarget.URL.includes("home")) && (this.objects != undefined)) {
        this.onMouseDown(event);
        //}
    }

    public onMouseDown(event) {

        //event.preventDefault();
        event.stopImmediatePropagation();

        // Get current mouse/touch coordinates
        this.mouse.x = (event.clientX / window.innerWidth) * 2 - 1;
        this.mouse.y = - (event.clientY / window.innerHeight) * 2 + 1;

        this.raycaster.setFromCamera(this.mouse, this.camera);

        // Save the object and associated text/label that is selected
        this.intersectsObj = this.raycaster.intersectObjects(this.objects);

        // Check if a list object was selected
        if (this.intersectsObj.length < 1) {
            // If not
            if (this.tableObj != null) {
                this.intersectsObj = this.raycaster.intersectObject(this.tableObj);
            }
            else {  // change

                for (var i = 1; i < this.savedTables.length; i++) {
                    if (this.savedTables[i].objects.length > 0) {
                        //intersectsObj = [];

                        this.intersectsObj = this.raycaster.intersectObjects(this.savedTables[i].objects);

                        if (this.intersectsObj.length > 0) {

                            this.removeObjectsFromScene(this.objects);
                            this.objects = this.savedTables[i].objects;

                            this.objects.forEach((object) => {
                                object.position.x = this.objects[0].position.x;
                                object.position.y = this.objects[0].position.y;
                            });

                            this.disposeObjectsFromScene(this.savedTables[i].objects);

                            this.tableSaved = true;

                            break;
                        }
                    }

                    if (this.removedTables[i].objects.length > 0) {
                        this.intersectsObj = this.raycaster.intersectObjects(this.removedTables[i].objects);

                        if (this.intersectsObj.length > 0) {

                            this.removeObjectsFromScene(this.objects);
                            this.objects = this.removedTables[i].objects;

                            this.objects.forEach((object) => {
                                object.position.x = this.objects[0].position.x;
                                object.position.y = this.objects[0].position.y;
                            });

                            this.disposeObjectsFromScene(this.removedTables[i].objects);

                            this.tableRemoved = true;

                            break;
                        }
                    }
                }

                // change
                //if (this.intersectsObj.length == 1) {
                //    console.log(this.intersectsObj[0].object.name);
                //}
                //else if (this.intersectsObj.length > 1) {
                //    console.log("-----------")
                //    console.log(this.intersectsObj[0].object.name);
                //    console.log(this.intersectsObj[1].object.name);
                //    console.log("-----------")
                //}

                // if (intersectsObj.length > 0) {
                //     currDragObj = intersectsObj[0].object;
                //     var index = getIndexOfTable(savedTables);
                //     addObjectsToScene(savedTables[index].objects);
                // }
                this.addObjectsToScene(this.objects);

                if (this.intersectsObj.length > 0) {
                    this.objects.forEach((object) => {
                        if ((object.num == '0') || (object.place != 0)) {
                            this.addedObj.push(object.num);
                            this.grid[object.num].placed = true;
                        }
                        else {
                            object.position.x = object.xcord;
                            object.position.y = object.ycord;
                        }
                    });

                    if (this.objects[0].type == 'table') {
                        this.objects[0].scale.set(1.5, 1.5, 1.5);
                    }

                    this.isTableDragging = true;
                }
                //else if (this.intersectsObj.length < 1 && this.currDragObj == undefined) {  // Nothing was touched (page switch)
                //    //(touchstart) = "swipe($event, 'start')"(touchend) = "swipe($event, 'end')"

                //    this.swipedata(event, 'start');
                //}
            }
        }


        // Check that an object is still selected
        if (this.intersectsObj.length > 0) {
            this.currDragObj = this.intersectsObj[0].object;

            // currDragObj = cloneObject(intersectsObj[0].object);
            // intersectsObj = [];
            this.isDragging = true;
            // getLabelIndex();
            // Check if any other objects are added
            if (this.addedObj.length > 0) {
                // Loop through each added object
                for (var i = 0; i < this.addedObj.length; i++) {
                    // Check if the current selected object is already added
                    var found = $.inArray(this.currDragObj.num, this.addedObj);
                    if (found == -1) {  // Set colour of newly added (first time selected) object and text/label

                        this.addedObj.push(this.currDragObj.num); // Add selected object to list
                        //getLabelIndex(currDragObj);                // Get the objects title/abbr index for color coding

                        if (this.currDragObj.material.color.getHex() == 0xffffff) {
                            this.currDragObj.material.color.setHex(Math.random() * 0xffffff);
                            // Save objects original colour
                            this.originalColors[this.currDragObj.num] = this.currDragObj.material.color.getHex();
                            this.currDragObj.title.material.color.setHex(this.currDragObj.material.color.getHex());
                        }

                        break;
                    }
                }
                // Check if the selected object is the table object (center)
                if (this.currDragObj.type == 'table') {
                    // Set table object colour
                    this.currDragObj.material.color.setHex(this.tableColors[0]);
                    // Set all other column objects colour
                    this.addedObj.forEach((obj) => {
                        if (this.objects[obj].type == 'column') {
                            // objects[obj].material.color.setHex(tableColors[obj]);
                            this.objects[obj].material.color.setHex(this.tableColors[1]);
                        }
                    });

                    // Remove all column text/labels
                    this.objects.forEach(function (obj) {
                        obj.abbr.visible = false;
                    });

                    this.currDragObj.abbr.visible = true;
                    // Only turn table dragging on if at lease 1 column exists
                    if (this.addedObj.length >= 1) { this.isTableDragging = true; }

                }
            }
            else {  // Set colour of first added object and text/label
                if (this.currDragObj.material.color.getHex() == 0xffffff) {
                    this.currDragObj.material.color.setHex(Math.random() * 0xffffff);
                    // Save objects original colour
                    this.originalColors[this.currDragObj.num] = this.currDragObj.material.color.getHex();
                    this.currDragObj.title.material.color.setHex(this.currDragObj.material.color.getHex());
                }
                this.addedObj.push(this.currDragObj.num); // Add selected object to list
            }
        }

        // swipedata check
        if (this.intersectsObj.length < 1 && this.currDragObj == undefined) {  // Nothing was touched (page switch)

            this.swipedata(event, 'start');
        }
    }


    public onTouchEnd(event) {

        event.stopImmediatePropagation();

        this.onMouseUp(event);
    }


    public onMouseUp(event) {

        //event.preventDefault();
        event.stopImmediatePropagation();

        //var rect = this.renderer.domElement.getBoundingClientRect();

        //this.mouse.x = ((event.x - rect.left) / rect.width) * 2 - 1;
        //this.mouse.y = - ((event.y - rect.top) / rect.height) * 2 + 1;

        // Check if entire table is being dragged
        if ((typeof this.currDragObj != "undefined") && (this.currDragObj != null)) {

            if (this.isTableDragging) {
                this.clearGridPositions();
                this.repositionColumns();
                this.currDragObj = this.objects[0];
                // Loop through all objects in table
                this.addedObj.forEach((place) => {
                    // Set objects color back to original color
                    this.objects[place].material.color.setHex(this.originalColors[place]);
                    this.objects[place].abbr.visible = true;  // Make abbreviated title/label visible
                    // Set objects location back to original grid placement locations
                    this.objects[place].rotation.x = this.grid[this.objects[place].place].rotx;
                    this.objects[place].position.x = this.grid[this.objects[place].place].posx;
                    this.objects[place].position.y = this.grid[this.objects[place].place].posy;
                    this.objects[place].gravity = this.objects[place].place / 3; // Reset objects gravity increment
                    //objects[place].scale.set(1, 1, 1);
                    //objects[place].abbr.scale.set(2, 2, 2);
                });

                this.currDragObj.abbr.scale.set(2, 2, 2);  // Down scale title/label back to original size
                this.currDragObj.scale.set(1, 1, 1);       // Down scale table object back to original size
                this.shadowTitle(this.currDragObj, 'left');                  // Set all abbreviated titles/labels back to grid home positions

                //disposeObjectsFromScene()

                this.isTableDragging = false;              // Turn off table dragging
                this.impact = false;                       // Remove gravity impact
                this.tableScale = 0.0;
            }
            else if (this.resetTable) {
                // Reset grid placements
                // grid.forEach(function(place) {
                //     place.placed = false;
                // });
                this.clearGridPositions();
                // Remove all objects from added table list
                this.addedObj.length = 0;

                this.keys = Object.keys(this.data);

                if (this.currDragObj.type == 'table' && this.tableSaved) {
                    for (var i = 0; i < this.savedTables.length; i++) {
                        if (this.savedTables[i].tableUuid == this.currDragObj.uuid) {
                            this.removeObjectsFromScene(this.savedTables[i].objects);
                            this.savedTables[i].objects = [];
                            this.savedTables[i].placed = false;
                            this.savedTables[i].tableUuid = "";
                            break;
                        }
                    }
                }
                else if (this.currDragObj.type == 'table' && this.tableRemoved) {
                    for (var i = 0; i < this.removedTables.length; i++) {
                        if (this.removedTables[i].tableUuid == this.currDragObj.uuid) {
                            this.removeObjectsFromScene(this.removedTables[i].objects);
                            this.removedTables[i].objects = [];
                            this.removedTables[i].placed = false;
                            this.removedTables[i].tableUuid = "";
                            break;
                        }
                    }
                }
                else {
                    this.removeObjectsFromScene(this.objects);
                }

                //if (cloneObjects.length > 0) { removeObjectsFromScene(cloneObjects); cloneObjects = []; }

                this.buildDataObjects(this.keys.length);

                // Deactivate reset table flag
                this.resetTable = false;
                this.tableSaved = false;
                this.tableRemoved = false;
                this.currDragObj = null;
                this.tableObj = null;
            }
            else {  // Set object back to original color
                this.currDragObj.material.color.setHex(this.originalColors[this.currDragObj.num]);

                //change
                if ((this.currDragObj.type == 'table') && (this.addedObj.length == 1) && (this.tableObj == undefined)) {
                    var object: any;
                    object = Object;
                    this.keys = object.values(this.data[this.currDragObj.name]);

                    this.objects.forEach((obj) => {

                        if (obj.type == 'table') {

                            this.tableObj = obj.clone();
                            this.tableObj.material = obj.material.clone();
                            this.tableObj.title = obj.title.clone();
                            this.tableObj.title.material = obj.title.material.clone();
                            this.tableObj.abbr = obj.abbr.clone();
                            this.tableObj.abbr.material = obj.abbr.material.clone();

                            this.tableObj.gravity = obj.gravity;
                            this.tableObj.num = '0';//obj.num;
                            this.tableObj.place = obj.place;
                            this.tableObj.type = obj.type;

                            //tableObj.saved = false;

                            this.tableObj.xcord = obj.xcord;
                            this.tableObj.ycord = obj.ycord;
                            this.tableObj.zcord = obj.zcord;

                            this.scene.add(this.tableObj.title);
                            this.scene.add(this.tableObj.abbr);
                            this.scene.add(this.tableObj);

                        }

                        this.scene.remove(obj.title);
                        this.scene.remove(obj.abbr);
                        this.scene.remove(obj);
                    });

                    this.removeObjectsFromScene(this.objects);

                    this.buildDataObjects(this.keys.length);

                    this.objects.push(this.tableObj);

                    this.addedObj.length = 0;

                    this.addedObj.push(this.tableObj.num);
                }
            }
        }

        this.isDragging = false; // Turn off dragging
        this.oldX = 0; this.oldY = 0; // Reset previous dragged object position
        // Check if object is back in list after dragging stopped to remove from added list
        if ((this.currDragObj != "undefined") && (this.currDragObj != null)) {
            // change
            //Check if object has been dragged to grid
            if (this.currDragObj.position.x < this.halfObjectWidth) {
                // Check if it is a table object

            }
            //if ((currDragObj.position.x > halfWindowWidth - 11) && ) {// || (currDragObj.position.x < halfWindowWidth)) {
            if (((this.currDragObj.position.x > this.halfObjectWidth) &&
                (this.currDragObj.position.x < this.halfWindowWidth - this.objectWidth)) ||
                (this.currDragObj.position.x > this.listStartX - this.quarterObjectWidth)) { //halfWindowWidth - quarterObjectWidth)) {
                this.grid[this.currDragObj.place].placed = false;   // Open up grid place
                this.currDragObj.place = 0;                    // Set objects placement to 0
                this.currDragObj.type = "";                    // Reset object type
                this.removeObject(this.addedObj, this.currDragObj.num);  // Remove object from list
                this.currDragObj.abbr.visible = false;   // Hide abbreviated title/label

                // Reposition all objects after removal if at least 1 exists in grid
                if (this.addedObj.length > 0) {
                    // Reposition objects in grid
                    this.repositionColumns();
                }
            }
        }
        //else if (this.intersectsObj.length < 1 && this.currDragObj == undefined) {
        else {
            /* Page Swipe (as no object is selected */
            this.swipedata(event, 'end');

        }

        this.intersectsObj = null;
        this.currDragObj = null;
    }

    swipedata(e: any, when: string): void {

        e.preventDefault();

        var currX = 0;
        var currY = 0;

        if (e.type.includes('mouse')) {

            currX = e.x;
            currY = e.y;
        } else {

            currX = e.changedTouches[0].pageX;
            currY = e.changedTouches[0].pageY;
        }

        const coord: [number, number] = [currX, currY];
        const time = new Date().getTime();

        if (when === 'start') {
            this.swipeCoord = coord;
            this.swipeTime = time;
        }
        else if ((when === 'end') && (this.swipeCoord != undefined)) {

            const direction = [coord[0] - this.swipeCoord[0], coord[1] - this.swipeCoord[1]];
            const duration = time - this.swipeTime;

            if ((duration > 250 //Rapid
                && Math.abs(direction[0]) > 30) //Long enough
                && (Math.abs(direction[0]) > Math.abs(direction[1] * 3))) { //Horizontal enough
                const swipe = direction[0] < 0 ? 'next' : 'previous';

                if (swipe == "next") {

                    this.onNext();
                }
                else if (swipe == "previous") {

                    this.onStart();
                }

            }
        }
    }

    //private onTouchMove(event) {

    //    event.stopImmediatePropagation();

    //    event.clientX = event.touches[0].clientX;
    //    event.clientY = event.touches[0].clientY;

    //    this.onMouseMove(event);
    //}

    private onMouseMove(event) {

        event.preventDefault();
        event.stopImmediatePropagation();

        // Rotate current touched/dragged object
        if (typeof this.intersectsObj != "undefined") {
            if (this.intersectsObj != null && typeof this.intersectsObj[0] != "undefined") {

                this.currDragObj = this.intersectsObj[0].object;

                this.setCurrentObjectPosition(event);

                // Direction 'left', 'right', 'up', 'down' comes from getTouchDirection/getMouseDirection event functions
                /*###############################################################################
                  #                             TABLE DRAG                                      #
                  ###############################################################################*/
                // Check if current dragged object is table object and at least 1 column exists
                if (this.currDragObj.type == 'table' && this.addedObj.length >= 1 && this.isTableDragging) {

                    // Loop through all objects added to grid
                    for (var i = 0; i < this.addedObj.length; i++) { // Set to
                        // Get the objects difference in position from main table object
                        var diffx = this.grid[this.objects[this.addedObj[i]].place].posx - this.grid[0].posx;
                        var diffy = this.grid[this.objects[this.addedObj[i]].place].posy - this.grid[0].posy;
                        // Set objects location relative to dragged table object
                        this.objects[this.addedObj[i]].position.x = this.currDragObj.position.x + diffx;
                        this.objects[this.addedObj[i]].position.y = this.currDragObj.position.y + diffy;
                    }

                    this.shadowTitle(this.currDragObj, 'up');

                    /*##################### TABLE DRAG RIGHT TO LIST #####################*/
                    // Check if table is dragged over to list location
                    if (this.currDragObj.position.x > this.halfWindowWidth - this.objectWidth) {

                        this.isTableDragging = false;
                        this.resetTable = true;

                        this.objects.forEach(function (obj) {
                            obj.rotation.x = 0;
                            obj.rotation.y += 0.005;
                            obj.position.x = obj.xcord;
                            obj.position.y = obj.ycord;
                        });

                        this.currDragObj.scale.set(1, 1, 1);
                    }
                    // Check if table is dragged up to 'Save' table location (top)
                    /*##################### TABLE DRAG UP TO SAVE TABLE ROW #####################*/
                    else if (this.currDragObj.position.y > (this.halfWindowHeight + this.halfObjectWidth)) {

                        var tableIndex = this.getIndexOfTable(this.removedTables);
                        this.removedTables[tableIndex].placed = false;

                        if (this.getIndexOfTable(this.savedTables) == 0) {
                            if (this.currDragObj.hasOwnProperty("saved")) { delete this.currDragObj.saved; }
                        }

                        for (var h = 1; h < this.objects.length; h++) {
                            if ((this.currDragObj.saved != undefined) && (this.currDragObj.saved)) {
                                if (this.savedTables[h].objects[0].uuid == this.currDragObj.uuid) {

                                    break;
                                }
                            }
                            else {
                                if (this.savedTables[h].placed == false) {
                                    break;
                                }
                            }
                        }

                        this.currDragObj.scale.set(1, 1, 1);

                        this.savedTables[h].objects = this.cloneObjectArray(this.objects);

                        if (this.savedTables[h].placed == false) {
                            this.savedTables[h].placed = true;
                        }

                        this.savedTables[h].tableUuid = this.savedTables[h].objects[0].uuid;

                        this.saveTable(this.savedTables[h]);

                        // Convert saved table to JSON
                        var jsonTable = this.convertObjectsToJson(this.savedTables[h]);
                        // Attempt to send table to server for saving
                        if (jsonTable != undefined) {
                            // Save table to server
                            var sentToServer = this.saveTableToServer(jsonTable);
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

                        //this.dragControls = new THREE.DragControls(this.savedTables[h].objects, this.camera, this.renderer.domElement);

                        this.isTableDragging = false;
                        this.resetTable = true;

                        this.removeObjectsFromScene(this.objects);

                        this.repositionTables(this.removedTables);
                    }
                    /*##################### TABLE DRAG UP TO SAVE #####################*/
                    else if (this.currDragObj.position.y > (this.halfWindowHeight / 3)) {
                        for (var i = 0; i < this.addedObj.length; i++) {

                            if (this.objects[this.addedObj[i]].type == 'column') {

                                if (!this.impact) {

                                    this.applyGravity(this.currDragObj, this.addedObj[i]);
                                }
                                else {
                                    this.objects[this.addedObj[i]].position.x = this.currDragObj.position.x;
                                    this.objects[this.addedObj[i]].position.y = this.currDragObj.position.y;
                                    // Place the abbreviated title/label based drag up or drag down
                                    if (this.currDragObj.position.y > 0) { // Drag up to SAVE table
                                        this.currDragObj.abbr.position.y = this.currDragObj.position.y - this.objectWidth;
                                    } else {                          // Drag down to REMOVE table
                                        this.currDragObj.abbr.position.y = this.currDragObj.position.y + this.halfObjectWidth;
                                    }
                                    // After gravity threshold, scale table object to larger size for save/remove placeholder
                                    this.tableScale += (0.2 / this.addedObj.length);
                                    if (this.tableScale < 0.5) {
                                        this.currDragObj.scale.set(1 + this.tableScale, 1 + this.tableScale, 1 + this.tableScale);
                                    }
                                }
                            }
                        }
                    }
                    // Check if table is dragged down to 'Remove' table location (bottom)
                    /*##################### TABLE DRAG DOWN TO REMOVE #####################*/
                    else if (this.currDragObj.position.y < -(this.halfWindowHeight + this.halfObjectWidth)) {

                        var tableIndex = this.getIndexOfTable(this.savedTables);
                        this.savedTables[tableIndex].placed = false;

                        if (this.getIndexOfTable(this.removedTables) == 0) {
                            if (this.currDragObj.hasOwnProperty("saved")) { delete this.currDragObj.saved; }
                        }

                        for (var h = 1; h < this.objects.length; h++) {
                            if ((this.currDragObj.saved != undefined) && (this.currDragObj.saved)) {
                                if (this.removedTables[h].objects[0].uuid == this.currDragObj.uuid) {

                                    break;
                                }
                            }
                            else {
                                if (this.removedTables[h].placed == false) {
                                    break;
                                }
                            }
                        }

                        this.currDragObj.scale.set(1, 1, 1);

                        this.removedTables[h].objects = this.cloneObjectArray(this.objects);

                        if (this.removedTables[h].placed == false) {
                            this.removedTables[h].placed = true;
                        }

                        this.removedTables[h].tableUuid = this.removedTables[h].objects[0].uuid;

                        this.removeTable(this.removedTables[h]);

                        //this.dragControls = new THREE.DragControls(this.removedTables[h].objects, this.camera, this.renderer.domElement);

                        this.isTableDragging = false;
                        this.resetTable = true;

                        this.removeObjectsFromScene(this.objects);

                        this.repositionTables(this.savedTables);
                    }
                    /*##################### TABLE DRAG DOWN TO REMOVE #####################*/
                    else if (this.currDragObj.position.y < -(this.halfWindowHeight / 3)) {

                        for (var i = 0; i < this.addedObj.length; i++) {

                            if (this.objects[this.addedObj[i]].type == 'table') {
                                this.objects[this.addedObj[i]].material.color.setHex(this.tableColors[2]);
                            }
                            else {
                                this.objects[this.addedObj[i]].material.color.setHex(this.tableColors[3]);

                                if (!this.impact) {

                                    this.applyGravity(this.currDragObj, this.addedObj[i]);
                                }
                                else {
                                    this.objects[this.addedObj[i]].position.x = this.currDragObj.position.x;
                                    this.objects[this.addedObj[i]].position.y = this.currDragObj.position.y;
                                    // Place the abbreviated title/label based drag up or drag down
                                    if (this.currDragObj.position.y > 0) { // Drag up to SAVE table
                                        this.currDragObj.abbr.position.y = this.currDragObj.position.y - this.objectWidth;
                                    } else {                          // Drag down to REMOVE table
                                        this.currDragObj.abbr.position.y = this.currDragObj.position.y + this.halfObjectWidth;
                                    }
                                    // After gravity threshold, scale table object to larger size for save/remove placeholder
                                    this.tableScale += (0.2 / this.addedObj.length);
                                    if (this.tableScale < 0.5) {
                                        this.currDragObj.scale.set(1 + this.tableScale, 1 + this.tableScale, 1 + this.tableScale);
                                    }
                                }
                            }
                        }
                    }
                    /*##################### TABLE DRAG DOWN TO GRID #####################*/
                    // Reset gravity if table dragged back down to initial grid placement
                    else if ((this.currDragObj.position.y < (this.halfWindowHeight / 2)) && (this.impact)) {
                        // Loop through all objects in table
                        this.addedObj.forEach((place) => {
                            // Set objects gravity back to original gravity value
                            this.objects[place].gravity = this.objects[place].place / 3; // Reset objects gravity increment
                            // Set objects colour back to table SAVE colour
                            if (this.objects[place].type == 'table') {
                                this.objects[place].material.color.setHex(this.tableColors[0]);
                            } else {
                                this.objects[place].material.color.setHex(this.tableColors[1]);
                            }
                        });

                        this.currDragObj.scale.set(1, 1, 1);
                        this.impact = false;
                        this.tableScale = 0.0;
                    }
                }
                /*##################### DRAG LEFT TO GRID #####################*/
                else if (this.left) {
                    if (this.currDragObj.rotation.x < 1.5) {
                        this.currDragObj.rotation.x += this.rotationV;
                    }

                    if (this.currDragObj.position.x < this.halfWindowWidth - this.objectWidth) {

                        if ((this.currDragObj.place == 0) && (this.currDragObj.type == '')) {
                            for (var i = 0; i < this.grid.length; i++) {
                                if (this.grid[i].placed == false) {
                                    this.repositionObject(this.currDragObj, i);
                                    this.currDragObj.type = this.grid[i].type;
                                    this.currDragObj.place = this.grid[i].place;
                                    this.grid[i].placed = true;
                                    this.currDragObj.gravity = 1.0; //currDragObj.place / 3;
                                    //this.shadowTitle(this.currDragObj, 'left');
                                    break;
                                }
                            }

                            this.shadowTitle(this.currDragObj, 'left');
                            this.isDragging = false;
                        }
                        else {
                            if (this.currDragObj != undefined) {

                                this.repositionObject(this.currDragObj, this.currDragObj.place);
                                this.shadowTitle(this.currDragObj, 'left');
                            }
                        }
                    }
                    this.shadowTitle(this.currDragObj, 'left');
                }
                /*##################### DRAG RIGHT TO GRID #####################*/
                else if (this.right) {

                    if (this.currDragObj.rotation.x >= 0.000) {
                        this.currDragObj.rotation.x -= this.rotationV;
                    }

                    if (this.currDragObj.position.x > this.halfObjectWidth) {
                        this.currDragObj.rotation.x = 0;
                        this.currDragObj.rotation.y += 0.005;
                        this.currDragObj.position.x = this.currDragObj.xcord;
                        this.currDragObj.position.y = this.currDragObj.ycord;
                        this.currDragObj.gravity = 0;
                    }

                    this.shadowTitle(this.currDragObj, 'right');
                }
            }
        }

        //this.render();
    }

    public getTouchDirection(event) {

        event.clientX = event.touches[0].clientX;
        event.clientY = event.touches[0].clientY;

        this.getMouseDirection(event);
    }

    public getMouseDirection(event) {

        event.stopImmediatePropagation();

        // Find horizontal direction
        if (this.oldX < event.clientX) {
            this.right = true;
            this.left = false;
            this.xDirection = 'right';
        } else {
            this.left = true;
            this.right = false;
            this.xDirection = 'left';
        }

        // Find vertical direction
        if (this.oldY < event.clientY) {
            this.down = true;
            this.up = false;
            this.yDirection = 'down';
        } else {
            this.up = true;
            this.down = false;
            this.yDirection = 'up';
        }

        this.oldX = event.clientX;
        this.oldY = event.clientY;

        this.onMouseMove(event);
    }

    private setCurrentObjectPosition(event) {

        var mv = new THREE.Vector3(
            (event.clientX / window.innerWidth) * 2 - 1,
            -(event.clientY / window.innerHeight) * 2 + 1,
            0.5);

        mv.unproject(this.camera);

        var dir = mv.sub(this.camera.position).normalize();
        var distance = - this.camera.position.z / dir.z;

        var pos = this.camera.position.clone().add(dir.multiplyScalar(distance));

        this.currDragObj.position.x = pos.x
        this.currDragObj.position.y = pos.y;
    }

    private onWindowResize() {

        this.camera.aspect = window.innerWidth / window.innerHeight;
        this.camera.updateProjectionMatrix();
        this.renderer.setSize(window.innerWidth, window.innerHeight);
    }

    //@HostListener('window:resize', ['$event'])
    //public onResize(event: Event) {
    //    this.canvas.style.width = "100%";
    //    this.canvas.style.height = "100%";
    //    console.log("onResize: " + this.canvas.clientWidth + ", " + this.canvas.clientHeight);

    //    this.camera.aspect = this.getAspectRatio();
    //    this.camera.updateProjectionMatrix();
    //    this.renderer.setSize(this.canvas.clientWidth, this.canvas.clientHeight);
    //    this.render();
    //}

    @HostListener('document:keypress', ['$event'])
    public onKeyPress(event: KeyboardEvent) {
        console.log("onKeyPress: " + event.key);
    }


    /* ANIMATE & RENDER LOOP */
    protected animate() {

        requestAnimationFrame(this.animateCallback.callAnimate);

        // Check if an object has been selected and stop it's rotation if so
        if (this.objects != undefined) {
            this.objects.forEach((element) => {
                if (this.addedObj.length > 0) {
                    // Loop through currently touched/dragged objects
                    for (var i = 0; i < this.addedObj.length; i++) {
                        // If already found (touched/dragged) stop horizontal rotation
                        var found = $.inArray(element.num, this.addedObj);
                        if (found != -1) {
                            element.rotation.y = 0.000;
                        } // If not found (touched/dragged) then continue rotating horizontally
                        else {
                            element.rotation.y += 0.005;
                            this.objects[0].rotation.y = 0.000;
                        }
                    }
                }
                else { // If no touched/dragged objects exist then rotate horizontally
                    if (this.grid[element.num].type == 'table') {
                        element.rotation.y = 0.000;
                    } else {
                        element.rotation.y += 0.005;
                    }
                }
            });
        }

        //this.controls.update();
        this.render();
    }

    public render() {

        this.renderer.render(this.scene, this.camera);
    }


    /* DATA SCAFFOLDING */

    private buildDataGrid() {

        var cell = {
            place: 0,
            placed: false,
            type: "table",
            posx: -this.objectWidth,
            posy: 0,
            posz: 0,
            rotx: 1.5, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0
        }
        this.grid.push(cell);

        cell = {
            place: 1,
            placed: false,
            type: "column",
            posx: -this.objectWidth + this.halfObjectWidth - 10,
            posy: this.halfObjectWidth * 1.5 + 5,
            posz: 0,
            rotx: 1.5, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0
        }
        this.grid.push(cell);

        cell = {
            place: 2,
            placed: false,
            type: "column",
            posx: -this.objectWidth + this.halfObjectWidth - 10,
            posy: -this.halfObjectWidth * 1.5 - 5,
            posz: 0,
            rotx: 1.5, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0
        }
        this.grid.push(cell);

        cell = {
            place: 3,
            placed: false,
            type: "column",
            posx: -this.objectWidth * 2 + 20,
            posy: 0,
            posz: 0,
            rotx: 1.5, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0
        }
        this.grid.push(cell);

        cell = {
            place: 4,
            placed: false,
            type: "column",
            posx: -20,
            posy: 0,
            posz: 0,
            rotx: 1.5, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0
        }
        this.grid.push(cell);

        cell = {
            place: 5,
            placed: false,
            type: "column",
            posx: -this.objectWidth - this.halfObjectWidth + 10,
            posy: this.halfObjectWidth * 1.5 + 5,
            posz: 0,
            rotx: 1.5, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0
        }
        this.grid.push(cell);

        cell = {
            place: 6,
            placed: false,
            type: "column",
            posx: -this.objectWidth - this.halfObjectWidth + 10,
            posy: -this.halfObjectWidth * 1.5 - 5,
            posz: 0,
            rotx: 1.5, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0
        }
        this.grid.push(cell);

        cell = {
            place: 7,
            placed: false,
            type: "column",
            posx: this.halfObjectWidth / 2 + 20,
            posy: this.halfObjectWidth * 1.5 + 5,
            posz: 0,
            rotx: 1.5, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0
        }
        this.grid.push(cell);

        cell = {
            place: 8,
            placed: false,
            type: "column",
            posx: (-this.objectWidth * 2) - this.halfObjectWidth + 30,
            posy: this.halfObjectWidth * 1.5 + 5,
            posz: 0,
            rotx: 1.5, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0
        }
        this.grid.push(cell);

        var cell = {
            place: 9,
            placed: false,
            type: "column",
            posx: -this.objectWidth,
            posy: this.objectWidth * 2 - this.halfObjectWidth + 10,
            posz: 0,
            rotx: 1.5, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0
        }
        this.grid.push(cell);

        cell = {
            place: 10,
            placed: false,
            type: "",
            posx: this.listStartX,
            posy: this.listStartY,
            posz: 0,
            rotx: 1.5, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0
        }
        this.grid.push(cell);

    }

    private buildDataBlock() {

        this.data = {
            "Movies": [
                "Title", "Released", "Origin", "Location", "Company", "Budget", "Director", "Producer", "Actors", "Gross"
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

    private buildSavedGrid() {

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
        this.savedTables.push(cell);

        cell = {
            place: 1,
            placed: false,
            type: "table",
            posx: this.savedStartX,//var listStartX = (window.innerWidth / 2) - 10;,
            posy: this.savedStartY,
            posz: 0,
            rotx: 0, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0,
            objects: [],
            table: "",
            tableUuid: ""
        }
        this.savedTables.push(cell);

        cell = {
            place: 2,
            placed: false,
            type: "table",
            posx: this.savedStartX + this.savedObjWidth + this.savedTableSpace,
            posy: this.savedStartY,
            posz: 0,
            rotx: 0, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0,
            objects: [],
            table: "",
            tableUuid: ""
        }
        this.savedTables.push(cell);

        cell = {
            place: 3,
            placed: false,
            type: "table",
            posx: this.savedStartX + (this.savedObjWidth + this.savedTableSpace) * 2,
            posy: this.savedStartY,
            posz: 0,
            rotx: 0, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0,
            objects: [],
            table: "",
            tableUuid: ""
        }
        this.savedTables.push(cell);

        cell = {
            place: 4,
            placed: false,
            type: "table",
            posx: this.savedStartX + (this.savedObjWidth + this.savedTableSpace) * 3,
            posy: this.savedStartY,
            posz: 0,
            rotx: 0, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0,
            objects: [],
            table: "",
            tableUuid: ""
        }
        this.savedTables.push(cell);

        cell = {
            place: 5,
            placed: false,
            type: "table",
            posx: this.savedStartX + (this.savedObjWidth + this.savedTableSpace) * 4,
            posy: this.savedStartY,
            posz: 0,
            rotx: 0, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0,
            objects: [],
            table: "",
            tableUuid: ""
        }
        this.savedTables.push(cell);

        cell = {
            place: 6,
            placed: false,
            type: "table",
            posx: this.savedStartX + (this.savedObjWidth + this.savedTableSpace) * 5,
            posy: this.savedStartY,
            posz: 0,
            rotx: 0, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0,
            objects: [],
            table: "",
            tableUuid: ""
        }
        this.savedTables.push(cell);

        cell = {
            place: 7,
            placed: false,
            type: "table",
            posx: this.savedStartX + (this.savedObjWidth + this.savedTableSpace) * 6,
            posy: this.savedStartY,
            posz: 0,
            rotx: 0, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0,
            objects: [],
            table: "",
            tableUuid: ""
        }
        this.savedTables.push(cell);

        cell = {
            place: 8,
            placed: false,
            type: "table",
            posx: this.savedStartX + (this.savedObjWidth + this.savedTableSpace) * 7,
            posy: this.savedStartY,
            posz: 0,
            rotx: 0, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0,
            objects: [],
            table: "",
            tableUuid: ""
        }
        this.savedTables.push(cell);

        cell = {
            place: 9,
            placed: false,
            type: "table",
            posx: this.savedStartX + (this.savedObjWidth + this.savedTableSpace) * 8,
            posy: this.savedStartY,
            posz: 0,
            rotx: 0, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0,
            objects: [],
            table: "",
            tableUuid: ""
        }
        this.savedTables.push(cell);

        cell = {
            place: 10,
            placed: false,
            type: "table",
            posx: this.savedStartX + (this.savedObjWidth + this.savedTableSpace) * 9,
            posy: this.savedStartY,
            posz: 0,
            rotx: 0, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0,
            objects: [],
            table: "",
            tableUuid: ""
        }
        this.savedTables.push(cell);

    }

    private buildRemovedGrid() {

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
        this.removedTables.push(cell);

        cell = {
            place: 1,
            placed: false,
            type: "table",
            posx: this.removedStartX,
            posy: this.removedStartY,
            posz: 0,
            rotx: 0, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0,
            objects: [],
            table: ""
        }
        this.removedTables.push(cell);

        cell = {
            place: 2,
            placed: false,
            type: "table",
            posx: this.removedStartX + this.savedObjWidth + this.savedTableSpace,
            posy: this.removedStartY,
            posz: 0,
            rotx: 0, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0,
            objects: [],
            table: ""
        }
        this.removedTables.push(cell);

        cell = {
            place: 3,
            placed: false,
            type: "table",
            posx: this.removedStartX + (this.savedObjWidth + this.savedTableSpace) * 2,
            posy: this.removedStartY,
            posz: 0,
            rotx: 0, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0,
            objects: [],
            table: ""
        }
        this.removedTables.push(cell);

        cell = {
            place: 4,
            placed: false,
            type: "table",
            posx: this.removedStartX + (this.savedObjWidth + this.savedTableSpace) * 3,
            posy: this.removedStartY,
            posz: 0,
            rotx: 0, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0,
            objects: [],
            table: ""
        }
        this.removedTables.push(cell);

        cell = {
            place: 5,
            placed: false,
            type: "table",
            posx: this.removedStartX + (this.savedObjWidth + this.savedTableSpace) * 4,
            posy: this.removedStartY,
            posz: 0,
            rotx: 0, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0,
            objects: [],
            table: ""
        }
        this.removedTables.push(cell);

        cell = {
            place: 6,
            placed: false,
            type: "table",
            posx: this.removedStartX + (this.savedObjWidth + this.savedTableSpace) * 5,
            posy: this.removedStartY,
            posz: 0,
            rotx: 0, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0,
            objects: [],
            table: ""
        }
        this.removedTables.push(cell);

        cell = {
            place: 7,
            placed: false,
            type: "table",
            posx: this.removedStartX + (this.savedObjWidth + this.savedTableSpace) * 6,
            posy: this.removedStartY,
            posz: 0,
            rotx: 0, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0,
            objects: [],
            table: ""
        }
        this.removedTables.push(cell);

        cell = {
            place: 8,
            placed: false,
            type: "table",
            posx: this.removedStartX + (this.savedObjWidth + this.savedTableSpace) * 7,
            posy: this.removedStartY,
            posz: 0,
            rotx: 0, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0,
            objects: [],
            table: ""
        }
        this.removedTables.push(cell);

        cell = {
            place: 9,
            placed: false,
            type: "table",
            posx: this.removedStartX + (this.savedObjWidth + this.savedTableSpace) * 8,
            posy: this.removedStartY,
            posz: 0,
            rotx: 0, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0,
            objects: [],
            table: ""
        }
        this.removedTables.push(cell);

        cell = {
            place: 10,
            placed: false,
            type: "table",
            posx: this.removedStartX + (this.savedObjWidth + this.savedTableSpace) * 9,
            posy: this.removedStartY,
            posz: 0,
            rotx: 0, roty: 0, rotz: 0,
            scax: 0, scay: 0, scaz: 0,
            objects: [],
            table: ""
        }
        this.removedTables.push(cell);

    }

    // END OF DATA SCAFFOLDING

    ngOnDestroy() {

        this.disposeObjectsFromScene(this.objects);
        //this.removeObjectsFromScene(this.objects);

    }
}

