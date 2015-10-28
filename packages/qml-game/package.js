Package.describe({
  name: 'minicast:qml-game',
  summary: 'defines basic functionality for games of quantified modal logic ',
  version: '0.1.0',
  // git: 'https://github.com/minicast/meteor-qml-game'
});

Package.onUse(function(api) {
  api.versionsFrom('1.0.1');
  api.use(['meteor', 'ddp', 'jquery', 'coffeescript']);

  api.addFiles('server/game.coffee', ['server']);

  api.export(['G', 'S', 'F']);
});

Package.onTest(function(api){
  api.use('mike:mocha-package');
  api.addFiles('server/game.coffee', ['server']);
  api.addFiles('tests/tests.js', ['server']);
});
