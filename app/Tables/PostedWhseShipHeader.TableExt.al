tableextension 50612 "TFB Posted Whse. Ship. Header" extends "Posted Whse. Shipment Header" //7320
{
    fields
    {
        field(50652; "TFB Destination Type"; Enum "Warehouse Destination Type")
        {
            Editable = false;
            Caption = 'Destination Type';
        }
        field(50563; "TFB Destination No."; Code[20])
        {
            TableRelation = IF ("TFB Destination Type" = CONST(Vendor)) Vendor
            ELSE
            IF ("TFB Destination Type" = CONST(Customer)) Customer
            ELSE
            IF ("TFB Destination Type" = CONST(Location)) Location;
            Editable = false;
            Caption = 'Destination No.';


        }
        field(50564; "TFB Destination Sub. No."; Code[20])
        {
            TableRelation = IF ("TFB Destination Type" = CONST(Customer)) "Ship-to Address".Code WHERE("Customer No." = FIELD("TFB Destination No."))
            ELSE
            IF ("TFB Destination Type" = CONST(Vendor)) "Order Address".Code WHERE("Vendor No." = FIELD("TFB Destination No."));
            Caption = 'Destination Sub. No';
            Editable = false;
        }
        field(50566; "TFB Destination Name"; Text[100])
        {
            Editable = false;
            Caption = 'Destination Name';

        }
        field(50570; "TFB Instructions"; Text[2048])
        {
            Editable = false;
            Caption = 'Delivery Instructions';
            DataClassification = CustomerContent;
        }
        field(50580; "TFB Address Print"; Text[1024])
        {
            Editable = false;
            Caption = 'Delivery Address';
            DataClassification = CustomerContent;

        }
        field(50590; "TFB Dest. Spec."; Boolean)
        {
            Editable = false;
            Caption = 'Destination Specific';

        }
        field(50600; "TFB 3PL Booking No."; Text[30])
        {
            Editable = true;
            Caption = '3PL Booking No.';
            DataClassification = CustomerContent;

            trigger OnValidate()

            begin
                WhsCU.UpdateShipmentBookingDetails(Rec);
            end;
        }
        field(50610; "TFB Package Tracking No. "; Text[30])
        {
            Editable = true;
            Caption = 'Package Tracking No.';
            DataClassification = CustomerContent;

            trigger OnValidate()

            begin
                WhsCU.UpdateShipmentBookingDetails(Rec);
            end;
        }


    }

    local procedure UpdateShipmentHeaderDetails()

    var
        Customer: record Customer;
        ShipTo: record "Ship-to Address";
        WhseRqst: record "Warehouse Request";


    begin
        case "TFB Destination Type" of
            WhseRqst."Destination Type"::Customer:
                begin
                    Customer.Get("TFB Destination No.");
                    if "TFB Destination Sub. No." <> '' then begin
                        ShipTo.SetRange("Customer No.", "TFB Destination No.");
                        ShipTo.SetRange("Location Code", "TFB Destination Sub. No.");
                        if ShipTo.FindFirst() then begin

                            "Shipping Agent Code" := CopyStr(AssignCodeIfNotEmpty(ShipTo."Shipping Agent Code", Customer."Shipping Agent Code"), 1, 10);
                            "Shipping Agent Service Code" := CopyStr(AssignCodeIfNotEmpty(ShipTo."Shipping Agent Service Code", Customer."Shipping Agent Service Code"), 1, 10);
                            "Shipment Method Code" := CopyStr(AssignCodeIfNotEmpty(ShipTo."Shipment Method Code", Customer."Shipment Method Code"), 1, 10);

                        end;

                    end else begin
                        "Shipping Agent Code" := Customer."Shipping Agent Code";
                        "Shipping Agent Service Code" := Customer."Shipping Agent Service Code";
                        "Shipment Method Code" := Customer."Shipment Method Code";
                    end;

                end;



        end;
    end;

    local procedure AssignCodeIfNotEmpty(PrimaryCode: code[20]; BackUpCode: code[20]): code[20]

    begin
        if PrimaryCode <> '' then
            Exit(PrimaryCode)
        else
            Exit(BackUpCode)
    end;


    var
        WhsCU: Codeunit "TFB Whs. Ship. Mgmt";
}