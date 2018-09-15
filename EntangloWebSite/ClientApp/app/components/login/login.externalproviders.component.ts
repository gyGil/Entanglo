import { Component, Inject, OnInit, NgZone, PLATFORM_ID } from '@angular/core';
import { isPlatformBrowser } from '@angular/common';
import { HttpClient } from "@angular/common/http";
import { Router } from "@angular/router";
import { AuthService } from '../../services/auth.service';

declare var window: any;

@Component({
    selector: "login-externalproviders",
    templateUrl: "./login.externalproviders.component.html"
})
export class LoginExternalProvidersComponent implements OnInit {
    ngOnInit() {

    }
}