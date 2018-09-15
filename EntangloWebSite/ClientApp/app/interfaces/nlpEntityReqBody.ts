interface NlpEntityRequestBody {
    Text: LineInfo[];
}
interface LineInfo {
    Text: string;
    LineNum: number;
}