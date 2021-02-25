tableextension 50611 "TFB Posted Whse. Shipment Line" extends "Posted Whse. Shipment Line"
{
    fields
    {
        field(50660; "TFB Tracking Lines Exist"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = exist ("Whse. Item Tracking Line" where("Item No." = field("Item No."), "Source ID" = field("Source No.")));

        }
        field(50661; "TFB Shipping Agent Code"; Code[20])
        {
            FieldClass = FlowField;
            CalcFormula = lookup ("Warehouse Shipment Header"."Shipping Agent Code" where("No." = field("No.")));
            Editable = false;
            Caption = 'Shipping Agent Code';
        }
        field(50662; "TFB Destination Name"; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup ("Warehouse Shipment Header"."TFB Destination Name" where("No." = field("No.")));
            Caption = 'Destination Name';
        }

    }

}