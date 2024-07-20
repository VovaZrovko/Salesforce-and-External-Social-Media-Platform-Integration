@IsTest
global class CallOutSuccessMock implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if (req.getMethod() == 'DELETE') {
            res.setStatusCode(200);
            res.setBody('{ "data": { "deleted": true }}');
        } else if (req.getMethod() == 'POST') {
            res.setBody('{ "data": { "id": "12345" }, "expires_in": 10000, "access_token": "accesstoken" }');
            res.setStatusCode(201);
        } else if (req.getMethod() == 'GET') {
            res.setBody('{ "data": { "username": "test username"}}');
            res.setStatusCode(200);
        }
        return res;
    }
}