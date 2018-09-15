import { Inject, Injectable } from "@angular/core";
import { HttpClient, HttpHeaders } from "@angular/common/http";
import { Router } from '@angular/router';
import { Observable } from "rxjs";


@Injectable()
export class OcrService {
    //ocrApiUrl: string = "api/ocr";        // Older URL
    ocrApiUrl: string = "api/ocr/main";
    profileUrl: string = "api/ocr/main/create";

    constructor(
        private http: HttpClient,
        private router: Router,
        @Inject('BASE_URL') private baseUrl: string) {
    }

    postOcr(img: Image): Observable<DataProfile> {

        var url = this.baseUrl + this.ocrApiUrl;

        return this.http
                    .post<DataProfile>(url, img, {
                        headers: new HttpHeaders({ 'Content-Type': 'application/json' })
                    })
                    .map((res) => {
                        //debugger;
                        //console.log("OK: ocr response from " + url);
                        //console.log("OCR Message: " + res.Text);
                        console.log(res);
                        return res;
                    })
                    .catch(error => {
                        console.log("Not-Ok: ocr response from " + url);
                        return new Observable<any>(error);
                    });
    }

    postProfile(data: ProfileResponse): Observable<DataProfile> {

        var url = this.baseUrl + this.profileUrl;

        return this.http
            .post<DataProfile>(url, data, {
                headers: new HttpHeaders({ 'Content-Type': 'application/json' })
            })
            .map((res) => {
                //debugger;
                //console.log("OK: ocr response from " + url);
                //console.log("OCR Message: " + res.Text);
                console.log(res);
                return res;
            })
            .catch(error => {
                console.log("Not-Ok: ocr response from " + url);
                return new Observable<any>(error);
            });
    }
}