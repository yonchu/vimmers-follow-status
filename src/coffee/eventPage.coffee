class Background
  constructor: (@commands) ->
    @addEventListeners()

  addEventListeners: ->
    chrome.runtime.onMessage.addListener (request, sender, sendResponse) =>
      if sender.tab
        console.log "from a content script: #{sender.tab.url}"
      else
        console.log "from the extension"
      target = @commands[request.target]
      unless target
        throw Error "Invalid target #{request.target}", @commands
      args = request.args
      args.push sendResponse
      res = target[request.action].apply target, args
      if res
        sendResponse res: res
      return true
    return


class TwitterCommands
  constructor: ->

  sendSignedRequest: (url, request, sendResponse) ->
    Twitter.sendSignedRequest url, sendResponse, request
    return


class Twitter
  @OAUTH_PARAM:
    request_url: 'https://api.twitter.com/oauth/request_token'
    authorize_url: 'https://api.twitter.com/oauth/authorize'
    access_url: 'https://api.twitter.com/oauth/access_token'
    consumer_key: 'I7GcKlS4hnVloq9vLyvfQ'
    consumer_secret: 'N0eoeNkSufsKsnpywjKZsZeK6DrqA7Jhr7kW6I'
    scope: 'https://api.twitter.com/1.1/'
    app_name: 'vimmers_folow_status'

  # TODO onfailure
  @sendSignedRequest: (url, onsuccess, request) ->
    new Twitter().sendSignedRequest url, onsuccess, request

  constructor: ->

  authorize: (onAuthorised) ->
    console.log 'Run authorizing.'
    oauth = ChromeExOAuth.initBackgroundPage Twitter.OAUTH_PARAM
    oauth.authorize ->
      console.log 'Authorized successfully.'
      onAuthorised oauth
    return

  sendSignedRequest: (url, onsuccess, request) ->
    @authorize (oauth) =>
      # Note Function.bind supported only from ES5.
      oauth.sendSignedRequest(
        url,
        @_onSendSignedRequest.bind(@, onsuccess),
        request
      )
      return
    return

  _onSendSignedRequest: (onsuccess, response, xhr) ->
    resJson = JSON.parse response
    console.log 'Signed request response', resJson
    if resJson.errors?[0].code is 89
      @removeOauthToken()
    onsuccess res: resJson
    return

  removeOauthToken: ->
    console.log 'Remove oath access token.', localStorage
    localStorage.removeItem 'oauth_tokenhttps://api.twitter.com/1.1/'
    localStorage.removeItem 'oauth_token_secrethttps://api.twitter.com/1.1/'
    console.log localStorage
    return


## Main
exports = exports ? window ? @
exports.bg = new Background(
  twitter: new TwitterCommands
)
