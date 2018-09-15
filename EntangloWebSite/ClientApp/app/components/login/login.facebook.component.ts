import { Component, Inject, OnInit, NgZone, PLATFORM_ID } from '@angular/core';
import { isPlatformBrowser } from '@angular/common';
import { HttpClient } from "@angular/common/http";
import { Router } from "@angular/router";
import { AuthService } from '../../services/auth.service';

// declare these vars here 
// to let the TS compiler know that they exist
declare var window: any;
declare var FB: any;

@Component({
    selector: "login-facebook",
    templateUrl: "./login.facebook.component.html"
})

export class LoginFacebookComponent implements OnInit {


    ngOnInit() {
    }
}
