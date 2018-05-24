using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Twilio;
using Twilio.Rest.Video.V1;
using Twilio.Rest.Video.V1.Room;
using System.IO;
using System.Net;
using System.Text;
using Newtonsoft.Json;
using System.Web.Services;

namespace VideoApplication
{
    public partial class TwilioVideo : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {


        }
        protected void RecordingBtn_Click(object sender, EventArgs e)
        {
            //StartRecording();
            // Find your Account SID and Auth Token at twilio.com/console
            const string apiKeySid = "SK0678c0ad0045e85ac68f91d3eca7c87c";
            const string apiKeySecret = "6AQNum22c9t20kZsbGXffSZQDpEyjyWs";
            // const string roomUniqueName = "Anu";
            TwilioClient.Init(apiKeySid, apiKeySecret);
            var rooms = RoomResource.Read(
           status: RoomResource.RoomStatusEnum.Completed,
           //uniqueName: "05212018014523086");
           uniqueName: "05212018045230018");
            foreach (var room in rooms)
            {
                Console.WriteLine(room.Sid);
                string roomSid = room.Sid;
                //Console.WriteLine(room.Sid);

                //const string roomSid = "RM9236a49ad89bde01060d416c418b1157";

                TwilioClient.Init(apiKeySid, apiKeySecret);

                var recordings = RecordingResource.Read(
                    groupingSid: new List<string>() { roomSid });

                foreach (var recording in recordings)
                {
                    Console.WriteLine(recording.Sid);
                    string recordingSid = recording.Sid;
                    var RetrieveRecording = RoomRecordingResource.Fetch(roomSid, recordingSid);
                    Console.WriteLine(RetrieveRecording.Type);
                    string uri = "https://video.twilio.com/v1/" +
                        $"Rooms/{roomSid}/" +
                        $"Recordings/{recordingSid}/" +
                        "Media/";

                    var request = (HttpWebRequest)WebRequest.Create(uri);
                    request.Headers.Add("Authorization", "Basic " + Convert.ToBase64String(Encoding.ASCII.GetBytes(apiKeySid + ":" + apiKeySecret)));
                    request.AllowAutoRedirect = false;
                    string responseBody = new StreamReader(request.GetResponse().GetResponseStream()).ReadToEnd();
                    var mediaLocation = JsonConvert.DeserializeObject<Dictionary<string, string>>(responseBody)["redirect_to"];

                    Console.WriteLine(mediaLocation);
                    new WebClient().DownloadFile(mediaLocation, @"C:\Users\bhanushree.rajanna\Desktop\TestR\" + recording.TrackName + RetrieveRecording.Type + "AudioVideo.mp4");
                }
            }
        }
    }
}
