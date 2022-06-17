codeunit 50500 OneDriveCU
{
    trigger OnRun()
    begin
    end;

    procedure GetFilesFromOneDrive()
    var
        OneDrive: Record OneDrive;
        Base64Convert: Codeunit "Base64 Convert";
        httpClient: HttpClient;
        httpContent: HttpContent;
        httpHeader: HttpHeaders;
        httpResponse: HttpResponseMessage;
        JsonArray: JsonArray;
        JsonObject: JsonObject;
        JsonToken: JsonToken;
        OutStream: OutStream;
        FileArrayBase64: text;
        OutPut: Text;
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

        OneDrive.DeleteAll();

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
        Base64Convert: Codeunit "Base64 Convert";
        Istream: InStream;
        FileArrayBase64: text;
        Filename: Text;
    begin
        OneDrive.Get(Id);

        Filename := OneDrive.Name;

        OneDrive.CalcFields(FileArray);
        if OneDrive.FileArray.HasValue then begin
            OneDrive.FileArray.CreateInStream(Istream);
            FileArrayBase64 := Base64Convert.ToBase64(Istream);
            DownloadFromStream(Istream, 'Export', '', 'All Files (*.*)|*.*', Filename);
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
