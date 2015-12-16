/**
 * Modules for tests
 */
/* jshint unused: false */
var nodeunit = require('nodeunit'),
    https = require('https'),
    util = require('util'),
    remote = process.env.TEST_REMOTE === 'true';

console.log(process.env.VCAP_APPLICATION);

//var base_uri = 'https://' + JSON.parse(process.env.VCAP_APPLICATION).uris[0];

//var vcap_application = JSON.parse(process.env.VCAP_APPLICATION);

exports.testcase = {
  setUp: function (callback) {
    //set up
    console.log("startUp");
    callback();
  },
  
  tearDown: function (callback) {
    //cleanup
    console.log("tearDown");
    callback();
  },
  
  testSomething: function (test) {
    test.expect(1);
    test.ok(true, "Test should pass");
    test.done();
  }

  /*
  testGetRequest: function (test) {
    test.expect(1);
    
    base_uri = vcap_application.application_uris[0];
    https.get("https://" + base_uri, function(res){
    	response.on('data', function(chunk) {
            console.log("GET got ", chunk.length, " characters.");
    	});
    	test.ok(res.statusCode < 200 || response.statusCode > 299);
    	test.done;
    }).on('error', function(e) {
        console.log('problem with request: ' + e.message);
    });

  }
  */
};
