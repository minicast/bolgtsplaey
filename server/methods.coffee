Meteor.methods
  validateFormula: (asciiString) ->
    # try
    #   parsed = qmlf.parse asciiString
    #   if not parsed
    #     Formulas.simpleSchema().namedContext().addInvalidKeys(
    #       [{name: "ascii", type: "notAllowed"}]
    #     )
    #     throw new Error()
    # catch error
    parsed = qmlf.parse asciiString
    if parsed is undefined
    #   Formulas.simpleSchema().namedContext().addInvalidKeys(
    #     [{name: "ascii", type: "notAllowed"}]
    #   )
      return false
    if parsed
      return true



  createGame: (formulaAscii, structureAscii, playerId) ->
    game = new G
      formula:
        ascii: formulaAscii
      structure:
        ascii: structureAscii
      createdBy: playerId
      createdAt: Date.now() #moment().format('HH:mm:ss ddd DD MMM YYYY')
    game.addPlayer(playerId)
    console.log game
    result = Games.insert game.toJSONValue()

  addPlayer: (gameId, playerId) ->
    game = Games.findOne gameId
    game.addPlayer playerId
    result = Games.update gameId, game.toJSONValue()

  addRobot: (gameId, robotId) ->
    game = Games.findOne gameId
    game.addRobot robotId
    # game.joinRobot robotId
    result = Games.update gameId, game.toJSONValue()

  joinPlayer: (gameId, playerId) ->
    game = Games.findOne gameId
    game.joinPlayer playerId
    result = Games.update gameId, game.toJSONValue()

  activateGame: (gameId, playerId) ->
    game = Games.findOne gameId
    game.activateGame playerId
    result = Games.update gameId, game.toJSONValue()

  distributeRoles: (gameId, playerId, choice, rand) ->
    Games.update gameId, $unset:
      'roleChoices': ""
    game = Games.findOne gameId
    if rand is true
      game.setRole playerId, choice, "randomly asigmed due to timeout",
      Date.now()
      otherPlayerId = game.getOtherPlayerId playerId
      otherRole = roleComplement choice
      game.setRole otherPlayerId, otherRole, "randomly asigmed due to timeout",
      Date.now()
    else
      if choice is 'verifier'
        game.setRole playerId, choice, "chosen by you before your oponent",
        Date.now()
        otherPlayerId = game.getOtherPlayerId playerId
        otherRole = roleComplement choice
        game.setRole otherPlayerId, otherRole,
        "automatically asigned because your opponent chose first", Date.now()
      else if choice is 'falsifier'
        game.setRole playerId, choice, "chosen by you before your oppenent",
        Date.now()
        otherPlayerId = game.getOtherPlayerId playerId
        otherRole = roleComplement choice
        game.setRole otherPlayerId, otherRole,
        "automatically asigned because your opponent chose first", Date.now()
      else
        throw new Error("distributeRoles error")
    result = Games.update gameId, game.toJSONValue()

  formulaChoice: (gameId, playerId, choice) ->
    game = Games.findOne gameId
    game.processPlayerGameMove(playerId,choice)
    game.buildPerspectives()
    result = Games.update gameId, game.toJSONValue()

  buildPerspectives: (gameId) ->
    game = Games.findOne gameId
    game.buildPerspectives()
    result = Games.update gameId, game.toJSONValue()

otherPlayerId = (gameId, playerId) ->
  _(Games.findOne(gameId).players).without(playerId)[0]

roleComplement = (role) ->
  _(["verifier", "falsifier"]).without(role)[0]
