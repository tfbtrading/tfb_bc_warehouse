pageextension 50600 "TFB Warehouse Setup" extends "Warehouse Setup"
{
    layout
    {
        addafter("Require Pick")
        {
            field("TFB Require Stock Availability"; Rec."TFB Require Stock Availability")
            {
                ApplicationArea = All;
                Importance = Standard;
                ToolTip = 'Used by warehouse shipment to indicate if stock availability is taken into account';
            }
        }

        addlast(General)
        {
            field("TFB Credit Tolerance"; Rec."TFB Credit Tolerance")
            {
                ApplicationArea = All;
                Importance = Standard;
                ToolTip = 'Used to indicate how much leeway is given to customer before shipment is put on hold';
            }
        }

    }

    actions
    {
    }
}