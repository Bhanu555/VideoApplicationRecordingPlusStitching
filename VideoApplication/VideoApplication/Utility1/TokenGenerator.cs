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
            var AccountSid = "ACfaeaf5681a4b27e04896c8d57b7a829b";
            var ApiKeySid = "SK26a5ad58fe67cd4192caf9d49c11e160";
            var ApiKeySecret = "3ROMylcwSwpUCn0ROstqRgSWmGr4alvk";
           
            TwilioClient.Init(ApiKeySid, ApiKeySecret);           

            //Console.WriteLine(room.Sid);
            var identity = "bhan";

            // Create a video grant for the token
            var grant = new VideoGrant();
            string letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ123456789";
            Random rndm = new Random();
            string ServerVariable = new string(Enumerable.Repeat(letters, 10).Select(s => s[rndm.Next(s.Length)]).ToArray());
        
            grant.Room = "Anu";
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