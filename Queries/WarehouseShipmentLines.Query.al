query 50601 "TFB Warehouse Shipment Lines"
{
    QueryType = API;
    APIPublisher = 'tfb';
    APIGroup = 'warehouse';
    APIVersion = 'v1.0';
    EntityName = 'warehouseShipmentLine';
    EntitySetName = 'warehouseShipmentLines';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(Warehouse_Shipment_Header; "Warehouse Shipment Header")
        {
            SqlJoinType = LeftOuterJoin;
            column(shipmentID; "No.")
            {
                Caption = 'ShipmentID', Locked = true;
            }
            column(reqShipmentDate; "Shipment Date")
            {
                Caption = 'RequestedShipmentDate', Locked = true;

            }
            column(locationCode; "Location Code")
            {
                Caption = 'Location', Locked = true;
            }
            column(status; Status)
            {
                Caption = 'Status', Locked = true;
            }



            dataitem(Warehouse_Shipment_Line; "Warehouse Shipment Line")
            {
                DataItemLink = "No." = Warehouse_Shipment_header."No.";
                SqlJoinType = LeftOuterJoin;


                column(qtyBase; "Qty. to Ship (Base)")
                {
                    Caption = 'QtyBase', Locked = true;

                }

                dataitem(Sales_Header; "Sales Header")
                {
                    DataItemLink = "No." = Warehouse_Shipment_Line."Source No.";

                    SqlJoinType = LeftOuterJoin;
                    column(customerNo; "Sell-to Customer No.")
                    {
                        Caption = 'CustomerNo', Locked = true;
                    }
                    column(customerName; "Sell-to Customer Name")
                    {
                        Caption = 'CustomerName', Locked = true;
                    }
                    column(documentType; "Document Type")
                    {
                        Caption = 'DocumentType', Locked = true;
                    }
                    column(custPORef; "External Document No.")
                    {
                        Caption = 'CustPORef', Locked = true;
                    }
                    column(instructions; "TFB Instructions")
                    {
                        Caption = 'Instructions', Locked = true;
                    }
                    column(shipToCode; "Ship-to Code")
                    {
                        Caption = 'ShipToCode', Locked = true;
                    }
                    Column(shipToContact; "Ship-to Contact")
                    {
                        Caption = 'ShipToContact', Locked = true;
                    }
                    column(shipToStreet; "Ship-to Address")
                    {
                        Caption = 'Street', Locked = true;
                    }
                    column(shipToCity; "Ship-to City")
                    {
                        Caption = 'City', Locked = true;
                    }
                    column(shipToPostCode; "Ship-to Post Code")
                    {
                        Caption = 'PostCode', Locked = true;
                    }
                    column(shipToState; "Ship-to County")
                    {
                        Caption = 'State', Locked = true;
                    }

                    dataitem(Sales_Line; "Sales Line")
                    {
                        DataItemLink = "Document No." = Sales_Header."No.", "Document Type" = Sales_Header."Document Type", "Line No." = Warehouse_Shipment_Line."Source Line No.";
                        SqlJoinType = LeftOuterJoin;
                        column(salesOrderNo; "Document No.")
                        {
                            Caption = 'SalesOrderNo', Locked = true;
                        }
                        column(itemNo; "No.")
                        {
                            Caption = 'ItemNo', Locked = true;
                        }
                        column(itemName; Description)
                        {
                            Caption = 'ItemName', Locked = true;
                        }
                        column(shippingAgent; "Shipping Agent Code")
                        {
                            Caption = 'ShippingAgent', Locked = true;
                        }
                        column(shippingServiceCode; "Shipping Agent Service Code")
                        {
                            Caption = 'ShippingServiceCode', Locked = true;
                        }
                        column(itemWeight; "Net Weight")
                        {
                            Caption = 'ItemWeightKg', Locked = true;
                        }
                        column(QtyPerUnitOfMeasure; "Qty. per Unit of Measure")
                        {
                            Caption = 'QtyPerUoM', Locked = true;
                        }

                        dataitem(Reservation_Entry; "Reservation Entry")
                        {
                            DataItemLink = "Source ID" = Sales_Line."Document No.", "Source Ref. No." = Sales_Line."Line No.", "Item No." = Sales_Line."No.";
                            //DataItemTableFilter = "Item Tracking" = const(None), "Source Type" = const(37);
                            SqlJoinType = LeftOuterJoin;
                            Column(lotNo; "Lot No.")
                            {
                                Caption = 'LotNo', Locked = true;

                            }
                            Column(lotQuantity; "Quantity (Base)")
                            {
                                Caption = 'LotQtyBase', Locked = true;
                                Method = Sum;

                                ReverseSign = true;
                            }

                            dataitem(Item; Item)
                            {
                                DataItemLink = "No." = Reservation_Entry."Item No.";

                                column(baseUoM; "Base Unit of Measure")
                                {
                                    Caption = 'BaseUoM', Locked = true;
                                }
                            }


                        }



                    }


                }



            }
        }

    }



    var


    trigger OnBeforeOpen()
    begin

        // SetRange(sourceType, 37);
        //SetRange(itemTracking, itemTracking::None);
        //SetRange(documentType, documentType::Order);

    end;
}