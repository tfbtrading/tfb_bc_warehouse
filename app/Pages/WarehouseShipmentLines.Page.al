page 50609 "TFB Warehouse Shipment Lines"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Warehouse Shipment Line";
    Editable = false;
    Caption = 'Warehouse Shipment Lines';
    SourceTableView = where("Qty. to Ship (Base)" = filter(> 0));



    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Lookup = true;
                    ToolTip = 'Specifies warehouse shipment no.';

                    DrillDown = true;
                    DrillDownPageId = "Warehouse Shipment";
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies location for warehouse shipment';
                }
                field("TFB Shipping Agent Code"; Rec."TFB Shipping Agent Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies shipping agent code';
                }
                field("Shipment Date"; Rec."Shipment Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies shipment date';
                }
                field("Destination Type"; Rec."Destination Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies destination type';
                }
                field("Destination No."; Rec."Destination No.")
                {
                    ApplicationArea = All;
                    Lookup = true;
                    ToolTip = 'Specifies destination no. i.e. customer number';
                }
                field("TFB Destination Name"; Rec."TFB Destination Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies name of destination';


                    trigger OnLookup(var Text: Text): Boolean

                    var
                        Customer: Record Customer;
                        CustomerCard: Page "Customer Card";


                    begin
                        If Rec."Destination Type" = Rec."Destination Type"::Customer then
                            If Customer.Get(Rec."Destination No.") then begin
                                CustomerCard.SetRecord(Customer);
                                CustomerCard.Run();
                            end;
                    end;
                }
                field("Source Document"; Rec."Source Document")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies source document';
                }
                field("Source Line No."; Rec."Source Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies source line no';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies item number';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies variant code';
                }
                field("Description"; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies description of item';
                }

                field("Qty. to Ship"; Rec."Qty. to Ship")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies qty to ship';
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies unit of measure';
                }
                field("Qty. per Unit of Measure"; Rec."Qty. per Unit of Measure")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies base qty per unit of measure';
                }


            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Navigation)
        {
            Action("Customer")
            {
                Promoted = True;
                PromotedIsBig = True;
                PromotedOnly = True;
                Image = Customer;
                ApplicationArea = All;
                ToolTip = 'Opens related customer';
                trigger OnAction()

                var
                    Customer: Record Customer;
                    CustomerCard: Page "Customer Card";


                begin
                    If Rec."Destination Type" = Rec."Destination Type"::Customer then
                        If Customer.Get(Rec."Destination No.") then begin
                            CustomerCard.SetRecord(Customer);
                            CustomerCard.Run();
                        end;
                end;
            }

            action("Warehouse Shipment")
            {
                Promoted = True;
                PromotedIsBig = True;
                PromotedOnly = true;
                ToolTip = 'Opens related warehouse shipment';
                image = NewWarehouseShipment;
                RunObject = Page "Warehouse Shipment";
                RunPageLink = "No." = field("No.");
                RunPageMode = Edit;
                ApplicationArea = All;


            }
        }

    }
}