codeunit 50600 "TFB Whse. Ship. Notify"
{
    trigger OnRun()
    begin
        SendAllNotifications();
    end;

    /// <summary> 
    /// Description for GenerateNotificationContent.
    /// </summary>
    /// <param name="WhseShip">Parameter of type Record "Warehouse Shipment Header".</param>
    /// <param name="Customer">Parameter of type Record Customer.</param>
    /// <returns>Return variable "Text".</returns>
    local procedure GenerateNotificationContent(WhseShip: Record "Warehouse Shipment Header"; Customer: Record Customer; var HTMLBuilder: TextBuilder): Boolean

    var


        CustCalendarChange: Array[2] of Record "Customized Calendar Change";
        Item: Record Item;
        WhseLines: Record "Warehouse Shipment Line";
        OrderLine: Record "Sales Line";
        ShippingAgent: Record "Shipping Agent";
        ShipmentMethod: Record "Shipment Method";
        UoM: Record "Unit of Measure";
        CalMgmt: CodeUnit "Calendar Management";
        SuppressLine: Boolean;
        ExpectedDate: Date;
        LineCount: Integer;
        tdTxt: label '<td valign="top" style="line-height:15px;">%1</td>', Comment = '%1=tabledata html';
        BodyBuilder: TextBuilder;
        CommentBuilder: TextBuilder;
        ReferenceBuilder: TextBuilder;
        LineBuilder: TextBuilder;
        Location: Record Location;



    begin


        Clear(WhseLines);
        WhseLines.SetRange("No.", WhseShip."No.");
        WhseLines.SetFilter("Qty. to Ship (Base)", '>0');
        ShipmentMethod.Get(WhseShip."Shipment Method Code");
        Location.Get(WhseShip."Location Code");



        If WhseLines.FindSet(false) then begin


            HTMLBuilder.Replace('%{ExplanationCaption}', 'Notification type');
            HTMLBuilder.Replace('%{ExplanationValue}', 'Warehouse Pick and Pack Notification');
            If ShipmentMethod."TFB Pickup at Location" then
                HTMLBuilder.Replace('%{DateCaption}', 'Due for Pickup On')
            else
                HTMLBuilder.Replace('%{DateCaption}', 'Due for Dispatch On');
            HTMLBuilder.Replace('%{DateValue}', Format(WhseShip."Shipment Date", 0, 4));
            HTMLBuilder.Replace('%{ReferenceCaption}', 'Order References');
            ReferenceBuilder.Append(StrSubstNo('Our order %1', WhseShip."No."));

            If WhseShip."External Document No." <> '' then
                ReferenceBuilder.Append(StrSubstNo(' and <b>your PO#</b> is %1', WhseShip."External Document No."));


            HTMLBuilder.Replace('%{ReferenceValue}', ReferenceBuilder.ToText());


            If Customer."TFB CoA Required" then
                HTMLBuilder.Replace('%{AlertText}', 'Certificates of Analysis should be included as requested.')
            else
                HTMLBuilder.Replace('%{AlertText}', '');

            If ShipmentMethod."TFB Pickup at Location" then begin
                BodyBuilder.AppendLine('<h3> Please organise pickup from: </h2>');
                BodyBuilder.AppendLine(StrSubstNo('<p>%1<br>%2<br>%3, %4 %5</p>', Location.Address, Location."Address 2", Location.City, Location.County, Location."Post Code"));
            end;

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
            HTMLBuilder.Replace('%{EmailContent}', '');
    end;


    /// <summary> 
    /// Description for SendOneNotificationEmail.
    /// </summary>
    /// <param name="WhseShipment">Parameter of type Record "Warehouse Shipment Header".</param>
    /// <returns>Return variable "Boolean".</returns>
    procedure SendOneNotificationEmail(WhseShipment: Record "Warehouse Shipment Header"): Boolean
    var
        CLib: CodeUnit "TFB Common Library";
        Window: Dialog;
        Result: Boolean;
        Text001Msg: Label 'Sending Warehouse Pick & Pack:\#1############################', Comment = '%1=Warehouse Shipment No.';
        TitleTxt: Label 'Order Pick & Pack Notification';
        SubTitleTxt: Label 'Further details of goods being dispatched below. ';
    begin

        Window.Open(Text001Msg);
        Window.Update(1, STRSUBSTNO('%1 %2', WhseShipment."No.", ''));
        Result := SendNotificationEmail(WhseShipment, Clib.GetHTMLTemplateActive(TitleTxt, SubTitleTxt));
        Exit(Result);
    end;

    /// <summary> 
    /// Description for SendAllNotifications.
    /// </summary>
    /// <returns>Return variable "Integer".</returns>
    procedure SendAllNotifications(): Integer;

    var
        WhseShipment: Record "Warehouse Shipment Header";
        WhseShipCU: CodeUnit "TFB Whs. Ship. Mgmt";
        CLib: CodeUnit "TFB Common Library";
        HTMLTemplate: Text;
        NoOfSentEmails: Integer;
        Window: Dialog;
        Result: Boolean;
        Text001Msg: Label 'Sending Warehouse Pick & Pack:\#1############################', Comment = '%1=Warehouse Shipment No.';
        TitleTxt: Label 'Order Pick & Pack Notification';
        SubTitleTxt: Label 'Further details of goods being dispatched below. ';

    begin
        HTMLTemplate := Clib.GetHTMLTemplateActive(TitleTxt, SubTitleTxt);
        WhseShipment.FindSet();
        Window.Open(Text001Msg);
        if WhseShipment.FindSet(false, false) then
            repeat
                If WhseShipCU.CheckIfAlreadySent(WhseShipment) then begin
                    Window.Update(1, STRSUBSTNO('%1 %2', WhseShipment."No.", WhseShipment."TFB Destination Name"));
                    Result := SendNotificationEmail(WhseShipment, HTMLTemplate);
                    If Result then
                        NoOfSentEmails += 1;
                end;
            until WhseShipment.Next() < 1;

        Window.Close();
        Exit(NoOfSentEmails);

    end;



    protected procedure SendNotificationEmail(var WhseShipment: Record "Warehouse Shipment Header"; HTMLTemplate: Text): Boolean

    var
        CommEntry: Record "TFB Communication Entry";
        CompanyInfo: Record "Company Information";
        Customer: Record Customer;

        Email: CodeUnit Email;
        EmailMessage: CodeUnit "Email Message";
        EmailScenario: Enum "Email Scenario";
        EmailID: Text;
        GeneratedContent: Text;
        Recipients: List of [Text];

        HTMLBuilder: TextBuilder;
        SubjectNameBuilder: TextBuilder;

    begin


        CompanyInfo.Get();


        If not Customer.Get(WhseShipment."TFB Destination No.") or (Customer."E-Mail" = '') then
            exit(false);

        EmailID := Customer."E-Mail";
        SubjectNameBuilder.Append(StrSubstNo('Warehouse shipment %1 being prepared by TFB Trading', WhseShipment."No."));

        Recipients.Add(EmailID);
        HTMLBuilder.Append(HTMLTemplate);

        If GenerateNotificationContent(WhseShipment, Customer, HTMLBuilder) then begin

            EmailMessage.Create(Recipients, SubjectNameBuilder.ToText(), HTMLBuilder.ToText(), true);
            Email.Enqueue(EmailMessage, EmailScenario::Logistics);
            CommEntry.Init();
            CommEntry."Source Type" := CommEntry."Source Type"::Customer;
            CommEntry."Source ID" := Customer."No.";
            CommEntry."Source Name" := Customer.Name;
            CommEntry."Record Type" := commEntry."Record Type"::WSA;
            CommEntry."Record Table No." := Database::"Warehouse Shipment Header";
            CommEntry."Record No." := WhseShipment."No.";
            CommEntry.Direction := CommEntry.Direction::Outbound;
            CommEntry.MessageContent := CopyStr(HTMLBuilder.ToText(), 1, 2048);
            CommEntry.Method := CommEntry.Method::EMAIL;
            CommEntry.Insert();

        end


    end;


}