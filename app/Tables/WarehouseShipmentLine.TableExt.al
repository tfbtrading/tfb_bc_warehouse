tableextension 50607 "TFB Warehouse Shipment Line" extends "Warehouse Shipment Line"
{
    fields
    {

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