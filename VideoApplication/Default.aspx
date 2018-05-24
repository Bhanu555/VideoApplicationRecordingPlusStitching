<%@ Page Title="Home Page" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="VideoApplication._Default" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <style type="text/css" media="screen">
        html, body {
            height: 95%;
        }

        body {
            margin: 0;
            padding: 0;
            overflow: auto;
            text-align: left;
            background-color: Gray;
        }

        object:focus {
            outline: none;
        }

        #flashContent {
            display: none;
        }


        /*#video {
            position: relative;
            top: 17px;
            left: 71px;
            color: #99FF33;
        }*/

        #text {
            position: relative;
            z-index: 2147483647;
            top: 31px;
            left: 0px;
        }

        #picture-in-picture {
            position: relative;
            /*width:600px;
            height: 750px;
                top: 14px;
                left: 0px;*/
        }

        #remote-media {
            height: 200px;
            width: 75%;
            border: 5px hidden solid blue;
            position: absolute;
        }

            #remote-media video {
                width: 120%;
            }

        #local-media {
            height: 200px;
            width: 75%;
            float: left;
            top: 175px;
            left:280px;
            border: 5px hidden solid orange;
            position: absolute;
        }

        .auto-style1 {
            color: #00FF00;
            width: 40px;
        }

        .overlay {
            position: absolute;
            top: 11%;
            left: 19%;
            width: 200%;
            height: 151%;
            z-index: 10;
            background-color: rgba(0,0,0,0.5); /*dim the background*/
        }

        .auto-style2 {
            color: #99FF33;
            width: 703px;
        }
      
    </style>
    <p class="auto-style1">
        <strong>Hola!!! </strong>       
    </p>
     <asp:Button ID="RecordButton" Text="Click here for recording of specified Room" OnClick="RecordingBtnn_Click" class="myButton" runat="server" />
     <br />
    <h1 class="auto-style2">Welcome To Twilio Programmable Video</h1>  
    <div id="picture-in-picture">
        <div id="remote-media">
            <strong></strong>
        </div>
        <div id="controls">
            <div id="preview">
                <div id ="'mydiv">
                <div id="local-media"></div></div>
                <br />
            </div>
            <div id="room-controls">
                <button type="button" id="button-leave" style="display: none;"></button>
            </div>
            <div id="log"></div>

        </div>
    </div>
    <div id="text">
    </div>
    <script src="//media.twiliocdn.com/sdk/js/video/v1/twilio-video.min.js"></script>
    <script type="text/javascript">      
        var activeRoom;
        var previewTracks;

        var identity = 'Bhanu';
        var roomName;
        var connectOptions = {
            name: 'Alice',
            logLevel: 'debug',
            audio: true,
            video: {
                width: 240,
                height: 150,

            },
        };

        if (previewTracks) {
            connectOptions.tracks = previewTracks;
        }

        // Join the Room with the token from the server and the
        // LocalParticipant's Tracks.
        Twilio.Video.connect('<%:VideoApplication.Utility1.TokenGenerator.AccessTokenGenerator() %>', connectOptions)
            .then(roomJoined, function (error) {
                console.error('Unable to connect to Room: ' + error.message);
            });

        // Bind button to leave Room.
        document.getElementById('button-leave').onclick = function (event) {
            event.preventDefault()
            console.log('Leaving room...');
            activeRoom.disconnect();
<%--             __doPostBack("<%= RecordButton.UniqueID %>", "OnClick");--%>
<%--         document.getElementById('<%= RecordButton.ClientID %>').click();--%>

        };

        function attachTracks(tracks, container) {
            tracks.forEach(function (track) {
                container.appendChild(track.attach());
            });
        }

        // Attach the Participant's Tracks to the DOM.
        function attachParticipantTracks(participant, container) {
            var tracks = Array.from(participant.tracks.values());
            attachTracks(tracks, container);
        };

        // Detach the Tracks from the DOM.
        function detachTracks(tracks) {
            tracks.forEach(function (track) {
                track.detach().forEach(function (detachedElement) {
                    detachedElement.remove();
                });
            });
        };

        // Detach the Participant's Tracks from the DOM.
        function detachParticipantTracks(participant) {
            var tracks = Array.from(participant.tracks.values());
            detachTracks(tracks);
        };

        function roomJoined(room) {
            window.room = activeRoom = room;

            /* 
 
            log("Joined as '" + identity + "'"); */
            document.getElementById('button-leave').style.display = 'none';

            // Attach LocalParticipant's Tracks, if not already attached.
            var previewContainer = document.getElementById('local-media');
            if (!previewContainer.querySelector('video')) {
                attachParticipantTracks(room.localParticipant, previewContainer);
            }

            // Attach the Tracks of the Room's Participants.
            room.participants.forEach(function (participant) {
                console.log("Already in Room: '" + participant.identity + "'");
                var previewContainer = document.getElementById('remote-media');
                attachParticipantTracks(participant, previewContainer);
            });

            // When a Participant joins the Room, log the event.
            room.on('participantConnected', function (participant) {
                console.log("Joining: '" + participant.identity + "'");
            });

            // When a Participant adds a Track, attach it to the DOM.
            room.on('trackAdded', function (track, participant) {
                console.log(participant.identity + " added track: " + track.kind);
                var previewContainer = document.getElementById('remote-media');
                attachTracks([track], previewContainer);
            });

            // When a Participant removes a Track, detach it from the DOM.
            room.on('trackRemoved', function (track, participant) {
                console.log(participant.identity + " removed track: " + track.kind);
                detachTracks([track]);
            });

            // When a Participant leaves the Room, detach its Tracks.
            room.on('participantDisconnected', function (participant) {
                console.log("Participant '" + participant.identity + "' left the room");
                detachParticipantTracks(participant);
            });

            // Once the LocalParticipant leaves the room, detach the Tracks
            // of all Participants, including that of the LocalParticipant.
            room.on('disconnected', function () {
                console.log('Left');
                if (previewTracks) {
                    previewTracks.forEach(function (track) {
                        track.stop();
                    });
                }
                detachParticipantTracks(room.localParticipant);
                room.participants.forEach(detachParticipantTracks);
                activeRoom = null;
                document.getElementById('button-leave').style.display = 'none';
            });
        }
        

var Draggable = function (id) {
    var el = document.getElementById(id),
        isDragReady = false,
        dragoffset = {
            x: 0,
            y: 0
        };
    this.init = function () {
        //only for this demo
        this.initPosition();
        this.events();
    };
    //only for this demo
    this.initPosition = function () {
        el.style.position = "absolute";
        el.style.top = "0";
        el.style.left = "0";
    };
    //events for the element
    this.events = function () {
        var self = this;
        _on(el, 'mousedown', function (e) {
            isDragReady = true;
            //corssbrowser mouse pointer values
            e.pageX = e.pageX || e.clientX + (document.documentElement.scrollLeft ? document.documentElement.scrollLeft : document.body.scrollLeft);
            e.pageY = e.pageY || e.clientY + (document.documentElement.scrollTop ? document.documentElement.scrollTop : document.body.scrollTop);
            dragoffset.x = e.pageX - el.offsetLeft;
            dragoffset.y = e.pageY - el.offsetTop;
        });
        _on(document, 'mouseup', function () {
            isDragReady = false;
        });
        _on(document, 'mousemove', function (e) {
            if (isDragReady) {
                e.pageX = e.pageX || e.clientX + (document.documentElement.scrollLeft ? document.documentElement.scrollLeft : document.body.scrollLeft);
                e.pageY = e.pageY || e.clientY + (document.documentElement.scrollTop ? document.documentElement.scrollTop : document.body.scrollTop);
                // left/right constraint
                if (e.pageX - dragoffset.x < 0) {
                    offsetX = 0;
                } else if (e.pageX - dragoffset.x + 102 > document.body.clientWidth) {
                    offsetX = document.body.clientWidth - 102;
                } else {
                    offsetX = e.pageX - dragoffset.x;
                }
                 
                // top/bottom constraint   
                if (e.pageY - dragoffset.y < 0) {
                    offsetY = 0;
                } else if (e.pageY - dragoffset.y + 102 > document.body.clientHeight) {
                    offsetY = document.body.clientHeight - 102;
                } else {
                    offsetY = e.pageY - dragoffset.y;
                }   

                el.style.top = offsetY + "px";
                el.style.left = offsetX + "px";
            }
        });
    };
    //cross browser event Helper function
    var _on = function (el, event, fn) {
        document.attachEvent ? el.attachEvent('on' + event, fn) : el.addEventListener(event, fn, !0);
    };
    this.init();
}

new Draggable('local-media');
</script> 
</asp:Content>
