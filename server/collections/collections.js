Games = new Mongo.Collection("games", {
  transform: function(doc) {
    "use strict";
    var g = new G(doc);
    return g;
  }
});

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

EJSON.addType("F", function fromJSONValue(value) {
  return new F(value.ascii);
});

EJSON.addType("S", function fromJSONValue(value) {
  return new S(value.ascii);
});

EJSON.addType("G", function fromJSONValue(value) {
  return new G(value);
});

// // Tell EJSON about our new custom type
// EJSON.addType("Formula", function fromJSONValue(value) {
//   // the parameter - value - will look like whatever we
//   // returned from toJSONValue from above.
//   console.log(value);
//   return new Formula(value.formulaAscii);
// });
//
// Formula = function(formulaAscii) {
//   this.formulaAscii = formulaAscii;
// };
//
// Formula.prototype = {
//   constructor: Formula,
//
//   toString: function() {
//     return this.formulaAscii;
//   },
//
//   // Return a copy of this instance
//   clone: function() {
//     return new Formula(this.formulaAscii);
//   },
//
//   // Compare this instance to another instance
//   equals: function(other) {
//     if (!(other instanceof Formula))
//       return false;
//
//     return this.formulaAscii == other.formulaAscii;
//   },
//
//   // Return the name of this type which should be the same as the one
//   // padded to EJSON.addType
//   typeName: function() {
//     return "Formula";
//   },
//
//   // Serialize the instance into a JSON-compatible value. It could
//   // be an object, string, or whatever would naturally serialize to JSON
//   toJSONValue: function() {
//     return {
//       formulaAscii: this.formulaAscii
//     };
//   }
// };
//
