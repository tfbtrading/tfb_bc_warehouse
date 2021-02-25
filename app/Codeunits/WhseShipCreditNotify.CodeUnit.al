codeunit 50601 "TFB Whse. Ship. Credit Notify"
{
    trigger OnRun()
    begin

    end;

    /// <summary> 
    /// Generate the content that gets sent in a notification about a credit issue with a warehouse shipment
    /// </summary>
    /// <param name="WhseShip">Parameter of type Record "Warehouse Shipment Header".</param>
    /// <param name="Customer">Parameter of type Record Customer.</param>
    /// <param name="Overdue">Parameter of type Boolean.</param>
    /// <param name="OverCreditLimit">Parameter of type Boolean.</param>
    /// <returns>Return variable "Text".</returns>
    local procedure GenerateNotificationContent(WhseShip: Record "Warehouse Shipment Header"; Customer: Record Customer; Overdue: Boolean; OverCreditLimit: Boolean; var HTMLBuilder: TextBuilder): Boolean

    var

        CustCalendarChange: Array[2] of Record "Customized Calendar Change";
        Item: Record Item;
        WhseLines: Record "Warehouse Shipment Line";
        OrderLine: Record "Sales Line";
        ShippingAgent: Record "Shipping Agent";
        WhseSetup: Record "Warehouse Setup";
        UoM: Record "Unit of Measure";
        WhseShipCU: CodeUnit "TFB Whs. Ship. Mgmt";
        CalMgmt: CodeUnit "Calendar Management";
        SuppressLine: Boolean;
        ExpectedDate: Date;
        LineCount: Integer;
        tdTxt: label '<td valign="top" style="line-height:15px;">%1</td>', comment = '%1=table data html';
        BodyBuilder: TextBuilder;
        CommentBuilder: TextBuilder;
        LineBuilder: TextBuilder;
        ReferenceBuilder: TextBuilder;



    begin


        Clear(WhseLines);
        WhseSetup.Get();
        WhseLines.SetRange("No.", WhseShip."No.");
        WhseLines.SetFilter("Qty. to Ship (Base)", '>0');

        Customer.SetRange("Date Filter", 0D, Today());
        Customer.CalcFields("Balance (LCY)", "Balance Due (LCY)");

        If WhseLines.FindSet(false) then begin


            HTMLBuilder.Replace('%{ExplanationCaption}', 'Notification type');
            HTMLBuilder.Replace('%{ExplanationValue}', 'Order Credit Issue Notification');
            HTMLBuilder.Replace('%{DateCaption}', 'Due for Dispatch On');
            HTMLBuilder.Replace('%{DateValue}', Format(WhseShip."Shipment Date", 0, 4));
            HTMLBuilder.Replace('%{ReferenceCaption}', 'Order References');
            ReferenceBuilder.Append(StrSubstNo('Our order %1', WhseShip."No."));

            If WhseShip."External Document No." <> '' then
                ReferenceBuilder.Append(StrSubstNo(' and <b>your PO#</b> is %1', WhseShip."External Document No."));


            HTMLBuilder.Replace('%{ReferenceValue}', ReferenceBuilder.ToText());



            HTMLBuilder.Replace('%{AlertText}', '');

            BodyBuilder.AppendLine(StrSubstNo('<h2>A shipment due for shipment on %1 is being on hold pending credit issue resolution.</h2>', WhseShip."Shipment Date"));

            If Overdue then
                BodyBuilder.AppendLine(StrSubstNo('<h4>There are invoices valued at %1 currently overdue. </h4>', Customer."Balance Due (LCY)"));
            If OverCreditLimit then
                BodyBuilder.AppendLine(StrSubstNo('<h4>Dispatch value of %1 will result in credit limit of %2 being exceeded by %3. </h4>', WhseShipCU.GetValueOfShipment(WhseShip), Customer."Credit Limit (LCY)", ABS((Customer."Balance (LCY)" + WhseShipCU.GetValueOfShipment(WhseShip)) - Customer."Credit Limit (LCY)")));

            If Overdue or OverCreditLimit then
                BodyBuilder.AppendLine(StrSubstNo('<p>Note. We provide a tolerance of %1 AUD so small amounts do not hold anything up. Please call or email to discuss so we can get these goods to you as fast as possible.</p>', WhseSetup."TFB Credit Tolerance"));

            BodyBuilder.AppendLine('<table class="tfbdata" width="80%" cellspacing="0" cellpadding="10" border="0">');
            BodyBuilder.AppendLine('<thead>');
            BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="20%">Order No</th>');
            BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="35%">Item Desc.</th>');
            BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="10%">Qty Ordered</th>');
            BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="10%">Weight</th>');
            BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="25%">Comments</th></thead>');

            repeat
                SuppressLine := false;
                Item.Get(WhseLines."Item No.");

                If Item.Type = Item.Type::Inventory then begin



                    UoM.Get(Item."Base Unit of Measure");
                    Clear(LineBuilder);
                    Clear(OrderLine);
                    Clear(CommentBuilder);

                    OrderLine.SetRange("Document Type", OrderLine."Document Type"::Order);
                    OrderLine.SetRange("Document No.", WhseLines."Source No.");
                    OrderLine.SetRange("Line No.", WhseLines."Source Line No.");

                    OrderLine.FindFirst();
                    //BodyBuilder.AppendLine('<tr>');
                    LineBuilder.AppendLine('<tr>');
                    LineBuilder.Append(StrSubstNo(tdTxt, OrderLine."Document No."));
                    LineBuilder.Append(StrSubstNo(tdTxt, WhseLines.Description));
                    LineBuilder.Append(StrSubstNo(tdTxt, WhseLines."Qty. to Ship (Base)"));
                    LineBuilder.Append(StrSubstNo(tdTxt, Format(Item."Net Weight" * WhseLines."Qty. to Ship (Base)") + 'kg'));

                    //Add details on expected arrival
                    ShippingAgent.Get(WhseShip."Shipping Agent Code");

                    CustCalendarChange[1].Description := 'Source';
                    CustCalendarChange[1]."Source Type" := CustCalendarChange[1]."Source Type"::"Shipping Agent";
                    CustCalendarChange[1]."Source Code" := ShippingAgent.Code;
                    CustCalendarChange[1]."Additional Source Code" := WhseShip."Shipping Agent Service Code";

                    CustCalendarChange[2].Description := 'Customer';
                    CustCalendarChange[2]."Source Type" := CustCalendarChange[2]."Source Type"::Customer;
                    CustCalendarChange[2]."Source Code" := WhseShip."TFB Destination No.";

                    ExpectedDate := CalMgmt.CalcDateBOC(format(OrderLine."Shipping Time"), WhseShip."Shipment Date", CustCalendarChange, true);

                    CommentBuilder.Append(StrSubstNo('Expected delivery on %1 using %2', ExpectedDate, ShippingAgent.Name));


                    LineBuilder.Append(StrSubstNo(tdTxt, CommentBuilder.ToText()));
                    LineBuilder.AppendLine('</tr>');

                    If not SuppressLine then begin
                        BodyBuilder.Append(LineBuilder.ToText());
                        LineCount := LineCount + 1;
                    end;
                end;
            until WhseLines.Next() < 1;

            BodyBuilder.AppendLine('</table>');


        end;

        If LineCount > 0 then begin
            HTMLBuilder.Replace('%{EmailContent}', BodyBuilder.ToText());
            Exit(true);
        end
        else
            Exit(false);

    end;


    /// <summary> 
    /// Send just a notification email related to a warehouse location
    /// </summary>
    /// <param name="WhseShipment">Parameter of type Record "Warehouse Shipment Header".</param>
    /// <param name="overdue">Parameter of type Boolean.</param>
    /// <param name="overcreditlimit">Parameter of type Boolean.</param>
    /// <returns>Return variable "Boolean".</returns>
    procedure SendOneNotificationEmail(WhseShipment: Record "Warehouse Shipment Header"; overdue: Boolean; overcreditlimit: Boolean): Boolean
    var
        CLib: CodeUnit "TFB Common Library";
        Window: Dialog;
        Result: Boolean;
        Text001Msg: Label 'Sending Order Credit Issue:\#1############################', comment = '%1=Warehouse Shipment No.';
        TitleTxt: Label 'Order Credit Issue Notification';
        SubTitleTxt: Label 'Further details of goods on hold are below. ';
    begin

        Window.Open(Text001Msg);
        Window.Update(1, STRSUBSTNO('%1 %2', WhseShipment."No.", ''));
        Result := SendNotificationEmail(WhseShipment, CLib.GetHTMLTemplateActive(TitleTxt, SubTitleTxt), overdue, overcreditlimit);
        Exit(Result);
    end;



    /// <summary> 
    /// Retrieve a HTML template
    /// </summary>
    /// <param name="TopicText">Parameter of type Text.</param>
    /// <param name="TitleText">Parameter of type Text.</param>
    /// <returns>Return variable "Text".</returns>


    protected procedure SendNotificationEmail(var WhseShipment: Record "Warehouse Shipment Header"; HTMLTemplate: Text; Overdue: Boolean; OverCreditLimit: Boolean): Boolean

    var
        CommEntry: Record "TFB Communication Entry";
        CompanyInfo: Record "Company Information";
        Customer: Record Customer;

        Email: CodeUnit Email;
        EmailMessage: CodeUnit "Email Message";
        EmailScenario: Enum "Email Scenario";
        EmailID: Text;

        Recipients: List of [Text];

        HTMLBuilder: TextBuilder;
        SubjectNameBuilder: TextBuilder;

    begin


        CompanyInfo.Get();


        If not Customer.Get(WhseShipment."TFB Destination No.") or (Customer."E-Mail" = '') then
            exit(false);


        EmailID := Customer."E-Mail";
        SubjectNameBuilder.Append(StrSubstNo('Warehouse shipment %1 is on hold pending credit resolution', WhseShipment."No."));


        Recipients.Add(EmailID);


        HTMLBuilder.Append(HTMLTemplate);

        If GenerateNotificationContent(WhseShipment, Customer, Overdue, OverCreditLimit, HTMLBuilder) then begin
            EmailMessage.Create(Recipients, SubjectNameBuilder.ToText(), HTMLBuilder.ToText(), true);

            Email.Enqueue(EmailMessage, EmailScenario::"Customer Statement");
            CommEntry.Init();
            CommEntry."Source Type" := CommEntry."Source Type"::Customer;
            CommEntry."Source ID" := Customer."No.";
            CommEntry."Source Name" := Customer.Name;
            CommEntry."Record Type" := commEntry."Record Type"::CIN;
            CommEntry."Record Table No." := Database::"Warehouse Shipment Header";
            CommEntry."Record No." := WhseShipment."No.";
            CommEntry.Direction := CommEntry.Direction::Outbound;
            CommEntry.MessageContent := CopyStr(HTMLBuilder.ToText(), 1, 2048);
            CommEntry.Method := CommEntry.Method::EMAIL;
            CommEntry.Insert();
        end;
    end;


}