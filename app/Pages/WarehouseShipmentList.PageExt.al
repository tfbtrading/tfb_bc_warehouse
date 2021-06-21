pageextension 50606 "TFB Warehouse Shipment List" extends "Warehouse Shipment List" //MyTargetPageId
{
    layout
    {

        addafter("No.")
        {
            field("TFB 3PL Booking No."; Rec."TFB 3PL Booking No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the 3PL booking number';
                Visible = false;
            }
        }

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
                ToolTip = 'Specifies destination name';
            }
            field("TFB Destination Sub. No."; Rec."TFB Destination Sub. No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies destination ship-to location';
            }


        }


        modify("Location Code")
        {
            Visible = true;
        }
        movebefore("TFB Destination Type"; "Location Code")


        addafter(Status)
        {
            field("TFB Credit Hold"; Rec."TFB Credit Hold")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies whether a credit hold is placed on the warehouse shipment';

            }
            field("TFB Credit Override"; Rec."TFB Credit Override")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies if a credit hold has been overridden';
            }
            field(TrackingOkay; TrackingOkayVar)
            {
                ApplicationArea = All;
                Caption = 'Tracking Okay';
                ToolTip = 'Specifies if item tracking (lot details) have been entered correctly';
            }

            field(SentToWarehouse; SentToWarehouseVar)
            {
                ApplicationArea = All;
                Caption = 'Emailed to Whs.';
                ToolTip = 'Specifies if the warehouse shipment has been sent to 3PL warehouse';
            }
            field(TotalWeightToShip; Rec.GetTotalWeightToShip())
            {
                ApplicationArea = All;
                Caption = 'Weight pending shipment';
                ToolTip = 'Specifies the total weight requested for shipment';
                Visible = true;

            }
            field("TFB Reported Weight"; Rec."TFB Reported Weight")
            {
                ApplicationArea = All;
                ToolTip = 'Reported weight by warehouse';
                Visible = rec."TFB 3PL Booking No." <> '';
            }
        }

    }


    actions
    {
        addafter("Re&open")
        {
            Action("&Create Warehouse Shipments")
            {
                Image = NewWarehouseShipment;
                Enabled = true;
                ApplicationArea = All;
                RunObject = report "TFB Create Warehouse Shipments";
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Create a new warehouse shipment';

            }
            Action("&Email Warehouse")
            {
                Image = SendEmailPDF;
                Enabled = true;
                ApplicationArea = All;
                ToolTip = 'Email warehouse shipment to 3PL warehouse';

                trigger OnAction()

                var
                    WhseShipCodeUnit: Codeunit "TFB Whs. Ship. Mgmt";
                    EmailSuccess: Boolean;

                begin
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
            Action("&Send Credit Notes")
            {

                Image = CreditCardLog;
                Enabled = true;
                ApplicationArea = All;
                ToolTip = 'Email customers credit notices';

                trigger OnAction()

                var
                    WhseShipHeader: Record "Warehouse Shipment Header";
                    Customer: Record Customer;
                    WhseCreditNotify: CodeUnit "TFB Whse. Ship. Credit Notify";
                    WhseShipCodeUnit: CodeUnit "TFB Whs. Ship. Mgmt";

                    overdue, overCreditLimit : Boolean;


                begin

                    overdue := false;
                    overCreditLimit := false;

                    if WhseShipHeader.FindSet() then
                        repeat
                            if WhseShipHeader."TFB Destination Type" = WhseShipHeader."TFB Destination Type"::Customer then
                                If not WhseShipheader."TFB Credit Hold" then
                                    If Customer.Get(WhseShipheader."TFB Destination No.") then
                                        If WhseShipCodeUnit.CheckIfCreditHoldApplies(Customer, WhseShipCodeUnit.GetValueOfShipment(WhseShipheader), overdue, overCreditLimit) then begin
                                            WhseShipheader."TFB Credit Hold" := true;
                                            WhseShipheader.Modify();
                                            WhseCreditNotify.SendOneNotificationEmail(WhseShipheader, overdue, overCreditLimit);
                                        end;
                        until WhseShipHeader.Next() < 1;
                end;


            }

            Action("&Notify All Customers")
            {
                Image = SendEmailPDFNoAttach;
                Enabled = true;
                ApplicationArea = All;
                Promoted = True;
                PromotedIsBig = true;
                PromotedCategory = Process;
                ToolTip = 'Notifies all customers with outstanding warehouse shipments that a delivery is pending';


                trigger OnAction()

                var
                    WhseNotifyCU: Codeunit "TFB Whse. Ship. Notify";
                    NoOfEmailsSent: Integer;

                begin

                    NoOfEmailsSent := WhseNotifyCU.SendAllNotifications();

                    If NoOfEmailsSent > 0 then
                        Message('A total of %1 warehouse notifications were sent', NoOfEmailsSent);
                end;


            }

            Action("&Import from CartonCloud")
            {
                Image = Import;
                Enabled = true;
                ApplicationArea = All;
                Promoted = true;
                PromotedIsBig = true;
                ToolTip = 'Ímport from excel in standard cartoncloud format';

                trigger OnAction()

                var

                begin
                    ReadExcelSheet();
                    ImportExcelData();

                end;
            }

        }



    }

    views
    {
        addlast

        {
            view(ReadyToPost)
            {
                Caption = 'Ready to Post';
                Filters = where("TFB 3PL Booking No." = filter('<>'''''));
                SharedLayout = false;

                layout
                {
                    modify("TFB Reported Weight")
                    {
                        Visible = true;
                    }
                    modify(TotalWeightToShip)
                    {
                        Visible = true;
                    }
                    modify("TFB 3PL Booking No.")
                    {
                        Visible = true;
                    }


                    movelast(Control1; "TFB Reported Weight", TotalWeightToShip)
                }
            }
        }
    }



    local procedure ReadExcelSheet()
    var
        FileManagement: Codeunit "File Management";
        ExtFilterTxt: Label 'xlsx';
        FileFilterTxt: Label 'All files (*.xlsx)|*.xlsx';
        UploadExcelMsg: Label 'Choose file to upload';
        TempBlob: CodeUnit "Temp Blob";
        InStream: InStream;
        FromFile: Text;
        SheetName: Text;
    begin
        FileManagement.BLOBImportWithFilter(TempBlob, UploadExcelMsg, '', FileFilterTxt, ExtFilterTxt);
        If not TempBlob.HasValue() then exit;
        TempBlob.CreateInStream(InStream);
        SheetName := CopyStr(TempExcelBuffer.SelectSheetsNameStream(InStream), 1, 100);

        TempExcelBuffer.Reset();
        TempExcelBuffer.DeleteAll();
        TempExcelBuffer.OpenBookStream(InStream, SheetName);
        TempExcelBuffer.ReadSheet();
    end;


    local procedure ImportExcelData()
    var
        WhseShipment: Record "Warehouse Shipment Header";
        RowNo: Integer;

        ExcelLineRef: Code[20];

        MaxRowNo: Integer;
    begin
        RowNo := 0;

        MaxRowNo := 0;


        TempExcelBuffer.Reset();
        if TempExcelBuffer.FindLast() then
            MaxRowNo := TempExcelBuffer."Row No.";


        for RowNo := 2 to MaxRowNo do begin
            Evaluate(ExcelLineRef, GetValueAtCell(RowNo, 3));

            If WhseShipment.Get(ExcelLineRef) then begin

                Evaluate(WhseShipment."TFB 3PL Booking No.", GetValueAtCell(RowNo, 1));
                WhseShipment.Validate("TFB 3PL Booking No.");

                Evaluate(WhseShipment."TFB Reported Weight", GetValueAtCell(RowNo, 10));

                WhseShipment.Modify(true);

                //TODO add in automatic posting
            end;



        end;
        Message(ExcelImportSucessMsg);
        CurrPage.Update();
    end;

    local procedure GetValueAtCell(RowNo: Integer; ColNo: Integer): Text
    begin

        TempExcelBuffer.Reset();
        If TempExcelBuffer.Get(RowNo, ColNo) then
            exit(TempExcelBuffer."Cell Value as Text")
        else
            exit('');
    end;



    trigger OnAfterGetRecord()

    var

    begin
        TrackingOkayVar := not WhsShipMgmt.CheckOrderItemTrackingIssueExists(Rec."No.");

        SentToWarehouseVar := WhsShipMgmt.CheckIfAlreadySent(rec);
    end;

    var

        TempExcelBuffer: Record "Excel Buffer" temporary;
        WhsShipMgmt: CodeUnit "TFB Whs. Ship. Mgmt";
        SheetName: Text[100];

        UploadExcelMsg: Label 'Please Choose the Excel file.';
        NoFileFoundMsg: Label 'No Excel file found!';
        ExcelImportSucessMsg: Label 'Excel is successfully imported.';
        TrackingOkayVar: Boolean;
        SentToWarehouseVar: Boolean;




}