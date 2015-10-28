timeoutValue = 60 * 1000 # 1 minute

Template.activeGames.changed = ->
  console.log "activeGames template <tbody> changed"


Template.activeGames.events
  'change .tbody': () ->
    # Meteor.clearTimeout Session.get 'randomMoveChoiceTimeoutId'
    # randomRolesTimeoutId = Meteor.setTimeout () ->
    #   console.log 'timeout'
    # , timeoutValue
    # Session.set 'randomMoveChoiceTimeoutId', randomRolesTimeoutId

  'click .roleChoice': (event, template) ->
    gameId = @._id
    playerId = Meteor.userId()
    choice = event.currentTarget.value
    random = false
    Meteor.clearTimeout Session.get 'randomRolesTimeoutId'
    Meteor.clearTimeout Session.get 'randomBuildPerspectivesId'
    Meteor.call "distributeRoles", gameId, playerId, choice, random,
    (error, result) ->
      if error
        console.log "error", error
      if result
        console.log "success", result
        Meteor.call "buildPerspectives", gameId, (error, result) ->
          if error
            console.log "error", error
          if result
            console.log "success", result

  'click .formulaChoice': (event, template) ->
    gameId = event.currentTarget.value
    playerId = Meteor.userId()
    choice = @.toString()

    random = false

    # Meteor.clearTimeout Session.get 'randomMoveChoiceTimeoutId'
    # randomRolesTimeoutId = Meteor.setTimeout () ->
    #   console.log 'timeout'
    # , timeoutValue
    # Session.set 'randomMoveChoiceTimeoutId', randomRolesTimeoutId


    Meteor.call "formulaChoice", gameId, playerId, choice, (error, result) ->
      if error
        console.log "error", error
      if result
        console.log "success", result

Template.playableGames.events
  "click button": (event, template) ->
    gameId = @._id
    playerId = Meteor.userId()
    if !Meteor.userId()
      alert "Please sign in to play this game!"
    else
      Meteor.call "activateGame", gameId, playerId, (error, result) ->
        if error
          console.log "error", error
        if result
          console.log "success", result
      randomRolesTimeoutId = Meteor.setTimeout () ->
        randomChoice = ['verifier','falsifier'][Math.round(Math.random())]
        random = true
        Meteor.call "distributeRoles", gameId, playerId, randomChoice, random
        (error, result) ->
          if error
            console.log "error", error
          if result
            console.log "success", result
      , timeoutValue
      Session.set 'randomRolesTimeoutId', randomRolesTimeoutId
      randomBuildPerspectivesId = Meteor.setTimeout () ->
        Meteor.call "buildPerspectives", gameId, (error, result) ->
          if error
            console.log "error", error
          if result
            console.log "success", result
      , timeoutValue + 3000
      Session.set 'randomBuildPerspectivesId', randomBuildPerspectivesId

Template.publicGames.events
  "click button": (event, template) ->
    if !Meteor.userId()
      alert "Please sign in to join this game!"
    else
      Meteor.call "addPlayer", @._id, Meteor.userId(), (error, result) ->
        if error
          console.log "error", error
        if result
          console.log "success", result
      Meteor.call "joinPlayer", @._id, Meteor.userId(), (error, result) ->
        if error
          console.log "error", error
        if result
          console.log "success", result

Template.initiatedGames.events
  "click button": (event, template) ->
    robotId = "Random Robot"
    Meteor.call "addRobot", @._id, robotId, (error, result) ->
      if error
        console.log "error", error
      if result
        console.log "success", result

Template.createGame.events
  'submit #createGame': (event, template) ->
    console.log "ok"
    if !Meteor.userId()
      alert "Please sign in to create a game!"
    else
      target = event
      console.log target
      formula = $('#formulaTextInput').val()
      structure = $('#structureTextInput').val()
        # target['1'].value #or event.target.formula.value
      # structure = target.structureText.value #or target.structure.value
      console.log formula, structure
      playerId = Meteor.userId()

      Meteor.call "createGame", formula, structure, playerId, (error, result) ->
        if error
          console.log "error", error
        if result
          console.log "success", result
