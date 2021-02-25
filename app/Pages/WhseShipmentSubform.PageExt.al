pageextension 50608 "TFB Whse. Shipment Subform" extends "Whse. Shipment Subform"
{
    layout
    {

        addafter("Qty. (Base)")
        {


            field(TrackingEmoji; TrackingEmojiVar)
            {
                Caption = 'Line. Status';
                ToolTip = 'Specifies if status of item tracking for the warehouse shipment line';
                ApplicationArea = All;
                Width = 5;
                Editable = false;
                Visible = true;

                trigger OnDrillDown()

                var

                begin
                    Rec.OpenItemTrackingLines();
                end;
            }
        }

        addafter("Destination No.")
        {
            field("TFB Destination Name"; Rec."TFB Destination Name")
            {
                ApplicationArea = All;
                Visible = True;
                ToolTip = 'Specifies the destination name';
            }
            field("Shipping Advice"; Rec."Shipping Advice")
            {
                ApplicationArea = All;
                Visible = True;
                ToolTip = 'Specifies the shipping advice';
            }
        }


    }

    trigger OnAfterGetRecord()

    begin
        TrackingOkay := WhsCU.CheckLineItemTrackingOkay(Rec, Rec."Qty. to Ship (Base)");
        If TrackingOkay then
            TrackingEmojiVar := '✅'
        else
            TrackingEmojiVar := '⚠️';
    end;

    trigger OnModifyRecord(): Boolean

    begin
        TrackingOkay := WhsCU.CheckLineItemTrackingOkay(Rec, Rec."Qty. to Ship (Base)");
        If TrackingOkay then
            TrackingEmojiVar := '✅'
        else
            TrackingEmojiVar := '⚠️';
    end;


    var
        WhsCU: CodeUnit "TFB Whs. Ship. Mgmt";
        TrackingOkay: Boolean;
        TrackingEmojiVar: Text;



}