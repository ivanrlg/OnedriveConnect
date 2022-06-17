codeunit 50500 OneDriveCU
{
    trigger OnRun()
    begin
    end;

    procedure GetFilesFromOneDrive()
    var
        fileMgt: Codeunit "File Management";
        httpClient: HttpClient;
        httpContent: HttpContent;
        httpResponse: HttpResponseMessage;
        httpHeader: HttpHeaders;
        Result: Boolean;
        Message: Text;
        OutPut: Text;
        JsonObject: JsonObject;
        JsonToken: JsonToken;
        JsonArray: JsonArray;
        OneDrive: Record OneDrive;
        FileArrayBase64: text;
        TempBLOB: codeunit "Temp Blob";
        OutStream: OutStream;
        InStr: InStream;
        Base64Convert: Codeunit "Base64 Convert";
        FileContent: Text;
    begin
        httpContent.GetHeaders(httpHeader);
        httpClient.Post(GetUrl, httpContent, httpResponse);

        httpResponse.Content().ReadAs(OutPut);

        if (httpResponse.HttpStatusCode <> 200) then begin
            Error(OutPut);
        end;

        if not JsonArray.ReadFrom(OutPut) then begin
            Error('Problem reading Json.');
        end;

        foreach JsonToken in JsonArray do begin
            JsonObject := JsonToken.AsObject();

            OneDrive.Init();
            OneDrive.Id := GetJsonToken(JsonObject, 'id').AsValue().AsText();
            OneDrive.Name := GetJsonToken(JsonObject, 'name').AsValue().AsText();
            OneDrive.Size := GetJsonToken(JsonObject, 'size').AsValue().AsDecimal() / 1024;
            OneDrive.ExtensionType1 := GetJsonToken(JsonObject, 'extensionType1').AsValue().AsText();
            OneDrive.ExtensionType2 := GetJsonToken(JsonObject, 'extensionType2').AsValue().AsText();
            OneDrive.Folder := GetJsonToken(JsonObject, 'folder').AsValue().AsBoolean();

            FileArrayBase64 := GetJsonToken(JsonObject, 'fileArray').AsValue().AsText();

            OneDrive.FileArray.CreateOutStream(OutStream);
            Base64Convert.FromBase64(FileArrayBase64, OutStream);

            if not OneDrive.Insert() then begin
                OneDrive.Modify();
            end;
        end;
    end;

    procedure DownloadFromCloud(Id: Code[50])
    var
        OneDrive: Record OneDrive;
        Istream1: InStream;
        Istream2: InStream;
        OStream: OutStream;
        TempBLOB: codeunit "Temp Blob";
        Content: Text;
        Filename: Text;
        Base64Convert: Codeunit "Base64 Convert";
        Data: BigText;
        FileArrayBase64, Base64String, OriginalString : text;
    begin
        OneDrive.Get(Id);

        Filename := OneDrive.Name;

        OneDrive.CalcFields(FileArray);
        if OneDrive.FileArray.HasValue then begin
            OneDrive.FileArray.CreateInStream(Istream1);
            FileArrayBase64 := Base64Convert.ToBase64(Istream1);
            DownloadFromStream(Istream1, 'Export', '', 'All Files (*.*)|*.*', Filename);
        end;
    end;

    procedure GetUrl(): Text
    var
        UrlLabel: Label '%1api/%2?Code=%3';
    begin
        exit(StrSubstNo(UrlLabel, BaseUrlUploadFunction, ApiName, CodeFunctions));
    end;

    local procedure GetJsonToken(JsonObject: JsonObject; TokenKey: Text) JsonToken: JsonToken;
    begin
        if not JsonObject.Get(TokenKey, JsonToken) then
            Error('Could not find a token with key %1', TokenKey);
    end;

    var
        BaseUrlUploadFunction: Label 'http://onedriveconnect.azurewebsites.net/', Locked = true;
        ApiName: Label 'GetItemsByFolder', Locked = true;
        CodeFunctions: Label 'tVfRsX6YyapklLUvmg5xKKHgoUWODhUBmnPRl2Ed-YuiAzFub0hi1g==', Locked = true;
}