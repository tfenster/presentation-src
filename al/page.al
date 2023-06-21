pageextension 50101 Pageusercontrol extends "Customer Card"
{
    layout
    {
        addafter(General)
        {
            usercontrol(MyLogoControl; MyLogoControl)
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        addafter("&Customer")
        {
            action("ConnectImage")
            {
                Caption = 'Connect image';
                ApplicationArea = All;
                trigger OnAction()
                begin
                    CurrPage.MyLogoControl.connectImage();
                end;
            }
        }
    }
}