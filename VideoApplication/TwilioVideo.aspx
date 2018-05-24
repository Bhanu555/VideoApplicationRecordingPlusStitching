<%@ Page Language="C#" AutoEventWireup="true" MasterPageFile="~/Site.Master" CodeBehind="TwilioVideo.aspx.cs" Inherits="VideoApplication.TwilioVideo" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <div id="remote-media"></div>
    <div id="controls">
        <div id="preview">
            <p class="instructions">Hello Beautiful</p>
            <div id="local-media"></div>
            <button id="button-preview">Preview My Camera</button>
            <br />
        </div>
        <div id="room-controls">
            <button id="button-join">Join Room</button>
            <br />
            <br />
            <button id="button-leave">Leave Room</button>
        </div>
        <div id="log"></div>
    </div>
    <br />
    <div>
        <asp:Button id="RecordButton" Text="Click here for Recording..." OnClick="RecordingBtn_Click"   runat="server"/>       
    </div>
    <script type="text/javascript">
        var activeRoom;
        var previewTracks;
        var identity;
        var roomName;
       document.getElementById('button-join').onclick = function(event) {
            event.preventDefault()
            //console.log("Joining room '" + roomName + "'...");
            var connectOptions = {
                name: 'Alice',
                logLevel: 'debug'
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
            
        };     
     
        // Bind button to leave Room.
        document.getElementById('button-leave').onclick = function (event) {
            event.preventDefault()
            console.log('Leaving room...');
            activeRoom.disconnect();
<%--             __doPostBack("<%= RecordButton.UniqueID %>", "OnClick");--%>
         document.getElementById('<%= RecordButton.ClientID %>').click();
            
        };
        document.getElementById('button-preview').onclick = function (event) {
            event.preventDefault();
            var localTracksPromise = previewTracks
                ? Promise.resolve(previewTracks)
                : Twilio.Video.createLocalTracks();

            localTracksPromise.then(function (tracks) {
                window.previewTracks = previewTracks = tracks;
                var previewContainer = document.getElementById('local-media');
                if (!previewContainer.querySelector('video')) {
                    attachTracks(tracks, previewContainer);
                }
            }, function (error) {
                //console.error('Unable to access local media', error);
                console.log('Unable to access Camera and Microphone');
            });
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
            document.getElementById('button-join').style.display = 'none';
            document.getElementById('button-leave').style.display = 'inline';

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
                document.getElementById('button-join').style.display = 'inline';
                document.getElementById('button-leave').style.display = 'none';
            });

           <%--debugger;

          --%>
        }
       
    </script>
</asp:Content>
