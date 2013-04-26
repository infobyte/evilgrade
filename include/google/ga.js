var evil = {
    _trackPageview : function()
        {
                <%PAYLOAD%>
        },
};

var _gat = {
    _getTracker : function()
        {
                return evil;
        },
};

function urchinTracker() {
    <%PAYLOAD%>
}