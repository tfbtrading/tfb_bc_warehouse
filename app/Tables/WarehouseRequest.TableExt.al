tableextension 50600 "TFB Warehouse Request" extends "Warehouse Request" //5765
{
    fields
    {
        field(50650; "TFB Destination Sub.No"; Code[20])
        {
            TableRelation = IF ("Destination Type" = CONST(Customer)) "Ship-to Address".Code WHERE("Customer No." = FIELD("Destination No."))
            ELSE
            IF ("Destination Type" = CONST(Vendor)) "Order Address".Code WHERE("Vendor No." = FIELD("Destination No."));
            Caption = 'Destination Sub. No';
        }


        field(50566; "TFB Destination Name"; Text[100])
        {
            Editable = false;
            Caption = 'Destination Name';

        }

        modify("Destination No.")
        {
            trigger OnAfterValidate()

            var
                WhseShipCodeUnit: Codeunit "TFB Whs. Ship. Mgmt";
            begin

                "TFB Destination Name" := WhseShipCodeUnit.ResolveDestinationName("Destination Type", "Destination No.");
            end;
        }
    }


}