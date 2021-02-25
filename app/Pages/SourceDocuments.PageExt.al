pageextension 50602 "TFB Source Documents" extends "Source Documents"
{
    layout
    {

        addafter("Destination No.")
        {
            field("Destination Name"; DestinationName)
            {
                ApplicationArea = All;
                Editable = false;
                Caption = 'Destination';
                ToolTip = 'Specifies destination name i.e. customers name';
            }
            field("TFB Destination Sub.No"; Rec."TFB Destination Sub.No")
            {
                ApplicationArea = All;
                Caption = 'Destination Sub No.';
                ToolTip = 'Specifies destination ship to. alternative';
            }
        }
    }

    actions
    {
    }

    var
        WhseShipCodeUnit: Codeunit "TFB Whs. Ship. Mgmt";
        DestinationName: Text[100];


    trigger OnAfterGetRecord()
    begin
        DestinationName := WhseShipCodeUnit.ResolveDestinationName(Rec."Destination Type", Rec."Destination No.");
    end;




}