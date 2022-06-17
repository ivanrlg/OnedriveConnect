table 50500 "OneDrive"
{
    Caption = 'OneDrive';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Id; Code[50])
        {
            Caption = 'Id';
            DataClassification = ToBeClassified;
        }
        field(2; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = ToBeClassified;
        }
        field(3; Size; Decimal)
        {
            Caption = 'Size';
            DataClassification = ToBeClassified;
        }
        field(4; ExtensionType1; Text[200])
        {
            Caption = 'ExtensionType1';
            DataClassification = ToBeClassified;
        }
        field(5; ExtensionType2; Text[10])
        {
            Caption = 'ExtensionType2';
            DataClassification = ToBeClassified;
        }
        field(6; Folder; Boolean)
        {
            Caption = 'Folder';
            DataClassification = ToBeClassified;
        }
        field(7; FileArray; Blob)
        {
            Caption = 'FileArray';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
    }
}
