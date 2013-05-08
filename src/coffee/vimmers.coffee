class Vimmers
  @FRIENDSHIPS_LOOKUP_URL: 'https://api.twitter.com/1.1/friendships/lookup.json'
  @MAX_NAME_COUNT_PER_REQUEST: 100

  status:
    both:
      className: 'status-both'
      count: 0
    following:
      className: 'status-following'
      count: 0
    followed:
      clssName: 'status-followed'
      count: 0
    none:
      className: 'status-none'
      count: 0

  fetchCount: 0

  friendships: null

  # DOM
  persons: null

  constructor: () ->
    console.log 'Run Vimmers.'
    @addEventListeners()

  addEventListeners: ->
    document.getElementById('vimmers-showall')
      .addEventListener('click',  (event) =>
        setTimeout(=>
          @init()
          return
        , 1 * 1000)
        return
      , false)
    return

  init: ->
    @persons = document.querySelectorAll('.persons .person')
    console.log "Total vimmers: #{@persons.length}"
    namesList = @getScreenNmaesList()
    for names in namesList
      @fetchFollowStatus names
    return

  getScreenNmaesList: ->
    namesList = []
    names = []
    namesList.push names
    for person in @persons
      if names.length >= Vimmers.MAX_NAME_COUNT_PER_REQUEST
        names = []
        namesList.push names
      name = @getScreenNmae person
      continue unless name
      names.push name
    return namesList

  getScreenNmae: (person) ->
    href = person.querySelectorAll('.link a')[0]?.getAttribute('href')
    return href.match(/twitter\.com\/(.*)/)?[1]

  fetchFollowStatus: (screenNames) ->
    @fetchCount += 1
    url = Vimmers.FRIENDSHIPS_LOOKUP_URL
    request =
      method: 'GET',
      parameters:
        screen_name: screenNames.join ','
    chrome.extension.sendRequest({
        'target' : 'twitter',
        'action' : 'sendSignedRequest',
        'args'   : [url, request]
      }, (response) =>
        console.log 'Follow status: ', response
        @fetchCount -= 1
        unless response.res
          console.log 'Fetch follow status: no results.'
          return
        @friendships or= {}
        for friendship in response.res
          @friendships[friendship.screen_name] = friendship
        if @fetchCount
          return
        @renderFollowStatus()
        @renderExplanation()
    )
    return

  renderFollowStatus: ->
    for person in @persons
      name = @getScreenNmae person
      continue unless name
      friendship = @friendships[name]
      unless friendship
        console.error "Unknown friendship: #{name}"
        continue
      connections = friendship.connections
      isFollowing = 'following' in connections
      isFollowed = 'followed_by' in connections
      className = @updateStatus isFollowing, isFollowed
      person.className += " #{className}"
    return

  updateStatus: (isFollowing, isFollowed) ->
    className = null
    if isFollowing and isFollowed
      @status.both.count += 1
      className = @status.both.className
    else if isFollowing
      @status.following.count += 1
      className = @status.following.className
    else if isFollowed
      @status.followed.count += 1
      className = @status.followed.className
    else
      @status.none.count += 1
      className = @status.none.className
    return className

  renderExplanation: ->
    total = "<p>Total: #{@persons.length}</p>"
    followingExp = "<p>Following only: #{@status.following.count}</p>"
    followedExp = "<p>Followed only: #{@status.followed.count}</p>"
    bothExp = "<p>Both: #{@status.both.count}</p>"
    div = document.getElementById 'status-explanation'
    unless div
      div = document.createElement 'div'
      div.id = 'status-explanation'
      pos = document.querySelector('.vimmers-controls')
      parent = pos.parentNode
      parent.insertBefore div, pos
      div = document.getElementById 'status-explanation'
    div.innerHTML = total + followingExp + followedExp + bothExp
    return


## Main
vimmers = new Vimmers
