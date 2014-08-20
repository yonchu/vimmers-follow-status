// Generated by CoffeeScript 1.7.1
(function() {
  var Vimmers, vimmers,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  Vimmers = (function() {
    Vimmers.FRIENDSHIPS_LOOKUP_URL = 'https://api.twitter.com/1.1/friendships/lookup.json';

    Vimmers.MAX_NAME_COUNT_PER_REQUEST = 100;

    function Vimmers() {
      console.log('Run Vimmers.');
      this.fetchCount = 0;
      this.friendships = [];
      this.persons = null;
      this.status = {
        both: {
          className: 'status-both',
          count: 0
        },
        following: {
          className: 'status-following',
          count: 0
        },
        followed: {
          clssName: 'status-followed',
          count: 0
        },
        none: {
          className: 'status-none',
          count: 0
        }
      };
      this.addEventListeners();
    }

    Vimmers.prototype.addEventListeners = function() {
      document.getElementById('vimmers-showall').addEventListener('click', (function(_this) {
        return function(event) {
          setTimeout(_this.showFollowStatus.bind(_this), 1 * 1000);
        };
      })(this), false);
    };

    Vimmers.prototype.showFollowStatus = function() {
      var namesList;
      this.persons = document.querySelectorAll('.persons .person');
      console.log("Total vimmers: " + this.persons.length);
      namesList = this.getScreenNmaesList();
      this.fetchFollowStatus(namesList);
    };

    Vimmers.prototype.getScreenNmaesList = function() {
      var name, names, namesList, person, _i, _len, _ref;
      namesList = [];
      names = [];
      namesList.push(names);
      _ref = this.persons;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        person = _ref[_i];
        if (names.length >= Vimmers.MAX_NAME_COUNT_PER_REQUEST) {
          names = [];
          namesList.push(names);
        }
        name = this.getScreenNmae(person);
        if (!name) {
          continue;
        }
        names.push(name);
      }
      return namesList;
    };

    Vimmers.prototype.getScreenNmae = function(person) {
      var href, _ref, _ref1;
      href = (_ref = person.querySelector('.link a')) != null ? _ref.getAttribute('href') : void 0;
      return (_ref1 = href.match(/twitter\.com\/(.*)/)) != null ? _ref1[1] : void 0;
    };

    Vimmers.prototype.fetchFollowStatus = function(namesList) {
      var length, request, sendMessageParam, tryNextFetch, url;
      url = Vimmers.FRIENDSHIPS_LOOKUP_URL;
      request = {
        method: 'GET',
        parameters: {
          screen_name: null
        }
      };
      sendMessageParam = {
        target: 'twitter',
        action: 'sendSignedRequest',
        args: [url, request]
      };
      length = namesList.length;
      tryNextFetch = (function(_this) {
        return function(index) {
          if (index >= length) {
            console.log("All fetch finished!");
            _this.renderFollowStatus();
            _this.renderExplanation();
            return;
          }
          console.log("Try fetch " + index);
          request.parameters.screen_name = namesList[index].join(',');
          chrome.runtime.sendMessage(sendMessageParam, function(response) {
            var friendship, _i, _len, _ref;
            console.log('Follow status: ', response);
            if (!response.res) {
              alert('フォロー状態の取得に失敗しました');
              return;
            }
            _ref = response.res;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              friendship = _ref[_i];
              _this.friendships[friendship.screen_name] = friendship;
            }
            tryNextFetch(index + 1);
          });
        };
      })(this);
      tryNextFetch(0);
    };

    Vimmers.prototype.renderFollowStatus = function() {
      var className, connections, friendship, isFollowed, isFollowing, name, person, _i, _len, _ref;
      _ref = this.persons;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        person = _ref[_i];
        name = this.getScreenNmae(person);
        if (!name) {
          continue;
        }
        friendship = this.friendships[name];
        if (!friendship) {
          console.error("Unknown friendship: " + name);
          continue;
        }
        connections = friendship.connections;
        isFollowing = __indexOf.call(connections, 'following') >= 0;
        isFollowed = __indexOf.call(connections, 'followed_by') >= 0;
        className = this.updateStatus(isFollowing, isFollowed);
        person.className += " " + className;
      }
    };

    Vimmers.prototype.updateStatus = function(isFollowing, isFollowed) {
      var className;
      className = '';
      if (isFollowing && isFollowed) {
        this.status.both.count += 1;
        className = this.status.both.className;
      } else if (isFollowing) {
        this.status.following.count += 1;
        className = this.status.following.className;
      } else if (isFollowed) {
        this.status.followed.count += 1;
        className = this.status.followed.className;
      } else {
        this.status.none.count += 1;
        className = this.status.none.className;
      }
      return className;
    };

    Vimmers.prototype.renderExplanation = function() {
      var bothExp, div, followedExp, followingExp, pos, total;
      total = "<p>Total: " + this.persons.length + "</p>";
      followingExp = "<p>Following only: " + this.status.following.count + "</p>";
      followedExp = "<p>Followed only: " + this.status.followed.count + "</p>";
      bothExp = "<p>Both: " + this.status.both.count + "</p>";
      div = document.createElement('div');
      div.id = 'status-explanation';
      div.innerHTML = total + followingExp + followedExp + bothExp;
      pos = document.querySelector('.vimmers-controls');
      pos.parentNode.insertBefore(div, pos);
    };

    return Vimmers;

  })();

  vimmers = new Vimmers;

}).call(this);
