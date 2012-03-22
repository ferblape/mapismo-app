String.prototype.capitaliseFirstLetter = function() {
  return this.charAt(0).toUpperCase() + this.slice(1);
}

String.prototype.isBlank = function() {
  return (this.trim() == "");
}
