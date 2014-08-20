// Generated by CoffeeScript 1.7.1
(function() {
  var Background, Twitter, TwitterCommands, exports, _ref;

  Background = (function() {
    function Background(commands) {
      this.commands = commands;
      this.addEventListeners();
    }

    Background.prototype.addEventListeners = function() {
      chrome.runtime.onMessage.addListener((function(_this) {
        return function(request, sender, sendResponse) {
          var args, res, target;
          if (sender.tab) {
            console.log("from a content script: " + sender.tab.url);
          } else {
            console.log("from the extension");
          }
          target = _this.commands[request.target];
          if (!target) {
            throw Error("Invalid target " + request.target, _this.commands);
          }
          args = request.args;
          args.push(sendResponse);
          res = target[request.action].apply(target, args);
          if (res) {
            sendResponse({
              res: res
            });
          }
          return true;
        };
      })(this));
    };

    return Background;

  })();

  TwitterCommands = (function() {
    function TwitterCommands() {}

    TwitterCommands.prototype.sendSignedRequest = function(url, request, sendResponse) {
      Twitter.sendSignedRequest(url, sendResponse, request);
    };

    return TwitterCommands;

  })();

  Twitter = (function() {
    Twitter.OAUTH_PARAM = {
      request_url: 'https://api.twitter.com/oauth/request_token',
      authorize_url: 'https://api.twitter.com/oauth/authorize',
      access_url: 'https://api.twitter.com/oauth/access_token',
      consumer_key: 'I7GcKlS4hnVloq9vLyvfQ',
      consumer_secret: 'N0eoeNkSufsKsnpywjKZsZeK6DrqA7Jhr7kW6I',
      scope: 'https://api.twitter.com/1.1/',
      app_name: 'vimmers_folow_status'
    };

    Twitter.sendSignedRequest = function(url, onsuccess, request) {
      return new Twitter().sendSignedRequest(url, onsuccess, request);
    };

    function Twitter() {}

    Twitter.prototype.authorize = function(onAuthorised) {
      var oauth;
      console.log('Run authorizing.');
      oauth = ChromeExOAuth.initBackgroundPage(Twitter.OAUTH_PARAM);
      oauth.authorize(function() {
        console.log('Authorized successfully.');
        return onAuthorised(oauth);
      });
    };

    Twitter.prototype.sendSignedRequest = function(url, onsuccess, request) {
      this.authorize((function(_this) {
        return function(oauth) {
          oauth.sendSignedRequest(url, _this._onSendSignedRequest.bind(_this, onsuccess), request);
        };
      })(this));
    };

    Twitter.prototype._onSendSignedRequest = function(onsuccess, response, xhr) {
      var resJson, _ref;
      resJson = JSON.parse(response);
      console.log('Signed request response', resJson);
      if (((_ref = resJson.errors) != null ? _ref[0].code : void 0) === 89) {
        this.removeOauthToken();
      }
      onsuccess({
        res: resJson
      });
    };

    Twitter.prototype.removeOauthToken = function() {
      console.log('Remove oath access token.', localStorage);
      localStorage.removeItem('oauth_tokenhttps://api.twitter.com/1.1/');
      localStorage.removeItem('oauth_token_secrethttps://api.twitter.com/1.1/');
      console.log(localStorage);
    };

    return Twitter;

  })();

  exports = (_ref = exports != null ? exports : window) != null ? _ref : this;

  exports.bg = new Background({
    twitter: new TwitterCommands
  });

}).call(this);
