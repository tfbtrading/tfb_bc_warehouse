tableextension 50601 "TFB Warehouse Shipment Header" extends "Warehouse Shipment Header" //7320
{
    fields
    {
        field(50652; "TFB Destination Type"; Enum "Warehouse Destination Type")
        {
            Editable = true;
            Caption = 'Destination Type';
        }
        field(50563; "TFB Destination No."; Code[20])
        {
            TableRelation = IF ("TFB Destination Type" = CONST(Vendor)) Vendor
            ELSE
            IF ("TFB Destination Type" = CONST(Customer)) Customer
            ELSE
            IF ("TFB Destination Type" = CONST(Location)) Location;
            Editable = true;
            Caption = 'Destination No.';

            trigger OnValidate()

            var
                WhseShipCodeUnit: Codeunit "TFB Whs. Ship. Mgmt";
            begin

                "TFB Destination Name" := WhseShipCodeUnit.ResolveDestinationName("TFB Destination Type", "TFB Destination No.");
                UpdateShipmentHeaderDetails();
            end;
        }
        field(50564; "TFB Destination Sub. No."; Code[20])
        {
            TableRelation = IF ("TFB Destination Type" = CONST(Customer)) "Ship-to Address".Code WHERE("Customer No." = FIELD("TFB Destination No."))
            ELSE
            IF ("TFB Destination Type" = CONST(Vendor)) "Order Address".Code WHERE("Vendor No." = FIELD("TFB Destination No."));
            Caption = 'Destination Sub. No';
            Editable = true;

            trigger OnValidate()

            begin
                UpdateShipmentHeaderDetails();
            end;
        }
        field(50566; "TFB Destination Name"; Text[100])
        {
            Editable = false;
            Caption = 'Destination Name';

        }
        field(50570; "TFB Instructions"; Text[2048])
        {
            Editable = true;
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
            DataClassification = CustomerContent;
        }
        field(50600; "TFB 3PL Booking No."; Text[30])
        {
            Editable = true;
            Caption = '3PL Booking No.';
            DataClassification = CustomerContent;
        }
        field(50610; "TFB Package Tracking No. "; Text[30])
        {
            Editable = true;
            Caption = 'Package Tracking No.';
            DataClassification = CustomerContent;

        }
        field(50620; "TFB Credit Hold"; Boolean)
        {
            Editable = false;
            Caption = 'Customer Credit Hold';
            DataClassification = CustomerContent;
        }
        field(50630; "TFB Credit Override"; Boolean)
        {
            Editable = true;
            Caption = 'Override Credit Hold';
            DataClassification = CustomerContent;
        }
        field(50640; "TFB Special Handling"; Boolean)
        {
            Editable = true;
            Caption = 'Special Handling';
            DataClassification = CustomerContent;
        }
        field(50650; "TFB Reported Weight"; Decimal)
        {
            Editable = false;
            Caption = 'Reported Weight';
            DataClassification = CustomerContent;

        }


    }

    /// <summary>
    /// Calculated the total weight of items that are scheduled to be shipped by looking at the item
    /// </summary>
    /// <returns>Return value of type Decimal.</returns>
    procedure GetTotalWeightToShip(): Decimal

    var
        Line: Record "Warehouse Shipment Line";
        Item: Record Item;
        Weight: Decimal;

    begin

        Line.SetRange("No.", Rec."No.");
        Line.SetLoadFields("Qty. to Ship (Base)", "Item No.");
        If Line.FindSet(false, false) then
            repeat begin

                If Item.Get(Line."Item No.") then
                    Weight += Line."Qty. to Ship (Base)" * Item."Net Weight";

            end until Line.Next() = 0;

        Exit(Weight);

    end;

    local procedure UpdateShipmentHeaderDetails()

    var
        Customer: record Customer;
        Location: record Location;
        ShipTo: record "Ship-to Address";
        WhseRqst: record "Warehouse Request";
        WhsShipCodeUnit: CodeUnit "TFB Whs. Ship. Mgmt";
        AddressCodeUnit: CodeUnit "Format Address";
        AddrArray: array[8] of Text[100];

        TxtBuilder: TextBuilder;


    begin
        case "TFB Destination Type" of
            WhseRqst."Destination Type"::Customer:
                begin
                    Customer.Get("TFB Destination No.");
                    "TFB Instructions" := CopyStr(WhsShipCodeUnit.GetCustDelInstr("TFB Destination No."), 1, 2048);


                    if "TFB Destination Sub. No." <> '' then begin
                        ShipTo.SetRange("Customer No.", "TFB Destination No.");
                        ShipTo.SetRange(Code, "TFB Destination Sub. No.");
                        if ShipTo.FindFirst() then begin

                            "Shipping Agent Code" := CopyStr(AssignCodeIfNotEmpty(ShipTo."Shipping Agent Code", Customer."Shipping Agent Code"), 1, 10);
                            "Shipping Agent Service Code" := CopyStr(AssignCodeIfNotEmpty(ShipTo."Shipping Agent Service Code", Customer."Shipping Agent Service Code"), 1, 10);
                            "Shipment Method Code" := CopyStr(AssignCodeIfNotEmpty(ShipTo."Shipment Method Code", Customer."Shipment Method Code"), 1, 10);


                            //Populate address for print based on Customer alternate location details
                            AddressCodeUnit.FormatAddr(AddrArray, ShipTo.Name, ShipTo."Name 2", ShipTo.Contact, ShipTo.Address, ShipTo."Address 2", ShipTo.City, ShipTo."Post Code", ShipTo.County, ShipTo."Country/Region Code");
                            TxtBuilder.AppendLine(AddrArray[1]);
                            TxtBuilder.AppendLine(AddrArray[2]);
                            TxtBuilder.AppendLine(AddrArray[3]);
                            TxtBuilder.AppendLine(AddrArray[4]);
                            TxtBuilder.AppendLine(AddrArray[5]);
                            "TFB Address Print" := CopyStr(TxtBuilder.ToText(), 1, 1024);
                        end;

                    end else begin
                        "Shipping Agent Code" := Customer."Shipping Agent Code";
                        "Shipping Agent Service Code" := Customer."Shipping Agent Service Code";
                        "Shipment Method Code" := Customer."Shipment Method Code";

                        //Populate address for print based on Customer header details
                        AddressCodeUnit.Customer(AddrArray, Customer);
                        TxtBuilder.AppendLine(AddrArray[1]);
                        TxtBuilder.AppendLine(AddrArray[2]);
                        TxtBuilder.AppendLine(AddrArray[3]);
                        TxtBuilder.AppendLine(AddrArray[4]);
                        TxtBuilder.AppendLine(AddrArray[5]);
                        "TFB Address Print" := CopyStr(TxtBuilder.ToText(), 1, 1024);
                    end;

                end;

            WhseRqst."Destination Type"::Location:

                If Location.Get("TFB Destination No.") then begin
                    AddressCodeUnit.FormatAddr(AddrArray, Location.Name, Location."Name 2", Location.Contact, Location.Address, Location."Address 2", Location.City, Location."Post Code", Location.County, Location."Country/Region Code");
                    TxtBuilder.AppendLine(AddrArray[1]);
                    TxtBuilder.AppendLine(AddrArray[2]);
                    TxtBuilder.AppendLine(AddrArray[3]);
                    TxtBuilder.AppendLine(AddrArray[4]);
                    TxtBuilder.AppendLine(AddrArray[5]);
                    "TFB Address Print" := CopyStr(TxtBuilder.ToText(), 1, 1024);
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


}