// Refer to https://blog.cloudboost.io/capturing-camera-using-angular-5-2e177c68201f
import { Component, ViewChild, OnInit } from '@angular/core';
import * as THREE from 'three';


@Component({
    selector: 'webcam-control',
    templateUrl: './webcamControl.component.html',
    styleUrls: ['./webcamControl.component.css']
})
export class WebCamControlComponent implements OnInit {
    @ViewChild('videoElement') videoElement: any; 
    //@ViewChild('canvasElement') canvasElement: any; 
    //@ViewChild('shotElement') shotElement: any; 

    readonly STR_VIDEO_ICON: string = "glyphicon glyphicon-facetime-video";
    readonly STR_VIDEO_CANCEL_ICON: string = "glyphicon glyphicon-ban-circle";
    readonly STR_CAM_ON: string = "Turn On";
    readonly STR_CAM_OFF: string = "Turn Off";
    readonly STR_TAKE_PIC_ICON: string = "glyphicon glyphicon-camera";
    readonly STR_RESUME_CAM: string = "glyphicon glyphicon-play";
    
    video: any;
    localstream: any;
    displayControls = true;
    isCamTurnOn = true;
    tookShot = false;
    strCamTurnOnOff: string = this.STR_CAM_ON;
    strCamTurnOnOffIcon: string = this.STR_VIDEO_ICON;
    strTakePic: string = this.STR_TAKE_PIC_ICON;


    constructor() { }

    ngOnInit() {
        this.video = this.videoElement.nativeElement;
        //this.canvasElement = this.canvasElement.nativeElement;
        //this.shotElement = this.shotElement.nativeElement;
        this.start();
    }

    
    start() {
        this.initCamera({ video: true, audio: false });
    }

    /* EVENTS */
    onCamDown(e: any, when: string): void {

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

        //this.turnoff();
        //this.toggleCam();
    }

    onCamUp(e: any, when: string): void {

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

        //this.toggleCam();
        //this.turnoff();
    }
    
    toggleCam() {

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
        }
        catch (e) {
            console.log('Error:', e);
        }
    }

    toggleShot() {
        if (!this.isCamTurnOn) {
            console.log("Cam is not Turn On status.");
            return;
        }

        try {
            if (!this.tookShot) {
                this.shot();
                console.log("Take shot");
                this.strTakePic = this.STR_RESUME_CAM;
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

        browser.mediaDevices.getUserMedia(config).then((stream: any) => {
            this.video.src = window.URL.createObjectURL(stream);
            this.localstream = stream;
            this.video.play();            
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

    shot() {
        ////var img = document.querySelector('img') || document.createElement('img');

        //this.canvasElement.width = this.video.offsetWidth;
        //this.canvasElement.height = this.video.offsetHeight;

        //var context = this.canvasElement.getContext('2d');
        //context.drawImage(this.video, 0, 0, this.canvasElement.width, this.canvasElement.height);

        //// var jpgUrl = this.canvasElement.toDataURL('image/png');

        //var pngUrl = this.canvasElement.toDataURL();
        //console.log(pngUrl);

        ////this.shotElement.appendChild(img);
    }

    resume() {
        this.video.play();
    }


    turnoff() {
        this.video.pause();
        this.video.src = "";
        this.localstream.getTracks()[0].stop();
    }

}
