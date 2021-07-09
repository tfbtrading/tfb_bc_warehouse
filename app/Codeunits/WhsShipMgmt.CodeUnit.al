codeunit 50602 "TFB Whs. Ship. Mgmt"
{


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Purch. Release", 'OnAfterCreateWhseRqst', '', false, false)]
    /// <summary> 
    /// Description for ExtWhsePurchRelease.
    /// </summary>
    /// <param name="PurchHeader">Parameter of type Record "Purchase Header".</param>
    /// <param name="PurchLine">Parameter of type Record "Purchase Line".</param>
    /// <param name="WhseRqst">Parameter of type Record "Warehouse Request".</param>
    /// <param name="WhseType">Parameter of type Option.</param>
    local procedure ExtWhsePurchRelease(var PurchHeader: Record "Purchase Header"; var PurchLine: Record "Purchase Line"; var WhseRqst: Record "Warehouse Request"; WhseType: Option)
    begin

        WhseRqst."TFB Destination Sub.No" := PurchHeader."Order Address Code";
        WhseRqst.Modify(false)

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Sales Release", 'OnBeforeCreateWhseRequest', '', false, false)]
    /// <summary> 
    /// Description for ExtWhseSalesRelease.
    /// </summary>
    /// <param name="SalesHeader">Parameter of type Record "Sales Header".</param>
    /// <param name="SalesLine">Parameter of type Record "Sales Line".</param>
    /// <param name="WhseRqst">Parameter of type Record "Warehouse Request".</param>
    /// <param name="WhseType">Parameter of type Option.</param>
    local procedure ExtWhseSalesRelease(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var WhseRqst: Record "Warehouse Request"; WhseType: Option)
    begin

        WhseRqst."TFB Destination Sub.No" := SalesHeader."Ship-to Code";

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Post Shipment", 'OnBeforeCheckWhseShptLines', '', false, false)]
    /// <summary> 
    /// Description for HandleOnBeforeCheckWhseShptLines.
    /// </summary>
    /// <param name="WarehouseShipmentLine">Parameter of type Record "Warehouse Shipment Line".</param>
    local procedure HandleOnBeforeCheckWhseShptLines(var WarehouseShipmentLine: Record "Warehouse Shipment Line")

    var
        Header: Record "Warehouse Shipment Header";
    begin

        If Header.get(WarehouseShipmentLine."No.") then
            If (not Header."TFB Special Handling") and (Header."TFB 3PL Booking No." = '') then
                Error('3PL Booking No must be filled before release');

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Shipment Release", 'OnBeforeRelease', '', false, false)]
    /// <summary> 
    /// Description for ExtWhsessSalesRelease.
    /// </summary>
    /// <param name="WarehouseShipmentHeader">Parameter of type Record "Warehouse Shipment Header".</param>
    local procedure ExtWhsessSalesRelease(var WarehouseShipmentHeader: Record "Warehouse Shipment Header")
    begin

        If (WarehouseShipmentHeader."TFB 3PL Booking No." = '') and (not WarehouseShipmentHeader."TFB Special Handling") then
            WarehouseShipmentHeader.FieldError("TFB 3PL Booking No.", 'Booking must be filled before release');

        If CheckOrderItemTrackingIssueExists(WarehouseShipmentHeader."No.") then
            Error('Item lot number details have not been entered');

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Transfer Release", 'OnAfterCreateOutboundWhseRequest', '', false, false)]
    /// <summary> 
    /// Description for HandleOnAfterCreateOutboundWhseRequest.
    /// </summary>
    /// <param name="TransferHeader">Parameter of type Record "Transfer Header".</param>
    /// <param name="WarehouseRequest">Parameter of type Record "Warehouse Request".</param>
    local procedure HandleOnAfterCreateOutboundWhseRequest(var TransferHeader: Record "Transfer Header"; var WarehouseRequest: Record "Warehouse Request")
    begin

    end;

    [EventSubscriber(ObjectType::Report, Report::"Get Source Documents", 'OnAfterCreateShptHeader', '', false, false)]
    /// <summary> 
    /// Description for HandleCreateShptHeader.
    /// </summary>
    /// <param name="WarehouseRequest">Parameter of type Record "Warehouse Request".</param>
    /// <param name="WarehouseShipmentHeader">Parameter of type Record "Warehouse Shipment Header".</param>
    /// <param name="SalesLine">Parameter of type Record "Sales Line".</param>
    local procedure HandleCreateShptHeader(WarehouseRequest: Record "Warehouse Request"; var WarehouseShipmentHeader: Record "Warehouse Shipment Header"; SalesLine: Record "Sales Line")

    var

    begin

        WarehouseShipmentHeader."TFB Destination Type" := WarehouseRequest."Destination Type";
        WarehouseShipmentHeader.Validate("TFB Destination No.", WarehouseRequest."Destination No.");
        WarehouseShipmentHeader.Validate("TFB Destination Sub. No.", WarehouseRequest."TFB Destination Sub.No");
        WarehouseShipmentHeader.Modify()
    end;

    [EventSubscriber(ObjectType::Report, Report::"Get Source Documents", 'OnAfterTransHeaderOnAfterGetRecord', '', false, false)]
    local procedure HandleOnAfterTransHeaderOnAfterGetRecord(var WarehouseRequest: Record "Warehouse Request"; TransferHeader: Record "Transfer Header"; var BreakReport: Boolean; var SkipRecord: Boolean)

    var

    begin

        WarehouseRequest."Destination No." := TransferHeader."Transfer-to Code";
        WarehouseRequest.Modify()
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Post Shipment", 'OnBeforePostedWhseShptHeaderInsert', '', false, false)]
    local procedure HandlePostWhseShptHeaderInsert(var PostedWhseShipmentHeader: Record "Posted Whse. Shipment Header"; WarehouseShipmentHeader: Record "Warehouse Shipment Header")
    begin

        PostedWhseShipmentHeader."TFB Destination Type" := WarehouseShipmentHeader."TFB Destination Type";
        PostedWhseShipmentHeader."TFB Destination No." := WarehouseShipmentHeader."TFB Destination No.";
        PostedWhseShipmentHeader."TFB Destination Sub. No." := WarehouseShipmentHeader."TFB Destination Sub. No.";
        PostedWhseShipmentHeader."TFB Destination Name" := WarehouseShipmentHeader."TFB Destination Name";
        PostedWhseShipmentHeader."TFB Instructions" := WarehouseShipmentHeader."TFB Instructions";
        PostedWhseShipmentHeader."TFB Address Print" := WarehouseShipmentHeader."TFB Address Print";
        PostedWhseShipmentHeader."TFB 3PL Booking No." := WarehouseShipmentHeader."TFB 3PL Booking No.";
        PostedWhseShipmentHeader."TFB Package Tracking No. " := WarehouseShipmentHeader."TFB Package Tracking No. ";

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Post Shipment", 'OnInitSourceDocumentHeaderOnBeforeSalesHeaderModify', '', false, false)]
    local procedure HandleInitSalesHeader(ModifyHeader: Boolean; var SalesHeader: Record "Sales Header"; var WarehouseShipmentHeader: Record "Warehouse Shipment Header")

    var

    begin

        SalesHeader."TFB 3PL Booking No." := WarehouseShipmentHeader."TFB 3PL Booking No.";
        SalesHeader."Package Tracking No." := WarehouseShipmentHeader."TFB Package Tracking No. ";

        ModifyHeader := true;

    end;

    [EventSubscriber(ObjectType::Report, Report::"Get Source Documents", 'OnBeforeWarehouseRequestOnAfterGetRecord', '', false, false)]
    local procedure HandleWarehouseRequestOnAfterGetRecord(var BreakReport: Boolean; var SkipRecord: Boolean; var WarehouseRequest: Record "Warehouse Request"; var WhseHeaderCreated: Boolean)

    var
        Line: Record "Sales Line";
        Item: Record Item;
        WhseSetup: Record "Warehouse Setup";

    begin


        case WarehouseRequest."Source Document" of
            WarehouseRequest."Source Document"::"Sales Order":
                begin

                    WhseSetup.Get();

                    //Check whether warehouse setup checks for inventory availability

                    If WhseSetup."TFB Require Stock Availability" then begin

                        //Get Sales Lines with Outstanding quantities
                        //Assume Skipping Record unless Line Item Found in Which Inventory is >0

                        Line.SetRange("Document Type", Line."Document Type"::Order);
                        Line.SetRange("Document No.", WarehouseRequest."Source No.");
                        Line.SetFilter("Outstanding Qty. (Base)", '>0');


                        if Line.FindSet(false, false) then
                            repeat

                                If Item.Get(Line."No.") then begin
                                    Item.SetFilter("Location Filter", 'MB');
                                    Item.CalcFields(Inventory);
                                    If Item.Inventory < Line."Outstanding Qty. (Base)" then
                                        SkipRecord := true;
                                end;

                            until Line.Next() < 1;


                    end;
                end;

        end;


    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Create Source Document", 'OnBeforeCheckIfSalesLine2ShptLine', '', true, true)]
    local procedure MyProcedure(var IsHandled: Boolean; var ReturnValue: Boolean; var SalesLine: Record "Sales Line")

    begin
    end;

    [EventSubscriber(ObjectType::Report, Report::"Get Source Documents", 'OnBeforeWhseShptHeaderInsert', '', true, true)]
    local procedure MyProcedure2(var WarehouseRequest: Record "Warehouse Request"; var WarehouseShipmentHeader: Record "Warehouse Shipment Header")

    begin

    end;

    [EventSubscriber(ObjectType::Report, Report::"Get Source Documents", 'OnBeforeWhseShptHeaderInsert', '', true, true)]
    local procedure MyProcedure3(var WarehouseRequest: Record "Warehouse Request"; var WarehouseShipmentHeader: Record "Warehouse Shipment Header")

    begin
    end;


    [EventSubscriber(ObjectType::Report, Report::"Get Source Documents", 'OnAfterCreateWhseDocuments', '', false, false)]
    local procedure HandleOnAfterSalesLine(var WarehouseRequest: Record "Warehouse Request"; var WhseReceiptHeader: Record "Warehouse Receipt Header"; var WhseShipmentHeader: Record "Warehouse Shipment Header"; WhseHeaderCreated: Boolean)
    begin


    end;


    procedure AutoPopulateLotDetails(var Header: record "Warehouse Shipment Header")

    var
    /*  TS: Record "Tracking Specification";
     ITDC: CodeUnit "Item Tracking Data Collection";
     WM: CodeUnit "Whse. Management";
     ITM: CodeUnit "Item Tracking Management";
     RE: CodeUnit "Reservation Engine Mgt."; */

    begin

        /*  ITM.UpdateWhseItemTrkgLines();
         ITDC.SelectMultipleTrackingNo();
         ITDC.AddSelectedTrackingToDataSet();
         TS.CopyTrackingFromReservEntry();
         TS.CheckItemTrackingQuantity();
         TS.InitFromSalesLine();*
         TS.InitTrackingSpecification(TS."Source Type"::); */

    end;

    /// <summary> 
    /// Determine what should be shown in the destination name field
    /// </summary>
    /// <param name="DestinationType">Parameter of type Enum "Warehouse Destination Type".</param>
    /// <param name="DestinationNo">Parameter of type Code[20].</param>
    /// <returns>Return variable "text[100]".</returns>
    procedure ResolveDestinationName(var DestinationType: Enum "Warehouse Destination Type"; DestinationNo: Code[20]): text[100]

    var
        WhseRqst: Record "Warehouse Request";

    begin

        case DestinationType of
            WhseRqst."Destination Type"::Customer:
                Exit(ResolveCustomerName(DestinationNo));

            WhseRqst."Destination Type"::Vendor:
                Exit(ResolveVendorName(DestinationNo));

            WhseRqst."Destination Type"::Location:
                Exit(ResolveLocationName(DestinationNo));

        end;


    end;

    local procedure ResolveCustomerName(DestinationNo: Code[20]): text[100]

    var
        Customer: record Customer;

    begin
        If Customer.Get(DestinationNo) then
            Exit(Customer.Name);
    end;

    local procedure ResolveVendorName(DestinationNo: Code[20]): text[100]

    var
        Vendor: record Vendor;

    begin
        If Vendor.Get(DestinationNo) then
            Exit(Vendor.Name);
    end;

    local procedure ResolveLocationName(DestinationNo: Code[20]): text[100]

    var
        Location: record Location;

    begin
        If Location.Get(DestinationNo) then
            Exit(Location.Name);
    end;

    procedure GetCustDelInstr(CustomerNo: Code[20]): Text
    var
        Customer: record Customer;
        DelInstrBuilder: TextBuilder;

    begin


        begin
            DelInstrBuilder.Clear();
            If Customer.get(CustomerNo) then begin

                DelInstrBuilder.AppendLine(Customer."Delivery Instructions");
                If Customer.PalletAccountNo <> '' then begin
                    DelInstrBuilder.AppendLine(format(Customer."TFB Pallet Acct Type"));
                    DelInstrBuilder.AppendLine(Customer.PalletAccountNo);
                end;

            end;

            Exit(DelInstrBuilder.ToText());


        end;
    end;

    procedure UpdateShipmentBookingDetails(WhsShip: Record "Posted Whse. Shipment Header")

    var
        Shipment: Record "Sales Shipment Header";
        Line: Record "Posted Whse. Shipment Line";

        CU: CodeUnit "Shipment Header - Edit";


    begin

        Line.SetRange("No.", WhsShip."No.");

        If not Line.IsEmpty() then begin

            Clear(Shipment);
            If Line."Posted Source Document" = Line."Posted Source Document"::"Posted Shipment" then
                if Shipment.Get(Line."Posted Source No.") then begin



                    Shipment."TFB 3PL Booking No." := WhsShip."TFB 3PL Booking No.";

                    If WhsShip."TFB Package Tracking No. " <> '' then
                        Shipment."Package Tracking No." := WhsShip."TFB Package Tracking No. ";

                    CU.Run(Shipment);

                end;
        end;



    end;


    procedure CheckIfAlreadySent(var WhseShipment: Record "Warehouse Shipment Header"): Boolean

    var
        CommLog: Record "TFB Communication Entry";


    begin


        Clear(CommLog);
        CommLog.SetRange("Record Type", CommLog."Record Type"::WSO);
        CommLog.SetRange(Direction, 20);
        CommLog.SetRange("Record No.", WhseShipment."No.");
        CommLog.SetRange("Source Type", 30);
        CommLog.SetRange("Source ID", WhseShipment."Location Code");

        If CommLog.IsEmpty() then
            Exit(false)
        else
            Exit(true)

    end;

    local procedure WriteToCommLog(WhseShipment: Record "Warehouse Shipment Header")

    var
        CommLog: Record "TFB Communication Entry";
        Location: Record Location;


    begin
        //Added direct integer values for commlog due to compiling issue publishing when using Enumeration

        Clear(CommLog);
        CommLog.Init();
        CommLog."Record Type" := CommLog."Record Type"::WSO;
        CommLog."Record No." := WhseShipment."No.";
        CommLog."Record Table No." := WhseShipment.RecordId().TableNo();
        CommLog.Direction := CommLog.Direction::Outbound; //outbound
        CommLog.Method := CommLog.Method::EMAIL; //email
        CommLog.SentTimeStamp := CurrentDateTime();
        CommLog."Source Type" := CommLog."Source Type"::Warehouse;
        CommLog."Source ID" := WhseShipment."Location Code";



        If Location.Get(WhseShipment."Location Code") then
            CommLog."Source Name" := Location.Name;

        CommLog.Insert();

    end;


    procedure SendEmailToWarehouse(var WhseShipment: Record "Warehouse Shipment Header"): Boolean

    var

        LocationTable: Record Location;
        RepSelWhse: Record "Report Selection Warehouse";
        CompanyInfo: Record "Company Information";
        Message: CodeUnit "Email Message";
        Email: CodeUnit Email;
        TempBlobCU: CodeUnit "Temp Blob";
        EmailRecordRef, VarEmailRecordRef : RecordRef;
        FieldRefVar: FieldRef;
        IStream: InStream;
        OStream: OutStream;
        EmailID, XmlParameters : Text;

        FileNameBuilder, SubjectNameBuilder : TextBuilder;
        Recipients: List of [Text];


    begin


        //First check if item tracking details have been entered

        If CheckOrderItemTrackingIssueExists(WhseShipment."No.") then
            If not Dialog.Confirm('Item tracking details have not been entered. Are you sure?', true) then
                exit;

        CompanyInfo.Get();

        LocationTable.Get(WhseShipment."Location Code");
        EmailID := LocationTable."E-Mail";
        FileNameBuilder.Append('Warehouse Shipment ');
        FileNameBuilder.Append(WhseShipment."No.");
        FileNameBuilder.Append('.pdf');
        FileNameBuilder.Replace('/', '-');

        SubjectNameBuilder.Append('Warehouse Shipment ');
        SubjectNameBuilder.Append(WhseShipment."No.");
        SubjectNameBuilder.Append(' from TFB');




        RepSelWhse.SetRange(Usage, RepSelWhse.Usage::Shipment);

        If RepSelWhse.FindFirst() then begin


            TempBlobCU.CreateOutStream(OStream);


            EmailRecordRef.GetTable(WhseShipment);
            FieldRefVar := EmailRecordRef.Field(WhseShipment.FieldNo("No."));
            FieldRefVar.SetRange(WhseShipment."No.");

            If EmailRecordRef.Count() > 0 then begin

                VarEmailRecordRef := EmailRecordRef;

                Report.SaveAs(RepSelWhse."Report ID", XmlParameters, ReportFormat::Pdf, OStream, VarEmailRecordRef);

                TempBlobCU.CreateInStream(IStream);
                Recipients.Add(EmailID);

                Message.Create(Recipients, SubjectNameBuilder.ToText(), GenerateEmailContent(WhseShipment), true);
                Message.AddAttachment(CopyStr(FileNameBuilder.ToText(), 1, 250), 'application/pdf', IStream);

                Email.Enqueue(Message, Enum::"Email Scenario"::Logistics);
                WriteToCommLog(WhseShipment);


            end;

        end;
    end;

    local procedure GenerateEmailContent(WhseShipment: Record "Warehouse Shipment Header"): Text

    var
        TFBCommonLibrary: CodeUnit "TFB Common Library";
        HTMLBuilder: TextBuilder;

    begin

        HTMLBuilder.Append(TFBCommonLibrary.GetHTMLTemplateActive('Warehouse Shipment', 'Instructions to ship goods'));

        HTMLBuilder.Replace('%{ExplanationCaption}', 'Notification type');
        HTMLBuilder.Replace('%{ExplanationValue}', 'Warehouse Pick and Pack Instructions');
        HTMLBuilder.Replace('%{DateCaption}', 'Due for Dispatch On');
        HTMLBuilder.Replace('%{DateValue}', Format(WhseShipment."Shipment Date", 0, 4));
        HTMLBuilder.Replace('%{ReferenceCaption}', 'Order References');
        HTMLBuilder.Replace('%{ReferenceValue}', WhseShipment."No.");
        HTMLBuilder.Replace('%{AlertText}', 'This is a system generated mail. Please do not reply');
        HTMLBuilder.Replace('%{EmailContent}', '');

        Exit(HTMLBuilder.ToText());

    end;

    procedure CheckIfCreditHoldApplies(Customer: Record Customer; NewShipmentValue: Decimal; var overdue: Boolean; var overCreditLimit: Boolean): Boolean

    var
        WhseSetup: Record "Warehouse Setup";
        BalanceAfterShipment: Decimal;

    begin

        WhseSetup.Get();

        Customer.SetRange("Date Filter", 0D, today());
        Customer.CalcFields("Balance (LCY)");
        Customer.CalcFields("Balance Due (LCY)");

        //Check if any invoices are overdue
        If Customer."Balance Due (LCY)" > WhseSetup."TFB Credit Tolerance" then
            overdue := true;

        //Check if new order to be shipped take customer over credit limit
        BalanceAfterShipment := Customer."Balance (LCY)" + NewShipmentValue;
        if BalanceAfterShipment > (Customer."Credit Limit (LCY)" + WhseSetup."TFB Credit Tolerance") then
            overCreditLimit := true;

        If overdue or overCreditLimit then exit(true) else exit(false);
    end;

    procedure GetValueOfShipment(WhseShipmentHeader: Record "Warehouse Shipment Header"): Decimal

    var
        Line: Record "Warehouse Shipment Line";
        TotalValue: Decimal;

    begin

        Line.SetRange("No.", WhseShipmentHeader."No.");
        Line.SetRange("Source Document", Line."Source Document"::"Sales Order");

        if Line.FindSet() then
            repeat

                TotalValue += GetSalesLineValue(Line."Source No.", Line."Source Line No.", Line."Qty. to Ship");


            until Line.Next() < 1;

        Exit(TotalValue);

    end;

    procedure CheckLineItemTrackingOkay(Line: Record "Warehouse Shipment Line"; QtyBaseToCheck: Decimal): Boolean
    var
        SalesLine: Record "Sales Line";
        TransferLine: Record "Transfer Line";
        Item: Record Item;
        ItemTracking: Record "Item Tracking Code";
        RecRef: RecordRef;
        QtyTracked: Decimal;
    begin

        Item.Get(Line."Item No.");
        If not ItemTracking.Get(Item."Item Tracking Code") then exit(true);

        If not ItemTracking."Lot Specific Tracking" then exit(true);

        case Line."Source Document" of
            Line."Source Document"::"Sales Order":
                begin
                    SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
                    SalesLine.SetRange("Document No.", Line."Source No.");
                    SalesLine.SetRange("Line No.", Line."Source Line No.");
                    If SalesLine.FindFirst() then begin

                        RecRef.GetTable(SalesLine);
                        QtyTracked := CheckSalesLineTrackedQty(RecRef);

                        If QtyBaseToCheck = QtyTracked then
                            Exit(true)
                        else
                            Exit(false);
                    end else
                        exit(false)
                end;
            Line."Source Document"::"Outbound Transfer":
                begin
                    TransferLine.SetRange("Document No.", Line."Source No.");
                    TransferLine.SetRange("Line No.", Line."Source Line No.");
                    If TransferLine.FindFirst() then begin
                        RecRef.GetTable(TransferLine);
                        QtyTracked := CheckSalesLineTrackedQty(RecRef);

                        If QtyBaseToCheck = QtyTracked then
                            Exit(true)
                        else
                            Exit(false);
                    end else
                        exit(false)
                end;
        end;

    end;


    //Compress Tracking specification



    procedure GetSalesLineValue(DocNo: Code[20]; LineNo: Integer; QtyToBeShipped: Decimal): Decimal
    var
        SalesLine: Record "Sales Line";

    begin

        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange("Document No.", DocNo);
        SalesLine.SetRange("Line No.", LineNo);
        If SalesLine.FindFirst() then
            Exit((SalesLine."Line Amount" / SalesLine.Quantity) * QtyToBeShipped);

    end;

    procedure CheckOrderItemTrackingIssueExists(DocNo: Code[20]): Boolean

    var

        Line: Record "Warehouse Shipment Line";
        IssueFound: Boolean;


    begin
        Line.SetRange("No.", DocNo);
        Line.SetRange("Source Document", Line."Source Document"::"Sales Order");
        IssueFound := false;
        if Line.FindSet() then
            repeat

                //Not return indicates that line item tracking is missing and set issue found to true
                If (not IssueFound) and (not CheckLineItemTrackingOkay(Line, Line."Qty. to Ship (Base)")) then
                    IssueFound := true;

            until Line.Next() < 1;

        Exit(IssueFound);
    end;


    local procedure CheckSalesLineTrackedQty(RecRef: RecordRef): Decimal

    var
        ReservationEntry: Record "Reservation Entry";
        FldRef: FieldRef;

        TotalQtyToHandle: Decimal;



    begin
        FldRef := RecRef.Field(3); // Document No
        ReservationEntry.SetRange("Source ID", FldRef.Value());
        FldRef := RecRef.Field(4); // Line No
        ReservationEntry.SetRange("Source Ref. No.", FldRef.Value());
        FldRef := RecRef.Field(6); // No.
        ReservationEntry.SetRange("Item No.", FldRef.Value());
        ReservationEntry.SetRange("Source Type", RecRef.Number());
        ReservationEntry.SetFilter("Item Tracking", '> %1', ReservationEntry."Item Tracking"::None);
        if ReservationEntry.FindSet() then
            repeat


                TotalQtyToHandle := TotalQtyToHandle + ABS(ReservationEntry."Qty. to Handle (Base)");

            until ReservationEntry.Next() = 0;

        exit(TotalQtyToHandle);
    end;
}
