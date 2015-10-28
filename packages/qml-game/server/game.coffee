class F
  typeName: ->
    'F'
  toJSONValue: ->
    ascii: @ascii
  constructor: (@ascii) ->
    @peg = @parse()
    @lop = @leftOperand()
    @rop = @rightOperand()

  parse: () -> qmlf.parse @ascii
  esrap: (peg) -> _(peg).flatten().join("")
  isAtom: () -> typeof @peg is 'string'
  isDoubleNegation: () -> @isNegation() and @peg[1] is "~"
  isNegation: () -> @peg[0] is "~"
  isConjunction: () -> @peg[2] is "&"
  isDisjunction: () -> @peg[2] is "|"
  isImplication: () -> @peg[2] is ">"
  isEquivalence: () -> @peg[2] is "^"
  isBinaryOp: () ->
    @isConjunction() or @isDisjunction() or @isImplication() or @isEquivalence()
  leftOperand: () -> @peg[1] if @isNegation() or @isBinaryOp()
  rightOperand: () -> @peg[3] if @isBinaryOp
  mainOperator: () ->
    return undefined if @isAtom()
    return "~" if @isNegation()
    return @formulaPeg[2] if @isBinaryOp()

class S
  typeName: ->
    'S'
  toJSONValue: ->
    ascii: @ascii
  constructor: (@ascii) ->
    @peg = @parse()
    @mds = @metaDomainSize()

  parse: () -> qmls.parse @ascii
  esrap: (peg) -> _(peg).flatten().join("")
  getValuation: () -> _(_(@peg[2][0][1]).flatten()).without(',') if @mds is 1
  metaDomainSize: () -> @ascii.split(";").length

class G
  typeName: ->
    'G'
  toJSONValue: ->
    formula: @formula.toJSONValue()
    structure: @structure.toJSONValue()
    subFormula: @subFormula.toJSONValue()
    players: @players, perspectives: @perspectives
    verifier: @verifier, falsifier: @falsifier
    createdBy: @createdBy, createdAt: @createdAt
    joinedBy: @joinedBy, joinedAt: @joinedAt
    startedBy: @startedBy, startedAt: @startedAt
    activeGame: @activeGame, roleChoices: @roleChoices
    history: @history
  constructor: (doc) ->
    @formula = new F doc.formula.ascii
    @structure = new S doc.structure.ascii
    if doc.subFormula
      @subFormula = new F doc.subFormula.ascii
    else
      @subFormula = new F doc.formula.ascii
    @players = doc.players || []; @perspectives = doc.perspectives || {}
    @verifier = doc.verifier; @falsifier = doc.falsifier
    @createdBy = doc.createdBy; @createdAt = doc.createdAt
    @joinedBy = doc.joinedBy; @joinedAt = doc.joinedAt
    @activeGame = doc.activeGame; @roleChoices = doc.roleChoices
    @startedBy = doc.startedBy; @startedAt = doc.startedAt
    @history = doc.history || []

  esrap: (peg) -> _(peg).flatten().join("")

  addPlayer: (playerId) ->
    @players.push(playerId)
    @perspectives[playerId] = {}

  addRobot: (robotId) ->
    @addPlayer robotId
    @joinedBy = robotId
    @joinedAt = Date.now()

  # joinRobot: (robotId) ->
  #   @joinPlayer robotId

  joinPlayer: (playerId) ->
    @joinedBy = playerId
    @joinedAt = Date.now()

  activateGame: (playerId) ->
    @activeGame = true
    @roleChoices = ["verifier", "falsifier"]
    @startedBy = playerId
    @startedAt = Date.now()

  setRole: (playerId, role, message, time) ->
    @[role] = playerId
    @perspectives[playerId]["startingRole"] = role
    @perspectives[playerId]["startingRoleDistributionMessage"] = message
    @perspectives[playerId]["role"] = role
    @perspectives[playerId]["roleDistributionMessage"] = message
    if "Random Robot" in @players and @perspectives["Random Robot"].choices
      @processRobotGameMove("Random Robot")

  getOtherPlayerId: (playerId) ->
    _(@players).without(playerId)[0]

  switchRoles: () ->
    currentVerifierId = @["verifier"]
    currentFalsifierId = @["falsifier"]
    flipStep = @history.length
    switchMessage = "automatically assigned by role switch at step #{flipStep}"
    @perspectives[currentVerifierId]["role"] = "falsifier"
    @perspectives[currentVerifierId]["roleDistributionMessage"] = switchMessage
    @perspectives[currentFalsifierId]["role"] = "verifier"
    @perspectives[currentFalsifierId]["roleDistributionMessage"] = switchMessage
    @["verifier"] = currentFalsifierId
    @["falsifier"] = currentVerifierId

  processPlayerGameMove: (playerId, move) ->
    @subFormula = new F move
    step =
      move: move
      moveNo: @history.length
      moveBy: playerId
      moveRole: @perspectives[playerId].role
      moveAt: Date.now()
      unexploredChoices: _(@perspectives[playerId].choices).without(move)
    @history.push(step)
    @

  processRobotGameMove: (robotId) ->
    if @perspectives[robotId].choices
      console.log "inside processRobotGameMove"
      moves = @perspectives[robotId].choices
      randomMove = moves[Math.floor(Math.random() * moves.length)]
      console.log randomMove
    @processPlayerGameMove robotId, randomMove
    @buildPerspectives()

  processAutomaticNegationMove: () ->
    @switchRoles()
    @subFormula = new F @subFormula.ascii.substr(1)
    step =
      move: @subFormula.ascii
      moveNo: @history.length
      moveBy: 'Duality Droid'
      moveRole: 'swaper'
      moveAt: Date.now()
    @history.push(step)
    @buildPerspectives()

  processAtomicModelCheck: (truthValue) ->
    step =
      move: truthValue
      moveNo: @history.length
      moveBy: "Surface Sensor"
      moveRole: "checker"
      moveAt: Date.now()
    @history.push(step)


  buildPerspectives: () ->
    if @subFormula.isAtom()
      if @subFormula.ascii in @structure.getValuation()
        truthValue = "true"
        verifierMessage = "win"; verifierColor = "success"
        falsifierMessage = "lose"; falsifierColor = "danger"
        @processAtomicModelCheck(truthValue)
      if not (@subFormula.ascii in @structure.getValuation())
        truthValue = "false"
        verifierMessage = "lose"; verifierColor = "danger"
        falsifierMessage = "win"; falsifierColor = "success"
        @processAtomicModelCheck(truthValue)
      @perspectives[@verifier]['choices'] = []
      @perspectives[@verifier]['truthValue'] = truthValue
      @perspectives[@verifier]['verifierMessage'] = verifierMessage
      @perspectives[@verifier]['verifierColor'] = verifierColor
      @perspectives[@falsifier]['choices'] = []
      @perspectives[@falsifier]['truthValue'] = truthValue
      @perspectives[@falsifier]['falsifierMessage'] = falsifierMessage
      @perspectives[@falsifier]['falsifierColor'] = falsifierColor
    if @subFormula.isNegation()
      @processAutomaticNegationMove()
    if @subFormula.isConjunction()
      @perspectives[@verifier]['choices'] = []
      @perspectives[@falsifier]['choices'] =
        _([@subFormula.lop, @subFormula.rop]).map(@esrap)
    if @subFormula.isDisjunction()
      @perspectives[@falsifier]['choices'] = []
      @perspectives[@verifier]['choices'] =
        _([@subFormula.lop, @subFormula.rop]).map(@esrap)
    if @subFormula.isImplication()
      @perspectives[@falsifier]['choices'] = []
      @perspectives[@verifier]['choices'] =
        ['~' + @esrap(@subFormula.lop), @esrap(@subFormula.rop)]
    if @subFormula.isEquivalence()
      @perspectives[@falsifier]['choices'] = []
      @perspectives[@verifier]['choices'] =
        [
          '(' + @esrap(@subFormula.lop) + '&' + @esrap(@subFormula.rop) + ')',
          '(~' + @esrap(@subFormula.lop)+ '&~' + @esrap(@subFormula.rop) + ')'
        ]
    if "Random Robot" in @players and
    @perspectives["Random Robot"].choices.length > 0
      console.log "randomRobot move"
      @processRobotGameMove("Random Robot")

  isBacktracking: () ->
    not ((_(_(@history).filter(
      (x) -> x.unexploredChoices
    )).filter(
      (x) -> x.unexploredChoices.length
    )).length is 0)

  backtrackingStatus: () ->
    history = @history
    backtrackableSteps = _(_(history).filter(
      (x) -> x.unexploredChoices
    )).filter(
      (x) -> x.unexploredChoices.length
    )
    backtrackableStepsNumbers = _(backtrackableSteps).map(
      (x) -> x.moveNo
    )
    backtrackableStepsNumbersAndChoices = _(backtrackableSteps).map(
      (x) -> { no: x.moveNo, choices: x.unexploredChoices }
    )
    {
      h: history, bks: backtrackableSteps, bksn: backtrackableStepsNumbers
      bksnc: backtrackableStepsNumbersAndChoices
    }

  # clone: ->
  #   # new G(@formulaAscii, @structureAscii, @subFormulaAscii)
  #   new G(@)
  # equals: (other) ->
  #   if !(other instanceof G)
  #     return false
  #   # @formulaAscii is other.formulaAscii and
  #   # @structureAscii is other.structureAscii and
  #   # @subFormulaAscii is other.subFormulaAscii
  #   @ is other
