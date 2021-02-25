tableextension 50602 "TFB Warehouse Setup" extends "Warehouse Setup"
{
    fields
    {
        field(50600; "TFB Require Stock Availability"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Require Stock Availability';
            Access = Public;
            Editable = true;
        }

        field(50610; "TFB Credit Tolerance"; Decimal)

        {
            DataClassification = CustomerContent;
            Caption = 'Credit Tolerance';
            Access = Public;
            Editable = true;
            MinValue = 0;
            MaxValue = 10000;
        }
    }


}