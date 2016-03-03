import requests

"""
cmd == CD
function appendSource(obj, imgOn, imgOver, cmd) {
    obj.empty();

    $(obj).empty().append(createSwapInput(imgOn, imgOver).click(function() {
        putRequest({
            cmd0: "PutZone_InputFunction/" + cmd,
            cmd1: "aspMainZone_WebUpdateStatus/"
        }, true, true);
    }));
}


function putRequest(data, bReload, bFill) {
    var url = "";
    if (_bDebug) {
        url = "/proxy.php?url=" + encodeURI("MainZone/index.put.asp");
        //url = "/postVar.php";
    } else {
        url = "./index.put.asp";
    }
    $.post(url, data, function(data) {
        if (_bDebug) {
            //alert(data);
        }
        if (bReload) {
            loadMainXml(bFill);
            setTimeout( function() {
                loadMainXml( false );
            }, 2000 );
        }
    });
}

{
                cmd0: "PutZone_OnOff/OFF",
                cmd1: "aspMainZone_WebUpdateStatus/"
            }



var vol = 99 * x / w;
vol = vol / 100 * 110 - 87.5;
if (vol > 18.0) {
    vol = 18.0;
} else {
    vol = parseInt(vol);
}

if (vol < -80.5 ) {
    return "--";
}

if (vol * 2 % 2 == 0) {
    return vol + ".0";
}

"""

cmd = "CD"

data = {
    "cmd0": "PutZone_InputFunction/" + cmd,
    "cmd1": "aspMainZone_WebUpdateStatus/"
}

def sendcmd(data):
    url = "http://marantz-sr6007.local./MainZone/index.put.asp";
    r = requests.post(url, data=data)
    print r.status_code


def power(p):
    data = {
    "cmd0": "PutZone_OnOff/{}".format("ON" if p else "OFF"),
    "cmd1": "aspMainZone_WebUpdateStatus/"
    }
    sendcmd(data)

def select_input(code):
    data = {
    "cmd0": "PutZone_InputFunction/{}".format(code),
    "cmd1": "aspMainZone_WebUpdateStatus/"
    }
    sendcmd(data)

def volume(vol):
    volDB = vol / 100.0 * 110.0 - 87.5;
    if volDB > 18.0:
        volDB = 18.0;
    
    if volDB < -80.5 :
        volDB = "--";
    else:
        volDB = str(int(volDB)) + ".0"
    data = {
        "cmd0": "PutMasterVolumeSet/{}".format(volDB)
    }
    sendcmd(data)

power(True) 
select_input("CD")
volume(35)
