import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { HttpClientModule, HTTP_INTERCEPTORS } from '@angular/common/http';
import { RouterModule } from '@angular/router';

import { AuthService } from './services/auth.service';
import { OcrService } from './services/ocr.service';
import { NlpService } from './services/nlp.service';
import { AiService } from './services/ai.service';
import { DataTableService } from './services/dataTable.service';

// Pop-up Dialog Module
import { MatCardModule } from '@angular/material';
import { MatButtonModule } from '@angular/material';
import { MatDialogModule } from '@angular/material';
import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';

import { AppComponent } from './components/app/app.component';
import { NavMenuComponent } from './components/navmenu/navmenu.component';
import { HomeComponent } from './components/home/home.component';
//import { CreateTableComponent } from './components/createTable/createTable.component';
import { DesignDataComponent } from './components/createTable/dataDesign.component';
import { DataDialogComponent } from './components/datadialog/datadialog.component';
import { ViewTableComponent } from './components/viewTable/viewTable.component';
import { AnalyzeDataComponent } from './components/analyzeData/analyzeData.component';
import { OcrComponent } from './components/InputData/ocr.component';
import { WebCamControlComponent } from './components/InputData/webcamControl.component';
import { LoginComponent } from './components/login/login.component';
import { LoginFacebookComponent } from './components/login/login.facebook.component';
import { LoginExternalProvidersComponent } from './components/login/login.externalproviders.component';


@NgModule({
    declarations: [
        AppComponent,
        NavMenuComponent,
        HomeComponent,
        //CreateTableComponent,
        DesignDataComponent,
        DataDialogComponent,
        ViewTableComponent,
        AnalyzeDataComponent,
        OcrComponent,
        WebCamControlComponent,
        LoginComponent,
        LoginFacebookComponent,
        LoginExternalProvidersComponent
    ],
    imports: [
        CommonModule,
        HttpClientModule,
        FormsModule,
        ReactiveFormsModule,
        MatDialogModule,         // Dialog Module
        BrowserModule,
        BrowserAnimationsModule,
        MatCardModule,
        MatButtonModule,
        MatDialogModule,
        RouterModule.forRoot([
            { path: '', redirectTo: 'home', pathMatch: 'full' },
            { path: 'home', component: HomeComponent },
            //{ path: 'create/table', component: CreateTableComponent },
            { path: 'design/data', component: DesignDataComponent },
            { path: 'datadialog', component: DataDialogComponent },
            { path: 'ocr', component: OcrComponent },
            { path: 'view/table', component: ViewTableComponent },
            { path: 'analyze/data', component: AnalyzeDataComponent },
            { path: 'login', component: LoginComponent },
            { path: '**', redirectTo: 'home' }
        ])
    ],
    providers: [
        AuthService,
        OcrService,
        NlpService,
        AiService,
        DataTableService
    ]
})
export class AppModuleShared {
}
