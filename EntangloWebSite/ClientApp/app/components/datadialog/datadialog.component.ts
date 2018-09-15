
import { Component, Inject, OnInit } from '@angular/core';
// Pop-up Dialog
import { MAT_DIALOG_DATA } from '@angular/material';
import { MatDialogRef } from '@angular/material';
import { MatDialog } from '@angular/material';
import * as interact from 'interactjs';

@Component({
    selector: 'datadialog',
    templateUrl: './datadialog.component.html',
    styleUrls: ['./datadialog.component.css']
})
export class DataDialogComponent implements OnInit {

    private interaction: any;

    constructor(public thisDialogRef: MatDialogRef<DataDialogComponent>,
        @Inject(MAT_DIALOG_DATA) public data: any) {
    }


    onCloseConfirm() {

        var dataType = document.getElementById('data-type');

        this.thisDialogRef.close(dataType);
    }

    onCloseCancel() {

        var dataType = document.getElementById('data-type');

        dataType.attributes[0].value = 'Cancelled';

        this.thisDialogRef.close(dataType);
    }

    onCamUp(e: any, when: string): void {

        console.log('dialog-camup');
    }

    onCamDown(e: any, when: string): void {

        console.log('dialog-camdown');
    }

    ngOnInit() {

        //this.initializeInteraction();
    }

}
