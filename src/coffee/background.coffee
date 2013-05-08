class Background
  commands:
    'twitter': null

  constructor: (twitterCommands)->
    @commands.twitter = twitterCommands
    @addEventListeners()

  addEventListeners: ->
    chrome.extension.onRequest.addListener (message, sender, sendResponse) =>
      target = @commands[message.target]
      unless target
        throw new Error "Invalid target #{message.target}", @commands
      args = message.args
      args.push sendResponse
      res = target[message.action].apply target, args
      if res
        sendResponse res: res
    return


class TwitterCommands
  constructor: ->

  sendSignedRequest: (url, request, sendResponse) ->
    tw = new Twitter sendResponse
    tw.sendSignedRequest url, request
    return


class Twitter
  _oauth: null
  _authorizedCallback: null

  constructor: (@_sendResponse) ->

  _authorize: ->
    console.log 'Run authorizing.'
    @_oauth = ChromeExOAuth.initBackgroundPage(
      request_url: 'https://api.twitter.com/oauth/request_token'
      authorize_url: 'https://api.twitter.com/oauth/authorize'
      access_url: 'https://api.twitter.com/oauth/access_token'
      consumer_key: 'I7GcKlS4hnVloq9vLyvfQ'
      consumer_secret: 'N0eoeNkSufsKsnpywjKZsZeK6DrqA7Jhr7kW6I'
      scope: 'https://api.twitter.com/1.1/'
      app_name: 'vimmers_folow_status'
    )
    @_oauth.authorize @_onAuthorized
    return

  _onAuthorized: =>
    console.log 'Authorized successfully.'
    @_authorizedCallback?.call @
    @_authorizedCallback = null
    return

  sendSignedRequest: (url, request) ->
    @_authorizedCallback = =>
      console.log 'Call onAuthoried callback', url, request
      @_oauth.sendSignedRequest(
        url,
        @_onSendSignedRequest,
        request
      )
      url = null
      request = null
      return
    @_authorize()
    return

  _onSendSignedRequest: (response, xhr) =>
    resJson = JSON.parse response
    console.log 'Response of sendSignedRequest', resJson
    if resJson.errors?[0].code is 89
      @_removeOauthToken()
      console.log localStorage
      resJson = null
    @_sendResponse res: resJson
    return

  _removeOauthToken: ->
    console.log 'Remove oath access token.'
    localStorage.removeItem 'oauth_tokenhttps://api.twitter.com/1.1/'
    localStorage.removeItem 'oauth_token_secrethttps://api.twitter.com/1.1/'
    return


## Main
exports = exports ? window ? @
exports.bg = new Background (new TwitterCommands)
