import { Inject, Injectable } from "@angular/core";
import { HttpClient, HttpHeaders } from "@angular/common/http";
import { Router } from '@angular/router';
import { Observable } from "rxjs";


@Injectable()
export class DataTableService {
    userTablesUrl: string = "api/DataView/UserTables";
    dataTableUrl: string = "api/DataView/DataTables";
    delProfileUrl: string = "api/DataView/DelProfile";
    delProfileDataUrl: string = "api/DataView/DelProfileData";
    delUserTablesUrl: string = "api/DataView/DelUserTables";

    constructor(
        private http: HttpClient,
        private router: Router,
        @Inject('BASE_URL') private baseUrl: string) {
    }
    
    getUserTables(): Observable<[string]> {
        var url = this.baseUrl + this.userTablesUrl;

        return this.http
            .get<string[]>(url, {
                headers: new HttpHeaders({ 'Content-Type': 'application/json' })
            })
            .map((res) => {
                return res;
            })
            .catch(error => {
                console.log("Not-Ok: " + url);
                return new Observable<any>(error);
            });
    }
    
    getDataTable(tableName: string): Observable<[[string]]> {
        var url = this.baseUrl + this.dataTableUrl + "?tableName=" + tableName;

        return this.http
            .get<string[][]>(url, {
                headers: new HttpHeaders({ 'Content-Type': 'application/json' })
            })
            .map((res) => {
                return res;
            })
            .catch(error => {
                console.log("Not-Ok: " + url);
                return new Observable<any>(error);
            });
    }

    delProfile(): Observable<any> {
        var url = this.baseUrl + this.delProfileUrl;

        return this.http
            .delete<any>(url, {
                headers: new HttpHeaders({ 'Content-Type': 'application/json' })
            })
            .map((res) => {               
                return res;
            })
            .catch(error => {
                console.log("Not-Ok: " + url);
                return new Observable<any>(error);
            });
    }

    delProfileData(): Observable<any> {
        var url = this.baseUrl + this.delProfileDataUrl;

        return this.http
            .delete<any>(url, {
                headers: new HttpHeaders({ 'Content-Type': 'application/json' })
            })
            .map((res) => {
                return res;
            })
            .catch(error => {
                console.log("Not-Ok: " + url);
                return new Observable<any>(error);
            });
    }

    delUserTables(): Observable<any> {
        var url = this.baseUrl + this.delUserTablesUrl;

        return this.http
            .delete<any>(url, {
                headers: new HttpHeaders({ 'Content-Type': 'application/json' })
            })
            .map((res) => {
                return res;
            })
            .catch(error => {
                console.log("Not-Ok: " + url);
                return new Observable<any>(error);
            });
    }
}