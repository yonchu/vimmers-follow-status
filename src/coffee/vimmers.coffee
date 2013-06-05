class Vimmers
  @FRIENDSHIPS_LOOKUP_URL: 'https://api.twitter.com/1.1/friendships/lookup.json'
  @MAX_NAME_COUNT_PER_REQUEST: 100

  constructor: ->
    console.log 'Run Vimmers.'

    @fetchCount = 0
    @friendships = []
    # DOM
    @persons = null

    @status =
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

    @addEventListeners()

  addEventListeners: ->
    document.getElementById('vimmers-showall')
      .addEventListener('click',  (event) =>
        # Function.bind supported only from ES5.
        setTimeout @showFollowStatus.bind(@), 1 * 1000
        return
      , false)
    return

  showFollowStatus: ->
    @persons = document.querySelectorAll '.persons .person'
    console.log "Total vimmers: #{@persons.length}"
    namesList = @getScreenNmaesList()
    @fetchFollowStatus namesList
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
    href = person.querySelector('.link a')?.getAttribute 'href'
    return href.match(/twitter\.com\/(.*)/)?[1]

  fetchFollowStatus: (namesList) ->
    url = Vimmers.FRIENDSHIPS_LOOKUP_URL
    request =
      method: 'GET',
      parameters:
        screen_name: null
    sendMessageParam =
      target: 'twitter',
      action: 'sendSignedRequest',
      args  : [url, request]
    length = namesList.length

    tryNextFetch = (index) =>
      if index >= length
        console.log "All fetch finished!"
        @renderFollowStatus()
        @renderExplanation()
        return
      console.log "Try fetch #{index}"
      request.parameters.screen_name = namesList[index].join ','
      chrome.runtime.sendMessage sendMessageParam, (response) =>
        console.log 'Follow status: ', response
        unless response.res
          alert 'フォロー状態の取得に失敗しました'
          return
        for friendship in response.res
          @friendships[friendship.screen_name] = friendship
        tryNextFetch index + 1
        return
      return
    tryNextFetch 0
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
    className = ''
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
    div = document.createElement 'div'
    div.id = 'status-explanation'
    div.innerHTML = total + followingExp + followedExp + bothExp
    pos = document.querySelector('.vimmers-controls')
    pos.parentNode.insertBefore div, pos
    return


## Main
vimmers = new Vimmers
