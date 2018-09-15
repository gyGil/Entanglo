import { DataTableService } from '../../services/dataTable.service';
import { Component, OnInit } from '@angular/core';
import { } from '@angular/material';
import { Router } from '@angular/router';

@Component({
    selector: 'view-table',
    templateUrl: './viewTable.component.html',
    styleUrls: ['./viewTable.component.css']
})
export class ViewTableComponent implements OnInit {


    tableNames: any;
    selectedTable: string;
    rowsTable: string[][];
    colnames: string[];
    datapoints: string[][];
    message: string;

    constructor(private router: Router,
                private dataTableService: DataTableService) {

        this.message = "";
    }



    ngOnInit() {
        this.dataTableService.getUserTables()
            .subscribe(async res => {
                this.tableNames = res;
            },
            err => {
                console.log("request failed - ", err);
            });

    }

    onTableNameChange(tableName) {

        this.selectedTable = tableName;

        this.dataTableService.getDataTable(this.selectedTable)
            .subscribe(async res => {
                this.rowsTable = res;

                if (this.rowsTable.length > 0) {
                    this.colnames = this.rowsTable[0];
                    this.datapoints = new Array();
                    for (var i: number = 1; i < this.rowsTable.length; i++) {
                        this.datapoints[i - 1] = this.rowsTable[i];
                    }
                }
            },
            err => {
                console.log("request failed - ", err);
            });
    }

    resetProfile(event) {
        this.dataTableService.delProfile()
            .subscribe(async res => {
                if (res)
                    this.message = "Success to reset profile.";
                else
                    this.message = "Fail to reset profile.";
            },
            err => {
                console.log("request failed - ", err);
            });
    }

    resetProfileData(event) {
        this.dataTableService.delProfileData()
            .subscribe(async res => {
                if (res)
                    this.message = "Success to reset profile data.";
                else
                    this.message = "Fail to reset profile data.";
            },
            err => {
                console.log("request failed - ", err);
            });
    }

    resetUserTables(event) {
        this.dataTableService.delUserTables()
            .subscribe(async res => {
                if (res)
                    this.message = "Success to delete user tables.";
                else
                    this.message = "Fail to delete user tables.";
            },
            err => {
                console.log("request failed - ", err);
            });
    }
}
