pageextension 50603 "TFB Warehouse Shipment" extends "Warehouse Shipment" //7335
{
    layout
    {
        addafter("Posting Date")
        {
            field("TFB Credit Hold"; Rec."TFB Credit Hold")
            {
                ApplicationArea = All;
                ToolTip = 'Indicates if a credit hold exists on warehouse shipment';

            }

            group(CreditHold)
            {
                ShowCaption = false;
                Visible = Rec."TFB Credit Hold";

                field("TFB Credit Override"; Rec."TFB Credit Override")
                {
                    ApplicationArea = all;
                    Editable = Rec."TFB Credit Hold";
                    ToolTip = 'Indicates if credit issue should be overridden';
                }
            }

            field("TFB Special Handling"; Rec."TFB Special Handling")
            {
                ApplicationArea = All;
                Editable = true;
                ToolTip = 'Indicates that order is not sent automatically to warehouse';
            }

            group(Standard3PL)
            {
                ShowCaption = false;
                Visible = not Rec."TFB Special Handling";


                field("TFB 3PL Booking No."; Rec."TFB 3PL Booking No.")
                {
                    ApplicationArea = All;
                    Editable = true;
                    ToolTip = 'Indicates booking reference from 3PL Warehouse';

                }
            }
            field("TFB Sent Log"; ExistingCommLogEntry)
            {
                ApplicationArea = All;
                Editable = false;
                Caption = 'Sent to Warehouse';
                ToolTip = 'Indicates if message has already been sent to warehouse';

            }


        }
        addafter("Sorting Method")
        {
            group("TFBDestination Details")
            {
                Caption = 'Destination Details';
                field(Override; Override)
                {
                    ApplicationArea = All;
                    Caption = 'Override';
                    Editable = True;
                    ToolTip = 'Indicates if destination should be overridden';
                }

                field("TFB Destination Type"; Rec."TFB Destination Type")
                {
                    ApplicationArea = All;
                    Editable = Override;
                    Caption = 'Type';
                    ToolTip = 'Sets whether it is a customer, vendor, location';
                }
                field("TFB Destination No."; Rec."TFB Destination No.")
                {
                    ApplicationArea = All;
                    Editable = Override;
                    Caption = 'No.';
                    ToolTip = 'Unique no. of destination';
                }
                field("TFB Destination Name"; Rec."TFB Destination Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Name';
                    ToolTip = 'Name/description of destination';
                }
                group(SubLocation)
                {
                    Visible = True;

                    ShowCaption = false;
                    field("TFB Destination Sub. No."; Rec."TFB Destination Sub. No.")
                    {
                        ApplicationArea = All;
                        Editable = Override;
                        Caption = 'Alternative ShipTo';
                        ToolTip = 'Name/description of alternative ship-to for destination';

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
                ToolTip = 'Address details';
            }
            field("TFB Instructions"; Rec."TFB Instructions")
            {
                ApplicationArea = All;
                MultiLine = true;
                Width = 200;
                ToolTip = 'Warehouse instructions';
            }
            group(InstructionsInfo)
            {
                Visible = InstructionsDiffer;
                ShowCaption = false;

                label(InstructionsDiffer)
                {
                    Caption = 'Discrepency in instructions exist';
                    Visible = InstructionsDiffer;
                }
            }


            field("TFB Package Tracking No. "; Rec."TFB Package Tracking No. ")
            {
                ApplicationArea = All;
                Editable = true;
                ToolTip = 'Information on package tracking details if 3rd party courier is used';
            }
            field(TotalWeightToShip; Rec.GetTotalWeightToShip())
            {
                ApplicationArea = All;
                Caption = 'Weight pending shipment';
                ToolTip = 'Specifies the total weight requested for shipment';

            }
            field("TFB Reported Weight"; Rec."TFB Reported Weight")
            {
                ApplicationArea = All;
                ToolTip = 'Reported weight by warehouse';
                Visible = true;
            }
        }

        addlast(factboxes)
        {
            part(Customer; "Customer Details FactBox")
            {
                ApplicationArea = All;
                Provider = WhseShptLines;
                SubPageLink = "No." = field("Destination No.");
            }
        }

    }



    actions
    {
        addbefore("&Print")
        {
            Action("&Email Warehouse")
            {
                Image = SendEmailPDF;
                Enabled = true;
                ApplicationArea = All;
                Promoted = True;
                PromotedIsBig = true;
                PromotedCategory = Category4;
                ToolTip = 'Sends message with shipment details to 3PL warehouse';

                trigger OnAction()

                var
                    WhseShipCodeUnit: Codeunit "TFB Whs. Ship. Mgmt";
                    EmailSuccess: Boolean;
                    CreditPass: Boolean;

                begin
                    CreditPass := true;

                    If Rec."TFB Credit Hold" and not Rec."TFB Credit Override" then
                        If not Confirm('Customer is on credit hold for new shipments. Proceed?', false) then
                            CreditPass := false;

                    If CreditPass then
                        case WhseShipCodeUnit.CheckIfAlreadySent(rec) of
                            True:
                                If Confirm('Already sent to warehouse. Send again?', false) then
                                    EmailSuccess := WhseShipCodeUnit.SendEmailToWarehouse(Rec);
                            False:
                                EmailSuccess := WhseShipCodeUnit.SendEmailToWarehouse(Rec);
                        end;

                    If EmailSuccess then
                        Message('Warehouse shipment %1 sent successfully to location %2', rec."No.", Rec."Location Code");
                end;


            }

            Action("&Notify Customer")
            {
                Image = SendEmailPDFNoAttach;
                Enabled = true;
                ApplicationArea = All;
                Promoted = True;
                PromotedIsBig = true;
                PromotedCategory = Category4;
                ToolTip = 'Send details about warehouse shipment to customer';


                trigger OnAction()

                var
                    WhseNotifyCU: Codeunit "TFB Whse. Ship. Notify";
                    EmailSuccess: Boolean;

                begin

                    EmailSuccess := WhseNotifyCU.SendOneNotificationEmail(Rec);

                    If EmailSuccess then
                        Message('Warehouse Pick & Pack %1 sent successfully to customer %2', rec."No.", Rec."TFB Destination Name");
                end;
            }
            Action("&AutoPopulate Lots")
            {
                Image = LotInfo;
                Enabled = true;
                ApplicationArea = All;
                Promoted = True;
                PromotedIsBig = true;
                PromotedCategory = Category4;
                ToolTip = 'Autopopulate lot number tracking for warehouse shipment';


                trigger OnAction()

                var
                    WhseShipMgmtCU: Codeunit "TFB Whs. Ship. Mgmt";


                begin

                    WhseShipMgmtCU.AutoPopulateLotDetails(Rec);
                end;
            }
        }


    }

    trigger OnAfterGetRecord()
    begin
        DestinationName := WhseShipCodeUnit.ResolveDestinationName(Rec."TFB Destination Type", Rec."TFB Destination No.");
        ExistingCommLogEntry := WhseShipCodeUnit.CheckIfAlreadySent(Rec);
        InstructionsDiffer := CheckInstructionsForDifference();
        Override := False;
    end;

    var
        WhseShipCodeUnit: Codeunit "TFB Whs. Ship. Mgmt";
        Override: Boolean;


        DestinationName: Text[100];

        ExistingCommLogEntry: Boolean;

        InstructionsDiffer: Boolean;

    local procedure CheckInstructionsForDifference(): Boolean;

    var
        WhseLine: Record "Warehouse Shipment Line";
        SalesOrder: Record "Sales Header";

    begin

        WhseLine.SetRange("No.", Rec."No.");
        WhseLine.SetRange("Source Document", WhseLine."Source Document"::"Sales Order");

        If WhseLine.FindSet(false, false) then
            repeat

                If SalesOrder.Get(SalesOrder."Document Type"::Order, WhseLine."Source No.") then
                    If SalesOrder."TFB Instructions" <> Rec."TFB Instructions" then
                        Exit(true);


            until WhseLine.Next() = 0

        else
            Exit(false);

    end;

}