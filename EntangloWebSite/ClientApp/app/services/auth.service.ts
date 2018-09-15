import { EventEmitter, Inject, Injectable, PLATFORM_ID } from "@angular/core";
import { isPlatformBrowser } from '@angular/common';
import { HttpClient, HttpHeaders } from "@angular/common/http";
import { Router } from '@angular/router';
import { Observable } from "rxjs";
import 'rxjs/Rx';

@Injectable()
export class AuthService {
    authKey: string = "auth";
    clientId: string = "TestMakerFree";

    constructor(
        private http: HttpClient,
        private router: Router,
        @Inject(PLATFORM_ID) private platformId: any) {
    }

    // Returns TRUE if the user is logged in, FALSE otherwise.
    isLoggedIn(): boolean {
        if (isPlatformBrowser(this.platformId)) {
            return localStorage.getItem(this.authKey) != null;
        }
        return false;
    }

    isPageRequiredAuth(): boolean {
        return this.router.url != '/home';
    }
}