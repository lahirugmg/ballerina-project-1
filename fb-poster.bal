import org.wso2.ballerina.connectors.facebook;
import ballerina.lang.messages;
import ballerina.lang.system;
import ballerina.net.http;
import ballerina.lang.jsons;

message response;
json facebookJSONResponse;
string postID;

string accessToken = "asdf";
string pageId = "3534453445345";

function main (string[] args) {

    facebook:ClientConnector facebookConnector = create facebook:ClientConnector(accessToken);

    message facebookResponse = {};
    json facebookJSONResponse;
    
    facebookResponse = facebook:ClientConnector.createPost(facebookConnector, pageId,"","","");

    facebookJSONResponse = messages:getJsonPayload(facebookResponse);
    system:println(jsons:toString(facebookJSONResponse));
}
    
function init () (facebook:ClientConnector facebookConnector) {

    facebookConnector = create facebook:ClientConnector(accessToken);
    return facebookConnector;
}

function createNewsPost () {
    facebook:ClientConnector facebookConnector = init();
    response = facebook:ClientConnector.createPost (facebookConnector, "me", "Test Message from Ballerina", "", "");
    facebookJSONResponse = messages:getJsonPayload(response);
    json a = facebookJSONResponse["id"];
    system:println(a);
    system:println(facebookJSONResponse);
    int status = http:getStatusCode(response);

    system:println("===testCreatePost completed===\n");
}