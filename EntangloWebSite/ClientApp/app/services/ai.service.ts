import { Inject, Injectable } from "@angular/core";
import { HttpClient, HttpHeaders } from "@angular/common/http";
import { Router } from '@angular/router';
import { Observable } from "rxjs";


@Injectable()
export class AiService {
    aiApiUrl: string = "api/ai/wordrecom";

    constructor(
        private http: HttpClient,
        private router: Router,
        @Inject('BASE_URL') private baseUrl: string) {
    }

    postWordRecom(wordRecomBody: wordRecomRequestBody): Observable<WordRecomResult> {
        var url = this.baseUrl + this.aiApiUrl;

        return this.http
            .post<WordRecomResult>(url, wordRecomBody, {
                headers: new HttpHeaders({ 'Content-Type': 'application/json' })
            })
            .map((res) => {
                console.log(res.StatusCode + ": word recom response from " + url);
                console.log(res.StatusCode);
                console.log("TargetWord: " + res.TargetWord);
                res.ClosestWords.forEach(word => {
                    console.log(word);
                });
                
                return res;
            })
            .catch(error => {
                console.log("Not-Ok: word recom response from " + url);
                return new Observable<any>(error);
            });
    }
    
}