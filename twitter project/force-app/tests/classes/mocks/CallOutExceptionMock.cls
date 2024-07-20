@IsTest
global class CallOutExceptionMock implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req) {
        throw new CalloutException('Mock callout exception');
    }
}