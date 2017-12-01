
import ballerina.net.http;
import ballerina.data.sql;
import ballerina.lang.messages;
import ballerina.utils.logger;
import ballerina.lang.jsons;
import ballerina.lang.datatables;
import ballerina.lang.system;
import org.wso2.ballerina.connectors.gmail;


@http:config { basePath: "/news"}
service<http> NewsService {
 
    @http:GET {}
    resource receive (message m) {
 
        map propertiesMap = {"jdbcUrl": "jdbc:mysql://localhost:3306/newsdb","username": "root","password": "root","maximumPoolSize": 1};
 
        sql:ClientConnector newsDB = create sql:ClientConnector      (propertiesMap);
        message response = {};
        string query = "SELECT * FROM news";
        sql:Parameter[] parameters = [];
        datatable dt = sql:ClientConnector.select(newsDB, query, parameters);
 
        var jsonRes,error = <json>dt;
 
        string s = jsons:toString(jsonRes);
        logger:info(s);
        messages:setJsonPayload(response,jsonRes);
        datatables:close(dt);

        reply response;
    }

    @http:POST {}
    resource send (message m) {
        map propertiesMap = {"jdbcUrl": "jdbc:mysql://localhost:3306/newsdb","username": "root","password": "root","maximumPoolSize": 1};
        sql:Parameter[] parameters = [];

        sql:ClientConnector newsDB = create sql:ClientConnector(propertiesMap);

        message response = {};
        int i = 0;
        json jsonPayload = messages:getJsonPayload(m);
        int arrayLength = jsons:getInt(jsonPayload,"$.length()");
        string emailMessageBody = "";

        while (i < arrayLength) {
            json e = jsonPayload[i];
            system:println("Each news: ");
            system:println(e);
            
            string title = jsons:getString(e,"$.title");
            string abstract = jsons:getString(e,"$.abstract");
            string provider = jsons:getString(e,"$.provider");
            string link = jsons:getString(e,"$.link");
            int numPages = jsons:getInt(e,"$.numPages");
            string date = jsons:getString(e,"$.date");

            string query = "INSERT INTO news (title, abstract, provider, link, numPages, date) VALUES ('" + title + "','" + abstract + "','" + provider + "','" + link + "'," + numPages + ",'" + date + "');";
                        system:println(query);

            int success = sql:ClientConnector.update(newsDB, query, parameters);
            
            emailMessageBody = emailMessageBody + title + ": " + link + "\n\n";
            system:println(success);
            
            i = i + 1;
            
        }
        
        string query = "SELECT fname, lname, email FROM subscriber";
        datatable dt = sql:ClientConnector.select(newsDB, query, parameters);
        var jsonRes,error = <json>dt;
        
        arrayLength = jsons:getInt(jsonRes,"$.length()");
        i = 0;
        system:println(jsons:toString(jsonRes));

        while (i < arrayLength) {
            json e = jsonRes[i];
            system:println("Each subscriber: ");
            system:println(e);
            
            string fname = jsons:getString(e, "$.fname");
            string lname = jsons:getString(e, "$.lname");
            string subscriberEmail = jsons:getString(e, "$.email");
            
            string personalizedBody = "Hi " + fname + ",\n\n" + "Here are the latest news,\n" + emailMessageBody + "Thanks.";
            sendNewsMails (subscriberEmail, personalizedBody);
            i = i + 1;
        }
        
        jsonRes = "{\"result\":\"success\"}";
        messages:setJsonPayload(response, jsonRes);

        reply response;
    }
}


string accessToken="ya29.-BXKTEr0J1e6MRPkJQFlKNFNB6PUV";
string refreshToken = "1/-uFpIX0Q";

string userId = "lahirugmg@gmail.com";
function init () (gmail:ClientConnector gmailConnector) {
    gmailConnector = create gmail:ClientConnector(userId,accessToken,refreshToken,"","");
    return;
}

function sendNewsMails (string to, string messageBody) (message) {
    // string to = recipientAddress;
    string subject = "Latest news";
    string from = userId;
    // string messageBody = "Test message 1";
    string cc = userId;
    string bcc = userId;
    string id = "154b8c77e551c511";
    string threadId = "154b8c77e551c512";
    gmail:ClientConnector connectorInstance = init();
    message gmailResponse = gmail:ClientConnector.sendMail (connectorInstance, to, subject, from, messageBody
                                                            , cc, bcc, id, threadId);
    //json gmailJSONResponse = messages:getJsonPayload(gmailResponse);
    return gmailResponse;
}
