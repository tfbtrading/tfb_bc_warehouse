report 50604 "TFB Create Warehouse Shipments"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;
    UseRequestPage = True;
    Caption = 'Create Warehouse Shipments';

    dataset
    {


        dataitem("Warehouse Request"; "Warehouse Request")
        {

            RequestFilterFields = "Location Code", "Source Document", "Source No.", "Destination Type", "Destination No.", "Shipping Agent Code";

            trigger OnPreDataItem()
            var
                WhseShipHeader: Record "Warehouse Shipment Header";
            begin
                Window.Open(Text001Msg);
                IF WhseShipHeader.findlast() THEN
                    LastShipmentNo := WhseShipHeader."No.";
            end;

            trigger OnAfterGetRecord()

            var
                Customer: Record Customer;
                PurchaseLine: record "Purchase Line";
                SalesLine: record "Sales Line";
                TransferLine: record "Transfer Line";
                WhseActLine: Record "Warehouse Activity Line";
                WhseRequest: record "Warehouse Request";
                WhseShipHeader: Record "Warehouse Shipment Header";
                GetSourceDocuments: report "Get Source Documents";
                ReleaseWhseShipment: Codeunit "Whse.-Shipment Release";
                AppendShipmentFound: Boolean;

            begin
                Window.Update(1, STRSUBSTNO('%1 %2 (%3)', "Warehouse Request"."Source Document", "Warehouse Request"."Source No.", "Warehouse Request"."Location Code"));

                //Copy primary key filters
                WhseRequest.SETRANGE(Type, "Warehouse Request".Type);
                WhseRequest.SETRANGE("Location Code", "Warehouse Request"."Location Code");
                WhseRequest.SETRANGE("Source Type", "Warehouse Request"."Source Type");
                WhseRequest.SETRANGE("Source Subtype", "Warehouse Request"."Source Subtype");
                WhseRequest.SETRANGE("Source No.", "Warehouse Request"."Source No.");

                //Set ToDate filter on document lines
                SalesLine.SETFILTER("Shipment Date", '..%1', ToDate);

                PurchaseLine.SETFILTER("Planned Receipt Date", '..%1', ToDate);
                TransferLine.SETFILTER("Shipment Date", '..%1', ToDate);
                CLEAR(GetSourceDocuments);

                //Check Blocked Customer
                IF "Warehouse Request"."Source Type" = 37 THEN
                    IF Customer.GET("Warehouse Request"."Destination No.") THEN
                        IF (Customer.Blocked = Customer.Blocked::Ship) OR (Customer.Blocked = Customer.Blocked::All) THEN
                            CurrReport.SKIP();

                //Find already created shipments for the same destination (also existing if applicable)
                IF CombineShipments THEN BEGIN
                    AppendShipmentFound := FALSE;
                    WhseShipHeader.SETRANGE("Location Code", "Warehouse Request"."Location Code");
                    WhseShipHeader.SETRANGE("TFB Destination Type", "Warehouse Request"."Destination Type");
                    WhseShipHeader.SETRANGE("TFB Destination No.", "Warehouse Request"."Destination No.");
                    WhseShipHeader.SETRANGE("TFB Destination Sub. No.", "Warehouse Request"."TFB Destination Sub.No");
                    WhseShipHeader.SETRANGE("Shipping Agent Code", "Warehouse Request"."Shipping Agent Code");
                    IF AppendToExisting = AppendToExisting::Never THEN
                        WhseShipHeader.SETFILTER("No.", '>%1', LastShipmentNo);
                    IF WhseShipHeader.FindSet(false, false) THEN BEGIN
                        REPEAT
                            IF AppendToExisting = AppendToExisting::NoPick THEN BEGIN
                                WhseActLine.SETRANGE("Whse. Document Type", WhseActLine."Whse. Document Type"::Shipment);
                                WhseActLine.SETRANGE("Whse. Document No.", WhseShipHeader."No.");
                                IF NOT WhseActLine.IsEmpty() THEN
                                    AppendShipmentFound := TRUE;
                            END ELSE
                                AppendShipmentFound := TRUE;
                        UNTIL (WhseShipHeader.Next() = 0) OR (AppendShipmentFound);
                        IF AppendShipmentFound THEN BEGIN
                            IF WhseShipHeader.Status = WhseShipHeader.Status::Released THEN
                                ReleaseWhseShipment.Reopen(WhseShipHeader);

                            GetSourceDocuments.SetOneCreatedShptHeader(WhseShipHeader);
                        END;
                    END;
                END;

                //Create shipment / Insert lines
                GetSourceDocuments.SetHideDialog(TRUE);
                GetSourceDocuments.USEREQUESTPAGE(FALSE);
                GetSourceDocuments.SETTABLEVIEW(WhseRequest);
                GetSourceDocuments.SETTABLEVIEW(SalesLine);
                GetSourceDocuments.SETTABLEVIEW(PurchaseLine);
                GetSourceDocuments.SETTABLEVIEW(TransferLine);
                GetSourceDocuments.Run();


            end;

            trigger OnPostDataItem()

            begin
                UpdateDatesAndReleaseShipments();

                Window.Close();

            end;


        }



    }

    requestpage
    {

        SaveValues = true;

        layout
        {
            area(Content)
            {
                group(Options)
                {
                    field("Ending Date"; ToDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Ending Date';
                        ToolTip = 'Specifies the date up to which shipment dates are specified to be included';

                    }
                    field("Ignore Inventory"; IgnoreInventory)
                    {
                        ApplicationArea = All;
                        Caption = 'Ignore Inventory';
                        ToolTip = 'Specifies if inventory availability should be ignored';

                    }
                    field("Combine Shipments";
                    CombineShipments)
                    {
                        ApplicationArea = All;
                        Caption = 'Combined Shipments';
                        ToolTip = 'Specifies if items for a single destination should be combined';

                        trigger OnValidate()

                        begin
                            RequestOptionsPage.Update();
                        end;
                    }
                    field("Append to Existing Shipment"; AppendToExisting)
                    {
                        ApplicationArea = All;
                        Caption = 'Append to Existing';
                        ToolTip = 'Specifies if any new items should be added to existing warehouse shipments';
                        Enabled = true;
                    }
                }
            }
        }


    }


    var
        Window: Dialog;
        CombineShipments: Boolean;
        LastShipmentNo: Code[20];
        ToDate: Date;
        IgnoreInventory: Boolean;
        AppendToExisting: Enum "TFB Whse. Append To Existing";
        Text001Msg: Label 'Creating Warehouse Shipments:\#1############################', Comment = '%1=Warehouse Shipment ID';






    local procedure UpdateDatesAndReleaseShipments()

    var
        WhseShipheader: Record "Warehouse Shipment Header";
        //Customer: Record Customer;
        WhseShipCodeUnit: CodeUnit "TFB Whs. Ship. Mgmt";
    //WhseCreditNotify: CodeUnit "TFB Whse. Ship. Credit Notify";
    //overdue: Boolean;
    //overCreditLimit: Boolean;
    begin
        WhseShipheader.SetRange(Status, WhseShipheader.Status::Open);
        If WhseShipheader.Findset(false, false) then
            repeat
                //TODO Reactive Credit management
                // overdue := false;
                // overCreditLimit := false;

                //Update to next working date if not already sent to warehouse

                If not WhseShipCodeUnit.CheckIfAlreadySent(WhseShipheader) or not WhseShipheader."TFB Special Handling" then begin
                    WhseShipheader."Shipment Date" := GetNextWorkDay();
                    WhseShipheader."Posting Date" := WhseShipheader."Shipment Date";
                    WhseShipheader.Modify();
                end;

            //Check customer status in terms of credit worthiness

            /*  if WhseShipHeader."TFB Destination Type" = WhseShipHeader."TFB Destination Type"::Customer then
                 If not WhseShipheader."TFB Credit Hold" then
                     If Customer.Get(WhseShipheader."TFB Destination No.") then
                         If WhseShipCodeUnit.CheckIfCreditHoldApplies(Customer, WhseShipCodeUnit.GetValueOfShipment(WhseShipheader), overdue, overCreditLimit) then begin
                             WhseShipheader."TFB Credit Hold" := true;
                             WhseShipheader.Modify();
                             WhseCreditNotify.SendOneNotificationEmail(WhseShipheader, overdue, overCreditLimit);
                         end; */

            Until WhseShipheader.Next() = 0;

    end;

    local procedure GetNextWorkDay(): Date

    var
        CompanyInfo: Record "Company Information";
        CustCalendarChange: Record "Customized Calendar Change";
        CalendarMgt: CodeUnit "Calendar Management";
        CalcDateFormula: DateFormula;
        TargetDate: Date;
        NonWorking: Boolean;

    begin
        Evaluate(CalcDateFormula, '1D');
        TargetDate := CalcDate(CalcDateFormula, Today());
        CompanyInfo.Get();
        CustCalendarChange.SetSource(CustCalendarChange."Source Type"::Company, '', '', CompanyInfo."Base Calendar Code");
        repeat
            NonWorking := CalendarMgt.IsNonworkingDay(TargetDate, CustCalendarChange);
            If NonWorking then
                TargetDate := CalcDate(CalcDateFormula, TargetDate);
        Until Not NonWorking;

        Exit(TargetDate);

    end;




}