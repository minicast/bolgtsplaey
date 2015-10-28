Games = new Mongo.Collection("games");
Games.allow({
  insert: function(){
    return true;
  },
  // update: function(){
  //   return true;
  // },
  // remove: function(){
  //   return true;
  // }
});
// Structures = new Mongo.Collection("structures");
// Formulas = new Mongo.Collection("formulas");
