// Refer to https://blog.cloudboost.io/capturing-camera-using-angular-5-2e177c68201f

import { Component, ElementRef, ViewChild, OnInit, OnDestroy, HostListener, Inject } from '@angular/core';
import { OcrService } from '../../services/ocr.service';
import { NlpService } from '../../services/nlp.service';
import { Router } from '@angular/router';
import * as $ from 'jquery';
import * as interact from 'interactjs';
import { DataDialogComponent } from '../datadialog/datadialog.component';

// Pop-up Dialog
import { MatDialog, MatDialogRef, MAT_DIALOG_DATA } from '@angular/material';
import { Observable } from 'rxjs/Observable';
import { Subscription } from 'rxjs';


@Component({
    selector: 'ocr',
    templateUrl: './ocr.component.html',
    styleUrls: ['./webcamControl.component.css',
        './ocr.component.css']
})
export class OcrComponent implements OnInit, OnDestroy {

    @ViewChild('videoElement') videoElement: any;
    @ViewChild('buttonElement') buttonElement: any;
    @ViewChild('imageDisplayArea') imageElement: any;

    private isMobile: boolean = false; 

    @ViewChild('canvas')
    private canvasRef: ElementRef;

    /* WebCam */
    readonly STR_VIDEO_ICON: string = "glyphicon glyphicon-facetime-video";
    readonly STR_VIDEO_CANCEL_ICON: string = "glyphicon glyphicon-ban-circle";
    readonly STR_CAM_ON: string = "Turn On";
    readonly STR_CAM_OFF: string = "Turn Off";
    readonly STR_TAKE_PIC_ICON: string = "glyphicon glyphicon-camera";
    readonly STR_RESUME_CAM: string = "glyphicon glyphicon-play";

    video: any;
    button: any;
    imageFromFile: any;
    picture: any;
    localstream: any;
    displayControls = true;
    isCamTurnOn = true;
    tookShot = false;
    strCamTurnOnOff: string = this.STR_CAM_ON;
    strCamTurnOnOffIcon: string = this.STR_VIDEO_ICON;
    strTakePic: string = this.STR_TAKE_PIC_ICON;

    private icon: any;
    private localimage: any;
    private dataView: any;
    private shotSuppress = false;

    /* Screen Sections */
    private discardWidth: number;
    private selectWidth: number;
    private saveWidth: number;
    private offsetWidth: number;
    private offsetHeight: number;
    private offsetMargin: number;
    private offsetStart: number;

    /* Page Swipe */
    private swipeCoord?: [number, number];
    private swipeTime?: number;

    /* Page Scroll */
    private startScrollY: number;
    private currScrollTop: number;
    private scrollDiff: number = 0;

    fileToUpload: File;
    fileType: string | undefined;
    imgForDisplay: string;

    /* Data Profile */
    private dataProfile: DataProfile;
    entities: any = [];
    statusNote: string;
    statusCode: string;
    resultCode: string;
    statusCode_ocr: string;
    statusCode_nlp: string;
    locale: string;
    language: string;
    textAfterOcr: string;
    //textAfterNlp: string;
    textAfterNlp: any;
    private timer: Observable<any>;
    private subscription: Subscription;

    /* Angular DnD 'Interact JS' */
    private data: any;
    private interaction: any;
    private eventTypes: any;
    private startPos: any;
    private threshHoldParent: string;
    private selectionMainElementCount: number;
    private keepData: string;

    private removeScrollOffset: number;
    private selectScrollOffset: number;
    private saveScrollOffset: number;

    private touchCount: number = 0;
    private dragPositionSet: boolean = false;

    private saveObjList: any = [];
    private mergeObject: any;
    private mergeTypes: any = [];
    //private mergedObjectsId: string;
    private mergeToObjectId: string;
    private currObjectId: string;

    //private currTouches: any = [];

    /* Material Dialog */
    private dialogId: string;

    /* CSS COLOUR PALLET */
    private discardColour: string = '#d96459';
    private selectColour: string = '#f2ae72';
    private keepColour: string = '#588c7e';

    private defaultColour: string = 'white';
    private hoverColour: string = '#ffeead';
    private pressedColour: string = '#ffcc5c';

    private removeColour: string = '#ff8480';//'#ff6f69'; 
    private saveColour: string = '#96ceb4';

    private discardArrow: string = 'darkred';
    private saveArrow: string = 'darkgreen';

    private topFadeColour: string = '#b8a9c9';
    private bottomFadeColour: string = 'white';

    private completedButton: string = '#5b9aa0';

    private antiDefaultColour: string = '#333';

    // Dialog Pop-up
    private dialogResult: string;
    private type: string;
    private value: string;
    private options: any = [];
    private startTime: number;

    constructor(private ocrService: OcrService,
        private nlpService: NlpService, // Natural Language Processing 
        private router: Router,         // Routing to the other pages on swipe gesture
        public dialog: MatDialog) {     // Pop-up dialog for editing data-types

        this.imgForDisplay = "";
        this.fileType = "";
        this.statusCode_ocr = "";
        this.statusCode_nlp = "";
        this.locale = "";
        this.language = "";
        this.textAfterOcr = "";
        //this.textAfterNlp = "";

    }

    /*  ##############################################################################
        #                         START OF WEB CAM FUNCTIONS                         #
        ##############################################################################  */

    // Pop-up Dialog
    openDialog(options) {

        let dialogRef = this.dialog.open(DataDialogComponent, {

            data: { type: this.type, value: this.value, options: options }
            
        });

        dialogRef.afterClosed().subscribe(result => {
            
            if (result.attributes[0].value != 'Cancelled') {                    // Check if the opened dialog was cancelled

                let dialog: any;
                dialog = document.getElementById(this.dialogId);

                if (dialog.id.includes('merge')) {

                    // Check if merge item has already been merged
                    //if (this.mergeToObjectId.includes('merge')) {

                    //    this.mergeToObjectId = this.extractId(this.mergeToObjectId);
                    //}

                    if (result.value != '') {

                        dialog.firstChild.innerHTML = result.value.replace(/ /g, "_");
                    }
                    else {
                        result.value = dialog.firstChild.innerHTML.replace(/ /g, "_");
                        dialog.firstChild.innerHTML = result.value;
                    }

                    if (this.currObjectId != null || this.mergeToObjectId != null) {

                        // Get dragged over objects IndexInfo
                        var currIndexInfo: any = this.dataProfile.Entities[Number(this.currObjectId)].IndexInfo;
                        // Loop through all dragged objects IndexInfos
                        for (var i = 0; i < currIndexInfo.length; i++) {
                            // Add dragged over objects IndexInfo to Merge into objects IndexInfo
                            this.dataProfile.Entities[Number(this.extractId(this.mergeToObjectId))].IndexInfo.push(currIndexInfo[i]);
                        }
                        // Remove dragged over object from Entities
                        this.dataProfile.Entities.splice(Number(this.currObjectId), 1);

                        // Set new merged data type
                        this.dataProfile.Entities[Number(this.extractId(this.mergeToObjectId))].Type = result.value.replace(/ /g, "_");
                        // Set new merged data value
                        this.dataProfile.Entities[Number(this.extractId(this.mergeToObjectId))].Name = dialog.lastChild.innerText;

                        // Remove previous object that has been merged
                        var saveDataParent: any = document.getElementById('keep');
                        var currMergedObj: any = document.getElementById(this.currObjectId);
                        if (currMergedObj != null) {
                            saveDataParent.removeChild(currMergedObj);
                        }
                    }
                }
                else {

                    if (result.value != '') {
                        dialog[0].innerHTML = result.value.replace(/ /g, "_");
                    }
                    else {

                        result.value = dialog[0].innerHTML.replace(/ /g, "_");
                    }

                    // Get the data profile id number from the dialog id
                    //dialog.id = this.extractId(dialog.id);
                    // Update data profile
                    this.dataProfile.Entities[Number(this.extractId(dialog.id))].Type = result.value;
                }

            } else {

                if (this.mergeObject != null) {

                    console.log('Cancelled');

                    //var objects: any = [];
                    //objects = document.getElementsByClassName('draggable');

                    //for (var i = 0; i < objects.length; i++) {

                    //    if (objects[i].style.display == 'none') {
                    //        objects[i].style.display = 'inline-table';
                    //        objects[i].style.backgroundColor = this.saveColour;
                    //    }
                    //}

                    var currentObj: any = document.getElementById(this.currObjectId);
                    var mergedObj: any = document.getElementById(this.mergeObject.id);
                    currentObj.style.display = 'inline-table';
                    currentObj.style.backgroundColor = this.saveColour;
                    mergedObj.style.display = 'inline-table';
                    mergedObj.style.backgroundColor = this.saveColour;

                    var saveDataParent: any = document.getElementById('keep');
                    //var currMergedObj: any = document.getElementById(this.mergedObjectsId);
                    var currMergedObj: any = document.getElementById('merge-' + this.mergeToObjectId);
                    saveDataParent.removeChild(currMergedObj);
                }
            }

            this.mergeObject = null;
            this.mergeTypes = [];

            this.currObjectId = null;
            this.mergeToObjectId = null;

            result.attributes[0].value = '';                                    // Reset dialog status
            this.switchDialogBackground();                                      // Switch background back to normal

        });

    }

    openMergeDialog(event) {

        if (event.target.localName == 'select') {

            if (event.target.parentElement.nextSibling == null) {
                this.type = event.target.parentElement.firstChild.innerText;
                this.value = event.target.parentElement.lastChild.innerText;
                this.dialogId = event.target.parentElement.id;
            } else {
                this.type = event.target.parentElement.nextSibling.firstChild.innerText;
                this.value = event.target.parentElement.nextSibling.lastChild.innerText;
                this.dialogId = event.target.parentElement.nextSibling.id;
            }
        }
        else if (event.target.localName == 'div') {

            //if (event.target.parentElement.nextSibling == null) {
            if (event.target.firstChild.id.includes('merge')) {
                this.type = event.target.firstChild.innerText;
                this.value = event.target.lastChild.innerText;
                this.dialogId = event.target.id;
            } else {
                this.type = event.target.nextSibling.firstChild.innerText;
                this.value = event.target.nextSibling.lastChild.innerText;
                this.dialogId = event.target.nextSibling.id;
            }
        }
        else if (event.target.localName == 'span') {

            if (event.target.parentElement.nextSibling == null) {
                this.type = event.target.parentElement.firstChild.innerText;
                this.value = event.target.parentElement.lastChild.innerText;
                this.dialogId = event.target.parentElement.id;
            } else {
                this.type = event.target.parentElement.nextSibling.firstChild.innerText;
                this.value = event.target.parentElement.nextSibling.lastChild.innerText;
                this.dialogId = event.target.parentElement.nextSibling.id;
            }
        }

        this.switchDialogBackground();

        this.openDialog(this.mergeTypes);
    }

    ngOnInit() {

        this.isMobile = this.mobileCheck();

        this.video = this.videoElement.nativeElement;
        this.button = this.buttonElement.nativeElement;

        this.imageFromFile = this.imageElement.nativeElement;

        this.start();

        // Camera ON/OFF icon
        this.icon = document.getElementById('camera');
        // Open Local Image (Icon)
        this.localimage = document.getElementById('localimage');
        // Open Local Image (Folder)
        var fileOpen = document.getElementById('fileopen');
        // Data View (switch page)
        this.dataView = document.getElementById('data-view');

        /* Angular DnD */
        this.setBackgroundColours();
        this.startPos = null;
        this.threshHoldParent = 'select';
        this.selectionMainElementCount = 0;
        this.keepData = '';
        this.initializeInteraction();

        // Scrolling Offset Values
        this.removeScrollOffset = 0;
        this.selectScrollOffset = 0;
        this.saveScrollOffset = 0;

        // Set Initial Screen Sectioning
        this.discardWidth = window.innerWidth / 3;
        this.selectWidth = (window.innerWidth / 3) * 2
        this.saveWidth = window.innerWidth;
        this.offsetWidth = this.discardWidth;
        this.offsetMargin = this.offsetHeight = window.innerHeight / 10;
        this.offsetStart = window.innerWidth * 0.015;
    }

    mobileCheck(): boolean {

        var check = false;
        (function (a) { if (/(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino/i.test(a) || /1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(a.substr(0, 4))) check = true; })(navigator.userAgent || navigator.vendor);// || window.opera);
        return check;
    }

    private setBackgroundColours() {

        document.getElementById('discard').style.backgroundColor = this.discardColour;
        document.getElementById('choose').style.backgroundColor = this.defaultColour;
        document.getElementById('keep').style.backgroundColor = this.keepColour;
        document.getElementById('arrow-left').style.color = this.discardArrow;
        document.getElementById('arrow-right').style.color = this.saveArrow;
    }

    private initializeInteraction() {

        this.interaction = interact('.draggable')
            .draggable({

                // enable inertial throwing
                inertia: false,

                // keep the element within the area of it's parent
                //restrict: {
                //    restriction: "parent",
                //    endOnly: true,
                //    elementRect: { top: 0, left: 0, bottom: 1, right: 1 }
                //},

                // enable autoScroll
                autoScroll: true,

                onstart: (event) => {

                    //this.touchCount++;
                    // Set selected object to yellow on drag start
                    event.target.style.backgroundColor = this.hoverColour;

                    // Set dragged object to front
                    this.setObjectToFront(event); 

                    // Set target objects starting X coordinate
                    //event.target.setAttribute('startX', event.clientX);
                    
                    // Set scroll offset value
                    this.setScrollOffset(event);

                    // Create possible merge list (save/keep only)
                    if (event.target.parentElement.className.includes('save')) {

                        var draggableList: any = document.getElementsByClassName('draggable');

                        for (var i = 0; i < draggableList.length; i++) {

                            if (draggableList[i].parentElement.className.includes('save') && 
                                    draggableList[i].id != event.target.id) {

                                this.saveObjList.push(draggableList[i]);
                            }
                        }
                    }
                },
                // call this function on every dragmove event
                onmove: (event) => {

                    this.dragMoveListener(event);

                    //if (Math.abs(event.clientX - event.target.getAttribute('startX')) > 50) {

                        //this.setObjectToFront(event);
                        //event.target.setAttribute('startX', 0);
                    //}

                    if (event.target.parentElement.className.includes('save')) {

                        var currRect: any = document.getElementById(event.target.id).getBoundingClientRect();

                        var currDivOffsetTop: number = Number(currRect.top);
                        var currDivOffsetLeft: number = Number(currRect.left);
                        var currDivHeight: number = Number(currRect.height);
                        var currDivWidth: number = Number(currRect.width);

                        // Detect if dragged object is overtop of another for merging
                        for (var i = 0; i < this.saveObjList.length; i++) {

                            var mergeRect: any = document.getElementById(this.saveObjList[i].id).getBoundingClientRect();

                            var mergeDivOffsetTop: number = mergeRect.top;
                            var mergeDivOffsetLeft: number = mergeRect.left;
                            var mergeDivHeight: number = mergeRect.height;
                            var mergeDivWidth: number = mergeRect.width;

                            if ((mergeDivOffsetLeft + mergeDivWidth) > currDivOffsetLeft &&
                                    mergeDivOffsetLeft < (currDivOffsetLeft + currDivWidth) &&
                                        (mergeDivOffsetTop + mergeDivHeight) > (currDivOffsetTop + (currDivHeight / 2)) &&
                                            mergeDivOffsetTop < (currDivOffsetTop + (currDivHeight / 2))) {

                                this.saveObjList[i].style.backgroundColor = 'blue';
                                event.target.style.backgroundColor = 'blue';
                                this.mergeObject = this.saveObjList[i];
                            }
                            else if (this.saveObjList[i].style.backgroundColor == 'blue') {

                                this.saveObjList[i].style.backgroundColor = this.saveColour;
                                event.target.style.backgroundColor = this.saveColour;
                                event.target.lastChild.style.color = 'white';
                                this.mergeObject = null;
                            }
                        }
                    }

                },
                // call this function on every dragend event
                onend: (event) => {

                    this.dragPositionSet = false;
                    // Set dragged object back to settled positioning
                    this.setObjectToBack(event);

                    this.setObjectColour(event.target);

                    // Set <div> object back to starting position
                    var currDragObj = document.getElementById(event.currentTarget.id);

                    var objectClass = event.target.parentNode.className;

                    this.setObjectPosition(event, objectClass);

                    currDragObj.style.webkitTransform =
                        currDragObj.style.transform =
                        'translate(' + 0 + '%, ' + 0 + '%)';

                    // Reset the position attributes on end
                    event.target.setAttribute('data-x', 0);
                    event.target.setAttribute('data-y', 0);

                    // Reset current saved object list for next drag event
                    if (event.target.parentElement.className.includes('save')) {

                        event.target.style.backgroundColor = this.saveColour;
                        this.saveObjList = [];

                        if (this.mergeObject != null) {

                            if (this.mergeObject.id.includes('merge')) {
                                // Pre-merged object with multiple spans
                                this.mergeTypes.push(this.mergeObject.firstChild.innerText);
                                if (event.target.id.includes('merge')) {
                                    // Underlying object is a previously merged object without select elements
                                    this.mergeTypes.push(event.target.firstChild.innerText);
                                } else {    // Underlying object is an original with select elements
                                    this.mergeTypes.push(event.target.children[0].firstChild.innerText);
                                }
                            }
                            else {  // Original Merge with select drop-down element
                                this.mergeTypes.push(this.mergeObject.children[0].firstChild.innerText);
                                if (event.target.id.includes('merge')) {
                                    // Dragged object is already merged with no select elements
                                    this.mergeTypes.push(event.target.firstChild.innerText);
                                }   // Dragged object has not been merged and has select elements
                                else {
                                    this.mergeTypes.push(event.target.children[0].firstChild.innerText);
                                }
                            }

                            this.mergeObject.style.display = 'none';
                            event.target.style.display = 'none';
                            this.buildMergeObject(event);
                        }

                        //this.mergeObject = null;
                        //this.mergeTypes = [];
                    }

                    // Switch between 'Selection Completed' view/button and 'Choose'
                    if (document.getElementById('choose').getElementsByClassName('draggable').length < 1) {

                        this.selectionCompleted(true);
                    }
                    else if (document.getElementById('choose').getElementsByClassName('draggable').length == 1) {

                        this.selectionCompleted(false);
                    }

                    //var textEl = event.target.querySelector('p');

                    //textEl && (textEl.textContent =
                    //    'moved a distance of '
                    //    + (Math.sqrt(Math.pow(event.pageX - event.x0, 2) +
                    //        Math.pow(event.pageY - event.y0, 2) | 0))
                    //        .toFixed(2) + 'px');
                }
            });
    }

    private extractId(id): string {

        //if (id.includes('merge')) {
        var splitArgs = id.split("-");
        if (splitArgs.length > 1) {
            id = splitArgs[1];
        }
        else if (splitArgs.length > 2) {
            id = splitArgs[2];
        }
        else {
            id = splitArgs[0];
        }
        //}

        return id;
    }

    private buildMergeObject(currDiv) {

        this.currObjectId = currDiv.target.id; //this.extractId(currDiv.target.id);
        this.mergeToObjectId = this.mergeObject.id; //this.extractId(this.mergeObject.id);

        var divObj = document.createElement('div');
        divObj.className = 'draggable';
        //this.mergedObjectsId = divObj.id = 'merge' + new Date().getTime().toString();
        divObj.id = 'merge-' + this.mergeToObjectId;

        // Add Events to <div>
        var mouseDownObj = {
            handleEvent: () => {
                this.onCamDown(event, 'edit');
            },
            when: "edit"
        };

        divObj.addEventListener("mousedown", mouseDownObj, false);

        // Add MouseUp event to <div>
        var mouseUpObj = {
            handleEvent: () => {
                this.onCamUp(event, 'edit');
            },
            when: "edit"
        };

        divObj.addEventListener("mouseup", mouseUpObj, false);

        var touchStartObj = {
            handleEvent: () => {
                this.onCamDown(event, 'edit');
            },
            when: "edit"
        };

        divObj.addEventListener("touchstart", touchStartObj, false);

        // Add touchEnd event to <div>
        var touchEndObj = {
            handleEvent: () => {
                this.onCamUp(event, 'edit');
            },
            when: "edit"
        };

        divObj.addEventListener("touchend", touchEndObj, false);


        // Style each <div>
        this.addObjectStyle(divObj, 'div', 'nlp');

        // Create text value holder (<span>) for each <div>
        var spanLabel = document.createElement('span');

        if (this.mergeObject.id.includes('merge')) {
            if (currDiv.target.id.includes('merge')) {
                // Both objects are pre-merged objects with multiple spans
                spanLabel.innerHTML = this.mergeObject.firstChild.innerText + ' ' + currDiv.target.firstChild.innerText;
            } else {
                // Pre-merged object with multiple spans and original object with select elements
                spanLabel.innerHTML = this.mergeObject.firstChild.innerText + ' ' + currDiv.target.children[0].firstChild.innerText;
            }
        } else {
            if (currDiv.target.id.includes('merge')) {
                // Dragged object is already merged without select elements but bottom object is original
                spanLabel.innerHTML = this.mergeObject.children[0].firstChild.innerText + ' ' + currDiv.target.firstChild.innerText;
            } else {
                // Both dragged and bottom objects are original with select drop-down elements
                spanLabel.innerHTML = this.mergeObject.children[0].firstChild.innerText + ' ' + currDiv.target.children[0].firstChild.innerText;
            }
        }

        spanLabel.id = 'merge1';

        // Style each <span>
        this.addObjectStyle(spanLabel, 'span2', 'nlp');

        // Attach <span> to <div> and <div> to main <div>
        divObj.appendChild(spanLabel);


        // Create text value holder (<span>) for each <div>
        var secSpanLabel = document.createElement('span');

        secSpanLabel.innerHTML = this.mergeObject.lastElementChild.innerText + '\n' + currDiv.target.lastElementChild.innerText

        secSpanLabel.id = 'merge2';

        // Style each <span>
        this.addObjectStyle(secSpanLabel, 'span1', 'nlp');

        // Attach <span> to <div> and <div> to main <div>
        divObj.appendChild(secSpanLabel);

        var divSave = document.getElementsByClassName('data save')[0];

        divSave.appendChild(divObj);

        // Get starting position coordinates and save
        var x = divObj.offsetLeft;
        var y = divObj.offsetTop;

        divObj.setAttribute('startX', x.toString());
        divObj.setAttribute('startY', y.toString());

    }

    /* MERGE EVENTS */
    onMergeDown(e: any, when: string): void {


    }

    onMergeUp(e: any, when: string): void {


    }

    private setScrollOffset(event) {

        if (this.removeScrollOffset < 0 ||
                this.selectScrollOffset < 0 ||
                    this.saveScrollOffset < 0) {    // Check if any scrolling has happened

            switch (event.target.parentNode.id) {

                case 'discard':                 // Set Discard <div> scroll offset

                    event.target.setAttribute('data-y', this.removeScrollOffset);
                    break;

                case 'choose':                  // Set Select <div> scroll offset

                    event.target.setAttribute('data-y', this.selectScrollOffset);
                    break;

                case 'keep':                    // Set Save <div> scroll offset

                    event.target.setAttribute('data-y', this.saveScrollOffset);
                    break;

                default:                        // Set Select as default <div> scroll offset

                    event.target.setAttribute('data-y', this.selectScrollOffset);
                    break;
            }

        }

    }

    private setObjectColour(object) {

        if (object.children.length > 0 && object.children[0].localName == 'select') {

            object.children[0].style.color = this.defaultColour;
        }

        if (object.className != 'select-label') {   // Skip if background was selected

            switch (object.parentNode.className) {

                case "data remove":

                    object.style.backgroundColor = this.removeColour;
                    break;

                case "data select":

                    object.style.backgroundColor = this.selectColour;

                    break;

                case "data save":

                    object.style.backgroundColor = this.saveColour;
                    break;

                default:

            }
        }
    }

    /* Angular DnD */
    private dragMoveListener(event: any) {

        var target = event.target,
            // keep the dragged position in the data-x/data-y attributes
            x = (parseFloat(target.getAttribute('data-x')) || 0) + event.dx,
            y = (parseFloat(target.getAttribute('data-y')) || 0) + event.dy;

        //var objectClass = target.parentNode.className;

        // translate the element
        target.style.webkitTransform =
            target.style.transform =
            'translate(' + x + 'px, ' + y + 'px)';

        // update the position attributes
        target.setAttribute('data-x', x);
        target.setAttribute('data-y', y);

    }

    private setObjectToFront(event) {

        event.target.style.width = '32%';
        event.target.style.height = '8vh';
        event.target.style.margin = '3% 1% 0% 1%';
        event.target.style.lineHeight = '4vh';
        event.target.style.position = 'absolute';
        event.target.style.zIndex = '999';

        //// translate the element
        //event.target.style.webkitTransform =
        //    event.target.style.transform =
        //    'translate(-100%, 100%)';

        event.target.children[0].style.width = '32vw';

        event.target.children[1].style.fontSize = '2.0vw';

        event.target.setAttribute('startx', event.clientX);

        var currY: number = Number(event.target.getAttribute('data-y'));

        // Offset the offset created by switching dragged object from relative to absolute positioning
        // except for the center select column that does not yet have the offset
        if (!event.target.parentElement.className.includes('select') &&
                    event.target.previousElementSibling.className == 'draggable') {
            event.target.setAttribute('data-y', currY + 50);
        }

        if (!this.dragPositionSet && event.target.parentElement.id != 'choose') {

            var currDataX: number = event.target.getAttribute('data-x');
            var currDataY: number = event.target.getAttribute('data-y');


            //var divRect: any = document.getElementById(event.target.id).getBoundingClientRect();

            //console.log('X:' + divRect.x);

            var dataX: number = Number(event.target.getAttribute('data-x')); //< -(this.offsetWidth) && event.target.offsetLeft > this.offsetStart
            var offsetLeft: number = event.target.offsetLeft;

            if (event.target.parentElement.id == 'discard') {

                if (Math.abs(dataX + offsetLeft) > (this.offsetWidth + this.offsetMargin)) {

                    event.target.setAttribute('data-x', Number(dataX) - this.offsetWidth);
                }
                else if (Math.abs(dataX + offsetLeft) > this.offsetWidth) {

                    event.target.setAttribute('data-x', Number(dataX) - this.offsetWidth);
                }
            }
            else if (event.target.parentElement.id == 'keep') {

                //if (Math.abs(dataX + offsetLeft) > ((3 * this.offsetWidth) - this.offsetMargin)) {

                //    event.target.setAttribute('data-x', Number(dataX) + this.offsetWidth);
                //}
                if (Math.abs(dataX + offsetLeft) > ((2 * this.offsetWidth) + this.offsetMargin)) {

                    event.target.setAttribute('data-x', Number(dataX) - this.offsetWidth);
                }
                else if (Math.abs(dataX + offsetLeft) > (3 * this.offsetWidth)) {

                    event.target.setAttribute('data-x', Number(dataX) - this.offsetWidth);
                }
            }
        }
        else {

            if (event.target.offsetLeft > (2 * (this.offsetWidth - this.offsetStart))) {

                var dataX: number = Number(event.target.getAttribute('data-x'));
                event.target.setAttribute('data-x', dataX - this.offsetWidth);

                var dataY: number = Number(event.target.getAttribute('data-y'));
                event.target.setAttribute('data-y', dataY + Number(event.target.clientHeight));
            }
        }

        console.log('clientX: ' + event.clientX);
        console.log('data-x: ' + event.target.getAttribute('data-x'));
        console.log('offsetLeft: ' + event.target.offsetLeft);

    }

    private setObjectToBack(event) {

        event.target.style.width = '90%';
        event.target.style.height = '5vh';
        event.target.style.margin = '7% 5% 1% 3%';
        event.target.style.lineHeight = '3vh';
        event.target.style.position = 'relative';
        event.target.style.zIndex = '0';

        event.target.children[0].style.width = '30vw';

        event.target.children[1].style.fontSize = '1.5vw';

    }

    private setObjectPosition(event, className) {

        var target = event.target;

        //var threshHold = ((target.offsetParent.clientWidth / 3) - (target.clientWidth / 2));

        var removeDiv = document.getElementById('discard');
        var selectDiv = document.getElementById('choose');
        var saveDiv = document.getElementById('keep');
        var dragDiv = document.getElementById(target.id);
        var currPos = event.clientX;

        // removed  - this.offsetMargin 
        if (currPos > 0 && currPos <= (this.discardWidth)) {

            removeDiv.appendChild(dragDiv);
            dragDiv.style.backgroundColor = this.removeColour;
        }
        else if (currPos > (this.discardWidth) && currPos <= (this.selectWidth - this.offsetMargin)) {

            // Skip re-appending if object is already in Select column (keep position)
            if (!className.includes('select')) {
                selectDiv.appendChild(dragDiv);
                dragDiv.style.backgroundColor = this.selectColour;
            }
        }
        else if (currPos > (this.selectWidth - this.offsetMargin)) {

            saveDiv.appendChild(dragDiv);
            dragDiv.style.backgroundColor = this.saveColour;
        }

        target.setAttribute('data-x', 0);
        target.setAttribute('data-y', 0);

    }

    /* GET CANVAS ELEMENT */
    private get canvas(): HTMLCanvasElement {

        return this.canvasRef.nativeElement;
    }

    /*  ##############################################################################
        #                            WEB CAM / OCR / NLP                             #
        ##############################################################################  */

    /*  ########################## END OF WEB CAM FUNCTIONS ##########################  */
    start() {

        this.initCamera({ video: true, audio: false });
    }


    /* CAMERA EVENTS */
    onCamDown(e: any, when: string): void {

        // Check for touch scroll
        if (e.type.includes('touch')) {
            // Set vertical scroll starting point
            if (e.target.id == 'discard' || e.target.id == 'choose' || e.target.id == 'keep' ||
                e.target.id == 'remove' || e.target.id == 'select' || e.target.id == 'save') {

                this.startScrollY = e.changedTouches[0].clientY;
            }
        }

        this.startTime = new Date().getTime();  // Get starting tick count for detecting open dialog event

        var className = e.target.className;
        var target = e.currentTarget;

        if (className.includes('videoElement')) {

            // Set icon to Engaged - true
            this.switchIconColour(className, this.isCamTurnOn, true);
        }
        //else if (className.includes('arrow')) {
        else if (when == 'removeall' || when == 'saveall') {

            target.style.color = this.pressedColour;

            if (className.includes('arrow-left')) {

                var discardDiv = document.getElementById('discard');
                discardDiv.style.backgroundColor = this.pressedColour;
            }
            else if (className.includes('arrow-right')) {

                var keepDiv = document.getElementById('keep');
                keepDiv.style.backgroundColor = this.pressedColour;
            }
        }
        else if (when == 'completed') {

            var doneLabel = document.getElementById('completed');
            var checkButton = document.getElementById('selection');
            checkButton.style.color = doneLabel.style.color = this.pressedColour;
        }
        else if (when == 'reset') {

            var reset = document.getElementById('reset');
            reset.style.color = this.pressedColour;
        }

        this.swipeocr(e, 'start');
    }

    onTouchMove(e: any, when: string): void {

        // Prevent scrolling when a data object is being dragged
        if (e.target.className != 'draggable' && e.target.parentElement.className != 'draggable') {

            this.scrollDiff += this.startScrollY - e.changedTouches[0].clientY;

            var section: string;
            // Find which div section is being scrolled
            if (e.target.className.includes('remove')) {
                section = 'discard';
            } else if (e.target.className.includes('select') || e.target.className.includes('choose')) {
                section = 'choose';
            } else if (e.target.className.includes('save')) {
                section = 'keep';
            }

            if (section !== undefined) {
                var scrollDiv = document.getElementById(section);

                scrollDiv.scrollTop = (this.scrollDiff / 10);

                // Limit scroll to top of window
                if (scrollDiv.scrollTop <= 0 && this.scrollDiff < 0) {
                    scrollDiv.scrollTop = 0; this.scrollDiff = 0;
                }

                // Prevent scroll difference value from exceeding scrollHeight limit
                if (this.scrollDiff >= (scrollDiv.scrollHeight * 10)) {

                    this.scrollDiff = (scrollDiv.scrollHeight * 10);
                }
            }
        }
        
    }


    onCamUp(e: any, when: string): void {

        //this.currTouches = [];

        var target = e.target;

        var className = e.target.className;

        if ((this.mergeObject != undefined || this.mergeObject != null) && this.mergeTypes.length > 0) {

            //var mergedId: string = e.target.parentElement.nextSibling.id;
            //var idTags: any = mergedId.split("-");
            //if (idTags.length > 2) {
            //    if (idTags[0].includes('merge') && idTags[1].includes('merge')) {

            //    }
            //}

            this.openMergeDialog(e);
            //this.mergeObject = null;
            //this.mergeTypes = [];
        }

        if (className == 'videoElement') {

            this.swipeocr(e, 'end');

            this.tookShot = false;
            // Turn off icon Engaged - false
            this.switchIconColour(className, this.isCamTurnOn, false);

            if (!this.shotSuppress) {

                this.toggleShot();
            }

            this.shotSuppress = false;
        }
        else if (className.includes('glyphicon-off')) {

            if (when == 'engage') {

                this.switchIconColour(className, this.isCamTurnOn, true);
                console.log('ENGAGE/SWITCH CAMERA ICON COLOUR');
            }
            else if (when == 'toggle') {

                this.toggleCam();
                this.shotSuppress = true;
                console.log('TOGGLE CAMERA ON/OFF');
            }

        }
        else if (className.includes('glyphicon-folder-open')) {

            if (when == 'engage') {

                this.switchIconColour(className, this.isCamTurnOn, true);
            }
            else if (when == 'open') {

                var input = document.getElementById('fileopen');
                input.click();

                if (e.type.includes('touch')) {
                    this.switchIconColour(className, true, false);
                }

                console.log('OPEN FOLDER TO SELECT LOCAL IMAGE');
            }
        }
        else if (className.includes('glyphicon-th-list')) {

            if (when == 'engage') {

                this.switchIconColour(className, this.isCamTurnOn, true);
            }
            else if (when == 'data') {

                if (this.isCamTurnOn) {
                    this.toggleCam();
                }

                this.router.navigateByUrl("/view/table");
            }
        }
        else if (when == 'removeall' || when == 'saveall') {

            if (className.includes('arrow-left')) {

                var divDiscard = document.getElementsByClassName('data remove')[0];
                var objects = document.getElementById('choose').children;

                for (var i = 0; i < objects.length; i++) {

                    if (objects[i].className == 'draggable') {

                        document.getElementById(objects[i].id).style.backgroundColor = this.removeColour;
                        divDiscard.appendChild(objects[i]);
                        --i;
                    }
                }

                this.onMouseLeave(e, 'hover');

                this.selectionCompleted(true);

            }
            else if (className.includes('arrow-right')) {

                var saveDiscard = document.getElementsByClassName('data save')[0];
                var objects = document.getElementById('choose').children;

                for (var i = 0; i < objects.length; i++) {

                    if (objects[i].className == 'draggable') {

                        document.getElementById(objects[i].id).style.backgroundColor = this.saveColour;
                        saveDiscard.appendChild(objects[i]);
                        --i;
                    }
                }

                this.onMouseLeave(e, 'hover');

                this.selectionCompleted(true);

            }
        }
        else if (when == 'completed') {
            // Get choosen (KEEP) OCR data
            var keepList = document.getElementsByClassName('data save')[0].children;
            // Loop through all elements and build chosen data string for NLP
            for (var i = 0; i < keepList.length; i++) {
                if (keepList[i].className == 'draggable') {
                    if (i == keepList.length - 1) {
                        this.keepData += keepList[i].textContent;       // Don't add newline character on last line
                    }
                    else {
                        this.keepData += keepList[i].textContent + '\n';// All newline character on line
                    }
                }
            }

            // Build NLP/Column choose View
            //this.switchSelectionScreen();

            // Send chosen data to NLP
            //this.nlpTrigger(this.keepData);

        }
        else if (when == 'reset') {

            var reset = document.getElementById('reset');
            reset.style.color = this.hoverColour;

            this.removeObjectsFromScene();

            // Load back to camera/picture folder
            this.switchView();

        }
        else if (when == 'end' && target.parentNode.className != 'ocr') {

            var endTime = new Date().getTime();

            if (endTime - this.startTime < 150) {

                if (target.parentNode.className == 'draggable') {

                    target = target.parentNode;
                }

                //if (target.className.includes('check')) {
                if (target.className.includes('new-window') || target.className.includes('check')) {

                    // Handle sending of data/profile/changes/etc
                    var profileBackup = JSON.parse(JSON.stringify(this.dataProfile));

                    var allData: any = document.getElementsByClassName('draggable');
                    var saveData: any = [];
                    var discardData: any = [];

                    for (var i = 0; i < this.dataProfile.Entities.length; i++) {

                        for (var j = 0; j < allData.length; j++) {

                            if (!allData[j].parentElement.className.includes('save')) {

                                if (this.dataProfile.Entities[i].Id == allData[j].id) {

                                    this.dataProfile.Entities.splice(i, 1);
                                }
                            }
                        }
                    }


                    var profileResponse: ProfileResponse = {
                        ProfileId: Number(this.dataProfile.ResultCode),
                        TableName: this.dataProfile.Entities[0].Type + this.dataProfile.ResultCode,
                        Entities: this.dataProfile.Entities
                    };

                    this.ocrService.postProfile(profileResponse)
                        .subscribe(async res => {

                            this.dataProfile = res;

                            console.log("Status Code: " + this.dataProfile.StatusCode + " \n" +
                                        "Result Code: " + this.dataProfile.ResultCode + " \n" +
                                        "Note: " + this.dataProfile.Note + " \n" +
                                        "Entities: " + this.dataProfile.Entities + "\n");

                            var doneLabel: any = document.getElementById('completed');
                            var doneSymbol: any = document.getElementById('selection');
                            var dataSaved: any = document.getElementById('data-saved');
                            var dataError: any = document.getElementById('data-error');

                            if (this.dataProfile.StatusCode == '200') {

                                // Clear screen, display successful data capture, return to cam/folder
                                doneLabel.style.color = this.completedButton;

                                doneLabel.innerText = 'GOT IT!';
                                //doneLabel.classList.remove('hover');
                                doneSymbol.style.display = 'none';
                                dataSaved.style.display = 'initial';
                                dataSaved.style.color = this.completedButton;
                                //dataSaved.classList.remove('hover');

                                this.removeObjectsFromScene();
                                this.dataProfile = null;

                                this.timer = Observable.timer(2000);
                                this.subscription = this.timer.subscribe(() => {

                                    doneLabel.innerText = 'SAVE DATA!';
                                    this.selectionCompleted(false);

                                    this.switchView();
                                });

                            }
                            else {

                                console.log(this.dataProfile.Note);

                                this.toggleErrorTimeout();
                                this.timer = Observable.timer(5000);
                                this.subscription = this.timer.subscribe(() => {

                                    this.hideError('hover');
                                    this.dataProfile = profileBackup;
                                });

                            }

                        },
                        err => {
                            console.log("profile request failed - ", err);
                        });
                }
                else if (target.className.includes('arrow')) {

                    // Prompt user of all data item being pushed to 'Discard' or 'Save'
                }
                else if (!target.className.includes('label') && target.parentNode.className != 'data-main') {   /// Don't open if background is clicked

                    if (target.firstChild.id.includes('merge')) {

                        this.openMergeDialog(e);
                    }
                    else if (target.children.length > 1) {   // Verify this is the data set

                        this.type = target.children[0].firstChild.innerText;

                        this.value = target.children[1].innerText;

                        var dataTypesList = target.children[0];
                        var dataTypes = [];
                        for (var i = 0; i < dataTypesList.length; i++) {

                            dataTypes.push(dataTypesList[i].value);
                        }

                        this.dialogId = document.getElementById(target.id).children[0].id;

                        this.switchDialogBackground();

                        this.openDialog(dataTypes);
                    }
                }

                this.startTime = 0;
            }
        }

        // Set Data Value text back to default colour on mouseup/touchend/dragend
        this.setValueTextColourDefault(target);
        this.setObjectColour(target.parentNode);

        //console.log('oncamup');
    }

    toggleErrorTimeout(): void {

        document.getElementById('completed').innerText = '\n\n\nERROR\nSAVING\nDATA!\nTRY AGAIN';
        document.getElementById('completed').style.color = this.discardArrow;

        document.getElementById('selection').style.display = 'none';
        document.getElementById('data-error').style.display = 'initial';

    }

    hideError(when): void {

        document.getElementById('data-error').style.display = "none";

        document.getElementById('selection').style.display = "initial";
        document.getElementById('selection').style.color = this.completedButton;

        document.getElementById('completed').style.color = this.completedButton;
        document.getElementById('completed').innerText = "SAVE DATA!";
    }

    onMouseEnter(e: any, when: string): void {

        var target = e.currentTarget;
        var className = e.currentTarget.className;
        //var target = e.target;
        //var className = e.target.className;

        if (when == "hover") {

            if (className.includes('glyphicon-off') ||
                className.includes('glyphicon-folder-open') ||
                className.includes('glyphicon-th-list')) {

                target.style.color = this.pressedColour;
            }
            else if (className.includes('draggable')) {

                var parentClass = e.currentTarget.parentNode.className;

                target.style.backgroundColor = this.hoverColour;

                if (parentClass.includes('select')) {

                    //target.firstChild.style.color = this.selectColour;
                    for (var i = 0; i < target.children.length; i++) {
                        target.children[i].style.color = this.selectColour;
                    }
                }
                else if (parentClass.includes('remove')) {

                    //target.firstChild.style.color = this.removeColour;
                    for (var i = 0; i < target.children.length; i++) {
                        target.children[i].style.color = this.removeColour;
                    }
                }
                else if (parentClass.includes('save')) {

                    //target.firstChild.style.color = this.saveColour;
                    for (var i = 0; i < target.children.length; i++) {
                        target.children[i].style.color = this.saveColour;
                    }
                }
            }
            else {// if (className.includes('arrow') || className.includes('check')) {

                target.style.color = this.hoverColour;

                if (className.includes('arrow-left')) {

                    var discardDiv = document.getElementById('discard');
                    discardDiv.style.backgroundColor = this.hoverColour;
                }
                else if (className.includes('arrow-right')) {

                    var keepDiv = document.getElementById('keep');
                    keepDiv.style.backgroundColor = this.hoverColour;
                }
                //else if (className.includes('check') || className.includes('done')) {
                else if (className.includes('new-window') || className.includes('check') || className.includes('done')) {

                    var doneLabel = document.getElementById('completed');
                    var checkButton = document.getElementById('selection');
                    checkButton.style.color = doneLabel.style.color = this.hoverColour;
                }
                else if (className.includes('glyphicon-repeat')) {

                    var reset = document.getElementById('reset');
                    reset.style.color = this.hoverColour;
                }
            }
        }

    }

    onMouseLeave(e: any, when: string): void {

        //var target = e.currentTarget;
        //var className = e.currentTarget.className;
        var target = e.target;
        var className = e.target.className;

        if (when == "hover") {

            if (className.includes('glyphicon-off') ||
                className.includes('glyphicon-folder-open') ||
                className.includes('glyphicon-th-list')) {

                this.switchIconColour(className, this.isCamTurnOn, false);
            }
            else if (className.includes('draggable')) {

                var parentDiv = target.parentNode.className;

                //target.style.backgroundColor = this.selectColour;

                if (parentDiv.includes('select')) {

                    target.style.backgroundColor = this.selectColour;       // White

                    for (var i = 0; i < target.children.length; i++) {
                        target.children[i].style.color = this.defaultColour;
                    }
                }
                else if (parentDiv.includes('remove')) {

                    target.style.backgroundColor = this.removeColour;       // Light Red

                    for (var i = 0; i < target.children.length; i++) {
                        target.children[i].style.color = this.defaultColour;
                    }
                }
                else if (parentDiv.includes('save')) {

                    target.style.backgroundColor = this.saveColour;         // Light Green

                    for (var i = 0; i < target.children.length; i++) {
                        target.children[i].style.color = this.defaultColour;
                    }
                }
            }
            else if (className.includes('arrow-left')) {

                target.style.color = this.discardArrow;

                var discardDiv = document.getElementById('discard');
                discardDiv.style.backgroundColor = this.discardColour;
            }
            else if (className.includes('arrow-right')) {

                target.style.color = this.saveArrow;             // Light Green

                var keepDiv = document.getElementById('keep');
                keepDiv.style.backgroundColor = this.keepColour;  // Light Green
            }
            //else if (className.includes('check') || className.includes('done')) {
            else if (className.includes('new-window') || className.includes('check') || className.includes('done')) {

                var doneLabel = document.getElementById('completed');
                var checkButton = document.getElementById('selection');
                checkButton.style.color = doneLabel.style.color = this.completedButton;
                //target.style.color = this.saveColour;
            }
            else if (className.includes('glyphicon-repeat')) {

                var reset = document.getElementById('reset');
                reset.style.color = this.antiDefaultColour;
            }

        }

        //console.log('onmouseleave');
    }

    onScroll(e: any, type: string): void {

        var divClass: string;

        switch (type) {

            case 'discard':
                divClass = 'data remove';
                var parentDiv = document.getElementsByClassName(divClass);
                this.removeScrollOffset = -(parentDiv[0].scrollTop);

                break;

            case 'choose':
                divClass = 'data select';
                var parentDiv = document.getElementsByClassName(divClass);
                this.selectScrollOffset = -(parentDiv[0].scrollTop);

                break;

            case 'keep':
                divClass = 'data save';
                var parentDiv = document.getElementsByClassName(divClass);
                this.saveScrollOffset = -(parentDiv[0].scrollTop);

                break;
        }

    }

    private setValueTextColourDefault(target) {

        // Return Text colour back to default on Mouse Up
        if (!target.className.includes('label') && !target.className.includes('glyphicon')) {       // Don't change default colour for background <div> label or buttons

            if (target.children.length > 1) {   // NLP Data object if children greater than 1

                if (target.children[1].localName == 'span') {   // Text span dragged, change color back

                    target.children[1].style.color = this.defaultColour;
                }
                else if (target.children[1].localName == 'option') {    // Drop-down list dragged, change color of child text

                    target.parentNode.children[1].style.color = this.defaultColour;
                }
            }
            else {  // OCR Data object

                target.style.color = this.defaultColour;
            }
        }

    }

    toggleCam() {

        //e.preventDefault();

        try {
            if (this.isCamTurnOn) {
                this.turnoff();
                this.strCamTurnOnOff = this.STR_CAM_ON;
                this.strCamTurnOnOffIcon = this.STR_VIDEO_ICON;
            }
            else {
                this.start();
                this.strCamTurnOnOff = this.STR_CAM_OFF;
                this.strCamTurnOnOffIcon = this.STR_VIDEO_CANCEL_ICON;
            }

            this.isCamTurnOn = !this.isCamTurnOn;

            this.switchIconColour('glyphicon glyphicon-off', this.isCamTurnOn, false);
        }
        catch (e) {
            console.log('Error:', e);
        }
    }

    private switchIconColour(type, iconOn, engaged) {

        switch (type) {
            case 'glyphicon glyphicon-off':
                if (engaged) {
                    this.icon.style.color = this.hoverColour;
                } else if (iconOn) {
                    this.icon.style.color = this.removeColour;
                } else {
                    this.icon.style.color = this.selectColour;
                }
                break;

            case 'glyphicon glyphicon-folder-open':
                if (engaged) {
                    this.localimage.style.color = this.hoverColour;
                } else if (iconOn) {
                    this.localimage.style.color = this.antiDefaultColour;
                } else {
                    this.localimage.style.color = this.selectColour;
                }
                break;

            case 'glyphicon glyphicon-th-list':
                if (engaged) {
                    this.dataView.style.color = this.hoverColour;
                } else if (iconOn) {
                    this.dataView.style.color = this.antiDefaultColour;
                } else {
                    this.dataView.style.color = this.selectColour;
                }
                break;


            default:
                break;
        }
    }

    toggleShot() {

        if (!this.isCamTurnOn) {
            console.log("Cam is not Turn On status.");
            return;
        }

        try {
            if (!this.tookShot) {
                this.shot(this.video);
                console.log("Take shot");
                this.strTakePic = this.STR_RESUME_CAM;
                this.turnoff();
                this.switchView();

                //this.buildDataObjects();
            }
            else {
                this.strTakePic = this.STR_TAKE_PIC_ICON;
            }
            this.tookShot = !this.tookShot;
        }
        catch (e) {
            console.log("Error:", e);
        }
    }

    private switchView() {

        var canvasElement = this.canvas;
        var videoElement = this.video;
        var buttonElement = this.button;
        var imageElement = this.imageFromFile;


        if ((videoElement.style.display == 'block') || (videoElement.style.display == '')) {

            canvasElement.style.display = 'block';
            videoElement.style.display = 'none';
            buttonElement.style.display = 'none';
            this.toggleCam();
        }
        else if ((videoElement.style.display == 'none') && (canvasElement.style.display == 'block')) {

            canvasElement.style.display = 'none';
            videoElement.style.display = 'block';
            buttonElement.style.display = 'block';
            document.getElementById('arrow-left').style.display = 'block';
            document.getElementById('arrow-right').style.display = 'block';
            document.getElementById('data-saved').style.display = 'none';
            var fileInput: any = document.getElementById('fileopen');
            fileInput.type = 'file';
            this.toggleCam();
        }
        else if ((imageElement.style.display == 'block') || (imageElement.style.display == '')) {

            imageElement.style.display = 'none';
            buttonElement.style.display = 'none';
            canvasElement.style.display = 'block';
        }
        else {

            canvasElement.style.display = 'none';
            videoElement.style.display = 'block';
            buttonElement.style.display = 'block';
        }
    }

    private switchDialogBackground() {

        var dialogBackground = document.getElementById('dialog-background');

        if (dialogBackground.style.display == 'none' || dialogBackground.style.display == '') {

            dialogBackground.style.display = 'initial';
        }
        else {

            dialogBackground.style.display = 'none';
        }
    }

    private switchSelectionScreen() {

        var discardLabel = document.getElementById('discard');
        var keepLabel = document.getElementById('save');
        var chooseLabel = document.getElementById('choose-match');
        var swipeLabel = document.getElementById('swipe');

        var doneButton = document.getElementById('selection');
        var doneLabel = document.getElementById('completed');
        var dataSaved = document.getElementById('data-saved');

        if (keepLabel.textContent == 'KEEP') {

            chooseLabel.textContent = 'EDITDATA';
            chooseLabel.style.margin = '6vh 0vh 0vh 0vh';
            keepLabel.textContent = 'SAVEDATA';
            keepLabel.style.fontSize = '20vh';
            keepLabel.style.margin = '-18vh 0vh 0vh 0vh';

            chooseLabel.style.display = 'initial';

            doneButton.style.display = 'none';
            doneLabel.style.display = 'none';
        }
        else {

            chooseLabel.textContent = 'CHOOSE';
            chooseLabel.style.margin = '0vh 0vh 0vh 0vh';
            keepLabel.textContent = 'KEEP';
            keepLabel.style.fontSize = '22vh';
            chooseLabel.style.margin = '0vh 0vh 0vh 0vh';

            chooseLabel.style.display = 'none';

            doneButton.style.display = 'initial';
            doneLabel.style.display = 'initial';
        }
    }

    private selectionCompleted(completed) {

        var selectionState = document.getElementsByClassName('select-label')[0].textContent;

        var chooseLabel;

        //if (selectionState.includes('CHOOSE')) {
        //    chooseLabel = document.getElementById('select');
        //} else {
            chooseLabel = document.getElementById('choose-match');
        //}
        //var swipeLabel = document.getElementById('swipe');
        var discardArrow = document.getElementById('arrow-left');
        var keepArrow = document.getElementById('arrow-right');

        var doneButton = document.getElementById('selection');
        var doneLabel = document.getElementById('completed');

        if (completed) {

            chooseLabel.style.display = 'none';
            //swipeLabel.style.display = 'none';
            discardArrow.style.display = 'none';
            keepArrow.style.display = 'none';

            doneButton.style.display = 'initial';
            doneLabel.style.display = 'initial';
        }
        else {

            chooseLabel.style.display = 'initial';

            doneButton.style.display = 'none';
            doneLabel.style.display = 'none';

            //if (selectionState.includes('CHOOSE')) {

                //swipeLabel.style.display = 'initial';
                discardArrow.style.display = 'initial';
                keepArrow.style.display = 'initial';
            //}
        }
    }

    /*
    sound() {
        this.initCamera({ video: true, audio: true });
    }
    */

    initCamera(config: any) {
        var browser = <any>navigator;

        browser.getUserMedia = (browser.getUserMedia ||
            browser.webkitGetUserMedia ||
            browser.mozGetUserMedia ||
            browser.msGetUserMedia);


        browser.mediaDevices.getUserMedia(config)   // config: audio/video settings
        .then((mediaStream) => {
            // Get video
            this.video = document.querySelector('video');
            if ("srcObject" in this.video) {
                this.video.srcObject = mediaStream;
            } else {
                this.video.src = window.URL.createObjectURL(mediaStream);
            }
            this.video.onloadmetadata = (e) => {
                this.video.play();
            };
        })
        .catch(function (err) {
            console.log(err.name + ": " + err.message);
        });
    }

    /*
    pause() {
        this.video.pause();
    }
    */

    toggleControls() {
        this.video.controls = this.displayControls;
        this.displayControls = !this.displayControls;
    }

    shot(display) {

        var frameCanvas = document.createElement('canvas');

        if (display.className == 'imageDisplayArea') {

            /// For displaying image before OCR
            //frameCanvas.height = display.clientHeight;
            //frameCanvas.width = display.clientWidth;

            var img = new Image();
            img.src = this.picture;
        }
        else {

            frameCanvas.height = display.videoHeight;
            frameCanvas.width = display.videoWidth;

            var twoDContext = frameCanvas.getContext('2d');

            twoDContext.drawImage(display, 0, 0, frameCanvas.width, frameCanvas.height);

            var img = new Image();
            img.src = frameCanvas.toDataURL();

        }

        this.ocrTriggerForFile(img);

    }

    private openLocalImage() {

        var fileReader: FileReader = new FileReader();
        var img = new Image();
        var cleanImg: Image = { Base64_image: "", FileType: "" };
        this.imgForDisplay = "";
        this.statusCode_ocr = "";
        this.locale = "";
        this.textAfterOcr = "";

        // Read file content as base64
        if (this.fileToUpload != null) {
            fileReader.readAsDataURL(this.fileToUpload);
        }
        else {
            console.log("file is null");
        }

        // Trigger onloadend when FileReader is done to read file
        fileReader.onloadend = (e) => {

            img.src = fileReader.result;

            this.ocrTriggerForFile(img);
            this.switchView();
        }

        /// For Displaying Image before OCR
        //this.videoElement.nativeElement.style.display = 'none';
        //this.imageElement.nativeElement.style.display = 'normal';
        //this.imageElement.nativeElement.appendChild(img);
        
    }

    handleFileInput(files: FileList) {

        this.removeObjectsFromScene();

        this.fileToUpload = files.item(0);
        this.fileType = files.item(0).name.split('.').pop();
        this.openLocalImage();

        var fileInput: any = document.getElementById('fileopen');
        fileInput.type = '';
    }

    resume() {
        this.video.play();
    }


    turnoff() {

        // Older 'Deprecated' browsers
        if (this.video.srcObject == undefined) {

            this.video.pause();
            this.video.src = "";
            this.localstream.getTracks()[0].stop();

        } else {

            //this.video.paused = true;
            this.video.src = "";
            this.video.srcObject.getTracks()[0].stop();
        }
        
    }

                                                          
    /*  ########################## START OF OCR FUNCTIONS ############################  */

    /* Page Swipe Routing Functions */
    onStart() {

        event.stopImmediatePropagation();

        this.router.navigateByUrl("/view/table");
    }

    onPrevious() {

        event.stopImmediatePropagation();

        if (this.isMobile) {

            this.router.navigateByUrl("/home");
        } else {

            this.router.navigateByUrl("/design/data");
        }
    }

    /* Page Swipe Function */
    swipeocr(e: any, when: string): void {

        e.preventDefault();

        var currX = 0;
        var currY = 0;

        if (e.type.includes('mouse') || e.type.includes('click')) {

            currX = e.x;
            currY = e.y;

        } else if (e.type.includes('touch')) {

            currX = e.changedTouches[0].pageX;
            currY = e.changedTouches[0].pageY;
        }

        const coord: [number, number] = [currX, currY];
        const time = new Date().getTime();

        if (when === 'start') {
            this.swipeCoord = coord;
            this.swipeTime = time;
        }

        else if (when === 'end') {

            if (coord != undefined && this.swipeCoord != undefined) {

                const direction = [coord[0] - this.swipeCoord[0], coord[1] - this.swipeCoord[1]];
                const duration = time - this.swipeTime;

                if ((duration > 250 //Rapid
                    && Math.abs(direction[0]) > 30) //Long enough
                    && (Math.abs(direction[0]) > Math.abs(direction[1] * 3))) { //Horizontal enough

                    const swipe = direction[0] < 0 ? 'next' : 'previous';

                    if (swipe == "next") {

                        this.onStart();
                    }
                    else if (swipe == "previous") {

                        this.onPrevious();
                    }
                }
            }
        }
    }

    @HostListener('window:resize', ['$event'])
    public onResize(event: Event) {

        this.video.width = window.innerWidth;
        this.video.height = window.innerHeight;

        // Reset Screen Sectioning on resize
        this.discardWidth = window.innerWidth / 3;
        this.selectWidth = (window.innerWidth / 3) * 2
        this.saveWidth = window.innerWidth;
        this.offsetWidth = this.discardWidth;
        this.offsetMargin = this.offsetHeight = window.innerHeight / 10;
        this.offsetStart = window.innerWidth * 0.015;

    }


    ngOnDestroy() {

        //document.removeEventListener('mousedown', this.onOcrMouseDown, false);
        //document.removeEventListener('touchstart', this.onOcrTouchStart, false);

        //document.removeEventListener('touchend', this.onOcrTouchEnd, false);
        //document.removeEventListener('mouseup', this.onOcrMouseUp, false);
    }


    ocrTriggerForFile(img) {

        var cleanImg: Image = { Base64_image: "", FileType: "" };
        this.imgForDisplay = "";
        this.statusCode_ocr = "";
        this.locale = "";
        this.textAfterOcr = "";

        // Remove type from result of file
        cleanImg.Base64_image = img.src.split(',')[1];

        if (cleanImg.Base64_image != "") {
            this.ocrService.postOcr(cleanImg)
                .subscribe(async res => {

                    // ResultCode: 0    Added to database
                    //             > 0  Profile ID
                    //             -    Error: retun NOte

                    // Return success

                    this.dataProfile = res;

                    console.log("Status Code: " + this.dataProfile.StatusCode + " \n" +
                                "ResultCode: " + this.dataProfile.ResultCode + " \n" +
                                "Note: \n" + this.dataProfile.Note);

                    if (this.dataProfile.ResultCode == '0') {

                        this.autoDataSaveViewSwitch(true);

                        this.timer = Observable.timer(2000);
                        this.subscription = this.timer.subscribe(() => {

                            this.autoDataSaveViewSwitch(false);

                            this.switchView();
                        });
                    }
                    else if (Number(this.dataProfile.ResultCode) < 0) {
                        
                        this.toggleErrorTimeout();
                        document.getElementById('select').style.display = 'none';
                        this.timer = Observable.timer(3000);
                        this.subscription = this.timer.subscribe(() => {

                            this.hideError('hover');
                            document.getElementById('select').style.display = 'initial';
                            document.getElementById('selection').style.display = 'none';
                            this.switchView();
                        });
                    }
                    else {

                        await this.buildDataObjects('nlp');
                    }

                    


                    //await this.buildDataObjects(this.textAfterOcr, 'ocr');
                    // Send parsed data to NLP after chosen by USER
                    //this.nlpTrigger(this.textAfterOcr);

                },
                err => {
                    console.log("ocr request failed - ", err);
                });
        }
        else {
            console.log("Not found image");
        }

    }

    autoDataSaveViewSwitch(saved: boolean) {

        var doneLabel: any = document.getElementById('completed');
        var dataSaved: any = document.getElementById('data-saved');
        var selectLabel: any = document.getElementById('select');
        var discardBack: any = document.getElementById('discard');
        var discardLabel: any = document.getElementById('remove');
        var saveLabel: any = document.getElementById('save');

        if (saved) {
            selectLabel.style.display = 'none';
            doneLabel.style.display = 'initial';
            doneLabel.innerText = 'SAVED!';
            dataSaved.style.display = 'initial'
            discardBack.style.backgroundColor = this.saveColour;
            discardLabel.style.display = 'none';
            saveLabel.style.display = 'none';
            //this.selectionCompleted(false);
        } else {

            selectLabel.style.display = 'initial';
            doneLabel.style.display = 'none';
            doneLabel.innerText = 'EDIT DATA';
            dataSaved.style.display = 'none';
            discardBack.style.backgroundColor = this.discardColour;
            discardLabel.style.display = 'initial';
            saveLabel.style.display = 'initial';
        }
    }
    
    /*  ########################## START OF NLP FUNCTIONS ############################  */

    //nlpTrigger() {
    //nlpTrigger(textAfterOcr) {
    //    this.statusCode_nlp = "";
    //    this.language = "";
    //    //this.textAfterNlp = "";var nlpBody: NlpRequestBody = { Text: this.textAfterOcr };
    //    this.textAfterNlp = [];
    //    var nlpBody: NlpRequestBody = { Text: textAfterOcr };
        


    //    this.nlpService.postNlp(nlpBody)
    //        .subscribe(async res => {

    //            this.statusCode_nlp = res.StatusCode;
    //            this.language = res.Language;

    //            for (var i = 0; i < res.Entities.length; ++i) {

    //                //this.textAfterNlp += res.Entities[i].Name + ":";
    //                //this.textAfterNlp += res.Entities[i].Type + ":";
    //                //this.textAfterNlp += "\n";

    //                this.textAfterNlp.push(res.Entities[i].Name + ":" + res.Entities[i].Type);
    //                //this.textAfterNlp += "\n";
    //            }

    //            await this.buildDataObjects(this.textAfterNlp, 'nlp');
    //        },
    //        err => {
    //            console.log("nlp request failed - ", err);
    //        });
    //}



    /*  ##############################################################################
        #                                INTERACT JS UI                              #
        ##############################################################################  */

    /*  ######################## START OF THREE JS FUNCTIONS #########################  */

    
    /* BUILD THREE JS OBJECTS FOR DISPLAYING DATA */
    //private buildDataObjects() {
    //private buildDataObjects(data, type) {
    private buildDataObjects(type) {

        // Delete existing objects if already created
        var objects = document.getElementsByClassName('draggable');
        if (objects.length > 0) { this.removeObjectsFromScene(); }

        var keys: any;
        var dataTypes: any;

        // Get the key/value pairs of the OCR extraction
        switch (type) {
            case 'ocr':

                //keys = data.split('\n');        // Split each line of OCR data
                //keys = keys.filter(Boolean);    // Remove blank entries
                //break;

            case 'nlp':

                var name = [];
                var dataType = [];
                var combined = [];

                var dataPairList = [];

                //data.Entities.forEach(element => {

                //    dataPairList.push(element.Type);
                //    dataPairList.push(element.Name);
                //});
                //data.forEach(element => {

                //    var pair = element.split(':');

                //    dataPairList.push(pair[1]);
                //    dataPairList.push(pair[0]);
                //});

                // Add Data Type listing
                //this.appendElementsAndEventsToPairs(dataPairList, 'select', 'nlp');
                //this.appendElementsAndEventsToPairs(data, 'select', 'nlp');
                this.appendElementsAndEventsToPairs('select', 'nlp');

                dataType.length = 0;

                break;
        }

    }

    //private appendElementsAndEventsToPairs(keys, element, action) {
    private appendElementsAndEventsToPairs(element, action) {

        //var pid = 0;

        // Create a <div> object for each key/value pair
        //for (var i = 0; i < keys.length; i++) {
        for (var i = 0; i < this.dataProfile.Entities.length; i++) {

            // Add MouseEnter event to <div>
            var divObj = document.createElement('div');
            divObj.className = 'draggable';
            // Add Events to <div>
            var mouseEnterObj = {
                handleEvent: () => {
                    this.onMouseEnter(event, 'hover');
                },
                when: "hover"
            };

            divObj.addEventListener("mouseenter", mouseEnterObj, false);

            // Add MouseLeave event to <div>
            var mouseLeaveObj = {
                handleEvent: () => {
                    this.onMouseLeave(event, 'hover');
                },
                when: "hover"
            };

            divObj.addEventListener("mouseleave", mouseLeaveObj, false);

            // Add TouchStart event (point to MouseEnter) to <div>
            var touchStartObj = {
                handleEvent: () => {
                    this.onMouseEnter(event, 'hover');
                },
                when: "hover"
            };

            divObj.addEventListener("touchstart", touchStartObj, false);

            // Add TouchEnd event (point to MouseEnter) to <div> 
            var touchEndObj = {
                handleEvent: () => {
                    this.onMouseLeave(event, 'hover');
                },
                when: "hover"
            };

            divObj.addEventListener("touchend", touchEndObj, false);

            // Style each <div>
            this.addObjectStyle(divObj, 'div', 'nlp');

            // CREATE DATA TYPE PLACEHOLDER
            // Create text data type holder (<span>) for each <div>
            var pLabelType = document.createElement('select');
            
            //divObj.id = keys[i] + pid;
            divObj.id = i.toString(); //this.dataProfile.Entities[i].IndexInfo[0].line.toString();
            this.dataProfile.Entities[i].Id = i;
            //pLabelType.id = 'type' + pid;
            pLabelType.id = 'type-' + divObj.id;

            // Style each <span>
            this.addObjectStyle(pLabelType, 'span2', 'nlp');

            // Attach <span> to <div> and <div> to main <div>
            divObj.appendChild(pLabelType);


            //++i; // Increment to data type key

            // CREATE VALUE PLACEHOLDER
            // Create text value holder (<span>) for each <div>
            var spanLabel = document.createElement('span');
            //spanLabel.innerHTML = keys[i];
            spanLabel.innerHTML = this.dataProfile.Entities[i].Name;
            //spanLabel.id = 'value' + pid++;
            spanLabel.id = 'value-' + divObj.id; //this.dataProfile.Entities[i].IndexInfo[0].line.toString();

            // Style each <p>
            this.addObjectStyle(spanLabel, 'span1', 'nlp');

            // Attach <p> to <div> and <div> to main <div>
            divObj.appendChild(spanLabel);


            if (element == 'select') {
                var divSelect = document.getElementsByClassName('data select')[0];
            }
            else if (element == 'save') {
                var divSelect = document.getElementsByClassName('data save')[0];
            }

            divSelect.appendChild(divObj);

            //var select: any = document.getElementById('type' + (pid - 1));
            var select: any = document.getElementById('type-' + divObj.id);

            // Make original option of data value
            var option = document.createElement('option');
            //option.text = keys[i - 1];
            option.text = this.dataProfile.Entities[i].Type.replace(/ /g, "_");
            select.add(option);

            // Create drop down of all other options
            //for (var j = 0; j < keys.length; j++) {

            //    if (keys[j] != 'Unknown' && keys[j] != keys[i - 1]) { // Don't add 'UNKNOWN'
            //        var option = document.createElement('option');
            //        option.text = keys[j];
            //        select.add(option);
            //    }
            //    ++j;
            //}
            for (var j = 0; j < this.dataProfile.Entities.length; j++) {

                if (this.dataProfile.Entities[j].Type != 'Unknown' && this.dataProfile.Entities[j].Type != option.text) { // Don't add 'UNKNOWN'
                //if (this.dataProfile.Entities[j].Type != option.text) {
                    var option = document.createElement('option');
                    option.text = this.dataProfile.Entities[j].Type.replace(/ /g, "_");
                    select.add(option);
                }
                //++j;
            }

            // Get starting position coordinates and save
            var x = divObj.offsetLeft;
            var y = divObj.offsetTop;

            divObj.setAttribute('startX', x.toString());
            divObj.setAttribute('startY', y.toString());
        }
    }

    private addObjectStyle(object: any, element: string, action: string) {

        switch (action) {

            case 'normal':

                switch (element) {

                    case 'div':

                        object.style.display = "table";
                        object.style.width = "90%";
                        object.style.height = "5.0vh";
                        object.style.minHeight = "1.0vh";
                        object.style.margin = "3.0% 5.0% 3.0% 5.0%";
                        object.style.textAlign = "center";
                        object.style.verticalAlign = "middle";
                        object.style.lineHeight = "2.0vh";
                        object.style.backgroundColor = this.selectColour;
                        object.style.color = this.defaultColour;
                        object.style.borderRadius = "0.75em";

                        object.style.cssText +=
                            "-webkit-transform: translate(0%, 0%);" +
                            "transform:translate(0%, 0%);";
                        break;

                    case 'p':

                        object.style.fontWeight = 'bold';
                        object.style.display = 'table-cell';
                        object.style.verticalAlign = 'middle';
                        //object.style.wordBreak = "break-all";
                        break;

                }
                break;

            case 'nlp':

                switch (element) {

                    case 'div':

                        object.style.display = "inline-table";
                        object.style.width = "90%";
                        object.style.height = "5.0vh";
                        object.style.minHeight = "1.0vh";
                        object.style.margin = "7.0% 5.0% 1.0% 3.0%";
                        object.style.verticalAlign = "middle";
                        object.style.lineHeight = "3.0vh";
                        object.style.backgroundColor = this.selectColour;
                        object.style.color = this.defaultColour;
                        object.style.borderRadius = "0.75em";
                        object.style.position = 'relative';

                        break;

                    case 'span1':

                        object.style.fontWeight = 'bold';
                        object.style.fontSize = '1.5vw';
                        object.style.verticalAlign = 'bottom';
                        object.style.transform = 'translateX(0vw) translate(0vh)';
                        object.style.display = 'block';
                        object.style.padding = '0vh 0.5vw 0vh 0.5vw'
                        break;

                    case 'span2':

                        object.style.fontWeight = 'bold';
                        object.style.fontSize = '2.5vh';
                        object.style.textAlign = 'left';
                        object.style.transform = 'translateX(0vw) translateY(-2.0vh)';
                        object.style.display = 'block';
                        object.style.backgroundColor = this.topFadeColour;
                        object.style.borderRadius = '0.1em';
                        object.style.height = '3vh';
                        object.style.width = '30vw';
                        object.style.padding = '0vh 0.5vw 0vh 0.5vw'
                        object.style.whiteSpace = 'nowrap';
                        object.style.overflow = 'hidden';
                        object.style.textOverflow = 'ellipsis';

                        break;

                }
                break;
        }
    }

    /* REMOVE, CLEAR AND DISPOSE OF OBJECTS IN MEMORY */
    private disposeObjectsFromScene(objects) {

        
    }

    /* ADD OBJECTS BACK TO THE SCENE FOR RENDERING */
    private addObjectsToScene(objects) {

        
    }

    /* REMOVE OBJECTS FROM SCENE */
    private removeObjectsFromScene() {

        var objects = document.getElementsByClassName('draggable');
        while (objects.length > 0) {
            objects[0].parentNode.removeChild(objects[0]);
        }
    }
    
}
