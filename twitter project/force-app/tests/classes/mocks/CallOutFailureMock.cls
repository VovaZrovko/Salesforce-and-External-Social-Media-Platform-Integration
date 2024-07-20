@IsTest
global class CallOutFailureMock implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{ "error": "Mock error" }');
        res.setStatusCode(400);
        return res;
    }
}