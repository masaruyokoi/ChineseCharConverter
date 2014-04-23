<html lang="zh-TW">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>Chinese Pinyin Translator</title>
<script>
function getPinyin(lang) {
  var data = {text: document.getElementById("origtxt").innerText, lang: lang};
  xh = XMLHttpRequest();
  xh.onreadystatementchange = function () {
    var READYSTATE_COMPLETED = 4;
    var HTTP_STATUS_OK = 200;
    if (this.readyState == READYSTATE_COMPLETED &&
      this.status == HTTP_STATUS_OK)
      document.getElementById("result").innerHTML = this.responseText;
    xh.open('POST', 'convert.php');
    xh.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    xh.send(encodeURIComponent(data));
  };
}
</script>
</head>
<body>
<form>
<p>
<textarea name="text" cols="80" rows="10" id="origtxt"></textarea>
</p>
<p>
<input type="submit" name="lang" value="Cantonese" onClick="getPinyin('cantonese')" />
<input type="submit" name="lang" value="Putonghua" onClick="getPinyin('putonghua')" />
</p>
</form>
<p id="result">(Result will be shown here)</p>

<h2>References</h2>
<ul>
<li><a href="http://www.unicode.org/Public/UNIDATA/">Unicode's Unihan</a> is based on this program.</li>
</ul>
</body>
</html>
