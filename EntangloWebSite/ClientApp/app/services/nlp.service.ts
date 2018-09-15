import { Inject, Injectable } from "@angular/core";
import { HttpClient, HttpHeaders } from "@angular/common/http";
import { Router } from '@angular/router';
import { Observable } from "rxjs";


@Injectable()
export class NlpService {
    nlpApiUrl: string = "api/ocr/nlp";

    constructor(
        private http: HttpClient,
        private router: Router,
        @Inject('BASE_URL') private baseUrl: string) {
    }

    postNlp(nlpBody: NlpRequestBody): Observable<NlpResult> {
        var url = this.baseUrl + this.nlpApiUrl;


        return this.http
            .post<NlpResult>(url, nlpBody, {
                headers: new HttpHeaders({ 'Content-Type': 'application/json' })
            })
            .map((res) => {
                console.log("OK: nlp response from " + url);

                console.log("NLP Message: " + res.StatusCode);
                //res.Entities.forEach(entity => {
                //    console.log("Entity: " + entity);
                //});

                return res;
            })
            .catch(error => {
                console.log("Not-Ok: nlp response from " + url);
                return new Observable<any>(error);
            });

    }
}