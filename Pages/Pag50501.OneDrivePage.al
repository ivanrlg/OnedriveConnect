page 50501 OneDrivePage
{
    ApplicationArea = All;
    Caption = 'One Drive';
    PageType = List;
    SourceTable = OneDrive;
    UsageCategory = Lists;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Name; Rec.Name)
                {
                    Caption = 'File Name';
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    var
                        Question: Label 'Are you sure you want to download the file %1??';
                        Confirmed: Boolean;
                    begin
                        Confirmed := Dialog.Confirm(Question, false, Rec.Name);
                        if not Confirmed then
                            exit;

                        OneDriveCU.DownloadFromCloud(Rec.Id);
                    end;
                }
                field(Size; Rec.Size)
                {
                    Caption = 'Size(KB)';
                    ApplicationArea = All;
                }
                field(ExtensionType2; Rec.ExtensionType2)
                {
                    Caption = 'Extension Type';
                    ApplicationArea = All;
                }
            }

        }
    }

    actions
    {
        area(Processing)
        {
            action(Reload)
            {
                Caption = 'Reload';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ApplicationArea = All;
                trigger OnAction();
                begin
                    OneDriveCU.GetFilesFromOneDrive();
                end;
            }
        }
    }
    trigger OnOpenPage()
    begin
        OneDriveCU.GetFilesFromOneDrive();
    end;

    var
        OneDriveCU: Codeunit OneDriveCU;
}
