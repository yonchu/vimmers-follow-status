class Background
  commands:
    'twitter': null

  constructor: (@twitter)->
    @commands.twitter = @twitter
    @addEventListeners()

  addEventListeners: ->
    chrome.extension.onRequest.addListener (message, sender, sendResponse) =>
      target = @commands[message.target]
      unless target
        throw new Error "Invalid target #{message.target}"
      args = message.args
      args.push sendResponse
      res = target[message.action].apply target, args
      if res
        sendResponse res: res
      target = null
    return


class Twitter
  oauth: null

  constructor: ->

  authorize: (callback) ->
    console.log 'Run authorizing.'
    @oauth = ChromeExOAuth.initBackgroundPage(
      request_url: 'https://api.twitter.com/oauth/request_token'
      authorize_url: 'https://api.twitter.com/oauth/authorize'
      access_url: 'https://api.twitter.com/oauth/access_token'
      consumer_key: 'I7GcKlS4hnVloq9vLyvfQ'
      consumer_secret: 'N0eoeNkSufsKsnpywjKZsZeK6DrqA7Jhr7kW6I'
      scope: 'https://api.twitter.com/1.1/'
      app_name: 'vimmers_folow_status'
    )
    @oauth.authorize (@onAuthorized callback)
    callback = null
    return

  onAuthorized: (callback) ->
    return =>
      console.log 'Authorize successfully.'
      callback.call @
      callback = null
    return

  sendSignedRequest: (url, request, sendResponse) ->
    @authorize =>
      console.log 'Call onAuthoried callback', url, request
      @oauth.sendSignedRequest(
        url,
        (@onSendSignedRequest sendResponse),
        request
      )
      url = null
      request = null
      sendResponse = null
      return
    return

  onSendSignedRequest: (sendResponse) ->
    return (response, xhr) =>
      response = JSON.parse response
      console.log 'Response of sendSignedRequest', response
      if response.errors?[0].code is 89
        @removeOauthToken()
        console.log localStorage
        response = null
      sendResponse res: response
      sendResponse = null
      return

  removeOauthToken: ->
    console.log 'Remove oath access token.'
    localStorage.removeItem 'oauth_tokenhttps://api.twitter.com/1.1/'
    localStorage.removeItem 'oauth_token_secrethttps://api.twitter.com/1.1/'
    return


## Main
exports = exports ? window ? @
exports.bg = new Background (new Twitter)
