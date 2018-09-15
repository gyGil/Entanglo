interface NlpResult {
    StatusCode: string;
    Language: string;
    Entities: [NlpEntity];
}

interface NlpEntity {
    Name: string;
    Type: string;
}
/*
interface NlpResult {
    StatusCode: string;
    Language: string;
    Entities: [NlpEntity];
    ProfileStatus: bool;
    
}

interface NlpEntity {
    Name: NlpItem;
    Type: string;
}
*/

interface NlpItem {
    Text: string;
    SubText: NlpSubItem[];
}

interface NlpSubItem {
    Text: string;
    LineNum: number;
    StartIdx: number;
    EndIdx: number;
}
