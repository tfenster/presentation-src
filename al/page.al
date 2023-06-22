pageextension 50150 CustomerCheck extends "Customer Card"
{
    actions
    {
        addafter("&Customer")
        {
            action("Register customer")
            {
                Caption = 'Register customer';
                ApplicationArea = All;
                trigger OnAction()
                var
                    Client: HttpClient;
                    Response: HttpResponseMessage;
                    Content: HttpContent;
                begin
                    Content.WriteFrom('registered');
                    Client.Post('https://bctechdays-store-c8vxeq2k.fermyon.app/' + Rec."No.", Content, Response);
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
    begin
        Client.Get('https://bctechdays-store-c8vxeq2k.fermyon.app/' + Rec."No.", Response);
        if (Response.HttpStatusCode <> 200) then
            Message('The customer is not registered')
    end;

}