Template.headerTemplate.helpers({
  status: Meteor.status
});

Template.allGames.helpers
  rendered: ->

  allGames: ->
    Games.find()

Template.activeGames.helpers
  activeGames: (currentUser) ->
    # Games
    # .find
    #   $and: [ { players: Meteor.userId() }, { players: $size: 2 } ]
    #   activeGame: true
    # .sort
    #   createdAt: -1
    return Games.find({
      $and: [
        {
          players: Meteor.userId()
        }, {
          players: {
            $size: 2
          }
        }
      ],
      activeGame: true
    },
    {sort:{ startedAt: -1}, limit: 1}
    )
  otherPlayer: (currentUser) ->
    otherPlayer @.players, currentUser._id
  perspective: (playerId) ->
    @perspectives[playerId]
  youPlayer: (player, currentUser) ->
    if currentUser._id is player
      return "You"
    if player is "Random Robot"
      return "Robot (random)"
    else
    if player is "Duality Droid"
      return "Duality (automatic)"
    else
    if player is "Surface Sensor"
      return "Check (extension)"
    else
      return player.slice(0,5);

  momentize: (miliseconds) ->
    moment(miliseconds).format("HH:mm:ss")
  backtrack: () ->
    # # @history
    # # not ((_(_(@history).filter(
    # #   (x) -> x.unexploredChoices
    # # )).filter(
    # #   (x) -> x.unexploredChoices.length
    # # )).length is 0)
    # history = @history
    # backtrackableSteps = _(_(history).filter(
    #   (x) -> x.unexploredChoices
    # )).filter(
    #   (x) -> x.unexploredChoices.length
    # )
    # backtrackableStepsNumbers = _(backtrackableSteps).map(
    #   (x) -> x.moveNo
    # )
    # backtrackableStepsNumbersAndChoices = _(backtrackableSteps).map(
    #   (x) -> { no: x.moveNo, choices: x.unexploredChoices }
    # )
    # {
    #   h: history, bks: backtrackableSteps, bksn: backtrackableStepsNumbers
    #   bksnc: backtrackableStepsNumbersAndChoices
    # }
    false

Template.playableGames.helpers
  playableGames: (currentUser) ->
    Games.find
      $and: [ { players: Meteor.userId() }, { players: $size: 2 } ]
      activeGame:
        $not: true,
      {sort: {joinedAt: -1}, limit: 3}

  otherPlayer: (currentUser) ->
    otherPlayer @.players, currentUser._id #Meteor.userId()

  youPlayer: (player, currentUser) ->
    if currentUser._id is player
      return "You"
    if player is "Random Robot"
      return "Robot"
    else
      return player.slice(0,5);

  momentize: (miliseconds) ->
    # moment(miliseconds).format("HH:mm:ss ddd DD MMM YYYY")
    moment(miliseconds).format("HH:mm:ss (DD/MM/YY)")

otherPlayer = (playersList, userId) ->
  _(playersList).without(userId)[0]

Template.publicGames.helpers
  publicGames: (currentUser) ->
    Games.find
      'players.0':
        $not: Meteor.userId()
      players:
        $size: 1,
      {sort: {createdAt: -1}, limit: 3}
  slicePlayer: (player) ->
    player.slice(0,5)
  momentize: (miliseconds) ->
    moment(miliseconds).format("HH:mm:ss (DD/MM/YY)")

Template.initiatedGames.helpers
  initiatedGames: (currentUser) ->
    Games.find({
      'players.0': Meteor.userId(),
      players: { $size: 1 }
      },
      {sort: {createdAt: -1}, limit: 3}
    )
  momentize: (miliseconds) ->
    moment(miliseconds).format("HH:mm:ss (DD/MM/YY)")
