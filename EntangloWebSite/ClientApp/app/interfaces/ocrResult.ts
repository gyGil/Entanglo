interface DataProfile {

    Entities: [NlpEntity];
    Note: string;
    ResultCode: string; 
    StatusCode: string;
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

