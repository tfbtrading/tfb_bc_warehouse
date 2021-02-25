pageextension 50601 "TFB Customer Details Factbox" extends "Customer Details FactBox"
{


    layout
    {
        addafter("Credit Limit (LCY)")
        {
            field("Balance (LCY)"; Rec."Balance (LCY)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies balance outstanding';
            }
            field("Balance Due (LCY)"; Rec."Balance Due (LCY)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies overdue balance oustanding';
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    trigger OnOpenPage()

    begin

        Rec.SetRange("Date Filter", 0D, today());
    end;
}