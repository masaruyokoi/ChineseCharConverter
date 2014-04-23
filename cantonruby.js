function cantonRuby() {
  dic = new XMLHttpRequest();
  dic.open("get", "cantondic.json", true);

  dic.onload = function() {
    var dic = JSON.parse(this.responseText);
    document.body.innerHTML.replace(/./g, function(str, p1, offset) {
      if (dic[p1] === undefined) return p1;
      return "<ruby><rb>" + p1 + "</rb><rt>" +
        dic[p1].join("<br/>") + "</rt></ruby>";
    }
  }
  dic.
}
