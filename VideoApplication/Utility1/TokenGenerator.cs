using System;
using Twilio;
using System.Collections.Generic;
using Twilio.Jwt.AccessToken;
using Twilio.Rest.Video.V1;
using System.Linq;



namespace VideoApplication.Utility1
{
    public static class TokenGenerator
    {
        public static string AccessTokenGenerator()
        {
            // Substitute your Twilio AccountSid and ApiKey details
            var AccountSid = "AC8afec90bbe166f208ecf04fb48717251";
            var ApiKeySid = "SKd8aac04eba0fa8ed056c6263990fa85c";
            var ApiKeySecret = "uUiLZ8XytHGuo15BPnU4EuZ5kdywBDWO";

            TwilioClient.Init(ApiKeySid, ApiKeySecret);           

            //Console.WriteLine(room.Sid);
            var identity = "bhan";

            // Create a video grant for the token
            var grant = new VideoGrant();
            string letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ123456789";
            Random rndm = new Random();
            string ServerVariable = new string(Enumerable.Repeat(letters, 10).Select(s => s[rndm.Next(s.Length)]).ToArray());
        
            grant.Room ="Alice";
            var grants = new HashSet<IGrant> { grant };

            // Create an Access Token generator
            var token = new Token(AccountSid, ApiKeySid, ApiKeySecret, identity: identity, grants: grants);

            // Serialize the token as a JWT
            String Jwttoken = token.ToJwt();
            Console.WriteLine(token.ToJwt());
            return Jwttoken;       

           
        }

    }
    
}