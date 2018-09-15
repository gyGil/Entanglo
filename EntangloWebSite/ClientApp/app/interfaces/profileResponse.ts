interface ProfileResponse {

    ProfileId: number;
    TableName: string; 
    Entities: [NlpEntity];
}

interface NlpEntity {

    IndexInfo: [IndexEntity];
    Id: number;
    Name: string;
    Type: string;
}

interface IndexEntity {

    line: number;
    end: number;
    start: number;
}

