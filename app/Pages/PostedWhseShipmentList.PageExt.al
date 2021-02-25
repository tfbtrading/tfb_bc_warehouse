pageextension 50614 "TFB Posted Whse. Shipment List" extends "Posted Whse. Shipment List" //MyTargetPageId
{
    layout
    {
        addafter("Shipment Date")
        {
            field("TFB Destination Type"; Rec."TFB Destination Type")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies destination type';
            }
            field("TFB Destination No."; Rec."TFB Destination No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies destination number';

            }
            field("TFB Destination Name"; Rec."TFB Destination Name")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies name of the destination';
            }
            field("TFB Destination Sub. No."; Rec."TFB Destination Sub. No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies if alternative ship-to is specified for destination';
            }
        }

    }

}