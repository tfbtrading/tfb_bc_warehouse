pageextension 50613 "TFB Posted Whse. Shipment" extends "Posted Whse. Shipment" //
{
    layout
    {
        addafter("Location Code")
        {
            field("TFB 3PL Booking No."; Rec."TFB 3PL Booking No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the 3PL booking number';
            }
            field("TFB Package Tracking No. "; Rec."TFB Package Tracking No. ")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the package tracking number if supplied';
            }
            group("TFBDestination Details")
            {
                Caption = 'Destination Details';
                field("TFB Destination Type"; Rec."TFB Destination Type")
                {
                    ApplicationArea = All;
                    Caption = 'Type';
                    ToolTip = 'Specifies the destination type';
                }
                field("TFB Destination No."; Rec."TFB Destination No.")
                {
                    ApplicationArea = All;
                    Caption = 'No.';
                    ToolTip = 'Specifies the destination number';
                }
                field("TFB Destination Name"; Rec."TFB Destination Name")
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                    ToolTip = 'Specifies the customers name';
                }
                group(TFBSubLocation)
                {
                    Visible = True;
                    ShowCaption = false;
                    field("TFB Destination Sub. No."; Rec."TFB Destination Sub. No.")
                    {
                        ApplicationArea = All;
                        Caption = 'Alt. Ship To';
                        ToolTip = 'Specifies if an alternative ship-to has been specified';

                    }
                }

            }

        }
        addafter("Shipment Method Code")
        {
            field("TFB Address Print"; Rec."TFB Address Print")
            {
                ApplicationArea = All;
                MultiLine = true;
                Width = 200;
                ToolTip = 'Specifies the address that has been sent to';
            }
            field("TFB Instructions"; Rec."TFB Instructions")
            {
                ApplicationArea = All;
                MultiLine = true;
                Width = 200;
                ToolTip = 'Specifies the instructions for shipment';
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        DestinationName := WhseShipCodeUnit.ResolveDestinationName(Rec."TFB Destination Type", Rec."TFB Destination No.");
    end;

    var
        WhseShipCodeUnit: Codeunit "TFB Whs. Ship. Mgmt";

        DestinationName: Text[100];

}